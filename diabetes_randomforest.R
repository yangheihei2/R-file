# ============================================================
#  Diabetes HNP Benchmark — trained HNP, 100 runs, parallel
# ============================================================

library(data.table)
library(caret)
library(randomForest)
library(foreach)
library(doParallel)
library(parallel)

source("hnp_package_importance_order.R")

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

cat("Total sample size:", nrow(diabetes_data), "\n")
cat("Class distribution:\n")
print(table(diabetes_data[[label_col]]))

# ---------- 2. Experimental parameters ----------------------------

method <- "randomforest"

n_runs <- 100
n_cores <- 25

alphas <- c(0.4, 0.2)
deltas <- c(0.2, 0.2)

hnp_ratio <- 0.05
train_ratio <- hnp_ratio

hnp_split_match <- list(
  c(train = 0.5,  threshold = 0.5, error = 0.00),
  c(train = 0.45, threshold = 0.5, error = 0.05),
  c(train = 0.95, threshold = 0.0, error = 0.05)
)

# ---------- 3. Parallel experiments ----------------------------

cl <- makeCluster(n_cores)
registerDoParallel(cl)

set.seed(2025, kind = "L'Ecuyer-CMRG")

result_mat <- foreach(
  k = seq_len(n_runs),
  .combine = "rbind",
  .packages = c("data.table", "caret", "randomForest")
) %dopar% {
  
  source("hnp_package_importance_order.R")
  
  set.seed(2025 + k)
  
  hnp_idx <- createDataPartition(
    diabetes_data[[label_col]],
    p = hnp_ratio,
    list = FALSE
  )
  
  hnp_df <- diabetes_data[ hnp_idx, , drop = FALSE]
  test_df <- diabetes_data[-hnp_idx, , drop = FALSE]
  
  parts_by_class <- vector("list", length(importance_order))
  
  for (i in seq_along(importance_order)) {
    cls <- importance_order[i]
    
    Si <- hnp_df[
      as.character(hnp_df[[label_col]]) == cls,
      ,
      drop = FALSE
    ]
    
    parts_by_class[[i]] <- hnp_split_one_class(
      Si,
      hnp_split_match[[i]],
      class_i = i
    )
  }
  
  Ss_df <- do.call(rbind, lapply(parts_by_class, function(x) x[["Ss"]]))
  St_df <- do.call(rbind, lapply(parts_by_class, function(x) x[["St"]]))
  Se_df <- do.call(rbind, lapply(parts_by_class, function(x) x[["Se"]]))
  
  hnp_train_df <- rbind(St_df, Se_df)
  
  pretrained_model <- randomForest(
    x = Ss_df[, feature_cols, drop = FALSE],
    y = Ss_df[[label_col]],
    ntree = 20,
    mtry = max(1L, floor(sqrt(length(feature_cols)))),
    nodesize = 20,
    classwt = c(8, 3, 1)
  )
  
  classical_model <- randomForest(
    x = hnp_df[, feature_cols, drop = FALSE],
    y = hnp_df[[label_col]],
    ntree = 20,
    mtry = max(1L, floor(sqrt(length(feature_cols)))),
    nodesize = 20,
    classwt = c(8, 3, 1)
  )
  
  hnp_model <- hnp_umbrella(
    X = hnp_train_df[, feature_cols, drop = FALSE],
    Y = hnp_train_df[[label_col]],
    levels = alphas,
    tolerances = deltas,
    importance_order = importance_order,
    pretrained_model = pretrained_model,
    grid_search = TRUE
  )
  
  classical_out <- hnp_summary(
    classifier = classical_model,
    X = test_df[, feature_cols, drop = FALSE],
    Y = test_df[[label_col]],
    importance_order = importance_order
  )
  
  hnp_out <- hnp_summary(
    classifier = hnp_model,
    X = test_df[, feature_cols, drop = FALSE],
    Y = test_df[[label_col]],
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
