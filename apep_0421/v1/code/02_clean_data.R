## ═══════════════════════════════════════════════════════════════════════════
## 02_clean_data.R — Construct district-level analysis panel
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))

cat("\n══════════════════════════════════════════════\n")
cat("STEP 1: LOAD RAW DATA\n")
cat("══════════════════════════════════════════════\n\n")

# ── 1a. NFHS district data (long format) ──────────────────────────────────
nfhs_raw <- fread(file.path(data_dir, "nfhs", "India.csv"))
cat("NFHS raw loaded:", nrow(nfhs_raw), "rows\n")
cat("Columns:", paste(names(nfhs_raw), collapse = ", "), "\n\n")

# ── 1b. SHRUG Census 2011 PCA (district level) ───────────────────────────
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))
cat("Census 2011 PCA loaded:", nrow(pca11), "districts\n")

# ── 1c. SHRUG Town Directory (district level) ────────────────────────────
td11 <- fread(file.path(shrug_dir, "pc11_td_clean_pc11dist.csv"))
cat("Census 2011 TD loaded:", nrow(td11), "districts\n")

# ── 1d. VIIRS nightlights (district × year) ──────────────────────────────
viirs <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
cat("VIIRS nightlights loaded:", nrow(viirs), "rows\n")

# ── 1e. SECC rural data (district level) ──────────────────────────────────
secc <- fread(file.path(shrug_dir, "secc_rural_pc11dist.csv"))
cat("SECC rural loaded:", nrow(secc), "districts\n\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 2: RESHAPE NFHS DATA\n")
cat("══════════════════════════════════════════════\n\n")

# Create unique district ID from state + district census codes
nfhs_raw[, dist_id := paste0(
  sprintf("%02d", as.integer(ST_CEN_CD)),
  sprintf("%03d", as.integer(DT_CEN_CD))
)]

# Define indicator mapping for key variables
indicator_map <- data.table(
  indicator_name = c(
    # Education outcomes
    "Female population age 6 years and above who ever attended school (%)",
    "Women with 10 or more years of schooling (%)",
    "Women who are literate (%)",
    # Treatment variable
    "Population living in households with an improved drinkingwater source (%)",
    # Health outcomes (mechanism)
    "Prevalence of diarrhoea in the 2 weeks preceding the survey (%)",
    "Children under 5 years who are stunted (height for age) (%)",
    "Children under 5 years who are underweight (weight for age) (%)",
    "Children under 5 years who are wasted (weight for height) (%)",
    # Nutrition (mechanism)
    "Children age 6-8 months receiving solid or semisolid food and breastmilk (%)",
    # Maternal health
    "Mothers who had at least 4 antenatal care visits (%)",
    "Institutional births (%)",
    # Sanitation control
    "Population living in households that use an improved sanitation facility (%)",
    # Other infrastructure (placebo)
    "Population living in households with electricity (%)",
    "Households using clean fuel for cooking (%)",
    # Demographics
    "Population below age 15 years (%)",
    "Sex ratio of the total population (females per 1,000 males)",
    # Fertility
    "Women age 2024 years married before age 18 years (%)",
    "Women age 15-19 years who were already mothers or pregnant at the time of the survey (%)",
    # Insurance (placebo for health mechanism)
    "Households with any usual member covered under a health insurance/financing scheme (%)",
    # Tobacco placebo
    "Men age 15 years and above who use any kind of tobacco (%)"
  ),
  var_name = c(
    "fem_school_attend", "women_10yr_school", "women_literate",
    "improved_water",
    "child_diarrhea", "child_stunted", "child_underweight", "child_wasted",
    "child_adequate_food",
    "anc_4visits", "inst_births",
    "improved_sanitation",
    "hh_electricity", "clean_fuel",
    "pop_under15", "sex_ratio",
    "child_marriage", "teen_pregnancy",
    "health_insurance",
    "male_tobacco"
  )
)

cat("Mapping", nrow(indicator_map), "indicators to variable names\n")

# Reshape: long → wide with NFHS-4 and NFHS-5 values
nfhs_wide <- dcast(
  nfhs_raw[Indicator %in% indicator_map$indicator_name],
  dist_id + State + District + ST_CEN_CD + DT_CEN_CD ~ Indicator,
  value.var = c("NFHS 5", "NFHS 4"),
  fun.aggregate = function(x) {
    x <- suppressWarnings(as.numeric(x))
    x <- x[!is.na(x)]
    if (length(x) == 0) return(NA_real_)
    mean(x)
  }
)

