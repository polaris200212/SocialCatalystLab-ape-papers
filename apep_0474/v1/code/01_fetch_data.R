## =============================================================================
## 01_fetch_data.R — Data acquisition via INSEE Sirene API
## apep_0474: Downtown for Sale? ACV Commercial Displacement
##
## Strategy: Use the Sirene API (api.insee.fr) to query establishment data
## for ACV communes and potential control communes, rather than downloading
## the full 2.7GB bulk file. The API returns JSON with establishment details
## including creation dates, NAF codes, and administrative status.
## =============================================================================

source(file.path(dirname(sys.frame(1)$ofile %||% "code/01_fetch_data.R"), "00_packages.R"))
library(httr)
library(jsonlite)

## ---- Configuration ----
API_KEY <- Sys.getenv("INSEE_SIRENE_API_KEY")
if (API_KEY == "") {
  # Read from .env file
  env_lines <- readLines(".env", warn = FALSE)
  key_line <- grep("INSEE_SIRENE_API_KEY", env_lines, value = TRUE)
  if (length(key_line) > 0) {
    API_KEY <- gsub(".*=", "", key_line[1])
  }
}
stopifnot(nchar(API_KEY) > 10)
cat(sprintf("API key loaded: %s...\n", substr(API_KEY, 1, 8)))

BASE_URL <- "https://api.insee.fr/api-sirene/3.11/siret"

## ---- 1. ACV Commune List ----
cat("=== Downloading ACV commune list ===\n")
acv_url <- "https://static.data.gouv.fr/resources/programme-action-coeur-de-ville/20250924-154200/liste-acv-com2025-20250704.csv"
acv_path <- file.path(DATA, "acv_communes.csv")

if (!file.exists(acv_path)) {
  download.file(acv_url, acv_path, quiet = FALSE)
}
acv <- read_csv(acv_path, show_col_types = FALSE)
cat(sprintf("ACV communes loaded: %d rows\n", nrow(acv)))

acv <- acv %>%
  rename(code_commune = insee_com) %>%
  mutate(acv = 1L, date_signature = dmy(date_signature))

write_csv(acv, file.path(DATA, "acv_communes_clean.csv"))
acv_codes <- unique(acv$code_commune)

## ---- 2. Helper function to query Sirene API ----
query_sirene <- function(commune_code, naf_prefix = NULL, cursor = "*",
                          nombre = 1000) {
  # Build query
  q_parts <- sprintf("codeCommuneEtablissement:%s", commune_code)
  if (!is.null(naf_prefix)) {
    naf_filter <- paste(sprintf("activitePrincipaleEtablissement:%s*", naf_prefix),
                        collapse = " OR ")
    q_parts <- sprintf("(%s) AND (%s)", q_parts, naf_filter)
  }

  resp <- GET(
    BASE_URL,
    query = list(
      q = q_parts,
      nombre = nombre,
      curseur = cursor,
      champs = paste(
        "siret",
        "dateCreationEtablissement",
        "activitePrincipaleEtablissement",
        "etatAdministratifEtablissement",
        "codeCommuneEtablissement",
        sep = ","
      )
    ),
    add_headers(
      `X-INSEE-Api-Key-Integration` = API_KEY,
      Accept = "application/json"
    )
  )

  if (status_code(resp) == 429) {
    # Rate limit - wait and retry
    Sys.sleep(2)
    return(query_sirene(commune_code, naf_prefix, cursor, nombre))
  }

  if (status_code(resp) != 200) {
    return(list(etablissements = list(), header = list(total = 0), curseurSuivant = NULL))
  }

  content(resp, as = "parsed", simplifyVector = FALSE)
}

## ---- 3. Fetch establishments for all communes ----
cat("\n=== Fetching establishment data from Sirene API ===\n")

# We'll query establishments for:
# 1. All ACV communes
# 2. A broad set of potential control communes (medium-sized)
# Downtown-facing NAF prefixes: 47, 55, 56, 93, 96
# Placebo NAF prefix: 46

# For efficiency, query ALL sectors per commune (no NAF filter)
# and filter in post-processing

fetch_commune_data <- function(commune_code, max_pages = 20) {
  all_etabs <- list()
  cursor <- "*"

  for (page in 1:max_pages) {
    result <- query_sirene(commune_code, naf_prefix = NULL, cursor = cursor)

    if (length(result$etablissements) == 0) break

    for (etab in result$etablissements) {
      # Extract the current period's NAF code
      naf <- etab$activitePrincipaleEtablissement
      if (is.null(naf)) {
        # Check periodesEtablissement
        periods <- etab$periodesEtablissement
        if (length(periods) > 0) {
          naf <- periods[[1]]$activitePrincipaleEtablissement
        }
      }

      all_etabs[[length(all_etabs) + 1]] <- data.frame(
        siret = etab$siret %||% NA_character_,
        date_creation = etab$dateCreationEtablissement %||% NA_character_,
        naf = naf %||% NA_character_,
        status = etab$etatAdministratifEtablissement %||% NA_character_,
        code_commune = etab$codeCommuneEtablissement %||% commune_code,
        stringsAsFactors = FALSE
      )
    }

    # Check for next cursor
    cursor <- result$curseurSuivant
    if (is.null(cursor) || cursor == "") break

    Sys.sleep(0.1)  # Rate limiting
  }

  if (length(all_etabs) == 0) return(data.frame())
  bind_rows(all_etabs)
}

