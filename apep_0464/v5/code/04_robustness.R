## ============================================================================
## 04_robustness.R — Connected Backlash (apep_0464 v5)
## Robustness checks for the network amplification of carbon tax backlash
## v3: AKM shift-share SEs, two-way clustering, Conley HAC,
##     migration proxy, time-varying controls, distance bins, placebo timing,
##     election-type event studies, expanded inference comparison
## v4: Immigration horse-race (WS1), HonestDiD sensitivity (WS2),
##     Oster bounds (WS1), additional placebos 2002/2004 (WS7)
## v5: Timing decomposition (WS2), measurement error bounds (WS3),
##     distance bin with urbanization interaction (WS4), alternative blocking RI (WS5),
##     block RI power analysis (WS5), shift-level RI (WS5),
##     donut design (WS7), triple-difference (WS7),
##     pre-trend-adjusted specification with Rambachan-Roth (WS7)
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"

## Load analysis data
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
main_results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
dept_results <- readRDS(file.path(DATA_DIR, "dept_results.rds"))

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

## Add election_num if missing (v3: 10 elections, 2012 = reference = 5)
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
cat("ROBUSTNESS CHECKS — Connected Backlash (apep_0464 v3)\n")
cat(strrep("=", 70), "\n")


## ============================================================================
## 1. AKM (2019) SHIFT-SHARE ROBUST STANDARD ERRORS (NEW — WS1 P0)
## ============================================================================

cat("\n=== 1. AKM (2019) Shift-Share Robust SEs ===\n")
cat("  (Most critical new robustness check: inference accounting for\n")
cat("   shift-share structure of the network exposure instrument)\n\n")

## The network exposure is a shift-share: exposure_d = SUM_j w_dj * fuel_j
##   shares = SCI weights (w_dj)
##   shifts = fuel vulnerability (co2_commute)
## AKM (2019) provides valid SEs that account for this structure.

## Step 1: Build the shares matrix W (N_dept x N_dept)
## and align with département panel
dept_codes_ordered <- sort(unique(dept_panel$dept_code))
n_dept <- length(dept_codes_ordered)

sci_wide <- sci_matrix %>%
  filter(dept_from %in% dept_codes_ordered & dept_to %in% dept_codes_ordered) %>%
  select(dept_from, dept_to, sci_weight) %>%
  pivot_wider(
    names_from = dept_to,
    values_from = sci_weight,
    values_fill = 0
  ) %>%
  arrange(dept_from)

## Ensure column ordering matches row ordering
W_mat <- as.matrix(sci_wide[, -1])
rownames(W_mat) <- sci_wide$dept_from
## Reorder columns to match dept_codes_ordered
col_order <- match(dept_codes_ordered, colnames(W_mat))
col_order <- col_order[!is.na(col_order)]
W_mat <- W_mat[match(dept_codes_ordered, rownames(W_mat)),
                match(dept_codes_ordered[dept_codes_ordered %in% colnames(W_mat)],
                      colnames(W_mat))]

cat("  Shares matrix W:", nrow(W_mat), "x", ncol(W_mat), "\n")

## Step 2: Build shifts vector (fuel vulnerability by département)
fuel_vec_aligned <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered))

shifts_vec <- fuel_vec_aligned$co2_commute
names(shifts_vec) <- fuel_vec_aligned$dept_code

cat("  Shifts vector:", length(shifts_vec), "départements\n")

## Step 3: Compute the shift-share exposure for verification
ss_exposure <- as.numeric(W_mat %*% shifts_vec)
names(ss_exposure) <- dept_codes_ordered

## Step 4: Build long-difference dataset for AKM regression
## Average post - average pre for each département
dept_ld <- dept_panel %>%
  mutate(period = ifelse(post_carbon == 1, "post", "pre")) %>%
  group_by(dept_code, period) %>%
  summarize(
    rn_share = mean(rn_share, na.rm = TRUE),
    own_fuel = first(co2_commute),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = period,
    values_from = rn_share,
    names_prefix = "rn_"
  ) %>%
  mutate(
    delta_rn = rn_post - rn_pre
  ) %>%
  filter(!is.na(delta_rn))

## Merge in network exposure
dept_ld <- dept_ld %>%
  mutate(
    network_exposure = ss_exposure[match(dept_code, names(ss_exposure))],
    own_fuel_std = (own_fuel - mean(own_fuel, na.rm = TRUE)) /
      sd(own_fuel, na.rm = TRUE),
    network_fuel_std = (network_exposure - mean(network_exposure, na.rm = TRUE)) /
      sd(network_exposure, na.rm = TRUE)
  ) %>%
  filter(!is.na(network_fuel_std))

n_ld <- nrow(dept_ld)
cat("  Long-difference dataset: N =", n_ld, "départements\n")

## Step 5: Use ShiftShareSE::reg_ss() for AKM standard errors
## reg_ss expects: formula, data, W (shares matrix), X (shift vector), SE
##
## The function signature is:
##   reg_ss(formula, data, W, X, method = "AKM", ...)
## where W is the shares matrix (N x K) and X is the shifts vector (K x 1)
##
## We estimate: delta_rn ~ network_fuel_std + own_fuel_std
## The shift-share variable is network_fuel_std

## Align W matrix rows to match dept_ld
W_ld <- W_mat[match(dept_ld$dept_code, rownames(W_mat)),
               match(dept_ld$dept_code[dept_ld$dept_code %in% colnames(W_mat)],
                     colnames(W_mat))]

## Align shifts to columns of W_ld
shifts_ld <- shifts_vec[match(colnames(W_ld), names(shifts_vec))]

akm_result <- tryCatch({
  ## ShiftShareSE::reg_ss with AKM method
  ## The function takes the regression formula, data, shares matrix W,
  ## and shift vector X
  reg_ss(delta_rn ~ network_fuel_std + own_fuel_std,
         data = dept_ld,
         W = W_ld,
         X = shifts_ld,
         method = "AKM",
         alpha = 0.05)
}, error = function(e) {
  cat("  NOTE: reg_ss() returned error:", e$message, "\n")
  cat("  Attempting alternative specification...\n")

  ## Alternative: use the exposure directly
  tryCatch({
    reg_ss(delta_rn ~ network_fuel_std,
           data = dept_ld,
           W = W_ld,
           X = shifts_ld,
           method = "AKM",
           alpha = 0.05)
  }, error = function(e2) {
    cat("  reg_ss() alternative also failed:", e2$message, "\n")
    NULL
  })
})

## Also run standard OLS on the long-difference for comparison
ld_ols <- lm(delta_rn ~ network_fuel_std + own_fuel_std, data = dept_ld)
ld_ols_robust <- coeftest(ld_ols, vcov = vcovHC(ld_ols, type = "HC1"))

cat("\n  Long-difference OLS (robust SEs):\n")
print(ld_ols_robust)

## Extract AKM results if available
if (!is.null(akm_result)) {
  cat("\n  AKM (2019) shift-share robust inference:\n")
  print(akm_result)

  ## Extract AKM SE and p-value for the network coefficient
  akm_se_network <- tryCatch({
    if (is.list(akm_result) && "se" %in% names(akm_result)) {
      akm_result$se[grep("network", names(akm_result$se))[1]]
    } else if (is.list(akm_result) && "coefficients" %in% names(akm_result)) {
      akm_result$coefficients[grep("network", rownames(akm_result$coefficients)), "Std. Error"]
    } else {
      ## Try to extract from summary
      s <- summary(akm_result)
      s$coefficients[grep("network", rownames(s$coefficients)), "Std. Error"]
    }
  }, error = function(e) NA_real_)

  akm_p_network <- tryCatch({
    if (is.list(akm_result) && "p" %in% names(akm_result)) {
      akm_result$p[grep("network", names(akm_result$p))[1]]
    } else if (is.list(akm_result) && "coefficients" %in% names(akm_result)) {
      akm_result$coefficients[grep("network", rownames(akm_result$coefficients)), "Pr(>|t|)"]
    } else {
      s <- summary(akm_result)
      s$coefficients[grep("network", rownames(s$coefficients)), "Pr(>|t|)"]
    }
  }, error = function(e) NA_real_)

  cat(sprintf("  AKM SE (network): %.4f\n", akm_se_network))
  cat(sprintf("  AKM p-value (network): %.4f\n", akm_p_network))
} else {
  cat("  WARNING: ShiftShareSE::reg_ss() could not be run.\n")
  cat("  Falling back to manual AKM variance computation.\n")

  ## Manual AKM SE computation following Adao, Kolesar, Morales (2019)
  ## V_AKM = (X'X)^{-1} * SUM_k [ (SUM_i w_ik * e_i)^2 * g_k^2 ] * (X'X)^{-1}
  ## where e_i = residuals, w_ik = shares, g_k = shifts

  e_hat <- residuals(ld_ols)

  ## For each shift source k (département j that provides the "shift"),
  ## compute: sum_i w_ij * e_i (the share-weighted sum of residuals)
  ## Then weight by g_k^2

  source_depts <- colnames(W_ld)
  akm_meat <- 0

  for (k in seq_along(source_depts)) {
    w_k <- W_ld[, k]  # Column k of shares matrix
    g_k <- shifts_ld[k]  # Shift for source k
    akm_meat <- akm_meat + (sum(w_k * e_hat))^2 * g_k^2
  }

  ## Get the (X'X)^{-1} from the regression
  X_mat <- model.matrix(ld_ols)
  XtX_inv <- solve(crossprod(X_mat))

  ## AKM variance-covariance matrix
  V_akm <- XtX_inv %*% (akm_meat * diag(ncol(X_mat))) %*% XtX_inv

  ## Extract SE for network coefficient
  net_idx <- grep("network", colnames(X_mat))
  akm_se_network <- sqrt(V_akm[net_idx, net_idx])

  ## Compute p-value
  net_coef <- coef(ld_ols)[net_idx]
  akm_t <- net_coef / akm_se_network
  akm_p_network <- 2 * pnorm(-abs(akm_t))

  cat(sprintf("  Manual AKM SE (network): %.4f\n", akm_se_network))
  cat(sprintf("  Manual AKM t-stat:       %.3f\n", akm_t))
  cat(sprintf("  Manual AKM p-value:      %.4f\n", akm_p_network))

  akm_result <- list(
    method = "manual_AKM",
    se_network = akm_se_network,
    p_network = akm_p_network,
    t_network = as.numeric(akm_t)
  )
}

## Compare with clustered SEs from main specification
clustered_se_net <- get_se(dept_results$d1, "network_fuel_std")
clustered_coef_net <- get_coef(dept_results$d1, "network_fuel_std")
cat(sprintf("\n  Comparison:\n"))
cat(sprintf("    Clustered SE (dept):  %.4f\n", clustered_se_net))
cat(sprintf("    AKM shift-share SE:   %.4f\n", akm_se_network))
cat(sprintf("    Ratio AKM/Clustered:  %.2f\n", akm_se_network / clustered_se_net))

robustness_results$akm_shift_share <- list(
  akm_result = akm_result,
  akm_se_network = akm_se_network,
  akm_p_network = akm_p_network,
  clustered_se_network = clustered_se_net,
  ld_ols = ld_ols,
  ld_ols_robust = ld_ols_robust,
  n_dept = n_ld,
  description = "AKM (2019) shift-share robust SEs for network coefficient (long-difference)"
)


## ============================================================================
## 2. TWO-WAY CLUSTERING (NEW — WS1)
## ============================================================================

cat("\n=== 2. Two-Way Clustering (dept + election) ===\n")

## v3: Use pop-weighted to match D2 (primary specification)
## Département-level: cluster on dept_code + id_election
d_twoway_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                         network_fuel_std:post_carbon |
                         dept_code + id_election,
                       data = dept_panel,
                       cluster = ~dept_code + id_election,
                       weights = ~total_registered)

