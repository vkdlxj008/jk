# 🗄️ SQL Analysis Report

## 📊 Executive Summary
This comprehensive SQL analysis of 1,338 insurance records reveals critical insights into premium determinants using advanced SQL techniques including window functions, subqueries, and CASE statements for data categorization. The analysis confirms smoking status as the most significant risk factor, with smokers paying 280% more than non-smokers. Regional variations, BMI categories, and demographic factors show substantial impact on insurance costs, providing actionable insights for risk assessment and pricing strategies.

---

## 🔍 Key Findings

### 1. 🚬 Smoking Impact Analysis
**SQL Query Used:**
```sql
-- Basic statistics with GROUP BY and aggregation functions
SELECT smoker, COUNT(*) AS People, ROUND(AVG(charges), 2) AS avg_premium,
       ROUND(STDDEV(charges), 2) AS standard_deviation
FROM insurance_data GROUP BY smoker;

-- Subquery calculation for precise difference
SELECT ROUND((SELECT AVG(charges) FROM insurance_data WHERE smoker = 'yes') - 
             (SELECT AVG(charges) FROM insurance_data WHERE smoker = 'no'), 2) AS difference;
```

**SQL Results:**
- Smokers: $32,050.23 average premium (274 people)
- Non-smokers: $8,434.27 average premium (1,064 people)
- **Difference**: $23,615.96 (280% increase for smokers)

**Key Insights:**
- Smoking represents the single most significant risk factor in insurance pricing
- The premium difference of nearly $24,000 annually demonstrates the substantial health risks associated with smoking
- Only 20.48% of the population smokes, yet they represent the highest cost segment
- Standard deviation for smokers ($11,520.47) is nearly double that of non-smokers ($5,990.96), indicating higher variability in smoking-related health costs

### 2. 🌍 Regional Analysis
**SQL Query Used:**
```sql
-- Regional statistics with conditional aggregation
SELECT region, COUNT(*) AS people, ROUND(AVG(charges), 2) AS avg_premium,
       SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) AS smoker_count,
       ROUND(SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS smoker_rate
FROM insurance_data GROUP BY region ORDER BY avg_premium DESC;
```

**SQL Results:**
| Region | People Count | Avg Premium | Smoker Rate |
|--------|-------------|------------|-------------|
| Southeast | 364 | $14,735.41 | 25.00% |
| Northeast | 324 | $13,406.38 | 20.68% |
| Northwest | 325 | $12,417.58 | 17.85% |
| Southwest | 325 | $12,346.94 | 17.85% |

**Key Insights:**
- Southeast region shows highest average premiums ($14,735.41) correlating with highest smoking rate (25%)
- Southwest region has lowest premiums ($12,346.94) with lowest smoking rate (17.85%)
- Clear correlation between regional smoking rates and insurance costs discovered through CASE WHEN aggregation
- Regional premium differences of up to $2,388 suggest significant geographic risk factors

### 3. ⚖️ BMI Category Analysis
**SQL Query Used:**
```sql
-- BMI categorization using nested CASE WHEN statements
SELECT 
    CASE WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
         WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal (18.5-24.9)'
         WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight (25-29.9)'
         WHEN bmi >= 30 THEN 'Obese (≥30)'
    END AS BMI_category,
    COUNT(*) AS people_count, ROUND(AVG(charges), 2) AS average_premium
FROM insurance_data GROUP BY [CASE statement] ORDER BY average_premium DESC;
```

**SQL Results:**
| BMI Category | People Count | Avg Premium | Avg BMI |
|-------------|-------------|------------|---------|
| Obese (≥30) | 707 | $15,552.34 | 35.27 |
| Overweight (25-29.9) | 386 | $10,987.51 | 27.60 |
| Normal (18.5-24.9) | 225 | $10,409.34 | 22.62 |
| Underweight (<18.5) | 20 | $8,852.20 | 17.57 |

**Key Insights:**
- Obesity affects over half the population (707/1,338 = 52.8%) and drives significantly higher premiums
- Clear linear relationship between BMI categories and insurance costs revealed through systematic categorization
- $5,142 premium difference between obese and underweight categories
- Normal weight individuals show only marginal premium advantage over underweight, suggesting optimal health range

