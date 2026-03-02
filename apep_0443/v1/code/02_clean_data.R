# ============================================================================
# 02_clean_data.R — Construct variables and analysis sample
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

data_dir <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)

# ── Load raw data ──────────────────────────────────────────────────────────
pc01 <- fread(file.path(data_dir, "pc01_raw.csv"))
pc11 <- fread(file.path(data_dir, "pc11_raw.csv"))
dist_key <- fread(file.path(data_dir, "dist_key.csv"))

# ── Construct Census 2001 variables (pre-treatment / running variable) ─────
pc01[, `:=`(
  pop01          = pc01_pca_tot_p,
  pop01_f        = pc01_pca_tot_f,
  pop01_m        = pc01_pca_tot_m,
  sc_share01     = fifelse(pc01_pca_tot_p > 0, pc01_pca_p_sc / pc01_pca_tot_p, NA_real_),
  st_share01     = fifelse(pc01_pca_tot_p > 0, pc01_pca_p_st / pc01_pca_tot_p, NA_real_),
  lit_rate01     = fifelse(pc01_pca_tot_p > 0, pc01_pca_p_lit / pc01_pca_tot_p, NA_real_),
  lit_rate_f01   = fifelse(pc01_pca_tot_f > 0, pc01_pca_f_lit / pc01_pca_tot_f, NA_real_),
  lit_rate_m01   = fifelse(pc01_pca_tot_m > 0, pc01_pca_m_lit / pc01_pca_tot_m, NA_real_),
  lfpr01         = fifelse(pc01_pca_tot_p > 0, pc01_pca_tot_work_p / pc01_pca_tot_p, NA_real_),
  lfpr_f01       = fifelse(pc01_pca_tot_f > 0, pc01_pca_tot_work_f / pc01_pca_tot_f, NA_real_),
  lfpr_m01       = fifelse(pc01_pca_tot_m > 0, pc01_pca_tot_work_m / pc01_pca_tot_m, NA_real_),
  # Non-agricultural worker share among workers
  nonag_share01  = fifelse(pc01_pca_tot_work_p > 0,
                           (pc01_pca_main_hh_p + pc01_pca_main_ot_p) / pc01_pca_tot_work_p,
                           NA_real_),
  nonag_share_f01 = fifelse(pc01_pca_tot_work_f > 0,
                            (pc01_pca_main_hh_f + pc01_pca_main_ot_f) / pc01_pca_tot_work_f,
                            NA_real_),
  nonag_share_m01 = fifelse(pc01_pca_tot_work_m > 0,
                            (pc01_pca_main_hh_m + pc01_pca_main_ot_m) / pc01_pca_tot_work_m,
                            NA_real_)
)]

# ── Construct Census 2011 variables (outcomes) ────────────────────────────
pc11[, `:=`(
  pop11          = pc11_pca_tot_p,
  pop11_f        = pc11_pca_tot_f,
  pop11_m        = pc11_pca_tot_m,
  sc_share11     = fifelse(pc11_pca_tot_p > 0, pc11_pca_p_sc / pc11_pca_tot_p, NA_real_),
  st_share11     = fifelse(pc11_pca_tot_p > 0, pc11_pca_p_st / pc11_pca_tot_p, NA_real_),
  lit_rate11     = fifelse(pc11_pca_tot_p > 0, pc11_pca_p_lit / pc11_pca_tot_p, NA_real_),
  lit_rate_f11   = fifelse(pc11_pca_tot_f > 0, pc11_pca_f_lit / pc11_pca_tot_f, NA_real_),
  lit_rate_m11   = fifelse(pc11_pca_tot_m > 0, pc11_pca_m_lit / pc11_pca_tot_m, NA_real_),
  lfpr11         = fifelse(pc11_pca_tot_p > 0, pc11_pca_tot_work_p / pc11_pca_tot_p, NA_real_),
  lfpr_f11       = fifelse(pc11_pca_tot_f > 0, pc11_pca_tot_work_f / pc11_pca_tot_f, NA_real_),
  lfpr_m11       = fifelse(pc11_pca_tot_m > 0, pc11_pca_tot_work_m / pc11_pca_tot_m, NA_real_),
  nonag_share11  = fifelse(pc11_pca_tot_work_p > 0,
                           (pc11_pca_main_hh_p + pc11_pca_main_ot_p) / pc11_pca_tot_work_p,
                           NA_real_),
  nonag_share_f11 = fifelse(pc11_pca_tot_work_f > 0,
                            (pc11_pca_main_hh_f + pc11_pca_main_ot_f) / pc11_pca_tot_work_f,
                            NA_real_),
  nonag_share_m11 = fifelse(pc11_pca_tot_work_m > 0,
                            (pc11_pca_main_hh_m + pc11_pca_main_ot_m) / pc11_pca_tot_work_m,
                            NA_real_)
)]

