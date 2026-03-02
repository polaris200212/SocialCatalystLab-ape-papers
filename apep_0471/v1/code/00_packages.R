## 00_packages.R — Install and load required packages
## apep_0471: UC Rollout and Firm Formation

required_pkgs <- c(
  "tidyverse", "data.table", "arrow", "fixest", "did",
  "HonestDiD", "bacondecomp", "modelsummary", "kableExtra",
  "sf", "scales", "patchwork", "lubridate", "httr2",
  "nomisr", "jsonlite", "ggthemes", "sandwich", "lmtest",
  "clubSandwich"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

library(tidyverse)
library(data.table)
library(arrow)
library(fixest)
library(did)
library(modelsummary)
library(kableExtra)
library(scales)
library(patchwork)
library(lubridate)
library(httr2)
library(jsonlite)

# APEP theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      plot.caption = element_text(hjust = 0, color = "grey50", size = base_size - 2)
    )
}

theme_set(theme_apep())

cat("Packages loaded successfully.\n")
