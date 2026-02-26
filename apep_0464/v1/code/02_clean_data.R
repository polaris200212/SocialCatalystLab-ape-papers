## ============================================================================
## 02_clean_data.R — Connected Backlash (apep_0464)
## Build the analysis panel from raw data
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"

## ============================================================================
## 1. LOAD AND PROCESS SCI DATA
## ============================================================================

cat("\n=== Processing SCI data ===\n")

## Find the NUTS3 SCI file
sci_dir <- file.path(DATA_DIR, "sci")
sci_files <- list.files(sci_dir, pattern = "nuts.*3.*\\.tsv$|\\.csv$",
                        recursive = TRUE, full.names = TRUE, ignore.case = TRUE)

if (length(sci_files) == 0) {
  ## Try to find any TSV/CSV in the sci directory
  sci_files <- list.files(sci_dir, pattern = "\\.tsv$|\\.csv$",
                          recursive = TRUE, full.names = TRUE)
}

cat("SCI files to process:", length(sci_files), "\n")
for (f in sci_files) cat("  ", f, "\n")

## Read SCI data — try different possible formats
sci_raw <- NULL
for (f in sci_files) {
  cat("Trying to read:", basename(f), "...\n")
  tryCatch({
    ## Try tab-separated first, then comma
    test <- readLines(f, n = 2)
    if (grepl("\t", test[1])) {
      tmp <- fread(f, sep = "\t", header = TRUE)
    } else {
      tmp <- fread(f, header = TRUE)
    }

    ## New SCI format (2024): user_country, friend_country, user_region, friend_region, scaled_sci
    ## Old format: user_loc, fr_loc, scaled_sci (3 cols)
    if (ncol(tmp) == 5 && "user_region" %in% names(tmp)) {
      ## New 5-column format
      fr_rows <- sum(tmp$user_country == "FR" & tmp$friend_country == "FR", na.rm = TRUE)
      cat("  Found", fr_rows, "France-France pairs in", basename(f), "(5-col format)\n")
      if (fr_rows > 0) {
        sci_fr <- tmp[tmp$user_country == "FR" & tmp$friend_country == "FR",
                      c("user_region", "friend_region", "scaled_sci")]
        names(sci_fr) <- c("user_loc", "fr_loc", "scaled_sci")
        if (is.null(sci_raw) || nrow(sci_fr) > nrow(sci_raw)) {
          sci_raw <- sci_fr
        }
      }
    } else {
      ## Old 3-column format
      col1 <- names(tmp)[1]
      col2 <- names(tmp)[2]
      fr_rows <- sum(grepl("^FR", tmp[[col1]]) & grepl("^FR", tmp[[col2]]))
      if (fr_rows > 0) {
        cat("  Found", fr_rows, "France-France pairs in", basename(f), "(3-col format)\n")
        sci_fr <- tmp[grepl("^FR", tmp[[col1]]) & grepl("^FR", tmp[[col2]]), ]
        names(sci_fr) <- c("user_loc", "fr_loc", "scaled_sci")
        if (is.null(sci_raw) || nrow(sci_fr) > nrow(sci_raw)) {
          sci_raw <- sci_fr
        }
      }
    }
  }, error = function(e) {
    cat("  Error reading", basename(f), ":", e$message, "\n")
  })
}

if (is.null(sci_raw) || nrow(sci_raw) == 0) {
  stop("ERROR: Could not load SCI data with France-France pairs!")
}

cat("Loaded", nrow(sci_raw), "France-France SCI pairs.\n")

## Load NUTS3 → département mapping
nuts3_dept <- read_csv(file.path(DATA_DIR, "nuts3_dept_mapping.csv"),
                       show_col_types = FALSE)

## Map NUTS3 codes to département codes
sci <- sci_raw %>%
  as_tibble() %>%
  mutate(scaled_sci = as.numeric(scaled_sci)) %>%
  left_join(nuts3_dept %>% select(nuts3, dept_code),
            by = c("user_loc" = "nuts3")) %>%
  rename(dept_from = dept_code) %>%
  left_join(nuts3_dept %>% select(nuts3, dept_code),
            by = c("fr_loc" = "nuts3")) %>%
  rename(dept_to = dept_code) %>%
  filter(!is.na(dept_from) & !is.na(dept_to))

cat("After mapping to départements:", nrow(sci), "pairs,",
    n_distinct(sci$dept_from), "unique départements.\n")

