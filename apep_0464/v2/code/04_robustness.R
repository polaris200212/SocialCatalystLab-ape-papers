## ============================================================================
## 04_robustness.R — Connected Backlash (apep_0464 v2)
## Robustness checks for the network amplification of carbon tax backlash
## v2: Expanded panel (10 elections), improved inference, additional checks
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

## Add election_num if missing (v2: 10 elections, 2014 = reference = 6)
if (!"election_num" %in% names(panel)) {
  panel <- panel %>%
    mutate(
      election_num = case_when(
        year == 2002 ~ 1L,
        year == 2004 ~ 2L,
        year == 2007 ~ 3L,
        year == 2009 ~ 4L,
        year == 2012 ~ 5L,
        year == 2014 ~ 6L,
        year == 2017 ~ 7L,
        year == 2019 ~ 8L,
        year == 2022 ~ 9L,
        year == 2024 ~ 10L,
        TRUE ~ NA_integer_
      )
    )
}

if (!"election_num" %in% names(dept_panel)) {
  dept_panel <- dept_panel %>%
    mutate(
      election_num = case_when(
        year == 2002 ~ 1L,
        year == 2004 ~ 2L,
        year == 2007 ~ 3L,
        year == 2009 ~ 4L,
        year == 2012 ~ 5L,
        year == 2014 ~ 6L,
        year == 2017 ~ 7L,
        year == 2019 ~ 8L,
        year == 2022 ~ 9L,
        year == 2024 ~ 10L,
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
cat("ROBUSTNESS CHECKS — Connected Backlash (apep_0464 v2)\n")
cat(strrep("=", 70), "\n")

## ============================================================================
## 1. DISTANCE-RESTRICTED SCI: Only connections > 200 km apart
## ============================================================================

cat("\n=== 1. Distance-Restricted SCI (>200 km) ===\n")

## Load departement boundaries for centroids
geo_file <- file.path(DATA_DIR, "geo", "departements.geojson")
if (!file.exists(geo_file)) {
  cat("  WARNING: departements.geojson not found. Skipping distance restriction.\n")
  robustness_results$distance_restricted <- NULL
} else {
  dept_geo <- sf::st_read(geo_file, quiet = TRUE)

  ## Compute departement centroids (in geographic coordinates)
  dept_centroids <- dept_geo %>%
    sf::st_centroid() %>%
    mutate(
      lon = sf::st_coordinates(.)[, 1],
      lat = sf::st_coordinates(.)[, 2]
    ) %>%
    sf::st_drop_geometry() %>%
    select(dept_code = code, lon, lat)

  ## Compute pairwise distances (Haversine, in km)
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
## 3. LEAVE-ONE-OUT DEPARTEMENTS
## ============================================================================

cat("\n=== 3. Leave-One-Out Departements ===\n")

all_depts <- sort(unique(panel$dept_code))
n_depts <- length(all_depts)
cat("  Iterating over", n_depts, "departements...\n")

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
  description = "Leave-one-out: iteratively drop each departement and re-estimate"
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

## The network exposure is a shift-share: exposure_d = SUM_j w_dj x fuel_j
## where w_dj = SCI shares (cross-sectional) and fuel_j = dept fuel vulnerability
##
## Following GPSS (2020):
## (a) Compute Rotemberg weights: how much each "share" (dept j's SCI connection
##     to dept d) contributes to the overall IV estimate
## (b) Test share exogeneity: regress baseline outcomes on top shares

## Work at departement level for tractability
dept_data <- dept_panel %>%
  filter(!is.na(co2_commute) & !is.na(network_fuel_norm) & !is.na(rn_share))

## Step 1: Compute the "shares" matrix (SCI weights by departement pair)
sci_wide <- sci_matrix %>%
  select(dept_from, dept_to, sci_weight) %>%
  pivot_wider(
    names_from = dept_to,
    values_from = sci_weight,
    values_fill = 0
  )

dept_names <- sci_wide$dept_from
W <- as.matrix(sci_wide[, -1])  # N_dept x N_dept SCI weight matrix
rownames(W) <- dept_names

## Shifts vector: fuel vulnerability of each departement
shifts <- fuel_vuln %>%
  filter(dept_code %in% dept_names) %>%
  arrange(match(dept_code, dept_names))

## Verify alignment
stopifnot(all(shifts$dept_code == dept_names))

cat("  Shares matrix: ", nrow(W), "x", ncol(W), "\n")
cat("  Shifts vector:", length(shifts$co2_commute), "departements\n")

## Step 2: Compute Rotemberg weights
dept_data_pre_post <- dept_data %>%
  select(dept_code, id_election, year, rn_share, co2_commute,
         network_fuel_norm, post_carbon) %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

shifts_vec <- setNames(shifts$co2_commute, shifts$dept_code)

n_sources <- ncol(W)
source_depts <- colnames(W)

rotemberg_weights <- numeric(n_sources)
names(rotemberg_weights) <- source_depts

for (j_idx in seq_along(source_depts)) {
  j <- source_depts[j_idx]
  if (j %in% names(shifts_vec)) {
    s_j <- W[, j_idx]
    g_j <- shifts_vec[j]
    rotemberg_weights[j_idx] <- g_j * var(s_j)
  }
}

## Normalize
rotemberg_weights <- rotemberg_weights / sum(rotemberg_weights, na.rm = TRUE)

## Identify top contributors
top_weights <- sort(rotemberg_weights, decreasing = TRUE)[1:10]
cat("\n  Top 10 Rotemberg weights (source departements):\n")
for (k in seq_along(top_weights)) {
  dept_k <- names(top_weights)[k]
  cat(sprintf("    %2d. Dept %s: alpha = %.4f (fuel = %.2f tCO2e)\n",
              k, dept_k, top_weights[k],
              ifelse(dept_k %in% fuel_vuln$dept_code,
                     fuel_vuln$co2_commute[fuel_vuln$dept_code == dept_k], NA)))
}

## Step 3: Share exogeneity test
pre_data <- dept_data_pre_post %>%
  filter(year == min(year)) %>%
  select(dept_code, rn_share_baseline = rn_share)

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

## Concentration diagnostics
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
## 6. STANDARD RANDOMIZATION INFERENCE (v2: 5000 permutations)
## ============================================================================

cat("\n=== 6. Randomization Inference (Standard) ===\n")

## Permute departement-level fuel vulnerability across departements
## (keeping SCI network structure fixed), recompute network exposure,
## and re-estimate the main specification 5000 times.

set.seed(20260226)
N_PERM <- 5000

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
dept_codes_in_panel <- sort(unique(dept_panel$dept_code))
fuel_vec <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_in_panel) %>%
  arrange(dept_code)
n_d <- nrow(fuel_vec)

## Pre-compute the W matrix for departements in panel
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

## Run permutations at departement level for speed
cat("  Running", N_PERM, "permutations (departement-level)...\n")

perm_t_own <- numeric(N_PERM)
perm_t_net <- numeric(N_PERM)

pb <- txtProgressBar(min = 0, max = N_PERM, style = 3)

for (p in seq_len(N_PERM)) {
  ## Permute fuel vulnerability across departements
  perm_idx <- sample(n_d)
  fuel_perm <- fuel_vec$co2_commute[perm_idx]

  ## Recompute network exposure with permuted fuel
  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)

  ## Standardize
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  ## Map back to departement panel
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
  description = "Permute dept fuel vulnerability across depts, recompute network exposure (5000 permutations)"
)

## ============================================================================
## 7. ALTERNATIVE SCI NORMALIZATION: Raw scaled_sci weights
## ============================================================================

cat("\n=== 7. Alternative SCI Normalization (Raw Weights) ===\n")

## The baseline uses row-normalized SCI weights (sci_weight = scaled_sci / sum).
## Here we use raw scaled_sci directly, which preserves the absolute level
## of social connectedness.

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

cat("\n=== 8. Controlling for Departement-Level Income ===\n")

## Load Filosofi 2021 data
filosofi_file <- file.path(DATA_DIR, "insee", "filosofi_2021", "DS_FILOSOFI_CC_data.csv")

if (file.exists(filosofi_file)) {
  filosofi_raw <- fread(filosofi_file, sep = ";", encoding = "UTF-8")

  ## Extract departement-level median standard of living (MED_SL)
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

  cat("  Loaded Filosofi income for", nrow(dept_income), "departements.\n")
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
    description = "Main spec + departement-level log median income (Filosofi 2021) interacted with post"
  )
} else {
  cat("  WARNING: Filosofi data not found at", filosofi_file, "\n")
  cat("  Skipping income control robustness check.\n")
  robustness_results$income_control <- NULL
}

## ============================================================================
## ============================================================================
## v2: NEW WORKSTREAMS — Improved Inference (WS3) and Additional Robustness (WS5)
## ============================================================================
## ============================================================================

cat("\n", strrep("=", 70), "\n")
cat("v2: NEW ROBUSTNESS CHECKS\n")
cat(strrep("=", 70), "\n")

## ============================================================================
## 9. WILD CLUSTER BOOTSTRAP (WS3: Improved Inference)
## ============================================================================

cat("\n=== 9. Wild Cluster Bootstrap (WS3) ===\n")

## Manual WCB implementation (fwildclusterboot not available for R 4.5.2)
## Uses Rademacher weights at the cluster (département) level
## Following Cameron, Gelbach & Miller (2008)

set.seed(20260226)
N_BOOT <- 9999

## Work at département level for tractability
dept_boot <- dept_panel %>%
  filter(!is.na(own_fuel_std) & !is.na(network_fuel_std) & !is.na(rn_share))

## Get cluster IDs
clusters <- sort(unique(dept_boot$dept_code))
G <- length(clusters)
cat("  Number of clusters (départements):", G, "\n")

## Estimate restricted model (under H0: beta = 0 for each coefficient)
## Full model
m_full_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                       network_fuel_std:post_carbon |
                       dept_code + id_election,
                     data = dept_boot,
                     cluster = ~dept_code)

