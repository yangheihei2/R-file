# ============================================================
#  Diabetes HNP Benchmark — 100 runs, parallel (25 cores)
# ============================================================

library(caret)
library(data.table)
library(foreach)
library(doParallel)
library(parallel)

library(HNPclassifier)

# ---------- 1. Load and preprocess data ----------------------------

diabetes_raw <- as.data.frame(
  fread("diabetes_012_health_indicators_BRFSS2015.csv")
)

label_col <- "Diabetes_012"
importance_order <- c("1", "2", "3")

diabetes_raw[[label_col]] <- as.character(diabetes_raw[[label_col]])
diabetes_raw <- diabetes_raw[
  diabetes_raw[[label_col]] %in% c("1", "2", "0"), 
  ,
  drop = FALSE
]

diabetes_raw[[label_col]][diabetes_raw[[label_col]] == "0"] <- "3"

feature_cols <- setdiff(names(diabetes_raw), label_col)

diabetes_raw[feature_cols] <- lapply(diabetes_raw[feature_cols], as.numeric)

diabetes_data <- diabetes_raw[, c(feature_cols, label_col), drop = FALSE]
diabetes_data <- diabetes_data[complete.cases(diabetes_data), , drop = FALSE]
diabetes_data[[label_col]] <- factor(
  diabetes_data[[label_col]],
  levels = importance_order
)

cat("Data preprocessing completed.\n")
print(table(diabetes_data[[label_col]]))

# ---------- 2. Experimental parameters ----------------------------

method <- "svm"     # "logistic" | "svm" | "randomforest"
n_runs <- 100
n_cores <- 10

alphas <- c(0.4, 0.2)
deltas <- c(0.2, 0.2)

train_ratio <- 0.05

# ---------- 3. Parallel experiments ----------------------------

cl <- makeCluster(n_cores)
registerDoParallel(cl)

set.seed(2025, kind = "L'Ecuyer-CMRG")

result_mat <- foreach(
  k = seq_len(n_runs),
  .combine = "rbind",
  .packages = c("data.table", "caret")
) %dopar% {
  
  source("hnp_package_importance_order.R")
  
  set.seed(2025 + k)
  
  train_idx <- sample(
    nrow(diabetes_data),
    size = floor(train_ratio * nrow(diabetes_data))
  )
  
  train_df <- diabetes_data[ train_idx, , drop = FALSE]
  test_df  <- diabetes_data[-train_idx, , drop = FALSE]
  
  x_train <- train_df[, feature_cols, drop = FALSE]
  y_train <- train_df[[label_col]]
  
  x_test <- test_df[, feature_cols, drop = FALSE]
  y_test <- test_df[[label_col]]
  
  classical_model <- base_function(
    x = x_train,
    y = y_train,
    method = method
  )
  
  hnp_model <- hnp_umbrella(
    X = x_train,
    Y = y_train,
    levels = alphas,
    tolerances = deltas,
    importance_order = importance_order,
    method = method
  )
  
  classical_out <- hnp_summary(
    classifier = classical_model,
    X = x_test,
    Y = y_test,
    importance_order = importance_order
  )
  
  hnp_out <- hnp_summary(
    classifier = hnp_model,
    X = x_test,
    Y = y_test,
    importance_order = importance_order
  )
  
  cm_classical <- as.matrix(
    classical_out$confusion_matrix[importance_order, importance_order]
  )
  
  cm_hnp <- as.matrix(
    hnp_out$confusion_matrix[importance_order, importance_order]
  )
  
  c(
    k,
    as.vector(t(cm_classical)),
    as.vector(t(cm_hnp))
  )
}

stopCluster(cl)

cat("Experiments completed.\n")

# ---------- 4. Reconstruct confusion matrices ----------------------------

result_df <- as.data.frame(result_mat)

n_cls <- length(importance_order)
n_cells <- n_cls^2

colnames(result_df) <- c(
  "run_id",
  paste0("classical_", seq_len(n_cells)),
  paste0("hnp_", seq_len(n_cells))
)

to_conf_list <- function(df, prefix) {
  cols <- paste0(prefix, "_", seq_len(n_cells))
  
  lapply(seq_len(nrow(df)), function(i) {
    matrix(
      as.numeric(df[i, cols]),
      nrow = n_cls,
      byrow = TRUE,
      dimnames = list(
        True = importance_order,
        Predicted = importance_order
      )
    )
  })
}

conf_classical <- to_conf_list(result_df, "classical")
conf_hnp <- to_conf_list(result_df, "hnp")

# ---------- 5. Save results and boxplot ----------------------------

alpha <- alphas
delta <- deltas
base_method <- method

mu <- NULL
rho <- NULL
Sigma <- NULL

model_tag <- if (exists("hnp_split_match")) {
  paste0("trained_", base_method)
} else {
  base_method
}

output_stem <- sprintf(
  "Diabetes_HNP_Boxplot_%s_%druns_%dtrain",
  model_tag,
  n_runs,
  as.integer(round(train_ratio * 100))
)

png(
  filename = paste0(output_stem, ".png"),
  width = 1800,
  height = 1200,
  res = 180
)

boxplot_out <- hnp_boxplot(
  conf_1 = conf_classical,
  conf_2 = conf_hnp,
  levels = alpha,
  tolerances = delta,
  name_1 = "Classical",
  name_2 = "H-NP"
)

dev.off()

save(
  mu,
  rho,
  Sigma,
  alpha,
  delta,
  importance_order,
  base_method,
  conf_classical,
  conf_hnp,
  boxplot_out,
  file = paste0(output_stem, ".RData")
)

cat("Results saved to:", paste0(output_stem, ".RData"), "\n")
cat("Boxplot saved to:", paste0(output_stem, ".png"), "\n")