cat("  Département-level (two-way: dept + election):\n")
cat("    Own fuel x Post:     ", round(get_coef(d_twoway_dept, "own_fuel_std"), 4),
    " (", round(get_se(d_twoway_dept, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(d_twoway_dept, "network_fuel_std"), 4),
    " (", round(get_se(d_twoway_dept, "network_fuel_std"), 4), ")\n")

## Commune-level: cluster on dept_code + id_election
d_twoway_comm <- feols(rn_share ~ own_fuel_std:post_carbon +
                         network_fuel_std:post_carbon |
                         code_commune + id_election,
                       data = panel,
                       cluster = ~dept_code + id_election)

cat("\n  Commune-level (two-way: dept + election):\n")
cat("    Own fuel x Post:     ", round(get_coef(d_twoway_comm, "own_fuel_std"), 4),
    " (", round(get_se(d_twoway_comm, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(d_twoway_comm, "network_fuel_std"), 4),
    " (", round(get_se(d_twoway_comm, "network_fuel_std"), 4), ")\n")

## Compare SEs
se_oneway_dept <- get_se(dept_results$d1, "network_fuel_std")
se_twoway_dept <- get_se(d_twoway_dept, "network_fuel_std")
cat(sprintf("\n  SE comparison (network coef, dept-level):\n"))
cat(sprintf("    One-way (dept):        %.4f\n", se_oneway_dept))
cat(sprintf("    Two-way (dept+elec):   %.4f\n", se_twoway_dept))
cat(sprintf("    Ratio two-way/one-way: %.2f\n", se_twoway_dept / se_oneway_dept))

twoway_p_dept <- 2 * pt(
  abs(get_coef(d_twoway_dept, "network_fuel_std") /
        get_se(d_twoway_dept, "network_fuel_std")),
  df = min(n_distinct(dept_panel$dept_code),
           n_distinct(dept_panel$id_election)) - 1,
  lower.tail = FALSE
)

robustness_results$two_way_cluster <- list(
  dept_model = d_twoway_dept,
  commune_model = d_twoway_comm,
  coef_network_dept = get_coef(d_twoway_dept, "network_fuel_std"),
  se_network_dept = get_se(d_twoway_dept, "network_fuel_std"),
  coef_network_comm = get_coef(d_twoway_comm, "network_fuel_std"),
  se_network_comm = get_se(d_twoway_comm, "network_fuel_std"),
  p_network_dept = twoway_p_dept,
  description = "Two-way clustering on dept_code + id_election"
)


## ============================================================================
## 3. CONLEY SPATIAL HAC STANDARD ERRORS (NEW — WS1)
## ============================================================================

cat("\n=== 3. Conley Spatial HAC SEs (300 km bandwidth) ===\n")

## Load département centroids
geo_file <- file.path(DATA_DIR, "geo", "departements.geojson")

if (file.exists(geo_file)) {
  dept_geo <- sf::st_read(geo_file, quiet = TRUE)
  dept_centroids <- dept_geo %>%
    sf::st_centroid() %>%
    mutate(
      lon = sf::st_coordinates(.)[, 1],
      lat = sf::st_coordinates(.)[, 2]
    ) %>%
    sf::st_drop_geometry() %>%
    select(dept_code = code, lon, lat)

  ## Merge centroids into département panel
  dept_panel_geo <- dept_panel %>%
    left_join(dept_centroids, by = "dept_code") %>%
    filter(!is.na(lat) & !is.na(lon))

  cat("  Merged centroids for", n_distinct(dept_panel_geo$dept_code), "départements.\n")

  ## v3: Estimate with Conley spatial HAC SEs (300 km bandwidth), pop-weighted (D2)
  ## fixest supports vcov = conley(cutoff, lat = "lat", lon = "lon")
  d_conley <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            dept_code + id_election,
          data = dept_panel_geo,
          weights = ~total_registered,
          vcov = conley(cutoff = 300, lat = "lat", lon = "lon"))
  }, error = function(e) {
    cat("  Conley SEs via fixest failed:", e$message, "\n")
    cat("  Trying with distance = 300 (degrees approximation)...\n")
    tryCatch({
      ## 300 km ~ 2.7 degrees at French latitudes
      feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon |
              dept_code + id_election,
            data = dept_panel_geo,
            weights = ~total_registered,
            vcov = conley(cutoff = 2.7, lat = "lat", lon = "lon"))
    }, error = function(e2) {
      cat("  Conley SEs not available:", e2$message, "\n")
      NULL
    })
  })

  if (!is.null(d_conley)) {
    cat("  Conley spatial HAC results (300 km bandwidth):\n")
    cat("    Own fuel x Post:     ", round(get_coef(d_conley, "own_fuel_std"), 4),
        " (", round(get_se(d_conley, "own_fuel_std"), 4), ")\n")
    cat("    Network fuel x Post: ", round(get_coef(d_conley, "network_fuel_std"), 4),
        " (", round(get_se(d_conley, "network_fuel_std"), 4), ")\n")

    conley_se_net <- get_se(d_conley, "network_fuel_std")
    conley_t_net <- get_coef(d_conley, "network_fuel_std") / conley_se_net
    conley_p_net <- 2 * pnorm(-abs(conley_t_net))

    cat(sprintf("    Conley SE (network):  %.4f\n", conley_se_net))
    cat(sprintf("    Conley t-stat:        %.3f\n", conley_t_net))
    cat(sprintf("    Conley p-value:       %.4f\n", conley_p_net))

    cat(sprintf("\n  SE comparison (network coef):\n"))
    cat(sprintf("    Clustered (dept):    %.4f\n", se_oneway_dept))
    cat(sprintf("    Conley (300 km):     %.4f\n", conley_se_net))
    cat(sprintf("    Ratio Conley/Clust:  %.2f\n", conley_se_net / se_oneway_dept))

    robustness_results$conley_spatial <- list(
      model = d_conley,
      coef_network = get_coef(d_conley, "network_fuel_std"),
      se_network = conley_se_net,
      p_network = conley_p_net,
      bandwidth_km = 300,
      description = "Conley spatial HAC SEs with 300 km bandwidth"
    )
  } else {
    cat("  WARNING: Conley SEs could not be computed.\n")
    conley_p_net <- NA_real_
    robustness_results$conley_spatial <- NULL
  }
} else {
  cat("  WARNING: departements.geojson not found. Skipping Conley SEs.\n")
  conley_p_net <- NA_real_
  robustness_results$conley_spatial <- NULL
}


## ============================================================================
## 4. DISTANCE-RESTRICTED SCI (>200 km) — from v2
## ============================================================================

cat("\n=== 4. Distance-Restricted SCI (>200 km) ===\n")

if (file.exists(geo_file)) {
  if (!exists("dept_centroids")) {
    dept_geo <- sf::st_read(geo_file, quiet = TRUE)
    dept_centroids <- dept_geo %>%
      sf::st_centroid() %>%
      mutate(
        lon = sf::st_coordinates(.)[, 1],
        lat = sf::st_coordinates(.)[, 2]
      ) %>%
      sf::st_drop_geometry() %>%
      select(dept_code = code, lon, lat)
  }

  ## Haversine distance
  haversine_km <- function(lon1, lat1, lon2, lat2) {
    R <- 6371
    dlon <- (lon2 - lon1) * pi / 180
    dlat <- (lat2 - lat1) * pi / 180
    a <- sin(dlat / 2)^2 + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dlon / 2)^2
    2 * R * asin(sqrt(a))
  }

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
      sci_weight_dist = scaled_sci / sum(scaled_sci)
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

  ## Merge into dept panel and standardize
  dept_panel_dist <- dept_panel %>%
    left_join(network_distant, by = "dept_code") %>%
    filter(!is.na(network_fuel_distant)) %>%
    mutate(
      network_fuel_distant_std = (network_fuel_distant -
        mean(network_fuel_distant, na.rm = TRUE)) /
        sd(network_fuel_distant, na.rm = TRUE)
    )

  ## Estimate with distance-restricted network exposure (dept level)
  m_dist_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                         network_fuel_distant_std:post_carbon |
                         dept_code + id_election,
                       data = dept_panel_dist,
                       cluster = ~dept_code)

  cat("  Results (>200 km SCI only, dept-level):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_dist_dept, "own_fuel_std"), 4),
      " (", round(get_se(m_dist_dept, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_dist_dept, "network_fuel_distant"), 4),
      " (", round(get_se(m_dist_dept, "network_fuel_distant"), 4), ")\n")

  ## Also at commune level
  panel_dist <- panel %>%
    left_join(network_distant, by = "dept_code") %>%
    filter(!is.na(network_fuel_distant)) %>%
    mutate(
      network_fuel_distant_std = (network_fuel_distant -
        mean(network_fuel_distant, na.rm = TRUE)) /
        sd(network_fuel_distant, na.rm = TRUE)
    )

  m_dist_comm <- feols(rn_share ~ own_fuel_std:post_carbon +
                         network_fuel_distant_std:post_carbon |
                         code_commune + id_election,
                       data = panel_dist,
                       cluster = ~dept_code)

  cat("  Results (>200 km SCI only, commune-level):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_dist_comm, "own_fuel_std"), 4),
      " (", round(get_se(m_dist_comm, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_dist_comm, "network_fuel_distant"), 4),
      " (", round(get_se(m_dist_comm, "network_fuel_distant"), 4), ")\n")

  robustness_results$distance_restricted <- list(
    dept_model = m_dist_dept,
    commune_model = m_dist_comm,
    coef_own_dept = get_coef(m_dist_dept, "own_fuel_std"),
    se_own_dept = get_se(m_dist_dept, "own_fuel_std"),
    coef_network_dept = get_coef(m_dist_dept, "network_fuel_distant"),
    se_network_dept = get_se(m_dist_dept, "network_fuel_distant"),
    coef_network_comm = get_coef(m_dist_comm, "network_fuel_distant"),
    se_network_comm = get_se(m_dist_comm, "network_fuel_distant"),
    n_obs_dept = nobs(m_dist_dept),
    n_obs_comm = nobs(m_dist_comm),
    n_distant_pairs = nrow(sci_distant),
    description = "Network exposure computed using only SCI connections >200 km apart"
  )
} else {
  cat("  WARNING: departements.geojson not found. Skipping distance restriction.\n")
  robustness_results$distance_restricted <- NULL
}


## ============================================================================
## 5. PLACEBO OUTCOMES: Turnout, Green, Center-right — from v2
## ============================================================================

cat("\n=== 5. Placebo Outcomes ===\n")

## 5a. Turnout (département level — primary)
m_placebo_turnout_dept <- feols(turnout ~ own_fuel_std:post_carbon +
                                  network_fuel_std:post_carbon |
                                  dept_code + id_election,
                                data = dept_panel,
                                cluster = ~dept_code)

t_net_turnout_dept <- get_coef(m_placebo_turnout_dept, "network_fuel_std") /
  get_se(m_placebo_turnout_dept, "network_fuel_std")

