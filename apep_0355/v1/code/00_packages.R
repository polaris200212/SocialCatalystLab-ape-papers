## ============================================================================
## 00_packages.R — Load all required packages
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
## ============================================================================

# Core data manipulation
library(data.table)
library(arrow)
library(tidyverse)
library(lubridate)

# Econometrics
library(fixest)       # TWFE, event studies with feols()
library(did)          # Callaway-Sant'Anna estimator
library(HonestDiD)    # Rambachan-Roth sensitivity analysis

# Visualization
library(ggplot2)
library(patchwork)
library(scales)
library(viridis)

# Tables
library(modelsummary)
library(kableExtra)

# Spatial/mapping
library(sf)

# Set global options
options(scipen = 999)
setFixest_nthreads(4)

# APEP theme for consistent figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      axis.title = element_text(size = base_size),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      strip.text = element_text(face = "bold"),
      plot.caption = element_text(color = "grey50", size = base_size - 2, hjust = 0)
    )
}

theme_set(theme_apep())

cat("Packages loaded successfully.\n")
