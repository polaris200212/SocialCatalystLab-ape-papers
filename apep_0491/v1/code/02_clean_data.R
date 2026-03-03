## ============================================================================
## 02_clean_data.R — Variable construction and panel finalization
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")
DATA <- "../data"
panel <- readRDS(file.path(DATA, "analysis_panel.rds"))

## ============================================================================
## 1. Log-transformed outcomes (for percentage interpretation)
## ============================================================================

## Add 1 to avoid log(0) — standard in crime literature
panel[, log_murder_rate  := log(murder_rate + 1)]
panel[, log_assault_rate := log(assault_agg_rate + 1)]
panel[, log_robbery_rate := log(robbery_rate + 1)]
panel[, log_violent_rate := log(violent_rate + 1)]
panel[, log_property_rate := log(property_rate + 1)]
panel[, log_burglary_rate := log(burglary_rate + 1)]
panel[, log_larceny_rate  := log(larceny_rate + 1)]

## ============================================================================
## 2. Numeric state identifier for fixest
## ============================================================================

panel[, state_id := as.integer(factor(state_abb))]

## ============================================================================
## 3. Cohort labels
## ============================================================================

panel[, cohort_label := fcase(
  g == 0, "Never treated",
  g <= 2005, "Early (1999-2005)",
  g <= 2017, "Pre-wave (2016-2017)",
  g <= 2018, "2018 wave",
  g <= 2019, "2019 wave",
  g <= 2020, "2020 wave",
  default = "2024 wave"
)]

## ============================================================================
## 4. Summary statistics
## ============================================================================

cat("\n=== Panel Summary ===\n")
cat(sprintf("States: %d (treated: %d, never-treated: %d)\n",
            uniqueN(panel$state_abb),
            uniqueN(panel[treated == TRUE]$state_abb),
            uniqueN(panel[treated == FALSE]$state_abb)))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("State-years: %d\n", nrow(panel)))

## Mean crime rates by treatment status
cat("\n--- Mean crime rates per 100K (2000-2023) ---\n")
summary_dt <- panel[, .(
  murder_rate  = mean(murder_rate, na.rm = TRUE),
  assault_rate = mean(assault_agg_rate, na.rm = TRUE),
  robbery_rate = mean(robbery_rate, na.rm = TRUE),
  violent_rate = mean(violent_rate, na.rm = TRUE),
  property_rate = mean(property_rate, na.rm = TRUE),
  n_obs = .N
), by = treated]
print(summary_dt)

## Cohort distribution
cat("\n--- Treated states by cohort ---\n")
cohort_dt <- unique(panel[treated == TRUE, .(state_abb, erpo_year, cohort_label)])
setorder(cohort_dt, erpo_year, state_abb)
print(cohort_dt)

## ============================================================================
## 5. Save cleaned panel
## ============================================================================

saveRDS(panel, file.path(DATA, "analysis_panel_clean.rds"))
cat(sprintf("\nSaved cleaned panel: %s\n", file.path(DATA, "analysis_panel_clean.rds")))
