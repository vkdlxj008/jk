library(tidyverse)
library(lubridate)
library(plotly)
library(viridis)
library(effsize)
library(changepoint)
library(zoo)

# === 0. Data Load and Preprocessing ===

# Load and clean the raw crime dataset
subject <- read.csv("C:/Users/BYU Rental/Downloads/Crimes.csv")
subject_clean <- subject[complete.cases(subject$X.Coordinate, subject$Y.Coordinate, subject$Year), ]

# Function to remove outliers based on standard deviation threshold
remove_outliers <- function(data, variable, deviation_threshold = 3) {
  mean_val <- mean(data[[variable]])
  sd_val <- sd(data[[variable]])
  valid_data <- data[abs(data[[variable]] - mean_val) < deviation_threshold * sd_val, ]
  return(valid_data)
}

# Remove spatial outliers (extreme coordinates)
subject_clean <- remove_outliers(subject_clean, "X.Coordinate")
subject_clean <- remove_outliers(subject_clean, "Y.Coordinate")

# === 1. Statistical Test: Pre/During/Post Pandemic ===

# Prepare daily crime counts
subject_clean1 <- subject_clean %>%
  mutate(Day = as.Date(mdy_hms(Date))) %>%
  group_by(Day) %>%
  summarize(crime_counts = n()) %>%
  mutate(Year = year(Day))

# Split data into periods
pandemic_before <- subject_clean1 %>%
  filter(Year >= 2017 & Year <= 2019) %>%
  mutate(Period = "Before")

pandemic_period <- subject_clean1 %>%
  filter(Year >= 2020 & Year <= 2021) %>%
  mutate(Period = "During")

pandemic_after <- subject_clean1 %>%
  filter(Year >= 2022 & Year <= 2023) %>%
  mutate(Period = "After")

# Combine all periods for analysis
combined_data <- bind_rows(pandemic_before, pandemic_period, pandemic_after)

# Kruskal-Wallis Test (non-parametric ANOVA)
kruskal_result <- kruskal.test(crime_counts ~ Period, data = combined_data)
print("=== Kruskal-Wallis Test ===")
print(kruskal_result)

# Post-hoc pairwise Wilcoxon tests if significant
if (kruskal_result$p.value < 0.05) {
  pairwise_result <- pairwise.wilcox.test(combined_data$crime_counts, 
                                          combined_data$Period,
                                          p.adjust.method = "bonferroni")
  print("=== Post-hoc Pairwise Comparisons ===")
  print(pairwise_result)
}

# Effect size (Cohen's d) between periods
cohen_before_during <- cohen.d(pandemic_before$crime_counts, 
                               pandemic_period$crime_counts)
cohen_before_after <- cohen.d(pandemic_before$crime_counts, 
                              pandemic_after$crime_counts)
cohen_during_after <- cohen.d(pandemic_period$crime_counts, 
                              pandemic_after$crime_counts)

print("=== Effect Sizes ===")
print(paste("Before vs During:", round(cohen_before_during$estimate, 3)))
print(paste("Before vs After:", round(cohen_before_after$estimate, 3)))
print(paste("During vs After:", round(cohen_during_after$estimate, 3)))

# === 2. Time Series Analysis ===

# Monthly trends with moving average and labels
monthly_data <- subject_clean %>%
  mutate(Date = as.Date(mdy_hms(Date)),
         YearMonth = floor_date(Date, "month")) %>%
  group_by(YearMonth) %>%
  summarize(crime_counts = n()) %>%
  mutate(
    Year = year(YearMonth),
    Month = month(YearMonth),
    moving_avg = rollmean(crime_counts, k = 3, fill = NA, align = "center"),
    Period = case_when(
      Year <= 2019 ~ "Before",
      Year %in% 2020:2021 ~ "During", 
      Year >= 2022 ~ "After"
    )
  )

# Change Point Detection
cpt_result <- cpt.mean(monthly_data$crime_counts, method = "PELT")
change_points <- cpts(cpt_result)

print("=== Change Points Detected ===")
print(monthly_data$YearMonth[change_points])

