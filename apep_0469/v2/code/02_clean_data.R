## ============================================================================
## 02_clean_data.R — Longitudinal Panel via Census Linking Project Crosswalk
## Missing Men, Rising Women v2 (apep_0469)
## ============================================================================
## THIS IS THE KEY SCRIPT that makes v2 fundamentally different from v1.
##
## v1 used 1% cross-sections (different people in each year). v2 uses IPUMS
## full-count (100%) data LINKED via the Census Linking Project (Abramitzky,
## Boustan, Eriksson, Pérez, Rashid 2025) crosswalk. This crosswalk provides
## histid_1940 → histid_1950 mappings for individuals matched across the two
## complete-count censuses using automated record linkage.
##
## The ABE algorithm links individuals by first name, last name, year of birth,
## and place of birth. Because women's surnames change at marriage, the standard
## ABE crosswalk primarily links men. We exploit this by:
##   1. Tracking men individually (1940 → 1950) via the crosswalk
##   2. Tracking wives through their husbands' households
##
## MEMORY-AWARE: Each year file is ~40 GB in memory. With 96+ GB RAM, we
## process each year independently, merge with crosswalk, then combine.
##
## Output datasets:
##   - linked_panel_40_50.rds   : Individuals linked across 1940 and 1950
##   - couples_panel_40_50.rds  : Married couples tracked through household linkage
##   - state_analysis.rds       : State-level aggregates (from full-count)
##   - linkage_diagnostics.rds  : Selection into linkage analysis
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"

## --------------------------------------------------------------------------
## Helper: construct variables on a single-year data.table
## NOTE: Unlike v1, we KEEP serial, pernum, relate for household linkage
## --------------------------------------------------------------------------
construct_vars <- function(dt) {
  setnames(dt, tolower(names(dt)))

  # Strip haven_labelled types using set()
  lab_cols <- names(dt)[vapply(dt, inherits, logical(1), "haven_labelled")]
  cat(sprintf("  Haven-labelled columns: %d\n", length(lab_cols)))
  for (col in lab_cols) {
    set(dt, j = col, value = as.numeric(dt[[col]]))
  }

  # Create derived columns
  set(dt, j = "statefip", value = as.integer(dt[["statefip"]]))
  set(dt, j = "female",   value = as.integer(dt[["sex"]] == 2))
  set(dt, j = "in_lf",    value = as.integer(dt[["labforce"]] == 2))
  set(dt, j = "employed",  value = as.integer(dt[["empstat"]] == 1))
  set(dt, j = "occ_score", value = fifelse(dt[["occscore"]] > 0, as.numeric(dt[["occscore"]]), NA_real_))
  set(dt, j = "sei_score", value = fifelse(dt[["sei"]] > 0, as.numeric(dt[["sei"]]), NA_real_))
  set(dt, j = "married",   value = as.integer(dt[["marst"]] %in% c(1, 2)))
  set(dt, j = "single",    value = as.integer(dt[["marst"]] == 6))
  set(dt, j = "is_head",   value = as.integer(dt[["relate"]] == 1))
  set(dt, j = "is_spouse", value = as.integer(dt[["relate"]] == 2))
  set(dt, j = "is_urban",  value = as.integer(dt[["urban"]] == 2))
  set(dt, j = "is_farm",   value = as.integer(dt[["farm"]] == 2))

  educ_v <- dt[["educ"]]
  set(dt, j = "educ_years", value = fcase(
    educ_v == 0 | is.na(educ_v), NA_real_,
    educ_v == 1, 0,  educ_v == 2, 2.5, educ_v == 3, 6.5, educ_v == 4, 9,
    educ_v == 5, 10, educ_v == 6, 11,  educ_v == 7, 12,  educ_v == 8, 13,
    educ_v == 9, 14, educ_v == 10, 15, educ_v == 11, 16, educ_v >= 12, 17
  ))
  rm(educ_v)

  race_v <- dt[["race"]]
  set(dt, j = "race_cat", value = fcase(race_v == 1, "White", race_v == 2, "Black", default = "Other"))
  rm(race_v)

  # Drop columns we no longer need (but KEEP serial, pernum, relate for household linkage)
  drop_cols <- intersect(names(dt), c("sex", "labforce", "empstat", "marst",
                                       "urban", "farm", "occscore",
                                       "sei", "educ", "race", "sample",
                                       "hhwt", "gq",
                                       "related", "raced", "bpld", "educd",
                                       "empstatd", "occ1950", "versionhist"))
  for (col in drop_cols) set(dt, j = col, value = NULL)
  invisible(dt)
}


