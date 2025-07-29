# ===============================================
# 📥 Load and Transform Aggregated Data
# ===============================================
# Transform already aggregated daily_crimes.csv etc. into an analysis-ready format.

cat("📊 Starting aggregated data loading...\n")

# ===============================================
# 1. Load Basic Aggregated Data
# ===============================================

cat("📥 Loading daily aggregated data...\n")

# Load daily_crimes.csv
if(file.exists("C:/Users/BYU Rental/Downloads/daily_crimes.csv")) {
  daily_crimes_raw <- read.csv("C:/Users/BYU Rental/Downloads/daily_crimes.csv", stringsAsFactors = FALSE)
  cat("✅ Daily data loaded:", nrow(daily_crimes_raw), "rows\n")
} else {
  stop("❌ data/daily_crimes.csv file not found.")
}

# Check data structure
cat("📋 Data structure:\n")
str(daily_crimes_raw)

# ===============================================
# 2. Date Conversion and Period Classification
# ===============================================

cat("📅 Converting dates and classifying periods...\n")

# Date conversion (supports multiple formats)
daily_crimes <- daily_crimes_raw |>
  mutate(
    # Attempt date conversion (considering multiple formats)
    Date = case_when(
      !is.na(as.Date(Day, format = "%Y-%m-%d")) ~ as.Date(Day, format = "%Y-%m-%d"),
      !is.na(as.Date(Day, format = "%m/%d/%Y")) ~ as.Date(Day, format = "%m/%d/%Y"),
      !is.na(ymd(Day)) ~ ymd(Day),
      TRUE ~ as.Date(NA)
    ),

    # Extract Year, Month
    Year = year(Date),
    Month = month(Date),
    YearMonth = floor_date(Date, "month"),

    # Classify pandemic period (refer to development-history for definitions)
    Period = case_when(
      Year >= 2017 & Year <= 2019 ~ "Before",
      Year >= 2020 & Year <= 2021 ~ "During",
      Year >= 2022 & Year <= 2023 ~ "After",
      TRUE ~ "Other"
    ),

    # Crime counts (use 'count' column if exists, otherwise assume 1)
    crime_counts = if("count" %in% colnames(daily_crimes_raw)) count else 1
  ) |>
  filter(!is.na(Date), Period != "Other") |>
  arrange(Date)

cat("✅ Date conversion complete:", nrow(daily_crimes), "rows\n")
cat("📅 Analysis period:", min(daily_crimes$Date, na.rm = TRUE), "~",
    max(daily_crimes$Date, na.rm = TRUE), "\n")

# Check data count by period
period_counts <- daily_crimes |>
  group_by(Period) |>
  summarise(
    records = n(),
    unique_dates = n_distinct(Date),
    total_crimes = sum(crime_counts, na.rm = TRUE),
    date_range = paste(min(Date), "~", max(Date)),
    .groups = "drop"
  )

cat("📊 Data distribution by period:\n")
print(period_counts)

# ===============================================
# 3. Load Additional Aggregated Data (if available)
# ===============================================

# Monthly summary data
if(file.exists("data/monthly_summary.csv")) {
  cat("📥 Loading monthly summary data...\n")
  monthly_summary <- read.csv("data/monthly_summary.csv", stringsAsFactors = FALSE)
  cat("✅ Monthly summary loaded:", nrow(monthly_summary), "rows\n")
} else {
  cat("⚠️ Monthly summary data not found. Generating from daily data.\n")
  monthly_summary <- daily_crimes |>
    group_by(YearMonth, Year, Primary.Type, Location.Description) |>
    summarise(
      total_crimes = sum(crime_counts, na.rm = TRUE),
      days_with_crime = n(),
      avg_daily_crimes = round(total_crimes / days_with_crime, 2),
      .groups = "drop"
    )
}

# Crime type summary
if(file.exists("data/crime_types_summary.csv")) {
  cat("📥 Loading crime type summary data...\n")
  crime_types_summary <- read.csv("data/crime_types_summary.csv", stringsAsFactors = FALSE)
  cat("✅ Crime type summary loaded:", nrow(crime_types_summary), "rows\n")
} else {
  cat("⚠️ Crime type summary not found. Generating.\n")
  crime_types_summary <- daily_crimes |>
    group_by(Primary.Type) |>
    summarise(
      total_incidents = sum(crime_counts, na.rm = TRUE),
      total_days = n_distinct(Date),
      avg_per_day = round(total_incidents / total_days, 2),
      first_recorded = min(Date, na.rm = TRUE),
      last_recorded = max(Date, na.rm = TRUE),
      years_active = n_distinct(Year),
      .groups = "drop"
    ) |>
    arrange(desc(total_incidents))
}

