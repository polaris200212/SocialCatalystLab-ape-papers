## ============================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir  <- "../tables"

panel      <- fread(file.path(data_dir, "district_year_panel.csv"))
panel_dmsp <- fread(file.path(data_dir, "panel_dmsp_only.csv"))
panel_viirs <- fread(file.path(data_dir, "panel_viirs_only.csv"))

panel[, first_treat := treat_year]

## ════════════════════════════════════════════════════════════
## 1. Goodman-Bacon Decomposition
## ════════════════════════════════════════════════════════════

cat("\n=== Bacon Decomposition ===\n")

## Need balanced panel for bacondecomp
## Restrict to common years across all districts
year_range <- panel[, .(min_y = min(year), max_y = max(year)), by = dist_id]
common_years <- year_range[, max(min_y)]:year_range[, min(max_y)]
panel_bal <- panel[year %in% common_years]

## Create binary treatment (ever treated by year)
## bacondecomp needs: Y ~ D, unit, time
bacon_df <- as.data.frame(panel_bal[, .(
  log_light, treated, dist_id, year
)])

bacon_out <- tryCatch({
  bacon(log_light ~ treated, data = bacon_df,
        id_var = "dist_id", time_var = "year")
}, error = function(e) {
  cat("Bacon decomposition error:", e$message, "\n")
  NULL
})

if (!is.null(bacon_out)) {
  cat("Bacon decomposition complete.\n")
  cat("Overall TWFE estimate:",
      sum(bacon_out$estimate * bacon_out$weight), "\n")
  cat("\nDecomposition by type:\n")
  bacon_summary <- aggregate(
    cbind(weight, estimate) ~ type,
    data = bacon_out, FUN = function(x) round(sum(x), 4)
  )
  print(bacon_summary)
  saveRDS(bacon_out, file.path(tab_dir, "bacon_decomp.rds"))
}

## ════════════════════════════════════════════════════════════
## 2. DMSP-Only Analysis (avoids sensor harmonization issues)
## ════════════════════════════════════════════════════════════

cat("\n=== DMSP-Only Analysis (1994-2013) ===\n")

panel_dmsp[, first_treat := treat_year]

twfe_dmsp <- feols(log_light ~ i(event_time, ref = -1) | dist_id + year,
                    data = panel_dmsp[event_time >= -12 & event_time <= 7],
                    cluster = ~dist_id)
cat("DMSP-only event study:\n")
print(summary(twfe_dmsp))
saveRDS(twfe_dmsp, file.path(tab_dir, "twfe_dmsp_only.rds"))

## ════════════════════════════════════════════════════════════
## 3. VIIRS-Only Analysis (higher resolution, no top-coding)
## ════════════════════════════════════════════════════════════

cat("\n=== VIIRS-Only Analysis (2012-2023) ===\n")

## All districts are treated by 2012 (Phase III started 2009).
## Compare Phase I (treated 6+ years) vs Phase III (treated 4+ years)
## using years of exposure as treatment intensity.
panel_viirs[, first_treat := treat_year]
panel_viirs[, years_exposed := year - treat_year]

## Phase I dummy (early treated)
panel_viirs[, phase1 := as.integer(mgnrega_phase == 1)]

## Phase I vs Phase III only — compare treatment duration effects
pv_p1p3 <- panel_viirs[mgnrega_phase %in% c(1, 3)]
twfe_viirs <- feols(log_light ~ phase1:years_exposed | dist_id + year,
                     data = pv_p1p3, cluster = ~dist_id)
cat("VIIRS-only (Phase I vs III, exposure interaction):\n")
print(summary(twfe_viirs))
saveRDS(twfe_viirs, file.path(tab_dir, "twfe_viirs_only.rds"))

## ════════════════════════════════════════════════════════════
## 4. District-Specific Linear Trends
## ════════════════════════════════════════════════════════════

cat("\n=== District-Specific Trends ===\n")

twfe_trends <- feols(log_light ~ treated | dist_id[year] + year,
                      data = panel, cluster = ~dist_id)
cat("TWFE with district-specific trends:\n")
print(summary(twfe_trends))
saveRDS(twfe_trends, file.path(tab_dir, "twfe_dist_trends.rds"))

## ════════════════════════════════════════════════════════════
## 5. Placebo Test: Fake Treatment Dates
## ════════════════════════════════════════════════════════════

cat("\n=== Placebo Tests ===\n")

## Placebo 1: Shift treatment back 5 years (all pre-MGNREGA)
panel_placebo <- copy(panel)
panel_placebo[, placebo_treat := as.integer(year >= (treat_year - 5))]
panel_placebo_pre <- panel_placebo[year < 2006]  # Only pre-MGNREGA years

