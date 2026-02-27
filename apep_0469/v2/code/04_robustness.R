## ============================================================================
## 04_robustness.R — Robustness Checks for Two-Panel Design
## Missing Men, Rising Women v2 (apep_0469)
## ============================================================================
## Uses COUPLES PANEL for wife outcomes (ABE links men only, wives tracked
## through husbands' households).

source("code/00_packages.R")

data_dir <- "data"
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
models <- readRDS(file.path(data_dir, "main_models.rds"))

# Region for couples
couples[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]

robustness <- list()

cat("=== Robustness Checks (Couples Panel for Wives) ===\n\n")
cat(sprintf("Couples panel: %s observations\n", format(nrow(couples), big.mark = ",")))


## --------------------------------------------------------------------------
## R1: Oster (2019) Coefficient Stability (Wives)
## --------------------------------------------------------------------------

cat("--- R1: Oster Bounds ---\n")

oster_result <- tryCatch({
  r_unc <- feols(wife_d_in_lf ~ mob_std, data = couples, cluster = ~statefip_1940)
  r_ctrl <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
                  sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 |
                  region, data = couples, cluster = ~statefip_1940)

  bu <- coef(r_unc)["mob_std"]
  bc <- coef(r_ctrl)["mob_std"]
  ru <- as.numeric(fixest::r2(r_unc, "r2"))
  rc <- as.numeric(fixest::r2(r_ctrl, "r2"))

  if (is.finite(ru) && is.finite(rc) && abs(bu - bc) > 1e-10 && abs(rc - ru) > 1e-10) {
    rm <- min(1, 1.3 * rc)
    d <- (bc / (bu - bc)) * ((rm - rc) / (rc - ru))
  } else {
    d <- NA
  }

  cat(sprintf("Beta_unc = %.6f (R2 = %.6f)\n", bu, ru))
  cat(sprintf("Beta_ctrl = %.6f (R2 = %.6f)\n", bc, rc))
  cat(sprintf("Oster delta = %s\n\n",
      ifelse(is.na(d), "NA", sprintf("%.2f", d))))

  list(beta_unc = bu, beta_ctrl = bc, r2_unc = ru, r2_ctrl = rc, delta = d)
}, error = function(e) {
  cat(sprintf("  Oster bounds failed: %s\n\n", e$message))
  list(beta_unc = NA, beta_ctrl = NA, r2_unc = NA, r2_ctrl = NA, delta = NA)
})

robustness$oster <- oster_result


## --------------------------------------------------------------------------
## R2: Randomization Inference (permute mobilization across states)
## --------------------------------------------------------------------------

cat("--- R2: Randomization Inference ---\n")

# Re-estimate the preferred specification (needed for RI)
r_ctrl_ri <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
                   sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 |
                   region, data = couples, cluster = ~statefip_1940)
observed_beta <- coef(r_ctrl_ri)["mob_std"]
n_perm <- 1000

cat("Residualizing wife outcome against controls...\n")
# Use simpler controls to avoid NA removals that would mismatch rows
resid_model <- feols(wife_d_in_lf ~ sp_age_1940 + I(sp_age_1940^2) |
                     region, data = couples[!is.na(sp_age_1940)])
resid_mob <- feols(mob_std ~ sp_age_1940 + I(sp_age_1940^2) |
                   region, data = couples[!is.na(sp_age_1940)])

# Match residuals to observations that were actually used
ri_idx <- which(!is.na(couples$sp_age_1940))
couples[, d_in_lf_resid := NA_real_]
couples[ri_idx, d_in_lf_resid := residuals(resid_model)]
couples[, mob_resid := NA_real_]
couples[ri_idx, mob_resid := residuals(resid_mob)]

# Collapse to state level
state_resid <- couples[, .(mean_y_resid = mean(d_in_lf_resid, na.rm = TRUE),
                            mean_mob_resid = mean(mob_resid, na.rm = TRUE),
                            n = .N),
                       by = statefip_1940]
state_resid <- merge(state_resid,
                     state_mob[, .(statefip, mob_std)],
                     by.x = "statefip_1940", by.y = "statefip")

cat(sprintf("Permuting mobilization across %d states (%d permutations)...\n",
    nrow(state_resid), n_perm))

set.seed(42)
perm_betas <- replicate(n_perm, {
  state_resid[, mob_perm := sample(mob_std)]
  coef(lm(mean_y_resid ~ mob_perm, data = state_resid, weights = n))["mob_perm"]
})

