## ============================================================================
## 01_fetch_data.R — Data acquisition for apep_0454
##
## Sources:
##   1. T-MSIS Medicaid Provider Spending (local Parquet)
##   2. NPPES National Provider Registry (CMS bulk download)
##   3. Census ACS 5-Year (state demographics)
##   4. FRED (state unemployment)
##   5. CDC Provisional COVID-19 Deaths (Socrata API)
##   6. CDC Provisional Drug Overdose Deaths (Socrata API)
##   7. OxCGRT US Sub-National COVID Policy Tracker (GitHub CSV)
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")

## ---- 1. T-MSIS Parquet ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  dir.create(SHARED_DATA, showWarnings = FALSE, recursive = TRUE)
  zip_path <- file.path(SHARED_DATA, "medicaid_provider_spending.csv.zip")

  # Download if zip not already present
  if (!file.exists(zip_path) || file.size(zip_path) < 3e9) {
    cat("T-MSIS Parquet not found. Downloading from HHS Open Data...\n")
    download.file(
      "https://stopendataprod.blob.core.windows.net/datasets/medicaid-provider-spending/2026-02-09/medicaid-provider-spending.csv.zip",
      zip_path, mode = "wb", timeout = 7200
    )
  } else {
    cat("T-MSIS zip already downloaded.\n")
  }

  cat("Unzipping...\n")
  csv_file <- unzip(zip_path, exdir = SHARED_DATA)
  cat("Converting to Parquet...\n")
  dt <- fread(csv_file[1], showProgress = TRUE, nThread = 8)
  write_parquet(dt, tmsis_path)
  rm(dt); gc()
  file.remove(csv_file, zip_path)
  cat("T-MSIS Parquet created.\n")
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. NPPES Extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (!file.exists(nppes_path)) {
  cat("NPPES extract not found. Downloading bulk file from CMS...\n")
  nppes_zip <- file.path(SHARED_DATA, "nppes_full.zip")
  download.file(
    "https://download.cms.gov/nppes/NPPES_Data_Dissemination_February_2026.zip",
    nppes_zip, mode = "wb", timeout = 600
  )
  csv_files <- unzip(nppes_zip, exdir = SHARED_DATA)
  nppes_csv <- csv_files[grepl("npidata_pfile.*\\.csv$", csv_files) & !grepl("header", csv_files)]

  nppes_cols <- c(
    "NPI", "Entity Type Code",
    "Provider Organization Name (Legal Business Name)",
    "Provider Last Name (Legal Name)", "Provider First Name",
    "Provider Credential Text", "Provider Sex Code",
    "Provider Business Practice Location Address State Name",
    "Provider Business Practice Location Address Postal Code",
    "Provider Business Practice Location Address City Name",
    "Healthcare Provider Taxonomy Code_1",
    "Healthcare Provider Taxonomy Code_2",
    "Is Sole Proprietor", "Is Organization Subpart",
    "Parent Organization LBN", "Parent Organization TIN",
    "Provider Enumeration Date", "NPI Deactivation Date",
    "NPI Deactivation Reason Code", "NPI Reactivation Date",
    "Last Update Date"
  )
  nppes <- fread(nppes_csv[1], select = nppes_cols, showProgress = TRUE, nThread = 8)
  setnames(nppes, c(
    "npi", "entity_type", "org_name", "last_name", "first_name",
    "credential", "gender", "state", "zip", "city",
    "taxonomy_1", "taxonomy_2", "sole_prop", "is_subpart",
    "parent_org_name", "parent_org_tin",
    "enumeration_date", "deactivation_date", "deactivation_reason",
    "reactivation_date", "last_update"
  ))
  for (col in c("enumeration_date", "deactivation_date", "reactivation_date", "last_update")) {
    nppes[, (col) := as.Date(get(col), format = "%m/%d/%Y")]
  }
  nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]
  write_parquet(nppes, nppes_path)
  file.remove(csv_files, nppes_zip)
  cat(sprintf("NPPES extract saved: %s providers\n", format(nrow(nppes), big.mark = ",")))
} else {
  cat("Loading NPPES extract...\n")
  nppes <- as.data.table(read_parquet(nppes_path))
}
nppes[, npi := as.character(npi)]

## ---- 3. Build state × provider-type × month panel from T-MSIS ----
cat("Building provider-level monthly aggregates via Arrow...\n")

