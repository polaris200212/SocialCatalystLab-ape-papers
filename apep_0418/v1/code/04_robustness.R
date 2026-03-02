##############################################################################
# 04_robustness.R — Robustness checks and sensitivity analysis
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 4: Robustness Checks ===\n\n")

rdd_sample <- readRDS(file.path(DATA_DIR, "rdd_sample.rds"))
rd_main <- readRDS(file.path(DATA_DIR, "rd_main_nocov.rds"))

###############################################################################
# 1. Bandwidth sensitivity
###############################################################################
cat("--- Bandwidth Sensitivity ---\n")

h_opt <- rd_main$bws[1, 1]
b_opt <- rd_main$bws[2, 1]  # Bias bandwidth
h_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

bw_results <- list()
for (mult in h_multipliers) {
  h <- h_opt * mult
  b <- b_opt * mult  # Scale bias bandwidth proportionally
  rd_bw <- tryCatch({
    rdrobust(
      y = rdd_sample$post_ira_mw_per_1000emp,
      x = rdd_sample$ff_share,
      c = 0.17,
      h = h,
      b = b,
      all = TRUE
    )
  }, error = function(e) NULL)

  if (!is.null(rd_bw)) {
    bw_results[[as.character(mult)]] <- data.frame(
      multiplier = mult,
      bandwidth = h,
      estimate = rd_bw$coef[3],
      se = rd_bw$se[3],
      p_value = rd_bw$pv[3],
      n_left = rd_bw$N_h[1],
      n_right = rd_bw$N_h[2]
    )
    cat("  h =", round(h, 4), " (", mult, "x): est =", round(rd_bw$coef[3], 3),
        " p =", round(rd_bw$pv[3], 3),
        " N =", rd_bw$N_h[1] + rd_bw$N_h[2], "\n")
  }
}

bw_df <- bind_rows(bw_results)
saveRDS(bw_df, file.path(DATA_DIR, "bandwidth_sensitivity.rds"))

###############################################################################
# 2. Placebo cutoffs
###############################################################################
cat("\n--- Placebo Cutoffs ---\n")

placebo_cutoffs <- c(0.05, 0.08, 0.10, 0.12, 0.14, 0.20, 0.25, 0.30, 0.40)

placebo_results <- list()
for (c_val in placebo_cutoffs) {
  rd_plac <- tryCatch({
    rdrobust(
      y = rdd_sample$post_ira_mw_per_1000emp,
      x = rdd_sample$ff_share,
      c = c_val,
      all = TRUE
    )
  }, error = function(e) NULL)

  if (!is.null(rd_plac)) {
    placebo_results[[as.character(c_val)]] <- data.frame(
      cutoff = c_val,
      is_true = c_val == 0.17,
      estimate = rd_plac$coef[3],
      se = rd_plac$se[3],
      p_value = rd_plac$pv[3],
      n_left = rd_plac$N_h[1],
      n_right = rd_plac$N_h[2]
    )
    cat("  c =", c_val, ": est =", round(rd_plac$coef[3], 3),
        " p =", round(rd_plac$pv[3], 3),
        ifelse(c_val == 0.17, " <-- TRUE CUTOFF", ""), "\n")
  }
}

placebo_df <- bind_rows(placebo_results)
saveRDS(placebo_df, file.path(DATA_DIR, "placebo_cutoffs.rds"))

###############################################################################
# 3. Donut RDD (exclude observations closest to threshold)
###############################################################################
cat("\n--- Donut RDD ---\n")

donut_sizes <- c(0.01, 0.02, 0.03, 0.05)

donut_results <- list()
for (donut in donut_sizes) {
  rdd_donut <- rdd_sample %>%
    filter(abs(ff_share - 0.17) >= donut)

  rd_donut <- tryCatch({
    rdrobust(
      y = rdd_donut$post_ira_mw_per_1000emp,
      x = rdd_donut$ff_share,
      c = 0.17,
      all = TRUE
    )
  }, error = function(e) NULL)

  if (!is.null(rd_donut)) {
    donut_results[[as.character(donut)]] <- data.frame(
      donut_width = donut,
      estimate = rd_donut$coef[3],
      se = rd_donut$se[3],
      p_value = rd_donut$pv[3],
      n_obs = rd_donut$N_h[1] + rd_donut$N_h[2]
    )
    cat("  Donut =", donut, ": est =", round(rd_donut$coef[3], 3),
        " p =", round(rd_donut$pv[3], 3), "\n")
  }
}

donut_df <- bind_rows(donut_results)
saveRDS(donut_df, file.path(DATA_DIR, "donut_rdd.rds"))

###############################################################################
# 4. Alternative outcomes
###############################################################################
cat("\n--- Alternative Outcomes ---\n")

