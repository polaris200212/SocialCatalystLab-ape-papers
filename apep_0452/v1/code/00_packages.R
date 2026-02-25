## 00_packages.R — Load libraries and set themes
## apep_0452: Mercury regulation and ASGM in Africa

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(fixest)
library(did)
library(DRDID)
library(httr)
library(jsonlite)
library(countrycode)
library(sandwich)
library(lmtest)
library(modelsummary)
library(purrr)
library(stringr)
library(broom)

# APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      legend.text = element_text(size = base_size - 2),
      plot.caption = element_text(hjust = 0, color = "grey50", size = base_size - 2),
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "treated" = "#E63946",
  "control" = "#457B9D",
  "highlight" = "#F4A261",
  "neutral" = "#2A9D8F",
  "grey" = "#6C757D"
)

# Paths
data_dir <- file.path(dirname(getwd()), "data")
fig_dir  <- file.path(dirname(getwd()), "figures")
tab_dir  <- file.path(dirname(getwd()), "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Directories set.\n")
