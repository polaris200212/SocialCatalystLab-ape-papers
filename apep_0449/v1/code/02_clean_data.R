## ============================================================================
## 02_clean_data.R — Construct RDD analysis dataset
## Merge election results with criminal background + nightlights outcomes
## ============================================================================
source("00_packages.R")

cat("\n========================================\n")
cat("DATA CONSTRUCTION\n")
cat("========================================\n\n")

SHRUG <- file.path(DATA_DIR, "shrug")

## ============================================================================
## 1. LOAD AND MERGE CANDIDATE + AFFIDAVIT DATA
## ============================================================================
cat("── 1. Loading Trivedi candidate data ──\n")
triv_cand <- as.data.table(haven::read_dta(
  file.path(SHRUG, "trivedi_candidates_clean.dta")))
cat("  Loaded", nrow(triv_cand), "candidate-election observations\n")

triv_cand <- triv_cand[, .(
  sh_election_id, sh_cand_id, ac07_id, ac08_id, ac_id,
  pc01_state_id, pc01_district_id, eci_state_name, tr_ac_name,
  constituency_type, year, assembly_no, bye_election, n_cand,
  turnout_percentage, position, cand_name, sex, party,
  votes, vote_share_percentage, valid_votes, electors
)]

cat("\n── 2. Loading ADR affidavit data ──\n")
aff <- fread(file.path(SHRUG, "affidavits_clean.tab"),
             quote = "")
cat("  Loaded", nrow(aff), "affidavit records\n")

## Strip embedded quotes from ID columns (fread artifact)
for (col in c("sh_cand_id", "sh_election_id", "ac07_id", "ac08_id",
              "pc01_state_id", "ac_id")) {
  if (col %in% names(aff))
    aff[, (col) := gsub('"', '', get(col))]
}

aff <- aff[, .(sh_cand_id, sh_election_id, year,
               num_crim, crime_major, crime_major_adr,
               assets, liabilities, income, cash, ed, age,
               winner, party)]

aff[, `:=`(
  any_crim = fifelse(!is.na(num_crim) & num_crim > 0, 1L, 0L),
  n_crim   = fifelse(is.na(num_crim), 0L, as.integer(num_crim)),
  major_crim = fifelse(!is.na(crime_major) & crime_major > 0, 1L, 0L)
)]

cat("  Criminal candidates:", sum(aff$any_crim), "/", nrow(aff),
    "(", round(100 * mean(aff$any_crim), 1), "%)\n")

## Merge candidates with affidavits
cat("\n── 3. Merging ──\n")
merged <- merge(triv_cand, aff, by = "sh_cand_id",
                suffixes = c("", "_aff"), all.x = FALSE, all.y = FALSE)
merged[, year := ifelse(is.na(year), year_aff, year)]
cat("  Matched:", nrow(merged), "candidates across",
    uniqueN(merged$sh_election_id), "elections\n")

## ============================================================================
## 2. CONSTRUCT RDD DATASET
## ============================================================================
cat("\n── 4. Constructing RDD running variable ──\n")

setorder(merged, sh_election_id, position)
top2 <- merged[position <= 2]
elec_both <- top2[, .N, by = sh_election_id][N == 2, sh_election_id]
top2 <- top2[sh_election_id %in% elec_both]
cat("  Elections with both top-2 matched:", length(elec_both), "\n")

## Reshape to wide
winner <- top2[position == 1, .(
  sh_election_id, ac07_id, ac08_id, ac_id,
  pc01_state_id, pc01_district_id, eci_state_name, tr_ac_name,
  constituency_type, year, assembly_no, bye_election, n_cand,
  turnout_percentage, valid_votes, electors,
  w_name = cand_name, w_party = party, w_sex = sex,
  w_votes = votes, w_vshare = vote_share_percentage,
  w_crim = any_crim, w_ncrim = n_crim, w_major = major_crim,
  w_assets = assets, w_liabilities = liabilities,
  w_ed = ed, w_age = age
)]

