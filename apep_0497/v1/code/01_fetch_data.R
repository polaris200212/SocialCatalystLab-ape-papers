## =============================================================================
## 01_fetch_data.R — Fetch all data sources
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== DATA ACQUISITION ===\n")
cat("Fetching: DVF (CdD + raw), REI, Filosofi, RP Logement\n\n")

## =============================================================================
## 1A. DVF Commune Aggregates 2014-2020 (Caisse des Dépôts open data)
## =============================================================================

cat("--- DVF Commune Aggregates 2014-2020 (Caisse des Dépôts) ---\n")

dvf_dir <- file.path(data_dir, "dvf")
dir.create(dvf_dir, showWarnings = FALSE, recursive = TRUE)

cdd_file <- file.path(dvf_dir, "dvf_commune_2014_2020.csv")

if (!file.exists(cdd_file) || file.size(cdd_file) < 1e6) {
  ## Download full commune-level DVF from Caisse des Dépôts
  ## API: paginated, max 100 records per request
  ## Total: ~175K records

  cat("  Downloading commune-level DVF from Caisse des Dépôts...\n")
  base_url <- "https://opendata.caissedesdepots.fr/api/explore/v2.1/catalog/datasets/donnees-valeurs-foncieres-a-la-commune/exports/csv?delimiter=%2C&list_separator=%2C&quote_all=false&with_bom=false"

  tryCatch({
    download.file(base_url, cdd_file, mode = "wb", quiet = FALSE)
    cat("  CdD DVF downloaded:", round(file.size(cdd_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    stop("CdD DVF download failed.\nError: ", e$message,
         "\nPivot research question or fix the source.")
  })

  stopifnot("CdD DVF file too small" = file.size(cdd_file) > 1e6)
} else {
  cat("  CdD DVF already downloaded:", round(file.size(cdd_file) / 1e6, 1), "MB\n")
}

## =============================================================================
## 1B. DVF Raw Transactions 2021-2024 (data.gouv.fr)
## =============================================================================

cat("\n--- DVF Raw Transactions 2021-2024 (data.gouv.fr) ---\n")

dvf_raw_urls <- list(
  "2021" = "https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres/20251018-234836/valeursfoncieres-2021.txt.zip",
  "2022" = "https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres/20251018-234844/valeursfoncieres-2022.txt.zip",
  "2023" = "https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres/20251018-234851/valeursfoncieres-2023.txt.zip",
  "2024" = "https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres/20251018-234857/valeursfoncieres-2024.txt.zip"
)

## Also try geo-dvf geocoded version
dvf_geo_urls <- list(
  "2021" = "https://files.data.gouv.fr/geo-dvf/latest/csv/2021/full.csv.gz",
  "2022" = "https://files.data.gouv.fr/geo-dvf/latest/csv/2022/full.csv.gz",
  "2023" = "https://files.data.gouv.fr/geo-dvf/latest/csv/2023/full.csv.gz",
  "2024" = "https://files.data.gouv.fr/geo-dvf/latest/csv/2024/full.csv.gz"
)

for (yr in names(dvf_geo_urls)) {
  geo_file <- file.path(dvf_dir, paste0("dvf_geo_", yr, ".csv.gz"))
  raw_file <- file.path(dvf_dir, paste0("dvf_raw_", yr, ".txt.zip"))

  if ((file.exists(geo_file) && file.size(geo_file) > 1e6) ||
      (file.exists(raw_file) && file.size(raw_file) > 1e6)) {
    cat("  DVF", yr, "already downloaded\n")
    next
  }

  ## Try geo-dvf first
  cat("  Downloading DVF", yr, "(geo-dvf)...\n")
  tryCatch({
    download.file(dvf_geo_urls[[yr]], geo_file, mode = "wb", quiet = FALSE)
    if (file.size(geo_file) > 1e6) {
      cat("  DVF", yr, "(geo) downloaded:", round(file.size(geo_file) / 1e6, 1), "MB\n")
      next
    }
  }, error = function(e) {
    cat("  Geo-dvf failed, trying raw...\n")
  })

  ## Fall back to raw DVF
  cat("  Downloading DVF", yr, "(raw)...\n")
  tryCatch({
    download.file(dvf_raw_urls[[yr]], raw_file, mode = "wb", quiet = FALSE)
    cat("  DVF", yr, "(raw) downloaded:", round(file.size(raw_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    stop("DVF ", yr, " unavailable.\nError: ", e$message,
         "\nPivot research question or fix the source.")
  })
}

## =============================================================================
## 2. REI (Recensement des Éléments d'Imposition) — Commune Tax Rates
## =============================================================================

cat("\n--- REI: Commune-level tax rates ---\n")

rei_dir <- file.path(data_dir, "rei")
dir.create(rei_dir, showWarnings = FALSE, recursive = TRUE)

rei_file <- file.path(rei_dir, "rei_full.csv")

if (!file.exists(rei_file) || file.size(rei_file) < 1e6) {
  rei_url <- "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/impots-locaux-fichier-de-recensement-des-elements-dimposition-a-la-fiscalite-dir/exports/csv?delimiter=%3B&list_separator=%2C&quote_all=false&with_bom=true"

  cat("  Downloading REI from data.economie.gouv.fr...\n")
  tryCatch({
    download.file(rei_url, rei_file, mode = "wb", quiet = FALSE)
    cat("  REI downloaded:", round(file.size(rei_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    stop("REI data unavailable.\nError: ", e$message,
         "\nPivot research question or fix the source.")
  })
} else {
  cat("  REI already downloaded:", round(file.size(rei_file) / 1e6, 1), "MB\n")
}

## =============================================================================
## 3. Filosofi — Commune-Level Income Distribution (2017)
## =============================================================================

cat("\n--- Filosofi: Income distribution 2017 ---\n")

filo_dir <- file.path(data_dir, "filosofi")
dir.create(filo_dir, showWarnings = FALSE, recursive = TRUE)

filo_file <- file.path(filo_dir, "filosofi_2017.csv")

if (!file.exists(filo_file) || file.size(filo_file) < 1e4) {
  filo_urls <- c(
    "https://www.insee.fr/fr/statistiques/fichier/4291712/indic-struct-distrib-revenu-2017-COMMUNES_csv.zip",
    "https://www.insee.fr/fr/statistiques/fichier/4291712/FILO2017_DISP_COM_csv.zip",
    "https://www.insee.fr/fr/statistiques/fichier/4291712/base-cc-filosofi-2017_csv.zip"
  )

  filo_zip <- file.path(filo_dir, "filosofi_2017.zip")
  downloaded <- FALSE

  for (url in filo_urls) {
    cat("  Trying:", url, "\n")
    tryCatch({
      download.file(url, filo_zip, mode = "wb", quiet = FALSE)
      if (file.size(filo_zip) > 1e4) {
        unzip(filo_zip, exdir = filo_dir)
        extracted <- list.files(filo_dir, pattern = "\\.(csv|CSV)$",
                                full.names = TRUE, recursive = TRUE)
        if (length(extracted) > 0) {
          file.copy(extracted[1], filo_file, overwrite = TRUE)
          cat("  Filosofi 2017 extracted:", round(file.size(filo_file) / 1e6, 1), "MB\n")
          downloaded <- TRUE
          break
        }
      }
    }, error = function(e) {
      cat("  Failed:", e$message, "\n")
    })
  }

  if (!downloaded) {
    cat("  WARNING: Filosofi download failed. Will construct proxy.\n")
  }
} else {
  cat("  Filosofi 2017 already downloaded\n")
}

## =============================================================================
## 4. RP Logement — Housing Census (Primary vs Secondary Residences)
## =============================================================================

cat("\n--- RP Logement: Housing census 2017 ---\n")

rp_dir <- file.path(data_dir, "rp")
dir.create(rp_dir, showWarnings = FALSE, recursive = TRUE)

rp_file <- file.path(rp_dir, "rp_logement_2017.csv")

if (!file.exists(rp_file) || file.size(rp_file) < 1e4) {
  rp_urls <- c(
    "https://www.insee.fr/fr/statistiques/fichier/4515539/base-cc-logement-2017_csv.zip",
    "https://www.insee.fr/fr/statistiques/fichier/4515540/base-cc-logement-2017_csv.zip"
  )

  rp_zip <- file.path(rp_dir, "rp_logement_2017.zip")
  downloaded <- FALSE

  for (url in rp_urls) {
    cat("  Trying:", url, "\n")
    tryCatch({
      download.file(url, rp_zip, mode = "wb", quiet = FALSE)
      if (file.size(rp_zip) > 1e4) {
        unzip(rp_zip, exdir = rp_dir)
        extracted <- list.files(rp_dir, pattern = "\\.(csv|CSV)$",
                                full.names = TRUE, recursive = TRUE)
        if (length(extracted) > 0) {
          file.copy(extracted[1], rp_file, overwrite = TRUE)
          cat("  RP Logement 2017 extracted:", round(file.size(rp_file) / 1e6, 1), "MB\n")
          downloaded <- TRUE
          break
        }
      }
    }, error = function(e) {
      cat("  Failed:", e$message, "\n")
    })
  }

  if (!downloaded) {
    cat("  WARNING: RP download failed. Will proceed without.\n")
  }
} else {
  cat("  RP Logement 2017 already downloaded\n")
}

## =============================================================================
## 5. Validation
## =============================================================================

cat("\n=== DATA VALIDATION ===\n")

## Check CdD DVF
stopifnot("CdD DVF must exist and be > 1MB" = file.exists(cdd_file) && file.size(cdd_file) > 1e6)
cat("CdD DVF (2014-2020):", round(file.size(cdd_file) / 1e6, 1), "MB\n")

## Check recent DVF files
recent_files <- list.files(dvf_dir, pattern = "dvf_(geo|raw)_202[1-4]", full.names = TRUE)
recent_files <- recent_files[file.size(recent_files) > 1e6]
cat("Recent DVF files (2021-2024):", length(recent_files), "found\n")
stopifnot("Need at least 3 recent DVF files" = length(recent_files) >= 3)

## Check REI
stopifnot("REI file must exist and be > 1MB" = file.exists(rei_file) && file.size(rei_file) > 1e6)
cat("REI:", round(file.size(rei_file) / 1e6, 1), "MB\n")

cat("\nData acquisition complete.\n")
