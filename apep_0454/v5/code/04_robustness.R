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


## ---- 9. HonestDiD Sensitivity Bounds (Rambachan & Roth 2023) ----
cat("\n=== Robustness 9: HonestDiD Sensitivity Bounds ===\n")

# Extract event study coefficients for providers
es_ct_prov <- coeftable(results$es_providers)
es_names_prov <- rownames(es_ct_prov)
es_idx_prov <- grep("event_m_covid::", es_names_prov)
es_df_prov <- as.data.frame(es_ct_prov[es_idx_prov, , drop = FALSE])
es_df_prov$event_time <- as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1",
                                          es_names_prov[es_idx_prov]))
es_df_prov <- es_df_prov[order(es_df_prov$event_time), ]

# Use last 12 pre-periods and first 12 post-periods for computational feasibility
# (HonestDiD with 23 pre + 58 post is intractable)
pre_idx <- which(es_df_prov$event_time >= -12 & es_df_prov$event_time < -1)
post_idx <- which(es_df_prov$event_time >= 0 & es_df_prov$event_time <= 11)
n_pre <- length(pre_idx)
n_post <- length(post_idx)

# Build coefficient vector and vcov (pre + post, excluding ref)
keep_idx <- c(pre_idx, post_idx)
es_coef_vec <- es_df_prov$Estimate[keep_idx]
names(es_coef_vec) <- NULL

# Get vcov from fixest model
full_vcov <- vcov(results$es_providers)
# Match to the same indices
full_names <- es_names_prov[es_idx_prov]
ordered_names <- full_names[order(es_df_prov$event_time)]
keep_names <- ordered_names[keep_idx]
es_vcov_mat <- full_vcov[keep_names, keep_names]

cat(sprintf("  n_pre = %d, n_post = %d (trimmed for HonestDiD)\n", n_pre, n_post))

# Relative magnitudes approach (Delta^RM)
honest_rm_prov <- tryCatch({
  createSensitivityResults_relativeMagnitudes(
    betahat = es_coef_vec,
    sigma = es_vcov_mat,
    numPrePeriods = n_pre,
    numPostPeriods = n_post,
    Mbarvec = seq(0, 2, by = 0.25),
    alpha = 0.05
  )
}, error = function(e) {
  cat(sprintf("  HonestDiD RM failed: %s\n", e$message))
  NULL
})

if (!is.null(honest_rm_prov)) {
  cat("  HonestDiD relative magnitudes (providers):\n")
  print(honest_rm_prov)
  # Find breakdown value: largest Mbar where CI excludes 0
  rm_breakdown_prov <- NA
  for (row_i in seq_len(nrow(honest_rm_prov))) {
    lb <- honest_rm_prov$lb[row_i]
    ub <- honest_rm_prov$ub[row_i]
    if (!is.na(lb) && !is.na(ub) && (lb > 0 || ub < 0)) {
      rm_breakdown_prov <- honest_rm_prov$Mbar[row_i]
    }
  }
  cat(sprintf("  Breakdown Mbar (providers): %s\n",
              ifelse(is.na(rm_breakdown_prov), "0 (not robust at Mbar=0)",
                     as.character(rm_breakdown_prov))))
} else {
  rm_breakdown_prov <- NA
}

# Smoothness restriction approach (Delta^SD)
honest_sd_prov <- tryCatch({
  createSensitivityResults(
    betahat = es_coef_vec,
    sigma = es_vcov_mat,
    numPrePeriods = n_pre,
    numPostPeriods = n_post,
    Mvec = seq(0, 0.1, by = 0.01),
    alpha = 0.05
  )
}, error = function(e) {
  cat(sprintf("  HonestDiD SD failed: %s\n", e$message))
  NULL
})

if (!is.null(honest_sd_prov)) {
  cat("  HonestDiD smoothness (providers):\n")
  print(honest_sd_prov)
}

# Now for beneficiaries
es_ct_bene <- coeftable(results$es_bene)
es_names_bene <- rownames(es_ct_bene)
es_idx_bene <- grep("event_m_covid::", es_names_bene)
es_df_bene <- as.data.frame(es_ct_bene[es_idx_bene, , drop = FALSE])
es_df_bene$event_time <- as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1",
                                          es_names_bene[es_idx_bene]))
es_df_bene <- es_df_bene[order(es_df_bene$event_time), ]

