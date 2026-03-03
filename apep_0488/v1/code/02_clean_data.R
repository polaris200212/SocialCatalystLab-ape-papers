## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 02_clean_data.R: Clean and merge all data sources into analysis panels
## =============================================================================

source("00_packages.R")

## ---------------------------------------------------------------------------
## 1. OPTIC PDMP policy dates → state-level treatment timing
##    OPTIC data ends 2017; supplement with PDAPS for 2017-2019 adopters
## ---------------------------------------------------------------------------
cat("=== Processing policy dates ===\n")

pdmp <- haven::read_dta(file.path(DATA_DIR, "optic_pdmp.dta"))
nal  <- haven::read_dta(file.path(DATA_DIR, "optic_nal.dta"))
gsl  <- haven::read_dta(file.path(DATA_DIR, "optic_gsl.dta"))

# Extract must-access PDMP adoption year from OPTIC
optic_ma <- pdmp %>%
  filter(!is.na(date_prescriber_mustaccess), Must_Access_partial > 0) %>%
  select(state, date_prescriber_mustaccess) %>%
  distinct() %>%
  mutate(must_access_year = as.integer(format(date_prescriber_mustaccess, "%Y")))

cat("OPTIC must-access states:", nrow(optic_ma), "\n")

# Supplement with post-2017 must-access PDMP adoptions from PDAPS
# Source: PDAPS (pdaps.org) and Schuler et al. (2020, NBER WP 27484)
# Horwitz et al. (2021, AEJ: Economic Policy)
supplement_ma <- tribble(
  ~state, ~must_access_year,
  "PA",   2016L,
  "DC",   2016L,
  "MN",   2017L,
  "WI",   2017L,
  "UT",   2017L,
  "SC",   2017L,
  "AR",   2017L,
  "ND",   2017L,
  "WA",   2017L,
  "AZ",   2017L,
  "NE",   2017L,
  "IL",   2018L,
  "MI",   2018L,
  "MD",   2018L,
  "LA",   2018L,
  "MS",   2018L,
  "FL",   2018L,
  "CO",   2019L,
  "AL",   2019L
)

# Combine: OPTIC takes priority where both exist
all_ma <- optic_ma %>%
  select(state, must_access_year) %>%
  bind_rows(supplement_ma %>%
    filter(!(state %in% optic_ma$state)))

cat("Total must-access states:", nrow(all_ma), "\n")
cat("Adoption years:\n")
print(table(all_ma$must_access_year))

# Naloxone access law dates from OPTIC
nal_dates <- nal %>%
  filter(!is.na(date_anynal), any_nal > 0) %>%
  select(state, date_anynal) %>%
  distinct() %>%
  mutate(naloxone_year = as.integer(format(date_anynal, "%Y")))

# Good Samaritan law dates from OPTIC
gsl_dates <- gsl %>%
  filter(!is.na(date_anygsl), anygsl > 0) %>%
  select(state, date_anygsl) %>%
  distinct() %>%
  mutate(gsl_year = as.integer(format(date_anygsl, "%Y")))

# All 51 jurisdictions (50 states + DC)
all_states <- c(state.abb, "DC")
policy_dates <- tibble(state = all_states) %>%
  left_join(all_ma %>% select(state, must_access_year), by = "state") %>%
  left_join(nal_dates %>% select(state, naloxone_year), by = "state") %>%
  left_join(gsl_dates %>% select(state, gsl_year), by = "state")

cat("Never-treated states:", sum(is.na(policy_dates$must_access_year)), "\n")
saveRDS(policy_dates, file.path(DATA_DIR, "policy_dates.rds"))

## ---------------------------------------------------------------------------
## 2. CMS Medicare Part D: Opioid Prescribing by Geography → state × year
## ---------------------------------------------------------------------------
cat("\n=== Processing CMS Part D opioid prescribing data ===\n")

geo_path <- file.path(DATA_DIR, "opioid_rates_geography.rds")
if (!file.exists(geo_path)) stop("CMS opioid geography data not found. Run 01_fetch_data.R first.")

geo_raw <- readRDS(geo_path)

