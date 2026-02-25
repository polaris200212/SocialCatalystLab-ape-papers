## ==========================================================================
## 00_packages.R — Load libraries and set global options
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

# Core data manipulation
library(tidyverse)
library(data.table)

# Spatial analysis
library(sf)
library(geosphere)

# Econometrics
library(rdrobust)    # RDD estimation (Cattaneo, Idrobo, Titiunik)
library(rddensity)   # McCrary-style density test
library(fixest)      # High-dimensional FE regressions
library(sandwich)    # Robust standard errors
library(lmtest)      # Coefficient tests

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)
library(kableExtra)

# Utilities
library(haven)

# ---- APEP standard theme ----
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# ---- Paths ----
# Use relative paths from code/ directory
code_dir <- getwd()
paper_dir <- dirname(code_dir)
data_dir <- file.path(paper_dir, "data")
fig_dir  <- file.path(paper_dir, "figures")
tab_dir  <- file.path(paper_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Paths set.\n")
cat("  data_dir:", data_dir, "\n")
cat("  fig_dir: ", fig_dir, "\n")
cat("  tab_dir: ", tab_dir, "\n")
