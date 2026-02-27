## 04b_robustness_continue.R — Run sections 25-30 that failed
## This resumes from the point where 04_robustness.R errored in section 25

source("00_packages.R")

DATA_DIR <- "../data"

## Load analysis data
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
main_results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
dept_results <- readRDS(file.path(DATA_DIR, "dept_results.rds"))

## Load partial robustness results from the interrupted run
robustness_results <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

## Standardize exposure variables (matching 03_main_analysis.R)
panel <- panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

dept_panel <- dept_panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

## Add election_num if missing
if (!"election_num" %in% names(dept_panel)) {
  dept_panel <- dept_panel %>%
    mutate(
      election_num = case_when(
        year == 2002 ~ 1L, year == 2004 ~ 2L, year == 2007 ~ 3L,
        year == 2009 ~ 4L, year == 2012 ~ 5L, year == 2014 ~ 6L,
        year == 2017 ~ 7L, year == 2019 ~ 8L, year == 2022 ~ 9L,
        year == 2024 ~ 10L, TRUE ~ NA_integer_
      ))
}

if (!"election_num" %in% names(panel)) {
  panel <- panel %>%
    mutate(
      election_num = case_when(
        year == 2002 ~ 1L, year == 2004 ~ 2L, year == 2007 ~ 3L,
        year == 2009 ~ 4L, year == 2012 ~ 5L, year == 2014 ~ 6L,
        year == 2017 ~ 7L, year == 2019 ~ 8L, year == 2022 ~ 9L,
        year == 2024 ~ 10L, TRUE ~ NA_integer_
      ))
}

## Helper functions
get_coef <- function(model, pattern) {
  nms <- names(coef(model))
  idx <- grep(pattern, nms)
  if (length(idx) == 0) return(NA_real_)
  coef(model)[idx[1]]
}
get_se <- function(model, pattern) {
  nms <- names(se(model))
  idx <- grep(pattern, nms)
  if (length(idx) == 0) return(NA_real_)
  se(model)[idx[1]]
}

## Build W_mat and dept_codes_ordered (needed by sections 25-26)
dept_codes_ordered <- sort(unique(dept_panel$dept_code))
n_dept <- length(dept_codes_ordered)

sci_wide <- sci_matrix %>%
  filter(dept_from %in% dept_codes_ordered & dept_to %in% dept_codes_ordered) %>%
  select(dept_from, dept_to, sci_weight) %>%
  pivot_wider(names_from = dept_to, values_from = sci_weight, values_fill = 0) %>%
  arrange(dept_from)

W_mat <- as.matrix(sci_wide[, -1])
rownames(W_mat) <- sci_wide$dept_from
W_mat <- W_mat[match(dept_codes_ordered, rownames(W_mat)),
                match(dept_codes_ordered[dept_codes_ordered %in% colnames(W_mat)],
                      colnames(W_mat))]

fuel_vec <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered))

## Need region info for block RI power analysis (hardcoded NUTS-2 regions)
region_blocks <- list(
  IDF = c("75", "77", "78", "91", "92", "93", "94", "95"),
  GES = c("08", "10", "51", "52", "54", "55", "57", "67", "68", "88"),
  HDF = c("02", "59", "60", "62", "80"),
  NOR = c("14", "27", "50", "61", "76"),
  BRE = c("22", "29", "35", "56"),
  CVL = c("18", "28", "36", "37", "41", "45"),
  PDL = c("44", "49", "53", "72", "85"),
  BFC = c("21", "25", "39", "58", "70", "71", "89", "90"),
  ARA = c("01", "03", "07", "15", "26", "38", "42", "43", "63", "69", "73", "74"),
  OCC = c("09", "11", "12", "30", "31", "32", "34", "46", "48", "65", "66", "81", "82"),
  NAQ = c("16", "17", "19", "23", "24", "33", "40", "47", "64", "79", "86", "87"),
  PAC = c("04", "05", "06", "13", "83", "84"),
  COR = c("2A", "2B")
)

