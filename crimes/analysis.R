# ===============================================
# 🚀 Chicago Crime Analysis - Main Runner
# ===============================================
# 원클릭 전체 분석 실행기
# 모든 분석 스크립트를 순차적으로 실행합니다.
# 필요한 패키지 로드
source("scripts/00_setup.R")
# 분석 실행 옵션
RUN_PREPROCESSING <- TRUE    # 전처리 실행 여부
RUN_STATISTICAL <- TRUE      # 통계 분석 실행 여부  
RUN_VISUALIZATION <- TRUE    # 시각화 실행 여부
GENERATE_REPORT <- TRUE      # 리포트 생성 여부
cat("🚀 Chicago Crime Analysis 시작...\n")
cat("=", 50, "\n")
# 시작 시간 기록
start_time <- Sys.time()
# ===============================================
# 1. 데이터 전처리
# ===============================================
if(RUN_PREPROCESSING) {
  cat("🔧 데이터 전처리 중...\n")
  tryCatch({
    source("scripts/01_load_aggregated_data.R")
    cat("✅ 전처리 완료\n\n")
  }, error = function(e) {
    cat("❌ 전처리 오류:", e$message, "\n\n")
  })
}
# ===============================================  
# 2. 탐색적 데이터 분석
# ===============================================
cat("🔍 탐색적 데이터 분석 중...\n")
tryCatch({
  source("scripts/02_legacy_integration.R")
  cat("✅ 탐색적 분석 완료\n\n")
}, error = function(e) {
  cat("❌ 탐색적 분석 오류:", e$message, "\n\n")
})
# ===============================================
# 3. 통계 분석 (팬데믹 영향 등)
# ===============================================
if(RUN_STATISTICAL) {
  cat("📊 통계 분석 중...\n")
  tryCatch({
    source("scripts/03_statistical_analysis.R")
    cat("✅ 통계 분석 완료\n\n")
  }, error = function(e) {
    cat("❌ 통계 분석 오류:", e$message, "\n\n")
  })
}
# ===============================================
# 4. 시각화 생성
# ===============================================
if(RUN_VISUALIZATION) {
  cat("📈 시각화 생성 중...\n")
  tryCatch({
    source("scripts/04_visualization.R")
    cat("✅ 시각화 완료\n\n")
  }, error = function(e) {
    cat("❌ 시각화 오류:", e$message, "\n\n")
  })
}
# ===============================================
# 5. 최종 리포트 생성
# ===============================================
if(GENERATE_REPORT) {
  cat("📋 분석 리포트 생성 중...\n")
  tryCatch({
    source("scripts/05_generate_report.R")
    cat("✅ 리포트 생성 완료\n\n")
  }, error = function(e) {
    cat("❌ 리포트 생성 오류:", e$message, "\n\n")
  })
}
# 실행 시간 계산
end_time <- Sys.time()
execution_time <- round(as.numeric(difftime(end_time, start_time, units = "mins")), 2)
cat("=", 50, "\n")
cat("🎉 전체 분석 완료!\n")
cat("⏱ 총 실행 시간:", execution_time, "분\n")
cat("📁 결과물은 outputs/ 폴더에서 확인하세요.\n")
cat("🎛 인터랙티브 대시보드: shiny/app.R 실행\n")
cat("=", 50, "\n")