# Classify HCPCS and aggregate at NPI × month × provider-type level
provider_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    is_hcbs = hcpcs_prefix %in% c("T", "H", "S")
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, is_hcbs) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
provider_monthly[, billing_npi := as.character(billing_npi)]
provider_monthly[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
provider_monthly[, year := year(month_date)]
provider_monthly[, month_num := month(month_date)]

cat(sprintf("Provider monthly: %s rows\n", format(nrow(provider_monthly), big.mark = ",")))

# NPI → state mapping
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2,
                   .(npi, state, entity_type, enumeration_date,
                     deactivation_date, sole_prop, taxonomy_1)]
provider_monthly <- merge(provider_monthly, npi_state,
                          by.x = "billing_npi", by.y = "npi", all.x = TRUE)

# Drop unmatched and territories
us_states <- c(state.abb, "DC")
provider_monthly <- provider_monthly[state %in% us_states]

cat(sprintf("After state filter: %s rows, %d states\n",
            format(nrow(provider_monthly), big.mark = ","),
            uniqueN(provider_monthly$state)))

# Provider type label
provider_monthly[, prov_type := fifelse(is_hcbs, "HCBS", "Non-HCBS")]

# State × provider-type × month panel
panel <- provider_monthly[, .(
  total_paid       = sum(total_paid),
  total_claims     = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers      = uniqueN(billing_npi)
), by = .(state, prov_type, month_date, year, month_num)]

setorder(panel, state, prov_type, month_date)
cat(sprintf("Panel: %d rows (%d states × %d types × %d months)\n",
            nrow(panel), uniqueN(panel$state), uniqueN(panel$prov_type),
            uniqueN(panel$month_date)))

## ---- 4. Pre-COVID Provider Exit Measures (v8: purely pre-treatment) ----
cat("Computing pre-COVID provider exit intensity...\n")

## --- 4a. PRIMARY: Pre-period exit rate (2018 active, absent from ALL 2019) ---
# This is purely pre-treatment: no post-Feb-2020 information used
active_2018 <- provider_monthly[year == 2018,
                                .(billing_npi, state, is_hcbs, entity_type,
                                  enumeration_date, taxonomy_1)] |>
  unique(by = c("billing_npi", "state"))

active_2019 <- provider_monthly[year == 2019, .(billing_npi)] |> unique()

# Exiters: active in 2018, NOT active in 2019
active_2018[, exited_pre := !(billing_npi %in% active_2019$billing_npi)]

# State-level pre-period exit rates
state_exits_pre <- active_2018[, .(
  n_active_pre       = .N,
  n_exited_pre       = sum(exited_pre),
  exit_rate_pre      = mean(exited_pre),
  n_hcbs_active_pre  = sum(is_hcbs),
  n_hcbs_exited_pre  = sum(exited_pre & is_hcbs),
  hcbs_exit_rate_pre = fifelse(sum(is_hcbs) > 0,
                                sum(exited_pre & is_hcbs) / sum(is_hcbs), NA_real_)
), by = state]

cat(sprintf("Pre-period exit rates: median %.1f%%, range %.1f%%--%.1f%%\n",
            100 * median(state_exits_pre$exit_rate_pre),
            100 * min(state_exits_pre$exit_rate_pre),
            100 * max(state_exits_pre$exit_rate_pre)))

## --- 4b. LEGACY: Pandemic exit rate (for robustness comparison) ---
active_2018_2019 <- provider_monthly[year %in% 2018:2019,
                                     .(billing_npi, state, is_hcbs, entity_type,
                                       enumeration_date, taxonomy_1)] |>
  unique(by = c("billing_npi", "state"))

active_2020_plus <- provider_monthly[month_date >= "2020-03-01",
                                     .(billing_npi)] |> unique()

active_2018_2019[, exited_pandemic := !(billing_npi %in% active_2020_plus$billing_npi)]

state_exits_pandemic <- active_2018_2019[, .(
  n_active_pandemic       = .N,
  n_exited_pandemic       = sum(exited_pandemic),
  exit_rate_pandemic      = mean(exited_pandemic),
  hcbs_exit_rate_pandemic = fifelse(sum(is_hcbs) > 0,
                                     sum(exited_pandemic & is_hcbs) / sum(is_hcbs), NA_real_)
), by = state]

cat(sprintf("Pandemic exit rates: median %.1f%%, range %.1f%%--%.1f%%\n",
            100 * median(state_exits_pandemic$exit_rate_pandemic),
            100 * min(state_exits_pandemic$exit_rate_pandemic),
            100 * max(state_exits_pandemic$exit_rate_pandemic)))

