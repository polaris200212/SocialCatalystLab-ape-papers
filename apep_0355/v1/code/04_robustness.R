## ============================================================================
## 04_robustness.R — Robustness checks
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")

rom_panel <- readRDS(file.path(DATA, "rom_panel.rds"))
zip_panel <- readRDS(file.path(DATA, "zip_svc_panel.rds"))
analysis_excl <- readRDS(file.path(DATA, "analysis_exclusions.rds"))
all_excl <- readRDS(file.path(DATA, "all_matched_exclusions.rds"))

rom_panel[rom_paid < 0, rom_paid := 0]
rom_panel[, ln_rom_paid := log(rom_paid + 1)]
rom_panel[, state_month := paste0(state, "_", month_num)]

cat("=== Robustness Checks ===\n")

## ====================================================================
## 1. Pre-trend Test
## ====================================================================
cat("\n--- Pre-trend Joint F-Test ---\n")

es_model <- feols(
  ln_rom_paid ~ i(event_time, ref = -1) | unit_id + state_month,
  data = rom_panel[event_time >= -12 & event_time <= 12],
  cluster = ~unit_id
)

# Joint test of pre-period coefficients
pre_coefs <- grep("event_time::-", names(coef(es_model)), value = TRUE)
if (length(pre_coefs) > 1) {
  pretrend_test <- tryCatch(wald(es_model, pre_coefs), error = function(e) NULL)
  if (!is.null(pretrend_test)) {
    cat("Joint F-test of pre-treatment coefficients:\n")
    print(pretrend_test)
  }
}

## ====================================================================
## 2. Placebo: Different service categories in same ZIP
## ====================================================================
cat("\n--- Placebo: Non-treated services in treated ZIPs ---\n")

# Get untreated service categories in treated ZIPs
treated_zips <- unique(analysis_excl$zip5)
treated_pairs <- unique(paste0(analysis_excl$zip5, "_", analysis_excl$svc_cat))

# Same-ZIP, different-service placebo
placebo_panel <- zip_panel[
  zip5 %in% treated_zips &
  !unit_id %in% treated_pairs &
  treated == FALSE  # These are service categories NOT affected by exclusion
]

# Assign placebo treatment: same timing as the ZIP's actual treatment
first_excl_by_zip <- analysis_excl[, .(
  placebo_excl_num = min(as.integer((year(exclusion_date) - 2018) * 12 + month(exclusion_date)))
), by = zip5]

placebo_panel <- merge(placebo_panel, first_excl_by_zip, by = "zip5", all.x = TRUE)
placebo_panel <- placebo_panel[!is.na(placebo_excl_num)]
placebo_panel[, placebo_post := as.integer(month_num >= placebo_excl_num)]
placebo_panel[!is.finite(ln_paid), ln_paid := 0]

