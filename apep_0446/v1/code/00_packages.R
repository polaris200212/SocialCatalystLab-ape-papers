## ─── 00_packages.R ─────────────────────────────────────────────
## Load and install all required packages for apep_0446
## e-NAM Agricultural Market Integration DiD
## ────────────────────────────────────────────────────────────────

required_packages <- c(
  "data.table", "httr", "jsonlite",     # Data fetching
  "tidyverse", "lubridate",              # Data wrangling
  "fixest", "did",                       # DiD estimation
  "HonestDiD",                           # Sensitivity analysis
  "ggplot2", "scales", "latex2exp",      # Figures
  "knitr", "kableExtra",                 # Tables
  "pdftools"                             # PDF parsing (e-NAM directory)
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

## ─── APEP Theme ────────────────────────────────────────────────
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "grey30", linewidth = 0.3),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}
theme_set(theme_apep())

## ─── Paths ─────────────────────────────────────────────────────
data_dir <- "data"
fig_dir  <- "figures"
tab_dir  <- "tables"
dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

cat("✓ All packages loaded. Ready.\n")