# Filter to state-level, Overall breakout
geo_state <- geo_raw %>%
  filter(Prscrbr_Geo_Lvl == "State", Breakout == "Overall") %>%
  mutate(
    year = as.integer(Year),
    state_fips = sprintf("%02d", as.integer(Prscrbr_Geo_Cd)),
    geo_desc = Prscrbr_Geo_Desc,
    # Convert string columns to numeric
    n_prescribers = as.numeric(Tot_Prscrbrs),
    n_opioid_prescribers = as.numeric(Tot_Opioid_Prscrbrs),
    opioid_claims = as.numeric(Tot_Opioid_Clms),
    total_claims = as.numeric(Tot_Clms),
    opioid_rate = as.numeric(Opioid_Prscrbng_Rate),
    opioid_rate_5y_chg = as.numeric(Opioid_Prscrbng_Rate_5Y_Chg),
    opioid_rate_1y_chg = as.numeric(Opioid_Prscrbng_Rate_1Y_Chg),
    la_opioid_claims = as.numeric(LA_Tot_Opioid_Clms),
    la_opioid_rate = as.numeric(LA_Opioid_Prscrbng_Rate),
    la_opioid_rate_5y_chg = as.numeric(LA_Opioid_Prscrbng_Rate_5Y_Chg),
    la_opioid_rate_1y_chg = as.numeric(LA_Opioid_Prscrbng_Rate_1Y_Chg)
  ) %>%
  select(year, state_fips, geo_desc, n_prescribers, n_opioid_prescribers,
         opioid_claims, total_claims, opioid_rate, opioid_rate_5y_chg,
         opioid_rate_1y_chg, la_opioid_claims, la_opioid_rate,
         la_opioid_rate_5y_chg, la_opioid_rate_1y_chg)

# Map state FIPS to abbreviation
fips_map <- tibble(
  state_fips = sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56)),
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
)

geo_state <- geo_state %>%
  left_join(fips_map, by = "state_fips") %>%
  filter(!is.na(state))

# Compute derived measures
geo_state <- geo_state %>%
  mutate(
    opioid_share = opioid_claims / pmax(total_claims, 1),
    la_share_of_opioid = la_opioid_claims / pmax(opioid_claims, 1),
    opioid_prescriber_share = n_opioid_prescribers / pmax(n_prescribers, 1)
  )

cat("CMS state panel:", nrow(geo_state), "state-years\n")
cat("Years:", paste(sort(unique(geo_state$year)), collapse = ", "), "\n")
cat("States per year:\n")
print(table(geo_state$year))

## ---------------------------------------------------------------------------
## 3. CDC Overdose Mortality: State × year panel
## ---------------------------------------------------------------------------
cat("\n=== Processing CDC overdose mortality data ===\n")

# NCHS Drug Poisoning Mortality by State
nchs_path <- file.path(DATA_DIR, "nchs_drug_overdose_deaths.csv")
if (file.exists(nchs_path)) {
  nchs <- fread(nchs_path)
  cat("  NCHS columns:", paste(head(names(nchs), 8), collapse = ", "), "...\n")
  cat("  NCHS rows:", nrow(nchs), "\n")

  if ("Year" %in% names(nchs)) {
    nchs_clean <- nchs %>%
      filter(!is.na(Year)) %>%
      mutate(year = as.integer(Year))
    saveRDS(nchs_clean, file.path(DATA_DIR, "nchs_processed.rds"))
    cat("  NCHS processed:", nrow(nchs_clean), "rows\n")
  }
}

# VSRR provisional data (2015-2025, monthly 12-month-ending)
vsrr_path <- file.path(DATA_DIR, "vsrr_provisional_overdose.csv")
if (file.exists(vsrr_path)) {
  vsrr <- fread(vsrr_path)
  cat("  VSRR columns:", paste(head(names(vsrr), 8), collapse = ", "), "...\n")

  # Extract state-level annual overdose counts
  # Filter: "Number of Drug Overdose Deaths" indicator, December period (calendar year)
  vsrr_state <- vsrr %>%
    filter(
      Indicator == "Number of Drug Overdose Deaths",
      !is.na(`Data Value`),
      `State Name` != "United States"
    ) %>%
    mutate(
      deaths = as.numeric(gsub(",", "", `Data Value`)),
      year = as.integer(Year),
      month_name = Month,
      state_name = `State Name`
    ) %>%
    filter(month_name == "December", !is.na(deaths)) %>%
    group_by(state_name, year) %>%
    slice_max(order_by = year, n = 1) %>%
    ungroup() %>%
    select(state_name, year, deaths)

  # Map state names to abbreviations
  state_name_map <- tibble(
    state_name = c(state.name, "District of Columbia"),
    state = c(state.abb, "DC")
  )

  vsrr_state <- vsrr_state %>%
    left_join(state_name_map, by = "state_name") %>%
    filter(!is.na(state))

  cat("  VSRR annual mortality:", nrow(vsrr_state), "state-years\n")
  saveRDS(vsrr_state, file.path(DATA_DIR, "vsrr_processed.rds"))
}

## ---------------------------------------------------------------------------
## 4. Census ACS controls
## ---------------------------------------------------------------------------
cat("\n=== Processing Census ACS controls ===\n")

