###############################################################################
# 00_packages.R — Install and load required packages
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

required_pkgs <- c(
  "tidyverse", "data.table", "arrow", "fixest",
  "rdrobust", "rddensity", "rdlocrand",
  "ggplot2", "patchwork", "scales", "xtable",
  "httr2", "jsonlite", "sf",
  "sandwich", "lmtest"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(arrow)
  library(fixest)
  library(rdrobust)
  library(rddensity)
  library(ggplot2)
  library(patchwork)
  library(scales)
  library(xtable)
  library(httr2)
  library(jsonlite)
  library(sandwich)
  library(lmtest)
})

# APEP ggplot theme
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey30"),
    axis.title = element_text(size = 10),
    legend.position = "bottom"
  )
theme_set(theme_apep)

# EPC band boundaries
EPC_BOUNDARIES <- c(39, 55, 69, 81, 92)
EPC_BAND_NAMES <- c("E/F", "D/E", "C/D", "B/C", "A/B")

# Period definitions (energy crisis)
PERIOD_BREAKS <- as.Date(c("2018-04-01", "2021-10-01", "2023-07-01"))
PERIOD_LABELS <- c("Pre-MEES", "Post-MEES Pre-Crisis", "Crisis", "Post-Crisis")

cat("Packages loaded. EPC boundaries:", EPC_BOUNDARIES, "\n")
