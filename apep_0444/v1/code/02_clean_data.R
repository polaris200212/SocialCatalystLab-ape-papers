## ============================================================
## 02_clean_data.R — Build district × year nightlights panel
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

shrug_dir <- "data/india_shrug"

# ── Load geographic crosswalk ────────────────────────────────
cat("Loading geographic crosswalk...\n")
xwalk <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
setnames(xwalk, "shrid2", "shrid")

# ── Load VIIRS nightlights (2012–2023) ───────────────────────
cat("Loading VIIRS nightlights...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
setnames(viirs, "shrid2", "shrid")

# Keep median-masked category (standard in literature)
viirs <- viirs[category == "median-masked"]
viirs <- viirs[, .(shrid, year, viirs_sum = viirs_annual_sum,
                    viirs_mean = viirs_annual_mean,
                    viirs_max = viirs_annual_max,
                    viirs_cells = viirs_annual_num_cells)]

cat("VIIRS years:", sort(unique(viirs$year)), "\n")
cat("VIIRS villages:", uniqueN(viirs$shrid), "\n")

# ── Load DMSP nightlights (2008–2013 for extended pre-treatment) ──
cat("Loading DMSP nightlights...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
setnames(dmsp, "shrid2", "shrid")

# Keep years 2008-2013 for extended pre-treatment
dmsp <- dmsp[year >= 2008]
dmsp <- dmsp[, .(shrid, year,
                  dmsp_sum = dmsp_total_light_cal,
                  dmsp_mean = dmsp_mean_light_cal,
                  dmsp_max = dmsp_max_light,
                  dmsp_cells = dmsp_num_cells)]

cat("DMSP years:", sort(unique(dmsp$year)), "\n")

# ── Load Census PCA 2011 for baseline controls ───────────────
cat("Loading Census PCA 2011...\n")
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
setnames(pca11, "shrid2", "shrid")

# Select key variables for controls
pca11_vars <- pca11[, .(
  shrid,
  pop_2011 = pc11_pca_tot_p,
  hh_2011 = pc11_pca_no_hh,
  lit_rate_2011 = fifelse(pc11_pca_tot_p > 0,
                          pc11_pca_p_lit / pc11_pca_tot_p, NA_real_),
  sc_share_2011 = fifelse(pc11_pca_tot_p > 0,
                           pc11_pca_p_sc / pc11_pca_tot_p, NA_real_),
  st_share_2011 = fifelse(pc11_pca_tot_p > 0,
                           pc11_pca_p_st / pc11_pca_tot_p, NA_real_),
  worker_share_2011 = fifelse(pc11_pca_tot_p > 0,
                               pc11_pca_tot_work_p / pc11_pca_tot_p, NA_real_),
  female_share_2011 = fifelse(pc11_pca_tot_p > 0,
                               pc11_pca_tot_f / pc11_pca_tot_p, NA_real_)
)]

# ── Merge village data with crosswalk ────────────────────────
cat("Merging with crosswalk...\n")
viirs <- merge(viirs, xwalk, by = "shrid", all.x = FALSE)
dmsp <- merge(dmsp, xwalk, by = "shrid", all.x = FALSE)
pca11_vars <- merge(pca11_vars, xwalk, by = "shrid", all.x = FALSE)

# ── Identify rural vs urban villages ──────────────────────────
# SHRUG SHRIDs starting with "r" pattern indicate rural
# Actually, the SHRID structure is: SS-DD-SSS-BBBBB-VVVVVV
# Rural/urban classification from Census town directory
# For now, use population as proxy: villages with pop < 10000 are rural
pca11_vars[, is_rural := as.integer(pop_2011 < 10000)]

# ── Aggregate to district × year ─────────────────────────────
cat("Aggregating VIIRS to district × year...\n")

# All villages (primary)
dist_viirs <- viirs[, .(
  nl_sum = sum(viirs_sum, na.rm = TRUE),
  nl_mean = mean(viirs_mean, na.rm = TRUE),
  nl_max = max(viirs_max, na.rm = TRUE),
  n_villages = .N,
  nl_cells = sum(viirs_cells, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id, year)]

# Rural-only villages (robustness)
rural_shrids <- pca11_vars[is_rural == 1, .(shrid)]
viirs_rural <- viirs[shrid %in% rural_shrids$shrid]
dist_viirs_rural <- viirs_rural[, .(
  nl_sum_rural = sum(viirs_sum, na.rm = TRUE),
  nl_mean_rural = mean(viirs_mean, na.rm = TRUE),
  n_villages_rural = .N
), by = .(pc11_state_id, pc11_district_id, year)]

# Merge rural-only
dist_viirs <- merge(dist_viirs, dist_viirs_rural,
                     by = c("pc11_state_id", "pc11_district_id", "year"),
                     all.x = TRUE)

# ── Aggregate DMSP to district × year ────────────────────────
cat("Aggregating DMSP to district × year...\n")
dist_dmsp <- dmsp[, .(
  dmsp_sum = sum(dmsp_sum, na.rm = TRUE),
  dmsp_mean = mean(dmsp_mean, na.rm = TRUE),
  dmsp_max = max(dmsp_max, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id, year)]

# ── Aggregate baseline controls to district level ────────────
cat("Computing district baseline controls...\n")
dist_baseline <- pca11_vars[, .(
  pop_2011 = sum(pop_2011, na.rm = TRUE),
  hh_2011 = sum(hh_2011, na.rm = TRUE),
  lit_rate_2011 = weighted.mean(lit_rate_2011, pop_2011, na.rm = TRUE),
  sc_share_2011 = weighted.mean(sc_share_2011, pop_2011, na.rm = TRUE),
  st_share_2011 = weighted.mean(st_share_2011, pop_2011, na.rm = TRUE),
  worker_share_2011 = weighted.mean(worker_share_2011, pop_2011, na.rm = TRUE),
  female_share_2011 = weighted.mean(female_share_2011, pop_2011, na.rm = TRUE),
  rural_share = sum(is_rural * pop_2011, na.rm = TRUE) / sum(pop_2011, na.rm = TRUE),
  n_villages = .N
), by = .(pc11_state_id, pc11_district_id)]

# ── Load ODF treatment dates ─────────────────────────────────
cat("Loading ODF treatment dates...\n")
odf <- fread(file.path(BASE_DIR, "data", "odf_dates.csv"))

# ── Merge treatment into panel ────────────────────────────────
dist_panel <- merge(dist_viirs, odf[, .(pc11_state_id, odf_year, odf_month, frac_exposure)],
                     by = "pc11_state_id", all.x = TRUE)

# ── Construct treatment variables ────────────────────────────
dist_panel[, `:=`(
  # Binary post-ODF indicator
  post_odf = as.integer(year >= odf_year),
  # Exposure-weighted treatment (fractional in declaration year)
  treat_weighted = fifelse(year > odf_year, 1,
                           fifelse(year == odf_year, frac_exposure, 0)),
  # Treatment cohort for CS-DiD (first treatment year)
  cohort = odf_year,
  # Log nightlights (primary outcome)
  log_nl = log(nl_sum + 1),
  log_nl_rural = log(nl_sum_rural + 1),
  # District ID for fixed effects
  dist_id = paste0(pc11_state_id, "_", pc11_district_id)
)]

# ── Merge baseline controls ──────────────────────────────────
dist_panel <- merge(dist_panel, dist_baseline,
                     by = c("pc11_state_id", "pc11_district_id"), all.x = TRUE)

# Population-weighted nightlights (per capita)
dist_panel[, log_nl_pc := log(nl_sum / pop_2011 + 0.001)]

# ── Trim extreme observations ────────────────────────────────
# Remove districts with zero population or missing nightlights
dist_panel <- dist_panel[pop_2011 > 0 & !is.na(nl_sum)]

# ── Create relative time variable ─────────────────────────────
dist_panel[, rel_time := year - odf_year]

cat("\n=== Panel Summary ===\n")
cat("Districts:", uniqueN(dist_panel$dist_id), "\n")
cat("States:", uniqueN(dist_panel$pc11_state_id), "\n")
cat("Years:", sort(unique(dist_panel$year)), "\n")
cat("Total observations:", nrow(dist_panel), "\n")
cat("Treatment cohorts:\n")
print(table(dist_panel[year == 2012, cohort]))
cat("\n")

# ── Save panel ────────────────────────────────────────────────
fwrite(dist_panel, file.path(BASE_DIR, "data", "district_panel.csv"))
cat("Panel saved to data/district_panel.csv\n")

# ── Also construct DMSP extended panel (2008-2013) ────────────
dist_dmsp_panel <- merge(dist_dmsp, odf[, .(pc11_state_id, odf_year, odf_month)],
                          by = "pc11_state_id", all.x = TRUE)
dist_dmsp_panel[, `:=`(
  log_dmsp = log(dmsp_sum + 1),
  dist_id = paste0(pc11_state_id, "_", pc11_district_id),
  rel_time = year - odf_year
)]
dist_dmsp_panel <- merge(dist_dmsp_panel, dist_baseline,
                          by = c("pc11_state_id", "pc11_district_id"), all.x = TRUE)
dist_dmsp_panel <- dist_dmsp_panel[pop_2011 > 0 & !is.na(dmsp_sum)]

fwrite(dist_dmsp_panel, file.path(BASE_DIR, "data", "district_dmsp_panel.csv"))
cat("DMSP panel saved to data/district_dmsp_panel.csv\n")