## Get actual t-statistics
actual_coefs <- coef(m_full_dept)
actual_ses <- se(m_full_dept)
net_nm <- names(actual_coefs)[grepl("network_fuel_std", names(actual_coefs))]
own_nm <- names(actual_coefs)[grepl("own_fuel_std", names(actual_coefs))]

actual_t_own_wcb <- actual_coefs[own_nm[1]] / actual_ses[own_nm[1]]
actual_t_net_wcb <- actual_coefs[net_nm[1]] / actual_ses[net_nm[1]]

## Get residuals and fitted values from restricted model (no treatment effects)
m_restricted <- feols(rn_share ~ 1 | dept_code + id_election,
                      data = dept_boot)
resid_restricted <- residuals(m_restricted)
fitted_restricted <- fitted(m_restricted)

## Create design matrix
X_boot <- model.matrix(~ own_fuel_std:post_carbon + network_fuel_std:post_carbon - 1,
                        data = dept_boot)

## Wild cluster bootstrap
cat("  Running", N_BOOT, "WCB iterations (Rademacher weights)...\n")
boot_t_own <- numeric(N_BOOT)
boot_t_net <- numeric(N_BOOT)

for (b in seq_len(N_BOOT)) {
  ## Rademacher weights: +1 or -1 for each cluster
  rademacher <- sample(c(-1, 1), G, replace = TRUE)
  w_vec <- rademacher[match(dept_boot$dept_code, clusters)]

  ## Perturb residuals: y* = fitted + w * resid
  dept_boot$y_star <- fitted_restricted + w_vec * resid_restricted

  ## Re-estimate on perturbed data
  m_star <- tryCatch({
    feols(y_star ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            dept_code + id_election,
          data = dept_boot,
          cluster = ~dept_code)
  }, error = function(e) NULL)

  if (!is.null(m_star)) {
    star_coefs <- coef(m_star)
    star_ses <- se(m_star)
    own_nm_s <- names(star_coefs)[grepl("own_fuel_std", names(star_coefs))]
    net_nm_s <- names(star_coefs)[grepl("network_fuel_std", names(star_coefs))]
    if (length(own_nm_s) > 0) boot_t_own[b] <- star_coefs[own_nm_s[1]] / star_ses[own_nm_s[1]]
    if (length(net_nm_s) > 0) boot_t_net[b] <- star_coefs[net_nm_s[1]] / star_ses[net_nm_s[1]]
  }

  if (b %% 1000 == 0) cat("    Completed", b, "of", N_BOOT, "\n")
}

