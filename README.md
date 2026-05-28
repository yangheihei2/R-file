# HNPclassifier 论文代码说明（R Journal 稿件对应）

这个仓库用于对应你当前 LaTeX 稿件中的示例、仿真和部分图形复现实验。  
下面按“论文章节 -> 对应脚本 -> 使用方法”整理，便于投稿时核对与复现。

---

## 1. 环境准备

### 1.1 R 依赖包

请先安装依赖：

```r
install.packages(c("MASS", "nnet", "randomForest", "e1071"))
```

### 1.2 运行前说明

- 大部分脚本第一行都通过 `source("hnp_package_importance_order.R")` 加载核心函数。
- 很多 simulation 脚本默认 `n_runs = 1000`，计算时间会比较长。
- 脚本中部分保存语句会尝试保存 `boxplot_out`，但原脚本没有给这个对象赋值；如果直接运行，保存步骤可能报错（见“常见问题”）。

---

## 2. 核心函数文件（算法实现）

### `hnp_package_importance_order.R`

这是核心实现文件，包含：

- H--NP 主函数：`hnp_umbrella()`
- 结果评估：`hnp_summary()`
- 重复实验可视化与统计：`hnp_boxplot()`
- 关键算法组件：  
  `hnp_upper_bound()`、`hnp_delta_search()`、`hnp_predict_proba()`、`hnp_build_score_functions()` 等
- 示例中用到的数据生成与辅助函数：  
  `generate_ball_data()`、`train_nn_and_get_scores()` 等

---

## 3. 论文 “Implementation details” 对应代码

### 3.1 Example 1（高斯三分类，内置 base learner）

**对应脚本**：`EXample1.R`

**用途**：

- 生成三类高斯数据（`A/B/C`）
- 训练 H--NP 分类器（脚本里当前 `method = "svm"`）
- 展示 `hnp_summary()` 输出（混淆矩阵、overall accuracy、under-classification error、remaining error）

**运行**：

```bash
Rscript EXample1.R
```

---

### 3.2 Example 2（pretrained model / score function / score matrix）

**对应脚本**：`Example2_all.R`

**用途**：

- 用 `generate_ball_data()` 生成三分类球形分布数据
- 训练神经网络并通过三种输入方式构建 H--NP：
  1. `pretrained_model = nn_model$model`
  2. `pretrained_model = score_fun`
  3. `input_is_score = TRUE`（直接喂 score matrix）
- 进行重复实验并调用 `hnp_boxplot()`

**运行**：

```bash
Rscript Example2_all.R
```

---

## 4. 论文 “Simulation studies” 对应代码

---

### 4.1 Simulation 1（3-class Gaussian）

#### 设定 T1
- 脚本：`simulation_for_3_classes_T1.R`
- 典型 split：`(0.50/0.50), (0.45/0.50/0.05), (0.95/0/0.05)`
- 输出保存：`simulation_3class_gaussian_hnp_T1.RData`

#### 设定 T2
- 脚本：`simulation_for_3_classes_T2.R`
- split 更偏训练：`(0.80/0.20), (0.75/0.20/0.05), ...`
- 输出保存：`simulation_3class_gaussian_hnp_T2.RData`

#### 设定 T3
- 脚本：`simulation_for_3_classes_T3.R`
- split：`(0.70/0.30), (0.65/0.30/0.05), ...`
- 输出保存：`simulation_3class_gaussian_hnp_T3.RData`

#### 设定 T4
- 脚本：`simiulation_for_3_classes_T4.R`（文件名里 `simiulation` 拼写保留原样）
- split：`(0.60/0.40), (0.55/0.40/0.05), ...`
- 输出保存：`simulation_3class_gaussian_hnp_T4.RData`

#### 设定 T5
- 脚本：`simulation_for_3_classes_T5.R`
- split 更偏 threshold：`(0.30/0.70), (0.25/0.70/0.05), ...`
- 输出保存：`simulation_3class_gaussian_hnp_T5.RData`

#### 设定 T6（类别不平衡）
- 脚本：`simulation_for_3_classes_T6.R`
- 类别样本量：`n_train = c(300, 300, 600)`
- 输出保存：`simulation_3class_gaussian_hnp_T6.RData`

**运行方式（示例）**：

```bash
Rscript simulation_for_3_classes_T1.R
```

---

### 4.2 Simulation 2（5-class Gaussian，alpha=delta=0.1）

#### Logistic
- 脚本：`simulation_for_5_classes_logistic.R`
- 输出：`simulation_5_class_gaussian_hnp_logistic.RData`

#### Random Forest
- 脚本：`simulation_for_5_classes_randomforest.R`
- 输出：`simulation_5_class_gaussian_hnp_randomforest.RData`

#### SVM
- 脚本：`simulation_for_5_classes_svm.R`
- 输出：`simulation_5_class_gaussian_hnp_svm.RData`

**运行方式（示例）**：

```bash
Rscript simulation_for_5_classes_logistic.R
```

---

### 4.3 5-class 更严格控制（alpha=delta=0.05）

#### Logistic
- 脚本：`simulation_5_classes_0_05_logistic.R`
- 输出：`simulation_5_class_gaussian_hnp_logistic_0_05.RData`

#### Random Forest
- 脚本：`simulation_5_classes_0_05_randomforest.R`
- 输出：`simulation_5_class_gaussian_hnp_randomforest_0_05.RData`

#### SVM
- 脚本：`simulation_5_classes_0_05_svm.R`
- 输出：`simulation_5_class_gaussian_hnp_svm_0_05.RData`

**运行方式（示例）**：

```bash
Rscript simulation_5_classes_0_05_svm.R
```

---

## 5. 与 LaTeX 章节的快速对应

- **Implementation details / Example 1** -> `EXample1.R`
- **Implementation details / Example 2** -> `Example2_all.R`
- **Simulation 1: three-class classification** -> `simulation_for_3_classes_T1.R` ... `T6`
- **Simulation 2: five-class classification** -> `simulation_for_5_classes_logistic.R` / `randomforest` / `svm`
- **补充 0.05 级别实验** -> `simulation_5_classes_0_05_*`
- **函数实现与包行为说明** -> `hnp_package_importance_order.R`

---

## 6. 常见问题（建议在投稿前统一修正）

1. **`boxplot_out` 未定义**  
   多个脚本末尾 `save(..., boxplot_out, ...)`，但前面没有 `boxplot_out <- hnp_boxplot(...)`。  
   建议改成：
   ```r
   boxplot_out <- hnp_boxplot(...)
   ```

2. **拼写不一致**  
   - `simiulation_for_3_classes_T4.R`（多了一个 i）
   - `EXample1.R`（大小写不统一）
   建议投稿前统一命名，避免 reviewer 运行时困惑。

3. **部分脚本含本机绝对路径 `load("~/Desktop/...")`**  
   这会影响复现。建议改为仓库相对路径或注释掉。

---

## 7. 一键复现建议（可选）

目前仓库是“每个实验一个脚本”。如果你愿意，我下一步可以再帮你加一个：

- `run_all.R`：按章节顺序依次运行
- `run_fast.R`：把 `n_runs` 临时降到 10 或 20 做快速 smoke test

这样更符合 R Journal 对“可复现性”的阅读体验。