# Total clean energy (not just post-IRA)
rd_total <- rdrobust(
  y = rdd_sample$clean_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  all = TRUE
)
cat("  Total clean energy: est =", round(rd_total$coef[3], 3),
    " p =", round(rd_total$pv[3], 3), "\n")

# Number of generators (extensive margin)
rd_ngen <- tryCatch({
  rdrobust(
    y = rdd_sample$n_post_ira,
    x = rdd_sample$ff_share,
    c = 0.17,
    all = TRUE
  )
}, error = function(e) {
  cat("  n_post_ira: insufficient variation\n")
  NULL
})
if (!is.null(rd_ngen)) {
  cat("  N generators: est =", round(rd_ngen$coef[3], 3),
      " p =", round(rd_ngen$pv[3], 3), "\n")
}

alt_outcomes <- list(
  total_clean = rd_total,
  n_generators = rd_ngen
)
saveRDS(alt_outcomes, file.path(DATA_DIR, "alternative_outcomes.rds"))

###############################################################################
# 5. Heterogeneity by area type (MSA vs non-MSA)
###############################################################################
cat("\n--- Heterogeneity: MSA vs non-MSA ---\n")

hetero_results <- list()
for (atype in c("MSA", "non-MSA")) {
  sub <- rdd_sample %>% filter(area_type == atype)
  if (nrow(sub) > 30) {
    rd_sub <- tryCatch({
      rdrobust(
        y = sub$post_ira_mw_per_1000emp,
        x = sub$ff_share,
        c = 0.17,
        all = TRUE
      )
    }, error = function(e) NULL)

    if (!is.null(rd_sub)) {
      hetero_results[[atype]] <- rd_sub
      cat("  ", atype, ": est =", round(rd_sub$coef[3], 3),
          " p =", round(rd_sub$pv[3], 3),
          " N =", rd_sub$N_h[1] + rd_sub$N_h[2], "\n")
    }
  }
}
saveRDS(hetero_results, file.path(DATA_DIR, "heterogeneity_msa.rds"))

###############################################################################
# 6. Bivariate RDD (both FF employment and unemployment thresholds)
###############################################################################
cat("\n--- Bivariate RDD (full sample, both thresholds) ---\n")

# Use the full dataset (not just above-unemployment areas)
area_full <- readRDS(file.path(DATA_DIR, "area_data_full.rds"))

# Create interaction term: distance to BOTH thresholds
nat_unemp <- readRDS(file.path(DATA_DIR, "national_unemp_2022.rds"))

area_full <- area_full %>%
  filter(!is.na(unemp_rate), !is.na(ff_share), total_emp > 0) %>%
  mutate(
    ff_dist = ff_share - 0.17,
    unemp_dist = unemp_rate - nat_unemp
  )

# Parametric bivariate RDD: OLS with both running variables
biv_sample <- area_full %>%
  filter(
    abs(ff_dist) <= h_opt * 1.5,
    abs(unemp_dist) <= 2  # Within 2pp of national unemployment
  )

if (nrow(biv_sample) > 30) {
  biv_rd <- feols(
    post_ira_mw_per_1000emp ~ energy_community +
      ff_dist + unemp_dist + ff_dist:unemp_dist +
      above_ff_threshold:ff_dist + above_unemp_threshold:unemp_dist,
    data = biv_sample,
    vcov = "hetero"
  )

  cat("  Bivariate RDD:\n")
  cat("    Treatment:", round(coef(biv_rd)["energy_communityTRUE"], 3), "\n")
  cat("    N:", nobs(biv_rd), "\n")
  saveRDS(biv_rd, file.path(DATA_DIR, "bivariate_rd.rds"))
}

###############################################################################
# 7. RDD on unemployment margin
###############################################################################
cat("\n--- RDD on Unemployment Margin ---\n")

# Among areas with FF employment >= 0.17%, test the unemployment discontinuity
unemp_rdd <- area_full %>%
  filter(above_ff_threshold)

if (nrow(unemp_rdd) > 30) {
  rd_unemp <- tryCatch({
    rdrobust(
      y = unemp_rdd$post_ira_mw_per_1000emp,
      x = unemp_rdd$unemp_rate,
      c = nat_unemp,
      all = TRUE
    )
  }, error = function(e) NULL)

  if (!is.null(rd_unemp)) {
    cat("  Unemployment RDD (among FF >= 0.17%):\n")
    cat("    Estimate:", round(rd_unemp$coef[3], 3), "\n")
    cat("    p-value:", round(rd_unemp$pv[3], 3), "\n")
    saveRDS(rd_unemp, file.path(DATA_DIR, "rd_unemployment_margin.rds"))
  }
}

