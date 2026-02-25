## ==========================================================================
## 01_fetch_data.R — Download DVF and ZFE boundary data
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- 1. Download DVF departmental data ----
# DVF (Demandes de Valeurs Foncières) - geocoded property transactions
# Source: https://files.data.gouv.fr/geo-dvf/
# License: Licence Ouverte / Open Licence 2.0

# Target departments for ZFE cities:
#   Paris (Grand Paris Métropole / A86): 75, 92, 93, 94
#   Lyon: 69
#   Grenoble: 38
#   Strasbourg: 67

departments <- c("75", "92", "93", "94", "69", "38", "67")
years <- 2018:2023  # Pre-ZFE (2018) through post-ZFE (2023)

dvf_raw_dir <- file.path(data_dir, "dvf_raw")
dir.create(dvf_raw_dir, showWarnings = FALSE, recursive = TRUE)

cat("Downloading DVF data...\n")
for (yr in years) {
  for (dep in departments) {
    dest <- file.path(dvf_raw_dir, paste0("dvf_", yr, "_", dep, ".csv.gz"))
    if (file.exists(dest)) {
      cat("  Already exists:", basename(dest), "\n")
      next
    }
    url <- paste0("https://files.data.gouv.fr/geo-dvf/latest/csv/",
                   yr, "/departements/", dep, ".csv.gz")
    cat("  Downloading:", url, "\n")
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      cat("    OK (", file.size(dest) / 1e6, "MB)\n")
    }, error = function(e) {
      cat("    FAILED:", e$message, "\n")
      if (file.exists(dest)) file.remove(dest)
    })
    Sys.sleep(0.5)  # polite rate limiting
  }
}

# ---- 2. Download ZFE boundary data ----
zfe_dir <- file.path(data_dir, "zfe_boundaries")
dir.create(zfe_dir, showWarnings = FALSE, recursive = TRUE)

# Paris ZFE (Grand Paris Métropole)
# Source: Paris Open Data
paris_zfe <- file.path(zfe_dir, "zfe_paris.geojson")
if (!file.exists(paris_zfe)) {
  cat("Downloading Paris ZFE boundary...\n")
  download.file(
    "https://opendata.paris.fr/api/explore/v2.1/catalog/datasets/zone-a-faibles-emissions/exports/geojson",
    paris_zfe, mode = "wb", quiet = TRUE
  )
  cat("  OK\n")
}

# Grenoble ZFE
# Source: Grenoble Métropole Open Data
grenoble_zfe <- file.path(zfe_dir, "zfe_grenoble.geojson")
if (!file.exists(grenoble_zfe)) {
  cat("Downloading Grenoble ZFE boundary...\n")
  tryCatch({
    download.file(
      "https://data.metropolegrenoble.fr/api/explore/v2.1/catalog/datasets/les-zones-a-faibles-emissions-zfe/exports/geojson",
      grenoble_zfe, mode = "wb", quiet = TRUE
    )
    cat("  OK\n")
  }, error = function(e) {
    cat("  FAILED:", e$message, "\n")
  })
}

# Lyon ZFE
# Source: Grand Lyon Open Data
lyon_zfe <- file.path(zfe_dir, "zfe_lyon.geojson")
if (!file.exists(lyon_zfe)) {
  cat("Downloading Lyon ZFE boundary...\n")
  tryCatch({
    download.file(
      "https://download.data.grandlyon.com/wfs/grandlyon?SERVICE=WFS&VERSION=2.0.0&request=GetFeature&typename=met_metropole.envzonefaiblesemissions&SRSNAME=EPSG:4326&outputFormat=application/json",
      lyon_zfe, mode = "wb", quiet = TRUE
    )
    cat("  OK\n")
  }, error = function(e) {
    cat("  FAILED:", e$message, "\n")
  })
}

# Strasbourg ZFE
# Source: Eurométropole de Strasbourg Open Data
strasbourg_zfe <- file.path(zfe_dir, "zfe_strasbourg.geojson")
if (!file.exists(strasbourg_zfe)) {
  cat("Downloading Strasbourg ZFE boundary...\n")
  tryCatch({
    download.file(
      "https://data.strasbourg.eu/api/explore/v2.1/catalog/datasets/zfe_perimetre/exports/geojson",
      strasbourg_zfe, mode = "wb", quiet = TRUE
    )
    cat("  OK\n")
  }, error = function(e) {
    cat("  FAILED:", e$message, "\n")
  })
}

# ---- 3. Verify downloads ----
cat("\n=== Download Summary ===\n")

# DVF files
dvf_files <- list.files(dvf_raw_dir, pattern = "dvf_.*\\.csv\\.gz$", full.names = TRUE)
cat("DVF files downloaded:", length(dvf_files), "of", length(departments) * length(years), "\n")
total_mb <- sum(file.size(dvf_files)) / 1e6
cat("Total DVF size:", round(total_mb, 1), "MB\n")

# ZFE files
zfe_files <- list.files(zfe_dir, pattern = "\\.geojson$", full.names = TRUE)
cat("ZFE boundary files:", length(zfe_files), "\n")
for (f in zfe_files) {
  tryCatch({
    g <- st_read(f, quiet = TRUE)
    cat("  ", basename(f), ":", nrow(g), "features,",
        st_geometry_type(g, by_geometry = FALSE), "\n")
  }, error = function(e) {
    cat("  ", basename(f), ": ERROR -", e$message, "\n")
  })
}

cat("\nData fetch complete.\n")
