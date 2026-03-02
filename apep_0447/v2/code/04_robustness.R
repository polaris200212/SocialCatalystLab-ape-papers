## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## v2 revision: WS4 — RI on claims, 5000 perms, wild cluster bootstrap
## ============================================================================

source("00_packages.R")

DATA <- "../data"
panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
panel_all <- readRDS(file.path(DATA, "panel_all_analysis.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

cat("=== Robustness Checks ===\n\n")

# Ensure factor coding
panel[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

## ---- 1. Binary treatment (above/below median stringency) ----
cat("--- R1: Binary Treatment (Median Split) ---\n")
med_stringency <- median(state_treatment$peak_stringency, na.rm = TRUE)
panel[, high_stringency := as.integer(peak_stringency > med_stringency)]

r1_binary <- feols(
  log_paid ~ high_stringency:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(r1_binary)

## ---- 2. Cumulative stringency ----
cat("\n--- R2: Cumulative Stringency (Mar-Jun 2020) ---\n")
r2_cumul <- feols(
  log_paid ~ cum_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(r2_cumul)

## ---- 3. Exclude never-lockdown states ----
cat("\n--- R3: Exclude Never-Lockdown States ---\n")
never_lockdown <- state_treatment[never_treated == TRUE]$state
panel_lockdown_only <- panel[!(state %in% never_lockdown)]
cat(sprintf("Excluding %d never-lockdown states: %s\n",
            length(never_lockdown), paste(never_lockdown, collapse = ", ")))

r3_no_never <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_lockdown_only,
  cluster = ~state_f
)
summary(r3_no_never)

## ---- 4. Placebo: Pre-period (treat March 2019) ----
cat("\n--- R4: Placebo Test (Fake Treatment March 2019) ---\n")
panel_pre <- panel[month_date < as.Date("2020-03-01")]
panel_pre[, placebo_post := as.integer(month_date >= as.Date("2019-04-01"))]

r4_placebo <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:placebo_post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_pre,
  cluster = ~state_f
)
cat("Placebo DDD (should be null):\n")
summary(r4_placebo)

## ---- 5. Alternative comparison: CPT professional services ----
cat("\n--- R5: Alternative Comparison Group (CPT Professional) ---\n")

tmsis_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "tmsis.parquet")
nppes_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "nppes_extract.parquet")

tmsis_ds <- open_dataset(tmsis_path)
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
us_states <- c(state.abb, "DC")
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2 & state %in% us_states,
                   .(npi, state)]

cat("Building HCBS vs CPT panel...\n")

# Use clean HCBS codes for the CPT comparison too
clean_hcbs_codes <- c("T1019","T1020","T2016","T2017","T2022","T2025",
                       "T2028","T2033","T2034","T2036","T1005")

alt_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    service_type = case_when(
      HCPCS_CODE %in% clean_hcbs_codes ~ "HCBS",
      hcpcs_prefix %in% c("0","1","2","3","4","5","6","7","8","9") ~ "CPT",
      TRUE ~ NA_character_
    ),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  filter(!is.na(service_type)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, year, month_num, service_type) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(alt_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
alt_monthly <- merge(alt_monthly, npi_state, by.x = "billing_npi", by.y = "npi", all.x = FALSE)

alt_panel <- alt_monthly[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, service_type, year, month_num, CLAIM_FROM_MONTH)]

alt_panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
alt_panel <- alt_panel[month_date != as.Date("2020-03-01")]

alt_panel <- merge(alt_panel, state_treatment[, .(state, peak_stringency)], by = "state", all.x = TRUE)
alt_panel[, `:=`(
  post = as.integer(month_date >= as.Date("2020-04-01")),
  is_hcbs = as.integer(service_type == "HCBS"),
  log_paid = log(total_paid + 1),
  peak_stringency_std = peak_stringency / 100,
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

r5_cpt <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = alt_panel,
  cluster = ~state_f
)
cat("DDD with CPT as comparison (instead of BH):\n")
summary(r5_cpt)

rm(alt_monthly, alt_panel)
gc()

## ---- 6. Randomization inference — 5000 permutations (WS4) ----
cat("\n--- R6: Randomization Inference (5000 permutations) ---\n")

set.seed(42)
n_perms <- 5000

# Get actual coefficients for both log_paid and log_claims
actual_coef_paid <- coef(feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel, cluster = ~state_f
))

