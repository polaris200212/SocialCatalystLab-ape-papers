## ===========================================================================
## 01_fetch_data.R — Data Acquisition
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================
## Sources:
##   1. DVF (Demandes de Valeurs Foncières) — property transactions
##   2. REI (Impôts locaux) — commune-level tax rates and revenue
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. DVF — Property Transactions
# ============================================================================

cat("=== Fetching DVF property transaction data ===\n")

# Strategy:
# A) Try the complete geolocalized DVF file (all years, ~494 MB)
# B) Fall back to year-by-year downloads for 2020-2025

# --- Approach A: Complete DVF file ---
dvf_complete <- file.path(DAT, "dvf_complete.csv.gz")

if (!file.exists(dvf_complete)) {
  cat("  Downloading complete DVF file (~494 MB)...\n")
  tryCatch({
    download.file(
      "https://www.data.gouv.fr/fr/datasets/r/d7933994-2c66-4131-a4da-cf7cd18040a4",
      dvf_complete, mode = "wb", quiet = FALSE,
      method = "libcurl",
      extra = "--connect-timeout 30"
    )
    cat(sprintf("    Downloaded: %.1f MB\n", file.size(dvf_complete) / 1e6))
  }, error = function(e) {
    cat(sprintf("  Complete DVF download failed: %s\n", e$message))
    cat("  Falling back to year-by-year downloads...\n")
  })
}

# --- Approach B: Year-by-year (geo-DVF, 2020-2025) ---
dvf_yearly_url <- "https://files.data.gouv.fr/geo-dvf/latest/csv/"
years_available <- 2020:2024

for (yr in years_available) {
  dest <- file.path(DAT, sprintf("dvf_%d.csv.gz", yr))
  if (!file.exists(dest)) {
    url <- sprintf("%s%d/full.csv.gz", dvf_yearly_url, yr)
    cat(sprintf("  Downloading DVF %d...\n", yr))
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      cat(sprintf("    Downloaded: %.1f MB\n", file.size(dest) / 1e6))
    }, error = function(e) {
      cat(sprintf("    DVF %d failed: %s\n", yr, e$message))
    })
  } else {
    cat(sprintf("  DVF %d already exists (%.1f MB)\n", yr,
                file.size(dest) / 1e6))
  }
}

# --- Also try original (non-geo) DVF for 2014-2019 ---
# These are TXT files from DGFiP, pipe-delimited
# The original DVF dataset rolls over (only keeps 5 years), but try anyway
orig_dvf_ids <- list(
  "2024" = "95cc3843-3ec2-440a-8e16-e3bb17086091",
  "2023" = "17fc8311-5188-4ba3-8671-7b30dd6aab8b",
  "2022" = "3c18e534-8e2e-4e82-9c34-76115e3f09e6",
  "2021" = "5cc7f9a3-e803-4dfe-be6b-6e304ec23443",
  "2020" = "90a98de0-f562-4328-aa16-fe0dd1dca60f"
)

for (yr_name in names(orig_dvf_ids)) {
  dest <- file.path(DAT, sprintf("dvf_orig_%s.txt.gz", yr_name))
  if (!file.exists(dest)) {
    url <- paste0("https://www.data.gouv.fr/fr/datasets/r/", orig_dvf_ids[[yr_name]])
    cat(sprintf("  Downloading original DVF %s...\n", yr_name))
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      if (file.size(dest) > 10000) {
        cat(sprintf("    Downloaded: %.1f MB\n", file.size(dest) / 1e6))
      } else {
        cat(sprintf("    File too small (%.0f bytes), likely error page\n", file.size(dest)))
        file.remove(dest)
      }
    }, error = function(e) {
      cat(sprintf("    Original DVF %s failed: %s\n", yr_name, e$message))
    })
  }
}

# ============================================================================
# 2. Read DVF Data
# ============================================================================

cat("\n=== Reading DVF data ===\n")

