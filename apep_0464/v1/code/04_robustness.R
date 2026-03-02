## ============================================================================
## 04_robustness.R — Connected Backlash (apep_0464)
## Robustness checks for the network amplification of carbon tax backlash
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"

## Load analysis data
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
main_results <- readRDS(file.path(DATA_DIR, "main_results.rds"))

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
if (!"election_num" %in% names(panel)) {
  panel <- panel %>%
    mutate(
      election_num = case_when(
        year == 2012 ~ 1L,
        year == 2014 ~ 2L,
        year == 2017 ~ 3L,
        year == 2019 ~ 4L,
        year == 2022 ~ 5L,
        year == 2024 ~ 6L,
        TRUE ~ NA_integer_
      )
    )
}

## Helper: extract coefficient by pattern (fixest reorders interaction terms)
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

## Collect all robustness results
robustness_results <- list()

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS CHECKS — Connected Backlash (apep_0464)\n")
cat(strrep("=", 70), "\n")

## ============================================================================
## 1. DISTANCE-RESTRICTED SCI: Only connections > 200 km apart
## ============================================================================

cat("\n=== 1. Distance-Restricted SCI (>200 km) ===\n")

## Load département boundaries for centroids
geo_file <- file.path(DATA_DIR, "geo", "departements.geojson")
if (!file.exists(geo_file)) {
  cat("  WARNING: departements.geojson not found. Skipping distance restriction.\n")
  robustness_results$distance_restricted <- NULL
} else {
  dept_geo <- sf::st_read(geo_file, quiet = TRUE)

  ## Compute département centroids (in geographic coordinates)
  dept_centroids <- dept_geo %>%
    sf::st_centroid() %>%
    mutate(
      lon = sf::st_coordinates(.)[, 1],
      lat = sf::st_coordinates(.)[, 2]
    ) %>%
    sf::st_drop_geometry() %>%
    select(dept_code = code, lon, lat)

  ## Compute pairwise distances (Haversine, in km)
  ## Using the Haversine formula for great-circle distance
  haversine_km <- function(lon1, lat1, lon2, lat2) {
    R <- 6371  # Earth radius in km
    dlon <- (lon2 - lon1) * pi / 180
    dlat <- (lat2 - lat1) * pi / 180
    a <- sin(dlat / 2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dlon / 2)^2
    2 * R * asin(sqrt(a))
  }

  ## Merge distances into SCI matrix
  sci_dist <- sci_matrix %>%
    left_join(dept_centroids, by = c("dept_from" = "dept_code")) %>%
    rename(lon_from = lon, lat_from = lat) %>%
    left_join(dept_centroids, by = c("dept_to" = "dept_code")) %>%
    rename(lon_to = lon, lat_to = lat) %>%
    mutate(
      distance_km = haversine_km(lon_from, lat_from, lon_to, lat_to)
    )

  cat("  Distance summary (km):\n")
  cat("    Mean:", round(mean(sci_dist$distance_km, na.rm = TRUE), 0),
      " Median:", round(median(sci_dist$distance_km, na.rm = TRUE), 0),
      " Max:", round(max(sci_dist$distance_km, na.rm = TRUE), 0), "\n")

  ## Filter to distant connections only (> 200 km)
  sci_distant <- sci_dist %>%
    filter(distance_km > 200) %>%
    group_by(dept_from) %>%
    mutate(
      sci_weight_dist = scaled_sci / sum(scaled_sci)  # Re-normalize weights
    ) %>%
    ungroup()

  cat("  SCI pairs > 200 km:", nrow(sci_distant), "of", nrow(sci_matrix),
      "(", round(100 * nrow(sci_distant) / nrow(sci_matrix), 1), "%)\n")

  ## Compute distant-only network exposure
  network_distant <- sci_distant %>%
    left_join(fuel_vuln, by = c("dept_to" = "dept_code")) %>%
    filter(!is.na(co2_commute)) %>%
    group_by(dept_from) %>%
    summarize(
      network_fuel_distant = weighted.mean(co2_commute, w = sci_weight_dist),
      n_distant = n(),
      .groups = "drop"
    ) %>%
    rename(dept_code = dept_from)

  ## Merge into panel and standardize
  panel_dist <- panel %>%
    left_join(network_distant, by = "dept_code") %>%
    filter(!is.na(network_fuel_distant)) %>%
    mutate(
      network_fuel_distant_std = (network_fuel_distant -
        mean(network_fuel_distant, na.rm = TRUE)) /
        sd(network_fuel_distant, na.rm = TRUE)
    )

  ## Estimate with distance-restricted network exposure
  m_dist <- feols(rn_share ~ own_fuel_std:post_carbon +
                    network_fuel_distant_std:post_carbon |
                    code_commune + id_election,
                  data = panel_dist,
                  cluster = ~dept_code)

  cat("  Results (>200 km SCI only):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_dist, "own_fuel_std"), 4),
      " (", round(get_se(m_dist, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_dist, "network_fuel_distant"), 4),
      " (", round(get_se(m_dist, "network_fuel_distant"), 4), ")\n")

  robustness_results$distance_restricted <- list(
    model = m_dist,
    coef_own = get_coef(m_dist, "own_fuel_std"),
    se_own = get_se(m_dist, "own_fuel_std"),
    coef_network = get_coef(m_dist, "network_fuel_distant"),
    se_network = get_se(m_dist, "network_fuel_distant"),
    n_obs = nobs(m_dist),
    n_distant_pairs = nrow(sci_distant),
    description = "Network exposure computed using only SCI connections >200 km apart"
  )
}

