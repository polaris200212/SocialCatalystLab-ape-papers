## ============================================================================
## 02_clean_data.R — Panel Construction from MLP Linked Data
## Missing Men, Rising Women v3 (apep_0469)
## ============================================================================
## Uses pre-built MLP linked panels from Azure (read in 01_fetch_data.R).
## Constructs:
##   - linked_panel_40_50.rds   : 2-period individual panel (men + women)
##   - couples_panel_40_50.rds  : Married couples tracked through households
##   - linked_panel_30_40_50.rds: 3-period individual panel (pre-trend)
##   - couples_panel_30_40_50.rds: 3-period couples panel (pre-trend)
##   - married_women_aggregate.rds: Full-count married-women LFP by state/year
##   - selection_diagnostics.rds: IPW weights + linkage balance
##   - state_analysis.rds       : State-level aggregates
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"

cat("=== MLP Panel Construction (v3: 3-Wave Design) ===\n")
cat(sprintf("Available RAM: %.0f GB\n",
    as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1e9))


## --------------------------------------------------------------------------
## Helper: Year-specific variable constructors
## --------------------------------------------------------------------------

#' Construct derived variables for 1930 census data
#' 1930 has CLASSWKR but NO EMPSTAT, EDUC, or INCWAGE
#' Uses set() to avoid data.table NSE/scoping issues on large tables
construct_vars_1930 <- function(dt, suffix = "_1930") {
  nm <- names(dt)
  n <- nrow(dt)

  # LFP from CLASSWKR > 0 ("gainful employment" — standard in econ history)
  classwkr_col <- paste0("classwkr", suffix)
  if (classwkr_col %in% nm) {
    set(dt, j = paste0("in_lf", suffix), value = as.integer(dt[[classwkr_col]] > 0))
  }

  sex_col <- paste0("sex", suffix)
  if (sex_col %in% nm) {
    set(dt, j = paste0("female", suffix), value = as.integer(dt[[sex_col]] == 2))
  }

  marst_col <- paste0("marst", suffix)
  if (marst_col %in% nm) {
    set(dt, j = paste0("married", suffix), value = as.integer(dt[[marst_col]] %in% c(1, 2)))
  }

  race_col <- paste0("race", suffix)
  if (race_col %in% nm) {
    rv <- dt[[race_col]]
    set(dt, j = paste0("race_cat", suffix),
        value = fifelse(rv == 1, "White", fifelse(rv == 2, "Black", "Other")))
  }

  farm_col <- paste0("farm", suffix)
  if (farm_col %in% nm) {
    set(dt, j = paste0("is_farm", suffix), value = as.integer(dt[[farm_col]] == 2))
  }

  occscore_col <- paste0("occscore", suffix)
  if (occscore_col %in% nm) {
    ov <- dt[[occscore_col]]
    set(dt, j = paste0("occ_score", suffix), value = fifelse(ov > 0, as.numeric(ov), NA_real_))
  }

  sei_col <- paste0("sei", suffix)
  if (sei_col %in% nm) {
    sv <- dt[[sei_col]]
    set(dt, j = paste0("sei_score", suffix), value = fifelse(sv > 0, as.numeric(sv), NA_real_))
  }

  invisible(dt)
}

