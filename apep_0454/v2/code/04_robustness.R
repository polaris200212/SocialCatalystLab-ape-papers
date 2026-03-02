## ============================================================================
## 04_robustness.R — Robustness checks for apep_0454
##
## 1. Alternative exit definitions
## 2. Placebo tests
## 3. Randomization inference
## 4. Leave-one-out jackknife
## 5. HonestDiD sensitivity
## 6. Bartik diagnostics
## 7. Alternative specifications
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))

hcbs_panel <- panel[prov_type == "HCBS"]

## ---- 1. Alternative exit definitions ----
cat("=== Robustness 1: Alternative exit window definitions ===\n")

# The main analysis uses "no billing after Feb 2020" as exit.
# Test: exit = no billing after June 2019 (stricter) and Dec 2020 (looser)

# We can't recompute from raw T-MSIS here without the provider_monthly data.
# Instead, test sensitivity to the binary high/low cutoff:
# Use terciles and quintiles instead of median split.

panel[, high_exit_p75 := exit_rate > quantile(exit_rate, 0.75, na.rm = TRUE)]
panel[, high_exit_p25 := exit_rate > quantile(exit_rate, 0.25, na.rm = TRUE)]
if (!"post_covid_num" %in% names(panel)) panel[, post_covid_num := as.integer(post_covid)]

rob_p75 <- feols(
  ln_providers ~ post_covid_num:I(high_exit_p75) + unemp_rate |
    state + month_date,
  data = panel[prov_type == "HCBS"],
  cluster = ~state
)

rob_p25 <- feols(
  ln_providers ~ post_covid_num:I(high_exit_p25) + unemp_rate |
    state + month_date,
  data = panel[prov_type == "HCBS"],
  cluster = ~state
)

cat("Median split:\n")
summary(results$did_covid)
cat("\n75th percentile split:\n")
summary(rob_p75)
cat("\n25th percentile split:\n")
summary(rob_p25)

## ---- 2. Placebo test: False event date ----
cat("\n=== Robustness 2: Placebo event dates ===\n")

# Placebo 1: March 2019 (one year before actual COVID)
hcbs_panel[, event_m_placebo := round(as.numeric(difftime(month_date,
                                       as.Date("2019-03-01"), units = "days")) / 30.44)]
hcbs_panel[, event_m_placebo := pmax(-12, pmin(12, event_m_placebo))]

# Only use pre-COVID data for placebo
placebo_data <- hcbs_panel[month_date < "2020-03-01"]

es_placebo <- feols(
  ln_providers ~ i(event_m_placebo, exit_rate, ref = -1) |
    state + month_date,
  data = placebo_data,
  cluster = ~state
)
cat("Placebo event study (March 2019 'event', pre-COVID data only):\n")
summary(es_placebo)

## ---- 3. Randomization inference ----
cat("\n=== Robustness 3: Randomization Inference ===\n")

# Permute exit_rate across states
set.seed(42)
n_perm <- 2000
true_coef <- coef(results$did_covid)["post_covid_num:exit_rate"]

perm_coefs <- numeric(n_perm)
states <- unique(hcbs_panel$state)