region_lookup <- character(0)
for (reg in names(region_blocks)) {
  for (dc in region_blocks[[reg]]) {
    region_lookup[dc] <- reg
  }
}

fuel_vec$region <- region_lookup[fuel_vec$dept_code]
unique_regions <- unique(fuel_vec$region[!is.na(fuel_vec$region)])
region_indices <- lapply(unique_regions, function(r) which(fuel_vec$region == r))
names(region_indices) <- unique_regions

cat("\n=== RESUMING v5 sections 25-30 ===\n\n")

## ============================================================================
## v5 NEW: 25. BLOCK RI POWER ANALYSIS (WS5)
## ============================================================================

cat("\n=== 25. Block RI Power Analysis (v5 WS5) ===\n")

N_POWER_SIM <- 200
N_BLOCK_INNER <- 200

true_effect <- get_coef(dept_results$d2, "network_fuel_std")
cat(sprintf("  True effect to detect: %.4f\n", true_effect))
cat(sprintf("  Simulating %d datasets, %d block perms each...\n", N_POWER_SIM, N_BLOCK_INNER))

resid_sd <- sd(residuals(dept_results$d2))

power_rejections <- 0

for (s in seq_len(N_POWER_SIM)) {
  dept_sim <- dept_panel %>%
    select(dept_code, id_election, year, post_carbon, total_registered,
           own_fuel_std, network_fuel_std) %>%
    filter(!is.na(own_fuel_std) & !is.na(network_fuel_std)) %>%
    mutate(
      y_sim = true_effect * network_fuel_std * post_carbon +
        get_coef(dept_results$d2, "own_fuel_std") * own_fuel_std * post_carbon +
        rnorm(n(), 0, resid_sd)
    )

  m_sim <- tryCatch({
    feols(y_sim ~ own_fuel_std:post_carbon + network_fuel_std:post_carbon |
            dept_code + id_election,
          data = dept_sim, cluster = ~dept_code, weights = ~total_registered)
  }, error = function(e) NULL)

  if (is.null(m_sim)) next

  actual_t_sim <- get_coef(m_sim, "network_fuel_std") / get_se(m_sim, "network_fuel_std")

  block_t_sim <- numeric(N_BLOCK_INNER)
  for (p in seq_len(N_BLOCK_INNER)) {
    fuel_perm <- fuel_vec$co2_commute
    for (r in unique_regions) {
      idx <- region_indices[[r]]
      if (length(idx) > 1) fuel_perm[idx] <- fuel_perm[sample(idx)]
    }
    net_perm <- as.numeric(W_mat %*% fuel_perm)
    own_perm_std <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
    net_perm_std <- (net_perm - mean(net_perm)) / sd(net_perm)

    pmap <- tibble(dept_code = dept_codes_ordered,
                   own_fuel_std_p = own_perm_std,
                   network_fuel_std_p = net_perm_std)

    dp <- dept_sim %>%
      select(dept_code, id_election, y_sim, total_registered, post_carbon) %>%
      left_join(pmap, by = "dept_code")

    mp <- tryCatch({
      feols(y_sim ~ own_fuel_std_p:post_carbon + network_fuel_std_p:post_carbon |
              dept_code + id_election, data = dp, cluster = ~dept_code, weights = ~total_registered)
    }, error = function(e) NULL)

    if (!is.null(mp)) {
      block_t_sim[p] <- get_coef(mp, "network_fuel_std_p") / get_se(mp, "network_fuel_std_p")
    }
  }

  block_ri_p_sim <- mean(abs(block_t_sim) >= abs(actual_t_sim), na.rm = TRUE)
  if (block_ri_p_sim < 0.05) power_rejections <- power_rejections + 1

  if (s %% 100 == 0) cat(sprintf("  Power sim %d/%d, rejections so far: %d\n",
                                   s, N_POWER_SIM, power_rejections))
}

