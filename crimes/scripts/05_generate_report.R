# ===============================================
# 📋 개선된 분석 리포트 생성기 (완전한 에러 핸들링)
# ===============================================

cat("📋 분석 리포트 생성 시작...\n")

# ===============================================
# 0. 스마트 파일 탐지 및 로드 시스템
# ===============================================

smart_load_rds <- function(possible_paths, description = "파일") {
  for(path in possible_paths) {
    if(file.exists(path)) {
      cat("✅", description, "로드:", path, "\n")
      return(readRDS(path))
    }
  }
  cat("⚠️ ", description, "을 찾을 수 없습니다. 시도한 경로:\n")
  for(path in possible_paths) {
    cat("   -", path, "\n")
  }
  return(NULL)
}

# 경로 설정
if(!exists("PROCESSED_DATA_PATH")) {
  PROCESSED_DATA_PATH <- "data/processed"
  cat("📍 PROCESSED_DATA_PATH 설정:", PROCESSED_DATA_PATH, "\n")
}

cat("📂 데이터 파일 탐지 및 로드 중...\n")

# 각 데이터별로 여러 가능한 파일명 시도
daily_crimes <- smart_load_rds(c(
  file.path(PROCESSED_DATA_PATH, "daily_crimes.rds"),
  file.path(PROCESSED_DATA_PATH, "daily_crimes_analysis.rds"),
  file.path(PROCESSED_DATA_PATH, "daily_crimes_cleaned.rds"),
  file.path(PROCESSED_DATA_PATH, "daily_crimes_for_analysis.rds")
), "일별 범죄 데이터")

crime_type_summary <- smart_load_rds(c(
  file.path(PROCESSED_DATA_PATH, "crime_type_summary.rds"),
  file.path(PROCESSED_DATA_PATH, "crime_type_analysis.rds"),
  file.path(PROCESSED_DATA_PATH, "crime_types_summary.rds")
), "범죄 유형 요약")

# 데이터 품질 보고서 (전처리 요약 대신 사용 가능)
data_quality <- smart_load_rds(c(
  file.path(PROCESSED_DATA_PATH, "preprocessing_summary.rds"),
  file.path(PROCESSED_DATA_PATH, "data_quality_report.rds")
), "데이터 품질 보고서")

# 통계 분석 결과
statistical_results <- smart_load_rds(c(
  "outputs/tables/statistical_analysis_results.rds"
), "통계 분석 결과")

# 레거시 통합 결과
legacy_results <- smart_load_rds(c(
  "outputs/tables/legacy_integration_results.rds"
), "레거시 통합 결과")

# ===============================================
# 1. 대체 데이터 생성 및 검증
# ===============================================

