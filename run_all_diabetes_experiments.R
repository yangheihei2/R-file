# ============================================================
#  Run Three Diabetes HNP Experiments + Summary Table + Boxplots
# ============================================================

source("hnp_package_importance_order.R")

experiment_scripts <- list(
  list(
    label = "Logistic regression",
    script = "diabetes_logistic.R",
    boxplot = "Diabetes_HNP_Boxplot_logistic_100runs_5train.png"
  ),
  list(
    label = "SVM",
    script = "diabetes_svm.R",
    boxplot = "Diabetes_HNP_Boxplot_svm_100runs_5train.png"
  ),
  list(
    label = "Random forest (pre-trained)",
    script = "diabetes_randomforest.R",
    boxplot = "Diabetes_HNP_Boxplot_trained_randomforest_100runs_5train.png"
  )
)

run_one_experiment <- function(item) {
  env <- new.env(parent = globalenv())
  
  cat("\n============================================================\n")
  cat("Running:", item$label, "\n")
  cat("Script :", item$script, "\n")
  cat("============================================================\n")
  
  source(item$script, local = env, chdir = TRUE)
  
  foreach::registerDoSEQ()
  gc()
  
  list(
    label = item$label,
    script = item$script,
    boxplot = item$boxplot,
    conf_classical = env$conf_classical,
    conf_hnp = env$conf_hnp,
    alpha = env$alphas,
    delta = env$deltas
  )
}

metric_by_run <- function(conf_list) {
  do.call(rbind, lapply(conf_list, function(cm) {
    cm <- as.matrix(cm)
    
    r1_star <- sum(cm["1", c("2", "3")]) / sum(cm["1", ])
    r2_star <- cm["2", "3"] / sum(cm["2", ])
    r_overall <- 1 - sum(diag(cm)) / sum(cm)
    
    c(
      R1star = r1_star,
      R2star = r2_star,
      Roverall = r_overall
    )
  }))
}

make_summary_rows <- function(res) {
  classical_metrics <- metric_by_run(res$conf_classical)
  hnp_metrics <- metric_by_run(res$conf_hnp)
  
  data.frame(
    BaseMethod = c(res$label, ""),
    Paradigm = c("Classical", "H-NP"),
    R1star = c(
      mean(classical_metrics[, "R1star"]),
      mean(hnp_metrics[, "R1star"])
    ),
    R2star = c(
      mean(classical_metrics[, "R2star"]),
      mean(hnp_metrics[, "R2star"])
    ),
    V1 = c(
      mean(classical_metrics[, "R1star"] > res$alpha[1]),
      mean(hnp_metrics[, "R1star"] > res$alpha[1])
    ),
    V2 = c(
      mean(classical_metrics[, "R2star"] > res$alpha[2]),
      mean(hnp_metrics[, "R2star"] > res$alpha[2])
    ),
    Roverall = c(
      mean(classical_metrics[, "Roverall"]),
      mean(hnp_metrics[, "Roverall"])
    ),
    stringsAsFactors = FALSE
  )
}

draw_summary_table <- function(tab, output_file) {
  png(output_file, width = 2200, height = 560, res = 300)
  
  par(mar = c(0, 0, 0, 0), family = "serif")
  
  col_widths <- c(3.4, 1.55, 0.85, 0.85, 0.75, 0.75, 1.05)
  x_edges <- c(0, cumsum(col_widths))
  x_centers <- (x_edges[-1] + x_edges[-length(x_edges)]) / 2
  
  n_rows <- nrow(tab)
  total_height <- n_rows + 1
  total_width <- sum(col_widths)
  
  plot(
    c(0, total_width),
    c(0, total_height),
    type = "n",
    axes = FALSE,
    xlab = "",
    ylab = "",
    xaxs = "i",
    yaxs = "i"
  )
  
  headers <- list(
    "Base method",
    "Paradigm",
    expression(R["1*"]),
    expression(R["2*"]),
    expression(V[1]),
    expression(V[2]),
    expression(R[overall])
  )
  
  for (j in seq_along(headers)) {
    text(
      x = x_centers[j],
      y = total_height - 0.5,
      labels = headers[[j]],
      cex = 0.95
    )
  }
  
  for (i in seq_len(n_rows)) {
    y <- total_height - 1 - (i - 0.5)
    
    values <- c(
      tab$Paradigm[i],
      sprintf("%.3f", tab$R1star[i]),
      sprintf("%.3f", tab$R2star[i]),
      sprintf("%.3f", tab$V1[i]),
      sprintf("%.3f", tab$V2[i]),
      sprintf("%.3f", tab$Roverall[i])
    )
    
    for (j in 2:7) {
      text(
        x = x_centers[j],
        y = y,
        labels = values[j - 1],
        cex = 0.9
      )
    }
  }
  
  base_rows <- seq(1, n_rows, by = 2)
  
  for (row_id in base_rows) {
    y <- total_height - 1 - row_id
    
    text(
      x = x_centers[1],
      y = y,
      labels = tab$BaseMethod[row_id],
      cex = 0.9
    )
  }
  
  segments(0, total_height, total_width, total_height, lwd = 1.4)
  segments(0, total_height - 1, total_width, total_height - 1, lwd = 1.1)
  
  for (r in seq(2, n_rows, by = 2)) {
    y <- total_height - 1 - r
    segments(0, y, total_width, y, lwd = 1.1)
  }
  
  vertical_lines <- x_edges[c(2, 3, 5, 7)]
  
  for (x in vertical_lines) {
    segments(x, 0, x, total_height, lwd = 1.1)
  }
  
  dev.off()
}

make_boxplot <- function(res) {
  png(
    filename = res$boxplot,
    width = 1800,
    height = 1200,
    res = 180
  )
  
  hnp_boxplot(
    conf_1 = res$conf_classical,
    conf_2 = res$conf_hnp,
    levels = res$alpha,
    tolerances = res$delta,
    name_1 = "Classical",
    name_2 = "H-NP"
  )
  
  dev.off()
}

results <- lapply(experiment_scripts, run_one_experiment)

summary_table <- do.call(
  rbind,
  lapply(results, make_summary_rows)
)

draw_summary_table(
  summary_table,
  "Diabetes_HNP_summary_table.png"
)

invisible(lapply(results, make_boxplot))

print(summary_table)

cat("\nSummary table saved to: Diabetes_HNP_summary_table.png\n")
cat("Boxplots saved to:\n")
for (item in experiment_scripts) {
  cat("  ", item$boxplot, "\n", sep = "")
}
