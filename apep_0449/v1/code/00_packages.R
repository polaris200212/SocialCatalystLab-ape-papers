## ============================================================================
## 00_packages.R — Criminal Politicians and Local Development (apep_0449)
## Load all required libraries
## ============================================================================

## ── CRAN packages ──────────────────────────────────────────────────────────
pkgs <- c(
  "data.table",     # Fast data manipulation
  "fixest",         # Fixed effects regression (for panel specs)
  "rdrobust",       # RDD estimation (Calonico, Cattaneo & Farrell)
  "rddensity",      # McCrary-type density tests
  "ggplot2",        # Plotting
  "haven",          # Read Stata .dta files (SHRUG format)
  "readr",          # Read CSV files
  "dplyr",          # Data wrangling
  "tidyr",          # Data reshaping
  "stringr",        # String manipulation
  "httr",           # HTTP requests for data download
  "jsonlite",       # JSON parsing
  "xtable",         # LaTeX table export
  "scales",         # Scale formatting for plots
  "patchwork",      # Combine ggplot panels
  "modelsummary",   # Regression tables
  "kableExtra"      # Table formatting
)

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}

## ── Global settings ────────────────────────────────────────────────────────
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 12),
    legend.position = "bottom"
  ))

options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

## ── Paths (relative to code/ directory) ─────────────────────────────────────
BASE_DIR  <- ".."
DATA_DIR  <- file.path(BASE_DIR, "data")
FIG_DIR   <- file.path(BASE_DIR, "figures")
TAB_DIR   <- file.path(BASE_DIR, "tables")
CODE_DIR  <- "."

dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)

cat("Packages loaded. Directories set.\n")
cat("  BASE_DIR:", BASE_DIR, "\n")
cat("  DATA_DIR:", DATA_DIR, "\n")
