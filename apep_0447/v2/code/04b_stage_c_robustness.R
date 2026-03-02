## ============================================================================
## 04b_stage_c_robustness.R — Additional analyses for Stage C revision
## Adds: multiple placebos, leave-one-out, provider dynamics
## Loads existing robustness results and appends new fields
## ============================================================================

source("00_packages.R")

DATA <- "../data"
panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

panel[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

## ---- 1. Multiple Placebos ----
cat("--- Multiple Placebo Dates ---\n")

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
    cat(sprintf("  Placebo %s: beta=%.3f, se=%.3f, p=%.3f, n=%d\n",
                pname, ct[1, "Estimate"], ct[1, "Std. Error"], ct[1, "Pr(>|t|)"], m_placebo$nobs))
  }, error = function(e) {
    cat(sprintf("  Placebo %s failed: %s\n", pname, e$message))
    placebo_results[[pname]] <<- list(coef = NA, se = NA, pval = NA, n = NA)
  })
}
panel_pre[, placebo_post_tmp := NULL]

## ---- 2. Leave-One-Out Jackknife ----
cat("\n--- Leave-One-Out Jackknife ---\n")

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

baseline_coef <- robustness$ri_actual_coef_paid
loo_influence <- abs(loo_coefs - baseline_coef)
top_influence <- sort(loo_influence, decreasing = TRUE)[1:5]
cat("Top 5 influential states:\n")
for (nm in names(top_influence)) {
  cat(sprintf("  Drop %s: beta=%.3f (influence=%.3f)\n",
              nm, loo_coefs[nm], top_influence[nm]))
}

## ---- 3. Provider Entry/Exit Dynamics ----
cat("\n--- Provider Entry/Exit Dynamics ---\n")

provider_dynamics <- list()

tmsis_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "tmsis.parquet")
nppes_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "nppes_extract.parquet")

clean_hcbs_codes <- c("T1019","T1020","T2016","T2017","T2022","T2025",
                       "T2028","T2033","T2034","T2036","T1005")
us_states <- c(state.abb, "DC")

tryCatch({
  tmsis_ds <- open_dataset(tmsis_path)
  nppes_dt <- as.data.table(read_parquet(nppes_path))
  nppes_dt[, npi := as.character(npi)]
  npi_state_dt <- nppes_dt[!is.na(state) & state != "" & nchar(state) == 2 & state %in% us_states,
                           .(npi, state)]

  hcbs_providers <- tmsis_ds |>
    filter(HCPCS_CODE %in% clean_hcbs_codes) |>
    select(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, TOTAL_CLAIMS) |>
    collect() |>
    as.data.table()

  setnames(hcbs_providers, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
  hcbs_providers <- merge(hcbs_providers, npi_state_dt, by.x = "billing_npi", by.y = "npi", all.x = FALSE)
  hcbs_providers[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
  hcbs_providers[, year := year(month_date)]

  annual_providers <- hcbs_providers[, .(n_months = uniqueN(month_date)),
                                     by = .(state, billing_npi, year)]

  provider_years <- annual_providers[, .(providers = uniqueN(billing_npi)), by = .(state, year)]
  provider_years[, new_providers := NA_integer_]
  provider_years[, exited_providers := NA_integer_]

  for (y in 2019:2024) {
    prev_set <- annual_providers[year == y - 1, .(billing_npi, state)]
    curr_set <- annual_providers[year == y, .(billing_npi, state)]

    new_entrants <- curr_set[!prev_set, on = .(billing_npi, state)]
    exiters <- prev_set[!curr_set, on = .(billing_npi, state)]

    new_by_state <- new_entrants[, .(n_new = .N), by = state]
    exit_by_state <- exiters[, .(n_exit = .N), by = state]

    for (s in unique(provider_years[year == y]$state)) {
      provider_years[year == y & state == s, new_providers :=
        ifelse(s %in% new_by_state$state, new_by_state[state == s]$n_new, 0L)]
      provider_years[year == y & state == s, exited_providers :=
        ifelse(s %in% exit_by_state$state, exit_by_state[state == s]$n_exit, 0L)]
    }
  }

  provider_years <- merge(provider_years, state_treatment[, .(state, peak_stringency)], by = "state")
  med_str <- median(state_treatment$peak_stringency, na.rm = TRUE)
  provider_years[, str_group := fifelse(peak_stringency > med_str, "High", "Low")]

  churn_summary <- provider_years[year >= 2019 & !is.na(new_providers), .(
    mean_providers = mean(providers, na.rm = TRUE),
    mean_new = mean(new_providers, na.rm = TRUE),
    mean_exit = mean(exited_providers, na.rm = TRUE),
    entry_rate = mean(new_providers / providers, na.rm = TRUE),
    exit_rate = mean(exited_providers / providers, na.rm = TRUE)
  ), by = .(str_group, year)]

  cat("Provider dynamics by stringency group:\n")
  print(churn_summary)

  provider_dynamics$churn_summary <- churn_summary
  provider_dynamics$provider_years <- provider_years

  rm(hcbs_providers, annual_providers)
  gc()
}, error = function(e) {
  cat(sprintf("Provider dynamics failed: %s\n", e$message))
  provider_dynamics$churn_summary <- data.table()
})

## ---- 4. Save updated robustness ----
robustness$placebo_results <- placebo_results
robustness$loo_coefs <- loo_coefs
robustness$loo_influence <- loo_influence
robustness$baseline_coef <- baseline_coef
robustness$provider_dynamics <- provider_dynamics

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))

cat("\n=== Stage C robustness additions complete ===\n")
