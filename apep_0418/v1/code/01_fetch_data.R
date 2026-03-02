##############################################################################
# 01_fetch_data.R — Fetch all data from APIs and public sources
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 1: Fetching data ===\n\n")

###############################################################################
# 1. County Business Patterns — Fossil fuel employment by county (2021)
###############################################################################
cat("--- Fetching County Business Patterns (2021) ---\n")

# Fossil fuel NAICS codes:
# 211   = Oil and gas extraction
# 2121  = Coal mining
# 21311 = Support activities for mining
# 486   = Pipeline transportation
# We fetch at NAICS 3-digit and 4-digit levels and aggregate

# Census API base URL for 2021 CBP
cbp_base <- "https://api.census.gov/data/2021/cbp"

# Fetch total employment by county
cat("  Fetching total county employment...\n")
total_url <- paste0(cbp_base, "?get=EMP,ESTAB,PAYANN&for=county:*&NAICS2017=00")
total_resp <- httr::GET(total_url)
total_json <- jsonlite::fromJSON(httr::content(total_resp, "text", encoding = "UTF-8"))
total_df <- as.data.frame(total_json[-1, ], stringsAsFactors = FALSE)
names(total_df) <- total_json[1, ]
total_df <- total_df %>%
  mutate(
    fips = paste0(state, county),
    total_emp = as.numeric(EMP),
    total_estab = as.numeric(ESTAB)
  ) %>%
  select(fips, state_fips = state, county_fips = county, total_emp, total_estab)

cat("  Total counties:", nrow(total_df), "\n")

# Fetch fossil fuel employment by NAICS
ff_naics <- c("211", "2121", "21311", "486")
ff_list <- list()

for (naics in ff_naics) {
  cat("  Fetching NAICS", naics, "...\n")
  url <- paste0(cbp_base, "?get=EMP,ESTAB&for=county:*&NAICS2017=", naics)
  resp <- httr::GET(url)
  if (httr::status_code(resp) == 200) {
    json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
    df <- as.data.frame(json[-1, ], stringsAsFactors = FALSE)
    names(df) <- json[1, ]
    df <- df %>%
      mutate(
        fips = paste0(state, county),
        ff_emp = as.numeric(EMP),
        naics = naics
      ) %>%
      select(fips, naics, ff_emp)
    ff_list[[naics]] <- df
    cat("    Counties with data:", nrow(df), "\n")
  } else {
    cat("    WARNING: API returned status", httr::status_code(resp), "\n")
  }
  Sys.sleep(0.5)  # Rate limiting
}

ff_df <- bind_rows(ff_list) %>%
  group_by(fips) %>%
  summarise(ff_emp = sum(ff_emp, na.rm = TRUE), .groups = "drop")

cat("  Counties with any FF employment:", nrow(ff_df), "\n")

# Merge and compute FF employment share
cbp_county <- total_df %>%
  left_join(ff_df, by = "fips") %>%
  mutate(
    ff_emp = replace_na(ff_emp, 0),
    ff_share = ff_emp / total_emp * 100  # As percentage
  )

saveRDS(cbp_county, file.path(DATA_DIR, "cbp_county_2021.rds"))
cat("  Saved: cbp_county_2021.rds\n\n")

###############################################################################
# 2. MSA/non-MSA delineations — Map counties to MSAs
###############################################################################
cat("--- Fetching MSA delineations ---\n")

# Download Census county-to-CBSA crosswalk (list1 has county-level mappings)
msa_url <- "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2023/delineation-files/list1_2023.xlsx"
msa_file <- file.path(DATA_DIR, "msa_delineation_2023.xlsx")

if (!file.exists(msa_file)) {
  download.file(msa_url, msa_file, mode = "wb")
}

msa_raw <- read_excel(msa_file, skip = 2)
cat("  MSA delineation columns:", paste(names(msa_raw), collapse = ", "), "\n")

# Use the exact column names from the Census file
msa_df <- msa_raw %>%
  transmute(
    cbsa_code = as.character(`CBSA Code`),
    cbsa_title = as.character(`CBSA Title`),
    metro_micro = as.character(`Metropolitan/Micropolitan Statistical Area`),
    state_fips = str_pad(as.character(`FIPS State Code`), 2, pad = "0"),
    county_fips = str_pad(as.character(`FIPS County Code`), 3, pad = "0"),
    fips = paste0(state_fips, county_fips)
  ) %>%
  filter(!is.na(cbsa_code), nchar(fips) == 5)