runner <- top2[position == 2, .(
  sh_election_id,
  r_name = cand_name, r_party = party, r_sex = sex,
  r_votes = votes, r_vshare = vote_share_percentage,
  r_crim = any_crim, r_ncrim = n_crim, r_major = major_crim,
  r_assets = assets, r_liabilities = liabilities,
  r_ed = ed, r_age = age
)]

rdd_raw <- merge(winner, runner, by = "sh_election_id")

## Keep only elections where top-2 differ in criminal status
case1 <- rdd_raw[w_crim == 1 & r_crim == 0]
case1[, `:=`(margin = w_vshare - r_vshare, treatment = 1L)]

case2 <- rdd_raw[w_crim == 0 & r_crim == 1]
case2[, `:=`(margin = -(w_vshare - r_vshare), treatment = 0L)]

rdd <- rbind(case1, case2)
rdd <- rdd[bye_election == 0 | is.na(bye_election)]
rdd <- rdd[valid_votes > 1000 | is.na(valid_votes)]

cat("  RDD sample (criminal vs non-criminal):", nrow(rdd), "elections\n")
cat("    Criminal won:", sum(rdd$treatment == 1), "\n")
cat("    Criminal lost:", sum(rdd$treatment == 0), "\n")
cat("    Close (|m| < 5%):", sum(abs(rdd$margin) < 5), "\n")
cat("    Close (|m| < 10%):", sum(abs(rdd$margin) < 10), "\n")

## ============================================================================
## 3. MERGE NIGHTLIGHTS (LONG → WIDE → GROWTH)
## ============================================================================
cat("\n── 5. Merging nightlights ──\n")

## Load NL in long format
nl07 <- fread(file.path(SHRUG, "dmsp_con07.tab"))
nl08 <- fread(file.path(SHRUG, "dmsp_con08.tab"))

## Pivot to wide: one row per constituency, columns = total_light_cal_YYYY
nl07_wide <- dcast(nl07, ac07_id ~ year,
                   value.var = "dmsp_total_light_cal", fun.aggregate = mean)
nl08_wide <- dcast(nl08, ac08_id ~ year,
                   value.var = "dmsp_total_light_cal", fun.aggregate = mean)

## Rename columns with prefix
yr_cols07 <- setdiff(names(nl07_wide), "ac07_id")
setnames(nl07_wide, yr_cols07, paste0("nl_", yr_cols07))
yr_cols08 <- setdiff(names(nl08_wide), "ac08_id")
setnames(nl08_wide, yr_cols08, paste0("nl_", yr_cols08))

cat("  NL07 wide:", nrow(nl07_wide), "constituencies,",
    length(yr_cols07), "years\n")
cat("  NL08 wide:", nrow(nl08_wide), "constituencies,",
    length(yr_cols08), "years\n")
cat("  Years (con08):", paste(yr_cols08, collapse = ", "), "\n")

## Split RDD by delimitation era
rdd_pre08  <- rdd[year < 2008 & !is.na(ac07_id) & ac07_id != ""]
rdd_post08 <- rdd[year >= 2008 & !is.na(ac08_id) & ac08_id != ""]

cat("  Pre-2008 elections:", nrow(rdd_pre08), "\n")
cat("  Post-2008 elections:", nrow(rdd_post08), "\n")

## Merge NL
rdd_pre08  <- merge(rdd_pre08, nl07_wide, by = "ac07_id", all.x = TRUE)
rdd_post08 <- merge(rdd_post08, nl08_wide, by = "ac08_id", all.x = TRUE)