block_ri_power <- power_rejections / N_POWER_SIM
cat(sprintf("\n  Block RI power (13 regions, %d inner perms): %.1f%%\n",
            N_BLOCK_INNER, 100 * block_ri_power))
cat(sprintf("  Interpretation: With 13 NUTS-2 blocks, block RI has ~%.0f%% power\n",
            100 * block_ri_power))
cat("  to detect the estimated effect. Low power is expected given the coarse blocking.\n")

mde_approx <- 2.80 * get_se(dept_results$d2, "network_fuel_std")
cat(sprintf("  Approximate MDE (80%% power, dept-clustered SE): %.4f pp\n", mde_approx))

robustness_results$block_ri_power <- list(
  power = block_ri_power,
  n_simulations = N_POWER_SIM,
  n_inner_perms = N_BLOCK_INNER,
  true_effect = true_effect,
  mde_approx = mde_approx,
  description = "Block RI power analysis via Monte Carlo simulation"
)


## ============================================================================
## v5 NEW: 26. SHIFT-LEVEL RI / BORUSYAK ET AL. (WS5)
## ============================================================================

cat("\n=== 26. Shift-Level RI (Borusyak et al.) (v5 WS5) ===\n")

fuel_vec_shift <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered))

## Create density terciles for "comparable" permutation groups
density_terciles <- fuel_vec_shift %>%
  mutate(density_tercile = ntile(co2_commute, 3)) %>%
  select(dept_code, density_tercile)

N_SHIFT_RI <- 2000

shift_t_own <- numeric(N_SHIFT_RI)
shift_t_net <- numeric(N_SHIFT_RI)

actual_t_own <- get_coef(dept_results$d2, "own_fuel_std") / get_se(dept_results$d2, "own_fuel_std")
actual_t_net <- get_coef(dept_results$d2, "network_fuel_std") / get_se(dept_results$d2, "network_fuel_std")

cat(sprintf("  Running %d shift-level permutations (within density terciles)...\n", N_SHIFT_RI))

for (i in seq_len(N_SHIFT_RI)) {
  fuel_perm <- fuel_vec_shift$co2_commute
  for (q in 1:3) {
    idx <- which(density_terciles$density_tercile == q)
    if (length(idx) > 1) fuel_perm[idx] <- fuel_perm[sample(idx)]
  }

  net_perm <- as.numeric(W_mat %*% fuel_perm)
  own_perm_std <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_perm_std <- (net_perm - mean(net_perm)) / sd(net_perm)

  pmap <- tibble(dept_code = dept_codes_ordered,
                 own_fuel_std_p = own_perm_std,
                 network_fuel_std_p = net_perm_std)

  dp <- dept_panel %>%
    select(dept_code, id_election, rn_share, total_registered, post_carbon) %>%
    left_join(pmap, by = "dept_code")

  mp <- tryCatch({
    feols(rn_share ~ own_fuel_std_p:post_carbon + network_fuel_std_p:post_carbon |
            dept_code + id_election, data = dp, cluster = ~dept_code, weights = ~total_registered)
  }, error = function(e) NULL)

  if (!is.null(mp)) {
    shift_t_own[i] <- get_coef(mp, "own_fuel_std_p") / get_se(mp, "own_fuel_std_p")
    shift_t_net[i] <- get_coef(mp, "network_fuel_std_p") / get_se(mp, "network_fuel_std_p")
  }

  if (i %% 1000 == 0) cat(sprintf("    Completed %d of %d\n", i, N_SHIFT_RI))
}

