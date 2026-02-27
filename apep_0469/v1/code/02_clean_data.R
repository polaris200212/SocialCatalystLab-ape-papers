## ============================================================================
## 02_clean_data.R — Variable Construction and Panel Assembly
## Missing Men, Rising Women (apep_0469)
## ============================================================================
## DESIGN:
##   Primary analysis uses STATE-level mobilization rates from CenSoc,
##   matching all 4.5M IPUMS records via STATEFIP.
##   This follows Acemoglu, Autor & Lyle (2004).
##
##   County-level analysis supplements this for the ~100 identified counties
##   in the IPUMS 1% sample.
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"

## --------------------------------------------------------------------------
## 1. Load and Prepare IPUMS Data
## --------------------------------------------------------------------------

cat("=== Loading IPUMS Data ===\n")

ipums_rds <- file.path(data_dir, "ipums_mlp_clean.rds")

if (file.exists(ipums_rds)) {
  mlp <- readRDS(ipums_rds)
  cat(sprintf("Loaded %s records\n", format(nrow(mlp), big.mark = ",")))
} else {
  ipums_files <- list.files(data_dir, pattern = "usa_.*\\.(csv\\.gz|dat\\.gz)", full.names = TRUE)
  ddi_files <- list.files(data_dir, pattern = "usa_.*\\.xml", full.names = TRUE)
  if (length(ipums_files) > 0 && length(ddi_files) > 0) {
    ddi <- read_ipums_ddi(ddi_files[1])
    mlp <- as.data.table(read_ipums_micro(ddi, data_file = ipums_files[1]))
    saveRDS(mlp, ipums_rds)
  } else {
    stop("No IPUMS data found. Run 01_fetch_data.R first.")
  }
}

# Standardize to lowercase
setnames(mlp, tolower(names(mlp)))

# Strip haven_labelled types → plain numeric/integer (critical for comparisons)
for (col in names(mlp)) {
  if (inherits(mlp[[col]], "haven_labelled")) {
    mlp[, (col) := as.numeric(get(col))]
  }
}

cat(sprintf("Columns: %s\n", paste(names(mlp), collapse = ", ")))
cat(sprintf("Years: %s\n", paste(sort(unique(mlp$year)), collapse = ", ")))
cat(sprintf("States: %d, Records by year:\n", uniqueN(mlp$statefip)))
print(mlp[, .N, by = year][order(year)])


## --------------------------------------------------------------------------
## 2. Variable Construction
## --------------------------------------------------------------------------

cat("\n=== Constructing Variables ===\n")

# -- County FIPS code (only identified for large counties in 1% sample) --
county_col <- intersect(c("countyfip", "county"), names(mlp))
if (length(county_col) > 0) {
  cv <- county_col[1]
  mlp[, county_fips := as.integer(statefip) * 1000L + as.integer(get(cv))]
  mlp[get(cv) == 0 | is.na(get(cv)), county_fips := NA_integer_]
  cat(sprintf("County identified: %s / %s (%.1f%%)\n",
      format(sum(!is.na(mlp$county_fips)), big.mark = ","),
      format(nrow(mlp), big.mark = ","),
      100 * mean(!is.na(mlp$county_fips))))
}

# -- State FIPS (always identified) --
mlp[, statefip := as.integer(statefip)]

# -- Gender --
mlp[, female := as.integer(sex == 2)]

# -- Race --
mlp[, race_cat := fcase(
  race == 1, "White",
  race == 2, "Black",
  default = "Other"
)]

# -- Labor force --
mlp[, in_lf := as.integer(labforce == 2)]

# -- Employed --
mlp[, employed := as.integer(empstat == 1)]

# -- Occupation score --
mlp[, occ_score := fifelse(occscore > 0, as.numeric(occscore), NA_real_)]

# -- SEI --
mlp[, sei_score := fifelse(sei > 0, as.numeric(sei), NA_real_)]

# -- Education years --
mlp[, educ_years := fcase(
  educ == 0 | is.na(educ), NA_real_,
  educ == 1, 0,
  educ == 2, 2.5,
  educ == 3, 6.5,
  educ == 4, 9,
  educ == 5, 10,
  educ == 6, 11,
  educ == 7, 12,
  educ == 8, 13,
  educ == 9, 14,
  educ == 10, 15,
  educ == 11, 16,
  educ >= 12, 17
)]