cat("  5a. Turnout as outcome (dept-level):\n")
cat("    Own fuel x Post:     ", round(get_coef(m_placebo_turnout_dept, "own_fuel_std"), 4),
    " (", round(get_se(m_placebo_turnout_dept, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(m_placebo_turnout_dept, "network_fuel_std"), 4),
    " (", round(get_se(m_placebo_turnout_dept, "network_fuel_std"), 4), ")\n")
cat("    t-stat (network):    ", round(t_net_turnout_dept, 2), "\n")
cat("    Placebo passed?      ",
    ifelse(abs(t_net_turnout_dept) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

robustness_results$placebo_turnout <- list(
  model = m_placebo_turnout_dept,
  coef_network = get_coef(m_placebo_turnout_dept, "network_fuel_std"),
  se_network = get_se(m_placebo_turnout_dept, "network_fuel_std"),
  t_stat_network = as.numeric(t_net_turnout_dept),
  n_obs = nobs(m_placebo_turnout_dept),
  description = "Placebo: turnout as outcome (département level)"
)

## 5b. Green share (département level)
if ("green_share" %in% names(dept_panel)) {
  m_placebo_green <- feols(green_share ~ own_fuel_std:post_carbon +
                             network_fuel_std:post_carbon |
                             dept_code + id_election,
                           data = dept_panel,
                           cluster = ~dept_code)

  t_net_green <- get_coef(m_placebo_green, "network_fuel_std") /
    get_se(m_placebo_green, "network_fuel_std")

  cat("\n  5b. Green share as outcome (dept-level):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_placebo_green, "own_fuel_std"), 4),
      " (", round(get_se(m_placebo_green, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_placebo_green, "network_fuel_std"), 4),
      " (", round(get_se(m_placebo_green, "network_fuel_std"), 4), ")\n")
  cat("    t-stat (network):    ", round(t_net_green, 2), "\n")
  cat("    Placebo passed?      ",
      ifelse(abs(t_net_green) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

  robustness_results$placebo_green <- list(
    model = m_placebo_green,
    coef_network = get_coef(m_placebo_green, "network_fuel_std"),
    se_network = get_se(m_placebo_green, "network_fuel_std"),
    t_stat_network = as.numeric(t_net_green),
    n_obs = nobs(m_placebo_green),
    description = "Placebo: green (EELV) vote share as outcome (département level)"
  )
} else {
  cat("  WARNING: green_share not found. Skipping.\n")
  robustness_results$placebo_green <- NULL
}

## 5c. Center-right share (département level)
if ("right_share" %in% names(dept_panel)) {
  m_placebo_right <- feols(right_share ~ own_fuel_std:post_carbon +
                             network_fuel_std:post_carbon |
                             dept_code + id_election,
                           data = dept_panel,
                           cluster = ~dept_code)

  t_net_right <- get_coef(m_placebo_right, "network_fuel_std") /
    get_se(m_placebo_right, "network_fuel_std")

  cat("\n  5c. Center-right share as outcome (dept-level):\n")
  cat("    Own fuel x Post:     ", round(get_coef(m_placebo_right, "own_fuel_std"), 4),
      " (", round(get_se(m_placebo_right, "own_fuel_std"), 4), ")\n")
  cat("    Network fuel x Post: ", round(get_coef(m_placebo_right, "network_fuel_std"), 4),
      " (", round(get_se(m_placebo_right, "network_fuel_std"), 4), ")\n")
  cat("    t-stat (network):    ", round(t_net_right, 2), "\n")
  cat("    Placebo passed?      ",
      ifelse(abs(t_net_right) < 1.96, "YES (insignificant)", "NO (significant)"), "\n")

  robustness_results$placebo_right <- list(
    model = m_placebo_right,
    coef_network = get_coef(m_placebo_right, "network_fuel_std"),
    se_network = get_se(m_placebo_right, "network_fuel_std"),
    t_stat_network = as.numeric(t_net_right),
    n_obs = nobs(m_placebo_right),
    description = "Placebo: center-right (LR/UMP) vote share as outcome (département level)"
  )
} else {
  cat("  WARNING: right_share not found. Skipping.\n")
  robustness_results$placebo_right <- NULL
}


## ============================================================================
## 6. LEAVE-ONE-OUT DEPARTEMENTS — from v2
## ============================================================================

cat("\n=== 6. Leave-One-Out Départements ===\n")

all_depts <- sort(unique(dept_panel$dept_code))
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
  dept_loo <- dept_panel %>% filter(dept_code != d)

  m_loo <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            dept_code + id_election,
          data = dept_loo,
          cluster = ~dept_code,
          weights = ~total_registered)
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

cat("\n  Leave-one-out distribution (network coefficient):\n")
cat("    Mean:   ", round(mean(loo_results$coef_network, na.rm = TRUE), 4), "\n")
cat("    Median: ", round(median(loo_results$coef_network, na.rm = TRUE), 4), "\n")
cat("    Min:    ", round(min(loo_results$coef_network, na.rm = TRUE), 4),
    " (dropped:", loo_results$dept_dropped[which.min(loo_results$coef_network)], ")\n")
cat("    Max:    ", round(max(loo_results$coef_network, na.rm = TRUE), 4),
    " (dropped:", loo_results$dept_dropped[which.max(loo_results$coef_network)], ")\n")
cat("    SD:     ", round(sd(loo_results$coef_network, na.rm = TRUE), 4), "\n")

main_coef_net_dept <- get_coef(dept_results$d2, "network_fuel_std")
loo_signif <- sum(abs(loo_results$coef_network / loo_results$se_network) > 1.96,
                  na.rm = TRUE)
cat("    Significant in ", loo_signif, "/", nrow(loo_results),
    " iterations (", round(100 * loo_signif / nrow(loo_results), 1), "%)\n")

robustness_results$leave_one_out <- list(
  loo_table = loo_results,
  mean_coef_network = mean(loo_results$coef_network, na.rm = TRUE),
  sd_coef_network = sd(loo_results$coef_network, na.rm = TRUE),
  pct_significant = 100 * loo_signif / nrow(loo_results),
  main_coef_network = main_coef_net_dept,
  description = "Leave-one-out: iteratively drop each département and re-estimate (dept level)"
)


## ============================================================================
## 7. ALTERNATIVE EXPOSURE WINDOW: Post-Gilets Jaunes (2019+) — from v2
## ============================================================================

cat("\n=== 7. Post-GJ Window (2019+) ===\n")

m_gj_dept <- feols(rn_share ~ own_fuel_std:post_gj +
                      network_fuel_std:post_gj |
                      dept_code + id_election,
                    data = dept_panel,
                    cluster = ~dept_code)

m_both_windows_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                               network_fuel_std:post_carbon +
                               own_fuel_std:post_gj +
                               network_fuel_std:post_gj |
                               dept_code + id_election,
                             data = dept_panel,
                             cluster = ~dept_code)

cat("  Post-GJ only specification (dept-level):\n")
cat("    Own fuel x Post-GJ:     ", round(get_coef(m_gj_dept, "own_fuel_std"), 4),
    " (", round(get_se(m_gj_dept, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post-GJ: ", round(get_coef(m_gj_dept, "network_fuel_std"), 4),
    " (", round(get_se(m_gj_dept, "network_fuel_std"), 4), ")\n")

cat("\n  Both windows (post-carbon + incremental post-GJ):\n")
etable(m_gj_dept, m_both_windows_dept,
       headers = c("Post-GJ Only", "Both Windows"),
       se.below = TRUE)

robustness_results$post_gj <- list(
  model_gj = m_gj_dept,
  model_both = m_both_windows_dept,
  coef_own_gj = get_coef(m_gj_dept, "own_fuel_std"),
  se_own_gj = get_se(m_gj_dept, "own_fuel_std"),
  coef_network_gj = get_coef(m_gj_dept, "network_fuel_std"),
  se_network_gj = get_se(m_gj_dept, "network_fuel_std"),
  n_obs = nobs(m_gj_dept),
  description = "Post-GJ (2019+) window instead of post-carbon (2017+), département level"
)


## ============================================================================
## 8. BARTIK / SHIFT-SHARE DIAGNOSTICS (GPSS 2020) — from v2
## ============================================================================

cat("\n=== 8. Bartik Shift-Share Diagnostics (GPSS 2020) ===\n")

## The network exposure is a shift-share: exposure_d = SUM_j w_dj x fuel_j
## Following GPSS (2020):
## (a) Compute Rotemberg weights
## (b) Test share exogeneity

## Step 1: Compute Rotemberg weights
shifts_vec_full <- setNames(fuel_vuln$co2_commute, fuel_vuln$dept_code)

## Use the SCI weight matrix already constructed
n_sources <- ncol(W_mat)
source_depts <- colnames(W_mat)

rotemberg_weights <- numeric(n_sources)
names(rotemberg_weights) <- source_depts

for (j_idx in seq_along(source_depts)) {
  j <- source_depts[j_idx]
  if (j %in% names(shifts_vec_full)) {
    s_j <- W_mat[, j_idx]
    g_j <- shifts_vec_full[j]
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
  cat(sprintf("    %2d. Dept %s: alpha = %.4f (fuel = %.2f tCO2e)\n",
              k, dept_k, top_weights[k],
              ifelse(dept_k %in% fuel_vuln$dept_code,
                     fuel_vuln$co2_commute[fuel_vuln$dept_code == dept_k], NA)))
}

## Step 2: Share exogeneity test
pre_data <- dept_panel %>%
  filter(year == min(year)) %>%
  select(dept_code, rn_share_baseline = rn_share)

top5_sources <- names(sort(rotemberg_weights, decreasing = TRUE)[1:5])

share_test_data <- pre_data
for (src in top5_sources) {
  src_col <- paste0("share_", src)
  src_idx <- which(source_depts == src)
  if (length(src_idx) > 0) {
    share_vals <- W_mat[, src_idx]
    share_df <- tibble(
      dept_code = rownames(W_mat),
      !!src_col := share_vals
    )
    share_test_data <- share_test_data %>%
      left_join(share_df, by = "dept_code")
  }
}

## F-test: do top shares jointly predict baseline outcome?
share_cols <- names(share_test_data)[grepl("^share_", names(share_test_data))]
f_pval <- NA_real_

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
    cat("  WARNING: F-test could not be computed.\n")
  }
} else {
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
## 9. RANDOMIZATION INFERENCE (5000 permutations) — from v2
## ============================================================================

cat("\n=== 9. Randomization Inference (Standard, 5000 perms) ===\n")

set.seed(20260226)
N_PERM <- 5000

## v3: Use D2 (pop-weighted) as baseline for RI
actual_t_own <- get_coef(dept_results$d2, "own_fuel_std") /
  get_se(dept_results$d2, "own_fuel_std")
actual_t_net <- get_coef(dept_results$d2, "network_fuel_std") /
  get_se(dept_results$d2, "network_fuel_std")

cat("  Actual t-statistics (dept-level D2, pop-weighted):\n")
cat("    Own:     ", round(actual_t_own, 3), "\n")
cat("    Network: ", round(actual_t_net, 3), "\n")

## Pre-compute: dept codes and fuel vector aligned with W_mat
fuel_vec <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered))
n_d <- nrow(fuel_vec)

stopifnot(all(fuel_vec$dept_code == dept_codes_ordered))

cat("  Running", N_PERM, "permutations (département-level)...\n")

perm_t_own <- numeric(N_PERM)
perm_t_net <- numeric(N_PERM)

pb <- txtProgressBar(min = 0, max = N_PERM, style = 3)

for (p in seq_len(N_PERM)) {
  perm_idx <- sample(n_d)
  fuel_perm <- fuel_vec$co2_commute[perm_idx]

  ## Recompute network exposure with permuted fuel
  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)

  ## Standardize
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  ## Map back to département panel
  perm_map <- tibble(
    dept_code = dept_codes_ordered,
    own_fuel_std_perm = own_std_perm,
    network_fuel_std_perm = net_std_perm
  )

  dept_perm <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, post_carbon, total_registered) %>%
    left_join(perm_map, by = "dept_code") %>%
    filter(!is.na(own_fuel_std_perm) & !is.na(network_fuel_std_perm))

  m_perm <- tryCatch({
    feols(rn_share ~ own_fuel_std_perm:post_carbon +
            network_fuel_std_perm:post_carbon |
            dept_code + id_election,
          data = dept_perm,
          cluster = ~dept_code,
          weights = ~total_registered)
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

ri_p_own <- mean(abs(perm_t_own) >= abs(actual_t_own), na.rm = TRUE)
ri_p_net <- mean(abs(perm_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat("\n  Randomization inference results (", N_PERM, " permutations):\n")
cat("    Own exposure:     RI p-value = ", round(ri_p_own, 4), "\n")
cat("    Network exposure: RI p-value = ", round(ri_p_net, 4), "\n")

robustness_results$randomization_inference <- list(
  n_permutations = N_PERM,
  actual_t_own = as.numeric(actual_t_own),
  actual_t_net = as.numeric(actual_t_net),
  ri_p_own = ri_p_own,
  ri_p_net = ri_p_net,
  perm_t_own = perm_t_own,
  perm_t_net = perm_t_net,
  description = "Permute dept fuel vulnerability, recompute network exposure (5000 perms, dept-level)"
)


## ============================================================================
## 10. BLOCK-PERMUTATION RI (10000 within-region perms) — from v2
## ============================================================================

cat("\n=== 10. Block-Permutation RI (within regions, 10000 perms) ===\n")

## 13 metropolitan regions
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

region_coverage <- fuel_vec %>%
  group_by(region) %>%
  summarize(n = n(), .groups = "drop")
cat("  Region blocks:\n")
for (i in seq_len(nrow(region_coverage))) {
  cat(sprintf("    %s: %d départements\n",
              region_coverage$region[i], region_coverage$n[i]))
}
cat("  Départements without region:", sum(is.na(fuel_vec$region)), "\n")

set.seed(20260227)
N_BLOCK_PERM <- 10000

cat("  Running", N_BLOCK_PERM, "block permutations (within-region)...\n")

block_perm_t_own <- numeric(N_BLOCK_PERM)
block_perm_t_net <- numeric(N_BLOCK_PERM)

fuel_regions <- fuel_vec$region
unique_regions <- unique(fuel_regions[!is.na(fuel_regions)])
region_indices <- lapply(unique_regions, function(r) which(fuel_regions == r))
names(region_indices) <- unique_regions

pb2 <- txtProgressBar(min = 0, max = N_BLOCK_PERM, style = 3)

for (p in seq_len(N_BLOCK_PERM)) {
  fuel_perm <- fuel_vec$co2_commute

  for (r in unique_regions) {
    idx <- region_indices[[r]]
    if (length(idx) > 1) {
      fuel_perm[idx] <- fuel_perm[sample(idx)]
    }
  }

  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)

  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  perm_map <- tibble(
    dept_code = dept_codes_ordered,
    own_fuel_std_perm = own_std_perm,
    network_fuel_std_perm = net_std_perm
  )

  dept_perm <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, post_carbon, total_registered) %>%
    left_join(perm_map, by = "dept_code") %>%
    filter(!is.na(own_fuel_std_perm) & !is.na(network_fuel_std_perm))

  m_perm <- tryCatch({
    feols(rn_share ~ own_fuel_std_perm:post_carbon +
            network_fuel_std_perm:post_carbon |
            dept_code + id_election,
          data = dept_perm,
          cluster = ~dept_code,
          weights = ~total_registered)
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
  description = "Block-permutation RI: permute fuel within 13 metropolitan regions (10000 perms)"
)


## ============================================================================
## 11. WILD CLUSTER BOOTSTRAP (9999 reps) — from v2
## ============================================================================

cat("\n=== 11. Wild Cluster Bootstrap (WCB, 9999 reps) ===\n")

set.seed(20260226)
N_BOOT <- 9999

dept_boot <- dept_panel %>%
  filter(!is.na(own_fuel_std) & !is.na(network_fuel_std) & !is.na(rn_share))

clusters <- sort(unique(dept_boot$dept_code))
G <- length(clusters)
cat("  Number of clusters (départements):", G, "\n")

## v3: Full model (pop-weighted, matching D2)
m_full_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                       network_fuel_std:post_carbon |
                       dept_code + id_election,
                     data = dept_boot,
                     cluster = ~dept_code,
                     weights = ~total_registered)

actual_coefs <- coef(m_full_dept)
actual_ses <- se(m_full_dept)
net_nm <- names(actual_coefs)[grepl("network_fuel_std", names(actual_coefs))]
own_nm <- names(actual_coefs)[grepl("own_fuel_std", names(actual_coefs))]

actual_t_own_wcb <- actual_coefs[own_nm[1]] / actual_ses[own_nm[1]]
actual_t_net_wcb <- actual_coefs[net_nm[1]] / actual_ses[net_nm[1]]

## Restricted model (pop-weighted)
m_restricted <- feols(rn_share ~ 1 | dept_code + id_election,
                      data = dept_boot,
                      weights = ~total_registered)
resid_restricted <- residuals(m_restricted)
fitted_restricted <- fitted(m_restricted)

cat("  Running", N_BOOT, "WCB iterations (Rademacher weights)...\n")
boot_t_own <- numeric(N_BOOT)
boot_t_net <- numeric(N_BOOT)

for (b in seq_len(N_BOOT)) {
  rademacher <- sample(c(-1, 1), G, replace = TRUE)
  w_vec <- rademacher[match(dept_boot$dept_code, clusters)]

  dept_boot$y_star <- fitted_restricted + w_vec * resid_restricted

  m_star <- tryCatch({
    feols(y_star ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon |
            dept_code + id_election,
          data = dept_boot,
          cluster = ~dept_code,
          weights = ~total_registered)
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

dept_boot$y_star <- NULL


## ============================================================================
## 12. MIGRATION-PROXY RE-ESTIMATION (NEW — WS2)
## ============================================================================

cat("\n=== 12. Migration-Proxy Re-estimation (WS2) ===\n")

## v3 FIX: network_fuel_migration is already in dept_panel from 02_clean_data.R
## No need to join again (joining causes name collision)
dept_panel_mig <- dept_panel %>%
  filter(!is.na(network_fuel_migration)) %>%
  mutate(
    network_fuel_migration_std = (network_fuel_migration -
      mean(network_fuel_migration, na.rm = TRUE)) /
      sd(network_fuel_migration, na.rm = TRUE)
  )

cat("  Migration network exposure available for",
    n_distinct(dept_panel_mig$dept_code), "départements.\n")

## Correlation between SCI and migration network exposure
cor_sci_mig <- dept_panel_mig %>%
  distinct(dept_code, .keep_all = TRUE) %>%
  summarize(
    pearson = cor(network_fuel_std, network_fuel_migration_std, use = "complete.obs"),
    spearman = cor(network_fuel_std, network_fuel_migration_std,
                   method = "spearman", use = "complete.obs")
  )
cat("  SCI vs. Migration network exposure:\n")
cat("    Pearson r:  ", round(cor_sci_mig$pearson, 3), "\n")
cat("    Spearman rho:", round(cor_sci_mig$spearman, 3), "\n")

## v3: Département-level: main spec with migration weights (pop-weighted, D2)
m_mig_dept <- feols(rn_share ~ own_fuel_std:post_carbon +
                      network_fuel_migration_std:post_carbon |
                      dept_code + id_election,
                    data = dept_panel_mig,
                    cluster = ~dept_code,
                    weights = ~total_registered)

cat("\n  Migration-proxy results (dept-level):\n")
cat("    Own fuel x Post:     ", round(get_coef(m_mig_dept, "own_fuel_std"), 4),
    " (", round(get_se(m_mig_dept, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(m_mig_dept, "network_fuel_migration"), 4),
    " (", round(get_se(m_mig_dept, "network_fuel_migration"), 4), ")\n")

## v3 FIX: network_fuel_migration already in panel from 02_clean_data.R
panel_mig <- panel %>%
  filter(!is.na(network_fuel_migration)) %>%
  mutate(
    network_fuel_migration_std = (network_fuel_migration -
      mean(network_fuel_migration, na.rm = TRUE)) /
      sd(network_fuel_migration, na.rm = TRUE)
  )

m_mig_comm <- feols(rn_share ~ own_fuel_std:post_carbon +
                      network_fuel_migration_std:post_carbon |
                      code_commune + id_election,
                    data = panel_mig,
                    cluster = ~dept_code)

cat("\n  Migration-proxy results (commune-level):\n")
cat("    Own fuel x Post:     ", round(get_coef(m_mig_comm, "own_fuel_std"), 4),
    " (", round(get_se(m_mig_comm, "own_fuel_std"), 4), ")\n")
cat("    Network fuel x Post: ", round(get_coef(m_mig_comm, "network_fuel_migration"), 4),
    " (", round(get_se(m_mig_comm, "network_fuel_migration"), 4), ")\n")

## Compare with SCI-based coefficient
cat("\n  Comparison (dept-level):\n")
cat(sprintf("    SCI-based network coef:       %.4f (%.4f)\n",
            get_coef(dept_results$d1, "network_fuel_std"),
            get_se(dept_results$d1, "network_fuel_std")))
cat(sprintf("    Migration-based network coef: %.4f (%.4f)\n",
            get_coef(m_mig_dept, "network_fuel_migration"),
            get_se(m_mig_dept, "network_fuel_migration")))

robustness_results$migration_proxy <- list(
  dept_model = m_mig_dept,
  commune_model = m_mig_comm,
  coef_network_dept = get_coef(m_mig_dept, "network_fuel_migration"),
  se_network_dept = get_se(m_mig_dept, "network_fuel_migration"),
  coef_network_comm = get_coef(m_mig_comm, "network_fuel_migration"),
  se_network_comm = get_se(m_mig_comm, "network_fuel_migration"),
  n_obs_dept = nobs(m_mig_dept),
  n_obs_comm = nobs(m_mig_comm),
  cor_sci_migration = cor_sci_mig,
  description = "Re-estimate main spec using gravity-based migration proxy instead of SCI weights"
)


## ============================================================================
## 13. TIME-VARYING CONTROLS BATTERY (NEW — WS3)
## ============================================================================

cat("\n=== 13. Time-Varying Controls Battery (WS3) ===\n")

dept_controls <- readRDS(file.path(DATA_DIR, "dept_controls.rds"))

## Ensure controls are in the département panel
dept_panel_ctrl <- dept_panel %>%
  left_join(dept_controls %>% select(-any_of(intersect(names(dept_panel), names(dept_controls))[-1])),
            by = "dept_code") %>%
  filter(!is.na(unemp_rate_2013) & !is.na(share_bac_plus) &
           !is.na(share_immigrant) & !is.na(share_industry))

## Build control interactions (if not already present)
dept_panel_ctrl <- dept_panel_ctrl %>%
  mutate(
    unemp_x_post = unemp_rate_2013 * post_carbon,
    educ_x_post = share_bac_plus * post_carbon,
    immig_x_post = share_immigrant * post_carbon,
    industry_x_post = share_industry * post_carbon,
    year_num = year - 2002  # for linear trends
  )

n_ctrl_depts <- n_distinct(dept_panel_ctrl$dept_code)
cat("  Controls available for", n_ctrl_depts, "départements.\n")

## v3: All controls battery uses pop-weighted spec (matching D2, the primary)
## (a) Baseline: own + network x post
ctrl_a <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon |
                  dept_code + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (b) + unemployment x post
ctrl_b <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon +
                  unemp_x_post |
                  dept_code + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (c) + education x post
ctrl_c <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon +
                  educ_x_post |
                  dept_code + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (d) + immigration x post
ctrl_d <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon +
                  immig_x_post |
                  dept_code + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (e) + industry x post
ctrl_e <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon +
                  industry_x_post |
                  dept_code + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (f) + département-specific linear trends
ctrl_f <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon |
                  dept_code[year_num] + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## (g) Kitchen-sink: all controls + trends
ctrl_g <- feols(rn_share ~ own_fuel_std:post_carbon +
                  network_fuel_std:post_carbon +
                  unemp_x_post + educ_x_post +
                  immig_x_post + industry_x_post |
                  dept_code[year_num] + id_election,
                data = dept_panel_ctrl,
                cluster = ~dept_code,
                weights = ~total_registered)

## Collect results
ctrl_models <- list(
  a_baseline = ctrl_a,
  b_unemployment = ctrl_b,
  c_education = ctrl_c,
  d_immigration = ctrl_d,
  e_industry = ctrl_e,
  f_trends = ctrl_f,
  g_kitchen_sink = ctrl_g
)

ctrl_labels <- c(
  "(a) Baseline",
  "(b) + Unemployment x Post",
  "(c) + Education x Post",
  "(d) + Immigration x Post",
  "(e) + Industry x Post",
  "(f) + Dept-specific trends",
  "(g) Kitchen-sink + trends"
)

cat("\n  Network coefficient stability across specifications:\n")
cat(sprintf("  %-35s  %8s  %8s  %6s\n", "Specification", "Coef", "SE", "N"))
cat("  ", strrep("-", 65), "\n")

ctrl_summary <- tibble(
  specification = character(),
  coef_network = numeric(),
  se_network = numeric(),
  n_obs = integer()
)

for (i in seq_along(ctrl_models)) {
  m <- ctrl_models[[i]]
  cn <- get_coef(m, "network_fuel_std")
  sn <- get_se(m, "network_fuel_std")
  nn <- as.integer(nobs(m))
  cat(sprintf("  %-35s  %8.4f  %8.4f  %6d\n", ctrl_labels[i], cn, sn, nn))
  ctrl_summary <- bind_rows(ctrl_summary, tibble(
    specification = ctrl_labels[i],
    coef_network = cn,
    se_network = sn,
    n_obs = nn
  ))
}

cat(sprintf("\n  Coefficient range: [%.4f, %.4f]\n",
            min(ctrl_summary$coef_network, na.rm = TRUE),
            max(ctrl_summary$coef_network, na.rm = TRUE)))
cat(sprintf("  Coefficient CV:    %.1f%%\n",
            100 * sd(ctrl_summary$coef_network, na.rm = TRUE) /
              abs(mean(ctrl_summary$coef_network, na.rm = TRUE))))

robustness_results$time_varying_controls <- list(
  models = ctrl_models,
  summary = ctrl_summary,
  n_depts = n_ctrl_depts,
  description = "Progressive addition of time-varying controls (département level)"
)


## ============================================================================
## 14. DISTANCE-BIN DECOMPOSITION (NEW — WS4)
## ============================================================================

cat("\n=== 14. Distance-Bin Decomposition (WS4) ===\n")

distance_bin_data <- readRDS(file.path(DATA_DIR, "distance_bin_data.rds"))

bin_names <- c("0-50km", "50-100km", "100-200km", "200-400km", "400+km")

bin_results <- tibble(
  bin = character(),
  coef_network = numeric(),
  se_network = numeric(),
  n_depts = integer(),
  n_obs = integer()
)

for (bn in bin_names) {
  ## Extract bin-specific exposure
  bin_exp <- distance_bin_data %>%
    filter(bin == bn) %>%
    select(dept_code, network_fuel_bin = network_fuel)

  ## Merge into département panel
  dept_panel_bin <- dept_panel %>%
    left_join(bin_exp, by = "dept_code") %>%
    filter(!is.na(network_fuel_bin)) %>%
    mutate(
      network_fuel_bin_std = (network_fuel_bin -
        mean(network_fuel_bin, na.rm = TRUE)) /
        sd(network_fuel_bin, na.rm = TRUE)
    )

  n_bin_depts <- n_distinct(dept_panel_bin$dept_code)

  if (n_bin_depts < 10) {
    cat(sprintf("  Bin %s: only %d départements — skipping\n", bn, n_bin_depts))
    bin_results <- bind_rows(bin_results, tibble(
      bin = bn,
      coef_network = NA_real_,
      se_network = NA_real_,
      n_depts = n_bin_depts,
      n_obs = NA_integer_
    ))
    next
  }

  m_bin <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_carbon +
            network_fuel_bin_std:post_carbon |
            dept_code + id_election,
          data = dept_panel_bin,
          cluster = ~dept_code,
          weights = ~total_registered)
  }, error = function(e) {
    cat(sprintf("  Bin %s ERROR: %s\n", bn, e$message))
    NULL
  })

  if (!is.null(m_bin)) {
    cn <- get_coef(m_bin, "network_fuel_bin")
    sn <- get_se(m_bin, "network_fuel_bin")
    nn <- as.integer(nobs(m_bin))

    cat(sprintf("  Bin %-10s: coef = %7.4f (%6.4f), N_dept = %d, N_obs = %d\n",
                bn, cn, sn, n_bin_depts, nn))

    bin_results <- bind_rows(bin_results, tibble(
      bin = bn,
      coef_network = cn,
      se_network = sn,
      n_depts = n_bin_depts,
      n_obs = nn
    ))
  } else {
    bin_results <- bind_rows(bin_results, tibble(
      bin = bn,
      coef_network = NA_real_,
      se_network = NA_real_,
      n_depts = n_bin_depts,
      n_obs = NA_integer_
    ))
  }
}

cat("\n  Distance-bin decomposition summary:\n")
print(bin_results, n = 10)

robustness_results$distance_bins <- list(
  bin_results = bin_results,
  description = "Network effect by distance bin (0-50, 50-100, 100-200, 200-400, 400+ km)"
)


## ============================================================================
## 15. PLACEBO TIMING TESTS (NEW — WS5)
## ============================================================================

cat("\n=== 15. Placebo Timing Tests ===\n")

## Test fake treatment dates: 2002, 2004, 2007, 2009 (v4: expanded from 2)
## CRITICAL: Restrict to pre-2014 elections only!
## Otherwise the "post" period includes real post-treatment elections.

fake_dates <- c(2004, 2007, 2009)
placebo_timing <- tibble(
  fake_date = integer(),
  coef_own = numeric(),
  se_own = numeric(),
  coef_network = numeric(),
  se_network = numeric(),
  n_obs = integer()
)

## v3 FIX: Restrict to pre-2014 elections for placebo timing test
dept_panel_pre <- dept_panel %>% filter(year < 2014)
cat("  Pre-2014 sample:", nrow(dept_panel_pre), "obs,",
    n_distinct(dept_panel_pre$year), "elections\n")

for (fd in fake_dates) {
  dept_panel_fake <- dept_panel_pre %>%
    mutate(post_fake = as.integer(year >= fd))

  m_fake <- tryCatch({
    feols(rn_share ~ own_fuel_std:post_fake +
            network_fuel_std:post_fake |
            dept_code + id_election,
          data = dept_panel_fake,
          cluster = ~dept_code,
          weights = ~total_registered)
  }, error = function(e) {
    cat(sprintf("  Fake date %d ERROR: %s\n", fd, e$message))
    NULL
  })

  if (!is.null(m_fake)) {
    co <- get_coef(m_fake, "own_fuel_std")
    so <- get_se(m_fake, "own_fuel_std")
    cn <- get_coef(m_fake, "network_fuel_std")
    sn <- get_se(m_fake, "network_fuel_std")
    nn <- as.integer(nobs(m_fake))

    t_net <- cn / sn
    cat(sprintf("  Fake date %d: Own = %.4f (%.4f), Network = %.4f (%.4f), t = %.2f\n",
                fd, co, so, cn, sn, t_net))
    cat(sprintf("    Placebo passed? %s\n",
                ifelse(abs(t_net) < 1.96, "YES (insignificant)", "NO (significant)")))

    placebo_timing <- bind_rows(placebo_timing, tibble(
      fake_date = fd,
      coef_own = co,
      se_own = so,
      coef_network = cn,
      se_network = sn,
      n_obs = nn
    ))
  }
}

## Compare with actual treatment date (D2 primary)
cat(sprintf("  Actual date 2014: Network = %.4f (%.4f), t = %.2f\n",
            get_coef(dept_results$d2, "network_fuel_std"),
            get_se(dept_results$d2, "network_fuel_std"),
            get_coef(dept_results$d2, "network_fuel_std") /
              get_se(dept_results$d2, "network_fuel_std")))

robustness_results$placebo_timing <- list(
  results = placebo_timing,
  fake_dates = fake_dates,
  description = "Placebo timing tests: fake treatment at 2004, 2007, and 2009 (should be null)"
)


## ============================================================================
## 16. ELECTION-TYPE SEPARATE EVENT STUDIES (NEW — WS5)
## ============================================================================

cat("\n=== 16. Election-Type Separate Event Studies ===\n")

## Presidential elections only
dept_pres <- dept_panel %>%
  filter(election_type == "presidential") %>%
  mutate(
    pres_num = case_when(
      year == 2002 ~ 1L,
      year == 2007 ~ 2L,
      year == 2012 ~ 3L,
      year == 2017 ~ 4L,
      year == 2022 ~ 5L,
      TRUE ~ NA_integer_
    )
  ) %>%
  filter(!is.na(pres_num))

cat("  Presidential elections:", n_distinct(dept_pres$year), "elections,",
    nrow(dept_pres), "obs\n")

es_pres <- tryCatch({
  feols(rn_share ~ i(pres_num, network_fuel_std, ref = 3) +
          i(pres_num, own_fuel_std, ref = 3) |
          dept_code + id_election,
        data = dept_pres,
        cluster = ~dept_code)
}, error = function(e) {
  cat("  Presidential ES error:", e$message, "\n")
  NULL
})

if (!is.null(es_pres)) {
  cat("  Presidential event study (ref = 2012):\n")
  pres_ct <- coeftable(es_pres)
  net_idx <- grepl("network_fuel_std", rownames(pres_ct))
  if (any(net_idx)) {
    pres_es_data <- tibble(
      election_num = as.integer(gsub(".*::(\\d+):.*", "\\1", rownames(pres_ct)[net_idx])),
      estimate = pres_ct[net_idx, "Estimate"],
      se = pres_ct[net_idx, "Std. Error"]
    ) %>%
      bind_rows(tibble(election_num = 3L, estimate = 0, se = 0)) %>%
      arrange(election_num) %>%
      mutate(
        year = c(2002, 2007, 2012, 2017, 2022)[election_num],
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se
      )
    cat("    Network coefficients:\n")
    print(pres_es_data)
  }
}

## European elections only
dept_euro <- dept_panel %>%
  filter(election_type == "european") %>%
  mutate(
    euro_num = case_when(
      year == 2004 ~ 1L,
      year == 2009 ~ 2L,
      year == 2014 ~ 3L,
      year == 2019 ~ 4L,
      year == 2024 ~ 5L,
      TRUE ~ NA_integer_
    )
  ) %>%
  filter(!is.na(euro_num))

cat("\n  European elections:", n_distinct(dept_euro$year), "elections,",
    nrow(dept_euro), "obs\n")

es_euro <- tryCatch({
  feols(rn_share ~ i(euro_num, network_fuel_std, ref = 3) +
          i(euro_num, own_fuel_std, ref = 3) |
          dept_code + id_election,
        data = dept_euro,
        cluster = ~dept_code)
}, error = function(e) {
  cat("  European ES error:", e$message, "\n")
  NULL
})

if (!is.null(es_euro)) {
  cat("  European event study (ref = 2014):\n")
  euro_ct <- coeftable(es_euro)
  net_idx_e <- grepl("network_fuel_std", rownames(euro_ct))
  if (any(net_idx_e)) {
    euro_es_data <- tibble(
      election_num = as.integer(gsub(".*::(\\d+):.*", "\\1", rownames(euro_ct)[net_idx_e])),
      estimate = euro_ct[net_idx_e, "Estimate"],
      se = euro_ct[net_idx_e, "Std. Error"]
    ) %>%
      bind_rows(tibble(election_num = 3L, estimate = 0, se = 0)) %>%
      arrange(election_num) %>%
      mutate(
        year = c(2004, 2009, 2014, 2019, 2024)[election_num],
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se
      )
    cat("    Network coefficients:\n")
    print(euro_es_data)
  }
}

robustness_results$election_type_es <- list(
  presidential_model = es_pres,
  european_model = es_euro,
  presidential_data = if (exists("pres_es_data")) pres_es_data else NULL,
  european_data = if (exists("euro_es_data")) euro_es_data else NULL,
  description = "Separate event studies for presidential and European elections"
)


## ============================================================================
## v4 NEW: 17. IMMIGRATION HORSE-RACE (WS1 — HIGHEST PRIORITY)
## ============================================================================

cat("\n=== 17. Immigration Horse-Race (v4 WS1) ===\n")

## Load SCI-weighted immigration exposure
network_immigration <- readRDS(file.path(DATA_DIR, "network_immigration.rds"))

## Merge and standardize (avoid duplicating column if already present)
dept_panel_hr <- dept_panel %>%
  { if ("network_immigration_norm" %in% names(.)) . else left_join(., network_immigration, by = "dept_code") } %>%
  filter(!is.na(network_immigration_norm)) %>%
  mutate(
    network_immig_std = (network_immigration_norm -
      mean(network_immigration_norm, na.rm = TRUE)) /
      sd(network_immigration_norm, na.rm = TRUE),
    immig_x_post = share_immigrant * post_carbon,
    network_immig_x_post = network_immig_std * post_carbon
  )

cat("  Immigration horse-race sample:", nrow(dept_panel_hr), "obs,",
    n_distinct(dept_panel_hr$dept_code), "départements.\n")

## Correlation between network fuel and network immigration
cor_net_fuel_immig <- cor(dept_panel_hr$network_fuel_std,
                          dept_panel_hr$network_immig_std,
                          use = "complete.obs")
cat("  Correlation(network fuel std, network immig std):", round(cor_net_fuel_immig, 3), "\n")

## (a) Network fuel alone (baseline — should match D2)
hr_a <- feols(rn_share ~ own_fuel_std:post_carbon +
                network_fuel_std:post_carbon |
                dept_code + id_election,
              data = dept_panel_hr,
              cluster = ~dept_code,
              weights = ~total_registered)

## (b) Network immigration alone
hr_b <- feols(rn_share ~ own_fuel_std:post_carbon +
                network_immig_std:post_carbon |
                dept_code + id_election,
              data = dept_panel_hr,
              cluster = ~dept_code,
              weights = ~total_registered)

## (c) HORSE-RACE: Both network fuel AND network immigration
hr_c <- feols(rn_share ~ own_fuel_std:post_carbon +
                network_fuel_std:post_carbon +
                network_immig_std:post_carbon |
                dept_code + id_election,
              data = dept_panel_hr,
              cluster = ~dept_code,
              weights = ~total_registered)

## (d) Horse-race with own immigration control too
hr_d <- feols(rn_share ~ own_fuel_std:post_carbon +
                network_fuel_std:post_carbon +
                network_immig_std:post_carbon +
                immig_x_post |
                dept_code + id_election,
              data = dept_panel_hr,
              cluster = ~dept_code,
              weights = ~total_registered)

cat("\n  Horse-race results (network coefficient):\n")
cat(sprintf("  %-40s  %8s  %8s\n", "Specification", "Coef", "SE"))
cat("  ", strrep("-", 60), "\n")

hr_models <- list(hr_a = hr_a, hr_b = hr_b, hr_c = hr_c, hr_d = hr_d)
hr_labels <- c(
  "(a) Net Fuel alone",
  "(b) Net Immigration alone",
  "(c) Horse-race: Both",
  "(d) Horse-race + Own Immigration"
)

for (i in seq_along(hr_models)) {
  m <- hr_models[[i]]
  cn_fuel <- get_coef(m, "network_fuel_std")
  sn_fuel <- get_se(m, "network_fuel_std")
  cn_immig <- get_coef(m, "network_immig_std")
  sn_immig <- get_se(m, "network_immig_std")

  cat(sprintf("  %-40s", hr_labels[i]))
  if (!is.na(cn_fuel)) {
    cat(sprintf("  Fuel: %7.4f (%6.4f)", cn_fuel, sn_fuel))
  }
  if (!is.na(cn_immig)) {
    cat(sprintf("  Immig: %7.4f (%6.4f)", cn_immig, sn_immig))
  }
  cat("\n")
}

## Key diagnostic: Did fuel survive the horse-race?
fuel_survived <- abs(get_coef(hr_c, "network_fuel_std") /
                       get_se(hr_c, "network_fuel_std")) > 1.645
cat(sprintf("\n  HORSE-RACE VERDICT: Network fuel coefficient %s the horse-race.\n",
            ifelse(fuel_survived, "SURVIVES", "does NOT survive")))

robustness_results$immigration_horse_race <- list(
  models = hr_models,
  labels = hr_labels,
  fuel_alone_coef = get_coef(hr_a, "network_fuel_std"),
  fuel_alone_se = get_se(hr_a, "network_fuel_std"),
  horserace_fuel_coef = get_coef(hr_c, "network_fuel_std"),
  horserace_fuel_se = get_se(hr_c, "network_fuel_std"),
  horserace_immig_coef = get_coef(hr_c, "network_immig_std"),
  horserace_immig_se = get_se(hr_c, "network_immig_std"),
  fuel_survived = fuel_survived,
  cor_fuel_immig = cor_net_fuel_immig,
  description = "Horse-race: SCI-weighted fuel vs SCI-weighted immigration network exposure"
)


## ============================================================================
## v4 NEW: 18. OSTER (2019) BOUNDS (WS1)
## ============================================================================

cat("\n=== 18. Oster (2019) Omitted Variable Bias Bounds ===\n")

## Oster (2019) delta: how much selection on unobservables relative to
## observables would be needed to explain away the network fuel effect.
## We compute delta using the coefficient movement and R² changes when
## adding immigration controls.

## Short regression (no immigration control)
oster_short <- feols(rn_share ~ own_fuel_std:post_carbon +
                       network_fuel_std:post_carbon |
                       dept_code + id_election,
                     data = dept_panel_hr,
                     cluster = ~dept_code,
                     weights = ~total_registered)

## Long regression (with immigration controls)
oster_long <- feols(rn_share ~ own_fuel_std:post_carbon +
                      network_fuel_std:post_carbon +
                      network_immig_std:post_carbon +
                      immig_x_post |
                      dept_code + id_election,
                    data = dept_panel_hr,
                    cluster = ~dept_code,
                    weights = ~total_registered)

## Extract within-R² (fixest provides this)
r2_short <- fitstat(oster_short, "wr2")$wr2
r2_long <- fitstat(oster_long, "wr2")$wr2

beta_short <- get_coef(oster_short, "network_fuel_std")
beta_long <- get_coef(oster_long, "network_fuel_std")

## Oster delta = beta_long * (R²_long - R²_short) / ((beta_short - beta_long) * (R²_max - R²_long))
## where R²_max = min(2.2 * R²_long, 1) following Oster (2019) recommended bound
R_max <- min(2.2 * r2_long, 1)

## delta = (beta_long * (R²_long - R²_short)) / ((beta_short - beta_long) * (R_max - R²_long))
denom <- (beta_short - beta_long) * (R_max - r2_long)

if (abs(denom) > 1e-10) {
  oster_delta <- (beta_long * (r2_long - r2_short)) / denom
} else {
  oster_delta <- Inf  # controls don't move the coefficient
}

cat(sprintf("  Short regression (no immigration controls):\n"))
cat(sprintf("    beta_network = %.4f, within-R² = %.6f\n", beta_short, r2_short))
cat(sprintf("  Long regression (with immigration controls):\n"))
cat(sprintf("    beta_network = %.4f, within-R² = %.6f\n", beta_long, r2_long))
cat(sprintf("  R_max (2.2 * R²_long): %.6f\n", R_max))
cat(sprintf("  Oster delta: %.2f\n", oster_delta))
cat(sprintf("  Interpretation: Unobservables would need to be %.1fx as important\n", abs(oster_delta)))
cat(sprintf("    as immigration observables to fully explain away the network fuel effect.\n"))
cat(sprintf("  Oster (2019) threshold: |delta| > 1 indicates robustness.\n"))
cat(sprintf("  Result: %s\n",
            ifelse(abs(oster_delta) > 1, "PASSES Oster bound (|delta| > 1)",
                   "FAILS Oster bound (|delta| <= 1)")))

robustness_results$oster_bounds <- list(
  beta_short = beta_short,
  beta_long = beta_long,
  r2_short = r2_short,
  r2_long = r2_long,
  R_max = R_max,
  delta = oster_delta,
  passes = abs(oster_delta) > 1,
  description = "Oster (2019) coefficient stability bound for omitted variable bias"
)


## ============================================================================
## v4 NEW: 19. HONESTDID SENSITIVITY ANALYSIS (WS2)
## ============================================================================

cat("\n=== 19. HonestDiD Sensitivity Analysis (v4 WS2) ===\n")

## Apply Rambachan-Roth (2023) sensitivity analysis to the event study.
## The smoothness restriction (M-bound) asks: how large can the pre-trend
## slope be before the post-treatment effect is explained away?

## Load event study results
es_results <- readRDS(file.path(DATA_DIR, "event_study_results.rds"))

## We need the event study with both own and network (es_both)
## HonestDiD works with fixest objects directly via fixest_didHonest

## Try HonestDiD on the département-level event study
## First build département-level event study
if (!"election_num" %in% names(dept_panel)) {
  dept_panel <- dept_panel %>%
    mutate(
      election_num = case_when(
        year == 2002 ~ 1L, year == 2004 ~ 2L, year == 2007 ~ 3L,
        year == 2009 ~ 4L, year == 2012 ~ 5L, year == 2014 ~ 6L,
        year == 2017 ~ 7L, year == 2019 ~ 8L, year == 2022 ~ 9L,
        year == 2024 ~ 10L, TRUE ~ NA_integer_
      )
    )
}

es_dept_net <- feols(rn_share ~ i(election_num, network_fuel_std, ref = 5) +
                       i(election_num, own_fuel_std, ref = 5) |
                       dept_code + id_election,
                     data = dept_panel,
                     cluster = ~dept_code,
                     weights = ~total_registered)

## Extract event study data for HonestDiD
## HonestDiD needs: betahat (pre and post), sigma (VCV), numPrePeriods, numPostPeriods
es_ct <- coeftable(es_dept_net)
net_idx <- grepl("network_fuel_std", rownames(es_ct))

## Extract only network coefficients (ordered by election_num)
net_coefs <- es_ct[net_idx, ]
net_nums <- as.integer(gsub(".*::(\\d+):.*", "\\1", rownames(net_coefs)))
net_order <- order(net_nums)
net_coefs <- net_coefs[net_order, ]
net_nums <- net_nums[net_order]

## Pre-treatment: election_num 1-4 (2002, 2004, 2007, 2009); ref = 5 (2012)
## Post-treatment: election_num 6-10 (2014, 2017, 2019, 2022, 2024)
pre_idx <- which(net_nums < 5)
post_idx <- which(net_nums > 5)

betahat <- net_coefs[, "Estimate"]
names(betahat) <- paste0("t", net_nums)

## Get the variance-covariance matrix for network coefficients
## fixest provides vcov for all coefficients; extract the network block
all_vcov <- vcov(es_dept_net)
net_rows <- which(grepl("network_fuel_std", rownames(all_vcov)))
sigma_net <- all_vcov[net_rows, net_rows]
## Reorder to match
sigma_net <- sigma_net[net_order, net_order]

numPrePeriods <- length(pre_idx)
numPostPeriods <- length(post_idx)

cat("  Event study for HonestDiD:\n")
cat("    Pre-treatment periods:", numPrePeriods, "\n")
cat("    Post-treatment periods:", numPostPeriods, "\n")
cat("    Pre-treatment coefficients:", round(betahat[pre_idx], 4), "\n")
cat("    Post-treatment coefficients:", round(betahat[post_idx], 4), "\n")

## Run HonestDiD with smoothness restriction (relative magnitudes)
honest_result <- tryCatch({
  ## Smoothness restriction: Delta^{RM}
  ## This tests: treatment effects robust to violations of parallel trends
  ## up to M times the maximum pre-treatment trend change
  HonestDiD::createSensitivityResults_relativeMagnitudes(
    betahat = betahat,
    sigma = sigma_net,
    numPrePeriods = numPrePeriods,
    numPostPeriods = numPostPeriods,
    Mbarvec = seq(0, 2, by = 0.5),
    l_vec = c(rep(0, numPostPeriods - 1), 1)  # Focus on last post-period
  )
}, error = function(e) {
  cat("  HonestDiD relative magnitudes error:", e$message, "\n")
  NULL
})

if (!is.null(honest_result)) {
  cat("\n  HonestDiD Sensitivity (Relative Magnitudes, last post-period):\n")
  cat(sprintf("  %-8s  %10s  %10s\n", "Mbar", "CI Lower", "CI Upper"))
  cat("  ", strrep("-", 35), "\n")
  for (i in seq_len(nrow(honest_result))) {
    cat(sprintf("  %-8.1f  %10.4f  %10.4f\n",
                honest_result$Mbar[i],
                honest_result$lb[i],
                honest_result$ub[i]))
  }

  ## Find largest Mbar where CI still excludes zero
  robust_Mbar <- max(honest_result$Mbar[honest_result$lb > 0], na.rm = TRUE)
  if (is.infinite(robust_Mbar) && all(honest_result$lb <= 0)) {
    robust_Mbar <- 0
  } else if (is.infinite(robust_Mbar)) {
    robust_Mbar <- max(honest_result$Mbar)
  }

  cat(sprintf("\n  Effect is robust up to Mbar = %.1f\n", robust_Mbar))
  cat("  (Mbar = max relative magnitude of pre-trend violation)\n")
}

## Also try smoothness restriction (Delta^{SD})
honest_sd <- tryCatch({
  HonestDiD::createSensitivityResults(
    betahat = betahat,
    sigma = sigma_net,
    numPrePeriods = numPrePeriods,
    numPostPeriods = numPostPeriods,
    Mvec = seq(0, 0.5, by = 0.1),
    l_vec = c(rep(0, numPostPeriods - 1), 1)
  )
}, error = function(e) {
  cat("  HonestDiD smoothness restriction error:", e$message, "\n")
  NULL
})

if (!is.null(honest_sd)) {
  cat("\n  HonestDiD Sensitivity (Smoothness, last post-period):\n")
  cat(sprintf("  %-8s  %10s  %10s\n", "M", "CI Lower", "CI Upper"))
  cat("  ", strrep("-", 35), "\n")
  for (i in seq_len(nrow(honest_sd))) {
    cat(sprintf("  %-8.2f  %10.4f  %10.4f\n",
                honest_sd$M[i],
                honest_sd$lb[i],
                honest_sd$ub[i]))
  }
}

robustness_results$honest_did <- list(
  relative_magnitudes = honest_result,
  smoothness = honest_sd,
  betahat = betahat,
  sigma = sigma_net,
  numPrePeriods = numPrePeriods,
  numPostPeriods = numPostPeriods,
  es_dept_model = es_dept_net,
  robust_Mbar = if (exists("robust_Mbar")) robust_Mbar else NA,
  description = "Rambachan-Roth (2023) HonestDiD sensitivity analysis for parallel trends"
)


## ============================================================================
## 20. EXPANDED INFERENCE COMPARISON TABLE
## ============================================================================

cat("\n=== 17. Expanded Inference Comparison ===\n")

## Collect all p-values for the network coefficient
clustered_se_p_net <- 2 * pt(
  abs(actual_t_net),
  df = length(unique(dept_panel$dept_code)) - 1,
  lower.tail = FALSE
)

## AKM p-value
akm_p <- robustness_results$akm_shift_share$akm_p_network

## Two-way cluster p-value
twoway_p <- robustness_results$two_way_cluster$p_network_dept

## Conley p-value
conley_p <- if (!is.null(robustness_results$conley_spatial)) {
  robustness_results$conley_spatial$p_network
} else {
  NA_real_
}

inference_comparison <- tibble(
  method = c(
    "Clustered SE (département)",
    "AKM shift-share SE",
    "Two-way cluster (dept + election)",
    "Conley spatial HAC (300 km)",
    "Standard RI (full permutation)",
    "Block RI (within-region permutation)",
    "Wild Cluster Bootstrap (Rademacher)"
  ),
  p_own = c(
    2 * pt(abs(actual_t_own),
           df = length(unique(dept_panel$dept_code)) - 1, lower.tail = FALSE),
    NA_real_,  # AKM applies to network coefficient
    2 * pt(abs(get_coef(d_twoway_dept, "own_fuel_std") /
                 get_se(d_twoway_dept, "own_fuel_std")),
           df = min(n_distinct(dept_panel$dept_code),
                    n_distinct(dept_panel$id_election)) - 1,
           lower.tail = FALSE),
    if (!is.null(robustness_results$conley_spatial)) {
      2 * pnorm(-abs(get_coef(robustness_results$conley_spatial$model, "own_fuel_std") /
                        get_se(robustness_results$conley_spatial$model, "own_fuel_std")))
    } else { NA_real_ },
    ri_p_own,
    block_ri_p_own,
    wcb_p_own
  ),
  p_network = c(
    clustered_se_p_net,
    akm_p,
    twoway_p,
    conley_p,
    ri_p_net,
    block_ri_p_net,
    wcb_p_net
  )
)

cat("\n  Inference comparison (p-values for network coefficient):\n")
cat(sprintf("  %-45s  %10s  %10s\n", "Method", "p (Own)", "p (Network)"))
cat("  ", strrep("-", 70), "\n")
for (i in seq_len(nrow(inference_comparison))) {
  p_own_str <- ifelse(is.na(inference_comparison$p_own[i]), "      --",
                      sprintf("%10.4f", inference_comparison$p_own[i]))
  p_net_str <- ifelse(is.na(inference_comparison$p_network[i]), "      --",
                      sprintf("%10.4f", inference_comparison$p_network[i]))
  cat(sprintf("  %-45s  %s  %s\n",
              inference_comparison$method[i],
              p_own_str,
              p_net_str))
}

robustness_results$inference_comparison <- inference_comparison


## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS
## ============================================================================

cat("\n\nSaving robustness results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))


## ============================================================================
## COMPREHENSIVE SUMMARY TABLE (v3)
## ============================================================================

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS SUMMARY TABLE (v3)\n")
cat(strrep("=", 70), "\n\n")

summary_rows <- list()

## Baseline (département D1)
summary_rows[[1]] <- tibble(
  specification = "Baseline (Dept D1)",
  coef_own = get_coef(dept_results$d1, "own_fuel_std"),
  se_own = get_se(dept_results$d1, "own_fuel_std"),
  coef_network = get_coef(dept_results$d1, "network_fuel_std"),
  se_network = get_se(dept_results$d1, "network_fuel_std"),
  n_obs = nobs(dept_results$d1)
)

## 1. AKM shift-share
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "1. AKM shift-share SE",
  coef_own = coef(ld_ols)["own_fuel_std"],
  se_own = NA_real_,
  coef_network = coef(ld_ols)["network_fuel_std"],
  se_network = akm_se_network,
  n_obs = n_ld
)

## 2. Two-way cluster
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "2. Two-way cluster (dept+elec)",
  coef_own = get_coef(d_twoway_dept, "own_fuel_std"),
  se_own = get_se(d_twoway_dept, "own_fuel_std"),
  coef_network = get_coef(d_twoway_dept, "network_fuel_std"),
  se_network = get_se(d_twoway_dept, "network_fuel_std"),
  n_obs = nobs(d_twoway_dept)
)

## 3. Conley
if (!is.null(robustness_results$conley_spatial)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "3. Conley HAC (300 km)",
    coef_own = get_coef(robustness_results$conley_spatial$model, "own_fuel_std"),
    se_own = get_se(robustness_results$conley_spatial$model, "own_fuel_std"),
    coef_network = robustness_results$conley_spatial$coef_network,
    se_network = robustness_results$conley_spatial$se_network,
    n_obs = nobs(robustness_results$conley_spatial$model)
  )
}

## 4. Distance-restricted
if (!is.null(robustness_results$distance_restricted)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "4. SCI > 200 km only",
    coef_own = robustness_results$distance_restricted$coef_own_dept,
    se_own = robustness_results$distance_restricted$se_own_dept,
    coef_network = robustness_results$distance_restricted$coef_network_dept,
    se_network = robustness_results$distance_restricted$se_network_dept,
    n_obs = robustness_results$distance_restricted$n_obs_dept
  )
}

## 5. Placebos
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "5a. Placebo: Turnout",
  coef_own = get_coef(m_placebo_turnout_dept, "own_fuel_std"),
  se_own = get_se(m_placebo_turnout_dept, "own_fuel_std"),
  coef_network = robustness_results$placebo_turnout$coef_network,
  se_network = robustness_results$placebo_turnout$se_network,
  n_obs = robustness_results$placebo_turnout$n_obs
)

if (!is.null(robustness_results$placebo_green)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "5b. Placebo: Green share",
    coef_own = get_coef(m_placebo_green, "own_fuel_std"),
    se_own = get_se(m_placebo_green, "own_fuel_std"),
    coef_network = robustness_results$placebo_green$coef_network,
    se_network = robustness_results$placebo_green$se_network,
    n_obs = robustness_results$placebo_green$n_obs
  )
}

if (!is.null(robustness_results$placebo_right)) {
  summary_rows[[length(summary_rows) + 1]] <- tibble(
    specification = "5c. Placebo: Center-right",
    coef_own = get_coef(m_placebo_right, "own_fuel_std"),
    se_own = get_se(m_placebo_right, "own_fuel_std"),
    coef_network = robustness_results$placebo_right$coef_network,
    se_network = robustness_results$placebo_right$se_network,
    n_obs = robustness_results$placebo_right$n_obs
  )
}

## 6. LOO
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "6. LOO (mean across depts)",
  coef_own = mean(loo_results$coef_own, na.rm = TRUE),
  se_own = NA_real_,
  coef_network = robustness_results$leave_one_out$mean_coef_network,
  se_network = NA_real_,
  n_obs = NA_integer_
)

