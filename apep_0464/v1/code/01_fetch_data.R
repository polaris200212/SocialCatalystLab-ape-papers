## ============================================================================
## 01_fetch_data.R — Connected Backlash (apep_0464)
## Fetch all required data from public APIs and open data sources
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## 1. FACEBOOK SOCIAL CONNECTEDNESS INDEX (SCI)
## Source: Humanitarian Data Exchange (HDX)
## Level: NUTS3 (= French départements)
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

## List available SCI files
sci_files <- list.files(sci_dir, pattern = "\\.tsv$|\\.csv$", recursive = TRUE, full.names = TRUE)
cat("SCI files found:", length(sci_files), "\n")
for (f in sci_files) cat("  ", basename(f), "\n")

## ============================================================================
## 2. FRENCH ELECTION DATA (Aggregated Parquet)
## Source: data.gouv.fr — consolidated all-elections dataset
## Level: Bureau de vote (aggregable to commune/département)
## ============================================================================

cat("\n=== Downloading election data ===\n")

elections_dir <- file.path(DATA_DIR, "elections")
dir.create(elections_dir, showWarnings = FALSE)

## Candidate-level results (Parquet, 158 MB)
cand_url <- "https://object.files.data.gouv.fr/data-pipeline-open/elections/candidats_results.parquet"
cand_file <- file.path(elections_dir, "candidats_results.parquet")

if (!file.exists(cand_file)) {
  cat("Downloading candidate results (158 MB)...\n")
  download.file(cand_url, cand_file, mode = "wb", quiet = FALSE)
} else {
  cat("Candidate results already exist.\n")
}

## General results (turnout, Parquet, 68 MB)
gen_url <- "https://object.files.data.gouv.fr/data-pipeline-open/elections/general_results.parquet"
gen_file <- file.path(elections_dir, "general_results.parquet")

if (!file.exists(gen_file)) {
  cat("Downloading general results (68 MB)...\n")
  download.file(gen_url, gen_file, mode = "wb", quiet = FALSE)
} else {
  cat("General results already exist.\n")
}

## Political nuances dictionary
nuance_url <- "https://static.data.gouv.fr/resources/donnees-des-elections-agregees/20260216-092608/nuances-politiques.csv"
nuance_file <- file.path(elections_dir, "nuances-politiques.csv")

if (!file.exists(nuance_file)) {
  download.file(nuance_url, nuance_file, mode = "wb", quiet = FALSE)
}

## Quick validation
cat("\nValidating election data...\n")
cand_schema <- arrow::open_dataset(cand_file)$schema
cat("  Candidate columns:", paste(cand_schema$names, collapse = ", "), "\n")

gen_schema <- arrow::open_dataset(gen_file)$schema
cat("  General columns:", paste(gen_schema$names, collapse = ", "), "\n")

## ============================================================================
## 3. FUEL CONSUMPTION BY DÉPARTEMENT (SDES)
## Source: data.gouv.fr / SDES petroleum product sales
## Level: Département, annual
## ============================================================================

cat("\n=== Downloading fuel consumption data ===\n")

fuel_dir <- file.path(DATA_DIR, "fuel")
dir.create(fuel_dir, showWarnings = FALSE)

## The SDES fuel consumption data by département
## Try the DiDo API endpoint first
fuel_url <- "https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles/76c57f55-7af5-401c-a99b-d4b7c9b6ce67/csv?millesime=2025-01&withColumnName=true&withColumnDescription=false&withColumnUnit=false&orderBy=-ANNEE"
fuel_file <- file.path(fuel_dir, "fuel_consumption_dept.csv")

