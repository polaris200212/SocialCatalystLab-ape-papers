# =============================================================================
# 00_packages.R — Package installation and loading
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

# Core packages
required_pkgs <- c(
  # Data manipulation
  "tidyverse", "data.table", "janitor", "readxl", "readODS",
  # Econometrics
  "fixest", "did", "HonestDiD", "sandwich", "lmtest",
  # Spatial / geography
  "sf",
  # API access
  "httr2", "jsonlite", "curl",
  # Figures and tables
  "ggplot2", "patchwork", "scales", "kableExtra", "modelsummary",
  # Bootstrap inference
  "boot"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# Set ggplot theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "grey40"),
      legend.position = "bottom"
    )
)

# Paths
data_dir   <- file.path(dirname(getwd()), "data")
fig_dir    <- file.path(dirname(getwd()), "figures")
tab_dir    <- file.path(dirname(getwd()), "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir,  showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir,  showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Data dir:", data_dir, "\n")
