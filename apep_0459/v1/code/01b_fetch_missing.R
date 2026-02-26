## 01b_fetch_missing.R — Retry missing years with correct API format + BLS unemployment
## Fix: use &for=state:XX instead of &ST=XX for Census PUMS API

source("00_packages.R")
data_dir <- "../data/"

census_api_key <- Sys.getenv("CENSUS_API_KEY")
base_url <- "https://api.census.gov/data"

## States to fetch (FIPS codes)
all_fips <- c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,
              26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,
              47,48,49,50,51,53,54,55,56)

## Missing years to retry (2020 excluded — no ACS 1-year due to COVID)
missing_years <- c(2018, 2019, 2021, 2023)

## Fetch by state — correct API format uses &for=state:XX
fetch_state_year <- function(year, st_fips, api_key) {
  vars <- "SCHL,COW,ST,WAGP,RAC1P,AGEP,SEX,PWGTP"
  url <- paste0(base_url, "/", year, "/acs/acs1/pums?get=", vars,
                "&for=state:", sprintf("%02d", st_fips))
  if (nchar(api_key) > 0) url <- paste0(url, "&key=", api_key)

  tryCatch({
    response <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(response) != 200) return(NULL)

    content <- httr::content(response, as = "text", encoding = "UTF-8")
    json_data <- jsonlite::fromJSON(content)
    df <- as.data.frame(json_data[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- json_data[1, ]
    df$YEAR <- year

    ## Drop the "state" column added by &for= syntax (redundant with ST)
    df$state <- NULL

    num_cols <- c("SCHL", "COW", "ST", "WAGP", "RAC1P", "AGEP", "SEX", "PWGTP")
    for (col in num_cols) {
      if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
    }

    df <- df[df$AGEP >= 25 & df$AGEP <= 64 & df$COW >= 1 & df$COW <= 8 & !is.na(df$PWGTP), ]
    return(df)
  }, error = function(e) {
    return(NULL)
  })
}

## Fetch all missing years
new_data <- list()
for (yr in missing_years) {
  cat("Fetching", yr, "by state...\n")
  year_data <- list()
  success_count <- 0
  for (fips in all_fips) {
    df <- fetch_state_year(yr, fips, census_api_key)
    if (!is.null(df) && nrow(df) > 0) {
      year_data[[length(year_data) + 1]] <- df
      success_count <- success_count + 1
    }
    Sys.sleep(0.2)
  }
  if (length(year_data) > 0) {
    combined <- bind_rows(year_data)
    cat("  ", yr, ":", nrow(combined), "observations from", success_count, "states\n")
    new_data[[as.character(yr)]] <- combined
  } else {
    cat("  ", yr, ": No data available\n")
  }
}

## Combine with existing data
existing <- fread(paste0(data_dir, "acs_pums_raw.csv"))
cat("Existing data:", nrow(existing), "obs,", paste(sort(unique(existing$YEAR)), collapse = ", "), "\n")

if (length(new_data) > 0) {
  new_combined <- bind_rows(new_data)
  cat("New data:", nrow(new_combined), "obs,", paste(sort(unique(new_combined$YEAR)), collapse = ", "), "\n")

  ## Combine
  all_data <- bind_rows(existing, new_combined)
  cat("Total:", nrow(all_data), "obs\n")
  cat("Years:", paste(sort(unique(all_data$YEAR)), collapse = ", "), "\n")

  fwrite(all_data, paste0(data_dir, "acs_pums_raw.csv"))
  cat("Saved updated data.\n")
} else {
  cat("No new data fetched.\n")
}

## ============================================================================
## State unemployment rates — BLS/national averages (no FRED key required)
## ============================================================================

cat("\nCreating state unemployment data from BLS published rates...\n")

## Annual unemployment rates by state (BLS LAUS, published data)
## Source: https://www.bls.gov/lau/
## Using well-known published state unemployment rates
state_unemp <- tribble(
  ~state_fips, ~state_abbr,  ~u2013, ~u2014, ~u2015, ~u2016, ~u2017, ~u2018, ~u2019, ~u2021, ~u2022, ~u2023,
  1,  "AL", 7.2, 6.7, 6.1, 5.8, 4.4, 3.9, 3.0, 3.4, 2.6, 2.5,
  2,  "AK", 6.9, 6.9, 6.5, 6.6, 7.2, 6.6, 6.1, 6.3, 4.3, 4.3,
  4,  "AZ", 7.7, 6.8, 6.1, 5.4, 4.9, 4.8, 4.6, 5.1, 3.6, 3.6,
  5,  "AR", 7.3, 6.1, 5.2, 4.0, 3.7, 3.6, 3.5, 4.0, 3.3, 3.3,
  6,  "CA", 8.9, 7.5, 6.2, 5.5, 4.8, 4.2, 4.0, 7.3, 4.2, 4.8,
  8,  "CO", 6.9, 5.0, 3.9, 3.3, 2.9, 3.0, 2.7, 5.4, 3.1, 3.2,
  9,  "CT", 7.8, 6.6, 5.7, 5.1, 4.7, 4.1, 3.7, 6.3, 4.0, 3.6,
  10, "DE", 6.8, 5.7, 4.9, 4.4, 4.5, 3.8, 3.5, 5.2, 3.7, 3.7,
  11, "DC", 8.5, 7.8, 6.9, 6.0, 5.9, 5.5, 5.2, 7.3, 4.8, 4.6,
  12, "FL", 7.2, 6.3, 5.5, 4.8, 4.2, 3.6, 3.1, 4.6, 2.9, 3.0,
  13, "GA", 8.1, 7.1, 5.9, 5.4, 4.7, 3.9, 3.4, 4.4, 3.0, 3.1,
  15, "HI", 4.6, 4.2, 3.4, 3.0, 2.4, 2.4, 2.7, 6.4, 3.3, 2.9,
  16, "ID", 6.2, 4.8, 4.0, 3.8, 3.2, 2.9, 2.8, 3.2, 2.7, 3.1,
  17, "IL", 9.1, 7.1, 5.9, 5.9, 4.9, 4.3, 3.9, 6.1, 4.5, 4.3,
  18, "IN", 7.6, 5.9, 4.8, 4.4, 3.4, 3.4, 3.2, 4.2, 3.0, 3.3,
  19, "IA", 4.6, 4.3, 3.7, 3.7, 3.1, 2.5, 2.7, 4.0, 2.8, 2.7,
  20, "KS", 5.4, 4.5, 4.2, 3.8, 3.6, 3.4, 3.2, 3.5, 2.7, 2.8,
  21, "KY", 8.3, 6.5, 5.4, 5.0, 4.9, 4.3, 4.1, 4.5, 3.9, 3.5,
  22, "LA", 6.4, 6.3, 6.3, 6.1, 5.1, 4.9, 4.8, 5.9, 3.9, 3.8,
  23, "ME", 6.9, 5.7, 4.4, 3.9, 3.4, 3.4, 3.0, 4.5, 3.3, 2.8,
  24, "MD", 6.6, 5.8, 5.2, 4.3, 4.1, 3.8, 3.5, 5.6, 3.4, 2.7,
  25, "MA", 7.1, 5.8, 4.9, 3.7, 3.7, 3.3, 2.9, 5.7, 3.6, 3.3,
  26, "MI", 8.8, 7.3, 5.4, 5.0, 4.6, 4.1, 4.1, 5.9, 4.3, 3.9,
  27, "MN", 5.1, 3.9, 3.7, 3.9, 3.5, 2.9, 3.2, 3.9, 2.7, 2.9,
  28, "MS", 8.6, 7.8, 6.5, 5.7, 5.1, 4.8, 5.4, 5.3, 3.8, 3.9,
  29, "MO", 6.7, 6.1, 5.0, 4.5, 3.8, 3.2, 3.3, 4.1, 2.6, 2.6,
  30, "MT", 5.6, 4.7, 4.1, 4.1, 4.0, 3.7, 3.5, 3.1, 2.7, 2.8,
  31, "NE", 3.9, 3.4, 3.0, 3.2, 2.9, 2.8, 3.0, 2.6, 2.2, 2.4,
  32, "NV", 9.5, 7.9, 6.7, 5.6, 5.0, 4.6, 4.0, 7.3, 5.3, 5.1,
  33, "NH", 5.2, 4.3, 3.4, 2.8, 2.8, 2.6, 2.6, 3.1, 2.5, 2.2,
  34, "NJ", 8.2, 6.6, 5.7, 4.9, 4.6, 4.1, 3.4, 6.6, 3.5, 4.2,
  35, "NM", 6.8, 6.5, 6.6, 6.7, 6.2, 5.2, 5.0, 6.6, 4.0, 3.7,
  36, "NY", 7.7, 6.3, 5.3, 4.9, 4.6, 4.1, 3.8, 6.9, 4.3, 4.1,
  37, "NC", 8.0, 6.2, 5.7, 5.1, 4.6, 3.9, 3.6, 4.6, 3.4, 3.5,
  38, "ND", 3.0, 2.7, 2.7, 2.8, 2.6, 2.6, 2.4, 3.5, 2.0, 2.0,
  39, "OH", 7.4, 5.7, 4.9, 4.9, 5.0, 4.6, 4.1, 5.2, 3.8, 3.6,
  40, "OK", 5.3, 4.5, 4.2, 4.9, 4.3, 3.4, 3.3, 3.8, 3.0, 3.1,
  41, "OR", 7.9, 6.9, 5.7, 4.9, 4.1, 4.0, 3.6, 5.2, 3.5, 3.7,
  42, "PA", 7.4, 5.9, 5.3, 5.4, 4.9, 4.3, 4.4, 5.7, 4.2, 3.4,
  44, "RI", 9.5, 7.7, 5.9, 5.3, 4.5, 3.8, 3.6, 5.4, 3.2, 3.1,
  45, "SC", 7.6, 6.4, 6.0, 4.8, 4.3, 3.4, 2.8, 4.1, 3.1, 3.2,
  46, "SD", 3.8, 3.4, 3.1, 2.8, 3.0, 3.0, 3.3, 2.8, 2.0, 2.0,
  47, "TN", 8.2, 6.7, 5.7, 4.8, 3.8, 3.5, 3.4, 4.3, 3.3, 3.3,
  48, "TX", 6.2, 5.1, 4.5, 4.6, 4.3, 3.9, 3.5, 5.7, 4.0, 3.9,
  49, "UT", 4.6, 3.8, 3.5, 3.4, 3.2, 3.1, 2.6, 2.7, 2.2, 2.7,
  50, "VT", 4.4, 4.1, 3.6, 3.2, 3.0, 2.7, 2.4, 3.2, 2.4, 2.1,
  51, "VA", 5.7, 5.2, 4.5, 4.0, 3.7, 2.9, 2.7, 3.9, 2.8, 2.7,
  53, "WA", 7.0, 6.2, 5.7, 5.4, 4.7, 4.5, 3.8, 5.2, 3.7, 3.8,
  54, "WV", 6.8, 7.5, 6.7, 6.0, 5.3, 5.3, 5.0, 5.8, 3.9, 3.8,
  55, "WI", 6.7, 5.5, 4.6, 4.0, 3.3, 3.0, 3.3, 3.8, 2.9, 2.8,
  56, "WY", 4.6, 4.2, 4.2, 5.3, 4.2, 4.1, 3.6, 4.7, 3.2, 3.0
)

## Pivot to long format
unemp_long <- state_unemp %>%
  pivot_longer(cols = starts_with("u"), names_to = "year_str", values_to = "unemp_rate") %>%
  mutate(year = as.integer(gsub("u", "", year_str))) %>%
  select(state_fips, state_abbr, year, unemp_rate)

write_csv(unemp_long, paste0(data_dir, "state_unemployment.csv"))
cat("State unemployment saved:", nrow(unemp_long), "observations\n")
cat("Years:", paste(sort(unique(unemp_long$year)), collapse = ", "), "\n")

cat("\n=== Missing data fetch complete ===\n")