shift_ri_p_own <- mean(abs(shift_t_own) >= abs(actual_t_own), na.rm = TRUE)
shift_ri_p_net <- mean(abs(shift_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat(sprintf("  Shift-level RI (within density terciles):\n"))
cat(sprintf("    Own exposure:     p = %.4f\n", shift_ri_p_own))
cat(sprintf("    Network exposure: p = %.4f\n", shift_ri_p_net))

robustness_results$shift_ri <- list(
  p_own = shift_ri_p_own,
  p_network = shift_ri_p_net,
  n_permutations = N_SHIFT_RI,
  method = "Within density-tercile permutation of shifts, shares (SCI) held fixed",
  description = "Borusyak et al. shift-level RI: permute fuel vulnerability within density terciles"
)


## ============================================================================
## v5 NEW: 27. DONUT DESIGN (WS7)
## ============================================================================

cat("\n=== 27. Donut Design (v5 WS7) ===\n")

dept_donut <- dept_panel %>%
  filter(!year %in% c(2012, 2014))

cat(sprintf("  Donut sample: %d obs (dropped 2012, 2014 boundary elections)\n", nrow(dept_donut)))

m_donut <- feols(rn_share ~ own_fuel_std:post_carbon + network_fuel_std:post_carbon |
                   dept_code + id_election,
                 data = dept_donut, cluster = ~dept_code, weights = ~total_registered)

cat("  Donut results (dept-level, pop-weighted):\n")
cat(sprintf("    Own fuel x Post:     %.4f (%.4f)\n",
            get_coef(m_donut, "own_fuel_std"), get_se(m_donut, "own_fuel_std")))
cat(sprintf("    Network fuel x Post: %.4f (%.4f)\n",
            get_coef(m_donut, "network_fuel_std"), get_se(m_donut, "network_fuel_std")))

robustness_results$donut <- list(
  model = m_donut,
  coef_own = get_coef(m_donut, "own_fuel_std"),
  se_own = get_se(m_donut, "own_fuel_std"),
  coef_net = get_coef(m_donut, "network_fuel_std"),
  se_net = get_se(m_donut, "network_fuel_std"),
  n_obs = nrow(dept_donut),
  description = "Donut design: drop 2012 and 2014 boundary elections"
)


## ============================================================================
## v5 NEW: 28. TRIPLE-DIFFERENCE: RN VS GREEN (WS7)
## ============================================================================

cat("\n=== 28. Triple-Difference: RN vs Green (v5 WS7) ===\n")

## Check if Green vote share is available
green_var <- intersect(c("green_share", "ecolo_share", "green_pct"), names(dept_panel))

if (length(green_var) > 0) {
  green_col <- green_var[1]
  cat(sprintf("  Using Green variable: %s\n", green_col))

  dept_rn <- dept_panel %>%
    select(dept_code, id_election, year, post_carbon, total_registered,
           own_fuel_std, network_fuel_std, outcome = rn_share) %>%
    mutate(is_rn = 1L)

  dept_green <- dept_panel %>%
    select(dept_code, id_election, year, post_carbon, total_registered,
           own_fuel_std, network_fuel_std, outcome = all_of(green_col)) %>%
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
    cat(etable(m_triple))
    cat("\n")

    robustness_results$triple_diff <- list(
      model = m_triple,
      description = "Triple-difference: RN vs Green × network fuel exposure × post-carbon"
    )
  }
} else {
  cat("  Green vote share not available in dept_panel. Skipping triple-diff.\n")
  cat("  Available columns:", paste(head(names(dept_panel), 20), collapse = ", "), "...\n")

  robustness_results$triple_diff <- list(
    description = "Triple-difference: SKIPPED — no Green vote share variable found"
  )
}


## ============================================================================
## v5 NEW: 29. PRE-TREND-ADJUSTED SPECIFICATION (WS7)
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
  cat(sprintf("    Pre-trend own:       %.4f (%.4f)\n",
              get_coef(m_trend_adj, "pre_trend_own"), get_se(m_trend_adj, "pre_trend_own")))
  cat(sprintf("    Pre-trend net:       %.4f (%.4f)\n",
              get_coef(m_trend_adj, "pre_trend_net"), get_se(m_trend_adj, "pre_trend_net")))

  robustness_results$pre_trend_adjusted <- list(
    model = m_trend_adj,
    coef_own = get_coef(m_trend_adj, "own_fuel_std"),
    se_own = get_se(m_trend_adj, "own_fuel_std"),
    coef_net = get_coef(m_trend_adj, "network_fuel_std"),
    se_net = get_se(m_trend_adj, "network_fuel_std"),
    description = "Pre-trend-adjusted: absorb differential pre-trends via exposure × time interaction"
  )
}