cat("=== Census Linking Project Crosswalk Panel Construction ===\n")
cat(sprintf("Available RAM: %.0f GB\n",
    as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1e9))


## --------------------------------------------------------------------------
## 0. Load Census Linking Project Crosswalk
## --------------------------------------------------------------------------

cat("\n=== Loading Census Linking Project Crosswalk ===\n")

cw_file <- file.path(data_dir, "crosswalk_1940_1950.csv")
ei_file <- file.path(data_dir, "ei_crosswalk_1940_1950.csv")

if (!file.exists(cw_file)) {
  stop("Census Linking Project crosswalk not found: ", cw_file,
       "\nDownload from: https://doi.org/10.7910/DVN/DXHTEQ")
}

cw <- fread(cw_file, nThread = getDTthreads())
cat(sprintf("Crosswalk loaded: %s rows, %d columns\n",
    format(nrow(cw), big.mark = ","), ncol(cw)))
cat(sprintf("  Columns: %s\n", paste(names(cw), collapse = ", ")))
cat(sprintf("  Memory: %s\n", format(object.size(cw), units = "GB")))

# Show match counts by method
for (col in grep("^(link_abe|abe|ei)_", names(cw), value = TRUE)) {
  n <- sum(cw[[col]] == 1, na.rm = TRUE)
  cat(sprintf("  %s: %s matches\n", col, format(n, big.mark = ",")))
}

# Primary method: ABE exact conservative (highest precision, fewest false matches)
# Also keep ABE NYSIIS conservative as robustness variant
primary_method <- "link_abe_exact_conservative"
if (!primary_method %in% names(cw)) {
  # Try alternative column name patterns (with or without link_ prefix)
  possible <- grep("exact.*conserv|conserv.*exact", names(cw), value = TRUE)
  if (length(possible) > 0) {
    primary_method <- possible[1]
    cat(sprintf("Using alternative column: %s\n", primary_method))
  } else {
    possible <- grep("conservative", names(cw), value = TRUE)
    primary_method <- possible[1]
    cat(sprintf("Fallback to: %s\n", primary_method))
  }
}

cw_primary <- cw[get(primary_method) == 1, .(histid_1940, histid_1950)]
cat(sprintf("Primary method (%s): %s linked pairs\n",
    primary_method, format(nrow(cw_primary), big.mark = ",")))

# De-duplicate: keep only 1:1 unique matches
# (Remove cases where one histid maps to multiple counterparts)
dup_40 <- cw_primary[, .N, by = histid_1940][N > 1, histid_1940]
dup_50 <- cw_primary[, .N, by = histid_1950][N > 1, histid_1950]
cw_primary <- cw_primary[!histid_1940 %in% dup_40 & !histid_1950 %in% dup_50]
cat(sprintf("After de-duplication (1:1 only): %s linked pairs\n",
    format(nrow(cw_primary), big.mark = ",")))
cat(sprintf("  Removed %s duplicate-40, %s duplicate-50\n",
    format(length(dup_40), big.mark = ","),
    format(length(dup_50), big.mark = ",")))

