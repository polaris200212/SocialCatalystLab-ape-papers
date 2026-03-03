# =============================================================================
# 02_clean_data.R — Construct analysis datasets and balance tables
# =============================================================================
# Takes the raw individual and county panels from 01_fetch_data.R, applies
# sample restrictions, constructs additional variables, and creates balance
# tables for the pre-treatment period (1920).
#
# Input:  ../data/individual_panel.rds
#         ../data/county_year_panel.rds
#         ../data/county_tva.rds
# Output: ../data/analysis_county.rds       (county panel for DiD)
#         ../data/analysis_individual.rds    (individual panel, restricted)
#         ../data/balance_table_data.rds     (balance table at 1920 baseline)
#         ../data/bordering_counties.rds     (bordering non-TVA control)
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load data
# =============================================================================
log_msg("Loading data from 01_fetch_data.R...")

df <- readRDS(file.path(DATA_DIR, "individual_panel.rds"))
county_panel <- readRDS(file.path(DATA_DIR, "county_year_panel.rds"))
county_tva <- readRDS(file.path(DATA_DIR, "county_tva.rds"))

log_msg(sprintf("  Individuals: %s", fmt(nrow(df))))
log_msg(sprintf("  County-year obs: %s", fmt(nrow(county_panel))))

# =============================================================================
# 2. Sample restrictions for county-level analysis
# =============================================================================
log_msg("Applying sample restrictions for county-level analysis...")

# Restrict to counties with at least 30 individuals per year for stable shares
min_county_n <- 30L

county_counts <- county_panel[, .(min_n = min(n_individuals)),
                               by = county_id]
valid_counties <- county_counts[min_n >= min_county_n]$county_id

analysis_county <- county_panel[county_id %in% valid_counties]

log_msg(sprintf("  Counties with >= %d individuals/year: %d (of %d total)",
                min_county_n,
                length(valid_counties),
                length(unique(county_panel$county_id))))
log_msg(sprintf("  TVA counties retained: %d",
                length(unique(analysis_county[tva == 1]$county_id))))
log_msg(sprintf("  Control counties retained: %d",
                length(unique(analysis_county[tva == 0]$county_id))))

# =============================================================================
# 3. Create outcome changes (for first-differenced specifications)
# =============================================================================
log_msg("Creating first-differenced outcomes...")

# Reshape to wide for first differences
county_wide <- dcast(analysis_county,
  county_id + statefip_1920 + countyicp_1920 + tva ~ year,
  value.var = c("ag_share", "mfg_share", "transition_ag_to_mfg",
                "transition_ag_to_mfg_cond", "occ_change_rate",
                "farm_exit_rate", "n_individuals", "mean_age",
                "pct_white", "pct_farm", "pct_urban", "pct_literate"))

# First differences (changes between periods)
# Pre-treatment change: 1930 - 1920
county_wide[, d_ag_share_pre   := ag_share_1930 - ag_share_1920]
county_wide[, d_mfg_share_pre  := mfg_share_1930 - mfg_share_1920]

# Post-treatment change: 1940 - 1930
county_wide[, d_ag_share_post  := ag_share_1940 - ag_share_1930]
county_wide[, d_mfg_share_post := mfg_share_1940 - mfg_share_1930]

# Full-period change: 1940 - 1920
county_wide[, d_ag_share_full  := ag_share_1940 - ag_share_1920]
county_wide[, d_mfg_share_full := mfg_share_1940 - mfg_share_1920]

saveRDS(county_wide, file.path(DATA_DIR, "county_wide.rds"))

# =============================================================================
# 4. Identify bordering (same-state + adjacent-state) control counties
# =============================================================================
log_msg("Identifying bordering control counties...")

# Control counties in TVA states (same-state non-TVA)
same_state_control <- unique(analysis_county[
  tva == 0 & statefip_1920 %in% TVA_STATES]$county_id)

# Control counties in adjacent states
adjacent_control <- unique(analysis_county[
  tva == 0 & statefip_1920 %in% TVA_ADJACENT_STATES]$county_id)

# Combined bordering controls: same-state + adjacent-state
bordering_controls <- union(same_state_control, adjacent_control)

bordering_counties <- data.table(
  county_id = bordering_controls,
  control_type = fifelse(
    bordering_controls %in% same_state_control,
    "same_state", "adjacent_state"
  )
)

log_msg(sprintf("  Same-state non-TVA controls: %d counties",
                length(same_state_control)))
log_msg(sprintf("  Adjacent-state controls: %d counties",
                length(adjacent_control)))
log_msg(sprintf("  Total bordering controls: %d counties",
                length(bordering_controls)))

saveRDS(bordering_counties, file.path(DATA_DIR, "bordering_counties.rds"))

# =============================================================================
# 5. Create analysis subsamples
# =============================================================================
log_msg("Creating analysis subsamples...")

# Full sample
analysis_county[, sample_full := TRUE]

# Bordering controls only (TVA counties + bordering non-TVA)
tva_counties_ids <- unique(analysis_county[tva == 1]$county_id)
analysis_county[, sample_bordering := county_id %in% c(tva_counties_ids, bordering_controls)]

