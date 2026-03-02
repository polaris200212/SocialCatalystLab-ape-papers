## 00_packages.R — Install and load required packages
## APEP-0420: The Visible and the Invisible

required_packages <- c(
  "tidyverse",    # data manipulation + ggplot2
  "fixest",       # high-dimensional FE regression
  "data.table",   # fast data wrangling
  "AIPW",         # augmented IPW (doubly robust)
  "SuperLearner", # ensemble ML for nuisance estimation
  "ranger",       # random forests
  "xgboost",      # gradient boosting
  "cobalt",       # covariate balance diagnostics
  "WeightIt",     # propensity score weighting
  "sensemakr",    # sensitivity analysis (Cinelli & Hazlett)
  "xtable",       # LaTeX table output
  "modelsummary", # regression tables
  "kableExtra",   # table formatting
  "scales"        # number formatting
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

## ggplot2 theme for APEP papers
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

cat("Packages loaded successfully.\n")
