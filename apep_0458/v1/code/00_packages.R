## 00_packages.R — Load libraries and set global options
## APEP-0458: Second Home Caps and Local Labor Markets

# Core data manipulation
library(tidyverse)
library(data.table)
library(jsonlite)
library(httr)

# RDD packages (Cattaneo suite)
library(rdrobust)
library(rddensity)

# Regression and inference
library(fixest)
library(sandwich)
library(lmtest)

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# APEP standard theme
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

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue (treated / above threshold)
  "#D55E00",  # Orange (control / below threshold)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Set global theme
theme_set(theme_apep())

# Working directory — use here::here() or relative paths
if (!dir.exists("code")) {
  # Navigate up from code/ to the paper root
  if (dir.exists("../code")) {
    setwd("..")
  }
}

cat("Working directory:", getwd(), "\n")
cat("Packages loaded successfully.\n")
