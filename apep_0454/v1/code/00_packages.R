## ============================================================================
## 00_packages.R — Load libraries and set global options
## apep_0454: The Depleted Safety Net
## ============================================================================

# Core data manipulation
library(data.table)
library(arrow)
library(tidyverse)

# Econometrics
library(fixest)
library(did)
library(sandwich)
library(lmtest)

# Figures
library(ggplot2)
library(latex2exp)
library(scales)

# Set global options
setFixest_nthreads(min(12L, parallel::detectCores()))
options(scipen = 999)

# APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      legend.text = element_text(size = base_size - 2),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(hjust = 0, color = "grey50", size = base_size - 2),
      strip.text = element_text(face = "bold", size = base_size)
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "high_exit" = "#D62828",
  "low_exit" = "#003049",
  "hcbs" = "#F77F00",
  "non_hcbs" = "#457B9D",
  "pre" = "#ADB5BD",
  "post" = "#E63946",
  "arpa" = "#2A9D8F",
  "neutral" = "#6C757D"
)

# Paths
DATA_DIR <- "../data"
FIG_DIR  <- "../figures"
TAB_DIR  <- "../tables"
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

cat("=== Packages loaded, theme set ===\n")
