# H-NP package Code Guide

This repository contains the R scripts used for the examples, three-class simulations, and five-class simulations in the HNPclassifier manuscript. 

---

## 1. Setup

Install the required R packages before running the scripts:

```r
install.packages(c("MASS"))
```

Most scripts load the implementation with:

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


## 5. Recommended Running Order

For a quick check, run the examples first:

```bash
Rscript EXample1.R
Rscript Example2_all.R
```

To generate the three-class simulation table:

```bash
Rscript run_all_T1_T4.R
```

To generate the five-class summaries with `alpha = delta = 0.1`:

```bash
Rscript run_simulation_for_5_classes_all.R
```

To generate the five-class summaries with `alpha = delta = 0.05`:

```bash
Rscript run_simulation_0_05_5_classes_all.R
```

To reproduce the diabetes application (Figure 3 and Table 6):

```bash
Rscript run_all_diabetes_experiments.R
```

To reproduce the German Credit application (Figure 4):

```bash
Rscript credit_new.R
```

The five-class random forest and SVM simulations are usually much slower than logistic regression.

---

## 6. Diabetes Real-Data Experiments (Figure 3 and Table 6)

These scripts reproduce the diabetes application in the manuscript:

| Manuscript output | Repository script / file |
|---|---|
| **Figure 3** (boxplots) | `diabetes_logistic.R`, `diabetes_svm.R`, `diabetes_randomforest.R`, or `run_all_diabetes_experiments.R` |
| **Table 6** (summary table) | `run_all_diabetes_experiments.R` → `Diabetes_HNP_summary_table.png` |

They apply H-NP to the BRFSS 2015 diabetes dataset (`diabetes_012_health_indicators_BRFSS2015.csv`). Place the CSV file in the repository root before running.

### 6.1 Data and class labels

| Original label | Mapped label | Meaning |
|---|---|---|
| `1` | `1` | Pre-diabetes (highest priority) |
| `2` | `2` | Diabetes |
| `0` | `3` | Healthy (lowest priority) |

`importance_order <- c("1", "2", "3")`. Control levels: `alpha = c(0.4, 0.2)`, `delta = c(0.2, 0.2)`. Each run uses a 5% training split (`train_ratio = 0.05`) and evaluates on the remaining 95%.

### 6.2 Individual scripts (Figure 3 panels)

| Script | Base learner | Parallel cores | Figure 3 panel |
|---|---|---:|---|
| `diabetes_logistic.R` | Logistic regression | 25 | Logistic boxplot |
| `diabetes_svm.R` | SVM | 10 | SVM boxplot |
| `diabetes_randomforest.R` | Random forest (pre-trained) | 25 | Random forest boxplot |

All three use standard `base_function` + `hnp_umbrella`, except random forest which uses `pretrained_model` and custom `hnp_split_match`.

Run a single experiment:

```bash
Rscript diabetes_logistic.R
Rscript diabetes_svm.R
Rscript diabetes_randomforest.R
```

Each script saves:

- `Diabetes_HNP_Boxplot_<method>_100runs_5train.RData`
- `Diabetes_HNP_Boxplot_<method>_100runs_5train.png`

For random forest, the output prefix is `trained_randomforest` (e.g. `Diabetes_HNP_Boxplot_trained_randomforest_100runs_5train.RData`).

Estimated time (100 runs, machine-dependent):

| Script | Approximate time |
|---|---:|
| `diabetes_logistic.R` | 30--90 minutes |
| `diabetes_svm.R` | several hours |
| `diabetes_randomforest.R` | 1--3 hours |

### 6.3 Run all three experiments (Figure 3 + Table 6)

```bash
Rscript run_all_diabetes_experiments.R
```

This runner sequentially executes all three diabetes scripts, then produces:

- `Diabetes_HNP_summary_table.png` — **Table 6** in the manuscript
- Boxplots for logistic, SVM, and pre-trained random forest — **Figure 3** in the manuscript

The summary table columns match the three-class simulation format: `R1*`, `R2*`, `V1`, `V2`, and `R_overall`.

### 6.4 Practical notes

- Set `n_cores` to at most `detectCores() - 1` on your machine; using more workers than CPU cores does not speed up SVM runs.
- After each parallel script, `stopCluster(cl)` releases worker processes. When running multiple experiments in one R session, `run_all_diabetes_experiments.R` also calls `registerDoSEQ()` and `gc()` between scripts.
- SVM is slow mainly because `probability = TRUE` prediction is run on the large test set (~240k rows) and inside H-NP grid search. For faster debugging, reduce `n_runs` to 5--10 first.

---

## 7. German Credit Experiment (Figure 4)

This script reproduces the five-class German Credit application in the manuscript (**Figure 4**).

```bash
Rscript credit_new.R
```

### 7.1 Data and class labels

The script loads `GermanCredit` from the `caret` package and constructs five ordered risk classes:

| Label | Meaning |
|---|---|
| `1` | Bad credit (highest priority) |
| `2`--`5` | Good credit, split by loan amount quartiles (lowest to highest risk) |

`importance_order <- c("1", "2", "3", "4", "5")`. Control levels: `alpha = c(0.1, 0.1, 0.1, 0.1)`, `delta = c(0.2, 0.2, 0.2, 0.2)`. Each run uses a 70% training split (`train_ratio = 0.7`).

### 7.2 Experimental settings

| Setting | Value |
|---|---|
| Base learner | Random forest |
| Runs | 100 |
| Parallel cores | 25 |

### 7.3 Output

| Manuscript output | Repository file |
|---|---|
| **Figure 4** | Use `conf_classical` and `conf_hnp` from the saved `.RData` with `hnp_boxplot()` |

Main output file:

- `German_Credit_New_HNP_Boxplot_randomforest_100runs_70train_0.1_alphas.RData`

The `.RData` file also contains `under_summary_table` with columns `R1*`--`R4*`, `V1`--`V4`, and `Roverall` for Classical vs. H-NP.

Estimated time: about 30--90 minutes (machine-dependent).

### 7.4 Required packages

```r
install.packages(c("caret", "data.table", "randomForest", "foreach", "doParallel"))
```
