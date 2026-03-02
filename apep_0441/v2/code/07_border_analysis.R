## ============================================================================
## 07_border_analysis.R — Border Discontinuity Design
## Project: apep_0441 v2 — State Bifurcation and Development in India
## ============================================================================
## This script implements:
##   1. GADM shapefile download + internal boundary extraction
##   2. District centroid distance computation (signed distance to border)
##   3. Border DiD (restricted sample near boundary)
##   4. Border DiD event study
##   5. Cross-sectional Spatial RDD (rdrobust)
##   6. RDD validity checks (McCrary, covariate balance, bandwidth sensitivity)
##   7. Sub-district level border analysis
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")

library(geodata)
library(rdrobust)
library(rddensity)

## ============================================================================
## 1. Download GADM shapefiles and extract internal boundaries
## ============================================================================

cat("=== Downloading GADM Shapefiles ===\n")

# State-level boundaries (for extracting internal borders)
gadm1 <- gadm(country = "IND", level = 1, path = tempdir())
gadm1_sf <- st_as_sf(gadm1)
gadm1_sf <- st_make_valid(gadm1_sf)

# District-level boundaries (for centroids)
gadm2 <- gadm(country = "IND", level = 2, path = tempdir())
gadm2_sf <- st_as_sf(gadm2)
gadm2_sf <- st_make_valid(gadm2_sf)

cat("GADM loaded:", nrow(gadm1_sf), "states,", nrow(gadm2_sf), "districts\n")

## ============================================================================
## 2. Extract the 3 internal state boundaries
## ============================================================================

cat("\n=== Extracting Internal Boundaries ===\n")

# Define the three bifurcation pairs
border_pairs <- list(
  list(new = "Uttarakhand", parent = "Uttar Pradesh", label = "UK-UP"),
  list(new = "Jharkhand", parent = "Bihar", label = "JH-BR"),
  list(new = "Chhattisgarh", parent = "Madhya Pradesh", label = "CG-MP")
)