# Also load EI crosswalk if available (for robustness)
if (file.exists(ei_file)) {
  cw_ei <- fread(ei_file, nThread = getDTthreads())
  ei_method <- grep("^ei_exact_conservative$|^link_ei_exact_conservative$", names(cw_ei), value = TRUE)
  if (length(ei_method) == 0) ei_method <- grep("ei.*conserv", names(cw_ei), value = TRUE)
  if (length(ei_method) > 0) {
    cw_ei_primary <- cw_ei[get(ei_method[1]) == 1, .(histid_1940, histid_1950)]
    dup_40_ei <- cw_ei_primary[, .N, by = histid_1940][N > 1, histid_1940]
    dup_50_ei <- cw_ei_primary[, .N, by = histid_1950][N > 1, histid_1950]
    cw_ei_primary <- cw_ei_primary[!histid_1940 %in% dup_40_ei & !histid_1950 %in% dup_50_ei]
    cat(sprintf("EI crosswalk (%s): %s unique pairs (for robustness)\n",
        ei_method[1], format(nrow(cw_ei_primary), big.mark = ",")))
    saveRDS(cw_ei_primary, file.path(data_dir, "crosswalk_ei_unique.rds"))
  }
  rm(cw_ei); gc()
}

# Free full crosswalk, keep only primary unique pairs
rm(cw); gc()

# Sets for fast lookup
linked_histids_1940 <- cw_primary$histid_1940
linked_histids_1950 <- cw_primary$histid_1950


## --------------------------------------------------------------------------
## PASS 1: Process 1940 — state aggregates + extract linked individuals
## --------------------------------------------------------------------------

cat("\n=== PASS 1: 1940 Census ===\n")
dt40 <- readRDS(file.path(data_dir, "ipums_year_1940.rds"))
setalloccol(dt40)
construct_vars(dt40)
stopifnot("female" %in% names(dt40))
cat(sprintf("1940: %s records, %s\n", format(nrow(dt40), big.mark = ","),
    format(object.size(dt40), units = "GB")))
gc()

# State-level aggregates for 1940 (from FULL population)
cat("Computing 1940 state-level aggregates...\n")
dt40_wa <- dt40[age >= 18 & age <= 55]

agg_f_lf_40 <- dt40_wa[female == 1, weighted.mean(in_lf, perwt, na.rm = TRUE)]
agg_m_lf_40 <- dt40_wa[female == 0, weighted.mean(in_lf, perwt, na.rm = TRUE)]
agg_f_occ_40 <- dt40_wa[female == 1, weighted.mean(occ_score, perwt, na.rm = TRUE)]

state_gender_40 <- dt40_wa[, .(
  mean_lf = weighted.mean(in_lf, perwt, na.rm = TRUE),
  mean_occ = weighted.mean(occ_score, perwt, na.rm = TRUE),
  mean_sei = weighted.mean(sei_score, perwt, na.rm = TRUE),
  n = .N
), by = .(statefip, female)]
state_gender_40[, year := 1940L]

# Mobilization denominators (full-count male pop 18-44)
state_male_pop <- dt40[female == 0 & age >= 18 & age <= 44,
                       .(male_pop_18_44 = .N), by = statefip]

# State controls (from full-count)
state_controls <- dt40_wa[, .(
  pct_urban = mean(is_urban, na.rm = TRUE),
  pct_farm = mean(is_farm, na.rm = TRUE),
  pct_black = mean(race_cat == "Black", na.rm = TRUE),
  mean_educ = mean(educ_years, na.rm = TRUE),
  mean_age = mean(age, na.rm = TRUE),
  pct_married = mean(married, na.rm = TRUE),
  pct_in_lf_female = mean(in_lf[female == 1], na.rm = TRUE),
  total_pop = .N
), by = statefip]

rm(dt40_wa); gc()

# Extract LINKED individuals from 1940 using crosswalk
cat("Extracting 1940 linked individuals...\n")
setnames(dt40, "histid", "histid_1940", skip_absent = TRUE)

# Match on crosswalk histid_1940
setkey(dt40, histid_1940)
obs_1940 <- dt40[histid_1940 %chin% linked_histids_1940]
cat(sprintf("  Linked individuals in 1940: %s\n", format(nrow(obs_1940), big.mark = ",")))
cat(sprintf("  Women: %s, Men: %s\n",
    format(sum(obs_1940$female == 1), big.mark = ","),
    format(sum(obs_1940$female == 0), big.mark = ",")))

