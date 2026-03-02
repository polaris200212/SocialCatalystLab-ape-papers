## ============================================================================
## 01_fetch_data.R — Connected Backlash (apep_0464 v3)
## Fetch all required data from public APIs and open data sources
## v3: Add INSEE migration flows (WS2), unemployment/education/immigration (WS3)
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## 1. FACEBOOK SOCIAL CONNECTEDNESS INDEX (SCI)
## ============================================================================

cat("\n=== Downloading SCI data ===\n")

sci_url <- "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/b691d1d1-b286-456d-9a23-16e2f2d463cc/download/nuts_2024.zip"
sci_zip <- file.path(DATA_DIR, "nuts_2024.zip")
sci_dir <- file.path(DATA_DIR, "sci")

if (!file.exists(sci_zip)) {
  download.file(sci_url, sci_zip, mode = "wb", quiet = FALSE)
  dir.create(sci_dir, showWarnings = FALSE)
  unzip(sci_zip, exdir = sci_dir)
  cat("SCI data downloaded and extracted.\n")
} else {
  cat("SCI data already exists, skipping download.\n")
}

sci_files <- list.files(sci_dir, pattern = "\\.tsv$|\\.csv$", recursive = TRUE, full.names = TRUE)
cat("SCI files found:", length(sci_files), "\n")

## ============================================================================
## 2. FRENCH ELECTION DATA (Aggregated Parquet)
## ============================================================================

cat("\n=== Downloading election data ===\n")

elections_dir <- file.path(DATA_DIR, "elections")
dir.create(elections_dir, showWarnings = FALSE)

cand_url <- "https://object.files.data.gouv.fr/data-pipeline-open/elections/candidats_results.parquet"
cand_file <- file.path(elections_dir, "candidats_results.parquet")

if (!file.exists(cand_file)) {
  cat("Downloading candidate results (158 MB)...\n")
  download.file(cand_url, cand_file, mode = "wb", quiet = FALSE)
} else {
  cat("Candidate results already exist.\n")
}

gen_url <- "https://object.files.data.gouv.fr/data-pipeline-open/elections/general_results.parquet"
gen_file <- file.path(elections_dir, "general_results.parquet")

if (!file.exists(gen_file)) {
  cat("Downloading general results (68 MB)...\n")
  download.file(gen_url, gen_file, mode = "wb", quiet = FALSE)
} else {
  cat("General results already exist.\n")
}

nuance_url <- "https://static.data.gouv.fr/resources/donnees-des-elections-agregees/20260216-092608/nuances-politiques.csv"
nuance_file <- file.path(elections_dir, "nuances-politiques.csv")

if (!file.exists(nuance_file)) {
  download.file(nuance_url, nuance_file, mode = "wb", quiet = FALSE)
}

## ============================================================================
## 3. FUEL CONSUMPTION BY DÉPARTEMENT (SDES)
## ============================================================================

cat("\n=== Downloading fuel consumption data ===\n")

fuel_dir <- file.path(DATA_DIR, "fuel")
dir.create(fuel_dir, showWarnings = FALSE)

fuel_url <- "https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles/76c57f55-7af5-401c-a99b-d4b7c9b6ce67/csv?millesime=2025-01&withColumnName=true&withColumnDescription=false&withColumnUnit=false&orderBy=-ANNEE"
fuel_file <- file.path(fuel_dir, "fuel_consumption_dept.csv")

if (!file.exists(fuel_file)) {
  cat("Downloading fuel consumption by département...\n")
  tryCatch({
    download.file(fuel_url, fuel_file, mode = "wb", quiet = FALSE)
  }, error = function(e) {
    cat("  DiDo API failed, trying alternative URL...\n")
    alt_url <- "https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles/76c57f55-7af5-401c-a99b-d4b7c9b6ce67/csv?millesime=2024-06&withColumnName=true"
    tryCatch({
      download.file(alt_url, fuel_file, mode = "wb", quiet = FALSE)
    }, error = function(e2) {
      cat("  WARNING: Could not download fuel consumption data.\n")
    })
  })
} else {
  cat("Fuel consumption data already exists.\n")
}

## ============================================================================
## 4. FUEL PRICES
## ============================================================================

cat("\n=== Downloading fuel price archives ===\n")

prices_dir <- file.path(fuel_dir, "prices")
dir.create(prices_dir, showWarnings = FALSE)

years_needed <- 2013:2024

