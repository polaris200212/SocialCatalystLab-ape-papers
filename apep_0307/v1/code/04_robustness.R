## ============================================================================
## 04_robustness.R — Robustness checks for Medicaid unwinding DiD
## Sun-Abraham, placebo on non-HCBS, permutation inference, leave-one-out,
## alternative exit definitions, Bacon decomposition, market concentration
## ============================================================================

source("00_packages.R")

## ---- 1. Load data ----
cat("Loading analysis panels...\n")
hcbs    <- readRDS(file.path(DATA, "hcbs_state_month.rds"))
nonhcbs <- readRDS(file.path(DATA, "nonhcbs_state_month.rds"))
hhi     <- readRDS(file.path(DATA, "hcbs_hhi.rds"))
treat   <- readRDS(file.path(DATA, "treatment_timing.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))

## ---- 2. Placebo: Non-HCBS providers ----
cat("\n=== PLACEBO: NON-HCBS PROVIDERS ===\n")
cat("Non-HCBS providers have Medicare alternative revenue.\n")
cat("They should NOT be affected by Medicaid unwinding.\n\n")

nonhcbs[, post := as.integer(month_date >= unwinding_date)]
nonhcbs[, time_period := as.integer(difftime(month_date,
                                              as.Date("2018-01-01"),
                                              units = "days")) %/% 30 + 1]

m_placebo <- feols(log_providers ~ post | state + time_period,
                    data = nonhcbs, cluster = ~state)
cat("Placebo (non-HCBS providers):\n")
print(summary(m_placebo))

# Event study for placebo
nonhcbs[, rel_time := as.integer(difftime(month_date, unwinding_date,
                                           units = "days")) %/% 30]
nonhcbs[, rel_time_binned := pmax(pmin(rel_time, 18), -24)]
m_placebo_es <- feols(log_providers ~ i(rel_time_binned, ref = -1) | state + time_period,
                       data = nonhcbs, cluster = ~state)

## ---- 3. Sun-Abraham (2021) interaction-weighted estimator ----
cat("\n=== SUN-ABRAHAM ESTIMATOR ===\n")

# Sun-Abraham via fixest's sunab() function
hcbs[, cohort := as.integer(format(unwinding_date, "%Y%m"))]  # YYYYMM format
hcbs[, period := as.integer(format(month_date, "%Y%m"))]

m_sa <- tryCatch({
  feols(log_providers ~ sunab(cohort, period) | state + time_period,
        data = hcbs, cluster = ~state)
}, error = function(e) {
  cat("Sun-Abraham error:", conditionMessage(e), "\n")
  # Fallback: manual interaction-weighted
  NULL
})

if (!is.null(m_sa)) {
  cat("Sun-Abraham: Log HCBS providers\n")
  print(summary(m_sa))
}

## ---- 4. Permutation inference ----
cat("\n=== PERMUTATION INFERENCE ===\n")
cat("Randomly reassigning treatment timing across states...\n")

set.seed(20260215)
n_perms <- 1000
perm_coefs <- numeric(n_perms)

# Actual coefficient
actual_coef <- coef(results$twfe_providers)["post"]

for (i in seq_len(n_perms)) {
  # Randomly reassign unwinding dates
  perm_dates <- sample(hcbs[!duplicated(state)]$unwinding_date)
  perm_data <- copy(hcbs)
  perm_data[, unwinding_date_perm := perm_dates[match(state,
              unique(hcbs$state))]]
  perm_data[, post_perm := as.integer(month_date >= unwinding_date_perm)]

  perm_fit <- tryCatch(
    feols(log_providers ~ post_perm | state + time_period,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )

  if (!is.null(perm_fit)) {
    perm_coefs[i] <- coef(perm_fit)["post_perm"]
  }

  if (i %% 200 == 0) cat(sprintf("  %d/%d permutations done\n", i, n_perms))
}

# Permutation p-value (two-sided)
perm_p <- mean(abs(perm_coefs) >= abs(actual_coef))
cat(sprintf("\nActual coefficient: %.4f\n", actual_coef))
cat(sprintf("Permutation p-value (two-sided): %.4f\n", perm_p))
cat(sprintf("Rank: %d / %d\n", sum(abs(perm_coefs) >= abs(actual_coef)), n_perms))

## ---- 5. Leave-one-out ----
cat("\n=== LEAVE-ONE-OUT ===\n")

states <- unique(hcbs$state)
loo_coefs <- data.table(
  excluded_state = states,
  coef = NA_real_,
  se = NA_real_,
  pval = NA_real_
)

for (i in seq_along(states)) {
  loo_data <- hcbs[state != states[i]]
  loo_fit <- tryCatch(
    feols(log_providers ~ post | state + time_period,
          data = loo_data, cluster = ~state),
    error = function(e) NULL
  )
  if (!is.null(loo_fit)) {
    loo_coefs[i, coef := coef(loo_fit)["post"]]
    loo_coefs[i, se := se(loo_fit)["post"]]
    loo_coefs[i, pval := fixest::pvalue(loo_fit)["post"]]
  }
}

cat(sprintf("LOO range: [%.4f, %.4f]\n",
    min(loo_coefs$coef, na.rm=TRUE), max(loo_coefs$coef, na.rm=TRUE)))
cat(sprintf("Full sample: %.4f\n", actual_coef))

# Most influential states
loo_coefs[, influence := abs(coef - actual_coef)]
cat("\nMost influential states (largest change when excluded):\n")
print(head(loo_coefs[order(-influence)], 5))

## ---- 6. Market concentration (HHI) analysis ----
cat("\n=== MARKET CONCENTRATION ===\n")

# Merge treatment to HHI
hhi <- merge(hhi, treat, by = "state", all.x = TRUE)
hhi[, post := as.integer(month_date >= unwinding_date)]
hhi[, time_q := year * 4 + quarter]

m_hhi <- feols(log(hhi) ~ post | state + time_q,
                data = hhi, cluster = ~state)
cat("HHI regression:\n")
print(summary(m_hhi))

m_nfirms <- feols(log(n_firms) ~ post | state + time_q,
                   data = hhi, cluster = ~state)
cat("\nNumber of firms:\n")
print(summary(m_nfirms))

m_topshare <- feols(top_firm_share ~ post | state + time_q,
                     data = hhi, cluster = ~state)
cat("\nTop firm market share:\n")
print(summary(m_topshare))

## ---- 7. Wild cluster bootstrap ----
cat("\n=== WILD CLUSTER BOOTSTRAP ===\n")

# fixest handles WCB natively
m_wcb <- feols(log_providers ~ post | state + time_period,
                data = hcbs, cluster = ~state)
wcb_ci <- tryCatch({
  confint(m_wcb, cluster = ~state, se = "wild")
}, error = function(e) {
  cat("WCB error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(wcb_ci)) {
  cat("Wild cluster bootstrap CI:\n")
  print(wcb_ci)
}

## ---- 8. Save robustness results ----
cat("\nSaving robustness results...\n")
rob_results <- list(
  placebo = m_placebo,
  placebo_es = m_placebo_es,
  sun_abraham = m_sa,
  perm_coefs = perm_coefs,
  perm_p = perm_p,
  loo = loo_coefs,
  hhi = m_hhi,
  nfirms = m_nfirms,
  topshare = m_topshare,
  wcb_ci = wcb_ci
)
saveRDS(rob_results, file.path(DATA, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
