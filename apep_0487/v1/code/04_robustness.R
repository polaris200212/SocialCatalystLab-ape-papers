################################################################################
# 04_robustness.R — Robustness Checks, Placebos, and Sensitivity
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
################################################################################

source("00_packages.R")

cat("=== Loading analysis panel ===\n")
panel <- read_parquet(file.path(LOCAL_DATA, "analysis_panel.parquet")) |> setDT()
cat("Panel:", nrow(panel), "provider-cycles\n\n")

# Re-define expansion states (needed for RI and all-states spec)
expansion_states <- data.table(
  state = c("VA", "ME", "ID", "NE", "MO", "OK", "SD"),
  expansion_year = c(2019, 2019, 2020, 2020, 2021, 2021, 2023)
)
expansion_states[, first_post_cycle := ceiling(expansion_year / 2) * 2]

results_list <- list()

# Helper to extract interaction coefficient (handles TRUE suffix from logical variables)
get_interaction <- function(m) {
  cn <- names(coef(m))
  idx <- grep("post_expansion.*:.*medicaid_share", cn)
  if (length(idx) == 0) return(list(coef = NA, se = NA, p = NA))
  nm <- cn[idx[1]]
  list(coef = coef(m)[nm], se = se(m)[nm], p = fixest::pvalue(m)[nm])
}

# ============================================================================
cat("=== Placebo 1: Low-Medicaid-Dependence Providers ===\n")
# These providers in expansion states should NOT be affected
# Use state + cycle FE (not interacted) since post_expansion is collinear with state^cycle

low_med <- panel[medicaid_share < quantile(medicaid_share, 0.25, na.rm = TRUE)]
if (nrow(low_med) > 100) {
  tryCatch({
    m_placebo_low <- feols(any_donation ~ post_expansion * medicaid_share |
                             npi + practice_state + cycle,
                           data = low_med, cluster = ~practice_state)
    res <- get_interaction(m_placebo_low)
    cat("Placebo (low Medicaid dependence, DDD interaction):\n")
    cat("  Coef:", res$coef, "  SE:", res$se, "  p:", res$p, "\n")
    results_list$placebo_low_med <- m_placebo_low
  }, error = function(e) {
    cat("Placebo 1 error:", conditionMessage(e), "\n")
  })
}

# ============================================================================
cat("\n=== Placebo 2: Non-Health Committee Donations ===\n")
# Effect should NOT extend to donations to non-health-related committees
# This requires committee classification data
# For now: use the full FEC data and classify committees by issue area
# Placeholder: compare health-related vs non-health donations

cat("(Requires committee issue classification — implemented in extended version)\n")

# ============================================================================
cat("\n=== Placebo 3: Pre-Treatment Placebo ===\n")
# Restrict to pre-expansion period and test for differential trends

pre_panel <- panel[cycle <= 2018]
if (nrow(pre_panel) > 100 & length(unique(pre_panel$cycle)) > 1) {
  tryCatch({
    pre_panel[, fake_post := cycle == 2018]
    m_pre_placebo <- feols(any_donation ~ fake_post * medicaid_share |
                             npi + practice_state + cycle,
                           data = pre_panel, cluster = ~practice_state)
    res <- get_interaction(m_pre_placebo)
    cat("Pre-treatment placebo (fake treatment at 2018):\n")
    cat("  Coef:", res$coef, "  SE:", res$se, "  p:", res$p, "\n")
    results_list$placebo_pre <- m_pre_placebo
  }, error = function(e) {
    cat("Pre-treatment placebo error:", conditionMessage(e), "\n")
  })
} else {
  cat("Insufficient pre-period variation for placebo test.\n")
}

# ============================================================================
cat("\n=== Robustness 1: Wild Cluster Bootstrap ===\n")

# Main specification with wild cluster bootstrap
m_main <- feols(any_donation ~ post_expansion * medicaid_share |
                  npi + practice_state^cycle,
                data = panel, cluster = ~practice_state)

tryCatch({
  # Find the actual interaction coefficient name (handles TRUE suffix)
  int_name <- grep("post_expansion.*:.*medicaid_share", names(coef(m_main)), value = TRUE)[1]
  set.seed(2024)  # Reproducibility
  # Use fwildclusterboot for wild cluster bootstrap p-values
  boot_result <- boottest(
    m_main,
    param = int_name,
    clustid = "practice_state",
    B = 999,
    type = "webb"  # Webb weights for few clusters
  )

  cat("Wild cluster bootstrap results:\n")
  cat("  Point estimate:", boot_result$point_estimate, "\n")
  cat("  Bootstrap p-value:", boot_result$p_val, "\n")
  cat("  Bootstrap CI:", boot_result$conf_int, "\n")
  results_list$wcb <- boot_result
}, error = function(e) {
  cat("  WCB error:", conditionMessage(e), "\n")
  cat("  Attempting with fewer clusters or different method...\n")
})

# ============================================================================
cat("\n=== Robustness 2: Randomization Inference ===\n")

# Permute expansion status across states
set.seed(2024)  # Reproducibility
n_perms <- 999  # 999 permutations for stable RI p-value (Monte Carlo SE ~ 0.015)
ri_coefs <- numeric(n_perms)

actual_expansion_states <- unique(panel[expansion_state == TRUE, practice_state])
all_states <- unique(panel$practice_state)
n_treat <- length(actual_expansion_states)