# Plot time series with trends and event markers
p_timeseries <- ggplot(monthly_data, aes(x = YearMonth)) +
  geom_line(aes(y = crime_counts), color = "gray70", size = 0.5) +
  geom_line(aes(y = moving_avg, color = Period), size = 1.2, na.rm = TRUE) +
  geom_vline(xintercept = as.Date("2020-03-01"), 
             linetype = "dashed", color = "red", size = 1) +
  geom_vline(xintercept = as.Date("2022-01-01"), 
             linetype = "dashed", color = "blue", size = 1) +
  labs(title = "Monthly Crime Trends with Moving Average",
       x = "Date", y = "Number of Crimes",
       subtitle = "Red: Pandemic Start, Blue: Endemic Transition") +
  scale_color_manual(values = c("Before" = "#E31A1C", 
                                "During" = "#33A02C", 
                                "After" = "#1F78B4")) +
  theme_minimal()

ggsave('Monthly_Trends.png', p_timeseries, width = 12, height = 6)

# === 3. Analysis by Crime Type ===

# Compare crime types by period
crime_type_analysis <- subject_clean %>%
  mutate(Date = as.Date(mdy_hms(Date)),
         Year = year(Date),
         Period = case_when(
           Year <= 2019 ~ "Before",
           Year %in% 2020:2021 ~ "During",
           Year >= 2022 ~ "After"
         )) %>%
  filter(!is.na(Period), !is.na(Primary.Type)) %>%
  group_by(Primary.Type, Period) %>%
  summarize(crime_count = n(), .groups = "drop") %>%
  pivot_wider(names_from = Period, values_from = crime_count, values_fill = 0) %>%
  mutate(
    pct_change_during = ((During - Before) / Before) * 100,
    pct_change_after = ((After - Before) / Before) * 100,
    total_crimes = Before + During + After
  ) %>%
  filter(total_crimes >= 100) %>%
  arrange(pct_change_during)

# Top 10 most decreased/increased crimes during pandemic
print("=== Top 10 Crime Types with Biggest Decrease During Pandemic ===")
print(head(crime_type_analysis[, c("Primary.Type", "pct_change_during")], 10))

print("=== Top 10 Crime Types with Biggest Increase During Pandemic ===")
print(tail(crime_type_analysis[, c("Primary.Type", "pct_change_during")], 10))

# Create heatmap (Top 15 most frequent types)
top_crimes <- crime_type_analysis %>%
  top_n(15, total_crimes) %>%
  pull(Primary.Type)

heatmap_data <- crime_type_analysis %>%
  filter(Primary.Type %in% top_crimes) %>%
  select(Primary.Type, Before, During, After) %>%
  pivot_longer(cols = c(Before, During, After), 
               names_to = "Period", values_to = "Count") %>%
  mutate(Period = factor(Period, levels = c("Before", "During", "After")))

p_heatmap <- ggplot(heatmap_data, aes(x = Period, y = reorder(Primary.Type, Count))) +
  geom_tile(aes(fill = Count)) +
  geom_text(aes(label = Count), color = "white", size = 3) +
  scale_fill_viridis_c(name = "Crime\nCount", trans = "log10") +
  labs(title = "Crime Types by Period (Top 15 Most Common)",
       x = "Period", y = "Crime Type") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8),
        plot.title = element_text(size = 14, face = "bold"))

ggsave('Crime_Types_Heatmap.png', p_heatmap, width = 10, height = 8)

# Bar plot: percentage change
p_change <- crime_type_analysis %>%
  filter(Primary.Type %in% top_crimes) %>%
  ggplot(aes(x = reorder(Primary.Type, pct_change_during), 
             y = pct_change_during)) +
  geom_col(aes(fill = pct_change_during > 0)) +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "blue"),
                    name = "Change", labels = c("Decrease", "Increase")) +
  labs(title = "Percentage Change in Crime Types During Pandemic",
       subtitle = "Compared to Pre-Pandemic Period",
       x = "Crime Type", y = "Percentage Change (%)") +
  theme_minimal() +
  geom_hline(yintercept = 0, linetype
             

# 결과를 CSV로 저장
write.csv(summary_stats, "pandemic_crime_summary.csv", row.names = FALSE)
write.csv(crime_type_analysis, "crime_type_analysis.csv", row.names = FALSE)

print("=== Analysis Complete ===")
print("Files saved:")
print("- Monthly_Trends.png")
print("- Crime_Types_Heatmap.png") 
print("- Crime_Change_Rates.png")
print("- pandemic_crime_summary.csv")
print("- crime_type_analysis.csv")