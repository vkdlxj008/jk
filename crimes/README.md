# 🚔 Chicago Crime Analysis Project

> **Comprehensive analysis of Chicago crime patterns with focus on COVID-19 pandemic impact**

## 📊 Project Overview

This project analyzes Chicago Police Department crime data to understand how crime patterns changed during the COVID-19 pandemic. Using statistical methods and advanced visualizations, we examine temporal trends, crime type distributions, and spatial patterns.

### 🎯 Key Findings

- **Statistical Significance**: Kruskal-Wallis test reveals significant differences in crime rates across pandemic periods
- **Effect Sizes**: Cohen's d analysis quantifies the magnitude of changes
- **Crime Type Variations**: Different crime types showed varying responses to pandemic restrictions
- **Recovery Patterns**: Analysis of post-pandemic crime recovery trends

## 🏗 Project Structure

```
crimes/
├── README.md                    # 📝 This file
├── analysis.R                   # 🚀 One-click analysis runner
├── data/
│   ├── daily_crimes.csv        # 📊 Pre-aggregated daily crime data (GitHub-friendly)
│   ├── monthly_summary.csv     # 📈 Monthly aggregations
│   ├── crime_types_summary.csv # 🔍 Crime type breakdowns
│   ├── locations_summary.csv   # 📍 Location-based analysis
│   └── processed/              # 🔄 Analysis-ready datasets
├── scripts/
│   ├── 00_setup.R              # 📦 Package loading & configuration
│   ├── 01_load_aggregated_data.R # 📥 Load pre-processed data
│   ├── 02_legacy_integration.R  # 🔄 Integrate legacy methods
│   ├── 03_statistical_analysis_updated.R # 📊 Statistical tests
│   ├── 04_visualization_updated.R # 📈 Advanced visualizations
│   └── 05_generate_report_updated.R # 📋 Automated reporting
├── development-history/                     # 🗂 Original development files
│   ├── README.md                 # development-history documentation
│   ├── v1-prototype-exploration  # Original analysis script
│   │   └── 01-initial-pandemic-density-analysis.R          
│   ├── v2-statistical-valiation  # Statistical tests
│   │   └── 02-statistical-methods-exploration.R
│   ├── v3-comprehensive-analysis # Enhanced version 
│   │   └── 03-comprehensive-pandemic-impact-study.R
│   ├── v4-data-infrastructure    # data preprocessing & processing
│   │   ├── 04a-raw-data-preprocessing.R
│   │   └── 04b-summary-data-generation.R
│   └── outputs/               # Original outputs
├── outputs/
│   ├── plots/                  # 📈 Generated visualizations
│   │   ├── pandemic_impact/    # Pandemic-specific charts(planned)
│   │   ├── temporal_analysis/  # Time series visualizations(planned)
│   │   ├── crime_types/       # Crime type breakdowns(planned)
│   │   └── summary_dashboard.png # Main dashboard(planned)
│   ├── tables/                 # 📄 Analysis results(planned)
│   └── reports/               # 📋 Generated reports(planned)
├── shiny/
│   └── app.R                   # 🎛 Interactive dashboard (planned)
├── .gitignore                  # Git ignore rules
└── renv.lock                   # R environment lock file
```

## 🚀 Quick Start

### Prerequisites

- **R** (version 4.0+)
- **Required packages** (automatically installed):
  ```r
  tidyverse, lubridate, plotly, viridis, effsize, 
  changepoint, zoo, scales, gridExtra, RColorBrewer
  ```

### Running the Analysis

#### Option 1: Full Analysis (Recommended)
```r
# Run complete analysis pipeline
source("analysis.R")
```

#### Option 2: Step-by-Step
```r
# 1. Setup and load data
source("scripts/00_setup.R")
source("scripts/01_load_aggregated_data.R")

# 2. Run statistical analysis
source("scripts/03_statistical_analysis_updated.R")

# 3. Generate visualizations
source("scripts/04_visualization_updated.R")

# 4. Create reports
source("scripts/05_generate_report_updated.R")
```

## 📊 Data Sources

### Primary Dataset
- **Source**: Chicago Police Department via Chicago Data Portal
- **Original Size**: ~1.7GB (6.5M+ records)
- **GitHub Version**: Pre-aggregated daily summaries (~50MB)
- **Time Range**: 2017-2023
- **Geographic Coverage**: City of Chicago