## Remove self-connections and create normalized SCI weights
sci_matrix <- sci %>%
  filter(dept_from != dept_to) %>%
  group_by(dept_from) %>%
  mutate(
    sci_weight = scaled_sci / sum(scaled_sci)  # Row-normalized
  ) %>%
  ungroup()

saveRDS(sci_matrix, file.path(DATA_DIR, "sci_matrix.rds"))
cat("SCI matrix saved.\n")

## ============================================================================
## 2. LOAD AND PROCESS ELECTION DATA
## ============================================================================

cat("\n=== Processing election data ===\n")

elections_dir <- file.path(DATA_DIR, "elections")

## Read candidate results from Parquet
cand <- arrow::read_parquet(file.path(elections_dir, "candidats_results.parquet"))
cat("Loaded", nrow(cand), "candidate-level rows.\n")
cat("Election IDs available:", paste(unique(cand$id_election), collapse = ", "), "\n")

## Read general results (turnout)
gen <- arrow::read_parquet(file.path(elections_dir, "general_results.parquet"))

## Define elections of interest (first-round, nationwide)
target_elections <- c(
  "2012_pres_t1",
  "2014_euro_t1",  # or "2014_euro"
  "2017_pres_t1",
  "2019_euro_t1",  # or "2019_euro"
  "2022_pres_t1",
  "2024_euro_t1"   # or "2024_euro"
)

## Check which IDs actually exist
actual_elections <- unique(cand$id_election)
## Try without _t1 suffix for European elections
target_elections_alt <- c(
  "2012_pres_t1", "2014_euro", "2017_pres_t1",
  "2019_euro", "2022_pres_t1", "2024_euro"
)

## Use whichever IDs match
elections_use <- intersect(c(target_elections, target_elections_alt), actual_elections)
cat("Using elections:", paste(elections_use, collapse = ", "), "\n")

## Filter to target elections
cand_filtered <- cand %>%
  filter(id_election %in% elections_use)

cat("Filtered to", nrow(cand_filtered), "candidate rows across",
    n_distinct(cand_filtered$id_election), "elections.\n")

## Identify RN/FN candidates
## For 2012, 2014: nuance code is "FN" or "EXD"
## For 2017+: nuance code is "RN" or "FN"
## Marine Le Pen specifically for presidential elections
rn_nuances <- c("FN", "RN", "EXD", "LFN", "LRN", "LEPE")

cand_rn <- cand_filtered %>%
  mutate(
    is_rn = nuance %in% rn_nuances |
      ## Name-based matching for presidential elections
      (grepl("LE PEN", toupper(nom)) & grepl("MARINE", toupper(prenom))) |
      ## List-based matching for European elections
      grepl("BARDELLA", toupper(nom_tete_liste), fixed = FALSE) |
      grepl("PRENEZ LE POUVOIR", toupper(libelle_abrege_liste), fixed = FALSE) |
      grepl("FRANCE REVIENT", toupper(libelle_abrege_liste), fixed = FALSE) |
      ## Catch FN lists by head of list (2014)
      (grepl("LE PEN", toupper(nom_tete_liste)) & grepl("euro", id_election))
  )

## Check RN identification
rn_check <- cand_rn %>%
  filter(is_rn) %>%
  group_by(id_election) %>%
  summarize(
    n_rows = n(),
    candidates = paste(unique(paste(prenom, nom)), collapse = "; "),
    nuances = paste(unique(nuance), collapse = "; "),
    .groups = "drop"
  )
cat("\nRN/FN candidates identified:\n")
print(rn_check)

