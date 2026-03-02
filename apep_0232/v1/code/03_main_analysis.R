###############################################################################
# 03_main_analysis.R — Local projections and main results
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

panel <- readRDS("../data/panel_monthly.rds")
panel_annual <- readRDS("../data/panel_annual.rds")

# ===========================================================================
# 1. LOCAL PROJECTION IMPULSE RESPONSES — Baseline
# ===========================================================================
cat("=== LOCAL PROJECTIONS: MONETARY TRANSMISSION × HtM ===\n\n")

# Specification:
# Y_{s,t+h} - Y_{s,t-1} = α_s + α_t + γ(MP_t × HtM_s) + controls + ε

horizons <- c(0, 3, 6, 9, 12, 18, 24, 36, 48)

# Pre-compute forward changes for all horizons
panel_lp <- panel %>%
  filter(!is.na(brw_monthly), !is.na(htm_std)) %>%
  group_by(state_abbr) %>%
  arrange(date) %>%
  mutate(across(
    .cols = NULL  # placeholder
  )) %>%
  ungroup()

# For each horizon, compute Y_{t+h} - Y_{t-1}
for (h in horizons) {
  varname <- paste0("d_emp_h", h)
  panel_lp <- panel_lp %>%
    group_by(state_abbr) %>%
    arrange(date) %>%
    mutate(!!varname := 100 * (lead(log_emp, h) - lag(log_emp, 1))) %>%
    ungroup()
}

# Run local projections for each horizon
lp_results <- list()

for (h in horizons) {
  depvar <- paste0("d_emp_h", h)

  # Baseline: MP × HtM interaction with state + year-month FE
  fml <- as.formula(paste0(
    depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month"
  ))

  fit <- feols(fml, data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date)

  lp_results[[as.character(h)]] <- tibble(
    horizon = h,
    coef = coef(fit)["mp_htm"],
    se = sqrt(diag(vcov(fit)))["mp_htm"],
    nobs = fit$nobs,
    r2 = fitstat(fit, "r2")$r2
  )

  cat(sprintf("  h=%2d: γ = %7.4f (%.4f), N=%s\n",
              h, coef(fit)["mp_htm"],
              sqrt(diag(vcov(fit)))["mp_htm"],
              format(fit$nobs, big.mark = ",")))
}

lp_baseline <- bind_rows(lp_results) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    ci90_lo = coef - 1.645 * se,
    ci90_hi = coef + 1.645 * se,
    spec = "Baseline"
  )

saveRDS(lp_baseline, "../data/lp_baseline.rds")

# ===========================================================================
# 2. HORSE RACE: COMPETING CHANNELS
# ===========================================================================
cat("\n=== HORSE RACE: HtM vs ALTERNATIVE CHANNELS ===\n\n")

# Add competing interactions
panel_lp <- panel_lp %>%
  mutate(
    mp_homeown = brw_monthly * homeown_std
  )

# Run at key horizons: 12 and 24 months
horse_race_results <- list()

