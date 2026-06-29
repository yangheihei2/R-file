library(HNPclassifier)

scripts <- c(
  "simulation_5_classes_0_05_logistic.R",
  "simulation_5_classes_0_05_randomforest.R",
  "simulation_5_classes_0_05_svm.R"
)

method_labels <- c(
  logistic = "Logistic regression",
  randomforest = "Random forest",
  svm = "SVM"
)

run_one <- function(file) {
  env <- new.env(parent = globalenv())
  source(file, local = env, chdir = TRUE)
  env$script_output
}

outs <- lapply(scripts, run_one)
names(outs) <- sapply(outs, `[[`, "base_method")

make_plot_and_table <- function(out) {
  method <- out$base_method
  
  
  boxplot_out <- hnp_boxplot(
    conf_1 = out$conf_classical,
    conf_2 = out$conf_hnp,
    levels = out$alpha,
    tolerances = out$delta,
    name_1 = "Classical",
    name_2 = "H-NP"
  )
  
  # dev.off()
  
  boxplot_out
}

boxplot_outputs <- lapply(outs, make_plot_and_table)

extract_rows <- function(method) {
  x <- boxplot_outputs[[method]]
  
  cw <- x$classwise
  ov <- x$overall
  
  classical_cols <- paste0("Classical_Class_", 1:4)
  hnp_cols <- paste0("H-NP_Class_", 1:4)
  
  classical <- data.frame(
    `Base method` = method_labels[method],
    Paradigm = "Classical",
    `R1*` = cw["under-classification error mean", classical_cols[1]],
    `R2*` = cw["under-classification error mean", classical_cols[2]],
    `R3*` = cw["under-classification error mean", classical_cols[3]],
    `R4*` = cw["under-classification error mean", classical_cols[4]],
    V1 = cw["violation rate", classical_cols[1]],
    V2 = cw["violation rate", classical_cols[2]],
    V3 = cw["violation rate", classical_cols[3]],
    V4 = cw["violation rate", classical_cols[4]],
    `R_overall` = ov["overall misclassification error mean", "Classical"],
    check.names = FALSE
  )
  
  hnp <- data.frame(
    `Base method` = "",
    Paradigm = "H-NP",
    `R1*` = cw["under-classification error mean", hnp_cols[1]],
    `R2*` = cw["under-classification error mean", hnp_cols[2]],
    `R3*` = cw["under-classification error mean", hnp_cols[3]],
    `R4*` = cw["under-classification error mean", hnp_cols[4]],
    V1 = cw["violation rate", hnp_cols[1]],
    V2 = cw["violation rate", hnp_cols[2]],
    V3 = cw["violation rate", hnp_cols[3]],
    V4 = cw["violation rate", hnp_cols[4]],
    `R_overall` = ov["overall misclassification error mean", "H-NP"],
    check.names = FALSE
  )
  
  rbind(classical, hnp)
}

result_table <- do.call(
  rbind,
  lapply(names(outs), extract_rows)
)

num_cols <- 3:ncol(result_table)
result_table[num_cols] <- lapply(result_table[num_cols], function(x) sprintf("%.3f", as.numeric(x)))

print(result_table, row.names = FALSE)
lapply(outs, make_plot_and_table)
