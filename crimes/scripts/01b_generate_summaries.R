  # =============================================================================
  # Aggregated Summary Data Script
  # Generate monthly/type/location-level summaries from daily_crimes_summary.csv
  # =============================================================================
  library(dplyr)
  library(lubridate)
  library(readr)
  
  # Load data
  print("Loading daily aggregated data...")
  daily_data <- read_csv("Data/daily_crimes.csv")
  
  # Check structure
  print("Data structure:")
  glimpse(daily_data)
  print(paste("Total records:", nrow(daily_data)))
  
  # Generate Date column from Day
  daily_data <- daily_data %>%
    mutate(
      Date = ymd(Day),                          # "2001-01-01" format → use ymd()
      Month = floor_date(Date, "month"),
      Year_Month = format(Date, "%Y-%m")        # Format as YYYY-MM
    )
  
  # Confirm new columns
  print("Transformed data:")
  glimpse(daily_data)
  print("Sample Date values:")
  head(daily_data$Date)
  print("Sample Month values:")
  head(daily_data$Month)
  print("Sample Year_Month values:")
  head(daily_data$Year_Month)
  
  View(daily_data)
  
  # =============================================================================
  # 1. Generate monthly_summary.csv
  # =============================================================================
  print("Generating monthly summary data...")
  
  monthly_summary <- daily_data %>%
    group_by(Year_Month, Year, Primary.Type, Location.Description) %>%
    summarise(
      total_crimes = sum(count, na.rm = TRUE),
      days_with_crime = n(),
      avg_daily_crimes = round(total_crimes / days_with_crime, 2),
      .groups = "drop"
    ) %>%
    arrange(Year_Month, desc(total_crimes))
  
  # Monthly overall statistics
  monthly_totals <- daily_data %>%
    group_by(Year_Month, Year) %>%
    summarise(
      total_crimes = sum(count, na.rm = TRUE),
      unique_crime_types = n_distinct(Primary.Type),
      unique_locations = n_distinct(Location.Description),
      .groups = "drop"
    )
  
  View(monthly_summary)
  
  write_csv(monthly_summary, "Data/monthly_summary.csv")
  write_csv(monthly_totals, "Data/monthly_totals.csv")
  print("✓ monthly_summary.csv successfully created")
  
  # =============================================================================
  # 2. Generate crime_types_summary.csv
  # =============================================================================
  print("Generating summary by crime type...")
  
  crime_types_summary <- daily_data %>%
    group_by(Primary.Type) %>%
    summarise(
      total_incidents = sum(count, na.rm = TRUE),
      total_days = n_distinct(Date),
      avg_per_day = round(total_incidents / total_days, 2),
      first_recorded = min(Date, na.rm = TRUE),
      last_recorded = max(Date, na.rm = TRUE),
      years_active = n_distinct(Year),
      top_location = names(sort(table(Location.Description), decreasing = TRUE))[1],
      unique_locations = n_distinct(Location.Description),
      .groups = "drop"
    ) %>%
    arrange(desc(total_incidents))
  
  # Annual crime type trends
  crime_yearly_trends <- daily_data %>%
    group_by(Year, Primary.Type) %>%
    summarise(
      annual_total = sum(count, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(Year, desc(annual_total))
  
  write_csv(crime_types_summary, "Data/crime_types_summary.csv")
  write_csv(crime_yearly_trends, "Data/crime_yearly_trends.csv")
  print("✓ crime_types_summary.csv successfully created")
  
  # =============================================================================
  # 3. Generate locations_summary.csv
  # =============================================================================
  print("Generating summary by location...")
  
  locations_summary <- daily_data %>%
    group_by(Location.Description) %>%
    summarise(
      total_incidents = sum(count, na.rm = TRUE),
      total_days = n_distinct(Date),
      avg_per_day = round(total_incidents / total_days, 2),
      first_recorded = min(Date, na.rm = TRUE),
      last_recorded = max(Date, na.rm = TRUE),
      years_active = n_distinct(Year),
      top_crime_type = names(sort(table(Primary.Type), decreasing = TRUE))[1],
      unique_crime_types = n_distinct(Primary.Type),
      .groups = "drop"
    ) %>%
    arrange(desc(total_incidents))
  
  # Annual location trends
  location_yearly_trends <- daily_data %>%
    group_by(Year, Location.Description) %>%
    summarise(
      annual_total = sum(count, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(Year, desc(annual_total))
  
  write_csv(locations_summary, "Data/locations_summary.csv")
  write_csv(location_yearly_trends, "Data/location_yearly_trends.csv")
  print("✓ locations_summary.csv successfully created")
  
  # =============================================================================
  # 4. Save cleaned_data.rds
  # =============================================================================
  print("Saving RDS file...")
  
  cleaned_data <- list(
    daily_crimes = daily_data,
    
    monthly_summary = monthly_summary,
    monthly_totals = monthly_totals,
    
    crime_types = crime_types_summary,
    crime_yearly = crime_yearly_trends,
    
    locations = locations_summary,
    location_yearly = location_yearly_trends,
    
    metadata = list(
      creation_date = Sys.time(),
      total_records = nrow(daily_data),
      date_range = c(min(daily_data$Date, na.rm = TRUE), 
                     max(daily_data$Date, na.rm = TRUE)),
      unique_crime_types = sort(unique(daily_data$Primary.Type)),
      unique_locations = sort(unique(daily_data$Location.Description))
    )
  )
  
  saveRDS(cleaned_data, "Data/cleaned_data.rds")
  print("✓ cleaned_data.rds successfully created")
  
  # =============================================================================
  # Final Summary Output
  # =============================================================================
  print("\n=== Summary of Generated Files ===")
  print(paste("📅 monthly_summary.csv:", nrow(monthly_summary), "records"))
  print(paste("🔍 crime_types_summary.csv:", nrow(crime_types_summary), "crime types"))
  print(paste("📍 locations_summary.csv:", nrow(locations_summary), "locations"))
  print(paste("💾 cleaned_data.rds: RDS list with all summary data"))
  
  print("\n=== Top 5 Crime Types ===")
  print(head(crime_types_summary %>% select(Primary.Type, total_incidents, avg_per_day), 5))
  
  print("\n=== Top 5 Locations with Most Crimes ===")
  print(head(locations_summary %>% select(Location.Description, total_incidents, avg_per_day), 5))
  
  print("\n✅ All summary data files successfully created!")
  print("Generated files:")
  print("- monthly_summary.csv")
  print("- monthly_totals.csv (additional)")
  print("- crime_types_summary.csv")
  print("- crime_yearly_trends.csv (additional)")
  print("- locations_summary.csv")
  print("- location_yearly_trends.csv (additional)")
  print("- cleaned_data.rds")
  