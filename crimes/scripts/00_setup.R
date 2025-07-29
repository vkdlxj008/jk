# ===============================================
# 📦 Package Loading and Configuration
# ===============================================

# Required packages
required_packages <- c(
  "tidyverse",      # Data processing
  "lubridate",      # Date processing
  "plotly",         # Interactive plots
  "viridis",        # Color palette
  "effsize",        # Effect size calculation
  "changepoint",    # Change point detection
  "zoo",            # Time series processing
  "scales",         # Plot scaling
  "gridExtra",      # Multiple plots
  "RColorBrewer",   # Color palette
  "knitr",          # Table generation
  "corrplot"        # Correlation plot
)

# Install and load packages
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    cat("📦 Installing new packages:", paste(new_packages, collapse = ", "), "\n")
    install.packages(new_packages, dependencies = TRUE)
  }
}

install_if_missing(required_packages)

# Load packages
suppressPackageStartupMessages({
  lapply(required_packages, library, character.only = TRUE)
})

cat("✅ All packages loaded successfully\n")

# ===============================================
# 🎨 Visualization Theme Settings
# ===============================================

# Custom theme
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

# Set as default theme
theme_set(theme_crime_analysis())

# Define color palette
pandemic_colors <- c(
  "Before" = "#E31A1C",   # Red (Pre-pandemic)
  "During" = "#33A02C",   # Green (During pandemic)
  "After" = "#1F78B4"     # Blue (Post-pandemic)
)

# ===============================================
# 📁 Directory Structure Creation
# ===============================================

# Required directories
dirs <- c(
  "data/raw", "data/processed",
  "outputs/plots/pandemic_impact",
  "outputs/plots/temporal_analysis",
  "outputs/plots/crime_types",
  "outputs/tables",
  "outputs/reports",
  "legacy/outputs"
)

# Create directories
for(dir in dirs) {
  if(!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("📁 Creating directory:", dir, "\n")
  }
}

cat("✅ Project structure setup complete\n")

# ===============================================
# ⚙️ Global Settings
# ===============================================

# Data file path
DATA_PATH <- "C:/Users/BYU Rental/Downloads/Crimes.csv"
PROCESSED_DATA_PATH <- "C:/Users/BYU Rental/Downloads"

# Outlier removal threshold
OUTLIER_THRESHOLD <- 3

# Define pandemic periods
PANDEMIC_START <- as.Date("2020-03-01")
ENDEMIC_START <- as.Date("2022-01-01")

# Plot saving settings
PLOT_WIDTH <- 12
PLOT_HEIGHT <- 8
PLOT_DPI <- 300

cat("⚙️ Global settings complete\n\n")
