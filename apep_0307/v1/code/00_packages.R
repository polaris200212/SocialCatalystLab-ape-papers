## ============================================================================
## 00_packages.R — Load libraries for Medicaid Unwinding DiD
## ============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(arrow)
  library(fixest)
  library(did)          # Callaway-Sant'Anna
  library(ggplot2)
  library(ggthemes)
  library(sf)
  library(scales)
  library(kableExtra)
  library(modelsummary)
})

# ggplot theme
theme_set(theme_minimal(base_size = 11) +
            theme(plot.title = element_text(face = "bold"),
                  panel.grid.minor = element_blank(),
                  legend.position = "bottom"))

DATA  <- "../data"
FIG   <- "../figures"
TAB   <- "../tables"
dir.create(FIG, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded.\n")
