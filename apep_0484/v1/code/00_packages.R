###############################################################################
# 00_packages.R — Load required libraries and set global options
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
###############################################################################

# ---- Install packages if not present ----
required_pkgs <- c(
  "data.table", "fixest", "ggplot2", "dplyr", "tidyr", "readr",
  "lubridate", "scales", "knitr", "kableExtra", "modelsummary",
  "ggthemes", "patchwork", "arrow", "stringr", "broom",
  "sandwich", "lmtest", "HonestDiD"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# ---- Load libraries ----
library(data.table)
library(fixest)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(lubridate)
library(scales)
library(knitr)
library(kableExtra)
library(modelsummary)
library(patchwork)
library(arrow)
library(stringr)
library(sandwich)
library(lmtest)
library(HonestDiD)

# ---- Global options ----
setFixest_nthreads(parallel::detectCores())

# ---- Plotting theme ----
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    axis.title = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

# ---- Paths ----
data_dir   <- file.path(getwd(), "..", "data")
fig_dir    <- file.path(getwd(), "..", "figures")
tab_dir    <- file.path(getwd(), "..", "tables")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Paths configured.\n")
