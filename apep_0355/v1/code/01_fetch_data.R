## ============================================================================
## 01_fetch_data.R — Fetch and load all data sources
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
##
## Data sources:
##   1. T-MSIS Parquet (local) — Medicaid provider billing
##   2. NPPES extract (local) — Provider geography/type
##   3. OIG LEIE (direct CSV) — Fraud exclusion events
##   4. Census ZCTA-County crosswalk (download) — ZIP-to-county
##   5. Census ACS (API) — County demographics
## ============================================================================

source("00_packages.R")

## ---- Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ====================================================================
## 1. T-MSIS Parquet (local — lazy reference)
## ====================================================================
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
stopifnot(file.exists(tmsis_path))
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)
cat(sprintf("Schema: %s\n", paste(names(tmsis_ds), collapse = ", ")))

## ====================================================================
## 2. NPPES extract (local)
## ====================================================================
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
stopifnot(file.exists(nppes_path))
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

# NPI → ZIP5 → state mapping
npi_geo <- nppes[!is.na(state) & state != "",
                 .(npi, state, zip5, entity_type, taxonomy_1, sole_prop,
                   enumeration_date, deactivation_date)]

## ====================================================================
## 3. OIG LEIE Exclusion Data (direct CSV download)
## ====================================================================
cat("Downloading OIG LEIE exclusion data...\n")
leie_url <- "https://oig.hhs.gov/exclusions/downloadables/UPDATED.csv"
leie_file <- file.path(DATA, "leie_updated.csv")

if (!file.exists(leie_file)) {
  download.file(leie_url, leie_file, mode = "wb", quiet = FALSE)
}

leie <- fread(leie_file, encoding = "Latin-1")
cat(sprintf("OIG LEIE: %s total records\n", format(nrow(leie), big.mark = ",")))

# Clean and filter
# NPI is integer in this CSV — convert to character for filtering
leie[, npi_char := sprintf("%010d", as.integer(NPI))]
leie[, exclusion_date := as.Date(as.character(EXCLDATE), format = "%Y%m%d")]
leie[, reinstate_date := as.Date(as.character(REINDATE), format = "%Y%m%d")]
leie[is.na(reinstate_date), reinstate_date := NA]

# Filter to 2018-2024 exclusions with valid NPIs (NPI > 0 and 10 digits)
leie_valid <- leie[
  !is.na(exclusion_date) &
  year(exclusion_date) >= 2018 &
  year(exclusion_date) <= 2024 &
  NPI > 0 &
  nchar(npi_char) == 10
]

leie_valid[, npi := npi_char]

cat(sprintf("LEIE 2018-2024 with valid NPI: %d records\n", nrow(leie_valid)))
cat(sprintf("  By year: %s\n",
            paste(leie_valid[, .N, by = year(exclusion_date)][order(year)],
                  collapse = ", ")))

# Classify LEIE specialties into HCBS-related categories
leie_valid[, hcbs_related := SPECIALTY %in% c(
  "PERSONAL CARE PROVID", "NURSE/NURSES AIDE", "HOME HEALTH AGENCY",
  "HEALTH CARE AIDE", "MENTAL/BEHAVIORAL HE", "THERAPIST",
  "SOCIAL WORKER", "COUNSELOR", "PSYCHOLOGIST",
  "COMMUNITY HEALTH CTR", "RESIDENTIAL TREATMEN"
)]

cat(sprintf("  HCBS-related specialties: %d (%.0f%%)\n",
            sum(leie_valid$hcbs_related),
            100 * mean(leie_valid$hcbs_related)))

# Save cleaned LEIE
saveRDS(leie_valid, file.path(DATA, "leie_cleaned.rds"))

## ====================================================================
## 4. Census ZCTA-to-County Crosswalk
## ====================================================================
cat("Downloading Census ZCTA-County crosswalk...\n")
zcta_file <- file.path(DATA, "zcta_county_rel.txt")

if (!file.exists(zcta_file)) {
  zcta_url <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_county20_natl.txt"
  download.file(zcta_url, zcta_file, mode = "wb", quiet = FALSE)
}

zcta_county <- fread(zcta_file)
# Map ZCTA to primary county (highest land area overlap)
zcta_primary <- zcta_county[, .SD[which.max(AREALAND_PART)], by = GEOID_ZCTA5_20]
zcta_primary[, zip5 := sprintf("%05d", as.integer(GEOID_ZCTA5_20))]
zcta_primary[, county_fips := sprintf("%05d", as.integer(GEOID_COUNTY_20))]
zcta_primary[, state_fips := substr(county_fips, 1, 2)]

zip_county <- zcta_primary[, .(zip5, county_fips, state_fips)]
saveRDS(zip_county, file.path(DATA, "zip_county_xwalk.rds"))
cat(sprintf("ZIP-County crosswalk: %d ZIPs mapped\n", nrow(zip_county)))

## ====================================================================
## 5. Census ACS — County demographics
## ====================================================================
cat("Fetching Census ACS 5-year county data...\n")
acs_key <- Sys.getenv("CENSUS_API_KEY")

# Variables: total pop, 65+ pop, poverty count, median income
acs_vars <- "B01003_001E,B01001_020E,B01001_021E,B01001_022E,B01001_023E,B01001_024E,B01001_025E,B01001_044E,B01001_045E,B01001_046E,B01001_047E,B01001_048E,B01001_049E,B17001_002E,B19013_001E"

acs_url <- sprintf(
  "https://api.census.gov/data/2022/acs/acs5?get=%s,NAME&for=county:*&key=%s",
  acs_vars, acs_key
)

acs_raw <- jsonlite::fromJSON(acs_url)
acs_dt <- as.data.table(acs_raw[-1, ])
setnames(acs_dt, acs_raw[1, ])

# Construct county FIPS
acs_dt[, county_fips := paste0(state, county)]
acs_dt[, total_pop := as.numeric(B01003_001E)]

# Convert all ACS variables to numeric (they arrive as character from JSON)
age65_male <- paste0("B01001_0", 20:25, "E")
age65_female <- paste0("B01001_0", 44:49, "E")
all_age_cols <- c(age65_male, age65_female)
for (col in all_age_cols) {
  if (col %in% names(acs_dt)) acs_dt[, (col) := as.numeric(get(col))]
}

# Sum 65+ population (males 65-85+ and females 65-85+)
acs_dt[, pop_65plus := rowSums(.SD, na.rm = TRUE),
       .SDcols = intersect(all_age_cols, names(acs_dt))]

acs_dt[, poverty_count := as.numeric(B17001_002E)]
acs_dt[, median_income := as.numeric(B19013_001E)]
acs_dt[, poverty_rate := poverty_count / total_pop]
acs_dt[, elderly_share := pop_65plus / total_pop]

county_demo <- acs_dt[, .(county_fips, total_pop, pop_65plus, elderly_share,
                          poverty_rate, median_income)]
saveRDS(county_demo, file.path(DATA, "county_demographics.rds"))
cat(sprintf("ACS county demographics: %d counties\n", nrow(county_demo)))

## ====================================================================
## 6. Build NPI → ZIP → county → state lookup
## ====================================================================
npi_full_geo <- merge(npi_geo, zip_county, by = "zip5", all.x = TRUE)
npi_full_geo <- npi_full_geo[!is.na(county_fips)]
saveRDS(npi_full_geo, file.path(DATA, "npi_geography.rds"))
cat(sprintf("NPI geography lookup: %d NPIs with county assignment\n",
            nrow(npi_full_geo)))

cat("\n=== Data fetch complete ===\n")