for (i in seq_len(n_perm)) {
  perm_map <- data.table(state = states,
                         perm_exit_rate = sample(state_exits$exit_rate[match(states, state_exits$state)]))
  perm_data <- merge(hcbs_panel[, !c("exit_rate"), with = FALSE],
                     perm_map, by = "state")

  perm_data[, post_covid_num := as.integer(month_date >= "2020-03-01")]
  perm_fit <- tryCatch(
    feols(ln_providers ~ post_covid_num:perm_exit_rate + unemp_rate |
            state + month_date,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )
  if (!is.null(perm_fit)) {
    perm_coefs[i] <- coef(perm_fit)["post_covid_num:perm_exit_rate"]
  } else {
    perm_coefs[i] <- NA
  }
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(true_coef), na.rm = TRUE)
cat(sprintf("RI p-value (two-sided, %d permutations): %.3f\n", n_perm, ri_pvalue))
cat(sprintf("True coefficient: %.4f\n", true_coef))

## ---- 3b. RI for beneficiary outcomes ----
cat("\n=== Robustness 3b: RI for Beneficiary Outcomes ===\n")

true_coef_bene <- coef(results$did_bene)["post_covid_num:exit_rate"]
true_coef_cpb <- coef(results$did_claims_per_bene)["post_covid_num:exit_rate"]
perm_coefs_bene <- numeric(n_perm)
perm_coefs_cpb <- numeric(n_perm)

for (i in seq_len(n_perm)) {
  perm_map <- data.table(state = states,
                         perm_exit_rate = sample(state_exits$exit_rate[match(states, state_exits$state)]))
  perm_data <- merge(hcbs_panel[, !c("exit_rate"), with = FALSE],
                     perm_map, by = "state")
  perm_data[, post_covid_num := as.integer(month_date >= "2020-03-01")]

  perm_bene <- tryCatch(
    feols(ln_beneficiaries ~ post_covid_num:perm_exit_rate + unemp_rate |
            state + month_date,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )
  perm_cpb <- tryCatch(
    feols(ln_claims_per_bene ~ post_covid_num:perm_exit_rate + unemp_rate |
            state + month_date,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )

  perm_coefs_bene[i] <- if (!is.null(perm_bene)) coef(perm_bene)["post_covid_num:perm_exit_rate"] else NA
  perm_coefs_cpb[i] <- if (!is.null(perm_cpb)) coef(perm_cpb)["post_covid_num:perm_exit_rate"] else NA
}

ri_pvalue_bene <- mean(abs(perm_coefs_bene) >= abs(true_coef_bene), na.rm = TRUE)
ri_pvalue_cpb <- mean(abs(perm_coefs_cpb) >= abs(true_coef_cpb), na.rm = TRUE)
cat(sprintf("RI p-value (beneficiaries): %.3f\n", ri_pvalue_bene))
cat(sprintf("RI p-value (claims/bene): %.3f\n", ri_pvalue_cpb))

## ---- 3c. Non-HCBS falsification ----
cat("\n=== Robustness 3c: Non-HCBS Falsification ===\n")

non_hcbs_panel <- panel[prov_type == "Non-HCBS"]
non_hcbs_panel[, post_covid_num := as.integer(post_covid)]
rob_non_hcbs <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = non_hcbs_panel,
  cluster = ~state
)
cat("Non-HCBS falsification:\n")
summary(rob_non_hcbs)

## ---- 3d. Truncated sample (through June 2024) ----
cat("\n=== Robustness 3d: Truncated Sample ===\n")

rob_truncated <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel[month_date <= "2024-06-01"],
  cluster = ~state
)
cat("Truncated sample (through June 2024):\n")
summary(rob_truncated)

## ---- 4. Leave-one-state-out jackknife ----
cat("\n=== Robustness 4: Leave-one-state-out ===\n")

loo_coefs <- numeric(length(states))
names(loo_coefs) <- states

for (s in states) {
  loo_fit <- tryCatch(
    feols(ln_providers ~ post_covid_num:exit_rate + unemp_rate |
            state + month_date,
          data = hcbs_panel[state != s], cluster = ~state),
    error = function(e) NULL
  )
  if (!is.null(loo_fit)) {
    loo_coefs[s] <- coef(loo_fit)["post_covid_num:exit_rate"]
  } else {
    loo_coefs[s] <- NA
  }
}

cat(sprintf("LOO range: [%.4f, %.4f]\n", min(loo_coefs, na.rm = TRUE),
            max(loo_coefs, na.rm = TRUE)))
cat(sprintf("Full sample: %.4f\n", true_coef))

## ---- 5. Controls sensitivity ----
cat("\n=== Robustness 5: Control variable sensitivity ===\n")

# No controls
rob_no_controls <- feols(
  ln_providers ~ post_covid_num:exit_rate |
    state + month_date,
  data = hcbs_panel, cluster = ~state
)

# Full controls
rob_full_controls <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate +
    post_covid_num:poverty_rate + post_covid_num:median_age +
    post_covid_num:pct_black |
    state + month_date,
  data = hcbs_panel, cluster = ~state
)

# With stringency
if ("stringency" %in% names(hcbs_panel)) {
  rob_stringency <- feols(
    ln_providers ~ post_covid_num:exit_rate + unemp_rate + stringency |
      state + month_date,
    data = hcbs_panel[!is.na(stringency)], cluster = ~state
  )
} else {
  rob_stringency <- NULL
}

## ---- 6. Part 2 DDD robustness ----
cat("\n=== Robustness 6: DDD alternative specifications ===\n")

# Continuous exit rate (not binary)
ddd_continuous_rob <- feols(
  ln_beneficiaries ~ exit_rate_x_post_arpa_hcbs +
    exit_rate_x_post_arpa + exit_rate_x_hcbs +
    post_arpa_hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel, cluster = ~state
)

# DDD with COVID deaths as control
if ("covid_deaths" %in% names(panel)) {
  ddd_covid_control <- feols(
    ln_providers ~ triple_arpa + post_arpa_hcbs +
      post_arpa_high_exit + hcbs_high_exit +
      unemp_rate + covid_deaths |
      state_prov + prov_month,
    data = panel, cluster = ~state
  )
} else {
  ddd_covid_control <- NULL
}

## ---- 7. Exclusion restriction test for IV ----
cat("\n=== Robustness 7: IV exclusion restriction test ===\n")

# The Bartik instrument should NOT predict pre-COVID mortality trends
state_month_pre <- panel[prov_type == "HCBS" & month_date < "2020-03-01",
                          .(state, month_date, covid_deaths, predicted_exit_rate)] |>
  unique(by = c("state", "month_date"))

