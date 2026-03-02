# =============================================================================
# 00_packages.R - Load libraries and set options
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

# Install packages if needed
required_pkgs <- c("tidyverse", "fixest", "did", "httr", "jsonlite",
                   "sf", "tigris", "knitr", "kableExtra", "latex2exp",
                   "sandwich", "lmtest", "HonestDiD", "ipumsr")

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

# Load packages
library(tidyverse)
library(fixest)
library(did)
library(httr)
library(jsonlite)
library(sf)
library(tigris)
library(knitr)
library(kableExtra)
library(latex2exp)
library(sandwich)
library(lmtest)

options(tigris_use_cache = TRUE)
options(scipen = 999)

# ── APEP Standard Theme ─────────────────────────────────────────────────────
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
  "#0072B2",  # Blue (treated/Black)
  "#D55E00",  # Orange (control/White)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# fixest dictionary for table labels
setFixest_dict(c(
  black_reform = "Black $\\times$ Post-Reform",
  black = "Black",
  turnout = "Voter Turnout",
  registered = "Registration Rate",
  post_reform = "Post-Reform",
  low_risk_reform = "Low-Risk $\\times$ Post-Reform",
  high_risk_reform = "High-Risk $\\times$ Post-Reform"
))

cat("Packages loaded. Theme and colors set.\n")
