# ===============================================
# 📥 집계 데이터 로드 및 변환
# ===============================================
# 이미 집계된 daily_crimes.csv 등을 분석 형태로 변환

cat("📊 집계 데이터 로딩 시작...\n")

# ===============================================
# 1. 기본 집계 데이터 로드
# ===============================================

cat("📥 일별 집계 데이터 로딩 중...\n")

# daily_crimes.csv 로드
if(file.exists("C:/Users/BYU Rental/Downloads/daily_crimes.csv")) {
  daily_crimes_raw <- read.csv("C:/Users/BYU Rental/Downloads/daily_crimes.csv", stringsAsFactors = FALSE)
  cat("✅ 일별 데이터 로드:", nrow(daily_crimes_raw), "행\n")
} else {
  stop("❌ data/daily_crimes.csv 파일을 찾을 수 없습니다.")
}

# 데이터 구조 확인
cat("📋 데이터 구조:\n")
str(daily_crimes_raw)

# ===============================================
# 2. 날짜 변환 및 기간 분류
# ===============================================

cat("📅 날짜 변환 및 기간 분류 중...\n")

# 날짜 변환 (여러 형식 지원)
daily_crimes <- daily_crimes_raw %>%
  mutate(
    # 날짜 변환 시도 (여러 형식 고려)
    Date = case_when(
      !is.na(as.Date(Day, format = "%Y-%m-%d")) ~ as.Date(Day, format = "%Y-%m-%d"),
      !is.na(as.Date(Day, format = "%m/%d/%Y")) ~ as.Date(Day, format = "%m/%d/%Y"),
      !is.na(ymd(Day)) ~ ymd(Day),
      TRUE ~ as.Date(NA)
    ),
    
    # 연도, 월 추출
    Year = year(Date),
    Month = month(Date),
    YearMonth = floor_date(Date, "month"),
    
    # 팬데믹 기간 분류 (레거시 코드 참고)
    Period = case_when(
      Year >= 2017 & Year <= 2019 ~ "Before",
      Year >= 2020 & Year <= 2021 ~ "During",
      Year >= 2022 & Year <= 2023 ~ "After",
      TRUE ~ "Other"
    ),
    
    # 범죄 건수 (count 컬럼이 있으면 사용, 없으면 1로 가정)
    crime_counts = if("count" %in% colnames(daily_crimes_raw)) count else 1
  ) %>%
  filter(!is.na(Date), Period != "Other") %>%
  arrange(Date)

cat("✅ 날짜 변환 완료:", nrow(daily_crimes), "행\n")
cat("📅 분석 기간:", min(daily_crimes$Date, na.rm = TRUE), "~", 
    max(daily_crimes$Date, na.rm = TRUE), "\n")

# 기간별 데이터 개수 확인
period_counts <- daily_crimes %>%
  group_by(Period) %>%
  summarise(
    records = n(),
    unique_dates = n_distinct(Date),
    total_crimes = sum(crime_counts, na.rm = TRUE),
    date_range = paste(min(Date), "~", max(Date)),
    .groups = "drop"
  )

cat("📊 기간별 데이터 분포:\n")
print(period_counts)

# ===============================================
# 3. 추가 집계 데이터 로드 (있는 경우)
# ===============================================

# 월별 요약 데이터
if(file.exists("data/monthly_summary.csv")) {
  cat("📥 월별 요약 데이터 로딩 중...\n")
  monthly_summary <- read.csv("data/monthly_summary.csv", stringsAsFactors = FALSE)
  cat("✅ 월별 요약:", nrow(monthly_summary), "행\n")
} else {
  cat("⚠️ 월별 요약 데이터가 없습니다. 일별 데이터로부터 생성합니다.\n")
  monthly_summary <- daily_crimes %>%
    group_by(YearMonth, Year, Primary.Type, Location.Description) %>%
    summarise(
      total_crimes = sum(crime_counts, na.rm = TRUE),
      days_with_crime = n(),
      avg_daily_crimes = round(total_crimes / days_with_crime, 2),
      .groups = "drop"
    )
}

# 범죄 유형별 요약
if(file.exists("data/crime_types_summary.csv")) {
  cat("📥 범죄 유형 요약 데이터 로딩 중...\n")
  crime_types_summary <- read.csv("data/crime_types_summary.csv", stringsAsFactors = FALSE)
  cat("✅ 범죄 유형 요약:", nrow(crime_types_summary), "행\n")
} else {
  cat("⚠️ 범죄 유형 요약이 없습니다. 생성합니다.\n")
  crime_types_summary <- daily_crimes %>%
    group_by(Primary.Type) %>%
    summarise(
      total_incidents = sum(crime_counts, na.rm = TRUE),
      total_days = n_distinct(Date),
      avg_per_day = round(total_incidents / total_days, 2),
      first_recorded = min(Date, na.rm = TRUE),
      last_recorded = max(Date, na.rm = TRUE),
      years_active = n_distinct(Year),
      .groups = "drop"
    ) %>%
    arrange(desc(total_incidents))
}

