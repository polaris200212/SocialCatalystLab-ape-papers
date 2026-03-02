## ============================================================================
## 00_packages.R — Load libraries and set global options
## Project: The First Retirement Age v2 (revision of apep_0442)
## Hardware: 96GB RAM, multi-core
## ============================================================================

library(data.table)
library(rdrobust)
library(rddensity)
library(fixest)
library(ggplot2)
library(modelsummary)
library(ipumsr)
library(kableExtra)
library(patchwork)
library(scales)

## Set data.table threads for 96GB RAM machine
setDTthreads(8)

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

## Color palette
apep_blue    <- "#2980b9"
apep_red     <- "#c0392b"
apep_dark    <- "#2c3e50"
apep_grey    <- "#bdc3c7"
apep_orange  <- "#e67e22"
apep_green   <- "#27ae60"

## Paths
data_dir  <- "data"
fig_dir   <- "figures"
tab_dir   <- "tables"

dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

cat("Packages loaded. R", R.version.string, "\n")
cat("data.table threads:", getDTthreads(), "\n")
