## ============================================================================
## 01_fetch_data.R — Download UCR crime data and construct ERPO treatment panel
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_UCR <- file.path("..", "..", "..", "..", "data", "ucr_crime")
dir.create(SHARED_UCR, showWarnings = FALSE, recursive = TRUE)
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## SECTION 1: UCR OFFENSES KNOWN DATA
## ============================================================================

UCR_URL <- "https://dataverse.harvard.edu/api/access/datafile/10899293"
UCR_FILENAME <- "offenses_known_yearly_1960_2023.rds"
ucr_path <- file.path(SHARED_UCR, UCR_FILENAME)

if (!file.exists(ucr_path)) {
  cat("Downloading UCR Offenses Known from Harvard Dataverse (~69 MB)...\n")
  tryCatch({
    download.file(UCR_URL, ucr_path, mode = "wb", quiet = FALSE)
  }, error = function(e) stop("UCR data unavailable: ", e$message,
                               "\nCannot proceed without crime data."))
  cat(sprintf("Saved to: %s\n", ucr_path))
}

cat("Loading UCR Offenses Known...\n")
ucr_raw <- as.data.table(readRDS(ucr_path))
cat(sprintf("UCR: %s rows, %s columns\n",
            format(nrow(ucr_raw), big.mark = ","), ncol(ucr_raw)))
cat(sprintf("Years: %d-%d\n", min(ucr_raw$year), max(ucr_raw$year)))

## ---- Aggregate to state x year ----
## Filter: 12-month reporting agencies only
ucr_state <- ucr_raw[number_of_months_reported == 12, .(
  murder        = sum(actual_murder, na.rm = TRUE),
  rape          = sum(actual_rape_total, na.rm = TRUE),
  robbery       = sum(actual_robbery_total, na.rm = TRUE),
  assault_agg   = sum(actual_assault_aggravated, na.rm = TRUE),
  burglary      = sum(actual_burglary_total, na.rm = TRUE),
  larceny       = sum(actual_theft_total, na.rm = TRUE),
  mvt           = sum(actual_motor_vehicle_theft_total, na.rm = TRUE),
  clr_murder    = sum(total_cleared_murder, na.rm = TRUE),
  population    = sum(population, na.rm = TRUE),
  n_agencies    = uniqueN(ori)
), by = .(state_abb, year)]

## Compute rates per 100,000
rate_vars <- c("murder", "rape", "robbery", "assault_agg",
               "burglary", "larceny", "mvt")
for (v in rate_vars) {
  ucr_state[population > 0, paste0(v, "_rate") := get(v) / population * 100000]
}

## Violent crime composite
ucr_state[, violent_crime := murder + rape + robbery + assault_agg]
ucr_state[population > 0, violent_rate := violent_crime / population * 100000]

## Property crime composite
ucr_state[, property_crime := burglary + larceny + mvt]
ucr_state[population > 0, property_rate := property_crime / population * 100000]

## Murder clearance rate
ucr_state[murder > 0, murder_clearance := clr_murder / murder]

cat(sprintf("State panel: %d state-years, %d states, years %d-%d\n",
            nrow(ucr_state), uniqueN(ucr_state$state_abb),
            min(ucr_state$year), max(ucr_state$year)))

## ============================================================================
## SECTION 2: ERPO TREATMENT CODING
## ============================================================================

## ERPO adoption dates from National ERPO Resource Center (erpo.org)
## Verified against Ballotpedia, Giffords, and Everytown
erpo_laws <- data.table(
  state_abb = c("CT", "IN", "CA", "WA", "OR", "FL", "VT", "RI",
                "MA", "MD", "DE", "IL", "CO", "NJ", "NY",
                "HI", "NV", "NM", "VA", "MN", "MI"),
  erpo_year = c(1999L, 2005L, 2016L, 2016L, 2018L, 2018L, 2018L, 2018L,
                2018L, 2018L, 2018L, 2019L, 2019L, 2019L, 2019L,
                2020L, 2020L, 2020L, 2020L, 2024L, 2024L),
  ## Petitioner type: "le" = law enforcement only; "family" = family + LE
  petitioner_type = c("le", "le", "family", "family", "family", "le", "family", "family",
                      "family", "family", "family", "family", "family", "family", "family",
                      "family", "family", "family", "family", "family", "family")
)

## DC excluded from state-level UCR panel (not in standard state abbreviations)

## Anti-ERPO states (enacted laws restricting/prohibiting ERPOs)
anti_erpo <- c("OK", "TN", "WV", "WY", "MT", "TX")

## Merge treatment to state panel
ucr_state <- merge(ucr_state, erpo_laws, by = "state_abb", all.x = TRUE)

## Treatment indicators
ucr_state[, treated := !is.na(erpo_year)]
ucr_state[, post := (!is.na(erpo_year) & year >= erpo_year)]
ucr_state[, anti_erpo := state_abb %in% anti_erpo]

