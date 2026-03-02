## ============================================================
## 04_robustness.R — RDD validity and robustness checks (v2)
## McCrary density, covariate balance, placebo cutoffs,
## bandwidth sensitivity, donut hole, kernel sensitivity,
## + multiple hypothesis correction, MDE analysis
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
dir.create("../tables", showWarnings = FALSE)

cat("=== ROBUSTNESS CHECKS (v2) ===\n\n")

## ----------------------------------------------------------
## 1. McCrary Density Test
## ----------------------------------------------------------

cat("--- 1. McCrary Density Test ---\n")
dens <- rddensity(X = df$pop_centered, c = 0)
cat("  T-statistic:", round(dens$test$t_jk, 4), "\n")
cat("  P-value:", round(dens$test$p_jk, 4), "\n")
if (dens$test$p_jk > 0.05) {
  cat("  RESULT: No evidence of manipulation (p > 0.05)\n")
} else {
  cat("  RESULT: Evidence of sorting at threshold (p < 0.05)\n")
}

saveRDS(dens, "../data/density_test.rds")

## ----------------------------------------------------------
## 2. Covariate Balance at Threshold
## ----------------------------------------------------------

cat("\n--- 2. Covariate Balance ---\n")

balance_vars <- list(
  "Pop 15-64 (2011)" = "P11_POP1564",
  "Female emp rate (2011)" = "female_emp_rate_2011",
  "Female LFPR (2011)" = "female_lfpr_2011",
  "Total emp rate (2011)" = "total_emp_rate_2011",
  "Density (hab/km2)" = "densite"
)

balance_results <- data.frame()

for (name in names(balance_vars)) {
  var <- balance_vars[[name]]
  if (!var %in% names(df)) next

  y <- df[[var]]
  valid <- !is.na(y) & is.finite(y)
  if (sum(valid) < 500) next

  rd_bal <- tryCatch(
    rdrobust(y = y[valid], x = df$pop_centered[valid], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_bal)) {
    cat("  ", name, ": coef=", round(rd_bal$coef[1], 4),
        " p=", round(rd_bal$pv[3], 4), "\n")

    balance_results <- rbind(balance_results, data.frame(
      variable = name,
      coef = rd_bal$coef[1],
      se = rd_bal$se[3],
      pvalue = rd_bal$pv[3],
      bw = rd_bal$bws[1, 1],
      n_obs = rd_bal$N_h[1] + rd_bal$N_h[2]
    ))
  }
}

saveRDS(balance_results, "../data/balance_results.rds")

## ----------------------------------------------------------
## 3. Placebo Cutoffs
## ----------------------------------------------------------

cat("\n--- 3. Placebo Cutoffs ---\n")

placebo_cuts <- c(500, 700, 800, 900, 1100, 1200, 1300, 1500, 2000)
placebo_results <- data.frame()

valid_emp <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)

for (cut in placebo_cuts) {
  pop_c <- df$pop - cut

  rd_p <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid_emp], x = pop_c[valid_emp], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_p)) {
    cat("  Cutoff=", cut, ": coef=", round(rd_p$coef[1], 4),
        " p=", round(rd_p$pv[3], 4), "\n")

    placebo_results <- rbind(placebo_results, data.frame(
      cutoff = cut, coef = rd_p$coef[1], se = rd_p$se[3],
      pvalue = rd_p$pv[3], bw = rd_p$bws[1, 1], is_real = FALSE
    ))
  }
}

# Add real cutoff
rd_real <- rdrobust(y = df$female_emp_rate[valid_emp],
                    x = df$pop_centered[valid_emp], c = 0,
                    kernel = "triangular", p = 1, bwselect = "cerrd",
                    masspoints = "adjust")
placebo_results <- rbind(placebo_results, data.frame(
  cutoff = 1000, coef = rd_real$coef[1], se = rd_real$se[3],
  pvalue = rd_real$pv[3], bw = rd_real$bws[1, 1], is_real = TRUE
))

saveRDS(placebo_results, "../data/placebo_results.rds")

## ----------------------------------------------------------
## 4. Bandwidth Sensitivity
## ----------------------------------------------------------

cat("\n--- 4. Bandwidth Sensitivity ---\n")

bw_results <- data.frame()
for (bw in seq(100, 800, by = 50)) {
  sub <- df %>% filter(abs(pop_centered) <= bw,
                        !is.na(female_emp_rate),
                        is.finite(female_emp_rate))
  if (nrow(sub) < 50) next

  mod <- lm(female_emp_rate ~ above_threshold + pop_centered +
              I(above_threshold * pop_centered), data = sub)
  se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])

  bw_results <- rbind(bw_results, data.frame(
    bandwidth = bw, coef = coef(mod)[2], se = se, n = nrow(sub)
  ))

  if (bw %% 200 == 0) {
    cat("  BW=", bw, ": coef=", round(coef(mod)[2], 4),
        " SE=", round(se, 4), " N=", nrow(sub), "\n")
  }
}

saveRDS(bw_results, "../data/bw_sensitivity.rds")

## ----------------------------------------------------------
## 5. Donut Hole RDD
## ----------------------------------------------------------

cat("\n--- 5. Donut Hole RDD ---\n")