# -- Marital status --
mlp[, married := as.integer(marst %in% c(1, 2))]
mlp[, single := as.integer(marst == 6)]

# -- Household structure --
mlp[, is_head := as.integer(relate == 1)]
mlp[, is_urban := as.integer(urban == 2)]
mlp[, is_farm := as.integer(farm == 2)]

# -- Age groups --
mlp[, age_group := fcase(
  age >= 18 & age <= 25, "18-25",
  age >= 26 & age <= 35, "26-35",
  age >= 36 & age <= 45, "36-45",
  age >= 46 & age <= 55, "46-55",
  age >= 56, "56+",
  default = "Under 18"
)]

mlp[, birth_year := year - age]
mlp[, post := as.integer(year >= 1950)]

# Working-age restriction
mlp_wa <- mlp[age >= 18 & age <= 55]
cat(sprintf("Working-age (18-55): %s\n", format(nrow(mlp_wa), big.mark = ",")))


## --------------------------------------------------------------------------
## 3. State-Level Mobilization Rates (from CenSoc)
## --------------------------------------------------------------------------

cat("\n=== Constructing State Mobilization Rates ===\n")

censoc_rds <- file.path(data_dir, "censoc_enlistment.rds")

if (file.exists(censoc_rds)) {
  censoc <- readRDS(censoc_rds)
  cat(sprintf("CenSoc enlistment records: %s\n", format(nrow(censoc), big.mark = ",")))

  # State-level enlistment counts
  state_enlist <- censoc[!is.na(residence_state_fips) & residence_state_fips > 0,
                          .(n_enlisted = .N),
                          by = .(statefip = as.integer(residence_state_fips))]
  cat(sprintf("States with enlistment data: %d\n", nrow(state_enlist)))
  cat(sprintf("Total enlisted: %s\n", format(sum(state_enlist$n_enlisted), big.mark = ",")))

  # County-level enlistment counts (for supplementary analysis)
  censoc[, county_fips_censoc := as.integer(residence_state_fips) * 1000L +
                                  as.integer(residence_county_fips)]
  county_enlist <- censoc[!is.na(county_fips_censoc) & county_fips_censoc > 0,
                          .(n_enlisted_cty = .N),
                          by = .(county_fips = county_fips_censoc)]
} else {
  cat("CenSoc not available.\n")
  state_enlist <- data.table(statefip = integer(0), n_enlisted = integer(0))
  county_enlist <- data.table(county_fips = integer(0), n_enlisted_cty = integer(0))
}

# --- State-level mobilization rate ---
# Denominator: males 18-44 in 1940 (draft-eligible age)
state_male_pop <- mlp[year == 1940 & sex == 1 & age >= 18 & age <= 44,
                      .(male_pop_18_44 = .N), by = statefip]

state_mob <- merge(state_male_pop, state_enlist, by = "statefip", all.x = TRUE)
state_mob[is.na(n_enlisted), n_enlisted := 0]
state_mob[, mobilization_rate := n_enlisted / male_pop_18_44]

# NOTE: CenSoc has ~2.5M records, IPUMS 1940 1% has ~28K males 18-44 per state average.
# The mobilization rate = (CenSoc enlistees from state) / (IPUMS 1% males 18-44).
# This is NOT a true rate (numerator from full population, denominator from 1%).
# The RANKING across states is valid; the levels should be interpreted as relative.

cat(sprintf("States with mobilization data: %d\n", nrow(state_mob)))
cat("\nState mobilization rate distribution:\n")
print(state_mob[, .(mean = mean(mobilization_rate, na.rm = TRUE),
                    sd = sd(mobilization_rate, na.rm = TRUE),
                    p10 = quantile(mobilization_rate, 0.10, na.rm = TRUE),
                    p25 = quantile(mobilization_rate, 0.25, na.rm = TRUE),
                    p50 = quantile(mobilization_rate, 0.50, na.rm = TRUE),
                    p75 = quantile(mobilization_rate, 0.75, na.rm = TRUE),
                    p90 = quantile(mobilization_rate, 0.90, na.rm = TRUE))])