## For CS-DiD: group variable = adoption year (0 for never-treated)
ucr_state[, g := fifelse(treated, erpo_year, 0L)]

## Relative time
ucr_state[treated == TRUE, rel_time := year - erpo_year]

cat(sprintf("\nERPO treatment: %d treated states, %d never-treated\n",
            uniqueN(ucr_state[treated == TRUE]$state_abb),
            uniqueN(ucr_state[treated == FALSE]$state_abb)))

## ============================================================================
## SECTION 3: COVARIATES (FRED — unemployment rate)
## ============================================================================

## State FIPS mapping for FRED
state_fips <- data.table(
  state_abb = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,12,13,15,16,17,18,19,20,
                            21,22,23,24,25,26,27,28,29,30,31,32,33,34,
                            35,36,37,38,39,40,41,42,44,45,46,47,48,49,
                            50,51,53,54,55,56))
)

## Download state unemployment from FRED
## Load .env if it exists
env_path <- file.path("..", "..", "..", "..", ".env")
if (file.exists(env_path)) {
  env_lines <- readLines(env_path, warn = FALSE)
  env_lines <- env_lines[!grepl("^#|^$", env_lines)]
  for (line in env_lines) {
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      key <- trimws(parts[1])
      val <- trimws(paste(parts[-1], collapse = "="))
      val <- gsub("^['\"]|['\"]$", "", val)
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
}

FRED_KEY <- Sys.getenv("FRED_API_KEY")
if (nchar(FRED_KEY) > 0) {
  cat("Fetching state unemployment rates from FRED...\n")
  unemp_list <- list()
  for (i in seq_len(nrow(state_fips))) {
    st <- state_fips$state_abb[i]
    series_id <- paste0(st, "UR")
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=1990-01-01&frequency=a",
      series_id, FRED_KEY
    )
    tryCatch({
      resp <- jsonlite::fromJSON(url)
      if (!is.null(resp$observations)) {
        dt <- as.data.table(resp$observations)
        dt[, `:=`(state_abb = st,
                  year = as.integer(substr(date, 1, 4)),
                  unemp_rate = as.numeric(value))]
        unemp_list[[st]] <- dt[, .(state_abb, year, unemp_rate)]
      }
    }, error = function(e) {
      message(sprintf("  FRED warning for %s: %s", st, e$message))
    })
  }
  unemp_dt <- rbindlist(unemp_list)
  ucr_state <- merge(ucr_state, unemp_dt, by = c("state_abb", "year"), all.x = TRUE)
  cat(sprintf("Unemployment data merged: %d state-years with data\n",
              sum(!is.na(ucr_state$unemp_rate))))
} else {
  cat("FRED_API_KEY not set — skipping unemployment data.\n")
  ucr_state[, unemp_rate := NA_real_]
}

## ============================================================================
## SECTION 4: RESTRICT SAMPLE & VALIDATE
## ============================================================================

## Analysis sample: 2000-2023 (balanced panel with reasonable coverage)
panel <- ucr_state[year >= 2000 & year <= 2023]

## Flag 2021 coverage gap
panel[, coverage_gap := (year == 2021)]

## Drop non-50-state entities (DC, territories)
non_states <- c("DC", "GU", "PR", "CZ", "VI", "AS", "MP")
panel <- panel[!(state_abb %in% non_states)]

## === DATA VALIDATION (required) ===
## Drop rows with NA or empty state_abb
panel <- panel[!is.na(state_abb) & nchar(state_abb) == 2]
cat(sprintf("Unique states after filtering: %d\n", uniqueN(panel$state_abb)))
stopifnot("Expected 50 states" = uniqueN(panel$state_abb) == 50)
stopifnot("Expected years 2000-2023" = all(2000:2023 %in% unique(panel$year)))
stopifnot("Expected 21 treated states" = uniqueN(panel[treated == TRUE]$state_abb) == 21)
stopifnot("Murder rate available" = sum(!is.na(panel$murder_rate)) > 1000)

cat(sprintf("\n=== Data validation passed ===\n"))
cat(sprintf("Panel: %d state-years, %d states, years %d-%d\n",
            nrow(panel), uniqueN(panel$state_abb),
            min(panel$year), max(panel$year)))
cat(sprintf("Treated states: %d, Never-treated: %d\n",
            uniqueN(panel[treated == TRUE]$state_abb),
            uniqueN(panel[treated == FALSE]$state_abb)))
cat(sprintf("Anti-ERPO states: %d\n",
            uniqueN(panel[anti_erpo == TRUE]$state_abb)))

## ---- Save ----
saveRDS(panel, file.path(DATA, "analysis_panel.rds"))
cat(sprintf("Saved: %s\n", file.path(DATA, "analysis_panel.rds")))
