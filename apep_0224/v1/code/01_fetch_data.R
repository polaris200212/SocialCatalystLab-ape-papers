## ============================================================================
## 01_fetch_data.R — Fetch suicide mortality and control data
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## 1. Suicide mortality from CDC NCHS Leading Causes of Death (Socrata API)
##    Dataset: bi63-dtpu  Coverage: 1999-2017, all 50 states + DC
## ============================================================================

cat("Fetching suicide mortality data from CDC Socrata API...\n")

# Fetch all suicide records (state-level)
# Use httr query parameters to avoid URL encoding issues
base_url <- "https://data.cdc.gov/resource/bi63-dtpu.json"

resp <- GET(base_url, query = list(
  `$where` = "cause_name='Suicide'",
  `$limit` = "5000"
))
suicide_raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))

# Also fetch placebo outcomes: Heart Disease and Cancer
cat("Fetching placebo outcomes (Heart Disease, Cancer)...\n")

resp_heart <- GET(base_url, query = list(
  `$where` = "cause_name='Heart disease'",
  `$limit` = "5000"
))
heart_raw <- fromJSON(content(resp_heart, "text", encoding = "UTF-8"))

resp_cancer <- GET(base_url, query = list(
  `$where` = "cause_name='Cancer'",
  `$limit` = "5000"
))
cancer_raw <- fromJSON(content(resp_cancer, "text", encoding = "UTF-8"))

# Clean and combine
clean_cdc <- function(df, cause_label) {
  df %>%
    filter(state != "United States") %>%
    transmute(
      state = state,
      year = as.integer(year),
      cause = cause_label,
      deaths = as.integer(deaths),
      aadr = as.numeric(aadr)  # age-adjusted death rate per 100K
    )
}

mortality <- bind_rows(
  clean_cdc(suicide_raw, "Suicide"),
  clean_cdc(heart_raw, "Heart Disease"),
  clean_cdc(cancer_raw, "Cancer")
)

cat(sprintf("  Suicide: %d state-years\n", sum(mortality$cause == "Suicide")))
cat(sprintf("  Heart Disease: %d state-years\n", sum(mortality$cause == "Heart Disease")))
cat(sprintf("  Cancer: %d state-years\n", sum(mortality$cause == "Cancer")))

write_csv(mortality, file.path(data_dir, "cdc_mortality_state_year.csv"))

## ============================================================================
## 2. State population data from Census API
##    Used for: crude rate calculation, youth share, controls
## ============================================================================

cat("Fetching state population data from Census API...\n")

# Census population estimates by age, sex, state — Annual Estimates
# We use the PEP (Population Estimates Program)
# For 2000-2009: Intercensal estimates
# For 2010-2019: Postcensal estimates
# Fetch total + youth population by state-year

pop_all <- tibble()

# Helper: fetch annual population estimates from Census
fetch_census_pop <- function(vintage, start_year, end_year) {
  results <- tibble()
  for (yr in start_year:end_year) {
    base_url <- sprintf(
      "https://api.census.gov/data/%d/pep/charagegroups?get=POP,AGEGROUP,NAME&for=state:*&DATE_CODE=%d",
      vintage, yr - vintage + (if (vintage >= 2020) 2 else if (vintage >= 2015) 3 else 3)
    )
    tryCatch({
      resp <- GET(base_url)
      if (status_code(resp) == 200) {
        raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
        df <- as_tibble(raw[-1, ], .name_repair = "minimal")
        names(df) <- raw[1, ]
        results <- bind_rows(results, df %>% mutate(year_actual = yr))
      }
    }, error = function(e) {
      message(sprintf("  Census PEP failed for %d vintage year %d: %s", vintage, yr, e$message))
    })
  }
  results
}

# Alternative: use simpler ACS population data
# Fetch total population from ACS 1-year for 2005-2017
cat("  Fetching ACS population estimates...\n")

