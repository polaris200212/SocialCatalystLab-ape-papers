## ============================================================================
## 01_fetch_data.R — Data acquisition
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
##
## Sources:
##   1. T-MSIS Medicaid Provider Spending (local Parquet, 2.74 GB)
##   2. NPPES Bulk Extract (build from CSV or load pre-built)
##   3. FRED API: State minimum wage levels (annual, 2017-2024)
##   4. Census ACS: State population denominators
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. T-MSIS Parquet ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path,
       "\nDownload from: https://opendata.hhs.gov/datasets/medicaid-provider-spending/")
}

cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)
cat(sprintf("Schema: %s\n", paste(names(tmsis_ds), collapse = ", ")))

## ---- 2. NPPES Extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")

if (file.exists(nppes_path)) {
  cat("Loading pre-built NPPES extract...\n")
  nppes <- as.data.table(read_parquet(nppes_path))
} else {
  nppes_csv <- list.files(SHARED_DATA, pattern = "npidata_pfile.*\\.csv$", full.names = TRUE)
  nppes_csv <- nppes_csv[!grepl("header", nppes_csv)]

  if (length(nppes_csv) > 0) {
    cat(sprintf("Building NPPES extract from %s...\n", basename(nppes_csv[1])))
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
    nppes <- fread(nppes_csv[1], select = nppes_cols, showProgress = TRUE, nThread = 4)
    setnames(nppes, c(
      "npi", "entity_type", "org_name", "last_name", "first_name",
      "credential", "gender", "state", "zip", "city",
      "taxonomy_1", "taxonomy_2", "sole_prop", "is_subpart",
      "parent_org_name", "parent_org_tin",
      "enumeration_date", "deactivation_date", "deactivation_reason",
      "reactivation_date", "last_update"
    ))
    date_cols <- c("enumeration_date", "deactivation_date", "reactivation_date", "last_update")
    for (col in date_cols) {
      nppes[, (col) := as.Date(get(col), format = "%m/%d/%Y")]
    }
    nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]
    write_parquet(nppes, nppes_path)
    cat(sprintf("NPPES extract saved: %s providers\n", format(nrow(nppes), big.mark = ",")))
  } else {
    stop("No NPPES data found. Place bulk CSV or nppes_extract.parquet in:\n  ", SHARED_DATA)
  }
}
nppes[, npi := as.character(npi)]
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

## ---- 3. State Minimum Wage Data (FRED API) ----
cat("Fetching state minimum wage data from FRED...\n")
fredr_set_key(Sys.getenv("FRED_API_KEY"))

# State abbreviation to FIPS mapping
state_fips <- data.table(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56")
)

# FRED series: STTMINWG + state abbreviation
# States without state MW (use federal $7.25): AL, LA, MS, SC, TN
states_with_fred <- state_fips[!state_abbr %in% c("AL", "LA", "MS", "SC", "TN")]
states_no_mw <- state_fips[state_abbr %in% c("AL", "LA", "MS", "SC", "TN")]

mw_list <- list()
for (i in seq_len(nrow(states_with_fred))) {
  st <- states_with_fred$state_abbr[i]
  series_id <- paste0("STTMINWG", st)
  tryCatch({
    dat <- fredr(
      series_id = series_id,
      observation_start = as.Date("2017-01-01"),
      observation_end = as.Date("2025-01-01")
    )
    if (nrow(dat) > 0) {
      mw_list[[st]] <- data.table(
        state_abbr = st,
        date = dat$date,
        min_wage = dat$value
      )
    }
    Sys.sleep(0.15)  # Rate limit
  }, error = function(e) {
    cat(sprintf("  Warning: Failed for %s: %s\n", st, e$message))
  })
  if (i %% 10 == 0) cat(sprintf("  Fetched %d/%d states...\n", i, nrow(states_with_fred)))
}

mw_fred <- rbindlist(mw_list)
cat(sprintf("FRED MW data: %d state-year observations\n", nrow(mw_fred)))

# Add federal-minimum states
federal_mw <- 7.25
federal_years <- data.table(date = as.Date(paste0(2017:2025, "-01-01")))
no_mw_rows <- CJ(state_abbr = states_no_mw$state_abbr, date = federal_years$date)
no_mw_rows[, min_wage := federal_mw]
mw_fred <- rbindlist(list(mw_fred, no_mw_rows))

# Extract year
mw_fred[, year := year(date)]

# Join FIPS
mw_fred <- merge(mw_fred, state_fips, by = "state_abbr")

# For states where MW < federal minimum, effective MW = federal
mw_fred[min_wage < federal_mw, min_wage := federal_mw]

# Build annual panel: state × year minimum wage
mw_annual <- mw_fred[year >= 2017 & year <= 2025, .(
  min_wage = max(min_wage)
), by = .(state_abbr, state_fips, year)]
setorder(mw_annual, state_abbr, year)

# Compute year-over-year changes
mw_annual[, mw_change := min_wage - shift(min_wage, 1), by = state_abbr]
mw_annual[, mw_pct_change := mw_change / shift(min_wage, 1), by = state_abbr]

# Identify first MW increase year (2018-2024) for each state
first_increase <- mw_annual[mw_change > 0 & year >= 2018 & year <= 2024,
                            .(first_treat_year = min(year)), by = state_abbr]

