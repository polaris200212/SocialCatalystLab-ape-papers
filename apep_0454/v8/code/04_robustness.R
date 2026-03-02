## ============================================================================
## 04_robustness.R — Robustness checks for apep_0454 v8
##
## 1. Alternative exit definitions
## 2. Placebo tests
## 3. Randomization inference (unconditional)
## 3b. RI for beneficiary outcomes
## 3c. Non-HCBS falsification
## 3d. Full sample comparison
## 4. Leave-one-out jackknife
## 5. Controls sensitivity
## 6. DDD robustness
## 7. Exclusion restriction test
## 8. Wild Cluster Bootstrap
## 9. HonestDiD
## 10. Conditional RI (within Census divisions)
## 11. augsynth
## 12. Exit timing validation
## 13. Anderson-Rubin CI
## 14. STRATIFIED RI (v8: Census regions, urbanicity, governor party)
## 15. ENTITY-TYPE HETEROGENEITY (v8: Type 1 vs Type 2)
## 16. Legacy exit rate comparison (v8: pandemic vs pre-period)
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))

hcbs_panel <- panel[prov_type == "HCBS"]

## ---- 1. Alternative exit definitions ----
cat("=== Robustness 1: Alternative exit window definitions ===\n")

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

hcbs_panel[, event_m_placebo := round(as.numeric(difftime(month_date,
                                       as.Date("2019-03-01"), units = "days")) / 30.44)]
hcbs_panel[, event_m_placebo := pmax(-12, pmin(12, event_m_placebo))]

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

set.seed(42)
n_perm <- 2000
true_coef <- coef(results$did_covid)["post_covid_num:exit_rate"]

perm_coefs <- numeric(n_perm)
states <- unique(hcbs_panel$state)

for (i in seq_len(n_perm)) {
  perm_map <- data.table(state = states,
                         perm_exit_rate = sample(state_exits$exit_rate_pre[match(states, state_exits$state)]))
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
                         perm_exit_rate = sample(state_exits$exit_rate_pre[match(states, state_exits$state)]))
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

## ---- 3d. Full sample comparison ----
cat("\n=== Robustness 3d: Full Sample (Untruncated) ===\n")
cat("NOTE: Primary analysis truncated at June 2024 in v8.\n")

panel_full <- readRDS(file.path(DATA_DIR, "panel_full.rds"))
panel_full[, post_covid_num := as.integer(post_covid)]
panel_full[, ln_providers := log(pmax(n_providers, 1))]
if (!"unemp_rate" %in% names(panel_full) || all(is.na(panel_full$unemp_rate))) {
  panel_full[, unemp_rate := 0]
} else {
  panel_full[is.na(unemp_rate), unemp_rate := 0]
}

rob_full_sample <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = panel_full[prov_type == "HCBS"],
  cluster = ~state
)
cat("Full sample (untruncated) for comparison:\n")
summary(rob_full_sample)

rob_truncated <- results$did_covid

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

rob_no_controls <- feols(
  ln_providers ~ post_covid_num:exit_rate |
    state + month_date,
  data = hcbs_panel, cluster = ~state
)

rob_full_controls <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate +
    post_covid_num:poverty_rate + post_covid_num:median_age +
    post_covid_num:pct_black |
    state + month_date,
  data = hcbs_panel, cluster = ~state
)

if ("stringency" %in% names(hcbs_panel)) {
  rob_stringency <- feols(
    ln_providers ~ post_covid_num:exit_rate + unemp_rate + stringency |
      state + month_date,
    data = hcbs_panel[!is.na(stringency)], cluster = ~state
  )
} else {
  rob_stringency <- NULL
}

## ---- 6. DDD robustness ----
cat("\n=== Robustness 6: DDD alternative specifications ===\n")

ddd_continuous_rob <- feols(
  ln_beneficiaries ~ exit_rate_x_post_arpa_hcbs +
    exit_rate_x_post_arpa + exit_rate_x_hcbs +
    post_arpa_hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel, cluster = ~state
)

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

state_month_pre <- panel[prov_type == "HCBS" & month_date < "2020-03-01",
                          .(state, month_date, covid_deaths, predicted_exit_rate)] |>
  unique(by = c("state", "month_date"))

