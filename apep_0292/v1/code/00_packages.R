## 00_packages.R — Load libraries and set APEP theme
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

# --- Core packages ---
library(tidyverse)
library(jsonlite)
library(httr)

# --- Econometrics ---
library(rdrobust)      # RDD estimation (Cattaneo et al.)
library(rddensity)     # McCrary density test
library(fixest)        # Fixed effects / parametric RDD
library(sandwich)      # Robust SEs
library(lmtest)        # Coefficient testing

# --- Tables/output ---
library(knitr)
library(kableExtra)
library(modelsummary)

# --- APEP standard theme ---
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

# --- Output directories ---
fig_dir <- file.path(dirname(getwd()), "figures")
tab_dir <- file.path(dirname(getwd()), "tables")
data_dir <- file.path(dirname(getwd()), "data")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Output dirs:", fig_dir, tab_dir, data_dir, "\n")
