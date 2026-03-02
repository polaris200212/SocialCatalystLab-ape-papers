## ============================================================
## 01_fetch_data.R — Data acquisition (v3: BPE + expanded)
## Downloads: RNE councillor data, commune population data,
## INSEE census employment data, municipal finances (DGFIP),
## 2020 election candidacy data, Sirene business creation,
## BPE public equipment data
## ============================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ----------------------------------------------------------
## 1. Répertoire National des Élus (RNE) — Municipal Councillors
##    Source: data.gouv.fr, Ministry of Interior
## ----------------------------------------------------------

rne_url <- "https://static.data.gouv.fr/resources/repertoire-national-des-elus-1/20251223-103336/elus-conseillers-municipaux-cm.csv"
rne_file <- file.path(data_dir, "rne_conseillers_municipaux.csv")

if (!file.exists(rne_file)) {
  cat("Downloading RNE municipal councillors data...\n")
  download.file(rne_url, rne_file, mode = "wb")
  cat("  Downloaded:", round(file.info(rne_file)$size / 1e6, 1), "MB\n")
} else {
  cat("RNE data already exists.\n")
}

rne <- read_delim(rne_file, delim = ";",
                  locale = locale(encoding = "UTF-8"),
                  show_col_types = FALSE)
cat("RNE:", nrow(rne), "rows,", ncol(rne), "columns\n")

## ----------------------------------------------------------
## 2. Commune Data (Population + Geography)
##    Source: data.gouv.fr community dataset
## ----------------------------------------------------------

commune_url <- "https://www.data.gouv.fr/api/1/datasets/r/f5df602b-3800-44d7-b2df-fa40a0350325"
commune_file <- file.path(data_dir, "communes_france.csv")

if (!file.exists(commune_file)) {
  cat("Downloading commune data...\n")
  download.file(commune_url, commune_file, mode = "wb")
  cat("  Downloaded:", round(file.info(commune_file)$size / 1e6, 1), "MB\n")
} else {
  cat("Commune data already exists.\n")
}

communes <- read_csv(commune_file, show_col_types = FALSE)
cat("Communes:", nrow(communes), "rows,", ncol(communes), "columns\n")

## ----------------------------------------------------------
## 3. INSEE Census Employment Data (Commune Level)
##    Source: INSEE Recensement 2022
## ----------------------------------------------------------

insee_url <- "https://www.insee.fr/fr/statistiques/fichier/8581444/base-cc-emploi-pop-active-2022_csv.zip"
insee_zip <- file.path(data_dir, "base_cc_emploi_2022.zip")
insee_dir <- file.path(data_dir, "insee_emploi")

if (!file.exists(insee_zip)) {
  cat("Downloading INSEE census employment data (2022)...\n")
  download.file(insee_url, insee_zip, mode = "wb")
  cat("  Downloaded:", round(file.info(insee_zip)$size / 1e6, 1), "MB\n")
}

if (!dir.exists(insee_dir)) {
  dir.create(insee_dir, showWarnings = FALSE)
  unzip(insee_zip, exdir = insee_dir)
  cat("  Unzipped to:", insee_dir, "\n")
}

## ----------------------------------------------------------
## 4. Populations Légales (Historical)
##    Source: data.gouv.fr
## ----------------------------------------------------------

pop_url <- "https://www.data.gouv.fr/api/1/datasets/r/8cb92c8f-26e2-4705-b9bf-a76aba8c0450"
pop_file <- file.path(data_dir, "populations_legales.csv")

if (!file.exists(pop_file)) {
  cat("Downloading populations légales...\n")
  download.file(pop_url, pop_file, mode = "wb")
  cat("  Downloaded:", round(file.info(pop_file)$size / 1e6, 2), "MB\n")
} else {
  cat("Populations légales data already exists.\n")
}

## ----------------------------------------------------------
## 5. NEW: DGFIP Balances Comptables des Communes
##    Municipal finances — spending by function
##    Source: data.gouv.fr (Ministère de l'Économie)
## ----------------------------------------------------------

cat("\n=== NEW DATA: Municipal Finances ===\n")

