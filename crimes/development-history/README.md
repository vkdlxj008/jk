# Crime Data Analysis: COVID-19 Pandemic Impact Study
*From BYU Case Competition 2024 to Comprehensive Statistical Analysis*

This repository documents the evolution of a comprehensive crime data analysis project, tracking the development from initial exploratory analysis to robust statistical modeling and infrastructure development. **The project originated from the BYU Case Competition 2024** and evolved through multiple methodological iterations, each building upon previous insights and addressing emerging analytical challenges.

## 🎯 Project Overview

This project analyzes crime patterns before, during, and after the COVID-19 pandemic using Chicago crime data. The analysis evolved through multiple iterations, each building upon previous insights and methodological improvements.

## 📊 Key Research Questions

- How did crime patterns change during the COVID-19 pandemic?
- Which crime types were most affected by pandemic-related restrictions?
- What statistical methods best capture these temporal changes?
- How can we build robust data infrastructure for ongoing analysis?

## 🚀 Development Evolution

### Phase 1: Prototype Exploration (`v1-prototype-exploration/`)
**File**: `01-initial-pandemic-density-analysis.R` (originally `crimes.R`)

**Background**: This analysis originated from the **BYU Case Competition 2024**, where the initial research question focused on understanding how COVID-19 impacted crime patterns in Chicago.

**Objective**: Compare crime density distributions across three distinct pandemic periods

**Research Design**:
- **Before Pandemic**: 2017-2019 (baseline period)
- **During Pandemic**: 2020-2022 (lockdowns and restrictions)
- **After Pandemic**: 2022-2023 (recovery period)

**Key Features**:
- Basic data cleaning and outlier removal
- Three-period comparative framework
- Density plot visualization showing distributional differences
- Foundation for understanding temporal crime patterns

**Limitations & Challenges**: 
- **Temporal boundary ambiguity**: Defining "during" vs "after" pandemic periods proved challenging with 2023 as the data endpoint
- **Overlapping periods**: 2022 appeared in both "during" and "after" categories, creating analytical confusion
- **Limited statistical rigor**: Visual comparison without formal statistical testing
- **Data constraints**: Maximum data availability through 2023 limited post-pandemic analysis window

### Phase 2: Statistical Validation (`v2-statistical-validation/`)
**File**: `02-statistical-methods-exploration.R` (originally `analysis_some_statistical_validation.R`)

**Objective**: Apply comprehensive statistical methods learned in undergraduate coursework to validate crime data patterns

**Motivation**: After the initial visual analysis, the need arose to apply rigorous statistical testing to support or refute observed patterns using formal hypothesis testing frameworks.

**Statistical Methods Applied**:
- **T-tests**: Comparing means between Assault and Battery crime types
- **F-tests**: Testing variance equality between crime categories  
- **Z-tests**: Large sample mean comparison with known population parameters
- **Chi-square tests**: Association testing between crime types and locations
- **Correlation analysis**: Relationship between year and crime counts
- **P-value interpretation**: Statistical significance assessment across all tests

**Methodological Focus**:
- Systematic application of undergraduate statistical concepts
- Practical implementation of theoretical knowledge
- Understanding appropriate test selection for different data types
- Interpretation of statistical output in real-world context

**Learning Outcomes**:
- Recognition that crime data violates many parametric test assumptions
- Understanding of when to use different statistical approaches
- Appreciation for the complexity of categorical crime data analysis
- Foundation for more sophisticated analytical methods

### Phase 3: Comprehensive Analysis (`v3-comprehensive-analysis/`)
**File**: `03-comprehensive-pandemic-impact-study.R` (originally `analysis_enhancement.R`)

**Motivation**: Building upon statistical validation insights, this phase focused on **time series analysis** learning and **analytical differentiation** to create a more sophisticated and comprehensive study.

**Time Series Enhancement**:
- **Advanced temporal modeling**: Moving beyond simple period comparisons to continuous time analysis
- **Change point detection**: Algorithmic identification of structural breaks in crime patterns
- **Seasonal pattern recognition**: Accounting for natural temporal variations in crime data
- **Moving average smoothing**: Reducing noise while preserving underlying trends