# Trim to 12 pre + 12 post (same as providers, for computational feasibility)
pre_idx_b <- which(es_df_bene$event_time >= -12 & es_df_bene$event_time < -1)
post_idx_b <- which(es_df_bene$event_time >= 0 & es_df_bene$event_time <= 11)
n_pre_b <- length(pre_idx_b)
n_post_b <- length(post_idx_b)
keep_idx_b <- c(pre_idx_b, post_idx_b)
es_coef_bene <- es_df_bene$Estimate[keep_idx_b]
names(es_coef_bene) <- NULL

full_vcov_bene <- vcov(results$es_bene)
full_names_bene <- es_names_bene[es_idx_bene]
ordered_names_bene <- full_names_bene[order(es_df_bene$event_time)]
keep_names_bene <- ordered_names_bene[keep_idx_b]
es_vcov_bene <- full_vcov_bene[keep_names_bene, keep_names_bene]

honest_rm_bene <- tryCatch({
  createSensitivityResults_relativeMagnitudes(
    betahat = es_coef_bene,
    sigma = es_vcov_bene,
    numPrePeriods = n_pre_b,
    numPostPeriods = n_post_b,
    Mbarvec = seq(0, 2, by = 0.25),
    alpha = 0.05
  )
}, error = function(e) {
  cat(sprintf("  HonestDiD RM failed (bene): %s\n", e$message))
  NULL
})

if (!is.null(honest_rm_bene)) {
  cat("  HonestDiD relative magnitudes (beneficiaries):\n")
  print(honest_rm_bene)
  rm_breakdown_bene <- NA
  for (row_i in seq_len(nrow(honest_rm_bene))) {
    lb <- honest_rm_bene$lb[row_i]
    ub <- honest_rm_bene$ub[row_i]
    if (!is.na(lb) && !is.na(ub) && (lb > 0 || ub < 0)) {
      rm_breakdown_bene <- honest_rm_bene$Mbar[row_i]
    }
  }
  cat(sprintf("  Breakdown Mbar (beneficiaries): %s\n",
              ifelse(is.na(rm_breakdown_bene), "0", as.character(rm_breakdown_bene))))
} else {
  rm_breakdown_bene <- NA
}


## ---- 10. Conditional Randomization Inference (within Census divisions) ----
cat("\n=== Robustness 10: Conditional RI (within Census divisions) ===\n")

# Assign Census divisions
division_map <- data.table(
  state = c("CT","ME","MA","NH","RI","VT",
            "NJ","NY","PA",
            "IL","IN","MI","OH","WI",
            "IA","KS","MN","MO","NE","ND","SD",
            "DE","DC","FL","GA","MD","NC","SC","VA","WV",
            "AL","KY","MS","TN",
            "AR","LA","OK","TX",
            "AZ","CO","ID","MT","NV","NM","UT","WY",
            "AK","CA","HI","OR","WA"),
  division = c(rep("New England", 6),
               rep("Mid Atlantic", 3),
               rep("E N Central", 5),
               rep("W N Central", 7),
               rep("S Atlantic", 9),
               rep("E S Central", 4),
               rep("W S Central", 4),
               rep("Mountain", 8),
               rep("Pacific", 5))
)

state_exits_div <- merge(state_exits, division_map, by = "state", all.x = TRUE)

set.seed(2024)
n_perm_cond <- 5000
cond_perm_coefs <- numeric(n_perm_cond)
cond_perm_coefs_bene <- numeric(n_perm_cond)

for (i in seq_len(n_perm_cond)) {
  # Permute exit_rate WITHIN divisions
  perm_exits <- copy(state_exits_div)
  perm_exits[, perm_exit_rate := {
    er <- exit_rate[match(.SD$state, state)]
    sample(er)
  }, by = division]

  perm_map <- perm_exits[, .(state, perm_exit_rate)]
  perm_data <- merge(hcbs_panel[, !c("exit_rate"), with = FALSE],
                     perm_map, by = "state")
  perm_data[, post_covid_num := as.integer(month_date >= "2020-03-01")]

  perm_fit <- tryCatch(
    feols(ln_providers ~ post_covid_num:perm_exit_rate + unemp_rate |
            state + month_date,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )
  perm_fit_bene <- tryCatch(
    feols(ln_beneficiaries ~ post_covid_num:perm_exit_rate + unemp_rate |
            state + month_date,
          data = perm_data, cluster = ~state),
    error = function(e) NULL
  )

  cond_perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit)["post_covid_num:perm_exit_rate"] else NA
  cond_perm_coefs_bene[i] <- if (!is.null(perm_fit_bene)) coef(perm_fit_bene)["post_covid_num:perm_exit_rate"] else NA
}