# Household-based spouse linkage (1940)
# For each linked person who is a household head, find their spouse
cat("Building 1940 household spouse linkage...\n")

# Get serial numbers of linked individuals who are heads
linked_heads_40 <- obs_1940[is_head == 1, .(histid_1940, serial_head = serial, statefip)]

# Find spouses in those households
# Spouses have relate == 2 (or is_spouse == 1) in the same household
spouses_40 <- dt40[is_spouse == 1 & serial %in% linked_heads_40$serial_head,
                    .(serial, histid_spouse_1940 = histid_1940,
                      sp_female_1940 = female, sp_age_1940 = age,
                      sp_in_lf_1940 = in_lf, sp_employed_1940 = employed,
                      sp_occ_score_1940 = occ_score, sp_sei_score_1940 = sei_score,
                      sp_educ_years_1940 = educ_years, sp_married_1940 = married,
                      sp_race_cat_1940 = race_cat, sp_perwt_1940 = perwt)]

# Merge: head's histid → spouse's attributes (using serial number)
couples_40 <- merge(linked_heads_40, spouses_40,
                    by.x = "serial_head", by.y = "serial", all.x = FALSE)
cat(sprintf("  Couples in 1940: %s (head linked, spouse found)\n",
    format(nrow(couples_40), big.mark = ",")))

# Linkage diagnostics: compare linked vs unlinked 1940 populations
cat("Building linkage diagnostics...\n")
diag_1940 <- dt40[age >= 18 & age <= 55,
                   .(linked = as.integer(histid_1940 %chin% linked_histids_1940),
                     female, race_cat, is_urban, age, in_lf,
                     occ_score, married, educ_years)]

linkage_balance <- diag_1940[, .(
  pct_female = mean(female),
  pct_white = mean(race_cat == "White"),
  pct_urban = mean(is_urban, na.rm = TRUE),
  mean_age = mean(age),
  pct_in_lf = mean(in_lf, na.rm = TRUE),
  mean_occ = mean(occ_score, na.rm = TRUE),
  pct_married = mean(married, na.rm = TRUE),
  mean_educ = mean(educ_years, na.rm = TRUE),
  N = .N
), by = linked]

cat("Linked vs Unlinked (1940 characteristics):\n")
print(linkage_balance)

rm(dt40, diag_1940); gc()
cat(sprintf("Memory after 1940 processing: ~%.1f GB in use\n",
    sum(sapply(ls(), function(x) object.size(get(x)))) / 1e9))


## --------------------------------------------------------------------------
## PASS 2: Process 1950 — state aggregates + extract linked individuals
## --------------------------------------------------------------------------

cat("\n=== PASS 2: 1950 Census ===\n")
dt50 <- readRDS(file.path(data_dir, "ipums_year_1950.rds"))
setalloccol(dt50)
construct_vars(dt50)
stopifnot("female" %in% names(dt50))
cat(sprintf("1950: %s records, %s\n", format(nrow(dt50), big.mark = ","),
    format(object.size(dt50), units = "GB")))
gc()

# State-level aggregates for 1950
cat("Computing 1950 state-level aggregates...\n")
dt50_wa <- dt50[age >= 18 & age <= 55]

agg_f_lf_50 <- dt50_wa[female == 1, weighted.mean(in_lf, perwt, na.rm = TRUE)]
agg_m_lf_50 <- dt50_wa[female == 0, weighted.mean(in_lf, perwt, na.rm = TRUE)]
agg_f_occ_50 <- dt50_wa[female == 1, weighted.mean(occ_score, perwt, na.rm = TRUE)]

state_gender_50 <- dt50_wa[, .(
  mean_lf = weighted.mean(in_lf, perwt, na.rm = TRUE),
  mean_occ = weighted.mean(occ_score, perwt, na.rm = TRUE),
  mean_sei = weighted.mean(sei_score, perwt, na.rm = TRUE),
  n = .N
), by = .(statefip, female)]
state_gender_50[, year := 1950L]

rm(dt50_wa); gc()

