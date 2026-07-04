# ============================================================
# Run diabetes experiments in sequence and generate final table
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
  
  if (requireNamespace("foreach", quietly = TRUE)) {
    foreach::registerDoSEQ()
  }
  
  required_objects <- c("conf_classical", "conf_hnp", "alphas", "deltas")
  missing_objects <- required_objects[
    !vapply(required_objects, exists, logical(1), envir = env, inherits = FALSE)
  ]
  
  if (length(missing_objects) > 0) {
    stop(
      item$script,
      " did not create required object(s): ",
      paste(missing_objects, collapse = ", ")
    )
  }
  
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
  if (length(conf_list) == 0) {
    stop("confusion-matrix list is empty.")
  }
  
  do.call(rbind, lapply(conf_list, function(cm) {
    cm <- as.matrix(cm)
    cm <- cm[c("1", "2", "3"), c("1", "2", "3"), drop = FALSE]
    
    c(
      R1star = sum(cm["1", c("2", "3")]) / sum(cm["1", ]),
      R2star = cm["2", "3"] / sum(cm["2", ]),
      Roverall = 1 - sum(diag(cm)) / sum(cm)
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
  on.exit(dev.off(), add = TRUE)
  
  par(mar = c(0, 0, 0, 0), family = "serif")
  
  col_widths <- c(3.5, 1.45, 0.9, 0.9, 0.75, 0.75, 1.05)
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
    text(x_centers[j], total_height - 0.5, headers[[j]], cex = 0.95)
  }
  
  for (i in seq_len(n_rows)) {
    y <- total_height - 1 - (i - 0.5)
    
    row_values <- c(
      tab$Paradigm[i],
      sprintf("%.3f", tab$R1star[i]),
      sprintf("%.3f", tab$R2star[i]),
      sprintf("%.3f", tab$V1[i]),
      sprintf("%.3f", tab$V2[i]),
      sprintf("%.3f", tab$Roverall[i])
    )
    
    for (j in 2:7) {
      text(x_centers[j], y, row_values[j - 1], cex = 0.9)
    }
  }
  
  for (row_id in seq(1, n_rows, by = 2)) {
    y <- total_height - 1 - row_id
    text(x_centers[1], y, tab$BaseMethod[row_id], cex = 0.9)
  }
  
  segments(0, total_height, total_width, total_height, lwd = 1.4)
  segments(0, total_height - 1, total_width, total_height - 1, lwd = 1.1)
  segments(0, 0, total_width, 0, lwd = 1.4)
  
  for (r in seq(2, n_rows - 1, by = 2)) {
    y <- total_height - 1 - r
    segments(0, y, total_width, y, lwd = 1.1)
  }
  
  vertical_lines <- x_edges[c(2, 3, 5, 7)]
  for (x in vertical_lines) {
    segments(x, 0, x, total_height, lwd = 1.1)
  }
  
  invisible(output_file)
}

make_boxplot <- function(res) {
  png(res$boxplot, width = 1800, height = 1200, res = 180)
  on.exit(dev.off(), add = TRUE)
  
  hnp_boxplot(
    conf_1 = res$conf_classical,
    conf_2 = res$conf_hnp,
    levels = res$alpha,
    tolerances = res$delta,
    name_1 = "Classical",
    name_2 = "H-NP"
  )
}

results <- lapply(experiment_scripts, run_one_experiment)

summary_table <- do.call(rbind, lapply(results, make_summary_rows))

draw_summary_table(
  summary_table,
  "Diabetes_HNP_summary_table.png"
)

invisible(lapply(results, make_boxplot))

print_summary <- summary_table
print_summary[, 3:ncol(print_summary)] <- lapply(
  print_summary[, 3:ncol(print_summary)],
  function(x) sprintf("%.3f", x)
)

print(print_summary, row.names = FALSE)

cat("\nSummary table saved to: Diabetes_HNP_summary_table.png\n")
cat("Boxplots saved to:\n")
for (item in experiment_scripts) {
  cat("  ", item$boxplot, "\n", sep = "")
}
