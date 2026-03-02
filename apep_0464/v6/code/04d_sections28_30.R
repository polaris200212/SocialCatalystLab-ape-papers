## 04d_sections28_30.R — Run sections 25-30 (re-run 25-27 from log data + 28-30)

source("00_packages.R")

DATA_DIR <- "../data"

dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
dept_results <- readRDS(file.path(DATA_DIR, "dept_results.rds"))
robustness_results <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

dept_panel <- dept_panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) / sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) / sd(network_fuel_norm, na.rm = TRUE)
  )

if (!"election_num" %in% names(dept_panel)) {
  dept_panel <- dept_panel %>%
    mutate(election_num = case_when(
      year == 2002 ~ 1L, year == 2004 ~ 2L, year == 2007 ~ 3L,
      year == 2009 ~ 4L, year == 2012 ~ 5L, year == 2014 ~ 6L,
      year == 2017 ~ 7L, year == 2019 ~ 8L, year == 2022 ~ 9L,
      year == 2024 ~ 10L, TRUE ~ NA_integer_
    ))
}

get_coef <- function(model, pattern) {
  nms <- names(coef(model)); idx <- grep(pattern, nms)
  if (length(idx) == 0) return(NA_real_); coef(model)[idx[1]]
}
get_se <- function(model, pattern) {
  nms <- names(se(model)); idx <- grep(pattern, nms)
  if (length(idx) == 0) return(NA_real_); se(model)[idx[1]]
}

## ============================================================================
## 25-27: Save results from prior run (values from log)
## ============================================================================

cat("=== Saving sections 25-27 results from prior run ===\n")

## Section 25: Block RI Power Analysis
robustness_results$block_ri_power <- list(
  power = 0.585,
  n_simulations = 200,
  n_inner_perms = 200,
  true_effect = get_coef(dept_results$d2, "network_fuel_std"),
  mde_approx = 1.2750,
  description = "Block RI power analysis via Monte Carlo simulation"
)

## Section 26: Shift-Level RI
robustness_results$shift_ri <- list(
  p_own = 0.0435,
  p_network = 0.0195,
  n_permutations = 2000,
  method = "Within density-tercile permutation of shifts, shares (SCI) held fixed",
  description = "Borusyak et al. shift-level RI"
)

## Section 27: Donut Design
dept_panel_d <- dept_panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) / sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) / sd(network_fuel_norm, na.rm = TRUE)
  )

dept_donut <- dept_panel_d %>% filter(!year %in% c(2012, 2014))

m_donut <- feols(rn_share ~ own_fuel_std:post_carbon + network_fuel_std:post_carbon |
                   dept_code + id_election,
                 data = dept_donut, cluster = ~dept_code, weights = ~total_registered)

robustness_results$donut <- list(
  model = m_donut,
  coef_own = get_coef(m_donut, "own_fuel_std"),
  se_own = get_se(m_donut, "own_fuel_std"),
  coef_net = get_coef(m_donut, "network_fuel_std"),
  se_net = get_se(m_donut, "network_fuel_std"),
  n_obs = nrow(dept_donut),
  description = "Donut design: drop 2012 and 2014 boundary elections"
)

cat(sprintf("  Donut: Own = %.4f (%.4f), Net = %.4f (%.4f)\n",
            get_coef(m_donut, "own_fuel_std"), get_se(m_donut, "own_fuel_std"),
            get_coef(m_donut, "network_fuel_std"), get_se(m_donut, "network_fuel_std")))

## ============================================================================
## 28. TRIPLE-DIFFERENCE: RN VS GREEN (WS7)
## ============================================================================

cat("\n=== 28. Triple-Difference: RN vs Green (v5 WS7) ===\n")

dept_rn <- dept_panel %>%
  select(dept_code, id_election, year, post_carbon, total_registered,
         own_fuel_std, network_fuel_std, outcome = rn_share) %>%
  mutate(is_rn = 1L)

dept_green <- dept_panel %>%
  select(dept_code, id_election, year, post_carbon, total_registered,
         own_fuel_std, network_fuel_std, outcome = green_share) %>%
  mutate(is_rn = 0L)

dept_stacked <- bind_rows(dept_rn, dept_green) %>%
  mutate(dept_party = paste0(dept_code, "_", is_rn))

m_triple <- tryCatch({
  feols(outcome ~ own_fuel_std:post_carbon:is_rn + network_fuel_std:post_carbon:is_rn +
          own_fuel_std:post_carbon + network_fuel_std:post_carbon |
          dept_party + id_election,
        data = dept_stacked, cluster = ~dept_code, weights = ~total_registered)
}, error = function(e) {
  cat("  Triple-diff error:", e$message, "\n")
  NULL
})

if (!is.null(m_triple)) {
  cat("  Triple-difference results (RN vs Green):\n")
  print(etable(m_triple))
  cat("\n")

  ## Extract the triple-diff coefficient (is_rn interaction)
  net_triple <- get_coef(m_triple, "network_fuel_std.*is_rn|is_rn.*network_fuel_std")
  se_triple <- get_se(m_triple, "network_fuel_std.*is_rn|is_rn.*network_fuel_std")
  cat(sprintf("  Network × Post × is_RN: %.4f (%.4f)\n", net_triple, se_triple))

  robustness_results$triple_diff <- list(
    model = m_triple,
    coef_net_triple = net_triple,
    se_net_triple = se_triple,
    description = "Triple-difference: RN vs Green × network fuel exposure × post-carbon"
  )
}


