## ============================================================================
## 04_robustness.R — Robustness checks and falsification tests
## apep_0467: Priced Out of Care
##
## Tests:
##   1. Region × month FE
##   2. Alternative wage measures
##   3. Placebo: behavioral health providers (H-codes)
##   4. Pre-trend balance test
##   5. Randomization inference
##   6. Wild cluster bootstrap
##   7. Leave-one-out (jackknife states)
##   8. Dropping March-May 2020 (acute lockdown)
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
wage_ratio <- readRDS(file.path(DATA, "state_wage_ratio.rds"))

## ============================================================
## 1. Region × Month Fixed Effects
## ============================================================
cat("\n=== Robustness 1: Region × Month FE ===\n")

# Assign Census region
region_map <- data.table(
  state = c("CT","ME","MA","NH","RI","VT","NJ","NY","PA",
            "IN","IL","MI","OH","WI","IA","KS","MN","MO","NE","ND","SD",
            "DE","DC","FL","GA","MD","NC","SC","VA","WV","AL","KY","MS","TN",
            "AR","LA","OK","TX",
            "AZ","CO","ID","MT","NV","NM","UT","WY",
            "AK","CA","HI","OR","WA"),
  region = c(rep("NE", 9), rep("MW", 12), rep("S", 17), rep("W", 13))
)
panel <- merge(panel, region_map, by = "state", all.x = TRUE)

# Create region × month interaction
panel[, region_month := interaction(region, month_date, drop = TRUE)]

rob_region <- feols(
  log_providers ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + region_month,
  data = panel[!is.na(region)],
  cluster = ~state
)
cat("Region × month FE:\n")
summary(rob_region)


## ============================================================
## 2. Alternative Wage Measures
## ============================================================
cat("\n=== Robustness 2: Alternative Wage Measures ===\n")

# Wage LEVEL instead of ratio
panel[, pca_wage_x_post := pca_wage * post_covid]
rob_level <- feols(
  log_providers ~ pca_wage_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)
cat("PCA wage level × post:\n")
summary(rob_level)

# Outside wage level
panel[, outside_wage_x_post := outside_wage * post_covid]
rob_outside <- feols(
  log_providers ~ outside_wage_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)
cat("Outside wage level × post:\n")
summary(rob_outside)


## ============================================================
## 3. Placebo: Behavioral Health Providers (H-codes)
## ============================================================
cat("\n=== Robustness 3: Behavioral Health Placebo ===\n")

# Build behavioral health panel from T-MSIS
tmsis_ds <- open_dataset(file.path(SHARED_DATA, "tmsis.parquet"))
nppes <- as.data.table(read_parquet(file.path(SHARED_DATA, "nppes_extract.parquet"),
                                    col_select = c("npi", "state")))
nppes[, npi := as.character(npi)]
nppes <- nppes[!is.na(state) & state %in% c(state.abb, "DC")]
nppes <- nppes[!duplicated(npi)]

bh_monthly <- tmsis_ds |>
  filter(substr(HCPCS_CODE, 1, 1) == "H") |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(bh_monthly, c("BILLING_PROVIDER_NPI_NUM", "CLAIM_FROM_MONTH"),
         c("billing_npi", "month_str"))

bh_monthly <- merge(bh_monthly, nppes, by.x = "billing_npi", by.y = "npi", all.x = TRUE)
bh_monthly <- bh_monthly[!is.na(state)]
bh_monthly[, month_date := as.Date(paste0(month_str, "-01"))]

panel_bh <- bh_monthly[, .(
  bh_providers = uniqueN(billing_npi),
  bh_paid = sum(total_paid),
  bh_beneficiaries = sum(total_beneficiaries)
), by = .(state, month_date)]

panel_bh[, `:=`(
  log_bh_providers = log(bh_providers + 1),
  log_bh_beneficiaries = log(bh_beneficiaries + 1)
)]

# Merge wage ratio and time variables
panel_bh <- merge(panel_bh, wage_ratio[, .(state, wage_ratio)], by = "state", all.x = TRUE)
panel_bh[, post_covid := as.integer(month_date >= as.Date("2020-03-01"))]
panel_bh[, wage_ratio_x_post := wage_ratio * post_covid]
panel_bh <- panel_bh[!is.na(wage_ratio)]

# Truncate to match main panel (drop Dec 2024 — reporting lag artifact)
panel_bh <- panel_bh[month_date < as.Date("2024-12-01")]

# Placebo: wage ratio should NOT predict BH disruption (telehealth-eligible)
placebo_bh <- feols(
  log_bh_providers ~ wage_ratio_x_post | state + month_date,
  data = panel_bh,
  cluster = ~state
)
cat("Behavioral health placebo:\n")
summary(placebo_bh)

