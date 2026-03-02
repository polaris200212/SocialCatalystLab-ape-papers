## 01_fetch_data.R — Fetch ACS PUMS microdata and control variables
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

## ============================================================================
## PART 1: Treatment Variable — State Skills-Based Hiring Adoption Dates
## ============================================================================
## Sources: NCSL, Brookings, NGA, state executive order databases
## See Blair et al. (NBER WP 33220, 2024) for partial validation

treatment_df <- tribble(
  ~state_name,       ~state_fips, ~adopt_year, ~adopt_month, ~policy_type,  ~strength,
  "Maryland",              24,    2022,          3,   "executive",    "strong",
  "Colorado",               8,    2022,          4,   "executive",    "moderate",
  "Tennessee",             47,    2022,          7,   "legislative",  "strong",
  "Utah",                  49,    2022,         12,   "executive",    "strong",
  "Pennsylvania",          42,    2023,          1,   "executive",    "strong",
  "Alaska",                 2,    2023,          2,   "executive",    "moderate",
  "North Carolina",        37,    2023,          3,   "executive",    "moderate",
  "New Jersey",            34,    2023,          4,   "executive",    "moderate",
  "South Dakota",          46,    2023,          4,   "executive",    "moderate",
  "Georgia",               13,    2023,          4,   "legislative",  "moderate",
  "Virginia",              51,    2023,          5,   "executive",    "strong",
  "Ohio",                  39,    2023,          5,   "executive",    "moderate",
  "Florida",               12,    2023,          6,   "legislative",  "strong",
  "Missouri",              29,    2023,          7,   "legislative",  "moderate",
  "California",             6,    2023,          8,   "executive",    "moderate",
  "Minnesota",             27,    2023,         10,   "executive",    "strong",
  "Massachusetts",         25,    2024,          1,   "executive",    "moderate",
  "Washington",            53,    2024,          3,   "executive",    "moderate",
  "Connecticut",            9,    2024,          6,   "legislative",  "moderate",
  "Idaho",                 16,    2024,          6,   "legislative",  "moderate",
  "Louisiana",             22,    2025,          1,   "legislative",  "strong",
  "Indiana",               18,    2025,          1,   "executive",    "moderate"
)

## Assign first_treat year for DiD
## For states adopting Jan-Jun, treatment year = that year
## For states adopting Jul-Dec, treatment year = next year (ACS surveys full year)
treatment_df <- treatment_df %>%
  mutate(first_treat = if_else(adopt_month <= 6, adopt_year, adopt_year + 1))

## Save treatment data
write_csv(treatment_df, paste0(data_dir, "treatment_dates.csv"))
cat("Treatment variable constructed:", nrow(treatment_df), "treated states\n")

## ============================================================================
## PART 2: ACS PUMS Microdata via Census API
## ============================================================================
## Using Census PUMS API for 2012-2023
## Variables: SCHL (education), COW (class of worker), ST (state),
##            WAGP (wages), RAC1P (race), AGEP (age), OCCP (occupation),
##            SEX, PWGTP (person weight)

census_api_key <- Sys.getenv("CENSUS_API_KEY")
base_url <- "https://api.census.gov/data"

## Function to fetch ACS PUMS for a single year
fetch_acs_pums <- function(year, api_key) {
  cat("Fetching ACS PUMS for", year, "...\n")

  ## Variables to request
  vars <- c("SCHL", "COW", "ST", "WAGP", "RAC1P", "AGEP", "SEX",
            "OCCP", "PWGTP", "SOCP")

  ## Build URL
  ## For 2017+, use acs/acs1/pums; for earlier years, use acs/acs1/pums
  url <- paste0(base_url, "/", year, "/acs/acs1/pums",
                "?get=", paste(vars, collapse = ","),
                "&SCHL=20,21,22,23,24",  # HS diploma through doctorate
                "&COW=1,2,3,4,5,6,7,8",  # All classes of worker
                "&AGEP=25:64",           # Prime working age
                ifelse(nchar(api_key) > 0, paste0("&key=", api_key), ""))

  tryCatch({
    ## Try with filter
    response <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      json_data <- jsonlite::fromJSON(content)
      df <- as.data.frame(json_data[-1, ], stringsAsFactors = FALSE)
      colnames(df) <- json_data[1, ]
      df$YEAR <- year
      cat("  Fetched", nrow(df), "observations\n")
      return(df)
    }

    ## Fallback: fetch without filters, filter in R
    cat("  Trying unfiltered fetch...\n")
    url_simple <- paste0(base_url, "/", year, "/acs/acs1/pums",
                  "?get=", paste(vars, collapse = ","),
                  ifelse(nchar(api_key) > 0, paste0("&key=", api_key), ""))

    response <- httr::GET(url_simple, httr::timeout(300))
    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      json_data <- jsonlite::fromJSON(content)
      df <- as.data.frame(json_data[-1, ], stringsAsFactors = FALSE)
      colnames(df) <- json_data[1, ]
      df$YEAR <- year
      cat("  Fetched", nrow(df), "observations (unfiltered)\n")
      return(df)
    }

    cat("  ERROR: Status", httr::status_code(response), "\n")
    return(NULL)
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
    return(NULL)
  })
}