## ============================================================================
## v5 NEW: 30. EXTENDED RAMBACHAN-ROTH (WS7)
## ============================================================================

cat("\n=== 30. Extended Rambachan-Roth (v5 WS7) ===\n")

## First: event study for the network coefficient
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

  ## First post-period effect
  honest_first <- tryCatch({
    cs <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat_es,
      sigma = sigma_es,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = basisVector(1, n_post)
    )
    tibble(Mbar = cs$Mbar, lb = cs$lb, ub = cs$ub)
  }, error = function(e) {
    cat("  HonestDiD first period error:", e$message, "\n")
    NULL
  })

  if (!is.null(honest_first)) {
    cat("\n  HonestDiD (Relative Magnitudes, FIRST post-period):\n")
    cat(sprintf("  %-8s  %10s  %10s\n", "Mbar", "CI Lower", "CI Upper"))
    cat("  ", strrep("-", 35), "\n")
    for (i in seq_len(nrow(honest_first))) {
      cat(sprintf("  %-8.1f  %10.4f  %10.4f\n",
                  honest_first$Mbar[i], honest_first$lb[i], honest_first$ub[i]))
    }
    robust_Mbar_first <- max(honest_first$Mbar[honest_first$lb > 0], na.rm = TRUE)
    if (is.infinite(robust_Mbar_first) && all(honest_first$lb <= 0)) robust_Mbar_first <- 0
    cat(sprintf("  First-period effect robust up to Mbar = %.1f\n", robust_Mbar_first))
  }

  ## Average across all post-periods
  honest_avg <- tryCatch({
    l_avg <- rep(1/n_post, n_post)
    cs <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat_es,
      sigma = sigma_es,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = l_avg
    )
    tibble(Mbar = cs$Mbar, lb = cs$lb, ub = cs$ub)
  }, error = function(e) {
    cat("  HonestDiD average post-period error:", e$message, "\n")
    NULL
  })

  if (!is.null(honest_avg)) {
    cat("\n  HonestDiD (Relative Magnitudes, AVERAGE across all post-periods):\n")
    cat(sprintf("  %-8s  %10s  %10s\n", "Mbar", "CI Lower", "CI Upper"))
    cat("  ", strrep("-", 35), "\n")
    for (i in seq_len(nrow(honest_avg))) {
      cat(sprintf("  %-8.1f  %10.4f  %10.4f\n",
                  honest_avg$Mbar[i], honest_avg$lb[i], honest_avg$ub[i]))
    }
    robust_Mbar_avg <- max(honest_avg$Mbar[honest_avg$lb > 0], na.rm = TRUE)
    if (is.infinite(robust_Mbar_avg) && all(honest_avg$lb <= 0)) robust_Mbar_avg <- 0
    cat(sprintf("  Average effect robust up to Mbar = %.1f\n", robust_Mbar_avg))
  }

  robustness_results$honest_did_extended <- list(
    first_period = honest_first,
    average = honest_avg,
    robust_Mbar_first = if (exists("robust_Mbar_first")) robust_Mbar_first else NA,
    robust_Mbar_avg = if (exists("robust_Mbar_avg")) robust_Mbar_avg else NA,
    description = "Extended Rambachan-Roth: first post-period and average across all post-periods"
  )
}, error = function(e) {
  cat("  HonestDiD not available:", e$message, "\n")
})


## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS (v5)
## ============================================================================

cat("\n\nSaving robustness results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS CONTINUATION COMPLETE (v5: sections 25-30)\n")
cat(strrep("=", 70), "\n")