saveRDS(panel_bh, file.path(DATA, "panel_bh.rds"))
rm(bh_monthly)
gc()


## ============================================================
## 4. Pre-Trend Balance Test
## ============================================================
cat("\n=== Robustness 4: Pre-Trend Balance ===\n")

# Test: Is the wage ratio correlated with pre-COVID trends?
pre_panel <- panel[post_covid == 0]
pre_panel[, time_trend := as.numeric(month_date - min(month_date)) / 365]
pre_panel[, ratio_x_trend := wage_ratio * time_trend]

pretrend_test <- feols(
  log_providers ~ ratio_x_trend | state + month_date,
  data = pre_panel,
  cluster = ~state
)
cat("Pre-trend test (ratio × time trend, pre-COVID only):\n")
summary(pretrend_test)


## ============================================================
## 5. Randomization Inference
## ============================================================
cat("\n=== Robustness 5: Randomization Inference ===\n")

set.seed(42)
N_PERM <- 5000

# Main estimate
main_coef <- coef(feols(
  log_providers ~ wage_ratio_x_post | state + month_date,
  data = panel, cluster = ~state
))["wage_ratio_x_post"]

# Permute wage ratio across states
states <- unique(panel$state)
perm_coefs <- numeric(N_PERM)

for (i in seq_len(N_PERM)) {
  # Randomly reassign wage ratios to states
  perm_map <- data.table(
    state = states,
    perm_ratio = sample(wage_ratio[state %in% states]$wage_ratio)
  )
  panel_perm <- merge(panel[, !c("wage_ratio"), with = FALSE],
                      perm_map, by = "state", all.x = TRUE)
  panel_perm[, perm_x_post := perm_ratio * post_covid]

  tryCatch({
    m <- feols(log_providers ~ perm_x_post | state + month_date,
               data = panel_perm, cluster = ~state)
    perm_coefs[i] <- coef(m)["perm_x_post"]
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })

  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, N_PERM))
}

# RI p-value
ri_pvalue <- mean(abs(perm_coefs) >= abs(main_coef), na.rm = TRUE)
cat(sprintf("\nRandomization Inference:\n"))
cat(sprintf("  Main coefficient: %.4f\n", main_coef))
cat(sprintf("  RI p-value (two-sided): %.4f\n", ri_pvalue))
cat(sprintf("  Permutations: %d\n", sum(!is.na(perm_coefs))))

saveRDS(list(main_coef = main_coef, perm_coefs = perm_coefs, ri_pvalue = ri_pvalue),
        file.path(DATA, "ri_results.rds"))


## ============================================================
## 6. Wild Cluster Bootstrap
## ============================================================
cat("\n=== Robustness 6: Wild Cluster Bootstrap ===\n")

# Use fwildclusterboot if available, otherwise manual implementation
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  # Fit OLS model (fwildclusterboot needs lm/felm object)
  panel[, state_factor := factor(state)]
  panel[, month_factor := factor(month_date)]

  boot_model <- feols(
    log_providers ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date,
    data = panel
  )

  boot_result <- tryCatch({
    boottest(boot_model, param = "wage_ratio_x_post",
             B = 999, clustid = ~state, type = "webb")
  }, error = function(e) {
    cat(sprintf("  Bootstrap failed: %s\n", e$message))
    NULL
  })

  if (!is.null(boot_result)) {
    cat("Wild cluster bootstrap result:\n")
    print(summary(boot_result))
  }
} else {
  cat("fwildclusterboot not installed. Using standard cluster SEs.\n")
}


## ============================================================
## 7. Leave-One-Out (Jackknife States)
## ============================================================
cat("\n=== Robustness 7: Leave-One-Out ===\n")

loo_coefs <- numeric(length(states))
names(loo_coefs) <- states

for (st in states) {
  m <- feols(
    log_providers ~ wage_ratio_x_post | state + month_date,
    data = panel[state != st],
    cluster = ~state
  )
  loo_coefs[st] <- coef(m)["wage_ratio_x_post"]
}

cat(sprintf("LOO coefficient range: [%.4f, %.4f]\n",
            min(loo_coefs), max(loo_coefs)))
cat(sprintf("Most influential state (when dropped, biggest change): %s\n",
            names(which.max(abs(loo_coefs - main_coef)))))

saveRDS(loo_coefs, file.path(DATA, "loo_results.rds"))


## ============================================================
## 8. Dropping March-May 2020 (Acute Lockdown Period)
## ============================================================
cat("\n=== Robustness 8: Excluding Acute Lockdown ===\n")

panel_no_lockdown <- panel[!(month_date >= as.Date("2020-03-01") &
                              month_date <= as.Date("2020-05-31"))]