# States with no increase = never treated (first_treat = 0 for CS)
all_states <- unique(mw_annual$state_abbr)
treated_states <- first_increase$state_abbr
never_treated <- setdiff(all_states, treated_states)
cat(sprintf("\nTreatment summary:\n"))
cat(sprintf("  Treated states (MW increased 2018-2024): %d\n", length(treated_states)))
cat(sprintf("  Never-treated states (federal minimum throughout): %d\n", length(never_treated)))
cat(sprintf("  Treatment cohorts: %s\n",
            paste(sort(unique(first_increase$first_treat_year)), collapse = ", ")))

# Save MW data
saveRDS(mw_annual, file.path(DATA, "mw_annual.rds"))
saveRDS(first_increase, file.path(DATA, "first_increase.rds"))

## ---- 4. Census ACS — State Population ----
cat("\nFetching state population from Census ACS...\n")
census_key <- Sys.getenv("CENSUS_API_KEY")

pop_list <- list()
for (yr in 2018:2023) {
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
    yr, census_key
  )
  resp <- GET(url)
  if (status_code(resp) == 200) {
    raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    header <- raw[1, ]
    body <- as.data.table(raw[-1, ])
    setnames(body, header)
    body[, year := yr]
    body[, population := as.numeric(B01003_001E)]
    pop_list[[as.character(yr)]] <- body[, .(state_fips = state, state_name = NAME, year, population)]
  } else {
    cat(sprintf("  Warning: ACS %d returned status %d\n", yr, status_code(resp)))
  }
  Sys.sleep(0.3)
}

state_pop <- rbindlist(pop_list)
# Extrapolate 2024 from 2023
pop_2024 <- state_pop[year == 2023][, year := 2024]
state_pop <- rbindlist(list(state_pop, pop_2024))

cat(sprintf("State population data: %d state-year rows\n", nrow(state_pop)))
saveRDS(state_pop, file.path(DATA, "state_population.rds"))

## ---- 5. Build HCBS Provider Panel from T-MSIS ----
cat("\nBuilding HCBS provider panel from T-MSIS...\n")

# NPI → state mapping
npi_state <- nppes[!is.na(state) & state != "",
                   .(npi, state, entity_type, taxonomy_1, enumeration_date, deactivation_date)]

# Strategy: Build state-level panels directly from T-MSIS
# Two passes: one for HCBS (T/H/S codes), one for non-HCBS
# Each pass: get unique NPIs per state × month (for provider count) + spending totals

# NPI → state lookup as named vector for fast matching
npi_state_vec <- setNames(npi_state$state, npi_state$npi)

build_panel_from_tmsis <- function(ds, hcbs_filter, label) {
  cat(sprintf("  Building %s panel from T-MSIS...\n", label))

  if (hcbs_filter) {
    filtered <- ds |>
      filter(substr(HCPCS_CODE, 1, 1) %in% c("T", "H", "S"))
  } else {
    filtered <- ds |>
      filter(!(substr(HCPCS_CODE, 1, 1) %in% c("T", "H", "S")))
  }

  # First: get spending totals by NPI × month (drop HCPCS detail)
  npi_month <- filtered |>
    group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
    summarize(
      total_paid = sum(TOTAL_PAID, na.rm = TRUE),
      total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
      total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
      .groups = "drop"
    ) |>
    collect() |>
    as.data.table()

  setnames(npi_month, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
  cat(sprintf("    NPI-month rows: %s\n", format(nrow(npi_month), big.mark = ",")))

  # Map NPI → state via NPPES
  npi_month[, state := npi_state_vec[billing_npi]]
  npi_month <- npi_month[!is.na(state) & state != ""]
  cat(sprintf("    After state mapping: %s rows\n", format(nrow(npi_month), big.mark = ",")))

  # Parse time
  npi_month[, year := as.integer(substr(CLAIM_FROM_MONTH, 1, 4))]
  npi_month[, month_num := as.integer(substr(CLAIM_FROM_MONTH, 6, 7))]

  # Aggregate to state × month
  panel <- npi_month[, .(
    total_paid = sum(total_paid),
    total_claims = sum(total_claims),
    total_beneficiaries = sum(total_beneficiaries),
    n_providers = uniqueN(billing_npi)
  ), by = .(state, year, month_num, CLAIM_FROM_MONTH)]

  panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
  setorder(panel, state, month_date)

  cat(sprintf("    %s panel: %d rows, %d states, %d months\n",
              label, nrow(panel), uniqueN(panel$state), uniqueN(panel$month_date)))

  rm(npi_month)
  gc()
  return(panel)
}

panel_hcbs <- build_panel_from_tmsis(tmsis_ds, hcbs_filter = TRUE, "HCBS")
panel_nonhcbs <- build_panel_from_tmsis(tmsis_ds, hcbs_filter = FALSE, "Non-HCBS")

saveRDS(panel_hcbs, file.path(DATA, "panel_hcbs_state_month.rds"))
saveRDS(panel_nonhcbs, file.path(DATA, "panel_nonhcbs_state_month.rds"))

cat("\n=== Data acquisition complete ===\n")
