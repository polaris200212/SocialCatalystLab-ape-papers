## =============================================================================
## 00_packages.R — Load libraries and set global options
## apep_0497: Who Captures a Tax Cut? Property Price Capitalization from
##            France's €20B Taxe d'Habitation Abolition
## =============================================================================

## --- CRAN packages ---
required_packages <- c(
  "data.table",    # Fast data manipulation
  "fixest",        # Fast fixed effects estimation
  "did",           # Callaway-Sant'Anna DiD
  "HonestDiD",     # Rambachan-Roth sensitivity
  "ggplot2",       # Publication-quality figures
  "scales",        # Axis formatting
  "sf",            # Spatial data
  "arrow",         # Parquet I/O for large files
  "readxl",        # Excel files (Filosofi, RP)
  "stringr",       # String manipulation
  "knitr",         # Table output
  "kableExtra",    # LaTeX table formatting
  "modelsummary",  # Regression tables
  "sandwich",      # Clustered SEs
  "lmtest"         # Coefficient tests
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

## --- Global settings ---
setDTthreads(parallel::detectCores())
options(
  scipen = 999,
  digits = 4,
  datatable.print.class = TRUE,
  modelsummary_format_numeric_latex = "plain"
)

## --- ggplot theme ---
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "grey30", linewidth = 0.3),
    axis.ticks = element_line(color = "grey30", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(color = "grey40", size = 10),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

## --- Paths ---
base_dir <- file.path(getwd())
data_dir <- file.path(base_dir, "data")
fig_dir  <- file.path(base_dir, "figures")
tab_dir  <- file.path(base_dir, "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Threads:", getDTthreads(), "\n")