cond_ri_pvalue <- mean(abs(cond_perm_coefs) >= abs(true_coef), na.rm = TRUE)
cond_ri_pvalue_bene <- mean(abs(cond_perm_coefs_bene) >= abs(true_coef_bene), na.rm = TRUE)
cat(sprintf("Conditional RI p-value (providers, %d perms): %.3f\n", n_perm_cond, cond_ri_pvalue))
cat(sprintf("Conditional RI p-value (beneficiaries): %.3f\n", cond_ri_pvalue_bene))


## ---- 11. Binarized Treatment + augsynth (Ben-Michael et al. 2021) ----
cat("\n=== Robustness 11: augsynth with Binarized Treatment ===\n")

# Binarize: above-median exit rate = treated
hcbs_binary <- copy(hcbs_panel)
med_exit <- median(state_exits$exit_rate, na.rm = TRUE)
hcbs_binary[, treated := as.integer(exit_rate > med_exit)]
hcbs_binary[, treated_post := treated * as.integer(month_date >= "2020-03-01")]

# augsynth needs a data.frame with unit, time, treatment indicator
asyn_data <- as.data.frame(hcbs_binary[, .(
  state, month_date, ln_providers, treated_post, treated
)])
# Create a single treatment indicator for augsynth (1 when treated AND post)
asyn_data$trt <- asyn_data$treated * as.integer(asyn_data$month_date >= "2020-03-01")

asyn_result <- tryCatch({
  augsynth(
    ln_providers ~ trt,
    unit = state, time = month_date,
    data = asyn_data[asyn_data$treated == 1 | asyn_data$treated == 0, ],
    progfunc = "Ridge", scm = TRUE
  )
}, error = function(e) {
  cat(sprintf("  augsynth failed: %s\n", e$message))
  # Try simpler specification
  tryCatch({
    augsynth(
      ln_providers ~ trt,
      unit = state, time = month_date,
      data = asyn_data,
      progfunc = "Ridge", scm = FALSE
    )
  }, error = function(e2) {
    cat(sprintf("  augsynth fallback also failed: %s\n", e2$message))
    NULL
  })
})

if (!is.null(asyn_result)) {
  asyn_summ <- summary(asyn_result)
  cat("augsynth ATT:\n")
  print(asyn_summ)
  asyn_att <- asyn_summ$average_att$Estimate
  asyn_se <- asyn_summ$average_att$Std.Error
  cat(sprintf("  Average ATT: %.4f (SE=%.4f)\n", asyn_att, asyn_se))
} else {
  asyn_att <- NA
  asyn_se <- NA
  cat("  augsynth not available.\n")
}


## ---- 12. Exit Timing Validation (McCrary-style) ----
cat("\n=== Robustness 12: Exit Timing Validation ===\n")

# Load the raw panel to get last active month for each provider
# Since we have the panel at state-month level, reconstruct exit timing
# from the underlying data (state_exits has the exit rate but not timing)
# We can approximate: look at state-month provider counts for decline patterns

# Use the HCBS panel to compute month-over-month changes as proxy
hcbs_monthly <- hcbs_panel[, .(n_providers = mean(n_providers, na.rm = TRUE)),
                            by = month_date]
hcbs_monthly[, delta_providers := n_providers - shift(n_providers, 1)]
hcbs_monthly[, pct_change := delta_providers / shift(n_providers, 1) * 100]

# Test for bunching: is the Feb 2020 decline unusually large vs trend?
pre_covid_monthly <- hcbs_monthly[month_date >= "2018-07-01" & month_date < "2020-03-01"]
pre_covid_monthly[, time_idx := .I]