## Compute WCB p-values (two-sided)
wcb_p_own <- mean(abs(boot_t_own) >= abs(actual_t_own_wcb), na.rm = TRUE)
wcb_p_net <- mean(abs(boot_t_net) >= abs(actual_t_net_wcb), na.rm = TRUE)

cat(sprintf("  WCB results (%d replications):\n", N_BOOT))
cat(sprintf("    Own x Post:     WCB p-value = %.4f\n", wcb_p_own))
cat(sprintf("    Network x Post: WCB p-value = %.4f\n", wcb_p_net))

robustness_results$wild_bootstrap <- list(
  p_own = wcb_p_own,
  p_network = wcb_p_net,
  n_boot = N_BOOT,
  actual_t_own = as.numeric(actual_t_own_wcb),
  actual_t_net = as.numeric(actual_t_net_wcb),
  description = "Manual WCB (Rademacher weights, département-level clusters)"
)

## Clean up temp column
dept_boot$y_star <- NULL

## ============================================================================
## 10. BLOCK-PERMUTATION RANDOMIZATION INFERENCE (WS3: Improved Inference)
## ============================================================================

cat("\n=== 10. Block-Permutation RI (within regions) ===\n")

## Permute fuel vulnerability WITHIN regions (13 metropolitan regions),
## NOT across all departements. This preserves spatial autocorrelation
## structure. 10,000 permutations.

