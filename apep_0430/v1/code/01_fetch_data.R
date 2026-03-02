## ============================================================
## 01_fetch_data.R — Load SHRUG data and construct MGNREGA
##                   phase assignment
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

shrug_dir <- "../../../../data/india_shrug"
out_dir   <- "../data"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

cat("=== Loading SHRUG data ===\n")

## ── 1. Geographic crosswalk (SHRID → district → state) ─────
## Use the district-level key for mapping
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
setnames(dist_key, c("shrid2", "pc11_state_id", "pc11_district_id"))
cat("District key:", nrow(dist_key), "villages\n")

## ── 2. Census 2001 PCA (baseline characteristics) ──────────
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"),
               select = c("shrid2",
                           "pc01_pca_tot_p",      # Total population
                           "pc01_pca_p_sc",        # SC population
                           "pc01_pca_p_st",        # ST population
                           "pc01_pca_p_lit",        # Literate population
                           "pc01_pca_tot_work_p",   # Total workers
                           "pc01_pca_main_cl_p",    # Main cultivators
                           "pc01_pca_main_al_p",    # Main ag laborers
                           "pc01_pca_main_hh_p",    # Main HH industry
                           "pc01_pca_main_ot_p",    # Main other workers
                           "pc01_pca_tot_work_f",   # Female workers
                           "pc01_pca_tot_f"))       # Female population
cat("Census 2001 PCA:", nrow(pca01), "villages\n")

## ── 3. Census 2011 PCA (post-treatment outcomes) ───────────
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"),
               select = c("shrid2",
                           "pc11_pca_tot_p",
                           "pc11_pca_p_sc",
                           "pc11_pca_p_st",
                           "pc11_pca_p_lit",
                           "pc11_pca_tot_work_p",
                           "pc11_pca_main_cl_p",
                           "pc11_pca_main_al_p",
                           "pc11_pca_main_hh_p",
                           "pc11_pca_main_ot_p",
                           "pc11_pca_tot_work_f",
                           "pc11_pca_tot_f"))
cat("Census 2011 PCA:", nrow(pca11), "villages\n")

## ── 4. DMSP Nightlights (1994–2013) ────────────────────────
cat("Loading DMSP nightlights (this may take a minute)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"),
              select = c("shrid2", "dmsp_total_light_cal", "year"))
setnames(dmsp, c("shrid2", "light", "year"))
dmsp[, year := as.integer(year)]
dmsp <- dmsp[!is.na(year)]
cat("DMSP:", nrow(dmsp), "village-years,",
    dmsp[, uniqueN(shrid2)], "villages,",
    dmsp[, paste(range(year), collapse = "-")], "\n")

## ── 5. VIIRS Nightlights (2012–2023) ───────────────────────
cat("Loading VIIRS nightlights (this may take a minute)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"),
               select = c("shrid2", "viirs_annual_sum", "year"))
setnames(viirs, c("shrid2", "light", "year"))
viirs[, year := as.integer(year)]
viirs <- viirs[!is.na(year)]
cat("VIIRS:", nrow(viirs), "village-years,",
    viirs[, uniqueN(shrid2)], "villages,",
    viirs[, paste(range(year), collapse = "-")], "\n")

## ── 6. Construct MGNREGA Phase Assignment ──────────────────
##
## Phase assignment based on Planning Commission backwardness
## index. We reconstruct at DISTRICT level using Census 2001:
##   - SC/ST population share
##   - Agricultural labor share (ag laborers / total workers)
##   - Literacy rate (inverse proxy for wages)
##
## Within each state, districts are ranked by composite index.
## Phase I = 200 most backward nationally; Phase II = next 130;
## Phase III = all remaining.
##
## References:
##   Government of India (2003). "Identification of Districts
##     for Wage and Self Employment Programmes."
##   Zimmermann (2022, JDE) uses same within-state ranking.
## ────────────────────────────────────────────────────────────

cat("=== Constructing MGNREGA phase assignment ===\n")

