# =============================================================================
# 04_robustness.R — Robustness checks for traditional DiD
# =============================================================================
# Three robustness exercises:
#   A. Alternative control groups (bordering non-TVA counties only)
#   B. Placebo test (pre-treatment trends: 1920->1930 as fake "treatment")
#   C. Leave-one-state-out jackknife
#
# Input:  ../data/analysis_county.rds
#         ../data/bordering_counties.rds
# Output: ../data/robustness_results.rds
#         ../data/placebo_results.rds
#         ../data/loso_results.rds       (leave-one-state-out)
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load data
# =============================================================================
log_msg("Loading analysis data...")

analysis_county <- readRDS(file.path(DATA_DIR, "analysis_county.rds"))
bordering_counties <- readRDS(file.path(DATA_DIR, "bordering_counties.rds"))

# =============================================================================
# A. Alternative control groups
# =============================================================================
log_msg("\n=== A. Alternative Control Groups ===")

# Extract TVA county IDs
tva_ids <- unique(analysis_county[tva == 1]$county_id)

# --- A1: Bordering controls only (same-state + adjacent-state non-TVA) ---
bordering_sample <- analysis_county[
  county_id %in% c(tva_ids, bordering_counties$county_id)]

log_msg(sprintf("  Bordering sample: %d TVA + %d control counties",
                length(unique(bordering_sample[tva == 1]$county_id)),
                length(unique(bordering_sample[tva == 0]$county_id))))

# TWFE on bordering sample
r_ag_border <- feols(
  ag_share ~ tva_post | county_id + year,
  data = bordering_sample,
  cluster = ~statefip_1920
)

r_mfg_border <- feols(
  mfg_share ~ tva_post | county_id + year,
  data = bordering_sample,
  cluster = ~statefip_1920
)

log_msg("  Bordering controls:")
cat("    Ag share:  "); print(coeftable(r_ag_border)[1, 1:2])
cat("    Mfg share: "); print(coeftable(r_mfg_border)[1, 1:2])

# --- A2: Same-state non-TVA controls only ---
same_state_ids <- bordering_counties[control_type == "same_state"]$county_id
same_state_sample <- analysis_county[
  county_id %in% c(tva_ids, same_state_ids)]

log_msg(sprintf("  Same-state sample: %d TVA + %d control counties",
                length(unique(same_state_sample[tva == 1]$county_id)),
                length(unique(same_state_sample[tva == 0]$county_id))))

r_ag_same <- feols(
  ag_share ~ tva_post | county_id + year,
  data = same_state_sample,
  cluster = ~statefip_1920
)

r_mfg_same <- feols(
  mfg_share ~ tva_post | county_id + year,
  data = same_state_sample,
  cluster = ~statefip_1920
)

log_msg("  Same-state controls:")
cat("    Ag share:  "); print(coeftable(r_ag_same)[1, 1:2])
cat("    Mfg share: "); print(coeftable(r_mfg_same)[1, 1:2])

# --- A3: Non-South controls (exclude all Southern states) ---
# Southern states: AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, TX, VA, WV
# STATEFIP: 1, 5, 12, 13, 21, 22, 28, 37, 45, 47, 48, 51, 54
southern_fips <- c(1L, 5L, 12L, 13L, 21L, 22L, 28L, 37L, 45L, 47L, 48L, 51L, 54L)
non_south_ctrl_ids <- unique(analysis_county[
  tva == 0 & !(statefip_1920 %in% southern_fips)]$county_id)
non_south_sample <- analysis_county[
  county_id %in% c(tva_ids, non_south_ctrl_ids)]

log_msg(sprintf("  Non-South sample: %d TVA + %d control counties",
                length(unique(non_south_sample[tva == 1]$county_id)),
                length(unique(non_south_sample[tva == 0]$county_id))))

r_ag_nonsouth <- feols(
  ag_share ~ tva_post | county_id + year,
  data = non_south_sample,
  cluster = ~statefip_1920
)

r_mfg_nonsouth <- feols(
  mfg_share ~ tva_post | county_id + year,
  data = non_south_sample,
  cluster = ~statefip_1920
)

log_msg("  Non-South controls:")
cat("    Ag share:  "); print(coeftable(r_ag_nonsouth)[1, 1:2])
cat("    Mfg share: "); print(coeftable(r_mfg_nonsouth)[1, 1:2])

# =============================================================================
# B. Placebo test: pre-treatment trends (1920-1930 as fake treatment)
# =============================================================================
log_msg("\n=== B. Placebo Test (Pre-Treatment Trends) ===")

# Use only 1920 and 1930 data. Pretend treatment happens between them.
# If parallel trends hold, the TVA x post coefficient should be near zero.
placebo_data <- analysis_county[year %in% c(1920, 1930)]
placebo_data[, placebo_post := as.integer(year == 1930)]
placebo_data[, tva_placebo := tva * placebo_post]

# Ag share placebo
p_ag <- feols(
  ag_share ~ tva_placebo | county_id + year,
  data = placebo_data,
  cluster = ~statefip_1920
)

# Mfg share placebo
p_mfg <- feols(
  mfg_share ~ tva_placebo | county_id + year,
  data = placebo_data,
  cluster = ~statefip_1920
)

# Transition rates: only available as 1920->1930 transition
# No placebo possible for transition (only one pre-period)

log_msg("  Placebo (1920->1930):")
cat("    Ag share:  "); print(coeftable(p_ag)[1, 1:4])
cat("    Mfg share: "); print(coeftable(p_mfg)[1, 1:4])

