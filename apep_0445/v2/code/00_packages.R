###############################################################################
# 00_packages.R
# Opportunity Zone Designation and Data Center Investment
# APEP-0445 v2
###############################################################################

# --- Core packages ---
library(tidyverse)
library(data.table)
library(fixest)

# --- RDD packages ---
library(rdrobust)
library(rddensity)
library(rdlocrand)

# --- Data import ---
library(readxl)

# --- Inference ---
library(sandwich)
library(lmtest)

# --- Tables and figures ---
library(ggplot2)
library(latex2exp)
library(scales)

# --- Spatial ---
library(sf)

# --- APEP theme ---
theme_apep <- theme_minimal(base_size = 11, base_family = "serif") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey92"),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    axis.title = element_text(size = 10),
    legend.position = "bottom",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    strip.text = element_text(face = "bold", size = 10)
  )
theme_set(theme_apep)

# --- Paths (relative to code/ directory) ---
code_dir <- tryCatch(
  normalizePath(dirname(sys.frame(1)$ofile), mustWork = TRUE),
  error = function(e) getwd()
)
base_dir <- normalizePath(file.path(code_dir, ".."), mustWork = FALSE)
data_dir <- file.path(base_dir, "data")
fig_dir <- file.path(base_dir, "figures")
tab_dir <- file.path(base_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Base directory:", base_dir, "\n")
