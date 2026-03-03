## ============================================================================
## 00_packages.R — Load libraries and set global options
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

## ---- Install missing packages ----
pkgs <- c("data.table", "fixest", "did", "HonestDiD", "arrow",
           "ggplot2", "ggthemes", "patchwork", "modelsummary",
           "sandwich", "lmtest", "broom",
           "kableExtra", "scales", "stringr", "haven", "readr",
           "bacondecomp")

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

## ---- Load libraries ----
library(data.table)
library(fixest)
library(did)
library(HonestDiD)
library(arrow)
library(ggplot2)
library(ggthemes)
library(patchwork)
library(modelsummary)
library(sandwich)
library(lmtest)
library(broom)
library(kableExtra)
library(scales)
library(stringr)

## ---- Global options ----
setFixest_nthreads(parallel::detectCores() - 1)
options(modelsummary_factory_default = "kableExtra")

## ---- Plot theme ----
theme_apep <- theme_clean(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )
theme_set(theme_apep)

cat("Packages loaded successfully.\n")
