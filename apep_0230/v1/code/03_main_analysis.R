## 03_main_analysis.R - Primary DiD estimation
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("Panel loaded:", nrow(panel), "obs,", n_distinct(panel$district), "districts\n")

## ─────────────────────────────────────────────────────────────
## 1. TWFE baseline (for comparison / bias illustration)
## ─────────────────────────────────────────────────────────────

twfe_baseline <- feols(
  log_median_price ~ treated | district + year,
  data = panel,
  cluster = ~district
)

cat("\n=== TWFE Baseline ===\n")
summary(twfe_baseline)

## TWFE event study
panel <- panel %>%
  mutate(
    rel_year = ifelse(first_treat > 0, year - first_treat, NA_integer_)
  )

## Bin endpoints
panel <- panel %>%
  mutate(
    rel_year_binned = case_when(
      is.na(rel_year) ~ NA_integer_,
      rel_year < -5 ~ -5L,
      rel_year > 8 ~ 8L,
      TRUE ~ as.integer(rel_year)
    )
  )

twfe_es <- feols(
  log_median_price ~ i(rel_year_binned, ref = -1) | district + year,
  data = panel %>% filter(!is.na(rel_year_binned) | first_treat == 0),
  cluster = ~district
)

cat("\n=== TWFE Event Study ===\n")
summary(twfe_es)

## ─────────────────────────────────────────────────────────────
## 2. Callaway-Sant'Anna (2021) - Main specification
## ─────────────────────────────────────────────────────────────

cat("\n=== Callaway-Sant'Anna Estimation ===\n")
cat("This may take a few minutes...\n")

cs_out <- att_gt(
  yname = "log_median_price",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)

cat("\nGroup-time ATTs computed.\n")

## Aggregate to simple ATT
cs_simple <- aggte(cs_out, type = "simple")
cat("\n=== Simple ATT ===\n")
summary(cs_simple)

## Aggregate to event-study
cs_es <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 8)
cat("\n=== Dynamic ATT (Event Study) ===\n")
summary(cs_es)

## Aggregate by group (cohort)
cs_group <- aggte(cs_out, type = "group")
cat("\n=== Group-level ATT ===\n")
summary(cs_group)

## Aggregate by calendar time
cs_calendar <- aggte(cs_out, type = "calendar")
cat("\n=== Calendar-time ATT ===\n")
summary(cs_calendar)

## ─────────────────────────────────────────────────────────────
## 3. CS with never-treated controls (robustness)
## ─────────────────────────────────────────────────────────────

cs_never <- att_gt(
  yname = "log_median_price",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)

cs_never_simple <- aggte(cs_never, type = "simple")
cs_never_es <- aggte(cs_never, type = "dynamic", min_e = -5, max_e = 8)

cat("\n=== CS with Never-Treated Controls ===\n")
summary(cs_never_simple)

## ─────────────────────────────────────────────────────────────
## 4. TWFE with controls (price level and transactions)
## ─────────────────────────────────────────────────────────────

twfe_controls <- feols(
  log_median_price ~ treated + log(n_transactions) | district + year,
  data = panel,
  cluster = ~district
)

cat("\n=== TWFE with Controls ===\n")
summary(twfe_controls)

## ─────────────────────────────────────────────────────────────
## 5. Save all results
## ─────────────────────────────────────────────────────────────

results <- list(
  twfe_baseline = twfe_baseline,
  twfe_es = twfe_es,
  twfe_controls = twfe_controls,
  cs_out = cs_out,
  cs_simple = cs_simple,
  cs_es = cs_es,
  cs_group = cs_group,
  cs_calendar = cs_calendar,
  cs_never = cs_never,
  cs_never_simple = cs_never_simple,
  cs_never_es = cs_never_es
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\nAll main results saved.\n")
