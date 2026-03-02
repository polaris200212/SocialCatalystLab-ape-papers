## ============================================================================
## 00_packages.R — Package loading and setup
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

suppressPackageStartupMessages({
  library(arrow)
  library(data.table)
  library(dplyr)
  library(ggplot2)
  library(fixest)
  library(did)
  library(kableExtra)
  library(scales)
  library(lubridate)
  library(httr)
  library(jsonlite)
})

# ggplot theme
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom"
  ))

cat("Packages loaded.\n")
