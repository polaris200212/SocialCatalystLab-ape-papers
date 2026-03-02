## ============================================================================
## 01_fetch_data.R — Fetch all data sources
## apep_0467: Priced Out of Care
##
## Sources:
##   1. T-MSIS Parquet (local, pre-downloaded)
##   2. NPPES extract (local, pre-built)
##   3. BLS QCEW state-level wages (pre-fetched via Python/API)
##   4. COVID-19 case data (NYT GitHub)
##   5. FRED state unemployment (API)
##   6. Census ACS state population (API)
## ============================================================================

source("00_packages.R")

## ---- 0. Load .env for API keys ----
env_file <- file.path("..", "..", "..", "..", ".env")
if (file.exists(env_file)) {
  envs <- readLines(env_file, warn = FALSE)
  for (line in envs) {
    line <- trimws(line)
    if (nchar(line) == 0 || startsWith(line, "#")) next
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      key <- trimws(parts[1])
      val <- trimws(paste(parts[-1], collapse = "="))
      val <- gsub("^['\"]|['\"]$", "", val)
      if (Sys.getenv(key) == "") {
        do.call(Sys.setenv, setNames(list(val), key))
      }
    }
  }
  cat("Loaded .env file.\n")
}

## ---- 1. Verify T-MSIS Parquet ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path)
}
cat("T-MSIS Parquet verified.\n")

## ---- 2. Verify NPPES Extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (!file.exists(nppes_path)) {
  stop("NPPES extract not found at: ", nppes_path)
}
cat("NPPES extract verified.\n")

## ---- 3. BLS QCEW State-Level Wages (2019) ----
# Pre-fetched via QCEW API (Python). Industries:
#   624120: Services for Elderly/Disabled (HCBS proxy)
#   445110: Grocery Stores (competing sector)
#   722513: Limited-Service Restaurants (competing sector)
#   493110: General Warehousing (competing sector)
qcew_path <- file.path(DATA, "qcew_state_wages_2019.csv")
if (!file.exists(qcew_path)) {
  stop("QCEW wage data not found at: ", qcew_path, "\n",
       "Run the Python QCEW fetcher first.")
}
cat("QCEW wage data verified.\n")

## ---- 4. Download COVID-19 State Data (NYT) ----
cat("Downloading NYT COVID-19 state data...\n")
covid_path <- file.path(DATA, "covid_states.csv")

if (!file.exists(covid_path)) {
  # NYT COVID data from GitHub
  tryCatch({
    covid_url <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"
    download.file(covid_url, covid_path, mode = "w", quiet = TRUE)
    cat("COVID data downloaded.\n")
  }, error = function(e) {
    # Alternative: JHU CSSE
    cat("NYT unavailable, trying JHU...\n")
    jhu_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    download.file(jhu_url, file.path(DATA, "covid_jhu.csv"), mode = "w", quiet = TRUE)
    cat("JHU COVID data downloaded.\n")
  })
} else {
  cat("COVID data already downloaded.\n")
}

## ---- 5. Fetch FRED State Unemployment Rates ----
cat("Fetching state unemployment rates from FRED...\n")
fred_key <- Sys.getenv("FRED_API_KEY")
ur_path <- file.path(DATA, "state_unemployment.csv")

if (!file.exists(ur_path) && nchar(fred_key) > 0) {
  # State FIPS → FRED series mapping (LAUST[FIPS]0000000003)
  state_fips <- c(
    AL="01",AK="02",AZ="04",AR="05",CA="06",CO="08",CT="09",DE="10",
    DC="11",FL="12",GA="13",HI="15",ID="16",IL="17",IN="18",IA="19",
    KS="20",KY="21",LA="22",ME="23",MD="24",MA="25",MI="26",MN="27",
    MS="28",MO="29",MT="30",NE="31",NV="32",NH="33",NJ="34",NM="35",
    NY="36",NC="37",ND="38",OH="39",OK="40",OR="41",PA="42",RI="44",
    SC="45",SD="46",TN="47",TX="48",UT="49",VT="50",VA="51",WA="53",
    WV="54",WI="55",WY="56"
  )

  ur_list <- list()
  for (st in names(state_fips)) {
    series_id <- paste0("LAUST", state_fips[st], "0000000003")
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2018-01-01&observation_end=2024-12-31",
      series_id, fred_key
    )
    tryCatch({
      resp <- jsonlite::fromJSON(url)
      if (!is.null(resp$observations)) {
        dt <- as.data.table(resp$observations)[, .(date, value)]
        dt[, state := st]
        dt[, value := as.numeric(value)]
        ur_list[[st]] <- dt
      }
    }, error = function(e) {
      cat(sprintf("  FRED failed for %s: %s\n", st, e$message))
    })
  }

  if (length(ur_list) > 0) {
    ur_dt <- rbindlist(ur_list)
    fwrite(ur_dt, ur_path)
    cat(sprintf("State UR: %d observations for %d states\n", nrow(ur_dt), uniqueN(ur_dt$state)))
  }
} else if (file.exists(ur_path)) {
  cat("State UR already downloaded.\n")
} else {
  cat("WARNING: No FRED_API_KEY. State UR will use BLS fallback.\n")
}

## ---- 6. Fetch Census ACS State Population ----
cat("Fetching Census ACS population data...\n")
census_key <- Sys.getenv("CENSUS_API_KEY")
pop_path <- file.path(DATA, "state_population.csv")

if (!file.exists(pop_path) && nchar(census_key) > 0) {
  pop_list <- list()
  for (yr in 2018:2023) {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
      yr, census_key
    )
    tryCatch({
      resp <- jsonlite::fromJSON(url)
      dt <- as.data.table(resp[-1, ])
      setnames(dt, c("population", "state_name", "state_fips"))
      dt[, year := yr]
      dt[, population := as.numeric(population)]
      pop_list[[as.character(yr)]] <- dt
    }, error = function(e) {
      cat(sprintf("  Census failed for %d: %s\n", yr, e$message))
    })
  }

  if (length(pop_list) > 0) {
    pop_dt <- rbindlist(pop_list)
    fwrite(pop_dt, pop_path)
    cat(sprintf("Population: %d state-years\n", nrow(pop_dt)))
  }
} else if (file.exists(pop_path)) {
  cat("Population data already downloaded.\n")
} else {
  cat("WARNING: No CENSUS_API_KEY. Population data unavailable.\n")
}

cat("\n=== All data sources fetched ===\n")
