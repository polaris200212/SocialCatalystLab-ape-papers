###############################################################################
# 00_packages.R — Load libraries and set global options
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

# Core packages
library(tidyverse)
library(fixest)
library(did)

# Data access
library(httr2)
library(jsonlite)
library(rvest)
library(readxl)

# Tables and figures
library(latex2exp)
library(scales)
library(patchwork)

# Inference
library(sandwich)
library(HonestDiD)

# nomisr not available for R 4.3.2 — use direct NOMIS API via httr2

# Set global options
options(scipen = 999)

# APEP figure theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      legend.text = element_text(size = base_size - 2),
      strip.text = element_text(face = "bold", size = base_size),
      plot.caption = element_text(hjust = 0, color = "gray50", size = base_size - 2)
    )
}

theme_set(theme_apep())

# Colour palette
apep_colours <- c(
  "treated" = "#2C3E50",
  "control" = "#E74C3C",
  "ci" = "#BDC3C7",
  "highlight" = "#3498DB",
  "secondary" = "#27AE60"
)

# Data paths
DATA_DIR <- "data"
FIG_DIR <- "figures"
TAB_DIR <- "tables"

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Ready for analysis.\n")