## Alternative: Download PUMS CSV files directly from Census FTP
fetch_pums_csv <- function(year) {
  cat("Downloading PUMS CSV for", year, "...\n")
  url <- paste0("https://www2.census.gov/programs-surveys/acs/data/pums/",
                year, "/1-Year/csv_pus.zip")

  dest_file <- paste0(data_dir, "pums_", year, ".zip")

  if (file.exists(dest_file)) {
    cat("  Already downloaded:", dest_file, "\n")
    return(TRUE)
  }

  tryCatch({
    download.file(url, dest_file, mode = "wb", quiet = TRUE, timeout = 600)
    cat("  Downloaded:", dest_file, "\n")
    return(TRUE)
  }, error = function(e) {
    cat("  Download failed:", conditionMessage(e), "\n")
    return(FALSE)
  })
}

## Strategy: Use Census API for state-level aggregations
## ACS Detailed Table B24041: CLASS OF WORKER BY SEX AND EDUCATIONAL ATTAINMENT
## This gives us exactly what we need without downloading full PUMS

fetch_acs_table <- function(year, api_key) {
  cat("Fetching ACS table B15003 + employment for", year, "...\n")

  ## Use ACS Subject Table S2406 — Industry by Class of Worker
  ## Or B24041 — Class of Worker by Education
  ## Actually, we need a custom cross-tab. Let's use PUMS via tidycensus-style API.

  ## State-level query for employed persons by class of worker
  ## We'll use the ACS detail table approach
  ## Table S2301 has employment by education level, but not class of worker

  ## Best approach: Use ACS microdata API (PUMS endpoint)
  ## Available 2013+

  vars <- "SCHL,COW,ST,WAGP,RAC1P,AGEP,SEX,PWGTP"
  url <- paste0(base_url, "/", year, "/acs/acs1/pums?get=", vars,
                ifelse(nchar(api_key) > 0, paste0("&key=", api_key), ""))

  tryCatch({
    response <- httr::GET(url, httr::timeout(300))

    if (httr::status_code(response) != 200) {
      cat("  HTTP", httr::status_code(response), "for year", year, "\n")
      return(NULL)
    }

    content <- httr::content(response, as = "text", encoding = "UTF-8")
    json_data <- jsonlite::fromJSON(content)
    df <- as.data.frame(json_data[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- json_data[1, ]
    df$YEAR <- year

    ## Convert numeric columns
    num_cols <- c("SCHL", "COW", "ST", "WAGP", "RAC1P", "AGEP", "SEX", "PWGTP")
    for (col in num_cols) {
      if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
    }

    ## Filter to prime working age, employed
    df <- df %>%
      filter(AGEP >= 25, AGEP <= 64,
             COW >= 1, COW <= 8,
             !is.na(PWGTP))

    cat("  Loaded", nrow(df), "person records for", year, "\n")
    return(df)
  }, error = function(e) {
    cat("  Error fetching", year, ":", conditionMessage(e), "\n")
    return(NULL)
  })
}

## Fetch data for all years
years <- 2013:2023  # ACS PUMS API available 2013+
all_data <- list()

for (yr in years) {
  df <- fetch_acs_table(yr, census_api_key)
  if (!is.null(df)) {
    all_data[[as.character(yr)]] <- df
  }
  Sys.sleep(1)  # Rate limiting
}

## Combine all years
if (length(all_data) > 0) {
  pums_raw <- bind_rows(all_data)
  cat("\nTotal observations:", nrow(pums_raw), "\n")
  cat("Years covered:", paste(unique(pums_raw$YEAR), collapse = ", "), "\n")

  ## Save raw data
  fwrite(pums_raw, paste0(data_dir, "acs_pums_raw.csv"))
  cat("Saved to:", paste0(data_dir, "acs_pums_raw.csv"), "\n")
} else {
  cat("WARNING: No PUMS data fetched. Check API key.\n")

  ## Fallback: Use Census summary tables for state-level aggregation
  cat("\nFalling back to Census summary tables...\n")

  ## Fetch S2406: Industry by Class of Worker for each state and year
  ## And S1501: Educational Attainment
  ## These don't give us the exact cross-tab we need, but we can construct
  ## proxies from ACS 1-year PUMS downloads

  ## Download PUMS CSV files directly
  for (yr in years) {
    fetch_pums_csv(yr)
  }
}

## ============================================================================
## PART 3: State-Level Controls from FRED
## ============================================================================

fredr::fredr_set_key(Sys.getenv("FRED_API_KEY"))

## Fetch state unemployment rates
cat("\nFetching state unemployment rates from FRED...\n")

state_fips <- data.frame(
  state_fips = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,
                 26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,
                 47,48,49,50,51,53,54,55,56),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
                 "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
                 "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
                 "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
                 "WV","WI","WY")
)

## FRED series IDs for state unemployment: {STATE}UR
unemp_list <- list()
for (i in 1:nrow(state_fips)) {
  abbr <- state_fips$state_abbr[i]
  series_id <- paste0(abbr, "UR")

  tryCatch({
    df <- fredr::fredr(
      series_id = series_id,
      observation_start = as.Date("2012-01-01"),
      observation_end = as.Date("2024-12-31"),
      frequency = "a"  # Annual average
    )
    if (nrow(df) > 0) {
      df$state_fips <- state_fips$state_fips[i]
      df$state_abbr <- abbr
      unemp_list[[abbr]] <- df
    }
  }, error = function(e) {
    cat("  Error fetching unemployment for", abbr, "\n")
  })
  Sys.sleep(0.5)
}

if (length(unemp_list) > 0) {
  unemp_df <- bind_rows(unemp_list) %>%
    mutate(year = as.integer(format(date, "%Y"))) %>%
    select(state_fips, state_abbr, year, unemp_rate = value)

  write_csv(unemp_df, paste0(data_dir, "state_unemployment.csv"))
  cat("State unemployment data saved:", nrow(unemp_df), "observations\n")
}

cat("\n=== Data fetch complete ===\n")
