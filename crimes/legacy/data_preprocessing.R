library(dplyr)
library(lubridate)

subject <- read.csv("Crimes.csv")
daily_crimes <- subject |>
  mutate(Day= as.Date(mdy_hms(Date))) |>
  group_by(Day, Year, Primary.Type, Location.Description) |>
  summarize(count =n()) |>
  ungroup()
  View(daily_crimes)
  write.csv("daily_crimes_summary.csv")
