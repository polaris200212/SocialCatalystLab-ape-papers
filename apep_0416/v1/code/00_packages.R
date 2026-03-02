## ============================================================================
## 00_packages.R — Load libraries and set options
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

# Core data handling
library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

# Econometrics
library(fixest)
library(did)

# Figures
library(ggplot2)
library(scales)
library(patchwork)

# Tables
library(modelsummary)
library(kableExtra)

# Set options
options(scipen = 999)
setFixest_nthreads(4)

# APEP theme for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40", size = base_size),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(color = "gray50", hjust = 0)
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "Behavioral Health" = "#E63946",
  "HCBS" = "#457B9D",
  "CPT/Other" = "#A8DADC",
  "Treated" = "#E63946",
  "Control" = "#457B9D"
)

cat("Packages loaded successfully.\n")
