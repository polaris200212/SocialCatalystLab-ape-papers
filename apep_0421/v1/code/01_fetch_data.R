## ═══════════════════════════════════════════════════════════════════════════
## 01_fetch_data.R — Data acquisition from all sources
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))

cat("\n══════════════════════════════════════════════\n")
cat("STEP 1: LOAD SHRUG DATA (pre-downloaded)\n")
cat("══════════════════════════════════════════════\n\n")

# ── 1a. Geographic crosswalk (district codes) ───────────────────────────
td11 <- fread(file.path(shrug_dir, "td11", "pc11_td_clean_pc11dist.csv"))
cat("Town directory loaded:", nrow(td11), "rows,", ncol(td11), "cols\n")
cat("Columns:", paste(names(td11), collapse = ", "), "\n\n")

# ── 1b. VIIRS annual nightlights at district level ─────────────────────
viirs <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
cat("VIIRS nightlights loaded:", nrow(viirs), "rows,", ncol(viirs), "cols\n")
cat("Columns:", paste(head(names(viirs), 20), collapse = ", "), "\n\n")

# ── 1c. Census 2011 PCA at district level ──────────────────────────────
pca11 <- fread(file.path(shrug_dir, "pca11", "pc11_pca_clean_pc11dist.csv"))
cat("Census 2011 PCA loaded:", nrow(pca11), "rows,", ncol(pca11), "cols\n")
cat("Sample columns:", paste(head(names(pca11), 15), collapse = ", "), "\n\n")

# ── 1d. Census 2001 PCA at district level ──────────────────────────────
pca01 <- fread(file.path(shrug_dir, "pca01", "pc01_pca_clean_pc01dist.csv"))
cat("Census 2001 PCA loaded:", nrow(pca01), "rows,", ncol(pca01), "cols\n\n")

cat("\n══════════════════════════════════════════════\n")
cat("STEP 2: DOWNLOAD NFHS DISTRICT FACTSHEETS\n")
cat("══════════════════════════════════════════════\n\n")

nfhs_dir <- file.path(data_dir, "nfhs")
dir.create(nfhs_dir, recursive = TRUE, showWarnings = FALSE)

# Try GitHub source for NFHS CSVs
nfhs5_url <- "https://raw.githubusercontent.com/SaiSiddhardhaKalla/NFHS/main/NFHS-5/NFHS5_Districts.csv"
nfhs4_url <- "https://raw.githubusercontent.com/SaiSiddhardhaKalla/NFHS/main/NFHS-4/NFHS4_Districts.csv"

nfhs5_file <- file.path(nfhs_dir, "NFHS5_Districts.csv")
nfhs4_file <- file.path(nfhs_dir, "NFHS4_Districts.csv")

tryCatch({
  if (!file.exists(nfhs5_file)) {
    download.file(nfhs5_url, nfhs5_file, quiet = TRUE)
    cat("NFHS-5 district factsheets downloaded\n")
  } else {
    cat("NFHS-5 already exists\n")
  }
  nfhs5 <- fread(nfhs5_file)
  cat("NFHS-5 loaded:", nrow(nfhs5), "districts,", ncol(nfhs5), "indicators\n")
  cat("Sample columns:", paste(head(names(nfhs5), 10), collapse = ", "), "\n\n")
}, error = function(e) {
  cat("NFHS-5 download failed:", e$message, "\n")
  cat("Will try alternative source...\n\n")
})

tryCatch({
  if (!file.exists(nfhs4_file)) {
    download.file(nfhs4_url, nfhs4_file, quiet = TRUE)
    cat("NFHS-4 district factsheets downloaded\n")
  } else {
    cat("NFHS-4 already exists\n")
  }
  nfhs4 <- fread(nfhs4_file)
  cat("NFHS-4 loaded:", nrow(nfhs4), "districts,", ncol(nfhs4), "indicators\n")
  cat("Sample columns:", paste(head(names(nfhs4), 10), collapse = ", "), "\n\n")
}, error = function(e) {
  cat("NFHS-4 download failed:", e$message, "\n")
})

cat("\n══════════════════════════════════════════════\n")
cat("STEP 3: DOWNLOAD UDISE+ EDUCATION DATA\n")
cat("══════════════════════════════════════════════\n\n")

udise_dir <- file.path(data_dir, "udise")
dir.create(udise_dir, recursive = TRUE, showWarnings = FALSE)

# UDISE+ bulk data is available from data.gov.in and the portal
# Try data.gov.in API for UDISE data
# Note: UDISE+ may require manual download from udiseplus.gov.in
# For now, check if data has been placed manually or by another agent
udise_files <- list.files(udise_dir, pattern = "\\.csv$", full.names = TRUE)
if (length(udise_files) > 0) {
  cat("Found", length(udise_files), "UDISE files\n")
  for (f in udise_files) {
    cat("  -", basename(f), "\n")
  }
} else {
  cat("No UDISE files found yet. Will construct from available sources.\n")
  cat("UDISE+ data may need manual download from udiseplus.gov.in\n")
  cat("Alternative: Use SHRUG DISE data (shrug_dise) for older years.\n\n")
}

cat("\n══════════════════════════════════════════════\n")
cat("STEP 4: CONSTRUCT JJM TREATMENT DATA\n")
cat("══════════════════════════════════════════════\n\n")

jjm_dir <- file.path(data_dir, "jjm")
dir.create(jjm_dir, recursive = TRUE, showWarnings = FALSE)

# Check if JJM data has been collected by background agent
jjm_files <- list.files(jjm_dir, pattern = "\\.(csv|json|xlsx)$", full.names = TRUE)
if (length(jjm_files) > 0) {
  cat("Found", length(jjm_files), "JJM files\n")
  for (f in jjm_files) {
    cat("  -", basename(f), "\n")
  }
} else {
  cat("No JJM data files found yet.\n")
  cat("JJM dashboard data will be scraped or downloaded separately.\n\n")
}

cat("\n══════════════════════════════════════════════\n")
cat("STEP 5: SAVE RAW DATA INVENTORY\n")
cat("══════════════════════════════════════════════\n\n")

# Save data inventory
inventory <- data.table(
  source = c("SHRUG TD11", "SHRUG VIIRS", "SHRUG PCA11", "SHRUG PCA01",
             "NFHS-5", "NFHS-4"),
  rows = c(nrow(td11), nrow(viirs), nrow(pca11), nrow(pca01),
           ifelse(exists("nfhs5"), nrow(nfhs5), 0),
           ifelse(exists("nfhs4"), nrow(nfhs4), 0)),
  cols = c(ncol(td11), ncol(viirs), ncol(pca11), ncol(pca01),
           ifelse(exists("nfhs5"), ncol(nfhs5), 0),
           ifelse(exists("nfhs4"), ncol(nfhs4), 0))
)
cat("Data Inventory:\n")
print(inventory)

# Save key objects for downstream scripts
save(td11, viirs, pca11, pca01, file = file.path(data_dir, "shrug_raw.RData"))
cat("\nSHRUG raw data saved to", file.path(data_dir, "shrug_raw.RData"), "\n")

if (exists("nfhs5") && exists("nfhs4")) {
  save(nfhs5, nfhs4, file = file.path(data_dir, "nfhs_raw.RData"))
  cat("NFHS data saved to", file.path(data_dir, "nfhs_raw.RData"), "\n")
}

cat("\n✓ Data acquisition complete\n")
