## ============================================================
## 00_packages.R — Load required packages
## Breaking Purdah with Pavement (apep_0432)
## ============================================================

## ── Core packages ──────────────────────────────────────────
library(data.table)
library(fixest)
library(ggplot2)
library(rdrobust)
library(rddensity)

## ── Additional packages ────────────────────────────────────
library(modelsummary)
library(kableExtra)

## ── Set ggplot2 theme ──────────────────────────────────────
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    plot.title    = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(color = "grey40", size = 10),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )
theme_set(theme_apep)

## ── Paths (relative to repo root, resolved via here::here) ─
if (!requireNamespace("here", quietly = TRUE)) install.packages("here", repos = "https://cloud.r-project.org")
library(here)
shrug_dir  <- here("data", "india_shrug")
out_dir    <- here("output", "apep_0432", "v1")
fig_dir    <- file.path(out_dir, "figures")
tab_dir    <- file.path(out_dir, "tables")
data_dir   <- file.path(out_dir, "data")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded successfully.\n")
