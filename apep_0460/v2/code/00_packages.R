## ============================================================================
## 00_packages.R — Across the Channel: Brexit, Social Networks, and France
## APEP-0460
## ============================================================================

# Core data manipulation
library(tidyverse)
library(data.table)
library(readxl)

# Econometrics
library(fixest)       # Fast TWFE, IV, etable()
library(sandwich)     # Robust SEs
library(lmtest)       # Hypothesis tests

# Spatial / mapping
library(sf)
library(ggspatial)

# Figures
library(ggplot2)
library(latex2exp)
library(patchwork)    # Combine plots

# INSEE data
library(insee)        # INSEE BDM/SDMX API wrapper

# ---- APEP Standard Theme ----
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
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
data_dir   <- file.path(getwd(), "..", "data")
fig_dir    <- file.path(getwd(), "..", "figures")
tab_dir    <- file.path(getwd(), "..", "tables")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir,  showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir,  showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Data dir:", data_dir, "\n")
