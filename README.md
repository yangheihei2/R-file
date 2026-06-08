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
| Estimated time | About 1--2 minutes, depending on the repeated-run setting. |

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
| T1 | `simulation_for_3_classes_T1.R` | Balanced classes; split `(0.50/0.50), (0.45/0.50/0.05), (0.95/0/0.05)` | 1--3 minutes |
| T2 | `simulation_for_3_classes_T2.R` | Balanced classes; split `(0.70/0.30), (0.65/0.30/0.05), ...` | 1--3 minutes |
| T3 | `simulation_for_3_classes_T3.R` | Balanced classes; split `(0.30/0.70), (0.25/0.70/0.05), ...` | 1--3 minutes |
| T4 | `simulation_for_3_classes_T4.R` | Imbalanced classes, `n_train = c(300, 300, 600)` | 1--3 minutes |
| All T1--T4 | `run_all_T1_T4.R` | Runs T1 through T4 and writes the combined table | 4--12 minutes |

To run only one setting:

```bash
Rscript simulation_for_3_classes_T1.R
```

**Output format**

After `run_all_T1_T4.R` finishes, it prints and saves a summary table (`metric_table_print` / `table_3class_metric_results.csv`) with the following columns:

| Column | Meaning |
|---|---|
| `Paradigm` | `Classical` (base learner only) or `H-NP` (H-NP-adjusted classifier). |
| `Setting` | `C1` / `C2` for classical baselines; `T1`--`T4` for H-NP split settings. |
| `R1_star` | Average first under-classification error. |
| `R2_star` | Average second under-classification error. |
| `V1` | Violation rate for the first under-classification error (proportion of runs exceeding the target level). |
| `V2` | Violation rate for the second under-classification error. |
| `R_overall` | Average overall misclassification error. |

Example console output:

```
  Paradigm Setting R1_star R2_star    V1    V2 R_overall
 Classical      C1   0.222   0.344 1.000 1.000     0.362
 Classical      C2   0.285   0.709 1.000 1.000     0.400
      H-NP      T1   0.034   0.051 0.096 0.001     0.587
      H-NP      T2   0.031   0.039 0.098 0.002     0.597
      H-NP      T3   0.036   0.057 0.082 0.002     0.581
      H-NP      T4   0.031   0.037 0.102 0.004     0.598
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
