## ============================================================
## 01_fetch_data.R — Fetch DVF, TLV designation, and controls
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## -------------------------------------------------------
## 1. TLV Commune Lists
## -------------------------------------------------------
## The TLV designation is defined by decrees. We construct
## the treatment variable from the official commune lists.
## Source: Service-Public.fr / Légifrance / data.gouv.fr

cat("=== Fetching TLV commune lists ===\n")

## The 2023 expansion (Décret n° 2023-822) commune list
## Available from: https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000047984658
## We use the consolidated "zones tendues" list from Service-Public

## Method: Fetch the official list of communes in zones tendues
## The ANIL (Agence Nationale pour l'Information sur le Logement) maintains
## a reference file of communes in zones tendues

## Try the ANIL simulateur data which has zone tendue classifications
tlv_url <- "https://www.data.gouv.fr/fr/datasets/r/d573456c-76eb-4276-8d29-8bbc0a08804d"
tryCatch({
  temp_file <- file.path(data_dir, "zones_tendues_raw.csv")
  download.file(tlv_url, temp_file, mode = "wb", quiet = TRUE)
  cat("  Downloaded zones tendues list from data.gouv.fr\n")
}, error = function(e) {
  cat("  Note: Direct download failed, will construct from alternative source\n")
})

## Alternative: Construct from the decree text
## The decree lists communes by département. We use the known criteria:
## - Pre-2023 communes: in original zones tendues list (Article 232 CGI)
## - 2023 expansion: Décret 2023-822, adding communes with high tourism pressure

## For reproducibility, we construct the treatment variable from
## the Taxe d'habitation sur les logements vacants (THLV) vs TLV distinction:
## TLV communes are in "zones tendues"; non-TLV communes may have THLV (optional)

## Fetch the exhaustive commune list with zone classification
## Using the DGALN (Direction Générale de l'Aménagement) reference

## Construct treatment from the official government simulator API
cat("  Constructing TLV treatment from decree criteria...\n")

## The government provides a zone tendue simulator at:
## https://www.service-public.fr/simulateur/calcul/zones-tendues

## For reproducibility, we download the reference file
## maintained by the Ministry of Housing
ref_url <- "https://www.data.gouv.fr/fr/datasets/r/f84dc2f7-0189-4741-9988-e73ae14799da"
tryCatch({
  temp_ref <- file.path(data_dir, "ref_communes.csv")
  download.file(ref_url, temp_ref, mode = "wb", quiet = TRUE)
  cat("  Downloaded commune reference file\n")
}, error = function(e) {
  cat("  Reference file download failed\n")
})

## Since the exact commune list may not be available as a clean CSV,
## we construct treatment from the decree text using the Code INSEE list.
## The 2023 expansion targets communes meeting ANY of these criteria:
## (a) communes in "zones tendues" per Décret 2013-392 (original list)
## (b) communes added by Décret 2023-822 (expansion)
##
## Approach: Use the COG (Code Officiel Géographique) and cross-reference
## with the list published in the Journal Officiel.

## For now, let's fetch the base list using the data.gouv.fr API
library(httr)
library(jsonlite)

## Get the zones tendues dataset
cat("  Searching data.gouv.fr for zones tendues dataset...\n")
zt_search <- GET("https://www.data.gouv.fr/api/1/datasets/",
                  query = list(q = "taxe logements vacants zones tendues communes",
                               page_size = 5))
zt_results <- content(zt_search, as = "parsed")

## Print available datasets
for (ds in zt_results$data) {
  cat(sprintf("  Dataset: %s [%s]\n", ds$title, ds$id))
}

## -------------------------------------------------------
## 1b. Construct TLV commune list from direct sources
## -------------------------------------------------------

## The most reliable source is the ANIL's commune-level classification.
## Let's check if the API des communes provides zone tendue info
cat("\n  Trying API Geo for commune data...\n")

## We'll build the treatment variable from known administrative data.
## The key insight: the 2023 expansion added ~2,263 communes.
## These are primarily coastal tourism communes.