if ("covid_deaths" %in% names(state_month_pre) && any(!is.na(state_month_pre$covid_deaths))) {
  excl_test <- tryCatch(
    feols(covid_deaths ~ predicted_exit_rate | month_date,
          data = state_month_pre[!is.na(covid_deaths)], cluster = ~state),
    error = function(e) {
      cat("Exclusion test with FE failed, running simple OLS.\n")
      lm(covid_deaths ~ predicted_exit_rate, data = state_month_pre[!is.na(covid_deaths)])
    }
  )
  cat("Exclusion restriction test (predicted exit -> pre-COVID deaths):\n")
  summary(excl_test)
} else {
  cat("Pre-COVID death data not available for exclusion test.\n")
}

## ---- 8. Wild Cluster Bootstrap ----
cat("\n=== Robustness 8: Wild Cluster Bootstrap ===\n")

set.seed(123)
n_boot <- 999

wild_cluster_boot <- function(unrestricted_model, param_name, data_dt, dep_var,
                              cluster_var = "state", n_boot = 999) {
  clusters <- unique(data_dt[[cluster_var]])
  n_clusters <- length(clusters)
  orig_t <- coef(unrestricted_model)[param_name] / se(unrestricted_model)[param_name]

  # Restricted model: just FE (skip unemp_rate if it's collinear/constant)
  has_unemp_var <- "unemp_rate" %in% names(data_dt) && var(data_dt$unemp_rate, na.rm = TRUE) > 0
  restricted_formula <- if (has_unemp_var) {
    paste0(dep_var, " ~ unemp_rate | state + month_date")
  } else {
    paste0(dep_var, " ~ 1 | state + month_date")
  }
  unrestricted_formula <- if (has_unemp_var) {
    paste0(dep_var, " ~ post_covid_num:exit_rate + unemp_rate | state + month_date")
  } else {
    paste0(dep_var, " ~ post_covid_num:exit_rate | state + month_date")
  }

  restricted_fit <- feols(
    as.formula(restricted_formula),
    data = data_dt, cluster = as.formula(paste0("~", cluster_var))
  )
  restricted_fitted <- fitted(restricted_fit)
  restricted_resid <- residuals(restricted_fit)

  boot_t <- numeric(n_boot)

  for (b in seq_len(n_boot)) {
    weights <- sample(c(-1, 1), n_clusters, replace = TRUE)
    names(weights) <- clusters

    boot_data <- copy(data_dt)
    boot_data[, boot_weight := weights[get(cluster_var)]]
    boot_data[, (dep_var) := restricted_fitted + boot_weight * restricted_resid]

    boot_fit <- tryCatch(
      feols(as.formula(unrestricted_formula),
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

cat("WCB for providers...\n")
wcb_providers <- wild_cluster_boot(
  results$did_covid, "post_covid_num:exit_rate", hcbs_panel,
  dep_var = "ln_providers", n_boot = 999
)
cat(sprintf("  WCB p-value (providers): %.3f (orig t=%.2f, %d valid boots)\n",
            wcb_providers$p_value, wcb_providers$orig_t, wcb_providers$n_valid))

cat("WCB for beneficiaries...\n")
wcb_bene <- wild_cluster_boot(
  results$did_bene, "post_covid_num:exit_rate", hcbs_panel,
  dep_var = "ln_beneficiaries", n_boot = 999
)
cat(sprintf("  WCB p-value (beneficiaries): %.3f (orig t=%.2f, %d valid boots)\n",
            wcb_bene$p_value, wcb_bene$orig_t, wcb_bene$n_valid))

## ---- 9. HonestDiD Sensitivity Bounds ----
cat("\n=== Robustness 9: HonestDiD Sensitivity Bounds ===\n")

es_ct_prov <- coeftable(results$es_providers)
es_names_prov <- rownames(es_ct_prov)
es_idx_prov <- grep("event_m_covid::", es_names_prov)
es_df_prov <- as.data.frame(es_ct_prov[es_idx_prov, , drop = FALSE])
es_df_prov$event_time <- as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1",
                                          es_names_prov[es_idx_prov]))
es_df_prov <- es_df_prov[order(es_df_prov$event_time), ]

pre_idx <- which(es_df_prov$event_time >= -12 & es_df_prov$event_time < -1)
post_idx <- which(es_df_prov$event_time >= 0 & es_df_prov$event_time <= 11)
n_pre <- length(pre_idx)
n_post <- length(post_idx)

keep_idx <- c(pre_idx, post_idx)
es_coef_vec <- es_df_prov$Estimate[keep_idx]
names(es_coef_vec) <- NULL

full_vcov <- vcov(results$es_providers)
full_names <- es_names_prov[es_idx_prov]
ordered_names <- full_names[order(es_df_prov$event_time)]
keep_names <- ordered_names[keep_idx]
es_vcov_mat <- full_vcov[keep_names, keep_names]

cat(sprintf("  n_pre = %d, n_post = %d (trimmed for HonestDiD)\n", n_pre, n_post))

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

# Beneficiaries
es_ct_bene <- coeftable(results$es_bene)
es_names_bene <- rownames(es_ct_bene)
es_idx_bene <- grep("event_m_covid::", es_names_bene)
es_df_bene <- as.data.frame(es_ct_bene[es_idx_bene, , drop = FALSE])
es_df_bene$event_time <- as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1",
                                          es_names_bene[es_idx_bene]))