dvf_cols <- c("id_mutation", "date_mutation", "nature_mutation",
              "valeur_fonciere", "code_commune", "code_departement",
              "code_postal", "type_local", "surface_reelle_bati",
              "nombre_pieces_principales", "surface_terrain",
              "longitude", "latitude")

# Try complete file first
if (file.exists(dvf_complete) && file.size(dvf_complete) > 1e6) {
  cat("  Reading complete DVF file...\n")
  tryCatch({
    dvf <- fread(dvf_complete, select = dvf_cols, na.strings = c("", "NA"))
    cat(sprintf("  Loaded %d rows\n", nrow(dvf)))

    # Check what years are available
    dvf[, date_parsed := as.Date(date_mutation)]
    dvf[, year := year(date_parsed)]
    cat(sprintf("  Years in data: %s\n", paste(sort(unique(dvf$year)), collapse = ", ")))
  }, error = function(e) {
    cat(sprintf("  Failed to read complete file: %s\n", e$message))
    cat("  Falling back to yearly files...\n")
    dvf <- NULL
  })
} else {
  dvf <- NULL
}

# Fall back to yearly files
if (is.null(dvf) || nrow(dvf) == 0) {
  cat("  Reading year-by-year DVF files...\n")
  dvf_list <- list()

  for (yr in years_available) {
    fpath <- file.path(DAT, sprintf("dvf_%d.csv.gz", yr))
    if (!file.exists(fpath)) next
    cat(sprintf("  Reading DVF %d...\n", yr))
    tryCatch({
      tmp <- fread(fpath, select = dvf_cols, na.strings = c("", "NA"))
      tmp[, year := yr]
      dvf_list[[as.character(yr)]] <- tmp
      cat(sprintf("    %d: %d rows\n", yr, nrow(tmp)))
    }, error = function(e) {
      cat(sprintf("    Failed: %s\n", e$message))
    })
  }

  if (length(dvf_list) == 0) {
    stop("No DVF data could be loaded. Cannot proceed.\nCheck download URLs or data availability.")
  }

  dvf <- rbindlist(dvf_list, fill = TRUE)
  rm(dvf_list)
  gc()

  # Parse dates
  dvf[, date_parsed := as.Date(date_mutation)]
  if (!"year" %in% names(dvf)) dvf[, year := year(date_parsed)]
}

cat(sprintf("\nTotal DVF rows: %d\n", nrow(dvf)))
cat(sprintf("Years: %s\n", paste(sort(unique(dvf$year)), collapse = ", ")))

# --- Filter to residential sales ---
cat("\n=== Filtering to residential sales ===\n")

dvf <- dvf[nature_mutation == "Vente"]
dvf <- dvf[type_local %in% c("Appartement", "Maison")]
dvf <- dvf[!is.na(valeur_fonciere) & valeur_fonciere > 0]
dvf <- dvf[!is.na(surface_reelle_bati) & surface_reelle_bati > 0]
dvf <- dvf[!code_departement %in% c("67", "68", "57")]

dvf[, price_m2 := valeur_fonciere / surface_reelle_bati]
dvf[, month := month(date_parsed)]
dvf[, quarter := quarter(date_parsed)]

# Drop extreme outliers
n_before <- nrow(dvf)
dvf <- dvf[price_m2 >= 100 & price_m2 <= 30000]
cat(sprintf("  Dropped %d outliers (%.1f%%)\n",
            n_before - nrow(dvf), 100 * (n_before - nrow(dvf)) / n_before))

cat(sprintf("  Final: %d transactions, %d communes, years %s\n",
            nrow(dvf), uniqueN(dvf$code_commune),
            paste(sort(unique(dvf$year)), collapse=", ")))


# ============================================================================
# 3. REI — Tax Rate Data
# ============================================================================

cat("\n=== Fetching tax rate data ===\n")

# Primary source: data.economie.gouv.fr API with all years
rei_dest <- file.path(DAT, "rei_economie.csv")