## Fetch all French communes with basic info
communes_url <- "https://geo.api.gouv.fr/communes?fields=nom,code,codesPostaux,codeDepartement,codeRegion,population&limit=50000"
communes_resp <- GET(communes_url)
communes_raw <- content(communes_resp, as = "text", encoding = "UTF-8")
communes_df <- fromJSON(communes_raw, flatten = TRUE) %>%
  as_tibble() %>%
  rename(code_commune = code,
         dep = codeDepartement,
         region = codeRegion,
         pop = population) %>%
  select(code_commune, nom, dep, region, pop)

cat(sprintf("  Fetched %d communes from API Geo\n", nrow(communes_df)))

## -------------------------------------------------------
## 1c. TLV Treatment Assignment
## -------------------------------------------------------

## We use two approaches to identify treated communes:
## (A) Cross-reference with the known zone tendue decree lists
## (B) Use housing tension indicators to reconstruct designation

## The government published the definitive list in:
## Annexe to Décret 2023-822 (Journal Officiel, 26 August 2023)
## Previous: Annexe to Décret 2013-392

## For this paper, we use the SimulateurZonesTendues file
## which the DGALN maintains and updates after each decree.

## Download the definitive list (maintained by ANIL)
cat("  Downloading definitive zones tendues commune list...\n")

## The ANIL list is at this stable URL (CSV with code_commune and zone info)
## Try multiple known URLs for the zones tendues reference
urls_to_try <- c(
  "https://www.data.gouv.fr/fr/datasets/r/520de6f4-9048-4bda-b1e3-6b60b70c8db7",
  "https://www.ecologie.gouv.fr/sites/default/files/Liste_communes_classees_zone_tendue.csv"
)

zt_downloaded <- FALSE
for (u in urls_to_try) {
  tryCatch({
    temp <- file.path(data_dir, "zones_tendues_list.csv")
    download.file(u, temp, mode = "wb", quiet = TRUE)
    zt_downloaded <- TRUE
    cat(sprintf("  Downloaded from: %s\n", substr(u, 1, 60)))
    break
  }, error = function(e) {
    cat(sprintf("  Failed: %s\n", substr(u, 1, 60)))
  })
}

## If direct download fails, construct from known criteria
if (!zt_downloaded) {
  cat("  Direct list not available. Using INSEE housing data to proxy.\n")
  cat("  Will use Légifrance API to extract decree commune lists.\n")
}

## -------------------------------------------------------
## 1d. Construct Treatment from Census Housing Data
## -------------------------------------------------------

## INSEE publishes commune-level housing data including:
## - Number of residences principales, secondaires, logements vacants
## Source: Recensement de la population, fichier logements

cat("\n=== Fetching INSEE housing data ===\n")

## INSEE SDMX API for housing stock data
## Series: LOGEMENT by commune
## The RP (recensement) data is available at commune level

## Alternative: Download the pre-built commune-level housing file
## from INSEE's open data portal
housing_url <- "https://www.insee.fr/fr/statistiques/fichier/6543200/base-cc-logement-2020.csv"
housing_file <- file.path(data_dir, "logements_2020.csv")

tryCatch({
  download.file(housing_url, housing_file, mode = "wb", quiet = TRUE)
  cat("  Downloaded INSEE housing data (2020)\n")
}, error = function(e) {
  ## Try alternative URL pattern
  alt_url <- "https://www.insee.fr/fr/statistiques/fichier/6543200/base-cc-logement-2020.CSV"
  tryCatch({
    download.file(alt_url, housing_file, mode = "wb", quiet = TRUE)
    cat("  Downloaded INSEE housing data (alternative URL)\n")
  }, error = function(e2) {
    cat("  INSEE housing data download failed\n")
  })
})

## -------------------------------------------------------
## 2. DVF Data (Property Transactions)
## -------------------------------------------------------

cat("\n=== Fetching DVF data ===\n")

## Download geo-DVF bulk files for each year (2020-2025)
dvf_years <- 2020:2024
dvf_base <- "https://files.data.gouv.fr/geo-dvf/latest/csv"

