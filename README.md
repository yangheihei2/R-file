# HNPclassifier Manuscript Code Guide

This repository contains the R scripts used for the examples, simulations, and result tables in the current HNPclassifier manuscript.  
The guide is organized by manuscript section and lists the corresponding script, output files, run command, and approximate runtime.

---

## 1. Setup

Install the required R packages before running the scripts:

```r
install.packages(c("MASS", "nnet", "randomForest", "e1071"))
```

Most scripts load the package functions with:

```r
source("hnp_package_importance_order.R")
```

Runtime depends on the machine, the base learner, and the value of `n_runs`. The estimates below assume a standard laptop or desktop CPU. Scripts using random forests or SVMs with `n_runs = 1000` may take much longer.

---


## 3. Implementation examples

### 3.1 Example 1: three-class Gaussian data

| Item | Description |
|---|---|
| Script | `EXample1.R` |
| Main purpose | Demonstrates `hnp_umbrella()` with a built-in base learner. |
| Current base learner | `method = "svm"` |
| Main output | `hnp_summary()` results, including confusion matrix and error metrics. |
| Estimated time | Less than 1 minute. |

Run:

```bash
Rscript EXample1.R
```

---

### 3.2 Example 2: pretrained model, score function, and score matrix

| Item | Description |
|---|---|
| Script | `Example2_all.R` |
| Main purpose | Shows three input modes for H-NP classification. |
| Input modes | `pretrained_model`, user-defined `score_fun`, and `input_is_score = TRUE`. |
| Main output | Repeated-run summaries and `hnp_boxplot()` results. |
| Estimated time | About 2--10 minutes, depending on the repeated-run setting. |

Run:

```bash
Rscript Example2_all.R
```

---

## 4. Simulation studies

### 4.1 Simulation 1: three-class Gaussian settings T1--T4

Run all four settings and generate the manuscript table:

```bash
Rscript run_all_T1_T4.R
```

This script runs:

- `simulation_for_3_classes_T1.R`
- `simulation_for_3_classes_T2.R`
- `simulation_for_3_classes_T3.R`
- `simulation_for_3_classes_T4.R`

Main output files:

- `all_T1_T4_outputs.rds` — full outputs for T1--T4.
- `table_3class_metric_results.csv` — summary table with `R1_star`, `R2_star`, `V1`, `V2`, and `R_overall`.
- Each individual simulation also saves its own `.RData` file.

| Setting | Script | Main configuration | Estimated time |
|---|---|---|---|
| T1 | `simulation_for_3_classes_T1.R` | Balanced classes; split `(0.50/0.50), (0.45/0.50/0.05), (0.95/0/0.05)` | 5--20 minutes |
| T2 | `simulation_for_3_classes_T2.R` | Balanced classes; split `(0.70/0.30), (0.65/0.30/0.05), ...` | 5--20 minutes |
| T3 | `simulation_for_3_classes_T3.R` | Balanced classes; split `(0.30/0.70), (0.25/0.70/0.05), ...` | 5--20 minutes |
| T4 | `simulation_for_3_classes_T4.R` | Imbalanced classes, `n_train = c(300, 300, 600)` | 5--20 minutes |
| All T1--T4 | `run_all_T1_T4.R` | Runs T1 through T4 and writes the combined table | 20--80 minutes |

To run only one setting:

```bash
Rscript simulation_for_3_classes_T1.R
```

---

### 4.2 Simulation 2: five-class Gaussian data, alpha = delta = 0.1

| Base learner | Script | Output file | Estimated time |
|---|---|---|---|
| Logistic | `simulation_for_5_classes_logistic.R` | `simulation_5_class_gaussian_hnp_logistic.RData` | 10--30 minutes |
| Random forest | `simulation_for_5_classes_randomforest.R` | `simulation_5_class_gaussian_hnp_randomforest.RData` | 30--120 minutes |
| SVM | `simulation_for_5_classes_svm.R` | `simulation_5_class_gaussian_hnp_svm.RData` | 30--120 minutes |

Run example:

```bash
Rscript simulation_for_5_classes_logistic.R
```

---

### 4.3 Stricter five-class control, alpha = delta = 0.05

| Base learner | Script | Output file | Estimated time |
|---|---|---|---|
| Logistic | `simulation_5_classes_0_05_logistic.R` | `simulation_5_class_gaussian_hnp_logistic_0_05.RData` | 10--40 minutes |
| Random forest | `simulation_5_classes_0_05_randomforest.R` | `simulation_5_class_gaussian_hnp_randomforest_0_05.RData` | 40--150 minutes |
| SVM | `simulation_5_classes_0_05_svm.R` | `simulation_5_class_gaussian_hnp_svm_0_05.RData` | 40--150 minutes |

Run example:

```bash
Rscript simulation_5_classes_0_05_svm.R
```

---

## 5. Suggested running order

For a quick check, run the examples first:

```bash
Rscript EXample1.R
Rscript Example2_all.R
```

For manuscript simulation results, run the scripts in this order:

```bash
Rscript run_all_T1_T4.R
Rscript simulation_for_5_classes_logistic.R
Rscript simulation_for_5_classes_randomforest.R
Rscript simulation_for_5_classes_svm.R
Rscript simulation_5_classes_0_05_logistic.R
Rscript simulation_5_classes_0_05_randomforest.R
Rscript simulation_5_classes_0_05_svm.R
```

If a simulation is only used for checking code correctness, reduce `n_runs` first. For final manuscript results, keep the intended `n_runs` setting.
