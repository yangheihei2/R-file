# ============================================================
# Run T1--T4 and generate the metric table
# ============================================================

rm(list = ls())

run_r_file <- function(file) {
  env <- new.env(parent = globalenv())
  source(file, local = env, chdir = TRUE)
  get("script_output", envir = env)
}

T1_out <- run_r_file("simulation_for_3_classes_T1.R")
T2_out <- run_r_file("simulation_for_3_classes_T2.R")
T3_out <- run_r_file("simulation_for_3_classes_T3.R")
T4_out <- run_r_file("simulation_for_3_classes_T4.R")

all_results <- list(
  T1 = T1_out,
  T2 = T2_out,
  T3 = T3_out,
  T4 = T4_out
)

same_conf_list <- function(a, b) {
  all(vapply(seq_along(a), function(i) {
    identical(as.matrix(a[[i]]), as.matrix(b[[i]]))
  }, logical(1)))
}

C1_check <- same_conf_list(T1_out$conf_classical, T2_out$conf_classical) &&
  same_conf_list(T1_out$conf_classical, T3_out$conf_classical)

cat("Check whether Classical outputs of T1, T2, and T3 are identical: ",
    C1_check, "\n", sep = "")

saveRDS(all_results, file = "all_T1_T4_outputs.rds")

alpha <- T1_out$alpha
Tn <- nrow(as.matrix(T1_out$conf_classical[[1]]))

one_conf_metrics <- function(CM) {
  CM <- as.matrix(CM)
  N <- sum(CM)
  
  overall_error <- 1 - sum(diag(CM)) / N
  
  under <- numeric(Tn)
  
  for (k in seq_len(Tn)) {
    nk <- sum(CM[k, ])
    
    under[k] <- if (k < Tn) {
      sum(CM[k, (k + 1):Tn, drop = FALSE]) / nk
    } else {
      0
    }
  }
  
  c(
    R1_star = under[1],
    R2_star = under[2],
    R_overall = overall_error
  )
}

summarise_conf_list <- function(conf_list) {
  M <- t(vapply(conf_list, one_conf_metrics, numeric(3)))
  
  data.frame(
    R1_star = mean(M[, "R1_star"]),
    R2_star = mean(M[, "R2_star"]),
    V1 = mean(M[, "R1_star"] > alpha[1]),
    V2 = mean(M[, "R2_star"] > alpha[2]),
    R_overall = mean(M[, "R_overall"])
  )
}

make_metric_row <- function(paradigm, setting, conf_list) {
  data.frame(
    Paradigm = paradigm,
    Setting = setting,
    summarise_conf_list(conf_list)
  )
}

metric_table <- rbind(
  make_metric_row("Classical", "C1", T1_out$conf_classical),
  make_metric_row("Classical", "C2", T4_out$conf_classical),
  make_metric_row("H-NP", "T1", T1_out$conf_hnp),
  make_metric_row("H-NP", "T2", T2_out$conf_hnp),
  make_metric_row("H-NP", "T3", T3_out$conf_hnp),
  make_metric_row("H-NP", "T4", T4_out$conf_hnp)
)

metric_table_print <- metric_table
metric_table_print[, 3:7] <- round(metric_table_print[, 3:7], 3)

print(metric_table_print, row.names = FALSE)

write.csv(
  metric_table_print,
  file = "table_3class_metric_results.csv",
  row.names = FALSE
)