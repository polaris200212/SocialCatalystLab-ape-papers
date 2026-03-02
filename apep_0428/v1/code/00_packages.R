## ============================================================
## 00_packages.R — Load libraries and set global options
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

# Set working directory relative to this script's location
# Supports both source() and Rscript invocation
.get_script_dir <- function() {
  # When called via source()
  if (!is.null(sys.frame(1)$ofile)) return(dirname(sys.frame(1)$ofile))
  # When called via Rscript
  args <- commandArgs(trailingOnly = FALSE)
  f <- grep("--file=", args, value = TRUE)
  if (length(f) > 0) return(dirname(normalizePath(sub("--file=", "", f[1]))))
  # Fallback: current working directory
  return(getwd())
}
WORK_DIR <- normalizePath(file.path(.get_script_dir(), ".."), mustWork = FALSE)
BASE_DIR <- normalizePath(file.path(WORK_DIR, "../../.."), mustWork = FALSE)

# Core data
library(data.table)
library(tidyverse)

# RDD
library(rdrobust)
library(rddensity)

# Figures
library(ggplot2)
library(latex2exp)
library(patchwork)

# Tables
library(fixest)

# Set options
options(scipen = 999)
set.seed(42)

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

apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

cat("Packages loaded successfully.\n")