cat("NFHS wide:", nrow(nfhs_wide), "districts,", ncol(nfhs_wide), "columns\n")

# Rename columns using indicator map
for (i in 1:nrow(indicator_map)) {
  old_5 <- paste0("NFHS 5_", indicator_map$indicator_name[i])
  old_4 <- paste0("NFHS 4_", indicator_map$indicator_name[i])
  new_5 <- paste0(indicator_map$var_name[i], "_nfhs5")
  new_4 <- paste0(indicator_map$var_name[i], "_nfhs4")
  if (old_5 %in% names(nfhs_wide)) setnames(nfhs_wide, old_5, new_5)
  if (old_4 %in% names(nfhs_wide)) setnames(nfhs_wide, old_4, new_4)
}

# Compute changes (NFHS-5 minus NFHS-4)
for (v in indicator_map$var_name) {
  v5 <- paste0(v, "_nfhs5")
  v4 <- paste0(v, "_nfhs4")
  vd <- paste0("d_", v)
  if (v5 %in% names(nfhs_wide) & v4 %in% names(nfhs_wide)) {
    nfhs_wide[, (vd) := get(v5) - get(v4)]
  }
}

cat("\nSample change statistics:\n")
cat("  Δ Female school attendance:",
    round(mean(nfhs_wide$d_fem_school_attend, na.rm = TRUE), 2), "pp\n")
cat("  Δ Improved water:",
    round(mean(nfhs_wide$d_improved_water, na.rm = TRUE), 2), "pp\n")
cat("  Δ Child diarrhea:",
    round(mean(nfhs_wide$d_child_diarrhea, na.rm = TRUE), 2), "pp\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 3: CONSTRUCT TREATMENT VARIABLE\n")
cat("══════════════════════════════════════════════\n\n")

# Treatment intensity: Baseline water infrastructure deficit
# Districts with LOW baseline improved water = HIGH JJM exposure potential
nfhs_wide[, water_gap := 100 - improved_water_nfhs4]

cat("Water gap (100 - NFHS4 improved water):\n")
cat("  Mean:", round(mean(nfhs_wide$water_gap, na.rm = TRUE), 1), "\n")
cat("  SD:", round(sd(nfhs_wide$water_gap, na.rm = TRUE), 1), "\n")
cat("  Min:", round(min(nfhs_wide$water_gap, na.rm = TRUE), 1), "\n")
cat("  Max:", round(max(nfhs_wide$water_gap, na.rm = TRUE), 1), "\n")
cat("  Median:", round(median(nfhs_wide$water_gap, na.rm = TRUE), 1), "\n")

# Binary treatment: above-median water gap
nfhs_wide[, high_water_gap := as.integer(water_gap > median(water_gap, na.rm = TRUE))]
cat("\n  Districts with high water gap:", sum(nfhs_wide$high_water_gap, na.rm = TRUE), "\n")
cat("  Districts with low water gap:", sum(1 - nfhs_wide$high_water_gap, na.rm = TRUE), "\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 4: MERGE CENSUS 2011 CONTROLS\n")
cat("══════════════════════════════════════════════\n\n")

# Census 2011 uses sequential NATIONAL district IDs (state 01: 001-022, state 02: 023-034, ...)
# NFHS uses within-state sequential IDs (every state starts from 001)
# Build crosswalk: within each state, rank Census districts and map to NFHS within-state rank

# Census crosswalk
census_xwalk <- pca11[, .(pc11_state_id, pc11_district_id)]
census_xwalk[, state_id := as.integer(pc11_state_id)]
census_xwalk[, dist_rank := rank(pc11_district_id), by = state_id]
census_xwalk[, nfhs_dist_id := paste0(
  sprintf("%02d", state_id),
  sprintf("%03d", as.integer(dist_rank))
)]
census_xwalk[, census_dist_id := paste0(
  sprintf("%02d", state_id),
  sprintf("%03d", as.integer(pc11_district_id))
)]

cat("Census crosswalk built:", nrow(census_xwalk), "districts\n")
cat("Sample mapping (state 02):\n")
print(census_xwalk[state_id == 2, .(census_dist_id, nfhs_dist_id, dist_rank)])

# Check overlap with NFHS
overlap <- sum(census_xwalk$nfhs_dist_id %in% nfhs_wide$dist_id)
cat("\nCensus districts matching NFHS:", overlap, "/", nrow(census_xwalk), "\n")

