## ==========================================================================
## 03_main_analysis.R — Spatial RDD estimation
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- 1. Load analysis data ----
cat("Loading analysis data...\n")
dvf <- fread(file.path(data_dir, "dvf_zfe_analysis.csv"))
dvf[, date_mutation := as.Date(date_mutation)]
dvf[, zfe_start := as.Date(zfe_start)]
cat("Loaded:", nrow(dvf), "transactions\n")

# ---- 2. Main RDD specification ----
# Outcome: log(price/sqm)
# Running variable: distance to ZFE boundary (km, positive = inside)
# Cutoff: 0

# Focus on strong enforcement period (Crit'Air 4+, from June 2021)
post <- dvf[strong_enforcement == 1]
cat("Strong enforcement sample:", nrow(post), "transactions\n")

# Weak enforcement period for placebo (2020: Crit'Air 5 only + COVID)
pre <- dvf[enforcement_phase == 0]
cat("Weak enforcement (2020) sample:", nrow(pre), "transactions\n")

# 2a. Main estimate: pooled across cities, rdrobust
cat("\n=== Main RDD Estimate (Pooled, Post-ZFE) ===\n")
rdd_main <- rdrobust(
  y = post$log_price_sqm,
  x = post$dist_km,
  c = 0,
  kernel = "triangular",
  p = 1,     # local linear
  bwselect = "mserd"
)
summary(rdd_main)

# Store main result
main_tau <- rdd_main$coef[1]   # conventional
main_se  <- rdd_main$se[3]     # robust
main_bw  <- rdd_main$bws[1, 1] # bandwidth
main_n_l <- rdd_main$N[1]      # N left
main_n_r <- rdd_main$N[2]      # N right

cat("\n--- Main Result ---\n")
cat("  Treatment effect (log points):", round(main_tau, 4), "\n")
cat("  Robust SE:", round(main_se, 4), "\n")
cat("  Implied % effect:", round((exp(main_tau) - 1) * 100, 2), "%\n")
cat("  Optimal bandwidth:", round(main_bw, 3), "km\n")
cat("  N (left/right):", main_n_l, "/", main_n_r, "\n")

# 2b. With covariates
cat("\n=== Main RDD with Covariates ===\n")
# Prepare covariate matrix
post_cov <- post[!is.na(surface_reelle_bati) & !is.na(nombre_pieces_principales)]
covs <- as.matrix(post_cov[, .(surface_reelle_bati, nombre_pieces_principales,
                                 as.numeric(type_local == "Appartement"))])
colnames(covs) <- c("surface", "rooms", "apartment")

rdd_cov <- rdrobust(
  y = post_cov$log_price_sqm,
  x = post_cov$dist_km,
  c = 0,
  covs = covs,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)
summary(rdd_cov)

# 2c. City-by-city estimates
cat("\n=== City-by-City RDD Estimates ===\n")
city_results <- list()
for (city in unique(post$zfe_city)) {
  city_data <- post[zfe_city == city]
  if (nrow(city_data) < 100) {
    cat("  Skipping", city, "(too few obs:", nrow(city_data), ")\n")
    next
  }
  cat("  ", city, "(N=", nrow(city_data), ")...\n")
  tryCatch({
    rdd_city <- rdrobust(
      y = city_data$log_price_sqm,
      x = city_data$dist_km,
      c = 0,
      kernel = "triangular",
      p = 1,
      bwselect = "mserd"
    )
    city_results[[city]] <- data.frame(
      city = city,
      tau = rdd_city$coef[1],
      se_robust = rdd_city$se[3],
      pval_robust = rdd_city$pv[3],
      bw = rdd_city$bws[1, 1],
      n_left = rdd_city$N[1],
      n_right = rdd_city$N[2],
      pct_effect = (exp(rdd_city$coef[1]) - 1) * 100
    )
    cat("    tau =", round(rdd_city$coef[1], 4),
        "| se =", round(rdd_city$se[3], 4),
        "| bw =", round(rdd_city$bws[1, 1], 3), "km\n")
  }, error = function(e) {
    cat("    ERROR:", e$message, "\n")
  })
}

city_df <- bind_rows(city_results)
print(city_df)

# 2d. Weak enforcement placebo (2020: Crit'Air 5 only + COVID)
cat("\n=== Weak Enforcement Placebo (2020) ===\n")
# pre was already defined above as enforcement_phase == 0

rdd_placebo <- rdrobust(
  y = pre$log_price_sqm,
  x = pre$dist_km,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)
summary(rdd_placebo)

placebo_tau <- rdd_placebo$coef[1]
placebo_se <- rdd_placebo$se[3]
cat("\n--- Placebo Result ---\n")
cat("  Treatment effect (log points):", round(placebo_tau, 4), "\n")
cat("  Robust SE:", round(placebo_se, 4), "\n")
cat("  p-value:", round(rdd_placebo$pv[3], 4), "\n")

# 2e. Difference-in-discontinuities
# The key test: is the boundary effect different post-ZFE vs pre-ZFE?
cat("\n=== Difference in Discontinuities ===\n")
did_tau <- main_tau - placebo_tau
did_se <- sqrt(main_se^2 + placebo_se^2)  # conservative (assumes independence)
did_z <- did_tau / did_se
did_p <- 2 * pnorm(-abs(did_z))

cat("  DiD estimate (post - pre):", round(did_tau, 4), "\n")
cat("  SE:", round(did_se, 4), "\n")
cat("  z-stat:", round(did_z, 3), "\n")
cat("  p-value:", round(did_p, 4), "\n")
cat("  Implied % effect:", round((exp(did_tau) - 1) * 100, 2), "%\n")

# ---- 3. Heterogeneity ----
cat("\n=== Heterogeneity Analysis ===\n")

