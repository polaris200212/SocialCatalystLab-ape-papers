## ============================================================
## 01_fetch_data.R
## Fetch all data from APIs: CDC overdose, Census ACS covariates,
## PDMP mandate dates, state adjacency matrix
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ============================================================
## 1. CDC VSRR Provisional Drug Overdose Deaths (2015-2024)
##    Source: data.cdc.gov/resource/xkb8-kh2a
## ============================================================

cat("Fetching CDC VSRR provisional overdose data...\n")

indicators <- c(
  "Number of Drug Overdose Deaths",
  "Opioids (T40.0-T40.4,T40.6)",
  "Natural & semi-synthetic opioids (T40.2)",
  "Heroin (T40.1)",
  "Synthetic opioids, excl. methadone (T40.4)",
  "Cocaine (T40.5)",
  "Psychostimulants with abuse potential (T43.6)",
  "Methadone (T40.3)"
)

vsrr_all <- list()

for (ind in indicators) {
  cat("  Fetching:", ind, "\n")

  # Get December 12-month-ending for each year (= annual total)
  url <- paste0(
    "https://data.cdc.gov/resource/xkb8-kh2a.json?",
    "$limit=50000&",
    "month=December&",
    "period=12%20month-ending&",
    "indicator=", URLencode(ind, reserved = TRUE)
  )

  resp <- GET(url)
  if (status_code(resp) == 200) {
    dat <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    if (nrow(dat) > 0) {
      vsrr_all[[ind]] <- dat
      cat("    Got", nrow(dat), "rows\n")
    }
  }
  Sys.sleep(0.5)
}

vsrr_df <- bind_rows(vsrr_all) %>%
  select(state, state_name, year, indicator, data_value, predicted_value) %>%
  mutate(
    year = as.integer(year),
    deaths = as.numeric(data_value),
    predicted_deaths = as.numeric(predicted_value)
  ) %>%
  filter(!is.na(deaths), year >= 2015, year <= 2023) %>%
  # Use predicted_value where available (adjusts for incomplete reporting)
  mutate(deaths_adj = coalesce(predicted_deaths, deaths))

cat("VSRR data:", nrow(vsrr_df), "rows,", n_distinct(vsrr_df$state), "states\n")

write_csv(vsrr_df, paste0(data_dir, "cdc_vsrr_overdose.csv"))

## ============================================================
## 2. CDC NCHS Drug Poisoning Mortality (1999-2015)
##    Source: data.cdc.gov/resource/jx6g-fdh6
## ============================================================

cat("\nFetching CDC NCHS drug poisoning mortality data...\n")

nchs_url <- paste0(
  "https://data.cdc.gov/resource/jx6g-fdh6.json?",
  "$limit=50000&",
  "sex=Both%20Sexes&",
  "age=All%20Ages&",
  "race_hispanic_origin=All%20Races-All%20Origins"
)

resp_nchs <- GET(nchs_url)
nchs_df <- fromJSON(content(resp_nchs, "text", encoding = "UTF-8"))

nchs_df <- nchs_df %>%
  select(state, year, deaths, population, age_adjusted_rate) %>%
  mutate(
    year = as.integer(year),
    deaths = as.numeric(deaths),
    population = as.numeric(population),
    age_adjusted_rate = as.numeric(age_adjusted_rate)
  ) %>%
  filter(!is.na(deaths), year >= 1999, year <= 2015)

cat("NCHS data:", nrow(nchs_df), "rows\n")
write_csv(nchs_df, paste0(data_dir, "cdc_nchs_drug_poisoning.csv"))

## ============================================================
## 3. State Population from Census ACS (2006-2023)
## ============================================================

cat("\nFetching Census ACS state demographics...\n")

census_key <- Sys.getenv("CENSUS_API_KEY")

# ACS variables:
# B01003_001E = total population
# B19013_001E = median household income
# B15003_022E = bachelor's degree holders (25+)
# B15003_001E = total 25+ population (for education share)
# B27010_001E = civilian noninst pop for insurance
# B27010_002E = with health insurance
# B02001_002E = white alone
# B02001_001E = total for race denominator
# B01001_020E..039E = ages 25-54 (need specific cells)
# B23025_005E = unemployed
# B23025_003E = in labor force

acs_years <- 2006:2023
acs_vars <- "B01003_001E,B19013_001E,B15003_022E,B15003_001E,B27010_001E,B27010_002E,B02001_002E,B02001_001E,B23025_005E,B23025_003E"

