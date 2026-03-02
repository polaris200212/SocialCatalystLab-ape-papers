###############################################################################
# 00_packages.R — Load required packages and set global options
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Core data wrangling
library(tidyverse)
library(haven)
library(janitor)
library(lubridate)

# GSS data access
if (!require(gssr, quietly = TRUE)) {
  remotes::install_github("kjhealy/gssr", quiet = TRUE, upgrade = "never")
}
library(gssr)

# Causal inference / DR
if (!require(AIPW, quietly = TRUE)) install.packages("AIPW", quiet = TRUE)
if (!require(SuperLearner, quietly = TRUE)) install.packages("SuperLearner", quiet = TRUE)
if (!require(ranger, quietly = TRUE)) install.packages("ranger", quiet = TRUE)
if (!require(xgboost, quietly = TRUE)) install.packages("xgboost", quiet = TRUE)

library(AIPW)
library(SuperLearner)
library(ranger)
library(xgboost)

# Diagnostics and balance
if (!require(cobalt, quietly = TRUE)) install.packages("cobalt", quiet = TRUE)
if (!require(WeightIt, quietly = TRUE)) install.packages("WeightIt", quiet = TRUE)
library(cobalt)
library(WeightIt)

# Sensitivity analysis
if (!require(EValue, quietly = TRUE)) install.packages("EValue", quiet = TRUE)
if (!require(sensemakr, quietly = TRUE)) install.packages("sensemakr", quiet = TRUE)
library(EValue)
library(sensemakr)

# Figures
library(ggplot2)
if (!require(patchwork, quietly = TRUE)) install.packages("patchwork", quiet = TRUE)
if (!require(scales, quietly = TRUE)) install.packages("scales", quiet = TRUE)
if (!require(latex2exp, quietly = TRUE)) install.packages("latex2exp", quiet = TRUE)
library(patchwork)
library(scales)
library(latex2exp)

# Tables
if (!require(modelsummary, quietly = TRUE)) install.packages("modelsummary", quiet = TRUE)
if (!require(kableExtra, quietly = TRUE)) install.packages("kableExtra", quiet = TRUE)
library(modelsummary)
library(kableExtra)

# Additional
if (!require(jsonlite, quietly = TRUE)) install.packages("jsonlite", quiet = TRUE)
library(jsonlite)

# APEP standard theme
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

theme_set(theme_apep())

cat("All packages loaded successfully.\n")
