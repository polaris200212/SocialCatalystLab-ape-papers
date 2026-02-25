# ============================================================
# 01_fetch_data.R — Load SHRUG data from local files
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")

shrug_dir <- "../../../../data/india_shrug"
out_dir   <- "../data"

cat("Loading SHRUG data from:", shrug_dir, "\n")

# ── 1. VIIRS Annual Nightlights (District Level) ─────────────
viirs_dist <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
cat("VIIRS district-year obs (raw):", nrow(viirs_dist), "\n")
# SHRUG VIIRS has two categories: median-masked and average-masked
# Use median-masked (standard in nightlights literature)
if ("category" %in% names(viirs_dist)) {
  cat("  Categories:", unique(viirs_dist$category), "\n")
  viirs_dist <- viirs_dist[category == "median-masked"]
  cat("  After filtering to median-masked:", nrow(viirs_dist), "\n")
}
cat("  Years:", sort(unique(viirs_dist$year)), "\n")
cat("  Districts:", uniqueN(viirs_dist$pc11_district_id), "\n")

# ── 2. DMSP Nightlights (District Level, 1994–2013) ──────────
dmsp_dist <- fread(file.path(shrug_dir, "dmsp_pc11dist.csv"))
cat("DMSP district-year obs:", nrow(dmsp_dist), "\n")

# ── 3. Census 2011 Town Directory (Banking) ───────────────────
td_dist <- fread(file.path(shrug_dir, "pc11_td_clean_pc11dist.csv"))
cat("TD districts:", nrow(td_dist), "\n")

# Extract banking variables
banking <- td_dist[, .(
  pc11_state_id,
  pc11_district_id,
  bank_gov      = as.numeric(pc11_td_bank_gov),
  bank_priv_com = as.numeric(pc11_td_bank_priv_com),
  bank_coop     = as.numeric(pc11_td_bank_coop)
)]
banking[is.na(bank_gov), bank_gov := 0]
banking[is.na(bank_priv_com), bank_priv_com := 0]
banking[is.na(bank_coop), bank_coop := 0]
banking[, bank_total := bank_gov + bank_priv_com + bank_coop]

cat("Banking data: ", nrow(banking), " districts\n")
cat("  Mean total banks:", round(mean(banking$bank_total, na.rm = TRUE), 1), "\n")

# ── 4. Census 2011 PCA (Population, Demographics) ────────────
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))
cat("PCA 2011 districts:", nrow(pca11), "\n")

# ── 5. Census 2001 PCA (for pre-trend controls) ──────────────
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_pc01dist.csv"))
cat("PCA 2001 districts:", nrow(pca01), "\n")

# ── 6. VIIRS Sub-district Level ──────────────────────────────
viirs_subdist <- fread(file.path(shrug_dir, "viirs_annual_pc11subdist.csv"))
cat("VIIRS sub-district-year obs:", nrow(viirs_subdist), "\n")
cat("  Sub-districts:", uniqueN(paste0(viirs_subdist$pc11_state_id, "_",
                                        viirs_subdist$pc11_subdistrict_id)), "\n")

# ── 7. TD Sub-district Level (Banking) ───────────────────────
td_subdist <- fread(file.path(shrug_dir, "pc11_td_clean_pc11subdist.csv"))
cat("TD sub-districts:", nrow(td_subdist), "\n")

# ── Save all raw data objects ─────────────────────────────────
save(viirs_dist, dmsp_dist, banking, td_dist, pca11, pca01,
     viirs_subdist, td_subdist,
     file = file.path(out_dir, "raw_data.RData"))

cat("\nAll data loaded and saved to", file.path(out_dir, "raw_data.RData"), "\n")
