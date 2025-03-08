library(tidyverse)

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

pandemic_before <- subject_clean |> filter(Year >= 2017 & Year <= 2019) 
pandemic_period <- subject_clean |> filter(Year >= 2019 & Year <= 2022) 
pandemic_after <- subject_clean |> filter(Year >= 2022 & Year <= 2023) 
arrests <- subject_clean |> filter(Arrest == TRUE)

combined_data <- bind_rows(
  c(pandemic_before = pandemic_before,
       pandemic_period = pandemic_period,
       pandemic_after = pandemic_after,
       arrests = arrests
       )
)


ggplot(data = combined_data, aes(x = X.Coordinate, y = Y.Coordinate, color = Period)) + 
  geom_point() +
  labs(title = "Scatter Plot of Coordinates", x = "X Coordinate", y = "Y Coordinate", color = "Period")