create_fallback_from_loaded_data <- function() {
  cat("🔧 로드된 데이터로부터 누락 정보 재구성 중...\n")
  
  # outputs 폴더 구조 확인/생성
  if(!dir.exists("outputs/tables")) dir.create("outputs/tables", recursive = TRUE)
  if(!dir.exists("outputs/reports")) dir.create("outputs/reports", recursive = TRUE)
  
  # data_quality 보고서를 preprocessing_summary로 변환
  if(!is.null(data_quality) && is.null(preprocessing_summary)) {
    preprocessing_summary <<- list(
      original_rows = if(!is.null(data_quality$original_records)) data_quality$original_records else "알 수 없음",
      final_rows = if(!is.null(data_quality$analysis_records)) data_quality$analysis_records else "알 수 없음",
      date_range = if(!is.null(data_quality$date_range)) as.character(data_quality$date_range) else c("2017-01-01", "2023-12-31"),
      outliers_removed = 0,
      processing_date = Sys.time()
    )
  }
  
  # daily_crimes가 있으면 기본 통계 생성
  if(!is.null(daily_crimes) && is.null(statistical_results)) {
    cat("📊 로드된 데이터로부터 기본 통계 생성 중...\n")
    
    # 일별 범죄 데이터에서 기본 통계 추출
    if("Period" %in% colnames(daily_crimes) && "crime_counts" %in% colnames(daily_crimes)) {
      basic_stats <- daily_crimes %>%
        group_by(Period) %>%
        summarise(
          mean_daily_crimes = round(mean(crime_counts, na.rm = TRUE), 2),
          median_daily_crimes = round(median(crime_counts, na.rm = TRUE), 2),
          sd_daily_crimes = round(sd(crime_counts, na.rm = TRUE), 2),
          min_daily_crimes = min(crime_counts, na.rm = TRUE),
          max_daily_crimes = max(crime_counts, na.rm = TRUE),
          total_days = n(),
          .groups = "drop"
        )
      
      statistical_results <<- list(
        kruskal_result = list(
          significant = FALSE,
          p_value = NA,
          statistic = NA
        ),
        summary_stats = basic_stats,
        effect_sizes = data.frame(
          Comparison = c("Before vs During", "During vs After", "Before vs After"),
          Cohens_d = c(0, 0, 0),
          Effect_interpretation = c("No data", "No data", "No data")
        ),
        top_decreased_crimes = data.frame(
          Primary.Type = "데이터 부족",
          pct_change_during = 0
        ),
        top_increased_crimes = data.frame(
          Primary.Type = "데이터 부족", 
          pct_change_during = 0
        )
      )
    }
  }
  
  # 완전히 누락된 데이터들에 대한 기본값 설정
  if(is.null(preprocessing_summary)) {
    preprocessing_summary <<- list(
      original_rows = "알 수 없음",
      final_rows = "알 수 없음", 
      date_range = c("2017-01-01", "2023-12-31"),
      outliers_removed = 0,
      processing_date = Sys.time()
    )
  }
  
  if(is.null(statistical_results)) {
    statistical_results <<- list(
      kruskal_result = list(
        significant = FALSE,
        p_value = NA,
        statistic = NA
      ),
      summary_stats = data.frame(
        Period = c("Before", "During", "After"),
        mean_daily_crimes = c(0, 0, 0),
        median_daily_crimes = c(0, 0, 0),
        sd_daily_crimes = c(0, 0, 0),
        min_daily_crimes = c(0, 0, 0),
        max_daily_crimes = c(0, 0, 0),
        total_days = c(0, 0, 0)
      ),
      effect_sizes = data.frame(
        Comparison = c("Before vs During", "During vs After", "Before vs After"),
        Cohens_d = c(0, 0, 0),
        Effect_interpretation = c("No effect", "No effect", "No effect")
      ),
      top_decreased_crimes = data.frame(
        Primary.Type = "데이터 없음",
        pct_change_during = 0
      ),
      top_increased_crimes = data.frame(
        Primary.Type = "데이터 없음", 
        pct_change_during = 0
      )
    )
  }
  
  if(is.null(daily_crimes)) {
    daily_crimes <<- data.frame(
      Date = as.Date("2020-01-01"),
      Period = "During",
      crime_counts = 0
    )
  }
  
  if(is.null(crime_type_summary)) {
    crime_type_summary <<- data.frame(
      Primary.Type = "데이터 없음",
      total_crimes = 0,
      avg_per_day = 0
    )
  }
  
  cat("✅ 대체 데이터 생성 완료\n")
}

# 누락된 데이터가 있으면 대체 데이터 생성
if(is.null(daily_crimes) || is.null(statistical_results) || 
   is.null(crime_type_summary)) {
  create_fallback_from_loaded_data()
}

# ===============================================
# 2. 데이터 상태 확인
# ===============================================

data_status <- list(
  preprocessing_complete = !is.null(data_quality) || (!is.null(preprocessing_summary) && preprocessing_summary$final_rows != "알 수 없음"),
  statistical_complete = !is.null(statistical_results) && !is.na(statistical_results$kruskal_result$p_value),
  has_legacy_results = !is.null(legacy_results),
  daily_crimes_available = !is.null(daily_crimes) && nrow(daily_crimes) > 1,
  crime_types_available = !is.null(crime_type_summary) && nrow(crime_type_summary) > 1
)