for (yr in years_needed) {
  yr_zip <- file.path(prices_dir, paste0("prix_", yr, ".zip"))
  if (!file.exists(yr_zip)) {
    yr_url <- paste0("https://donnees.roulez-eco.fr/opendata/annee/", yr)
    cat(glue("  Downloading {yr}..."), "\n")
    tryCatch({
      download.file(yr_url, yr_zip, mode = "wb", quiet = TRUE)
    }, error = function(e) {
      cat(glue("  WARNING: Could not download {yr}"), "\n")
    })
  }
}

## ============================================================================
## 5. INSEE FILOSOFI (Income/Poverty by Département)
## ============================================================================

cat("\n=== Downloading INSEE Filosofi (income) data ===\n")

insee_dir <- file.path(DATA_DIR, "insee")
dir.create(insee_dir, showWarnings = FALSE)

filosofi_url <- "https://www.insee.fr/fr/statistiques/fichier/7756729/base-cc-filosofi-2021-geo2025_csv.zip"
filosofi_zip <- file.path(insee_dir, "filosofi_2021.zip")

if (!file.exists(filosofi_zip)) {
  cat("Downloading Filosofi 2021...\n")
  tryCatch({
    download.file(filosofi_url, filosofi_zip, mode = "wb", quiet = FALSE)
    unzip(filosofi_zip, exdir = file.path(insee_dir, "filosofi_2021"))
  }, error = function(e) {
    cat("  WARNING: Filosofi download failed:", e$message, "\n")
  })
} else {
  cat("Filosofi 2021 already exists.\n")
}

## ============================================================================
## 6. DÉPARTEMENT BOUNDARIES
## ============================================================================

cat("\n=== Downloading département boundaries ===\n")

geo_dir <- file.path(DATA_DIR, "geo")
dir.create(geo_dir, showWarnings = FALSE)

dept_geojson_url <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements-version-simplifiee.geojson"
dept_geojson <- file.path(geo_dir, "departements.geojson")

if (!file.exists(dept_geojson)) {
  tryCatch({
    download.file(dept_geojson_url, dept_geojson, mode = "wb", quiet = FALSE)
  }, error = function(e) {
    cat("  WARNING: GeoJSON download failed.\n")
  })
} else {
  cat("Département boundaries already exist.\n")
}

## ============================================================================
## 7. NUTS3 → DÉPARTEMENT MAPPING TABLE
## ============================================================================

cat("\n=== Creating NUTS3 ↔ département mapping ===\n")