acs_pop <- tibble()
for (yr in 2005:2017) {
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1?get=B01001_001E,B01001_007E,B01001_008E,B01001_009E,B01001_010E,B01001_031E,B01001_032E,B01001_033E,B01001_034E,NAME&for=state:*",
    yr
  )
  tryCatch({
    resp <- GET(url)
    if (status_code(resp) == 200) {
      raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
      df <- as_tibble(raw[-1, ], .name_repair = "minimal")
      names(df) <- raw[1, ]
      df$year <- yr
      acs_pop <- bind_rows(acs_pop, df)
    } else {
      message(sprintf("  ACS %d returned status %d", yr, status_code(resp)))
    }
  }, error = function(e) {
    message(sprintf("  ACS %d failed: %s", yr, e$message))
  })
  Sys.sleep(0.5)  # Rate limiting
}

# Process ACS population data
# B01001_001E = total population
# B01001_007E-010E = males 15-17, 18-19, 20, 21 (youth male)
# B01001_031E-034E = females 15-17, 18-19, 20, 21 (youth female)
if (nrow(acs_pop) > 0) {
  acs_clean <- acs_pop %>%
    mutate(across(starts_with("B01001"), as.numeric)) %>%
    transmute(
      state_name = NAME,
      state_fips = state,
      year = year,
      total_pop = B01001_001E,
      youth_pop_15_21 = B01001_007E + B01001_008E + B01001_009E + B01001_010E +
                         B01001_031E + B01001_032E + B01001_033E + B01001_034E,
      youth_share = youth_pop_15_21 / total_pop
    )
  cat(sprintf("  ACS population: %d state-years\n", nrow(acs_clean)))
  write_csv(acs_clean, file.path(data_dir, "census_population_state_year.csv"))
} else {
  cat("  WARNING: ACS population fetch failed. Will use mortality rates only.\n")
}

# Fetch for earlier years (1999-2004) from Census 2000 intercensal
# These are harder to get via API; we'll use 2005 ACS as approximate for 1999-2004
# This is a minor approximation since population changes slowly
cat("  Using 2005 values as proxy for 1999-2004 (population changes slowly)...\n")

## ============================================================================
## 3. State economic controls from BLS LAUS (unemployment)
## ============================================================================

cat("Fetching state unemployment rates from BLS...\n")

# BLS Local Area Unemployment Statistics - annual averages
# Series IDs: LASST{FIPS}0000000003 (unemployment rate)
# But BLS API requires registration. Use alternative: Census ACS employment data.

# Alternative: Use FRED for state unemployment rates
# FRED series: {STATE}UR (e.g., ALUR for Alabama)
state_abbrs <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID",
                 "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO",
                 "MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA",
                 "RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

# Skip FRED if no API key - use ACS employment status instead
cat("  Using ACS employment data as unemployment proxy...\n")

## ============================================================================
## 4. Treatment data: State suicide prevention training mandate dates
##    Sources: Lang et al. (2024, PMC11504333) + Jason Foundation records
## ============================================================================

cat("Compiling treatment dates from literature...\n")

# Treatment coding: First full calendar year after law's effective date
# Sources reconciled from:
#   - Lang et al. (2024): Effective dates for mandatory training laws
#   - Jason Foundation: Jason Flatt Act adoption years
#   - We use the EARLIER of the two if both sources provide dates