#' Construct derived variables for 1940 census data
#' 1940 has EMPSTAT, EDUC, INCWAGE, SEI
construct_vars_1940 <- function(dt, suffix = "_1940") {
  nm <- names(dt)

  empstat_col <- paste0("empstat", suffix)
  if (empstat_col %in% nm) {
    ev <- dt[[empstat_col]]
    set(dt, j = paste0("in_lf", suffix), value = as.integer(ev %in% c(1, 2)))
    set(dt, j = paste0("employed", suffix), value = as.integer(ev == 1))
  }

  sex_col <- paste0("sex", suffix)
  if (sex_col %in% nm) {
    set(dt, j = paste0("female", suffix), value = as.integer(dt[[sex_col]] == 2))
  }

  marst_col <- paste0("marst", suffix)
  if (marst_col %in% nm) {
    set(dt, j = paste0("married", suffix), value = as.integer(dt[[marst_col]] %in% c(1, 2)))
  }

  race_col <- paste0("race", suffix)
  if (race_col %in% nm) {
    rv <- dt[[race_col]]
    set(dt, j = paste0("race_cat", suffix),
        value = fifelse(rv == 1, "White", fifelse(rv == 2, "Black", "Other")))
  }

  farm_col <- paste0("farm", suffix)
  if (farm_col %in% nm) {
    set(dt, j = paste0("is_farm", suffix), value = as.integer(dt[[farm_col]] == 2))
  }

  occscore_col <- paste0("occscore", suffix)
  if (occscore_col %in% nm) {
    ov <- dt[[occscore_col]]
    set(dt, j = paste0("occ_score", suffix), value = fifelse(ov > 0, as.numeric(ov), NA_real_))
  }

  sei_col <- paste0("sei", suffix)
  if (sei_col %in% nm) {
    sv <- dt[[sei_col]]
    set(dt, j = paste0("sei_score", suffix), value = fifelse(sv > 0, as.numeric(sv), NA_real_))
  }

  educ_col <- paste0("educ", suffix)
  if (educ_col %in% nm) {
    educ_v <- dt[[educ_col]]
    set(dt, j = paste0("educ_years", suffix), value = fcase(
      educ_v == 0 | is.na(educ_v), NA_real_,
      educ_v == 1, 0,  educ_v == 2, 2.5, educ_v == 3, 6.5, educ_v == 4, 9,
      educ_v == 5, 10, educ_v == 6, 11,  educ_v == 7, 12,  educ_v == 8, 13,
      educ_v == 9, 14, educ_v == 10, 15, educ_v == 11, 16, educ_v >= 12, 17))
  }

  invisible(dt)
}

#' Construct derived variables for 1950 census data
#' 1950 has EMPSTAT, EDUC, INCWAGE but NO SEI
construct_vars_1950 <- function(dt, suffix = "_1950") {
  nm <- names(dt)

  empstat_col <- paste0("empstat", suffix)
  if (empstat_col %in% nm) {
    ev <- dt[[empstat_col]]
    set(dt, j = paste0("in_lf", suffix), value = as.integer(ev %in% c(1, 2)))
    set(dt, j = paste0("employed", suffix), value = as.integer(ev == 1))
  }

  sex_col <- paste0("sex", suffix)
  if (sex_col %in% nm) {
    set(dt, j = paste0("female", suffix), value = as.integer(dt[[sex_col]] == 2))
  }

  marst_col <- paste0("marst", suffix)
  if (marst_col %in% nm) {
    set(dt, j = paste0("married", suffix), value = as.integer(dt[[marst_col]] %in% c(1, 2)))
  }

  race_col <- paste0("race", suffix)
  if (race_col %in% nm) {
    rv <- dt[[race_col]]
    set(dt, j = paste0("race_cat", suffix),
        value = fifelse(rv == 1, "White", fifelse(rv == 2, "Black", "Other")))
  }

  farm_col <- paste0("farm", suffix)
  if (farm_col %in% nm) {
    set(dt, j = paste0("is_farm", suffix), value = as.integer(dt[[farm_col]] == 2))
  }

  occscore_col <- paste0("occscore", suffix)
  if (occscore_col %in% nm) {
    ov <- dt[[occscore_col]]
    set(dt, j = paste0("occ_score", suffix), value = fifelse(ov > 0, as.numeric(ov), NA_real_))
  }

  educ_col <- paste0("educ", suffix)
  if (educ_col %in% nm) {
    educ_v <- dt[[educ_col]]
    set(dt, j = paste0("educ_years", suffix), value = fcase(
      educ_v == 0 | is.na(educ_v), NA_real_,
      educ_v == 1, 0,  educ_v == 2, 2.5, educ_v == 3, 6.5, educ_v == 4, 9,
      educ_v == 5, 10, educ_v == 6, 11,  educ_v == 7, 12,  educ_v == 8, 13,
      educ_v == 9, 14, educ_v == 10, 15, educ_v == 11, 16, educ_v >= 12, 17))
  }

  invisible(dt)
}


## --------------------------------------------------------------------------
## 1. Load and Process 2-Period Panel (1940-1950)
## --------------------------------------------------------------------------

cat("\n=== Processing 1940-1950 Individual Panel ===\n")

dt <- readRDS(file.path(data_dir, "mlp_linked_40_50.rds"))
setDT(dt)  # Restore data.table internal self-reference after deserialization
alloc.col(dt, ncol(dt) + 30L)  # Pre-allocate column slots
cat(sprintf("Raw MLP 1940-1950: %s rows\n", format(nrow(dt), big.mark = ",")))

