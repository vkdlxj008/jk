Statewise Analysis of Graduation Rates and Contributing Factors (2011–2021)
{r}

weapon_s <- weapon_state |>
  pivot_longer(
    cols = c('2011', '2013', '2015', '2017'),
    names_to = "Years",
    values_to = "weapon_state"
  )

alcohol_s <- alcohol |>
  pivot_longer(
    cols = c('2011', '2013', '2015', '2017'),
    names_to = "Years",
    values_to = "alcohol"
  )

bully_s <- bully |>
  select(-c('2009')) |>
  pivot_longer(
    cols = c('2011', '2013', '2015', '2017'),
    names_to = "Years",
    values_to = "bully"
  )

cyberbully_s <- cyberbully |>
  select(-c('2009')) |>
  pivot_longer(
    cols = c('2011', '2013', '2015', '2017'),
    names_to = "Years",
    values_to = "cyberbully"
  )

acgr_s <- acgr |>
  select(-c(`2012`, `2014`, `2016`, `2018`, `2019`, `2020`, `2021`)) |>
  pivot_longer(
    cols = c('2011', '2013', '2015', '2017'),
    names_to = "Years",
    values_to = "acgr"
  )

combined_data <- acgr_s |>
  full_join(alcohol_s, by = c("state", "Years")) |>
  full_join(bully_s, by = c("state", "Years")) |>
  full_join(cyberbully_s, by = c("state", "Years")) |>
  full_join(weapon_s, by = c("state", "Years"))

head(combined_data)


Using the Anova(RCD) & Linear Regression
{r}
final_data <- na.omit(combined_data)
multi_anova <- aov(acgr ~ weapon_state +  bully + cyberbully + alcohol, data = final_data)
summary(multi_anova)

nrow(final_data)
length(coef(multi_anova)) 



model <- lm(acgr ~ weapon_state + bully + cyberbully + alcohol, data = final_data)
summary(model)


Plot
{r}
combine_rate <- final_data |>
  pivot_longer(cols = c(acgr, weapon_state, bully, cyberbully, alcohol), 
               names_to = "clue",
               values_to = "number") |>
  mutate(number = na.approx(number, na.rm = FALSE))

ggplot(combine_rate, aes(x = Years, y = number, color = clue, group = clue)) +
  geom_line() + 
  geom_point() +
   scale_y_continuous(limits = c(0, 100)) +
  facet_wrap(~state) +
  labs(
    title = "Factors Influencing Graduation Rates by Year and State",
    x = "Year",
    y = "Graduation Rate"
  )
