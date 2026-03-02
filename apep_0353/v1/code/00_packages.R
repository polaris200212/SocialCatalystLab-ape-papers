## ============================================================================
## 00_packages.R — Load and install required packages
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

required_packages <- c(
  "tidyverse", "data.table", "arrow",     # Data handling
  "fixest", "lmtest", "sandwich",          # Econometrics
  "ggplot2", "latex2exp", "scales",        # Visualization
  "sf", "tigris",                          # Spatial/maps
  "httr", "jsonlite",                      # API access
  "knitr", "kableExtra",                   # Tables
  "modelsummary"                           # Regression tables
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

## ---- APEP Standard Theme ----
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

## ---- Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
FIGURES <- "../figures"
TABLES <- "../tables"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGURES, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLES, showWarnings = FALSE, recursive = TRUE)

options(tigris_use_cache = TRUE)

cat("Packages loaded. Paths configured.\n")
