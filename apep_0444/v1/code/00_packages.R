## ============================================================
## 00_packages.R — Load libraries and set global options
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

# ── Install missing packages ────────────────────────────────
required_pkgs <- c(
  "data.table", "fixest", "did", "ggplot2", "ggthemes",
  "modelsummary", "kableExtra", "sf", "scales", "broom",
  "sandwich", "lmtest", "HonestDiD", "purrr", "stringr",
  "Cairo"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

# ── Load packages ────────────────────────────────────────────
library(data.table)
library(fixest)
library(did)
library(ggplot2)
library(ggthemes)
library(modelsummary)
library(kableExtra)
library(scales)
library(sandwich)
library(lmtest)
library(purrr)
library(stringr)

# ── Set global options ───────────────────────────────────────
setFixest_nthreads(4)
options(modelsummary_factory_default = "kableExtra")

# ── Publication theme ────────────────────────────────────────
theme_pub <- theme_minimal(base_size = 11, base_family = "serif") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(linewidth = 0.3, color = "grey90"),
    axis.line = element_line(linewidth = 0.4),
    axis.ticks = element_line(linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_pub)

# Base directory (relative to project root)
BASE_DIR <- file.path("output", "apep_0444", "v1")

cat("Packages loaded successfully.\n")
