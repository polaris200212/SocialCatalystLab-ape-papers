# =============================================================================
# 03_main_analysis.R — Traditional county-level DiD (replicating Kline & Moretti)
# =============================================================================
# Estimates TWFE DiD of TVA effects on agricultural employment share,
# manufacturing share, and Ag->Mfg transition rates using the county-year
# panel. This provides the traditional econometric benchmark against which
# the transformer-based DiD is compared.
#
# Treatment: TVA county (based on 1920 residence)
# Post: 1933 (TVA established). In our data, 1940 is the only post-period.
# Pre-period: 1920 and 1930 (two pre-treatment periods)
#
# Input:  ../data/analysis_county.rds
# Output: ../data/main_results.rds        (coefficient table)
#         ../data/model_objects.rds        (fixest model objects)
#         ../data/event_study_results.rds  (event study coefficients)
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load analysis data
# =============================================================================
log_msg("Loading analysis data...")

analysis_county <- readRDS(file.path(DATA_DIR, "analysis_county.rds"))

# Verify panel structure
log_msg(sprintf("  Panel: %s obs, %d counties, %d years",
                fmt(nrow(analysis_county)),
                length(unique(analysis_county$county_id)),
                length(unique(analysis_county$year))))

# =============================================================================
# 2. Primary TWFE specification
# =============================================================================
# Model: Y_{ct} = alpha_c + gamma_t + beta * (TVA_c x Post_t) + epsilon_{ct}
#
# Y = {ag_share, mfg_share, transition_ag_to_mfg, transition_ag_to_mfg_cond}
# TVA_c = 1 if county in TVA service area
# Post_t = 1 if year >= 1940 (first post-TVA observation)
# Clustered SEs at state level (following Kline & Moretti 2014)
# =============================================================================
log_msg("Running primary TWFE regressions...")

# --- Agricultural share ---
m1_ag <- feols(
  ag_share ~ tva_post | county_id + year,
  data = analysis_county,
  cluster = ~statefip_1920
)

# --- Manufacturing share ---
m1_mfg <- feols(
  mfg_share ~ tva_post | county_id + year,
  data = analysis_county,
  cluster = ~statefip_1920
)

# --- Ag-to-Mfg transition rate (unconditional) ---
# Only available for 1930 and 1940 (requires prior-year occupation)
trans_data <- analysis_county[year %in% c(1930, 1940)]
trans_data[, post_trans := as.integer(year == 1940)]
trans_data[, tva_post_trans := tva * post_trans]

m1_trans <- feols(
  transition_ag_to_mfg ~ tva_post_trans | county_id + year,
  data = trans_data,
  cluster = ~statefip_1920
)

# --- Ag-to-Mfg transition rate (conditional on Ag in prior year) ---
m1_trans_cond <- feols(
  transition_ag_to_mfg_cond ~ tva_post_trans | county_id + year,
  data = trans_data[!is.na(transition_ag_to_mfg_cond)],
  cluster = ~statefip_1920
)

# --- Occupation change rate ---
m1_occ <- feols(
  occ_change_rate ~ tva_post_trans | county_id + year,
  data = trans_data,
  cluster = ~statefip_1920
)

# --- Farm exit rate ---
m1_farm <- feols(
  farm_exit_rate ~ tva_post_trans | county_id + year,
  data = trans_data,
  cluster = ~statefip_1920
)

# Print results
log_msg("\n=== Primary TWFE Results ===")
cat("\n--- Agricultural Share ---\n")
summary(m1_ag)
cat("\n--- Manufacturing Share ---\n")
summary(m1_mfg)
cat("\n--- Ag-to-Mfg Transition (Unconditional) ---\n")
summary(m1_trans)
cat("\n--- Ag-to-Mfg Transition (Conditional on Ag) ---\n")
summary(m1_trans_cond)
cat("\n--- Occupation Change Rate ---\n")
summary(m1_occ)
cat("\n--- Farm Exit Rate ---\n")
summary(m1_farm)

# =============================================================================
# 3. Event study specification (using year interactions)
# =============================================================================
# With 3 periods (1920, 1930, 1940), we estimate:
#   Y_{ct} = alpha_c + gamma_t + delta_1930 * (TVA_c x 1{t=1930})
#            + delta_1940 * (TVA_c x 1{t=1940}) + epsilon_{ct}
#
# Reference period: 1920 (normalized to zero)
# delta_1930 = pre-trend test (should be ~0 if parallel trends hold)
# delta_1940 = treatment effect
# =============================================================================
log_msg("Running event study specifications...")

# Create year interactions
analysis_county[, tva_1930 := tva * as.integer(year == 1930)]
analysis_county[, tva_1940 := tva * as.integer(year == 1940)]

# Agricultural share event study
es_ag <- feols(
  ag_share ~ tva_1930 + tva_1940 | county_id + year,
  data = analysis_county,
  cluster = ~statefip_1920
)

# Manufacturing share event study
es_mfg <- feols(
  mfg_share ~ tva_1930 + tva_1940 | county_id + year,
  data = analysis_county,
  cluster = ~statefip_1920
)

log_msg("\n=== Event Study Results ===")
cat("\n--- Ag Share Event Study ---\n")
summary(es_ag)
cat("\n--- Mfg Share Event Study ---\n")
summary(es_mfg)

# Extract event study coefficients for plotting
extract_es <- function(model, outcome_name) {
  coefs <- coeftable(model)
  data.table(
    outcome = outcome_name,
    year = c(1920, 1930, 1940),
    coef = c(0, coefs[, 1]),
    se   = c(0, coefs[, 2]),
    ci_lower = c(0, coefs[, 1] - 1.96 * coefs[, 2]),
    ci_upper = c(0, coefs[, 1] + 1.96 * coefs[, 2])
  )
}