## --- 4c. Merge both exit measures ---
state_exits <- merge(state_exits_pre, state_exits_pandemic, by = "state", all = TRUE)

## --- 4d. Entity-type exit rates (for WS6 heterogeneity) ---
cat("Computing entity-type-specific exit rates...\n")

entity_exits_pre <- active_2018[!is.na(entity_type) & entity_type %in% c("1", "2"), .(
  n_active_ent      = .N,
  n_exited_ent      = sum(exited_pre),
  exit_rate_ent_pre = mean(exited_pre)
), by = .(state, entity_type)]

# Reshape to wide for merge into panel
entity_exits_wide <- dcast(entity_exits_pre, state ~ entity_type,
                            value.var = c("exit_rate_ent_pre", "n_active_ent"))
setnames(entity_exits_wide,
         c("state",
           "exit_rate_ent_pre_1", "exit_rate_ent_pre_2",
           "n_active_ent_1", "n_active_ent_2"),
         c("state",
           "exit_rate_indiv_pre", "exit_rate_org_pre",
           "n_active_indiv", "n_active_org"))

state_exits <- merge(state_exits, entity_exits_wide, by = "state", all.x = TRUE)

## --- 4e. Career length proxy ---
active_2018[, career_years := as.numeric(as.Date("2020-01-01") - enumeration_date) / 365.25]

## --- 4f. Bartik instrument (using PRE-PERIOD exit rates) ---
# Classify broad specialty from taxonomy
active_2018[, specialty := fcase(
  is_hcbs, "hcbs",
  grepl("^101Y|^103T|^106H|^2084P|^363L", taxonomy_1), "behavioral_health",
  grepl("^207|^208|^174", taxonomy_1), "physician",
  default = "other"
)]

# National specialty exit rates (2018 -> 2019)
national_spec_exit_pre <- active_2018[, .(
  national_exit_rate_pre = mean(exited_pre)
), by = specialty]

# Local specialty shares (2018 composition)
local_spec_share_pre <- active_2018[, .(n = .N), by = .(state, specialty)]
local_spec_share_pre[, share := n / sum(n), by = state]

# Bartik predicted exit rate (pre-period)
bartik_pre <- merge(local_spec_share_pre, national_spec_exit_pre, by = "specialty")
bartik_state_pre <- bartik_pre[, .(
  predicted_exit_rate = sum(share * national_exit_rate_pre)
), by = state]

state_exits <- merge(state_exits, bartik_state_pre, by = "state", all.x = TRUE)

## --- 4g. Quartiles and binary indicators (based on pre-period exit rate) ---
state_exits[, exit_quartile := cut(exit_rate_pre,
                                    breaks = quantile(exit_rate_pre, probs = 0:4/4, na.rm = TRUE),
                                    labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)"),
                                    include.lowest = TRUE)]
state_exits[, high_exit := exit_rate_pre > median(exit_rate_pre, na.rm = TRUE)]

cat(sprintf("Pre-period exit rates: median %.1f%%, range %.1f%%--%.1f%%\n",
            100 * median(state_exits$exit_rate_pre),
            100 * min(state_exits$exit_rate_pre),
            100 * max(state_exits$exit_rate_pre)))
cat(sprintf("Correlation(pre-period, pandemic): %.3f\n",
            cor(state_exits$exit_rate_pre, state_exits$exit_rate_pandemic, use = "complete.obs")))

## ---- 5. Census ACS State Demographics ----
cat("Fetching Census ACS 5-year data...\n")
census_key <- Sys.getenv("CENSUS_API_KEY")

acs_vars <- c(
  "B01003_001E",  # total population
  "B19013_001E",  # median household income
  "B17001_002E",  # below poverty level
  "B27010_001E",  # health insurance coverage
  "B02001_003E",  # Black population
  "B03003_003E",  # Hispanic population
  "B01002_001E"   # median age
)

acs_url <- sprintf(
  "https://api.census.gov/data/2019/acs/acs5?get=%s,NAME&for=state:*&key=%s",
  paste(acs_vars, collapse = ","), census_key
)
acs_raw <- jsonlite::fromJSON(acs_url)
acs_dt <- as.data.table(acs_raw[-1, ])
setnames(acs_dt, acs_raw[1, ])

# Clean numerics
for (v in acs_vars) acs_dt[, (v) := as.numeric(get(v))]

