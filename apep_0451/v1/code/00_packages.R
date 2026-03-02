##──────────────────────────────────────────────────────────────────────────────
## 00_packages.R — Load libraries and set global options
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

# Core data manipulation
library(data.table)
library(tidyverse)
library(here)           # Path construction with here::here()

# IPUMS reader
library(ipumsr)

# Econometrics
library(fixest)       # Fast FE regressions with clustering
library(DRDID)        # Sant'Anna & Zhao (2020) DR DiD

# DR / causal inference
library(AIPW)         # Augmented IPW with cross-fitting
library(SuperLearner) # Ensemble ML for nuisance estimation

# ML backends
library(ranger)       # Random forests
library(glmnet)       # Penalized regression

# Diagnostics
library(cobalt)       # Covariate balance
library(sensemakr)    # Sensitivity analysis (Cinelli & Hazlett)

# Figures
library(ggplot2)
library(patchwork)
library(scales)
library(ggthemes)

# Tables
library(modelsummary)
library(kableExtra)

# Inference
library(fwildclusterboot)  # Wild cluster bootstrap

# Set global options
setFixest_nthreads(4)
options(scipen = 999)
theme_set(theme_minimal(base_size = 11))

cat("All packages loaded successfully.\n")