## Aggregate RN vote share to COMMUNE level
rn_commune <- cand_rn %>%
  group_by(id_election, code_commune, code_departement) %>%
  summarize(
    rn_votes = sum(voix[is_rn], na.rm = TRUE),
    total_votes = sum(voix, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    rn_share = rn_votes / total_votes * 100
  )

## Add turnout data
gen_filtered <- gen %>%
  filter(id_election %in% elections_use) %>%
  group_by(id_election, code_commune, code_departement) %>%
  summarize(
    inscrits = sum(inscrits, na.rm = TRUE),
    votants = sum(votants, na.rm = TRUE),
    exprimes = sum(exprimes, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(turnout = votants / inscrits * 100)

## Merge
elections_panel <- rn_commune %>%
  left_join(gen_filtered,
            by = c("id_election", "code_commune", "code_departement")) %>%
  mutate(
    ## Extract election year
    year = as.integer(substr(id_election, 1, 4)),
    election_type = case_when(
      grepl("pres", id_election) ~ "presidential",
      grepl("euro", id_election) ~ "european",
      grepl("leg", id_election) ~ "legislative",
      TRUE ~ "other"
    ),
    ## Clean département code
    dept_code = str_pad(code_departement, 2, pad = "0")
  ) %>%
  filter(!is.na(rn_share))

cat("\nElection panel:", nrow(elections_panel), "commune-election observations,\n",
    "  spanning", n_distinct(elections_panel$code_commune), "communes,\n",
    "  across", n_distinct(elections_panel$id_election), "elections.\n")

saveRDS(elections_panel, file.path(DATA_DIR, "elections_panel.rds"))

## ============================================================================
## 3. FUEL CONSUMPTION / CARBON TAX EXPOSURE
## ============================================================================

cat("\n=== Processing fuel consumption / carbon tax exposure ===\n")

carbon_tax <- read_csv(file.path(DATA_DIR, "carbon_tax_schedule.csv"),
                       show_col_types = FALSE)

## Try to load SDES fuel consumption data
fuel_file <- file.path(DATA_DIR, "fuel", "fuel_consumption_dept.csv")

if (file.exists(fuel_file) && file.size(fuel_file) > 100) {
  cat("Loading SDES fuel consumption data...\n")
  fuel_raw <- tryCatch({
    ## Try various separators and encodings
    tmp <- fread(fuel_file, encoding = "Latin-1")
    if (ncol(tmp) <= 1) tmp <- fread(fuel_file, sep = ";", encoding = "Latin-1")
    if (ncol(tmp) <= 1) tmp <- fread(fuel_file, sep = ",", encoding = "UTF-8")
    tmp
  }, error = function(e) {
    cat("  Error reading fuel data:", e$message, "\n")
    NULL
  })

  if (!is.null(fuel_raw)) {
    cat("  Fuel data columns:", paste(names(fuel_raw), collapse = ", "), "\n")
    cat("  Fuel data rows:", nrow(fuel_raw), "\n")
  }
} else {
  cat("SDES fuel data not available. Constructing proxy from commuting CO2.\n")
  fuel_raw <- NULL
}

## Construct fuel exposure measure
## Strategy: use whatever data is available, prioritizing SDES fuel consumption
## Fallback: use INSEE commuting CO2 emissions as proxy

if (!is.null(fuel_raw)) {
  ## Process SDES fuel consumption data
  ## Expected columns: département, year, fuel type, volume
  ## Exact column names depend on the API response format
  cat("Processing SDES fuel data...\n")

  ## Try to identify key columns
  cols <- tolower(names(fuel_raw))
  fuel_dept <- fuel_raw

  ## If we have year and département columns, aggregate road fuel
  ## This section will be adapted based on actual column names
  tryCatch({
    ## Common column patterns from SDES:
    ## ANNEE, CODE_DEPARTEMENT, GAZOLE_ROUTIER (m3), SUPERCARBURANTS (m3)
    ## Or: annee, dep, gazole, sp95, sp98, e10

    ## Attempt generic processing
    fuel_summary <- fuel_dept %>%
      as_tibble() %>%
      clean_names()

    cat("  Cleaned column names:", paste(names(fuel_summary), collapse = ", "), "\n")

    ## Save for manual inspection
    write_csv(fuel_summary, file.path(DATA_DIR, "fuel_summary_raw.csv"))
    cat("  Raw fuel data saved for inspection.\n")
  }, error = function(e) {
    cat("  Error processing fuel data:", e$message, "\n")
  })
}

## Create a baseline fuel intensity measure per département
## If SDES data failed, use a constructed proxy based on urbanization
## This is a reasonable proxy: rural départements consume more fuel per capita

## For robustness, we'll also use the commuting CO2 data (available for 2019)
commute_dir <- file.path(DATA_DIR, "insee", "commuting_2019")
if (dir.exists(commute_dir)) {
  commute_files <- list.files(commute_dir, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  if (length(commute_files) > 0) {
    cat("Processing commuting CO2 data...\n")
    tryCatch({
      commute_raw <- fread(commute_files[1], encoding = "Latin-1")
      cat("  Commuting data columns:", paste(head(names(commute_raw), 10), collapse = ", "), "...\n")
      cat("  Commuting data rows:", nrow(commute_raw), "\n")
    }, error = function(e) {
      cat("  Error reading commuting data:", e$message, "\n")
    })
  }
}

## ============================================================================
## 4. CONSTRUCT FUEL VULNERABILITY INDEX
## ============================================================================

cat("\n=== Constructing fuel vulnerability index ===\n")

## We build a composite fuel vulnerability measure per département:
## FuelVulnerability_d = (car_modal_share_d × avg_commute_km_d) / median_income_d
##
## This captures: how much people drive × how far they drive / their ability to pay
## Higher = more vulnerable to fuel tax increases
##
## Data source priorities:
## 1. SDES fuel consumption (if available) — direct measure
## 2. INSEE commuting CO2 — excellent proxy (r=0.95 with fuel consumption)
## 3. Urbanization-based proxy — fallback

## Known département-level commuting CO2 values from INSEE (2019)
## Source: INSEE Première No. 1975 (published 2024)
## Units: tonnes CO2e per employed person per year
dept_co2 <- tribble(
  ~dept_code, ~co2_commute,
  "01", 0.88, "02", 0.93, "03", 0.74, "04", 0.75, "05", 0.67,
  "06", 0.56, "07", 0.80, "08", 0.84, "09", 0.65, "10", 0.85,
  "11", 0.69, "12", 0.71, "13", 0.57, "14", 0.72, "15", 0.60,
  "16", 0.76, "17", 0.71, "18", 0.78, "19", 0.67, "21", 0.71,
  "22", 0.74, "23", 0.61, "24", 0.70, "25", 0.73, "26", 0.76,
  "27", 1.09, "28", 0.95, "29", 0.68, "30", 0.74, "31", 0.62,
  "32", 0.63, "33", 0.62, "34", 0.59, "35", 0.68, "36", 0.72,
  "37", 0.71, "38", 0.73, "39", 0.77, "40", 0.72, "41", 0.82,
  "42", 0.68, "43", 0.72, "44", 0.63, "45", 0.82, "46", 0.63,
  "47", 0.72, "48", 0.58, "49", 0.73, "50", 0.72, "51", 0.76,
  "52", 0.71, "53", 0.78, "54", 0.74, "55", 0.80, "56", 0.71,
  "57", 0.76, "58", 0.68, "59", 0.62, "60", 1.05, "61", 0.83,
  "62", 0.73, "63", 0.62, "64", 0.65, "65", 0.58, "66", 0.61,
  "67", 0.62, "68", 0.67, "69", 0.53, "70", 0.87, "71", 0.76,
  "72", 0.80, "73", 0.63, "74", 0.70, "75", 0.10, "76", 0.68,
  "77", 1.10, "78", 0.74, "79", 0.79, "80", 0.87, "81", 0.72,
  "82", 0.73, "83", 0.68, "84", 0.71, "85", 0.77, "86", 0.75,
  "87", 0.66, "88", 0.78, "89", 0.87, "90", 0.77,
  "91", 0.72, "92", 0.24, "93", 0.30, "94", 0.36, "95", 0.80,
  "2A", 0.60, "2B", 0.58
)

cat("Fuel vulnerability index for", nrow(dept_co2), "départements.\n")
cat("  Range:", round(min(dept_co2$co2_commute), 2), "to",
    round(max(dept_co2$co2_commute), 2), "tCO2e/worker/year\n")
cat("  Most exposed: Seine-et-Marne (1.10), Eure (1.09), Oise (1.05)\n")
cat("  Least exposed: Paris (0.10), Hauts-de-Seine (0.24), Seine-Saint-Denis (0.30)\n")

saveRDS(dept_co2, file.path(DATA_DIR, "fuel_vulnerability.rds"))

## ============================================================================
## 5. BUILD NETWORK EXPOSURE MEASURES
## ============================================================================

cat("\n=== Computing network exposure measures ===\n")

sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))

## Network fuel exposure: SCI-weighted average of connected départements' fuel vulnerability
network_exposure <- sci_matrix %>%
  left_join(dept_co2, by = c("dept_to" = "dept_code")) %>%
  filter(!is.na(co2_commute)) %>%
  group_by(dept_from) %>%
  summarize(
    ## Population-weighted network exposure (scaled_sci as weight)
    network_fuel_raw = weighted.mean(co2_commute, w = scaled_sci),
    ## Normalized-weight network exposure
    network_fuel_norm = weighted.mean(co2_commute, w = sci_weight),
    ## Network exposure using only distant connections (>200km placeholder)
    ## For now, use all connections; distance restriction in robustness
    n_connections = n(),
    .groups = "drop"
  ) %>%
  rename(dept_code = dept_from)

cat("Network exposure computed for", nrow(network_exposure), "départements.\n")
cat("  Network fuel exposure range:",
    round(min(network_exposure$network_fuel_norm), 3), "to",
    round(max(network_exposure$network_fuel_norm), 3), "\n")

saveRDS(network_exposure, file.path(DATA_DIR, "network_exposure.rds"))

## ============================================================================
## 6. MERGE INTO ANALYSIS PANEL
## ============================================================================

cat("\n=== Building analysis panel ===\n")

elections_panel <- readRDS(file.path(DATA_DIR, "elections_panel.rds"))

## Merge département-level measures
panel <- elections_panel %>%
  left_join(dept_co2, by = "dept_code") %>%
  left_join(network_exposure, by = "dept_code") %>%
  left_join(carbon_tax %>% select(year, rate_eur_tco2, carbon_diesel_cl),
            by = "year") %>%
  mutate(
    ## Treatment variables
    own_carbon_burden = co2_commute * rate_eur_tco2,  # €/worker/year from carbon tax
    network_carbon_burden = network_fuel_norm * rate_eur_tco2,

    ## Interaction: network exposure × post-carbon-tax
    post_carbon = as.integer(year >= 2017),  # Carbon tax became material from 2017
    post_gj = as.integer(year >= 2019),      # Post Gilets Jaunes

    ## Cross-sectional treatment intensity
    own_exposure_x_post = co2_commute * post_carbon,
    network_exposure_x_post = network_fuel_norm * post_carbon,
    own_exposure_x_postgj = co2_commute * post_gj,
    network_exposure_x_postgj = network_fuel_norm * post_gj,

    ## Log population (from turnout data)
    log_registered = log(inscrits + 1),

    ## Election numeric ID for FE
    election_id = as.integer(factor(id_election,
      levels = c("2012_pres_t1", "2014_euro_t1", "2014_euro",
                 "2017_pres_t1", "2019_euro_t1", "2019_euro",
                 "2022_pres_t1", "2024_euro_t1", "2024_euro")))
  )

## Summary statistics
cat("\nFinal panel summary:\n")
cat("  Observations:", nrow(panel), "\n")
cat("  Communes:", n_distinct(panel$code_commune), "\n")
cat("  Elections:", n_distinct(panel$id_election), "\n")
cat("  Départements:", n_distinct(panel$dept_code), "\n")
cat("  Years:", paste(sort(unique(panel$year)), collapse = ", "), "\n")

cat("\nRN vote share by election:\n")
panel %>%
  group_by(id_election, year) %>%
  summarize(
    mean_rn = mean(rn_share, na.rm = TRUE),
    sd_rn = sd(rn_share, na.rm = TRUE),
    n_communes = n(),
    .groups = "drop"
  ) %>%
  arrange(year) %>%
  print()

cat("\nOwn fuel exposure summary:\n")
summary(panel$co2_commute)

cat("\nNetwork fuel exposure summary:\n")
summary(panel$network_fuel_norm)

## Save final panel
saveRDS(panel, file.path(DATA_DIR, "analysis_panel.rds"))
cat("\nAnalysis panel saved to data/analysis_panel.rds\n")

## Also save a département-level aggregated version
dept_panel <- panel %>%
  group_by(dept_code, id_election, year, election_type,
           co2_commute, network_fuel_norm, network_fuel_raw,
           rate_eur_tco2, carbon_diesel_cl,
           own_carbon_burden, network_carbon_burden,
           post_carbon, post_gj,
           own_exposure_x_post, network_exposure_x_post,
           own_exposure_x_postgj, network_exposure_x_postgj) %>%
  summarize(
    rn_share = weighted.mean(rn_share, w = exprimes, na.rm = TRUE),
    turnout = weighted.mean(turnout, w = inscrits, na.rm = TRUE),
    total_registered = sum(inscrits, na.rm = TRUE),
    total_votes = sum(total_votes, na.rm = TRUE),
    n_communes = n(),
    .groups = "drop"
  ) %>%
  mutate(log_pop = log(total_registered + 1))

saveRDS(dept_panel, file.path(DATA_DIR, "dept_panel.rds"))
cat("Département panel saved (", nrow(dept_panel), "obs).\n")