## 7. Post-GJ
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "7. Post-GJ (2019+)",
  coef_own = robustness_results$post_gj$coef_own_gj,
  se_own = robustness_results$post_gj$se_own_gj,
  coef_network = robustness_results$post_gj$coef_network_gj,
  se_network = robustness_results$post_gj$se_network_gj,
  n_obs = robustness_results$post_gj$n_obs
)

## 12. Migration proxy
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "12. Migration proxy weights",
  coef_own = get_coef(m_mig_dept, "own_fuel_std"),
  se_own = get_se(m_mig_dept, "own_fuel_std"),
  coef_network = robustness_results$migration_proxy$coef_network_dept,
  se_network = robustness_results$migration_proxy$se_network_dept,
  n_obs = robustness_results$migration_proxy$n_obs_dept
)

## 13. Kitchen-sink controls
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "13g. Kitchen-sink + trends",
  coef_own = get_coef(ctrl_g, "own_fuel_std"),
  se_own = get_se(ctrl_g, "own_fuel_std"),
  coef_network = get_coef(ctrl_g, "network_fuel_std"),
  se_network = get_se(ctrl_g, "network_fuel_std"),
  n_obs = as.integer(nobs(ctrl_g))
)

## 17. Horse-race: fuel survives immigration
summary_rows[[length(summary_rows) + 1]] <- tibble(
  specification = "17c. Horse-race (Fuel + Immig)",
  coef_own = get_coef(hr_c, "own_fuel_std"),
  se_own = get_se(hr_c, "own_fuel_std"),
  coef_network = get_coef(hr_c, "network_fuel_std"),
  se_network = get_se(hr_c, "network_fuel_std"),
  n_obs = as.integer(nobs(hr_c))
)

