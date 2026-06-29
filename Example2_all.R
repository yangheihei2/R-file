set.seed(123)

library(HNPclassifier)

n <- 500; d <- 3
radii <- c(3, 3, 3); centers <- replicate(3, runif(d, -2, 2), simplify = FALSE)



Train     <- generate_ball_data(n, centers, radii)
Threshold <- generate_ball_data(n, centers, radii)
Test      <- generate_ball_data(n, centers, radii)

head(Train, 2)

feats <- paste0("x", 1:3)


nn_model <- train_nn_and_get_scores(
  X = Train[, feats],
  Y = Train$y
)

nn_score <- predict(nn_model$model, newdata = Train[, feats], type = "raw")
head(nn_score, 2)


clf_model <- hnp_umbrella(
  X = Threshold[, feats, drop = FALSE],
  Y = Threshold$y,
  levels = c(0.1, 0.1),
  tolerances = c(0.1, 0.1),
  importance_order = c("C", "A", "B"),
  pretrained_model = nn_model$model,
  grid_search = FALSE
)

attr(clf_model, "method")


out_model <- hnp_summary(
  classifier = clf_model,
  X = Test[, feats],
  Y = Test$y )

print(out_model$confusion_matrix)

print(out_model$under_classification_error)

print(out_model$overall_accuracy)



score_fun <- function(X) {
  out <- predict(nn_model$model, newdata = as.data.frame(X), type = "raw")
}

head(score_fun(Train[, feats]), 2)


clf_function <- hnp_umbrella(
  X = Threshold[, feats],
  Y = Threshold$y,
  levels = c(0.1, 0.1),
  tolerances = c(0.1, 0.1),
  importance_order = c("C", "A", "B"),
  grid_search = FALSE,
  pretrained_model = score_fun

)

out_function <- hnp_summary(
  classifier = clf_function,
  X = Test[, feats],
  Y = Test$y)

print(out_function$confusion_matrix)


score_threshold <- score_fun(Threshold[, feats])
score_test      <- score_fun(Test[, feats])

clf_score <- hnp_umbrella(
  X = score_threshold,
  Y = Threshold$y,
  levels = c(0.1, 0.1),
  tolerances = c(0.1, 0.1),
  importance_order = c("C", "A", "B"),
  grid_search = FALSE,
  input_is_score = TRUE
)

out_score <- hnp_summary(
  classifier = clf_score,
  X = score_test,
  Y = Test$y)

print(out_score$confusion_matrix)



conf_classical <- list(); conf_hnp <- list()
alphas <- c(0.1, 0.1); deltas <- c(0.1, 0.1); class_order <- c("C", "A", "B")
for (i in seq_len(500)) {
  Train     <- generate_ball_data(n, centers, radii)
  Threshold <- generate_ball_data(n, centers, radii)
  Test      <- generate_ball_data(n*100, centers, radii)
  base_model <- train_nn_and_get_scores(X = Train[, feats], Y = Train$y)
  clf_hnp <- hnp_umbrella(X = Threshold[, feats], Y = Threshold$y,
                          levels = alphas, tolerances = deltas, importance_order =  class_order,
                          pretrained_model =  base_model$model, grid_search = FALSE)
  
  out_classical <- hnp_summary(classifier =  base_model$model, X = Test[, feats], 
                               Y = Test$y, importance_order = class_order)
  out_hnp <- hnp_summary(classifier = clf_hnp, X = Test[, feats],
                         Y = Test$y, importance_order = class_order)
  
  conf_classical[[i]] <- out_classical$confusion_matrix
  conf_hnp[[i]]  <- out_hnp$confusion_matrix }


hnp_boxplot(conf_1 = conf_classical, conf_2 = conf_hnp, levels = alphas, tolerances = deltas)


conf_classical <- list(); conf_hnp <- list()
alphas <- c(0.2,0.05); deltas <- c( 0.05, 0.2); class_order <- c("C", "A", "B")
for (i in seq_len(500)) {
  Train     <- generate_ball_data(n, centers, radii)
  Threshold <- generate_ball_data(n, centers, radii)
  Test      <- generate_ball_data(n*100, centers, radii)
  base_model <- train_nn_and_get_scores(X = Train[, feats], Y = Train$y)
  clf_hnp <- hnp_umbrella(X = Threshold[, feats], Y = Threshold$y,
                          levels = alphas, tolerances = deltas, importance_order =  class_order,
                          pretrained_model =  base_model$model, grid_search = FALSE)
  
  out_classical <- hnp_summary(classifier =  base_model$model, X = Test[, feats], 
                               Y = Test$y, importance_order = class_order)
  out_hnp <- hnp_summary(classifier = clf_hnp, X = Test[, feats],
                         Y = Test$y, importance_order = class_order)
  
  conf_classical[[i]] <- out_classical$confusion_matrix
  conf_hnp[[i]]  <- out_hnp$confusion_matrix }


hnp_boxplot(conf_1 = conf_classical, conf_2 = conf_hnp, levels = alphas, tolerances = deltas)


