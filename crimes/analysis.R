# Chicago Crime Analysis - Main Runner
source("scripts/00_setup.R")

RUN_PREPROCESSING <- TRUE
RUN_STATISTICAL <- TRUE  
RUN_VISUALIZATION <- TRUE
GENERATE_REPORT <- TRUE
cat("Chicago Crime Analysis start...\n")
cat("=", 50, "\n")

start_time <- Sys.time()
# 1. Data processing
if(RUN_PREPROCESSING) {
  cat("processing...\n")
  tryCatch({
    source("scripts/01_load_aggregated_data.R")
    cat("complete \n\n")
  }, error = function(e) {
    cat("❌ Error(processing):", e$message, "\n\n")
  })
}
# 2. EDA
cat("Exploring...\n")
tryCatch({
  source("scripts/02_legacy_integration.R")
  cat("complete \n\n")
}, error = function(e) {
  cat("Error(EDA):", e$message, "\n\n")
})
# 3. Analysis
if(RUN_STATISTICAL) {
  cat("Analysis...\n")
  tryCatch({
    source("scripts/03_statistical_analysis.R")
    cat("complete \n\n")
  }, error = function(e) {
    cat("Error(Analysis):", e$message, "\n\n")
  })
}
# 4. Visualizaion
if(RUN_VISUALIZATION) {
  cat("Visualizing...\n")
  tryCatch({
    source("scripts/04_visualization.R")
    cat("complete \n\n")
  }, error = function(e) {
    cat("Error(Visual) :", e$message, "\n\n")
  })
}
# 5. report
if(GENERATE_REPORT) {
  cat("reporting...\n")
  tryCatch({
    source("scripts/05_generate_report.R")
    cat("complete \n\n")
  }, error = function(e) {
    cat("Error(report) :", e$message, "\n\n")
  })
}
# measuring time
end_time <- Sys.time()
execution_time <- round(as.numeric(difftime(end_time, start_time, units = "mins")), 2)
cat("=", 50, "\n")
cat("whole complete!\n")
cat("Time:", execution_time, "min\n")
cat("🎛 Interactive Dashboard: shiny/app.R \n")

cat("=", 50, "\n")