saveRDS(msa_df, file.path(DATA_DIR, "msa_delineation.rds"))
cat("  Counties mapped to MSAs:", nrow(msa_df), "\n\n")

###############################################################################
# 3. Unemployment data — Census ACS + FRED
###############################################################################
cat("--- Fetching unemployment data ---\n")

fred_key <- Sys.getenv("FRED_API_KEY")

# National unemployment rate 2022 from FRED
nat_url <- paste0(
  "https://api.stlouisfed.org/fred/series/observations?series_id=UNRATE",
  "&observation_start=2022-01-01&observation_end=2022-12-31",
  "&api_key=", fred_key, "&file_type=json"
)
nat_resp <- jsonlite::fromJSON(nat_url)
nat_unemp_2022 <- mean(as.numeric(nat_resp$observations$value), na.rm = TRUE)
cat("  National unemployment 2022 (FRED):", round(nat_unemp_2022, 2), "%\n")
saveRDS(nat_unemp_2022, file.path(DATA_DIR, "national_unemp_2022.rds"))

# County-level unemployment from ACS 5-year (B23025: Employment Status)
# B23025_003 = In labor force, B23025_005 = Unemployed
acs_unemp_url <- paste0(
  "https://api.census.gov/data/2022/acs/acs5?get=NAME,B23025_003E,B23025_005E",
  "&for=county:*"
)
acs_unemp_resp <- httr::GET(acs_unemp_url)
if (httr::status_code(acs_unemp_resp) == 200) {
  unemp_json <- jsonlite::fromJSON(httr::content(acs_unemp_resp, "text", encoding = "UTF-8"))
  laus_df <- as.data.frame(unemp_json[-1, ], stringsAsFactors = FALSE)
  names(laus_df) <- unemp_json[1, ]
  laus_df <- laus_df %>%
    mutate(
      state_fips = state,
      county_fips = county,
      fips = paste0(state, county),
      labor_force = as.numeric(B23025_003E),
      unemployed = as.numeric(B23025_005E),
      unemp_rate = unemployed / labor_force * 100
    ) %>%
    filter(!is.na(unemp_rate), labor_force > 0) %>%
    select(fips, state_fips, county_fips, unemp_rate, labor_force, unemployed)

  saveRDS(laus_df, file.path(DATA_DIR, "laus_county_2022.rds"))
  cat("  Counties with ACS unemployment:", nrow(laus_df), "\n")
} else {
  cat("  WARNING: ACS unemployment API failed. Status:", httr::status_code(acs_unemp_resp), "\n")
  # Fallback: use FRED county-level series
  laus_df <- NULL
}

cat("\n")

###############################################################################
# 4. EIA 860 — Generator data (existing + planned)
###############################################################################
cat("--- Fetching EIA 860 generator data ---\n")

# EIA 860 data (2023) - comes as a ZIP file with multiple spreadsheets
eia860_zip_url <- "https://www.eia.gov/electricity/data/eia860/archive/xls/eia8602023.zip"
eia860_zip <- file.path(DATA_DIR, "eia860_2023.zip")
eia860_dir <- file.path(DATA_DIR, "eia860_2023")

if (!dir.exists(eia860_dir)) {
  cat("  Downloading EIA 860 (2023) ZIP...\n")
  download.file(eia860_zip_url, eia860_zip, mode = "wb")
  dir.create(eia860_dir, showWarnings = FALSE)
  unzip(eia860_zip, exdir = eia860_dir)
  cat("  Extracted files:", paste(list.files(eia860_dir), collapse = ", "), "\n")
}

# Find the generator file in the extracted directory
eia860_files <- list.files(eia860_dir, full.names = TRUE, recursive = TRUE)
eia860_file <- eia860_files[grepl("(?i)3_1_Generator|generator.*y2023", eia860_files)][1]
if (is.na(eia860_file)) {
  # Try any xlsx file
  eia860_file <- eia860_files[grepl("\\.xlsx$", eia860_files)][1]
}
cat("  Using EIA 860 file:", basename(eia860_file), "\n")

