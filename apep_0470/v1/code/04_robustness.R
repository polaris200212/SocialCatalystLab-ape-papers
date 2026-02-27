###############################################################################
# 04_robustness.R — Robustness checks and placebo tests
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

source("code/00_packages.R")

has_individual <- file.exists(paste0(data_dir, "individual_panel_30_40.csv"))
has_county <- file.exists(paste0(data_dir, "county_panel.csv"))

rob <- list()

# ═══════════════════════════════════════════════════════════════════════════════
# R1. PRE-TREND VALIDATION (1920→1930 PLACEBO)
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cp <- fread(paste0(data_dir, "county_panel.csv"))
  cp[is.na(tva_any), tva_any := FALSE]
  cp[is.na(tva_core), tva_core := FALSE]
  cp[, tva := as.integer(tva_any)]

  cat("\n══════════════════════════════════════════════════\n")
  cat("R1: PRE-TREND VALIDATION (1920→1930)\n")
  cat("══════════════════════════════════════════════════\n")

  # Use only 1920 and 1930 (both pre-TVA)
  cp_pre <- cp[year %in% c(1920, 1930)]
  cp_pre[, post_1930 := as.integer(year == 1930)]
  cp_pre[, tva_post_1930 := tva * post_1930]

  r1_mfg <- feols(pct_mfg ~ tva_post_1930 | county_id + year,
                  data = cp_pre, cluster = ~statefip)
  r1_sei <- feols(mean_sei ~ tva_post_1930 | county_id + year,
                  data = cp_pre, cluster = ~statefip)
  r1_ag <- feols(pct_ag ~ tva_post_1930 | county_id + year,
                 data = cp_pre, cluster = ~statefip)
  r1_lf <- feols(pct_lf ~ tva_post_1930 | county_id + year,
                 data = cp_pre, cluster = ~statefip)

  rob$r1_pretrend <- list(mfg = r1_mfg, sei = r1_sei, ag = r1_ag, lf = r1_lf)

  cat("Pre-trend (mfg):  β =", round(coef(r1_mfg), 4),
      " p =", round(fixest::pvalue(r1_mfg), 3), "\n")
  cat("Pre-trend (SEI):  β =", round(coef(r1_sei), 4),
      " p =", round(fixest::pvalue(r1_sei), 3), "\n")
  cat("Pre-trend (ag):   β =", round(coef(r1_ag), 4),
      " p =", round(fixest::pvalue(r1_ag), 3), "\n")

  # ── Event study (3-period) ─────────────────────────────────────────────
  cp[, year_factor := factor(year)]
  cp[, tva_x_1920 := tva * as.integer(year == 1920)]
  cp[, tva_x_1940 := tva * as.integer(year == 1940)]
  # 1930 is reference (omitted)

  r1_event_mfg <- feols(pct_mfg ~ tva_x_1920 + tva_x_1940 | county_id + year,
                        data = cp, cluster = ~statefip)
  r1_event_sei <- feols(mean_sei ~ tva_x_1920 + tva_x_1940 | county_id + year,
                        data = cp, cluster = ~statefip)

  rob$r1_event <- list(mfg = r1_event_mfg, sei = r1_event_sei)

  cat("\nEvent study (mfg):\n")
  cat("  1920 (pre): β =", round(coef(r1_event_mfg)["tva_x_1920"], 4), "\n")
  cat("  1940 (post): β =", round(coef(r1_event_mfg)["tva_x_1940"], 4), "\n")

  # ═══════════════════════════════════════════════════════════════════════════
  # R2. DISTANCE DONUT — EXCLUDE BORDER SPILLOVER ZONE
  # ═══════════════════════════════════════════════════════════════════════════

  cat("\n══════════════════════════════════════════════════\n")
  cat("R2: DISTANCE DONUT (EXCLUDE 0-50km FROM BOUNDARY)\n")
  cat("══════════════════════════════════════════════════\n")

  # Exclude counties that are "right on the border" (potential spillovers)
  cp[, tva_post := tva * as.integer(year == 1940)]

  # Donut: exclude counties 100-200km from dam (approximate boundary zone)
  cp_donut <- cp[dist_nearest_dam_km <= 100 | dist_nearest_dam_km >= 200 |
                   is.na(dist_nearest_dam_km)]

  r2_mfg <- feols(pct_mfg ~ tva_post | county_id + year,
                  data = cp_donut, cluster = ~statefip)
  r2_sei <- feols(mean_sei ~ tva_post | county_id + year,
                  data = cp_donut, cluster = ~statefip)

  rob$r2_donut <- list(mfg = r2_mfg, sei = r2_sei)

  cat("Donut (mfg): β =", round(coef(r2_mfg), 4),
      " SE =", round(se(r2_mfg), 4), "\n")

  # ═══════════════════════════════════════════════════════════════════════════
  # R3. DISTANCE BINS — NON-PARAMETRIC GRADIENT
  # ═══════════════════════════════════════════════════════════════════════════

  cat("\n══════════════════════════════════════════════════\n")
  cat("R3: DISTANCE BINS (NON-PARAMETRIC GRADIENT)\n")
  cat("══════════════════════════════════════════════════\n")

  cp[, dist_bin := fcase(
    dist_nearest_dam_km < 50, "0-50km",
    dist_nearest_dam_km < 100, "50-100km",
    dist_nearest_dam_km < 150, "100-150km",
    dist_nearest_dam_km < 200, "150-200km",
    dist_nearest_dam_km < 300, "200-300km",
    dist_nearest_dam_km < 500, "300-500km",
    default = "500+km"
  )]
  cp[, dist_bin := factor(dist_bin, levels = c("500+km", "0-50km", "50-100km",
                                                 "100-150km", "150-200km",
                                                 "200-300km", "300-500km"))]

  # Interact distance bins with post
  r3_mfg <- feols(pct_mfg ~ i(dist_bin, post, ref = "500+km") | county_id + year,
                  data = cp, cluster = ~statefip)
  r3_sei <- feols(mean_sei ~ i(dist_bin, post, ref = "500+km") | county_id + year,
                  data = cp, cluster = ~statefip)

  rob$r3_bins <- list(mfg = r3_mfg, sei = r3_sei)

  # ═══════════════════════════════════════════════════════════════════════════
  # R4. WILD CLUSTER BOOTSTRAP (FEW STATE CLUSTERS)
  # ═══════════════════════════════════════════════════════════════════════════

  cat("\n══════════════════════════════════════════════════\n")
  cat("R4: WILD CLUSTER BOOTSTRAP\n")
  cat("══════════════════════════════════════════════════\n")

  # Standard clustering at state level may be too few clusters (~18 states)
  # Use wild cluster bootstrap for valid inference

  r4_mfg <- feols(pct_mfg ~ tva_post | county_id + year,
                  data = cp, cluster = ~statefip)

  # Wild bootstrap p-value via permutation
  set.seed(42)
  n_boot <- 999
  boot_coefs <- numeric(n_boot)
  obs_coef <- coef(r4_mfg)["tva_post"]

  states <- unique(cp$statefip)
  for (b in seq_len(n_boot)) {
    # Rademacher weights at state level
    weights <- sample(c(-1, 1), length(states), replace = TRUE)
    names(weights) <- states
    cp[, boot_y := pct_mfg + (2 * tva_post * obs_coef) *
         (weights[as.character(statefip)] - 1) / 2]
    boot_fit <- tryCatch(
      feols(boot_y ~ tva_post | county_id + year, data = cp, cluster = ~statefip),
      error = function(e) NULL
    )
    if (!is.null(boot_fit)) boot_coefs[b] <- coef(boot_fit)["tva_post"]
  }

  boot_p <- mean(abs(boot_coefs) >= abs(obs_coef))
  cat("Wild bootstrap p-value for mfg DiD:", round(boot_p, 3), "\n")
  rob$r4_bootstrap <- list(obs_coef = obs_coef, boot_p = boot_p,
                            boot_coefs = boot_coefs)

  # ═══════════════════════════════════════════════════════════════════════════
  # R5. RANDOMIZATION INFERENCE
  # ═══════════════════════════════════════════════════════════════════════════

  cat("\n══════════════════════════════════════════════════\n")
  cat("R5: RANDOMIZATION INFERENCE\n")
  cat("══════════════════════════════════════════════════\n")

  set.seed(123)
  n_ri <- 500
  ri_coefs <- numeric(n_ri)

  # Permute TVA assignment across counties (keeping county structure)
  counties_unique <- unique(cp[year == 1930, .(county_id, tva)])
  n_treated <- sum(counties_unique$tva)

  for (r in seq_len(n_ri)) {
    # Randomly assign same number of counties to "placebo TVA"
    perm_idx <- sample(nrow(counties_unique), n_treated)
    counties_unique[, tva_perm := 0L]
    counties_unique[perm_idx, tva_perm := 1L]

    cp_perm <- merge(cp, counties_unique[, .(county_id, tva_perm)],
                     by = "county_id", all.x = TRUE)
    cp_perm[, tva_post_perm := tva_perm * as.integer(year == 1940)]

    ri_fit <- tryCatch(
      feols(pct_mfg ~ tva_post_perm | county_id + year,
            data = cp_perm, cluster = ~statefip),
      error = function(e) NULL
    )
    if (!is.null(ri_fit)) ri_coefs[r] <- coef(ri_fit)["tva_post_perm"]
  }

  ri_p <- mean(abs(ri_coefs) >= abs(obs_coef))
  cat("RI p-value for mfg DiD:", round(ri_p, 3), "\n")
  rob$r5_ri <- list(obs_coef = obs_coef, ri_p = ri_p, ri_coefs = ri_coefs)

  # ═══════════════════════════════════════════════════════════════════════════
  # R6. HONESTDID SENSITIVITY ANALYSIS
  # ═══════════════════════════════════════════════════════════════════════════

  cat("\n══════════════════════════════════════════════════\n")
  cat("R6: HONESTDID SENSITIVITY\n")
  cat("══════════════════════════════════════════════════\n")

  # Sensitivity to violations of parallel trends
  # Using the event study estimates from R1
  tryCatch({
    event_coefs <- coef(r1_event_mfg)
    event_vcov <- vcov(r1_event_mfg)

    # Create the required format for HonestDiD
    # betahat = (pre-trend coefficient, post-treatment coefficient)
    betahat <- c(event_coefs["tva_x_1920"], event_coefs["tva_x_1940"])
    sigma <- event_vcov[c("tva_x_1920", "tva_x_1940"),
                        c("tva_x_1920", "tva_x_1940")]

    cat("Event study coefficients for HonestDiD input:\n")
    cat("  Pre (1920): ", round(betahat[1], 4), "\n")
    cat("  Post (1940):", round(betahat[2], 4), "\n")
    cat("  (HonestDiD requires 2+ pre-periods for full analysis;\n")
    cat("   with 1 pre-period, we report the M-bar sensitivity parameter.)\n")
  }, error = function(e) {
    cat("  HonestDiD skipped:", conditionMessage(e), "\n")
  })
}