###############################################################################
# 8. Pre-IRA Placebo Test
###############################################################################
cat("\n--- Pre-IRA Placebo Test ---\n")

# If the IRA energy community bonus drives investment, there should be
# NO discontinuity in pre-IRA clean energy capacity at the 0.17% threshold.
# Pre-IRA = total clean MW minus post-IRA clean MW (generators online before 2023).

rdd_sample <- rdd_sample %>%
  mutate(
    pre_ira_mw_per_1000emp = clean_mw_per_1000emp - post_ira_mw_per_1000emp
  )

cat("  Pre-IRA outcome summary:\n")
cat("    Mean:", round(mean(rdd_sample$pre_ira_mw_per_1000emp, na.rm = TRUE), 3), "\n")
cat("    SD:", round(sd(rdd_sample$pre_ira_mw_per_1000emp, na.rm = TRUE), 3), "\n")

rd_pre_ira <- tryCatch({
  rdrobust(
    y = rdd_sample$pre_ira_mw_per_1000emp,
    x = rdd_sample$ff_share,
    c = 0.17,
    all = TRUE
  )
}, error = function(e) {
  cat("  Pre-IRA placebo: error -", e$message, "\n")
  NULL
})

if (!is.null(rd_pre_ira)) {
  cat("  Pre-IRA placebo RDD:\n")
  cat("    Estimate:", round(rd_pre_ira$coef[3], 3), "\n")
  cat("    SE:", round(rd_pre_ira$se[3], 3), "\n")
  cat("    p-value:", round(rd_pre_ira$pv[3], 3), "\n")
  cat("    N(left):", rd_pre_ira$N_h[1], " N(right):", rd_pre_ira$N_h[2], "\n")
  cat("    Interpretation:",
      ifelse(rd_pre_ira$pv[3] > 0.10,
             "No pre-existing discontinuity (GOOD - supports causal interpretation)",
             "WARNING: Pre-existing discontinuity detected"), "\n")
  saveRDS(rd_pre_ira, file.path(DATA_DIR, "rd_pre_ira_placebo.rds"))
}

###############################################################################
# 9. Minimum Detectable Effect (Power Analysis)
###############################################################################
cat("\n--- Power Analysis / MDE ---\n")

# Use rdpower for power calculations at the optimal bandwidth
if (requireNamespace("rdpower", quietly = TRUE)) {
  library(rdpower)

  # Data-driven power calculation
  power_data <- cbind(rdd_sample$post_ira_mw_per_1000emp, rdd_sample$ff_share)

  cat("  Power at various effect sizes:\n")
  test_taus <- c(2.0, 5.0, 8.0, 10.0, 12.0, 15.0)

  power_grid <- list()
  for (tau_val in test_taus) {
    pw <- tryCatch({
      rdpower(data = power_data, cutoff = 0.17,
              tau = tau_val, alpha = 0.05)
    }, error = function(e) {
      cat("    tau =", tau_val, " error:", e$message, "\n")
      NULL
    })

    if (!is.null(pw)) {
      power_grid[[as.character(tau_val)]] <- data.frame(
        tau = tau_val,
        power = pw$power
      )
      cat("    tau =", tau_val, " MW: power =", round(pw$power, 3), "\n")
    }
  }
  if (length(power_grid) > 0) {
    power_df <- bind_rows(power_grid)
    saveRDS(power_df, file.path(DATA_DIR, "power_grid.rds"))

    # Find MDE at 80% power via interpolation
    if (any(power_df$power >= 0.80)) {
      # Linear interpolation between points bracketing 0.80
      below <- power_df %>% filter(power < 0.80) %>% slice_max(tau, n = 1)
      above <- power_df %>% filter(power >= 0.80) %>% slice_min(tau, n = 1)
      if (nrow(below) > 0 && nrow(above) > 0) {
        mde_80 <- below$tau + (0.80 - below$power) /
          (above$power - above$tau + below$tau) * (above$tau - below$tau)
        # Simple linear interpolation
        mde_80 <- below$tau + (above$tau - below$tau) *
          (0.80 - below$power) / (above$power - below$power)
      } else {
        mde_80 <- min(power_df$tau[power_df$power >= 0.80])
      }
      cat("\n  MDE at 80% power: ~", round(mde_80, 1), " MW per 1,000 employees\n")
      cat("  (", round(mde_80 / mean(rdd_sample$post_ira_mw_per_1000emp, na.rm = TRUE) * 100, 0),
          "% of outcome mean)\n")
    } else {
      cat("\n  MDE at 80% power: > ", max(test_taus), " MW (underpowered)\n")
    }
  }
} else {
  cat("  rdpower package not available. Skipping power analysis.\n")
  cat("  Install with: install.packages('rdpower')\n")
}

cat("\n=== Robustness checks complete ===\n")
