# ============================================================
# Run German Credit experiments and generate plots plus summary table
# ============================================================

library(HNPclassifier)

experiment_scripts <- list(
  list(
    label = "Random forest",
    script = "credic_randomforest.R"
  ),
  list(
    label = "SVM",
    script = "credic_svm.R"
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
  gc()
  
  out <- env$script_output
  out$label <- item$label
  out
}

metric_by_run <- function(conf_list, importance_order) {
  n_cls <- length(importance_order)
  n_risk <- n_cls - 1L
  
  do.call(rbind, lapply(conf_list, function(cm) {
    cm <- as.matrix(cm)
    cm <- cm[importance_order, importance_order, drop = FALSE]
    
    r_under <- vapply(seq_len(n_risk), function(k) {
      if (sum(cm[k, ]) == 0) {
        return(NA_real_)
      }
      sum(cm[k, (k + 1):n_cls]) / sum(cm[k, ])
    }, numeric(1))
    
    names(r_under) <- paste0("R", seq_len(n_risk), "star")
    
    c(
      r_under,
      Roverall = 1 - sum(diag(cm)) / sum(cm)
    )
  }))
}

make_summary_rows <- function(res) {
  importance_order <- res$importance_order
  alpha <- res$alpha
  n_risk <- length(importance_order) - 1L
  
  classical_metrics <- metric_by_run(res$conf_classical, importance_order)
  hnp_metrics <- metric_by_run(res$conf_hnp, importance_order)
  
  out <- data.frame(
    BaseMethod = c(res$label, ""),
    Paradigm = c("Classical", "H-NP"),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(n_risk)) {
    r_col <- paste0("R", i, "star")
    out[[r_col]] <- c(
      mean(classical_metrics[, r_col], na.rm = TRUE),
      mean(hnp_metrics[, r_col], na.rm = TRUE)
    )
  }
  
  for (i in seq_len(n_risk)) {
    r_col <- paste0("R", i, "star")
    v_col <- paste0("V", i)
    out[[v_col]] <- c(
      mean(classical_metrics[, r_col] > alpha[i], na.rm = TRUE),
      mean(hnp_metrics[, r_col] > alpha[i], na.rm = TRUE)
    )
  }
  
  out$Roverall <- c(
    mean(classical_metrics[, "Roverall"], na.rm = TRUE),
    mean(hnp_metrics[, "Roverall"], na.rm = TRUE)
  )
  
  out
}



make_boxplot <- function(res) {
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



summary_table <- do.call(
  rbind,
  lapply(results, make_summary_rows)
)

summary_table_print <- summary_table
num_cols <- 3:ncol(summary_table_print)
summary_table_print[num_cols] <- lapply(
  summary_table_print[num_cols],
  function(x) sprintf("%.3f", as.numeric(x))
)


lapply(results, make_boxplot)
print(summary_table_print, row.names = FALSE)


