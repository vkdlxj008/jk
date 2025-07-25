library(ggplot2)
library(dplyr)

data <- read.csv("C:/Users/BYU Rental/Downloads/daily_crimes.csv")
head(data)

# T-test& between assault and battery
# There are too many variables in Primary.Type, Therefore, we will only use 'assault' and 'battery' for this test.
assault <- subset(data, Primary.Type == "ASSAULT")$count
battery <- subset(data, Primary.Type == "BATTERY")$count

t.test(assault, battery)

# F-test between assault and battery
# There are too many variables in Primary.Type, Therefore, we will only use 'assault' and 'battery' for this test.
assault1 <- filter(data, Primary.Type == "ASSAULT")$count
battery1 <- filter(data, Primary.Type == "BATTERY")$count

var.test(assault1,battery1)

# Z-test between assault and battery
# There are too many variables in Primary.Type, Therefore, we will only use 'assault' and 'battery' for this test.
n1 <- length(battery)
n2 <- length(assault)
mean1 <- mean(battery)
mean2 <- mean(assault)
sd1 <- sd(battery)
sd2 <- sd(assault)

z_score <- (mean1 - mean2) / sqrt((sd1^2/n1) + (sd2^2/n2))
p_value <- 2 * (1-pnorm(z_score))

z_score
p_value

# Chi-test between Primary.Type and Location.Description
tbl <- table(data$Primary.Type, data$Location.Description)
chisq.test(tbl, simulate.p.value = TRUE)

# Correaltion test between Year and count
cor.test(data$Year, data$count, method = "pearson")

#Visualize the distribution of number of incidents by Crime type through boxplot 
ggplot(data, aes(x=Primary.Type, y = count)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle=45, hjust = 1))
