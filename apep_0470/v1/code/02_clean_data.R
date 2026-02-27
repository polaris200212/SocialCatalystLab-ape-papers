###############################################################################
# 02_clean_data.R — Data cleaning, MLP linking, variable construction
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

source("code/00_packages.R")

# ── 1. Load IPUMS census data ───────────────────────────────────────────────
ipums_dir <- paste0(data_dir, "ipums/")

# IPUMS fixed-width data requires DDI (XML) metadata for parsing
ddi_files <- list.files(ipums_dir, pattern = "\\.xml$", full.names = TRUE)
csv_files <- list.files(ipums_dir, pattern = "\\.csv(\\.gz)?$", full.names = TRUE)

if (length(ddi_files) > 0) {
  # Preferred: use ipumsr DDI reader for fixed-width .dat.gz files
  ddi <- read_ipums_ddi(ddi_files[1])
  census_raw <- as.data.table(read_ipums_micro(ddi))
  cat("✓ Census data loaded via ipumsr DDI:", format(nrow(census_raw), big.mark = ","), "records\n")
} else if (length(csv_files) > 0) {
  census_raw <- fread(csv_files[1], nThread = getDTthreads())
  cat("✓ Census data loaded via fread:", format(nrow(census_raw), big.mark = ","), "records\n")
} else {
  stop("No IPUMS data files found in ", ipums_dir,
       "\n  Run 01_fetch_data.R first, or download manually from IPUMS.")
}

# ── 2. Basic variable construction ──────────────────────────────────────────
census <- copy(census_raw)

# Standardize variable names to lowercase
setnames(census, tolower(names(census)))

# Core demographic variables
census[, female := as.integer(sex == 2)]
census[, black := as.integer(race == 2)]
census[, white := as.integer(race == 1)]
census[, race_label := fifelse(black == 1, "Black",
                       fifelse(white == 1, "White", "Other"))]

# Age categories for heterogeneity
census[, age_group := fcase(
  age >= 15 & age < 25, "15-24",
  age >= 25 & age < 35, "25-34",
  age >= 35 & age < 45, "35-44",
  age >= 45 & age < 55, "45-54",
  age >= 55 & age < 65, "55-64",
  default = "Other"
)]
census[, working_age := as.integer(age >= 15 & age <= 64)]

# Labor market outcomes
census[, in_lf := as.integer(empstat %in% c(1, 2))]     # In labor force
census[, employed := as.integer(empstat == 1)]            # Employed
census[, in_mfg := as.integer(ind1950 >= 300 & ind1950 < 500)]  # Manufacturing
census[, in_ag := as.integer(ind1950 >= 100 & ind1950 < 200)]   # Agriculture
census[, on_farm := as.integer(farm == 2)]                # Lives on farm

# Occupational score (socioeconomic index)
census[, sei_score := as.numeric(sei)]
census[, occ_score := as.numeric(occscore)]

# Income (1940 only — code as NA for other years)
census[, wage_income := as.numeric(incwage)]
census[year != 1940 | wage_income >= 999998, wage_income := NA]
census[, log_wage := log(wage_income + 1)]
census[is.infinite(log_wage) | is.nan(log_wage), log_wage := NA]

# Education
census[, literate := as.integer(lit == 4)]  # Can read and write

# Housing
census[, owns_home := as.integer(ownershp == 1)]

# Nativity
census[, native_born := as.integer(nativity <= 1)]

cat("✓ Variables constructed\n")
cat("  Census years:", sort(unique(census$year)), "\n")
cat("  Records by year:\n")
print(census[, .N, by = year][order(year)])

# ── 3. Geographic matching ──────────────────────────────────────────────────
# Match census records to TVA county classification
county_class <- fread(paste0(data_dir, "county_classification.csv"))

# IPUMS uses COUNTYICP (ICPSR county codes). Modern shapefiles use FIPS.
# We need to harmonize. IPUMS STATEFIP matches FIPS state codes.
# COUNTYICP requires a crosswalk to modern FIPS county codes.
#
# For this analysis, we match on state FIPS + approximate county matching.
# IPUMS COUNTYICP = FIPS county code * 10 (for most states)
census[, countyfip_approx := countyicp %/% 10]