for (yr in dvf_years) {
  dvf_file <- file.path(data_dir, sprintf("dvf_%d.csv.gz", yr))
  if (file.exists(dvf_file)) {
    cat(sprintf("  DVF %d already downloaded\n", yr))
    next
  }

  dvf_url <- sprintf("%s/%d/full.csv.gz", dvf_base, yr)
  cat(sprintf("  Downloading DVF %d...\n", yr))
  tryCatch({
    download.file(dvf_url, dvf_file, mode = "wb", quiet = FALSE)
    cat(sprintf("  DVF %d: %.1f MB\n", yr, file.size(dvf_file) / 1e6))
  }, error = function(e) {
    cat(sprintf("  DVF %d download failed: %s\n", yr, e$message))
  })
}

## Also try 2025 if available
dvf_2025_file <- file.path(data_dir, "dvf_2025.csv.gz")
if (!file.exists(dvf_2025_file)) {
  tryCatch({
    download.file(sprintf("%s/2025/full.csv.gz", dvf_base),
                  dvf_2025_file, mode = "wb", quiet = TRUE)
    cat("  DVF 2025 downloaded\n")
  }, error = function(e) {
    cat("  DVF 2025 not yet available\n")
  })
}

## -------------------------------------------------------
## 3. Alternative DVF Source (DGFiP raw files for wider coverage)
## -------------------------------------------------------

## The DGFiP raw files may have different year coverage
## Check and download the raw text files
cat("\n=== Checking DGFiP raw DVF files ===\n")

dgfip_base <- "https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres"

## Known file URLs (from API search)
raw_dvf_urls <- list(
  "2020" = paste0(dgfip_base, "/20251018-234831/valeursfoncieres-2020-s2.txt.zip"),
  "2021" = paste0(dgfip_base, "/20251018-234836/valeursfoncieres-2021.txt.zip"),
  "2022" = paste0(dgfip_base, "/20251018-234844/valeursfoncieres-2022.txt.zip"),
  "2023" = paste0(dgfip_base, "/20251018-234851/valeursfoncieres-2023.txt.zip"),
  "2024" = paste0(dgfip_base, "/20251018-234857/valeursfoncieres-2024.txt.zip")
)

for (yr in names(raw_dvf_urls)) {
  raw_file <- file.path(data_dir, sprintf("dvf_raw_%s.zip", yr))
  if (file.exists(raw_file)) {
    cat(sprintf("  Raw DVF %s already downloaded\n", yr))
    next
  }
  cat(sprintf("  Downloading raw DVF %s...\n", yr))
  tryCatch({
    download.file(raw_dvf_urls[[yr]], raw_file, mode = "wb", quiet = TRUE)
    cat(sprintf("  Raw DVF %s: %.1f MB\n", yr, file.size(raw_file) / 1e6))
  }, error = function(e) {
    cat(sprintf("  Raw DVF %s failed: %s\n", yr, e$message))
  })
}

## -------------------------------------------------------
## 4. INSEE BDM Controls (Departement-level)
## -------------------------------------------------------

cat("\n=== Fetching INSEE BDM controls ===\n")

## Unemployment rate by département (for controls)
## INSEE SDMX endpoint
insee_sdmx_base <- "https://api.insee.fr/melodi/data"

## Population data from API Geo (already fetched above)
## Save communes data
saveRDS(communes_df, file.path(data_dir, "communes.rds"))
cat("  Saved communes data\n")

## -------------------------------------------------------
## 5. Save download manifest
## -------------------------------------------------------

manifest <- data.frame(
  source = c("DVF", "INSEE Housing", "Communes", "TLV List"),
  files = c(
    paste(sprintf("dvf_%d.csv.gz", dvf_years), collapse = ", "),
    "logements_2020.csv",
    "communes.rds",
    "zones_tendues_list.csv"
  ),
  status = c(
    ifelse(all(file.exists(file.path(data_dir, sprintf("dvf_%d.csv.gz", dvf_years)))),
           "complete", "partial"),
    ifelse(file.exists(housing_file), "complete", "missing"),
    "complete",
    ifelse(zt_downloaded, "complete", "needs_construction")
  ),
  stringsAsFactors = FALSE
)

cat("\n=== Download Manifest ===\n")
print(manifest)

saveRDS(manifest, file.path(data_dir, "download_manifest.rds"))

cat("\nData fetching complete.\n")