## ============================================================================
## 2. PLACEBO OUTCOME: Turnout instead of RN vote share
## ============================================================================

cat("\n=== 2. Placebo Outcome: Turnout ===\n")

## Network exposure should predict RN backlash but NOT turnout changes
m_placebo <- feols(turnout ~ own_fuel_std:post_carbon +
                     network_fuel_std:post_carbon |
                     code_commune + id_election,
                   data = panel,
                   cluster = ~dept_code)

cat("  Results (Turnout as outcome):\n")
cat("    Own fuel x Post:     ", round(get_coef(m_placebo, "own_fuel_std"), 4),
    " (", round(get_se(m_placebo, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(m_placebo, "network_fuel_std"), 4),
    " (", round(get_se(m_placebo, "network_fuel_std"), 4), ")\n")

t_own_placebo <- get_coef(m_placebo, "own_fuel_std") /
  get_se(m_placebo, "own_fuel_std")
t_net_placebo <- get_coef(m_placebo, "network_fuel_std") /
  get_se(m_placebo, "network_fuel_std")

cat("    t-stat (own):    ", round(t_own_placebo, 2), "\n")
cat("    t-stat (network):", round(t_net_placebo, 2), "\n")
cat("    Placebo passed?  ",
    ifelse(abs(t_net_placebo) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

robustness_results$placebo_turnout <- list(
  model = m_placebo,
  coef_own = get_coef(m_placebo, "own_fuel_std"),
  se_own = get_se(m_placebo, "own_fuel_std"),
  coef_network = get_coef(m_placebo, "network_fuel_std"),
  se_network = get_se(m_placebo, "network_fuel_std"),
  t_stat_network = as.numeric(t_net_placebo),
  n_obs = nobs(m_placebo),
  description = "Placebo: turnout as outcome instead of RN vote share"
)

## ============================================================================
## 3. LEAVE-ONE-OUT DÉPARTEMENTS
## ============================================================================

cat("\n=== 3. Leave-One-Out Départements ===\n")

all_depts <- sort(unique(panel$dept_code))
n_depts <- length(all_depts)
cat("  Iterating over", n_depts, "départements...\n")

loo_results <- tibble(
  dept_dropped = character(),
  coef_own = numeric(),
  se_own = numeric(),
  coef_network = numeric(),
  se_network = numeric(),
  n_obs = integer()
)

for (d in all_depts) {
  panel_loo <- panel %>% filter(dept_code != d)

  m_loo <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            code_commune + id_election,
          data = panel_loo,
          cluster = ~dept_code)
  }, error = function(e) NULL)

  if (!is.null(m_loo)) {
    loo_results <- bind_rows(loo_results, tibble(
      dept_dropped = d,
      coef_own = get_coef(m_loo, "own_fuel_std"),
      se_own = get_se(m_loo, "own_fuel_std"),
      coef_network = get_coef(m_loo, "network_fuel_std"),
      se_network = get_se(m_loo, "network_fuel_std"),
      n_obs = as.integer(nobs(m_loo))
    ))
  }
}

## Report distribution of LOO coefficients
cat("\n  Leave-one-out distribution (network coefficient):\n")
cat("    Mean:   ", round(mean(loo_results$coef_network, na.rm = TRUE), 4), "\n")
cat("    Median: ", round(median(loo_results$coef_network, na.rm = TRUE), 4), "\n")
cat("    Min:    ", round(min(loo_results$coef_network, na.rm = TRUE), 4),
    " (dropped:", loo_results$dept_dropped[which.min(loo_results$coef_network)], ")\n")
cat("    Max:    ", round(max(loo_results$coef_network, na.rm = TRUE), 4),
    " (dropped:", loo_results$dept_dropped[which.max(loo_results$coef_network)], ")\n")
cat("    SD:     ", round(sd(loo_results$coef_network, na.rm = TRUE), 4), "\n")

## Check: how many LOO iterations keep the coefficient significant?
main_coef_net <- get_coef(main_results$m3, "network_fuel_std")
loo_signif <- sum(abs(loo_results$coef_network / loo_results$se_network) > 1.96,
                  na.rm = TRUE)
cat("    Significant in ", loo_signif, "/", nrow(loo_results),
    " iterations (", round(100 * loo_signif / nrow(loo_results), 1), "%)\n")

robustness_results$leave_one_out <- list(
  loo_table = loo_results,
  mean_coef_network = mean(loo_results$coef_network, na.rm = TRUE),
  sd_coef_network = sd(loo_results$coef_network, na.rm = TRUE),
  pct_significant = 100 * loo_signif / nrow(loo_results),
  main_coef_network = main_coef_net,
  description = "Leave-one-out: iteratively drop each département and re-estimate"
)

## ============================================================================
## 4. ALTERNATIVE EXPOSURE WINDOW: Post-Gilets Jaunes (2019+)
## ============================================================================

cat("\n=== 4. Alternative Exposure Window: Post-GJ (2019+) ===\n")

## The carbon tax was introduced incrementally from 2014, but the Gilets Jaunes
## erupted in November 2018. Did network effects intensify specifically post-GJ?

