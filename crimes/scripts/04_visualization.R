# ===============================================
# 📈 고품질 시각화 생성 (패키지 로드 포함)
# ===============================================

cat("📈 시각화 생성 시작...\n")

# 필요한 패키지 로드
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(viridis)
library(gridExtra)  # grid.arrange용
library(grid)       # textGrob용 - 이게 빠졌음!
library(stringr)

# 전처리된 데이터 및 통계 결과 로드
daily_crimes <- readRDS(file.path(PROCESSED_DATA_PATH, "daily_crimes.rds"))
monthly_crimes <- readRDS(file.path(PROCESSED_DATA_PATH, "monthly_crimes.rds"))
crime_type_summary <- readRDS(file.path(PROCESSED_DATA_PATH, "crime_type_summary.rds"))
statistical_results <- readRDS("outputs/tables/statistical_analysis_results.rds")

# 시각화 설정값들 (만약 정의되지 않았다면)
if(!exists("PANDEMIC_START")) PANDEMIC_START <- as.Date("2020-03-01")
if(!exists("ENDEMIC_START")) ENDEMIC_START <- as.Date("2022-01-01")
if(!exists("pandemic_colors")) {
  pandemic_colors <- c("Before" = "#1f77b4", "During" = "#ff7f0e", "After" = "#2ca02c")
}
if(!exists("PLOT_WIDTH")) PLOT_WIDTH <- 12
if(!exists("PLOT_HEIGHT")) PLOT_HEIGHT <- 8
if(!exists("PLOT_DPI")) PLOT_DPI <- 300

# 출력 폴더 생성
dir.create("outputs/plots/temporal_analysis", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/plots/pandemic_impact", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/plots/crime_types", recursive = TRUE, showWarnings = FALSE)

# ===============================================
# 1. 시계열 트렌드 분석 차트
# ===============================================

cat("📊 시계열 트렌드 차트 생성 중...\n")

# monthly_crimes에 moving_avg 컬럼이 없다면 생성
if(!"moving_avg" %in% names(monthly_crimes)) {
  library(zoo)
  monthly_crimes <- monthly_crimes %>%
    arrange(YearMonth) %>%
    mutate(moving_avg = rollmean(crime_counts, k = 3, fill = NA, align = "center"))
}

# 월별 트렌드 with 이동평균 (linewidth 사용)
p_timeseries <- ggplot(monthly_crimes, aes(x = YearMonth)) +
  geom_line(aes(y = crime_counts), color = "gray70", linewidth = 0.5, alpha = 0.7) +
  geom_line(aes(y = moving_avg, color = Period), linewidth = 1.2, na.rm = TRUE) +
  geom_vline(xintercept = PANDEMIC_START, 
             linetype = "dashed", color = "red", linewidth = 1, alpha = 0.7) +
  geom_vline(xintercept = ENDEMIC_START, 
             linetype = "dashed", color = "blue", linewidth = 1, alpha = 0.7) +
  geom_smooth(aes(y = crime_counts), method = "loess", se = TRUE, 
              color = "black", alpha = 0.2) +
  scale_color_manual(values = pandemic_colors) +
  scale_x_date(date_labels = "%Y-%m", date_breaks = "6 months") +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Chicago Crime Trends: Monthly Analysis with Moving Average",
    subtitle = "Red line: Pandemic Start (Mar 2020) | Blue line: Endemic Transition (Jan 2022)",
    x = "Date", 
    y = "Number of Crimes",
    color = "Period",
    caption = "Source: Chicago Police Department | Gray: Raw data, Colored: 3-month moving average"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

ggsave("outputs/plots/temporal_analysis/monthly_trends_with_ma.png", 
       p_timeseries, width = PLOT_WIDTH, height = PLOT_HEIGHT, dpi = PLOT_DPI)

# ===============================================
# 2. 팬데믹 영향 비교 차트
# ===============================================

cat("📊 팬데믹 영향 비교 차트 생성 중...\n")