### 4. 👥 Demographic Breakdown
**SQL Query Used:**
```sql
-- Multi-dimensional analysis with age grouping
SELECT children, 
       CASE WHEN age < 30 THEN '20s' WHEN age >= 30 AND age < 40 THEN '30s'
            WHEN age >= 40 AND age < 50 THEN '40s' ELSE '50s and above' END AS age_group,
       COUNT(*) AS people_count, ROUND(AVG(charges), 2) AS average_premium
FROM insurance_data GROUP BY children, [age_group] ORDER BY children, age_group;
```

**SQL Results - Children Impact Analysis:**
- 0 children: $12,365.98 (574 people)
- 1 child: $12,731.17 (324 people)  
- 2 children: $15,073.56 (240 people)
- 3 children: $15,355.32 (157 people)
- 4+ children: Lower premiums due to small sample sizes

**Key Insights:**
- Having 2+ children correlates with 20%+ higher premiums
- Families with 2-3 children show highest insurance costs through systematic age-group cross-analysis
- Age groups in 50s+ consistently show higher premiums across all child categories
- 43% of population has no children, representing lower-risk segment identified through demographic segmentation

---

## 🔧 Data Validation & Advanced SQL Analysis

### 🔥 **High-Risk Group Identification using UNION:**
**SQL Query Used:**
```sql
-- Advanced segmentation using UNION ALL for comparative analysis
SELECT 'High Risk Group' AS group_type, COUNT(*) AS people_count, 
       ROUND(AVG(charges), 2) AS average_premium
FROM insurance_data WHERE smoker = 'yes' AND bmi >= 30
UNION ALL
SELECT 'General Group', COUNT(*), ROUND(AVG(charges), 2)
FROM insurance_data WHERE smoker = 'no' AND bmi < 30;
```

**Results:**
- **High Risk Group** (Obese Smokers): 145 people, $41,557.99 average premium
- **General Population**: 502 people, $7,977.03 average premium  
- **Risk Multiplier**: 5.2x higher premiums for high-risk individuals

### 📊 **BMI-Smoking Interaction using Cross-Tabulation:**
**SQL Query Used:**
```sql  
-- Multi-dimensional GROUP BY for interaction analysis
SELECT [BMI_category], smoker, COUNT(*) AS people_count, 
       ROUND(AVG(charges), 2) AS average_premium
FROM insurance_data 
GROUP BY [BMI_category], smoker ORDER BY BMI_category, smoker;
```

| BMI Category | Smoking Status | Count | Average Premium |
|-------------|----------------|-------|----------------|
| Normal | Non-smoker | 175 | $7,685.66 |
| Normal | Smoker | 50 | $19,942.22 |
| Obese | Non-smoker | 562 | $8,842.69 |
| Obese | Smoker | 145 | $41,557.99 |

**Critical Insight**: Obese smokers pay 4.7x more than obese non-smokers and 5.4x more than normal-weight non-smokers, discovered through systematic cross-tabulation analysis.

---

## 📈 Statistical Deep Dive

### Risk Factor Rankings (by Premium Impact)
1. **Smoking**: 280% increase ($23,615.96 difference)
2. **BMI Category**: Up to 75% increase (Obese vs Normal)
3. **Region**: Up to 19% increase (Southeast vs Southwest)
4. **Children (2+)**: Up to 24% increase
5. **Age**: Progressive increase with age groups

### Premium Distribution Analysis using Window Functions
**SQL Query Used:**
```sql
-- Top 10% analysis using PERCENT_RANK() window function
WITH ranked_data AS (
  SELECT *, PERCENT_RANK() OVER (ORDER BY charges DESC) AS pr
  FROM insurance_data
)
SELECT age, sex, bmi, children, smoker, region, charges,
       RANK() OVER (ORDER BY charges DESC) AS premium_ranking
FROM ranked_data WHERE pr <= 0.1 ORDER BY charges DESC;
```

**Results:**
- **Minimum Premium**: $1,121.87
- **Maximum Premium**: $63,770.43 (56.9x difference)
- **Overall Average**: $13,270.42 (calculated using simple AVG aggregation)
- **Top 10% Threshold**: $35,000+ (identified through PERCENT_RANK window function)
- **Top 1% Pattern**: All high-premium customers are smokers with multiple risk factors

---

## 💼 Business Implications

