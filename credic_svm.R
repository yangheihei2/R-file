# ============================================================
#  Credit HNP Benchmark — 100 runs, parallel
# ============================================================

library(caret)
library(data.table)
library(randomForest)
library(foreach)
library(doParallel)
library(parallel)

library(HNPclassifier)

# ---------- 1. Load and preprocess data ----------------------------

data("GermanCredit")

credit_raw <- as.data.frame(GermanCredit)

label_col <- "amount"
amount_source_col <- "Amount"
original_target_col <- "Class"
importance_order <- c("1", "2", "3", "4", "5")

is_good <- as.character(credit_raw[[original_target_col]]) == "Good"
good_amount <- credit_raw[[amount_source_col]][is_good]
good_q <- quantile(good_amount, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)

new_class <- rep("1", nrow(credit_raw))

good_idx <- which(is_good)
good_vals <- credit_raw[[amount_source_col]][good_idx]

new_class[good_idx] <- ifelse(
  good_vals <= good_q[1], "2",
  ifelse(
    good_vals <= good_q[2], "3",
    ifelse(good_vals <= good_q[3], "4", "5")
  )
)

credit_raw[[label_col]] <- factor(new_class, levels = importance_order)
credit_raw[[original_target_col]] <- NULL

feature_cols <- setdiff(names(credit_raw), c("Amount", label_col))

credit_data <- credit_raw[, c(feature_cols, label_col), drop = FALSE]
credit_data <- credit_data[complete.cases(credit_data), , drop = FALSE]

credit_data[[label_col]] <- factor(
  credit_data[[label_col]],
  levels = importance_order
)

cat("Data preprocessing completed.\n")
cat("Total sample size:", nrow(credit_data), "\n")
cat("Class distribution:\n")
print(table(credit_data[[label_col]]))

# ---------- 2. Experimental parameters ----------------------------

method <- "svm"     # "logistic" | "svm" | "randomforest"

n_runs <- 100
n_cores <- 10

alphas <- c(0.2, 0.2, 0.2, 0.2)
deltas <- c(0.2, 0.2, 0.2, 0.2)

train_ratio <- 0.7

# ---------- 3. Parallel experiments ----------------------------

cl <- makeCluster(n_cores)
registerDoParallel(cl)

set.seed(2025, kind = "L'Ecuyer-CMRG")

result_mat <- foreach(
  k = seq_len(n_runs),
  .combine = "rbind",
  .packages = c("caret", "data.table", "randomForest")
) %dopar% {
  
  library(HNPclassifier)
  
  set.seed(2025 + k)
  
  train_idx <- sample(
    nrow(credit_data),
    size = floor(train_ratio * nrow(credit_data))
  )
  
  train_df <- credit_data[ train_idx, , drop = FALSE]
  test_df  <- credit_data[-train_idx, , drop = FALSE]
  
  x_train <- train_df[, feature_cols, drop = FALSE]
  y_train <- train_df[[label_col]]
  
  x_test <- test_df[, feature_cols, drop = FALSE]
  y_test <- test_df[[label_col]]
  
  classical_model <- HNPclassifier:::base_function(
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

cat("Result summarization completed.\n")

script_output <- list(
  setting = "svm",
  n_train = n_train,
  hnp_split = hnp_split,
  alpha = alpha,
  delta = delta,
  conf_classical = conf_classical,
  conf_hnp = conf_hnp
)