acs_path <- file.path(DATA_DIR, "acs_state_demographics.rds")
if (file.exists(acs_path)) {
  acs_raw <- readRDS(acs_path)

  # ACS data is in long format from tidycensus: variable, estimate, moe
  # Pivot to wide format
  acs_wide <- acs_raw %>%
    select(GEOID, NAME, variable, estimate, year) %>%
    pivot_wider(names_from = variable, values_from = estimate) %>%
    mutate(
      total_pop = as.numeric(total_pop),
      median_income = as.numeric(median_income),
      poverty_count = as.numeric(poverty_count),
      pop_white = as.numeric(white_alone),
      pop_black = as.numeric(black_alone),
      pop_hispanic = as.numeric(hispanic)
    ) %>%
    mutate(
      poverty_rate = poverty_count / pmax(total_pop, 1) * 100,
      pct_white = pop_white / pmax(total_pop, 1) * 100,
      pct_black = pop_black / pmax(total_pop, 1) * 100
    )

  # Map state names to abbreviations
  acs_wide <- acs_wide %>%
    left_join(
      tibble(NAME = c(state.name, "District of Columbia", "Puerto Rico"),
             state = c(state.abb, "DC", "PR")),
      by = "NAME"
    ) %>%
    filter(!is.na(state), state != "PR")

  saveRDS(acs_wide, file.path(DATA_DIR, "acs_processed.rds"))
  cat("  ACS processed:", nrow(acs_wide), "state-years\n")
} else {
  cat("  No ACS data available\n")
}

## ---------------------------------------------------------------------------
## 5. FRED unemployment
## ---------------------------------------------------------------------------
cat("\n=== Processing FRED unemployment ===\n")

fred_path <- file.path(DATA_DIR, "fred_state_unemployment.rds")
if (file.exists(fred_path)) {
  fred_raw <- readRDS(fred_path)

  fred_clean <- fred_raw %>%
    mutate(year = as.integer(format(date, "%Y"))) %>%
    select(state, year, unemp_rate = value)

  saveRDS(fred_clean, file.path(DATA_DIR, "fred_processed.rds"))
  cat("  FRED processed:", nrow(fred_clean), "state-years\n")
} else {
  cat("  No FRED data available\n")
}

## ---------------------------------------------------------------------------
## 6. Build analysis panel: state × year with all merges
## ---------------------------------------------------------------------------
cat("\n=== Building analysis panel ===\n")

# Start with CMS prescribing panel
panel <- geo_state

# Merge policy dates
panel <- panel %>%
  left_join(policy_dates, by = "state") %>%
  mutate(
    # Treatment timing for CS-DiD (0 = never treated)
    first_treat = ifelse(is.na(must_access_year), 0L, must_access_year),
    # Main sample: 2014+ adopters only
    first_treat_main = ifelse(!is.na(must_access_year) & must_access_year >= 2014,
                              must_access_year, 0L),
    # Time-varying policy indicators
    pdmp_active = ifelse(!is.na(must_access_year) & year >= must_access_year, 1L, 0L),
    naloxone_active = ifelse(!is.na(naloxone_year) & year >= naloxone_year, 1L, 0L),
    gsl_active = ifelse(!is.na(gsl_year) & year >= gsl_year, 1L, 0L),
    # Relative time to treatment
    rel_time = ifelse(first_treat > 0, year - first_treat, NA_integer_)
  )

# Merge ACS controls
if (file.exists(file.path(DATA_DIR, "acs_processed.rds"))) {
  acs <- readRDS(file.path(DATA_DIR, "acs_processed.rds"))
  panel <- panel %>%
    left_join(acs %>% select(state, year, total_pop, median_income,
                             poverty_rate, pct_white, pct_black),
              by = c("state", "year"))
}

# Merge FRED unemployment
if (file.exists(file.path(DATA_DIR, "fred_processed.rds"))) {
  fred <- readRDS(file.path(DATA_DIR, "fred_processed.rds"))
  panel <- panel %>%
    left_join(fred, by = c("state", "year"))
}

# Merge mortality
if (file.exists(file.path(DATA_DIR, "vsrr_processed.rds"))) {
  mort <- readRDS(file.path(DATA_DIR, "vsrr_processed.rds"))
  panel <- panel %>%
    left_join(mort %>% select(state, year, overdose_deaths = deaths),
              by = c("state", "year"))
  # Per capita mortality rate
  if ("total_pop" %in% names(panel)) {
    panel <- panel %>%
      mutate(overdose_rate = overdose_deaths / total_pop * 100000)
  }
}

# Final panel diagnostics
cat("Final panel:", nrow(panel), "state-years\n")
cat("States:", n_distinct(panel$state), "\n")
cat("Years:", paste(range(panel$year), collapse = "-"), "\n")
cat("Must-access PDMP treated:", sum(panel$pdmp_active, na.rm = TRUE), "state-years\n")
cat("Must-access states:", n_distinct(panel$state[panel$first_treat > 0]), "\n")
cat("Never-treated states:", n_distinct(panel$state[panel$first_treat == 0]), "\n")

# Save panel
saveRDS(panel, file.path(DATA_DIR, "panel_prescribing.rds"))
cat("\n=== Data cleaning complete. Panel saved. ===\n")
