# HNPclassifier Manuscript Code Guide (R Journal Mapping)

This repository maps to the examples, simulations, and figure-generation workflows in your current LaTeX manuscript.  
The sections below are organized as: manuscript section -> script -> how to run.

---

## 1. Setup

### 1.1 R packages

Install dependencies first:

```r
install.packages(c("MASS", "nnet", "randomForest", "e1071"))
```

### 1.2 Notes before running

- Most scripts load core functions via `source("hnp_package_importance_order.R")`.
- Many simulation scripts use `n_runs = 1000` by default, so runtime can be long.
- Some scripts try to save `boxplot_out` without assigning it first; direct runs may fail at the save step.

---

## 2. Core Function File (Algorithm Implementation)

### `hnp_package_importance_order.R`

This is the core implementation file. It includes:

- Main H--NP interface: `hnp_umbrella()`
- Evaluation: `hnp_summary()`
- Repeated-run visualization and summary: `hnp_boxplot()`
- Key algorithmic components:  
  `hnp_upper_bound()`, `hnp_delta_search()`, `hnp_predict_proba()`, `hnp_build_score_functions()`, etc.
- Data generation and helper utilities used in examples:  
  `generate_ball_data()`, `train_nn_and_get_scores()`, etc.

---

## 3. Code for Manuscript “Implementation details”

### 3.1 Example 1 (three-class Gaussian, built-in base learner)

**Script**: `EXample1.R`

**What it does**:

- Generates three Gaussian classes (`A/B/C`)
- Trains an H--NP classifier (current script setting: `method = "svm"`)
- Shows `hnp_summary()` outputs (confusion matrix, overall accuracy, under-classification error, remaining error)

**Run**:

```bash
Rscript EXample1.R
```

---

### 3.2 Example 2 (pretrained model / score function / score matrix)

**Script**: `Example2_all.R`

**What it does**:

- Uses `generate_ball_data()` to generate three-class spherical data
- Trains a neural network and builds H--NP classifiers with three input modes:
  1. `pretrained_model = nn_model$model`
  2. `pretrained_model = score_fun`
  3. `input_is_score = TRUE` (direct score matrix input)
- Runs repeated experiments and calls `hnp_boxplot()`

**Run**:

```bash
Rscript Example2_all.R
```

---

## 4. Code for Manuscript “Simulation studies”

---

### 4.1 Simulation 1 (3-class Gaussian)

#### Setting T1
- Script: `simulation_for_3_classes_T1.R`
- Typical split: `(0.50/0.50), (0.45/0.50/0.05), (0.95/0/0.05)`
- Saved output: `simulation_3class_gaussian_hnp_T1.RData`

#### Setting T2
- Script: `simulation_for_3_classes_T2.R`
- Training-heavier split: `(0.80/0.20), (0.75/0.20/0.05), ...`
- Saved output: `simulation_3class_gaussian_hnp_T2.RData`

#### Setting T3
- Script: `simulation_for_3_classes_T3.R`
- Split: `(0.70/0.30), (0.65/0.30/0.05), ...`
- Saved output: `simulation_3class_gaussian_hnp_T3.RData`

#### Setting T4
- Script: `simiulation_for_3_classes_T4.R` (original filename spelling kept as-is)
- Split: `(0.60/0.40), (0.55/0.40/0.05), ...`
- Saved output: `simulation_3class_gaussian_hnp_T4.RData`

#### Setting T5
- Script: `simulation_for_3_classes_T5.R`
- Threshold-heavier split: `(0.30/0.70), (0.25/0.70/0.05), ...`
- Saved output: `simulation_3class_gaussian_hnp_T5.RData`

#### Setting T6 (class imbalance)
- Script: `simulation_for_3_classes_T6.R`
- Class sizes: `n_train = c(300, 300, 600)`
- Saved output: `simulation_3class_gaussian_hnp_T6.RData`

**Run example**:

```bash
Rscript simulation_for_3_classes_T1.R
```

---

### 4.2 Simulation 2 (5-class Gaussian, alpha=delta=0.1)

#### Logistic
- Script: `simulation_for_5_classes_logistic.R`
- Output: `simulation_5_class_gaussian_hnp_logistic.RData`

#### Random Forest
- Script: `simulation_for_5_classes_randomforest.R`
- Output: `simulation_5_class_gaussian_hnp_randomforest.RData`

#### SVM
- Script: `simulation_for_5_classes_svm.R`
- Output: `simulation_5_class_gaussian_hnp_svm.RData`

**Run example**:

```bash
Rscript simulation_for_5_classes_logistic.R
```

---

### 4.3 Stricter 5-class control (alpha=delta=0.05)

#### Logistic
- Script: `simulation_5_classes_0_05_logistic.R`
- Output: `simulation_5_class_gaussian_hnp_logistic_0_05.RData`

#### Random Forest
- Script: `simulation_5_classes_0_05_randomforest.R`
- Output: `simulation_5_class_gaussian_hnp_randomforest_0_05.RData`

#### SVM
- Script: `simulation_5_classes_0_05_svm.R`
- Output: `simulation_5_class_gaussian_hnp_svm_0_05.RData`

**Run example**:

```bash
Rscript simulation_5_classes_0_05_svm.R
```

---

## 5. One-click Reproducibility (optional)

The repository is currently organized as one script per experiment. If you want, I can add:

- `run_all.R`: execute all experiments in manuscript order
- `run_fast.R`: run quick smoke tests with smaller `n_runs` (e.g., 10 or 20)

This usually makes R Journal reproducibility checks smoother.