# Read generator data from the extracted files
cat("  Reading generator data...\n")

# The ZIP contains multiple files. Find generator and plant files.
gen_file <- eia860_files[grepl("(?i)3_1_Generator", eia860_files)][1]
plant_file <- eia860_files[grepl("(?i)2___Plant|2_1_Plant|Plant_Y", eia860_files)][1]

if (!is.na(gen_file)) {
  sheets <- excel_sheets(gen_file)
  cat("  Generator file sheets:", paste(head(sheets, 3), collapse = ", "), "\n")
  # Read the first sheet (or Operable/Existing)
  operable_sheet <- sheets[grepl("(?i)operable|existing|oper", sheets)]
  if (length(operable_sheet) > 0) {
    eia_gen <- read_excel(gen_file, sheet = operable_sheet[1], skip = 1)
  } else {
    eia_gen <- read_excel(gen_file, sheet = 1, skip = 1)
  }
  cat("  Generators loaded:", nrow(eia_gen), "rows\n")
} else {
  # Fallback: read from the main xlsx if it's a single file
  cat("  No separate generator file found. Trying main file...\n")
  sheets <- excel_sheets(eia860_file)
  gen_sheet <- sheets[grepl("(?i)generator|operable", sheets)]
  if (length(gen_sheet) > 0) {
    eia_gen <- read_excel(eia860_file, sheet = gen_sheet[1], skip = 1)
  } else {
    eia_gen <- read_excel(eia860_file, sheet = 1, skip = 1)
  }
  cat("  Generators loaded:", nrow(eia_gen), "rows\n")
}

if (!is.na(plant_file)) {
  plant_sheets <- excel_sheets(plant_file)
  eia_plant <- read_excel(plant_file, sheet = 1, skip = 1)
  cat("  Plants loaded:", nrow(eia_plant), "rows\n")
} else {
  eia_plant <- NULL
  cat("  WARNING: Plant location file not found in ZIP\n")
}

saveRDS(eia_gen, file.path(DATA_DIR, "eia860_generators_2023.rds"))
if (!is.null(eia_plant)) {
  saveRDS(eia_plant, file.path(DATA_DIR, "eia860_plants_2023.rds"))
}

# Read proposed generators from the same 860 ZIP (Proposed sheet)
if (!is.na(gen_file)) {
  proposed_sheets <- excel_sheets(gen_file)
  if ("Proposed" %in% proposed_sheets) {
    eia_planned <- read_excel(gen_file, sheet = "Proposed", skip = 1)
    saveRDS(eia_planned, file.path(DATA_DIR, "eia860_proposed_2023.rds"))
    cat("  Proposed generators:", nrow(eia_planned), "rows\n")
  }
}

cat("\n")

###############################################################################
# 5. FHFA House Price Index — MSA-level quarterly
###############################################################################
cat("--- Fetching FHFA House Price Index ---\n")

fhfa_url <- "https://www.fhfa.gov/sites/default/files/2024-08/HPI_AT_metro.csv"
fhfa_file <- file.path(DATA_DIR, "fhfa_hpi_metro.csv")

if (!file.exists(fhfa_file)) {
  tryCatch({
    download.file(fhfa_url, fhfa_file)
    cat("  Downloaded FHFA HPI\n")
  }, error = function(e) {
    cat("  WARNING: FHFA download failed:", e$message, "\n")
    # Try alternative URL
    alt_url <- "https://www.fhfa.gov/hpi/download/monthly/hpi_master.csv"
    tryCatch({
      download.file(alt_url, fhfa_file)
      cat("  Downloaded FHFA HPI (alternative)\n")
    }, error = function(e2) {
      cat("  FHFA HPI unavailable, will proceed without property value outcome\n")
    })
  })
}

if (file.exists(fhfa_file)) {
  fhfa_df <- read.csv(fhfa_file, stringsAsFactors = FALSE)
  saveRDS(fhfa_df, file.path(DATA_DIR, "fhfa_hpi.rds"))
  cat("  FHFA rows:", nrow(fhfa_df), "\n")
}

cat("\n")

###############################################################################
# 6. FRED — Quarterly Census of Employment and Wages (aggregate series)
###############################################################################
cat("--- Fetching QCEW employment data from FRED ---\n")

