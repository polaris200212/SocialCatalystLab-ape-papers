## ============================================================
## 00_packages.R — Load libraries, set themes
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

# --- Core packages ---
library(tidyverse)
library(fixest)
library(data.table)

# --- DiD / Inference ---
# fwildclusterboot not available for this R version; manual bootstrap below
library(did)              # Callaway-Sant'Anna (if needed)

# --- Figures ---
library(ggplot2)
library(patchwork)
library(scales)

# --- Tables ---
library(kableExtra)

# --- Data ---
library(jsonlite)

# --- APEP figure theme ---
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      plot.caption = element_text(color = "grey50", size = base_size - 2,
                                  hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      plot.margin = margin(10, 10, 10, 10)
    )
}

theme_set(theme_apep())

# --- Color palette ---
apep_colors <- c(
  "treated" = "#E41A1C",
  "control" = "#377EB8",
  "neutral" = "#4DAF4A",
  "highlight" = "#FF7F00",
  "grey" = "#999999"
)

cat("Packages loaded successfully.\n")