nuts3_dept <- tribble(
  ~nuts3, ~dept_code, ~dept_name,
  "FR101", "75", "Paris",
  "FR102", "77", "Seine-et-Marne",
  "FR103", "78", "Yvelines",
  "FR104", "91", "Essonne",
  "FR105", "92", "Hauts-de-Seine",
  "FR106", "93", "Seine-Saint-Denis",
  "FR107", "94", "Val-de-Marne",
  "FR108", "95", "Val-d'Oise",
  "FRB01", "18", "Cher",
  "FRB02", "28", "Eure-et-Loir",
  "FRB03", "36", "Indre",
  "FRB04", "37", "Indre-et-Loire",
  "FRB05", "41", "Loir-et-Cher",
  "FRB06", "45", "Loiret",
  "FRC11", "21", "Côte-d'Or",
  "FRC12", "58", "Nièvre",
  "FRC13", "71", "Saône-et-Loire",
  "FRC14", "89", "Yonne",
  "FRC21", "25", "Doubs",
  "FRC22", "39", "Jura",
  "FRC23", "70", "Haute-Saône",
  "FRC24", "90", "Territoire de Belfort",
  "FRD11", "14", "Calvados",
  "FRD12", "50", "Manche",
  "FRD13", "61", "Orne",
  "FRD21", "27", "Eure",
  "FRD22", "76", "Seine-Maritime",
  "FRE11", "59", "Nord",
  "FRE12", "62", "Pas-de-Calais",
  "FRE21", "02", "Aisne",
  "FRE22", "60", "Oise",
  "FRE23", "80", "Somme",
  "FRF11", "67", "Bas-Rhin",
  "FRF12", "68", "Haut-Rhin",
  "FRF21", "08", "Ardennes",
  "FRF22", "10", "Aube",
  "FRF23", "51", "Marne",
  "FRF24", "52", "Haute-Marne",
  "FRF31", "54", "Meurthe-et-Moselle",
  "FRF32", "55", "Meuse",
  "FRF33", "57", "Moselle",
  "FRF34", "88", "Vosges",
  "FRG01", "44", "Loire-Atlantique",
  "FRG02", "49", "Maine-et-Loire",
  "FRG03", "53", "Mayenne",
  "FRG04", "72", "Sarthe",
  "FRG05", "85", "Vendée",
  "FRH01", "22", "Côtes-d'Armor",
  "FRH02", "29", "Finistère",
  "FRH03", "35", "Ille-et-Vilaine",
  "FRH04", "56", "Morbihan",
  "FRI11", "24", "Dordogne",
  "FRI12", "33", "Gironde",
  "FRI13", "40", "Landes",
  "FRI14", "47", "Lot-et-Garonne",
  "FRI15", "64", "Pyrénées-Atlantiques",
  "FRI21", "19", "Corrèze",
  "FRI22", "23", "Creuse",
  "FRI23", "87", "Haute-Vienne",
  "FRI31", "16", "Charente",
  "FRI32", "17", "Charente-Maritime",
  "FRI33", "79", "Deux-Sèvres",
  "FRI34", "86", "Vienne",
  "FRJ11", "11", "Aude",
  "FRJ12", "30", "Gard",
  "FRJ13", "34", "Hérault",
  "FRJ14", "48", "Lozère",
  "FRJ15", "66", "Pyrénées-Orientales",
  "FRJ21", "09", "Ariège",
  "FRJ22", "12", "Aveyron",
  "FRJ23", "31", "Haute-Garonne",
  "FRJ24", "32", "Gers",
  "FRJ25", "46", "Lot",
  "FRJ26", "65", "Hautes-Pyrénées",
  "FRJ27", "81", "Tarn",
  "FRJ28", "82", "Tarn-et-Garonne",
  "FRK11", "03", "Allier",
  "FRK12", "15", "Cantal",
  "FRK13", "43", "Haute-Loire",
  "FRK14", "63", "Puy-de-Dôme",
  "FRK21", "01", "Ain",
  "FRK22", "07", "Ardèche",
  "FRK23", "26", "Drôme",
  "FRK24", "38", "Isère",
  "FRK25", "42", "Loire",
  "FRK26", "69", "Rhône",
  "FRK27", "73", "Savoie",
  "FRK28", "74", "Haute-Savoie",
  "FRL01", "04", "Alpes-de-Haute-Provence",
  "FRL02", "05", "Hautes-Alpes",
  "FRL03", "06", "Alpes-Maritimes",
  "FRL04", "13", "Bouches-du-Rhône",
  "FRL05", "83", "Var",
  "FRL06", "84", "Vaucluse",
  "FRM01", "2A", "Corse-du-Sud",
  "FRM02", "2B", "Haute-Corse"
)

write_csv(nuts3_dept, file.path(DATA_DIR, "nuts3_dept_mapping.csv"))
cat("  Created mapping with", nrow(nuts3_dept), "départements.\n")

## ============================================================================
## 8. CARBON TAX RATE SCHEDULE
## ============================================================================

cat("\n=== Creating carbon tax rate schedule ===\n")

carbon_tax <- tribble(
  ~year, ~rate_eur_tco2, ~ticpe_diesel_cl, ~ticpe_sp95_cl,
  2002,  0.00, 39.19, 58.92,
  2003,  0.00, 39.19, 58.92,
  2004,  0.00, 41.69, 58.92,
  2005,  0.00, 41.69, 58.92,
  2006,  0.00, 41.69, 58.92,
  2007,  0.00, 42.84, 60.69,
  2008,  0.00, 42.84, 60.69,
  2009,  0.00, 42.84, 60.69,
  2010,  0.00, 42.84, 60.69,
  2011,  0.00, 42.84, 60.69,
  2012,  0.00, 42.84, 60.69,
  2013,  0.00, 42.84, 60.69,
  2014,  7.00, 42.84, 60.69,
  2015, 14.50, 46.82, 62.41,
  2016, 22.00, 49.81, 64.12,
  2017, 30.50, 53.07, 65.07,
  2018, 44.60, 59.40, 68.29,
  2019, 44.60, 59.40, 68.29,
  2020, 44.60, 59.40, 68.29,
  2021, 44.60, 59.40, 68.29,
  2022, 44.60, 59.40, 68.29,
  2023, 44.60, 59.40, 68.29,
  2024, 44.60, 59.40, 68.29
)

carbon_tax <- carbon_tax %>%
  mutate(
    carbon_diesel_cl = rate_eur_tco2 * 2.651 / 1000 * 100,
    carbon_sp95_cl = rate_eur_tco2 * 2.287 / 1000 * 100
  )

write_csv(carbon_tax, file.path(DATA_DIR, "carbon_tax_schedule.csv"))
cat("  Carbon tax schedule saved (2002-2024).\n")

