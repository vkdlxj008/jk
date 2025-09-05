# 📊 School Graduation Rate Analysis

## 🎯 Project Overview
This started as a **group project**: we collected data and first ran **ANOVA/linear regression in R**, producing facet plots of state-level graduation rates.
I then **ported the workflow to Python**, replicating the original analysis.
Finally, I extended the work with **machine learning models (Logistic Regression vs Random Forest)** to predict high school graduation rates.
Because the dataset had many missing values, random train/test splits gave misleading results. To handle this, I designed a more robust **Expanding Time Split** (≤t-1 → t) validation scheme.

## 🏗️ Project Structure
```
school/
├─ data/
│   └─ school.csv                 # raw dataset (state × year × metrics)
├─ legacy/
│   ├─ README.md                  # original R notes
│   └─ drop_rate.R                # initial ANOVA/linear regression in R
├─ outputs/
│   ├─ artifacts/                 # machine learning artifacts (auto-generated)
│   │   ├─ Logit_by_year_*.csv    # yearly metrics for Logistic Regression
│   │   ├─ RF_by_year_*.csv       # yearly metrics for Random Forest
│   │   ├─ model_Logit_*.joblib   # trained scikit-learn pipeline (Logit)
│   │   ├─ model_RF_*.joblib      # trained scikit-learn pipeline (RF)
│   │   └─ manifest_*.json        # config & artifact manifest
│   ├─ Factors_Influencing_Fradutation_Rates_by_Year_and_State.PNG
│   └─ anava(RCD)_and_linearRegression.PNG
└─ src/
    ├─ analysis.py                 # exploratory analysis
    └─ school_ml.py                # ML pipeline (Logit vs RF, Expanding CV)
```
## 📊 Data
**Source**: data/school.csv
**Features**: alcohol, bully, cyberbully, weapon_state, year
**Target**: Adjusted Cohort Graduation Rate (ACGR, %)
**Binary classification**: ACGR ≥ 85% → 1, else 0

## 🔬 Method
1. **Exploratory Analysis**
- Initial R analysis: facet plots and ANOVA/linear regression (outputs/*.PNG).
2. **Python Port**
- Data cleaning, reshaping (long ↔ wide), and replication of R outputs.
3. **Machine Learning**
- Models: Logistic Regression (baseline, interpretable), Random Forest Classifier (non-linear).
- Validation: Expanding split (≤t-1 years for training, predict year t).
- Missing values: handled with SimpleImputer(strategy='median').

## 📋 Results
- **Logistic Regression**
   - Avg Accuracy ≈ 0.82, F1 ≈ 0.84, AUC ≈ 0.92
   - Stable, interpretable (coefficients by state/feature).
- **Random Forest**
  - Avg Accuracy ≈ 0.69, F1 ≈ 0.69, AUC ≈ 0.75
  - Performs well in later years but unstable in early years (AUC ~0.5 in 2012–2014).
- **Conclusion**: Logistic Regression is the most reliable overall. Random Forest provides supplementary insights but suffers from instability with sparse early data.

## 🎯 Artifacts
All experiment outputs are stored in `outputs/artifacts/`:
- `*_by_year_*.csv|pkl`: yearly evaluation metrics.
- `model_*.joblib`: trained pipelines.
- `manifest_*.json`: configuration + artifact log.

## ❓ How to Reproduce
cd src
python school_ml.py

Results will be saved automatically under `../outputs/artifacts/`.

## ⏭️ Next Steps
- Add **lag features** (e.g., previous year’s alcohol/bully levels → current ACGR).
- Address **class imbalance** (threshold tuning, resampling).
- Benchmark **other ML models** (Gradient Boosting, XGBoost, etc.).
