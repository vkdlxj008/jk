# 📊 Data Analysis Portfolio

Welcome! This repository showcases three data analysis projects focusing on real-world social issues, using R and Tableau for statistical modeling and data visualization.

---

## 🏥 Project 1: Insurance Cost Analysis  
**Date**: August 2024  → **Updated: July 2025**   
**Tools**: SQL (Advanced Analysis), Tableau (Interactive Dashboard)

### 🔍 Overview  
Comprehensive dual-methodology analysis of healthcare insurance costs using both SQL statistical analysis and Tableau visualization. This project examines 1,338 insurance records to identify key premium determinants and validate findings through cross-platform comparison.

### 📌 Key Statistical Findings  
- **Smoking impact**: **280% premium increase** ($32,050 vs $8,434 average)
- **Regional variations**: **Southeast region** shows highest costs ($14,735) with 25% smoking rate
- **BMI correlation**: **Obese individuals** pay $15,552 average (52.8% of population)  
- **High-risk segment**: **Obese smokers** average $41,558 (5.2x general population)
- **Methodology validation**: Both SQL and Tableau confirm smokers pay **3-4x more**

### 🔬 Technical Implementation
- **Advanced SQL**: Window functions, subqueries, CASE statements for multi-dimensional analysis
- **Statistical rigor**: PERCENT_RANK, STDDEV, conditional aggregation for precise calculations
- **Interactive dashboard**: Multi-variable correlation analysis with drill-down capabilities
- **Cross-validation**: Dual methodology ensures analytical reliability

### 💼 Business Impact
- **Risk-based pricing strategy**: Clear premium multipliers by risk factors
- **Geographic insights**: 15-20% regional rate adjustments recommended  
- **Wellness program targeting**: ROI-driven obesity and smoking cessation focus
- **Predictive accuracy**: 5.2x risk differentiation through combined factors

