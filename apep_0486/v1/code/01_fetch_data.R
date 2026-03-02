## 01_fetch_data.R — Fetch all data from real sources
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

cat("=== STEP 1: Fetch Vera Institute Incarceration Trends ===\n")

vera_url <- "https://github.com/vera-institute/incarceration-trends/raw/main/incarceration_trends_county.csv"
vera_file <- file.path(DATA_DIR, "vera_incarceration_trends.csv")

if (!file.exists(vera_file)) {
  cat("Downloading Vera data...\n")
  download.file(vera_url, vera_file, mode = "wb", quiet = FALSE)
  cat("Download complete:", file.size(vera_file), "bytes\n")
} else {
  cat("Vera data already exists:", file.size(vera_file), "bytes\n")
}

vera_raw <- fread(vera_file)
cat("Vera raw rows:", nrow(vera_raw), "\n")
cat("Vera year range:", range(vera_raw$year, na.rm = TRUE), "\n")
cat("Vera columns:", ncol(vera_raw), "\n")

# Key variables check
stopifnot("fips" %in% names(vera_raw))
stopifnot("total_jail_pop" %in% names(vera_raw))
stopifnot("black_jail_pop" %in% names(vera_raw))

cat("\n=== STEP 2: Fetch County Health Rankings (Homicides) ===\n")

# Download multiple years to build panel
chr_years <- 2013:2024
chr_files <- c()

for (yr in chr_years) {
  # CHR uses slightly different URL patterns across years
  urls_to_try <- c(
    sprintf("https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data%d.csv", yr),
    sprintf("https://www.countyhealthrankings.org/sites/default/files/media/document/analytic_data%d_0.csv", yr)
  )

  outfile <- file.path(DATA_DIR, sprintf("chr_%d.csv", yr))

  if (!file.exists(outfile)) {
    success <- FALSE
    for (url in urls_to_try) {
      tryCatch({
        download.file(url, outfile, mode = "wb", quiet = TRUE)
        if (file.size(outfile) > 10000) {
          cat(sprintf("CHR %d: downloaded (%.1f MB)\n", yr, file.size(outfile)/1e6))
          success <- TRUE
          break
        } else {
          file.remove(outfile)
        }
      }, error = function(e) {
        if (file.exists(outfile)) file.remove(outfile)
      })
    }
    if (!success) {
      cat(sprintf("CHR %d: NOT AVAILABLE\n", yr))
    }
  } else {
    cat(sprintf("CHR %d: already exists\n", yr))
  }

  if (file.exists(outfile)) chr_files <- c(chr_files, outfile)
}

cat("Downloaded CHR files for", length(chr_files), "years\n")

cat("\n=== STEP 3: Fetch Census ACS Demographics ===\n")

census_key <- Sys.getenv("CENSUS_API_KEY")
if (census_key == "") stop("CENSUS_API_KEY not set in environment")

# ACS 5-year estimates, all counties, key demographic variables
# B01003_001: Total population
# B02001_003: Black population
# B02001_002: White population
# B19013_001: Median household income
# B17001_002: Population below poverty level
# B23025_005: Unemployed
# B23025_003: In labor force

acs_years <- 2012:2022
acs_list <- list()

for (yr in acs_years) {
  cat(sprintf("Fetching ACS %d...\n", yr))

  acs_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,B02001_002E,B02001_003E,B19013_001E,B17001_002E,B23025_005E,B23025_003E&for=county:*&key=%s",
    yr, census_key
  )

  tryCatch({
    resp <- jsonlite::fromJSON(acs_url)
    df <- as.data.frame(resp[-1, ], stringsAsFactors = FALSE)
    names(df) <- resp[1, ]

    df <- df %>%
      mutate(
        year = yr,
        fips = paste0(state, county),
        total_pop_acs = as.numeric(B01003_001E),
        white_pop = as.numeric(B02001_002E),
        black_pop = as.numeric(B02001_003E),
        median_hh_income = as.numeric(B19013_001E),
        poverty_pop = as.numeric(B17001_002E),
        unemployed = as.numeric(B23025_005E),
        labor_force = as.numeric(B23025_003E)
      ) %>%
      select(year, fips, total_pop_acs, white_pop, black_pop,
             median_hh_income, poverty_pop, unemployed, labor_force)

    acs_list[[as.character(yr)]] <- df
    cat(sprintf("  ACS %d: %d counties\n", yr, nrow(df)))

    Sys.sleep(0.5)
  }, error = function(e) {
    cat(sprintf("  ACS %d: FAILED - %s\n", yr, e$message))
  })
}

