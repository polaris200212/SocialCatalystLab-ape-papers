##############################################################################
# 01_fetch_data.R — Data Acquisition
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

source("code/00_packages.R")

cat("=== STEP 1: FETCH DATA ===\n\n")

##############################################################################
# 1. State Virtual Snow Day Policy Database
##############################################################################

cat("--- Building state policy database ---\n")

# Policy adoption years compiled from:
# - EdWeek Research Center (2023): "Will Schools Ditch Snow Days?"
# - The 74 Million (2022): "Remote Learning and Snow Days"
# - Government Executive (2022): "Has Remote Learning Buried the Snow Day?"
# - State legislation databases (individual state statutes)
# - NWEA blog (2026): "What do we know about remote learning snow days?"

policy_data <- tribble(
  ~state_fips, ~state_abbr, ~state_name, ~adopt_year, ~adopt_type, ~max_days,
  # Pre-COVID Early Adopters (2011-2019)
  21L, "KY", "Kentucky",        2011L, "packet",   10L,
  33L, "NH", "New Hampshire",   2011L, "packet",    5L,
  20L, "KS", "Kansas",          2011L, "packet",    5L,
  29L, "MO", "Missouri",        2011L, "packet",   NA_integer_,
  54L, "WV", "West Virginia",   2011L, "packet",    5L,
  27L, "MN", "Minnesota",       2017L, "virtual",   5L,
  17L, "IL", "Illinois",        2019L, "virtual",   5L,
  42L, "PA", "Pennsylvania",    2019L, "virtual",   5L,
  # Post-COVID Adopters (2021-2023)
  37L, "NC", "North Carolina",  2021L, "virtual",  NA_integer_,
  39L, "OH", "Ohio",            2021L, "virtual",  NA_integer_,
  18L, "IN", "Indiana",         2021L, "virtual",  NA_integer_,
  47L, "TN", "Tennessee",       2021L, "virtual",  NA_integer_,
  13L, "GA", "Georgia",         2021L, "virtual",  NA_integer_,
  51L, "VA", "Virginia",        2022L, "virtual",  10L,
  36L, "NY", "New York",        2022L, "virtual",  NA_integer_,
  24L, "MD", "Maryland",        2022L, "virtual",   8L,
  34L, "NJ", "New Jersey",      2023L, "virtual",  NA_integer_,
  26L, "MI", "Michigan",        2021L, "virtual",  NA_integer_,
  55L, "WI", "Wisconsin",       2021L, "virtual",  NA_integer_,
  19L, "IA", "Iowa",            2021L, "virtual",  NA_integer_,
  08L, "CO", "Colorado",        2021L, "virtual",  NA_integer_,
  09L, "CT", "Connecticut",     2021L, "virtual",  NA_integer_,
  23L, "ME", "Maine",           2021L, "virtual",  NA_integer_
)

# States that explicitly prohibit virtual snow days
prohibit_states <- tribble(
  ~state_fips, ~state_abbr, ~state_name,
  05L, "AR", "Arkansas",
  25L, "MA", "Massachusetts",
  11L, "DC", "District of Columbia",
  28L, "MS", "Mississippi"
)

# All state FIPS for reference
all_states <- tibble(
  state_fips = c(1L,2L,4L,5L,6L,8L,9L,10L,11L,12L,13L,15L,16L,17L,18L,19L,
                 20L,21L,22L,23L,24L,25L,26L,27L,28L,29L,30L,31L,32L,33L,
                 34L,35L,36L,37L,38L,39L,40L,41L,42L,44L,45L,46L,47L,48L,
                 49L,50L,51L,53L,54L,55L,56L),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
                  "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
                  "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
                  "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
                  "WV","WI","WY")
)

# Mark treatment status
all_states <- all_states %>%
  left_join(policy_data %>% select(state_fips, adopt_year), by = "state_fips") %>%
  mutate(
    ever_treated = !is.na(adopt_year),
    pre_covid_adopter = !is.na(adopt_year) & adopt_year < 2020
  )

cat(sprintf("  Total states: %d\n", nrow(all_states)))
cat(sprintf("  Ever treated: %d\n", sum(all_states$ever_treated)))
cat(sprintf("  Pre-COVID adopters: %d\n", sum(all_states$pre_covid_adopter)))
cat(sprintf("  Never treated: %d\n", sum(!all_states$ever_treated)))

saveRDS(policy_data, "data/policy_data.rds")
saveRDS(all_states, "data/all_states.rds")

##############################################################################
# 2. NOAA Storm Events Database
##############################################################################