placebo_model <- tryCatch({
  feols(
    ln_paid ~ placebo_post | unit_id + month_num,
    data = placebo_panel,
    cluster = ~unit_id
  )
}, error = function(e) {
  cat("Placebo error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(placebo_model)) {
  cat("Placebo — Non-treated services in treated ZIPs:\n")
  plc_coef <- coef(placebo_model)["placebo_post"]
  plc_se <- se(placebo_model)["placebo_post"]
  plc_pv <- 2 * pnorm(-abs(plc_coef / plc_se))
  cat(sprintf("  β = %.4f (SE = %.4f, p = %.3f)\n", plc_coef, plc_se, plc_pv))
}

saveRDS(placebo_model, file.path(DATA, "placebo_model.rds"))

## ====================================================================
## 3. Market Share Threshold Sensitivity
## ====================================================================
cat("\n--- Threshold Sensitivity ---\n")

threshold_results <- list()
for (thresh in c(0.01, 0.03, 0.05, 0.10, 0.20)) {
  thresh_excl <- all_excl[market_share >= thresh & zip_annual_total >= 1000]

  if (nrow(thresh_excl) < 3) {
    cat(sprintf("  Threshold ≥%.0f%%: %d pairs (too few)\n", 100*thresh, nrow(thresh_excl)))
    next
  }

  thresh_ids <- paste0(thresh_excl$zip5, "_", thresh_excl$svc_cat)
  thresh_rom <- rom_panel[unit_id %in% thresh_ids]

  if (nrow(thresh_rom) < 50) next

  thresh_mod <- tryCatch(
    feols(ln_rom_paid ~ post | unit_id + state_month, data = thresh_rom, cluster = ~unit_id),
    error = function(e) NULL
  )

  if (!is.null(thresh_mod)) {
    t_coef <- coef(thresh_mod)["post"]
    t_se <- se(thresh_mod)["post"]
    t_pv <- 2 * pnorm(-abs(t_coef / t_se))
    threshold_results[[as.character(thresh)]] <- data.table(
      threshold = thresh,
      n_units = length(unique(thresh_ids)),
      coef = t_coef,
      se = t_se,
      pvalue = t_pv
    )
    cat(sprintf("  ≥%.0f%%: N=%d, β=%.4f (%.4f)\n",
                100*thresh, length(unique(thresh_ids)), t_coef, t_se))
  }
}

if (length(threshold_results) > 0) {
  threshold_dt <- rbindlist(threshold_results)
  saveRDS(threshold_dt, file.path(DATA, "threshold_sensitivity.rds"))
}

## ====================================================================
## 4. Randomization Inference
## ====================================================================
cat("\n--- Randomization Inference ---\n")

true_model <- feols(
  ln_rom_paid ~ post | unit_id + state_month,
  data = rom_panel,
  cluster = ~unit_id
)
true_coef <- coef(true_model)["post"]

set.seed(42)
n_perms <- 500
perm_coefs <- numeric(n_perms)

cat(sprintf("Running %d permutations...\n", n_perms))
for (i in seq_len(n_perms)) {
  perm_data <- copy(rom_panel)
  unit_excl <- unique(perm_data[, .(unit_id, excl_month_num)])
  unit_excl[, perm_excl := sample(excl_month_num)]
  perm_data[, excl_month_num := NULL]
  perm_data <- merge(perm_data, unit_excl[, .(unit_id, perm_excl)], by = "unit_id")
  perm_data[, perm_post := as.integer(month_num >= perm_excl)]

  perm_mod <- tryCatch(
    feols(ln_rom_paid ~ perm_post | unit_id + state_month, data = perm_data, cluster = ~unit_id),
    error = function(e) NULL
  )

  if (!is.null(perm_mod)) perm_coefs[i] <- coef(perm_mod)["perm_post"]
  if (i %% 100 == 0) cat(sprintf("  %d/%d\n", i, n_perms))
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(true_coef))
cat(sprintf("RI p-value: %.3f (true β = %.4f)\n", ri_pvalue, true_coef))

saveRDS(list(true_coef = true_coef, perm_coefs = perm_coefs, ri_pvalue = ri_pvalue),
        file.path(DATA, "randomization_inference.rds"))

## ====================================================================
## 5. Anticipation Test
## ====================================================================
cat("\n--- Anticipation Test ---\n")

# Excluded provider's own billing trajectory
rom_panel[, excluded_paid := total_paid_all - rom_paid]
rom_panel[excluded_paid < 0, excluded_paid := 0]
rom_panel[, ln_excluded := log(excluded_paid + 1)]

es_antic <- tryCatch(
  feols(ln_excluded ~ i(event_time, ref = -1) | unit_id + state_month,
        data = rom_panel[event_time >= -12 & event_time <= 6],
        cluster = ~unit_id),
  error = function(e) NULL
)

if (!is.null(es_antic)) {
  cat("Excluded provider billing trajectory:\n")
  print(summary(es_antic))
}

saveRDS(es_antic, file.path(DATA, "anticipation_model.rds"))

## ====================================================================
## 6. HonestDiD
## ====================================================================
cat("\n--- HonestDiD ---\n")

honest_result <- tryCatch({
  es_honest <- feols(
    ln_rom_paid ~ i(event_time, ref = -1) | unit_id + state_month,
    data = rom_panel[event_time >= -6 & event_time <= 6],
    cluster = ~unit_id
  )

  beta_hat <- coef(es_honest)
  sigma_hat <- vcov(es_honest)
  pre_idx <- grep("event_time::-", names(beta_hat))
  post_idx <- grep("event_time::[0-9]", names(beta_hat))

  if (length(pre_idx) >= 2 & length(post_idx) >= 1) {
    HonestDiD::createSensitivityResults(
      betahat = beta_hat,
      sigma = sigma_hat,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 2, by = 0.5)
    )
  }
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
  NULL
})

saveRDS(honest_result, file.path(DATA, "honestdid_results.rds"))

cat("\n=== Robustness complete ===\n")
