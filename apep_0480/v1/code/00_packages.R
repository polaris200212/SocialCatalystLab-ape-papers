##############################################################################
# 00_packages.R — Install and load required packages
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

required_pkgs <- c(
  "tidyverse",     # data wrangling and visualization

"data.table",    # fast data processing
  "fixest",        # two-way FE estimation
  "did",           # Callaway-Sant'Anna DiD
  "DRDID",         # Doubly Robust DiD estimator
  "sandwich",      # robust standard errors
  "lmtest",        # coefficient tests
  "ggplot2",       # figures
  "scales",        # axis formatting
  "httr2",         # HTTP API calls
  "jsonlite",      # JSON parsing
  "readxl",        # Excel file reading
  "arrow",         # Parquet/large CSV handling
  # nomisr not available for this R version; using httr2 direct calls
  "HonestDiD",     # Rambachan-Roth sensitivity
  "stargazer",     # LaTeX tables
  "modelsummary",  # modern table output
  "kableExtra",    # table formatting
  "patchwork",     # figure composition
  "viridis"        # colorblind-safe palettes
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# Set global options
options(scipen = 999)
theme_set(theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40"),
    legend.position = "bottom"
  ))

cat("All packages loaded successfully.\n")
