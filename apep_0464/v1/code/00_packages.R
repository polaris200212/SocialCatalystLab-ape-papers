## ============================================================================
## 00_packages.R — Connected Backlash (apep_0464)
## Load all required packages for analysis
## ============================================================================

cat("Installing/loading required packages...\n")

## — Helper: install if missing, then load
load_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  library(pkg, character.only = TRUE)
}

## — Core data manipulation
load_pkg("tidyverse")
load_pkg("data.table")
load_pkg("arrow")         # Parquet I/O for election data
load_pkg("janitor")

## — Spatial / mapping
load_pkg("sf")
load_pkg("rnaturalearth")
load_pkg("rnaturalearthdata")

## — Econometrics
load_pkg("fixest")         # TWFE, Sun-Abraham, cluster SEs
load_pkg("did")            # Callaway-Sant'Anna (if needed)
load_pkg("sandwich")
load_pkg("lmtest")
load_pkg("broom")

## — Structural estimation
load_pkg("maxLik")         # MLE
load_pkg("numDeriv")       # Numerical derivatives for Hessian
load_pkg("optimx")         # Optimization

## — Figures
load_pkg("ggplot2")
load_pkg("latex2exp")
load_pkg("scales")
load_pkg("patchwork")      # Multi-panel figures
load_pkg("viridis")
load_pkg("RColorBrewer")
load_pkg("ggrepel")

## — Tables
load_pkg("kableExtra")

## — Miscellaneous
load_pkg("haven")
load_pkg("readxl")
load_pkg("xml2")           # Parse fuel price XML
load_pkg("httr")
load_pkg("jsonlite")
load_pkg("glue")

## ============================================================================
## APEP Standard Theme
## ============================================================================

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

## Colorblind-safe palette
apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

## ============================================================================
## Set global options
## ============================================================================

options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE,
  readr.show_col_types = FALSE
)

## — fixest globals
setFixest_fml(..ctrl = ~ log_pop + unemployment_rate + log_median_income)

cat("All packages loaded successfully.\n")