event_study_results <- rbindlist(list(
  extract_es(es_ag, "Agriculture Share"),
  extract_es(es_mfg, "Manufacturing Share")
))

# =============================================================================
# 4. Weighted regressions (population weights)
# =============================================================================
log_msg("Running population-weighted regressions...")

# Weight by county population (number of linked individuals)
m2_ag <- feols(
  ag_share ~ tva_post | county_id + year,
  data = analysis_county,
  weights = ~n_individuals,
  cluster = ~statefip_1920
)

m2_mfg <- feols(
  mfg_share ~ tva_post | county_id + year,
  data = analysis_county,
  weights = ~n_individuals,
  cluster = ~statefip_1920
)

log_msg("\n=== Population-Weighted Results ===")
cat("\n--- Ag Share (Weighted) ---\n")
summary(m2_ag)
cat("\n--- Mfg Share (Weighted) ---\n")
summary(m2_mfg)

# =============================================================================
# 5. Regressions with baseline controls
# =============================================================================
log_msg("Running specifications with baseline controls...")

# Merge 1920 baseline characteristics into the panel
baseline_chars <- analysis_county[year == 1920,
  .(county_id, base_ag_share = ag_share, base_pct_white = pct_white,
    base_mean_age = mean_age, base_pct_urban = pct_urban,
    base_pct_literate = pct_literate, base_pct_farm = pct_farm)]

analysis_controls <- merge(analysis_county, baseline_chars,
                            by = "county_id", all.x = TRUE)

# Create interaction of baseline controls with year
analysis_controls[, base_ag_x_year := base_ag_share * year]
analysis_controls[, base_white_x_year := base_pct_white * year]
analysis_controls[, base_urban_x_year := base_pct_urban * year]

# With baseline controls interacted with year
m3_ag <- feols(
  ag_share ~ tva_post + base_ag_x_year + base_white_x_year + base_urban_x_year |
    county_id + year,
  data = analysis_controls,
  cluster = ~statefip_1920
)

m3_mfg <- feols(
  mfg_share ~ tva_post + base_ag_x_year + base_white_x_year + base_urban_x_year |
    county_id + year,
  data = analysis_controls,
  cluster = ~statefip_1920
)

log_msg("\n=== Results with Baseline Controls ===")
cat("\n--- Ag Share (with controls) ---\n")
summary(m3_ag)
cat("\n--- Mfg Share (with controls) ---\n")
summary(m3_mfg)

# =============================================================================
# 6. Compile main results table
# =============================================================================
log_msg("Compiling main results table...")

extract_results <- function(model, outcome, specification, n_counties = NULL) {
  ct <- coeftable(model)
  # Get the treatment coefficient (tva_post or tva_post_trans)
  treat_row <- grep("tva_post", rownames(ct))
  if (length(treat_row) == 0) return(NULL)
  treat_row <- treat_row[1]

  data.table(
    outcome = outcome,
    specification = specification,
    coef = ct[treat_row, 1],
    se = ct[treat_row, 2],
    t_stat = ct[treat_row, 3],
    p_value = ct[treat_row, 4],
    n_obs = model$nobs,
    n_counties = ifelse(is.null(n_counties), model$fixef_sizes[1], n_counties),
    r2_within = fitstat(model, "r2")$r2
  )
}

main_results <- rbindlist(list(
  # Panel A: Agricultural share
  extract_results(m1_ag, "Ag Share", "TWFE"),
  extract_results(m2_ag, "Ag Share", "TWFE (weighted)"),
  extract_results(m3_ag, "Ag Share", "TWFE + controls"),

  # Panel B: Manufacturing share
  extract_results(m1_mfg, "Mfg Share", "TWFE"),
  extract_results(m2_mfg, "Mfg Share", "TWFE (weighted)"),
  extract_results(m3_mfg, "Mfg Share", "TWFE + controls"),

  # Panel C: Transition rates
  extract_results(m1_trans, "Ag->Mfg Transition", "TWFE"),
  extract_results(m1_trans_cond, "Ag->Mfg Transition (cond)", "TWFE"),
  extract_results(m1_occ, "Occ Change Rate", "TWFE"),
  extract_results(m1_farm, "Farm Exit Rate", "TWFE")
), fill = TRUE)

log_msg("\n=== Main Results Summary ===")
print(main_results[, .(outcome, specification,
                         coef = round(coef, 4),
                         se = round(se, 4),
                         p = round(p_value, 3),
                         n_obs)])

# =============================================================================
# 7. Save outputs
# =============================================================================
log_msg("Saving results...")

saveRDS(main_results, file.path(DATA_DIR, "main_results.rds"))
saveRDS(event_study_results, file.path(DATA_DIR, "event_study_results.rds"))

# Save model objects (for etable and further analysis)
model_objects <- list(
  ag_twfe = m1_ag,
  mfg_twfe = m1_mfg,
  trans_twfe = m1_trans,
  trans_cond_twfe = m1_trans_cond,
  occ_twfe = m1_occ,
  farm_twfe = m1_farm,
  ag_weighted = m2_ag,
  mfg_weighted = m2_mfg,
  ag_controls = m3_ag,
  mfg_controls = m3_mfg,
  ag_es = es_ag,
  mfg_es = es_mfg
)
saveRDS(model_objects, file.path(DATA_DIR, "model_objects.rds"))

log_msg("Main analysis complete.")
