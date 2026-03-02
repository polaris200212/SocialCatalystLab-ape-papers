## =============================================================================
## 00_packages.R — Package loading and global settings
## apep_0474: Downtown for Sale? ACV Commercial Displacement
## =============================================================================

# --- Core ---
library(tidyverse)
library(data.table)
library(arrow)          # Read Sirene parquet files
library(fixest)         # TWFE + Sun-Abraham event studies
library(did)            # Callaway-Sant'Anna estimator

# --- Matching ---
library(MatchIt)        # Propensity score / CEM matching

# --- Inference ---
library(sandwich)       # Clustered SEs
library(lmtest)         # Coefficient tests
library(clubSandwich)    # Small-sample clustered SEs (CR2)

# --- Figures & Tables ---
library(ggplot2)
library(latex2exp)
library(patchwork)      # Combine panels
library(scales)         # Axis formatting
library(sf)             # Spatial data for maps

# --- Global settings ---
options(
  scipen = 999,
  dplyr.summarise.inform = FALSE,
  fixest.notes = FALSE
)

# Paths — relative to the code/ directory
BASE <- normalizePath(file.path(dirname(sys.frame(1)$ofile %||% "."), ".."), mustWork = FALSE)
if (!dir.exists(file.path(BASE, "data"))) {
  # Fallback: use the script's location parent directory
  BASE <- normalizePath(file.path(getwd(), ".."), mustWork = FALSE)
}
DATA <- file.path(BASE, "data")
FIG  <- file.path(BASE, "figures")
TAB  <- file.path(BASE, "tables")

dir.create(FIG, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB, showWarnings = FALSE, recursive = TRUE)

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
  "#0072B2",  # Blue (treated / ACV)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

theme_set(theme_apep())

cat("Packages loaded. Paths set.\n")
cat("  DATA:", DATA, "\n")
cat("  FIG: ", FIG, "\n")
cat("  TAB: ", TAB, "\n")
