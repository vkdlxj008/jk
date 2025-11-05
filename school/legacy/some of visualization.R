library(ggplot2)
library(dplyr)
library(car)
library(moments)
library(readr)
library(tidyr)
library(ggplot2)
library(corrplot)

graduation_model <- read.csv("final_data_clean.csv")

glimpse(graduation_model)
head(graduation_model)

#1) Linear facet plot
combine_rate <- graduation_model |>
  pivot_longer(
    cols = c(acgr, alcohol, bully, cyberbully, weapon_state),
    names_to = "clue",
    values_to = "number"
  ) |>
  arrange(state, clue, year)

ggplot(combine_rate, aes(x = year, y = number, color = clue, group = interaction(state, clue))) +
  geom_line() +
  geom_point(size = 1.2) +
  scale_y_continuous(limits = c(0, 100)) +
  facet_wrap(~ state, ncol = 6) +
  labs(
    title = "Factors Influencing Graduation Rates by Year and State",
    x = "Year", y = "Graduation Rate"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "right")

#2) Comparing high vs low mean of explanatory variable

risk_groups <- graduation_model |>
  group_by(state) |>
  summarise(
    mean_acgr    = mean(acgr, na.rm = TRUE),
    mean_alcohol = mean(alcohol, na.rm = TRUE),
    mean_bully   = mean(bully, na.rm = TRUE),
    mean_cyber   = mean(cyberbully, na.rm = TRUE),
    mean_weapon  = mean(weapon_state, na.rm = TRUE)
  ) |>
  mutate(
    alcohol_group = ifelse(mean_alcohol > median(mean_alcohol, na.rm = TRUE), "High", "Low"),
    bully_group   = ifelse(mean_bully   > median(mean_bully,   na.rm = TRUE), "High", "Low"),
    cyber_group   = ifelse(mean_cyber   > median(mean_cyber,   na.rm = TRUE), "High", "Low"),
    weapon_group  = ifelse(mean_weapon  > median(mean_weapon,  na.rm = TRUE), "High", "Low")
  )

risk_long <- risk_groups |>
  select(state, mean_acgr,
         alcohol_group, bully_group, cyber_group, weapon_group) |>
  pivot_longer(
    cols = c(alcohol_group, bully_group, cyber_group, weapon_group),
    names_to = "risk_factor",
    values_to = "group"
  )

risk_long$risk_factor <- dplyr::recode(
  risk_long$risk_factor,
  "alcohol_group" = "Alcohol Use",
  "bully_group"   = "Bullying",
  "cyber_group"   = "Cyberbullying",
  "weapon_group"  = "Weapon Threats"
)

# facet boxplot
ggplot(risk_long, aes(x = group, y = mean_acgr, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.size = 1.5) +
  facet_wrap(~ risk_factor, nrow = 1) +
  scale_fill_manual(values = c("Low" = "#74add1", "High" = "#d73027")) +
  labs(
    title = "Graduation Rates by Risk Level Across Different Factors",
    x = "Risk Group (Low vs High)",
    y = "Average Graduation Rate (%)",
    fill = "Risk Level"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )

#3) corrplot
cor_data <- graduation_model |>
  select(acgr, alcohol, bully, cyberbully, weapon_state) |>
  cor(use = "complete.obs")

corrplot(cor_data, method = "color", addCoef.col = "black",
         col = colorRampPalette(c("blue","white","red"))(200),
         tl.col = "black", tl.srt = 45,
         title = "Correlation among Graduation Rate and Risk Factors",
         mar = c(0,0,2,0))