# Construct derived variables
construct_vars_1940(dt)
construct_vars_1950(dt)

# Filter to working-age (18-55 in 1940)
dt <- dt[age_1940 >= 18 & age_1940 <= 55]
cat(sprintf("After age filter (18-55 in 1940): %s rows\n", format(nrow(dt), big.mark = ",")))
cat(sprintf("  Post-filter in_lf cols: %s\n", paste(grep("in_lf", names(dt), value = TRUE), collapse = ", ")))

# Within-person changes
dt[, `:=`(
  d_in_lf     = in_lf_1950 - in_lf_1940,
  d_occ_score = occ_score_1950 - occ_score_1940,
  d_employed  = employed_1950 - employed_1940,
  d_married   = married_1950 - married_1940
)]

# Age group for analysis
dt[, age_group := fcase(
  age_1940 >= 18 & age_1940 <= 25, "18-25",
  age_1940 >= 26 & age_1940 <= 35, "26-35",
  age_1940 >= 36 & age_1940 <= 45, "36-45",
  age_1940 >= 46 & age_1940 <= 55, "46-55")]

cat(sprintf("  Men: %s, Women: %s\n",
    format(sum(dt$female_1940 == 0, na.rm = TRUE), big.mark = ","),
    format(sum(dt$female_1940 == 1, na.rm = TRUE), big.mark = ",")))

# Save individual panel
linked_panel <- dt
rm(dt)  # Remove duplicate reference; linked_panel holds the data
saveRDS(linked_panel, file.path(data_dir, "linked_panel_40_50.rds"))
cat("Saved linked_panel_40_50.rds\n")


## --------------------------------------------------------------------------
## 2. Build Couples Panel (1940-1950)
## --------------------------------------------------------------------------

cat("\n=== Building Couples Panel (1940-1950) ===\n")

# Men who are household heads in 1940
# Note: SEI not available in the pre-built 1940-1950 linked data
heads_cols <- c("histid_1940", "serial_1940", "statefip_1940", "age_1940",
  "in_lf_1940", "employed_1940", "occ_score_1940",
  "educ_years_1940", "married_1940", "race_cat_1940",
  "histid_1950", "serial_1950", "statefip_1950", "age_1950",
  "in_lf_1950", "employed_1950", "occ_score_1950",
  "educ_years_1950", "married_1950",
  "mover", "age_group", "d_in_lf", "d_occ_score", "d_employed")
if ("sei_score_1940" %in% names(linked_panel)) heads_cols <- c(heads_cols, "sei_score_1940")
heads_cols <- intersect(heads_cols, names(linked_panel))
heads_40 <- linked_panel[female_1940 == 0 & relate_1940 == 1, ..heads_cols]
if ("mover" %in% names(heads_40)) setnames(heads_40, "mover", "mover_40_50")

# Find spouses in 1940 (RELATE == 2, same household SERIAL)
sp_cols_40 <- c("serial_1940", "age_1940", "in_lf_1940", "employed_1940",
  "occ_score_1940", "educ_years_1940", "race_cat_1940", "perwt_1940")
if ("sei_score_1940" %in% names(linked_panel)) sp_cols_40 <- c(sp_cols_40, "sei_score_1940")
sp_cols_40 <- intersect(sp_cols_40, names(linked_panel))
spouses_40 <- linked_panel[relate_1940 == 2 & female_1940 == 1, ..sp_cols_40]
# Rename spouse columns
sp_rename <- setdiff(names(spouses_40), "serial_1940")
setnames(spouses_40, sp_rename, paste0("sp_", sp_rename))

# Merge: head -> spouse in 1940
couples_40 <- merge(heads_40, spouses_40, by = "serial_1940", all.x = FALSE)
cat(sprintf("  Couples matched in 1940: %s\n", format(nrow(couples_40), big.mark = ",")))

# Find spouses in 1950 (same approach via SERIAL_1950)
sp_cols_50 <- c("serial_1950", "age_1950", "in_lf_1950", "employed_1950",
  "occ_score_1950", "educ_years_1950", "race_cat_1950", "perwt_1950")