## Define the 13 metropolitan regions mapping
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

## Build a region lookup vector from dept code -> region
region_lookup <- character(0)
for (reg in names(region_blocks)) {
  for (dc in region_blocks[[reg]]) {
    region_lookup[dc] <- reg
  }
}

## Assign regions to fuel_vec (already aligned with w_dept_order)
fuel_vec$region <- region_lookup[fuel_vec$dept_code]

## Report region coverage
region_coverage <- fuel_vec %>%
  group_by(region) %>%
  summarize(n = n(), .groups = "drop")
cat("  Region blocks:\n")
for (i in seq_len(nrow(region_coverage))) {
  cat(sprintf("    %s: %d departements\n",
              region_coverage$region[i], region_coverage$n[i]))
}
cat("  Departements without region:", sum(is.na(fuel_vec$region)), "\n")

## Use actual t-statistics from main model (already computed above)
cat("  Actual t-statistics (from main model):\n")
cat("    Own:     ", round(actual_t_own, 3), "\n")
cat("    Network: ", round(actual_t_net, 3), "\n")

set.seed(20260227)
N_BLOCK_PERM <- 10000

cat("  Running", N_BLOCK_PERM, "block permutations (within-region)...\n")

block_perm_t_own <- numeric(N_BLOCK_PERM)
block_perm_t_net <- numeric(N_BLOCK_PERM)

## Pre-compute region indices for each departement in the W_mat order
## This avoids repeated string operations inside the loop
fuel_regions <- fuel_vec$region
unique_regions <- unique(fuel_regions[!is.na(fuel_regions)])

## For each region, store the indices of departements that belong to it
region_indices <- lapply(unique_regions, function(r) which(fuel_regions == r))
names(region_indices) <- unique_regions