# Add crosswalk to Census datasets
pca11[, census_dist_id := paste0(
  sprintf("%02d", as.integer(pc11_state_id)),
  sprintf("%03d", as.integer(pc11_district_id))
)]
pca11 <- merge(pca11, census_xwalk[, .(census_dist_id, nfhs_dist_id)],
  by = "census_dist_id", all.x = TRUE)
pca11[, dist_id := nfhs_dist_id]

td11[, census_dist_id := paste0(
  sprintf("%02d", as.integer(pc11_state_id)),
  sprintf("%03d", as.integer(pc11_district_id))
)]
td11 <- merge(td11, census_xwalk[, .(census_dist_id, nfhs_dist_id)],
  by = "census_dist_id", all.x = TRUE)
td11[, dist_id := nfhs_dist_id]

secc[, census_dist_id := paste0(
  sprintf("%02d", as.integer(pc11_state_id)),
  sprintf("%03d", as.integer(pc11_district_id))
)]
secc <- merge(secc, census_xwalk[, .(census_dist_id, nfhs_dist_id)],
  by = "census_dist_id", all.x = TRUE)
secc[, dist_id := nfhs_dist_id]

# Construct Census controls
census_controls <- pca11[, .(
  dist_id,
  pop_total = pc11_pca_tot_p,
  num_hh = pc11_pca_no_hh,
  pop_female_share = pc11_pca_tot_f / pc11_pca_tot_p,
  pop_sc_share = pc11_pca_p_sc / pc11_pca_tot_p,
  pop_st_share = pc11_pca_p_st / pc11_pca_tot_p,
  literacy_rate = pc11_pca_p_lit / (pc11_pca_p_lit + pc11_pca_p_ill),
  female_literacy = pc11_pca_f_lit / (pc11_pca_f_lit + pc11_pca_f_ill),
  male_literacy = pc11_pca_m_lit / (pc11_pca_m_lit + pc11_pca_m_ill),
  child_share = pc11_pca_p_06 / pc11_pca_tot_p,
  worker_share = pc11_pca_tot_work_p / pc11_pca_tot_p,
  agr_worker_share = (pc11_pca_main_cl_p + pc11_pca_main_al_p) / pc11_pca_tot_p
)]

# School infrastructure from TD11
school_infra <- td11[, .(
  dist_id,
  n_primary_gov = pc11_td_primary_gov,
  n_primary_priv = pc11_td_primary_priv,
  n_middle_gov = pc11_td_middle_gov,
  n_middle_priv = pc11_td_middle_priv,
  n_sec_gov = pc11_td_sec_gov,
  n_sec_priv = pc11_td_sec_priv,
  n_hospital = pc11_td_all_hospital,
  hospital_beds = pc11_td_allh_beds
)]

# SECC deprivation indicators
secc_vars <- names(secc)[grepl("secc", names(secc))]
cat("SECC variables available:", length(secc_vars), "\n")

# Key SECC variables
secc_controls <- secc[, .SD, .SDcols = c("dist_id",
  grep("(secc_pov_rate|secc_cons|deprivation)", names(secc), value = TRUE))]
if (ncol(secc_controls) <= 1) {
  # Fallback: use whatever is available
  secc_num <- names(secc)[sapply(secc, is.numeric)]
  secc_num <- secc_num[!grepl("state_id|district_id", secc_num)]
  if (length(secc_num) > 0) {
    secc_controls <- secc[, .SD, .SDcols = c("dist_id", head(secc_num, 5))]
  }
}
cat("SECC controls:", ncol(secc_controls) - 1, "variables\n")

# Merge everything
df <- merge(nfhs_wide, census_controls, by = "dist_id", all.x = TRUE)
df <- merge(df, school_infra, by = "dist_id", all.x = TRUE)
if (ncol(secc_controls) > 1) {
  df <- merge(df, secc_controls, by = "dist_id", all.x = TRUE)
}

cat("\nMerged dataset:", nrow(df), "districts,", ncol(df), "columns\n")
cat("Districts with Census match:", sum(!is.na(df$pop_total)), "\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 5: CONSTRUCT VIIRS NIGHTLIGHTS PANEL\n")
cat("══════════════════════════════════════════════\n\n")

