###############################################################################
# 00_packages.R — Load all required libraries
# Paper: Divine Forgiveness Beliefs (apep_0218)
###############################################################################

# Install packages if needed
required_pkgs <- c(
  "tidyverse", "haven", "fixest", "modelsummary", "kableExtra",
  "ggplot2", "scales", "patchwork", "viridis", "sf", "rnaturalearth",
  "rnaturalearthdata", "curl", "jsonlite", "stargazer", "broom",
  "forcats", "ggrepel", "gridExtra", "RColorBrewer"
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  library(pkg, character.only = TRUE)
}

# Set global theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "grey40"),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
)

# Color palette for divine beliefs
divine_pal <- c(
  "Forgiving" = "#2166AC",
  "Punitive" = "#B2182B",
  "Neutral" = "#999999",
  "Active/Moralizing" = "#D6604D",
  "Active/Not Moralizing" = "#F4A582",
  "Otiose" = "#FDDBC7",
  "Absent" = "#D1E5F0"
)

cat("All packages loaded successfully.\n")
