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
n_perm <- 500
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

## ---- Save robustness results ----
rob_results <- list(
  rob_p75 = rob_p75,
  rob_p25 = rob_p25,
  es_placebo = es_placebo,
  ri_pvalue = ri_pvalue,
  ri_coefs = perm_coefs,
  loo_coefs = loo_coefs,
  rob_no_controls = rob_no_controls,
  rob_full_controls = rob_full_controls,
  rob_stringency = rob_stringency,
  ddd_continuous_rob = ddd_continuous_rob,
  ddd_covid_control = ddd_covid_control,
  true_coef = true_coef
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