sp_cols_50 <- intersect(sp_cols_50, names(linked_panel))
spouses_50 <- linked_panel[relate_1950 == 2 & female_1950 == 1, ..sp_cols_50]
sp_rename_50 <- setdiff(names(spouses_50), "serial_1950")
setnames(spouses_50, sp_rename_50, paste0("sp_", sp_rename_50))

# Merge 1950 spouse
couples_panel <- merge(couples_40, spouses_50, by = "serial_1950", all.x = FALSE)
cat(sprintf("  Couples matched in both years: %s\n", format(nrow(couples_panel), big.mark = ",")))

# Wife's within-person changes (only compute diffs for cols that exist)
if (all(c("sp_in_lf_1950", "sp_in_lf_1940") %in% names(couples_panel))) {
  couples_panel[, wife_d_in_lf := sp_in_lf_1950 - sp_in_lf_1940]
}
if (all(c("sp_employed_1950", "sp_employed_1940") %in% names(couples_panel))) {
  couples_panel[, wife_d_employed := sp_employed_1950 - sp_employed_1940]
}
if (all(c("sp_occ_score_1950", "sp_occ_score_1940") %in% names(couples_panel))) {
  couples_panel[, wife_d_occ_score := sp_occ_score_1950 - sp_occ_score_1940]
}
if ("sp_age_1940" %in% names(couples_panel)) couples_panel[, wife_age_1940 := sp_age_1940]
if ("sp_age_1950" %in% names(couples_panel)) couples_panel[, wife_age_1950 := sp_age_1950]

# Rename husband columns for clarity (only rename columns that exist)
rename_if_exists <- function(dt, old, new) {
  exists_mask <- old %in% names(dt)
  if (any(exists_mask)) setnames(dt, old[exists_mask], new[exists_mask])
}
rename_if_exists(couples_panel,
  c("d_in_lf", "d_employed", "d_occ_score"),
  c("husband_d_in_lf", "husband_d_employed", "husband_d_occ_score"))
rename_if_exists(couples_panel,
  c("age_1940", "in_lf_1940", "employed_1940", "occ_score_1940"),
  c("husband_age_1940", "husband_in_lf_1940", "husband_employed_1940", "husband_occ_score_1940"))
rename_if_exists(couples_panel,
  c("in_lf_1950", "employed_1950", "occ_score_1950"),
  c("husband_in_lf_1950", "husband_employed_1950", "husband_occ_score_1950"))

saveRDS(couples_panel, file.path(data_dir, "couples_panel_40_50.rds"))
cat(sprintf("Saved couples_panel_40_50.rds: %s couples\n",
    format(nrow(couples_panel), big.mark = ",")))

# Free intermediates from couples construction
rm(heads_40, spouses_40, couples_40, spouses_50)
gc()


## --------------------------------------------------------------------------
## 3. Load and Process 3-Period Panel (1930-1940-1950) — Pre-Trend
## --------------------------------------------------------------------------

cat("\n=== Processing 1930-1940-1950 Individual Panel ===\n")

dt3 <- readRDS(file.path(data_dir, "mlp_linked_30_40_50.rds"))
setDT(dt3)  # Restore data.table internal self-reference
alloc.col(dt3, ncol(dt3) + 40L)
cat(sprintf("Raw MLP 1930-1940-1950: %s rows\n", format(nrow(dt3), big.mark = ",")))

# Construct derived variables for all 3 periods
construct_vars_1930(dt3)
construct_vars_1940(dt3)
construct_vars_1950(dt3)

# Filter to working-age in 1940 (18-55) => 8-45 in 1930, 28-65 in 1950
dt3 <- dt3[age_1940 >= 18 & age_1940 <= 55]
cat(sprintf("After age filter (18-55 in 1940): %s rows\n", format(nrow(dt3), big.mark = ",")))

# Within-person changes for BOTH periods
dt3[, `:=`(
  # 1930->1940 (pre-trend / placebo period)
  d_in_lf_30_40     = in_lf_1940 - in_lf_1930,
  d_occ_score_30_40 = occ_score_1940 - occ_score_1930,
  # 1940->1950 (treatment period)
  d_in_lf_40_50     = in_lf_1950 - in_lf_1940,
  d_occ_score_40_50 = occ_score_1950 - occ_score_1940
)]

dt3[, age_group := fcase(
  age_1940 >= 18 & age_1940 <= 25, "18-25",
  age_1940 >= 26 & age_1940 <= 35, "26-35",
  age_1940 >= 36 & age_1940 <= 45, "36-45",
  age_1940 >= 46 & age_1940 <= 55, "46-55")]