actual_coef_claims <- coef(feols(
  log_claims ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel, cluster = ~state_f
))

states_in_data <- unique(panel$state)
cat(sprintf("Running %d permutations of stringency across %d states...\n",
            n_perms, length(states_in_data)))

perm_coefs_paid <- numeric(n_perms)
perm_coefs_claims <- numeric(n_perms)

for (i in 1:n_perms) {
  if (i %% 500 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))

  perm_map <- data.table(
    state = states_in_data,
    perm_stringency = sample(panel[!duplicated(state), peak_stringency_std])
  )

  panel_perm <- merge(panel, perm_map, by = "state")

  tryCatch({
    m_perm_paid <- feols(
      log_paid ~ perm_stringency:is_hcbs:post |
        state_f^service_f + service_f^month_f + state_f^month_f,
      data = panel_perm, cluster = ~state_f
    )
    perm_coefs_paid[i] <- coef(m_perm_paid)

    m_perm_claims <- feols(
      log_claims ~ perm_stringency:is_hcbs:post |
        state_f^service_f + service_f^month_f + state_f^month_f,
      data = panel_perm, cluster = ~state_f
    )
    perm_coefs_claims[i] <- coef(m_perm_claims)
  }, error = function(e) {
    perm_coefs_paid[i] <<- NA
    perm_coefs_claims[i] <<- NA
  })
}

perm_coefs_paid_valid <- perm_coefs_paid[!is.na(perm_coefs_paid)]
perm_coefs_claims_valid <- perm_coefs_claims[!is.na(perm_coefs_claims)]

ri_p_paid <- mean(abs(perm_coefs_paid_valid) >= abs(actual_coef_paid))
ri_p_claims <- mean(abs(perm_coefs_claims_valid) >= abs(actual_coef_claims))

cat(sprintf("\nRI p-value (log_paid): %.4f (based on %d valid permutations)\n",
            ri_p_paid, length(perm_coefs_paid_valid)))
cat(sprintf("Actual coefficient (log_paid): %.4f\n", actual_coef_paid))

cat(sprintf("\nRI p-value (log_claims): %.4f (based on %d valid permutations)\n",
            ri_p_claims, length(perm_coefs_claims_valid)))
cat(sprintf("Actual coefficient (log_claims): %.4f\n", actual_coef_claims))

## ---- 7. Wild Cluster Bootstrap (WS4) ----
cat("\n--- R7: Wild Cluster Bootstrap ---\n")

if (wcb_available) {
  cat("Running wild cluster bootstrap with fwildclusterboot...\n")

  # Need to create the interaction variable manually for boottest
  panel[, ddd_interact := peak_stringency_std * is_hcbs * post]

  # Refit with explicit interaction variable
  m_wcb_base <- feols(
    log_claims ~ ddd_interact |
      state_f^service_f + service_f^month_f + state_f^month_f,
    data = panel,
    cluster = ~state_f
  )

  tryCatch({
    wcb_result <- boottest(
      m_wcb_base,
      param = "ddd_interact",
      B = 9999,
      clustid = "state_f",
      type = "rademacher"
    )
    cat("Wild cluster bootstrap result:\n")
    print(summary(wcb_result))

    wcb_pvalue <- pvalue(wcb_result)
    wcb_ci <- confint(wcb_result)
    cat(sprintf("WCB p-value: %.4f\n", wcb_pvalue))
    cat(sprintf("WCB 95%% CI: [%.3f, %.3f]\n", wcb_ci[1], wcb_ci[2]))
  }, error = function(e) {
    cat(sprintf("WCB failed: %s\n", e$message))
    wcb_pvalue <- NA
    wcb_ci <- c(NA, NA)
  })
} else {
  cat("fwildclusterboot not available. Skipping WCB.\n")
  wcb_pvalue <- NA
  wcb_ci <- c(NA, NA)
}

## ---- 8. Time-varying stringency ----
cat("\n--- R8: Time-Varying Monthly Stringency ---\n")
panel_oxcgrt <- panel[post == 1 & month_date <= as.Date("2022-12-01")]