if (!file.exists(rei_dest) || file.size(rei_dest) < 1000) {
  cat("  Downloading REI from data.economie.gouv.fr...\n")

  # The API exports commune-level tax rates
  rei_url <- paste0(
    "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/",
    "impots-locaux-fichier-de-recensement-des-elements-dimposition-a-la-fiscalite-dir",
    "/exports/csv?select=annee,code_commune,libelle_commune,code_departement,",
    "taux_th_commune,taux_tfb_commune,taux_tfnb_commune,",
    "produit_th_commune,produit_tfb_commune,",
    "base_nette_th_commune,base_nette_tfb_commune",
    "&limit=-1&delimiter=,")

  tryCatch({
    download.file(rei_url, rei_dest, mode = "wb", quiet = FALSE)
    cat(sprintf("    Downloaded: %.1f MB\n", file.size(rei_dest) / 1e6))
  }, error = function(e) {
    cat(sprintf("  REI download failed: %s\n", e$message))
  })
}

# Also download individual year ZIPs from data.gouv.fr as fallback
rei_resources <- list(
  "2017" = "a1fa0b09-bf38-4e07-a60d-04a1be2e9981",
  "2018" = "e42c59c7-3d64-4f34-b258-3c4683447c46",
  "2019" = "1f2a36c6-a104-4e19-8a49-e7b0cfe70639",
  "2020" = "b8db13f6-5219-4077-b07a-cfc1f5274478"
)

for (yr_name in names(rei_resources)) {
  dest <- file.path(DAT, sprintf("rei_%s.zip", yr_name))
  if (!file.exists(dest)) {
    url <- paste0("https://www.data.gouv.fr/fr/datasets/r/", rei_resources[[yr_name]])
    cat(sprintf("  Downloading REI %s...\n", yr_name))
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      if (file.size(dest) > 10000) {
        cat(sprintf("    Downloaded: %.1f MB\n", file.size(dest) / 1e6))
      } else {
        file.remove(dest)
      }
    }, error = function(e) NULL)
  }
}

# Also try the "Fiscalité locale des particuliers" dataset (2021-2024 rates)
fisc_url <- "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/fiscalite-locale-des-particuliers-taux-votes-par-les-communes-et-les-intercommunalites/exports/csv?limit=-1&delimiter=,"
fisc_dest <- file.path(DAT, "fiscalite_locale.csv")

if (!file.exists(fisc_dest)) {
  cat("  Downloading Fiscalité locale des particuliers...\n")
  tryCatch({
    download.file(fisc_url, fisc_dest, mode = "wb", quiet = TRUE)
    cat(sprintf("    Downloaded: %.1f MB\n", file.size(fisc_dest) / 1e6))
  }, error = function(e) {
    cat(sprintf("  Fiscalité locale download failed: %s\n", e$message))
  })
}


# ============================================================================
# 4. Save Raw DVF
# ============================================================================

cat("\n=== Saving processed DVF ===\n")
fwrite(dvf, file.path(DAT, "dvf_residential.csv"))
cat(sprintf("  Saved: dvf_residential.csv (%.1f MB, %d rows)\n",
            file.size(file.path(DAT, "dvf_residential.csv")) / 1e6, nrow(dvf)))


# ============================================================================
# 5. DATA VALIDATION
# ============================================================================

cat("\n=== Data Validation ===\n")

n_depts <- uniqueN(dvf$code_departement)
n_years <- uniqueN(dvf$year)
min_per_year <- dvf[, .N, by = year][, min(N)]

stopifnot("Expected 80+ departments" = n_depts >= 80)
stopifnot("Expected multiple years" = n_years >= 3)
stopifnot("Expected >50K transactions per year" = min_per_year > 50000)
stopifnot("Expected positive prices" = all(dvf$valeur_fonciere > 0))

cat(sprintf("DVF validated: %d transactions, %d communes, %d departments, %d years\n",
            nrow(dvf), uniqueN(dvf$code_commune), n_depts, n_years))

cat("\nTransactions by year:\n")
print(dvf[, .(n = .N, mean_pm2 = round(mean(price_m2)),
              med_pm2 = round(median(price_m2))), by = year][order(year)])

cat("\n=== Data fetch complete ===\n")
