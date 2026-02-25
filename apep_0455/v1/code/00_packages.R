## ============================================================
## 00_packages.R — Install and load required packages
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

# Install if missing
pkgs <- c(
  # Core
  "tidyverse", "data.table", "arrow",
  # Econometrics
  "fixest", "did", "DRDID", "HonestDiD", "lmtest", "sandwich", "clubSandwich",
  # Matching
  "MatchIt",
  # Figures
  "ggplot2", "latex2exp", "patchwork", "scales",
  # Data access
  "httr", "jsonlite", "readr",
  # Spatial
  "sf"
)

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

# Load
suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(fixest)
  library(did)
  library(ggplot2)
  library(latex2exp)
  library(patchwork)
  library(scales)
  library(arrow)
})

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
  "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9"
)

cat("Packages loaded successfully.\n")
