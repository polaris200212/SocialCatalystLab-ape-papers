#' ---
#' Selective Licensing and Crime Displacement
#' 00_packages.R — Load libraries and set global options
#' ---

# Install required packages if missing
required_pkgs <- c(
  "httr2", "jsonlite", "dplyr", "tidyr", "readr", "stringr", "lubridate",
  "data.table", "fixest", "ggplot2", "patchwork", "kableExtra",
  "did", "HonestDiD", "modelsummary", "broom", "purrr", "sf"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing ", pkg, "...")
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

suppressPackageStartupMessages({
  library(httr2)
  library(jsonlite)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(lubridate)
  library(data.table)
  library(fixest)
  library(ggplot2)
  library(patchwork)
  library(did)
})

# ggplot2 global theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      legend.position = "bottom"
    )
)

# Paths
BASE_DIR <- file.path(getwd())
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")
CODE_DIR <- file.path(BASE_DIR, "code")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

message("Packages loaded. Working directory: ", getwd())
