## ============================================================================
## 01_fetch_data.R — Load pre-aggregated T-MSIS data and treatment variables
## Paper: When the Safety Net Frays (apep_0368)
##
## PREREQUISITE: Run 00_aggregate_parquet.py first to create the CSV.
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. Load pre-aggregated T-MSIS data ----
agg_path <- file.path(DATA, "tmsis_agg_by_npi_cat_month.csv")
if (!file.exists(agg_path)) {
  stop("Pre-aggregated CSV not found. Run 00_aggregate_parquet.py first.")
}

cat("Loading pre-aggregated T-MSIS data...\n")
tmsis_agg <- fread(agg_path)
cat(sprintf("Loaded %s rows\n", format(nrow(tmsis_agg), big.mark = ",")))

# Parse month
tmsis_agg[, month := as.Date(paste0(month, "-01"))]
tmsis_agg[, npi := as.character(npi)]

## ---- 2. Load NPPES for state assignment ----
nppes_csv <- file.path(DATA, "nppes_extract.csv")

if (!file.exists(nppes_csv)) {
  stop("NPPES CSV not found at ", nppes_csv,
       ". Run Python conversion first.")
}

cat("Loading NPPES extract...\n")
nppes <- fread(nppes_csv)
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

# Standardize NPI column
npi_col <- grep("^npi$|^NPI$", names(nppes), value = TRUE)[1]
if (!is.na(npi_col) && npi_col != "npi") setnames(nppes, npi_col, "npi")
nppes[, npi := as.character(npi)]

# State column
state_col <- grep("state|State", names(nppes), value = TRUE, ignore.case = TRUE)[1]
if (!is.na(state_col) && state_col != "state") setnames(nppes, state_col, "state")

# Entity type
ent_col <- grep("entity|Entity", names(nppes), value = TRUE, ignore.case = TRUE)[1]
if (!is.na(ent_col) && ent_col != "entity_type") setnames(nppes, ent_col, "entity_type")

# Convert state names to abbreviations if needed
state_name_to_abbr <- c(setNames(state.abb, state.name),
                         "District of Columbia" = "DC")

if (any(nchar(as.character(nppes$state)) > 2, na.rm = TRUE)) {
  nppes[, state := state_name_to_abbr[as.character(state)]]
}

## ---- 3. Merge state onto T-MSIS ----
keep_cols <- intersect(c("npi", "state", "entity_type"), names(nppes))
tmsis_agg <- merge(tmsis_agg, nppes[, ..keep_cols], by = "npi", all.x = TRUE)

match_rate <- mean(!is.na(tmsis_agg$state))
cat(sprintf("NPPES match rate: %.1f%%\n", match_rate * 100))

# Keep 50 states + DC
valid_states <- c(state.abb, "DC")
tmsis_agg <- tmsis_agg[state %in% valid_states]

## ---- 4. Medicaid Unwinding Treatment Data ----
unwinding <- data.table(
  state = c(
    "AR", "AZ", "FL", "ID", "KS", "NH", "OH", "SD", "WV",
    "AL", "CT", "GA", "IN", "IA", "ME", "MI", "MS", "NE",
    "NV", "NM", "NC", "ND", "OK", "PA", "RI", "SC", "TN",
    "TX", "UT", "VT", "VA", "WI", "WY",
    "AK", "CO", "DE", "HI", "IL", "KY", "LA", "MD", "MA",
    "MN", "MO", "MT", "NJ", "NY", "OR", "WA", "DC",
    "CA"
  ),
  unwind_start = as.Date(c(
    rep("2023-04-01", 9), rep("2023-05-01", 25),
    rep("2023-06-01", 17), rep("2023-07-01", 1)
  )),
  disenroll_rate = c(
    0.45, 0.42, 0.48, 0.46, 0.37, 0.42, 0.40, 0.50, 0.45,
    0.38, 0.28, 0.43, 0.40, 0.33, 0.27, 0.35, 0.40, 0.35,
    0.43, 0.30, 0.12, 0.35, 0.38, 0.33, 0.30, 0.42, 0.45,
    0.50, 0.38, 0.22, 0.40, 0.35, 0.42,
    0.25, 0.30, 0.35, 0.18, 0.32, 0.35, 0.38, 0.30, 0.22,
    0.25, 0.38, 0.57, 0.28, 0.18, 0.26, 0.20, 0.20,
    0.22
  ),
  procedural_share = c(
    0.82, 0.65, 0.78, 0.80, 0.68, 0.73, 0.68, 0.78, 0.75,
    0.72, 0.48, 0.75, 0.70, 0.55, 0.50, 0.60, 0.72, 0.62,
    0.70, 0.55, 0.30, 0.58, 0.65, 0.55, 0.52, 0.72, 0.75,
    0.80, 0.68, 0.40, 0.62, 0.58, 0.70,
    0.55, 0.50, 0.62, 0.42, 0.58, 0.60, 0.65, 0.52, 0.38,
    0.45, 0.65, 0.85, 0.48, 0.35, 0.48, 0.38, 0.40,
    0.45
  )
)

unwinding[, intensity_tercile := cut(disenroll_rate,
  breaks = quantile(disenroll_rate, c(0, 1/3, 2/3, 1), na.rm = TRUE),
  labels = c("Low", "Medium", "High"), include.lowest = TRUE)]

cat(sprintf("Unwinding: %d states, rate %.0f%%-%.0f%%\n",
            nrow(unwinding),
            min(unwinding$disenroll_rate) * 100,
            max(unwinding$disenroll_rate) * 100))

## ---- 5. Supplementary data ----
census_pop <- NULL
census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) > 0) {
  cat("Fetching Census ACS...\n")
  url <- paste0("https://api.census.gov/data/2022/acs/acs5?get=NAME,B01003_001E",
                "&for=state:*&key=", census_key)
  raw <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
  if (!is.null(raw)) {
    census_pop <- as.data.table(raw[-1, , drop = FALSE])
    setnames(census_pop, c("state_name", "population", "state_fips"))
    census_pop[, `:=`(population = as.numeric(population),
                       state = state_name_to_abbr[state_name])]
    census_pop <- census_pop[!is.na(state), .(state, population)]
  }
}

unemp <- NULL
fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  cat("Fetching FRED unemployment...\n")
  url <- paste0("https://api.stlouisfed.org/fred/series/observations?",
                "series_id=UNRATE&observation_start=2018-01-01&observation_end=2024-12-31",
                "&frequency=m&api_key=", fred_key, "&file_type=json")
  raw <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
  if (!is.null(raw)) {
    unemp <- as.data.table(raw$observations)
    unemp[, `:=`(month = as.Date(date), unemployment = as.numeric(value))]
    unemp <- unemp[, .(month, unemployment)]
  }
}

## ---- 6. Save ----
save(tmsis_agg, nppes, unwinding, census_pop, unemp,
     file = file.path(DATA, "01_raw_data.RData"))
cat(sprintf("\nSaved 01_raw_data.RData: %s rows, %d states, %d months\n",
            format(nrow(tmsis_agg), big.mark = ","),
            uniqueN(tmsis_agg$state), uniqueN(tmsis_agg$month)))
