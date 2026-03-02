# ==============================================================================
# 02_clean_data.R — Construct analysis panel
# APEP-0468: Where Does Workfare Work?
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
shrug_dir <- Sys.getenv("SHRUG_DIR", file.path(normalizePath("../.."), "data", "india_shrug"))

# ==============================================================================
# 1. Load prepared data
# ==============================================================================
cat("=== Loading data ===\n")
baseline <- readRDS(file.path(data_dir, "baseline_district.rds"))
nl_panel <- readRDS(file.path(data_dir, "nightlights_panel.rds"))

# Load crosswalk for additional variables
td <- fread(file.path(shrug_dir, "pc11_td_clean_pc11dist.csv"))

# Census 2011 for post-treatment outcomes
pc11 <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))

# ==============================================================================
# 2. Harmonize district codes (Census 2001 → 2011)
# ==============================================================================
cat("\n=== Harmonizing district codes ===\n")

# The nightlights use pc11 codes, baseline uses pc01 codes
# 593 districts in 2001, 640 in 2011 (districts split)
# Strategy: merge baseline characteristics to nightlights panel using
# the shrid_pc01dist_key crosswalk

key_01_11 <- fread(file.path(shrug_dir, "shrid_pc01dist_key.csv"))
key_11 <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))

# Build pc01 → pc11 district mapping by finding the most common pc11 district
# for each pc01 district
cat("Building Census 2001→2011 district crosswalk...\n")

# Merge both keys on shrid to get pc01_dist → pc11_dist mapping
xwalk <- merge(key_01_11[, .(shrid2, pc01_state_id, pc01_district_id)],
               key_11[, .(shrid2, pc11_state_id, pc11_district_id)],
               by = "shrid2")

# For each pc01 district, find the dominant pc11 district (many-to-one for splits)
dist_xwalk <- xwalk[, .N, by = .(pc01_state_id, pc01_district_id,
                                   pc11_state_id, pc11_district_id)]
dist_xwalk <- dist_xwalk[dist_xwalk[, .I[which.max(N)],
                                      by = .(pc01_state_id, pc01_district_id)]$V1]

cat("Crosswalk: ", nrow(dist_xwalk), "mappings (pc01→pc11)\n")

# Merge baseline (pc01 codes) with crosswalk to get pc11 codes
baseline_11 <- merge(baseline, dist_xwalk[, .(pc01_state_id, pc01_district_id,
                                                pc11_state_id, pc11_district_id)],
                     by = c("pc01_state_id", "pc01_district_id"))

# Create pc11-based district ID
baseline_11[, dist_id_11 := pc11_state_id * 1000 + pc11_district_id]

cat("Baseline districts matched to pc11:", nrow(baseline_11), "\n")

# For split districts: assign SAME phase to all daughter districts
# (they inherit parent's backwardness)
# First check for duplicates in pc11 mapping
dupes <- baseline_11[, .N, by = dist_id_11][N > 1]
if (nrow(dupes) > 0) {
  cat("WARNING:", nrow(dupes), "pc11 districts map to multiple pc01 districts\n")
  cat("  Keeping the one with largest population\n")
  baseline_11 <- baseline_11[baseline_11[, .I[which.max(pop_2001)], by = dist_id_11]$V1]
}

# ==============================================================================
# 3. Merge baseline with nightlights panel
# ==============================================================================
cat("\n=== Merging panel ===\n")

# Create district ID in nightlights
nl_panel[, dist_id_11 := pc11_state_id * 1000 + pc11_district_id]

# DMSP has overlapping satellites in some years — average across sensors
nl_panel <- nl_panel[, .(total_light = mean(total_light, na.rm = TRUE),
                          mean_light = mean(mean_light, na.rm = TRUE),
                          max_light = max(max_light, na.rm = TRUE),
                          num_cells = mean(num_cells, na.rm = TRUE)),
                      by = .(pc11_state_id, pc11_district_id, dist_id_11, year)]
cat("After deduplication:", nrow(nl_panel), "obs\n")

# Merge
panel <- merge(nl_panel, baseline_11[, .(dist_id_11, mgnrega_phase, first_treat,
                                          pop_2001, sc_st_share, lit_rate,
                                          ag_labor_share, cultivator_share,
                                          backwardness_index, backward_rank,
                                          pc01_state_id)],
               by = "dist_id_11")

cat("Panel dimensions:", nrow(panel), "rows,", ncol(panel), "columns\n")
cat("Districts in panel:", length(unique(panel$dist_id_11)), "\n")
cat("Years:", paste(range(panel$year), collapse = "–"), "\n")

# ==============================================================================
# 4. Add crosswalk variables (rainfall, infrastructure)
# ==============================================================================
cat("\n=== Adding geographic controls ===\n")

td[, dist_id_11 := pc11_state_id * 1000 + pc11_district_id]

panel <- merge(panel, td[, .(dist_id_11,
                               avg_rainfall = pc11_td_avg_rain,
                               max_temp = pc11_td_max_temp,
                               area = pc11_td_area,
                               bank_gov = pc11_td_bank_gov,
                               bank_priv = pc11_td_bank_priv_com,
                               hospitals = pc11_td_all_hospital,
                               prim_schools = pc11_td_primary_gov)],
               by = "dist_id_11", all.x = TRUE)

# ==============================================================================
# 5. Construct analysis variables
# ==============================================================================
cat("\n=== Constructing analysis variables ===\n")

# Log nightlights (primary outcome)
panel[, log_light := log(total_light + 1)]
panel[, log_mean_light := log(mean_light + 0.01)]