# Balances comptables — presentation croisée (nature x fonction)
# We download 2019-2022 (post-parity mandate)
finance_years <- 2019:2022
for (yr in finance_years) {
  # data.gouv.fr resource IDs for balances comptables communes
  fin_file <- file.path(data_dir, paste0("balances_comptables_communes_", yr, ".csv"))

  if (!file.exists(fin_file)) {
    cat("Downloading municipal finance data for", yr, "...\n")

    # Try the DGFIP open data portal
    fin_url <- switch(as.character(yr),
      "2022" = "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/balances-comptables-des-communes-en-2022/exports/csv?delimiter=%3B&use_labels=false",
      "2021" = "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/balances-comptables-des-communes-en-2021/exports/csv?delimiter=%3B&use_labels=false",
      "2020" = "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/balances-comptables-des-communes-en-2020/exports/csv?delimiter=%3B&use_labels=false",
      "2019" = "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/balances-comptables-des-communes-en-2019/exports/csv?delimiter=%3B&use_labels=false"
    )

    tryCatch({
      download.file(fin_url, fin_file, mode = "wb", quiet = TRUE)
      fsize <- file.info(fin_file)$size
      if (fsize < 1000) {
        cat("  WARNING: File too small (", fsize, "bytes), may have failed\n")
        # Try alternative URL format
        fin_url_alt <- paste0(
          "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/",
          "balances-comptables-des-communes-en-", yr,
          "/exports/csv?delimiter=%3B&use_labels=true"
        )
        download.file(fin_url_alt, fin_file, mode = "wb", quiet = TRUE)
        fsize <- file.info(fin_file)$size
      }
      cat("  Downloaded:", round(fsize / 1e6, 1), "MB\n")
    }, error = function(e) {
      cat("  ERROR downloading", yr, ":", e$message, "\n")
    })
  } else {
    cat("Municipal finance", yr, "already exists (",
        round(file.info(fin_file)$size / 1e6, 1), "MB)\n")
  }
}

## ----------------------------------------------------------
## 6. NEW: 2020 Municipal Election Candidacy Data
##    Source: data.gouv.fr (Ministry of Interior)
##    Two files: communes >=1000 and <1000
## ----------------------------------------------------------

cat("\n=== NEW DATA: 2020 Election Candidacies ===\n")

# Communes >= 1000 (list-based voting with parity)
cand_above_url <- "https://static.data.gouv.fr/resources/elections-municipales-2020-candidatures-au-1er-tour/20200228-093340/municipales2020-candidatures-T1-communes-1000etplus.txt"
cand_above_file <- file.path(data_dir, "candidatures_2020_above1000.txt")