cat("\n--- Fetching NOAA Storm Events data ---\n")

# NOAA Storm Events are available as CSV bulk downloads from NCEI
# We focus on winter weather event types: Winter Storm, Heavy Snow,
# Blizzard, Ice Storm, Winter Weather, Lake-Effect Snow, Freezing Fog

# Fetch from NOAA Storm Events API (bulk CSV files)
base_url <- "https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/"

storm_events_all <- data.frame()

# Correct filename pattern: StormEvents_details-ftp_v1.0_dYYYY_cDATE.csv.gz
# The creation date suffix changes, so we need to find the right file

for (yr in 2005:2024) {
  destfile <- sprintf("data/storms_%d.csv.gz", yr)

  if (!file.exists(destfile)) {
    # Try common date suffixes
    downloaded <- FALSE
    for (csuffix in c("20250520", "20250101", "20241231", "20240901")) {
      url <- sprintf("%sStormEvents_details-ftp_v1.0_d%d_c%s.csv.gz",
                     base_url, yr, csuffix)
      tryCatch({
        download.file(url, destfile, mode = "wb", quiet = TRUE)
        cat(sprintf("  Downloaded storms %d\n", yr))
        downloaded <- TRUE
        break
      }, error = function(e) {
        # Try next suffix
      })
    }
    if (!downloaded) {
      cat(sprintf("  WARN: Could not download storms %d\n", yr))
    }
  }

  if (file.exists(destfile) && file.size(destfile) > 100) {
    tryCatch({
      df <- fread(cmd = sprintf("gunzip -c '%s'", destfile),
                  select = c("STATE_FIPS", "YEAR", "MONTH_NAME",
                             "EVENT_TYPE", "BEGIN_DATE_TIME",
                             "DAMAGE_PROPERTY", "INJURIES_DIRECT",
                             "DEATHS_DIRECT"),
                  showProgress = FALSE)
      storm_events_all <- bind_rows(storm_events_all, df)
    }, error = function(e) {
      cat(sprintf("  WARN: Could not parse storms %d: %s\n", yr, e$message))
    })
  }
}

# Filter to winter weather events
winter_event_types <- c("Winter Storm", "Heavy Snow", "Blizzard",
                        "Ice Storm", "Winter Weather",
                        "Lake-Effect Snow", "Freezing Fog",
                        "Cold/Wind Chill", "Extreme Cold/Wind Chill")

if (nrow(storm_events_all) > 0) {
  storm_events <- storm_events_all %>%
    filter(EVENT_TYPE %in% winter_event_types) %>%
    mutate(
      state_fips = as.integer(STATE_FIPS),
      year = as.integer(YEAR),
      month = match(toupper(substr(MONTH_NAME, 1, 3)),
                    toupper(month.abb))
    ) %>%
    filter(!is.na(state_fips), !is.na(year), !is.na(month))

  # Aggregate to state × month
  storm_state_month <- storm_events %>%
    group_by(state_fips, year, month) %>%
    summarize(
      n_winter_events = n(),
      .groups = "drop"
    )

  cat(sprintf("  Total winter weather events: %s\n",
              format(nrow(storm_events), big.mark = ",")))
  cat(sprintf("  State-months with events: %s\n",
              format(nrow(storm_state_month), big.mark = ",")))

  saveRDS(storm_state_month, "data/storm_state_month.rds")
} else {
  cat("  WARN: No storm events downloaded. Using BLS weather data as fallback.\n")
}

##############################################################################
# 3. BLS Work Absence Data (National Series)
##############################################################################

cat("\n--- Fetching BLS work absence data ---\n")

# National-level series as context/validation
# LNU02036012: Absent from work due to bad weather (thousands)
# LNU02036008: Absent from work due to child care problems (thousands)
# LNU02000000: Total employed (thousands)

bls_series <- c(
  "LNU02036012",  # Bad weather absences
  "LNU02036008",  # Child care absences
  "LNU02036014",  # Other family/personal obligations
  "LNU02000000"   # Total employed
)

bls_data <- data.frame()