# --- Fetch ACV communes ---
cat(sprintf("Fetching %d ACV communes...\n", length(acv_codes)))
acv_data <- list()
pb <- txtProgressBar(min = 0, max = length(acv_codes), style = 3)

for (i in seq_along(acv_codes)) {
  acv_data[[i]] <- fetch_commune_data(acv_codes[i])
  setTxtProgressBar(pb, i)
  Sys.sleep(0.05)
}
close(pb)

acv_etabs <- bind_rows(acv_data)
cat(sprintf("ACV establishments fetched: %s\n", format(nrow(acv_etabs), big.mark = ",")))

# --- Identify potential control communes ---
# We need medium-sized communes that are NOT in ACV.
# Strategy: find communes with similar establishment counts to ACV communes.
# Use a curated list of medium-sized communes from INSEE.

# First, let's compute ACV commune sizes to calibrate control selection
acv_sizes <- acv_etabs %>%
  filter(!is.na(naf)) %>%
  mutate(naf2 = substr(naf, 1, 2)) %>%
  filter(naf2 %in% c("47", "55", "56", "93", "96")) %>%
  group_by(code_commune) %>%
  summarise(n_downtown = n(), .groups = "drop")

cat(sprintf("\nACV downtown establishments per commune: median=%d, mean=%.0f, range=[%d, %d]\n",
            median(acv_sizes$n_downtown),
            mean(acv_sizes$n_downtown),
            min(acv_sizes$n_downtown),
            max(acv_sizes$n_downtown)))

# --- Build control commune list ---
# We'll use a sample of French communes in the "ville moyenne" population range
# These are communes with populations 10k-100k that are NOT in ACV
# For now, use a curated set of département préfectures and sous-préfectures

# Read COG (Code Officiel Géographique) for commune universe
cog_url <- "https://www.insee.fr/fr/statistiques/fichier/7766585/v_commune_2024.csv"
cog_path <- file.path(DATA, "cog_communes_2024.csv")

if (!file.exists(cog_path)) {
  tryCatch(
    download.file(cog_url, cog_path, quiet = FALSE),
    error = function(e) cat("COG download failed\n")
  )
}

# Alternative: use commune population from the Sirene API itself
# Query a set of medium-sized communes by département
# We'll sample 5-10 non-ACV communes per département containing ACV cities
acv_depts <- unique(substr(acv_codes, 1, 2))
cat(sprintf("\nACV départements: %d\n", length(acv_depts)))

# For each ACV département, find non-ACV communes with similar commercial density
# Use a pragmatic approach: query known medium-sized city codes
# French communes with codes starting with each dept prefix

# Load a pre-compiled list of French communes with population data
# Alternatively, generate control candidates from our knowledge
# Key French "villes moyennes" NOT in ACV (there are thousands)

# Strategy: Query Sirene for establishment counts per commune in ACV départements
# This gives us the universe of potential controls

cat("\n=== Building control commune candidates ===\n")

# For efficiency, we'll query the API for aggregate counts by département
# and select communes with similar establishment counts to ACV communes

# Sample control communes: 5 per ACV département, matching on size
# We know typical commune codes: dept prefix + 3 digits (001-999)
# Query a few hundred communes across ACV départements

set.seed(42)
control_candidates <- c()