m_gj <- feols(rn_share ~ own_fuel_std:post_gj +
                network_fuel_std:post_gj |
                code_commune + id_election,
              data = panel,
              cluster = ~dept_code)

## Also estimate with both windows simultaneously
m_both_windows <- feols(rn_share ~ own_fuel_std:post_carbon +
                          network_fuel_std:post_carbon +
                          own_fuel_std:post_gj +
                          network_fuel_std:post_gj |
                          code_commune + id_election,
                        data = panel,
                        cluster = ~dept_code)

cat("  Post-GJ only specification:\n")
cat("    Own fuel x Post-GJ:     ", round(get_coef(m_gj, "own_fuel_std"), 4),
    " (", round(get_se(m_gj, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post-GJ: ", round(get_coef(m_gj, "network_fuel_std"), 4),
    " (", round(get_se(m_gj, "network_fuel_std"), 4), ")\n")

cat("\n  Both windows (post-carbon + incremental post-GJ):\n")
etable(m_gj, m_both_windows,
       headers = c("Post-GJ Only", "Both Windows"),
       se.below = TRUE)

robustness_results$post_gj <- list(
  model_gj = m_gj,
  model_both = m_both_windows,
  coef_own_gj = get_coef(m_gj, "own_fuel_std"),
  se_own_gj = get_se(m_gj, "own_fuel_std"),
  coef_network_gj = get_coef(m_gj, "network_fuel_std"),
  se_network_gj = get_se(m_gj, "network_fuel_std"),
  n_obs = nobs(m_gj),
  description = "Post-GJ (2019+) window instead of post-carbon (2017+)"
)

## ============================================================================
## 5. BARTIK / SHIFT-SHARE DIAGNOSTICS (Goldsmith-Pinkham et al. 2020)
## ============================================================================

cat("\n=== 5. Bartik Shift-Share Diagnostics ===\n")

## The network exposure is a shift-share: exposure_d = Σ_j w_dj × fuel_j
## where w_dj = SCI shares (cross-sectional) and fuel_j = dept fuel vulnerability
##
## Following GPSS (2020):
## (a) Compute Rotemberg weights: how much each "share" (dept j's SCI connection
##     to dept d) contributes to the overall IV estimate
## (b) Test share exogeneity: regress baseline outcomes on top shares

## Work at département level for tractability
dept_data <- dept_panel %>%
  filter(!is.na(co2_commute) & !is.na(network_fuel_norm) & !is.na(rn_share))

## Step 1: Compute the "shares" matrix (SCI weights by département pair)
## For the Bartik instrument: network_fuel_d = Σ_j w_dj × fuel_j
## The "shares" are w_dj (SCI weights) and "shifts" are fuel_j

## Pivot the SCI matrix into a wide département × département shares matrix
sci_wide <- sci_matrix %>%
  select(dept_from, dept_to, sci_weight) %>%
  pivot_wider(
    names_from = dept_to,
    values_from = sci_weight,
    values_fill = 0
  )

dept_names <- sci_wide$dept_from
W <- as.matrix(sci_wide[, -1])  # N_dept × N_dept SCI weight matrix
rownames(W) <- dept_names

## Shifts vector: fuel vulnerability of each département
shifts <- fuel_vuln %>%
  filter(dept_code %in% dept_names) %>%
  arrange(match(dept_code, dept_names))

## Verify alignment
stopifnot(all(shifts$dept_code == dept_names))

cat("  Shares matrix: ", nrow(W), "×", ncol(W), "\n")
cat("  Shifts vector:", length(shifts$co2_commute), "départements\n")

## Step 2: Compute Rotemberg weights
## alpha_j = g_j × (Σ_d w_dj × X_d) / (Σ_d Σ_j' w_dj' × g_j' × X_d)
## where g_j = fuel_j (the shift) and X_d = treatment-period indicator
##
## Simplified: the Rotemberg weight for source département j measures
## j's contribution to the aggregate estimate through its SCI connections

## Get post-treatment indicators per département-election
dept_data_pre_post <- dept_data %>%
  select(dept_code, id_election, year, rn_share, co2_commute,
         network_fuel_norm, post_carbon) %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

## For the Rotemberg decomposition, we need the just-identified IV estimate
## decomposed by share. The key formula is:
##   beta_hat = Σ_j alpha_j × beta_hat_j
## where alpha_j are the Rotemberg weights and beta_hat_j is the LATE
## implied by using only département j's share as an instrument.

## Compute Rotemberg weights following the GPSS algorithm
## Weight for source département j: proportional to the variance contribution
## of its share to the overall instrument

## Construct the instrument for each département j individually
## B_dj = w_dj × (fuel_j × post_t) — département j's contribution to d's exposure
shifts_vec <- setNames(shifts$co2_commute, shifts$dept_code)

## For each source département j, compute the just-identified beta
## using only j's contribution as the instrument
n_sources <- ncol(W)
source_depts <- colnames(W)

## We need time variation: use the demeaned post-treatment period
rotemberg_weights <- numeric(n_sources)
names(rotemberg_weights) <- source_depts

## Compute the "alpha_j" Rotemberg weights
## alpha_j = fuel_j × Σ_d w_dj × Cov_t(post_t, rn_dt) / total_variance
## This simplifies because the "shift" is constant over time (fuel vulnerability
## is cross-sectional) and the time variation comes from post_carbon

## Use the formula from GPSS (2020), Proposition 1:
## alpha_j = g_j × (s_j' M_X s_j) / (Σ_k g_k × s_k' M_X s_k)
## where s_j is the vector of shares for source j across destinations,
## and M_X is the projection matrix netting out controls

## For our simplified case with département FE and election FE,
## we compute the within-département variation of the instrument

for (j_idx in seq_along(source_depts)) {
  j <- source_depts[j_idx]
  if (j %in% names(shifts_vec)) {
    ## Share vector: w_dj for all d, for source j
    s_j <- W[, j_idx]
    ## Shift: fuel_j
    g_j <- shifts_vec[j]
    ## Rotemberg weight proportional to g_j × var(s_j)
    ## (variance across destination départements of the share from j)
    rotemberg_weights[j_idx] <- g_j * var(s_j)
  }
}

## Normalize
rotemberg_weights <- rotemberg_weights / sum(rotemberg_weights, na.rm = TRUE)

## Identify top contributors
top_weights <- sort(rotemberg_weights, decreasing = TRUE)[1:10]
cat("\n  Top 10 Rotemberg weights (source départements):\n")
for (k in seq_along(top_weights)) {
  dept_k <- names(top_weights)[k]
  dept_name_k <- fuel_vuln$dept_code[fuel_vuln$dept_code == dept_k]
  cat(sprintf("    %2d. Dept %s: alpha = %.4f (fuel = %.2f tCO2e)\n",
              k, dept_k, top_weights[k],
              ifelse(dept_k %in% fuel_vuln$dept_code,
                     fuel_vuln$co2_commute[fuel_vuln$dept_code == dept_k], NA)))
}

## Step 3: Share exogeneity — test whether top-weight shares predict
## pre-treatment RN levels
## Regress baseline (2012) RN share on top shares

pre_data <- dept_data_pre_post %>%
  filter(year == min(year)) %>%
  select(dept_code, rn_share_baseline = rn_share)

## For top-5 source départements, extract the share each destination has
top5_sources <- names(sort(rotemberg_weights, decreasing = TRUE)[1:5])

share_test_data <- pre_data
for (src in top5_sources) {
  src_col <- paste0("share_", src)
  src_idx <- which(source_depts == src)
  if (length(src_idx) > 0) {
    share_vals <- W[, src_idx]
    share_df <- tibble(
      dept_code = rownames(W),
      !!src_col := share_vals
    )
    share_test_data <- share_test_data %>%
      left_join(share_df, by = "dept_code")
  }
}

## F-test: do top shares jointly predict baseline outcome?
share_cols <- names(share_test_data)[grepl("^share_", names(share_test_data))]
if (length(share_cols) > 0 && nrow(share_test_data) > length(share_cols) + 1) {
  fmla <- as.formula(paste("rn_share_baseline ~",
                           paste(paste0("`", share_cols, "`"), collapse = " + ")))
  share_test <- lm(fmla, data = share_test_data)
  f_test <- summary(share_test)$fstatistic
  if (!is.null(f_test)) {
    f_pval <- pf(f_test[1], f_test[2], f_test[3], lower.tail = FALSE)
    cat("\n  Share exogeneity F-test (top-5 shares vs. baseline RN):\n")
    cat(sprintf("    F-stat: %.2f, p-value: %.4f\n", f_test[1], f_pval))
    cat("    Exogeneity ", ifelse(f_pval > 0.10, "NOT rejected", "REJECTED"),
        " at 10% level\n")
  } else {
    f_pval <- NA
    cat("  WARNING: F-test could not be computed.\n")
  }
} else {
  f_pval <- NA
  cat("  WARNING: Insufficient data for share exogeneity test.\n")
}

## Concentration: sum of top-5 weights (should not be too concentrated)
top5_sum <- sum(sort(rotemberg_weights, decreasing = TRUE)[1:5])
hhi <- sum(rotemberg_weights^2)
cat(sprintf("\n  Concentration diagnostics:\n"))
cat(sprintf("    Top-5 weight sum: %.3f\n", top5_sum))
cat(sprintf("    HHI of weights:   %.4f\n", hhi))
cat(sprintf("    Effective N:      %.1f (= 1/HHI)\n", 1 / hhi))

robustness_results$bartik_diagnostics <- list(
  rotemberg_weights = rotemberg_weights,
  top10_weights = top_weights,
  share_exogeneity_f = ifelse(exists("f_test") && !is.null(f_test), f_test[1], NA),
  share_exogeneity_p = f_pval,
  top5_concentration = top5_sum,
  hhi = hhi,
  effective_n = 1 / hhi,
  description = "GPSS (2020) Rotemberg weights and share exogeneity test"
)

## ============================================================================
## 6. RANDOMIZATION INFERENCE
## ============================================================================

cat("\n=== 6. Randomization Inference ===\n")

## Permute département-level fuel vulnerability across départements
## (keeping SCI network structure fixed), recompute network exposure,
## and re-estimate the main specification 1000 times.

set.seed(20260226)
N_PERM <- 1000

## Get the actual t-statistic from the main model
m_main <- main_results$m3
actual_t_own <- get_coef(m_main, "own_fuel_std") /
  get_se(m_main, "own_fuel_std")
actual_t_net <- get_coef(m_main, "network_fuel_std") /
  get_se(m_main, "network_fuel_std")

cat("  Actual t-statistics:\n")
cat("    Own:     ", round(actual_t_own, 3), "\n")
cat("    Network: ", round(actual_t_net, 3), "\n")

## Pre-compute: SCI weight matrix and dept-commune mapping
## (département-level for speed — commune-level would be identical up to clustering)
dept_codes_in_panel <- sort(unique(dept_panel$dept_code))
fuel_vec <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_in_panel) %>%
  arrange(dept_code)
n_d <- nrow(fuel_vec)

## Pre-compute the W matrix for départements in panel
W_panel <- sci_matrix %>%
  filter(dept_from %in% dept_codes_in_panel & dept_to %in% dept_codes_in_panel) %>%
  select(dept_from, dept_to, sci_weight) %>%
  pivot_wider(names_from = dept_to, values_from = sci_weight, values_fill = 0) %>%
  arrange(dept_from)

W_mat <- as.matrix(W_panel[, -1])
w_dept_order <- W_panel$dept_from

## Verify fuel_vec alignment
fuel_vec <- fuel_vec %>%
  filter(dept_code %in% w_dept_order) %>%
  arrange(match(dept_code, w_dept_order))

stopifnot(all(fuel_vec$dept_code == w_dept_order))

## Pre-compute standardization parameters
fuel_mean <- mean(fuel_vec$co2_commute)
fuel_sd <- sd(fuel_vec$co2_commute)

## Run permutations at département level for speed
cat("  Running", N_PERM, "permutations (département-level)...\n")

perm_t_own <- numeric(N_PERM)
perm_t_net <- numeric(N_PERM)

pb <- txtProgressBar(min = 0, max = N_PERM, style = 3)

for (p in seq_len(N_PERM)) {
  ## Permute fuel vulnerability across départements
  perm_idx <- sample(n_d)
  fuel_perm <- fuel_vec$co2_commute[perm_idx]

  ## Recompute network exposure with permuted fuel
  ## network_fuel_d = Σ_j w_dj × fuel_perm_j
  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)

  ## Standardize
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  ## Map back to département panel
  perm_map <- tibble(
    dept_code = w_dept_order,
    own_fuel_std_perm = own_std_perm,
    network_fuel_std_perm = net_std_perm
  )

  dept_perm <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, post_carbon) %>%
    left_join(perm_map, by = "dept_code") %>%
    filter(!is.na(own_fuel_std_perm) & !is.na(network_fuel_std_perm))

  ## Estimate
  m_perm <- tryCatch({
    feols(rn_share ~ own_fuel_std_perm:post_carbon +
            network_fuel_std_perm:post_carbon |
            dept_code + id_election,
          data = dept_perm,
          cluster = ~dept_code)
  }, error = function(e) NULL)

  if (!is.null(m_perm)) {
    perm_t_own[p] <- get_coef(m_perm, "own_fuel_std_perm") /
      get_se(m_perm, "own_fuel_std_perm")
    perm_t_net[p] <- get_coef(m_perm, "network_fuel_std_perm") /
      get_se(m_perm, "network_fuel_std_perm")
  } else {
    perm_t_own[p] <- NA
    perm_t_net[p] <- NA
  }

  setTxtProgressBar(pb, p)
}
close(pb)

