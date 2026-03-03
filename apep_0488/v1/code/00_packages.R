## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 00_packages.R: Load and install required packages
## =============================================================================

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Core packages
if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
if (!requireNamespace("fixest", quietly = TRUE)) install.packages("fixest")
if (!requireNamespace("did", quietly = TRUE)) install.packages("did")
if (!requireNamespace("data.table", quietly = TRUE)) install.packages("data.table")
if (!requireNamespace("haven", quietly = TRUE)) install.packages("haven")
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("patchwork", quietly = TRUE)) install.packages("patchwork")
if (!requireNamespace("scales", quietly = TRUE)) install.packages("scales")
if (!requireNamespace("xtable", quietly = TRUE)) install.packages("xtable")
if (!requireNamespace("kableExtra", quietly = TRUE)) install.packages("kableExtra")
if (!requireNamespace("HonestDiD", quietly = TRUE)) install.packages("HonestDiD")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")

library(tidyverse)
library(fixest)
library(did)
library(data.table)
library(haven)
library(readxl)
library(ggplot2)
library(patchwork)
library(scales)
library(xtable)
library(kableExtra)
library(HonestDiD)
library(jsonlite)

# APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(colour = "grey30", linewidth = 0.3),
      axis.ticks = element_line(colour = "grey30", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(colour = "grey40"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}
theme_set(theme_apep())

# Paths
CODE_DIR <- tryCatch(
  dirname(rstudioapi::getActiveDocumentContext()$path),
  error = function(e) "."
)
if (length(CODE_DIR) == 0 || CODE_DIR == "" || CODE_DIR == ".") {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    CODE_DIR <- dirname(sub("--file=", "", file_arg))
  } else {
    CODE_DIR <- getwd()
  }
}
BASE_DIR <- file.path(CODE_DIR, "..")
DATA_DIR <- file.path(BASE_DIR, "data")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR,  showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR,  showWarnings = FALSE, recursive = TRUE)

## Load .env for API keys (Rscript doesn't inherit shell environment)
env_path <- file.path(BASE_DIR, "../../../.env")
if (file.exists(env_path)) {
  env_lines <- readLines(env_path, warn = FALSE)
  env_lines <- env_lines[!grepl("^#|^$", env_lines)]
  for (line in env_lines) {
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      key <- trimws(parts[1])
      val <- trimws(paste(parts[-1], collapse = "="))
      val <- gsub("^['\"]|['\"]$", "", val)
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
}

cat("Packages loaded. Data dir:", DATA_DIR, "\n")
