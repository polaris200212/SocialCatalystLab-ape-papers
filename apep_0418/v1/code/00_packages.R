##############################################################################
# 00_packages.R — Load libraries and set global options
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

# Core
library(tidyverse)
library(data.table)
library(readxl)

# Econometrics
library(fixest)
library(rdrobust)
library(rddensity)

# Mapping
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# Tables
library(knitr)
library(kableExtra)

# Graphics
library(ggplot2)
library(latex2exp)
library(patchwork)
library(scales)

# Set paths
BASE_DIR <- file.path(getwd())
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")
CODE_DIR <- file.path(BASE_DIR, "code")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR,  showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR,  showWarnings = FALSE, recursive = TRUE)

# APEP standard theme
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
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Load environment variables from .env
env_file <- file.path(dirname(dirname(getwd())), ".env")
if (!file.exists(env_file)) env_file <- file.path(dirname(getwd()), ".env")
if (!file.exists(env_file)) env_file <- file.path(Sys.getenv("HOME"), "auto-policy-evals", ".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file)
  for (line in env_lines) {
    if (grepl("^[A-Z].*=", line) && !grepl("^#", line)) {
      parts <- strsplit(line, "=", fixed = TRUE)[[1]]
      key <- parts[1]
      val <- paste(parts[-1], collapse = "=")
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
  cat("Loaded .env from:", env_file, "\n")
}

cat("Packages loaded. Working directory:", getwd(), "\n")
