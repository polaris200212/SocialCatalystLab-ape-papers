## 00_packages.R - Load required packages
## Neighbourhood Planning and House Prices (apep_0228)

reqpkg <- c("tidyverse", "data.table", "fixest", "did", "readxl",
            "ggplot2", "scales", "kableExtra", "HonestDiD", "haven")

for (pkg in reqpkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

## APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      plot.caption = element_text(hjust = 0, color = "grey50", size = base_size - 2)
    )
}
theme_set(theme_apep())

cat("All packages loaded successfully.\n")