for (hole in c(10, 20, 50)) {
  sub <- df %>%
    filter(abs(pop_centered) >= hole,
           !is.na(female_emp_rate),
           is.finite(female_emp_rate))

  rd_donut <- tryCatch(
    rdrobust(y = sub$female_emp_rate, x = sub$pop_centered, c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_donut)) {
    cat("  Donut=", hole, ": coef=", round(rd_donut$coef[1], 4),
        " SE=", round(rd_donut$se[3], 4),
        " p=", round(rd_donut$pv[3], 4), "\n")
  }
}

## ----------------------------------------------------------
## 6. Polynomial Order Sensitivity
## ----------------------------------------------------------

cat("\n--- 6. Polynomial Order ---\n")

for (poly in 1:3) {
  rd_poly <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid_emp],
             x = df$pop_centered[valid_emp], c = 0,
             kernel = "triangular", p = poly, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )
  if (!is.null(rd_poly)) {
    cat("  p=", poly, ": coef=", round(rd_poly$coef[1], 4),
        " SE=", round(rd_poly$se[3], 4),
        " p-val=", round(rd_poly$pv[3], 4),
        " BW=", round(rd_poly$bws[1, 1]), "\n")
  }
}

## ----------------------------------------------------------
## 7. Kernel Sensitivity
## ----------------------------------------------------------

cat("\n--- 7. Kernel Choice ---\n")

for (kern in c("triangular", "uniform", "epanechnikov")) {
  rd_kern <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid_emp],
             x = df$pop_centered[valid_emp], c = 0,
             kernel = kern, p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )
  if (!is.null(rd_kern)) {
    cat("  ", kern, ": coef=", round(rd_kern$coef[1], 4),
        " SE=", round(rd_kern$se[3], 4),
        " p=", round(rd_kern$pv[3], 4), "\n")
  }
}

## ----------------------------------------------------------
## 8. NEW: Multiple Hypothesis Correction (Holm)
## ----------------------------------------------------------

cat("\n--- 8. Multiple Hypothesis Correction ---\n")

results_v2 <- readRDS("../data/rd_results_v2.rds")

# Collect all p-values from labor market outcomes
labor_pvals <- sapply(results_v2$labor, function(r) r$pv_robust)
labor_names <- sapply(results_v2$labor, function(r) r$name)

holm_pvals <- p.adjust(labor_pvals, method = "holm")

cat("  Holm-adjusted p-values (labor market family):\n")
for (i in seq_along(labor_names)) {
  cat(sprintf("    %s: raw=%.4f, Holm=%.4f\n",
      labor_names[i], labor_pvals[i], holm_pvals[i]))
}

# Also correct across ALL outcomes (extended family)
all_pvals <- c(
  labor_pvals,
  sapply(results_v2$political, function(r) r$pv_robust),
  sapply(results_v2$spending, function(r) r$pv_robust)
)
all_names <- c(
  labor_names,
  sapply(results_v2$political, function(r) r$name),
  sapply(results_v2$spending, function(r) r$name)
)

if (length(all_pvals) > 0) {
  holm_all <- p.adjust(all_pvals, method = "holm")
  cat("\n  Holm-adjusted p-values (all outcomes):\n")
  for (i in seq_along(all_names)) {
    cat(sprintf("    %s: raw=%.4f, Holm=%.4f\n",
        all_names[i], all_pvals[i], holm_all[i]))
  }
}

# Save correction results
saveRDS(list(
  labor_holm = data.frame(name = labor_names, p_raw = labor_pvals, p_holm = holm_pvals),
  all_holm = if (length(all_pvals) > 0)
    data.frame(name = all_names, p_raw = all_pvals, p_holm = holm_all) else NULL
), "../data/mht_correction.rds")

## ----------------------------------------------------------
## 9. NEW: Minimum Detectable Effect (MDE) Analysis
## ----------------------------------------------------------

cat("\n--- 9. Minimum Detectable Effect ---\n")

# MDE = (z_alpha/2 + z_beta) * SE, at 80% power, alpha = 0.05
z_alpha <- qnorm(0.975)
z_beta <- qnorm(0.80)

mde_results <- data.frame()

for (out_name in names(results_v2$labor)) {
  r <- results_v2$labor[[out_name]]
  mde <- (z_alpha + z_beta) * r$se_robust
  mde_pct_mean <- NA

  # Get outcome mean for context
  if (out_name %in% names(df)) {
    out_mean <- mean(df[[out_name]], na.rm = TRUE)
    mde_pct_mean <- mde / out_mean * 100
  }

  cat(sprintf("  %s: MDE = %.4f (%.1f%% of mean)\n",
      r$name, mde, ifelse(is.na(mde_pct_mean), 0, mde_pct_mean)))

  mde_results <- rbind(mde_results, data.frame(
    outcome = r$name,
    se = r$se_robust,
    mde = mde,
    mde_pct = mde_pct_mean
  ))
}

saveRDS(mde_results, "../data/mde_results.rds")

# Compare with literature benchmarks
cat("\n  Literature benchmarks:\n")
cat("    Chattopadhyay & Duflo (2004): ~50-100% increase in public goods\n")
cat("    Beaman et al. (2012): 5-7 pp in aspirations\n")
cat("    Bertrand et al. (2019): null on broad labor outcomes\n")
cat("    Bagues & Campa (2021): 0.3-0.6 pp on female candidacy\n")

cat("\nRobustness checks complete.\n")