cat(sprintf("  Men: %s, Women: %s\n",
    format(sum(dt3$female_1940 == 0, na.rm = TRUE), big.mark = ","),
    format(sum(dt3$female_1940 == 1, na.rm = TRUE), big.mark = ",")))

saveRDS(dt3, file.path(data_dir, "linked_panel_30_40_50.rds"))
cat("Saved linked_panel_30_40_50.rds\n")


## --------------------------------------------------------------------------
## 4. Build 3-Period Couples Panel (for pre-trend on wives)
## --------------------------------------------------------------------------

cat("\n=== Building 3-Period Couples Panel ===\n")

# Track husband -> wife in 1930, 1940, and 1950
# Husband must be head in 1940 (our anchor year)
heads3_40 <- dt3[female_1940 == 0 & relate_1940 == 1,
  .(histid_1930, histid_1940, histid_1950,
    serial_1930, serial_1940, serial_1950,
    statefip_1940, husband_age_1940 = age_1940,
    husband_in_lf_1930 = in_lf_1930, husband_in_lf_1940 = in_lf_1940, husband_in_lf_1950 = in_lf_1950,
    husband_occ_score_1940 = occ_score_1940,
    d_in_lf_30_40, d_in_lf_40_50, mover_40_50, age_group)]

# Spouse in 1940
sp3_40 <- dt3[relate_1940 == 2 & female_1940 == 1,
  .(serial_1940, sp_age_1940 = age_1940,
    sp_in_lf_1940 = in_lf_1940, sp_educ_years_1940 = educ_years_1940,
    sp_race_cat_1940 = race_cat_1940)]

# Spouse in 1930 (via SERIAL_1930)
sp3_30 <- dt3[relate_1930 == 2 & female_1930 == 1,
  .(serial_1930, sp_in_lf_1930 = in_lf_1930, sp_age_1930 = age_1930)]

# Spouse in 1950 (via SERIAL_1950)
sp3_50 <- dt3[relate_1950 == 2 & female_1950 == 1,
  .(serial_1950, sp_in_lf_1950 = in_lf_1950, sp_age_1950 = age_1950)]

# Chain merges
couples3 <- merge(heads3_40, sp3_40, by = "serial_1940", all.x = FALSE)
couples3 <- merge(couples3, sp3_30, by = "serial_1930", all.x = FALSE)
couples3 <- merge(couples3, sp3_50, by = "serial_1950", all.x = FALSE)

# Wife's changes for both periods
couples3[, `:=`(
  wife_d_in_lf_30_40 = sp_in_lf_1940 - sp_in_lf_1930,
  wife_d_in_lf_40_50 = sp_in_lf_1950 - sp_in_lf_1940
)]

cat(sprintf("  3-period couples (1930-1940-1950): %s\n",
    format(nrow(couples3), big.mark = ",")))

saveRDS(couples3, file.path(data_dir, "couples_panel_30_40_50.rds"))
cat("Saved couples_panel_30_40_50.rds\n")

rm(dt3, heads3_40, sp3_30, sp3_40, sp3_50, couples3); gc()


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

# Male pop 18-44 from linked panel (use full 1940 pop from Azure aggregates)
# We compute from our panel as a denominator proxy
state_male_pop <- linked_panel[female_1940 == 0 & age_1940 >= 18 & age_1940 <= 44,
                               .(male_pop_18_44 = .N), by = statefip_1940]
setnames(state_male_pop, "statefip_1940", "statefip")

state_mob <- merge(state_male_pop, state_enlist, by = "statefip", all.x = TRUE)
state_mob[is.na(n_enlisted), n_enlisted := 0]
state_mob[, mobilization_rate := n_enlisted / male_pop_18_44]
state_mob[, mob_std := as.numeric(scale(mobilization_rate))]
state_mob[, mob_quintile := paste0("Q", cut(rank(mobilization_rate),
          breaks = quantile(rank(mobilization_rate), probs = seq(0, 1, 0.2)),
          labels = FALSE, include.lowest = TRUE))]

cat(sprintf("States: %d\n", nrow(state_mob)))
print(state_mob[, .(mean = mean(mobilization_rate), sd = sd(mobilization_rate))])
saveRDS(state_mob, file.path(data_dir, "state_mobilization.rds"))