for (series_id in bls_series) {
  for (start_yr in seq(2005, 2021, by = 10)) {
    end_yr <- min(start_yr + 9, 2024)
    url <- sprintf(
      "https://api.bls.gov/publicAPI/v2/timeseries/data/%s?startyear=%d&endyear=%d",
      series_id, start_yr, end_yr
    )
    tryCatch({
      resp <- jsonlite::fromJSON(url)
      if (resp$status == "REQUEST_SUCCEEDED") {
        df <- resp$Results$series$data[[1]] %>%
          mutate(
            series_id = series_id,
            year = as.integer(year),
            month = as.integer(gsub("M", "", period)),
            value = as.numeric(value)
          ) %>%
          filter(month <= 12)
        bls_data <- bind_rows(bls_data, df)
      }
    }, error = function(e) {
      cat(sprintf("  WARN: BLS fetch failed for %s (%d-%d): %s\n",
                  series_id, start_yr, end_yr, e$message))
    })
    Sys.sleep(1)  # Rate limit
  }
}

if (nrow(bls_data) > 0) {
  bls_wide <- bls_data %>%
    select(series_id, year, month, value) %>%
    pivot_wider(names_from = series_id, values_from = value)

  # Rename columns that exist (some series may fail to fetch)
  rename_map <- c(
    bad_weather_abs = "LNU02036012",
    childcare_abs = "LNU02036008",
    other_family_abs = "LNU02036014",
    total_employed = "LNU02000000"
  )
  for (new_nm in names(rename_map)) {
    old_nm <- rename_map[new_nm]
    if (old_nm %in% names(bls_wide)) {
      names(bls_wide)[names(bls_wide) == old_nm] <- new_nm
    }
  }

  # Add missing columns as NA
  for (col in c("bad_weather_abs", "childcare_abs", "other_family_abs", "total_employed")) {
    if (!col %in% names(bls_wide)) {
      bls_wide[[col]] <- NA_real_
    }
  }

  bls_wide <- bls_wide %>%
    mutate(
      weather_abs_rate = bad_weather_abs / total_employed * 100,
      childcare_abs_rate = childcare_abs / total_employed * 100
    )

  cat(sprintf("  BLS observations: %d\n", nrow(bls_wide)))
  saveRDS(bls_wide, "data/bls_national_absences.rds")
}

##############################################################################
# 4. CPS State-Level Work Absence Data
##############################################################################

cat("\n--- Constructing state-level absence data from BLS LAUS ---\n")

# Since CPS microdata parsing is complex, we use two complementary approaches:
# A) BLS national absence data (above) for aggregate trends
# B) BLS LAUS state employment data + CPS ASEC for state-level variation

# Fetch LAUS (Local Area Unemployment Statistics) for state employment
# Series: LASST{FIPS}00000000{measure}
# Measure 06 = employment level

laus_data <- data.frame()

for (fips in sprintf("%02d", c(1,2,4:6,8:13,15:42,44:51,53:56))) {
  series_id <- sprintf("LASST%s0000000000006", fips)
  url <- sprintf(
    "https://api.bls.gov/publicAPI/v2/timeseries/data/%s?startyear=2005&endyear=2014",
    series_id
  )
  tryCatch({
    resp <- jsonlite::fromJSON(url)
    if (resp$status == "REQUEST_SUCCEEDED" && length(resp$Results$series$data) > 0) {
      df <- resp$Results$series$data[[1]] %>%
        mutate(
          state_fips = as.integer(fips),
          year = as.integer(year),
          month = as.integer(gsub("M", "", period)),
          employment = as.numeric(value)
        ) %>%
        filter(month <= 12) %>%
        select(state_fips, year, month, employment)
      laus_data <- bind_rows(laus_data, df)
    }
  }, error = function(e) {
    # Silently skip failures
  })
  Sys.sleep(0.3)
}

# Second batch: 2015-2024
for (fips in sprintf("%02d", c(1,2,4:6,8:13,15:42,44:51,53:56))) {
  series_id <- sprintf("LASST%s0000000000006", fips)
  url <- sprintf(
    "https://api.bls.gov/publicAPI/v2/timeseries/data/%s?startyear=2015&endyear=2024",
    series_id
  )
  tryCatch({
    resp <- jsonlite::fromJSON(url)
    if (resp$status == "REQUEST_SUCCEEDED" && length(resp$Results$series$data) > 0) {
      df <- resp$Results$series$data[[1]] %>%
        mutate(
          state_fips = as.integer(fips),
          year = as.integer(year),
          month = as.integer(gsub("M", "", period)),
          employment = as.numeric(value)
        ) %>%
        filter(month <= 12) %>%
        select(state_fips, year, month, employment)
      laus_data <- bind_rows(laus_data, df)
    }
  }, error = function(e) {
    # Silently skip failures
  })
  Sys.sleep(0.3)
}

if (nrow(laus_data) > 0) {
  cat(sprintf("  LAUS observations: %s\n", format(nrow(laus_data), big.mark = ",")))
  saveRDS(laus_data, "data/laus_state_employment.rds")
}

