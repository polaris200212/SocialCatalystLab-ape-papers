## ============================================================
## 00_packages.R — Load libraries and set themes
## apep_0482: Within-Category Budget Reallocation Under Gender
##            Quotas in Spanish Municipalities
## ============================================================

# Core data manipulation
library(tidyverse)
library(data.table)

# Causal inference
library(rdrobust)      # RDD estimation (Calonico, Cattaneo, Titiunik)
library(rddensity)     # McCrary density test
library(fixest)        # High-dimensional FE (for panel specifications)

# Tables and output
library(modelsummary)
library(kableExtra)

# Figures
library(ggplot2)
library(patchwork)
library(scales)

# Data access
library(httr)
library(jsonlite)

# Set ggplot theme
theme_set(theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40"),
    axis.title = element_text(size = 11),
    legend.position = "bottom"
  ))

# Color palette for within-education categories
edu_colors <- c(
  "Infant/Primary Centers" = "#2166AC",
  "Infant/Primary Operations" = "#4393C3",
  "Complementary Services" = "#D6604D",
  "Other Education" = "#878787"
)

cat("Packages loaded. R version:", R.version.string, "\n")