twfe_placebo <- feols(log_light ~ placebo_treat | dist_id + year,
                       data = panel_placebo_pre, cluster = ~dist_id)
cat("Placebo (shifted 5 years back, pre-period only):\n")
print(summary(twfe_placebo))
saveRDS(twfe_placebo, file.path(tab_dir, "twfe_placebo.rds"))

## Placebo 2: Randomization inference
## Permute phase assignment 500 times, re-estimate
set.seed(42)
n_perms <- 500
dist_ids <- panel[year == 2000, .(dist_id, first_treat)]
ri_coefs <- numeric(n_perms)

cat("Running randomization inference (", n_perms, "permutations)...\n")
for (i in seq_len(n_perms)) {
  ## Shuffle treatment years across districts
  perm_treats <- sample(dist_ids$first_treat)
  panel_ri <- copy(panel)
  panel_ri[, perm_treat_year := perm_treats[match(dist_id, dist_ids$dist_id)]]
  panel_ri[, perm_treated := as.integer(year >= perm_treat_year)]

  mod_ri <- feols(log_light ~ perm_treated | dist_id + year,
                   data = panel_ri, cluster = ~dist_id, warn = FALSE)
  ri_coefs[i] <- coef(mod_ri)["perm_treated"]

  if (i %% 100 == 0) cat("  Permutation", i, "/", n_perms, "\n")
}

## Actual coefficient
actual_coef <- coef(feols(log_light ~ treated | dist_id + year,
                           data = panel, cluster = ~dist_id))["treated"]

ri_pvalue <- mean(abs(ri_coefs) >= abs(actual_coef))
cat("RI p-value:", ri_pvalue, "\n")
cat("Actual coef:", actual_coef, "\n")
cat("RI 95% CI: [", quantile(ri_coefs, 0.025), ",",
    quantile(ri_coefs, 0.975), "]\n")

saveRDS(list(actual = actual_coef, permuted = ri_coefs, pvalue = ri_pvalue),
        file.path(tab_dir, "ri_results.rds"))

## ════════════════════════════════════════════════════════════
## 6. HonestDiD Sensitivity Analysis
## ════════════════════════════════════════════════════════════

cat("\n=== HonestDiD Sensitivity ===\n")

## Run event study for HonestDiD
es_for_honest <- feols(
  log_light ~ i(event_time, ref = -1) | dist_id + year,
  data = panel[event_time >= -5 & event_time <= 15],
  cluster = ~dist_id
)

## Extract coefficients and vcov for HonestDiD
beta_hat <- coef(es_for_honest)
sigma_hat <- vcov(es_for_honest)

## Identify pre and post periods
pre_indices  <- grep("event_time::-", names(beta_hat))
post_indices <- grep("event_time::[0-9]", names(beta_hat))

if (length(pre_indices) >= 2 & length(post_indices) >= 1) {
  honest_result <- tryCatch({
    createSensitivityResults(
      betahat = beta_hat,
      sigma   = sigma_hat,
      numPrePeriods  = length(pre_indices),
      numPostPeriods = length(post_indices),
      Mvec = seq(0, 0.05, by = 0.01)
    )
  }, error = function(e) {
    cat("HonestDiD error:", e$message, "\n")
    NULL
  })

  if (!is.null(honest_result)) {
    cat("HonestDiD results:\n")
    print(honest_result)
    saveRDS(honest_result, file.path(tab_dir, "honest_did.rds"))
  }
} else {
  cat("Insufficient pre/post periods for HonestDiD\n")
}

saveRDS(es_for_honest, file.path(tab_dir, "es_for_honest.rds"))

## ════════════════════════════════════════════════════════════
## 7. Population-Weighted Analysis
## ════════════════════════════════════════════════════════════

cat("\n=== Population-Weighted TWFE ===\n")

twfe_weighted <- feols(log_light ~ treated | dist_id + year,
                        data = panel, cluster = ~dist_id,
                        weights = ~pop)
cat("Population-weighted TWFE:\n")
print(summary(twfe_weighted))
saveRDS(twfe_weighted, file.path(tab_dir, "twfe_pop_weighted.rds"))

## ════════════════════════════════════════════════════════════
## 8. State × Year Fixed Effects (absorb state-level shocks)
## ════════════════════════════════════════════════════════════

cat("\n=== State × Year FE ===\n")

panel[, state_year := paste(pc11_state_id, year, sep = "_")]
twfe_state_year <- feols(log_light ~ treated | dist_id + state_year,
                          data = panel, cluster = ~dist_id)
cat("TWFE with state × year FE:\n")
print(summary(twfe_state_year))
saveRDS(twfe_state_year, file.path(tab_dir, "twfe_state_year.rds"))

cat("\n=== Robustness checks complete ===\n")
