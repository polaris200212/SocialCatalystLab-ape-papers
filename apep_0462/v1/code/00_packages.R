## 00_packages.R — Load packages and set global options
## apep_0462: Speed limit reversal (80→90 km/h) and road safety in France

# Core
library(tidyverse)
library(data.table)

# Econometrics
library(fixest)
library(did)

# Figures
library(ggplot2)
library(patchwork)
library(scales)
library(latex2exp)

# Tables
library(kableExtra)

# Misc
library(haven)
library(arrow)

# ── APEP Standard Theme ──────────────────────────────────────────────
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
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Set default theme
theme_set(theme_apep())

# Output paths
OUT_DIR <- here::here("output", "apep_0462", "v1")
DATA_DIR <- file.path(OUT_DIR, "data")
FIG_DIR  <- file.path(OUT_DIR, "figures")
TAB_DIR  <- file.path(OUT_DIR, "tables")
CODE_DIR <- file.path(OUT_DIR, "code")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Output directory:", OUT_DIR, "\n")