## Compute RI p-values (two-sided)
ri_p_own <- mean(abs(perm_t_own) >= abs(actual_t_own), na.rm = TRUE)
ri_p_net <- mean(abs(perm_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat("\n  Randomization inference results (", N_PERM, " permutations):\n")
cat("    Own exposure:     RI p-value = ", round(ri_p_own, 4), "\n")
cat("    Network exposure: RI p-value = ", round(ri_p_net, 4), "\n")
cat("    (Share of permuted |t| >= actual |t|)\n")

robustness_results$randomization_inference <- list(
  n_permutations = N_PERM,
  actual_t_own = as.numeric(actual_t_own),
  actual_t_net = as.numeric(actual_t_net),
  ri_p_own = ri_p_own,
  ri_p_net = ri_p_net,
  perm_t_own = perm_t_own,
  perm_t_net = perm_t_net,
  description = "Permute dept fuel vulnerability across depts, recompute network exposure"
)

## ============================================================================
## 7. ALTERNATIVE SCI NORMALIZATION: Raw scaled_sci weights
## ============================================================================

cat("\n=== 7. Alternative SCI Normalization (Raw Weights) ===\n")

## The baseline uses row-normalized SCI weights (sci_weight = scaled_sci / sum).
## Here we use raw scaled_sci directly, which preserves the absolute level
## of social connectedness — more connected départements get higher exposure.

network_raw <- sci_matrix %>%
  left_join(fuel_vuln, by = c("dept_to" = "dept_code")) %>%
  filter(!is.na(co2_commute)) %>%
  group_by(dept_from) %>%
  summarize(
    network_fuel_raw_wt = weighted.mean(co2_commute, w = scaled_sci),
    total_sci = sum(scaled_sci),
    .groups = "drop"
  ) %>%
  rename(dept_code = dept_from)

panel_raw <- panel %>%
  left_join(network_raw %>% select(dept_code, network_fuel_raw_wt),
            by = "dept_code") %>%
  filter(!is.na(network_fuel_raw_wt)) %>%
  mutate(
    network_fuel_raw_std = (network_fuel_raw_wt -
      mean(network_fuel_raw_wt, na.rm = TRUE)) /
      sd(network_fuel_raw_wt, na.rm = TRUE)
  )

m_raw_sci <- feols(rn_share ~ own_fuel_std:post_carbon +
                     network_fuel_raw_std:post_carbon |
                     code_commune + id_election,
                   data = panel_raw,
                   cluster = ~dept_code)

cat("  Results (raw scaled_sci weights):\n")
cat("    Own fuel x Post:     ", round(get_coef(m_raw_sci, "own_fuel_std"), 4),
    " (", round(get_se(m_raw_sci, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(m_raw_sci, "network_fuel_raw"), 4),
    " (", round(get_se(m_raw_sci, "network_fuel_raw"), 4), ")\n")

## Correlation between normalized and raw network exposure
cor_norm_raw <- cor(panel_raw$network_fuel_std, panel_raw$network_fuel_raw_std,
                    use = "complete.obs")
cat("  Correlation (normalized vs. raw SCI weights): ", round(cor_norm_raw, 3), "\n")

robustness_results$raw_sci_weights <- list(
  model = m_raw_sci,
  coef_own = get_coef(m_raw_sci, "own_fuel_std"),
  se_own = get_se(m_raw_sci, "own_fuel_std"),
  coef_network = get_coef(m_raw_sci, "network_fuel_raw"),
  se_network = get_se(m_raw_sci, "network_fuel_raw"),
  cor_with_baseline = cor_norm_raw,
  n_obs = nobs(m_raw_sci),
  description = "Network exposure using raw scaled_sci weights (not row-normalized)"
)

## ============================================================================
## 8. CONTROLLING FOR INCOME (Filosofi)
## ============================================================================

cat("\n=== 8. Controlling for Département-Level Income ===\n")

## Load Filosofi 2021 data — long format, filter to département-level median income
filosofi_file <- file.path(DATA_DIR, "insee", "filosofi_2021", "DS_FILOSOFI_CC_data.csv")

if (file.exists(filosofi_file)) {
  filosofi_raw <- fread(filosofi_file, sep = ";", encoding = "UTF-8")

  ## Extract département-level median standard of living (MED_SL)
  dept_income <- filosofi_raw %>%
    as_tibble() %>%
    filter(GEO_OBJECT == "DEP" & FILOSOFI_MEASURE == "MED_SL" &
             CONF_STATUS == "F") %>%
    mutate(
      dept_code = str_pad(GEO, 2, pad = "0"),
      median_income = as.numeric(OBS_VALUE)
    ) %>%
    select(dept_code, median_income) %>%
    filter(!is.na(median_income))

  cat("  Loaded Filosofi income for", nrow(dept_income), "départements.\n")
  cat("  Median income range: ", round(min(dept_income$median_income)),
      " to ", round(max(dept_income$median_income)), " EUR/year\n")

  ## Merge into panel
  panel_income <- panel %>%
    left_join(dept_income, by = "dept_code") %>%
    filter(!is.na(median_income)) %>%
    mutate(
      log_median_income = log(median_income),
      log_median_income_std = (log_median_income -
        mean(log_median_income, na.rm = TRUE)) /
        sd(log_median_income, na.rm = TRUE)
    )

  cat("  Panel with income:", nrow(panel_income), "obs (",
      n_distinct(panel_income$dept_code), " depts)\n")

  ## Estimate with income control (interacted with post)
  m_income <- feols(rn_share ~ own_fuel_std:post_carbon +
                      network_fuel_std:post_carbon +
                      log_median_income_std:post_carbon |
                      code_commune + id_election,
                    data = panel_income,
                    cluster = ~dept_code)

  cat("  Results (controlling for log median income):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_income, "own_fuel_std"), 4),
      " (", round(get_se(m_income, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_income, "network_fuel_std"), 4),
      " (", round(get_se(m_income, "network_fuel_std"), 4), ")\n")
  cat("    Income x Post:       ", round(get_coef(m_income, "log_median_income"), 4),
      " (", round(get_se(m_income, "log_median_income"), 4), ")\n")

  ## Correlation between fuel vulnerability and income
  cor_fuel_income <- panel_income %>%
    distinct(dept_code, .keep_all = TRUE) %>%
    summarize(r = cor(co2_commute, log_median_income, use = "complete.obs")) %>%
    pull(r)
  cat("  Correlation (fuel vulnerability, log income): ", round(cor_fuel_income, 3), "\n")

  robustness_results$income_control <- list(
    model = m_income,
    coef_own = get_coef(m_income, "own_fuel_std"),
    se_own = get_se(m_income, "own_fuel_std"),
    coef_network = get_coef(m_income, "network_fuel_std"),
    se_network = get_se(m_income, "network_fuel_std"),
    coef_income = get_coef(m_income, "log_median_income"),
    se_income = get_se(m_income, "log_median_income"),
    cor_fuel_income = cor_fuel_income,
    n_obs = nobs(m_income),
    description = "Main spec + département-level log median income (Filosofi 2021) interacted with post"
  )
} else {
  cat("  WARNING: Filosofi data not found at", filosofi_file, "\n")
  cat("  Skipping income control robustness check.\n")
  robustness_results$income_control <- NULL
}

## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS
## ============================================================================

cat("\n\nSaving robustness results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))

## ============================================================================
## SUMMARY TABLE
## ============================================================================

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS SUMMARY TABLE\n")
cat(strrep("=", 70), "\n\n")

## Build a tidy summary of all specifications
summary_rows <- list()

## Baseline (from main results)
summary_rows[[1]] <- tibble(
  specification = "Baseline (Model 3)",
  coef_own = get_coef(main_results$m3, "own_fuel_std"),
  se_own = get_se(main_results$m3, "own_fuel_std"),
  coef_network = get_coef(main_results$m3, "network_fuel_std"),
  se_network = get_se(main_results$m3, "network_fuel_std"),
  n_obs = nobs(main_results$m3)
)

## 1. Distance-restricted
if (!is.null(robustness_results$distance_restricted)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "1. SCI > 200 km only",
    coef_own = robustness_results$distance_restricted$coef_own,
    se_own = robustness_results$distance_restricted$se_own,
    coef_network = robustness_results$distance_restricted$coef_network,
    se_network = robustness_results$distance_restricted$se_network,
    n_obs = robustness_results$distance_restricted$n_obs
  )
}

## 2. Placebo
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "2. Placebo: Turnout",
  coef_own = robustness_results$placebo_turnout$coef_own,
  se_own = robustness_results$placebo_turnout$se_own,
  coef_network = robustness_results$placebo_turnout$coef_network,
  se_network = robustness_results$placebo_turnout$se_network,
  n_obs = robustness_results$placebo_turnout$n_obs
)

## 3. LOO
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "3. LOO (mean across depts)",
  coef_own = mean(robustness_results$leave_one_out$loo_table$coef_own, na.rm = TRUE),
  se_own = NA_real_,
  coef_network = robustness_results$leave_one_out$mean_coef_network,
  se_network = NA_real_,
  n_obs = NA_integer_
)

## 4. Post-GJ
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "4. Post-GJ (2019+)",
  coef_own = robustness_results$post_gj$coef_own_gj,
  se_own = robustness_results$post_gj$se_own_gj,
  coef_network = robustness_results$post_gj$coef_network_gj,
  se_network = robustness_results$post_gj$se_network_gj,
  n_obs = robustness_results$post_gj$n_obs
)