r8_monthly <- feols(
  log_paid ~ stringency_avg:is_hcbs |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_oxcgrt,
  cluster = ~state_f
)
cat("Monthly stringency x HCBS (OxCGRT coverage only):\n")
summary(r8_monthly)

## ---- 9. All-HCBS robustness (original broad T-code classification) ----
cat("\n--- R9: All T-codes (Original Classification) ---\n")
panel_all[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

r9_all_hcbs <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_all,
  cluster = ~state_f
)
cat("All T-codes DDD (robustness):\n")
summary(r9_all_hcbs)

## ---- 10. Multiple Placebos (Stage C reviewer request) ----
cat("\n--- R10: Multiple Placebo Dates ---\n")

panel_pre <- panel[month_date < as.Date("2020-03-01")]

placebo_dates <- list(
  "April 2019" = as.Date("2019-04-01"),
  "October 2019" = as.Date("2019-10-01"),
  "January 2020" = as.Date("2020-01-01")
)

placebo_results <- list()
for (pname in names(placebo_dates)) {
  pdate <- placebo_dates[[pname]]
  panel_pre[, placebo_post_tmp := as.integer(month_date >= pdate)]

  tryCatch({
    m_placebo <- feols(
      log_paid ~ peak_stringency_std:is_hcbs:placebo_post_tmp |
        state_f^service_f + service_f^month_f + state_f^month_f,
      data = panel_pre,
      cluster = ~state_f
    )
    ct <- coeftable(m_placebo)
    placebo_results[[pname]] <- list(
      coef = ct[1, "Estimate"],
      se = ct[1, "Std. Error"],
      pval = ct[1, "Pr(>|t|)"],
      n = m_placebo$nobs
    )
    cat(sprintf("  Placebo %s: beta=%.3f, se=%.3f, p=%.3f\n",
                pname, ct[1, "Estimate"], ct[1, "Std. Error"], ct[1, "Pr(>|t|)"]))
  }, error = function(e) {
    cat(sprintf("  Placebo %s failed: %s\n", pname, e$message))
    placebo_results[[pname]] <<- list(coef = NA, se = NA, pval = NA, n = NA)
  })
}
panel_pre[, placebo_post_tmp := NULL]

## ---- 11. Leave-One-Out Jackknife (Stage C reviewer request) ----
cat("\n--- R11: Leave-One-Out Jackknife ---\n")

states_for_loo <- unique(panel$state)
loo_coefs <- numeric(length(states_for_loo))
names(loo_coefs) <- states_for_loo

for (i in seq_along(states_for_loo)) {
  s <- states_for_loo[i]
  panel_loo <- panel[state != s]

  tryCatch({
    m_loo <- feols(
      log_paid ~ peak_stringency_std:is_hcbs:post |
        state_f^service_f + service_f^month_f + state_f^month_f,
      data = panel_loo,
      cluster = ~state_f
    )
    loo_coefs[i] <- coef(m_loo)
  }, error = function(e) {
    loo_coefs[i] <<- NA
  })
}

cat(sprintf("LOO range: [%.3f, %.3f]\n", min(loo_coefs, na.rm = TRUE), max(loo_coefs, na.rm = TRUE)))
cat(sprintf("LOO mean: %.3f, LOO SD: %.3f\n", mean(loo_coefs, na.rm = TRUE), sd(loo_coefs, na.rm = TRUE)))

# Which states have biggest influence?
baseline_coef <- coef(feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel, cluster = ~state_f
))
loo_influence <- abs(loo_coefs - baseline_coef)
top_influence <- sort(loo_influence, decreasing = TRUE)[1:5]
cat("Top 5 influential states:\n")
for (nm in names(top_influence)) {
  cat(sprintf("  Drop %s: beta=%.3f (influence=%.3f)\n",
              nm, loo_coefs[nm], top_influence[nm]))
}

## ---- 12. Provider Entry/Exit Dynamics (Stage C reviewer request) ----
cat("\n--- R12: Provider Entry/Exit Dynamics ---\n")

# Compute provider persistence using panel data
provider_dynamics <- list()

