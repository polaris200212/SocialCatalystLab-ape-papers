## ============================================================
## 00_packages.R — Load libraries and set global options
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

# Core
library(tidyverse)
library(data.table)
library(fixest)

# DiD / Causal Inference
library(did)
library(HonestDiD)

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# Data I/O
library(jsonlite)
library(httr)

# Set options
options(
  scipen = 999,
  dplyr.summarise.inform = FALSE,
  fixest.dict = c(
    log_branches_pc = "Log(Branches per 100K)",
    log_bank_emp    = "Log(Banking Employment)",
    log_bank_emp_pc = "Log(Banking Emp. per 100K)",
    durbin_exposure = "Durbin Exposure",
    post            = "Post (2012+)"
  )
)

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
  "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9"
)

cat("Packages loaded successfully.\n")