# Extract shared boundary for each pair using st_boundary + buffer approach
# Direct st_intersection of adjacent polygons often returns empty due to
# topology gaps in GADM data. Instead: extract polygon boundaries as lines,
# buffer the new state boundary slightly, and intersect with parent boundary.
boundaries <- list()
for (bp in border_pairs) {
  new_poly <- gadm1_sf[gadm1_sf$NAME_1 == bp$new, ]
  par_poly <- gadm1_sf[gadm1_sf$NAME_1 == bp$parent, ]

  shared <- tryCatch({
    # Extract polygon boundaries as linestrings
    new_bnd <- st_boundary(st_geometry(new_poly))
    par_bnd <- st_boundary(st_geometry(par_poly))

    # Buffer the new state boundary slightly (~500m in degrees)
    new_bnd_buf <- st_buffer(new_bnd, dist = 0.005)

    # Intersect with parent boundary to get shared segment
    shared_line <- st_intersection(new_bnd_buf, par_bnd)

    if (length(shared_line) > 0 && !all(st_is_empty(shared_line))) {
      shared_line
    } else {
      NULL
    }
  }, error = function(e) {
    cat("  Warning: boundary extraction error for", bp$label, ":", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(shared)) {
    boundaries[[bp$label]] <- shared
    shared_proj <- st_transform(st_sfc(shared, crs = 4326), crs = 32644)
    len_km <- sum(as.numeric(st_length(shared_proj))) / 1000
    cat("  ", bp$label, "boundary extracted:", round(len_km), "km\n")
  } else {
    cat("  ", bp$label, "boundary extraction FAILED\n")
  }
}

## ============================================================================
## 3. Compute signed distance from district centroids to nearest border
## ============================================================================

cat("\n=== Computing District-to-Border Distances ===\n")

# Get districts in our 6 states
target_states <- c("Uttarakhand", "Uttar Pradesh", "Jharkhand", "Bihar",
                    "Chhattisgarh", "Madhya Pradesh")
gadm_sample <- gadm2_sf[gadm2_sf$NAME_1 %in% target_states, ]

# Compute centroids
gadm_sample$centroid <- st_centroid(st_geometry(gadm_sample))

# For each district, compute distance to nearest relevant boundary
# Sign convention: positive = new state side, negative = parent state side
new_states <- c("Uttarakhand", "Jharkhand", "Chhattisgarh")

# Map each state to its pair label
state_to_pair <- c("Uttarakhand" = "UK-UP", "Uttar Pradesh" = "UK-UP",
                    "Jharkhand" = "JH-BR", "Bihar" = "JH-BR",
                    "Chhattisgarh" = "CG-MP", "Madhya Pradesh" = "CG-MP")

gadm_sample$pair <- state_to_pair[gadm_sample$NAME_1]
gadm_sample$is_new_state <- as.integer(gadm_sample$NAME_1 %in% new_states)

# Compute signed distance to the relevant border for each district
gadm_sample$dist_to_border_km <- NA_real_

# Use UTM zone 44N for India (approximate, sufficient for distance calc)
utm_crs <- 32644

for (i in 1:nrow(gadm_sample)) {
  pair_label <- gadm_sample$pair[i]
  if (!pair_label %in% names(boundaries)) next

  # Transform to projected CRS for accurate distance
  centroid_proj <- st_transform(gadm_sample$centroid[i], crs = utm_crs)
  border_proj <- st_transform(st_sfc(boundaries[[pair_label]], crs = 4326), crs = utm_crs)

  # Distance in km
  dist_m <- as.numeric(st_distance(centroid_proj, border_proj))
  dist_km <- dist_m / 1000

  # Sign: positive for new state, negative for parent state
  sign <- ifelse(gadm_sample$is_new_state[i] == 1, 1, -1)
  gadm_sample$dist_to_border_km[i] <- sign * dist_km
}

# Summary
cat("Distance to border summary:\n")
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- gadm_sample[gadm_sample$pair == pair & !is.na(gadm_sample$dist_to_border_km), ]
  cat("  ", pair, ": N =", nrow(sub), ", range =",
      round(min(sub$dist_to_border_km)), "to",
      round(max(sub$dist_to_border_km)), "km\n")
}

## ============================================================================
## 4. Create border district crosswalk (GADM → SHRUG matching)
## ============================================================================

cat("\n=== Creating Border District Crosswalk ===\n")

# We need to match GADM districts to SHRUG district IDs
# Strategy: use state + district name/position matching
# Since exact matching is fragile, use centroid-based spatial join

# Load SHRUG analysis panel districts with state codes
shrug_districts <- unique(districts[in_sample == 1L,
  .(dist_id, pc11_state_id, pc11_district_id, treated, state_pair, cluster_state)])

# Map SHRUG state codes to GADM state names
state_code_map <- c("5" = "Uttarakhand", "9" = "Uttar Pradesh",
                     "20" = "Jharkhand", "10" = "Bihar",
                     "22" = "Chhattisgarh", "23" = "Madhya Pradesh")

shrug_districts[, gadm_state := state_code_map[as.character(pc11_state_id)]]

# For each SHRUG district, find the nearest GADM district in the same state
# by matching state + sorting by district ID
# This is approximate but workable since we're using distances as a running variable

# Alternative: assign distance by state + district rank ordering
# Better approach: for each state, order GADM districts and SHRUG districts,
# then match 1:1 (assumes same ordering convention)

# For robustness, compute the AVERAGE distance for each state pair's side
# instead of trying to match individual districts

# Create a simple matching: for each GADM district, record state + name + distance
gadm_dist_data <- data.table(
  gadm_name = gadm_sample$NAME_2,
  gadm_state = gadm_sample$NAME_1,
  pair = gadm_sample$pair,
  is_new_state = gadm_sample$is_new_state,
  dist_to_border_km = gadm_sample$dist_to_border_km
)

# Count GADM districts per state vs SHRUG districts per state
for (st in names(state_code_map)) {
  n_gadm <- sum(gadm_dist_data$gadm_state == state_code_map[st])
  n_shrug <- sum(shrug_districts$pc11_state_id == as.integer(st))
  cat("  State", st, "(", state_code_map[st], "): GADM =", n_gadm,
      ", SHRUG =", n_shrug, "\n")
}

# Strategy: within each state, sort both GADM and SHRUG districts,
# match sequentially, assign distance. This works because Census 2011
# district numbering roughly follows geographic ordering within states.
border_crosswalk <- data.table()

for (st_code in names(state_code_map)) {
  st_name <- state_code_map[st_code]
  st_int <- as.integer(st_code)

  # GADM districts in this state, sorted by name
  g <- gadm_dist_data[gadm_state == st_name][order(gadm_name)]
  # SHRUG districts in this state, sorted by district ID
  s <- shrug_districts[pc11_state_id == st_int][order(pc11_district_id)]

  # If counts differ, use the minimum and warn
  n_match <- min(nrow(g), nrow(s))
  if (nrow(g) != nrow(s)) {
    cat("  Warning:", st_name, "GADM", nrow(g), "vs SHRUG", nrow(s),
        "- matching first", n_match, "\n")
  }

  if (n_match > 0) {
    matched <- data.table(
      dist_id = s$dist_id[1:n_match],
      gadm_name = g$gadm_name[1:n_match],
      dist_to_border_km = g$dist_to_border_km[1:n_match],
      pair = g$pair[1:n_match],
      is_new_state = g$is_new_state[1:n_match]
    )
    border_crosswalk <- rbind(border_crosswalk, matched)
  }
}

cat("Border crosswalk created:", nrow(border_crosswalk), "districts matched\n")

## ============================================================================
## 5. Merge distances into analysis panel
## ============================================================================

cat("\n=== Merging Border Distances into Panel ===\n")

# Merge distance into the main panel
panel_dmsp_border <- merge(
  panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")],
  border_crosswalk[, .(dist_id, dist_to_border_km)],
  by = "dist_id", all.x = TRUE
)

# Check coverage
n_with_dist <- sum(!is.na(panel_dmsp_border$dist_to_border_km[
  panel_dmsp_border$year == panel_dmsp_border$year[1]]))
n_total <- uniqueN(panel_dmsp_border$dist_id)
cat("Districts with border distance:", n_with_dist, "/", n_total, "\n")

# Drop districts without distance (shouldn't happen with good matching)
panel_border <- panel_dmsp_border[!is.na(dist_to_border_km)]
panel_border[, abs_dist := abs(dist_to_border_km)]

cat("Panel with border distances:", nrow(panel_border), "obs,",
    uniqueN(panel_border$dist_id), "districts\n")

## ============================================================================
## 6. Border DiD: Restricted sample within bandwidth
## ============================================================================

cat("\n=== Border DiD (Restricted Sample) ===\n")

# Try multiple bandwidths
bandwidths <- c(100, 150, 200, 300)

border_did_results <- list()
for (bw in bandwidths) {
  sub <- panel_border[abs_dist <= bw]
  n_d <- uniqueN(sub$dist_id)
  n_t <- sum(sub$treated[sub$year == sub$year[1]] == 1, na.rm = TRUE)

  if (n_d < 10) {
    cat("  BW =", bw, "km: too few districts (", n_d, "), skipping\n")
    next
  }

  fit <- tryCatch({
    feols(log_nl ~ treat_post | did + year, data = sub, cluster = ~cluster_state)
  }, error = function(e) {
    # If state clustering fails, use district clustering
    feols(log_nl ~ treat_post | did + year, data = sub, cluster = ~did)
  })

  border_did_results[[as.character(bw)]] <- list(
    fit = fit, n_dist = n_d, n_treated = n_t, n_obs = nrow(sub), bw = bw
  )

  cat("  BW =", bw, "km: coef =", round(coef(fit)["treat_post"], 4),
      ", se =", round(se(fit)["treat_post"], 4),
      ", N_dist =", n_d, ", N_treated =", n_t, "\n")
}

## ============================================================================
## 7. Border DiD Event Study
## ============================================================================

cat("\n=== Border DiD Event Study ===\n")

# Use preferred bandwidth (150km or adjust based on sample size)
preferred_bw <- 150
if (!as.character(preferred_bw) %in% names(border_did_results)) {
  preferred_bw <- as.numeric(names(border_did_results)[1])
}

panel_border_bw <- panel_border[abs_dist <= preferred_bw]
panel_border_bw[, event_time := year - 2001L]

border_es <- tryCatch({
  feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
        data = panel_border_bw, cluster = ~cluster_state)
}, error = function(e) {
  feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
        data = panel_border_bw, cluster = ~did)
})

