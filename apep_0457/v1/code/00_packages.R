##############################################################################
# 00_packages.R — Load libraries and set global options
# APEP-0457: The Lex Weber Shock
##############################################################################

# Install missing packages silently
required_pkgs <- c(
  "tidyverse", "fixest", "did", "rdrobust", "rddensity",
  "data.table", "httr", "jsonlite", "sandwich", "lmtest",
  "latex2exp", "bacondecomp", "clubSandwich", "HonestDiD"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing:", pkg, "\n")
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

# Also try BFS package for Swiss federal data
if (!requireNamespace("BFS", quietly = TRUE)) {
  tryCatch(
    install.packages("BFS", repos = "https://cloud.r-project.org", quiet = TRUE),
    error = function(e) cat("BFS package not available; will use direct API calls\n")
  )
}

# Load packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
  library(did)
  library(rdrobust)
  library(rddensity)
  library(data.table)
  library(httr)
  library(jsonlite)
  library(sandwich)
  library(lmtest)
  library(latex2exp)
})

# ── APEP standard theme ──────────────────────────────────────────────────────
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = base_size - 1, face = "bold"),
      axis.text = element_text(size = base_size - 2, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 2, face = "bold"),
      legend.text = element_text(size = base_size - 3),
      plot.title = element_text(size = base_size + 1, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = base_size - 2, color = "grey40", hjust = 0),
      plot.caption = element_text(size = base_size - 4, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10),
      strip.text = element_text(size = base_size - 1, face = "bold")
    )
}

apep_colors <- c(
  "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9"
)

# ── Global settings ──────────────────────────────────────────────────────────
options(scipen = 999)
setFixest_fml(..ctrl = ~ 1)

# Set paths relative to paper workspace
data_dir   <- file.path(dirname(getwd()), "data")
fig_dir    <- file.path(dirname(getwd()), "figures")
tab_dir    <- file.path(dirname(getwd()), "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Data dir:", data_dir, "\n")