if (nchar(fred_key) > 0) {
  # National unemployment rates for identifying threshold year
  for (yr in 2019:2024) {
    series_id <- "UNRATE"
    url <- paste0(
      "https://api.stlouisfed.org/fred/series/observations?series_id=", series_id,
      "&observation_start=", yr, "-01-01&observation_end=", yr, "-12-31",
      "&api_key=", fred_key, "&file_type=json"
    )
    resp <- jsonlite::fromJSON(url)
    avg <- mean(as.numeric(resp$observations$value), na.rm = TRUE)
    cat("  National unemployment", yr, ":", round(avg, 2), "%\n")
  }
}

cat("\n")

###############################################################################
# 7. ACS 5-year — MSA-level demographics (for covariates)
###############################################################################
cat("--- Fetching ACS 5-year MSA demographics ---\n")

acs_vars <- "B01001_001E,B19013_001E,B15003_022E,B15003_001E,B02001_002E,B02001_001E"
acs_url <- paste0(
  "https://api.census.gov/data/2021/acs/acs5?get=NAME,", acs_vars,
  "&for=metropolitan%20statistical%20area/micropolitan%20statistical%20area:*"
)

acs_resp <- httr::GET(acs_url)
if (httr::status_code(acs_resp) == 200) {
  acs_json <- jsonlite::fromJSON(httr::content(acs_resp, "text", encoding = "UTF-8"))
  acs_df <- as.data.frame(acs_json[-1, ], stringsAsFactors = FALSE)
  names(acs_df) <- acs_json[1, ]
  acs_df <- acs_df %>%
    rename(
      cbsa_code = `metropolitan statistical area/micropolitan statistical area`,
      pop = B01001_001E,
      med_income = B19013_001E,
      bach_degree = B15003_022E,
      total_25plus = B15003_001E,
      white_pop = B02001_002E,
      total_race = B02001_001E
    ) %>%
    mutate(across(c(pop, med_income, bach_degree, total_25plus, white_pop, total_race),
                  as.numeric)) %>%
    mutate(
      pct_bachelors = bach_degree / total_25plus * 100,
      pct_white = white_pop / total_race * 100
    )
  saveRDS(acs_df, file.path(DATA_DIR, "acs_msa_demographics.rds"))
  cat("  MSAs with ACS data:", nrow(acs_df), "\n")
} else {
  cat("  WARNING: ACS API returned status", httr::status_code(acs_resp), "\n")
}

cat("\n")

###############################################################################
# 8. Treasury Energy Community lists
###############################################################################
cat("--- Fetching Treasury Energy Community data ---\n")

# Treasury publishes county-level energy community data
# Main page: https://home.treasury.gov/policy-issues/tax-policy/data-transparency/all-treasury-generated-energy-communities-data-sets
# Direct download: FFE+U qualified MSAs/non-MSAs

ec_url <- "https://home.treasury.gov/system/files/8861/MSA-NMSA_FFE_2024.xlsx"
ec_file <- file.path(DATA_DIR, "treasury_energy_communities_2024.xlsx")

if (!file.exists(ec_file)) {
  tryCatch({
    download.file(ec_url, ec_file, mode = "wb")
    cat("  Downloaded Treasury EC data\n")
  }, error = function(e) {
    cat("  WARNING: Treasury download failed, trying alternatives...\n")
    # Try the DOE NETL data layer
    alt_url <- "https://home.treasury.gov/system/files/8861/MSA-NMSA_FFE_2023.xlsx"
    tryCatch(download.file(alt_url, ec_file, mode = "wb"), error = function(e2) {
      cat("  Treasury data unavailable. Will construct from CBP data directly.\n")
    })
  })
}

if (file.exists(ec_file)) {
  ec_sheets <- excel_sheets(ec_file)
  cat("  EC sheets:", paste(ec_sheets, collapse = ", "), "\n")
  ec_raw <- read_excel(ec_file, sheet = 1)
  saveRDS(ec_raw, file.path(DATA_DIR, "treasury_ec_raw.rds"))
  cat("  Energy community entries:", nrow(ec_raw), "\n")
}

cat("\n=== Data fetching complete ===\n")
cat("Files saved to:", DATA_DIR, "\n")
cat("Contents:\n")
cat(paste("  ", list.files(DATA_DIR), collapse = "\n"), "\n")
