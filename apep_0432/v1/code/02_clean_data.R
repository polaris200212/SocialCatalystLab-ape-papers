## ============================================================
## 02_clean_data.R — Construct analysis panel
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "raw_shrug.RData"))

## ── Step 1: Merge Census 2001 + 2011 + geography ──────────
panel <- merge(pca01, pca11, by = "shrid2", all = FALSE)
panel <- merge(panel, geo, by = "shrid2", all.x = TRUE)
panel <- merge(panel, td11, by = "shrid2", all.x = TRUE)
cat(sprintf("After Census + geo merge: %s villages\n",
            formatC(nrow(panel), big.mark = ",")))

## ── Step 2: Construct key variables (baseline = 2001) ─────

## Running variable: Census 2001 population
panel[, pop01 := pc01_pca_tot_p]

## Caste composition (Census 2001)
panel[, sc_share_01 := fifelse(pc01_pca_tot_p > 0,
                                pc01_pca_p_sc / pc01_pca_tot_p, NA_real_)]
panel[, st_share_01 := fifelse(pc01_pca_tot_p > 0,
                                pc01_pca_p_st / pc01_pca_tot_p, NA_real_)]
panel[, gen_share_01 := 1 - sc_share_01 - st_share_01]

## Caste terciles (use ntile to handle ties at zero)
panel[!is.na(sc_share_01), sc_tercile := factor(
  findInterval(sc_share_01,
               quantile(sc_share_01, probs = c(1/3, 2/3), na.rm = TRUE),
               rightmost.closed = TRUE) + 1L,
  levels = 1:3, labels = c("Low SC", "Mid SC", "High SC"))]

panel[!is.na(st_share_01), st_tercile := factor(
  findInterval(st_share_01,
               quantile(st_share_01, probs = c(1/3, 2/3), na.rm = TRUE),
               rightmost.closed = TRUE) + 1L,
  levels = 1:3, labels = c("Low ST", "Mid ST", "High ST"))]

## Dominant caste category
panel[, caste_dominant := fifelse(st_share_01 > 0.5, "ST-dominated",
                           fifelse(sc_share_01 > 0.5, "SC-dominated",
                                   "General/OBC-dominated"))]

## ── Step 3: Female employment outcomes ────────────────────

## Female Work Participation Rate (FWPR)
panel[, fwpr_01 := fifelse(pc01_pca_tot_f > 0,
                            pc01_pca_tot_work_f / pc01_pca_tot_f, NA_real_)]
panel[, fwpr_11 := fifelse(pc11_pca_tot_f > 0,
                            pc11_pca_tot_work_f / pc11_pca_tot_f, NA_real_)]
panel[, d_fwpr := fwpr_11 - fwpr_01]

## Male Work Participation Rate
panel[, mwpr_01 := fifelse(pc01_pca_tot_m > 0,
                            pc01_pca_tot_work_m / pc01_pca_tot_m, NA_real_)]
panel[, mwpr_11 := fifelse(pc11_pca_tot_m > 0,
                            pc11_pca_tot_work_m / pc11_pca_tot_m, NA_real_)]
panel[, d_mwpr := mwpr_11 - mwpr_01]

## Gender gap in work participation
panel[, gender_gap_01 := mwpr_01 - fwpr_01]
panel[, gender_gap_11 := mwpr_11 - fwpr_11]
panel[, d_gender_gap := gender_gap_11 - gender_gap_01]

## Female employment decomposition (shares of female pop)
## Agricultural laborers
panel[, f_aglabor_share_01 := fifelse(pc01_pca_tot_f > 0,
                                       pc01_pca_main_al_f / pc01_pca_tot_f, NA_real_)]
panel[, f_aglabor_share_11 := fifelse(pc11_pca_tot_f > 0,
                                       pc11_pca_main_al_f / pc11_pca_tot_f, NA_real_)]
panel[, d_f_aglabor := f_aglabor_share_11 - f_aglabor_share_01]

## Cultivators
panel[, f_cultiv_share_01 := fifelse(pc01_pca_tot_f > 0,
                                      pc01_pca_main_cl_f / pc01_pca_tot_f, NA_real_)]
panel[, f_cultiv_share_11 := fifelse(pc11_pca_tot_f > 0,
                                      pc11_pca_main_cl_f / pc11_pca_tot_f, NA_real_)]
panel[, d_f_cultiv := f_cultiv_share_11 - f_cultiv_share_01]

## Household industry workers
panel[, f_hh_share_01 := fifelse(pc01_pca_tot_f > 0,
                                  pc01_pca_main_hh_f / pc01_pca_tot_f, NA_real_)]
panel[, f_hh_share_11 := fifelse(pc11_pca_tot_f > 0,
                                  pc11_pca_main_hh_f / pc11_pca_tot_f, NA_real_)]
panel[, d_f_hh := f_hh_share_11 - f_hh_share_01]

## Other workers (non-farm, services)
panel[, f_other_share_01 := fifelse(pc01_pca_tot_f > 0,
                                     pc01_pca_main_ot_f / pc01_pca_tot_f, NA_real_)]
panel[, f_other_share_11 := fifelse(pc11_pca_tot_f > 0,
                                     pc11_pca_main_ot_f / pc11_pca_tot_f, NA_real_)]
panel[, d_f_other := f_other_share_11 - f_other_share_01]

## Non-workers share
panel[, f_nonwork_share_01 := fifelse(pc01_pca_tot_f > 0,
                                       pc01_pca_non_work_f / pc01_pca_tot_f, NA_real_)]
