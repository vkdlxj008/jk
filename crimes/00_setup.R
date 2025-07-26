# ===============================================
# 📦 패키지 로드 및 설정
# ===============================================

# 필요한 패키지들
required_packages <- c(
  "tidyverse",      # 데이터 처리
  "lubridate",      # 날짜 처리  
  "plotly",         # 인터랙티브 플롯
  "viridis",        # 컬러 팔레트
  "effsize",        # Effect size 계산
  "changepoint",    # Change point detection
  "zoo",            # 시계열 처리
  "scales",         # 플롯 스케일링
  "gridExtra",      # 다중 플롯
  "RColorBrewer",   # 컬러 팔레트
  "knitr",          # 테이블 생성
  "corrplot"        # 상관관계 플롯
)

# 패키지 설치 및 로드
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("📦 새 패키지 설치 중:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  }
}

install_if_missing(required_packages)

# 패키지 로드
suppressPackageStartupMessages({
  lapply(required_packages, library, character.only = TRUE)
})

cat("✅ 모든 패키지 로드 완료\n")

# ===============================================
# 🎨 시각화 테마 설정
# ===============================================

# 사용자 정의 테마
theme_crime_analysis <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.title = element_text(size = 12, face = "bold"),
      legend.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.border = element_rect(color = "gray80", fill = NA, size = 0.5)
    )
}

# 기본 테마로 설정
theme_set(theme_crime_analysis())

# 컬러 팔레트 정의
pandemic_colors <- c(
  "Before" = "#E31A1C",   # 빨강 (팬데믹 전)
  "During" = "#33A02C",   # 초록 (팬데믹 중)  
  "After" = "#1F78B4"     # 파랑 (팬데믹 후)
)

# ===============================================
# 📁 디렉토리 구조 생성
# ===============================================

# 필요한 디렉토리들
dirs <- c(
  "data/raw", "data/processed",
  "outputs/plots/pandemic_impact",
  "outputs/plots/temporal_analysis", 
  "outputs/plots/crime_types",
  "outputs/tables",
  "outputs/reports",
  "legacy/outputs"
)

# 디렉토리 생성
for(dir in dirs) {
  if(!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("📁 디렉토리 생성:", dir, "\n")
  }
}

cat("✅ 프로젝트 구조 설정 완료\n")

# ===============================================
# ⚙️ 전역 설정
# ===============================================

# 데이터 파일 경로
DATA_PATH <- "C:/Users/BYU Rental/Downloads/Crimes.csv"
PROCESSED_DATA_PATH <- "C:/Users/BYU Rental/Downloads"

# 아웃라이어 제거 기준
OUTLIER_THRESHOLD <- 3

# 팬데믹 기간 정의
PANDEMIC_START <- as.Date("2020-03-01")
ENDEMIC_START <- as.Date("2022-01-01")

# 플롯 저장 설정
PLOT_WIDTH <- 12
PLOT_HEIGHT <- 8
PLOT_DPI <- 300

cat("⚙️ 전역 설정 완료\n\n")