# Extract LINKED individuals from 1950 using crosswalk
cat("Extracting 1950 linked individuals...\n")
setnames(dt50, "histid", "histid_1950", skip_absent = TRUE)

setkey(dt50, histid_1950)
obs_1950 <- dt50[histid_1950 %chin% linked_histids_1950]
cat(sprintf("  Linked individuals in 1950: %s\n", format(nrow(obs_1950), big.mark = ",")))

# Household-based spouse linkage (1950)
cat("Building 1950 household spouse linkage...\n")

# We need serial numbers of the SAME linked individuals who were heads
# First find which of our linked 1950 individuals are heads
linked_heads_50_histids <- merge(
  cw_primary[, .(histid_1940, histid_1950)],
  linked_heads_40[, .(histid_1940)],
  by = "histid_1940"
)$histid_1950

linked_heads_50 <- obs_1950[histid_1950 %chin% linked_heads_50_histids,
                             .(histid_1950, serial_head = serial)]

spouses_50 <- dt50[is_spouse == 1 & serial %in% linked_heads_50$serial_head,
                    .(serial, histid_spouse_1950 = histid_1950,
                      sp_female_1950 = female, sp_age_1950 = age,
                      sp_in_lf_1950 = in_lf, sp_employed_1950 = employed,
                      sp_occ_score_1950 = occ_score, sp_sei_score_1950 = sei_score,
                      sp_educ_years_1950 = educ_years, sp_married_1950 = married,
                      sp_race_cat_1950 = race_cat, sp_perwt_1950 = perwt)]

couples_50 <- merge(linked_heads_50, spouses_50,
                    by.x = "serial_head", by.y = "serial", all.x = FALSE)
cat(sprintf("  Couples in 1950: %s (head linked, spouse found)\n",
    format(nrow(couples_50), big.mark = ",")))

rm(dt50); gc()


## --------------------------------------------------------------------------
## 3. Build Linked Individual Panel (1940-1950)
## --------------------------------------------------------------------------

cat("\n=== Building Linked Individual Panel ===\n")

# Prepare 1940 side
obs_1940_panel <- obs_1940[, .(
  histid_1940, statefip_1940 = statefip, age_1940 = age,
  female, race_cat, in_lf_1940 = in_lf,
  occ_score_1940 = occ_score, sei_score_1940 = sei_score,
  married_1940 = married, single_1940 = single,
  educ_years_1940 = educ_years, is_head_1940 = is_head,
  is_urban_1940 = is_urban, is_farm_1940 = is_farm,
  employed_1940 = employed, perwt_1940 = perwt)]

# Prepare 1950 side
obs_1950_panel <- obs_1950[, .(
  histid_1950, statefip_1950 = statefip, age_1950 = age,
  in_lf_1950 = in_lf, occ_score_1950 = occ_score,
  sei_score_1950 = sei_score, married_1950 = married,
  single_1950 = single, is_head_1950 = is_head,
  is_urban_1950 = is_urban, employed_1950 = employed,
  perwt_1950 = perwt)]

# Join via crosswalk
linked_40_50 <- merge(cw_primary, obs_1940_panel, by = "histid_1940")
linked_40_50 <- merge(linked_40_50, obs_1950_panel, by = "histid_1950")

cat(sprintf("\n*** LINKED 1940-1950 PANEL: %s individuals ***\n",
    format(nrow(linked_40_50), big.mark = ",")))
cat(sprintf("  Women: %s\n", format(sum(linked_40_50$female == 1), big.mark = ",")))
cat(sprintf("  Men:   %s\n", format(sum(linked_40_50$female == 0), big.mark = ",")))

# Age consistency check (should be ~10 years)
linked_40_50[, age_diff := age_1950 - age_1940]
cat("Age difference distribution (should be ~10):\n")
print(linked_40_50[, .(mean = mean(age_diff), sd = sd(age_diff),
                        p5 = quantile(age_diff, 0.05),
                        p50 = quantile(age_diff, 0.50),
                        p95 = quantile(age_diff, 0.95))])