es_df_bene <- es_df_bene[order(es_df_bene$event_time), ]

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


## ---- 10. Conditional RI (within Census divisions) ----
cat("\n=== Robustness 10: Conditional RI (within Census divisions) ===\n")

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

region_map <- data.table(
  state = division_map$state,
  region = fcase(
    division_map$division %in% c("New England", "Mid Atlantic"), "Northeast",
    division_map$division %in% c("E N Central", "W N Central"), "Midwest",
    division_map$division %in% c("S Atlantic", "E S Central", "W S Central"), "South",
    division_map$division %in% c("Mountain", "Pacific"), "West"
  )
)

state_exits_div <- merge(state_exits, division_map, by = "state", all.x = TRUE)
state_exits_div <- merge(state_exits_div, region_map, by = "state", all.x = TRUE)

set.seed(2024)
n_perm_cond <- 5000
cond_perm_coefs <- numeric(n_perm_cond)
cond_perm_coefs_bene <- numeric(n_perm_cond)

for (i in seq_len(n_perm_cond)) {
  perm_exits <- copy(state_exits_div)
  perm_exits[, perm_exit_rate := {
    er <- exit_rate_pre[match(.SD$state, state)]
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


## ---- 11. augsynth ----
cat("\n=== Robustness 11: augsynth with Binarized Treatment ===\n")

hcbs_binary <- copy(hcbs_panel)
med_exit <- median(state_exits$exit_rate_pre, na.rm = TRUE)
hcbs_binary[, treated := as.integer(exit_rate > med_exit)]
hcbs_binary[, treated_post := treated * as.integer(month_date >= "2020-03-01")]

asyn_data <- as.data.frame(hcbs_binary[, .(
  state, month_date, ln_providers, treated_post, treated
)])
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


## ---- 12. Exit Timing Validation ----
cat("\n=== Robustness 12: Exit Timing Validation ===\n")

hcbs_monthly <- hcbs_panel[, .(n_providers = mean(n_providers, na.rm = TRUE)),
                            by = month_date]
hcbs_monthly[, delta_providers := n_providers - shift(n_providers, 1)]
hcbs_monthly[, pct_change := delta_providers / shift(n_providers, 1) * 100]

pre_covid_monthly <- hcbs_monthly[month_date >= "2018-07-01" & month_date < "2020-03-01"]
pre_covid_monthly[, time_idx := .I]

feb_zscore <- NA
if (nrow(pre_covid_monthly) > 5) {
  trend_fit <- lm(delta_providers ~ time_idx, data = pre_covid_monthly)
  predicted_feb2020 <- predict(trend_fit,
    newdata = data.table(time_idx = nrow(pre_covid_monthly) + 1))
  actual_feb2020 <- hcbs_monthly[month_date == "2020-02-01", delta_providers]

  resid_sd <- sd(residuals(trend_fit))
  if (length(actual_feb2020) > 0) {
    feb_zscore <- (actual_feb2020 - predicted_feb2020) / resid_sd
    cat(sprintf("  Feb 2020 z-score: %.2f (|z| > 2 would suggest bunching)\n", feb_zscore))
  }
}

exit_timing <- list(
  monthly = hcbs_monthly,
  pre_trend = if (exists("trend_fit")) trend_fit else NULL,
  feb_zscore = feb_zscore
)


## ---- 13. Anderson-Rubin CI ----
cat("\n=== Robustness 13: Anderson-Rubin Confidence Set ===\n")

if (!is.null(results$iv_providers)) {
  iv_coef <- coef(results$iv_providers)["post_covid_num:predicted_exit_rate"]

  beta_grid <- seq(iv_coef - 10, iv_coef + 10, by = 0.5)
  ar_pvalues <- numeric(length(beta_grid))

  for (j in seq_along(beta_grid)) {
    beta0 <- beta_grid[j]
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
    cat("  AR confidence set is empty or unbounded.\n")
  }

  hcbs_panel[, y_adj := NULL]
} else {
  ar_ci_lo <- NA
  ar_ci_hi <- NA
  ar_bounded <- NA
  cat("  IV model not available.\n")
}


## =========================================================================
## 14. STRATIFIED RI (v8: Census regions, urbanicity, governor party)
## =========================================================================

cat("\n=== Robustness 14: Stratified RI (v8) ===\n")

## --- 14a. Census regions (4 strata) ---
cat("\n--- 14a: RI within Census Regions ---\n")

set.seed(2025)
n_perm_strat <- 1000
region_perm_coefs <- numeric(n_perm_strat)

for (i in seq_len(n_perm_strat)) {
  perm_exits <- copy(state_exits_div)
  perm_exits[, perm_exit_rate := {
    er <- exit_rate_pre[match(.SD$state, state)]
    sample(er)
  }, by = region]

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
  region_perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit)["post_covid_num:perm_exit_rate"] else NA
}

ri_pvalue_region <- mean(abs(region_perm_coefs) >= abs(true_coef), na.rm = TRUE)
cat(sprintf("RI p-value (Census regions, %d perms): %.3f\n", n_perm_strat, ri_pvalue_region))

## --- 14b. Urbanicity quartiles ---
cat("\n--- 14b: RI within Urbanicity Quartiles ---\n")

pop_dt <- unique(panel[, .(state, population)])
state_exits_urban <- merge(state_exits_div, pop_dt, by = "state", all.x = TRUE)
state_exits_urban[, urban_quartile := cut(population,
                                           breaks = quantile(population, probs = 0:4/4, na.rm = TRUE),
                                           labels = c("UQ1", "UQ2", "UQ3", "UQ4"),
                                           include.lowest = TRUE)]

urban_perm_coefs <- numeric(n_perm_strat)

set.seed(2026)
for (i in seq_len(n_perm_strat)) {
  perm_exits <- copy(state_exits_urban)
  perm_exits[, perm_exit_rate := {
    er <- exit_rate_pre[match(.SD$state, state)]
    sample(er)
  }, by = urban_quartile]

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
  urban_perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit)["post_covid_num:perm_exit_rate"] else NA
}

ri_pvalue_urban <- mean(abs(urban_perm_coefs) >= abs(true_coef), na.rm = TRUE)
cat(sprintf("RI p-value (urbanicity quartiles, %d perms): %.3f\n", n_perm_strat, ri_pvalue_urban))

## --- 14c. Governor party 2019 ---
cat("\n--- 14c: RI within Governor Party ---\n")

gov_party <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
            "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
            "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
            "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
            "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"),
  gov_party_2019 = c("R","R","R","R","D","D","D","D","R","R",
                      "D","R","D","R","R","D","D","D","D","R",
                      "R","D","D","R","R","D","R","D","R","D",
                      "D","D","D","R","R","R","D","D","D","R",
                      "R","R","R","R","R","D","D","R","D","R","D")
)

