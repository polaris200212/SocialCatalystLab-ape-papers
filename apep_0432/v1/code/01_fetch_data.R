## ============================================================
## 01_fetch_data.R — Load SHRUG data (already downloaded locally)
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))

cat("Loading SHRUG village-level data...\n")

## ── Census 2001 PCA (pre-treatment) ───────────────────────
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"),
               select = c("shrid2",
                           "pc01_pca_tot_p", "pc01_pca_tot_m", "pc01_pca_tot_f",
                           "pc01_pca_p_06", "pc01_pca_m_06", "pc01_pca_f_06",
                           "pc01_pca_p_sc", "pc01_pca_m_sc", "pc01_pca_f_sc",
                           "pc01_pca_p_st", "pc01_pca_m_st", "pc01_pca_f_st",
                           "pc01_pca_p_lit", "pc01_pca_m_lit", "pc01_pca_f_lit",
                           "pc01_pca_tot_work_p", "pc01_pca_tot_work_m", "pc01_pca_tot_work_f",
                           "pc01_pca_mainwork_p", "pc01_pca_mainwork_m", "pc01_pca_mainwork_f",
                           "pc01_pca_main_cl_p", "pc01_pca_main_cl_m", "pc01_pca_main_cl_f",
                           "pc01_pca_main_al_p", "pc01_pca_main_al_m", "pc01_pca_main_al_f",
                           "pc01_pca_main_hh_p", "pc01_pca_main_hh_m", "pc01_pca_main_hh_f",
                           "pc01_pca_main_ot_p", "pc01_pca_main_ot_m", "pc01_pca_main_ot_f",
                           "pc01_pca_non_work_p", "pc01_pca_non_work_m", "pc01_pca_non_work_f"))
cat(sprintf("  Census 2001 PCA: %s villages\n", formatC(nrow(pca01), big.mark = ",")))

## ── Census 2011 PCA (post-treatment) ──────────────────────
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"),
               select = c("shrid2",
                           "pc11_pca_tot_p", "pc11_pca_tot_m", "pc11_pca_tot_f",
                           "pc11_pca_p_06", "pc11_pca_m_06", "pc11_pca_f_06",
                           "pc11_pca_p_sc", "pc11_pca_m_sc", "pc11_pca_f_sc",
                           "pc11_pca_p_st", "pc11_pca_m_st", "pc11_pca_f_st",
                           "pc11_pca_p_lit", "pc11_pca_m_lit", "pc11_pca_f_lit",
                           "pc11_pca_tot_work_p", "pc11_pca_tot_work_m", "pc11_pca_tot_work_f",
                           "pc11_pca_mainwork_p", "pc11_pca_mainwork_m", "pc11_pca_mainwork_f",
                           "pc11_pca_main_cl_p", "pc11_pca_main_cl_m", "pc11_pca_main_cl_f",
                           "pc11_pca_main_al_p", "pc11_pca_main_al_m", "pc11_pca_main_al_f",
                           "pc11_pca_main_hh_p", "pc11_pca_main_hh_m", "pc11_pca_main_hh_f",
                           "pc11_pca_main_ot_p", "pc11_pca_main_ot_m", "pc11_pca_main_ot_f"))
cat(sprintf("  Census 2011 PCA: %s villages\n", formatC(nrow(pca11), big.mark = ",")))

## ── Geographic crosswalk (village → district → state) ─────
geo <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat(sprintf("  Geographic key: %s villages\n", formatC(nrow(geo), big.mark = ",")))

## ── Town directory (roads, amenities, distances) ──────────
td11 <- fread(file.path(shrug_dir, "pc11_td_clean_shrid.csv"),
              select = c("shrid2",
                          "pc11_td_k_road", "pc11_td_p_road",
                          "pc11_td_sh_dist", "pc11_td_dh_dist",
                          "pc11_td_city_dist", "pc11_td_rail_dist",
                          "pc11_td_el_dom",
                          "pc11_td_bank_gov", "pc11_td_bank_priv_com",
                          "pc11_td_primary_gov", "pc11_td_primary_priv",
                          "pc11_td_all_hospital", "pc11_td_allh_beds"))
cat(sprintf("  Town directory: %s villages\n", formatC(nrow(td11), big.mark = ",")))

## ── Economic Census 2005 (pre-treatment) ──────────────────
ec05 <- fread(file.path(shrug_dir, "ec05_shrid.csv"),
              select = c("shrid2",
                          "ec05_emp_all", "ec05_emp_f", "ec05_emp_m",
                          "ec05_count_sc", "ec05_count_st", "ec05_count_obc"))
cat(sprintf("  EC 2005: %s villages\n", formatC(nrow(ec05), big.mark = ",")))

## ── Economic Census 2013 (post-treatment) ─────────────────
ec13 <- fread(file.path(shrug_dir, "ec13_shrid.csv"),
              select = c("shrid2",
                          "ec13_emp_all", "ec13_emp_f", "ec13_emp_m",
                          "ec13_count_all", "ec13_count_f",
                          "ec13_count_sc", "ec13_count_st", "ec13_count_obc",
                          "ec13_emp_own_f"))
cat(sprintf("  EC 2013: %s villages\n", formatC(nrow(ec13), big.mark = ",")))

## ── SECC 2011 (household deprivation) ─────────────────────
secc <- fread(file.path(shrug_dir, "secc_rural_shrid.csv"),
              select = c("shrid2",
                          "secc_hh", "sc_share",
                          "land_own_share", "ed_prim_share",
                          "inc_source_manlab_share", "inc_source_cultiv_share",
                          "inc_source_domest_share"))
cat(sprintf("  SECC 2011: %s villages\n", formatC(nrow(secc), big.mark = ",")))

## ── Nightlights (DMSP annual, village-level) ──────────────
nl <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
cat(sprintf("  DMSP nightlights: %s village-years\n", formatC(nrow(nl), big.mark = ",")))

## ── Save raw data objects ─────────────────────────────────
save(pca01, pca11, geo, td11, ec05, ec13, secc, nl,
     file = file.path(data_dir, "raw_shrug.RData"))
cat("All data loaded and saved to data/raw_shrug.RData\n")