**Analytical Differentiation Strategies**:
- **Non-parametric approaches**: Addressing distributional assumptions violations found in Phase 2
- **Effect size reporting**: Moving beyond p-values to practical significance measures
- **Multi-level analysis**: Combining overall trends with crime-type specific patterns
- **Professional visualization**: Publication-ready graphics with clear interpretability

**Key Features**:
- **Advanced Statistical Testing**:
  - Kruskal-Wallis non-parametric ANOVA for robust period comparisons
  - Post-hoc pairwise Wilcoxon tests with multiple comparison corrections
  - Cohen's d effect size calculations for practical significance assessment
- **Time Series Analysis**:
  - Monthly trend analysis with 3-month moving averages
  - PELT (Pruned Exact Linear Time) change point detection algorithm
  - Visual timeline markers for key pandemic milestones
- **Crime Type Analysis**:
  - Percentage change calculations across pandemic periods
  - Top 15 most frequent crime types deep-dive analysis
  - Interactive heatmaps showing temporal-categorical patterns
- **Professional Visualizations**:
  - Multi-layered time series plots with trend lines
  - Color-coded period analysis for clear interpretation
  - Publication-ready graphics with comprehensive legends

**Methodological Rigor**:
- Bonferroni correction for multiple hypothesis testing
- Effect size reporting alongside statistical significance
- Robust non-parametric methods for non-normal crime count distributions
- Comprehensive summary statistics with confidence intervals

### Phase 4: Data Infrastructure (`v4-data-infrastructure/`)

#### 4a. Raw Data Preprocessing
**File**: `04a-raw-data-preprocessing.R` (originally `data_preprocessing.R`)

**Challenge**: The original crime dataset was too large for GitHub repository inclusion, necessitating a data reduction strategy that preserved analytical value while reducing file size.

**Objective**: Create aggregated daily crime summaries that maintain essential information while enabling version control

**Data Reduction Strategy**:
- **Temporal aggregation**: Convert individual incidents to daily counts
- **Categorical preservation**: Maintain crime type and location classifications
- **Essential variable retention**: Keep only variables critical for analysis
- **Quality assurance**: Implement data validation checks during aggregation

**Features**:
- Daily aggregation by crime type and location combination
- Consistent date formatting and validation
- Data quality checks and missing value handling
- Export to standardized CSV format suitable for sharing

#### 4b. Summary Data Generation
**File**: `04b-summary-data-generation.R` (originally `generate_summaries.R`)

**Motivation**: After creating aggregated daily data, the need emerged to generate multiple analytical perspectives from the same underlying dataset to support diverse research questions.

**Objective**: Create comprehensive summary datasets enabling different analytical approaches without requiring raw data reprocessing

**Multi-perspective Analysis**:
- **Monthly summaries**: Temporal trend analysis capability
- **Crime type summaries**: Category-specific pattern identification  
- **Location summaries**: Geographic pattern analysis
- **Cross-tabulated summaries**: Combined temporal-categorical analysis

**Output Files**:
- `monthly_summary.csv`: Monthly aggregations by type/location
- `monthly_totals.csv`: Overall monthly statistics
- `crime_types_summary.csv`: Comprehensive crime type analysis
- `crime_yearly_trends.csv`: Annual trends by crime type
- `locations_summary.csv`: Location-based crime analysis
- `location_yearly_trends.csv`: Annual location trends
- `cleaned_data.rds`: Complete R data structure for advanced analysis

## 📈 Key Findings

### Statistical Results
- **Significant pandemic impact**: Kruskal-Wallis test confirmed significant differences across periods
- **Effect sizes**: Medium to large effect sizes detected between pre/during/post pandemic periods
- **Change points**: Algorithm detected major shifts coinciding with pandemic timeline