state_exits_gov <- merge(state_exits_div, gov_party, by = "state", all.x = TRUE)

gov_perm_coefs <- numeric(n_perm_strat)

set.seed(2027)
for (i in seq_len(n_perm_strat)) {
  perm_exits <- copy(state_exits_gov)
  perm_exits[, perm_exit_rate := {
    er <- exit_rate_pre[match(.SD$state, state)]
    sample(er)
  }, by = gov_party_2019]

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
  gov_perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit)["post_covid_num:perm_exit_rate"] else NA
}

ri_pvalue_gov <- mean(abs(gov_perm_coefs) >= abs(true_coef), na.rm = TRUE)
cat(sprintf("RI p-value (governor party, %d perms): %.3f\n", n_perm_strat, ri_pvalue_gov))

## RI summary
cat("\n--- RI SUMMARY ---\n")
cat(sprintf("  Unconditional:        p = %.3f (%d perms)\n", ri_pvalue, n_perm))
cat(sprintf("  Census divisions:     p = %.3f (%d perms)\n", cond_ri_pvalue, n_perm_cond))
cat(sprintf("  Census regions:       p = %.3f (%d perms)\n", ri_pvalue_region, n_perm_strat))
cat(sprintf("  Urbanicity quartiles: p = %.3f (%d perms)\n", ri_pvalue_urban, n_perm_strat))
cat(sprintf("  Governor party 2019:  p = %.3f (%d perms)\n", ri_pvalue_gov, n_perm_strat))