cat("📊 데이터 상태 확인:\n")
cat("  - 전처리 완료:", ifelse(data_status$preprocessing_complete, "✅", "❌"), "\n")
cat("  - 통계 분석:", ifelse(data_status$statistical_complete, "✅", "❌"), "\n")
cat("  - 일별 데이터:", ifelse(data_status$daily_crimes_available, "✅", "❌"), "\n")
cat("  - 범죄 유형:", ifelse(data_status$crime_types_available, "✅", "❌"), "\n")
cat("  - 레거시 결과:", ifelse(data_status$has_legacy_results, "✅", "❌"), "\n")

# ===============================================
# 3. 마크다운 리포트 생성
# ===============================================

cat("📝 마크다운 리포트 작성 중...\n")

# 리포트 헤더
report_content <- paste0(
  "# Chicago Crime Analysis Report\n",
  "*Generated on: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "*\n\n",
  "## 📋 Data Processing Status\n\n"
)

# 데이터 상태 표시
if(data_status$preprocessing_complete) {
  if(!is.null(data_quality)) {
    final_rows <- if(!is.null(data_quality$analysis_records)) data_quality$analysis_records else data_quality$final_rows
    date_range <- if(!is.null(data_quality$date_range)) data_quality$date_range else c("2017", "2023")
  } else {
    final_rows <- preprocessing_summary$final_rows
    date_range <- preprocessing_summary$date_range
  }
  
  report_content <- paste0(report_content, 
                           "✅ **Data Preprocessing**: Complete (", 
                           format(final_rows, big.mark = ","), " records processed)\n")
} else {
  report_content <- paste0(report_content, 
                           "⚠️ **Data Preprocessing**: Incomplete or using fallback data\n")
}

if(data_status$statistical_complete) {
  report_content <- paste0(report_content, "✅ **Statistical Analysis**: Complete\n")
} else {
  report_content <- paste0(report_content, "⚠️ **Statistical Analysis**: Incomplete or using fallback data\n")
}

if(data_status$daily_crimes_available) {
  report_content <- paste0(report_content, "✅ **Daily Crime Data**: Available\n")
} else {
  report_content <- paste0(report_content, "⚠️ **Daily Crime Data**: Limited or missing\n")
}

if(data_status$crime_types_available) {
  report_content <- paste0(report_content, "✅ **Crime Type Analysis**: Available\n")
} else {
  report_content <- paste0(report_content, "⚠️ **Crime Type Analysis**: Limited or missing\n")
}

if(data_status$has_legacy_results) {
  report_content <- paste0(report_content, "✅ **Legacy Integration**: Complete\n")
} else {
  report_content <- paste0(report_content, "❌ **Legacy Integration**: Not available\n")
}

report_content <- paste0(report_content, "\n## 📊 Executive Summary\n\n")

# 실행 요약
if(data_status$preprocessing_complete) {
  if(!is.null(data_quality)) {
    final_rows <- if(!is.null(data_quality$analysis_records)) data_quality$analysis_records else "처리된 레코드"
    date_range <- if(!is.null(data_quality$date_range)) as.character(data_quality$date_range) else c("2017", "2023")
  } else {
    final_rows <- preprocessing_summary$final_rows
    date_range <- preprocessing_summary$date_range
  }
  
  report_content <- paste0(report_content,
                           "This report analyzes Chicago crime data to assess the impact of the COVID-19 pandemic on crime patterns. The analysis covers ",
                           format(final_rows, big.mark = ","), " crime incidents from ",
                           date_range[1], " to ", date_range[2], ".\n\n")
} else if(data_status$daily_crimes_available) {
  date_range <- range(daily_crimes$Date, na.rm = TRUE)
  total_records <- nrow(daily_crimes)
  
  report_content <- paste0(report_content,
                           "This report analyzes Chicago crime data using aggregated daily crime records. The analysis covers ",
                           format(total_records, big.mark = ","), " data points from ",
                           as.character(date_range[1]), " to ", as.character(date_range[2]), ".\n\n")
} else {
  report_content <- paste0(report_content,
                           "This report provides a framework for Chicago crime analysis. **Note**: Some analysis components are incomplete due to missing input data.\n\n")
}

# 주요 발견사항
report_content <- paste0(report_content, "### Key Findings\n\n")

