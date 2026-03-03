# =============================================================================
# 01_fetch_data.R — Fetch MLP linked panel from Azure, build county-year panel
# =============================================================================
# Queries the three-census balanced panel (1920-1930-1940) from Azure via
# DuckDB. Constructs individual-level and county-level datasets with TVA
# treatment assignment.
#
# Input:  az://derived/mlp_panel/linked_1920_1930_1940.parquet (~34.7M rows)
# Output: ../data/individual_panel.rds    (individual-level, males 18-65)
#         ../data/county_year_panel.rds   (county-year aggregates)
#         ../data/county_tva.rds          (county-level TVA assignment)
# =============================================================================

source("00_packages.R")

con <- apep_azure_connect()

# =============================================================================
# 1. Verify panel structure
# =============================================================================
log_msg("Verifying panel structure...")

panel_n <- apep_azure_query(con, sprintf(
  "SELECT COUNT(*) AS n FROM 'az://%s'", PANEL_PATH
))
log_msg(sprintf("  Panel rows: %s", fmt(panel_n$n)))

# Check column availability
cols <- apep_azure_query(con, sprintf(
  "SELECT column_name FROM (DESCRIBE SELECT * FROM 'az://%s')", PANEL_PATH
))
log_msg(sprintf("  Columns: %d", nrow(cols)))

# Verify key columns exist
required_cols <- c(
  "statefip_1920", "countyicp_1920", "occ1950_1920", "ind1950_1920",
  "age_1920", "sex_1920", "race_1920", "marst_1920", "farm_1920",
  "lit_1920", "urban_1920", "ownershp_1920", "classwkr_1920", "nchild_1920",
  "statefip_1930", "countyicp_1930", "occ1950_1930", "ind1950_1930",
  "statefip_1940", "countyicp_1940", "occ1950_1940", "ind1950_1940"
)
missing <- setdiff(required_cols, cols$column_name)
if (length(missing) > 0) {
  log_msg(sprintf("  WARNING: Missing columns: %s", paste(missing, collapse = ", ")))
}

# =============================================================================
# 2. Query individual-level data for males aged 18-65
# =============================================================================
log_msg("Fetching individual-level data (males 18-65 in 1920)...")