# VIIRS data has: pc11_district_id, pc11_state_id, viirs_annual_mean, year
# Apply same crosswalk
viirs[, census_dist_id := paste0(
  sprintf("%02d", as.integer(pc11_state_id)),
  sprintf("%03d", as.integer(pc11_district_id))
)]
viirs <- merge(viirs, census_xwalk[, .(census_dist_id, nfhs_dist_id)],
  by = "census_dist_id", all.x = TRUE)
viirs[, dist_id := nfhs_dist_id]

# Already in long format with 'year' column
viirs_long <- viirs[!is.na(dist_id), .(
  dist_id, year = as.integer(year),
  nightlights = as.numeric(viirs_annual_mean)
)]
cat("VIIRS panel:", nrow(viirs_long), "district-years\n")
cat("Year range:", range(viirs_long$year, na.rm = TRUE), "\n")

# Compute pre/post JJM nightlights change
viirs_pre <- viirs_long[year %in% 2015:2018,
  .(nl_pre = mean(nightlights, na.rm = TRUE)), by = dist_id]
viirs_post <- viirs_long[year %in% 2019:2021,
  .(nl_post = mean(nightlights, na.rm = TRUE)), by = dist_id]
viirs_change <- merge(viirs_pre, viirs_post, by = "dist_id")
viirs_change[, d_nightlights := nl_post - nl_pre]
viirs_change[, d_nightlights_pct := 100 * (nl_post - nl_pre) / (nl_pre + 0.01)]

df <- merge(df, viirs_change, by = "dist_id", all.x = TRUE)
cat("Districts with VIIRS match:", sum(!is.na(df$d_nightlights)), "\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 6: FINAL CLEANING AND VARIABLE CONSTRUCTION\n")
cat("══════════════════════════════════════════════\n\n")

# Log population
df[, log_pop := log(pop_total + 1)]

# State fixed effects (from NFHS state codes)
df[, state_id := as.integer(ST_CEN_CD)]

# Standardize treatment variable for interpretation
df[, water_gap_sd := scale(water_gap)[, 1]]

# Create quintiles of water gap
df[, water_gap_q := cut(water_gap,
  breaks = quantile(water_gap, probs = seq(0, 1, 0.2), na.rm = TRUE),
  include.lowest = TRUE, labels = paste0("Q", 1:5))]

# Clean any remaining NAs in key variables
key_vars <- c("d_fem_school_attend", "d_improved_water", "water_gap",
              "literacy_rate", "pop_sc_share", "pop_st_share", "log_pop")
n_complete <- sum(complete.cases(df[, ..key_vars]))
cat("Districts with complete key variables:", n_complete, "/", nrow(df), "\n")

# Analysis sample
df_analysis <- df[complete.cases(df[, ..key_vars])]
cat("Analysis sample:", nrow(df_analysis), "districts\n")

# State-level summary
state_summary <- df_analysis[, .(
  n_districts = .N,
  mean_water_gap = round(mean(water_gap, na.rm = TRUE), 1),
  mean_d_school = round(mean(d_fem_school_attend, na.rm = TRUE), 1),
  mean_d_water = round(mean(d_improved_water, na.rm = TRUE), 1)
), by = State][order(-n_districts)]
cat("\nState-level summary (top 10 by N):\n")
print(head(state_summary, 10))

cat("\n══════════════════════════════════════════════\n")
cat("STEP 7: SAVE ANALYSIS DATA\n")
cat("══════════════════════════════════════════════\n\n")

# Save full merged dataset
fwrite(df, file.path(data_dir, "analysis_full.csv"))
cat("Full dataset saved:", nrow(df), "districts\n")

# Save analysis sample
fwrite(df_analysis, file.path(data_dir, "analysis_sample.csv"))
cat("Analysis sample saved:", nrow(df_analysis), "districts\n")

# Save VIIRS panel for event study
if (exists("viirs_long")) {
  fwrite(viirs_long, file.path(data_dir, "viirs_panel.csv"))
  cat("VIIRS panel saved:", nrow(viirs_long), "district-years\n")
}

# Save for R downstream use
save(df, df_analysis, file = file.path(data_dir, "analysis_data.RData"))
if (exists("viirs_long")) {
  save(viirs_long, file = file.path(data_dir, "viirs_panel.RData"))
}

cat("\n✓ Data cleaning complete\n")
cat("  Analysis sample:", nrow(df_analysis), "districts\n")
cat("  States:", length(unique(df_analysis$State)), "\n")
cat("  Key outcomes: d_fem_school_attend, d_women_10yr_school, d_child_diarrhea\n")
cat("  Treatment: water_gap (100 - NFHS4 improved water %)\n")
