suppressPackageStartupMessages({
  library(MASS)
  library(nnet)
  library(HNPclassifier)
})

set.seed(123456)

n_runs <- 1000
d <- 3
T <- 5

n_train <- c(600, 600, 600, 600, 600)
n_test  <- c(10000, 10000, 10000, 10000, 10000)

alpha <- c(0.1, 0.1, 0.1, 0.1)
delta <- c(0.1, 0.1, 0.1, 0.1)

hnp_split = list(
  c(train = 0.50, threshold = 0.50, error = 0.00),
  c(train = 0.45, threshold = 0.50, error = 0.05),
  c(train = 0.45, threshold = 0.50, error = 0.05),
  c(train = 0.45, threshold = 0.50, error = 0.05),
  c(train = 0.95, threshold = 0.00, error = 0.05)
)

importance_order <- c("1", "2", "3", "4", "5")
feats <- paste0("x", seq_len(d))
base_method <- "randomforest"

sample_unit_ball_3d <- function() {
  theta <- runif(1, 0, 2 * pi)
  u <- runif(1, -1, 1)
  r <- runif(1)^(1 / 3)
  
  x <- sqrt(1 - u^2) * cos(theta)
  y <- sqrt(1 - u^2) * sin(theta)
  z <- u
  
  r * c(x, y, z)
}

make_sigma <- function(rho, d) {
  outer(seq_len(d), seq_len(d), function(p, q) rho^abs(p - q))
}

mu <- lapply(seq_len(T), function(i) sample_unit_ball_3d())
rho <- runif(T, 0, 1)
Sigma <- lapply(rho, make_sigma, d = d)

gen_data <- function(n_each) {
  
  X_list <- vector("list", T)
  y_list <- vector("list", T)
  
  for (i in seq_len(T)) {
    X_list[[i]] <- MASS::mvrnorm(
      n = n_each[i],
      mu = mu[[i]],
      Sigma = Sigma[[i]]
    )
    
    y_list[[i]] <- rep(importance_order[i], n_each[i])
  }
  
  X <- do.call(rbind, X_list)
  X <- as.data.frame(X)
  colnames(X) <- feats
  
  X$y <- factor(
    unlist(y_list),
    levels = importance_order
  )
  
  X
}

conf_classical <- vector("list", n_runs)
conf_hnp <- vector("list", n_runs)

for (r in seq_len(n_runs)) {
  
  set.seed(123 + r)
  
  Train <- gen_data(n_train)
  Test  <- gen_data(n_test)
  
  fit_classical <- base_function(
    x = Train[, feats, drop = FALSE],
    y = Train$y,
    method = base_method
  )
  
  clf_hnp <- hnp_umbrella(
    X = Train[, feats, drop = FALSE],
    Y = Train$y,
    levels = alpha,
    hnp_split = hnp_split,
    tolerances = delta,
    importance_order = importance_order,
    method = base_method,
    grid_search = TRUE,
    max_grid = 30,
    max_combinations = 2000,
    verbose = FALSE
  )
  
  sum_classical <- hnp_summary(
    classifier = fit_classical,
    X = Test[, feats, drop = FALSE],
    Y = Test$y,
    importance_order = importance_order
  )
  
  sum_hnp <- hnp_summary(
    classifier = clf_hnp,
    X = Test[, feats, drop = FALSE],
    Y = Test$y,
    importance_order = importance_order
  )
  
  conf_classical[[r]] <- sum_classical$confusion_matrix
  conf_hnp[[r]] <- sum_hnp$confusion_matrix
  
  cat("\nRun", r, "\n")
  
  cat(
    "Classical under-classification:",
    paste(
      sprintf(
        "Class %s = %.4f",
        sum_classical$class_levels[seq_len(T - 1)],
        sum_classical$under_classification_error[seq_len(T - 1)]
      ),
      collapse = ", "
    ),
    "\n"
  )
  
  cat(
    "HNP under-classification:",
    paste(
      sprintf(
        "Class %s = %.4f",
        sum_hnp$class_levels[seq_len(T - 1)],
        sum_hnp$under_classification_error[seq_len(T - 1)]
      ),
      collapse = ", "
    ),
    "\n"
  )
  
  if (r %% 50 == 0) {
    cat("Finished run", r, "\n")
  }
}

hnp_boxplot(
  conf_1 = conf_classical,
  conf_2 = conf_hnp,
  levels = alpha,
  tolerances = delta,
  name_1 = "Classical",
  name_2 = "HNP"
)



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
  file = "simulation_5_class_gaussian_hnp_randomforest.RData"
)






load("~/Desktop/code for paper HNP R/simulation_5_class_gaussian_hnp_randomforest.RData")
hnp_boxplot(
  conf_1 = conf_classical,
  conf_2 = conf_hnp,
  levels = alpha,
  tolerances = delta,
  name_1 = "Classical",
  name_2 = "H-NP"
)