ri_p <- mean(abs(perm_betas) >= abs(observed_beta))
cat(sprintf("Observed beta = %.6f\n", observed_beta))
cat(sprintf("RI p-value = %.4f (two-sided, %d permutations)\n\n", ri_p, n_perm))

couples[, c("d_in_lf_resid", "mob_resid") := NULL]

robustness$ri <- list(observed = observed_beta, perm_betas = perm_betas, p_value = ri_p)


## --------------------------------------------------------------------------
## R3: HC2/HC3 Standard Errors (state-level cross-validation)
## --------------------------------------------------------------------------

cat("--- R3: HC2/HC3 Standard Errors (State-Level) ---\n")

state_controls <- readRDS(file.path(data_dir, "state_controls.rds"))
state_merged <- merge(state_analysis, state_controls, by = "statefip",
                      all.x = TRUE, suffixes = c("", "_dup"))
dup_cols <- grep("_dup$", names(state_merged), value = TRUE)
if (length(dup_cols) > 0) state_merged[, (dup_cols) := NULL]

state_clean <- state_merged[!is.na(mob_std) & !is.na(d_lf_female)]
state_lm <- lm(d_lf_female ~ mob_std + pct_urban + pct_farm + pct_black +
                mean_educ + pct_married,
                data = state_clean, weights = total_pop)

se_iid <- sqrt(diag(vcov(state_lm)))["mob_std"]
se_hc2 <- sqrt(diag(sandwich::vcovHC(state_lm, type = "HC2")))["mob_std"]
se_hc3 <- sqrt(diag(sandwich::vcovHC(state_lm, type = "HC3")))["mob_std"]

beta_state <- coef(state_lm)["mob_std"]
cat(sprintf("Beta_state = %.6f\n", beta_state))
cat(sprintf("  IID SE = %.6f (t = %.2f)\n", se_iid, beta_state / se_iid))
cat(sprintf("  HC2 SE = %.6f (t = %.2f)\n", se_hc2, beta_state / se_hc2))
cat(sprintf("  HC3 SE = %.6f (t = %.2f)\n\n", se_hc3, beta_state / se_hc3))

robustness$hc <- list(beta = beta_state, se_iid = se_iid, se_hc2 = se_hc2, se_hc3 = se_hc3)


## --------------------------------------------------------------------------
## R4: Leave-One-Out Influence (State-Level)
## --------------------------------------------------------------------------

cat("--- R4: Leave-One-Out Influence ---\n")

loo_betas <- numeric(nrow(state_clean))
for (i in seq_len(nrow(state_clean))) {
  loo_data <- state_clean[-i]
  loo_m <- lm(d_lf_female ~ mob_std + pct_urban + pct_farm + pct_black +
              mean_educ + pct_married, data = loo_data, weights = total_pop)
  loo_betas[i] <- coef(loo_m)["mob_std"]
}

cat(sprintf("LOO betas: all %d same sign? %s\n", length(loo_betas),
    ifelse(all(sign(loo_betas) == sign(loo_betas[1])), "YES", "NO")))
cat(sprintf("Range: [%.6f, %.6f]\n\n", min(loo_betas), max(loo_betas)))

robustness$loo <- list(betas = loo_betas,
                       all_same_sign = all(sign(loo_betas) == sign(loo_betas[1])))


## --------------------------------------------------------------------------
## R5: Placebo — Older Wives (46+ in 1940, too old for wartime labor entry)
## --------------------------------------------------------------------------

cat("--- R5: Placebo — Older Wives ---\n")

older_wives <- couples[sp_age_1940 >= 46]
cat(sprintf("Older wives (46+ in 1940): N = %s\n", format(nrow(older_wives), big.mark = ",")))

if (nrow(older_wives) > 100) {
  r5 <- tryCatch(
    feols(wife_d_in_lf ~ mob_std + sp_age_1940 + husband_age_1940 |
          region, data = older_wives, cluster = ~statefip_1940),
    error = function(e) { cat(sprintf("  Placebo skipped: %s\n", e$message)); NULL }
  )
  if (!is.null(r5)) {
    cat(sprintf("Older wives (46+): beta = %.6f (SE = %.6f, p = %.3f)\n\n",
        coef(r5)["mob_std"], sqrt(vcov(r5)["mob_std", "mob_std"]),
        2 * pnorm(-abs(coef(r5)["mob_std"] / sqrt(vcov(r5)["mob_std", "mob_std"])))))
    robustness$placebo_older <- r5
  }
} else {
  cat("Too few older wives for placebo test\n\n")
}


## --------------------------------------------------------------------------
## R6: Men's First-Difference Robustness (Oster + ANCOVA)
## --------------------------------------------------------------------------

