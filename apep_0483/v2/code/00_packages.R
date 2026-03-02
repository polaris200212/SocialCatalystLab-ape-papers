###############################################################################
# 00_packages.R — Install and load required packages
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
###############################################################################

pkgs <- c(
  # Data wrangling
  "tidyverse", "data.table", "janitor", "arrow", "readxl",
  # Econometrics
  "fixest", "did", "lfe",
  # Sensitivity and robustness
  "HonestDiD",
  # Tables and figures
  "modelsummary", "kableExtra", "ggthemes", "scales", "patchwork",
  # Data access
  "httr2", "jsonlite",
  # Inference
  "sandwich", "lmtest"
)

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}

# APEP theme for consistent figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_apep())

cat("Packages loaded successfully.\n")