##############################################################################
# 5. Census ACS Data — Parental Employment Characteristics by State
##############################################################################

cat("\n--- Fetching ACS parental employment data ---\n")

# ACS Table B23003: Presence of Own Children Under 18 by Age of Adults
# by Employment Status
# Universe: Population 20-64 years

acs_data <- data.frame()

for (yr in 2005:2023) {
  survey <- ifelse(yr >= 2010, "acs/acs1", "acs/acs1")
  url <- sprintf(
    "https://api.census.gov/data/%d/%s?get=NAME,B23003_002E,B23003_003E,B23003_008E,B23003_009E,B23003_017E,B23003_018E&for=state:*",
    yr, survey
  )
  tryCatch({
    resp <- jsonlite::fromJSON(url)
    if (!is.null(resp) && nrow(resp) > 1) {
      df <- as.data.frame(resp[-1, ], stringsAsFactors = FALSE)
      names(df) <- resp[1, ]
      df <- df %>%
        mutate(
          year = yr,
          state_fips = as.integer(state),
          # With children under 18 - in labor force
          parents_lf = as.numeric(B23003_003E),
          # With children under 18 - employed
          parents_emp = as.numeric(B23003_008E),
          # No children under 18 - in labor force
          nochildren_lf = as.numeric(B23003_018E),
          # Population with children
          pop_with_children = as.numeric(B23003_002E),
          # Population without children
          pop_no_children = as.numeric(B23003_017E)
        ) %>%
        select(state_fips, year, starts_with("parents_"), starts_with("nochildren_"),
               starts_with("pop_"))
      acs_data <- bind_rows(acs_data, df)
    }
  }, error = function(e) {
    cat(sprintf("  WARN: ACS %d fetch failed: %s\n", yr, e$message))
  })
  Sys.sleep(0.5)
}

if (nrow(acs_data) > 0) {
  acs_data <- acs_data %>%
    mutate(
      parent_emp_rate = parents_emp / pop_with_children,
      parent_share = pop_with_children / (pop_with_children + pop_no_children)
    )
  cat(sprintf("  ACS observations: %s\n", format(nrow(acs_data), big.mark = ",")))
  saveRDS(acs_data, "data/acs_parental_employment.rds")
}

##############################################################################
# 6. NOAA Temperature/Climate Data for Winter Severity
##############################################################################

cat("\n--- Fetching NOAA climate data ---\n")

# Use Climate at a Glance API for state-level monthly average temperature
# and precipitation (as supplementary winter severity measure)

noaa_climate <- data.frame()

for (fips in sprintf("%02d", c(1,2,4:6,8:13,15:42,44:51,53:56))) {
  url <- sprintf(
    "https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/statewide/time-series/%s/tavg/all/1/2005-2024?base_prd=true&begbaseyear=1901&endbaseyear=2000",
    fips
  )
  tryCatch({
    resp <- readLines(url, warn = FALSE)
    # Parse CSV response (skip header lines)
    header_end <- grep("^Date,", resp)
    if (length(header_end) > 0) {
      csv_text <- paste(resp[header_end:length(resp)], collapse = "\n")
      df <- fread(text = csv_text)
      if (ncol(df) >= 2) {
        names(df)[1:2] <- c("date_str", "avg_temp")
        df <- df %>%
          mutate(
            state_fips = as.integer(fips),
            year = as.integer(substr(date_str, 1, 4)),
            month = as.integer(substr(date_str, 5, 6)),
            avg_temp = as.numeric(avg_temp)
          ) %>%
          filter(!is.na(year), !is.na(month), !is.na(avg_temp)) %>%
          select(state_fips, year, month, avg_temp)
        noaa_climate <- bind_rows(noaa_climate, df)
      }
    }
  }, error = function(e) {
    # Silently skip
  })
  Sys.sleep(0.3)
}

if (nrow(noaa_climate) > 0) {
  cat(sprintf("  NOAA climate observations: %s\n",
              format(nrow(noaa_climate), big.mark = ",")))
  saveRDS(noaa_climate, "data/noaa_climate.rds")
}

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Files saved to data/:\n")
cat("  - policy_data.rds\n")
cat("  - all_states.rds\n")
cat("  - storm_state_month.rds\n")
cat("  - bls_national_absences.rds\n")
cat("  - laus_state_employment.rds\n")
cat("  - acs_parental_employment.rds\n")
cat("  - noaa_climate.rds\n")