if ("covid_deaths" %in% names(state_month_pre) && any(!is.na(state_month_pre$covid_deaths))) {
  # Cross-sectional test: predicted exit shouldn't predict pre-COVID deaths
  # Use month FE only (predicted_exit_rate is state-level, absorbed by state FE)
  excl_test <- tryCatch(
    feols(covid_deaths ~ predicted_exit_rate | month_date,
          data = state_month_pre[!is.na(covid_deaths)], cluster = ~state),
    error = function(e) {
      cat("Exclusion test with FE failed, running simple OLS.\n")
      lm(covid_deaths ~ predicted_exit_rate, data = state_month_pre[!is.na(covid_deaths)])
    }
  )
  cat("Exclusion restriction test (predicted exit → pre-COVID deaths):\n")
  summary(excl_test)
} else {
  cat("Pre-COVID death data not available for exclusion test.\n")
}

## ---- 8. Wild Cluster Bootstrap (Cameron, Gelbach, Miller 2008) ----
cat("\n=== Robustness 8: Wild Cluster Bootstrap ===\n")

# Wild Cluster Restricted (WCR) bootstrap — Cameron, Gelbach, Miller (2008)
# Uses restricted residuals under H0: beta_treatment = 0
set.seed(123)
n_boot <- 999

wild_cluster_boot <- function(unrestricted_model, param_name, data_dt, dep_var,
                              cluster_var = "state", n_boot = 999) {
  clusters <- unique(data_dt[[cluster_var]])
  n_clusters <- length(clusters)
  orig_t <- coef(unrestricted_model)[param_name] / se(unrestricted_model)[param_name]

  # Step 1: Fit RESTRICTED model (H0: beta_treatment = 0)
  restricted_fit <- feols(
    as.formula(paste0(dep_var, " ~ unemp_rate | state + month_date")),
    data = data_dt, cluster = as.formula(paste0("~", cluster_var))
  )
  restricted_fitted <- fitted(restricted_fit)
  restricted_resid <- residuals(restricted_fit)

  boot_t <- numeric(n_boot)

  for (b in seq_len(n_boot)) {
    # Step 2: Rademacher weights per cluster
    weights <- sample(c(-1, 1), n_clusters, replace = TRUE)
    names(weights) <- clusters

    # Step 3: Y* = Yhat_restricted + w_g * e_restricted
    boot_data <- copy(data_dt)
    boot_data[, boot_weight := weights[get(cluster_var)]]
    boot_data[, (dep_var) := restricted_fitted + boot_weight * restricted_resid]

    # Step 4: Fit UNRESTRICTED model on Y*
    boot_fit <- tryCatch(
      feols(as.formula(paste0(dep_var, " ~ post_covid_num:exit_rate + unemp_rate | state + month_date")),
            data = boot_data, cluster = as.formula(paste0("~", cluster_var))),
      error = function(e) NULL
    )

    if (!is.null(boot_fit) && param_name %in% names(coef(boot_fit))) {
      boot_t[b] <- coef(boot_fit)[param_name] / se(boot_fit)[param_name]
    } else {
      boot_t[b] <- NA
    }
  }

  boot_t <- boot_t[!is.na(boot_t)]
  p_val <- mean(abs(boot_t) >= abs(orig_t))
  list(p_value = p_val, orig_t = orig_t, n_valid = length(boot_t))
}

# Provider supply
cat("WCB for providers...\n")
wcb_providers <- wild_cluster_boot(
  results$did_covid, "post_covid_num:exit_rate", hcbs_panel,
  dep_var = "ln_providers", n_boot = 999
)
cat(sprintf("  WCB p-value (providers): %.3f (orig t=%.2f, %d valid boots)\n",
            wcb_providers$p_value, wcb_providers$orig_t, wcb_providers$n_valid))

# Beneficiaries
cat("WCB for beneficiaries...\n")
wcb_bene <- wild_cluster_boot(
  results$did_bene, "post_covid_num:exit_rate", hcbs_panel,
  dep_var = "ln_beneficiaries", n_boot = 999
)
cat(sprintf("  WCB p-value (beneficiaries): %.3f (orig t=%.2f, %d valid boots)\n",
            wcb_bene$p_value, wcb_bene$orig_t, wcb_bene$n_valid))


## ---- Save robustness results ----
rob_results <- list(
  rob_p75 = rob_p75,
  rob_p25 = rob_p25,
  es_placebo = es_placebo,
  ri_pvalue = ri_pvalue,
  ri_pvalue_bene = ri_pvalue_bene,
  ri_pvalue_cpb = ri_pvalue_cpb,
  ri_coefs = perm_coefs,
  ri_coefs_bene = perm_coefs_bene,
  ri_coefs_cpb = perm_coefs_cpb,
  loo_coefs = loo_coefs,
  rob_no_controls = rob_no_controls,
  rob_full_controls = rob_full_controls,
  rob_stringency = rob_stringency,
  rob_non_hcbs = rob_non_hcbs,
  rob_truncated = rob_truncated,
  ddd_continuous_rob = ddd_continuous_rob,
  ddd_covid_control = ddd_covid_control,
  true_coef = true_coef,
  wcb_providers = wcb_providers,
  wcb_bene = wcb_bene
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
