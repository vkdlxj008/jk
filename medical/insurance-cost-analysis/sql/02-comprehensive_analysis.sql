-- Insurance Data Analysis SQL Query
-- data: insurance_analysis.insurance_data

-- =============================================================================
-- 1. Comparative Analysis of Smokers vs. Non-Smokers Insurance Premiums
-- =============================================================================

-- 1-1. Basic statistics by smoking status
SELECT 
    smoker AS Smoking_status,
    COUNT(*) AS People,
    ROUND(AVG(charges), 2) AS The_average_premium,
    ROUND(MIN(charges), 2) AS minimum_insurance_premium,
    ROUND(MAX(charges), 2) AS maximum_insurance_premium,
    ROUND(STDDEV(charges), 2) AS standard_deviation
FROM insurance_analysis.insurance_data
GROUP BY smoker
ORDER BY The_average_premium DESC;

-- 1-2. difference in premiums between smokers and non-smokers
SELECT 
    ROUND(
        (SELECT AVG(charges) FROM insurance_analysis.insurance_data WHERE smoker = 'yes') - 
        (SELECT AVG(charges) FROM insurance_analysis.insurance_data WHERE smoker = 'no'), 2
    ) AS Smoker_non_smoker_insurance_premium_difference,
    ROUND(
        ((SELECT AVG(charges) FROM insurance_analysis.insurance_data WHERE smoker = 'yes') / 
         (SELECT AVG(charges) FROM insurance_analysis.insurance_data WHERE smoker = 'no') - 1) * 100, 2
    ) AS Smokers_Increase_rate_percent;

-- =============================================================================
-- 2. Analysis of premiums by region
-- =============================================================================

-- 2-1. Basic statistics by region
SELECT 
    region AS region,
    COUNT(*) AS people,
    ROUND(AVG(charges), 2) AS The_average_premium,
    ROUND(MIN(charges), 2) AS minimum_insurance_premium,
    ROUND(MAX(charges), 2) AS maximum_insurance_premium,
    ROUND(STDDEV(charges), 2) AS standard_deviation
FROM insurance_analysis.insurance_data
GROUP BY region
ORDER BY The_average_premium DESC;

-- 2-2. Smoking rate by region and insurance premium relationship
SELECT 
    region AS region,
    COUNT(*) AS total_people,
    SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) AS smoker_count,
    ROUND(SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS smoker_rate_percent,
    ROUND(AVG(charges), 2) AS average_premium
FROM insurance_analysis.insurance_data
GROUP BY region
ORDER BY smoker_rate_percent DESC;

-- =============================================================================
-- 3. BMI and Insurance Premium Relationship Analysis
-- =============================================================================

-- 3-1. Insurance premium analysis by BMI category
SELECT 
    CASE 
        WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal (18.5-24.9)'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight (25-29.9)'
        WHEN bmi >= 30 THEN 'Obese (≥30)'
    END AS BMI_category,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium,
    ROUND(AVG(bmi), 2) AS average_BMI
FROM insurance_analysis.insurance_data
GROUP BY 
    CASE 
        WHEN bmi < 18.5 THEN 'Underweight (<18.5)'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal (18.5-24.9)'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight (25-29.9)'
        WHEN bmi >= 30 THEN 'Obese (≥30)'
    END
ORDER BY average_premium DESC;

-- 3-2. Interaction analysis between BMI and smoking status
SELECT 
    CASE 
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        WHEN bmi >= 30 THEN 'Obese'
    END AS BMI_category,
    smoker AS smoking_status,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium
FROM insurance_analysis.insurance_data
GROUP BY 
    CASE 
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'Normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'Overweight'
        WHEN bmi >= 30 THEN 'Obese'
    END, smoker
ORDER BY BMI_category, smoking_status;

-- =============================================================================
-- 4. Insurance Premium Difference Analysis by Number of Children
-- =============================================================================

-- 4-1. Basic statistics by number of children
SELECT 
    children AS number_of_children,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium,
    ROUND(MIN(charges), 2) AS minimum_premium,
    ROUND(MAX(charges), 2) AS maximum_premium,
    ROUND(STDDEV(charges), 2) AS standard_deviation
FROM insurance_analysis.insurance_data
GROUP BY children
ORDER BY children;

-- 4-2. Insurance premium analysis by number of children and age group
SELECT 
    children AS number_of_children,
    CASE 
        WHEN age < 30 THEN '20s'
        WHEN age >= 30 AND age < 40 THEN '30s'
        WHEN age >= 40 AND age < 50 THEN '40s'
        WHEN age >= 50 THEN '50s and above'
    END AS age_group,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium
FROM insurance_analysis.insurance_data
GROUP BY children, 
    CASE 
        WHEN age < 30 THEN '20s'
        WHEN age >= 30 AND age < 40 THEN '30s'
        WHEN age >= 40 AND age < 50 THEN '40s'
        WHEN age >= 50 THEN '50s and above'
    END
ORDER BY number_of_children, age_group;

-- =============================================================================
-- 5. Comprehensive Analysis: Multiple Factor Analysis
-- =============================================================================

-- 5-1. High-risk group identification considering all factors
SELECT 
    'High Risk Group' AS group_type,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium,
    ROUND(AVG(age), 1) AS average_age,
    ROUND(AVG(bmi), 1) AS average_BMI
FROM insurance_analysis.insurance_data
WHERE smoker = 'yes' AND bmi >= 30
UNION ALL
SELECT 
    'General Group' AS group_type,
    COUNT(*) AS people_count,
    ROUND(AVG(charges), 2) AS average_premium,
    ROUND(AVG(age), 1) AS average_age,
    ROUND(AVG(bmi), 1) AS average_BMI
FROM insurance_analysis.insurance_data
WHERE smoker = 'no' AND bmi < 30;

-- 5-2. Profile analysis of top 10% premium customers
-- First, calculate OFFSET values with variables
SET @offset_val = (
  SELECT FLOOR(COUNT(*) * 0.1)
  FROM insurance_analysis.insurance_data
);

-- Then, the reference cutoff value is obtained
WITH ranked_data AS (
  SELECT *,
         PERCENT_RANK() OVER (ORDER BY charges DESC) AS pr
  FROM insurance_analysis.insurance_data
)
SELECT age,
       sex,
       bmi AS BMI,
       children,
       smoker,
       region,
       charges,
       RANK() OVER (ORDER BY charges DESC) AS premium_ranking
FROM ranked_data
WHERE pr <= 0.1
ORDER BY charges DESC;

-- 5-3. Data summary statistics
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT age) AS age_range,
    COUNT(DISTINCT region) AS number_of_regions,
    ROUND(AVG(charges), 2) AS overall_average_premium,
    ROUND(MIN(charges), 2) AS minimum_premium,
    ROUND(MAX(charges), 2) AS maximum_premium,
    SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) AS smoker_count,
    ROUND(SUM(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS smoker_rate_percent
FROM insurance_analysis.insurance_data;