# Flag bad age matches and remove
bad_age <- abs(linked_40_50$age_diff - 10) > 3
cat(sprintf("Removing %s individuals with age mismatch (|age_diff - 10| > 3)\n",
    format(sum(bad_age), big.mark = ",")))
linked_40_50 <- linked_40_50[!bad_age]
cat(sprintf("After age filter: %s individuals\n",
    format(nrow(linked_40_50), big.mark = ",")))

# Movers
linked_40_50[, mover := as.integer(statefip_1940 != statefip_1950)]
cat(sprintf("Interstate movers: %s (%.1f%%)\n",
    format(sum(linked_40_50$mover), big.mark = ","),
    100 * mean(linked_40_50$mover)))

# Within-person changes
linked_40_50[, `:=`(
  d_in_lf     = in_lf_1950 - in_lf_1940,
  d_occ_score = occ_score_1950 - occ_score_1940,
  d_sei_score = sei_score_1950 - sei_score_1940,
  d_married   = married_1950 - married_1940,
  d_head      = is_head_1950 - is_head_1940,
  d_employed  = employed_1950 - employed_1940,
  d_urban     = is_urban_1950 - is_urban_1940
)]


## --------------------------------------------------------------------------
## 4. Build Couples Panel (wives tracked through husbands' households)
## --------------------------------------------------------------------------

cat("\n=== Building Couples Panel ===\n")

# Join couples from 1940 and 1950 through the husband's crosswalk link
# couples_40: histid_1940 (husband) → spouse attributes in 1940
# couples_50: histid_1950 (husband) → spouse attributes in 1950
# cw_primary: histid_1940 → histid_1950

couples_panel <- merge(
  couples_40[, .(histid_1940, histid_spouse_1940, statefip,
                  sp_female_1940, sp_age_1940, sp_in_lf_1940,
                  sp_employed_1940, sp_occ_score_1940, sp_sei_score_1940,
                  sp_educ_years_1940, sp_married_1940, sp_race_cat_1940,
                  sp_perwt_1940)],
  cw_primary,
  by = "histid_1940"
)

couples_panel <- merge(
  couples_panel,
  couples_50[, .(histid_1950, histid_spouse_1950,
                  sp_female_1950, sp_age_1950, sp_in_lf_1950,
                  sp_employed_1950, sp_occ_score_1950, sp_sei_score_1950,
                  sp_educ_years_1950, sp_married_1950, sp_race_cat_1950,
                  sp_perwt_1950)],
  by = "histid_1950"
)

# Filter to female spouses in both years (husband → wife tracking)
couples_panel <- couples_panel[sp_female_1940 == 1 & sp_female_1950 == 1]

cat(sprintf("*** COUPLES PANEL: %s married couples tracked 1940-1950 ***\n",
    format(nrow(couples_panel), big.mark = ",")))

# Wife's within-person changes (through household linkage)
couples_panel[, `:=`(
  wife_d_in_lf     = sp_in_lf_1950 - sp_in_lf_1940,
  wife_d_employed  = sp_employed_1950 - sp_employed_1940,
  wife_d_occ_score = sp_occ_score_1950 - sp_occ_score_1940,
  wife_d_sei_score = sp_sei_score_1950 - sp_sei_score_1940,
  wife_age_1940    = sp_age_1940,
  wife_age_1950    = sp_age_1950
)]

# Rename for clarity
setnames(couples_panel, "statefip", "statefip_1940")


## --------------------------------------------------------------------------
## 5. State-Level Mobilization Rates
## --------------------------------------------------------------------------

cat("\n=== State Mobilization Rates ===\n")

censoc_rds <- file.path(data_dir, "censoc_enlistment.rds")
if (file.exists(censoc_rds)) {
  censoc <- readRDS(censoc_rds)
  state_enlist <- censoc[!is.na(residence_state_fips) & residence_state_fips > 0,
                          .(n_enlisted = .N),
                          by = .(statefip = as.integer(residence_state_fips))]
  rm(censoc); gc()
} else {
  state_enlist <- data.table(statefip = integer(0), n_enlisted = integer(0))
}