## ============================================================================
## 9. INSEE POPULATION BY DÉPARTEMENT
## ============================================================================

cat("\n=== Downloading population estimates ===\n")

pop_url <- "https://www.insee.fr/fr/statistiques/fichier/1893198/estim-pop-dep-sexe-gca-1975-2024.xls"
pop_file <- file.path(insee_dir, "population_dept.xls")

if (!file.exists(pop_file)) {
  tryCatch({
    download.file(pop_url, pop_file, mode = "wb", quiet = FALSE)
  }, error = function(e) {
    cat("  WARNING: Population download failed:", e$message, "\n")
  })
} else {
  cat("Population data already exists.\n")
}

## ============================================================================
## v3 NEW: 10. INSEE INTER-DEPARTEMENT MIGRATION FLOWS (WS2)
## Source: INSEE RP 2013 — Migrations résidentielles
## Level: Département × Département (origin-destination matrix)
## ============================================================================

cat("\n=== v3: Downloading INSEE migration flows (WS2) ===\n")

migration_dir <- file.path(insee_dir, "migration")
dir.create(migration_dir, showWarnings = FALSE)

## INSEE provides inter-département migration matrices from the census
## RP 2013: commune of residence × commune of prior residence (5 years before)
## We use the département-level aggregated version
## Try the BDM SDMX route first, then fallback to direct file

migration_file <- file.path(migration_dir, "migration_interdept_2013.csv")

if (!file.exists(migration_file)) {
  cat("  Attempting to download migration matrix from INSEE...\n")

  ## Method 1: Direct CSV from INSEE web (migration matrix 2013)
  ## The "Migrations résidentielles" RP2013 file at département level
  mig_url <- "https://www.insee.fr/fr/statistiques/fichier/2862068/base-cc-coupl-fam-men-2013_csv.zip"
  mig_zip <- file.path(migration_dir, "rp2013_coupl.zip")

  mig_success <- FALSE

  ## Method 2: Direct table of interdepartmental flows
  ## INSEE provides MOBRES tables (residential mobility) by département
  ## Try the tableaux détaillés for RP2013
  mig_url2 <- "https://www.insee.fr/fr/statistiques/fichier/2866283/base-td-mob-dep-2013.zip"
  mig_zip2 <- file.path(migration_dir, "rp2013_mob_dep.zip")

  tryCatch({
    download.file(mig_url2, mig_zip2, mode = "wb", quiet = FALSE, timeout = 300)
    unzip(mig_zip2, exdir = migration_dir)
    cat("  Downloaded RP2013 mobility by département.\n")
    mig_success <- TRUE
  }, error = function(e) {
    cat("  WARNING: RP2013 mobility download failed:", e$message, "\n")
  })

  if (!mig_success) {
    ## Method 3: Construct from known inter-regional migration patterns
    ## Based on published INSEE regional migration data (Première No 1725, 2019)
    cat("  Constructing migration proxy from published regional flows...\n")
    cat("  (Will build migration proxy matrix from published flows in 02_clean_data.R)\n")
  }
} else {
  cat("  Migration data already exists.\n")
}

## ============================================================================
## v3 NEW: 11. INSEE UNEMPLOYMENT BY DÉPARTEMENT (WS3)
## Source: INSEE BDM / Taux de chômage localisés
## Level: Département, quarterly (we use annual average)
## ============================================================================

cat("\n=== v3: Downloading INSEE unemployment data (WS3) ===\n")

unemployment_dir <- file.path(insee_dir, "unemployment")
dir.create(unemployment_dir, showWarnings = FALSE)

## INSEE provides quarterly unemployment rates by département
## Series: "Taux de chômage localisés" via BDM/SDMX
## We download the full time series and average to annual

unemp_file <- file.path(unemployment_dir, "chomage_dept.csv")

if (!file.exists(unemp_file)) {
  cat("  Downloading unemployment rates from INSEE BDM...\n")

  ## INSEE BDM SDMX endpoint for localised unemployment
  ## Series ID pattern: 001688889 (national), then by département
  ## Alternative: direct CSV download from the web page
  unemp_url <- "https://www.insee.fr/fr/statistiques/fichier/1893230/sl_etc_2003-2024.xlsx"
  unemp_xlsx <- file.path(unemployment_dir, "chomage_dept.xlsx")

  tryCatch({
    download.file(unemp_url, unemp_xlsx, mode = "wb", quiet = FALSE, timeout = 120)
    cat("  Downloaded unemployment rates (Excel).\n")
  }, error = function(e) {
    cat("  WARNING: Unemployment download failed:", e$message, "\n")
    cat("  Will construct from known values in 02_clean_data.R.\n")
  })
} else {
  cat("  Unemployment data already exists.\n")
}