# 박스플롯으로 분포 비교
p_pandemic_boxplot <- daily_crimes %>%
  ggplot(aes(x = Period, y = crime_counts, fill = Period)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.3) +
  geom_violin(alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, 
               fill = "white", color = "black") +
  scale_fill_manual(values = pandemic_colors) +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    title = "Daily Crime Distribution by Pandemic Period",
    subtitle = "Box plots with violin plots overlay | Diamond: Mean values",
    x = "Pandemic Period",
    y = "Daily Crime Count",
    caption = "Outliers shown as individual points"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/plots/pandemic_impact/daily_crime_distribution.png",
       p_pandemic_boxplot, width = 10, height = 8, dpi = PLOT_DPI)

# 밀도 비교 플롯
p_pandemic_density <- daily_crimes %>%
  ggplot(aes(x = crime_counts, fill = Period)) +
  geom_density(alpha = 0.6) +
  geom_vline(data = statistical_results$summary_stats, 
             aes(xintercept = mean_daily_crimes, color = Period),
             linetype = "dashed", linewidth = 1) +
  scale_fill_manual(values = pandemic_colors) +
  scale_color_manual(values = pandemic_colors) +
  labs(
    title = "Crime Density Distribution Across Pandemic Periods",
    subtitle = "Dashed lines represent mean values for each period",
    x = "Daily Crime Count",
    y = "Density",
    fill = "Period",
    color = "Period"
  ) +
  facet_wrap(~Period, ncol = 1, scales = "free_y") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("outputs/plots/pandemic_impact/pandemic_density_comparison.png",
       p_pandemic_density, width = 10, height = 12, dpi = PLOT_DPI)

# ===============================================
# 3. 범죄 유형별 히트맵
# ===============================================

cat("🔥 범죄 유형별 히트맵 생성 중...\n")

# 상위 15개 범죄 유형 선택
top_crimes <- crime_type_summary %>%
  top_n(15, total_crimes) %>%
  pull(Primary.Type)

# 히트맵 데이터 준비
heatmap_data <- crime_type_summary %>%
  filter(Primary.Type %in% top_crimes) %>%
  select(Primary.Type, Before, During, After) %>%
  pivot_longer(cols = c(Before, During, After), 
               names_to = "Period", values_to = "Count") %>%
  mutate(
    Period = factor(Period, levels = c("Before", "During", "After")),
    Primary.Type = str_wrap(Primary.Type, width = 20)
  )

p_heatmap <- ggplot(heatmap_data, aes(x = Period, y = reorder(Primary.Type, Count))) +
  geom_tile(aes(fill = Count), color = "white", linewidth = 0.5) +
  geom_text(aes(label = scales::comma(Count)), 
            color = "white", size = 3, fontface = "bold") +
  scale_fill_viridis_c(name = "Crime\nCount", trans = "log10", 
                       labels = scales::comma_format()) +
  labs(
    title = "Crime Types Heatmap by Pandemic Period",
    subtitle = "Top 15 Most Common Crime Types (Log scale)",
    x = "Pandemic Period",
    y = "Crime Type"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 9),
    axis.text.x = element_text(size = 11, face = "bold"),
    plot.title = element_text(size = 16, face = "bold")
  )

ggsave("outputs/plots/crime_types/crime_types_heatmap.png",
       p_heatmap, width = 12, height = 10, dpi = PLOT_DPI)

# ===============================================
# 4. 변화율 분석 차트
# ===============================================

cat("📊 범죄 유형별 변화율 차트 생성 중...\n")

# 팬데믹 중 변화율 막대 그래프
p_change_during <- crime_type_summary %>%
  filter(Primary.Type %in% top_crimes) %>%
  mutate(
    Primary.Type = str_wrap(Primary.Type, width = 25),
    change_direction = ifelse(pct_change_during > 0, "증가", "감소")
  ) %>%
  ggplot(aes(x = reorder(Primary.Type, pct_change_during), 
             y = pct_change_during)) +
  geom_col(aes(fill = change_direction), alpha = 0.8) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", linewidth = 0.5) +
  coord_flip() +
  scale_fill_manual(values = c("증가" = "#d62728", "감소" = "#2ca02c")) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Crime Type Changes During Pandemic",
    subtitle = "Percentage change compared to pre-pandemic period (2017-2019)",
    x = "Crime Type",
    y = "Percentage Change (%)",
    fill = "Direction"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 9),
    legend.position = "bottom"
  )

ggsave("outputs/plots/crime_types/crime_change_rates_during.png",
       p_change_during, width = 12, height = 10, dpi = PLOT_DPI)

