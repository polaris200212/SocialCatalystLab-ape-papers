## ═══════════════════════════════════════════════════════════════════════════
## 00_packages.R — Load libraries and set global options
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

# ── Core packages ────────────────────────────────────────────────────────
library(data.table)    # Fast data manipulation
library(fixest)        # High-dimensional FE estimation + Callaway-Sant'Anna
library(ggplot2)       # Visualization
library(did)           # Callaway & Sant'Anna (2021) DiD estimator
library(modelsummary)  # Publication-quality tables
library(kableExtra)    # LaTeX table formatting

# ── Spatial / GIS (only if needed) ───────────────────────────────────────
# library(sf)
# library(terra)

# ── Utility packages ────────────────────────────────────────────────────
library(haven)         # Read Stata files
library(readxl)        # Read Excel files
library(stringr)       # String manipulation
library(scales)        # Formatting

# ── Global options ──────────────────────────────────────────────────────
options(scipen = 999)  # Avoid scientific notation
setFixest_nthreads(4)  # Parallel threads for fixest

# ── Relative path setup ────────────────────────────────────────────────
get_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  if (!is.null(getOption("rstudio.proj.path"))) {
    proj_path <- getOption("rstudio.proj.path")
    if (dir.exists(file.path(proj_path, "code"))) {
      return(file.path(proj_path, "code"))
    }
  }
  return(getwd())
}

script_dir <- get_script_dir()
if (basename(script_dir) == "code") {
  base_dir <- dirname(script_dir)
} else {
  base_dir <- script_dir
}

data_dir   <- file.path(base_dir, "data")
fig_dir    <- file.path(base_dir, "figures")
tab_dir    <- file.path(base_dir, "tables")
shrug_dir  <- "data/india_shrug"

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# ── ggplot2 theme ───────────────────────────────────────────────────────
theme_paper <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.title = element_text(size = 10),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_paper)

cat("Packages loaded. Base directory:", base_dir, "\n")