## Build and print summary
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

cat(sprintf("%-35s  %10s %5s  %10s %5s  %8s\n",
            "Specification", "Own x Post", "Sig", "Net x Post", "Sig", "N"))
cat(strrep("-", 82), "\n")

for (i in seq_len(nrow(summary_table))) {
  row <- summary_table[i, ]
  cat(sprintf("%-35s  %7.4f    %3s  %7.4f    %3s  %8s\n",
              row$specification,
              row$coef_own,
              row$sig_own,
              row$coef_network,
              row$sig_network,
              ifelse(is.na(row$n_obs), "varies",
                     format(row$n_obs, big.mark = ","))))
  if (!is.na(row$se_own)) {
    cat(sprintf("%-35s  (%6.4f)        (%6.4f)\n",
                "", row$se_own, row$se_network))
  }
}

cat(strrep("-", 82), "\n")
cat("*** p<0.01, ** p<0.05, * p<0.10\n")

## Additional diagnostics summary
cat("\n--- Additional Diagnostics ---\n")
cat(sprintf("  8. Bartik: Top-5 Rotemberg weight sum = %.3f, HHI = %.4f",
            robustness_results$bartik_diagnostics$top5_concentration,
            robustness_results$bartik_diagnostics$hhi))
if (!is.na(robustness_results$bartik_diagnostics$share_exogeneity_p)) {
  cat(sprintf(", Share exog. p = %.3f",
              robustness_results$bartik_diagnostics$share_exogeneity_p))
}
cat("\n")