# Same-state controls only
analysis_county[, sample_same_state := county_id %in% c(tva_counties_ids, same_state_control)]

log_msg(sprintf("  Full sample counties: %d",
                length(unique(analysis_county[sample_full == TRUE]$county_id))))
log_msg(sprintf("  Bordering sample counties: %d",
                sum(analysis_county[year == 1920]$sample_bordering)))
log_msg(sprintf("  Same-state sample counties: %d",
                sum(analysis_county[year == 1920]$sample_same_state)))

# =============================================================================
# 6. Construct balance table (at 1920 baseline)
# =============================================================================
log_msg("Constructing balance table at 1920 baseline...")

baseline <- analysis_county[year == 1920]

balance_vars <- c(
  "ag_share", "mfg_share", "mean_age", "pct_white", "pct_married",
  "pct_urban", "pct_literate", "pct_farm", "n_individuals"
)

balance_labels <- c(
  "Agriculture share", "Manufacturing share", "Mean age",
  "Share white", "Share married", "Share urban",
  "Share literate", "Share on farm", "N individuals (county mean)"
)

# Compute means and SDs by TVA status
balance_list <- lapply(seq_along(balance_vars), function(i) {
  v <- balance_vars[i]
  tva_vals <- baseline[tva == 1, get(v)]
  ctrl_vals <- baseline[tva == 0, get(v)]

  tva_mean  <- mean(tva_vals, na.rm = TRUE)
  tva_sd    <- sd(tva_vals, na.rm = TRUE)
  ctrl_mean <- mean(ctrl_vals, na.rm = TRUE)
  ctrl_sd   <- sd(ctrl_vals, na.rm = TRUE)
  diff      <- tva_mean - ctrl_mean

  # Normalized difference (Imbens & Rubin 2015)
  norm_diff <- diff / sqrt(tva_sd^2 + ctrl_sd^2)

  # T-test for difference
  tt <- tryCatch(
    t.test(tva_vals, ctrl_vals)$p.value,
    error = function(e) NA_real_
  )

  data.table(
    variable  = balance_labels[i],
    tva_mean  = tva_mean,
    tva_sd    = tva_sd,
    ctrl_mean = ctrl_mean,
    ctrl_sd   = ctrl_sd,
    diff      = diff,
    norm_diff = norm_diff,
    p_value   = tt
  )
})

balance_table <- rbindlist(balance_list)

# Add sample sizes
balance_table <- rbind(
  data.table(
    variable = "N counties",
    tva_mean = nrow(baseline[tva == 1]),
    tva_sd = NA_real_,
    ctrl_mean = nrow(baseline[tva == 0]),
    ctrl_sd = NA_real_,
    diff = NA_real_,
    norm_diff = NA_real_,
    p_value = NA_real_
  ),
  balance_table
)

log_msg("Balance table:")
print(balance_table[, .(variable,
                         TVA = round(tva_mean, 3),
                         Control = round(ctrl_mean, 3),
                         Diff = round(diff, 3),
                         NormDiff = round(norm_diff, 3))])

saveRDS(balance_table, file.path(DATA_DIR, "balance_table_data.rds"))

# =============================================================================
# 7. Restrict individual panel to valid counties
# =============================================================================
log_msg("Restricting individual panel to valid counties...")

analysis_individual <- df[county_id %in% valid_counties]

log_msg(sprintf("  Retained: %s individuals (of %s)",
                fmt(nrow(analysis_individual)), fmt(nrow(df))))

saveRDS(analysis_individual, file.path(DATA_DIR, "analysis_individual.rds"))

# =============================================================================
# 8. Save final analysis county panel
# =============================================================================
saveRDS(analysis_county, file.path(DATA_DIR, "analysis_county.rds"))

# =============================================================================
# 9. Descriptive summary of the analysis sample
# =============================================================================
log_msg("\n=== Analysis Sample Summary ===")

for (yr in c(1920, 1930, 1940)) {
  cp <- analysis_county[year == yr]
  log_msg(sprintf("  Year %d:", yr))
  log_msg(sprintf("    TVA counties: %d, Ag share: %.3f, Mfg share: %.3f",
                  nrow(cp[tva == 1]),
                  mean(cp[tva == 1]$ag_share, na.rm = TRUE),
                  mean(cp[tva == 1]$mfg_share, na.rm = TRUE)))
  log_msg(sprintf("    Ctrl counties: %d, Ag share: %.3f, Mfg share: %.3f",
                  nrow(cp[tva == 0]),
                  mean(cp[tva == 0]$ag_share, na.rm = TRUE),
                  mean(cp[tva == 0]$mfg_share, na.rm = TRUE)))

  if (yr > 1920) {
    trans_var <- "transition_ag_to_mfg_cond"
    log_msg(sprintf("    Ag->Mfg transition (cond): TVA=%.3f, Ctrl=%.3f",
                    mean(cp[tva == 1][[trans_var]], na.rm = TRUE),
                    mean(cp[tva == 0][[trans_var]], na.rm = TRUE)))
  }
}

log_msg("\nData cleaning complete. All analysis datasets saved.")
