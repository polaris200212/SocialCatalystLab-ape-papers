## ============================================================================
## 00_packages.R — Load libraries and set global options
## Project: The First Retirement Age (apep_0442)
## ============================================================================

library(data.table)
library(rdrobust)
library(rddensity)
library(fixest)
library(ggplot2)
library(modelsummary)
library(ipumsr)
library(kableExtra)

## APEP plot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = rel(1.2)),
      plot.subtitle = element_text(color = "grey40", size = rel(0.9)),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      plot.caption = element_text(color = "grey50", hjust = 0)
    )
}

theme_set(theme_apep())

## Paths
data_dir  <- "data"
fig_dir   <- "figures"
tab_dir   <- "tables"

dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

cat("Packages loaded. R", R.version.string, "\n")