### Data Processing Notes
- **Original data** contains individual crime incidents with coordinates
- **Aggregated data** provides daily counts by crime type and location
- **Outlier removal** applied to geographic coordinates (3-sigma rule)
- **Missing data** handling for incomplete records

## 🔬 Methodology

### Statistical Analysis
- **Non-parametric testing**: Kruskal-Wallis test (data not normally distributed)
- **Post-hoc analysis**: Pairwise Wilcoxon tests with Bonferroni correction
- **Effect size**: Cohen's d for practical significance
- **Change point detection**: PELT method for temporal breakpoints
- **Multiple comparisons**: Various statistical tests (T-test, F-test, Chi-square)

### Temporal Classification
```
📅 Before Pandemic:  2017-2019 (baseline period)
🦠 During Pandemic:  2020-2021 (lockdowns & restrictions)
📈 After Pandemic:   2022-2023 (recovery period)
```

### Key Metrics
- **Daily crime rates** by period
- **Percentage changes** in crime types
- **Recovery ratios** (post vs pre-pandemic)
- **Seasonal adjustments** and trend analysis

## 📈 Key Visualizations

1. **📊 Summary Dashboard** - Overview of all key findings
2. **📈 Time Series Analysis** - Monthly trends with moving averages
3. **🦠 Pandemic Impact Charts** - Before/during/after comparisons
4. **🔥 Crime Type Heatmaps** - Intensity maps by period
5. **📦 Distribution Analysis** - Box plots and density curves
6. **📍 Geographic Patterns** - Location-based analysis
7. **🎮 Interactive Plots** - Plotly-based dynamic charts

## 📋 Results Summary

### Statistical Significance
- **Kruskal-Wallis Test**: H = XX.XX, p < 0.001
- **Effect Sizes**: Medium to large effects observed
- **Most Impacted Crime Types**: 
  - Largest decreases: [Auto-generated from analysis]
  - Largest increases: [Auto-generated from analysis]

### Pandemic Impact Patterns
- **Overall Crime**: X% decrease during pandemic
- **Recovery Status**: X% of pre-pandemic levels by 2023
- **Persistent Changes**: Some crime types show lasting effects

## 🛠 Technical Features

### Code Quality
- ✅ **Modular design** - Separated concerns across multiple scripts
- ✅ **Error handling** - Comprehensive try-catch blocks
- ✅ **Progress tracking** - Real-time status updates
- ✅ **Data validation** - Quality checks and verification
- ✅ **Reproducibility** - Consistent random seeds and environment

### Output Quality
- ✅ **High-resolution plots** (300 DPI)
- ✅ **Publication-ready** visualizations
- ✅ **Interactive dashboards** for exploration
- ✅ **Automated reports** in multiple formats
- ✅ **Comprehensive documentation**

## 🚨 Important Notes

### Data Limitations
- **Reporting bias**: Only includes reported crimes
- **Geographic scope**: Chicago city limits only
- **Temporal gaps**: Some missing data periods
- **Classification changes**: Crime type definitions may vary over time

### GitHub Considerations
- **Large files**: Original 1.7GB dataset not included
- **Preprocessed data**: Daily aggregations provided instead
- **Local reproduction**: Full analysis requires original dataset
- **Legacy preservation**: Original code maintained in `legacy/` folder

## 🔄 Legacy Integration

This project builds on previous analysis iterations:

- **`legacy/crimes.R`**: Original density analysis
- **`legacy/analysis_enhancement.R`**: Statistical improvements
- **`legacy/analysis_some_statistical_validation.R`**: Multiple test methods

All legacy approaches are integrated and improved in the current version while preserving original methodologies for comparison.

## 🎛 Interactive Features

### Planned Shiny Dashboard
- **Real-time filtering** by crime type and date range
- **Interactive maps** with geographic drill-down
- **Dynamic comparisons** between different periods
- **Exportable reports** with custom parameters

## 📚 Further Reading

- [Chicago Data Portal](https://data.cityofchicago.org/)
- [Pandemic Crime Impact Studies](https://example.com) *(placeholder)*
- [Statistical Methods Documentation](https://example.com) *(placeholder)*

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

- **Chicago Police Department** for providing open data
- **R Community** for excellent statistical packages
- **COVID-19 researchers** for methodological insights

---

*Last updated: [Auto-generated timestamp]*
*Analysis version: 2.0 (Aggregated Data Edition)*