# ===============================================
# 4. 분석용 데이터 준비
# ===============================================

cat("🔄 분석용 데이터 준비 중...\n")

# 일별 집계 (기간별 비교용)
daily_crimes_for_analysis <- daily_crimes %>%
  group_by(Date, Period, Year) %>%
  summarise(
    crime_counts = sum(crime_counts, na.rm = TRUE),
    unique_crime_types = n_distinct(Primary.Type, na.rm = TRUE),
    .groups = "drop"
  )

# 월별 집계 (시계열 분석용)
monthly_crimes_for_analysis <- daily_crimes %>%
  group_by(YearMonth, Year, Period) %>%
  summarise(
    crime_counts = sum(crime_counts, na.rm = TRUE),
    unique_crime_types = n_distinct(Primary.Type, na.rm = TRUE),
    avg_daily_crimes = crime_counts / n_distinct(Date),
    days_in_month = n_distinct(Date),
    .groups = "drop"
  ) %>%
  arrange(YearMonth) %>%
  mutate(
    # 3개월 이동평균
    moving_avg = rollmean(crime_counts, k = 3, fill = NA, align = "center")
  )

# 범죄 유형별 기간 비교 (레거시 코드 스타일 유지)
crime_type_analysis <- daily_crimes %>%
  filter(!is.na(Primary.Type)) %>%
  group_by(Primary.Type, Period) %>%
  summarise(crime_count = sum(crime_counts, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Period, values_from = crime_count, values_fill = 0) %>%
  mutate(
    total_crimes = Before + During + After,
    pct_change_during = ifelse(Before > 0, ((During - Before) / Before) * 100, 0),
    pct_change_after = ifelse(Before > 0, ((After - Before) / Before) * 100, 0)
  ) %>%
  filter(total_crimes >= 50) %>%  # 충분한 데이터가 있는 범죄만
  arrange(desc(total_crimes))

cat("✅ 분석용 데이터 준비 완료\n")

# ===============================================
# 5. 데이터 저장
# ===============================================

cat("💾 변환된 데이터 저장 중...\n")

# 전처리된 데이터들을 processed 폴더에 저장
if(!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# RDS 형태로 저장 (빠른 로딩)
saveRDS(daily_crimes, "data/processed/daily_crimes_cleaned.rds")
saveRDS(daily_crimes_for_analysis, "data/processed/daily_crimes_analysis.rds")
saveRDS(monthly_crimes_for_analysis, "data/processed/monthly_crimes_analysis.rds")
saveRDS(crime_type_analysis, "data/processed/crime_type_analysis.rds")

# CSV 형태로도 저장 (호환성)
write.csv(daily_crimes_for_analysis, "data/processed/daily_crimes_for_analysis.csv", row.names = FALSE)
write.csv(monthly_crimes_for_analysis, "data/processed/monthly_crimes_for_analysis.csv", row.names = FALSE)
write.csv(crime_type_analysis, "data/processed/crime_type_analysis.csv", row.names = FALSE)

# ===============================================
# 6. 데이터 품질 검증
# ===============================================

cat("🔍 데이터 품질 검증 중...\n")

# 기본 통계
data_quality <- list(
  original_records = nrow(daily_crimes_raw),
  cleaned_records = nrow(daily_crimes),
  analysis_records = nrow(daily_crimes_for_analysis),
  date_range = range(daily_crimes$Date, na.rm = TRUE),
  periods = table(daily_crimes$Period),
  crime_types = length(unique(daily_crimes$Primary.Type)),
  missing_dates = sum(is.na(daily_crimes$Date)),
  missing_crime_types = sum(is.na(daily_crimes$Primary.Type) | daily_crimes$Primary.Type == ""),
  total_crimes_by_period = daily_crimes_for_analysis %>%
    group_by(Period) %>%
    summarise(total = sum(crime_counts, na.rm = TRUE), .groups = "drop")
)

# 품질 검증 결과 저장
saveRDS(data_quality, "data/processed/data_quality_report.rds")

cat("✅ 집계 데이터 로딩 완료!\n")
cat("📊 최종 데이터:\n")
cat("  - 일별 분석 데이터:", nrow(daily_crimes_for_analysis), "행\n")
cat("  - 월별 분석 데이터:", nrow(monthly_crimes_for_analysis), "행\n")
cat("  - 범죄 유형 분석:", nrow(crime_type_analysis), "유형\n")
cat("📅 분석 기간:", data_quality$date_range[1], "~", data_quality$date_range[2], "\n")
cat("🔢 총 범죄 유형:", data_quality$crime_types, "개\n\n")