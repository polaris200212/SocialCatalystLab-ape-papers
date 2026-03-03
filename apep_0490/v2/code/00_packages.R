###############################################################################
# 00_packages.R — Load libraries and set configuration
# Paper: The Price of Position (apep_0490)
###############################################################################

# Core packages
library(tidyverse)
library(data.table)
library(jsonlite)
library(httr2)

# RDD packages
library(rdrobust)
library(rddensity)

# Econometrics
library(fixest)
library(sandwich)
library(lmtest)

# Figures and tables
library(ggplot2)
library(patchwork)
library(kableExtra)
library(scales)

# Set ggplot theme
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "grey40"),
    axis.title = element_text(size = 11),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

# Paths — resolve to parent of code/ directory
BASE_DIR <- normalizePath(file.path(getwd(), ".."), mustWork = FALSE)
if (!dir.exists(file.path(BASE_DIR, "code"))) {
  # Fallback: if run from the paper root directly
  BASE_DIR <- getwd()
}
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

# arXiv cutoff: 14:00 ET = 18:00 UTC (standard time) / 18:00 UTC (EDT)
# Actually: 14:00 US Eastern. During EDT (Mar-Nov): 18:00 UTC
#           During EST (Nov-Mar): 19:00 UTC
# We will compute in ET for consistency.
CUTOFF_HOUR_ET <- 14
CUTOFF_MIN_ET  <- 0

# Categories of interest (AI/ML)
AI_CATEGORIES <- c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV", "cs.IR")

# Industry research labs for adoption measurement — tiered classification
INDUSTRY_LABS_TIER1 <- c(
  "Google", "DeepMind", "Alphabet", "Google Brain", "Google Research",
  "OpenAI",
  "Meta", "Facebook", "FAIR", "Meta AI",
  "Anthropic",
  "xAI"
)

INDUSTRY_LABS_TIER2 <- c(
  "Microsoft Research", "Microsoft",
  "Amazon", "AWS", "Amazon Science",
  "Apple",
  "NVIDIA"
)

INDUSTRY_LABS_TIER3 <- c(
  "Baidu", "Baidu Research",
  "Tencent", "Tencent AI Lab",
  "ByteDance",
  "Samsung", "Samsung Research",
  "IBM Research", "IBM",
  "Huawei", "Huawei Noah"
)

INDUSTRY_LABS <- c(INDUSTRY_LABS_TIER1, INDUSTRY_LABS_TIER2, INDUSTRY_LABS_TIER3)

# Build tier lookup for matching
INDUSTRY_TIER_MAP <- c(
  setNames(rep("tier1", length(INDUSTRY_LABS_TIER1)), INDUSTRY_LABS_TIER1),
  setNames(rep("tier2", length(INDUSTRY_LABS_TIER2)), INDUSTRY_LABS_TIER2),
  setNames(rep("tier3", length(INDUSTRY_LABS_TIER3)), INDUSTRY_LABS_TIER3)
)

cat("Packages loaded, directories created.\n")
cat("Working directory:", getwd(), "\n")