🔗 [View Complete Analysis](https://github.com/vkdlxj008/jk/tree/main/medical/insurance-cost-analysis)  
📊 [SQL Analysis Report](https://github.com/vkdlxj008/jk/blob/main/medical/insurance-cost-analysis/reports/sql-analysis-results.md)  
📈 [Tableau Insights](https://github.com/vkdlxj008/jk/blob/main/medical/insurance-cost-analysis/reports/tableau-insights.md)  
🔍 [Methodology Comparison](https://github.com/vkdlxj008/jk/blob/main/medical/insurance-cost-analysis/reports/methodology-comparison.md)

---

## 🎓 Project 2: High School Graduation Rate Prediction  
**Date**: December 2024 → **Extended: September 2025**  
**Tools**: **R (Statistical Analysis) → Python (Machine Learning Pipeline)**

### 🔍 Overview
**Multi-phase analytical journey**: Started as a collaborative **R-based statistical analysis** of U.S. high school graduation rates, then evolved into a comprehensive **Python machine learning pipeline**. The project tackles a critical challenge in educational data science: **predicting graduation outcomes** while handling **sparse temporal data** and **missing values**.

### 🏗️ Technical Evolution
1. **Phase 1 (R)**: Group project with ANOVA/linear regression and facet visualizations
2. **Phase 2 (Python Port)**: Replicated R analysis for cross-platform validation  
3. **Phase 3 (ML Extension)**: Built production-ready prediction pipeline with **Expanding Time Split** validation

### 📊 Dataset & Target Engineering
- **Source**: 50 U.S. states, 2011–2017 (350+ state-year observations)
- **Features**: `alcohol`, `bully`, `cyberbully`, `weapon_state`, `year`
- **Target Engineering**: ACGR ≥ 85% → Binary classification (addresses class imbalance)
- **Challenge**: High missing data rate required sophisticated imputation strategy

### 🔬 Advanced Methodology: Expanding Time Split
**Innovation**: Designed **strict temporal validation** (≤t-1 → predict t) to prevent data leakage
- **Why**: Random splits gave misleading 90%+ accuracy due to missing data patterns
- **Implementation**: Train on all years before t, predict states seen in training for year t
- **Robustness**: Skips years with single-class training data, ensures realistic performance estimates

### 📈 Machine Learning Results

#### **Logistic Regression (Winner)**
- **Average Performance**: 82.1% Accuracy, 84.6% F1, **92.0% AUC**
- **Stability**: Consistent performance across all years (2012–2021)
- **Interpretability**: Clear state-level coefficients for policy insights
- **Key Predictors**: Michigan (-1.88), South Dakota (-1.88), Tennessee (+1.80)

#### **Random Forest Comparison**  
- **Average Performance**: 69.4% Accuracy, 69.5% F1, 75.5% AUC
- **Early Years**: Struggles with sparse data (AUC ≈ 0.5 in 2012–2014)
- **Late Years**: Strong performance (90%+ accuracy 2018–2021) 
- **Feature Importance**: Year (12.4%), Oregon (3.4%), South Dakota (3.3%)

### 🎯 Production Pipeline Features
```python
# Sophisticated preprocessing with missing data handling
preproc_for_logit = ColumnTransformer([
    ('cat', OneHotEncoder(handle_unknown='ignore'), cat_cols),
    ('num', Pipeline([
        ('imp', SimpleImputer(strategy='median')),
        ('sc', StandardScaler())
    ]), num_cols),
])

# Adaptive threshold optimization
def best_threshold_from_train(y_true, p_train, mode="f1"):
    cand = np.linspace(0.1, 0.9, 81)
    scores = [f1_score(y_true, (p_train >= c).astype(int)) for c in cand]
    return float(cand[np.argmax(scores)])
```

### 🔍 Statistical Insights (R Analysis)
- **Alcohol use**: Statistically significant negative predictor (F=6.73, p=0.011)
- **Weapon presence**: Modest association with graduation rates (p≈0.037)
- **Model fit**: R² ≈ 0.102, indicating complex multi-factor dynamics
- **Cross-platform validation**: Python OLS replicated R results exactly

### 🏭 Production-Ready Artifacts
**Automated pipeline generates**:
- `*_by_year_*.csv`: Yearly evaluation metrics with confidence intervals  
- `model_*.joblib`: Serialized scikit-learn pipelines ready for deployment
- `manifest_*.json`: Complete experiment configuration and artifact tracking
- **Full reproducibility**: One-command execution with timestamped outputs

### 💼 Business Impact & Policy Insights
- **Early Warning System**: Logistic model achieves 92% AUC for at-risk state identification
- **Resource Allocation**: State-level coefficients guide targeted intervention strategies
- **Temporal Reliability**: Expanding split ensures realistic performance in production deployment
- **Risk Stratification**: Clear differentiation between high/low graduation probability states

### 🔬 Technical Innovation
- **Temporal Validation**: Novel expanding split prevents data leakage in time-series prediction
- **Missing Data Strategy**: Median imputation preserves state-level patterns 
- **Threshold Optimization**: F1-maximized decision boundaries for balanced precision/recall
- **Cross-Model Validation**: Ensemble insights from interpretable (Logistic) vs. complex (RF) models

### ⏭️ Production Roadmap
- **Feature Engineering**: Lagged variables (previous year predictors → current outcomes)
- **Advanced Models**: Gradient boosting, XGBoost benchmarking  
- **Class Imbalance**: SMOTE, cost-sensitive learning for rare outcome prediction
- **Geographic Features**: Regional clustering, demographic integration

### 📊 Reproducibility
```bash
cd school/src  
python school_ml.py
# → Generates timestamped artifacts in ../outputs/artifacts/
```

**Key Differentiator**: This isn't just analysis—it's a **production-ready educational analytics pipeline** that handles real-world data challenges while maintaining statistical rigor.

🔗 [View Complete Pipeline](https://github.com/vkdlxj008/jk/tree/main/school)  
📈 [ML Implementation](https://github.com/vkdlxj008/jk/blob/main/school/src/school_ml.py)  
📊 [R Statistical Analysis](https://github.com/vkdlxj008/jk/tree/main/school/legacy)  
🎯 [Results Artifacts](https://github.com/vkdlxj008/jk/tree/main/school/outputs)

---

## 🚔 Project 3: Chicago Crime Analysis - COVID-19 Impact Study
**Date**: April 2024 → **Updated: August 2025**  
**Tools**: R (Advanced Statistical Analysis), tidyverse, plotly, changepoint detection, automated reporting

### 🔍 Overview  
**Full-scale statistical deep dive** into Chicago crime patterns during the COVID-19 pandemic. This project was built with a modular pipeline, heavy-duty statistical testing, and automated reporting — crunching through **6.5M+ crime records** from 2017–2023.
Honestly, it was a bit of a grind, but the result is a complete end-to-end workflow you can run with a single command.

### 📌 Key Statistical Findings  
- **Statistically significant impact**: Kruskal-Wallis test confirmed significant differences across pandemic periods (**p = 0.0154**)
- **Effect size quantification**: Cohen's d analysis revealed **medium to large effects** in key comparisons
- **Crime reduction during pandemic**: Significant decrease in daily crime rates during lockdown periods
- **Incomplete recovery**: Post-pandemic crime patterns show **persistent structural changes**
- **Crime type variations**: Different categories showed distinct pandemic response patterns

### 🔬 Technical Implementation
- **Modular architecture**: 6-script pipeline with automated execution (`analysis.R`)
- **Statistical rigor**: Non-parametric testing, effect size calculations, change point detection
- **Data engineering**: Processed 1.7GB dataset → optimized aggregated format for reproducibility
- **Quality assurance**: Comprehensive error handling, data validation, progress tracking
- **Publication-ready outputs**: High-resolution visualizations (300 DPI), automated reports

### 📊 Advanced Analytics
- **Time series analysis**: Monthly trends with 3-month moving averages
- **Change point detection**: PELT algorithm for identifying structural breaks
- **Geographic analysis**: Spatial outlier removal and location-based patterns  
- **Multi-dimensional comparison**: Crime type × location × temporal analysis
- **Recovery assessment**: Post-pandemic restoration patterns by category

### 🏗 Professional Workflow
- **One-click reproducibility**: Complete analysis via single command
- **Modular design**: Separated data processing, statistical analysis, visualization, reporting
- **Legacy integration**: Preserved and enhanced previous analytical approaches
- **Version control**: Comprehensive documentation and methodology tracking
- **Scalable architecture**: Designed for extension to other cities/datasets

### 💼 Business Applications
- **Policy evaluation**: Quantified impact of pandemic restrictions on public safety
- **Resource allocation**: Data-driven insights for law enforcement deployment
- **Trend forecasting**: Established baseline for post-pandemic crime predictions
- **Methodology framework**: Reusable analytical pipeline for urban crime studies

🔗 [View Complete Analysis](https://github.com/vkdlxj008/jk/tree/main/crimes) - Full reproducible pipeline with one-click execution  
📊 [Technical Documentation](https://github.com/vkdlxj008/jk/blob/main/crimes/README.md) - Detailed methodology and implementation  
📈 [Statistical Results](https://github.com/vkdlxj008/jk/tree/main/crimes/outputs) - Automated reports and visualizations

---

## 🧠 Skills Demonstrated  
- **Statistical Analysis**: ANOVA, non-parametric testing, effect size calculation, time series analysis
- **Data Engineering**: Large dataset processing, outlier detection, automated data validation  
- **Visualization**: Advanced ggplot2, interactive plotly dashboards, publication-quality graphics
- **Software Engineering**: Modular design, error handling, automated workflows, version control
- **Business Intelligence**: Policy recommendation, trend analysis, actionable insights generation