placebo_results <- rbindlist(list(
  data.table(outcome = "Ag Share", coef = coeftable(p_ag)[1, 1],
             se = coeftable(p_ag)[1, 2], p = coeftable(p_ag)[1, 4]),
  data.table(outcome = "Mfg Share", coef = coeftable(p_mfg)[1, 1],
             se = coeftable(p_mfg)[1, 2], p = coeftable(p_mfg)[1, 4])
))

# =============================================================================
# C. Leave-one-state-out jackknife
# =============================================================================
log_msg("\n=== C. Leave-One-State-Out Jackknife ===")

states_in_sample <- sort(unique(analysis_county$statefip_1920))
log_msg(sprintf("  States in sample: %d", length(states_in_sample)))

loso_ag  <- list()
loso_mfg <- list()

for (s in states_in_sample) {
  subset <- analysis_county[statefip_1920 != s]

  # Skip if dropping this state removes all TVA counties
  if (sum(subset$tva == 1 & subset$year == 1920) == 0) {
    log_msg(sprintf("    Skipping state %d (no TVA counties remain)", s))
    next
  }

  m_ag <- tryCatch(
    feols(ag_share ~ tva_post | county_id + year,
          data = subset, cluster = ~statefip_1920),
    error = function(e) NULL
  )

  m_mfg <- tryCatch(
    feols(mfg_share ~ tva_post | county_id + year,
          data = subset, cluster = ~statefip_1920),
    error = function(e) NULL
  )

  if (!is.null(m_ag)) {
    loso_ag[[as.character(s)]] <- data.table(
      dropped_state = s,
      coef = coeftable(m_ag)[1, 1],
      se   = coeftable(m_ag)[1, 2]
    )
  }

  if (!is.null(m_mfg)) {
    loso_mfg[[as.character(s)]] <- data.table(
      dropped_state = s,
      coef = coeftable(m_mfg)[1, 1],
      se   = coeftable(m_mfg)[1, 2]
    )
  }
}

loso_ag_dt  <- rbindlist(loso_ag)
loso_ag_dt[, outcome := "Ag Share"]
loso_mfg_dt <- rbindlist(loso_mfg)
loso_mfg_dt[, outcome := "Mfg Share"]
loso_results <- rbindlist(list(loso_ag_dt, loso_mfg_dt))

log_msg("  Leave-one-state-out summary (Ag Share):")
log_msg(sprintf("    Coef range: [%.4f, %.4f]",
                min(loso_ag_dt$coef), max(loso_ag_dt$coef)))
log_msg(sprintf("    Mean coef: %.4f", mean(loso_ag_dt$coef)))

log_msg("  Leave-one-state-out summary (Mfg Share):")
log_msg(sprintf("    Coef range: [%.4f, %.4f]",
                min(loso_mfg_dt$coef), max(loso_mfg_dt$coef)))
log_msg(sprintf("    Mean coef: %.4f", mean(loso_mfg_dt$coef)))

# =============================================================================
# D. Compile all robustness results
# =============================================================================
log_msg("\nCompiling robustness results...")

extract_rob <- function(model, outcome, spec) {
  ct <- coeftable(model)
  treat_row <- grep("tva_post|tva_placebo", rownames(ct))
  if (length(treat_row) == 0) return(NULL)
  treat_row <- treat_row[1]
  data.table(
    outcome = outcome,
    specification = spec,
    coef = ct[treat_row, 1],
    se = ct[treat_row, 2],
    p_value = ct[treat_row, 4],
    n_obs = model$nobs
  )
}

robustness_results <- rbindlist(list(
  # Alt controls: bordering
  extract_rob(r_ag_border, "Ag Share", "Bordering controls"),
  extract_rob(r_mfg_border, "Mfg Share", "Bordering controls"),
  # Alt controls: same-state
  extract_rob(r_ag_same, "Ag Share", "Same-state controls"),
  extract_rob(r_mfg_same, "Mfg Share", "Same-state controls"),
  # Alt controls: non-South
  extract_rob(r_ag_nonsouth, "Ag Share", "Non-South controls"),
  extract_rob(r_mfg_nonsouth, "Mfg Share", "Non-South controls"),
  # Placebo
  extract_rob(p_ag, "Ag Share", "Placebo (1920-1930)"),
  extract_rob(p_mfg, "Mfg Share", "Placebo (1920-1930)")
), fill = TRUE)

log_msg("\n=== Robustness Summary ===")
print(robustness_results[, .(outcome, specification,
                              coef = round(coef, 4),
                              se = round(se, 4),
                              p = round(p_value, 3))])

# =============================================================================
# E. Save outputs
# =============================================================================
log_msg("Saving robustness results...")

saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))
saveRDS(placebo_results, file.path(DATA_DIR, "placebo_results.rds"))
saveRDS(loso_results, file.path(DATA_DIR, "loso_results.rds"))

# Save model objects for table generation
rob_models <- list(
  ag_border = r_ag_border,
  mfg_border = r_mfg_border,
  ag_same = r_ag_same,
  mfg_same = r_mfg_same,
  ag_nonsouth = r_ag_nonsouth,
  mfg_nonsouth = r_mfg_nonsouth,
  ag_placebo = p_ag,
  mfg_placebo = p_mfg
)
saveRDS(rob_models, file.path(DATA_DIR, "robustness_models.rds"))

log_msg("Robustness analysis complete.")