for (h in c(12, 24)) {
  depvar <- paste0("d_emp_h", h)

  # Model 1: HtM only
  fit1 <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  # Model 2: Homeownership only
  fit2 <- feols(
    as.formula(paste0(depvar, " ~ mp_homeown + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  # Model 3: Both (horse race)
  fit3 <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + mp_homeown + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  # Model 4: SNAP instead of poverty
  fit4 <- feols(
    as.formula(paste0(depvar, " ~ mp_snap + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp %>% filter(!is.na(snap_std)),
    vcov = "DK", panel.id = ~state_abbr + date
  )

  horse_race_results[[paste0("h", h)]] <- list(
    htm_only = fit1,
    homeown_only = fit2,
    both = fit3,
    snap = fit4
  )
}

saveRDS(horse_race_results, "../data/horse_race_results.rds")

# Report horse race at h=24
cat("Horse race at h=24 months:\n")
hr24 <- horse_race_results$h24
cat(sprintf("  HtM only:      γ_htm = %.4f (%.4f)\n",
            coef(hr24$htm_only)["mp_htm"], sqrt(diag(vcov(hr24$htm_only)))["mp_htm"]))
cat(sprintf("  Homeown only:  γ_own = %.4f (%.4f)\n",
            coef(hr24$homeown_only)["mp_homeown"], sqrt(diag(vcov(hr24$homeown_only)))["mp_homeown"]))
cat(sprintf("  Both:          γ_htm = %.4f (%.4f), γ_own = %.4f (%.4f)\n",
            coef(hr24$both)["mp_htm"], sqrt(diag(vcov(hr24$both)))["mp_htm"],
            coef(hr24$both)["mp_homeown"], sqrt(diag(vcov(hr24$both)))["mp_homeown"]))

# ===========================================================================
# 3. ASYMMETRY TEST (Tightening vs Easing)
# ===========================================================================
cat("\n=== ASYMMETRY: TIGHTENING vs EASING ===\n\n")

# Split monetary shocks into tightening (>0) and easing (<0)
panel_lp <- panel_lp %>%
  mutate(
    brw_tight = ifelse(brw_monthly > 0, brw_monthly, 0),
    brw_ease = ifelse(brw_monthly < 0, brw_monthly, 0),
    mp_htm_tight = brw_tight * htm_std,
    mp_htm_ease = brw_ease * htm_std
  )

asym_results <- list()
for (h in c(12, 24, 36)) {
  depvar <- paste0("d_emp_h", h)

  fit_asym <- feols(
    as.formula(paste0(depvar, " ~ mp_htm_tight + mp_htm_ease + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  asym_results[[paste0("h", h)]] <- fit_asym

  cat(sprintf("  h=%2d: γ_tight = %7.4f (%.4f), γ_ease = %7.4f (%.4f)\n",
              h,
              coef(fit_asym)["mp_htm_tight"], sqrt(diag(vcov(fit_asym)))["mp_htm_tight"],
              coef(fit_asym)["mp_htm_ease"], sqrt(diag(vcov(fit_asym)))["mp_htm_ease"]))
}

saveRDS(asym_results, "../data/asymmetry_results.rds")

# ===========================================================================
# 4. TERCILE ANALYSIS (High vs Medium vs Low HtM)
# ===========================================================================
cat("\n=== TERCILE IRFs ===\n\n")

# Classify states into HtM terciles
tercile_cuts <- quantile(panel_lp$htm_poverty_xs, probs = c(1/3, 2/3), na.rm = TRUE)

panel_lp <- panel_lp %>%
  mutate(
    htm_tercile = case_when(
      htm_poverty_xs <= tercile_cuts[1] ~ "Low HtM",
      htm_poverty_xs <= tercile_cuts[2] ~ "Medium HtM",
      TRUE ~ "High HtM"
    ),
    htm_tercile = factor(htm_tercile, levels = c("Low HtM", "Medium HtM", "High HtM"))
  )

tercile_irf <- list()
for (terc in levels(panel_lp$htm_tercile)) {
  sub <- panel_lp %>% filter(htm_tercile == terc)

  for (h in horizons) {
    depvar <- paste0("d_emp_h", h)

    # NOTE: Use year + month FE (not year_month) because brw_monthly is a common
    # shock — it's identical across states within a month, so year_month FE
    # absorbs it completely. year + month allows cross-year variation in brw
    # to identify the coefficient within each tercile subsample.
    fit <- feols(
      as.formula(paste0(depvar, " ~ brw_monthly + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year + factor(month_num)")),
      data = sub, vcov = "DK", panel.id = ~state_abbr + date
    )

    tercile_irf[[paste(terc, h)]] <- tibble(
      tercile = terc,
      horizon = h,
      coef = coef(fit)["brw_monthly"],
      se = sqrt(diag(vcov(fit)))["brw_monthly"]
    )
  }
}

tercile_irf_df <- bind_rows(tercile_irf) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    tercile = factor(tercile, levels = c("Low HtM", "Medium HtM", "High HtM"))
  )

saveRDS(tercile_irf_df, "../data/tercile_irf.rds")

cat("Tercile IRFs at h=24:\n")
tercile_irf_df %>%
  filter(horizon == 24) %>%
  mutate(label = sprintf("  %s: β = %.3f (%.3f)", tercile, coef, se)) %>%
  pull(label) %>%
  cat(sep = "\n")

# ===========================================================================
# 5. FISCAL TRANSFER CHANNEL (Bartik IV)
# ===========================================================================
cat("\n=== FISCAL TRANSFER CHANNEL ===\n\n")

# Reload annual panel (may have been updated with Bartik in 02_clean_data.R)
panel_annual <- readRDS("../data/panel_annual.rds")

# Normalize Bartik instrument per capita
panel_annual <- panel_annual %>%
  mutate(
    htm_std_annual = (htm_poverty_xs - mean(htm_poverty_xs, na.rm = TRUE)) /
      sd(htm_poverty_xs, na.rm = TRUE)
  )

# Prepare Bartik variables only where data exists
if ("bartik_transfer" %in% names(panel_annual)) {
  panel_annual <- panel_annual %>%
    mutate(
      bartik_pc = ifelse(!is.na(bartik_transfer) & !is.na(population) & population > 0,
                         bartik_transfer / population * 1000, NA_real_),
      bartik_gdp = ifelse(!is.na(bartik_transfer) & !is.na(gdp_millions) & gdp_millions > 0,
                          bartik_transfer / (gdp_millions * 1000), NA_real_),
      bartik_htm = bartik_gdp * htm_std_annual
    )
}

if (!"bartik_gdp" %in% names(panel_annual)) {
  panel_annual$bartik_gdp <- NA_real_
  panel_annual$bartik_htm <- NA_real_
}

n_bartik <- sum(!is.na(panel_annual$bartik_gdp) &
                !is.na(panel_annual$d_log_gdp) &
                !is.na(panel_annual$d_transfer_ratio), na.rm = TRUE)
cat(sprintf("  Observations with complete Bartik + outcome data: %d\n", n_bartik))

# --- OLS: ΔlogGDP = α + β(ΔTransfer/GDP) + γ(ΔTransfer/GDP × HtM) + FE + ε ---
ols_data <- panel_annual %>%
  filter(!is.na(d_log_gdp), !is.na(d_transfer_ratio), !is.na(htm_std_annual))

fiscal_ols <- feols(
  d_log_gdp ~ d_transfer_ratio + I(d_transfer_ratio * htm_std_annual) |
    abbr + year,
  data = ols_data,
  vcov = "DK", panel.id = ~abbr + year
)

cat("OLS transfer multiplier:\n")
cat(sprintf("  β = %.4f (%.4f)\n",
            coef(fiscal_ols)["d_transfer_ratio"],
            sqrt(diag(vcov(fiscal_ols)))["d_transfer_ratio"]))
cat(sprintf("  γ (HtM interaction) = %.4f (%.4f)\n",
            coef(fiscal_ols)["I(d_transfer_ratio * htm_std_annual)"],
            sqrt(diag(vcov(fiscal_ols)))["I(d_transfer_ratio * htm_std_annual)"]))
cat(sprintf("  N = %d\n", fiscal_ols$nobs))

# --- IV: Use Bartik as instrument (with fallback) ---
fiscal_iv <- NULL
iv_data <- panel_annual %>%
  filter(!is.na(d_log_gdp), !is.na(bartik_gdp),
         !is.na(d_transfer_ratio), !is.na(htm_std_annual))

if (nrow(iv_data) >= 100) {
  tryCatch({
    fiscal_iv <- feols(
      d_log_gdp ~ 1 | abbr + year |
        d_transfer_ratio + I(d_transfer_ratio * htm_std_annual) ~
        bartik_gdp + I(bartik_gdp * htm_std_annual),
      data = iv_data,
      vcov = "DK", panel.id = ~abbr + year
    )

    cat("\nIV transfer multiplier (Bartik):\n")
    iv_coefs <- coef(fiscal_iv)
    iv_ses <- sqrt(diag(vcov(fiscal_iv)))
    for (nm in names(iv_coefs)) {
      cat(sprintf("  %s = %.4f (%.4f)\n", nm, iv_coefs[nm], iv_ses[nm]))
    }
    cat(sprintf("  N = %d\n", fiscal_iv$nobs))
  }, error = function(e) {
    cat(sprintf("\nIV estimation failed: %s\n", e$message))
    cat("Falling back to OLS-only results.\n")
  })
} else {
  cat(sprintf("\nInsufficient Bartik data for IV (%d obs < 100 minimum). Using OLS only.\n",
              nrow(iv_data)))
  cat("NOTE: Re-run 01_fetch_data.R to include national totals in bea_transfers.rds,\n")
  cat("      then re-run 02_clean_data.R to reconstruct the Bartik instrument.\n")
}

# Save results (iv may be NULL if insufficient data)
saveRDS(list(ols = fiscal_ols, iv = fiscal_iv), "../data/fiscal_results.rds")

# ===========================================================================
# 6. SAVE ALL MAIN RESULTS
# ===========================================================================

main_results <- list(
  lp_baseline = lp_baseline,
  horse_race = horse_race_results,
  asymmetry = asym_results,
  tercile_irf = tercile_irf_df,
  fiscal = list(ols = fiscal_ols, iv = fiscal_iv)
)

saveRDS(main_results, "../data/main_results.rds")

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
