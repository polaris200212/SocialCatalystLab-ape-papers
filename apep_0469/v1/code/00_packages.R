## ============================================================================
## 00_packages.R — Missing Men, Rising Women (apep_0469)
## Install and load all required packages
## ============================================================================

# Package list
pkgs <- c(
  # Core data
  "data.table", "arrow", "haven",
  # Econometrics
  "fixest", "did", "sandwich", "lmtest", "AER",
  # Lee bounds / selection
  "quantreg",
  # Figures
  "ggplot2", "ggthemes", "patchwork", "scales", "RColorBrewer",
  "viridis", "sf", "tigris", "ggrepel",
  # Tables
  "modelsummary", "kableExtra", "xtable",
  # Utilities
  "readr", "stringr", "glue", "here", "fst",
  # IPUMS
  "ipumsr",
  # Multiple testing
  "multcomp",
  # Bootstrap (optional)
  "boot"
)

# Install missing packages
new_pkgs <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(new_pkgs) > 0) {
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", dependencies = TRUE)
}

# Load all
invisible(lapply(pkgs, library, character.only = TRUE))

# Set options
options(
  tigris_use_cache = TRUE,
  scipen = 999,
  datatable.print.nrows = 20
)

# Theme for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      plot.caption = element_text(color = "grey60", size = base_size - 2, hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1)
    )
}

theme_set(theme_apep())

# Color palettes
pal_gender <- c("Women" = "#E63946", "Men" = "#457B9D")
pal_mobilization <- viridis::viridis(5, option = "D")
pal_race <- c("White" = "#264653", "Black" = "#E76F51", "Other" = "#2A9D8F")

# Load .env for API keys
env_file <- here::here(".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file, warn = FALSE)
  env_lines <- env_lines[!grepl("^#|^\\s*$", env_lines)]
  for (line in env_lines) {
    eq_pos <- regexpr("=", line, fixed = TRUE)
    if (eq_pos > 0) {
      key <- trimws(substr(line, 1, eq_pos - 1))
      val <- trimws(substr(line, eq_pos + 1, nchar(line)))
      if (nchar(key) > 0) {
        args <- list(val)
        names(args) <- key
        do.call(Sys.setenv, args)
      }
    }
  }
  cat("✓ Loaded .env\n")
}

cat("✓ All packages loaded. Ready.\n")
cat(sprintf("  R version: %s\n", R.version.string))
cat(sprintf("  data.table: %s\n", packageVersion("data.table")))
cat(sprintf("  fixest: %s\n", packageVersion("fixest")))
cat(sprintf("  Threads: %d\n", data.table::getDTthreads()))