# ===============================================
# 4. Prepare Data for Analysis
# ===============================================

cat("🔄 Preparing data for analysis...\n")

# Daily aggregation (for period comparison)
daily_crimes_for_analysis <- daily_crimes |>
  group_by(Date, Period, Year) |>
  summarise(
    crime_counts = sum(crime_counts, na.rm = TRUE),
    unique_crime_types = n_distinct(Primary.Type, na.rm = TRUE),
    .groups = "drop"
  )

# Monthly aggregation (for time series analysis)
monthly_crimes_for_analysis <- daily_crimes |>
  group_by(YearMonth, Year, Period) |>
  summarise(
    crime_counts = sum(crime_counts, na.rm = TRUE),
    unique_crime_types = n_distinct(Primary.Type, na.rm = TRUE),
    avg_daily_crimes = crime_counts / n_distinct(Date),
    days_in_month = n_distinct(Date),
    .groups = "drop"
  ) |>
  arrange(YearMonth) |>
  mutate(
    # 3-month rolling average
    moving_avg = rollmean(crime_counts, k = 3, fill = NA, align = "center")
  )

# Crime type period comparison (maintain the style from development-history)
crime_type_analysis <- daily_crimes |>
  filter(!is.na(Primary.Type)) |>
  group_by(Primary.Type, Period) |>
  summarise(crime_count = sum(crime_counts, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = Period, values_from = crime_count, values_fill = 0) |>
  mutate(
    total_crimes = Before + During + After,
    pct_change_during = ifelse(Before > 0, ((During - Before) / Before) * 100, 0),
    pct_change_after = ifelse(Before > 0, ((After - Before) / Before) * 100, 0)
  ) |>
  filter(total_crimes >= 50) |>  # Only crimes with sufficient data
  arrange(desc(total_crimes))

cat("✅ Data prepared for analysis\n")

# ===============================================
# 5. Save Data
# ===============================================

cat("💾 Saving transformed data...\n")

# Save preprocessed data to the 'processed' folder
if(!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Save as RDS format (for faster loading)
saveRDS(daily_crimes, "data/processed/daily_crimes_cleaned.rds")
saveRDS(daily_crimes_for_analysis, "data/processed/daily_crimes_analysis.rds")
saveRDS(monthly_crimes_for_analysis, "data/processed/monthly_crimes_analysis.rds")
saveRDS(crime_type_analysis, "data/processed/crime_type_analysis.rds")

# Also save as CSV format (for compatibility)
write.csv(daily_crimes_for_analysis, "data/processed/daily_crimes_for_analysis.csv", row.names = FALSE)
write.csv(monthly_crimes_for_analysis, "data/processed/monthly_crimes_for_analysis.csv", row.names = FALSE)
write.csv(crime_type_analysis, "data/processed/crime_type_analysis.csv", row.names = FALSE)

# ===============================================
# 6. Data Quality Validation
# ===============================================

cat("🔍 Validating data quality...\n")

# Basic statistics
data_quality <- list(
  original_records = nrow(daily_crimes_raw),
  cleaned_records = nrow(daily_crimes),
  analysis_records = nrow(daily_crimes_for_analysis),
  date_range = range(daily_crimes$Date, na.rm = TRUE),
  periods = table(daily_crimes$Period),
  crime_types = length(unique(daily_crimes$Primary.Type)),
  missing_dates = sum(is.na(daily_crimes$Date)),
  missing_crime_types = sum(is.na(daily_crimes$Primary.Type) | daily_crimes$Primary.Type == ""),
  total_crimes_by_period = daily_crimes_for_analysis |>
    group_by(Period) |>
    summarise(total = sum(crime_counts, na.rm = TRUE), .groups = "drop")
)

# Save quality validation results
saveRDS(data_quality, "data/processed/data_quality_report.rds")

cat("✅ Aggregated data loading complete!\n")
cat("📊 Final Data:\n")
cat("  - Daily analysis data:", nrow(daily_crimes_for_analysis), "rows\n")
cat("  - Monthly analysis data:", nrow(monthly_crimes_for_analysis), "rows\n")
cat("  - Crime type analysis:", nrow(crime_type_analysis), "types\n")
cat("📅 Analysis Period:", data_quality$date_range[1], "~", data_quality$date_range[2], "\n")
cat("🔢 Total Crime Types:", data_quality$crime_types, "\n\n")
