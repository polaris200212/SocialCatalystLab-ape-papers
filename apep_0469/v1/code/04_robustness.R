## ============================================================================
## 04_robustness.R — Robustness Checks
## Missing Men, Rising Women (apep_0469)
## ============================================================================

source("code/00_packages.R")
data_dir <- "data"

state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
indiv_panel <- readRDS(file.path(data_dir, "indiv_panel.rds"))

cat("=== Robustness Checks ===\n")
cat(sprintf("States: %d, Individuals: %s\n",
    nrow(state_analysis), format(nrow(indiv_panel), big.mark = ",")))


## --------------------------------------------------------------------------
## R1. Quintile Dummies (Non-Parametric Treatment)
## --------------------------------------------------------------------------

cat("\n--- R1: Quintile Dummies ---\n")

rob_quint <- feols(d_lf_female ~ i(mob_quintile, ref = "Q1") +
                   pct_urban + pct_black + pct_farm + mean_educ + mean_age,
                   data = state_analysis, weights = ~n_female_1940)

rob_quint_gap <- feols(d_lf_gap ~ i(mob_quintile, ref = "Q1") +
                       pct_urban + pct_black + pct_farm + mean_educ + mean_age,
                       data = state_analysis, weights = ~n_female_1940)

etable(rob_quint, rob_quint_gap, headers = c("Δ Female LFP", "Δ LFP Gap"))


## --------------------------------------------------------------------------
## R2. Weighted vs Unweighted
## --------------------------------------------------------------------------

cat("\n--- R2: Weighted vs Unweighted ---\n")

rob_unwt <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                  mean_educ + mean_age, data = state_analysis)
rob_wt <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age, data = state_analysis,
                weights = ~n_female_1940)

etable(rob_unwt, rob_wt, headers = c("Unweighted", "Pop-weighted"), keep = "mob_std")


## --------------------------------------------------------------------------
## R3. Excluding Southern States
## --------------------------------------------------------------------------

cat("\n--- R3: Excluding South ---\n")

south_fips <- c(1, 5, 10, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54)
nonsouth <- state_analysis[!statefip %in% south_fips]
nonsouth[, mob_std := as.numeric(scale(mobilization_rate))]

rob_nonsouth <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                      mean_educ + mean_age, data = nonsouth,
                      weights = ~n_female_1940)

cat(sprintf("Non-South: %d / %d states\n", nrow(nonsouth), nrow(state_analysis)))
etable(rob_nonsouth, keep = "mob_std")


## --------------------------------------------------------------------------
## R4. Trimmed Sample (Drop Top/Bottom 10% Mobilization)
## --------------------------------------------------------------------------

cat("\n--- R4: Trimmed Sample ---\n")

mob_p10 <- quantile(state_analysis$mobilization_rate, 0.10)
mob_p90 <- quantile(state_analysis$mobilization_rate, 0.90)
trimmed <- state_analysis[mobilization_rate >= mob_p10 & mobilization_rate <= mob_p90]
trimmed[, mob_std := as.numeric(scale(mobilization_rate))]

rob_trim <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                  mean_educ + mean_age, data = trimmed,
                  weights = ~n_female_1940)

cat(sprintf("Trimmed: %d / %d states\n", nrow(trimmed), nrow(state_analysis)))
etable(rob_trim, keep = "mob_std")


## --------------------------------------------------------------------------
## R5. Oster (2019) Coefficient Stability
## --------------------------------------------------------------------------

cat("\n--- R5: Oster (2019) ---\n")

m_short <- feols(d_lf_female ~ mob_std, data = state_analysis, weights = ~n_female_1940)
m_long <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age + pct_married,
                data = state_analysis, weights = ~n_female_1940)

beta_s <- coef(m_short)["mob_std"]
beta_l <- coef(m_long)["mob_std"]
r2_s <- fitstat(m_short, "r2")$r2
r2_l <- fitstat(m_long, "r2")$r2
r2_max <- min(1, 1.3 * r2_l)