# Quintiles
state_mob[, mob_quintile := paste0("Q", cut(rank(mobilization_rate),
          breaks = quantile(rank(mobilization_rate), probs = seq(0, 1, 0.2)),
          labels = FALSE, include.lowest = TRUE))]
state_mob[, mob_std := as.numeric(scale(mobilization_rate))]

cat("Mobilization quintile distribution:\n")
print(state_mob[, .(n_states = .N,
                    mean_rate = mean(mobilization_rate)),
                by = mob_quintile][order(mob_quintile)])

# Top and bottom mobilization states
cat("\nHighest mobilization states:\n")
print(head(state_mob[order(-mobilization_rate), .(statefip, mobilization_rate, n_enlisted, male_pop_18_44)], 10))
cat("\nLowest mobilization states:\n")
print(head(state_mob[order(mobilization_rate), .(statefip, mobilization_rate, n_enlisted, male_pop_18_44)], 10))


## --------------------------------------------------------------------------
## 4. County-Level Mobilization (Supplement)
## --------------------------------------------------------------------------

cat("\n=== County Mobilization (Supplement) ===\n")

county_male_pop <- mlp[year == 1940 & sex == 1 & age >= 18 & age <= 44 & !is.na(county_fips),
                       .(male_pop_18_44_cty = .N), by = county_fips]

county_mob <- merge(county_male_pop, county_enlist, by = "county_fips", all.x = TRUE)
county_mob[is.na(n_enlisted_cty), n_enlisted_cty := 0]
county_mob[, mobilization_rate_cty := n_enlisted_cty / male_pop_18_44_cty]
county_mob <- county_mob[male_pop_18_44_cty >= 10]  # Minimum size
county_mob[, mob_std_cty := as.numeric(scale(mobilization_rate_cty))]

cat(sprintf("Identified counties: %d\n", nrow(county_mob)))


## --------------------------------------------------------------------------
## 5. Merge Mobilization to Individual Data
## --------------------------------------------------------------------------

cat("\n=== Merging Mobilization ===\n")

# Primary: state-level mobilization
mlp_wa <- merge(mlp_wa,
                state_mob[, .(statefip, mobilization_rate, mob_quintile, mob_std)],
                by = "statefip", all.x = TRUE)

cat(sprintf("Individuals with state mobilization: %s / %s (%.1f%%)\n",
    format(sum(!is.na(mlp_wa$mobilization_rate)), big.mark = ","),
    format(nrow(mlp_wa), big.mark = ","),
    100 * mean(!is.na(mlp_wa$mobilization_rate))))

# Drop states with no mobilization data
mlp_wa <- mlp_wa[!is.na(mobilization_rate)]

# Supplement: county-level mobilization (where available)
mlp_wa <- merge(mlp_wa,
                county_mob[, .(county_fips, mobilization_rate_cty, mob_std_cty)],
                by = "county_fips", all.x = TRUE)

cat(sprintf("Individuals with county mobilization: %s (%.1f%%)\n",
    format(sum(!is.na(mlp_wa$mobilization_rate_cty)), big.mark = ","),
    100 * mean(!is.na(mlp_wa$mobilization_rate_cty))))

# State baseline controls (from 1940 Census)
state_controls <- mlp[year == 1940 & age >= 18 & age <= 55, .(
  pct_urban = mean(is_urban, na.rm = TRUE),
  pct_farm = mean(is_farm, na.rm = TRUE),
  pct_black = mean(race_cat == "Black", na.rm = TRUE),
  pct_female = mean(female, na.rm = TRUE),
  mean_educ = mean(educ_years, na.rm = TRUE),
  mean_age = mean(age, na.rm = TRUE),
  pct_married = mean(married, na.rm = TRUE),
  pct_in_lf_female = mean(in_lf[female == 1], na.rm = TRUE),
  pct_in_lf_male = mean(in_lf[female == 0], na.rm = TRUE),
  total_pop = .N
), by = statefip]

