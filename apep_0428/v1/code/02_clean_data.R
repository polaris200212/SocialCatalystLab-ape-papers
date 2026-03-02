## ============================================================
## 02_clean_data.R — Build analysis sample
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

out_dir <- file.path(WORK_DIR, "data")

pca01    <- readRDS(file.path(out_dir, "pca01.rds"))
pca11    <- readRDS(file.path(out_dir, "pca11.rds"))
dist_key <- readRDS(file.path(out_dir, "dist_key.rds"))

# ── Get state codes from district key ──────────────────────────
# SHRID prefix does NOT correspond to Census state codes
# Must use shrid_pc11dist_key which maps shrid2 → pc11_state_id
pca01 <- merge(pca01, dist_key[, .(shrid2, state_code = pc11_state_id)],
               by = "shrid2", all.x = TRUE)
cat(sprintf("State code merge: %d of %d matched\n",
            sum(!is.na(pca01$state_code)), nrow(pca01)))

# ── Define designated areas (250 threshold applies) ──────────

# Special Category / Hill States (all villages use 250 threshold)
special_cat_states <- c(
  1,   # Jammu & Kashmir
  2,   # Himachal Pradesh
  5,   # Uttarakhand
  11,  # Sikkim
  12,  # Arunachal Pradesh
  13,  # Nagaland
  14,  # Manipur
  15,  # Mizoram
  16,  # Tripura
  17,  # Meghalaya
  18   # Assam
)

# Schedule V states (districts with scheduled tribal areas)
# These states have significant Schedule V tribal districts
schedule_v_states <- c(
  20,  # Jharkhand (most districts)
  21,  # Odisha (many districts)
  22,  # Chhattisgarh (many districts)
  23,  # Madhya Pradesh (many districts)
  24,  # Gujarat (some districts)
  27,  # Maharashtra (some districts)
  28,  # Andhra Pradesh / Telangana (some districts)
  8    # Rajasthan (some districts + desert areas)
)

# Classification approach:
# Strategy A (primary): Special Category State = designated
# Strategy B (extend): High ST share (>50%) in Schedule V states = designated
# Strategy C (robustness): Any village with >50% ST population = designated

pca01[, `:=`(
  # Is this a Special Category State?
  is_special_cat = state_code %in% special_cat_states,

  # Is this in a Schedule V state with high tribal share?
  st_share_01 = fifelse(pc01_pca_tot_p > 0,
                        pc01_pca_p_st / pc01_pca_tot_p, NA_real_),

  # Baseline variables
  pop_01      = pc01_pca_tot_p,
  literacy_01 = fifelse(pc01_pca_tot_p > 0,
                        pc01_pca_p_lit / pc01_pca_tot_p, NA_real_),
  f_lit_01    = fifelse(pc01_pca_tot_f > 0,
                        pc01_pca_f_lit / pc01_pca_tot_f, NA_real_),
  m_lit_01    = fifelse(pc01_pca_tot_m > 0,
                        pc01_pca_m_lit / pc01_pca_tot_m, NA_real_),
  sc_share_01 = fifelse(pc01_pca_tot_p > 0,
                        pc01_pca_p_sc / pc01_pca_tot_p, NA_real_),
  worker_share_01 = fifelse(pc01_pca_tot_p > 0,
                            pc01_pca_tot_work_p / pc01_pca_tot_p, NA_real_),
  f_worker_share_01 = fifelse(pc01_pca_tot_f > 0,
                              pc01_pca_tot_work_f / pc01_pca_tot_f, NA_real_),
  main_worker_share_01 = fifelse(pc01_pca_tot_work_p > 0,
                                 pc01_pca_mainwork_p / pc01_pca_tot_work_p, NA_real_),
  n_hh_01 = pc01_pca_no_hh
)]

# Designated area flags
pca01[, `:=`(
  # Primary: Special Category State
  designated_A = is_special_cat,

  # Extended: Special Cat + high-ST in Schedule V states
  designated_B = is_special_cat |
    (state_code %in% schedule_v_states & !is.na(st_share_01) & st_share_01 > 0.5),

  # Robustness: Any village >50% ST
  designated_C = !is.na(st_share_01) & st_share_01 > 0.5
)]

cat("Designated area counts (Census 2001):\n")
cat(sprintf("  Strategy A (Special Cat States): %s villages\n",
            format(sum(pca01$designated_A), big.mark = ",")))
cat(sprintf("  Strategy B (A + high-ST in Schedule V): %s villages\n",
            format(sum(pca01$designated_B), big.mark = ",")))
cat(sprintf("  Strategy C (any >50%% ST): %s villages\n",
            format(sum(pca01$designated_C), big.mark = ",")))

# ── Construct Census 2011 outcomes ───────────────────────────
pca11[, `:=`(
  pop_11      = pc11_pca_tot_p,
  literacy_11 = fifelse(pc11_pca_tot_p > 0,
                        pc11_pca_p_lit / pc11_pca_tot_p, NA_real_),
  f_lit_11    = fifelse(pc11_pca_tot_f > 0,
                        pc11_pca_f_lit / pc11_pca_tot_f, NA_real_),
  m_lit_11    = fifelse(pc11_pca_tot_m > 0,
                        pc11_pca_m_lit / pc11_pca_tot_m, NA_real_),
  worker_share_11 = fifelse(pc11_pca_tot_p > 0,
                            pc11_pca_tot_work_p / pc11_pca_tot_p, NA_real_),
  f_worker_share_11 = fifelse(pc11_pca_tot_f > 0,
                              pc11_pca_tot_work_f / pc11_pca_tot_f, NA_real_),
  main_worker_share_11 = fifelse(pc11_pca_tot_work_p > 0,
                                 pc11_pca_mainwork_p / pc11_pca_tot_work_p, NA_real_),
  nonag_share_11 = fifelse(pc11_pca_tot_work_p > 0,
                           1 - (pc11_pca_main_cl_p + pc11_pca_main_al_p) /
                             pc11_pca_tot_work_p, NA_real_),
  f_nonag_share_11 = fifelse(pc11_pca_tot_work_f > 0,
                             1 - (pc11_pca_main_cl_f + pc11_pca_main_al_f) /
                               pc11_pca_tot_work_f, NA_real_),
  hh_industry_share_11 = fifelse(pc11_pca_tot_work_p > 0,
                                 pc11_pca_main_hh_p / pc11_pca_tot_work_p, NA_real_)
)]