# Merge county classification
census <- merge(census,
                county_class[, .(STATEFIP, COUNTYFIP, dist_nearest_dam_km,
                                  log_dist_dam, nearest_dam,
                                  tva_core, tva_peripheral, tva_any,
                                  border_control)],
                by.x = c("statefip", "countyfip_approx"),
                by.y = c("STATEFIP", "COUNTYFIP"),
                all.x = TRUE)

# Filter to analysis sample: TVA states + buffer states, working-age adults
analysis_states <- c(1, 5, 12, 13, 17, 18, 21, 22, 28, 29, 37, 39, 40,
                     45, 47, 48, 51, 54)  # Southeast + buffer
census_analysis <- census[statefip %in% analysis_states & working_age == 1]

# Handle unmatched counties
n_unmatched <- sum(is.na(census_analysis$tva_any))
cat("  Unmatched to county classification:", format(n_unmatched, big.mark = ","),
    "(", round(100 * n_unmatched / nrow(census_analysis), 1), "%)\n")

# Set unmatched to non-TVA, non-border (distant controls)
census_analysis[is.na(tva_any), `:=`(tva_core = FALSE, tva_peripheral = FALSE,
                                      tva_any = FALSE, border_control = FALSE)]
census_analysis[is.na(dist_nearest_dam_km), dist_nearest_dam_km := 999]
census_analysis[is.na(log_dist_dam), log_dist_dam := log(1000)]

cat("✓ Geographic matching complete\n")
cat("  TVA core individuals:", format(sum(census_analysis$tva_core), big.mark = ","), "\n")
cat("  Non-TVA individuals:", format(sum(!census_analysis$tva_any), big.mark = ","), "\n")

# ── 4. MLP record linking ──────────────────────────────────────────────────
# Link individuals across censuses using MLP crosswalks.
# Crosswalk format: HISTID_A (year 1) → HISTID_B (year 2)

mlp_dir <- paste0(data_dir, "mlp/")

link_census <- function(dt, xwalk_file, year_a, year_b) {
  if (!file.exists(xwalk_file)) {
    cat("⚠ Crosswalk file not found:", xwalk_file, "\n")
    cat("  Using within-household approximate matching instead.\n")
    return(NULL)
  }

  cat("  Loading crosswalk:", basename(xwalk_file), "...\n")
  xwalk <- as.data.table(read_parquet(xwalk_file))

  # Extract records for each year
  dt_a <- dt[year == year_a, .(histid, year, statefip, countyicp,
                                age, sex, race, occ1950, sei_score,
                                in_mfg, in_ag, on_farm, literate, owns_home,
                                tva_any, tva_core, dist_nearest_dam_km)]
  setnames(dt_a, paste0(names(dt_a), "_a"))
  setnames(dt_a, "histid_a", "HISTID_A")

  dt_b <- dt[year == year_b, .(histid, year, statefip, countyicp,
                                age, sex, race, occ1950, sei_score,
                                in_mfg, in_ag, on_farm, literate, owns_home,
                                tva_any, tva_core, dist_nearest_dam_km,
                                wage_income, log_wage, in_lf, employed)]
  setnames(dt_b, paste0(names(dt_b), "_b"))
  setnames(dt_b, "histid_b", "HISTID_B")

  # Merge with crosswalk
  linked <- merge(xwalk, dt_a, by = "HISTID_A")
  linked <- merge(linked, dt_b, by = "HISTID_B")

  cat("  ✓ Linked", format(nrow(linked), big.mark = ","),
      "individuals across", year_a, "→", year_b, "\n")
  return(linked)
}

# Attempt MLP linking
xwalk_1920_1930 <- paste0(mlp_dir, "crosswalk_1920_1930.parquet")
xwalk_1930_1940 <- paste0(mlp_dir, "crosswalk_1930_1940.parquet")