state_mob <- merge(state_male_pop, state_enlist, by = "statefip", all.x = TRUE)
state_mob[is.na(n_enlisted), n_enlisted := 0]
state_mob[, mobilization_rate := n_enlisted / male_pop_18_44]
state_mob[, mob_std := as.numeric(scale(mobilization_rate))]
state_mob[, mob_quintile := paste0("Q", cut(rank(mobilization_rate),
          breaks = quantile(rank(mobilization_rate), probs = seq(0, 1, 0.2)),
          labels = FALSE, include.lowest = TRUE))]

cat(sprintf("States: %d\n", nrow(state_mob)))
print(state_mob[, .(mean = mean(mobilization_rate), sd = sd(mobilization_rate))])


## --------------------------------------------------------------------------
## 6. Merge Mobilization into Panels
## --------------------------------------------------------------------------

cat("\n=== Merging Mobilization ===\n")

# Individual panel
linked_40_50 <- merge(linked_40_50,
                       state_mob[, .(statefip, mobilization_rate, mob_quintile, mob_std)],
                       by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
linked_40_50 <- linked_40_50[!is.na(mobilization_rate)]
cat(sprintf("Individual panel with mobilization: %s\n",
    format(nrow(linked_40_50), big.mark = ",")))

# Couples panel
couples_panel <- merge(couples_panel,
                        state_mob[, .(statefip, mobilization_rate, mob_quintile, mob_std)],
                        by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
couples_panel <- couples_panel[!is.na(mobilization_rate)]
cat(sprintf("Couples panel with mobilization: %s\n",
    format(nrow(couples_panel), big.mark = ",")))

# Also merge husband's attributes from the individual panel
husband_attrs <- linked_40_50[female == 0, .(
  histid_1940,
  husband_age_1940 = age_1940, husband_in_lf_1940 = in_lf_1940,
  husband_employed_1940 = employed_1940, husband_occ_score_1940 = occ_score_1940,
  husband_in_lf_1950 = in_lf_1950, husband_employed_1950 = employed_1950,
  husband_occ_score_1950 = occ_score_1950,
  husband_d_in_lf = d_in_lf, husband_d_employed = d_employed)]

couples_panel <- merge(couples_panel, husband_attrs,
                        by = "histid_1940", all.x = TRUE)
cat(sprintf("Couples with husband attributes: %s\n",
    format(sum(!is.na(couples_panel$husband_age_1940)), big.mark = ",")))


## --------------------------------------------------------------------------
## 7. State-Level Analysis Dataset
## --------------------------------------------------------------------------

cat("\n=== State-Level Analysis ===\n")

state_gender_year <- rbind(state_gender_40, state_gender_50)

state_gap <- dcast(state_gender_year, statefip + year ~ female,
                   value.var = c("mean_lf", "mean_occ"),
                   fun.aggregate = mean, fill = NA)
setnames(state_gap, gsub("_0$", "_male", gsub("_1$", "_female", names(state_gap))))
state_gap[, lf_gap := mean_lf_female - mean_lf_male]

s40 <- state_gap[year == 1940, .(statefip, lf_f40 = mean_lf_female,
  lf_m40 = mean_lf_male, occ_f40 = mean_occ_female, gap40 = lf_gap)]
s50 <- state_gap[year == 1950, .(statefip, lf_f50 = mean_lf_female,
  lf_m50 = mean_lf_male, occ_f50 = mean_occ_female, gap50 = lf_gap)]

state_analysis <- merge(s40, s50, by = "statefip")
state_analysis[, `:=`(d_lf_female = lf_f50 - lf_f40,
                       d_lf_male = lf_m50 - lf_m40,
                       d_lf_gap = gap50 - gap40)]
state_analysis <- merge(state_analysis, state_mob, by = "statefip", all.x = TRUE)
state_analysis <- merge(state_analysis, state_controls, by = "statefip", all.x = TRUE)
state_analysis <- state_analysis[!is.na(mobilization_rate)]


## --------------------------------------------------------------------------
## 8. Decomposition Inputs
## --------------------------------------------------------------------------

cat("\n=== Decomposition Inputs ===\n")

# Within-person changes from linked men
within_m_d_lf <- linked_40_50[female == 0, mean(d_in_lf, na.rm = TRUE)]
within_m_d_occ <- linked_40_50[female == 0, mean(d_occ_score, na.rm = TRUE)]

# Within-couple wife changes
within_wife_d_lf <- couples_panel[, mean(wife_d_in_lf, na.rm = TRUE)]
within_wife_d_occ <- couples_panel[, mean(wife_d_occ_score, na.rm = TRUE)]

decomp_inputs <- list(
  agg_f_lf_40 = agg_f_lf_40, agg_f_lf_50 = agg_f_lf_50,
  agg_m_lf_40 = agg_m_lf_40, agg_m_lf_50 = agg_m_lf_50,
  agg_f_occ_40 = agg_f_occ_40, agg_f_occ_50 = agg_f_occ_50,
  within_m_d_lf = within_m_d_lf,
  within_m_d_occ = within_m_d_occ,
  within_wife_d_lf = within_wife_d_lf,
  within_wife_d_occ = within_wife_d_occ,
  n_linked_individuals = nrow(linked_40_50),
  n_linked_men = sum(linked_40_50$female == 0),
  n_linked_women = sum(linked_40_50$female == 1),
  n_couples = nrow(couples_panel)
)

d_agg_f <- decomp_inputs$agg_f_lf_50 - decomp_inputs$agg_f_lf_40
cat(sprintf("Aggregate LFP change (women):        %.4f\n", d_agg_f))
cat(sprintf("Within-couple wife LFP change:       %.4f\n", within_wife_d_lf))
cat(sprintf("Within-person men LFP change:        %.4f\n", within_m_d_lf))
cat(sprintf("Compositional residual (women):      %.4f\n", d_agg_f - within_wife_d_lf))


## --------------------------------------------------------------------------
## 9. Save All Outputs
## --------------------------------------------------------------------------

cat("\n=== Saving ===\n")

saveRDS(linked_40_50, file.path(data_dir, "linked_panel_40_50.rds"))
saveRDS(couples_panel, file.path(data_dir, "couples_panel_40_50.rds"))
saveRDS(state_mob, file.path(data_dir, "state_mobilization.rds"))
saveRDS(state_analysis, file.path(data_dir, "state_analysis.rds"))
saveRDS(state_gender_year, file.path(data_dir, "state_gender_year.rds"))
saveRDS(state_controls, file.path(data_dir, "state_controls.rds"))
saveRDS(linkage_balance, file.path(data_dir, "linkage_diagnostics.rds"))
saveRDS(decomp_inputs, file.path(data_dir, "decomposition_inputs.rds"))
saveRDS(cw_primary, file.path(data_dir, "crosswalk_primary_unique.rds"))


track_info <- list(
  n_states = nrow(state_analysis),
  n_linked_40_50 = nrow(linked_40_50),
  n_linked_men = sum(linked_40_50$female == 0),
  n_linked_women = sum(linked_40_50$female == 1),
  n_couples = nrow(couples_panel),
  years = c(1940, 1950),
  linking_method = primary_method,
  crosswalk_source = "Census Linking Project (Abramitzky et al. 2025)"
)
saveRDS(track_info, file.path(data_dir, "track_info.rds"))

cat(sprintf("\n=== DONE ===\n"))
cat(sprintf("Individual panel (1940-1950): %s individuals\n",
    format(nrow(linked_40_50), big.mark = ",")))
cat(sprintf("  Women: %s, Men: %s\n",
    format(sum(linked_40_50$female == 1), big.mark = ","),
    format(sum(linked_40_50$female == 0), big.mark = ",")))
cat(sprintf("Couples panel: %s married couples\n",
    format(nrow(couples_panel), big.mark = ",")))
cat(sprintf("States with mobilization: %d\n", nrow(state_analysis)))
cat(sprintf("Linking method: %s\n", primary_method))
cat(sprintf("Source: Census Linking Project (doi:10.7910/DVN/DXHTEQ)\n"))