rob_no_lockdown <- feols(
  log_providers ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel_no_lockdown,
  cluster = ~state
)
cat("Excluding March-May 2020:\n")
summary(rob_no_lockdown)


## ============================================================
## 9. State-Specific Linear Trends
## ============================================================
cat("\n=== Robustness 9: State-Specific Linear Trends ===\n")

panel[, time_numeric := as.numeric(month_date - min(month_date)) / 365]
panel[, state_trend := interaction(state, time_numeric, drop = FALSE)]

rob_state_trends <- feols(
  log_providers ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date + state[time_numeric],
  data = panel,
  cluster = ~state
)
cat("State-specific linear trends:\n")
summary(rob_state_trends)


## ============================================================
## 10. Joint Pre-Period Test
## ============================================================
cat("\n=== Robustness 10: Joint Pre-Period Event Study Test ===\n")

# Compute event study model directly
panel[, event_time := as.numeric(difftime(month_date, as.Date("2020-01-01"), units = "days")) / 30.44]
panel[, event_time := round(event_time)]
# Interaction of wage ratio with event-time dummies (drop k=0 reference)
panel[, wage_ratio_x_k := wage_ratio * factor(event_time)]
es_model <- feols(
  log_providers ~ i(event_time, wage_ratio, ref = 0) | state + month_date,
  data = panel,
  cluster = ~state
)

# Extract pre-period coefficients
es_coefs <- coef(es_model)
es_vcov <- vcov(es_model)
pre_names <- grep("event_time::-", names(es_coefs), value = TRUE)

if (length(pre_names) > 0) {
  pre_coefs <- es_coefs[pre_names]
  pre_vcov <- es_vcov[pre_names, pre_names]
  # Wald test: joint significance of pre-period coefficients
  wald_stat <- as.numeric(t(pre_coefs) %*% solve(pre_vcov) %*% pre_coefs)
  wald_df <- length(pre_coefs)
  wald_pval <- 1 - pchisq(wald_stat, df = wald_df)
  cat(sprintf("Joint pre-period Wald test: chi2(%d) = %.3f, p = %.4f\n",
              wald_df, wald_stat, wald_pval))
} else {
  cat("No pre-period event-study coefficients found.\n")
  wald_stat <- NA; wald_df <- NA; wald_pval <- NA
}


## ============================================================
## 11. HonestDiD Sensitivity (Rambachan-Roth)
## ============================================================
cat("\n=== Robustness 11: HonestDiD Sensitivity ===\n")

honest_result <- tryCatch({
  library(HonestDiD)

  # Use the event study estimates for HonestDiD
  es_all_names <- grep("event_time::", names(es_coefs), value = TRUE)
  es_ordered <- sort(es_all_names)
  # Separate pre and post (excluding reference k=0)
  pre_es <- grep("::-", es_ordered, value = TRUE)
  post_es <- grep("::[0-9]", es_ordered, value = TRUE)
  post_es <- setdiff(post_es, grep("::0$", post_es, value = TRUE))

  # Need consecutive pre-period and post-period
  betahat <- es_coefs[c(pre_es, post_es)]
  sigma <- es_vcov[c(pre_es, post_es), c(pre_es, post_es)]
  numPrePeriods <- length(pre_es)
  numPostPeriods <- length(post_es)

  if (numPrePeriods >= 2 && numPostPeriods >= 1) {
    # Relative magnitudes approach
    honest <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = numPrePeriods,
      numPostPeriods = numPostPeriods,
      Mbarvec = seq(0, 2, by = 0.5)
    )
    cat("HonestDiD Relative Magnitudes sensitivity:\n")
    print(honest)
    honest
  } else {
    cat(sprintf("Not enough periods: %d pre, %d post\n", numPrePeriods, numPostPeriods))
    NULL
  }
}, error = function(e) {
  cat(sprintf("HonestDiD failed: %s\n", e$message))
  NULL
})


## ============================================================
## Save All Robustness Results
## ============================================================

rob_results <- list(
  region_month = rob_region,
  wage_level = rob_level,
  outside_level = rob_outside,
  placebo_bh = placebo_bh,
  pretrend = pretrend_test,
  ri = list(main_coef = main_coef, perm_coefs = perm_coefs, ri_pvalue = ri_pvalue),
  loo = loo_coefs,
  no_lockdown = rob_no_lockdown,
  state_trends = rob_state_trends,
  joint_pretest = list(wald_stat = wald_stat, wald_df = wald_df, wald_pval = wald_pval),
  honest_did = honest_result
)

saveRDS(rob_results, file.path(DATA, "robustness_results.rds"))
cat("\n=== All robustness results saved ===\n")