## ============================================================================
## v3 NEW: 12. INSEE RECENSEMENT — EDUCATION, IMMIGRATION, SECTOR (WS3)
## Source: INSEE RP 2013 (pre-treatment) + RP 2020 (for change)
## Level: Département
## ============================================================================

cat("\n=== v3: Downloading INSEE recensement data (WS3) ===\n")

recensement_dir <- file.path(insee_dir, "recensement")
dir.create(recensement_dir, showWarnings = FALSE)

## RP 2013: education, immigration, sector composition
## These are cross-sectional characteristics used as controls
rp2013_url <- "https://www.insee.fr/fr/statistiques/fichier/2862068/base-cc-coupl-fam-men-2013_csv.zip"
rp2013_zip <- file.path(recensement_dir, "rp2013_cc.zip")

if (!file.exists(rp2013_zip)) {
  cat("  Downloading RP 2013 cross-sectional data...\n")
  tryCatch({
    download.file(rp2013_url, rp2013_zip, mode = "wb", quiet = FALSE, timeout = 300)
    unzip(rp2013_zip, exdir = file.path(recensement_dir, "rp2013"))
    cat("  Downloaded RP 2013.\n")
  }, error = function(e) {
    cat("  WARNING: RP 2013 download failed:", e$message, "\n")
  })
} else {
  cat("  RP 2013 already exists.\n")
}

## Also get education-specific tables (diplômes)
## Base des diplômes par département
dip_url <- "https://www.insee.fr/fr/statistiques/fichier/2862201/base-cc-diplomes-form-2013_csv.zip"
dip_zip <- file.path(recensement_dir, "rp2013_diplomes.zip")

if (!file.exists(dip_zip)) {
  cat("  Downloading RP 2013 education data...\n")
  tryCatch({
    download.file(dip_url, dip_zip, mode = "wb", quiet = FALSE, timeout = 300)
    unzip(dip_zip, exdir = file.path(recensement_dir, "diplomes"))
    cat("  Downloaded education data.\n")
  }, error = function(e) {
    cat("  WARNING: Education download failed:", e$message, "\n")
  })
} else {
  cat("  Education data already exists.\n")
}

## Activité / Emploi (sector composition)
act_url <- "https://www.insee.fr/fr/statistiques/fichier/2862149/base-cc-emploi-pop-active-2013_csv.zip"
act_zip <- file.path(recensement_dir, "rp2013_emploi.zip")

if (!file.exists(act_zip)) {
  cat("  Downloading RP 2013 employment data...\n")
  tryCatch({
    download.file(act_url, act_zip, mode = "wb", quiet = FALSE, timeout = 300)
    unzip(act_zip, exdir = file.path(recensement_dir, "emploi"))
    cat("  Downloaded employment data.\n")
  }, error = function(e) {
    cat("  WARNING: Employment download failed:", e$message, "\n")
  })
} else {
  cat("  Employment data already exists.\n")
}

## ============================================================================
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("DATA FETCH COMPLETE (v3)\n")
cat(strrep("=", 60), "\n")

files_status <- tibble(
  dataset = c("SCI (NUTS3)", "Elections (Parquet)", "Fuel consumption",
              "Fuel prices", "Filosofi (income)",
              "Département boundaries", "Population",
              "Migration flows (v3)", "Unemployment (v3)",
              "Education (v3)", "Employment (v3)"),
  path = c(sci_zip, cand_file, fuel_file,
           file.path(prices_dir, "prix_2018.zip"),
           filosofi_zip,
           dept_geojson, pop_file,
           migration_file,
           unemp_file,
           dip_zip,
           act_zip),
  exists = file.exists(c(sci_zip, cand_file, fuel_file,
                         file.path(prices_dir, "prix_2018.zip"),
                         filosofi_zip,
                         dept_geojson, pop_file,
                         migration_file,
                         unemp_file,
                         dip_zip,
                         act_zip))
)

print(files_status %>% select(dataset, exists))
cat("\n")

if (all(files_status$exists)) {
  cat("All datasets downloaded successfully.\n")
} else {
  missing <- files_status %>% filter(!exists) %>% pull(dataset)
  cat("Missing datasets:", paste(missing, collapse = ", "), "\n")
  cat("Will construct from known values in 02_clean_data.R where possible.\n")
}
