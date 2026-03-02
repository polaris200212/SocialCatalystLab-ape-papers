## 00_packages.R — Load libraries and set global options
## APEP-0310: Workers' Compensation and Industrial Safety

# Core data manipulation
library(data.table)
library(tidyverse)

# Econometrics
library(fixest)       # Fast fixed effects
library(did)          # Callaway & Sant'Anna staggered DiD with DR
library(DRDID)        # Doubly robust DiD for repeated cross-sections

# DR/AIPW estimation
library(AIPW)         # Augmented IPW with cross-fitting
library(SuperLearner) # Ensemble ML for nuisance estimation
library(ranger)       # Random forests

# Diagnostics & sensitivity
library(cobalt)       # Covariate balance
library(sensemakr)    # Calibrated sensitivity analysis

# Visualization
library(ggplot2)
library(patchwork)
library(scales)
library(kableExtra)

# API access
library(httr)
library(jsonlite)

# Set global ggplot theme
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40"),
    strip.text = element_text(face = "bold"),
    legend.position = "bottom"
  )
theme_set(theme_apep)

# Paths
BASE_DIR <- file.path(getwd())
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Working directory:", getwd(), "\n")