## Compute NL growth for each election
## Pre-period: 3 years before election
## Post-period: 3-5 years after election (within DMSP range 1992-2013)
compute_nl <- function(dt, prefix = "nl_") {
  nl_cols <- grep(paste0("^", prefix, "\\d{4}$"), names(dt), value = TRUE)
  nl_years <- as.integer(gsub(prefix, "", nl_cols))

  dt[, nl_pre := NA_real_]
  dt[, nl_post := NA_real_]

  for (i in seq_len(nrow(dt))) {
    ey <- dt$year[i]
    pre_idx  <- which(nl_years >= (ey - 3) & nl_years < ey)
    post_idx <- which(nl_years > ey & nl_years <= (ey + 5))

    if (length(pre_idx) > 0) {
      vals <- as.numeric(dt[i, nl_cols[pre_idx], with = FALSE])
      dt[i, nl_pre := mean(vals, na.rm = TRUE)]
    }
    if (length(post_idx) > 0) {
      vals <- as.numeric(dt[i, nl_cols[post_idx], with = FALSE])
      dt[i, nl_post := mean(vals, na.rm = TRUE)]
    }
  }

  dt[, nl_growth := (nl_post - nl_pre) / (nl_pre + 1)]
  dt[, nl_change := nl_post - nl_pre]
  dt[, log_nl_post := log(nl_post + 1)]
  dt[, log_nl_pre  := log(nl_pre + 1)]
  dt
}

if (nrow(rdd_pre08) > 0) {
  rdd_pre08 <- compute_nl(rdd_pre08)
  cat("  Pre-2008 with NL:", sum(!is.na(rdd_pre08$nl_growth)), "\n")
}
if (nrow(rdd_post08) > 0) {
  rdd_post08 <- compute_nl(rdd_post08)
  cat("  Post-2008 with NL:", sum(!is.na(rdd_post08$nl_growth)), "\n")
}

## ============================================================================
## 4. MERGE CENSUS COVARIATES (PCA 2001)
## ============================================================================
cat("\n── 6. Merging Census covariates ──\n")

pca01_08 <- fread(file.path(SHRUG, "pc01_pca_clean_con08.tab"))
pca01_07 <- fread(file.path(SHRUG, "pc01_pca_clean_con07.tab"))

## Key covariates: population, literacy, SC/ST share, workers
pca_vars <- grep("pc01_pca_tot_p$|pc01_pca_p_lit$|pc01_pca_p_sc$|pc01_pca_p_st$|pc01_pca_tot_work_p$|pc01_pca_non_work_p$",
                  names(pca01_08), value = TRUE)
cat("  PCA vars:", paste(pca_vars, collapse = ", "), "\n")

if (length(pca_vars) > 0 && nrow(rdd_post08) > 0) {
  pca_merge08 <- pca01_08[, c("ac08_id", pca_vars), with = FALSE]
  rdd_post08 <- merge(rdd_post08, pca_merge08, by = "ac08_id", all.x = TRUE)
  cat("  Merged PCA for post-2008\n")
}

pca_vars07 <- grep("pc01_pca_tot_p$|pc01_pca_p_lit$|pc01_pca_p_sc$|pc01_pca_p_st$|pc01_pca_tot_work_p$",
                    names(pca01_07), value = TRUE)
if (length(pca_vars07) > 0 && nrow(rdd_pre08) > 0) {
  pca_merge07 <- pca01_07[, c("ac07_id", pca_vars07), with = FALSE]
  rdd_pre08 <- merge(rdd_pre08, pca_merge07, by = "ac07_id", all.x = TRUE)
  cat("  Merged PCA for pre-2008\n")
}

## Compute derived covariates
for (dt in list(rdd_pre08, rdd_post08)) {
  if ("pc01_pca_tot_p" %in% names(dt) && nrow(dt) > 0) {
    dt[, `:=`(
      lit_rate_01 = pc01_pca_p_lit / (pc01_pca_tot_p + 1),
      sc_share_01 = pc01_pca_p_sc / (pc01_pca_tot_p + 1),
      st_share_01 = pc01_pca_p_st / (pc01_pca_tot_p + 1),
      log_pop_01  = log(pc01_pca_tot_p + 1)
    )]
  }
}

## ============================================================================
## 5. MERGE VILLAGE DIRECTORY OUTCOMES
## ============================================================================
cat("\n── 7. Merging Village Directory outcomes ──\n")