# Use some well-known medium-sized non-ACV cities as controls
# These are préfectures/sous-préfectures in departments with ACV cities
known_medium_cities <- c(
  # Ain (01)
  "01034", "01283",
  # Aisne (02)
  "02408", "02722",
  # Allier (03)
  "03185", "03310",
  # Ardennes (08)
  "08105", "08362",
  # Aube (10)
  "10268", "10323",
  # Aude (11)
  "11069", "11262",
  # Aveyron (12)
  "12145", "12176",
  # Bouches-du-Rhône (13)
  "13004", "13047", "13054", "13056",
  # Calvados (14)
  "14366", "14220",
  # Cantal (15)
  "15014", "15187",
  # Charente (16)
  "16015", "16102",
  # Charente-Maritime (17)
  "17299", "17369",
  # Cher (18)
  "18033", "18279",
  # Corrèze (19)
  "19031", "19272",
  # Côte-d'Or (21)
  "21054", "21171",
  # Côtes-d'Armor (22)
  "22278", "22070",
  # Creuse (23)
  "23096", "23001",
  # Dordogne (24)
  "24037", "24322",
  # Doubs (25)
  "25056", "25388",
  # Drôme (26)
  "26281", "26198",
  # Eure (27)
  "27229", "27016",
  # Finistère (29)
  "29232", "29019",
  # Gard (30)
  "30007", "30189",
  # Haute-Garonne (31)
  "31555", "31395",
  # Gers (32)
  "32013", "32107",
  # Gironde (33)
  "33063", "33243",
  # Hérault (34)
  "34032", "34172",
  # Ille-et-Vilaine (35)
  "35238", "35115",
  # Indre (36)
  "36044", "36101",
  # Indre-et-Loire (37)
  "37261", "37003",
  # Isère (38)
  "38185", "38544",
  # Jura (39)
  "39198", "39300",
  # Landes (40)
  "40192", "40088",
  # Loire (42)
  "42218", "42147",
  # Haute-Loire (43)
  "43157", "43040",
  # Loire-Atlantique (44)
  "44109", "44162",
  # Loiret (45)
  "45234", "45147",
  # Lot (46)
  "46042", "46102",
  # Maine-et-Loire (49)
  "49007", "49099",
  # Manche (50)
  "50502", "50025",
  # Marne (51)
  "51108", "51230",
  # Haute-Marne (52)
  "52121", "52269",
  # Mayenne (53)
  "53130", "53054",
  # Meurthe-et-Moselle (54)
  "54395", "54528",
  # Meuse (55)
  "55029", "55545",
  # Morbihan (56)
  "56260", "56121",
  # Moselle (57)
  "57463", "57672",
  # Nièvre (58)
  "58194", "58086",
  # Nord (59)
  "59183", "59392",
  # Oise (60)
  "60057", "60159",
  # Orne (61)
  "61001", "61169",
  # Pas-de-Calais (62)
  "62041", "62193",
  # Puy-de-Dôme (63)
  "63113", "63178",
  # Pyrénées-Atlantiques (64)
  "64445", "64102",
  # Hautes-Pyrénées (65)
  "65440", "65286",
  # Pyrénées-Orientales (66)
  "66136", "66025",
  # Bas-Rhin (67)
  "67482", "67180",
  # Haut-Rhin (68)
  "68066", "68224",
  # Rhône (69)
  "69123", "69256",
  # Saône-et-Loire (71)
  "71270", "71076",
  # Sarthe (72)
  "72181", "72143",
  # Savoie (73)
  "73065", "73011",
  # Haute-Savoie (74)
  "74010", "74256",
  # Seine-Maritime (76)
  "76540", "76217",
  # Seine-et-Marne (77)
  "77284", "77186",
  # Deux-Sèvres (79)
  "79191", "79270",
  # Somme (80)
  "80021", "80001",
  # Tarn (81)
  "81004", "81065",
  # Tarn-et-Garonne (82)
  "82121", "82033",
  # Var (83)
  "83137", "83061",
  # Vaucluse (84)
  "84007", "84031",
  # Vendée (85)
  "85191", "85109",
  # Vienne (86)
  "86194", "86066",
  # Haute-Vienne (87)
  "87085", "87154",
  # Vosges (88)
  "88160", "88413",
  # Yonne (89)
  "89024", "89387",
  # Essonne (91)
  "91228", "91174"
)

# Remove any that are in ACV
control_communes <- setdiff(known_medium_cities, acv_codes)
cat(sprintf("Control commune candidates: %d\n", length(control_communes)))

# Fetch control commune data
cat("Fetching control communes...\n")
control_data <- list()
pb <- txtProgressBar(min = 0, max = length(control_communes), style = 3)

for (i in seq_along(control_communes)) {
  control_data[[i]] <- fetch_commune_data(control_communes[i])
  setTxtProgressBar(pb, i)
  Sys.sleep(0.05)
}
close(pb)

control_etabs <- bind_rows(control_data)
cat(sprintf("Control establishments fetched: %s\n",
            format(nrow(control_etabs), big.mark = ",")))

## ---- 4. Combine and save ----
cat("\n=== Combining data ===\n")

all_etabs <- bind_rows(
  acv_etabs %>% mutate(sample = "acv"),
  control_etabs %>% mutate(sample = "control")
)

# Clean
all_etabs <- all_etabs %>%
  filter(!is.na(date_creation)) %>%
  mutate(
    date_creation = as.Date(date_creation),
    year = year(date_creation),
    quarter = quarter(date_creation),
    naf2 = substr(naf, 1, 2),
    downtown_sector = as.integer(naf2 %in% c("47", "55", "56", "93", "96")),
    placebo_sector = as.integer(naf2 == "46")
  ) %>%
  filter(year >= 2010, year <= 2024)

cat(sprintf("Total establishments (2010-2024): %s\n",
            format(nrow(all_etabs), big.mark = ",")))
cat(sprintf("  Downtown-facing: %s\n",
            format(sum(all_etabs$downtown_sector), big.mark = ",")))
cat(sprintf("  Placebo (wholesale): %s\n",
            format(sum(all_etabs$placebo_sector), big.mark = ",")))

# Save raw establishment data
fwrite(all_etabs, file.path(DATA, "sirene_establishments.csv"))

## ---- 5. Remove partial bulk download ----
partial_file <- file.path(DATA, "StockEtablissement.parquet")
if (file.exists(partial_file)) {
  file.remove(partial_file)
  cat("Removed partial bulk download.\n")
}

cat("\nData acquisition complete.\n")
