# 📊 Data Analysis Portfolio

Welcome! This repository showcases three data analysis projects focusing on real-world social issues, using R and Tableau for statistical modeling and data visualization.

---

## 🏥 Project 1: Insurance Cost Analysis  
**Date**: August 2024  
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

### 📈 Visualizations & Analysis  
- **SQL Results**: 7 detailed CSV reports with exact statistical breakdowns
- **Tableau Dashboard**: Regional BMI vs cost comparison, demographic breakdown tables
- **Risk Segmentation**: High-risk group identification through systematic categorization
- **Methodology Comparison**: Comprehensive SQL vs Tableau analysis report

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
**Date**: December 2024  
**Tools**: R, ggplot2  

### 🔍 Overview  
This project examines how various social factors influence high school graduation rates across 50 U.S. states from 2011 to 2017.

### 📌 Key Insights  
- **Alcohol use** has a statistically significant negative effect on graduation rates (**p = 0.0106**).  
- **Weapon presence in schools** also shows a near-significant impact (**p = 0.0573**).  
- Despite consistent graduation rate increases nationwide, bullying and cyberbullying persist over time.

### 📈 Visualizations  
- Faceted time-series plots by state, showing:  
  - Graduation Rate (ACGR)  
  - Alcohol use, bullying, cyberbullying, and weapon reporting

🔗 [View Full Analysis](https://github.com/vkdlxj008/jk/blob/main/school/drop_rate.R)

---

## 🕵️ Project 3: COVID-19 and Crime Rate Analysis  
**Date**: April 2024  
**Tools**: R, ggplot2  

### 🔍 Overview  
This project investigates changes in local crime rates **before, during, and after** the COVID-19 pandemic using kernel density estimation.

### 📌 Key Insights  
- **Crime density significantly dropped** during the pandemic period.  
- Post-pandemic crime remained **lower than pre-pandemic levels**, suggesting a lasting behavioral or policy effect.  
- Policy suggestion: **Maintain certain public regulations** post-pandemic to sustain lower crime levels.

### 📈 Visualizations  
- Overlaid **density plots** of crime rate distributions across three periods (before, during, after pandemic)

🔗 [View Full Analysis](https://github.com/vkdlxj008/jk/blob/main/crimes/crimes.R)

---

## 🧠 Skills Demonstrated  
- Data wrangling & visualization in R and Tableau  
- Statistical testing (ANOVA, regression, p-values)  
- Demographic & temporal trend analysis  
- Policy recommendation based on data insights