if (!file.exists(cand_above_file)) {
  cat("Downloading 2020 candidacy data (communes >= 1000)...\n")
  tryCatch({
    download.file(cand_above_url, cand_above_file, mode = "wb")
    cat("  Downloaded:", round(file.info(cand_above_file)$size / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  ERROR:", e$message, "\n")
    # Try xlsx format
    cand_above_url2 <- "https://static.data.gouv.fr/resources/elections-municipales-2020-candidatures-au-1er-tour/20200228-093150/municipales2020-candidatures-T1-communes-1000etplus.xlsx"
    tryCatch({
      download.file(cand_above_url2, sub("\\.txt$", ".xlsx", cand_above_file), mode = "wb")
      cat("  Downloaded XLSX format\n")
    }, error = function(e2) cat("  Also failed XLSX:", e2$message, "\n"))
  })
} else {
  cat("2020 candidacy data (above) already exists.\n")
}

# Communes < 1000 (majority voting, no parity)
cand_below_url <- "https://static.data.gouv.fr/resources/elections-municipales-2020-candidatures-au-1er-tour/20200228-093505/municipales2020-candidatures-T1-communes-moins-de-1000.txt"
cand_below_file <- file.path(data_dir, "candidatures_2020_below1000.txt")

if (!file.exists(cand_below_file)) {
  cat("Downloading 2020 candidacy data (communes < 1000)...\n")
  tryCatch({
    download.file(cand_below_url, cand_below_file, mode = "wb")
    cat("  Downloaded:", round(file.info(cand_below_file)$size / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  ERROR:", e$message, "\n")
    cand_below_url2 <- "https://static.data.gouv.fr/resources/elections-municipales-2020-candidatures-au-1er-tour/20200228-093419/municipales2020-candidatures-T1-communes-moins-de-1000.xlsx"
    tryCatch({
      download.file(cand_below_url2, sub("\\.txt$", ".xlsx", cand_below_file), mode = "wb")
      cat("  Downloaded XLSX format\n")
    }, error = function(e2) cat("  Also failed XLSX:", e2$message, "\n"))
  })
} else {
  cat("2020 candidacy data (below) already exists.\n")
}

## ----------------------------------------------------------
## 7. NEW: INSEE Sirene — Business registrations
##    Source: data.gouv.fr (INSEE)
##    Stock file with sexeUniteLegale for sole proprietors
## ----------------------------------------------------------

cat("\n=== NEW DATA: Business Creation (Sirene) ===\n")

# Sirene stock file is very large (>6GB). Instead, use the
# "Créations d'entreprises" (business creation) dataset which
# is pre-aggregated at commune level
sirene_url <- "https://www.insee.fr/fr/statistiques/fichier/2015441/creations_par_commune.zip"
sirene_file <- file.path(data_dir, "creations_entreprises_commune.zip")
sirene_dir <- file.path(data_dir, "sirene_creations")

if (!file.exists(sirene_file)) {
  cat("Downloading INSEE business creation data by commune...\n")
  tryCatch({
    download.file(sirene_url, sirene_file, mode = "wb")
    cat("  Downloaded:", round(file.info(sirene_file)$size / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  Primary URL failed:", e$message, "\n")
    # Alternative: use Sirene API to get creation counts
    # We'll construct from the stock file monthly extracts
    sirene_url2 <- "https://files.data.gouv.fr/insee-sirene/StockEtablissement_utf8.zip"
    cat("  NOTE: Full Sirene stock is >6GB. Using geo-coded establishment file instead.\n")
    # Use the lighter geoloc file
    sirene_url3 <- "https://files.data.gouv.fr/insee-sirene-geo/GeolocalisationEtablissement_Sirene_pour_etudes_statistiques_utf8.zip"
    tryCatch({
      download.file(sirene_url3, file.path(data_dir, "sirene_geoloc.zip"), mode = "wb")
      cat("  Downloaded geoloc file\n")
    }, error = function(e2) {
      cat("  Sirene geoloc also failed:", e2$message, "\n")
      cat("  Will use Sirene API for commune-level counts in cleaning step\n")
    })
  })
}

if (file.exists(sirene_file) && !dir.exists(sirene_dir)) {
  dir.create(sirene_dir, showWarnings = FALSE)
  tryCatch(unzip(sirene_file, exdir = sirene_dir),
           error = function(e) cat("  Unzip failed:", e$message, "\n"))
}

## ----------------------------------------------------------
## 8. NEW v3: BPE (Base Permanente des Équipements)
##    Commune-level public facility counts
##    Source: INSEE / data.gouv.fr
## ----------------------------------------------------------

cat("\n=== NEW v3 DATA: BPE Public Equipment ===\n")

# BPE 2024 — latest vintage (replaces BPE 2023)
bpe_url <- "https://www.insee.fr/fr/statistiques/fichier/8217525/BPE24.zip"
bpe_file <- file.path(data_dir, "bpe24_ensemble.zip")
bpe_dir <- file.path(data_dir, "bpe24")

if (!file.exists(bpe_file)) {
  cat("Downloading BPE 2023 (public equipment data)...\n")
  tryCatch({
    download.file(bpe_url, bpe_file, mode = "wb")
    fsize <- file.info(bpe_file)$size
    cat("  Downloaded:", round(fsize / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  Primary URL failed:", e$message, "\n")
    # Try alternative URL
    bpe_url2 <- "https://www.data.gouv.fr/api/1/datasets/r/7f85d7e7-f60d-4e0e-99af-eef3529191f0"
    tryCatch({
      download.file(bpe_url2, bpe_file, mode = "wb")
      cat("  Downloaded from data.gouv.fr\n")
    }, error = function(e2) {
      cat("  Also failed:", e2$message, "\n")
    })
  })
} else {
  cat("BPE 2023 already exists (",
      round(file.info(bpe_file)$size / 1e6, 1), "MB)\n")
}

if (file.exists(bpe_file) && !dir.exists(bpe_dir)) {
  dir.create(bpe_dir, showWarnings = FALSE)
  tryCatch({
    unzip(bpe_file, exdir = bpe_dir)
    cat("  Unzipped to:", bpe_dir, "\n")
  }, error = function(e) cat("  Unzip failed:", e$message, "\n"))
}

# BPE 2018 — pre-treatment vintage for placebo
# Historical BPE files may not be available; skip if download fails
bpe18_url <- "https://www.insee.fr/fr/statistiques/fichier/3568656/bpe18_ensemble_xy_csv.zip"
bpe18_file <- file.path(data_dir, "bpe18_ensemble.zip")
bpe18_dir <- file.path(data_dir, "bpe18")

if (!file.exists(bpe18_file)) {
  cat("Downloading BPE 2018 (pre-treatment vintage)...\n")
  tryCatch({
    download.file(bpe18_url, bpe18_file, mode = "wb")
    cat("  Downloaded:", round(file.info(bpe18_file)$size / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  BPE 2018 download failed:", e$message, "\n")
    cat("  Will proceed with BPE 2023 only\n")
  })
} else {
  cat("BPE 2018 already exists (",
      round(file.info(bpe18_file)$size / 1e6, 1), "MB)\n")
}

if (file.exists(bpe18_file) && !dir.exists(bpe18_dir)) {
  dir.create(bpe18_dir, showWarnings = FALSE)
  tryCatch({
    unzip(bpe18_file, exdir = bpe18_dir)
    cat("  Unzipped to:", bpe18_dir, "\n")
  }, error = function(e) cat("  Unzip failed:", e$message, "\n"))
}

cat("\n=== Data acquisition complete ===\n")
cat("Files in data directory:\n")
for (f in list.files(data_dir, recursive = FALSE)) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, "(", round(sz / 1e6, 1), "MB)\n")
}