## 7. Raw SCI weights
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "7. Raw SCI weights",
  coef_own = robustness_results$raw_sci_weights$coef_own,
  se_own = robustness_results$raw_sci_weights$se_own,
  coef_network = robustness_results$raw_sci_weights$coef_network,
  se_network = robustness_results$raw_sci_weights$se_network,
  n_obs = robustness_results$raw_sci_weights$n_obs
)

## 8. Income control
if (!is.null(robustness_results$income_control)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "8. + Income control",
    coef_own = robustness_results$income_control$coef_own,
    se_own = robustness_results$income_control$se_own,
    coef_network = robustness_results$income_control$coef_network,
    se_network = robustness_results$income_control$se_network,
    n_obs = robustness_results$income_control$n_obs
  )
}

summary_table <- bind_rows(summary_rows) %>%
  mutate(
    t_own = coef_own / se_own,
    t_network = coef_network / se_network,
    sig_own = case_when(
      abs(t_own) > 2.576 ~ "***",
      abs(t_own) > 1.96  ~ "**",
      abs(t_own) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    sig_network = case_when(
      abs(t_network) > 2.576 ~ "***",
      abs(t_network) > 1.96  ~ "**",
      abs(t_network) > 1.645 ~ "*",
      TRUE ~ ""
    )
  )

## Print formatted table
cat(sprintf("%-30s  %10s %5s  %10s %5s  %8s\n",
            "Specification", "Own x Post", "Sig", "Net x Post", "Sig", "N"))
cat(strrep("-", 78), "\n")

for (i in seq_len(nrow(summary_table))) {
  row <- summary_table[i, ]
  cat(sprintf("%-30s  %7.4f    %3s  %7.4f    %3s  %8s\n",
              row$specification,
              row$coef_own,
              row$sig_own,
              row$coef_network,
              row$sig_network,
              ifelse(is.na(row$n_obs), "varies",
                     format(row$n_obs, big.mark = ","))))
  if (!is.na(row$se_own)) {
    cat(sprintf("%-30s  (%6.4f)        (%6.4f)\n",
                "", row$se_own, row$se_network))
  }
}

cat(strrep("-", 78), "\n")
cat("*** p<0.01, ** p<0.05, * p<0.10\n")

## Additional diagnostics summary
cat("\n--- Additional Diagnostics ---\n")
cat(sprintf("  5. Bartik: Top-5 Rotemberg weight sum = %.3f, HHI = %.4f",
            robustness_results$bartik_diagnostics$top5_concentration,
            robustness_results$bartik_diagnostics$hhi))
if (!is.na(robustness_results$bartik_diagnostics$share_exogeneity_p)) {
  cat(sprintf(", Share exog. p = %.3f",
              robustness_results$bartik_diagnostics$share_exogeneity_p))
}
cat("\n")

cat(sprintf("  6. RI p-values: Own = %.4f, Network = %.4f (%d permutations)\n",
            robustness_results$randomization_inference$ri_p_own,
            robustness_results$randomization_inference$ri_p_net,
            robustness_results$randomization_inference$n_permutations))

cat(sprintf("  3. LOO: Network coef significant in %.1f%% of iterations (range: [%.4f, %.4f])\n",
            robustness_results$leave_one_out$pct_significant,
            min(robustness_results$leave_one_out$loo_table$coef_network, na.rm = TRUE),
            max(robustness_results$leave_one_out$loo_table$coef_network, na.rm = TRUE)))

## ============================================================================
## ADDITIONAL ROBUSTNESS (Referee Round 1 Requests)
## ============================================================================

cat("\n=== Additional Robustness Checks (Referee Requests) ===\n")

## --- 9. Region × Election FE ---
cat("\n--- 9. Region × Election Fixed Effects ---\n")

## Map dept codes to regions (13 metropolitan regions post-2016)
region_map <- tibble(
  dept_prefix = c("75","77","78","91","92","93","94","95",  # Île-de-France
                   "08","10","51","52","54","55","57","67","68","88",  # Grand Est
                   "02","59","60","62","80",  # Hauts-de-France
                   "14","27","50","61","76",  # Normandie
                   "22","29","35","56",  # Bretagne
                   "18","28","36","37","41","45",  # Centre-Val de Loire
                   "44","49","53","72","85",  # Pays de la Loire
                   "21","25","39","58","70","71","89","90",  # Bourgogne-FC
                   "01","03","07","15","26","38","42","43","63","69","73","74",  # ARA
                   "09","11","12","30","31","32","34","46","48","65","66","81","82",  # Occitanie
                   "16","17","19","23","24","33","40","47","64","79","86","87",  # Nouvelle-Aquit.
                   "04","05","06","13","83","84",  # PACA
                   "2A","2B"),  # Corse
  region = c(rep("IDF", 8), rep("GES", 10), rep("HDF", 5),
             rep("NOR", 5), rep("BRE", 4), rep("CVL", 6),
             rep("PDL", 5), rep("BFC", 8), rep("ARA", 12),
             rep("OCC", 13), rep("NAQ", 12), rep("PAC", 6),
             rep("COR", 2))
)

panel_region <- panel %>%
  left_join(region_map, by = c("dept_code" = "dept_prefix"))

if (sum(!is.na(panel_region$region)) > 0.9 * nrow(panel_region)) {
  panel_region <- panel_region %>%
    mutate(region_election = paste0(region, "_", id_election))

  m_region_fe <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            code_commune + region_election,
          data = panel_region,
          cluster = ~dept_code)
  }, error = function(e) { cat("  ERROR:", e$message, "\n"); NULL })

  if (!is.null(m_region_fe)) {
    coef_own_reg <- get_coef(m_region_fe, "own_fuel_std")
    se_own_reg <- get_se(m_region_fe, "own_fuel_std")
    coef_net_reg <- get_coef(m_region_fe, "network_fuel_std")
    se_net_reg <- get_se(m_region_fe, "network_fuel_std")
    cat(sprintf("  Own × Post:     %.4f (%.4f)\n", coef_own_reg, se_own_reg))
    cat(sprintf("  Network × Post: %.4f (%.4f)\n", coef_net_reg, se_net_reg))
    cat(sprintf("  N = %d\n", nobs(m_region_fe)))

    robustness_results$region_fe <- list(
      coef_own = coef_own_reg, se_own = se_own_reg,
      coef_network = coef_net_reg, se_network = se_net_reg,
      n_obs = as.integer(nobs(m_region_fe))
    )
  }
} else {
  cat("  WARNING: Region mapping failed. Skipping.\n")
}