mlp_wa <- merge(mlp_wa, state_controls,
                by = "statefip", all.x = TRUE, suffixes = c("", "_st"))


## --------------------------------------------------------------------------
## 6. State-Level Panel (Primary Analysis Dataset)
## --------------------------------------------------------------------------

cat("\n=== Building State-Level Panel ===\n")

# State × year × gender outcomes
state_gender_year <- mlp_wa[, .(
  mean_lf = weighted.mean(in_lf, perwt, na.rm = TRUE),
  mean_employed = weighted.mean(employed, perwt, na.rm = TRUE),
  mean_occ = weighted.mean(occ_score, perwt, na.rm = TRUE),
  mean_sei = weighted.mean(sei_score, perwt, na.rm = TRUE),
  mean_head = weighted.mean(is_head, perwt, na.rm = TRUE),
  mean_married = weighted.mean(married, perwt, na.rm = TRUE),
  n = .N,
  n_wt = sum(perwt)
), by = .(statefip, year, female)]

# Gender gap by state and year
state_gap <- dcast(state_gender_year, statefip + year ~ female,
                   value.var = c("mean_lf", "mean_occ", "mean_sei", "mean_head",
                                 "mean_married", "mean_employed", "n", "n_wt"),
                   fun.aggregate = mean, fill = NA)
setnames(state_gap, gsub("_0$", "_male", gsub("_1$", "_female", names(state_gap))))

state_gap[, `:=`(
  lf_gap = mean_lf_female - mean_lf_male,
  occ_gap = mean_occ_female - mean_occ_male,
  sei_gap = mean_sei_female - mean_sei_male
)]

# State-level first differences
state_changes_40_50 <- merge(
  state_gap[year == 1940, .(statefip,
    lf_female_1940 = mean_lf_female, lf_male_1940 = mean_lf_male,
    occ_female_1940 = mean_occ_female, occ_male_1940 = mean_occ_male,
    sei_female_1940 = mean_sei_female, sei_male_1940 = mean_sei_male,
    head_female_1940 = mean_head_female,
    employed_female_1940 = mean_employed_female,
    married_female_1940 = mean_married_female,
    lf_gap_1940 = lf_gap, occ_gap_1940 = occ_gap,
    n_female_1940 = n_female, n_male_1940 = n_male)],
  state_gap[year == 1950, .(statefip,
    lf_female_1950 = mean_lf_female, lf_male_1950 = mean_lf_male,
    occ_female_1950 = mean_occ_female, occ_male_1950 = mean_occ_male,
    sei_female_1950 = mean_sei_female, sei_male_1950 = mean_sei_male,
    head_female_1950 = mean_head_female,
    employed_female_1950 = mean_employed_female,
    married_female_1950 = mean_married_female,
    lf_gap_1950 = lf_gap, occ_gap_1950 = occ_gap,
    n_female_1950 = n_female, n_male_1950 = n_male)],
  by = "statefip"
)

state_changes_40_50[, `:=`(
  d_lf_female = lf_female_1950 - lf_female_1940,
  d_lf_male = lf_male_1950 - lf_male_1940,
  d_occ_female = occ_female_1950 - occ_female_1940,
  d_occ_male = occ_male_1950 - occ_male_1940,
  d_lf_gap = lf_gap_1950 - lf_gap_1940,
  d_occ_gap = occ_gap_1950 - occ_gap_1940,
  d_head_female = head_female_1950 - head_female_1940,
  d_employed_female = employed_female_1950 - employed_female_1940,
  d_married_female = married_female_1950 - married_female_1940
)]

state_analysis <- merge(state_changes_40_50, state_mob, by = "statefip", all.x = TRUE)
state_analysis <- merge(state_analysis, state_controls, by = "statefip", all.x = TRUE)
state_analysis <- state_analysis[!is.na(mobilization_rate)]

cat(sprintf("State analysis dataset: %d states\n", nrow(state_analysis)))