if (!file.exists(fuel_file)) {
  cat("Downloading fuel consumption by département...\n")
  tryCatch({
    download.file(fuel_url, fuel_file, mode = "wb", quiet = FALSE)
    cat("  Downloaded from SDES DiDo API.\n")
  }, error = function(e) {
    cat("  DiDo API failed, trying alternative URL...\n")
    ## Alternative: try the main catalog page CSV export
    alt_url <- "https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles/76c57f55-7af5-401c-a99b-d4b7c9b6ce67/csv?millesime=2024-06&withColumnName=true"
    tryCatch({
      download.file(alt_url, fuel_file, mode = "wb", quiet = FALSE)
    }, error = function(e2) {
      cat("  WARNING: Could not download fuel consumption data. Will construct from fuel prices.\n")
    })
  })
} else {
  cat("Fuel consumption data already exists.\n")
}

## ============================================================================
## 4. FUEL PRICES (prix-carburants.gouv.fr)
## Source: Open XML archives, station-level
## Level: Station (with postal code → département)
## ============================================================================

cat("\n=== Downloading fuel price archives ===\n")

prices_dir <- file.path(fuel_dir, "prices")
dir.create(prices_dir, showWarnings = FALSE)

## Download annual archives for key years around the carbon tax
years_needed <- 2013:2024

for (yr in years_needed) {
  yr_zip <- file.path(prices_dir, paste0("prix_", yr, ".zip"))
  if (!file.exists(yr_zip)) {
    yr_url <- paste0("https://donnees.roulez-eco.fr/opendata/annee/", yr)
    cat(glue("  Downloading {yr}..."), "\n")
    tryCatch({
      download.file(yr_url, yr_zip, mode = "wb", quiet = TRUE)
    }, error = function(e) {
      cat(glue("  WARNING: Could not download {yr}: {e$message}"), "\n")
    })
  }
}

cat("Fuel price archives downloaded.\n")

## ============================================================================
## 5. INSEE FILOSOFI (Income/Poverty by Département)
## Source: INSEE
## Level: Département, annual (2017-2021)
## ============================================================================

cat("\n=== Downloading INSEE Filosofi (income) data ===\n")

insee_dir <- file.path(DATA_DIR, "insee")
dir.create(insee_dir, showWarnings = FALSE)

## Filosofi 2021 département-level (latest)
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
## 6. INSEE COMMUTING EMISSIONS DATA
## Source: data.gouv.fr / SDES
## Level: Commune, 2019
## ============================================================================

cat("\n=== Downloading commuting emissions data ===\n")

commute_url <- "https://www.data.gouv.fr/api/1/datasets/r/452692fb-edf8-4dbd-a870-cb0e4230dc13"
commute_zip <- file.path(insee_dir, "commuting_co2_2019.zip")

if (!file.exists(commute_zip)) {
  cat("Downloading commuting CO2 emissions (262 MB)...\n")
  tryCatch({
    download.file(commute_url, commute_zip, mode = "wb", quiet = FALSE, timeout = 600)
    unzip(commute_zip, exdir = file.path(insee_dir, "commuting_2019"))
  }, error = function(e) {
    cat("  WARNING: Commuting emissions download failed:", e$message, "\n")
    cat("  This is a supplementary measure. Will use fuel consumption as primary.\n")
  })
} else {
  cat("Commuting emissions data already exists.\n")
}

## ============================================================================
## 7. FRENCH DÉPARTEMENT BOUNDARIES (Shapefile)
## Source: Natural Earth or IGN Admin Express via data.gouv.fr
## ============================================================================

cat("\n=== Downloading département boundaries ===\n")

geo_dir <- file.path(DATA_DIR, "geo")
dir.create(geo_dir, showWarnings = FALSE)

## Use IGN Admin Express contours via data.gouv.fr
## Simplified departement boundaries
dept_geojson_url <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements-version-simplifiee.geojson"
dept_geojson <- file.path(geo_dir, "departements.geojson")

if (!file.exists(dept_geojson)) {
  cat("Downloading département boundaries...\n")
  tryCatch({
    download.file(dept_geojson_url, dept_geojson, mode = "wb", quiet = FALSE)
  }, error = function(e) {
    cat("  WARNING: GeoJSON download failed. Will use rnaturalearth fallback.\n")
  })
} else {
  cat("Département boundaries already exist.\n")
}

