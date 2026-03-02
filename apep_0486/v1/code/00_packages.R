## 00_packages.R — Load libraries and set options
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

# Load .env
env_file <- file.path(Sys.getenv("HOME"), "auto-policy-evals", ".env")
if (file.exists(env_file)) {
  lines <- readLines(env_file, warn = FALSE)
  for (l in lines) {
    l <- trimws(l)
    if (nchar(l) == 0 || substr(l, 1, 1) == "#") next
    eq_pos <- regexpr("=", l, fixed = TRUE)
    if (eq_pos > 0) {
      key <- trimws(substr(l, 1, eq_pos - 1))
      val <- trimws(substr(l, eq_pos + 1, nchar(l)))
      val <- gsub("^['\"]|['\"]$", "", val)
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
}

# Core
library(data.table)
library(fixest)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

# DiD
library(did)          # Callaway & Sant'Anna (2021)
library(HonestDiD)    # Rambachan & Roth sensitivity

# Inference
library(fwildclusterboot) # Wild cluster bootstrap

# Tables/output
library(modelsummary)
library(kableExtra)
library(xtable)

# Plot theme — clean, journal-ready
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.3),
    axis.ticks = element_line(color = "black", linewidth = 0.3),
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

# Color palette
APEP_COLORS <- c(
  "treated" = "#E63946",
  "control" = "#457B9D",
  "black"   = "#1D3557",
  "white"   = "#A8DADC",
  "pretrial" = "#F4A261",
  "sentenced" = "#2A9D8F",
  "ci"      = "gray80"
)

# Paths
DATA_DIR    <- "../data"
FIGURE_DIR  <- "../figures"
TABLE_DIR   <- "../tables"

cat("Packages loaded. Ready for apep_0486 analysis.\n")