cat(sprintf("  9. Standard RI p-values: Own = %.4f, Network = %.4f (%d permutations)\n",
            ri_p_own, ri_p_net, N_PERM))

cat(sprintf("  10. Block RI p-values: Own = %.4f, Network = %.4f (%d permutations)\n",
            block_ri_p_own, block_ri_p_net, N_BLOCK_PERM))

cat(sprintf("  11. WCB p-values: Own = %.4f, Network = %.4f (B=%d, Rademacher)\n",
            wcb_p_own, wcb_p_net, N_BOOT))

cat(sprintf("  17. Horse-race: Fuel coef = %.4f (%.4f), Immig coef = %.4f (%.4f), Fuel %s\n",
            robustness_results$immigration_horse_race$horserace_fuel_coef,
            robustness_results$immigration_horse_race$horserace_fuel_se,
            robustness_results$immigration_horse_race$horserace_immig_coef,
            robustness_results$immigration_horse_race$horserace_immig_se,
            ifelse(robustness_results$immigration_horse_race$fuel_survived, "SURVIVES", "falls")))

cat(sprintf("  18. Oster delta = %.2f (%s)\n",
            robustness_results$oster_bounds$delta,
            ifelse(robustness_results$oster_bounds$passes, "PASSES", "FAILS")))

