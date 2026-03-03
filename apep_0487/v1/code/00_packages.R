################################################################################
# 00_packages.R — Load Libraries and Set Global Options
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
################################################################################

# --- Core data manipulation ---
library(data.table)
library(arrow)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

# --- Econometrics ---
library(fixest)        # feols, fepois — fast fixed-effects estimation
library(did)           # Callaway-Sant'Anna staggered DiD
library(HonestDiD)     # Rambachan-Roth sensitivity bounds
library(sandwich)      # HAC/cluster-robust SEs
# library(fwildclusterboot) # Not available for this R version — use boottest from fixest instead

# --- Data access ---
library(httr2)         # HTTP requests (FEC bulk download)
library(jsonlite)      # JSON parsing
library(tidycensus)    # Census ACS API
library(fredr)         # FRED API

# --- Visualization ---
library(ggplot2)
library(ggthemes)
library(patchwork)     # Combine plots
library(scales)
library(sf)            # Spatial data for maps
library(kableExtra)    # Table formatting

# --- Record linkage ---
library(stringdist)    # String distance for fuzzy matching

# --- Global settings ---
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# Project paths (define FIRST since .env loading depends on BASE_DIR)
BASE_DIR <- normalizePath("../../../../")
DATA_DIR <- file.path(BASE_DIR, "data/medicaid_provider_spending")
OUTPUT_DIR <- normalizePath("../")
FIG_DIR   <- file.path(OUTPUT_DIR, "figures")
TAB_DIR   <- file.path(OUTPUT_DIR, "tables")
LOCAL_DATA <- file.path(OUTPUT_DIR, "data")

# Load .env file if it exists (for API keys)
env_file <- file.path(BASE_DIR, ".env")
if (file.exists(env_file)) {
  readRenviron(env_file)
}

# Set FRED API key
if (nzchar(Sys.getenv("FRED_API_KEY"))) {
  fredr_set_key(Sys.getenv("FRED_API_KEY"))
}

# Census API key
if (nzchar(Sys.getenv("CENSUS_API_KEY"))) {
  census_api_key(Sys.getenv("CENSUS_API_KEY"), install = FALSE)
}

# ggplot2 theme
theme_apep <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(color = "gray40", size = 10),
    axis.title = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

cat("Packages loaded. Base dir:", BASE_DIR, "\n")