linked_20_30 <- link_census(census_analysis, xwalk_1920_1930, 1920, 1930)
linked_30_40 <- link_census(census_analysis, xwalk_1930_1940, 1930, 1940)

# ── 5. Construct analysis panels ────────────────────────────────────────────
# If MLP crosswalks not available, construct approximate panel
# using household-level matching on name-like characteristics

if (is.null(linked_30_40)) {
  cat("\n  MLP crosswalks not available. Constructing repeated cross-section panel.\n")
  cat("  This uses county-level aggregation instead of individual linking.\n\n")

  # Aggregate to county-year level for DiD without individual linking
  county_panel <- census_analysis[, .(
    n_persons = .N,
    mean_sei = mean(sei_score, na.rm = TRUE),
    mean_occ_score = mean(occ_score, na.rm = TRUE),
    pct_mfg = mean(in_mfg, na.rm = TRUE),
    pct_ag = mean(in_ag, na.rm = TRUE),
    pct_farm = mean(on_farm, na.rm = TRUE),
    pct_lf = mean(in_lf, na.rm = TRUE),
    pct_employed = mean(employed, na.rm = TRUE),
    pct_literate = mean(literate, na.rm = TRUE),
    pct_owns_home = mean(owns_home, na.rm = TRUE),
    pct_black = mean(black, na.rm = TRUE),
    pct_female = mean(female, na.rm = TRUE),
    mean_age = mean(age, na.rm = TRUE),
    # 1940-only outcomes
    mean_wage = mean(wage_income, na.rm = TRUE),
    mean_log_wage = mean(log_wage, na.rm = TRUE),
    # Race-specific outcomes
    pct_mfg_white = mean(in_mfg[white == 1], na.rm = TRUE),
    pct_mfg_black = mean(in_mfg[black == 1], na.rm = TRUE),
    sei_white = mean(sei_score[white == 1], na.rm = TRUE),
    sei_black = mean(sei_score[black == 1], na.rm = TRUE),
    # Gender-specific outcomes
    pct_lf_male = mean(in_lf[female == 0], na.rm = TRUE),
    pct_lf_female = mean(in_lf[female == 1], na.rm = TRUE),
    sei_male = mean(sei_score[female == 0], na.rm = TRUE),
    sei_female = mean(sei_score[female == 1], na.rm = TRUE)
  ), by = .(statefip, countyfip_approx, year)]

  # Merge county characteristics
  county_panel <- merge(county_panel,
                        county_class[, .(STATEFIP, COUNTYFIP,
                                         dist_nearest_dam_km, log_dist_dam,
                                         tva_core, tva_peripheral, tva_any,
                                         border_control)],
                        by.x = c("statefip", "countyfip_approx"),
                        by.y = c("STATEFIP", "COUNTYFIP"),
                        all.x = TRUE)

  # Treatment variables
  county_panel[, post := as.integer(year == 1940)]
  county_panel[, tva_post := as.integer(tva_any == TRUE & post == 1)]
  county_panel[, tva_core_post := as.integer(tva_core == TRUE & post == 1)]
  county_panel[is.na(tva_any), tva_any := FALSE]
  county_panel[is.na(tva_core), tva_core := FALSE]

  # County ID for fixed effects
  county_panel[, county_id := paste0(statefip, "_", countyfip_approx)]

  fwrite(county_panel, paste0(data_dir, "county_panel.csv"))
  cat("✓ County-year panel saved:", format(nrow(county_panel), big.mark = ","), "obs\n")
  cat("  Counties:", length(unique(county_panel$county_id)), "\n")
  cat("  Years:", sort(unique(county_panel$year)), "\n")
}

