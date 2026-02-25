# ============================================================
# 02_clean_data.R — Construct analysis panel
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")
load("../data/raw_data.RData")

# ============================================================
# DISTRICT-LEVEL PANEL
# ============================================================

# ── 1. Build baseline district characteristics (Census 2011) ──
baseline <- pca11[, .(
  pc11_state_id,
  pc11_district_id,
  pop_total     = as.numeric(pc11_pca_tot_p),
  pop_male      = as.numeric(pc11_pca_tot_m),
  pop_female    = as.numeric(pc11_pca_tot_f),
  pop_sc        = as.numeric(pc11_pca_p_sc),
  pop_st        = as.numeric(pc11_pca_p_st),
  pop_lit       = as.numeric(pc11_pca_p_lit),
  workers_total = as.numeric(pc11_pca_tot_work_p),
  workers_main  = as.numeric(pc11_pca_mainwork_p),
  cultivators   = as.numeric(pc11_pca_main_cl_p),
  ag_laborers   = as.numeric(pc11_pca_main_al_p),
  hh_industry   = as.numeric(pc11_pca_main_hh_p),
  other_workers = as.numeric(pc11_pca_main_ot_p),
  nonworkers    = as.numeric(pc11_pca_non_work_p)
)]

# Construct shares
baseline[, `:=`(
  lit_rate    = pop_lit / pop_total,
  sc_share    = pop_sc / pop_total,
  st_share    = pop_st / pop_total,
  female_share = pop_female / pop_total,
  work_rate   = workers_total / pop_total,
  ag_share    = (cultivators + ag_laborers) / pmax(workers_total, 1),
  nonag_share = (hh_industry + other_workers) / pmax(workers_total, 1),
  log_pop     = log(pop_total + 1)
)]

# ── 2. Merge banking data ────────────────────────────────────
baseline <- merge(baseline, banking,
                  by = c("pc11_state_id", "pc11_district_id"),
                  all.x = TRUE)

# Bank branches per 100K population
baseline[, bank_per_100k := bank_total / pop_total * 100000]
baseline[is.na(bank_per_100k), bank_per_100k := 0]

# Log banking intensity (for robustness)
baseline[, log_bank := log(bank_total + 1)]

# Above-median binary indicator
baseline[, high_bank := as.integer(bank_per_100k >= median(bank_per_100k, na.rm = TRUE))]

# Quartile indicator
baseline[, bank_quartile := cut(bank_per_100k,
                                 breaks = quantile(bank_per_100k, probs = c(0, 0.25, 0.5, 0.75, 1),
                                                   na.rm = TRUE),
                                 labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)"),
                                 include.lowest = TRUE)]

cat("Baseline districts:", nrow(baseline), "\n")
cat("Bank per 100K - Mean:", round(mean(baseline$bank_per_100k, na.rm = TRUE), 2),
    "SD:", round(sd(baseline$bank_per_100k, na.rm = TRUE), 2), "\n")

# ── 3. Build VIIRS district-year panel ────────────────────────
viirs_panel <- viirs_dist[, .(
  pc11_state_id,
  pc11_district_id,
  year = as.integer(year),
  nl_sum  = viirs_annual_sum,
  nl_mean = viirs_annual_mean,
  nl_max  = viirs_annual_max,
  nl_cells = viirs_annual_num_cells
)]

# Log nightlights (add 0.01 to handle zeros)
viirs_panel[, log_nl := log(nl_sum + 0.01)]

cat("VIIRS panel obs:", nrow(viirs_panel), "\n")

# ── 4. Merge panel with baseline ─────────────────────────────
panel <- merge(viirs_panel, baseline,
               by = c("pc11_state_id", "pc11_district_id"),
               all.x = TRUE)

# Create treatment variables
panel[, `:=`(
  post      = as.integer(year >= 2017),
  event     = as.integer(year == 2016),
  # Event study indicators (relative to 2015)
  rel_year  = year - 2016,
  # Continuous treatment intensity
  treat_intensity = bank_per_100k * as.integer(year >= 2017),
  # Create unique district ID for FE
  dist_id = paste0(pc11_state_id, "_", pc11_district_id)
)]

# State ID for clustering
panel[, state_id := as.integer(pc11_state_id)]

# Drop observations with missing nightlights or banking
panel <- panel[!is.na(log_nl) & !is.na(bank_per_100k)]

cat("\nFinal district panel:\n")
cat("  Observations:", nrow(panel), "\n")
cat("  Districts:", uniqueN(panel$dist_id), "\n")
cat("  Years:", sort(unique(panel$year)), "\n")
cat("  States:", uniqueN(panel$state_id), "\n")

# ============================================================
# DMSP PANEL (Extended Pre-Period 1994–2013)
# ============================================================

dmsp_panel <- dmsp_dist[, .(
  pc11_state_id,
  pc11_district_id,
  year = as.integer(year),
  dmsp_sum  = dmsp_total_light_cal,
  dmsp_mean = dmsp_mean_light_cal
)]
dmsp_panel[, log_dmsp := log(dmsp_sum + 0.01)]

dmsp_panel <- merge(dmsp_panel, baseline,
                    by = c("pc11_state_id", "pc11_district_id"),
                    all.x = TRUE)
dmsp_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
dmsp_panel[, state_id := as.integer(pc11_state_id)]

cat("DMSP panel obs:", nrow(dmsp_panel), "\n")

# ============================================================
# SUB-DISTRICT PANEL
# ============================================================

# Extract sub-district banking from TD
sd_banking <- td_subdist[, .(
  pc11_state_id,
  pc11_district_id,
  pc11_subdistrict_id = get(grep("subdistrict", names(td_subdist), value = TRUE)[1]),
  sd_bank_gov  = as.numeric(pc11_td_bank_gov),
  sd_bank_priv = as.numeric(pc11_td_bank_priv_com),
  sd_bank_coop = as.numeric(pc11_td_bank_coop)
)]
sd_banking[is.na(sd_bank_gov), sd_bank_gov := 0]
sd_banking[is.na(sd_bank_priv), sd_bank_priv := 0]
sd_banking[is.na(sd_bank_coop), sd_bank_coop := 0]
sd_banking[, sd_bank_total := sd_bank_gov + sd_bank_priv + sd_bank_coop]

cat("Sub-district banking obs:", nrow(sd_banking), "\n")

# ── Save analysis panel ──────────────────────────────────────
save(panel, baseline, dmsp_panel, sd_banking,
     file = "../data/analysis_panel.RData")

cat("\nAnalysis panel saved.\n")

# ── Summary statistics ────────────────────────────────────────
cat("\n=== SUMMARY STATISTICS ===\n")
cat("Districts:", uniqueN(panel$dist_id), "\n")
cat("Years:", min(panel$year), "-", max(panel$year), "\n")
cat("Observations:", nrow(panel), "\n\n")

cat("Banking intensity (per 100K):\n")
print(summary(baseline$bank_per_100k))
cat("\nNightlights (log):\n")
print(summary(panel$log_nl))
cat("\nAg share of workers:\n")
print(summary(baseline$ag_share))
