## ===========================================================================
## 00_packages.R — Package Loading and Theme Setup
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

# --- Core packages ---
library(data.table)
library(fixest)        # Fast fixed effects estimation
library(ggplot2)
library(scales)
library(readr)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(lubridate)

# --- Econometric packages ---
library(did)           # Callaway-Sant'Anna
library(HonestDiD)     # Rambachan-Roth sensitivity
library(sandwich)      # Robust SEs
library(lmtest)        # Coefficient tests
# fwildclusterboot not available for this R version — use boottest from fixest instead

# --- Visualization ---
library(viridis)
library(patchwork)

# --- Theme ---
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(hjust = 0, color = "grey50", size = base_size - 2),
      strip.text = element_text(face = "bold", size = base_size)
    )
}
theme_set(theme_apep())

# Output path
OUT <- "../figures/"
TAB <- "../tables/"
DAT <- "../data/"

cat("Packages loaded. Output dirs:", OUT, TAB, DAT, "\n")