if (!is.null(robustness_results$honest_did$relative_magnitudes)) {
  cat(sprintf("  19. HonestDiD: Effect robust up to Mbar = %.1f\n",
              robustness_results$honest_did$robust_Mbar))
}

cat(sprintf("  6. LOO: Network coef significant in %.1f%% of iterations (range: [%.4f, %.4f])\n",
            robustness_results$leave_one_out$pct_significant,
            min(loo_results$coef_network, na.rm = TRUE),
            max(loo_results$coef_network, na.rm = TRUE)))

## Distance-bin summary
cat("\n--- Distance-Bin Decomposition ---\n")
for (i in seq_len(nrow(bin_results))) {
  r <- bin_results[i, ]
  if (!is.na(r$coef_network)) {
    t_val <- r$coef_network / r$se_network
    sig <- ifelse(abs(t_val) > 2.576, "***",
           ifelse(abs(t_val) > 1.96, "**",
           ifelse(abs(t_val) > 1.645, "*", "")))
    cat(sprintf("  %-10s: %.4f (%.4f) %s  [%d depts]\n",
                r$bin, r$coef_network, r$se_network, sig, r$n_depts))
  } else {
    cat(sprintf("  %-10s: NA (insufficient coverage)\n", r$bin))
  }
}

## Placebo timing summary
cat("\n--- Placebo Timing Tests ---\n")
for (i in seq_len(nrow(placebo_timing))) {
  r <- placebo_timing[i, ]
  t_val <- r$coef_network / r$se_network
  cat(sprintf("  Fake date %d: Network = %.4f (%.4f), t = %.2f — %s\n",
              r$fake_date, r$coef_network, r$se_network, t_val,
              ifelse(abs(t_val) < 1.96, "PASS", "FAIL")))
}

## ============================================================================
## v5 NEW: 21. TIMING DECOMPOSITION (WS2)
## ============================================================================

cat("\n=== 21. Timing Decomposition (v5 WS2) ===\n")

## Decompose Post into three treatment indicators:
## post_carbon_only: 2014-2017 (pre-GJ carbon tax era)
## post_gj: 2019+ (post-Gilets Jaunes)
## This tests whether the effect was present at initial carbon tax introduction

dept_panel <- dept_panel %>%
  mutate(
    post_carbon_only = as.integer(year >= 2014 & year < 2019),
    post_gj_only = as.integer(year >= 2019)
  )

## Model: Incremental timing decomposition
timing_decomp <- feols(rn_share ~ own_fuel_std:post_carbon_only +
                          network_fuel_std:post_carbon_only +
                          own_fuel_std:post_gj_only +
                          network_fuel_std:post_gj_only |
                          dept_code + id_election,
                        data = dept_panel,
                        cluster = ~dept_code,
                        weights = ~total_registered)

cat("  Timing decomposition (dept-level, pop-weighted):\n")
etable(timing_decomp, se.below = TRUE)

## Extract coefficients
net_carbon_only <- get_coef(timing_decomp, "network_fuel_std.*post_carbon_only")
se_carbon_only <- get_se(timing_decomp, "network_fuel_std.*post_carbon_only")
net_gj_only <- get_coef(timing_decomp, "network_fuel_std.*post_gj_only")
se_gj_only <- get_se(timing_decomp, "network_fuel_std.*post_gj_only")

cat(sprintf("  Network x Carbon-Only (2014-2017): %.4f (%.4f), t = %.2f\n",
            net_carbon_only, se_carbon_only, net_carbon_only / se_carbon_only))
cat(sprintf("  Network x GJ-Only (2019+):         %.4f (%.4f), t = %.2f\n",
            net_gj_only, se_gj_only, net_gj_only / se_gj_only))

## Test whether the two coefficients are equal (Wald test)
timing_wald <- tryCatch({
  wald(timing_decomp,
       paste0("`", names(coef(timing_decomp))[grepl("network_fuel_std.*post_carbon_only",
                                                       names(coef(timing_decomp)))], "` = `",
              names(coef(timing_decomp))[grepl("network_fuel_std.*post_gj_only",
                                                 names(coef(timing_decomp)))], "`"))
}, error = function(e) {
  cat("  Wald test error:", e$message, "\n")
  NULL
})

robustness_results$timing_decomposition <- list(
  model = timing_decomp,
  net_carbon_only = net_carbon_only,
  se_carbon_only = se_carbon_only,
  net_gj_only = net_gj_only,
  se_gj_only = se_gj_only,
  description = "Timing decomposition: carbon-tax-only period (2014-2017) vs GJ period (2019+)"
)


## ============================================================================
## v5 NEW: 22. MEASUREMENT ERROR BOUNDS (WS3)
## ============================================================================

cat("\n=== 22. Measurement Error Bounds (v5 WS3) ===\n")

## If SCI changed between a hypothetical 2013 and 2024 version,
## and the migration proxy correlation is rho = 0.66,
## then under classical measurement error:
## true_effect = observed_effect / rho
## (because the migration proxy is the noisy version, observed via SCI is less noisy)
## But if SCI itself has noise relative to the TRUE 2013 network:
## true_effect = observed_effect / attenuation_factor

rho_sci_mig <- cor_sci_mig$pearson  # correlation between SCI and migration proxy

cat(sprintf("  SCI-migration correlation (rho): %.3f\n", rho_sci_mig))
cat(sprintf("  If measurement error is classical:\n"))
cat(sprintf("    Attenuation factor: rho^2 = %.3f\n", rho_sci_mig^2))
cat(sprintf("    Bias-corrected effect (SCI baseline): %.4f / %.3f = %.4f\n",
            get_coef(dept_results$d2, "network_fuel_std"),
            1,
            get_coef(dept_results$d2, "network_fuel_std")))
cat(sprintf("    Bias-corrected effect (migration baseline): %.4f / %.3f = %.4f\n",
            robustness_results$migration_proxy$coef_network_dept,
            rho_sci_mig^2,
            robustness_results$migration_proxy$coef_network_dept / rho_sci_mig^2))

## Conservative bounds: assume SCI has measurement error of (1-rho) relative to true 2013 network
## Then our estimate is attenuated by rho (not rho^2) since SCI is the better proxy
cat(sprintf("\n  Conservative scenario (SCI has measurement error rho relative to true):\n"))
cat(sprintf("    Attenuation: rho = %.3f\n", rho_sci_mig))
cat(sprintf("    Corrected SCI effect: %.4f / %.3f = %.4f\n",
            get_coef(dept_results$d2, "network_fuel_std"),
            rho_sci_mig,
            get_coef(dept_results$d2, "network_fuel_std") / rho_sci_mig))

## Range of plausible true effects
lower_bound <- get_coef(dept_results$d2, "network_fuel_std")  # no correction
upper_bound <- get_coef(dept_results$d2, "network_fuel_std") / rho_sci_mig  # full correction

cat(sprintf("\n  Plausible range of true network effect: [%.4f, %.4f]\n",
            lower_bound, upper_bound))
cat("  Interpretation: Post-treatment SCI measurement implies our estimate\n")
cat("  is a LOWER BOUND if measurement error is classical.\n")

robustness_results$measurement_error_bounds <- list(
  rho_sci_migration = rho_sci_mig,
  observed_effect = get_coef(dept_results$d2, "network_fuel_std"),
  corrected_effect_conservative = get_coef(dept_results$d2, "network_fuel_std") / rho_sci_mig,
  corrected_effect_classical = robustness_results$migration_proxy$coef_network_dept / rho_sci_mig^2,
  lower_bound = lower_bound,
  upper_bound = upper_bound,
  description = "Measurement error bounds using SCI-migration correlation"
)


## ============================================================================
## v5 NEW: 23. DISTANCE BIN × URBANIZATION INTERACTION (WS4)
## ============================================================================

cat("\n=== 23. Distance Bin × Urbanization Interaction (v5 WS4) ===\n")

## Test structural interpretation: 50-200km ties are periurban-metro bridges
## Negative coefficient should be driven by urban départements connected to nearby rural ones

## Also create simplified two-bin version: nearby (<200km) vs distant (>200km)

if (file.exists(geo_file)) {
  ## Compute two-bin exposure: nearby vs distant
  sci_nearby <- sci_dist %>%
    filter(distance_km <= 200 & distance_km > 0) %>%
    group_by(dept_from) %>%
    mutate(sci_weight_nearby = scaled_sci / sum(scaled_sci)) %>%
    ungroup()

  sci_far <- sci_dist %>%
    filter(distance_km > 200) %>%
    group_by(dept_from) %>%
    mutate(sci_weight_far = scaled_sci / sum(scaled_sci)) %>%
    ungroup()

  net_nearby <- sci_nearby %>%
    left_join(fuel_vuln, by = c("dept_to" = "dept_code")) %>%
    filter(!is.na(co2_commute)) %>%
    group_by(dept_from) %>%
    summarize(net_fuel_nearby = weighted.mean(co2_commute, w = sci_weight_nearby),
              .groups = "drop") %>%
    rename(dept_code = dept_from)

  net_far <- sci_far %>%
    left_join(fuel_vuln, by = c("dept_to" = "dept_code")) %>%
    filter(!is.na(co2_commute)) %>%
    group_by(dept_from) %>%
    summarize(net_fuel_far = weighted.mean(co2_commute, w = sci_weight_far),
              .groups = "drop") %>%
    rename(dept_code = dept_from)

  dept_panel_twobin <- dept_panel %>%
    left_join(net_nearby, by = "dept_code") %>%
    left_join(net_far, by = "dept_code") %>%
    filter(!is.na(net_fuel_nearby) & !is.na(net_fuel_far)) %>%
    mutate(
      net_nearby_std = (net_fuel_nearby - mean(net_fuel_nearby, na.rm = TRUE)) /
        sd(net_fuel_nearby, na.rm = TRUE),
      net_far_std = (net_fuel_far - mean(net_fuel_far, na.rm = TRUE)) /
        sd(net_fuel_far, na.rm = TRUE)
    )

  ## Two-bin model: nearby vs distant
  m_twobin <- feols(rn_share ~ own_fuel_std:post_carbon +
                       net_nearby_std:post_carbon +
                       net_far_std:post_carbon |
                       dept_code + id_election,
                     data = dept_panel_twobin,
                     cluster = ~dept_code,
                     weights = ~total_registered)

  cat("  Two-bin results (nearby <200km vs distant >200km):\n")
  etable(m_twobin, se.below = TRUE)

  near_coef <- get_coef(m_twobin, "net_nearby_std")
  far_coef <- get_coef(m_twobin, "net_far_std")
  cat(sprintf("  Nearby (<200km): %.4f (%.4f)\n", near_coef, get_se(m_twobin, "net_nearby_std")))
  cat(sprintf("  Distant (>200km): %.4f (%.4f)\n", far_coef, get_se(m_twobin, "net_far_std")))

  robustness_results$distance_twobin <- list(
    model = m_twobin,
    near_coef = near_coef,
    near_se = get_se(m_twobin, "net_nearby_std"),
    far_coef = far_coef,
    far_se = get_se(m_twobin, "net_far_std"),
    description = "Two-bin distance decomposition: nearby (<200km) vs distant (>200km)"
  )
} else {
  cat("  WARNING: geo file not found. Skipping.\n")
  robustness_results$distance_twobin <- NULL
}


## ============================================================================
## v5 NEW: 24. ALTERNATIVE BLOCKING RI — URBANIZATION QUARTILE BLOCKS (WS5)
## ============================================================================

cat("\n=== 24. Alternative Blocking RI — Urbanization Quartile Blocks (v5 WS5) ===\n")

## Block RI within urbanization quartiles instead of NUTS-2 regions
## If block RI is null under regions but significant under urbanization blocks,
## that tells us the source of variation is cross-region, not within-region

## Create urbanization quartiles from fuel vulnerability (inverse proxy for urbanization)
fuel_vec_urban <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered)) %>%
  mutate(urban_quartile = ntile(-co2_commute, 4))  # Higher CO2 = more rural = lower quartile

set.seed(20260228)
N_URBAN_PERM <- 5000

cat("  Running", N_URBAN_PERM, "urbanization-block permutations...\n")

urban_perm_t_net <- numeric(N_URBAN_PERM)
urban_quartiles <- fuel_vec_urban$urban_quartile
unique_q <- unique(urban_quartiles)
quartile_indices <- lapply(unique_q, function(q) which(urban_quartiles == q))

for (p in seq_len(N_URBAN_PERM)) {
  fuel_perm <- fuel_vec_urban$co2_commute
  for (q_idx in seq_along(unique_q)) {
    idx <- quartile_indices[[q_idx]]
    if (length(idx) > 1) fuel_perm[idx] <- fuel_perm[sample(idx)]
  }

  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  perm_map <- tibble(
    dept_code = dept_codes_ordered,
    own_fuel_std_perm = own_std_perm,
    network_fuel_std_perm = net_std_perm
  )

  dept_perm <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, post_carbon, total_registered) %>%
    left_join(perm_map, by = "dept_code") %>%
    filter(!is.na(own_fuel_std_perm))

  m_perm <- tryCatch({
    feols(rn_share ~ own_fuel_std_perm:post_carbon +
            network_fuel_std_perm:post_carbon |
            dept_code + id_election,
          data = dept_perm,
          cluster = ~dept_code,
          weights = ~total_registered)
  }, error = function(e) NULL)

  if (!is.null(m_perm)) {
    urban_perm_t_net[p] <- get_coef(m_perm, "network_fuel_std_perm") /
      get_se(m_perm, "network_fuel_std_perm")
  } else {
    urban_perm_t_net[p] <- NA
  }
}

