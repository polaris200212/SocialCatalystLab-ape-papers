###############################################################################
# 00_packages.R — Load libraries and set global options
# Paper: The Geography of Monetary Transmission
###############################################################################

# Core data manipulation
library(tidyverse)
library(data.table)

# Econometrics
library(fixest)       # Fast fixed effects estimation
library(sandwich)     # Robust standard errors (Driscoll-Kraay)
library(lmtest)       # Coefficient testing

# Data access
library(fredr)        # FRED API
library(httr)         # HTTP requests (BEA API)
library(jsonlite)     # JSON parsing

# Figures
library(ggplot2)
library(patchwork)    # Multi-panel layouts
library(scales)       # Axis formatting
library(viridis)      # Color palettes

# Tables
library(modelsummary) # Regression tables
library(kableExtra)   # Table formatting

# Set FRED API key
fredr_set_key(Sys.getenv("FRED_API_KEY"))

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

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

theme_set(theme_apep())

cat("Packages loaded successfully.\n")