if(data_status$statistical_complete) {
  if(statistical_results$kruskal_result$significant) {
    significance_text <- "✅ **Statistically Significant Impact**: The Kruskal-Wallis test revealed significant differences in daily crime rates across pandemic periods (p < 0.05)."
  } else {
    significance_text <- "❌ **No Statistically Significant Impact**: The Kruskal-Wallis test found no significant differences in daily crime rates across pandemic periods (p ≥ 0.05)."
  }
  report_content <- paste0(report_content, significance_text, "\n\n")
} else {
  report_content <- paste0(report_content, "⚠️ **Statistical Analysis Pending**: Unable to determine statistical significance due to missing data.\n\n")
}

# ===============================================
# 4. 기술통계 섹션
# ===============================================

if(data_status$statistical_complete && nrow(statistical_results$summary_stats) > 0) {
  report_content <- paste0(report_content, 
                           "## 📈 Descriptive Statistics\n\n",
                           "### Daily Crime Rates by Period\n\n",
                           "| Period | Mean | Median | Std Dev | Min | Max | Total Days |\n",
                           "|--------|------|--------|---------|-----|-----|-----------|\n")
  
  for(i in 1:nrow(statistical_results$summary_stats)) {
    row <- statistical_results$summary_stats[i,]
    report_content <- paste0(report_content,
                             "| ", row$Period, " | ", row$mean_daily_crimes, " | ", row$median_daily_crimes, 
                             " | ", row$sd_daily_crimes, " | ", row$min_daily_crimes, " | ", 
                             row$max_daily_crimes, " | ", format(row$total_days, big.mark = ","), " |\n")
  }
  
  # Effect Size 섹션
  if(nrow(statistical_results$effect_sizes) > 0) {
    report_content <- paste0(report_content, "\n### Effect Sizes (Cohen's d)\n\n",
                             "The magnitude of differences between periods:\n\n")
    
    for(i in 1:nrow(statistical_results$effect_sizes)) {
      row <- statistical_results$effect_sizes[i,]
      report_content <- paste0(report_content, 
                               "- **", row$Comparison, "**: d = ", round(row$Cohens_d, 3), 
                               " (", row$Effect_interpretation, " effect)\n")
    }
  }
} else if(data_status$daily_crimes_available) {
  report_content <- paste0(report_content, "## 📈 Basic Data Summary\n\n",
                           "### Available Data Overview\n\n")
  
  if("Period" %in% colnames(daily_crimes)) {
    period_summary <- daily_crimes %>%
      group_by(Period) %>%
      summarise(
        records = n(),
        avg_crimes = round(mean(crime_counts, na.rm = TRUE), 2),
        total_crimes = sum(crime_counts, na.rm = TRUE),
        .groups = "drop"
      )
    
    report_content <- paste0(report_content, 
                             "| Period | Records | Avg Daily | Total Crimes |\n",
                             "|--------|---------|-----------|-------------|\n")
    
    for(i in 1:nrow(period_summary)) {
      row <- period_summary[i,]
      report_content <- paste0(report_content,
                               "| ", row$Period, " | ", format(row$records, big.mark = ","), 
                               " | ", row$avg_crimes, " | ", format(row$total_crimes, big.mark = ","), " |\n")
    }
  }
} else {
  report_content <- paste0(report_content, "## 📈 Statistical Analysis\n\n",
                           "⚠️ **Limited Data Available**: Detailed statistical analysis could not be completed due to missing input data.\n\n")
}

# ===============================================
# 5. 범죄 유형 분석 섹션
# ===============================================