urban_ri_p_net <- mean(abs(urban_perm_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat(sprintf("  Urbanization-block RI p-value (network): %.4f\n", urban_ri_p_net))
cat(sprintf("  Comparison: Region-block RI p-value: %.4f\n", block_ri_p_net))
cat(sprintf("  Comparison: Standard RI p-value: %.4f\n", ri_p_net))

robustness_results$urban_block_ri <- list(
  p_network = urban_ri_p_net,
  n_permutations = N_URBAN_PERM,
  description = "Block-permutation RI within urbanization quartiles (5000 perms)"
)


## ============================================================================
## v5 NEW: 25. BLOCK RI POWER ANALYSIS (WS5)
## ============================================================================

cat("\n=== 25. Block RI Power Analysis (v5 WS5) ===\n")

## Monte Carlo: Given 13 regions with ~7 depts each, what is the power
## to detect a 1.35pp effect under block permutation?

set.seed(20260301)
N_POWER_SIM <- 1000
N_BLOCK_INNER <- 500

## Under the null: no network effect
## Under the alternative: true effect = 1.35 (from D2)
## We simulate data under the alternative and compute rejection rate under block RI

true_effect <- get_coef(dept_results$d2, "network_fuel_std")
cat(sprintf("  True effect to detect: %.4f\n", true_effect))
cat(sprintf("  Simulating %d datasets, %d block perms each...\n", N_POWER_SIM, N_BLOCK_INNER))

## Get residual variance from baseline model
resid_sd <- sd(residuals(dept_results$d2))

power_rejections <- 0

for (s in seq_len(N_POWER_SIM)) {
  ## Generate synthetic Y under alternative
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

  ## Block RI under null (within-region)
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

## Minimum detectable effect (approximate)
## MDE ≈ effect * (z_alpha + z_beta) / actual_t
## For 80% power: z_0.025 + z_0.2 = 1.96 + 0.84 = 2.80
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

## Permute the SHIFTS (fuel vulnerability) across départements while holding
## the SHARES (SCI weights) fixed. This is the correct RI for shift-share designs.
## Note: This is conceptually the same as standard RI (section 9) since we already
## permute fuel across depts. The Borusyak et al. insight is that the shares matrix
## is held fixed, which is exactly what section 9 does.
## We add a refinement: permute only among "comparable" départements
## (similar population density) to strengthen the null.

fuel_vec_shift <- fuel_vuln %>%
  filter(dept_code %in% dept_codes_ordered) %>%
  arrange(match(dept_code, dept_codes_ordered))

## Population density terciles for matching
if ("pop_density" %in% names(fuel_vec_shift)) {
  fuel_vec_shift <- fuel_vec_shift %>%
    mutate(density_tercile = ntile(pop_density, 3))
} else {
  ## Use CO2 as inverse urbanization proxy
  fuel_vec_shift <- fuel_vec_shift %>%
    mutate(density_tercile = ntile(-co2_commute, 3))
}

set.seed(20260302)
N_SHIFT_PERM <- 5000

cat("  Running", N_SHIFT_PERM, "shift-level permutations (within density terciles)...\n")

shift_perm_t_net <- numeric(N_SHIFT_PERM)
density_terciles <- fuel_vec_shift$density_tercile
unique_terciles <- unique(density_terciles)
tercile_indices <- lapply(unique_terciles, function(t) which(density_terciles == t))

for (p in seq_len(N_SHIFT_PERM)) {
  fuel_perm <- fuel_vec_shift$co2_commute
  for (t_idx in seq_along(unique_terciles)) {
    idx <- tercile_indices[[t_idx]]
    if (length(idx) > 1) fuel_perm[idx] <- fuel_perm[sample(idx)]
  }

  net_fuel_perm <- as.numeric(W_mat %*% fuel_perm)
  own_std_perm <- (fuel_perm - mean(fuel_perm)) / sd(fuel_perm)
  net_std_perm <- (net_fuel_perm - mean(net_fuel_perm)) / sd(net_fuel_perm)

  perm_map <- tibble(
    dept_code = dept_codes_ordered,
    own_fuel_std_perm = own_std_perm,
    network_fuel_std_perm = net_std_perm
  )

  dept_perm <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, post_carbon, total_registered) %>%
    left_join(perm_map, by = "dept_code") %>%
    filter(!is.na(own_fuel_std_perm))

  m_perm <- tryCatch({
    feols(rn_share ~ own_fuel_std_perm:post_carbon +
            network_fuel_std_perm:post_carbon |
            dept_code + id_election,
          data = dept_perm,
          cluster = ~dept_code,
          weights = ~total_registered)
  }, error = function(e) NULL)

  if (!is.null(m_perm)) {
    shift_perm_t_net[p] <- get_coef(m_perm, "network_fuel_std_perm") /
      get_se(m_perm, "network_fuel_std_perm")
  } else {
    shift_perm_t_net[p] <- NA
  }
}

shift_ri_p_net <- mean(abs(shift_perm_t_net) >= abs(actual_t_net), na.rm = TRUE)

cat(sprintf("  Shift-level RI p-value (network): %.4f\n", shift_ri_p_net))
cat(sprintf("  Standard RI p-value: %.4f\n", ri_p_net))
cat(sprintf("  Region-block RI p-value: %.4f\n", block_ri_p_net))

robustness_results$shift_level_ri <- list(
  p_network = shift_ri_p_net,
  n_permutations = N_SHIFT_PERM,
  description = "Shift-level RI: permute fuel within density terciles, hold SCI shares fixed"
)


## ============================================================================
## v5 NEW: 27. DONUT DESIGN (WS7)
## ============================================================================

cat("\n=== 27. Donut Design (v5 WS7) ===\n")

## Drop 2012 and 2014 (boundary elections) and compare pre (2002-2009) vs post (2017+)
## This removes contamination from anticipation effects or delayed baseline effects

dept_panel_donut <- dept_panel %>%
  filter(!(year %in% c(2012, 2014))) %>%
  mutate(post_donut = as.integer(year >= 2017))

cat("  Donut sample (dropping 2012, 2014):", nrow(dept_panel_donut), "obs,",
    n_distinct(dept_panel_donut$year), "elections\n")
cat("  Elections:", paste(sort(unique(dept_panel_donut$year)), collapse = ", "), "\n")

m_donut <- feols(rn_share ~ own_fuel_std:post_donut +
                    network_fuel_std:post_donut |
                    dept_code + id_election,
                  data = dept_panel_donut,
                  cluster = ~dept_code,
                  weights = ~total_registered)

cat("  Donut design results (dept-level):\n")
cat(sprintf("    Own x Post:     %.4f (%.4f)\n",
            get_coef(m_donut, "own_fuel_std"), get_se(m_donut, "own_fuel_std")))
cat(sprintf("    Network x Post: %.4f (%.4f)\n",
            get_coef(m_donut, "network_fuel_std"), get_se(m_donut, "network_fuel_std")))

robustness_results$donut_design <- list(
  model = m_donut,
  coef_own = get_coef(m_donut, "own_fuel_std"),
  se_own = get_se(m_donut, "own_fuel_std"),
  coef_network = get_coef(m_donut, "network_fuel_std"),
  se_network = get_se(m_donut, "network_fuel_std"),
  n_obs = nobs(m_donut),
  description = "Donut design: drop 2012 and 2014, compare pre (2002-2009) vs post (2017+)"
)


## ============================================================================
## v5 NEW: 28. TRIPLE-DIFFERENCE: RN vs GREEN (WS7)
## ============================================================================

cat("\n=== 28. Triple-Difference: RN vs Green (v5 WS7) ===\n")

## If networks transmit fuel grievance specifically to RN (not Greens),
## the triple-diff should be significant

if ("green_share" %in% names(dept_panel)) {
  ## Stack RN and Green outcomes
  dept_rn <- dept_panel %>%
    select(dept_code, id_election, year, rn_share, own_fuel_std, network_fuel_std,
           post_carbon, total_registered) %>%
    mutate(outcome = rn_share, party = "RN")

  dept_green <- dept_panel %>%
    select(dept_code, id_election, year, green_share, own_fuel_std, network_fuel_std,
           post_carbon, total_registered) %>%
    mutate(outcome = green_share, party = "Green")

  dept_stacked <- bind_rows(dept_rn, dept_green) %>%
    mutate(
      is_rn = as.integer(party == "RN"),
      unit_party = paste0(dept_code, "_", party),
      elec_party = paste0(id_election, "_", party)
    )

  ## Triple-diff: outcome ~ own×post + net×post + own×post×RN + net×post×RN | FE
  m_triple <- tryCatch({
    feols(outcome ~ own_fuel_std:post_carbon +
            network_fuel_std:post_carbon +
            own_fuel_std:post_carbon:is_rn +
            network_fuel_std:post_carbon:is_rn |
            unit_party + elec_party,
          data = dept_stacked,
          cluster = ~dept_code,
          weights = ~total_registered)
  }, error = function(e) {
    cat("  Triple-diff error:", e$message, "\n")
    NULL
  })

  if (!is.null(m_triple)) {
    cat("  Triple-diff results:\n")
    etable(m_triple, se.below = TRUE)

    net_triple <- get_coef(m_triple, "network_fuel_std.*is_rn")
    se_triple <- get_se(m_triple, "network_fuel_std.*is_rn")
    cat(sprintf("  Network × Post × RN: %.4f (%.4f), t = %.2f\n",
                net_triple, se_triple, net_triple / se_triple))

    robustness_results$triple_diff <- list(
      model = m_triple,
      net_triple_coef = net_triple,
      net_triple_se = se_triple,
      n_obs = nobs(m_triple),
      description = "Triple-diff: RN vs Green as outcome difference × network fuel exposure"
    )
  }
} else {
  cat("  WARNING: green_share not in dept_panel. Skipping triple-diff.\n")
  robustness_results$triple_diff <- NULL
}


## ============================================================================
## v5 NEW: 29. PRE-TREND-ADJUSTED SPECIFICATION (WS7)
## ============================================================================

cat("\n=== 29. Pre-Trend-Adjusted Specification (v5 WS7) ===\n")

## Add exposure × pre-trend interaction to absorb the mild pre-trend (joint F=0.03)
## Use linear pre-trend from the event study coefficients

## Compute linear pre-trend: slope of network coefficients over pre-treatment elections
es_data <- readRDS(file.path(DATA_DIR, "event_study_data.rds"))
pre_net <- es_data$network %>% filter(year < 2014)

if (nrow(pre_net) > 2) {
  pre_trend_fit <- lm(estimate ~ year, data = pre_net)
  pre_trend_slope <- coef(pre_trend_fit)["year"]
  cat(sprintf("  Pre-trend slope: %.6f per year\n", pre_trend_slope))

  ## Add trend control: net_fuel_std × (year - 2012)
  dept_panel_trend <- dept_panel %>%
    mutate(
      year_centered = year - 2012,
      net_trend = network_fuel_std * year_centered
    )

  ## Model with pre-trend control
  m_detrended <- feols(rn_share ~ own_fuel_std:post_carbon +
                          network_fuel_std:post_carbon +
                          net_trend |
                          dept_code + id_election,
                        data = dept_panel_trend,
                        cluster = ~dept_code,
                        weights = ~total_registered)

  cat("  Pre-trend-adjusted results (dept-level):\n")
  cat(sprintf("    Own x Post:     %.4f (%.4f)\n",
              get_coef(m_detrended, "own_fuel_std"),
              get_se(m_detrended, "own_fuel_std")))
  cat(sprintf("    Network x Post: %.4f (%.4f)\n",
              get_coef(m_detrended, "network_fuel_std"),
              get_se(m_detrended, "network_fuel_std")))
  cat(sprintf("    Net × trend:    %.4f (%.4f)\n",
              get_coef(m_detrended, "net_trend"),
              get_se(m_detrended, "net_trend")))

  robustness_results$pre_trend_adjusted <- list(
    model = m_detrended,
    coef_network = get_coef(m_detrended, "network_fuel_std"),
    se_network = get_se(m_detrended, "network_fuel_std"),
    pre_trend_slope = pre_trend_slope,
    description = "Pre-trend-adjusted: add network_fuel_std × (year - 2012) linear trend"
  )
} else {
  cat("  WARNING: Insufficient pre-treatment data for trend estimation.\n")
  robustness_results$pre_trend_adjusted <- NULL
}


## ============================================================================
## v5 NEW: 30. RAMBACHAN-ROTH WITH BOTH APPROACHES (WS7)
## ============================================================================

cat("\n=== 30. Rambachan-Roth with Both Approaches (v5 WS7) ===\n")

## We already have relative magnitudes (section 19). Add the smoothness (M-bar) approach
## applied to the FIRST post-period (2014) as well as an average across all post-periods.

if (!is.null(robustness_results$honest_did$relative_magnitudes)) {
  ## Compute robust confidence sets for FIRST post-period
  honest_first <- tryCatch({
    HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma_net,
      numPrePeriods = numPrePeriods,
      numPostPeriods = numPostPeriods,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = c(1, rep(0, numPostPeriods - 1))  # Focus on first post-period (2014)
    )
  }, error = function(e) {
    cat("  HonestDiD first post-period error:", e$message, "\n")
    NULL
  })

  if (!is.null(honest_first)) {
    cat("\n  HonestDiD (Relative Magnitudes, FIRST post-period = 2014):\n")
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
    HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma_net,
      numPrePeriods = numPrePeriods,
      numPostPeriods = numPostPeriods,
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = rep(1 / numPostPeriods, numPostPeriods)  # Average across all post-periods
    )
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
}


## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS (v5)
## ============================================================================

cat("\n\nSaving robustness results...\n")
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n", strrep("=", 70), "\n")
cat("ROBUSTNESS CHECKS COMPLETE (v5: all 30 sections)\n")
cat(strrep("=", 70), "\n")