# Pre-trends: 1930-1940
if (1930 %in% unique(mlp$year)) {
  state_changes_30_40 <- merge(
    state_gap[year == 1930, .(statefip,
      lf_female_1930 = mean_lf_female, lf_male_1930 = mean_lf_male,
      occ_female_1930 = mean_occ_female, lf_gap_1930 = lf_gap)],
    state_gap[year == 1940, .(statefip,
      lf_female_1940 = mean_lf_female, lf_male_1940 = mean_lf_male,
      occ_female_1940 = mean_occ_female, lf_gap_1940 = lf_gap)],
    by = "statefip"
  )
  state_changes_30_40[, `:=`(
    d_lf_female_pre = lf_female_1940 - lf_female_1930,
    d_lf_male_pre = lf_male_1940 - lf_male_1930,
    d_occ_female_pre = occ_female_1940 - occ_female_1930,
    d_lf_gap_pre = lf_gap_1940 - lf_gap_1930
  )]
  state_pretrends <- merge(state_changes_30_40, state_mob, by = "statefip", all.x = TRUE)
  state_pretrends <- merge(state_pretrends, state_controls, by = "statefip", all.x = TRUE)
  state_pretrends <- state_pretrends[!is.na(mobilization_rate)]
  cat(sprintf("Pre-trend states (1930-1940): %d\n", nrow(state_pretrends)))
} else {
  state_pretrends <- data.table()
}


## --------------------------------------------------------------------------
## 7. Individual-Level Stacked Panel for Triple-Diff
## --------------------------------------------------------------------------

cat("\n=== Building Individual Stacked Panel ===\n")

# Triple-difference: female × post × mobilization
indiv_panel <- mlp_wa[year %in% c(1940, 1950)]
indiv_panel[, `:=`(
  female_x_post = female * post,
  female_x_mob = female * mob_std,
  post_x_mob = post * mob_std,
  female_x_post_x_mob = female * post * mob_std
)]

cat(sprintf("Individual stacked panel: %s obs (%s in 1940, %s in 1950)\n",
    format(nrow(indiv_panel), big.mark = ","),
    format(sum(indiv_panel$year == 1940), big.mark = ","),
    format(sum(indiv_panel$year == 1950), big.mark = ",")))


## --------------------------------------------------------------------------
## 8. Save Analysis Datasets
## --------------------------------------------------------------------------

cat("\n=== Saving Analysis Datasets ===\n")

saveRDS(state_mob, file.path(data_dir, "state_mobilization.rds"))
saveRDS(state_analysis, file.path(data_dir, "state_analysis.rds"))
saveRDS(state_gender_year, file.path(data_dir, "state_gender_year.rds"))
saveRDS(state_controls, file.path(data_dir, "state_controls.rds"))
saveRDS(county_mob, file.path(data_dir, "county_mobilization.rds"))
saveRDS(indiv_panel, file.path(data_dir, "indiv_panel.rds"))
saveRDS(mlp_wa[year == 1940, .(statefip, female, race_cat, age, age_group,
                                in_lf, occ_score, sei_score, educ_years,
                                married, is_head, is_urban, is_farm,
                                mobilization_rate, mob_quintile, perwt)],
        file.path(data_dir, "baseline_1940.rds"))

if (nrow(state_pretrends) > 0) {
  saveRDS(state_pretrends, file.path(data_dir, "state_pretrends.rds"))
}

# Metadata
track_info <- list(
  n_states = nrow(state_analysis),
  n_counties = nrow(county_mob),
  n_indiv_panel = nrow(indiv_panel),
  years = sort(unique(mlp$year)),
  has_histid = FALSE
)
saveRDS(track_info, file.path(data_dir, "track_info.rds"))

cat("\n=== SUMMARY ===\n")
cat(sprintf("States:              %d\n", nrow(state_analysis)))
cat(sprintf("Counties (suppl):    %d\n", nrow(county_mob)))
cat(sprintf("Individual panel:    %s obs\n", format(nrow(indiv_panel), big.mark = ",")))
cat(sprintf("Mobilization range:  [%.1f, %.1f]\n",
    min(state_mob$mobilization_rate, na.rm = TRUE),
    max(state_mob$mobilization_rate, na.rm = TRUE)))

cat("\n✓ Data cleaning complete. Proceed to 03_main_analysis.R\n")