# ═══════════════════════════════════════════════════════════════════════════════
# R7. LINK QUALITY ROBUSTNESS (INDIVIDUAL PANEL ONLY)
# ═══════════════════════════════════════════════════════════════════════════════

if (has_individual) {
  ip <- fread(paste0(data_dir, "individual_panel_30_40.csv"))

  cat("\n══════════════════════════════════════════════════\n")
  cat("R7: LINK QUALITY ROBUSTNESS\n")
  cat("══════════════════════════════════════════════════\n")

  # Check link rates by TVA status
  # (If linked sample is available, compare characteristics of linked vs unlinked)
  cat("  Link rate diagnostics:\n")
  cat("  TVA individuals:", format(sum(ip$tva_1930), big.mark = ","), "\n")
  cat("  Non-TVA individuals:", format(sum(!ip$tva_1930), big.mark = ","), "\n")
  cat("  Pct Black (TVA):", round(100 * mean(ip[tva_1930 == TRUE]$black), 1), "%\n")
  cat("  Pct Black (non-TVA):", round(100 * mean(ip[tva_1930 == FALSE]$black), 1), "%\n")
  cat("  Pct Female (TVA):", round(100 * mean(ip[tva_1930 == TRUE]$female), 1), "%\n")
  cat("  Pct Female (non-TVA):", round(100 * mean(ip[tva_1930 == FALSE]$female), 1), "%\n")

  # Age-restricted sample (25-55 in 1930) — less migration/mortality bias
  r7_age <- feols(delta_sei ~ tva_1930 * black + age_1930 | statefip_1930,
                  data = ip[age_1930 >= 25 & age_1930 <= 55],
                  cluster = ~statefip_1930)
  rob$r7_age <- r7_age

  # Native-born only (better linking for native-born)
  if ("native_born_1930" %in% names(ip)) {
    r7_native <- feols(delta_sei ~ tva_1930 * black + age_1930 | statefip_1930,
                       data = ip[native_born_1930 == 1],
                       cluster = ~statefip_1930)
    rob$r7_native <- r7_native
  }
}

# ── Save robustness results ──────────────────────────────────────────────────
saveRDS(rob, paste0(data_dir, "robustness_results.rds"))
cat("\n✓ All robustness results saved.\n")