# ── Merge 2001 and 2011 ─────────────────────────────────────
outcomes_11 <- pca11[, .(shrid2, pop_11, literacy_11, f_lit_11, m_lit_11,
                         worker_share_11, f_worker_share_11, main_worker_share_11,
                         nonag_share_11, f_nonag_share_11, hh_industry_share_11)]

df <- merge(pca01, outcomes_11, by = "shrid2", all.x = TRUE)

# Population growth
df[, pop_growth := fifelse(pop_01 > 0, (pop_11 - pop_01) / pop_01, NA_real_)]

# Gender literacy gap
df[, gender_lit_gap_01 := m_lit_01 - f_lit_01]
df[, gender_lit_gap_11 := m_lit_11 - f_lit_11]
df[, gender_lit_gap_change := gender_lit_gap_01 - gender_lit_gap_11]  # positive = gap closing

# ── Town Directory ──────────────────────────────────────────────
# TD file has only ~7,654 constituency-level rows (not village-level)
# Cannot merge directly to 593K villages; skip TD variables
cat("  Note: TD data is constituency-level (7,654 obs). Using census data only.\n")

# ── Merge nightlights (average across years) ─────────────────
dmsp  <- readRDS(file.path(out_dir, "dmsp.rds"))
viirs <- readRDS(file.path(out_dir, "viirs.rds"))

# Pre-treatment nightlights (1994-2000)
nl_pre <- dmsp[year >= 1994 & year <= 2000,
               .(nl_pre = mean(dmsp_total_light_cal, na.rm = TRUE)),
               by = shrid2]

# Post-treatment nightlights (2005-2013 DMSP, allowing ~5 years for construction)
nl_post_dmsp <- dmsp[year >= 2005 & year <= 2013,
                     .(nl_post_dmsp = mean(dmsp_total_light_cal, na.rm = TRUE)),
                     by = shrid2]

# Late post-treatment (VIIRS 2015-2023)
nl_post_viirs <- viirs[year >= 2015 & year <= 2023,
                       .(nl_post_viirs = mean(viirs_annual_sum, na.rm = TRUE)),
                       by = shrid2]

df <- merge(df, nl_pre, by = "shrid2", all.x = TRUE)
df <- merge(df, nl_post_dmsp, by = "shrid2", all.x = TRUE)
df <- merge(df, nl_post_viirs, by = "shrid2", all.x = TRUE)

# Log nightlights
df[, `:=`(
  log_nl_pre  = log(nl_pre + 0.01),
  log_nl_post_dmsp  = log(nl_post_dmsp + 0.01),
  log_nl_post_viirs = log(nl_post_viirs + 0.01)
)]

# Nightlights change
df[, nl_change_dmsp  := log_nl_post_dmsp - log_nl_pre]
df[, nl_change_viirs := log_nl_post_viirs - log_nl_pre]

# ── Create running variable (centered at threshold) ──────────
df[, rv_250 := pop_01 - 250]  # Centered at 250 threshold
df[, rv_500 := pop_01 - 500]  # Centered at 500 threshold
df[, above_250 := as.integer(pop_01 >= 250)]
df[, above_500 := as.integer(pop_01 >= 500)]

# ── Filter analysis samples ──────────────────────────────────

# Main sample: designated areas, near 250 threshold
# Wide bandwidth for exploration (final bandwidth selected by rdrobust)
sample_250_A <- df[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 500]
sample_250_B <- df[designated_B == TRUE & pop_01 >= 50 & pop_01 <= 500]
sample_250_C <- df[designated_C == TRUE & pop_01 >= 50 & pop_01 <= 500]

# Comparison: non-designated areas near 500 threshold
sample_500 <- df[designated_A == FALSE & designated_B == FALSE &
                   pop_01 >= 300 & pop_01 <= 750]

cat("\n=== Analysis Sample Sizes ===\n")
cat(sprintf("Sample A (Special Cat States, 250±200): %s villages\n",
            format(nrow(sample_250_A), big.mark = ",")))
cat(sprintf("Sample B (A + high-ST Schedule V, 250±200): %s villages\n",
            format(nrow(sample_250_B), big.mark = ",")))
cat(sprintf("Sample C (any >50%% ST, 250±200): %s villages\n",
            format(nrow(sample_250_C), big.mark = ",")))
cat(sprintf("Comparison (non-designated, 500±200): %s villages\n",
            format(nrow(sample_500), big.mark = ",")))

# ── Save ─────────────────────────────────────────────────────
saveRDS(df, file.path(out_dir, "analysis_full.rds"))
saveRDS(sample_250_A, file.path(out_dir, "sample_250_A.rds"))
saveRDS(sample_250_B, file.path(out_dir, "sample_250_B.rds"))
saveRDS(sample_250_C, file.path(out_dir, "sample_250_C.rds"))
saveRDS(sample_500, file.path(out_dir, "sample_500.rds"))

cat("\nData cleaning complete. Samples saved.\n")
