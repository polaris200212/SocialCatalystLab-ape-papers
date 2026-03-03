# ==============================================================================
# 00_packages.R — Help to Buy Regional Price Caps
# apep_0492 v1
# ==============================================================================

# Required packages
pkgs <- c(
  "data.table",      # Fast data manipulation
  "ggplot2",         # Plotting
  "fixest",          # Fixed effects regression
  "rdrobust",        # RDD bandwidth selection and estimation
  "rddensity",       # McCrary density test
  "sf",              # Spatial operations (for border distances)
  "httr2",           # HTTP requests (postcodes.io)
  "jsonlite",        # JSON parsing
  "scales",          # Axis formatting
  "patchwork",       # Combining plots
  "kableExtra",      # Table formatting
  "sandwich",        # Robust standard errors
  "boot"             # Bootstrap inference
)

# Install missing packages
installed <- rownames(installed.packages())
to_install <- pkgs[!pkgs %in% installed]
if (length(to_install) > 0) {
  install.packages(to_install, repos = "https://cloud.r-project.org", quiet = TRUE)
}

# Load all
invisible(lapply(pkgs, library, character.only = TRUE))

# ggplot theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(color = "grey40"),
      legend.position = "bottom"
    )
)

cat("All packages loaded successfully.\n")