## --------------------------------------------------------------------------
## 6. Merge Mobilization into All Panels
## --------------------------------------------------------------------------

cat("\n=== Merging Mobilization ===\n")

mob_cols <- state_mob[, .(statefip, mobilization_rate, mob_quintile, mob_std)]

# Individual panel (1940-1950)
linked_panel <- merge(linked_panel, mob_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
linked_panel <- linked_panel[!is.na(mobilization_rate)]
cat(sprintf("Individual panel with mob: %s\n", format(nrow(linked_panel), big.mark = ",")))
saveRDS(linked_panel, file.path(data_dir, "linked_panel_40_50.rds"))

# Couples panel (1940-1950)
couples_panel <- merge(couples_panel, mob_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
couples_panel <- couples_panel[!is.na(mobilization_rate)]
cat(sprintf("Couples panel with mob: %s\n", format(nrow(couples_panel), big.mark = ",")))
saveRDS(couples_panel, file.path(data_dir, "couples_panel_40_50.rds"))

# Free 2-period panels before loading 3-period (memory management)
rm(linked_panel, couples_panel); gc()
cat("  (Freed 2-period panels from memory)\n")

# 3-period individual panel
panel3 <- readRDS(file.path(data_dir, "linked_panel_30_40_50.rds"))
setDT(panel3); alloc.col(panel3, ncol(panel3) + 10L)
panel3 <- merge(panel3, mob_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
panel3 <- panel3[!is.na(mobilization_rate)]
saveRDS(panel3, file.path(data_dir, "linked_panel_30_40_50.rds"))
cat(sprintf("3-period panel with mob: %s\n", format(nrow(panel3), big.mark = ",")))
rm(panel3); gc()

# 3-period couples panel
couples3 <- readRDS(file.path(data_dir, "couples_panel_30_40_50.rds"))
setDT(couples3); alloc.col(couples3, ncol(couples3) + 10L)
couples3 <- merge(couples3, mob_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
couples3 <- couples3[!is.na(mobilization_rate)]
saveRDS(couples3, file.path(data_dir, "couples_panel_30_40_50.rds"))
cat(sprintf("3-period couples with mob: %s\n", format(nrow(couples3), big.mark = ",")))
rm(couples3); gc()

# Reload 2-period panels (with mob merged) for IPW and analysis sections
cat("\n--- Reloading 2-period panels for IPW/analysis ---\n")
linked_panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
setDT(linked_panel); alloc.col(linked_panel, ncol(linked_panel) + 20L)
couples_panel <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
setDT(couples_panel); alloc.col(couples_panel, ncol(couples_panel) + 10L)
gc()


## --------------------------------------------------------------------------
## 7. IPW Weights (Cell-Based)
## --------------------------------------------------------------------------

cat("\n=== Building IPW Weights ===\n")

pop_denom <- readRDS(file.path(data_dir, "population_denominators.rds"))

# Count linked individuals by cell (state × race × sex × age_group) in 1940
linked_cells <- linked_panel[, .(n_linked = .N),
  by = .(statefip = statefip_1940, sex = sex_1940, race = race_1940, age_group)]

# Full-count population cells for 1940
pop_1940 <- pop_denom[year == 1940, .(statefip, sex, race, age_group, n_pop)]

# Merge and compute linkage probability
ipw_cells <- merge(pop_1940, linked_cells, by = c("statefip", "sex", "race", "age_group"), all.x = TRUE)
ipw_cells[is.na(n_linked), n_linked := 0]
ipw_cells[, link_prob := n_linked / n_pop]
ipw_cells[link_prob > 0, ipw := 1 / link_prob]
ipw_cells[link_prob == 0, ipw := 0]

# Cap extreme weights at 99th percentile
cap <- quantile(ipw_cells[ipw > 0]$ipw, 0.99, na.rm = TRUE)
ipw_cells[ipw > cap, ipw := cap]

cat(sprintf("  IPW cells: %d, mean linkage prob = %.4f\n",
    nrow(ipw_cells), mean(ipw_cells$link_prob, na.rm = TRUE)))

# Merge IPW into individual panel
linked_panel <- merge(linked_panel,
  ipw_cells[, .(statefip, sex, race, age_group, ipw)],
  by.x = c("statefip_1940", "sex_1940", "race_1940", "age_group"),
  by.y = c("statefip", "sex", "race", "age_group"),
  all.x = TRUE)
linked_panel[is.na(ipw), ipw := 1]

saveRDS(linked_panel, file.path(data_dir, "linked_panel_40_50.rds"))

# Also merge into couples panel (use husband's cell)
# Convert numeric race to race_cat to match couples_panel's character column
ipw_husband_dt <- ipw_cells[sex == 1]
ipw_husband_dt[, race_cat := fifelse(race == 1, "White", fifelse(race == 2, "Black", "Other"))]
ipw_husband_agg <- ipw_husband_dt[, .(ipw_husband = mean(ipw, na.rm = TRUE)),
                                    by = .(statefip, race_cat, age_group)]
couples_panel <- merge(couples_panel, ipw_husband_agg,
  by.x = c("statefip_1940", "race_cat_1940", "age_group"),
  by.y = c("statefip", "race_cat", "age_group"),
  all.x = TRUE)
couples_panel[is.na(ipw_husband), ipw_husband := 1]
rm(ipw_husband_dt, ipw_husband_agg)

saveRDS(couples_panel, file.path(data_dir, "couples_panel_40_50.rds"))
saveRDS(ipw_cells, file.path(data_dir, "ipw_cells.rds"))


## --------------------------------------------------------------------------
## 8. State-Level Analysis Dataset
## --------------------------------------------------------------------------

cat("\n=== State-Level Analysis ===\n")

# Married-women aggregate LFP
mw_agg <- readRDS(file.path(data_dir, "married_women_aggregate.rds"))
mw_40 <- mw_agg[year == 1940, .(statefip, mw_lfp_40 = lfp_married_women, n_mw_40 = n_married_women)]
mw_50 <- mw_agg[year == 1950, .(statefip, mw_lfp_50 = lfp_married_women, n_mw_50 = n_married_women)]

# All-women aggregate LFP
aw <- readRDS(file.path(data_dir, "allwomen_aggregate.rds"))
aw_40 <- aw[year == 1940, .(statefip, aw_lfp_40 = lfp_all_women, n_aw_40 = n_all_women)]
aw_50 <- aw[year == 1950, .(statefip, aw_lfp_50 = lfp_all_women, n_aw_50 = n_all_women)]

# State-level within-couple means
state_within <- couples_panel[, .(
  within_wife_d_lf = mean(wife_d_in_lf, na.rm = TRUE),
  within_husband_d_lf = mean(husband_d_in_lf, na.rm = TRUE),
  n_couples = .N
), by = statefip_1940]
setnames(state_within, "statefip_1940", "statefip")

# State controls from full-count (read from existing if available)
# Compute from linked panel as fallback
state_controls <- linked_panel[age_1940 >= 18 & age_1940 <= 55, .(
  pct_urban = 0,  # URBAN not available in MLP parquet — will be NA
  pct_farm = mean(is_farm_1940, na.rm = TRUE),
  pct_black = mean(race_cat_1940 == "Black", na.rm = TRUE),
  mean_educ = mean(educ_years_1940, na.rm = TRUE),
  mean_age = mean(age_1940, na.rm = TRUE),
  pct_married = mean(married_1940, na.rm = TRUE),
  total_pop = .N
), by = statefip_1940]
setnames(state_controls, "statefip_1940", "statefip")

# Combine all state data
state_analysis <- Reduce(function(x, y) merge(x, y, by = "statefip", all.x = TRUE),
  list(state_mob, mw_40, mw_50, aw_40, aw_50, state_within, state_controls))

state_analysis[, `:=`(
  d_mw_lfp = mw_lfp_50 - mw_lfp_40,
  d_aw_lfp = aw_lfp_50 - aw_lfp_40
)]

state_analysis <- state_analysis[!is.na(mobilization_rate)]
cat(sprintf("State analysis: %d states\n", nrow(state_analysis)))

saveRDS(state_analysis, file.path(data_dir, "state_analysis.rds"))
saveRDS(state_controls, file.path(data_dir, "state_controls.rds"))


## --------------------------------------------------------------------------
## 9. Selection Diagnostics
## --------------------------------------------------------------------------

cat("\n=== Selection Diagnostics ===\n")

# Linkage rate vs mobilization (should be null)
link_diag <- readRDS(file.path(data_dir, "link_diagnostics.rds"))
cat(sprintf("  Link diagnostics: %s rows\n", format(nrow(link_diag), big.mark = ",")))

# Balance table: linked panel vs population denominators
pop_1940_totals <- pop_denom[year == 1940, .(n_pop = sum(n_pop)), by = .(statefip, sex)]
linked_totals <- linked_panel[, .(n_linked = .N), by = .(statefip = statefip_1940, sex = sex_1940)]
link_rates <- merge(pop_1940_totals, linked_totals, by = c("statefip", "sex"), all.x = TRUE)
link_rates[is.na(n_linked), n_linked := 0]
link_rates[, link_rate := n_linked / n_pop]

# State-level link rate for men
state_link_rate <- link_rates[sex == 1, .(statefip, link_rate_men = link_rate)]

selection_diag <- list(
  ipw_cells = ipw_cells,
  state_link_rates = state_link_rate,
  link_rates_by_cell = link_rates
)
saveRDS(selection_diag, file.path(data_dir, "selection_diagnostics.rds"))
cat("Saved selection_diagnostics.rds\n")


## --------------------------------------------------------------------------
## 10. Decomposition Inputs
## --------------------------------------------------------------------------

cat("\n=== Decomposition Inputs ===\n")

# Within-couple wife changes
within_wife_d_lf <- couples_panel[, mean(wife_d_in_lf, na.rm = TRUE)]

# Within-person men changes
within_m_d_lf <- linked_panel[female_1940 == 0, mean(d_in_lf, na.rm = TRUE)]

# Married-women aggregate change (full-count)
agg_mw_40 <- mw_agg[year == 1940, weighted.mean(lfp_married_women, n_married_women)]
agg_mw_50 <- mw_agg[year == 1950, weighted.mean(lfp_married_women, n_married_women)]
agg_d_mw <- agg_mw_50 - agg_mw_40

# All-women aggregate change (full-count)
agg_aw_40 <- aw[year == 1940, weighted.mean(lfp_all_women, n_all_women)]
agg_aw_50 <- aw[year == 1950, weighted.mean(lfp_all_women, n_all_women)]
agg_d_aw <- agg_aw_50 - agg_aw_40

decomp_inputs <- list(
  # Aggregate changes
  agg_d_married_women = agg_d_mw,
  agg_d_all_women = agg_d_aw,
  agg_mw_lfp_1940 = agg_mw_40, agg_mw_lfp_1950 = agg_mw_50,
  agg_aw_lfp_1940 = agg_aw_40, agg_aw_lfp_1950 = agg_aw_50,
  # Within-person changes
  within_wife_d_lf = within_wife_d_lf,
  within_m_d_lf = within_m_d_lf,
  # Sizes
  n_linked_individuals = nrow(linked_panel),
  n_linked_men = sum(linked_panel$female_1940 == 0),
  n_couples = nrow(couples_panel)
)

cat(sprintf("Married-women aggregate change (1940-1950):  %.4f\n", agg_d_mw))
cat(sprintf("All-women aggregate change (1940-1950):      %.4f\n", agg_d_aw))
cat(sprintf("Within-couple wife LFP change:               %.4f\n", within_wife_d_lf))
cat(sprintf("Within-person men LFP change:                %.4f\n", within_m_d_lf))
cat(sprintf("Compositional gap (married women):           %.4f\n", agg_d_mw - within_wife_d_lf))
cat(sprintf("Compositional gap (all women):               %.4f\n", agg_d_aw - within_wife_d_lf))

saveRDS(decomp_inputs, file.path(data_dir, "decomposition_inputs.rds"))


## --------------------------------------------------------------------------
## Summary
## --------------------------------------------------------------------------

cat("\n=== DONE ===\n")
cat(sprintf("Individual panel (1940-1950):  %s\n", format(nrow(linked_panel), big.mark = ",")))
cat(sprintf("  Men: %s, Women: %s\n",
    format(sum(linked_panel$female_1940 == 0), big.mark = ","),
    format(sum(linked_panel$female_1940 == 1), big.mark = ",")))
cat(sprintf("Couples panel (1940-1950):     %s couples\n",
    format(nrow(couples_panel), big.mark = ",")))
cat(sprintf("3-period panel (1930-50):      present\n"))
cat(sprintf("States with mobilization:      %d\n", nrow(state_analysis)))
cat(sprintf("Linkage method:                MLP v2 (Helgertz et al. 2023)\n"))
