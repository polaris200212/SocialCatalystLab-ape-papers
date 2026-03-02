##############################################################################
# 00_packages.R — Load libraries and set global options
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

# Core data wrangling
library(tidyverse)
library(data.table)
library(haven)

# Econometrics
library(fixest)
library(did)
library(bacondecomp)
library(sandwich)
library(lmtest)
# fwildclusterboot not available for this R version
# library(fwildclusterboot)

# Figures
library(ggplot2)
library(latex2exp)
library(sf)
library(tigris)
library(patchwork)

# Tables
library(knitr)
library(kableExtra)

# Set options
options(
  tigris_use_cache = TRUE,
  scipen = 999,
  digits = 4
)

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
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Set working directory (handle both RStudio and command line)
tryCatch({
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  setwd("..")
}, error = function(e) {
  # Running from command line — working directory already set
})

cat("Packages loaded successfully.\n")
