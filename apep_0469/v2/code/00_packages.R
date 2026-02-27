## ============================================================================
## 00_packages.R — Missing Men, Rising Women v2 (apep_0469)
## LONGITUDINAL PANEL with HISTID linking across full-count censuses
## ============================================================================

pkgs <- c(
  # Core data
  "data.table", "arrow", "haven",
  # Econometrics
  "fixest", "sandwich", "lmtest",
  # Figures
  "ggplot2", "patchwork", "scales", "RColorBrewer",
  "viridis", "sf", "tigris", "ggrepel",
  # Tables
  "modelsummary", "kableExtra", "xtable",
  # Utilities
  "readr", "stringr", "glue", "here",
  # IPUMS
  "ipumsr",
  # Bootstrap
  "boot"
)

new_pkgs <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(new_pkgs) > 0) {
  install.packages(new_pkgs, repos = "https://cloud.r-project.org", dependencies = TRUE)
}
invisible(lapply(pkgs, library, character.only = TRUE))

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

pal_gender <- c("Women" = "#E63946", "Men" = "#457B9D")
pal_mobilization <- viridis::viridis(5, option = "D")

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
}

cat(sprintf("Packages loaded. R %s, data.table %s, %d threads\n",
    R.version.string, packageVersion("data.table"), data.table::getDTthreads()))
cat(sprintf("Available RAM: ~%d GB\n",
    as.integer(as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1e9)))