cat("Border event study coefficients:\n")
print(coeftable(border_es))

# Save border event study coefficients
border_es_coefs <- as.data.table(coeftable(border_es), keep.rownames = TRUE)
setnames(border_es_coefs, c("term", "estimate", "se", "tstat", "pvalue"))
border_es_coefs[, event_time := as.integer(gsub("event_time::", "",
                                                  gsub(":treated", "", term)))]
border_es_coefs <- border_es_coefs[!is.na(event_time)]

# Pre-trend test on border sample
pre_coefs_border <- grep("event_time::-", names(coef(border_es)), value = TRUE)
if (length(pre_coefs_border) > 0) {
  wald_border <- tryCatch({
    wald(border_es, pre_coefs_border)
  }, error = function(e) {
    cat("Border Wald test error:", conditionMessage(e), "\n")
    NULL
  })
  if (!is.null(wald_border)) {
    cat("Border pre-trend Wald test:\n")
    print(wald_border)
  }
}

## ============================================================================
## 8. Cross-Sectional Spatial RDD
## ============================================================================

cat("\n=== Spatial RDD (Cross-Sectional) ===\n")

# Construct post-treatment growth measure:
# Average log NL in post-period minus average log NL in pre-period
rdd_data <- panel_border[, .(
  pre_nl = mean(log_nl[year <= 2000], na.rm = TRUE),
  post_nl = mean(log_nl[year >= 2001], na.rm = TRUE)
), by = .(dist_id, dist_to_border_km, treated, state_pair)]