if (abs(beta_s - beta_l) > 1e-10 && abs(r2_l - r2_s) > 1e-10) {
  delta <- (beta_l * (r2_max - r2_l)) / ((beta_s - beta_l) * (r2_l - r2_s))
} else {
  delta <- Inf
}

cat(sprintf("β (short): %.4f, β (long): %.4f\n", beta_s, beta_l))
cat(sprintf("R² (short): %.4f, R² (long): %.4f\n", r2_s, r2_l))
cat(sprintf("Oster δ: %.2f (|δ| > 1 = robust)\n", delta))

oster_results <- data.table(
  beta_s = beta_s, beta_l = beta_l,
  r2_s = r2_s, r2_l = r2_l, r2_max = r2_max, delta = delta
)


## --------------------------------------------------------------------------
## R6. Balance Test
## --------------------------------------------------------------------------

cat("\n--- R6: Covariate Balance ---\n")

bal_vars <- c("pct_urban", "pct_black", "pct_farm", "mean_educ",
              "mean_age", "pct_married", "pct_female")

balance_dt <- rbindlist(lapply(bal_vars, function(v) {
  if (v %in% names(state_analysis)) {
    fm <- as.formula(paste(v, "~ mob_std"))
    m <- feols(fm, data = state_analysis, weights = ~n_female_1940)
    s <- summary(m)
    ct <- coeftable(s)
    idx <- which(rownames(ct) == "mob_std")
    data.table(variable = v, coef = ct[idx, 1],
               se = ct[idx, 2], pval = ct[idx, 4])
  }
}))

cat("Balance: 1940 covariates on mobilization\n")
print(balance_dt)

# Joint F-test
bal_joint <- feols(mob_std ~ pct_urban + pct_black + pct_farm + mean_educ +
                   mean_age + pct_married,
                   data = state_analysis, weights = ~n_female_1940)
f_stat <- fitstat(bal_joint, "f")
cat(sprintf("Joint F: %.2f (p = %.4f)\n", f_stat$f$stat, f_stat$f$p))


## --------------------------------------------------------------------------
## R7. Individual-Level Robustness
## --------------------------------------------------------------------------

cat("\n--- R7: Individual Robustness ---\n")

women <- indiv_panel[female == 1]

# Different age ranges
rob_25_45 <- feols(in_lf ~ post * mob_std + age + I(age^2) + i(race_cat) +
                   married | statefip,
                   data = women[age >= 25 & age <= 45],
                   cluster = ~statefip, weights = ~perwt)

rob_18_35 <- feols(in_lf ~ post * mob_std + age + I(age^2) + i(race_cat) +
                   married | statefip,
                   data = women[age >= 18 & age <= 35],
                   cluster = ~statefip, weights = ~perwt)

# Unweighted
rob_unwt_indiv <- feols(in_lf ~ post * mob_std + age + I(age^2) + i(race_cat) +
                        married + is_farm | statefip + year,
                        data = women, cluster = ~statefip)

cat("Individual robustness:\n")
etable(rob_25_45, rob_18_35, rob_unwt_indiv,
       headers = c("Age 25-45", "Age 18-35", "Unweighted"),
       keep = c("post.*mob"))


## --------------------------------------------------------------------------
## R8. Bootstrap (State-Level)
## --------------------------------------------------------------------------

cat("\n--- R8: Bootstrap ---\n")

boot_fn <- function(data, indices) {
  d <- data[indices, ]
  d[, mob_std_b := as.numeric(scale(mobilization_rate))]
  m <- tryCatch(
    feols(d_lf_female ~ mob_std_b + pct_urban + pct_black + pct_farm +
          mean_educ + mean_age, data = d, weights = ~n_female_1940),
    error = function(e) NULL
  )
  if (is.null(m)) return(NA_real_)
  coef(m)["mob_std_b"]
}

