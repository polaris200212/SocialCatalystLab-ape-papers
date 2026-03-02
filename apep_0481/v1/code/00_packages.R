## 00_packages.R — Load required libraries and set global options
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

required_packages <- c(
  "data.table", "fixest", "ggplot2", "dplyr", "tidyr", "readr",
  "stringr", "haven", "modelsummary", "kableExtra", "stargazer",
  "rdrobust", "rddensity", "broom", "purrr", "xtable",
  "did", "HonestDiD", "sandwich", "lmtest", "clubSandwich",
  "scales", "grid", "gridExtra", "patchwork"
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

## Global ggplot theme
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "grey40"),
    axis.title = element_text(size = 11),
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

## Color palette for gender
gender_colors <- c("Male" = "#2166ac", "Female" = "#b2182b")
mandate_colors <- c("District" = "#1b7837", "List" = "#762a83")

cat("Packages loaded successfully.\n")
