## 00_packages.R — Load libraries and set themes
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

# Core packages
library(tidyverse)
library(fixest)        # Fast fixed effects estimation
library(did)           # Callaway & Sant'Anna DiD
library(HonestDiD)     # Sensitivity analysis for parallel trends
library(data.table)    # Fast data manipulation
library(lubridate)     # Date handling
library(jsonlite)      # JSON parsing for APIs

# Visualization
library(ggplot2)
library(patchwork)     # Combining plots
library(scales)        # Axis formatting
library(RColorBrewer)  # Color palettes

# Set ggplot theme for publication quality
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold", size = 10),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      legend.position = "bottom",
      axis.title = element_text(size = 10),
      axis.text = element_text(size = 9)
    )
)

cat("All packages loaded successfully.\n")