# State FIPS → abbreviation
fips_map <- data.table(
  fips = sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56)),
  state_abb = c(state.abb[1:2], state.abb[3:50], "DC")[match(
    c(state.name[1:2], state.name[3:50], "District of Columbia"),
    c(state.name, "District of Columbia")
  )]
)
# Simpler approach: use NAME field
state_name_map <- data.table(
  name = c(state.name, "District of Columbia"),
  abb = c(state.abb, "DC")
)
acs_dt <- merge(acs_dt, state_name_map, by.x = "NAME", by.y = "name", all.x = TRUE)
acs_dt <- acs_dt[!is.na(abb)]

# Census returns FIPS as "state"; our merge added "abb"
setnames(acs_dt, c("NAME", "B01003_001E", "B19013_001E", "B17001_002E",
                    "B27010_001E", "B02001_003E", "B03003_003E", "B01002_001E",
                    "state", "abb"),
         c("state_name", "population", "median_income", "poverty_count",
           "health_ins_total", "black_pop", "hispanic_pop", "median_age",
           "fips", "state"))

acs_dt[, poverty_rate := poverty_count / population]
acs_dt[, pct_black := black_pop / population]
acs_dt[, pct_hispanic := hispanic_pop / population]

cat(sprintf("ACS data: %d states\n", nrow(acs_dt)))

## ---- 6. FRED State Unemployment ----
cat("Fetching FRED state unemployment rates...\n")
fred_key <- Sys.getenv("FRED_API_KEY")

# State unemployment series IDs (format: XXYUR for state XX)
fred_series <- paste0(state.abb, "UR")
fred_series <- c(fred_series, "DCUR")

fetch_fred <- function(series_id, api_key) {
  url <- sprintf(
    "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2018-01-01&observation_end=2024-12-31",
    series_id, api_key
  )
  res <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
  if (is.null(res) || is.null(res$observations)) return(NULL)
  dt <- as.data.table(res$observations)
  dt[, `:=`(series = series_id, value = as.numeric(value), date = as.Date(date))]
  dt[, .(series, date, value)]
}

unemp_list <- lapply(fred_series, fetch_fred, api_key = fred_key)
unemp_list <- unemp_list[!sapply(unemp_list, is.null)]

if (length(unemp_list) > 0) {
  unemp <- rbindlist(unemp_list, fill = TRUE)
  if ("series" %in% names(unemp) && nrow(unemp) > 0) {
    unemp[, state := gsub("UR$", "", series)]
    unemp[, month_date := floor_date(date, "month")]
    unemp <- unemp[, .(unemp_rate = mean(value, na.rm = TRUE)), by = .(state, month_date)]
  } else {
    cat("WARNING: FRED data empty or missing series column. Using BLS fallback.\n")
    unemp <- data.table(state = character(), month_date = as.Date(character()),
                         unemp_rate = numeric())
  }
} else {
  cat("WARNING: All FRED API calls failed. Using empty unemployment data.\n")
  unemp <- data.table(state = character(), month_date = as.Date(character()),
                       unemp_rate = numeric())
}

cat(sprintf("FRED unemployment: %d state-months\n", nrow(unemp)))

## ---- 7. CDC COVID Deaths by State-Month ----
cat("Fetching CDC provisional COVID-19 deaths...\n")

# Provisional COVID-19 Deaths by Week Ending Date and State
# URL-encode the where clause to avoid quoting issues
covid_url <- paste0("https://data.cdc.gov/resource/r8kw-7aab.json?",
                    "$limit=50000&$select=state,start_date,end_date,covid_19_deaths,total_deaths",
                    "&$where=group%3D%27By%20Week%27")
covid_raw <- tryCatch(
  jsonlite::fromJSON(covid_url),
  error = function(e) {
    cat("Filtered query failed, using unfiltered...\n")
    jsonlite::fromJSON("https://data.cdc.gov/resource/r8kw-7aab.json?$limit=50000")
  }
)
covid_dt <- as.data.table(covid_raw)

if ("covid_19_deaths" %in% names(covid_dt)) {
  covid_dt[, `:=`(
    covid_deaths = as.numeric(covid_19_deaths),
    total_deaths = as.numeric(total_deaths),
    week_start = as.Date(start_date)
  )]
} else {
  # Unfiltered response: find COVID death columns
  death_col <- grep("covid.*death", names(covid_dt), value = TRUE, ignore.case = TRUE)[1]
  if (!is.null(death_col)) {
    covid_dt[, `:=`(covid_deaths = as.numeric(get(death_col)), week_start = as.Date(start_date))]
    covid_dt[, total_deaths := NA_real_]
  }
}
covid_dt[, month_date := floor_date(week_start, "month")]