# Nightlights per capita (alternative)
panel[, light_pc := total_light / pmax(pop_2001, 1000)]

# Event time relative to treatment
panel[, event_time := year - first_treat]

# Post-treatment indicator
panel[, post := as.integer(year >= first_treat)]

# Treated indicator (for TWFE)
panel[, treated := as.integer(post == 1)]

# Baseline terciles for heterogeneity
panel[, `:=`(
  rain_tercile = cut(avg_rainfall, breaks = quantile(avg_rainfall, c(0, 1/3, 2/3, 1),
                                                      na.rm = TRUE),
                     labels = c("Arid", "Medium", "Wet"), include.lowest = TRUE),
  ag_labor_tercile = cut(ag_labor_share, breaks = quantile(ag_labor_share,
                                                             c(0, 1/3, 2/3, 1),
                                                             na.rm = TRUE),
                         labels = c("Low", "Medium", "High"), include.lowest = TRUE),
  scst_tercile = cut(sc_st_share, breaks = quantile(sc_st_share, c(0, 1/3, 2/3, 1),
                                                      na.rm = TRUE),
                     labels = c("Low", "Medium", "High"), include.lowest = TRUE)
)]

# Baseline light level (year 2000)
bl_2000 <- panel[year == 2000, .(dist_id_11, baseline_light = log_light)]
bl_2000 <- unique(bl_2000, by = "dist_id_11")
panel <- merge(panel, bl_2000, by = "dist_id_11", all.x = TRUE)
panel[, light_tercile := cut(baseline_light,
                              breaks = quantile(baseline_light, c(0, 1/3, 2/3, 1),
                                                na.rm = TRUE),
                              labels = c("Dark", "Medium", "Bright"),
                              include.lowest = TRUE)]

# State factor for clustering
panel[, state := as.factor(pc01_state_id)]

# ==============================================================================
# 6. Add Census 2011 outcomes for mechanism analysis
# ==============================================================================
cat("\n=== Adding Census 2011 outcomes ===\n")

pc11[, dist_id_11 := pc11_state_id * 1000 + pc11_district_id]

census_change <- merge(
  baseline_11[, .(dist_id_11, mgnrega_phase, first_treat, pc01_state_id,
                   pop_01 = pop_2001,
                   workers_01 = total_workers,
                   ag_labor_01 = ag_laborers,
                   cult_01 = cultivators,
                   sc_st_share, lit_rate, ag_labor_share,
                   backwardness_index)],
  pc11[, .(dist_id_11,
            pop_11 = pc11_pca_tot_p,
            workers_11 = pc11_pca_tot_work_p,
            ag_labor_11 = pc11_pca_main_al_p,
            cult_11 = pc11_pca_main_cl_p,
            other_11 = pc11_pca_main_ot_p,
            hh_ind_11 = pc11_pca_main_hh_p,
            female_workers_11 = pc11_pca_tot_work_f,
            female_pop_11 = pc11_pca_tot_f)],
  by = "dist_id_11"
)

# Compute changes and shares
census_change[, `:=`(
  pop_growth = (pop_11 - pop_01) / pop_01,
  worker_share_01 = workers_01 / pop_01,
  worker_share_11 = workers_11 / pop_11,
  ag_labor_share_01 = ag_labor_01 / pmax(workers_01, 1),
  ag_labor_share_11 = ag_labor_11 / pmax(workers_11, 1),
  cult_share_01 = cult_01 / pmax(workers_01, 1),
  cult_share_11 = cult_11 / pmax(workers_11, 1),
  other_share_11 = other_11 / pmax(workers_11, 1),
  female_lfpr_11 = female_workers_11 / pmax(female_pop_11, 1),
  d_ag_labor_share = ag_labor_11/pmax(workers_11,1) - ag_labor_01/pmax(workers_01,1),
  d_cult_share = cult_11/pmax(workers_11,1) - cult_01/pmax(workers_01,1)
)]

saveRDS(census_change, file.path(data_dir, "census_change.rds"))

# ==============================================================================
# 7. Save final panel
# ==============================================================================
cat("\n=== Saving final panel ===\n")

saveRDS(panel, file.path(data_dir, "analysis_panel.rds"))

# Summary statistics
cat("\nPanel summary:\n")
cat("  N:", nrow(panel), "\n")
cat("  Districts:", length(unique(panel$dist_id_11)), "\n")
cat("  Years:", min(panel$year), "-", max(panel$year), "\n")
cat("  Phase I districts:", length(unique(panel[mgnrega_phase == 1]$dist_id_11)), "\n")
cat("  Phase II districts:", length(unique(panel[mgnrega_phase == 2]$dist_id_11)), "\n")
cat("  Phase III districts:", length(unique(panel[mgnrega_phase == 3]$dist_id_11)), "\n")
cat("\n  Outcome (log_light) summary:\n")
print(summary(panel$log_light))
cat("\n  Baseline characteristics by phase:\n")
print(panel[year == 2000, .(
  mean_light = mean(log_light, na.rm = TRUE),
  mean_scst = mean(sc_st_share, na.rm = TRUE),
  mean_lit = mean(lit_rate, na.rm = TRUE),
  mean_ag_lab = mean(ag_labor_share, na.rm = TRUE),
  mean_rain = mean(avg_rainfall, na.rm = TRUE),
  N = .N
), by = mgnrega_phase][order(mgnrega_phase)])

cat("\nCensus mechanism data:", nrow(census_change), "districts\n")
cat("\nDone.\n")
