# ===============================================
# 📋 분석 리포트 생성기
# ===============================================

cat("📋 분석 리포트 생성 시작...\n")

# 필요한 데이터 로드
preprocessing_summary <- readRDS(file.path(PROCESSED_DATA_PATH, "preprocessing_summary.rds"))
statistical_results <- readRDS("outputs/tables/statistical_analysis_results.rds")
daily_crimes <- readRDS(file.path(PROCESSED_DATA_PATH, "daily_crimes.rds"))
crime_type_summary <- readRDS(file.path(PROCESSED_DATA_PATH, "crime_type_summary.rds"))

# ===============================================
# 1. 마크다운 리포트 생성
# ===============================================

cat("📝 마크다운 리포트 작성 중...\n")

# 리포트 헤더
report_content <- paste0(
  "# Chicago Crime Analysis Report
*Generated on: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "*

## 📊 Executive Summary

This report analyzes Chicago crime data to assess the impact of the COVID-19 pandemic on crime patterns. The analysis covers ", 
  format(preprocessing_summary$final_rows, big.mark = ","), " crime incidents from ", 
  preprocessing_summary$date_range[1], " to ", preprocessing_summary$date_range[2], ".

### Key Findings

")

# 통계적 유의성 결과 추가
if(statistical_results$kruskal_result$significant) {
  significance_text <- "✅ **Statistically Significant Impact**: The Kruskal-Wallis test revealed significant differences in daily crime rates across pandemic periods (p < 0.05)."
} else {
  significance_text <- "❌ **No Statistically Significant Impact**: The Kruskal-Wallis test found no significant differences in daily crime rates across pandemic periods (p ≥ 0.05)."
}

report_content <- paste0(report_content, significance_text, "\n\n")

# 기술통계 섹션
report_content <- paste0(report_content, 
                         "## 📈 Descriptive Statistics

### Daily Crime Rates by Period

| Period | Mean | Median | Std Dev | Min | Max | Total Days |
|--------|------|--------|---------|-----|-----|------------|
")

for(i in 1:nrow(statistical_results$summary_stats)) {
  row <- statistical_results$summary_stats[i,]
  report_content <- paste0(report_content,
                           "| ", row$Period, " | ", row$mean_daily_crimes, " | ", row$median_daily_crimes, 
                           " | ", row$sd_daily_crimes, " | ", row$min_daily_crimes, " | ", 
                           row$max_daily_crimes, " | ", format(row$total_days, big.mark = ","), " |\n")
}

# Effect Size 섹션
report_content <- paste0(report_content, "\n### Effect Sizes (Cohen's d)

The magnitude of differences between periods:\n\n")

for(i in 1:nrow(statistical_results$effect_sizes)) {
  row <- statistical_results$effect_sizes[i,]
  report_content <- paste0(report_content, 
                           "- **", row$Comparison, "**: d = ", round(row$Cohens_d, 3), 
                           " (", row$Effect_interpretation, " effect)\n")
}

# 범죄 유형 분석 섹션
report_content <- paste0(report_content, "\n\n## 🔍 Crime Type Analysis

### Most Impacted Crime Types During Pandemic

**Biggest Decreases:**\n")

for(i in 1:min(5, nrow(statistical_results$top_decreased_crimes))) {
  row <- statistical_results$top_decreased_crimes[i,]
  report_content <- paste0(report_content,
                           i, ". ", row$Primary.Type, ": ", round(row$pct_change_during, 1), "% decrease\n")
}

report_content <- paste0(report_content, "\n**Biggest Increases:**\n")

for(i in 1:min(5, nrow(statistical_results$top_increased_crimes))) {
  row <- statistical_results$top_increased_crimes[i,]
  report_content <- paste0(report_content,
                           i, ". ", row$Primary.Type, ": +", round(row$pct_change_during, 1), "% increase\n")
}

# 방법론 섹션
report_content <- paste0(report_content, "\n\n## 🔬 Methodology

### Data Processing
- **Original Dataset**: ", format(preprocessing_summary$original_rows, big.mark = ","), " records
- **Final Dataset**: ", format(preprocessing_summary$final_rows, big.mark = ","), " records (after cleaning)
- **Outlier Removal**: Using 3-sigma rule for coordinate outliers
- **Period Classification**:
  - Before: 2017-2019
  - During: 2020-2021  
  - After: 2022-2023

### Statistical Tests
- **Non-parametric Testing**: Kruskal-Wallis test (due to non-normal distributions)
- **Post-hoc Analysis**: Pairwise Wilcoxon tests with Bonferroni correction
- **Effect Size**: Cohen's d for magnitude assessment
- **Change Point Detection**: PELT method for temporal analysis

### Limitations
- Analysis limited to reported crimes only
- Geographic outliers removed may represent valid but extreme locations
- Seasonal effects not fully controlled
- Causal inference limited due to observational nature of data

## 📁 Generated Outputs

### Visualizations
- `outputs/plots/summary_dashboard.png` - Overview dashboard
- `outputs/plots/pandemic_impact/` - Pandemic-specific analyses
- `outputs/plots/temporal_analysis/` - Time series visualizations
- `outputs/plots/crime_types/` - Crime type breakdowns

### Data Tables
- `outputs/tables/summary_statistics.csv` - Descriptive statistics
- `outputs/tables/effect_sizes.csv` - Statistical effect sizes
- `outputs/tables/most_decreased_crimes.csv` - Crime types with biggest decreases
- `outputs/tables/most_increased_crimes.csv` - Crime types with biggest increases

---
*This report was generated automatically using R. For questions about methodology or to reproduce results, run `analysis.R` in the project root directory.*
")

# 리포트 저장
writeLines(report_content, "outputs/reports/analysis_summary.md")

# ===============================================
# 2. HTML 리포트 생성 (선택사항)
# ===============================================

if(require(rmarkdown, quietly = TRUE)) {
  cat("🌐 HTML 리포트 생성 중...\n")
  
  # R Markdown 파일 생성
  rmd_content <- paste0('---
title: "Chicago Crime Analysis Report"
author: "Automated Analysis System"
date: "', format(Sys.time(), "%Y-%m-%d"), '"
output: 
  html_document:
    toc: true
    toc_float: true
    theme: flatly
    highlight: tango
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
library(knitr)
library(DT)
```

', report_content)
  
  writeLines(rmd_content, "outputs/reports/analysis_report.Rmd")
  
  tryCatch({
    rmarkdown::render("outputs/reports/analysis_report.Rmd")
    cat("✅ HTML 리포트 생성 완료\n")
  }, error = function(e) {
    cat("⚠️ HTML 리포트 생성 실패:", e$message, "\n")
  })
}

# ===============================================
# 3. 실행 로그 생성
# ===============================================

cat("📝 실행 로그 생성 중...\n")

execution_log <- list(
  analysis_date = Sys.time(),
  r_version = R.version.string,
  packages_used = required_packages,
  data_summary = preprocessing_summary,
  statistical_summary = list(
    kruskal_significant = statistical_results$kruskal_result$significant,
    kruskal_p_value = statistical_results$kruskal_result$p_value,
    num_crime_types_analyzed = nrow(crime_type_summary),
    total_periods_compared = length(unique(daily_crimes$Period))
  ),
  outputs_generated = list(
    plots_created = length(list.files("outputs/plots", recursive = TRUE, pattern = "\\.(png|html)$")),
    tables_created = length(list.files("outputs/tables", pattern = "\\.csv$")),
    reports_created = length(list.files("outputs/reports", pattern = "\\.(md|html)$"))
  )
)

saveRDS(execution_log, "outputs/reports/execution_log.rds")

# 간단한 로그 텍스트 파일도 생성
log_text <- paste0(
  "Chicago Crime Analysis Execution Log\n",
  "====================================\n",
  "Execution Date: ", format(execution_log$analysis_date, "%Y-%m-%d %H:%M:%S"), "\n",
  "R Version: ", execution_log$r_version, "\n",
  "Data Records Processed: ", format(execution_log$data_summary$final_rows, big.mark = ","), "\n",
  "Statistical Significance: ", ifelse(execution_log$statistical_summary$kruskal_significant, "YES", "NO"), "\n",
  "Plots Generated: ", execution_log$outputs_generated$plots_created, "\n",
  "Tables Generated: ", execution_log$outputs_generated$tables_created, "\n",
  "Reports Generated: ", execution_log$outputs_generated$reports_created, "\n"
)

writeLines(log_text, "outputs/reports/execution_log.txt")

# ===============================================
# 4. 개발 로그 업데이트
# ===============================================

cat("📚 개발 로그 업데이트 중...\n")

development_log <- paste0(
  "# Development Log

## ", format(Sys.Date(), "%Y-%m-%d"), " - Project Restructuring

### Changes Made
- Refactored monolithic analysis script into modular structure
- Created organized folder hierarchy
- Added comprehensive documentation
- Implemented automated report generation
- Enhanced statistical analysis with effect sizes
- Improved visualization quality and consistency

### Project Structure
```
crimes/
├── analysis.R                 # Main execution script
├── scripts/                   # Modular analysis scripts
│   ├── 00_setup.R
│   ├── 01_data_preprocessing.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_statistical_analysis.R
│   ├── 04_visualization.R
│   └── 05_generate_report.R
├── data/                      # Data storage
├── outputs/                   # Results and visualizations
├── legacy/                    # Original development files
└── shiny/                     # Interactive dashboard
```

### Analysis Improvements
- Added robust statistical testing (Kruskal-Wallis)
- Implemented effect size calculations (Cohen's d)
- Enhanced change point detection
- Improved crime type categorization
- Added recovery analysis

### Next Steps
- [ ] Implement Shiny dashboard
- [ ] Add geographic analysis
- [ ] Include seasonal decomposition
- [ ] Add forecasting models
- [ ] Create automated scheduling

---
")

# 기존 개발 로그가 있으면 추가, 없으면 새로 생성
dev_log_path <- "outputs/reports/development_log.md"
if(file.exists(dev_log_path)) {
  existing_log <- readLines(dev_log_path)
  development_log <- paste0(development_log, "\n", paste(existing_log, collapse = "\n"))
}

writeLines(development_log, dev_log_path)

cat("✅ 리포트 생성 완료!\n")
cat("📁 생성된 파일들:\n")
cat("  📝 outputs/reports/analysis_summary.md\n")
if(file.exists("outputs/reports/analysis_report.html")) {
  cat("  🌐 outputs/reports/analysis_report.html\n")
}
cat("  📊 outputs/reports/execution_log.txt\n")
cat("  📚 outputs/reports/development_log.md\n\n")