library(HNPclassifier)
library(MASS)

set.seed(123)
d <- 4

feats <- paste0("x", seq_len(d))
labels <- c("A", "B", "C")
n_each_train <- c(500, 500, 500)
n_each_test <- c(500, 500, 500)

means <- lapply(1:3, function(i) runif(d, -1.5, 1.5))
sigma2 <- runif(3, 1, 3)
Sigmas <- lapply(sigma2, function(s) diag(s, d))

X1 <- mvrnorm(n_each_train[1], mu = means[[1]], Sigma = Sigmas[[1]])
X2 <- mvrnorm(n_each_train[2], mu = means[[2]], Sigma = Sigmas[[2]])
X3 <- mvrnorm(n_each_train[3], mu = means[[3]], Sigma = Sigmas[[3]])
T1t <- mvrnorm(n_each_test[1], mu = means[[1]], Sigma = Sigmas[[1]])
T2t <- mvrnorm(n_each_test[2], mu = means[[2]], Sigma = Sigmas[[2]])
T3t <- mvrnorm(n_each_test[3], mu = means[[3]], Sigma = Sigmas[[3]])
Train <- data.frame(rbind(X1, X2, X3)); Test <- data.frame(rbind(T1t, T2t, T3t))
names(Train) <- feats; names(Test) <- feats
Train$y <- factor(  c(rep("A", nrow(X1)), rep("B", nrow(X2)), rep("C", nrow(X3))),
                    levels = c("A", "B", "C"))
Test$y <- factor(  c(rep("A", nrow(T1t)), rep("B", nrow(T2t)), rep("C", nrow(T3t))),
                   levels = c("A", "B", "C"))


head(Train, 2)




set.seed(1234)
clf_hnp <- hnp_umbrella( X = Train[, feats, drop = FALSE], Y = Train$y, 
                         levels = c(0.1, 0.1), tolerances = c(0.1, 0.1), 
                         importance_order = c("A", "B", "C"),
                         method = "svm", max_grid = 30)

print(clf_hnp)

prediction <- clf_hnp(Test[, feats])
head(prediction)


attr(clf_hnp, "label_mapping")

attr(clf_hnp, "objective")




out_metrics <- hnp_summary(
  classifier = clf_hnp,
  X = Test[, feats, drop = FALSE],
  Y = Test$y
)

print(out_metrics$confusion_matrix)

print(out_metrics$overall_accuracy)

print(out_metrics$under_classification_error)

print(out_metrics$remaining_error)

head(out_metrics$predictions, 2)