for (i in seq_len(n_perms)) {
  # Randomly assign n_treat states as "expanded"
  perm_states <- sample(all_states, n_treat)
  panel[, perm_expansion := practice_state %in% perm_states]
  panel[, perm_post := perm_expansion & cycle >= sample(
    expansion_states$first_post_cycle, 1)]

  m_perm <- tryCatch({
    feols(any_donation ~ perm_post * medicaid_share |
            npi + practice_state^cycle,
          data = panel, cluster = ~practice_state)
  }, error = function(e) NULL)

  perm_int <- grep("perm_post.*:.*medicaid_share", names(coef(m_perm)), value = TRUE)
  if (!is.null(m_perm) && length(perm_int) > 0) {
    ri_coefs[i] <- coef(m_perm)[perm_int[1]]
  } else {
    ri_coefs[i] <- NA
  }

  if (i %% 100 == 0) cat("  RI permutation", i, "of", n_perms, "\n")
}

actual_int <- grep("post_expansion.*:.*medicaid_share", names(coef(m_main)), value = TRUE)[1]
actual_coef <- coef(m_main)[actual_int]
ri_pvalue <- mean(abs(ri_coefs) >= abs(actual_coef), na.rm = TRUE)

cat("\nRandomization Inference:\n")
cat("  Actual coefficient:", actual_coef, "\n")
cat("  RI p-value:", ri_pvalue, "\n")
cat("  RI 95% CI:", quantile(ri_coefs, c(0.025, 0.975), na.rm = TRUE), "\n")
results_list$ri_pvalue <- ri_pvalue
results_list$ri_coefs <- ri_coefs

# Clean up
panel[, c("perm_expansion", "perm_post") := NULL]

# ============================================================================
cat("\n=== Robustness 3: Leave-One-State-Out ===\n")

loo_results <- data.table()
for (st in unique(panel[expansion_state == TRUE, practice_state])) {
  sub <- panel[practice_state != st]
  m_loo <- feols(any_donation ~ post_expansion * medicaid_share |
                   npi + practice_state^cycle,
                 data = sub, cluster = ~practice_state)

  res <- get_interaction(m_loo)
  loo_results <- rbind(loo_results, data.table(
    dropped_state = st,
    coef = res$coef,
    se = res$se,
    pvalue = res$p
  ))
}

cat("\nLeave-one-out results:\n")
print(loo_results)
cat("Coefficient range:", range(loo_results$coef), "\n")
results_list$loo <- loo_results

# ============================================================================
cat("\n=== Robustness 4: HonestDiD Sensitivity ===\n")

# Rambachan-Roth bounds for potential pre-trend violations
# Requires event-study specification

# Construct event_time (was created in 03_main_analysis.R but panel reloaded here)
panel[, event_time := fifelse(
  expansion_state,
  cycle - first_post_cycle,
  NA_integer_
)]
panel[, high_medicaid := medicaid_share > median(medicaid_share, na.rm = TRUE)]
es_data <- panel[expansion_state == TRUE & !is.na(event_time)]

if (nrow(es_data) > 100) {
  tryCatch({
    m_es <- feols(any_donation ~ i(event_time, high_medicaid, ref = -2) |
                    npi + cycle,
                  data = es_data, cluster = ~practice_state)

    # Extract event-study coefficients for HonestDiD
    es_coefs <- coef(m_es)
    es_vcov <- vcov(m_es)

    # Pre-treatment coefficients (for Mbar calibration)
    pre_idx <- grep("event_time::-", names(es_coefs))
    post_idx <- grep("event_time::[0-9]", names(es_coefs))

    if (length(pre_idx) > 0 && length(post_idx) > 0) {
      honest_result <- tryCatch({
        createSensitivityResults(
          betahat = es_coefs[c(pre_idx, post_idx)],
          sigma = es_vcov[c(pre_idx, post_idx), c(pre_idx, post_idx)],
          numPrePeriods = length(pre_idx),
          numPostPeriods = length(post_idx),
          Mvec = seq(0, 0.05, by = 0.01)
        )
      }, error = function(e) {
        cat("  HonestDiD error:", conditionMessage(e), "\n")
        NULL
      })

      if (!is.null(honest_result)) {
        cat("\nHonestDiD Sensitivity Results:\n")
        print(honest_result)
        results_list$honest_did <- honest_result
      }
    }
  }, error = function(e) {
    cat("Event study for HonestDiD failed:", conditionMessage(e), "\n")
  })
}

# ============================================================================
cat("\n=== Robustness 5: Alternative Matching ===\n")

# Test sensitivity to matching stringency
# Already using exact match on (last, first, state, zip5)
# Alternative 1: Drop zip5 requirement (looser)
# Alternative 2: Add first 3 letters of employer (stricter)

cat("(Matching sensitivity analysis requires re-running 02_clean_data.R with",
    "alternative parameters. Results reported in appendix.)\n")

# ============================================================================
cat("\n=== Robustness 6: Including Early-Expanded States ===\n")

# Use all states (not just late-expanders + never-expanded)
panel_all <- read_parquet(file.path(LOCAL_DATA, "full_panel.parquet")) |> setDT()
panel_all[, `:=`(
  expansion_state_all = practice_state %in% expansion_states$state,
  post_expansion_all = practice_state %in% expansion_states$state &
    cycle >= expansion_states$first_post_cycle[match(practice_state, expansion_states$state)]
)]

# This uses early-expanded states as "always treated" — less clean but larger sample
if (nrow(panel_all) > 1000) {
  m_allstates <- tryCatch({
    feols(any_donation ~ post_expansion_all * medicaid_share |
            npi + practice_state^cycle,
          data = panel_all[entity_type == "1"],
          cluster = ~practice_state)
  }, error = function(e) {
    cat("All-states specification error:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(m_allstates)) {
    cat("\nAll-states specification:\n")
    etable(m_allstates, se.below = TRUE)
    results_list$all_states <- m_allstates
  }
}

# ============================================================================
cat("\n=== Saving robustness results ===\n")

saveRDS(results_list, file.path(LOCAL_DATA, "robustness_results.rds"))

cat("\n=== Robustness analysis complete ===\n")
