# =============================================================================
# 00_packages.R — Going Up Alone (apep_0478)
# Load required packages and set global options
# =============================================================================

# Core
library(data.table)
library(dplyr)
library(tidyr)
library(stringr)

# Econometrics
library(fixest)
library(Synth)
library(augsynth)

# Visualization
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)
library(RColorBrewer)

# Tables
library(kableExtra)
library(modelsummary)

# I/O
library(DBI)
library(duckdb)

# Set global options
options(scipen = 999)
setFixest_nthreads(parallel::detectCores())

# APEP theme for ggplot
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2, hjust = 0),
      plot.subtitle = element_text(size = base_size, color = "grey40", hjust = 0),
      plot.caption = element_text(size = base_size - 3, color = "grey50", hjust = 1),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90"),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      legend.text = element_text(size = base_size - 2),
      strip.text = element_text(face = "bold", size = base_size - 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Color palette
apep_colors <- c(
  "#2C3E50", "#E74C3C", "#3498DB", "#2ECC71", "#F39C12",
  "#9B59B6", "#1ABC9C", "#E67E22", "#34495E", "#16A085"
)

# Paths
DATA_DIR <- file.path(dirname(getwd()), "data")
FIG_DIR  <- file.path(dirname(getwd()), "figures")
TAB_DIR  <- file.path(dirname(getwd()), "tables")

# Ensure output dirs exist
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

# OCC1950 codes
OCC_ELEVATOR <- 761L
OCC_JANITOR  <- 770L
OCC_PORTER   <- 780L
OCC_GUARD    <- 763L
OCC_CHARWOMAN <- 753L
OCC_HOUSEKEEPER <- 764L

# Building service occupations (comparison group)
BLDG_SERVICE_OCCS <- c(OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD, OCC_CHARWOMAN, OCC_HOUSEKEEPER)

# Census sample codes
SAMPLES <- c(
  "1900" = "us1900m", "1910" = "us1910m", "1920" = "us1920c",
  "1930" = "us1930d", "1940" = "us1940b", "1950" = "us1950b"
)

YEARS <- as.integer(names(SAMPLES))

cat("Packages loaded. Directories set.\n")
cat("  DATA_DIR:", DATA_DIR, "\n")
cat("  FIG_DIR:", FIG_DIR, "\n")
cat("  TAB_DIR:", TAB_DIR, "\n")