panel[, f_nonwork_share_11 := fifelse(pc11_pca_tot_f > 0,
                                       (pc11_pca_tot_f - pc11_pca_tot_work_f) / pc11_pca_tot_f, NA_real_)]
panel[, d_f_nonwork := f_nonwork_share_11 - f_nonwork_share_01]

## Female literacy rate
panel[, f_litrate_01 := fifelse(pc01_pca_tot_f > 0,
                                 pc01_pca_f_lit / pc01_pca_tot_f, NA_real_)]
panel[, f_litrate_11 := fifelse(pc11_pca_tot_f > 0,
                                 pc11_pca_f_lit / pc11_pca_tot_f, NA_real_)]
panel[, d_f_litrate := f_litrate_11 - f_litrate_01]

## Child sex ratio (male / (male + female) for ages 0-6)
panel[, csr_01 := fifelse(pc01_pca_p_06 > 0,
                           pc01_pca_m_06 / pc01_pca_p_06, NA_real_)]
panel[, csr_11 := fifelse(pc11_pca_p_06 > 0,
                           pc11_pca_m_06 / pc11_pca_p_06, NA_real_)]
panel[, d_csr := csr_11 - csr_01]

## ── Step 4: RDD treatment variable ────────────────────────
## PMGSY eligibility: pop >= 500 for plains, >= 250 for hills/tribal
## We use the 500 threshold as primary (most villages are in plains)
panel[, eligible_500 := as.integer(pop01 >= 500)]
panel[, eligible_250 := as.integer(pop01 >= 250)]

## Centered running variable
panel[, pop01_c500 := pop01 - 500]
panel[, pop01_c250 := pop01 - 250]

## ── Step 5: Infrastructure outcomes (first stage proxies) ─
panel[, has_paved_road := fifelse(!is.na(pc11_td_k_road),
                                   as.integer(pc11_td_k_road > 0), NA_integer_)]

## Bank access
panel[, has_bank := fifelse(!is.na(pc11_td_bank_gov),
                             as.integer(pc11_td_bank_gov > 0 | pc11_td_bank_priv_com > 0),
                             NA_integer_)]

## ── Step 6: Merge Economic Census data ────────────────────
panel <- merge(panel, ec05, by = "shrid2", all.x = TRUE)
panel <- merge(panel, ec13, by = "shrid2", all.x = TRUE)

## Female share of non-farm employment
panel[, f_nonfarm_share_05 := fifelse(ec05_emp_all > 0,
                                       ec05_emp_f / ec05_emp_all, NA_real_)]
panel[, f_nonfarm_share_13 := fifelse(ec13_emp_all > 0,
                                       ec13_emp_f / ec13_emp_all, NA_real_)]
panel[, d_f_nonfarm := f_nonfarm_share_13 - f_nonfarm_share_05]

## ── Step 7: Merge SECC ────────────────────────────────────
panel <- merge(panel, secc, by = "shrid2", all.x = TRUE)

## ── Step 8: Sample restrictions ───────────────────────────

## Keep rural villages only (exclude towns: pop > 5000 in 2001)
## Also drop villages with missing population or very small villages
panel_rdd <- panel[pop01 >= 50 & pop01 <= 2000 & !is.na(pop01)]
cat(sprintf("RDD sample (pop 50-2000): %s villages\n",
            formatC(nrow(panel_rdd), big.mark = ",")))

## Narrow bandwidth for main analysis
panel_bw <- panel_rdd[pop01 >= 300 & pop01 <= 700]
cat(sprintf("Main bandwidth (300-700): %s villages\n",
            formatC(nrow(panel_bw), big.mark = ",")))

## ── Step 9: Summary statistics ────────────────────────────
cat("\n=== Summary Statistics (Main Bandwidth) ===\n")
cat(sprintf("N villages: %s\n", formatC(nrow(panel_bw), big.mark = ",")))
cat(sprintf("Mean pop 2001: %.0f\n", mean(panel_bw$pop01, na.rm = TRUE)))
cat(sprintf("Mean SC share: %.3f\n", mean(panel_bw$sc_share_01, na.rm = TRUE)))
cat(sprintf("Mean ST share: %.3f\n", mean(panel_bw$st_share_01, na.rm = TRUE)))
cat(sprintf("Mean female WPR 2001: %.3f\n", mean(panel_bw$fwpr_01, na.rm = TRUE)))
cat(sprintf("Mean female WPR 2011: %.3f\n", mean(panel_bw$fwpr_11, na.rm = TRUE)))
cat(sprintf("Mean male WPR 2001: %.3f\n", mean(panel_bw$mwpr_01, na.rm = TRUE)))
cat(sprintf("Mean male WPR 2011: %.3f\n", mean(panel_bw$mwpr_11, na.rm = TRUE)))

## Caste-group summaries
cat("\n=== By Dominant Caste Category ===\n")
panel_bw[, .(
  N = .N,
  mean_fwpr_01 = mean(fwpr_01, na.rm = TRUE),
  mean_fwpr_11 = mean(fwpr_11, na.rm = TRUE),
  mean_mwpr_01 = mean(mwpr_01, na.rm = TRUE),
  d_fwpr = mean(d_fwpr, na.rm = TRUE),
  d_mwpr = mean(d_mwpr, na.rm = TRUE)
), by = caste_dominant][order(caste_dominant)] |> print()

## ── Save analysis datasets ────────────────────────────────
save(panel, panel_rdd, panel_bw,
     file = file.path(data_dir, "analysis_panel.RData"))
cat("\nAnalysis panel saved.\n")
