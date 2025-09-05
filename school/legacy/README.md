# 🎓 Project 2: High School Graduation Rate Analysis

>****

## 📊 Project Overview
This project examines how various social factors influence high school graduation rates across 50 U.S. states from 2011 to 2017 for Group project of STAT250 BYU. My role in the project involved data short sampling, analysis by data modeling **ANOVA** and **linear regression**, and **facet plot** to visualize high school graduation rates across the 50 states, along with variables that may negatively impact graduation rates.

- 📚 Source: National Center for Education Statistics (NCES)
- 🏛️ Collected by: Administrative Data Division, U.S. Dept. of Education
- 🔐 Usage Rights: Governed by the Freedom of Information Act (FOIA)
- 📅 Timeframe: 2011 to 2017
- 👨‍🎓 Variables: Graduation Rate, School Violence, Bullying, Alcohol Use

## 🤝 Team and Contributions
- Ethan Gertsch
- Johnny Lam
- Jun Kim

## 📊 Key Research Questions
- **Primary**: Do social risk factors (alcohol use, bullying, cyberbullying, weapon presence) significantly predict high school graduation rates?
- **Secondary**: Which states show consistent patterns of high/low graduation rates relative to risk factors?
- **Temporal**: How do these relationships change over the 2011-2017 period?

## 🔬 Statistical Analysis Results

### **ANOVA Findings**
Our **one-way ANOVA** analysis revealed significant associations between social factors and graduation rates:

- **Alcohol Use**: **F = 6.73, p = 0.0106** ✅ *Statistically Significant*
  - Strong negative association with graduation rates
  - Effect size suggests meaningful practical impact
  
- **Weapon Presence**: **F = 4.46, p ≈ 0.0368** ✅ *Statistically Significant*  
  - Moderate negative association with graduation outcomes
  - Consistent across multiple years

- **Bullying**: Persistent trends observed but not statistically significant in multivariate model
- **Cyberbullying**: Similar pattern to traditional bullying

### **Linear Regression Model**
**Multiple OLS Regression**: ACGR ~ Alcohol + Bullying + Cyberbullying + Weapon

- **Model Fit**: R² ≈ 0.102, Adj. R² ≈ 0.073
- **Overall Significance**: F(4,122) = 3.47, **p = 0.0101** ✅
- **Key Predictors**:
  - **Alcohol**: β = -0.201, p = 0.011 (significant negative predictor)
  - **Weapon**: β ≈ -0.520, p ≈ 0.057 (marginally significant)

### **State-Level Patterns**
**Facet Plot Analysis** revealed distinct state clusters:

- **High-Performing States**: Consistent 85%+ graduation rates despite varying risk factors
- **At-Risk States**: Lower graduation rates correlating with higher social risk indicators  
- **Temporal Stability**: Most states maintain relative ranking over 2011-2017 period

## 📈 Visualization Outputs

### **Primary Visualization**
- **File**: `Factors_Influencing_Fradutation_Rates_by_Year_and_State.PNG`
- **Type**: Faceted time-series plot showing all 50 states
- **Variables**: ACGR, Alcohol, Bullying, Cyberbullying, Weapon reporting
- **Insight**: Clear visual patterns of state-level performance over time

### **Statistical Summary**
- **File**: `anava(RCD)_and_linearRegression.PNG`  
- **Content**: ANOVA tables and regression output summary
- **Key Finding**: Alcohol use emerges as the most consistent predictor

## 🎯 Key Conclusions from R Analysis

1. **Alcohol Use** is the **strongest predictor** of graduation rates (both ANOVA and regression significant)
2. **Weapon Presence** shows **moderate association** with graduation outcomes
3. **Model Explains ~10%** of variance, suggesting complex multi-factor dynamics
4. **State-Level Effects** are substantial, indicating geographic/policy influences
5. **Temporal Consistency** in relationships across 2011-2017 period

## 🔬 Methodological Strengths
- **Comprehensive Coverage**: All 50 U.S. states over 7-year period
- **Multiple Approaches**: Both ANOVA and regression for robust inference
- **Visualization**: Clear faceted plots for pattern identification  
- **Statistical Rigor**: Proper significance testing and effect size consideration

## ⚠️ Limitations & Future Directions
- **R² = 0.102** suggests unmeasured confounding variables
- **Cross-sectional nature** limits causal inference
- **Missing data patterns** may affect some state-year combinations
- **Future work**: Could benefit from lagged variables and longitudinal modeling

## Data Pedigree and Terms of Service
The data for this research is primarily gathered from the National Center for Educational Statistics. 
The NCES is part of the United States Department of Education and was created to be the principal organization to collect, analyze, and publish US education statistics.
Within the NCES, a separate arm called the Administrative Data Division collects data by surveying schools across the United States. 
The datasets used in this research are from secondary schools and adhere to strict guidelines of data collection. 
The primary variables being analyzed among high schoolers are graduation rates, violence on school property, bullying, and alcohol use.
As all data is the product of government-collected federally funded research, 
the terms of service are regulated by the Freedom of Information Act which provides individuals with the right to access the information. 
Thus there are no concerns for this data's use in a school research project.

## 📚 Works Cited
1. National Center for Education Statistics. (2023). Table 219.46. Public high school 4-year adjusted cohort graduation rate
(ACGR), by selected student characteristics and state or jurisdiction: School years 2011-12 through 2021-22. U.S. Department of
Education, Institute of Education Sciences.
2. Aud, S., & Hannes, G. (Eds.). (2011). The condition of education 2011 in brief (NCES 2011-034). U.S. Department of
Education, National Center for Education Statistics. Retrieved from https://nces.ed.gov/pubs2011/2011034.pdf
Sum, A., Khatiwada, I., McLaughlin, J., & Palma, S. (2009). The consequences of dropping out of high school: Joblessness and
jailing for high school dropouts and the high cost for taxpayers. Center for Labor Market Studies, Northeastern University.
Retrieved from https://repository.library.northeastern.edu/downloads/neu:376324?datastream_id=content
3. Bridgeland, J. M., DiIulio, J. J., & Morison, K. B. (2006). The silent epidemic: Perspectives of high school dropouts. Civic
Enterprises in association with Peter D. Hart Research Associates for the Bill & Melinda Gates Foundation. Retrieved from
https://files.eric.ed.gov/fulltext/ED513444.pdf
4. Moretti, E. (2005). Does education reduce participation in criminal activities? Department of Economics, UC Berkeley. Retrieved
from https://web.archive.org/web/20181205193458/https://pdfs.semanticscholar.org/1468/65bf387c876041f043134afdd4365b912801.pdf

