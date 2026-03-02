## ============================================================
## 00_packages.R — Load required packages
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

## Core
library(data.table)
library(fixest)

## DiD methods
library(did)          # Callaway-Sant'Anna
library(bacondecomp)  # Goodman-Bacon decomposition
library(HonestDiD)    # Sensitivity to parallel trends violations

## Figures & tables
library(ggplot2)
library(scales)
library(latex2exp)

## ── APEP Theme ──────────────────────────────────────────────
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      text = element_text(family = ""),
      plot.title = element_text(face = "bold", size = base_size + 2,
                                hjust = 0, margin = margin(b = 8)),
      plot.subtitle = element_text(size = base_size, color = "grey40",
                                   hjust = 0, margin = margin(b = 12)),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = base_size - 1),
      legend.text = element_text(size = base_size - 1),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      strip.text = element_text(face = "bold", size = base_size),
      plot.margin = margin(10, 15, 10, 10),
      plot.caption = element_text(size = base_size - 2, color = "grey50",
                                  hjust = 0)
    )
}
theme_set(theme_apep())

## Colors for phases
phase_colors <- c("Phase I" = "#E41A1C", "Phase II" = "#377EB8",
                   "Phase III" = "#4DAF4A")

cat("Packages loaded successfully.\n")
