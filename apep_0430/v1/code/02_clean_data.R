## ============================================================
## 02_clean_data.R — Build district-year panel with harmonized
##                   nightlights and treatment assignment
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## ── 1. Load saved data ─────────────────────────────────────
cat("=== Loading data ===\n")
phase_dt  <- fread(file.path(data_dir, "district_phase_assignment.csv"))
dist_key  <- fread(file.path(data_dir, "village_district_key.csv"))
dmsp      <- fread(file.path(data_dir, "dmsp_nightlights.csv"))
viirs     <- fread(file.path(data_dir, "viirs_nightlights.csv"))
pca01     <- fread(file.path(data_dir, "census_2001_pca.csv"))

## ── 2. Aggregate nightlights to district-year ──────────────
cat("=== Aggregating nightlights to district level ===\n")

## Merge village-district key into nightlights
dmsp <- merge(dmsp, dist_key, by = "shrid2", all.x = TRUE)
viirs <- merge(viirs, dist_key, by = "shrid2", all.x = TRUE)

## District-year DMSP aggregation (sum of calibrated light)
dist_dmsp <- dmsp[!is.na(pc11_district_id), .(
  dmsp_light   = sum(light, na.rm = TRUE),
  dmsp_mean    = mean(light, na.rm = TRUE),
  n_villages   = .N
), by = .(pc11_state_id, pc11_district_id, year)]
cat("DMSP district-years:", nrow(dist_dmsp), "\n")

## District-year VIIRS aggregation
dist_viirs <- viirs[!is.na(pc11_district_id), .(
  viirs_light  = sum(light, na.rm = TRUE),
  viirs_mean   = mean(light, na.rm = TRUE),
  n_villages_v = .N
), by = .(pc11_state_id, pc11_district_id, year)]
cat("VIIRS district-years:", nrow(dist_viirs), "\n")

## ── 3. Harmonize DMSP and VIIRS ────────────────────────────
## Strategy: calibrate using 2012–2013 overlap period
## Log-linear regression: log(VIIRS+1) = a + b*log(DMSP+1) + e
## Then predict VIIRS-equivalent for DMSP years

cat("=== Harmonizing DMSP-VIIRS ===\n")

## Merge overlap years (2012, 2013)
overlap <- merge(
  dist_dmsp[year %in% 2012:2013, .(pc11_state_id, pc11_district_id,
                                     year, dmsp_light)],
  dist_viirs[year %in% 2012:2013, .(pc11_state_id, pc11_district_id,
                                      year, viirs_light)],
  by = c("pc11_state_id", "pc11_district_id", "year")
)

## Calibration regression
overlap[, log_dmsp  := log(dmsp_light + 1)]
overlap[, log_viirs := log(viirs_light + 1)]
cal_mod <- lm(log_viirs ~ log_dmsp, data = overlap)
cat("Calibration R²:", summary(cal_mod)$r.squared, "\n")
cat("Coefficients:", coef(cal_mod), "\n")

## Apply calibration to DMSP years
dist_dmsp[, log_dmsp := log(dmsp_light + 1)]
dist_dmsp[, log_viirs_hat := predict(cal_mod,
                                      newdata = data.frame(log_dmsp = log_dmsp))]
dist_dmsp[, harmonized_light := exp(log_viirs_hat) - 1]
dist_dmsp[harmonized_light < 0, harmonized_light := 0]

## Build unified district-year panel
## DMSP (calibrated) for 1994–2011, VIIRS for 2012–2023
panel_dmsp <- dist_dmsp[year <= 2011, .(
  pc11_state_id, pc11_district_id, year,
  light = harmonized_light,
  source = "DMSP_calibrated",
  n_villages
)]

panel_viirs <- dist_viirs[year >= 2012, .(
  pc11_state_id, pc11_district_id, year,
  light = viirs_light,
  source = "VIIRS",
  n_villages = n_villages_v
)]

panel <- rbindlist(list(panel_dmsp, panel_viirs))
setkey(panel, pc11_state_id, pc11_district_id, year)
cat("Unified panel:", nrow(panel), "district-years\n")
cat("Year range:", panel[, paste(range(year), collapse = "-")], "\n")

## ── 4. Merge treatment assignment ──────────────────────────
panel <- merge(panel, phase_dt[, .(pc11_state_id, pc11_district_id,
                                    mgnrega_phase, treat_year,
                                    backwardness_idx, national_rank,
                                    sc_st_share, ag_labor_share,
                                    illiteracy_rate, pop)],
               by = c("pc11_state_id", "pc11_district_id"),
               all.x = TRUE)

