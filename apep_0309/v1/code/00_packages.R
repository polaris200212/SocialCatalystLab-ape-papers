## ============================================================
## 00_packages.R
## PDMP Network Spillovers and Opioid Mortality
## Load all required packages and set global options
## ============================================================

## --- Core data wrangling ---
library(tidyverse)
library(data.table)
library(jsonlite)
library(httr)

## --- Econometrics: Doubly Robust & DiD ---
library(DRDID)          # Sant'Anna & Zhao (2020) doubly robust DiD
library(did)            # Callaway & Sant'Anna (2021) staggered DiD
library(fixest)         # Fast TWFE, Sun-Abraham, clustered SEs
library(AIPW)           # Augmented IPW with cross-fitting

## --- ML backends for nuisance estimation ---
library(SuperLearner)   # Ensemble ML
library(ranger)         # Fast random forests
library(glmnet)         # Penalized regression

## --- Diagnostics ---
library(cobalt)         # Covariate balance
library(sensemakr)      # Cinelli & Hazlett sensitivity analysis

## --- Tables & Figures ---
library(ggplot2)
library(latex2exp)
library(patchwork)      # Combine plots
library(scales)         # Axis formatting
library(sf)             # Spatial data for maps

## --- Set options ---
options(scipen = 999)
set.seed(20260216)

## --- APEP standard theme ---
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

cat("All packages loaded successfully.\n")
