## Truncate panel to avoid reporting lag artifacts in Dec 2024
source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
cat(sprintf("Before truncation: %d rows, date range %s to %s\n",
            nrow(panel), min(panel$month_date), max(panel$month_date)))

# Drop December 2024 (potential reporting lag)
panel <- panel[month_date < as.Date("2024-12-01")]

cat(sprintf("After truncation: %d rows, date range %s to %s\n",
            nrow(panel), min(panel$month_date), max(panel$month_date)))

saveRDS(panel, file.path(DATA, "panel_analysis.rds"))
cat("Saved truncated panel_analysis.rds\n")