# 3a. By property type
het_results <- list()

for (ptype in c("Appartement", "Maison")) {
  sub <- post[type_local == ptype]
  if (nrow(sub) < 200) next
  cat("  ", ptype, "(N=", nrow(sub), ")...\n")
  tryCatch({
    rdd_het <- rdrobust(
      y = sub$log_price_sqm,
      x = sub$dist_km,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    )
    het_results[[ptype]] <- data.frame(
      group = ptype,
      tau = rdd_het$coef[1],
      se_robust = rdd_het$se[3],
      pval = rdd_het$pv[3],
      bw = rdd_het$bws[1, 1],
      n = rdd_het$N[1] + rdd_het$N[2],
      pct_effect = (exp(rdd_het$coef[1]) - 1) * 100
    )
  }, error = function(e) cat("    ERROR:", e$message, "\n"))
}

# 3b. By year (temporal dynamics)
for (yr in sort(unique(post$year))) {
  sub <- post[year == yr]
  if (nrow(sub) < 200) next
  cat("  Year", yr, "(N=", nrow(sub), ")...\n")
  tryCatch({
    rdd_yr <- rdrobust(
      y = sub$log_price_sqm,
      x = sub$dist_km,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    )
    het_results[[paste0("Year_", yr)]] <- data.frame(
      group = paste0("Year ", yr),
      tau = rdd_yr$coef[1],
      se_robust = rdd_yr$se[3],
      pval = rdd_yr$pv[3],
      bw = rdd_yr$bws[1, 1],
      n = rdd_yr$N[1] + rdd_yr$N[2],
      pct_effect = (exp(rdd_yr$coef[1]) - 1) * 100
    )
  }, error = function(e) cat("    ERROR:", e$message, "\n"))
}

het_df <- bind_rows(het_results)
print(het_df)

# ---- 3b. Segment Fixed Effects Specification ----
cat("\n=== Segment FE Specification ===\n")
# Use fixest for segment FE + commune-clustered SEs
# Estimate within MSE-optimal bandwidth
opt_bw <- rdd_main$bws[1,1]
post_bw <- post[abs(dist_km) <= opt_bw]
cat("  Observations within optimal BW (", round(opt_bw, 3), "km):",
    nrow(post_bw), "\n")
cat("  N effective left:", sum(post_bw$inside_zfe == 0),
    "| right:", sum(post_bw$inside_zfe == 1), "\n")

# Store effective N for reporting
n_eff_left <- sum(post_bw$inside_zfe == 0)
n_eff_right <- sum(post_bw$inside_zfe == 1)

# Segment FE + year-quarter FE
if ("segment_5km" %in% names(post_bw) && length(unique(post_bw$segment_5km)) > 1) {
  seg_fe <- feols(
    log_price_sqm ~ inside_zfe + dist_km + I(dist_km * inside_zfe) |
      segment_5km + yearqtr,
    data = post_bw,
    cluster = ~code_commune
  )
  cat("  Segment FE estimate:\n")
  print(summary(seg_fe))

  # Also without segment FE but with commune clustering for comparison
  base_clustered <- feols(
    log_price_sqm ~ inside_zfe + dist_km + I(dist_km * inside_zfe) | yearqtr,
    data = post_bw,
    cluster = ~code_commune
  )
  cat("  Base (commune-clustered) estimate:\n")
  print(summary(base_clustered))
} else {
  cat("  WARNING: segment_5km not available, skipping segment FE\n")
  seg_fe <- NULL
  base_clustered <- NULL
}

# ---- 3c. Power Calculation ----
cat("\n=== Power Calculation ===\n")
# MDE at 80% power given the main SE
# MDE = (z_alpha/2 + z_beta) * SE
# For two-sided test at 5% level with 80% power:
z_alpha <- 1.96
z_beta <- 0.84
mde <- (z_alpha + z_beta) * main_se
cat("  Robust SE:", round(main_se, 4), "\n")
cat("  MDE (80% power, 5% level):", round(mde, 4), "log points\n")
cat("  MDE in %:", round((exp(mde) - 1) * 100, 2), "%\n")

# ---- 4. Save results ----
cat("\nSaving results...\n")

results <- list(
  main = list(
    tau = main_tau, se = main_se, bw = main_bw,
    n_left = main_n_l, n_right = main_n_r,
    n_eff_left = n_eff_left, n_eff_right = n_eff_right,
    pct_effect = (exp(main_tau) - 1) * 100
  ),
  placebo = list(
    tau = placebo_tau, se = placebo_se,
    pval = rdd_placebo$pv[3]
  ),
  did = list(
    tau = did_tau, se = did_se, z = did_z, p = did_p,
    pct_effect = (exp(did_tau) - 1) * 100
  ),
  segment_fe = if (!is.null(seg_fe)) list(
    tau = coef(seg_fe)["inside_zfe"],
    se = sqrt(vcov(seg_fe)["inside_zfe", "inside_zfe"]),
    n = nobs(seg_fe)
  ) else NULL,
  base_clustered = if (!is.null(base_clustered)) list(
    tau = coef(base_clustered)["inside_zfe"],
    se = sqrt(vcov(base_clustered)["inside_zfe", "inside_zfe"]),
    n = nobs(base_clustered)
  ) else NULL,
  power = list(
    mde_log = mde,
    mde_pct = (exp(mde) - 1) * 100
  ),
  city = city_df,
  heterogeneity = het_df,
  rdd_main_obj = rdd_main,
  rdd_cov_obj = rdd_cov,
  rdd_placebo_obj = rdd_placebo
)

saveRDS(results, file.path(data_dir, "rdd_results.rds"))
cat("Results saved to:", file.path(data_dir, "rdd_results.rds"), "\n")
