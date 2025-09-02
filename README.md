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

## 🎓 Project 2: High School Graduation Rate Analysis  
**Date**: December 2024 → **Updated: September 2025**  
**Tools**: **R (ggplot2), Python (pandas, statsmodels, plotnine, matplotlib)**

### 🔍 Overview
This project examines how social factors relate to U.S. high school graduation rates (ACGR) across 50 states from 2011–2017.  
We reconstructed the original R analysis in Python to ensure reproducibility and parity across ecosystems.

### 📌 Key Insights (ANOVA & OLS)
- **Alcohol use** shows a statistically significant negative association with ACGR  
  *(ANOVA F=6.73, p=0.0106; OLS β=-0.201, p=0.011)*.
- **Weapon presence** in schools shows a modest association with ACGR  
  *(ANOVA F=4.46, p≈0.0368; OLS β≈-0.520, p≈0.057)*.
- **Bullying** and **cyberbullying** trends persist but are **not significant** predictors in the multivariate model here.
- Model fit (Python OLS): **R² ≈ 0.102, Adj. R² ≈ 0.073**, *F*(4,122)=3.47, **p=0.0101**.

> The Python implementation reproduced the R results consistently.

### 📈 Visualizations
- **Faceted time-series** by state showing ACGR, Alcohol, Bullying, Cyberbullying, and Weapon reporting.  
  - PNG: [`school/outputs/Factors_Influencing_Fradutation_Rates_by_Year_and_State.PNG`](school/outputs/Factors_Influencing_Fradutation_Rates_by_Year_and_State.PNG)  
  - Python (plotnine) export: `school/outputs/facet_plot.png` (created on run)

---

## 🚔 Project 3: Chicago Crime Analysis - COVID-19 Impact Study
**Date**: April 2024 → **Updated: August 2025**  
**Tools**: R (Advanced Statistical Analysis), tidyverse, plotly, changepoint detection, automated reporting

### 🔍 Overview  
Comprehensive statistical analysis of Chicago crime patterns during the COVID-19 pandemic. The project uses a modular workflow with statistical testing and automated report generation, processing 6.5M+ crime records from 2017–2023.

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