acs_panel <- bind_rows(acs_list)
cat("ACS panel: ", nrow(acs_panel), "county-years\n")

fwrite(acs_panel, file.path(DATA_DIR, "acs_county_demographics.csv"))

cat("\n=== STEP 4: Fetch FRED State Unemployment Rates ===\n")

fred_key <- Sys.getenv("FRED_API_KEY")
if (fred_key == "") stop("FRED_API_KEY not set in environment")

# State unemployment rate series IDs follow pattern: {STATE}UR
state_fips <- data.frame(
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  stringsAsFactors = FALSE
)

fred_list <- list()
for (i in seq_len(nrow(state_fips))) {
  st <- state_fips$state_abbr[i]
  sf <- state_fips$state_fips[i]
  series_id <- paste0(st, "UR")

  fred_url <- sprintf(
    "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2005-01-01&observation_end=2024-12-31&frequency=a",
    series_id, fred_key
  )

  tryCatch({
    resp <- jsonlite::fromJSON(fred_url)
    obs <- resp$observations
    if (nrow(obs) > 0) {
      obs$state_fips <- sf
      obs$state_abbr <- st
      obs$year <- as.integer(substr(obs$date, 1, 4))
      obs$unemp_rate <- as.numeric(obs$value)
      fred_list[[st]] <- obs[, c("state_fips", "state_abbr", "year", "unemp_rate")]
    }
  }, error = function(e) {
    cat(sprintf("FRED %s: FAILED\n", st))
  })

  Sys.sleep(0.2)
}

fred_panel <- bind_rows(fred_list)
cat("FRED unemployment: ", nrow(fred_panel), "state-years\n")

fwrite(fred_panel, file.path(DATA_DIR, "fred_state_unemployment.csv"))

cat("\n=== STEP 5: Create Progressive DA Treatment File ===\n")

# Treatment coding based on Petersen, Mitchell & Yan (2024) and
# comprehensive media/academic sources
progressive_das <- tribble(
  ~fips,  ~county_name,           ~state, ~da_name,              ~treatment_year,
  "24510", "Baltimore City",       "MD",   "Marilyn Mosby",        2015,
  "17031", "Cook County",          "IL",   "Kim Foxx",             2016,
  "12095", "Orange County",        "FL",   "Aramis Ayala",         2016,
  "48201", "Harris County",        "TX",   "Kim Ogg",              2017,
  "29510", "St. Louis City",       "MO",   "Kimberly Gardner",     2017,
  "12057", "Hillsborough County",  "FL",   "Andrew Warren",        2017,
  "42101", "Philadelphia County",  "PA",   "Larry Krasner",        2018,
  "20209", "Wyandotte County",     "KS",   "Mark Dupree",          2017,
  "36047", "Kings County",         "NY",   "Eric Gonzalez",        2018,
  "29189", "St. Louis County",     "MO",   "Wesley Bell",          2019,
  "25025", "Suffolk County",       "MA",   "Rachael Rollins",      2019,
  "06013", "Contra Costa County",  "CA",   "Diana Becton",         2019,
  "37063", "Durham County",        "NC",   "Satana Deberry",       2019,
  "51013", "Arlington County",     "VA",   "Parisa Dehghani-Tafti",2020,
  "51059", "Fairfax County",       "VA",   "Steve Descano",        2020,
  "51107", "Loudoun County",       "VA",   "Buta Biberaj",         2020,
  "48113", "Dallas County",        "TX",   "John Creuzot",         2019,
  "06075", "San Francisco County", "CA",   "Chesa Boudin",         2020,
  "06037", "Los Angeles County",   "CA",   "George Gascon",        2021,
  "48453", "Travis County",        "TX",   "Jose Garza",           2021,
  "26125", "Oakland County",       "MI",   "Karen McDonald",       2021,
  "41051", "Multnomah County",     "OR",   "Mike Schmidt",         2021,
  "26161", "Washtenaw County",     "MI",   "Eli Savit",            2021,
  "36061", "New York County",      "NY",   "Alvin Bragg",          2022,
  "06001", "Alameda County",       "CA",   "Pamela Price",         2023
)

fwrite(progressive_das, file.path(DATA_DIR, "progressive_da_treatment.csv"))
cat("Treatment file:", nrow(progressive_das), "progressive DA counties\n")
cat("Treatment year range:", range(progressive_das$treatment_year), "\n")
cat("Unique states:", length(unique(progressive_das$state)), "\n")

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Files in data directory:\n")
cat(paste(list.files(DATA_DIR), collapse = "\n"), "\n")