## Aggregate Census 2001 to district level
dist01 <- merge(pca01, dist_key, by = "shrid2")
dist01 <- dist01[, .(
  pop         = sum(pc01_pca_tot_p, na.rm = TRUE),
  sc_pop      = sum(pc01_pca_p_sc, na.rm = TRUE),
  st_pop      = sum(pc01_pca_p_st, na.rm = TRUE),
  lit_pop     = sum(pc01_pca_p_lit, na.rm = TRUE),
  tot_workers = sum(pc01_pca_tot_work_p, na.rm = TRUE),
  ag_laborers = sum(pc01_pca_main_al_p, na.rm = TRUE),
  cultivators = sum(pc01_pca_main_cl_p, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id)]

## Compute index components
dist01[, sc_st_share := (sc_pop + st_pop) / pop]
dist01[, ag_labor_share := ag_laborers / tot_workers]
dist01[, illiteracy_rate := 1 - (lit_pop / pop)]

## Handle missing/infinite values
dist01[is.nan(sc_st_share) | is.infinite(sc_st_share), sc_st_share := 0]
dist01[is.nan(ag_labor_share) | is.infinite(ag_labor_share), ag_labor_share := 0]
dist01[is.nan(illiteracy_rate) | is.infinite(illiteracy_rate), illiteracy_rate := 0]

## Normalize each component to [0,1] within the national distribution
normalize <- function(x) {
  r <- rank(x, ties.method = "average") / length(x)
  return(r)
}

dist01[, idx_sc_st := normalize(sc_st_share)]
dist01[, idx_ag_labor := normalize(ag_labor_share)]
dist01[, idx_illiteracy := normalize(illiteracy_rate)]

## Composite backwardness index (equal weights)
dist01[, backwardness_idx := (idx_sc_st + idx_ag_labor + idx_illiteracy) / 3]

## Rank within state (for RDD later) and nationally
dist01[, state_rank := rank(-backwardness_idx, ties.method = "first"),
       by = pc11_state_id]
dist01[, national_rank := rank(-backwardness_idx, ties.method = "first")]

## Assign phases based on national rank
## Phase I: top 200 most backward (rank 1-200)
## Phase II: next 130 (rank 201-330)
## Phase III: remaining
dist01[, mgnrega_phase := ifelse(national_rank <= 200, 1L,
                           ifelse(national_rank <= 330, 2L, 3L))]

## Treatment year (first full calendar year of exposure)
## Phase I: started Feb 2006 → first full year = 2007
## Phase II: started Apr 2007 → first full year = 2008
## Phase III: started Apr 2008 → first full year = 2009
dist01[, treat_year := ifelse(mgnrega_phase == 1, 2007L,
                        ifelse(mgnrega_phase == 2, 2008L, 2009L))]

cat("Phase assignment:\n")
cat("  Phase I:  ", dist01[mgnrega_phase == 1, .N], "districts\n")
cat("  Phase II: ", dist01[mgnrega_phase == 2, .N], "districts\n")
cat("  Phase III:", dist01[mgnrega_phase == 3, .N], "districts\n")

## ── 7. Save intermediate datasets ──────────────────────────

## District-level treatment assignment
phase_dt <- dist01[, .(pc11_state_id, pc11_district_id,
                        pop, sc_st_share, ag_labor_share,
                        illiteracy_rate, backwardness_idx,
                        national_rank, state_rank,
                        mgnrega_phase, treat_year)]
fwrite(phase_dt, file.path(out_dir, "district_phase_assignment.csv"))
cat("Saved: district_phase_assignment.csv (", nrow(phase_dt), "districts)\n")

## Village-district key
fwrite(dist_key, file.path(out_dir, "village_district_key.csv"))
cat("Saved: village_district_key.csv\n")

## Census 2001 village-level
fwrite(pca01, file.path(out_dir, "census_2001_pca.csv"))
cat("Saved: census_2001_pca.csv\n")

## Census 2011 village-level
fwrite(pca11, file.path(out_dir, "census_2011_pca.csv"))
cat("Saved: census_2011_pca.csv\n")

## DMSP nightlights
fwrite(dmsp, file.path(out_dir, "dmsp_nightlights.csv"))
cat("Saved: dmsp_nightlights.csv\n")

## VIIRS nightlights
fwrite(viirs, file.path(out_dir, "viirs_nightlights.csv"))
cat("Saved: viirs_nightlights.csv\n")

cat("\n=== Data loading complete ===\n")