acs_all <- list()

for (yr in acs_years) {
  # Use ACS 1-year estimates (available for all states)
  survey <- "acs1"
  base_url <- paste0("https://api.census.gov/data/", yr, "/acs/", survey)

  url <- paste0(base_url, "?get=NAME,", acs_vars, "&for=state:*")
  if (nchar(census_key) > 0) {
    url <- paste0(url, "&key=", census_key)
  }

  resp <- tryCatch(GET(url), error = function(e) NULL)

  if (!is.null(resp) && status_code(resp) == 200) {
    raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
    names(df) <- raw[1, ]
    df$year <- yr
    acs_all[[as.character(yr)]] <- df
    cat("  ", yr, ":", nrow(df), "states\n")
  } else {
    cat("  ", yr, ": FAILED (trying ACS 5-year)\n")
    # Fallback to 5-year estimates
    base_url5 <- paste0("https://api.census.gov/data/", yr, "/acs/acs5")
    url5 <- paste0(base_url5, "?get=NAME,", acs_vars, "&for=state:*")
    if (nchar(census_key) > 0) url5 <- paste0(url5, "&key=", census_key)
    resp5 <- tryCatch(GET(url5), error = function(e) NULL)
    if (!is.null(resp5) && status_code(resp5) == 200) {
      raw <- fromJSON(content(resp5, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      df$year <- yr
      acs_all[[as.character(yr)]] <- df
      cat("    ACS 5-year OK:", nrow(df), "states\n")
    }
  }
  Sys.sleep(0.3)
}

acs_df <- bind_rows(acs_all) %>%
  rename(
    state_name = NAME,
    state_fips = state,
    pop = B01003_001E,
    median_hh_income = B19013_001E,
    bachelors = B15003_022E,
    pop_25plus = B15003_001E,
    civ_noninst = B27010_001E,
    with_insurance = B27010_002E,
    white_alone = B02001_002E,
    total_race = B02001_001E,
    unemployed = B23025_005E,
    labor_force = B23025_003E
  ) %>%
  mutate(across(c(pop, median_hh_income, bachelors, pop_25plus,
                  civ_noninst, with_insurance, white_alone, total_race,
                  unemployed, labor_force), as.numeric)) %>%
  mutate(
    year = as.integer(year),
    pct_bachelors = bachelors / pop_25plus * 100,
    pct_white = white_alone / total_race * 100,
    pct_uninsured = (civ_noninst - with_insurance) / civ_noninst * 100,
    unemployment_rate = unemployed / labor_force * 100,
    log_pop = log(pop),
    log_income = log(median_hh_income)
  )

cat("ACS data:", nrow(acs_df), "state-years\n")
write_csv(acs_df, paste0(data_dir, "census_acs_covariates.csv"))

## ============================================================
## 4. PDMP Must-Query Mandate Effective Dates
##    Sources: Buchmueller & Carey (2018, AEJ:EP),
##    Wen et al. (2019, Health Affairs), PDAPS.org,
##    Mallatt (2022), Horwitz et al. (2018)
## ============================================================

cat("\nCoding PDMP must-query mandate dates...\n")

# Must-query (comprehensive use) mandate effective dates
# These are the dates when prescribers were REQUIRED to check the PDMP
# before prescribing controlled substances (Schedule II+)
# Sources cross-referenced: PDAPS, Buchmueller & Carey (2018 Table 1),
# Wen et al. (2019 Appendix A2), NAMSDL/PDMP TTAC

pdmp_dates <- tribble(
  ~state, ~state_name, ~must_query_year,
  "KY", "Kentucky", 2012,
  "NM", "New Mexico", 2012,
  "TN", "Tennessee", 2013,
  "NY", "New York", 2013,
  "WV", "West Virginia", 2013,
  "OH", "Ohio", 2015,
  "CT", "Connecticut", 2015,
  "MA", "Massachusetts", 2016,
  "NV", "Nevada", 2016,
  "PA", "Pennsylvania", 2016,
  "VA", "Virginia", 2016,
  "IN", "Indiana", 2016,
  "NJ", "New Jersey", 2017,
  "AR", "Arkansas", 2017,
  "AZ", "Arizona", 2017,
  "SC", "South Carolina", 2017,
  "WI", "Wisconsin", 2017,
  "OK", "Oklahoma", 2017,
  "RI", "Rhode Island", 2017,
  "MD", "Maryland", 2018,
  "MN", "Minnesota", 2018,
  "CO", "Colorado", 2018,
  "VT", "Vermont", 2018,
  "ME", "Maine", 2018,
  "LA", "Louisiana", 2018,
  "NC", "North Carolina", 2018,
  "UT", "Utah", 2018,
  "DC", "District of Columbia", 2018,
  "AL", "Alabama", 2019,
  "IL", "Illinois", 2019,
  "HI", "Hawaii", 2019,
  "DE", "Delaware", 2019,
  "GA", "Georgia", 2019,
  "MI", "Michigan", 2019,
  "IA", "Iowa", 2020,
  "FL", "Florida", 2020,
  "NH", "New Hampshire", 2020,
  "SD", "South Dakota", 2020,
  "ID", "Idaho", 2020,
  "TX", "Texas", 2020,
  "WA", "Washington", 2020,
  "MS", "Mississippi", 2021,
  "ND", "North Dakota", 2021,
  "CA", "California", 2022,
  "WY", "Wyoming", 2022
  # States without must-query as of 2023: KS, MO, MT, NE, OR, AK
)

write_csv(pdmp_dates, paste0(data_dir, "pdmp_must_query_dates.csv"))
cat("PDMP dates coded:", nrow(pdmp_dates), "states\n")

## ============================================================
## 5. State Adjacency Matrix (contiguous states)
## ============================================================

cat("\nCoding state adjacency matrix...\n")

# US state adjacency list (contiguous 48 + DC)
# Each entry: state -> list of neighboring states
adj_list <- list(
  AL = c("FL", "GA", "MS", "TN"),
  AZ = c("CA", "CO", "NM", "NV", "UT"),
  AR = c("LA", "MO", "MS", "OK", "TN", "TX"),
  CA = c("AZ", "NV", "OR"),
  CO = c("AZ", "KS", "NE", "NM", "OK", "UT", "WY"),
  CT = c("MA", "NY", "RI"),
  DE = c("MD", "NJ", "PA"),
  DC = c("MD", "VA"),
  FL = c("AL", "GA"),
  GA = c("AL", "FL", "NC", "SC", "TN"),
  ID = c("MT", "NV", "OR", "UT", "WA", "WY"),
  IL = c("IN", "IA", "KY", "MO", "WI"),
  IN = c("IL", "KY", "MI", "OH"),
  IA = c("IL", "MN", "MO", "NE", "SD", "WI"),
  KS = c("CO", "MO", "NE", "OK"),
  KY = c("IL", "IN", "MO", "OH", "TN", "VA", "WV"),
  LA = c("AR", "MS", "TX"),
  ME = c("NH"),
  MD = c("DC", "DE", "PA", "VA", "WV"),
  MA = c("CT", "NH", "NY", "RI", "VT"),
  MI = c("IN", "OH", "WI"),
  MN = c("IA", "ND", "SD", "WI"),
  MS = c("AL", "AR", "LA", "TN"),
  MO = c("AR", "IL", "IA", "KS", "KY", "NE", "OK", "TN"),
  MT = c("ID", "ND", "SD", "WY"),
  NE = c("CO", "IA", "KS", "MO", "SD", "WY"),
  NV = c("AZ", "CA", "ID", "OR", "UT"),
  NH = c("MA", "ME", "VT"),
  NJ = c("DE", "NY", "PA"),
  NM = c("AZ", "CO", "OK", "TX", "UT"),
  NY = c("CT", "MA", "NJ", "PA", "VT"),
  NC = c("GA", "SC", "TN", "VA"),
  ND = c("MN", "MT", "SD"),
  OH = c("IN", "KY", "MI", "PA", "WV"),
  OK = c("AR", "CO", "KS", "MO", "NM", "TX"),
  OR = c("CA", "ID", "NV", "WA"),
  PA = c("DE", "MD", "NJ", "NY", "OH", "WV"),
  RI = c("CT", "MA"),
  SC = c("GA", "NC"),
  SD = c("IA", "MN", "MT", "ND", "NE", "WY"),
  TN = c("AL", "AR", "GA", "KY", "MO", "MS", "NC", "VA"),
  TX = c("AR", "LA", "NM", "OK"),
  UT = c("AZ", "CO", "ID", "NM", "NV", "WY"),
  VT = c("MA", "NH", "NY"),
  VA = c("DC", "KY", "MD", "NC", "TN", "WV"),
  WA = c("ID", "OR"),
  WV = c("KY", "MD", "OH", "PA", "VA"),
  WI = c("IA", "IL", "MI", "MN"),
  WY = c("CO", "ID", "MT", "NE", "SD", "UT")
)

# Convert to edge list
adj_edges <- map_dfr(names(adj_list), function(st) {
  tibble(state = st, neighbor = adj_list[[st]])
})

write_csv(adj_edges, paste0(data_dir, "state_adjacency.csv"))
cat("Adjacency edges:", nrow(adj_edges), "\n")

## ============================================================
## 6. Concurrent Opioid Policies (for robustness controls)
## ============================================================

cat("\nCoding concurrent opioid policies...\n")

# Key concurrent policies that might confound PDMP effects:
# (a) Naloxone Access Laws (NALs)
# (b) Good Samaritan Laws (GSLs)
# (c) Medicaid Expansion under ACA
# (d) Pill Mill Laws
# Sources: PDAPS, NCSL, KFF

concurrent <- tribble(
  ~state, ~naloxone_year, ~good_samaritan_year, ~medicaid_expansion_year,
  "AL", 2016, 2016, NA,
  "AK", 2016, 2015, 2015,
  "AZ", 2015, 2017, 2014,
  "AR", 2015, 2017, 2014,
  "CA", 2014, 2013, 2014,
  "CO", 2013, 2012, 2014,
  "CT", 2012, 2011, 2014,
  "DE", 2014, 2013, 2014,
  "DC", 2013, 2013, 2014,
  "FL", 2015, NA, NA,
  "GA", 2014, 2014, NA,
  "HI", 2016, 2016, 2014,
  "ID", 2015, 2016, 2020,
  "IL", 2010, 2012, 2014,
  "IN", 2015, 2015, 2015,
  "IA", 2016, 2017, 2014,
  "KS", 2017, NA, NA,
  "KY", 2013, 2013, 2014,
  "LA", 2014, 2014, 2016,
  "ME", 2014, 2019, 2019,
  "MD", 2013, 2013, 2014,
  "MA", 2012, 2012, 2014,
  "MI", 2014, 2017, 2014,
  "MN", 2014, 2014, 2014,
  "MS", 2016, 2016, NA,
  "MO", 2017, NA, NA,
  "MT", 2013, 2007, 2016,
  "NE", 2015, 2017, 2020,
  "NV", 2015, 2015, 2014,
  "NH", 2015, 2015, 2014,
  "NJ", 2013, 2013, 2014,
  "NM", 2001, 2007, 2014,
  "NY", 2006, 2011, 2014,
  "NC", 2013, 2013, 2016,
  "ND", 2015, 2015, 2014,
  "OH", 2014, 2016, 2014,
  "OK", 2014, 2015, NA,
  "OR", 2013, 2013, 2014,
  "PA", 2014, 2014, 2015,
  "RI", 2012, 2012, 2014,
  "SC", 2015, 2015, NA,
  "SD", 2016, 2018, NA,
  "TN", 2014, 2015, NA,
  "TX", 2015, NA, NA,
  "UT", 2014, 2014, 2020,
  "VT", 2013, 2013, 2014,
  "VA", 2013, 2015, 2019,
  "WA", 2010, 2010, 2014,
  "WV", 2015, 2015, 2014,
  "WI", 2014, 2014, NA,
  "WY", 2017, NA, NA
)

write_csv(concurrent, paste0(data_dir, "concurrent_opioid_policies.csv"))
cat("Concurrent policies coded for", nrow(concurrent), "states\n")

## ============================================================
## 7. State FIPS codes crosswalk
## ============================================================

cat("\nCreating state FIPS crosswalk...\n")

fips_xwalk <- tibble(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","District of Columbia","Florida",
                 "Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa",
                 "Kansas","Kentucky","Louisiana","Maine","Maryland",
                 "Massachusetts","Michigan","Minnesota","Mississippi","Missouri",
                 "Montana","Nebraska","Nevada","New Hampshire","New Jersey",
                 "New Mexico","New York","North Carolina","North Dakota","Ohio",
                 "Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas","Utah",
                 "Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming")
)

write_csv(fips_xwalk, paste0(data_dir, "state_fips_crosswalk.csv"))

cat("\n==============================\n")
cat("Data fetching complete.\n")
cat("Files saved to:", data_dir, "\n")
cat("==============================\n")