## ============================================================================
## 8. NUTS3 → DÉPARTEMENT MAPPING TABLE
## ============================================================================

cat("\n=== Creating NUTS3 ↔ département mapping ===\n")

## Official mapping: NUTS3 codes for French départements
## Source: Eurostat GISCO NUTS 2024 classification (verified Feb 2026)
## NOTE: NUTS 2024 substantially reorganized French NUTS2/NUTS3 codes
##   vs. NUTS 2021. Many sub-regions swapped numbering within NUTS1.

nuts3_dept <- tribble(
  ~nuts3, ~dept_code, ~dept_name,
  ## FR1 - Île-de-France
  "FR101", "75", "Paris",
  "FR102", "77", "Seine-et-Marne",
  "FR103", "78", "Yvelines",
  "FR104", "91", "Essonne",
  "FR105", "92", "Hauts-de-Seine",
  "FR106", "93", "Seine-Saint-Denis",
  "FR107", "94", "Val-de-Marne",
  "FR108", "95", "Val-d'Oise",
  ## FRB - Centre-Val de Loire
  "FRB01", "18", "Cher",
  "FRB02", "28", "Eure-et-Loir",
  "FRB03", "36", "Indre",
  "FRB04", "37", "Indre-et-Loire",
  "FRB05", "41", "Loir-et-Cher",
  "FRB06", "45", "Loiret",
  ## FRC - Bourgogne-Franche-Comté
  "FRC11", "21", "Côte-d'Or",
  "FRC12", "58", "Nièvre",
  "FRC13", "71", "Saône-et-Loire",
  "FRC14", "89", "Yonne",
  "FRC21", "25", "Doubs",
  "FRC22", "39", "Jura",
  "FRC23", "70", "Haute-Saône",
  "FRC24", "90", "Territoire de Belfort",
  ## FRD - Normandie
  "FRD11", "14", "Calvados",
  "FRD12", "50", "Manche",
  "FRD13", "61", "Orne",
  "FRD21", "27", "Eure",
  "FRD22", "76", "Seine-Maritime",
  ## FRE - Hauts-de-France
  "FRE11", "59", "Nord",
  "FRE12", "62", "Pas-de-Calais",
  "FRE21", "02", "Aisne",
  "FRE22", "60", "Oise",
  "FRE23", "80", "Somme",
  ## FRF - Grand Est (FRF1=Alsace, FRF2=Champagne-Ardenne, FRF3=Lorraine)
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
  ## FRG - Pays de la Loire
  "FRG01", "44", "Loire-Atlantique",
  "FRG02", "49", "Maine-et-Loire",
  "FRG03", "53", "Mayenne",
  "FRG04", "72", "Sarthe",
  "FRG05", "85", "Vendée",
  ## FRH - Bretagne
  "FRH01", "22", "Côtes-d'Armor",
  "FRH02", "29", "Finistère",
  "FRH03", "35", "Ille-et-Vilaine",
  "FRH04", "56", "Morbihan",
  ## FRI - Nouvelle-Aquitaine (FRI1=Aquitaine, FRI2=Limousin, FRI3=Poitou-Charentes)
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
  ## FRJ - Occitanie (FRJ1=Languedoc-Roussillon, FRJ2=Midi-Pyrénées)
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
  ## FRK - Auvergne-Rhône-Alpes (FRK1=Auvergne, FRK2=Rhône-Alpes)
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
  ## FRL - Provence-Alpes-Côte d'Azur
  "FRL01", "04", "Alpes-de-Haute-Provence",
  "FRL02", "05", "Hautes-Alpes",
  "FRL03", "06", "Alpes-Maritimes",
  "FRL04", "13", "Bouches-du-Rhône",
  "FRL05", "83", "Var",
  "FRL06", "84", "Vaucluse",
  ## FRM - Corse
  "FRM01", "2A", "Corse-du-Sud",
  "FRM02", "2B", "Haute-Corse"
)

