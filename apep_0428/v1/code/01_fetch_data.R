## ============================================================
## 01_fetch_data.R — Load SHRUG data from local disk
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

shrug_dir <- file.path(BASE_DIR, "data/india_shrug")
out_dir   <- file.path(WORK_DIR, "data")

cat("Loading SHRUG Census 2001 PCA...\n")
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
cat(sprintf("  Census 2001: %s observations, %d variables\n", format(nrow(pca01), big.mark = ","), ncol(pca01)))

cat("Loading SHRUG Census 2011 PCA...\n")
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
cat(sprintf("  Census 2011: %s observations, %d variables\n", format(nrow(pca11), big.mark = ","), ncol(pca11)))

cat("Loading SHRUG Town Directory (2011)...\n")
td11 <- fread(file.path(shrug_dir, "pc11_td_clean_shrid.csv"))
cat(sprintf("  Town Directory: %s observations, %d variables\n", format(nrow(td11), big.mark = ","), ncol(td11)))

cat("Loading SHRUG district key...\n")
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat(sprintf("  District key: %s observations\n", format(nrow(dist_key), big.mark = ",")))

cat("Loading DMSP nightlights...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
cat(sprintf("  DMSP: %s observations (years: %s to %s)\n",
            format(nrow(dmsp), big.mark = ","), min(dmsp$year), max(dmsp$year)))

cat("Loading VIIRS nightlights...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
cat(sprintf("  VIIRS: %s observations (years: %s to %s)\n",
            format(nrow(viirs), big.mark = ","), min(viirs$year), max(viirs$year)))

# ── Save loaded data ─────────────────────────────────────────
saveRDS(pca01, file.path(out_dir, "pca01.rds"))
saveRDS(pca11, file.path(out_dir, "pca11.rds"))
saveRDS(td11,  file.path(out_dir, "td11.rds"))
saveRDS(dist_key, file.path(out_dir, "dist_key.rds"))
saveRDS(dmsp,  file.path(out_dir, "dmsp.rds"))
saveRDS(viirs, file.path(out_dir, "viirs.rds"))

cat("\nAll data loaded and saved to RDS.\n")
