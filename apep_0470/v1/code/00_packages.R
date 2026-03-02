###############################################################################
# 00_packages.R — Load libraries and set global options
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

# ── Core data manipulation ───────────────────────────────────────────────────
library(data.table)     # Memory-efficient large data operations
library(arrow)          # Parquet I/O for MLP crosswalks

# ── Econometrics ─────────────────────────────────────────────────────────────
library(fixest)         # Individual FE, multi-way clustering, IV
library(did)            # Callaway-Sant'Anna staggered DiD
library(HonestDiD)      # Sensitivity to parallel trends violations
library(sandwich)       # Robust standard errors
library(lmtest)         # Hypothesis testing

# ── Spatial ──────────────────────────────────────────────────────────────────
library(sf)             # Spatial operations, distance calculations
library(tigris)         # Census county shapefiles
options(tigris_use_cache = TRUE)

# ── Visualization ────────────────────────────────────────────────────────────
library(ggplot2)
library(ggthemes)
library(viridis)
library(patchwork)      # Combine plots
library(scales)
library(RColorBrewer)
library(kableExtra)     # LaTeX table formatting

# ── IPUMS ────────────────────────────────────────────────────────────────────
library(ipumsr)         # Read IPUMS data/metadata

# ── Utilities ────────────────────────────────────────────────────────────────
library(stringr)
library(broom)

# ── Global settings ──────────────────────────────────────────────────────────
setDTthreads(parallel::detectCores() - 1)
options(scipen = 999)

# ── Plot theme ───────────────────────────────────────────────────────────────
theme_tva <- theme_minimal(base_size = 12, base_family = "serif") +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0),
    plot.subtitle = element_text(size = 11, color = "grey30", hjust = 0),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    strip.text = element_text(face = "bold", size = 11),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10)
  )
theme_set(theme_tva)

# ── Color palettes ───────────────────────────────────────────────────────────
# TVA-inspired palette: river blues, valley greens, dam grays
tva_colors <- c(
  "TVA"     = "#1a5276",   # Deep river blue
  "Non-TVA" = "#b03a2e",   # Southern clay red
  "Border"  = "#7d6608"    # Valley gold
)

race_colors <- c(
  "White" = "#2c3e50",
  "Black" = "#e74c3c"
)

gender_colors <- c(
  "Male"   = "#2980b9",
  "Female" = "#8e44ad"
)

# ── Output directories ──────────────────────────────────────────────────────
fig_dir   <- "figures/"
table_dir <- "tables/"
data_dir  <- "data/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("✓ Packages loaded. data.table threads:", getDTthreads(), "\n")
cat("✓ Available RAM:", round(as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1e9, 1), "GB\n")
