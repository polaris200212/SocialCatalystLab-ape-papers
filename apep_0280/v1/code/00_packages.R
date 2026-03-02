# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 00_packages.R - Load libraries and set themes
# ============================================================================

# Core packages
library(tidyverse)
library(haven)       # Read SAS transport files (BRFSS)
library(fixest)      # Fast fixed effects
library(did)         # Callaway-Sant'Anna DR-DiD
library(HonestDiD)   # Rambachan-Roth sensitivity
library(sandwich)    # Robust standard errors
library(lmtest)      # Coefficient tests

# Visualization
library(ggplot2)
library(scales)
library(latex2exp)

# Data
library(httr)
library(jsonlite)

# Set ggplot theme
theme_apep <- theme_minimal(base_size = 11, base_family = "serif") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    axis.line = element_line(color = "black", linewidth = 0.4),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

# Paths (relative from code/ directory)
base_dir   <- here::here("output", "apep_0277", "v1")
data_dir   <- file.path(base_dir, "data")
fig_dir    <- file.path(base_dir, "figures")
table_dir  <- file.path(base_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Directories ready.\n")