# 회복 상황 분석 (After vs Before)
p_recovery <- crime_type_summary %>%
  filter(Primary.Type %in% top_crimes) %>%
  mutate(
    Primary.Type = str_wrap(Primary.Type, width = 25),
    recovery_status = case_when(
      abs(pct_change_after) <= 5 ~ "완전 회복",
      pct_change_after > 5 ~ "초과 회복", 
      pct_change_after < -5 ~ "미회복"
    )
  ) %>%
  ggplot(aes(x = pct_change_during, y = pct_change_after)) +
  geom_point(aes(color = recovery_status, size = total_crimes), alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, linetype = "dotted", alpha = 0.5) +
  scale_color_manual(values = c("완전 회복" = "#2ca02c", 
                                "초과 회복" = "#ff7f0e",
                                "미회복" = "#d62728")) +
  scale_size_continuous(range = c(3, 8), labels = scales::comma_format()) +
  labs(
    title = "Crime Recovery Analysis: During vs After Pandemic",
    subtitle = "Each point represents a crime type | Size = Total crime count",
    x = "Change During Pandemic (%)",
    y = "Change After Pandemic (%)",
    color = "Recovery Status",
    size = "Total Crimes",
    caption = "Diagonal line: equal change in both periods"
  ) +
  theme_minimal()

ggsave("outputs/plots/pandemic_impact/recovery_analysis.png",
       p_recovery, width = 12, height = 10, dpi = PLOT_DPI)

# ===============================================
# 5. 통계 검정 결과 시각화
# ===============================================

cat("📊 통계 검정 결과 시각화 중...\n")

# Effect size 시각화
effect_size_data <- statistical_results$effect_sizes %>%
  mutate(
    abs_effect = abs(Cohens_d),
    direction = ifelse(Cohens_d > 0, "증가", "감소")
  )

p_effect_sizes <- ggplot(effect_size_data, aes(x = reorder(Comparison, abs_effect))) +
  geom_col(aes(y = Cohens_d, fill = direction), alpha = 0.8) +
  geom_hline(yintercept = c(-0.5, -0.2, 0.2, 0.5), 
             linetype = "dashed", alpha = 0.5) +
  coord_flip() +
  scale_fill_manual(values = c("증가" = "#d62728", "감소" = "#2ca02c")) +
  labs(
    title = "Effect Sizes (Cohen's d) for Period Comparisons",
    subtitle = "Dashed lines: Small (0.2), Medium (0.5) effect thresholds",
    x = "Comparison",
    y = "Cohen's d",
    fill = "Direction",
    caption = "Negative values indicate decrease in second period"
  ) +
  theme_minimal()

ggsave("outputs/plots/pandemic_impact/effect_sizes.png",
       p_effect_sizes, width = 10, height = 6, dpi = PLOT_DPI)

# ===============================================
# 6. 종합 대시보드 (수정된 부분)
# ===============================================

cat("🎛 종합 대시보드 생성 중...\n")

# 4분할 대시보드
p1 <- p_timeseries + theme(legend.position = "none", plot.title = element_text(size = 12))
p2 <- p_pandemic_boxplot + theme(plot.title = element_text(size = 12))
p3 <- p_change_during + theme(legend.position = "none", plot.title = element_text(size = 12))
p4 <- p_effect_sizes + theme(legend.position = "none", plot.title = element_text(size = 12))

# grid 패키지의 textGrob 사용 (이제 작동함)
dashboard <- grid.arrange(p1, p2, p3, p4, 
                          ncol = 2, nrow = 2,
                          top = textGrob("Chicago Crime Analysis Dashboard - Pandemic Impact", 
                                         gp = gpar(fontsize = 16, fontface = "bold")))

# 대시보드 저장
ggsave("outputs/plots/chicago_crime_dashboard.png", 
       dashboard, width = 16, height = 12, dpi = PLOT_DPI)

cat("✅ 모든 시각화 완료!\n")
cat("📁 저장된 위치:\n")
cat("  - outputs/plots/temporal_analysis/\n")
cat("  - outputs/plots/pandemic_impact/\n")
cat("  - outputs/plots/crime_types/\n")
cat("  - outputs/plots/chicago_crime_dashboard.png\n\n")