# ── Select relevant columns ───────────────────────────────────────────────
vars01 <- c("shrid2", "pop01", "pop01_f", "pop01_m",
            "sc_share01", "st_share01", "lit_rate01", "lit_rate_f01", "lit_rate_m01",
            "lfpr01", "lfpr_f01", "lfpr_m01",
            "nonag_share01", "nonag_share_f01", "nonag_share_m01")

vars11 <- c("shrid2", "pop11", "pop11_f", "pop11_m",
            "sc_share11", "st_share11", "lit_rate11", "lit_rate_f11", "lit_rate_m11",
            "lfpr11", "lfpr_f11", "lfpr_m11",
            "nonag_share11", "nonag_share_f11", "nonag_share_m11")

# ── Merge datasets ────────────────────────────────────────────────────────
df <- merge(pc01[, ..vars01], pc11[, ..vars11], by = "shrid2")
df <- merge(df, dist_key, by = "shrid2")

cat(sprintf("Merged panel: %d villages\n", nrow(df)))

# ── Construct change variables ─────────────────────────────────────────────
df[, `:=`(
  d_nonag_share_f = nonag_share_f11 - nonag_share_f01,
  d_nonag_share_m = nonag_share_m11 - nonag_share_m01,
  d_nonag_share   = nonag_share11 - nonag_share01,
  d_lfpr_f        = lfpr_f11 - lfpr_f01,
  d_lfpr_m        = lfpr_m11 - lfpr_m01,
  d_lit_rate_f    = lit_rate_f11 - lit_rate_f01,
  gender_gap_nonag11 = nonag_share_m11 - nonag_share_f11,
  gender_gap_nonag01 = nonag_share_m01 - nonag_share_f01,
  d_gender_gap_nonag = (nonag_share_m11 - nonag_share_f11) - (nonag_share_m01 - nonag_share_f01)
)]

# ── Construct RDD variables ───────────────────────────────────────────────
# Running variable: centered at 500 (PMGSY plains threshold)
df[, `:=`(
  running_var = pop01 - 500,
  eligible    = as.integer(pop01 >= 500)
)]

# ── Identify hill/tribal states (use 250 threshold instead) ───────────────
# NE states + Himachal Pradesh + Uttarakhand + J&K + Sikkim
hill_states <- c("02",   # Himachal Pradesh
                 "05",   # Uttarakhand
                 "01",   # Jammu & Kashmir
                 "11",   # Sikkim
                 "12",   # Arunachal Pradesh
                 "13",   # Nagaland
                 "14",   # Manipur
                 "15",   # Mizoram
                 "16",   # Tripura
                 "17",   # Meghalaya
                 "18")   # Assam

df[, is_hill := pc11_state_id %in% hill_states]

# For hill states, use 250 threshold
df[, `:=`(
  running_var_local = fifelse(is_hill, pop01 - 250, pop01 - 500),
  eligible_local    = fifelse(is_hill, as.integer(pop01 >= 250), as.integer(pop01 >= 500))
)]

# ── Filter to analysis sample ─────────────────────────────────────────────
# Drop uninhabited villages and extreme outliers
df_analysis <- df[pop01 > 0 & pop01 < 5000]

# Main sample: plains states only (500 threshold)
df_plains <- df_analysis[is_hill == FALSE]

# Hill sample: hill/tribal states only (250 threshold)
df_hills <- df_analysis[is_hill == TRUE]
df_hills[, `:=`(
  running_var = pop01 - 250,
  eligible    = as.integer(pop01 >= 250)
)]

cat(sprintf("Analysis sample: %d villages (plains: %d, hills: %d)\n",
            nrow(df_analysis), nrow(df_plains), nrow(df_hills)))
cat(sprintf("Plains villages near threshold (400-600): %d\n",
            nrow(df_plains[pop01 >= 400 & pop01 <= 600])))
cat(sprintf("Hill villages near threshold (150-350): %d\n",
            nrow(df_hills[pop01 >= 150 & pop01 <= 350])))

# ── Save cleaned data ─────────────────────────────────────────────────────
fwrite(df_analysis, file.path(data_dir, "analysis_sample.csv"))
fwrite(df_plains, file.path(data_dir, "plains_sample.csv"))
fwrite(df_hills, file.path(data_dir, "hills_sample.csv"))

cat("Cleaned data saved to data/\n")