## Create treatment indicator
panel[, treated := as.integer(year >= treat_year)]

## Create district numeric ID for panel FE
panel[, dist_id := as.integer(factor(
  paste(pc11_state_id, pc11_district_id, sep = "_")
))]

## Event time (relative to treatment year)
panel[, event_time := year - treat_year]

## Log outcome
panel[, log_light := log(light + 1)]

## Phase labels
panel[, phase_label := factor(
  ifelse(mgnrega_phase == 1, "Phase I",
    ifelse(mgnrega_phase == 2, "Phase II", "Phase III")),
  levels = c("Phase I", "Phase II", "Phase III")
)]

## ── 5. Construct baseline covariates ───────────────────────
## Quartiles of baseline characteristics for heterogeneity
panel[, sc_st_q := cut(sc_st_share,
                        breaks = quantile(sc_st_share, c(0, .25, .5, .75, 1),
                                          na.rm = TRUE),
                        labels = c("Q1", "Q2", "Q3", "Q4"),
                        include.lowest = TRUE)]
panel[, ag_labor_q := cut(ag_labor_share,
                           breaks = quantile(ag_labor_share, c(0, .25, .5, .75, 1),
                                             na.rm = TRUE),
                           labels = c("Q1", "Q2", "Q3", "Q4"),
                           include.lowest = TRUE)]
panel[, lit_q := cut(1 - illiteracy_rate,
                      breaks = quantile(1 - illiteracy_rate, c(0, .25, .5, .75, 1),
                                        na.rm = TRUE),
                      labels = c("Q1", "Q2", "Q3", "Q4"),
                      include.lowest = TRUE)]

## ── 6. Also build DMSP-only and VIIRS-only panels ─────────
## For sensor-specific robustness checks

panel_dmsp_only <- dist_dmsp[, .(
  pc11_state_id, pc11_district_id, year,
  light = dmsp_light,
  log_light = log(dmsp_light + 1),
  n_villages
)]
panel_dmsp_only <- merge(panel_dmsp_only,
                          phase_dt[, .(pc11_state_id, pc11_district_id,
                                       mgnrega_phase, treat_year,
                                       backwardness_idx, pop)],
                          by = c("pc11_state_id", "pc11_district_id"),
                          all.x = TRUE)
panel_dmsp_only[, treated := as.integer(year >= treat_year)]
panel_dmsp_only[, event_time := year - treat_year]
panel_dmsp_only[, dist_id := as.integer(factor(
  paste(pc11_state_id, pc11_district_id, sep = "_")
))]

panel_viirs_only <- dist_viirs[, .(
  pc11_state_id, pc11_district_id, year,
  light = viirs_light,
  log_light = log(viirs_light + 1),
  n_villages = n_villages_v
)]
panel_viirs_only <- merge(panel_viirs_only,
                           phase_dt[, .(pc11_state_id, pc11_district_id,
                                        mgnrega_phase, treat_year,
                                        backwardness_idx, pop)],
                           by = c("pc11_state_id", "pc11_district_id"),
                           all.x = TRUE)
panel_viirs_only[, treated := as.integer(year >= treat_year)]
panel_viirs_only[, event_time := year - treat_year]
panel_viirs_only[, dist_id := as.integer(factor(
  paste(pc11_state_id, pc11_district_id, sep = "_")
))]

## ── 7. Save ────────────────────────────────────────────────
fwrite(panel, file.path(data_dir, "district_year_panel.csv"))
cat("Saved: district_year_panel.csv (", nrow(panel), "obs)\n")

fwrite(panel_dmsp_only, file.path(data_dir, "panel_dmsp_only.csv"))
cat("Saved: panel_dmsp_only.csv (", nrow(panel_dmsp_only), "obs)\n")

fwrite(panel_viirs_only, file.path(data_dir, "panel_viirs_only.csv"))
cat("Saved: panel_viirs_only.csv (", nrow(panel_viirs_only), "obs)\n")

## Summary statistics
cat("\n=== Panel Summary ===\n")
cat("Districts:", panel[, uniqueN(dist_id)], "\n")
cat("Years:", panel[, paste(range(year), collapse = "-")], "\n")
cat("Phase distribution:\n")
print(panel[year == 2006, .N, by = phase_label][order(phase_label)])
cat("\nMean log(light+1) by phase and period:\n")
print(panel[, .(mean_log_light = mean(log_light, na.rm = TRUE)),
            by = .(phase_label, period = ifelse(year < 2007, "Pre",
                                          ifelse(year <= 2013, "Mid", "Late")))])

cat("\n=== Data cleaning complete ===\n")