## Indices of departements without a region (e.g., DOM-TOM) stay fixed
no_region_idx <- which(is.na(fuel_regions))

pb2 <- txtProgressBar(min = 0, max = N_BLOCK_PERM, style = 3)

for (p in seq_len(N_BLOCK_PERM)) {
  ## Block permutation: shuffle co2_commute WITHIN each region
  fuel_perm <- fuel_vec$co2_commute  # start with original

  for (r in unique_regions) {
    idx <- region_indices[[r]]
    if (length(idx) > 1) {
      fuel_perm[idx] <- fuel_perm[sample(idx)]
    }
  }
  ## Departements without region: leave unchanged (no permutation)

  ## Recompute network exposure with block-permuted fuel
  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)

  ## Standardize
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  ## Map back to departement panel
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
    block_perm_t_own[p] <- get_coef(m_perm, "own_fuel_std_perm") /
      get_se(m_perm, "own_fuel_std_perm")
    block_perm_t_net[p] <- get_coef(m_perm, "network_fuel_std_perm") /
      get_se(m_perm, "network_fuel_std_perm")
  } else {
    block_perm_t_own[p] <- NA
    block_perm_t_net[p] <- NA
  }

  setTxtProgressBar(pb2, p)
}
close(pb2)

## Compute block RI p-values (two-sided)
block_ri_p_own <- mean(abs(block_perm_t_own) >= abs(actual_t_own), na.rm = TRUE)
block_ri_p_net <- mean(abs(block_perm_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat("\n  Block RI results (", N_BLOCK_PERM, " within-region permutations):\n")
cat("    Own exposure:     Block RI p-value = ", round(block_ri_p_own, 4), "\n")
cat("    Network exposure: Block RI p-value = ", round(block_ri_p_net, 4), "\n")

robustness_results$block_ri <- list(
  n_permutations = N_BLOCK_PERM,
  actual_t_own = as.numeric(actual_t_own),
  actual_t_net = as.numeric(actual_t_net),
  block_ri_p_own = block_ri_p_own,
  block_ri_p_net = block_ri_p_net,
  perm_t_own = block_perm_t_own,
  perm_t_net = block_perm_t_net,
  region_blocks = region_blocks,
  description = "Block-permutation RI: permute fuel vulnerability WITHIN 13 metropolitan regions"
)

## ============================================================================
## 10b. INFERENCE COMPARISON TABLE (WS3)
## ============================================================================

cat("\n=== Inference Methods Comparison ===\n")

## Collect all p-values for the network coefficient
clustered_se_p_net <- 2 * pt(abs(actual_t_net),
                              df = length(unique(panel$dept_code)) - 1,
                              lower.tail = FALSE)
## (approximate; fixest uses its own DF correction, but this is close)

inference_comparison <- tibble(
  method = c("Clustered SE (departement)",
             "Standard RI (full permutation)",
             "Block RI (within-region permutation)",
             "Wild Cluster Bootstrap (Rademacher)"),
  p_own = c(
    2 * pt(abs(actual_t_own),
           df = length(unique(panel$dept_code)) - 1, lower.tail = FALSE),
    ri_p_own,
    block_ri_p_own,
    ifelse(!is.null(robustness_results$wild_bootstrap$p_own),
           robustness_results$wild_bootstrap$p_own, NA)
  ),
  p_network = c(
    clustered_se_p_net,
    ri_p_net,
    block_ri_p_net,
    ifelse(!is.null(robustness_results$wild_bootstrap$p_network),
           robustness_results$wild_bootstrap$p_network, NA)
  )
)

cat("\n  Inference comparison (p-values):\n")
cat(sprintf("  %-45s  %8s  %8s\n", "Method", "Own", "Network"))
cat("  ", strrep("-", 65), "\n")
for (i in seq_len(nrow(inference_comparison))) {
  cat(sprintf("  %-45s  %8.4f  %8.4f\n",
              inference_comparison$method[i],
              inference_comparison$p_own[i],
              inference_comparison$p_network[i]))
}

robustness_results$inference_comparison <- inference_comparison

## ============================================================================
## 11. PLACEBO PARTY OUTCOMES (WS5: Additional Robustness)
## ============================================================================

cat("\n=== 11. Placebo Party Outcomes: Green and Center-Right (WS5) ===\n")

## If network effects are specific to populist backlash against carbon tax,
## they should be weak or absent for Green (EELV) and Center-Right (LR/UMP) shares.

## 11a. Green share as outcome
if ("green_share" %in% names(panel)) {
  m_green <- feols(green_share ~ own_fuel_std:post_carbon +
                     network_fuel_std:post_carbon |
                     code_commune + id_election,
                   data = panel,
                   cluster = ~dept_code)

  cat("  Green share as outcome:\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_green, "own_fuel_std"), 4),
      " (", round(get_se(m_green, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_green, "network_fuel_std"), 4),
      " (", round(get_se(m_green, "network_fuel_std"), 4), ")\n")

  t_net_green <- get_coef(m_green, "network_fuel_std") /
    get_se(m_green, "network_fuel_std")
  cat("    t-stat (network):    ", round(t_net_green, 2), "\n")
  cat("    Placebo passed?      ",
      ifelse(abs(t_net_green) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

  robustness_results$placebo_green <- list(
    model = m_green,
    coef_own = get_coef(m_green, "own_fuel_std"),
    se_own = get_se(m_green, "own_fuel_std"),
    coef_network = get_coef(m_green, "network_fuel_std"),
    se_network = get_se(m_green, "network_fuel_std"),
    t_stat_network = as.numeric(t_net_green),
    n_obs = nobs(m_green),
    description = "Placebo: green (EELV) vote share as outcome"
  )
} else {
  cat("  WARNING: green_share not found in panel. Skipping.\n")
  robustness_results$placebo_green <- NULL
}

## 11b. Center-right share as outcome
if ("right_share" %in% names(panel)) {
  m_right <- feols(right_share ~ own_fuel_std:post_carbon +
                     network_fuel_std:post_carbon |
                     code_commune + id_election,
                   data = panel,
                   cluster = ~dept_code)

  cat("\n  Center-right share as outcome:\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_right, "own_fuel_std"), 4),
      " (", round(get_se(m_right, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_right, "network_fuel_std"), 4),
      " (", round(get_se(m_right, "network_fuel_std"), 4), ")\n")

  t_net_right <- get_coef(m_right, "network_fuel_std") /
    get_se(m_right, "network_fuel_std")
  cat("    t-stat (network):    ", round(t_net_right, 2), "\n")
  cat("    Placebo passed?      ",
      ifelse(abs(t_net_right) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

  robustness_results$placebo_right <- list(
    model = m_right,
    coef_own = get_coef(m_right, "own_fuel_std"),
    se_own = get_se(m_right, "own_fuel_std"),
    coef_network = get_coef(m_right, "network_fuel_std"),
    se_network = get_se(m_right, "network_fuel_std"),
    t_stat_network = as.numeric(t_net_right),
    n_obs = nobs(m_right),
    description = "Placebo: center-right (LR/UMP) vote share as outcome"
  )
} else {
  cat("  WARNING: right_share not found in panel. Skipping.\n")
  robustness_results$placebo_right <- NULL
}

## ============================================================================
## 12. URBAN/RURAL HETEROGENEITY (WS5: Additional Robustness)
## ============================================================================

cat("\n=== 12. Urban/Rural Heterogeneity (WS5) ===\n")

## Split departements into urbanization quartiles based on co2_commute
## (high co2_commute = more rural / car-dependent)
dept_fuel <- panel %>%
  distinct(dept_code, co2_commute) %>%
  filter(!is.na(co2_commute)) %>%
  mutate(
    urban_quartile = ntile(co2_commute, 4)
  )

cat("  Urbanization quartiles (based on co2_commute):\n")
quartile_summary <- dept_fuel %>%
  group_by(urban_quartile) %>%
  summarize(
    n_depts = n(),
    min_co2 = round(min(co2_commute), 2),
    max_co2 = round(max(co2_commute), 2),
    mean_co2 = round(mean(co2_commute), 2),
    .groups = "drop"
  )
print(quartile_summary)

## Merge quartiles into panel
panel_urban <- panel %>%
  left_join(dept_fuel %>% select(dept_code, urban_quartile), by = "dept_code") %>%
  filter(!is.na(urban_quartile))

## Estimate main spec for each quartile separately
urban_het_results <- list()

for (q in 1:4) {
  panel_q <- panel_urban %>% filter(urban_quartile == q)

  m_q <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            code_commune + id_election,
          data = panel_q,
          cluster = ~dept_code)
  }, error = function(e) {
    cat("  ERROR in quartile", q, ":", e$message, "\n")
    NULL
  })

  if (!is.null(m_q)) {
    coef_own_q <- get_coef(m_q, "own_fuel_std")
    se_own_q <- get_se(m_q, "own_fuel_std")
    coef_net_q <- get_coef(m_q, "network_fuel_std")
    se_net_q <- get_se(m_q, "network_fuel_std")
    n_depts_q <- n_distinct(panel_q$dept_code)

    label <- ifelse(q == 1, "Most Urban (Q1)",
             ifelse(q == 2, "Urban-Suburban (Q2)",
             ifelse(q == 3, "Suburban-Rural (Q3)",
                    "Most Rural (Q4)")))

    cat(sprintf("  Quartile %d (%s, %d depts):\n", q, label, n_depts_q))
    cat(sprintf("    Own x Post:     %.4f (%.4f)\n", coef_own_q, se_own_q))
    cat(sprintf("    Network x Post: %.4f (%.4f)\n", coef_net_q, se_net_q))

    urban_het_results[[paste0("Q", q)]] <- list(
      label = label,
      coef_own = coef_own_q,
      se_own = se_own_q,
      coef_network = coef_net_q,
      se_network = se_net_q,
      n_obs = nobs(m_q),
      n_depts = n_depts_q,
      co2_range = c(quartile_summary$min_co2[q], quartile_summary$max_co2[q])
    )
  }
}

robustness_results$urban_rural_heterogeneity <- list(
  quartile_results = urban_het_results,
  quartile_summary = quartile_summary,
  description = "Urban/rural heterogeneity: main spec by co2_commute quartile (Q1=most urban, Q4=most rural)"
)

## ============================================================================
## 13. REGION x ELECTION FIXED EFFECTS (WS5: Additional Robustness)
## ============================================================================

cat("\n=== 13. Region x Election Fixed Effects (WS5) ===\n")

## Map dept codes to regions (13 metropolitan regions post-2016)
region_map <- tibble(
  dept_prefix = c("75","77","78","91","92","93","94","95",  # Ile-de-France
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
    cat(sprintf("  Own x Post:     %.4f (%.4f)\n", coef_own_reg, se_own_reg))
    cat(sprintf("  Network x Post: %.4f (%.4f)\n", coef_net_reg, se_net_reg))
    cat(sprintf("  N = %d\n", nobs(m_region_fe)))

    robustness_results$region_fe <- list(
      model = m_region_fe,
      coef_own = coef_own_reg,
      se_own = se_own_reg,
      coef_network = coef_net_reg,
      se_network = se_net_reg,
      n_obs = as.integer(nobs(m_region_fe)),
      description = "Main spec with region x election FE instead of election FE"
    )
  }
} else {
  cat("  WARNING: Region mapping failed. Skipping.\n")
  robustness_results$region_fe <- NULL
}

## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS
## ============================================================================

cat("\n\nSaving robustness results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))

## ============================================================================
## COMPREHENSIVE SUMMARY TABLE (v2)
## ============================================================================

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS SUMMARY TABLE (v2)\n")
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

## 2. Placebo: Turnout
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

## 11a. Placebo: Green share
if (!is.null(robustness_results$placebo_green)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "11a. Placebo: Green share",
    coef_own = robustness_results$placebo_green$coef_own,
    se_own = robustness_results$placebo_green$se_own,
    coef_network = robustness_results$placebo_green$coef_network,
    se_network = robustness_results$placebo_green$se_network,
    n_obs = robustness_results$placebo_green$n_obs
  )
}

## 11b. Placebo: Center-right share
if (!is.null(robustness_results$placebo_right)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "11b. Placebo: Right share",
    coef_own = robustness_results$placebo_right$coef_own,
    se_own = robustness_results$placebo_right$se_own,
    coef_network = robustness_results$placebo_right$coef_network,
    se_network = robustness_results$placebo_right$se_network,
    n_obs = robustness_results$placebo_right$n_obs
  )
}

## 13. Region x Election FE
if (!is.null(robustness_results$region_fe)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "13. Region x Election FE",
    coef_own = robustness_results$region_fe$coef_own,
    se_own = robustness_results$region_fe$se_own,
    coef_network = robustness_results$region_fe$coef_network,
    se_network = robustness_results$region_fe$se_network,
    n_obs = robustness_results$region_fe$n_obs
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

cat(sprintf("  6. Standard RI p-values: Own = %.4f, Network = %.4f (%d permutations)\n",
            robustness_results$randomization_inference$ri_p_own,
            robustness_results$randomization_inference$ri_p_net,
            robustness_results$randomization_inference$n_permutations))

cat(sprintf("  10. Block RI p-values: Own = %.4f, Network = %.4f (%d permutations)\n",
            robustness_results$block_ri$block_ri_p_own,
            robustness_results$block_ri$block_ri_p_net,
            robustness_results$block_ri$n_permutations))

if (!is.null(robustness_results$wild_bootstrap)) {
  wcb_p_own <- ifelse(!is.null(robustness_results$wild_bootstrap$p_own),
                      robustness_results$wild_bootstrap$p_own, NA)
  wcb_p_net <- ifelse(!is.null(robustness_results$wild_bootstrap$p_network),
                      robustness_results$wild_bootstrap$p_network, NA)
  cat(sprintf("  9. WCB p-values: Own = %.4f, Network = %.4f (B=9999, Rademacher)\n",
              wcb_p_own, wcb_p_net))
}

cat(sprintf("  3. LOO: Network coef significant in %.1f%% of iterations (range: [%.4f, %.4f])\n",
            robustness_results$leave_one_out$pct_significant,
            min(robustness_results$leave_one_out$loo_table$coef_network, na.rm = TRUE),
            max(robustness_results$leave_one_out$loo_table$coef_network, na.rm = TRUE)))

## Urban/rural heterogeneity summary
if (!is.null(robustness_results$urban_rural_heterogeneity$quartile_results)) {
  cat("\n--- Urban/Rural Heterogeneity (Network coefficient) ---\n")
  for (q_name in names(robustness_results$urban_rural_heterogeneity$quartile_results)) {
    q_res <- robustness_results$urban_rural_heterogeneity$quartile_results[[q_name]]
    t_q <- q_res$coef_network / q_res$se_network
    sig_q <- ifelse(abs(t_q) > 2.576, "***",
             ifelse(abs(t_q) > 1.96, "**",
             ifelse(abs(t_q) > 1.645, "*", "")))
    cat(sprintf("  %s (%s): %.4f (%.4f) %s [%d depts]\n",
                q_name, q_res$label,
                q_res$coef_network, q_res$se_network, sig_q,
                q_res$n_depts))
  }
}

## Save final robustness results (redundant but ensures latest version)
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS CHECKS COMPLETE (v2: all workstreams)\n")
cat(strrep("=", 70), "\n")
