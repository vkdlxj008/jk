# ===============================================
# 🔄 레거시 분석 기법 통합
# ===============================================
# 기존 코드의 좋은 아이디어들을 현재 구조에 통합

cat("🔄 레거시 분석 기법 통합 시작...\n")

# 필요한 데이터 로드
daily_crimes_analysis <- readRDS("data/processed/daily_crimes_analysis.rds")
daily_crimes_cleaned <- readRDS("data/processed/daily_crimes_cleaned.rds")

# ===============================================
# 1. 다양한 통계 검정 (analysis_some_statistical_validation.R 기반)
# ===============================================

cat("📊 다양한 통계 검정 실행 중...\n")

# 상위 2개 범죄 유형으로 비교 (ASSAULT vs BATTERY 대신)
top_crime_types <- daily_crimes_cleaned %>%
  filter(!is.na(Primary.Type), Primary.Type != "") %>%
  group_by(Primary.Type) %>%
  summarise(total_count = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(total_count)) %>%
  head(2) %>%
  pull(Primary.Type)

if(length(top_crime_types) >= 2) {
  cat("🔍 상위 2개 범죄 유형 비교:", paste(top_crime_types, collapse = " vs "), "\n")
  
  # 각 범죄 유형별 일별 건수 추출
  crime1_data <- daily_crimes_cleaned %>%
    filter(Primary.Type == top_crime_types[1]) %>%
    group_by(Date) %>%
    summarise(count = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
    pull(count)
  
  crime2_data <- daily_crimes_cleaned %>%
    filter(Primary.Type == top_crime_types[2]) %>%
    group_by(Date) %>%
    summarise(count = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
    pull(count)
  
  # T-test
  if(length(crime1_data) > 0 && length(crime2_data) > 0) {
    t_test_result <- t.test(crime1_data, crime2_data)
    cat("=== T-test 결과 ===\n")
    cat("t-statistic:", round(t_test_result$statistic, 4), "\n")
    cat("p-value:", format(t_test_result$p.value, scientific = TRUE), "\n")
    cat("95% CI:", round(t_test_result$conf.int[1], 2), "~", round(t_test_result$conf.int[2], 2), "\n")
    
    # F-test (분산 동질성 검정)
    f_test_result <- var.test(crime1_data, crime2_data)
    cat("\n=== F-test 결과 (분산 동질성) ===\n")
    cat("F-statistic:", round(f_test_result$statistic, 4), "\n")
    cat("p-value:", format(f_test_result$p.value, scientific = TRUE), "\n")
    
    # Z-test (수동 계산)
    n1 <- length(crime1_data)
    n2 <- length(crime2_data)
    mean1 <- mean(crime1_data, na.rm = TRUE)
    mean2 <- mean(crime2_data, na.rm = TRUE)
    sd1 <- sd(crime1_data, na.rm = TRUE)
    sd2 <- sd(crime2_data, na.rm = TRUE)
    
    z_score <- (mean1 - mean2) / sqrt((sd1^2/n1) + (sd2^2/n2))
    z_p_value <- 2 * (1 - pnorm(abs(z_score)))
    
    cat("\n=== Z-test 결과 (수동 계산) ===\n")
    cat("Z-score:", round(z_score, 4), "\n")
    cat("p-value:", format(z_p_value, scientific = TRUE), "\n")
  }
}

# Chi-square test (범죄 유형 vs 위치)
if("Location.Description" %in% colnames(daily_crimes_cleaned)) {
  cat("\n🔍 Chi-square 검정: 범죄 유형 vs 위치\n")
  
  # 상위 범죄 유형과 위치만 선택 (계산 효율성)
  top_crimes <- daily_crimes_cleaned %>%
    group_by(Primary.Type) %>%
    summarise(total = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(total)) %>%
    head(5) %>%
    pull(Primary.Type)
  
  top_locations <- daily_crimes_cleaned %>%
    group_by(Location.Description) %>%
    summarise(total = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(total)) %>%
    head(5) %>%
    pull(Location.Description)
  
  chi_data <- daily_crimes_cleaned %>%
    filter(Primary.Type %in% top_crimes, 
           Location.Description %in% top_locations,
           !is.na(Primary.Type), !is.na(Location.Description))
  
  if(nrow(chi_data) > 0) {
    tryCatch({
      chi_table <- table(chi_data$Primary.Type, chi_data$Location.Description)
      chi_result <- chisq.test(chi_table, simulate.p.value = TRUE)
      
      cat("=== Chi-square 검정 결과 ===\n")
      cat("Chi-squared:", round(chi_result$statistic, 4), "\n")
      cat("p-value:", format(chi_result$p.value, scientific = TRUE), "\n")
      cat("자유도:", chi_result$parameter, "\n")
    }, error = function(e) {
      cat("⚠️ Chi-square 검정 실패:", e$message, "\n")
    })
  }
}

# 연도별 상관관계 분석
cat("\n📈 연도별 범죄 건수 상관관계 분석\n")
yearly_crimes <- daily_crimes_analysis %>%
  group_by(Year) %>%
  summarise(total_crimes = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
  arrange(Year)

if(nrow(yearly_crimes) > 2) {
  cor_result <- cor.test(yearly_crimes$Year, yearly_crimes$total_crimes, method = "pearson")
  cat("=== 연도-범죄건수 상관관계 ===\n")
  cat("상관계수:", round(cor_result$estimate, 4), "\n")
  cat("p-value:", format(cor_result$p.value, scientific = TRUE), "\n")
  cat("95% CI:", round(cor_result$conf.int[1], 3), "~", round(cor_result$conf.int[2], 3), "\n")
}

# ===============================================
# 2. 개선된 팬데믹 기간 분석 (analysis_enhancement.R 기반)
# ===============================================

cat("\n🦠 개선된 팬데믹 영향 분석\n")

# 레거시 코드에서 사용한 다른 기간 분류도 테스트
alternative_periods <- daily_crimes_analysis %>%
  mutate(
    Period_Alt = case_when(
      Year >= 2017 & Year <= 2019 ~ "Before",
      Year >= 2019 & Year <= 2022 ~ "During",  # 2019 포함, 2022 포함
      Year >= 2022 ~ "After",
      TRUE ~ "Other"
    )
  ) %>%
  filter(Period_Alt != "Other")

# 두 가지 기간 분류 비교
original_summary <- daily_crimes_analysis %>%
  group_by(Period) %>%
  summarise(
    mean_crimes = round(mean(crime_counts, na.rm = TRUE), 2),
    median_crimes = round(median(crime_counts, na.rm = TRUE), 2),
    total_crimes = sum(crime_counts, na.rm = TRUE),
    days = n(),
    .groups = "drop"
  ) %>%
  mutate(classification = "Original (2017-19 / 2020-21 / 2022-23)")

alternative_summary <- alternative_periods %>%
  group_by(Period_Alt) %>%
  summarise(
    mean_crimes = round(mean(crime_counts, na.rm = TRUE), 2),
    median_crimes = round(median(crime_counts, na.rm = TRUE), 2),
    total_crimes = sum(crime_counts, na.rm = TRUE),
    days = n(),
    .groups = "drop"
  ) %>%
  rename(Period = Period_Alt) %>%
  mutate(classification = "Alternative (2017-19 / 2019-22 / 2022+)")

cat("=== 기간 분류 비교 ===\n")
cat("원본 분류:\n")
print(original_summary %>% select(-classification))
cat("\n대안 분류 (레거시 코드 스타일):\n")
print(alternative_summary %>% select(-classification))

# ===============================================
# 3. 밀도 플롯 재현 (crimes.R 기반)
# ===============================================

cat("\n📊 레거시 스타일 밀도 플롯 생성 중...\n")

# 기간별 데이터 분리 (원본 레거시 방식)
pandemic_before <- daily_crimes_analysis %>%
  filter(Period == "Before") %>%
  mutate(Period_Label = "Pandemic Before")

pandemic_during <- daily_crimes_analysis %>%
  filter(Period == "During") %>%
  mutate(Period_Label = "Pandemic Period")

pandemic_after <- daily_crimes_analysis %>%
  filter(Period == "After") %>%
  mutate(Period_Label = "Pandemic After")

# 레거시 스타일 밀도 플롯
legacy_density_plot <- ggplot() +
  geom_density(data = pandemic_before, 
               aes(x = crime_counts, fill = Period_Label), alpha = 0.5) +
  geom_density(data = pandemic_during, 
               aes(x = crime_counts, fill = Period_Label), alpha = 0.5) +
  geom_density(data = pandemic_after, 
               aes(x = crime_counts, fill = Period_Label), alpha = 0.5) +
  labs(
    title = "Crime Density Comparison Before, During, and After Pandemic",
    subtitle = "Recreated from legacy crimes.R",
    x = "Number of Crimes", 
    y = "Density", 
    fill = "Period"
  ) +
  scale_fill_manual(values = c(
    "Pandemic Before" = "red", 
    "Pandemic Period" = "green", 
    "Pandemic After" = "blue"
  )) +
  theme_minimal()

# 레거지 폴더에 저장 (기존 파일과 비교용)
if(!dir.exists("legacy/outputs")) {
  dir.create("legacy/outputs", recursive = TRUE)
}
ggsave("legacy/outputs/Pandemic_Density_Recreated.png", 
       legacy_density_plot, width = 12, height = 8)

# 현대적 버전도 outputs에 저장
ggsave("outputs/plots/pandemic_impact/legacy_style_density.png", 
       legacy_density_plot, width = 12, height = 8)

# ===============================================
# 4. 박스플롯 분석 (legacy 아이디어 확장)
# ===============================================

cat("📦 범죄 유형별 박스플롯 생성 중...\n")

# 상위 10개 범죄 유형
top_10_crimes <- daily_crimes_cleaned %>%
  group_by(Primary.Type) %>%
  summarise(total = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(total)) %>%
  head(10) %>%
  pull(Primary.Type)

crime_boxplot_data <- daily_crimes_cleaned %>%
  filter(Primary.Type %in% top_10_crimes) %>%
  group_by(Date, Primary.Type) %>%
  summarise(daily_count = sum(crime_counts, na.rm = TRUE), .groups = "drop")

# 범죄 유형별 박스플롯 (레거시 스타일 개선)
crime_boxplot <- ggplot(crime_boxplot_data, 
                        aes(x = reorder(Primary.Type, daily_count, FUN = median), 
                            y = daily_count)) +
  geom_boxplot(aes(fill = Primary.Type), alpha = 0.7, outlier.alpha = 0.3) +
  coord_flip() +
  labs(
    title = "Daily Crime Distribution by Crime Type (Top 10)",
    subtitle = "Enhanced version of legacy boxplot analysis",
    x = "Crime Type",
    y = "Daily Count"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.y = element_text(size = 10)
  ) +
  scale_fill_viridis_d(option = "plasma")

ggsave("outputs/plots/crime_types/crime_distribution_boxplot.png", 
       crime_boxplot, width = 12, height = 8)

# ===============================================
# 5. 위치별 분석 추가 (레거시 데이터 활용)
# ===============================================

cat("📍 위치별 범죄 분석 중...\n")

if("Location.Description" %in% colnames(daily_crimes_cleaned)) {
  # 상위 위치별 범죄 분포
  top_locations <- daily_crimes_cleaned %>%
    group_by(Location.Description) %>%
    summarise(
      total_crimes = sum(crime_counts, na.rm = TRUE),
      unique_dates = n_distinct(Date),
      avg_per_day = round(total_crimes / unique_dates, 2),
      .groups = "drop"
    ) %>%
    arrange(desc(total_crimes)) %>%
    head(15)
  
  # 위치별 범죄 막대 차트
  location_plot <- ggplot(top_locations, 
                          aes(x = reorder(Location.Description, total_crimes), 
                              y = total_crimes)) +
    geom_col(aes(fill = avg_per_day), alpha = 0.8) +
    coord_flip() +
    scale_fill_viridis_c(name = "Avg/Day") +
    labs(
      title = "Top 15 Crime Locations",
      subtitle = "Based on total incidents (color = daily average)",
      x = "Location",
      y = "Total Crimes"
    ) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 9))
  
  ggsave("outputs/plots/crime_types/top_crime_locations.png", 
         location_plot, width = 12, height = 8)
  
  cat("✅ 위치별 분석 완료\n")
}

# ===============================================
# 6. 레거시 통합 결과 저장
# ===============================================

cat("💾 레거시 통합 결과 저장 중...\n")

# 통합 분석 결과
legacy_integration_results <- list(
  statistical_tests = list(
    top_crime_comparison = if(exists("t_test_result")) {
      list(
        crime_types = top_crime_types,
        t_test_p = t_test_result$p.value,
        f_test_p = if(exists("f_test_result")) f_test_result$p.value else NA,
        z_test_p = if(exists("z_p_value")) z_p_value else NA
      )
    } else NA,
    
    chi_square = if(exists("chi_result")) {
      list(
        statistic = chi_result$statistic,
        p_value = chi_result$p.value
      )
    } else NA,
    
    year_correlation = if(exists("cor_result")) {
      list(
        correlation = cor_result$estimate,
        p_value = cor_result$p.value
      )
    } else NA
  ),
  
  period_comparisons = list(
    original_classification = original_summary,
    alternative_classification = alternative_summary
  ),
  
  top_crimes = top_10_crimes,
  top_locations = if(exists("top_locations")) top_locations else NA,
  
  plots_generated = c(
    "legacy/outputs/Pandemic_Density_Recreated.png",
    "outputs/plots/pandemic_impact/legacy_style_density.png",
    "outputs/plots/crime_types/crime_distribution_boxplot.png",
    if(exists("location_plot")) "outputs/plots/crime_types/top_crime_locations.png"
  ),
  
  integration_date = Sys.time()
)

# 결과 저장
saveRDS(legacy_integration_results, "outputs/tables/legacy_integration_results.rds")

# 텍스트 요약 생성
legacy_summary <- paste0(
  "레거시 코드 통합 결과 요약\n",
  "==========================\n",
  "통합 일시: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n",
  
  "1. 통계 검정 결과:\n",
  if(exists("t_test_result")) {
    paste0("   - T-test (", paste(top_crime_types, collapse=" vs "), "): p=", 
           format(t_test_result$p.value, digits=4), "\n")
  } else "   - T-test: 실행되지 않음\n",
  
  if(exists("cor_result")) {
    paste0("   - 연도-범죄 상관관계: r=", round(cor_result$estimate, 3), 
           ", p=", format(cor_result$p.value, digits=4), "\n")
  } else "   - 상관관계 분석: 실행되지 않음\n",
  
  "\n2. 기간 분류 비교:\n",
  "   - 원본: 2017-19 / 2020-21 / 2022-23\n",
  "   - 대안: 2017-19 / 2019-22 / 2022+\n",
  
  "\n3. 생성된 시각화:\n",
  "   - 레거시 스타일 밀도 플롯\n",
  "   - 범죄 유형별 박스플롯\n",
  if(exists("location_plot")) "   - 위치별 범죄 분석\n" else "",
  
  "\n4. 상위 범죄 유형 (Top 10):\n",
  paste0("   ", 1:length(top_10_crimes), ". ", top_10_crimes, collapse="\n"),
  "\n"
)

writeLines(legacy_summary, "outputs/reports/legacy_integration_summary.txt")

cat("✅ 레거시 통합 완료!\n")
cat("📊 통계 검정:", if(exists("t_test_result")) "실행됨" else "일부 실행됨", "\n")
cat("📈 시각화:", length(legacy_integration_results$plots_generated), "개 생성\n")
cat("📁 결과 저장: outputs/tables/legacy_integration_results.rds\n")
cat("📋 요약 리포트: outputs/reports/legacy_integration_summary.txt\n\n")