set.seed(42)
boot_result <- boot(state_analysis, boot_fn, R = 999)
boot_clean <- boot_result$t[!is.na(boot_result$t)]

cat(sprintf("Bootstrap (999 reps, %d ok): est=%.4f, SE=%.4f, 95%% CI=[%.4f, %.4f]\n",
    length(boot_clean), boot_result$t0, sd(boot_clean),
    quantile(boot_clean, 0.025), quantile(boot_clean, 0.975)))


## --------------------------------------------------------------------------
## R9. Lee (2009) Bounds
## --------------------------------------------------------------------------

cat("\n--- R9: Lee Bounds ---\n")

women_1950 <- indiv_panel[female == 1 & year == 1950]

if (nrow(women_1950) > 1000) {
  bounds <- lapply(c(0, 0.05, 0.10, 0.15), function(p) {
    if (p == 0) {
      m <- tryCatch(
        feols(in_lf ~ mob_std + age + I(age^2) + i(race_cat) + married | statefip,
              data = women_1950, cluster = ~statefip, weights = ~perwt),
        error = function(e) NULL)
      if (is.null(m)) return(NULL)
      return(data.table(trim = p, coef = coef(m)["mob_std"], se = se(m)["mob_std"]))
    }

    high_mob <- women_1950[mob_std > 0]
    low_mob <- women_1950[mob_std <= 0]

    # Trim top/bottom p% from high-mobilization group
    q_lo <- quantile(high_mob$in_lf, p, na.rm = TRUE)
    q_hi <- quantile(high_mob$in_lf, 1 - p, na.rm = TRUE)

    d_lo <- rbind(low_mob, high_mob[in_lf >= q_lo])
    d_hi <- rbind(low_mob, high_mob[in_lf <= q_hi])

    m_lo <- tryCatch(feols(in_lf ~ mob_std + age + I(age^2) + i(race_cat) + married |
                           statefip, data = d_lo, cluster = ~statefip, weights = ~perwt),
                     error = function(e) NULL)
    m_hi <- tryCatch(feols(in_lf ~ mob_std + age + I(age^2) + i(race_cat) + married |
                           statefip, data = d_hi, cluster = ~statefip, weights = ~perwt),
                     error = function(e) NULL)

    data.table(trim = p,
               lower = if (!is.null(m_lo)) coef(m_lo)["mob_std"] else NA_real_,
               upper = if (!is.null(m_hi)) coef(m_hi)["mob_std"] else NA_real_)
  })

  lee_bounds <- rbindlist(bounds[!sapply(bounds, is.null)], fill = TRUE)
  print(lee_bounds)
} else {
  lee_bounds <- data.table()
}


## --------------------------------------------------------------------------
## R10. Randomization Inference (Permutation Test)
## --------------------------------------------------------------------------

cat("\n--- R10: Randomization Inference ---\n")

set.seed(42)
n_perm <- 1000

sa_ri <- copy(state_analysis)
actual_beta <- coef(feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                          mean_educ + mean_age, data = sa_ri, weights = ~n_female_1940))["mob_std"]

perm_betas <- numeric(n_perm)
for (i in seq_len(n_perm)) {
  sa_ri[, mob_perm := sample(mob_std)]
  m_perm <- feols(d_lf_female ~ mob_perm + pct_urban + pct_black + pct_farm +
                  mean_educ + mean_age, data = sa_ri, weights = ~n_female_1940)
  perm_betas[i] <- coef(m_perm)["mob_perm"]
}

ri_p <- mean(abs(perm_betas) >= abs(actual_beta))
cat(sprintf("RI p-value (two-sided, %d permutations): %.3f\n", n_perm, ri_p))
cat(sprintf("Actual β: %.4f, Perm mean: %.4f, Perm SD: %.4f\n",
    actual_beta, mean(perm_betas), sd(perm_betas)))