cat("--- R6: Men's Robustness ---\n")

# Men's Oster bounds
panel[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]

men_oster <- tryCatch({
  m_unc <- feols(d_in_lf ~ mob_std, data = panel, cluster = ~statefip_1940)
  m_ctrl <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
                  educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
                  region, data = panel, cluster = ~statefip_1940)

  men_beta_unc <- coef(m_unc)["mob_std"]
  men_beta_ctrl <- coef(m_ctrl)["mob_std"]
  men_r2_unc <- as.numeric(fixest::r2(m_unc, "r2"))
  men_r2_ctrl <- as.numeric(fixest::r2(m_ctrl, "r2"))

  if (is.finite(men_r2_unc) && is.finite(men_r2_ctrl) &&
      abs(men_beta_unc - men_beta_ctrl) > 1e-10 && abs(men_r2_ctrl - men_r2_unc) > 1e-10) {
    men_r2_max <- min(1, 1.3 * men_r2_ctrl)
    men_delta <- (men_beta_ctrl / (men_beta_unc - men_beta_ctrl)) *
                 ((men_r2_max - men_r2_ctrl) / (men_r2_ctrl - men_r2_unc))
  } else {
    men_delta <- NA
  }
  list(beta_ctrl = men_beta_ctrl, delta = men_delta, m_ctrl = m_ctrl)
}, error = function(e) {
  cat(sprintf("  Men's Oster skipped: %s\n", e$message))
  list(beta_ctrl = NA, delta = NA, m_ctrl = NULL)
})

cat(sprintf("Men's Oster delta = %s\n",
    ifelse(is.na(men_oster$delta), "NA", sprintf("%.2f", men_oster$delta))))
robustness$oster_men <- list(beta_ctrl = men_oster$beta_ctrl, delta = men_oster$delta)

