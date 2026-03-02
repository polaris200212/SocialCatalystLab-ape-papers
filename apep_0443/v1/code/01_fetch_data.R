# ============================================================================
# 01_fetch_data.R — Load SHRUG data from local files
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

project_root <- normalizePath(file.path(getwd(), "../../../.."))
shrug_dir <- file.path(project_root, "data", "india_shrug")
data_dir  <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)

cat("Loading Census 2001 PCA (running variable + pre-treatment)...\n")
pc01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
cat(sprintf("  Census 2001: %d villages, %d variables\n", nrow(pc01), ncol(pc01)))

cat("Loading Census 2011 PCA (outcome variables)...\n")
pc11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
cat(sprintf("  Census 2011: %d villages, %d variables\n", nrow(pc11), ncol(pc11)))

cat("Loading district crosswalk...\n")
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat(sprintf("  District key: %d rows\n", nrow(dist_key)))

cat("Loading DMSP nightlights (1992-2013)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
cat(sprintf("  DMSP: %d rows, years %d-%d\n", nrow(dmsp), min(dmsp$year), max(dmsp$year)))

cat("Loading VIIRS nightlights (2012+)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
cat(sprintf("  VIIRS: %d rows, years %d-%d\n", nrow(viirs), min(viirs$year), max(viirs$year)))

# Save raw data for reproducibility
fwrite(pc01, file.path(data_dir, "pc01_raw.csv"))
fwrite(pc11, file.path(data_dir, "pc11_raw.csv"))
fwrite(dist_key, file.path(data_dir, "dist_key.csv"))

cat("\nData loading complete. Files saved to data/\n")
cat(sprintf("Unique villages in Census 2001: %d\n", uniqueN(pc01$shrid2)))
cat(sprintf("Unique villages in Census 2011: %d\n", uniqueN(pc11$shrid2)))
cat(sprintf("Overlap (inner join): %d\n", length(intersect(pc01$shrid2, pc11$shrid2))))