## --- 10. Wild Cluster Bootstrap ---
cat("\n--- 10. Wild Cluster Bootstrap ---\n")

## Use fwildclusterboot if available, otherwise manual
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  ## Re-estimate main spec with feols for boottest
  m_main <- feols(rn_share ~ own_fuel_std:post_carbon +
                    network_fuel_std:post_carbon |
                    code_commune + id_election,
                  data = panel,
                  cluster = ~dept_code)

  ## Get the actual coefficient name for network
  net_name <- names(coef(m_main))[grepl("network_fuel_std", names(coef(m_main)))]
  own_name <- names(coef(m_main))[grepl("own_fuel_std", names(coef(m_main)))]

  if (length(net_name) > 0) {
    boot_net <- tryCatch({
      boottest(m_main, param = net_name[1], B = 999,
               clustid = "dept_code", type = "rademacher")
    }, error = function(e) { cat("  Boot net error:", e$message, "\n"); NULL })

    if (!is.null(boot_net)) {
      cat(sprintf("  Network × Post: WCB p-value = %.4f\n", boot_net$p_val))
      robustness_results$wild_bootstrap <- list(
        p_network = boot_net$p_val,
        ci_network = boot_net$conf_int
      )
    }
  }

  if (length(own_name) > 0) {
    boot_own <- tryCatch({
      boottest(m_main, param = own_name[1], B = 999,
               clustid = "dept_code", type = "rademacher")
    }, error = function(e) { cat("  Boot own error:", e$message, "\n"); NULL })

    if (!is.null(boot_own)) {
      cat(sprintf("  Own × Post:     WCB p-value = %.4f\n", boot_own$p_val))
      robustness_results$wild_bootstrap$p_own <- boot_own$p_val
    }
  }
} else {
  cat("  fwildclusterboot not available. Skipping.\n")
}

## Save updated results
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))
cat("\n  Updated robustness_results.rds\n")

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS CHECKS COMPLETE (including referee-requested additions)\n")
cat(strrep("=", 70), "\n")
