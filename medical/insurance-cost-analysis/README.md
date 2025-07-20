# 📊 Insurance Cost Analysis Project

## 🎯 Project Overview
A comprehensive analysis of healthcare insurance costs using both **SQL** and **Tableau** methodologies. This project uncovers key factors affecting insurance premiums through statistical analysis and interactive visualization, providing actionable insights for risk assessment and pricing strategies.

**Data Source**: Kaggle Medical Cost Personal Dataset (1,338 records)

## 🏗️ Project Structure
```
insurance-cost-analysis/
├── README.md                    # Project overview and guide
├── data/
│   ├── insurance.csv           # Original dataset
│   └── processed/              # SQL analysis results (CSV files)
├── analysis/
│   └── sql/                    # Database setup and analysis queries
│       ├── 01-setup.sql
│       └── 02-comprehensive_analysis.sql
├── visuals/
│   └── tableau/
│       ├── 2nd_draft.twbx     # Complete Tableau workbook
│       └── screenshots/
│           └── 2nddraftmedical.PNG
├── reports/                    # Comprehensive analysis reports
│   ├── sql-analysis-results.md        # Detailed SQL findings
│   ├── tableau-insights.md            # Visualization insights
│   └── methodology-comparison.md      # SQL vs Tableau comparison
└── validation/
    └── cross-validation-results.md    # Results validation
```

## 🔍 Key Findings

### 💨 Smoking Impact (Primary Factor)
- **280% higher premiums** for smokers ($32,050 vs $8,434)
- Smoking affects only 20% of population but drives highest costs
- **Most significant risk factor** confirmed by both SQL and Tableau analysis

### 🌍 Regional Variations
- **Southeast region**: Highest premiums ($14,735) with 25% smoking rate
- **Southwest region**: Lowest premiums ($12,346) with 17.85% smoking rate
- $2,388 premium difference between highest and lowest regions

### ⚖️ BMI Categories
- **Obese individuals** (≥30 BMI): $15,552 average premium
- **52.8% of population** falls into obese category
- Clear correlation between BMI and insurance costs

### 🏆 High-Risk Identification
- **Obese smokers**: $41,558 average premium (5.2x general population)
- Represent highest-cost segment requiring enhanced screening

## 📊 Analysis Methodologies

### 🗄️ SQL Analysis Highlights
- **Advanced SQL techniques**: Window functions, subqueries, CASE statements
- **Precise calculations**: Exact premium differences and statistical measures  
- **Multi-dimensional segmentation**: Risk groups and demographic analysis
- **Results**: 7 detailed CSV files with statistical breakdowns

### 📈 Tableau Visualization Highlights
- **Interactive dashboard**: Multi-dimensional relationship exploration
- **Regional BMI vs Cost comparison**: Combined bar and line charts
- **BMI-Cost correlation**: Scatter plot with trend analysis
- **Demographic breakdown**: Gender and smoking status impact

## 🔬 Methodology Comparison

| Aspect | SQL Analysis | Tableau Visualization |
|--------|-------------|---------------------|
| **Precision** | ✅ Exact numerical values | 🎯 Visual pattern recognition |
| **Best For** | Statistical validation, automation | Executive reporting, exploration |
| **Strengths** | Transparent calculations, reproducible | Intuitive understanding, interactive |

**Key Finding**: Both methodologies yield **consistent results** (smokers pay 3-4x more), validating analytical reliability.

## 🚀 Business Implications

### For Insurance Companies
- **Risk-based pricing**: Implement smoking status as primary factor
- **Regional strategies**: Adjust rates by 15-20% based on geography  
- **Wellness programs**: Target obesity reduction and smoking cessation
- **High-risk screening**: Enhanced medical evaluation for obese smokers

### For Risk Assessment
- **Priority factors**: Smoking status > BMI category > Region > Demographics
- **Predictive accuracy**: Combined factors provide 5.2x risk differentiation
- **Market opportunities**: Lower-risk segments in Southwest region

## 📋 How to Explore This Project

1. **📊 Start with visualizations**: View dashboard screenshot in `visuals/tableau/screenshots/`
2. **📈 Download Tableau workbook**: Open `visuals/tableau/2nd_draft.twbx` in Tableau
3. **🗄️ Review SQL analysis**: Check detailed findings in `reports/sql-analysis-results.md`
4. **🔍 Compare methodologies**: Read methodology comparison in `reports/methodology-comparison.md`
5. **📂 Explore raw data**: Processed results available in `data/processed/`

## 🛠️ Technical Implementation

### SQL Analysis Features
- **Database setup**: Automated data loading and table creation
- **Advanced queries**: Window functions for ranking, CASE statements for categorization
- **Statistical functions**: AVG, STDDEV, PERCENT_RANK for comprehensive analysis
- **Result validation**: Cross-verification through multiple aggregation methods

### Tableau Dashboard Components
- **Regional comparison**: BMI and cost metrics by geography
- **Correlation analysis**: BMI vs insurance charges with trend line
- **Demographic tables**: Gender and smoking status breakdown
- **Interactive elements**: Drill-down capabilities for detailed exploration

## 🎯 Key Achievements

- **✅ Dual methodology validation**: Consistent findings across SQL and Tableau
- **📊 Comprehensive risk profiling**: 5+ risk factors analyzed systematically
- **💼 Actionable insights**: Clear business recommendations for pricing strategy
- **🔍 Statistical rigor**: Advanced SQL techniques with proper validation
- **📈 Visual storytelling**: Intuitive dashboard design for stakeholder communication

---

## 📁 Supporting Documentation

- **Detailed SQL Report**: `reports/sql-analysis-results.md` - Complete statistical analysis
- **Tableau Insights**: `reports/tableau-insights.md` - Visualization findings  
- **Methodology Study**: `reports/methodology-comparison.md` - SQL vs Tableau comparison
- **Data Validation**: `validation/cross-validation-results.md` - Results verification

---

*This project demonstrates proficiency in both statistical analysis and data visualization, providing comprehensive insights through multiple analytical approaches for evidence-based decision making.*
