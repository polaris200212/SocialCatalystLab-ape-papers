## 00_packages.R — Load and install required packages
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

required_packages <- c(
  "tidyverse",    # Data manipulation + ggplot2
  "fixest",       # Fast fixed effects estimation (feols, sunab)
  "did",          # Callaway & Sant'Anna DiD
  "data.table",   # Memory-efficient data processing
  "fredr",        # FRED API (state unemployment)
  "scales",       # Axis formatting
  "xtable",       # LaTeX table output
  "HonestDiD",    # Sensitivity analysis for parallel trends
  "bacondecomp"   # Bacon decomposition for TWFE diagnostics
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

## APEP figure theme
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    axis.title = element_text(size = 10),
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

cat("All packages loaded successfully.\n")
cat("R version:", R.version.string, "\n")