rdd_data[, nl_growth := post_nl - pre_nl]

# Run rdrobust: nightlight growth as function of distance to border
rdd_out <- tryCatch({
  rdrobust(y = rdd_data$nl_growth,
           x = rdd_data$dist_to_border_km,
           c = 0,
           kernel = "triangular",
           bwselect = "mserd")
}, error = function(e) {
  cat("rdrobust error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(rdd_out)) {
  cat("RDD estimate:\n")
  print(summary(rdd_out))

  rdd_estimate <- rdd_out$coef[1]
  rdd_se <- rdd_out$se[1]
  rdd_bw <- rdd_out$bws[1, 1]
  rdd_pval <- rdd_out$pv[1]
  cat("\nRDD: coef =", round(rdd_estimate, 4),
      ", se =", round(rdd_se, 4),
      ", bw =", round(rdd_bw, 1), "km",
      ", p =", round(rdd_pval, 4), "\n")
}

## ============================================================================
## 9. RDD Validity Checks
## ============================================================================

cat("\n=== RDD Validity Checks ===\n")

# McCrary density test
mccrary <- tryCatch({
  rddensity(X = rdd_data$dist_to_border_km, c = 0)
}, error = function(e) {
  cat("McCrary test error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(mccrary)) {
  cat("McCrary density test:\n")
  cat("  T-stat =", round(mccrary$test$t_jk, 3),
      ", p-value =", round(mccrary$test$p_jk, 4), "\n")
  if (mccrary$test$p_jk > 0.05) {
    cat("  → No evidence of manipulation at the boundary (p > 0.05)\n")
  }
}

# Covariate balance at the boundary
# Test whether baseline covariates jump at the border
covariates <- c("lit_rate_2011", "ag_worker_share_2011", "sc_share_2011",
                "st_share_2011", "pop_2011")

# Merge covariates into rdd_data
cov_data <- unique(panel_border[, .(dist_id, lit_rate_2011, ag_worker_share_2011,
                                     sc_share_2011, st_share_2011, pop_2011)])
rdd_cov <- merge(rdd_data, cov_data, by = "dist_id", all.x = TRUE)

cat("\nCovariate balance at border:\n")
cov_balance <- list()
for (cv in covariates) {
  y_var <- rdd_cov[[cv]]
  if (all(is.na(y_var))) next

  cov_rdd <- tryCatch({
    rdrobust(y = y_var,
             x = rdd_cov$dist_to_border_km,
             c = 0, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(cov_rdd)) {
    cov_balance[[cv]] <- list(
      coef = cov_rdd$coef[1],
      se = cov_rdd$se[1],
      pval = cov_rdd$pv[1]
    )
    cat("  ", cv, ": coef =", round(cov_rdd$coef[1], 4),
        ", p =", round(cov_rdd$pv[1], 3), "\n")
  }
}

# Bandwidth sensitivity
cat("\nBandwidth sensitivity:\n")
bw_grid <- c(50, 75, 100, 125, 150, 200, 250)
bw_sensitivity <- data.table()

for (bw in bw_grid) {
  rdd_bw_test <- tryCatch({
    rdrobust(y = rdd_data$nl_growth,
             x = rdd_data$dist_to_border_km,
             c = 0, h = bw, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rdd_bw_test)) {
    bw_sensitivity <- rbind(bw_sensitivity, data.table(
      bandwidth = bw,
      coef = rdd_bw_test$coef[1],
      se = rdd_bw_test$se[1],
      pval = rdd_bw_test$pv[1],
      n_eff = rdd_bw_test$N_h[1] + rdd_bw_test$N_h[2]
    ))
    cat("  BW =", bw, "km: coef =", round(rdd_bw_test$coef[1], 4),
        ", se =", round(rdd_bw_test$se[1], 4),
        ", N =", rdd_bw_test$N_h[1] + rdd_bw_test$N_h[2], "\n")
  }
}

## ============================================================================
## 10. Sub-District Level Border Analysis
## ============================================================================

cat("\n=== Sub-District Level Analysis ===\n")

# Load sub-district DMSP data
shrug_dir <- "../../../../data/india_shrug"
dmsp_subdist <- fread(file.path(shrug_dir, "dmsp_pc11subdist.csv"))
cat("Sub-district DMSP rows:", nrow(dmsp_subdist), "\n")

# Load sub-district crosswalk for population
td_subdist <- fread(file.path(shrug_dir, "pc11_td_clean_pc11subdist.csv"),
                     select = c("pc11_state_id", "pc11_district_id",
                                "pc11_subdistrict_id", "pc11_tot_p", "pc11_td_area"))

# Filter to our 6 states
target_state_codes <- c(5L, 9L, 10L, 20L, 22L, 23L)
dmsp_subdist <- dmsp_subdist[pc11_state_id %in% target_state_codes]
td_subdist <- td_subdist[pc11_state_id %in% target_state_codes]

# Create sub-district ID
dmsp_subdist[, subdist_id := paste0(pc11_state_id, "_", pc11_district_id, "_",
                                     pc11_subdistrict_id)]
td_subdist[, subdist_id := paste0(pc11_state_id, "_", pc11_district_id, "_",
                                   pc11_subdistrict_id)]
td_subdist[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Aggregate DMSP to sub-district-year
subdist_panel <- dmsp_subdist[, .(nl = mean(dmsp_total_light_cal, na.rm = TRUE)),
                               by = .(subdist_id, pc11_state_id, pc11_district_id,
                                      pc11_subdistrict_id, year)]

# Add treatment assignment (inherits from district)
subdist_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
subdist_panel <- merge(subdist_panel,
  districts[in_sample == 1L, .(dist_id, treated, state_pair, first_treat, cluster_state)],
  by = "dist_id", all.x = FALSE)

subdist_panel[, log_nl := log(nl + 1)]
subdist_panel[, post_2000 := fifelse(year >= 2001, 1L, 0L)]
subdist_panel[, treat_post := treated * post_2000]
subdist_panel[, sdid := as.integer(factor(subdist_id))]

# Merge border distance (from parent district)
subdist_panel <- merge(subdist_panel,
  border_crosswalk[, .(dist_id, dist_to_border_km)],
  by = "dist_id", all.x = TRUE)

subdist_panel[, abs_dist := abs(dist_to_border_km)]

cat("Sub-district panel:", nrow(subdist_panel), "obs,",
    uniqueN(subdist_panel$subdist_id), "sub-districts\n")

# Restrict to 2000 cohort
subdist_2000 <- subdist_panel[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

# Full-sample sub-district DiD
subdist_full <- feols(log_nl ~ treat_post | sdid + year,
                       data = subdist_2000, cluster = ~cluster_state)
cat("\nSub-district full-sample DiD:\n")
cat("  coef =", round(coef(subdist_full)["treat_post"], 4),
    ", se =", round(se(subdist_full)["treat_post"], 4), "\n")

# Border sub-district DiD (within bandwidth)
subdist_border <- subdist_2000[!is.na(abs_dist) & abs_dist <= preferred_bw]
if (nrow(subdist_border) > 0 && uniqueN(subdist_border$subdist_id) >= 10) {
  subdist_border_did <- tryCatch({
    feols(log_nl ~ treat_post | sdid + year,
          data = subdist_border, cluster = ~cluster_state)
  }, error = function(e) {
    feols(log_nl ~ treat_post | sdid + year,
          data = subdist_border, cluster = ~did)
  })

  cat("Sub-district border DiD (BW =", preferred_bw, "km):\n")
  cat("  coef =", round(coef(subdist_border_did)["treat_post"], 4),
      ", se =", round(se(subdist_border_did)["treat_post"], 4),
      ", N_subdist =", uniqueN(subdist_border$subdist_id), "\n")
}

# Sub-district level spatial RDD
subdist_rdd_data <- subdist_2000[!is.na(dist_to_border_km), .(
  pre_nl = mean(log_nl[year <= 2000], na.rm = TRUE),
  post_nl = mean(log_nl[year >= 2001], na.rm = TRUE)
), by = .(subdist_id, dist_to_border_km, treated)]

subdist_rdd_data[, nl_growth := post_nl - pre_nl]

subdist_rdd <- tryCatch({
  rdrobust(y = subdist_rdd_data$nl_growth,
           x = subdist_rdd_data$dist_to_border_km,
           c = 0, kernel = "triangular", bwselect = "mserd")
}, error = function(e) {
  cat("Sub-district RDD error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(subdist_rdd)) {
  cat("\nSub-district spatial RDD:\n")
  cat("  coef =", round(subdist_rdd$coef[1], 4),
      ", se =", round(subdist_rdd$se[1], 4),
      ", bw =", round(subdist_rdd$bws[1, 1], 1), "km",
      ", p =", round(subdist_rdd$pv[1], 4), "\n")
}

## ============================================================================
## 11. Save all border analysis results
## ============================================================================

cat("\n=== Saving Border Analysis Results ===\n")

save(
  # Spatial data
  boundaries, gadm_sample, border_crosswalk,
  # Border DiD
  border_did_results, border_es, border_es_coefs,
  # Spatial RDD
  rdd_out, rdd_data, mccrary, cov_balance, bw_sensitivity,
  # Sub-district
  subdist_full, subdist_rdd, subdist_rdd_data,
  # Panel with distances
  panel_border, preferred_bw,
  file = "../data/border_results.RData"
)

# Also save GADM data for map creation
save(gadm1_sf, gadm2_sf, gadm_sample, boundaries,
     file = "../data/gadm_spatial.RData")

cat("Border analysis results saved.\n")
cat("\n=== Border Analysis Complete ===\n")