if(data_status$statistical_complete && 
   nrow(statistical_results$top_decreased_crimes) > 0 && 
   statistical_results$top_decreased_crimes$Primary.Type[1] != "데이터 없음") {
  
  report_content <- paste0(report_content, "## 🔍 Crime Type Analysis\n\n",
                           "### Most Impacted Crime Types During Pandemic\n\n",
                           "**Biggest Decreases:**\n")
  
  for(i in 1:min(5, nrow(statistical_results$top_decreased_crimes))) {
    row <- statistical_results$top_decreased_crimes[i,]
    report_content <- paste0(report_content,
                             i, ". ", row$Primary.Type, ": ", round(row$pct_change_during, 1), "% decrease\n")
  }
  
  if(nrow(statistical_results$top_increased_crimes) > 0 && 
     statistical_results$top_increased_crimes$Primary.Type[1] != "데이터 없음") {
    report_content <- paste0(report_content, "\n**Biggest Increases:**\n")
    
    for(i in 1:min(5, nrow(statistical_results$top_increased_crimes))) {
      row <- statistical_results$top_increased_crimes[i,]
      report_content <- paste0(report_content,
                               i, ". ", row$Primary.Type, ": +", round(row$pct_change_during, 1), "% increase\n")
    }
  }
} else if(data_status$crime_types_available) {
  report_content <- paste0(report_content, "## 🔍 Crime Type Overview\n\n",
                           "### Available Crime Types\n\n")
  
  if(nrow(crime_type_summary) > 1) {
    top_crimes <- head(crime_type_summary, 10)
    for(i in 1:nrow(top_crimes)) {
      row <- top_crimes[i,]
      if("total_crimes" %in% colnames(row)) {
        report_content <- paste0(report_content, i, ". ", row$Primary.Type, 
                                 ": ", format(row$total_crimes, big.mark = ","), " total incidents\n")
      } else {
        report_content <- paste0(report_content, i, ". ", row$Primary.Type, "\n")
      }
    }
  }
} else {
  report_content <- paste0(report_content, "## 🔍 Crime Type Analysis\n\n",
                           "⚠️ **Crime Type Analysis Unavailable**: Detailed crime type analysis could not be completed due to missing data.\n\n")
}

# ===============================================
# 6. 방법론 섹션
# ===============================================

report_content <- paste0(report_content, "## 🔬 Methodology\n\n",
                         "### Data Processing\n")

if(data_status$preprocessing_complete) {
  if(!is.null(data_quality)) {
    report_content <- paste0(report_content,
                             "- **Data Source**: Aggregated Chicago crime records\n",
                             "- **Processing Method**: Daily aggregation with period classification\n",
                             "- **Period Classification**:\n",
                             "  - Before: 2017-2019\n",
                             "  - During: 2020-2021\n",
                             "  - After: 2022-2023\n\n")
  } else {
    report_content <- paste0(report_content,
                             "- **Original Dataset**: ", format(preprocessing_summary$original_rows, big.mark = ","), " records\n",
                             "- **Final Dataset**: ", format(preprocessing_summary$final_rows, big.mark = ","), " records (after cleaning)\n",
                             "- **Period Classification**:\n",
                             "  - Before: 2017-2019\n",
                             "  - During: 2020-2021\n",
                             "  - After: 2022-2023\n\n")
  }
} else {
  report_content <- paste0(report_content,
                           "- **Data Processing**: Based on available aggregated crime data\n",
                           "- **Period Classification**: Standard pandemic period division\n",
                           "- **Quality Control**: Basic data validation applied\n\n")
}

report_content <- paste0(report_content, "### Statistical Methods\n")

if(data_status$statistical_complete) {
  report_content <- paste0(report_content,
                           "- **Non-parametric Testing**: Kruskal-Wallis test\n",
                           "- **Post-hoc Analysis**: Pairwise Wilcoxon tests with Bonferroni correction\n",
                           "- **Effect Size**: Cohen's d for magnitude assessment\n\n")
} else {
  report_content <- paste0(report_content,
                           "- **Descriptive Analysis**: Basic statistical summaries\n",
                           "- **Comparative Analysis**: Period-based comparisons where data allows\n\n")
}

report_content <- paste0(report_content,
                         "### Limitations\n",
                         "- Analysis based on available processed data\n",
                         "- Statistical testing limited by data completeness\n",
                         "- Geographic analysis not included in current scope\n",
                         "- Causal inference limited due to observational nature of data\n\n")

# ===============================================
# 7. 생성된 출력물
# ===============================================

report_content <- paste0(report_content, "## 📁 Generated Outputs\n\n")

# 실제 존재하는 파일들 체크
output_files <- list()
if(dir.exists("outputs/plots")) {
  plot_files <- list.files("outputs/plots", recursive = TRUE, pattern = "\\.(png|html)$")
  if(length(plot_files) > 0) {
    output_files$plots <- length(plot_files)
  }
}