if (nrow(pre_covid_monthly) > 5) {
  trend_fit <- lm(delta_providers ~ time_idx, data = pre_covid_monthly)
  predicted_feb2020 <- predict(trend_fit,
    newdata = data.table(time_idx = nrow(pre_covid_monthly) + 1))
  actual_feb2020 <- hcbs_monthly[month_date == "2020-02-01", delta_providers]
  actual_mar2020 <- hcbs_monthly[month_date == "2020-03-01", delta_providers]

  cat(sprintf("  Pre-COVID trend in monthly provider change: slope = %.2f/month\n",
              coef(trend_fit)["time_idx"]))
  cat(sprintf("  Predicted Feb 2020 change: %.1f\n", predicted_feb2020))
  cat(sprintf("  Actual Feb 2020 change: %.1f\n",
              ifelse(length(actual_feb2020) > 0, actual_feb2020, NA)))
  cat(sprintf("  Actual Mar 2020 change: %.1f\n",
              ifelse(length(actual_mar2020) > 0, actual_mar2020, NA)))

  # Residual test: is Feb 2020 an outlier?
  resid_sd <- sd(residuals(trend_fit))
  if (length(actual_feb2020) > 0) {
    feb_zscore <- (actual_feb2020 - predicted_feb2020) / resid_sd
    cat(sprintf("  Feb 2020 z-score: %.2f (|z| > 2 would suggest bunching)\n", feb_zscore))
  }
}

exit_timing <- list(
  monthly = hcbs_monthly,
  pre_trend = if (exists("trend_fit")) trend_fit else NULL,
  feb_zscore = if (exists("feb_zscore")) feb_zscore else NA
)


## ---- 13. Anderson-Rubin Weak-IV Confidence Set ----
cat("\n=== Robustness 13: Anderson-Rubin Confidence Set ===\n")

# Grid search over beta values for the IV
# For each beta0: test H0: beta = beta0 using reduced-form F-stat
# AR confidence set = all beta0 where p > 0.05

if (!is.null(results$iv_providers)) {
  iv_coef <- coef(results$iv_providers)["post_covid_num:predicted_exit_rate"]

  beta_grid <- seq(iv_coef - 10, iv_coef + 10, by = 0.5)
  ar_pvalues <- numeric(length(beta_grid))

  for (j in seq_along(beta_grid)) {
    beta0 <- beta_grid[j]
    # Under H0: beta = beta0, construct Y_adj = Y - beta0 * Z * Post
    hcbs_panel[, y_adj := ln_providers - beta0 * post_covid_num * predicted_exit_rate]

    ar_fit <- tryCatch(
      feols(y_adj ~ post_covid_num:predicted_exit_rate + unemp_rate |
              state + month_date,
            data = hcbs_panel, cluster = ~state),
      error = function(e) NULL
    )

    if (!is.null(ar_fit)) {
      ar_t <- coef(ar_fit)["post_covid_num:predicted_exit_rate"] /
              se(ar_fit)["post_covid_num:predicted_exit_rate"]
      ar_pvalues[j] <- 2 * pt(-abs(ar_t), df = length(unique(hcbs_panel$state)) - 1)
    } else {
      ar_pvalues[j] <- NA
    }
  }

  # AR confidence set: beta values where p > 0.05
  ar_ci <- beta_grid[ar_pvalues > 0.05]
  if (length(ar_ci) > 0) {
    ar_ci_lo <- min(ar_ci)
    ar_ci_hi <- max(ar_ci)
    ar_bounded <- TRUE
    cat(sprintf("  AR 95%% CI: [%.2f, %.2f]\n", ar_ci_lo, ar_ci_hi))
  } else {
    ar_ci_lo <- -Inf
    ar_ci_hi <- Inf
    ar_bounded <- FALSE
    cat("  AR confidence set is empty (all rejected) or unbounded.\n")
  }

  # Clean up temp column
  hcbs_panel[, y_adj := NULL]
} else {
  ar_ci_lo <- NA
  ar_ci_hi <- NA
  ar_bounded <- NA
  cat("  IV model not available.\n")
}


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
  true_coef_bene = true_coef_bene,
  wcb_providers = wcb_providers,
  wcb_bene = wcb_bene,
  # v3 additions
  honest_rm_prov = honest_rm_prov,
  honest_sd_prov = honest_sd_prov,
  honest_rm_bene = honest_rm_bene,
  rm_breakdown_prov = rm_breakdown_prov,
  rm_breakdown_bene = rm_breakdown_bene,
  cond_ri_pvalue = cond_ri_pvalue,
  cond_ri_pvalue_bene = cond_ri_pvalue_bene,
  cond_perm_coefs = cond_perm_coefs,
  asyn_result = asyn_result,
  asyn_att = asyn_att,
  asyn_se = asyn_se,
  exit_timing = exit_timing,
  ar_ci_lo = ar_ci_lo,
  ar_ci_hi = ar_ci_hi,
  ar_bounded = ar_bounded
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
