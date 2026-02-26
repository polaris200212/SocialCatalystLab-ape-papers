## ============================================================================
## 00_packages.R — Load libraries and set global options
## apep_0467: Priced Out of Care
## ============================================================================

# Core
library(data.table)
library(arrow)
library(tidyverse)
library(readxl)

# Econometrics
library(fixest)
library(sandwich)
library(lmtest)

# Figures
library(ggplot2)
library(latex2exp)
library(patchwork)
library(scales)

# Maps
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# Set fixest defaults
setFixest_nthreads(4)
setFixest_dict(c(
  log_providers = "Log Active Providers",
  log_beneficiaries = "Log Beneficiaries",
  log_spending = "Log Spending ($)",
  log_claims = "Log Claims",
  wage_ratio = "Wage Ratio (2019)",
  post_covid = "Post-COVID",
  covid_cases_pc = "COVID Cases/Capita",
  state_ur = "Unemployment Rate"
))

# APEP theme
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
  "#0072B2",  # Blue (primary)
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#56B4E9",  # Light blue
  "#E69F00"   # Gold
)

# Paths
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
FIGS <- "../figures"
TABS <- "../tables"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)
dir.create(FIGS, showWarnings = FALSE, recursive = TRUE)
dir.create(TABS, showWarnings = FALSE, recursive = TRUE)

cat("=== Packages loaded for apep_0467 ===\n")