if(dir.exists("outputs/tables")) {
  table_files <- list.files("outputs/tables", pattern = "\\.(csv|rds)$")
  if(length(table_files) > 0) {
    output_files$tables <- length(table_files)
  }
}

if(length(output_files) > 0) {
  if(!is.null(output_files$plots)) {
    report_content <- paste0(report_content, "- **Visualizations**: ", output_files$plots, " plot files generated\n")
  }
  if(!is.null(output_files$tables)) {
    report_content <- paste0(report_content, "- **Data Tables**: ", output_files$tables, " output files available\n")
  }
} else {
  report_content <- paste0(report_content, "- Output files will be generated upon full analysis completion\n")
}

report_content <- paste0(report_content, "\n---\n",
                         "*This report was generated automatically using R. Data availability: ",
                         ifelse(data_status$preprocessing_complete, "Complete", "Partial"), 
                         ". For questions about methodology, ensure all analysis scripts are executed in sequence.*\n")

# ===============================================
# 8. 리포트 저장
# ===============================================

if(!dir.exists("outputs/reports")) {
  dir.create("outputs/reports", recursive = TRUE)
}

writeLines(report_content, "outputs/reports/analysis_summary.md")

# ===============================================
# 9. 실행 로그 생성
# ===============================================

cat("📝 실행 로그 생성 중...\n")

execution_log <- list(
  analysis_date = Sys.time(),
  r_version = R.version.string,  
  data_status = data_status,
  files_loaded = list(
    daily_crimes = !is.null(daily_crimes) && nrow(daily_crimes) > 1,
    crime_types = !is.null(crime_type_summary) && nrow(crime_type_summary) > 1,
    statistical_results = !is.null(statistical_results),
    legacy_results = !is.null(legacy_results)
  ),
  outputs_generated = list(
    plots_available = if(exists("output_files") && !is.null(output_files$plots)) output_files$plots else 0,
    tables_available = if(exists("output_files") && !is.null(output_files$tables)) output_files$tables else 0,
    reports_created = 1
  )
)

saveRDS(execution_log, "outputs/reports/execution_log.rds")

log_text <- paste0(
  "Chicago Crime Analysis Execution Log\n",
  "====================================\n",
  "Execution Date: ", format(execution_log$analysis_date, "%Y-%m-%d %H:%M:%S"), "\n",
  "R Version: ", execution_log$r_version, "\n",
  "Data Status:\n",
  "  - Preprocessing Complete: ", ifelse(data_status$preprocessing_complete, "YES", "NO"), "\n",
  "  - Statistical Analysis: ", ifelse(data_status$statistical_complete, "YES", "NO"), "\n", 
  "  - Daily Crimes Available: ", ifelse(data_status$daily_crimes_available, "YES", "NO"), "\n",
  "  - Crime Types Available: ", ifelse(data_status$crime_types_available, "YES", "NO"), "\n",
  "  - Legacy Results: ", ifelse(data_status$has_legacy_results, "YES", "NO"), "\n",
  "Files Available: ", sum(unlist(execution_log$files_loaded)), "/4\n",
  "Outputs Generated: ", execution_log$outputs_generated$reports_created, " report(s)\n"
)

writeLines(log_text, "outputs/reports/execution_log.txt")

cat("✅ 강화된 리포트 생성 완료!\n")
cat("📁 생성된 파일들:\n")
cat("  📝 outputs/reports/analysis_summary.md\n")
cat("  📊 outputs/reports/execution_log.txt\n")
cat("  💾 outputs/reports/execution_log.rds\n")
cat("\n📊 데이터 상태 요약:\n")
cat("  - 전처리:", ifelse(data_status$preprocessing_complete, "✅", "⚠️"), "\n")
cat("  - 통계분석:", ifelse(data_status$statistical_complete, "✅", "⚠️"), "\n") 
cat("  - 일별데이터:", ifelse(data_status$daily_crimes_available, "✅", "⚠️"), "\n")
cat("  - 범죄유형:", ifelse(data_status$crime_types_available, "✅", "⚠️"), "\n")
if(data_status$has_legacy_results) {
  cat("  - 레거시통합: ✅\n")
}
cat("\n")