# We need county-level information for TVA assignment.
# Query all three years' variables for males aged 18-65 at baseline (1920).
query <- sprintf("
  SELECT
    -- IDs and demographics at baseline (1920)
    histid_1920,
    statefip_1920, countyicp_1920,
    age_1920, race_1920, marst_1920, nchild_1920,
    farm_1920, urban_1920, ownershp_1920, classwkr_1920,
    lit_1920,

    -- Occupation and industry (all 3 years)
    occ1950_1920, ind1950_1920,
    occ1950_1930, ind1950_1930,
    occ1950_1940, ind1950_1940,

    -- County (all 3 years, for migration detection)
    statefip_1930, countyicp_1930,
    statefip_1940, countyicp_1940,

    -- Farm status (all 3 years)
    farm_1930, farm_1940,

    -- Age for all years (for age bins)
    age_1930, age_1940

  FROM 'az://%s'
  WHERE sex_1920 = 1
    AND age_1920 BETWEEN 18 AND 65
", PANEL_PATH)

df <- as.data.table(apep_azure_query(con, query))
log_msg(sprintf("  Fetched: %s individuals", fmt(nrow(df))))

# =============================================================================
# 3. Create broad occupation and industry categories
# =============================================================================
log_msg("Creating broad occupation and industry categories...")

# OCC1950 broad groups
occ_broad <- function(occ) {
  fifelse(occ >= 0   & occ < 100,  "Professional",
  fifelse(occ >= 100 & occ < 200,  "Farmer",
  fifelse(occ >= 200 & occ < 300,  "Manager",
  fifelse(occ >= 300 & occ < 400,  "Clerical",
  fifelse(occ >= 400 & occ < 500,  "Sales",
  fifelse(occ >= 500 & occ < 600,  "Craftsman",
  fifelse(occ >= 600 & occ < 700,  "Operative",
  fifelse(occ >= 700 & occ < 800,  "Service",
  fifelse(occ >= 800 & occ < 900,  "FarmLaborer",
  fifelse(occ >= 900 & occ <= 970, "Laborer",
                                    "Other"))))))))))
}

# IND1950 broad sectors
ind_broad <- function(ind) {
  fifelse(ind >= 100 & ind < 200,  "Agriculture",
  fifelse(ind >= 200 & ind < 300,  "Mining",
  fifelse(ind >= 300 & ind < 400,  "Construction",
  fifelse(ind >= 400 & ind < 700,  "Manufacturing",
  fifelse(ind >= 700 & ind < 800,  "TranspUtil",
  fifelse(ind >= 800 & ind < 850,  "Trade",
  fifelse(ind >= 850 & ind < 900,  "FIRE",
  fifelse(ind >= 900 & ind < 950,  "Services",
  fifelse(ind >= 950 & ind <= 999, "PubAdmin",
                                    "None")))))))))
}

# Binary agriculture indicator (Farmer + FarmLaborer occupations, or Agr industry)
is_ag <- function(occ, ind) {
  as.integer(
    (occ >= 100 & occ < 200) |   # Farmers
    (occ >= 800 & occ < 900) |   # Farm laborers
    (ind >= 100 & ind < 200)     # Agriculture industry
  )
}

# Binary manufacturing indicator
is_mfg <- function(occ, ind) {
  as.integer(ind >= 400 & ind < 700)
}

# Apply to all 3 years
for (yr in c(1920, 1930, 1940)) {
  occ_col <- paste0("occ1950_", yr)
  ind_col <- paste0("ind1950_", yr)

  df[, paste0("occ_broad_", yr) := occ_broad(get(occ_col))]
  df[, paste0("ind_broad_", yr) := ind_broad(get(ind_col))]
  df[, paste0("in_ag_", yr)     := is_ag(get(occ_col), get(ind_col))]
  df[, paste0("in_mfg_", yr)    := is_mfg(get(occ_col), get(ind_col))]
}

# =============================================================================
# 4. Merge TVA treatment assignment
# =============================================================================
log_msg("Assigning TVA treatment status...")

tva_counties <- get_tva_counties()

# Merge on 1920 county of residence (intent-to-treat based on initial location)
df <- merge(df, tva_counties,
            by.x = c("statefip_1920", "countyicp_1920"),
            by.y = c("statefip", "countyicp"),
            all.x = TRUE)
df[is.na(tva), tva := 0L]

# Create county ID (unique state-county combo)
df[, county_id := paste0(statefip_1920, "_", countyicp_1920)]

log_msg(sprintf("  TVA individuals: %s (%.1f%%)",
                fmt(sum(df$tva == 1)),
                100 * mean(df$tva == 1)))
log_msg(sprintf("  Control individuals: %s", fmt(sum(df$tva == 0))))

# =============================================================================
# 5. Create transition variables (individual-level)
# =============================================================================
log_msg("Creating transition variables...")

# Ag-to-Manufacturing transitions
df[, ag_to_mfg_20_30 := as.integer(in_ag_1920 == 1 & in_mfg_1930 == 1)]
df[, ag_to_mfg_30_40 := as.integer(in_ag_1930 == 1 & in_mfg_1940 == 1)]

# Farm exit
df[, farm_exit_20_30 := as.integer(farm_1920 == 2 & farm_1930 != 2)]
df[, farm_exit_30_40 := as.integer(farm_1930 == 2 & farm_1940 != 2)]

# Occupation change (any change in broad occupation)
df[, occ_change_20_30 := as.integer(occ_broad_1920 != occ_broad_1930)]
df[, occ_change_30_40 := as.integer(occ_broad_1930 != occ_broad_1940)]

# Migration (cross-state move)
df[, migrant_20_30 := as.integer(statefip_1920 != statefip_1930)]
df[, migrant_30_40 := as.integer(statefip_1930 != statefip_1940)]

# =============================================================================
# 6. Build county-year panel (long format)
# =============================================================================
log_msg("Building county-year panel...")

# Function to aggregate county stats for a given year
county_stats <- function(dt, yr, prev_yr = NULL) {
  occ_col <- paste0("occ1950_", yr)
  ind_col <- paste0("ind1950_", yr)
  ag_col  <- paste0("in_ag_", yr)
  mfg_col <- paste0("in_mfg_", yr)

  # Base aggregation
  agg <- dt[, .(
    n_individuals = .N,
    ag_share      = mean(get(ag_col)),
    mfg_share     = mean(get(mfg_col)),
    mean_age      = mean(get(paste0("age_", yr))),
    pct_white     = mean(race_1920 == 1),
    pct_married   = mean(get(paste0("marst_", yr)) %in% 1:2, na.rm = TRUE),
    pct_urban     = if (yr <= 1940) mean(get(paste0("urban_", yr)) >= 2, na.rm = TRUE) else NA_real_,
    pct_literate  = if (yr <= 1930) mean(get(paste0("lit_", yr)) == 4, na.rm = TRUE) else NA_real_,
    pct_farm      = mean(get(paste0("farm_", yr)) == 2, na.rm = TRUE)
  ), by = .(county_id, statefip_1920, countyicp_1920, tva)]

  agg[, year := yr]

  # Add transition rates if we have a previous year
  if (!is.null(prev_yr)) {
    trans_col_ag_mfg <- paste0("ag_to_mfg_", prev_yr %% 100, "_", yr %% 100)
    trans_col_occ    <- paste0("occ_change_", prev_yr %% 100, "_", yr %% 100)
    farm_exit_col    <- paste0("farm_exit_", prev_yr %% 100, "_", yr %% 100)
    ag_prev_col      <- paste0("in_ag_", prev_yr)

    trans <- dt[, .(
      transition_ag_to_mfg = mean(get(trans_col_ag_mfg), na.rm = TRUE),
      occ_change_rate      = mean(get(trans_col_occ), na.rm = TRUE),
      farm_exit_rate       = mean(get(farm_exit_col), na.rm = TRUE),
      n_ag_workers_prev    = sum(get(ag_prev_col))
    ), by = .(county_id)]

    # Ag-to-mfg transition rate conditional on being in ag in prior year
    trans_cond <- dt[get(ag_prev_col) == 1, .(
      transition_ag_to_mfg_cond = mean(get(trans_col_ag_mfg), na.rm = TRUE)
    ), by = .(county_id)]

    agg <- merge(agg, trans, by = "county_id", all.x = TRUE)
    agg <- merge(agg, trans_cond, by = "county_id", all.x = TRUE)
  } else {
    agg[, `:=`(
      transition_ag_to_mfg = NA_real_,
      occ_change_rate      = NA_real_,
      farm_exit_rate       = NA_real_,
      n_ag_workers_prev    = NA_integer_,
      transition_ag_to_mfg_cond = NA_real_
    )]
  }

  return(agg)
}

# Build for each year
county_1920 <- county_stats(df, 1920)
county_1930 <- county_stats(df, 1930, prev_yr = 1920)
county_1940 <- county_stats(df, 1940, prev_yr = 1930)

county_panel <- rbindlist(list(county_1920, county_1930, county_1940),
                          use.names = TRUE, fill = TRUE)

# Create DiD variables
county_panel[, post := as.integer(year >= 1933)]
county_panel[, tva_post := tva * post]

# Year as factor for FE
county_panel[, year_f := as.factor(year)]

log_msg(sprintf("  County-year panel: %s rows (%d counties x 3 years)",
                fmt(nrow(county_panel)),
                length(unique(county_panel$county_id))))
log_msg(sprintf("  TVA counties: %d",
                length(unique(county_panel[tva == 1]$county_id))))
log_msg(sprintf("  Control counties: %d",
                length(unique(county_panel[tva == 0]$county_id))))

# =============================================================================
# 7. Save county-level TVA assignment (for maps and other scripts)
# =============================================================================
county_tva <- unique(county_panel[year == 1920,
  .(county_id, statefip_1920, countyicp_1920, tva)])

# =============================================================================
# 8. Summary statistics
# =============================================================================
log_msg("\n=== Summary Statistics ===")
log_msg(sprintf("  Total individuals: %s", fmt(nrow(df))))
log_msg(sprintf("  TVA (treated): %s", fmt(sum(df$tva == 1))))
log_msg(sprintf("  Control: %s", fmt(sum(df$tva == 0))))
log_msg(sprintf("  Total counties: %d", length(unique(df$county_id))))
log_msg(sprintf("  TVA counties: %d", length(unique(df[tva == 1]$county_id))))

# Agricultural shares over time
for (yr in c(1920, 1930, 1940)) {
  ag_col <- paste0("in_ag_", yr)
  mfg_col <- paste0("in_mfg_", yr)
  log_msg(sprintf("  %d Ag share: TVA=%.1f%%, Control=%.1f%% | Mfg share: TVA=%.1f%%, Control=%.1f%%",
                  yr,
                  100 * mean(df[tva == 1][[ag_col]]),
                  100 * mean(df[tva == 0][[ag_col]]),
                  100 * mean(df[tva == 1][[mfg_col]]),
                  100 * mean(df[tva == 0][[mfg_col]])))
}

# =============================================================================
# 9. Save outputs
# =============================================================================
log_msg("Saving outputs...")

saveRDS(df, file.path(DATA_DIR, "individual_panel.rds"))
saveRDS(county_panel, file.path(DATA_DIR, "county_year_panel.rds"))
saveRDS(county_tva, file.path(DATA_DIR, "county_tva.rds"))

log_msg(sprintf("  individual_panel.rds: %s rows", fmt(nrow(df))))
log_msg(sprintf("  county_year_panel.rds: %s rows", fmt(nrow(county_panel))))
log_msg(sprintf("  county_tva.rds: %d counties", nrow(county_tva)))

apep_azure_disconnect(con)
log_msg("Data fetch complete.")
