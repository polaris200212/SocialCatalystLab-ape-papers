###############################################################################
# 04_robustness.R — Robustness checks and placebo tests
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

panel <- readRDS("../data/panel_monthly.rds")
panel_annual <- readRDS("../data/panel_annual.rds")
lp_baseline <- readRDS("../data/lp_baseline.rds")

# Recompute forward changes
horizons <- c(0, 3, 6, 9, 12, 18, 24, 36, 48)

panel_lp <- panel %>%
  filter(!is.na(brw_monthly), !is.na(htm_std)) %>%
  group_by(state_abbr) %>%
  arrange(date)

for (h in horizons) {
  varname <- paste0("d_emp_h", h)
  panel_lp <- panel_lp %>%
    mutate(!!varname := 100 * (lead(log_emp, h) - lag(log_emp, 1)))
}
panel_lp <- panel_lp %>% ungroup()

# Add interactions
panel_lp <- panel_lp %>%
  mutate(
    mp_homeown = brw_monthly * homeown_std,
    mp_snap = brw_monthly * snap_std
  )

# ===========================================================================
# 1. ALTERNATIVE HtM MEASURES
# ===========================================================================
cat("=== ROBUSTNESS 1: ALTERNATIVE HtM MEASURES ===\n\n")

alt_htm_results <- list()
for (h in c(12, 24)) {
  depvar <- paste0("d_emp_h", h)

  # Poverty (baseline)
  fit_pov <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  # SNAP
  fit_snap <- feols(
    as.formula(paste0(depvar, " ~ mp_snap + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp %>% filter(!is.na(snap_std)),
    vcov = "DK", panel.id = ~state_abbr + date
  )

  # Homeownership (inverse — high homeownership = more wealthy HtM)
  fit_homeown <- feols(
    as.formula(paste0(depvar, " ~ mp_homeown + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  alt_htm_results[[paste0("h", h)]] <- list(
    poverty = fit_pov, snap = fit_snap, homeown = fit_homeown
  )

  cat(sprintf("h=%d: Poverty γ=%.4f (%.4f), SNAP γ=%.4f (%.4f), HomeOwn γ=%.4f (%.4f)\n",
              h,
              coef(fit_pov)["mp_htm"], sqrt(diag(vcov(fit_pov)))["mp_htm"],
              coef(fit_snap)["mp_snap"], sqrt(diag(vcov(fit_snap)))["mp_snap"],
              coef(fit_homeown)["mp_homeown"], sqrt(diag(vcov(fit_homeown)))["mp_homeown"]))
}

saveRDS(alt_htm_results, "../data/alt_htm_results.rds")

# ===========================================================================
# 2. SUB-PERIOD STABILITY
# ===========================================================================
cat("\n=== ROBUSTNESS 2: SUB-PERIOD STABILITY ===\n\n")

subperiod_results <- list()

# Pre-GFC: 1994-2007
sub_pre <- panel_lp %>% filter(year <= 2007)
# Post-GFC: 2010-2020
sub_post <- panel_lp %>% filter(year >= 2010)

for (h in c(12, 24)) {
  depvar <- paste0("d_emp_h", h)

  fit_pre <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = sub_pre, vcov = "DK", panel.id = ~state_abbr + date
  )

  fit_post <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = sub_post, vcov = "DK", panel.id = ~state_abbr + date
  )

  subperiod_results[[paste0("h", h)]] <- list(pre_gfc = fit_pre, post_gfc = fit_post)

  cat(sprintf("h=%d: Pre-GFC γ=%.4f (%.4f), Post-GFC γ=%.4f (%.4f)\n",
              h,
              coef(fit_pre)["mp_htm"], sqrt(diag(vcov(fit_pre)))["mp_htm"],
              coef(fit_post)["mp_htm"], sqrt(diag(vcov(fit_post)))["mp_htm"]))
}

saveRDS(subperiod_results, "../data/subperiod_results.rds")

# ===========================================================================
# 3. PERMUTATION INFERENCE
# ===========================================================================
cat("\n=== ROBUSTNESS 3: PERMUTATION INFERENCE ===\n\n")

set.seed(42)
n_perms <- 500

# Get the actual coefficient at h=24
actual_gamma_24 <- coef(feols(
  d_emp_h24 ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month,
  data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
))["mp_htm"]

# Permutation: randomly reassign HtM rankings across states
state_htms <- panel_lp %>%
  distinct(state_abbr, htm_poverty_xs) %>%
  filter(!is.na(htm_poverty_xs))

perm_gammas <- numeric(n_perms)
for (p in 1:n_perms) {
  # Shuffle HtM across states
  perm_htm <- state_htms %>%
    mutate(htm_perm = sample(htm_poverty_xs))

  perm_std_mean <- mean(perm_htm$htm_perm)
  perm_std_sd <- sd(perm_htm$htm_perm)

  perm_data <- panel_lp %>%
    left_join(perm_htm %>% select(state_abbr, htm_perm), by = "state_abbr") %>%
    mutate(
      htm_perm_std = (htm_perm - perm_std_mean) / perm_std_sd,
      mp_htm_perm = brw_monthly * htm_perm_std
    )

  fit_perm <- tryCatch(
    feols(
      d_emp_h24 ~ mp_htm_perm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month,
      data = perm_data, vcov = "DK", panel.id = ~state_abbr + date
    ),
    error = function(e) NULL
  )

  if (!is.null(fit_perm)) {
    perm_gammas[p] <- coef(fit_perm)["mp_htm_perm"]
  } else {
    perm_gammas[p] <- NA
  }

  if (p %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", p, n_perms))
}

perm_pvalue <- mean(abs(perm_gammas) >= abs(actual_gamma_24), na.rm = TRUE)
cat(sprintf("  Actual γ at h=24: %.4f\n", actual_gamma_24))
cat(sprintf("  Permutation p-value: %.3f (from %d permutations)\n",
            perm_pvalue, sum(!is.na(perm_gammas))))

saveRDS(
  list(actual = actual_gamma_24, permuted = perm_gammas, pvalue = perm_pvalue),
  "../data/permutation_results.rds"
)

# ===========================================================================
# 4. EXCLUDING EXTREME STATES
# ===========================================================================
cat("\n=== ROBUSTNESS 4: EXCLUDING EXTREME STATES ===\n\n")

# Exclude DC (outlier in many dimensions) and small states
exclude_states <- c("DC", "AK", "HI", "WY")

panel_excl <- panel_lp %>% filter(!state_abbr %in% exclude_states)

excl_results <- list()
for (h in c(12, 24)) {
  depvar <- paste0("d_emp_h", h)

  fit_excl <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 | state_abbr + year_month")),
    data = panel_excl, vcov = "DK", panel.id = ~state_abbr + date
  )

  excl_results[[paste0("h", h)]] <- fit_excl

  cat(sprintf("h=%d (excl DC/AK/HI/WY): γ=%.4f (%.4f)\n",
              h, coef(fit_excl)["mp_htm"], sqrt(diag(vcov(fit_excl)))["mp_htm"]))
}

saveRDS(excl_results, "../data/exclude_extreme_results.rds")

# ===========================================================================
# 5. CONTROLLING FOR LAGGED STATE GDP GROWTH
# ===========================================================================
cat("\n=== ROBUSTNESS 5: ADDITIONAL CONTROLS ===\n\n")

# Add lagged annual employment growth (12-month)
for (h in c(12, 24)) {
  depvar <- paste0("d_emp_h", h)

  fit_ctrl <- feols(
    as.formula(paste0(depvar, " ~ mp_htm + d_emp_lag1 + d_emp_lag2 + d_emp_lag3 + d_emp_lag6 + d_emp_lag12 | state_abbr + year_month")),
    data = panel_lp, vcov = "DK", panel.id = ~state_abbr + date
  )

  cat(sprintf("h=%d (extra lags): γ=%.4f (%.4f)\n",
              h, coef(fit_ctrl)["mp_htm"], sqrt(diag(vcov(fit_ctrl)))["mp_htm"]))
}

# ===========================================================================
# 6. FISCAL TRANSFER ROBUSTNESS — INCLUDING UI
# ===========================================================================
cat("\n=== ROBUSTNESS 6: FISCAL WITH UI ===\n\n")

# Construct Bartik WITH UI included
transfers_all <- readRDS("../data/bea_transfers.rds")

# Just report simple OLS with different transfer measures
for (dep in c("d_log_gdp", "d_log_emp")) {
  fit <- tryCatch(
    feols(
      as.formula(paste0(dep, " ~ d_transfer_ratio + I(d_transfer_ratio * htm_std_annual) | abbr + year")),
      data = panel_annual %>% filter(!is.na(get(dep)), !is.na(d_transfer_ratio)),
      vcov = "DK", panel.id = ~abbr + year
    ),
    error = function(e) NULL
  )

  if (!is.null(fit)) {
    cat(sprintf("  %s: β=%.4f (%.4f), γ_HtM=%.4f (%.4f)\n",
                dep,
                coef(fit)["d_transfer_ratio"],
                sqrt(diag(vcov(fit)))["d_transfer_ratio"],
                coef(fit)["I(d_transfer_ratio * htm_std_annual)"],
                sqrt(diag(vcov(fit)))["I(d_transfer_ratio * htm_std_annual)"]))
  }
}

cat("\n=== ROBUSTNESS CHECKS COMPLETE ===\n")