## =========================================================================
## 15. ENTITY-TYPE HETEROGENEITY (v8)
## =========================================================================

cat("\n=== Robustness 15: Entity-Type Heterogeneity (v8) ===\n\n")

entity_panel <- readRDS(file.path(DATA_DIR, "entity_panel_clean.rds"))

## Type 1 (Individual)
ent1_panel <- entity_panel[entity_type == "1"]
ent1_panel[, post_covid_num := as.integer(post_covid)]

did_ent1 <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = ent1_panel,
  cluster = ~state
)

cat("Entity Type 1 (Individual) — ln(providers):\n")
summary(did_ent1)

es_ent1 <- feols(
  ln_providers ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = ent1_panel,
  cluster = ~state
)

## Type 2 (Organization)
ent2_panel <- entity_panel[entity_type == "2"]
ent2_panel[, post_covid_num := as.integer(post_covid)]

did_ent2 <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = ent2_panel,
  cluster = ~state
)

cat("\nEntity Type 2 (Organization) — ln(providers):\n")
summary(did_ent2)

es_ent2 <- feols(
  ln_providers ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = ent2_panel,
  cluster = ~state
)

## Beneficiary outcomes by entity type
did_ent1_bene <- feols(
  ln_beneficiaries ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = ent1_panel,
  cluster = ~state
)

did_ent2_bene <- feols(
  ln_beneficiaries ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = ent2_panel,
  cluster = ~state
)

cat("\nEntity Type 1 — ln(beneficiaries):\n")
summary(did_ent1_bene)
cat("\nEntity Type 2 — ln(beneficiaries):\n")
summary(did_ent2_bene)


## =========================================================================
## 16. Legacy Exit Rate Comparison (v8)
## =========================================================================

cat("\n=== Robustness 16: Legacy (Pandemic) vs Pre-Period Exit Rate ===\n\n")

hcbs_panel_legacy <- copy(hcbs_panel)
hcbs_panel_legacy[, exit_rate_old := state_exits$exit_rate_pandemic[match(state, state_exits$state)]]
hcbs_panel_legacy[, post_covid_num := as.integer(post_covid)]

did_pandemic_exit <- feols(
  ln_providers ~ post_covid_num:exit_rate_old + unemp_rate |
    state + month_date,
  data = hcbs_panel_legacy,
  cluster = ~state
)

cat("Pandemic exit rate (old definition) — ln(providers):\n")
summary(did_pandemic_exit)

cat(sprintf("\nComparison:\n"))
cat(sprintf("  Pre-period exit rate: %.4f (SE=%.4f)\n",
            coef(results$did_covid)["post_covid_num:exit_rate"],
            se(results$did_covid)["post_covid_num:exit_rate"]))
cat(sprintf("  Pandemic exit rate:   %.4f (SE=%.4f)\n",
            coef(did_pandemic_exit)["post_covid_num:exit_rate_old"],
            se(did_pandemic_exit)["post_covid_num:exit_rate_old"]))


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
  rob_full_sample = rob_full_sample,
  ddd_continuous_rob = ddd_continuous_rob,
  ddd_covid_control = ddd_covid_control,
  true_coef = true_coef,
  true_coef_bene = true_coef_bene,
  wcb_providers = wcb_providers,
  wcb_bene = wcb_bene,
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
  ar_bounded = ar_bounded,
  # v8: Stratified RI
  ri_pvalue_region = ri_pvalue_region,
  ri_pvalue_urban = ri_pvalue_urban,
  ri_pvalue_gov = ri_pvalue_gov,
  region_perm_coefs = region_perm_coefs,
  urban_perm_coefs = urban_perm_coefs,
  gov_perm_coefs = gov_perm_coefs,
  # v8: Entity-type
  did_ent1 = did_ent1,
  did_ent2 = did_ent2,
  es_ent1 = es_ent1,
  es_ent2 = es_ent2,
  did_ent1_bene = did_ent1_bene,
  did_ent2_bene = did_ent2_bene,
  # v8: Legacy exit rate
  did_pandemic_exit = did_pandemic_exit
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