# ── 6. Individual-level panel (if MLP available) ────────────────────────────
if (!is.null(linked_30_40)) {
  # The 1930→1940 panel is the main treatment panel
  # 1920→1930 serves as pre-treatment placebo

  # Main treatment panel
  panel_main <- linked_30_40[, .(
    histid_1930 = HISTID_A,
    histid_1940 = HISTID_B,
    # 1930 characteristics (pre-treatment)
    statefip_1930 = statefip_a,
    county_1930 = countyicp_a,
    age_1930 = age_a,
    sex = sex_a,
    race = race_a,
    sei_1930 = sei_score_a,
    in_mfg_1930 = in_mfg_a,
    in_ag_1930 = in_ag_a,
    on_farm_1930 = on_farm_a,
    literate_1930 = literate_a,
    owns_home_1930 = owns_home_a,
    tva_1930 = tva_any_a,
    tva_core_1930 = tva_core_a,
    dist_dam_1930 = dist_nearest_dam_km_a,
    # 1940 outcomes (post-treatment)
    statefip_1940 = statefip_b,
    county_1940 = countyicp_b,
    sei_1940 = sei_score_b,
    in_mfg_1940 = in_mfg_b,
    in_ag_1940 = in_ag_b,
    on_farm_1940 = on_farm_b,
    wage_1940 = wage_income_b,
    log_wage_1940 = log_wage_b,
    in_lf_1940 = in_lf_b,
    employed_1940 = employed_b,
    owns_home_1940 = owns_home_b
  )]

  # Change variables (individual-level DiD)
  panel_main[, delta_sei := sei_1940 - sei_1930]
  panel_main[, entered_mfg := as.integer(in_mfg_1930 == 0 & in_mfg_1940 == 1)]
  panel_main[, left_ag := as.integer(in_ag_1930 == 1 & in_ag_1940 == 0)]
  panel_main[, left_farm := as.integer(on_farm_1930 == 1 & on_farm_1940 == 0)]

  # Demographics
  panel_main[, female := as.integer(sex == 2)]
  panel_main[, black := as.integer(race == 2)]
  panel_main[, white := as.integer(race == 1)]

  # Migration indicator
  panel_main[, mover := as.integer(statefip_1930 != statefip_1940 |
                                     county_1930 != county_1940)]

  # Age groups
  panel_main[, age_group := fcase(
    age_1930 >= 15 & age_1930 < 25, "15-24",
    age_1930 >= 25 & age_1930 < 35, "25-34",
    age_1930 >= 35 & age_1930 < 45, "35-44",
    age_1930 >= 45 & age_1930 < 55, "45-54",
    default = "55-64"
  )]

  fwrite(panel_main, paste0(data_dir, "individual_panel_30_40.csv"))
  cat("✓ Individual panel (1930→1940) saved:",
      format(nrow(panel_main), big.mark = ","), "linked individuals\n")
}

# ── 7. Summary statistics ───────────────────────────────────────────────────
cat("\n═══════════════════════════════════════════════════\n")
cat("SAMPLE SUMMARY\n")
cat("═══════════════════════════════════════════════════\n")

if (exists("county_panel")) {
  cat("\nCounty-year panel:\n")
  cat("  Total obs:", format(nrow(county_panel), big.mark = ","), "\n")
  cat("  TVA counties:", sum(county_panel$tva_any & county_panel$year == 1930), "\n")
  cat("  Border counties:", sum(county_panel$border_control & county_panel$year == 1930, na.rm = TRUE), "\n")
  cat("  Mean SEI (TVA 1930):", round(county_panel[tva_any == TRUE & year == 1930, mean(mean_sei, na.rm = TRUE)], 2), "\n")
  cat("  Mean SEI (Non-TVA 1930):", round(county_panel[tva_any == FALSE & year == 1930, mean(mean_sei, na.rm = TRUE)], 2), "\n")
}

if (exists("panel_main")) {
  cat("\nIndividual panel (1930→1940):\n")
  cat("  Linked individuals:", format(nrow(panel_main), big.mark = ","), "\n")
  cat("  TVA residents:", format(sum(panel_main$tva_1930), big.mark = ","), "\n")
  cat("  Black:", round(100 * mean(panel_main$black), 1), "%\n")
  cat("  Female:", round(100 * mean(panel_main$female), 1), "%\n")
  cat("  Movers:", round(100 * mean(panel_main$mover), 1), "%\n")
}

cat("\n✓ Data cleaning complete.\n")
