# =============================================================================
# 00_packages.R — Libraries and themes for apep_0476
# =============================================================================
# Descriptive Atlas of the MLP Census Panel, 1900-1950
# =============================================================================

library(duckdb)
library(DBI)
library(tidyverse)
library(scales)
library(ggplot2)
library(latex2exp)
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

# Colorblind-safe palette
apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Format numbers with commas
fmt <- function(x) format(x, big.mark = ",", scientific = FALSE)

# Repo root and output paths (relative to code/ directory)
REPO_ROOT <- here::here()
OUT_DIR <- file.path(REPO_ROOT, "output", "apep_0476", "v1")
FIG_DIR <- file.path(OUT_DIR, "figures")
TAB_DIR <- file.path(OUT_DIR, "tables")
DATA_DIR <- file.path(OUT_DIR, "data")

dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Output directory:", OUT_DIR, "\n")