## Save mapping
write_csv(nuts3_dept, file.path(DATA_DIR, "nuts3_dept_mapping.csv"))
cat("  Created mapping with", nrow(nuts3_dept), "départements.\n")

## ============================================================================
## 9. CARBON TAX RATE SCHEDULE
## ============================================================================

cat("\n=== Creating carbon tax rate schedule ===\n")

carbon_tax <- tribble(
  ~year, ~rate_eur_tco2, ~ticpe_diesel_cl, ~ticpe_sp95_cl,
  2013,  0.00, 42.84, 60.69,
  2014,  7.00, 42.84, 60.69,
  2015, 14.50, 46.82, 62.41,
  2016, 22.00, 49.81, 64.12,
  2017, 30.50, 53.07, 65.07,
  2018, 44.60, 59.40, 68.29,
  2019, 44.60, 59.40, 68.29,  # Frozen after GJ

  2020, 44.60, 59.40, 68.29,
  2021, 44.60, 59.40, 68.29,
  2022, 44.60, 59.40, 68.29,
  2023, 44.60, 59.40, 68.29,
  2024, 44.60, 59.40, 68.29
)

## Carbon component per liter (diesel = 2.651 kg CO2/L, SP95 = 2.287 kg CO2/L)
carbon_tax <- carbon_tax %>%
  mutate(
    carbon_diesel_cl = rate_eur_tco2 * 2.651 / 1000 * 100,  # €/tCO2 → c/L
    carbon_sp95_cl = rate_eur_tco2 * 2.287 / 1000 * 100
  )

write_csv(carbon_tax, file.path(DATA_DIR, "carbon_tax_schedule.csv"))
cat("  Carbon tax schedule saved (2013-2024).\n")

## ============================================================================
## 10. INSEE POPULATION BY DÉPARTEMENT
## Source: INSEE annual population estimates
## ============================================================================

cat("\n=== Downloading population estimates ===\n")

## Population by département (2012-2024)
pop_url <- "https://www.insee.fr/fr/statistiques/fichier/1893198/estim-pop-dep-sexe-gca-1975-2024.xls"
pop_file <- file.path(insee_dir, "population_dept.xls")

if (!file.exists(pop_file)) {
  cat("Downloading département population...\n")
  tryCatch({
    download.file(pop_url, pop_file, mode = "wb", quiet = FALSE)
  }, error = function(e) {
    cat("  WARNING: Population download failed:", e$message, "\n")
  })
} else {
  cat("Population data already exists.\n")
}

## ============================================================================
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("DATA FETCH COMPLETE\n")
cat(strrep("=", 60), "\n")

## Check what we got
files_status <- tibble(
  dataset = c("SCI (NUTS3)", "Elections (Parquet)", "Fuel consumption",
              "Fuel prices", "Filosofi (income)", "Commuting CO2",
              "Département boundaries", "Population"),
  path = c(sci_zip, cand_file, fuel_file,
           file.path(prices_dir, "prix_2018.zip"),
           filosofi_zip, commute_zip,
           dept_geojson, pop_file),
  exists = file.exists(c(sci_zip, cand_file, fuel_file,
                         file.path(prices_dir, "prix_2018.zip"),
                         filosofi_zip, commute_zip,
                         dept_geojson, pop_file))
)

print(files_status %>% select(dataset, exists))
cat("\n")

if (all(files_status$exists)) {
  cat("All critical datasets downloaded successfully.\n")
} else {
  missing <- files_status %>% filter(!exists) %>% pull(dataset)
  cat("WARNING: Missing datasets:", paste(missing, collapse = ", "), "\n")
  cat("Some analyses may need to be adapted.\n")
}
