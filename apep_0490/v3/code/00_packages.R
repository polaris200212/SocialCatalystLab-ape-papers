###############################################################################
# 00_packages.R — Load libraries and set configuration
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
###############################################################################

# Core packages
library(tidyverse)
library(data.table)
library(jsonlite)
library(httr2)
library(lubridate)

# RDD packages
library(rdrobust)
library(rddensity)

# Econometrics
library(fixest)
library(sandwich)
library(lmtest)
library(survival)  # Cox proportional hazard for adoption speed

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
  BASE_DIR <- getwd()
}
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")
LOG_DIR  <- file.path(BASE_DIR, "logs")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(LOG_DIR, showWarnings = FALSE, recursive = TRUE)

# arXiv cutoff: 14:00 ET (Eastern Time)
CUTOFF_HOUR_ET <- 14
CUTOFF_MIN_ET  <- 0

# Categories of interest (AI/ML)
AI_CATEGORIES <- c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV", "cs.IR")

# Date window: 2012-2024 (adoption within 12-18 months observable for papers through mid-2024)
YEAR_START <- 2012L
YEAR_END   <- 2024L

# Industry research labs for adoption measurement — tiered classification
FRONTIER_LABS <- c(
  "Google", "DeepMind", "Alphabet", "Google Brain", "Google Research",
  "OpenAI",
  "Meta", "Facebook", "FAIR", "Meta AI",
  "Anthropic",
  "xAI"
)

BIGTECH_LABS <- c(
  "Microsoft Research", "Microsoft",
  "Amazon", "AWS", "Amazon Science",
  "Apple",
  "NVIDIA"
)

OTHER_INDUSTRY_LABS <- c(
  "Baidu", "Baidu Research",
  "Tencent", "Tencent AI Lab",
  "ByteDance",
  "Samsung", "Samsung Research",
  "IBM Research", "IBM",
  "Huawei", "Huawei Noah"
)

INDUSTRY_LABS <- c(FRONTIER_LABS, BIGTECH_LABS, OTHER_INDUSTRY_LABS)

# Build tier lookup for matching
INDUSTRY_TIER_MAP <- c(
  setNames(rep("frontier", length(FRONTIER_LABS)), FRONTIER_LABS),
  setNames(rep("bigtech", length(BIGTECH_LABS)), BIGTECH_LABS),
  setNames(rep("other", length(OTHER_INDUSTRY_LABS)), OTHER_INDUSTRY_LABS)
)

cat("Packages loaded, directories created.\n")
cat("Working directory:", getwd(), "\n")