vd11_08 <- fread(file.path(SHRUG, "pc11_vd_clean_con08.tab"))
vd01_08 <- fread(file.path(SHRUG, "pc01_vd_clean_con08.tab"))

## Key amenity variables: roads, electricity, water, schools, health, banking
vd11_vars <- c("pc11_vd_tar_road", "pc11_vd_power_all",
               "pc11_vd_tap", "pc11_vd_bus",
               "pc11_vd_prim_sch_gov", "pc11_vd_m_sch_gov",
               "pc11_vd_s_sch_gov", "pc11_vd_phc",
               "pc11_vd_comm_bank", "pc11_vd_post_off")
## Check which exist
vd11_vars <- intersect(vd11_vars, names(vd11_08))
cat("  VD 2011 vars available:", paste(vd11_vars, collapse = ", "), "\n")

## If specific vars not found, try alternatives
if (length(vd11_vars) == 0) {
  vd11_vars <- grep("tar_road|power|tap|prim_sch|phc|comm_bank",
                     names(vd11_08), value = TRUE)
  vd11_vars <- head(vd11_vars, 10)
  cat("  Using alternative VD vars:", paste(vd11_vars, collapse = ", "), "\n")
}

if (length(vd11_vars) > 0 && nrow(rdd_post08) > 0) {
  vd11_merge <- vd11_08[, c("ac08_id", vd11_vars), with = FALSE]
  rdd_post08 <- merge(rdd_post08, vd11_merge, by = "ac08_id", all.x = TRUE)
  cat("  Merged VD 2011\n")
}

## Also merge VD 2001 baseline
vd01_vars <- gsub("pc11", "pc01", vd11_vars)
vd01_vars <- intersect(vd01_vars, names(vd01_08))
if (length(vd01_vars) == 0) {
  vd01_vars <- grep("tar_road|power|tap|prim_sch|phc|comm_bank",
                     names(vd01_08), value = TRUE)
  vd01_vars <- head(vd01_vars, 10)
}
if (length(vd01_vars) > 0 && nrow(rdd_post08) > 0) {
  vd01_merge <- vd01_08[, c("ac08_id", vd01_vars), with = FALSE]
  rdd_post08 <- merge(rdd_post08, vd01_merge, by = "ac08_id", all.x = TRUE)
  cat("  Merged VD 2001 baseline\n")
}

## ============================================================================
## 6. COMBINE AND SAVE
## ============================================================================
cat("\n── 8. Combining final dataset ──\n")

## Get common columns
common <- intersect(names(rdd_pre08), names(rdd_post08))
rdd_final <- rbind(rdd_pre08[, ..common], rdd_post08[, ..common], fill = TRUE)

cat("  Final RDD dataset:", nrow(rdd_final), "elections\n")
cat("  Treatment:", table(rdd_final$treatment), "\n")
cat("  Years:", paste(sort(unique(rdd_final$year)), collapse = ", "), "\n")
cat("  With NL data:", sum(!is.na(rdd_final$nl_growth)), "\n")
cat("  NL growth summary:\n")
print(summary(rdd_final$nl_growth))
cat("\n  Margin summary:\n")
print(summary(rdd_final$margin))

## Save main dataset
saveRDS(rdd_final, file.path(DATA_DIR, "rdd_analysis.rds"))
fwrite(rdd_final, file.path(DATA_DIR, "rdd_analysis.csv"))

## Save full datasets with VD outcomes for post-2008
if (nrow(rdd_post08) > 0) {
  saveRDS(rdd_post08, file.path(DATA_DIR, "rdd_post08_full.rds"))
}
if (nrow(rdd_pre08) > 0) {
  saveRDS(rdd_pre08, file.path(DATA_DIR, "rdd_pre08_full.rds"))
}

cat("\nSaved to:", file.path(DATA_DIR, "rdd_analysis.rds"), "\n")
cat("\n========================================\n")
cat("DATA CONSTRUCTION COMPLETE\n")
cat("========================================\n")