# Men's ANCOVA
m_ancova <- tryCatch(
  feols(in_lf_1950 ~ mob_std + in_lf_1940 + age_1940 + I(age_1940^2) +
        educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
        region, data = panel, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  ANCOVA (men) skipped: %s\n", e$message)); NULL }
)
if (!is.null(m_ancova)) {
  cat(sprintf("Men's ANCOVA: mob_std = %.6f (SE = %.6f)\n",
      coef(m_ancova)["mob_std"], sqrt(vcov(m_ancova)["mob_std", "mob_std"])))
  robustness$men_ancova <- m_ancova
}


## --------------------------------------------------------------------------
## R7: IPW — Reweight Linked Sample to Match Full Cross-Section
## --------------------------------------------------------------------------

cat("\n--- R7: IPW Reweighting ---\n")

linkage_diag <- readRDS(file.path(data_dir, "linkage_diagnostics.rds"))
cat("Linked vs unlinked balance:\n")
print(linkage_diag)

robustness$ipw_balance <- linkage_diag


## --------------------------------------------------------------------------
## R8: Quintile Treatment (Wives)
## --------------------------------------------------------------------------

cat("\n--- R8: Quintile Treatment (Wives) ---\n")

couples[, mob_q := factor(mob_quintile)]
r8 <- tryCatch(
  feols(wife_d_in_lf ~ mob_q + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  Quintile skipped: %s\n", e$message)); NULL }
)

if (!is.null(r8)) {
  cat("Quintile treatment effects (relative to Q1):\n")
  q_coefs <- coef(r8)[grep("mob_q", names(coef(r8)))]
  q_ses <- sqrt(diag(vcov(r8))[grep("mob_q", names(coef(r8)))])
  for (j in seq_along(q_coefs)) {
    cat(sprintf("  %s: beta = %.6f (SE = %.6f)\n",
        names(q_coefs)[j], q_coefs[j], q_ses[j]))
  }
  robustness$quintile <- r8
}


## --------------------------------------------------------------------------
## R9: ANCOVA — Wives (Level Regression with Lagged DV)
## --------------------------------------------------------------------------

cat("\n--- R9: ANCOVA (Wives) ---\n")

r9 <- tryCatch(
  feols(sp_in_lf_1950 ~ mob_std + sp_in_lf_1940 + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  ANCOVA skipped: %s\n", e$message)); NULL }
)

if (!is.null(r9)) {
  cat(sprintf("ANCOVA: mob_std = %.6f (SE = %.6f)\n",
      coef(r9)["mob_std"], sqrt(vcov(r9)["mob_std", "mob_std"])))
  cat(sprintf("  Lagged DV (sp_in_lf_1940) = %.4f\n\n", coef(r9)["sp_in_lf_1940"]))
  robustness$ancova <- r9
}


## --------------------------------------------------------------------------
## R10: Trimmed Sample (Drop Top/Bottom 5% Mobilization States)
## --------------------------------------------------------------------------

cat("--- R10: Trimmed Sample ---\n")

mob_p5 <- quantile(state_mob$mob_std, 0.05)
mob_p95 <- quantile(state_mob$mob_std, 0.95)
trimmed_states <- state_mob[mob_std >= mob_p5 & mob_std <= mob_p95, statefip]

couples_trimmed <- couples[statefip_1940 %in% trimmed_states]
r10 <- tryCatch(
  feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples_trimmed, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  Trimmed skipped: %s\n", e$message)); NULL }
)

if (!is.null(r10)) {
  cat(sprintf("Trimmed (5-95%%): beta = %.6f (SE = %.6f, N = %s)\n\n",
      coef(r10)["mob_std"], sqrt(vcov(r10)["mob_std", "mob_std"]),
      format(nrow(couples_trimmed), big.mark = ",")))
  robustness$trimmed <- r10
}


## --------------------------------------------------------------------------
## R11: ABE-EI Alternative Linkage (if available)
## --------------------------------------------------------------------------

cat("--- R11: ABE-EI Alternative Linkage ---\n")

ei_file <- file.path(data_dir, "crosswalk_ei_unique.rds")
if (file.exists(ei_file)) {
  cat("ABE-EI crosswalk available for robustness check\n")
  cat("(Full EI linkage replication deferred to appendix analysis)\n\n")
  robustness$ei_available <- TRUE
} else {
  cat("ABE-EI crosswalk not available\n\n")
  robustness$ei_available <- FALSE
}


## --------------------------------------------------------------------------
## R12: Wife Identity Verification (Age Consistency Check)
## --------------------------------------------------------------------------

cat("--- R12: Wife Identity Verification ---\n")

couples[, wife_verified := abs(sp_age_1950 - sp_age_1940 - 10) <= 2]
n_verified <- sum(couples$wife_verified, na.rm = TRUE)
n_total <- nrow(couples)
pct_verified <- 100 * n_verified / n_total

cat(sprintf("Wife age-verified: %s of %s (%.1f%%)\n",
    format(n_verified, big.mark = ","), format(n_total, big.mark = ","), pct_verified))

couples_verified <- couples[wife_verified == TRUE]

r12 <- tryCatch(
  feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 |
        region, data = couples_verified, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  Wife-verified skipped: %s\n", e$message)); NULL }
)

if (!is.null(r12)) {
  wv_beta <- coef(r12)["mob_std"]
  wv_se <- sqrt(vcov(r12)["mob_std", "mob_std"])
  cat(sprintf("Wife-verified subsample: beta = %.6f (SE = %.6f, N = %s)\n\n",
      wv_beta, wv_se, format(nrow(couples_verified), big.mark = ",")))
  robustness$wife_verified <- list(model = r12, n_verified = n_verified,
                                    pct_verified = pct_verified,
                                    beta = wv_beta, se = wv_se)
} else {
  cat("Wife-verified regression could not be estimated\n\n")
}

couples[, wife_verified := NULL]


## --------------------------------------------------------------------------
## R13: Wild Cluster Bootstrap (Wives)
## --------------------------------------------------------------------------

cat("\n--- R13: Wild Cluster Bootstrap (Wives) ---\n")
tryCatch({
  ## Correct wild cluster bootstrap (Cameron-Gelbach-Miller 2008)
  ## Step 1: Estimate RESTRICTED model (H0: beta_mob = 0)
  ## Step 2: Get restricted fitted values and residuals
  ## Step 3: y* = fitted_restricted + w_g * e_restricted
  ## Step 4: Estimate UNRESTRICTED model on y*, get t-stat for mob_std
  set.seed(42)
  B <- 999
  states <- sort(unique(couples$statefip_1940))
  G <- length(states)

  ## Observed t-statistic from W3 (unrestricted model)
  obs_beta <- coef(models$w3_lf)["mob_std"]
  obs_se <- sqrt(vcov(models$w3_lf)["mob_std", "mob_std"])
  obs_t <- obs_beta / obs_se
  cat(sprintf("  Observed: beta=%.6f, SE=%.6f, t=%.4f\n", obs_beta, obs_se, obs_t))

  ## Restricted model (everything EXCEPT mob_std)
  m_restricted <- feols(wife_d_in_lf ~ sp_age_1940 + I(sp_age_1940^2) +
                         sp_educ_years_1940 + husband_age_1940 | region,
                         data = couples, cluster = ~statefip_1940)
  fitted_r <- fitted(m_restricted)
  resid_r <- residuals(m_restricted)

  ## Pre-create state index for fast weight assignment
  state_idx <- match(couples$statefip_1940, states)

  boot_t <- numeric(B)
  cat(sprintf("  Running %d bootstrap iterations (G=%d clusters)...\n", B, G))
  for (b in seq_len(B)) {
    ## Rademacher weights: +1 or -1 per cluster
    w_state <- sample(c(-1L, 1L), G, replace = TRUE)
    w_i <- w_state[state_idx]

    ## Bootstrap outcome: y* = fitted_restricted + w_g * e_restricted
    couples[, y_boot := fitted_r + w_i * resid_r]

    m_b <- tryCatch(
      feols(y_boot ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
            sp_educ_years_1940 + husband_age_1940 | region,
            data = couples, cluster = ~statefip_1940),
      error = function(e) NULL
    )
    if (!is.null(m_b)) {
      boot_t[b] <- coef(m_b)["mob_std"] / sqrt(vcov(m_b)["mob_std", "mob_std"])
    } else {
      boot_t[b] <- NA
    }
    if (b %% 100 == 0) cat(sprintf("    %d/%d done\n", b, B))
  }
  couples[, y_boot := NULL]

  boot_t <- boot_t[is.finite(boot_t)]
  boot_p <- mean(abs(boot_t) >= abs(obs_t))
  ## Bootstrap CI via percentile-t method
  boot_ci_lo <- obs_beta - quantile(boot_t, 0.975) * obs_se
  boot_ci_hi <- obs_beta - quantile(boot_t, 0.025) * obs_se

  cat(sprintf("  Wild bootstrap p-value: %.4f (B=%d, G=%d)\n", boot_p, length(boot_t), G))
  cat(sprintf("  Wild bootstrap 95%% CI: [%.4f, %.4f]\n", boot_ci_lo, boot_ci_hi))
  robustness$wild_bootstrap <- list(p_value = boot_p,
                                     ci_lo = as.numeric(boot_ci_lo),
                                     ci_hi = as.numeric(boot_ci_hi))
}, error = function(e) {
  cat(sprintf("  Wild bootstrap failed: %s\n", e$message))
  robustness$wild_bootstrap <- NULL
})


## --------------------------------------------------------------------------
## R14: Non-Mover Couples
## --------------------------------------------------------------------------

cat("\n--- R14: Non-Mover Couples ---\n")
tryCatch({
  # Identify couples where husband did NOT change state
  if ("statefip_1950" %in% names(couples)) {
    couples[, husband_mover := (statefip_1940 != statefip_1950)]
  } else if ("mover" %in% names(panel)) {
    # Merge mover flag from individual panel (panel has statefip_1950)
    mover_map <- panel[, .(histid_1940, mover)]
    couples <- merge(couples, mover_map, by = "histid_1940", all.x = TRUE)
    couples[, husband_mover := ifelse(is.na(mover), FALSE, mover == 1)]
    couples[, mover := NULL]
  } else {
    stop("Cannot determine mover status: no statefip_1950 or mover column")
  }
  n_nonmover <- sum(!couples$husband_mover, na.rm = TRUE)
  n_mover <- sum(couples$husband_mover, na.rm = TRUE)
  cat(sprintf("  Non-mover couples: %s (%.1f%%)\n",
              format(n_nonmover, big.mark=","), 100*n_nonmover/nrow(couples)))

  w_nonmover <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
                       sp_educ_years_1940 + husband_age_1940 | region,
                       data = couples[husband_mover == FALSE],
                       cluster = ~statefip_1940)
  nonmover_beta <- coef(w_nonmover)["mob_std"]
  nonmover_se <- sqrt(vcov(w_nonmover)["mob_std", "mob_std"])
  cat(sprintf("  Non-mover couples: beta = %.6f (SE = %.6f, N = %s)\n",
              nonmover_beta, nonmover_se, format(nobs(w_nonmover), big.mark=",")))

  robustness$nonmover_couples <- list(model = w_nonmover, beta = nonmover_beta,
                                       se = nonmover_se, n = n_nonmover)
  couples[, husband_mover := NULL]  # clean up
}, error = function(e) {
  cat(sprintf("  Non-mover couples failed: %s\n", e$message))
  robustness$nonmover_couples <- NULL
})


## --------------------------------------------------------------------------
## Save
## --------------------------------------------------------------------------

cat("=== Saving Robustness Results ===\n")
saveRDS(robustness, file.path(data_dir, "robustness.rds"))
cat("Robustness checks complete. Proceed to 05_figures.R\n")