## --------------------------------------------------------------------------
## R11. HC2/HC3 Robust Standard Errors
## --------------------------------------------------------------------------

cat("\n--- R11: HC2/HC3 Standard Errors ---\n")

m_main <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age, data = state_analysis, weights = ~n_female_1940)

se_iid <- se(m_main)["mob_std"]
se_hc1 <- se(m_main, vcov = "HC1")["mob_std"]
se_hc3 <- se(m_main, vcov = "HC3")["mob_std"]

cat(sprintf("SE (IID): %.4f, SE (HC1): %.4f, SE (HC3): %.4f\n", se_iid, se_hc1, se_hc3))
cat(sprintf("t (IID): %.3f, t (HC1): %.3f, t (HC3): %.3f\n",
    coef(m_main)["mob_std"]/se_iid,
    coef(m_main)["mob_std"]/se_hc1,
    coef(m_main)["mob_std"]/se_hc3))


## --------------------------------------------------------------------------
## R12. Leave-One-Out Influence
## --------------------------------------------------------------------------

cat("\n--- R12: Leave-One-Out ---\n")

loo_betas <- numeric(nrow(state_analysis))
for (i in seq_len(nrow(state_analysis))) {
  sa_loo <- state_analysis[-i]
  sa_loo[, mob_std := as.numeric(scale(mobilization_rate))]
  m_loo <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
                 mean_educ + mean_age, data = sa_loo, weights = ~n_female_1940)
  loo_betas[i] <- coef(m_loo)["mob_std"]
}

loo_dt <- data.table(
  state = state_analysis$statefip,
  beta_loo = loo_betas,
  influence = loo_betas - actual_beta
)

cat("Most influential states (top 5 by |influence|):\n")
print(loo_dt[order(-abs(influence))][1:5, .(state, beta_loo, influence)])
cat(sprintf("LOO range: [%.4f, %.4f]\n", min(loo_betas), max(loo_betas)))
cat(sprintf("All LOO betas negative? %s\n", ifelse(all(loo_betas < 0), "Yes", "No")))


## --------------------------------------------------------------------------
## R13. ANCOVA Specification (Level with Lagged DV)
## --------------------------------------------------------------------------

cat("\n--- R13: ANCOVA ---\n")

# Construct 1940 LFP level for ANCOVA
sa_ancova <- copy(state_analysis)
sa_ancova[, lf_female_1950 := lf_female_1940 + d_lf_female]

rob_ancova <- feols(lf_female_1950 ~ mob_std + lf_female_1940 + pct_urban + pct_black +
                    pct_farm + mean_educ + mean_age,
                    data = sa_ancova, weights = ~n_female_1940)

cat("ANCOVA (level with lagged DV):\n")
etable(rob_ancova, keep = c("%mob_std", "%lf_female_1940"))


## --------------------------------------------------------------------------
## Save
## --------------------------------------------------------------------------

robustness <- list(
  quintile_lf = rob_quint, quintile_gap = rob_quint_gap,
  unweighted = rob_unwt, weighted = rob_wt,
  nonsouth = rob_nonsouth, trimmed = rob_trim,
  oster = oster_results, balance = balance_dt,
  balance_f = f_stat,
  bootstrap = list(t0 = boot_result$t0, se = sd(boot_clean),
                   ci = quantile(boot_clean, c(0.025, 0.975))),
  lee_bounds = lee_bounds,
  indiv_25_45 = rob_25_45, indiv_18_35 = rob_18_35,
  ri = list(actual_beta = actual_beta, perm_betas = perm_betas, ri_p = ri_p),
  se_robust = list(se_iid = se_iid, se_hc1 = se_hc1, se_hc3 = se_hc3),
  loo = loo_dt,
  ancova = rob_ancova
)

saveRDS(robustness, file.path(data_dir, "robustness.rds"))
cat("\n✓ Robustness complete. Proceed to 05_figures.R\n")