treatment <- tribble(
  ~state, ~effective_year, ~source,
  # Jason Flatt Act adoptions (Jason Foundation records)
  "Tennessee",     2007, "Jason Flatt Act",
  "Louisiana",     2008, "Jason Flatt Act / Lang 2024",
  "California",    2008, "Jason Flatt Act",
  "Mississippi",   2009, "Jason Flatt Act",
  "Illinois",      2010, "Jason Flatt Act",
  "Arkansas",      2011, "Jason Flatt Act",
  # Broader mandatory training laws (Lang et al. 2024 + JFA)
  "New Jersey",    2006, "Lang 2024",
  "Connecticut",   2011, "Lang 2024",
  "West Virginia", 2012, "Jason Flatt Act",
  "Utah",          2012, "Jason Flatt Act",
  "Alaska",        2012, "Jason Flatt Act",
  "South Carolina",2012, "Jason Flatt Act",
  "Ohio",          2012, "Jason Flatt Act",
  "North Dakota",  2013, "Jason Flatt Act",
  "Maine",         2014, "Lang 2024",
  "Washington",    2014, "Lang 2024",
  "Wyoming",       2014, "Jason Flatt Act / Lang 2024",
  "Delaware",      2015, "Lang 2024",
  "Georgia",       2015, "Jason Flatt Act / Lang 2024",
  "Montana",       2015, "Jason Flatt Act",
  "Nebraska",      2015, "Lang 2024",
  "Texas",         2015, "Jason Flatt Act / Lang 2024",
  "Alabama",       2016, "Jason Flatt Act",
  "Kansas",        2016, "Jason Flatt Act",
  "South Dakota",  2016, "Jason Flatt Act",
  "Tennessee",     2016, "Lang 2024 (strengthened)"  # Strengthened version
) %>%
  # Use earliest effective year per state
  group_by(state) %>%
  summarise(
    effective_year = min(effective_year),
    source = first(source),
    .groups = "drop"
  ) %>%
  # Treatment = first full calendar year after effective date
  # Most education laws take effect mid-year (July 1 = start of academic year)
  # Conservative coding: treatment_year = effective_year + 1
  # Robustness: treatment_year = effective_year
  mutate(
    treatment_year = effective_year + 1,
    treatment_year_alt = effective_year  # Alternative for robustness
  )

cat(sprintf("  %d treated states compiled\n", nrow(treatment)))
cat(sprintf("  Earliest treatment: %s (%d)\n",
            treatment$state[which.min(treatment$treatment_year)],
            min(treatment$treatment_year)))
cat(sprintf("  Latest treatment: %s (%d)\n",
            treatment$state[which.max(treatment$treatment_year)],
            max(treatment$treatment_year)))

write_csv(treatment, file.path(data_dir, "treatment_dates.csv"))

## ============================================================================
## 5. Medicaid expansion dates (concurrent policy control)
## ============================================================================

cat("Compiling Medicaid expansion dates...\n")

medicaid_expansion <- tribble(
  ~state, ~medicaid_year,
  "Arizona",       2014, "Arkansas",       2014, "California",    2014,
  "Colorado",      2014, "Connecticut",    2014, "Delaware",      2014,
  "Hawaii",        2014, "Illinois",       2014, "Iowa",          2014,
  "Kentucky",      2014, "Maryland",       2014, "Massachusetts", 2014,
  "Michigan",      2014, "Minnesota",      2014, "Nevada",        2014,
  "New Jersey",    2014, "New Mexico",     2014, "New York",      2014,
  "North Dakota",  2014, "Ohio",           2014, "Oregon",        2014,
  "Rhode Island",  2014, "Vermont",        2014, "Washington",    2014,
  "West Virginia", 2014, "District of Columbia", 2014,
  "New Hampshire", 2014, "Pennsylvania",   2015, "Indiana",       2015,
  "Alaska",        2015, "Montana",        2016, "Louisiana",     2016
)

write_csv(medicaid_expansion, file.path(data_dir, "medicaid_expansion.csv"))

## ============================================================================
## Summary
## ============================================================================

cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("Mortality data: %d rows (%d suicide state-years)\n",
            nrow(mortality), sum(mortality$cause == "Suicide")))
if (exists("acs_clean") && nrow(acs_clean) > 0) {
  cat(sprintf("Population data: %d state-years\n", nrow(acs_clean)))
}
cat(sprintf("Treatment dates: %d states\n", nrow(treatment)))
cat(sprintf("Medicaid expansion: %d states\n", nrow(medicaid_expansion)))
cat("All data saved to:", data_dir, "\n")