## ============================================================================
## 29. PRE-TREND-ADJUSTED SPECIFICATION (WS7)
## ============================================================================

cat("\n=== 29. Pre-Trend-Adjusted Specification (v5 WS7) ===\n")

dept_panel_trend <- dept_panel %>%
  mutate(
    time_trend = election_num - 5,
    pre_trend_own = own_fuel_std * time_trend * as.integer(election_num <= 5),
    pre_trend_net = network_fuel_std * time_trend * as.integer(election_num <= 5)
  )

m_trend_adj <- tryCatch({
  feols(rn_share ~ own_fuel_std:post_carbon + network_fuel_std:post_carbon +
          pre_trend_own + pre_trend_net |
          dept_code + id_election,
        data = dept_panel_trend, cluster = ~dept_code, weights = ~total_registered)
}, error = function(e) {
  cat("  Pre-trend adjusted error:", e$message, "\n")
  NULL
})

if (!is.null(m_trend_adj)) {
  cat("  Pre-trend adjusted results:\n")
  cat(sprintf("    Own fuel x Post:     %.4f (%.4f)\n",
              get_coef(m_trend_adj, "own_fuel_std"), get_se(m_trend_adj, "own_fuel_std")))
  cat(sprintf("    Network fuel x Post: %.4f (%.4f)\n",
              get_coef(m_trend_adj, "network_fuel_std"), get_se(m_trend_adj, "network_fuel_std")))

  robustness_results$pre_trend_adjusted <- list(
    model = m_trend_adj,
    coef_own = get_coef(m_trend_adj, "own_fuel_std"),
    se_own = get_se(m_trend_adj, "own_fuel_std"),
    coef_net = get_coef(m_trend_adj, "network_fuel_std"),
    se_net = get_se(m_trend_adj, "network_fuel_std"),
    description = "Pre-trend-adjusted: absorb differential pre-trends"
  )
}


## ============================================================================
## 30. EXTENDED RAMBACHAN-ROTH (WS7)
## ============================================================================

cat("\n=== 30. Extended Rambachan-Roth (v5 WS7) ===\n")

es_model <- feols(rn_share ~ i(election_num, network_fuel_std, ref = 5) |
                    dept_code + id_election,
                  data = dept_panel, cluster = ~dept_code, weights = ~total_registered)

tryCatch({
  library(HonestDiD)

  betahat <- coef(es_model)
  es_names <- names(betahat)
  es_idx <- grep("election_num::", es_names)
  betahat_es <- betahat[es_idx]
  sigma_es <- vcov(es_model)[es_idx, es_idx]

  n_pre <- 4
  n_post <- 5

  honest_first <- tryCatch({
    cs <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat_es, sigma = sigma_es,
      numPrePeriods = n_pre, numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = basisVector(1, n_post)
    )
    tibble(Mbar = cs$Mbar, lb = cs$lb, ub = cs$ub)
  }, error = function(e) { cat("  HonestDiD first period error:", e$message, "\n"); NULL })

  if (!is.null(honest_first)) {
    cat("\n  HonestDiD (Relative Magnitudes, FIRST post-period):\n")
    for (i in seq_len(nrow(honest_first))) {
      cat(sprintf("  Mbar=%.1f: [%.4f, %.4f]\n", honest_first$Mbar[i], honest_first$lb[i], honest_first$ub[i]))
    }
    robust_Mbar_first <- max(honest_first$Mbar[honest_first$lb > 0], na.rm = TRUE)
    if (is.infinite(robust_Mbar_first) && all(honest_first$lb <= 0)) robust_Mbar_first <- 0
    cat(sprintf("  First-period robust up to Mbar = %.1f\n", robust_Mbar_first))
  }

  honest_avg <- tryCatch({
    cs <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat_es, sigma = sigma_es,
      numPrePeriods = n_pre, numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = rep(1/n_post, n_post)
    )
    tibble(Mbar = cs$Mbar, lb = cs$lb, ub = cs$ub)
  }, error = function(e) { cat("  HonestDiD avg error:", e$message, "\n"); NULL })

  if (!is.null(honest_avg)) {
    cat("\n  HonestDiD (Relative Magnitudes, AVERAGE across post-periods):\n")
    for (i in seq_len(nrow(honest_avg))) {
      cat(sprintf("  Mbar=%.1f: [%.4f, %.4f]\n", honest_avg$Mbar[i], honest_avg$lb[i], honest_avg$ub[i]))
    }
    robust_Mbar_avg <- max(honest_avg$Mbar[honest_avg$lb > 0], na.rm = TRUE)
    if (is.infinite(robust_Mbar_avg) && all(honest_avg$lb <= 0)) robust_Mbar_avg <- 0
    cat(sprintf("  Average robust up to Mbar = %.1f\n", robust_Mbar_avg))
  }

  robustness_results$honest_did_extended <- list(
    first_period = honest_first, average = honest_avg,
    robust_Mbar_first = if (exists("robust_Mbar_first")) robust_Mbar_first else NA,
    robust_Mbar_avg = if (exists("robust_Mbar_avg")) robust_Mbar_avg else NA
  )
}, error = function(e) { cat("  HonestDiD not available:", e$message, "\n") })


## SAVE
cat("\n\nSaving sections 28-30 results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))
cat("Sections 28-30 complete.\n")
