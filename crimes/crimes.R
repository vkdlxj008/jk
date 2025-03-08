library(tidyverse)
library(lubridate)

# 데이터 로드 및 정제

subject <- read.csv("Crimes.csv")
subject_clean <- subject[complete.cases(subject$X.Coordinate, subject$Y.Coordinate, subject$Year), ]

remove_outliers <- function(data, variable, deviation_threshold = 3) {
  mean_val <- mean(data[[variable]])
  sd_val <- sd(data[[variable]])
  valid_data <- data[abs(data[[variable]] - mean_val) < deviation_threshold * sd_val, ]
  return(valid_data)
}

subject_clean <- remove_outliers(subject_clean, "X.Coordinate")
subject_clean <- remove_outliers(subject_clean, "Y.Coordinate")

subject_clean1 <- subject_clean %>%
  mutate(Day = as.Date(mdy_hms(Date))) %>%
  group_by(Day) %>%
  summarize(crime_counts = n()) %>%
  mutate(Year = year(Day))

# 펜데믹 기간별 데이터 필터링 및 "Period" 열 추가
pandemic_before <- subject_clean1 %>%
  filter(Year >= 2017 & Year <= 2019) %>%
  mutate(Period = "Pandemic Before")
pandemic_period <- subject_clean1 %>%
  filter(Year >= 2019 & Year <= 2022) %>%
  mutate(Period = "Pandemic Period")
pandemic_after <- subject_clean1 %>%
  filter(Year >= 2022 & Year <= 2023) %>%
  mutate(Period = "Pandemic After")


# 히스토그램 그리기
ggplot() +
  geom_density(data = pandemic_before, aes(x = crime_counts, fill = Period), alpha = 0.5) +
  geom_density(data = pandemic_period, aes(x = crime_counts, fill = Period), alpha = 0.5) +
  geom_density(data = pandemic_after, aes(x = crime_counts, fill = Period), alpha = 0.5) +
  labs(title = "Crime Density Comparison Before, During, and After Pandemic",
       x = "Number of Crimes", y = "Density", fill = "Period") +
  scale_fill_manual(values = c("Pandemic Before" = "red", "Pandemic Period" = "green", "Pandemic After" = "blue"))

ggsave('Pandemic_Density.png')
