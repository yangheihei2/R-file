# HNPclassifier: An R Package for Hierarchical Neyman-Pearson Classification

This repository contains the R scripts used for the examples, simulations, and real-data experiments in the corresponding paper.

---

## Computing Environment

The runtimes and results reported in this guide were generated on the following local environment:

| Item | Version / specification |
|---|---|
| Computer | MacBook Air |
| Model identifier | Mac17,3 |
| Chip | Apple M5 |
| CPU cores | 10 cores, 4 performance and 6 efficiency |
| Memory | 24 GB |
| R | 4.5.3, 2026-03-11 |

R package versions used on this machine:

| Package | Version |
|---|---:|
| `HNPclassifier` | 0.2.0 |
| `MASS` | 7.3.65 |
| `caret` | 7.0.1 |
| `data.table` | 1.18.4 |
| `randomForest` | 4.7.1.2 |
| `foreach` | 1.5.2 |
| `doParallel` | 1.0.17 |
| `e1071` | 1.7.17 |

---

## Notation

The summary tables use the following notation:

| Symbol | Meaning |
|---|---|
| $R_k^*$ | Mean under-classification error for class $k$. In the tables, `R1*` and `R2*` are $R_1^*$ and $R_2^*$. |
| $V_k$ | Violation rate for class $k$, defined as the proportion of runs in which $R_k^*$ exceeds the target level $\alpha_k$. In the tables, `V1` and `V2` are $V_1$ and $V_2$. |
| $R_{\mathrm{overall}}$ | Mean overall misclassification error across all classes. |
| $\alpha_k$ | Target upper bound for the under-classification error of class $k$. In the R scripts, this is set by `levels`. |
| $\delta_k$ | Tolerance level for the violation probability of class $k$. In the R scripts, this is set by `tolerances`. |

---

## 1. Setup

Install the required R packages before running the scripts:

```r
install.packages(c(
  "MASS",
  "caret",
  "data.table",
  "randomForest",
  "foreach",
  "doParallel",
  "e1071"
))
```

The scripts load the implementation with:

```r
library(HNPclassifier)
```

The estimated runtimes below are approximate and depend on the machine, base learner, and current simulation settings.

---

## 2. Examples

### 2.1 Example 1: three-class Gaussian data

```bash
Rscript EXample1.R
```

This script demonstrates the basic use of `hnp_umbrella()`. The current base learner is `method = "svm"`. The main output is the `hnp_summary()` result, including the confusion matrix and error metrics.

Estimated time: less than 1 minute.

### 2.2 Example 2: three input modes

```bash
Rscript Example2_all.R
```

This script demonstrates three input modes for H-NP classification:

- `pretrained_model`
- user-defined `score_fun`
- score-matrix input with `input_is_score = TRUE`

Estimated time: about 1--2 minutes.

---

## 3. Three-Class Simulations: T1--T4

The recommended entry point is:

```bash
Rscript run_all_T1_T4.R
```

This runner executes:

- `simulation_for_3_classes_T1.R`
- `simulation_for_3_classes_T2.R`
- `simulation_for_3_classes_T3.R`
- `simulation_for_3_classes_T4.R`

Estimated time for `run_all_T1_T4.R`: about 4--12 minutes.

Main output:

| Paradigm | Setting | R1_star | R2_star | V1 | V2 | R_overall |
|---|---|---:|---:|---:|---:|---:|
| Classical | C1 | 0.222 | 0.344 | 1.000 | 1.000 | 0.362 |
| Classical | C2 | 0.285 | 0.709 | 1.000 | 1.000 | 0.400 |
| H-NP | T1 | 0.034 | 0.051 | 0.096 | 0.001 | 0.587 |
| H-NP | T2 | 0.031 | 0.039 | 0.098 | 0.002 | 0.597 |
| H-NP | T3 | 0.036 | 0.057 | 0.082 | 0.002 | 0.581 |
| H-NP | T4 | 0.031 | 0.037 | 0.102 | 0.004 | 0.598 |

To run a single setting:

| Script | Estimated time |
|---|---:|
| `simulation_for_3_classes_T1.R` | 1--3 minutes |
| `simulation_for_3_classes_T2.R` | 1--3 minutes |
| `simulation_for_3_classes_T3.R` | 1--3 minutes |
| `simulation_for_3_classes_T4.R` | 1--3 minutes |

The three-class summary table contains:

| Column | Meaning |
|---|---|
| `Paradigm` | `Classical` for the original base learner; `H-NP` for the H-NP-adjusted classifier. |
| `Setting` | `C1` / `C2` for classical baselines; `T1`--`T4` for H-NP split settings. |
| `R1_star`, `R2_star` | Mean under-classification errors for classes 1 and 2. |
| `V1`, `V2` | Violation rates, defined as the proportion of runs exceeding the target level. |
| `R_overall` | Mean overall misclassification error. |

---

## 4. Five-Class Simulations

### 4.1 Run all base learners: alpha = delta = 0.1

```bash
Rscript run_simulation_for_5_classes_all.R
```

Estimated time for `run_simulation_for_5_classes_all.R`: about 6--8 hours.

This runner executes the following three scripts:

| Base learner | Individual script | Result file saved by the individual script | Estimated time |
|---|---|---|---:|
| Logistic regression | `simulation_for_5_classes_logistic.R` | `simulation_5_class_gaussian_hnp_logistic.RData` | 2--3 hours |
| Random forest | `simulation_for_5_classes_randomforest.R` | `simulation_5_class_gaussian_hnp_randomforest.RData` | 2--3 hours |
| SVM | `simulation_for_5_classes_svm.R` | `simulation_5_class_gaussian_hnp_svm.RData` | 2--3 hours |

The runner compares `Classical` and `H-NP` for each base learner and prints a summary table to the console. The table contains:

| Column | Meaning |
|---|---|
| `Base method` | Base learner name. |
| `Paradigm` | `Classical` or `H-NP`. |
| `R1*`--`R4*` | Mean under-classification errors for classes 1--4. |
| `V1`--`V4` | Violation rates for classes 1--4. |
| `R_overall` | Mean overall misclassification error. |

### 4.2 Run all base learners: alpha = delta = 0.05

```bash
Rscript run_simulation_0_05_5_classes_all.R
```

Estimated time for `run_simulation_0_05_5_classes_all.R`: about 6--8 hours.

This runner executes the stricter five-class simulations:

| Base learner | Individual script | Result file saved by the individual script | Estimated time |
|---|---|---|---:|
| Logistic regression | `simulation_5_classes_0_05_logistic.R` | `simulation_5_class_gaussian_hnp_logistic_0_05.RData` | 2--3 hours |
| Random forest | `simulation_5_classes_0_05_randomforest.R` | `simulation_5_class_gaussian_hnp_randomforest_0_05.RData` | 2--3 hours |
| SVM | `simulation_5_classes_0_05_svm.R` | `simulation_5_class_gaussian_hnp_svm_0_05.RData` | 2--3 hours |

The printed table has the same format as the `alpha = delta = 0.1` five-class runner.


## 5. Diabetes Real-Data Experiments (Figure 3 and Table 6)

These scripts reproduce the diabetes application. Place `diabetes_012_health_indicators_BRFSS2015.csv` in the repository root before running.

The recommended entry point is:

```bash
Rscript run_all_diabetes_experiments.R
```

This runner executes:

- `diabetes_logistic.R`
- `diabetes_svm.R`
- `diabetes_randomforest.R`

Estimated time for `run_all_diabetes_experiments.R`: several hours.

To run one base learner only:

| Script | Approximate time |
|---|---:|
| `diabetes_logistic.R` | 30--90 seconds |
| `diabetes_svm.R` | 2-3 hours |
| `diabetes_randomforest.R` | 30--90 seconds |

Main outputs:

| Manuscript output | Repository output |
|---|---|
| Figure 3 | Boxplots produced during `run_all_diabetes_experiments.R` |
| Table 6 | `Diabetes_HNP_summary_table.png` |

When `run_all_diabetes_experiments.R` is run in a non-interactive R session, the diabetes boxplots are written by R's default graphics device unless a graphics device is opened explicitly by the user.

---

## 6. German Credit Experiment (Figure 4)

This script reproduces the German Credit application.

```bash
Rscript credit_new.R
```

Estimated time for `credit_new.R`: about 30--90 minutes.

Main output:

| Manuscript output | Repository file |
|---|---|
| Figure 4 | `German_Credit_New_HNP_Boxplot_randomforest_100runs_70train_0.1_alphas.RData` |

Additional packages used by the real-data scripts:

```r
install.packages(c("caret", "data.table", "randomForest", "foreach", "doParallel"))
```