# State name to abbreviation
covid_dt <- merge(covid_dt, state_name_map, by.x = "state", by.y = "name", all.x = TRUE)
covid_dt <- covid_dt[!is.na(abb)]

covid_monthly <- covid_dt[, .(
  covid_deaths = sum(covid_deaths, na.rm = TRUE),
  total_deaths = sum(total_deaths, na.rm = TRUE)
), by = .(state = abb, month_date)]

cat(sprintf("CDC COVID deaths: %d state-months\n", nrow(covid_monthly)))

## ---- 8. CDC Drug Overdose Deaths (State-Month) ----
cat("Fetching CDC provisional drug overdose deaths...\n")

od_url <- paste0("https://data.cdc.gov/resource/xkb8-kh2a.json?",
                 "$limit=50000&$select=state_name,year,month,indicator,data_value",
                 "&$where=indicator%3D%27Number%20of%20Drug%20Overdose%20Deaths%27")
od_raw <- tryCatch(jsonlite::fromJSON(od_url), error = function(e) {
  cat("Overdose endpoint failed, trying unfiltered...\n")
  tryCatch(
    jsonlite::fromJSON("https://data.cdc.gov/resource/xkb8-kh2a.json?$limit=50000"),
    error = function(e2) { cat("All OD endpoints failed\n"); list() }
  )
})
od_dt <- as.data.table(od_raw)

# Filter for overdose deaths if unfiltered
if ("indicator" %in% names(od_dt)) {
  od_dt <- od_dt[grepl("Overdose", indicator, ignore.case = TRUE)]
}

if (nrow(od_dt) > 0 && "data_value" %in% names(od_dt)) {
  # Handle month as text (e.g., "January") or numeric
  month_map <- setNames(1:12, month.name)
  od_dt[, month_num := fifelse(month %in% names(month_map),
                                as.integer(month_map[month]),
                                suppressWarnings(as.integer(month)))]
  od_dt[, year_num := as.integer(year)]
  od_dt <- od_dt[!is.na(month_num) & !is.na(year_num)]
  od_dt[, `:=`(
    overdose_deaths = as.numeric(data_value),
    month_date = as.Date(sprintf("%d-%02d-01", year_num, month_num))
  )]
  od_dt <- merge(od_dt, state_name_map, by.x = "state_name", by.y = "name", all.x = TRUE)
  od_monthly <- od_dt[!is.na(abb), .(
    overdose_deaths = sum(overdose_deaths, na.rm = TRUE)
  ), by = .(state = abb, month_date)]
  cat(sprintf("CDC overdose deaths: %d state-months\n", nrow(od_monthly)))
} else {
  cat("WARNING: Overdose data unavailable. Will proceed without.\n")
  od_monthly <- data.table(state = character(), month_date = as.Date(character()),
                           overdose_deaths = numeric())
}

## ---- 9. OxCGRT COVID Policy Stringency ----
cat("Fetching OxCGRT US sub-national policy data...\n")

oxcgrt_url <- "https://raw.githubusercontent.com/OxCGRT/covid-policy-dataset/main/data/OxCGRT_compact_subnational_v1.csv"
oxcgrt_raw <- tryCatch(
  fread(oxcgrt_url, showProgress = FALSE),
  error = function(e) {
    cat("Primary OxCGRT URL failed, trying alternate...\n")
    fread("https://raw.githubusercontent.com/OxCGRT/USA-covid-policy/master/data/OxCGRT_US_latest.csv",
          showProgress = FALSE)
  }
)

if ("CountryCode" %in% names(oxcgrt_raw)) {
  oxcgrt_us <- oxcgrt_raw[CountryCode == "USA" & !is.na(RegionCode)]
} else if ("country_code" %in% names(oxcgrt_raw)) {
  oxcgrt_us <- oxcgrt_raw[country_code == "USA" & !is.na(region_code)]
} else {
  oxcgrt_us <- oxcgrt_raw
}

# Extract state abbreviation from region code (e.g., US_NY → NY)
if ("RegionCode" %in% names(oxcgrt_us)) {
  oxcgrt_us[, state := gsub("US_", "", RegionCode)]
  oxcgrt_us[, date := as.Date(as.character(Date), format = "%Y%m%d")]
  si_col <- grep("StringencyIndex", names(oxcgrt_us), value = TRUE)[1]
} else if ("region_code" %in% names(oxcgrt_us)) {
  oxcgrt_us[, state := gsub("US_", "", region_code)]
  oxcgrt_us[, date := as.Date(as.character(date), format = "%Y%m%d")]
  si_col <- grep("stringency_index", names(oxcgrt_us), value = TRUE)[1]
} else {
  si_col <- NULL
}