### Crime Pattern Changes
- **Decreased during pandemic**: Street crimes, public disturbances
- **Increased during pandemic**: Domestic violence, certain property crimes
- **Recovery patterns**: Varied significantly by crime type

### Methodological Insights
- Non-parametric methods more appropriate for crime count data
- Moving averages reveal clearer trends than raw monthly data
- Change point detection validates intuitive pandemic timeline

## 🛠️ Technical Stack

**Languages & Libraries**:
- **R**: Primary analysis language
- **tidyverse**: Data manipulation and visualization
- **lubridate**: Date handling
- **plotly**: Interactive visualizations
- **viridis**: Color palettes
- **effsize**: Effect size calculations
- **changepoint**: Change point detection
- **zoo**: Time series functions

**Statistical Methods**:
- Kruskal-Wallis Test
- Wilcoxon Pairwise Tests
- Cohen's d Effect Size
- PELT Change Point Detection
- Moving Average Smoothing

## 📁 Repository Structure

```
development-history/
├── README.md                                    # This file
├── v1-prototype-exploration/
│   └── 01-initial-pandemic-density-analysis.R  # Initial exploration
├── v2-statistical-validation/
│   └── 02-statistical-methods-exploration.R    # Statistical method testing
├── v3-comprehensive-analysis/
│   └── 03-comprehensive-pandemic-impact-study.R # Full analysis
└── v4-data-infrastructure/
    ├── 04a-raw-data-preprocessing.R             # Data cleaning
    └── 04b-summary-data-generation.R           # Summary generation
```

## 🚦 Getting Started

### Prerequisites
```r
install.packages(c("tidyverse", "lubridate", "plotly", "viridis", 
                   "effsize", "changepoint", "zoo"))
```

### Data Requirements
- Chicago crime dataset (`Crimes.csv`)
- Columns required: Date, X.Coordinate, Y.Coordinate, Year, Primary.Type, Location.Description

### Execution Order
1. Run `04a-raw-data-preprocessing.R` to create daily summaries
2. Run `04b-summary-data-generation.R` to create analytical datasets
3. Run `03-comprehensive-pandemic-impact-study.R` for full analysis

## 📊 Output Files

### Generated Visualizations
- `Monthly_Trends.png`: Time series with moving averages
- `Crime_Types_Heatmap.png`: Crime frequency by period
- `Crime_Change_Rates.png`: Percentage changes during pandemic
- `Pandemic_Density.png`: Density comparisons (from v1)

### Generated Data Files
- Multiple CSV summaries for different analytical perspectives
- RDS file with complete processed dataset
- Summary statistics tables

## 🔍 Future Enhancements

### Planned Improvements
- **Spatial Analysis**: Geographic crime pattern changes
- **Seasonal Decomposition**: Account for natural seasonal trends
- **Machine Learning**: Predictive modeling for crime patterns
- **Interactive Dashboard**: Shiny application for dynamic exploration
- **Real-time Updates**: Automated data pipeline integration

### Research Extensions
- **Economic Impact Analysis**: Correlation with unemployment/economic indicators
- **Policy Evaluation**: Impact of specific pandemic policies
- **Comparative Analysis**: Multi-city pandemic impact comparison
- **Long-term Recovery**: Extended post-pandemic pattern analysis

## 📝 Methodology Notes

### Statistical Considerations
- Non-parametric methods chosen due to non-normal crime count distributions
- Bonferroni correction applied for multiple comparisons
- Effect sizes reported alongside p-values for practical significance
- Change point detection validates temporal boundaries

### Data Quality Measures
- Outlier removal based on coordinate validity
- Complete case analysis for spatial data
- Consistent date parsing and validation
- Regular data structure verification

## 🤝 Contributing

This project represents an educational journey through statistical analysis development. Each phase builds methodological sophistication while maintaining reproducibility and clear documentation.

### Contact
For questions about methodology or implementation details, please refer to the code comments and statistical output summaries included in each analysis file.

---

*This project demonstrates the iterative nature of data science work, from initial exploration to production-ready analysis infrastructure.*