tryCatch({
  # Read raw provider-level data from T-MSIS for HCBS
  tmsis_ds <- open_dataset(tmsis_path)
  nppes_dt <- as.data.table(read_parquet(nppes_path))
  nppes_dt[, npi := as.character(npi)]
  npi_state_dt <- nppes_dt[!is.na(state) & state != "" & nchar(state) == 2 & state %in% us_states,
                           .(npi, state)]

  # Get clean HCBS provider-level monthly activity
  hcbs_providers <- tmsis_ds |>
    filter(HCPCS_CODE %in% clean_hcbs_codes) |>
    select(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, TOTAL_CLAIMS) |>
    collect() |>
    as.data.table()

  setnames(hcbs_providers, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
  hcbs_providers <- merge(hcbs_providers, npi_state_dt, by.x = "billing_npi", by.y = "npi", all.x = FALSE)
  hcbs_providers[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]

  # Annual provider sets
  hcbs_providers[, year := year(month_date)]

  annual_providers <- hcbs_providers[, .(n_months = uniqueN(month_date)),
                                     by = .(state, billing_npi, year)]

  # Entry/exit by year
  provider_years <- annual_providers[, .(providers = uniqueN(billing_npi)), by = .(state, year)]

  # Compute churn: providers in year t who were NOT in year t-1
  for (y in 2019:2024) {
    prev_set <- annual_providers[year == y - 1, .(billing_npi, state)]
    curr_set <- annual_providers[year == y, .(billing_npi, state)]

    new_entrants <- curr_set[!prev_set, on = .(billing_npi, state)]
    exiters <- prev_set[!curr_set, on = .(billing_npi, state)]

    new_by_state <- new_entrants[, .(new_providers = .N), by = state]
    exit_by_state <- exiters[, .(exited_providers = .N), by = state]

    provider_years[year == y, `:=`(
      new_providers = new_by_state$new_providers[match(state, new_by_state$state)],
      exited_providers = exit_by_state$exited_providers[match(state, exit_by_state$state)]
    )]
  }

  # Merge with stringency
  provider_years <- merge(provider_years, state_treatment[, .(state, peak_stringency)], by = "state")
  med_str <- median(state_treatment$peak_stringency, na.rm = TRUE)
  provider_years[, str_group := fifelse(peak_stringency > med_str, "High", "Low")]

  # Summarize
  churn_summary <- provider_years[year >= 2019, .(
    mean_providers = mean(providers, na.rm = TRUE),
    mean_new = mean(new_providers, na.rm = TRUE),
    mean_exit = mean(exited_providers, na.rm = TRUE)
  ), by = .(str_group, year)]

  cat("Provider dynamics by stringency group:\n")
  print(churn_summary)

  provider_dynamics$churn_summary <- churn_summary
  provider_dynamics$provider_years <- provider_years

  rm(hcbs_providers, annual_providers, provider_years)
  gc()
}, error = function(e) {
  cat(sprintf("Provider dynamics failed: %s\n", e$message))
  provider_dynamics$churn_summary <<- data.table()
})

## ---- 13. Save ----
robustness <- list(
  r1_binary = r1_binary,
  r2_cumul = r2_cumul,
  r3_no_never = r3_no_never,
  r4_placebo = r4_placebo,
  r5_cpt = r5_cpt,
  r8_monthly = r8_monthly,
  r9_all_hcbs = r9_all_hcbs,
  # RI results (both outcomes)
  ri_pvalue_paid = ri_p_paid,
  ri_actual_coef_paid = actual_coef_paid,
  ri_perm_coefs_paid = perm_coefs_paid_valid,
  ri_pvalue_claims = ri_p_claims,
  ri_actual_coef_claims = actual_coef_claims,
  ri_perm_coefs_claims = perm_coefs_claims_valid,
  n_perms = n_perms,
  # WCB
  wcb_pvalue = if (exists("wcb_pvalue")) wcb_pvalue else NA,
  wcb_ci = if (exists("wcb_ci")) wcb_ci else c(NA, NA),
  # Multiple placebos (Stage C)
  placebo_results = placebo_results,
  # Leave-one-out (Stage C)
  loo_coefs = loo_coefs,
  loo_influence = loo_influence,
  baseline_coef = baseline_coef,
  # Provider dynamics (Stage C)
  provider_dynamics = provider_dynamics
)

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