if (!is.null(si_col) && nrow(oxcgrt_us) > 0) {
  oxcgrt_us[, stringency := as.numeric(get(si_col))]
  oxcgrt_us[, month_date := floor_date(date, "month")]
  stringency_monthly <- oxcgrt_us[state %in% us_states, .(
    stringency = mean(stringency, na.rm = TRUE),
    max_stringency = max(stringency, na.rm = TRUE)
  ), by = .(state, month_date)]
  cat(sprintf("OxCGRT: %d state-months\n", nrow(stringency_monthly)))
} else {
  cat("WARNING: OxCGRT data format unexpected. Using empty placeholder.\n")
  stringency_monthly <- data.table(state = character(), month_date = as.Date(character()),
                                    stringency = numeric(), max_stringency = numeric())
}

## ---- 10. Entity-type panel (for WS6 heterogeneity) ----
cat("Building entity-type panel...\n")

# Build state × entity-type × month panel from provider_monthly
entity_panel <- provider_monthly[entity_type %in% c("1", "2") & is_hcbs == TRUE, .(
  total_paid       = sum(total_paid),
  total_claims     = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers      = uniqueN(billing_npi)
), by = .(state, entity_type, month_date, year, month_num)]

setorder(entity_panel, state, entity_type, month_date)
cat(sprintf("Entity-type panel: %d rows\n", nrow(entity_panel)))

## ---- 11. Merge and Save ----
cat("Merging panel with exit intensity and controls...\n")

# Merge exit intensity (using pre-period as primary, keeping pandemic for robustness)
panel <- merge(panel, state_exits[, .(state, exit_rate_pre, hcbs_exit_rate_pre,
                                       exit_rate_pandemic, hcbs_exit_rate_pandemic,
                                       exit_quartile, high_exit,
                                       predicted_exit_rate, n_active_pre)],
               by = "state", all.x = TRUE)

# PRIMARY exit_rate = pre-period definition
panel[, exit_rate := exit_rate_pre]
panel[, hcbs_exit_rate := hcbs_exit_rate_pre]
panel[, n_active := n_active_pre]

# Merge ACS demographics
panel <- merge(panel, acs_dt[, .(state, population, median_income, poverty_rate,
                                  pct_black, pct_hispanic, median_age)],
               by = "state", all.x = TRUE)

# Merge unemployment
panel <- merge(panel, unemp, by = c("state", "month_date"), all.x = TRUE)

# Merge COVID deaths
panel <- merge(panel, covid_monthly, by = c("state", "month_date"), all.x = TRUE)

# Merge overdose deaths
if (nrow(od_monthly) > 0) {
  panel <- merge(panel, od_monthly, by = c("state", "month_date"), all.x = TRUE)
}

# Merge stringency
if (nrow(stringency_monthly) > 0) {
  panel <- merge(panel, stringency_monthly, by = c("state", "month_date"), all.x = TRUE)
}

# Time variables
panel[, `:=`(
  post_covid = month_date >= "2020-03-01",
  post_arpa  = month_date >= "2021-04-01",
  event_time_covid = as.numeric(difftime(month_date, as.Date("2020-03-01"), units = "days")) / 30.44,
  event_time_arpa  = as.numeric(difftime(month_date, as.Date("2021-04-01"), units = "days")) / 30.44
)]
panel[, event_month_covid := round(event_time_covid)]
panel[, event_month_arpa := round(event_time_arpa)]

# Per-capita measures
panel[, `:=`(
  providers_per_100k = n_providers / (population / 100000),
  claims_per_provider = total_claims / pmax(n_providers, 1),
  beneficiaries_per_provider = total_beneficiaries / pmax(n_providers, 1),
  paid_per_provider = total_paid / pmax(n_providers, 1)
)]

setorder(panel, state, prov_type, month_date)

cat(sprintf("Final panel: %d rows\n", nrow(panel)))

## Save all datasets
saveRDS(panel, file.path(DATA_DIR, "panel.rds"))
saveRDS(state_exits, file.path(DATA_DIR, "state_exits.rds"))
saveRDS(provider_monthly, file.path(DATA_DIR, "provider_monthly.rds"))
saveRDS(entity_panel, file.path(DATA_DIR, "entity_panel.rds"))

cat("\n=== Data acquisition complete ===\n")
