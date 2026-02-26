# ==============================================================================
# 00_packages.R — Load and install required packages
# APEP-0468: MGNREGA and Crop Portfolio Diversification
# ==============================================================================

# Core data
library(data.table)
library(tidyverse)
library(haven)
library(readxl)

# DiD
library(did)         # Callaway-Sant'Anna
library(fixest)      # Sun-Abraham, TWFE
library(bacondecomp) # Bacon decomposition
library(HonestDiD)   # Rambachan-Roth sensitivity

# Inference
library(sandwich)
library(lmtest)
# fwildclusterboot not available for this R version; use clubSandwich instead
library(clubSandwich)      # Small-sample cluster-robust SEs

# Figures
library(ggplot2)
library(latex2exp)
library(patchwork)   # Combine plots

cat("All packages loaded successfully.\n")