### 🎯 **For Insurance Companies:**
- **Risk-Based Pricing**: Implement tiered pricing with smoking status as primary factor
- **Regional Strategy**: Consider market penetration opportunities in lower-risk Southwest region
- **Wellness Programs**: Target obesity reduction and smoking cessation programs
- **Predictive Modeling**: Use BMI + smoking combination for most accurate risk assessment

### 📊 **For Risk Assessment:**
- **Priority Screening**: Focus on smoking status and BMI during underwriting
- **Family Demographics**: Consider children count as supplementary risk factor
- **Geographic Considerations**: Adjust regional base rates by 15-20%
- **High-Risk Identification**: Flag obese smokers for enhanced medical screening

---

## 🔬 Technical SQL Implementation Notes

### Advanced SQL Techniques Utilized

**1. Conditional Aggregation with CASE WHEN:**
```sql
SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) AS smoker_count
-- Counts specific conditions within GROUP BY without subqueries
```

**2. Subquery Calculations for Precise Metrics:**
```sql
SELECT ROUND(
    (SELECT AVG(charges) FROM insurance_data WHERE smoker = 'yes') - 
    (SELECT AVG(charges) FROM insurance_data WHERE smoker = 'no'), 2
) AS difference;
-- Ensures exact calculation without JOIN complexity
```

**3. Window Functions for Ranking Analysis:**
```sql
PERCENT_RANK() OVER (ORDER BY charges DESC) AS percentile_rank
-- Identifies top performers without multiple passes through data
```

**4. Multi-Level Categorization:**
```sql
CASE WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
     WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal (18.5-24.9)'
     WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight (25-29.9)'
     ELSE 'Obese (≥30)' END
-- Creates meaningful business categories from continuous data
```

**5. UNION ALL for Comparative Segmentation:**
```sql
SELECT 'High Risk' AS segment, COUNT(*), AVG(charges)
FROM insurance_data WHERE smoker = 'yes' AND bmi >= 30
UNION ALL  
SELECT 'General', COUNT(*), AVG(charges)
FROM insurance_data WHERE smoker = 'no' AND bmi < 30;
-- Combines different population segments for direct comparison
```

### Data Processing Methodology
- **Dataset**: Medical insurance cost dataset with 1,338 complete records
- **Database**: `insurance_analysis.insurance_data` table structure
- **Key Functions**: AVG, SUM, COUNT, MIN, MAX, STDDEV, ROUND for statistical analysis
- **Categorization**: WHO BMI guidelines, custom age groups, risk-based segmentation
- **Quality Assurance**: All calculations verified through multiple aggregation methods

---

## 📋 Conclusions

### 🎯 **Primary Findings:**
1. **Smoking Dominance**: Smoking status is the overwhelming determinant of insurance costs, creating a 280% premium increase
2. **Compound Risk Effects**: Obese smokers represent the highest-cost segment at $41,558 average premium
3. **Geographic Correlation**: Regional smoking rates directly correlate with average premiums

### 🔄 **Data Quality Assessment:**
- **Comprehensive Coverage**: 1,338 records with complete demographic and health data
- **Balanced Distribution**: Good representation across all regions and age groups
- **Statistical Significance**: Large sample sizes enable confident conclusions

### 🚀 **Next Steps:**
- **Longitudinal Analysis**: Track premium changes over time for existing policyholders
- **Predictive Modeling**: Develop machine learning models using identified key factors
- **Cost-Benefit Analysis**: Quantify ROI of wellness programs targeting high-risk groups
- **Market Expansion**: Analyze opportunities in lower-risk demographic segments

---

## 📁 Supporting Data Files
- `1-1.Basic_statistic_by_smoking_status.csv` - Smoking impact breakdown
- `2-1.Basic_statistics_by_region.csv` - Regional comparison data
- `3-1.Insurance_premium_amalysis_by_BMI_category.csv` - BMI category analysis
- `4-1.Basic_statistics_by_number_of_children.csv` - Children impact analysis
- `5-1.High_risk_group_identification_considering_all_factors.csv` - Risk segmentation
- `5-2.Premium_ranking.csv` - Top premium holders analysis
- `5-3.Data_summary_statistics.csv` - Overall dataset statistics

---

*This SQL analysis provides comprehensive, data-driven insights for evidence-based insurance pricing and risk management strategies. All findings are based on rigorous statistical analysis of complete dataset records.*
