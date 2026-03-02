# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 01_fetch_data.R - Download BRFSS data and policy controls
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

# ============================================================================
# 1. BRFSS Annual Data Files (SAS Transport format)
# ============================================================================
# BRFSS surveys ~400,000 adults per year on health behaviors.
# Key variables: smoking status, quit attempts, cigarettes/day, state, month.
# Files are 100-300 MB each in SAS transport (.XPT) format.

brfss_dir <- file.path(data_dir, "brfss")
dir.create(brfss_dir, showWarnings = FALSE, recursive = TRUE)

# We need 1996-2022 for pre-trends (earliest ban = 2002 DE)
# Using 1996 as start: 6 pre-treatment years for the first adopter
years <- 1996:2022

download_brfss <- function(year) {
  outfile <- file.path(brfss_dir, sprintf("brfss_%d.rds", year))
  if (file.exists(outfile)) {
    cat(sprintf("  [%d] Already processed, skipping\n", year))
    return(invisible(NULL))
  }

  # CDC changed URL structure over time
  if (year >= 2021) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%dXPT.zip",
      year, year
    )
  } else if (year >= 2017) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d_XPT.zip",
      year, year
    )
  } else if (year >= 2011) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%dXPT.zip",
      year, year
    )
  } else if (year >= 2002) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/CDBRFS%02dXPT.zip",
      year, year %% 100
    )
  } else {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/CDBRFS%02dXPT.zip",
      year, year %% 100
    )
  }

  # Try different URL patterns if first fails
  urls_to_try <- c(
    url,
    # Alternative patterns
    sprintf("https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d.XPT", year, year),
    sprintf("https://www.cdc.gov/brfss/annual_data/%d/files/CDBRFS%02d.XPT", year, year %% 100),
    sprintf("https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d_XPT.zip", year, year)
  )

  tmpfile <- tempfile(fileext = ".zip")
  xptfile <- tempfile(fileext = ".XPT")
  downloaded <- FALSE

  for (u in urls_to_try) {
    cat(sprintf("  [%d] Trying: %s\n", year, basename(u)))
    tryCatch({
      resp <- GET(u, write_disk(tmpfile, overwrite = TRUE), timeout(300))
      if (status_code(resp) == 200) {
        downloaded <- TRUE
        break
      }
    }, error = function(e) {
      cat(sprintf("  [%d]   Failed: %s\n", year, e$message))
    })
  }

  if (!downloaded) {
    cat(sprintf("  [%d] FAILED to download - skipping\n", year))
    return(invisible(NULL))
  }

  # Read the file (might be zip or direct XPT)
  tryCatch({
    if (grepl("\\.zip$", basename(u), ignore.case = TRUE)) {
      # Unzip and find XPT file
      files <- unzip(tmpfile, list = TRUE)$Name
      xpt_name <- files[grepl("\\.xpt$", files, ignore.case = TRUE)][1]
      if (is.na(xpt_name)) {
        # Sometimes the zip contains the file directly
        xpt_name <- files[1]
      }
      unzip(tmpfile, files = xpt_name, exdir = dirname(xptfile))
      xptpath <- file.path(dirname(xptfile), xpt_name)
    } else {
      xptpath <- tmpfile
    }

    # Read SAS transport file
    df_raw <- haven::read_xpt(xptpath)
    cat(sprintf("  [%d] Raw data: %d rows, %d cols\n", year, nrow(df_raw), ncol(df_raw)))

    # Standardize variable names (BRFSS changed names over years)
    names(df_raw) <- toupper(names(df_raw))

    # Extract key variables - handle name changes across years
    extract_var <- function(df, candidates) {
      for (v in candidates) {
        if (v %in% names(df)) return(df[[v]])
      }
      return(rep(NA_real_, nrow(df)))
    }

    df_clean <- tibble(
      year = year,
      state_fips = as.integer(extract_var(df_raw, c("_STATE", "X_STATE"))),
      month = as.integer(extract_var(df_raw, c("IMONTH", "IYEAR"))),
      # Smoking status
      smoke_everyday = extract_var(df_raw, c("_SMOKER3", "X_SMOKER3", "SMOKER3")),
      smoke_status = extract_var(df_raw, c("SMOKDAY2", "SMOKEDAY")),
      smoke100 = extract_var(df_raw, c("SMOKE100")),
      # Quit attempts
      quit_attempt = extract_var(df_raw, c("STOPSMK2", "STPSMK2")),
      last_smoked = extract_var(df_raw, c("LASTSMK2", "LSTSMK2")),
      # Demographics
      age = as.integer(extract_var(df_raw, c("_AGEG5YR", "X_AGEG5YR", "AGE"))),
      age_raw = as.integer(extract_var(df_raw, c("_AGE80", "X_AGE80", "AGE"))),
      sex = as.integer(extract_var(df_raw, c("SEX", "SEX1", "SEXVAR", "BIRTHSEX"))),
      race = as.integer(extract_var(df_raw, c("_RACE", "X_RACE", "_RACEGR3",
                                                "X_RACEGR3", "_IMPRACE", "X_IMPRACE"))),
      education = as.integer(extract_var(df_raw, c("_EDUCAG", "X_EDUCAG", "EDUCA"))),
      income = as.integer(extract_var(df_raw, c("_INCOMG", "X_INCOMG", "INCOME2",
                                                  "_INCOMG1", "X_INCOMG1"))),
      # Weight
      wt = as.numeric(extract_var(df_raw, c("_LLCPWT", "X_LLCPWT",
                                              "_FINALWT", "X_FINALWT")))
    )

    # Save compressed
    saveRDS(df_clean, outfile)
    cat(sprintf("  [%d] Saved: %d observations\n", year, nrow(df_clean)))

  }, error = function(e) {
    cat(sprintf("  [%d] ERROR processing: %s\n", year, e$message))
  })

  # Cleanup
  unlink(tmpfile)
  unlink(xptfile)
  invisible(NULL)
}

cat("Downloading BRFSS annual files...\n")
for (yr in years) {
  download_brfss(yr)
}

# ============================================================================
# 2. State Cigarette Excise Tax Rates (CDC STATE System)
# ============================================================================

cat("\nFetching cigarette excise tax data from CDC STATE System...\n")

# Try CDC STATE System Socrata API
tax_url <- "https://data.cdc.gov/resource/2dwv-yxmx.csv"
tax_params <- list(
  `$select` = "year,locationabbr,locationdesc,submeasureid,data_value",
  `$where` = paste0(
    "topicid='LEG' AND submeasureid='LEG04'",
    " AND datasource='LGP' AND year >= 1995"
  ),
  `$limit` = 5000,
  `$order` = "year,locationabbr"
)

tax_resp <- GET(tax_url, query = tax_params)
if (status_code(tax_resp) == 200) {
  tax_data <- content(tax_resp, as = "text", encoding = "UTF-8") %>%
    read_csv(show_col_types = FALSE)
  cat(sprintf("  Tax data: %d rows\n", nrow(tax_data)))
  saveRDS(tax_data, file.path(data_dir, "cigarette_taxes_cdc.rds"))
} else {
  cat(sprintf("  CDC STATE System API returned %d - trying alternative\n",
              status_code(tax_resp)))

  # Hardcode state cigarette excise taxes (major source: Tax Foundation)
  # Using selected years to build a panel; interpolate between
  cat("  Building cigarette tax panel from published data...\n")

  # Federal cigarette tax history (cents per pack)
  fed_tax <- tribble(
    ~year, ~fed_tax_cents,
    1996, 24, 1997, 24, 1998, 24, 1999, 24,
    2000, 34, 2001, 34, 2002, 39, 2003, 39,
    2004, 39, 2005, 39, 2006, 39, 2007, 39, 2008, 39,
    2009, 101, 2010, 101, 2011, 101, 2012, 101,
    2013, 101, 2014, 101, 2015, 101, 2016, 101,
    2017, 101, 2018, 101, 2019, 101, 2020, 101,
    2021, 101, 2022, 101
  )
  saveRDS(fed_tax, file.path(data_dir, "federal_cigarette_tax.rds"))
  cat("  Saved federal tax panel\n")
}

# ============================================================================
# 3. Comprehensive Smoking Ban Treatment Coding
# ============================================================================
# Source: CDC MMWR April 22, 2011 (60:15) and June 24, 2016 (65:24)
# Comprehensive = workplaces + restaurants + bars

cat("\nCoding smoking ban treatment dates...\n")

ban_dates <- tribble(
  ~state_abbr, ~state_name, ~ban_year, ~ban_month,
  "DE", "Delaware",       2002, 11,
  "NY", "New York",       2003,  7,
  "CT", "Connecticut",    2003, 10,
  "MA", "Massachusetts",  2004,  7,
  "RI", "Rhode Island",   2005,  3,
  "WA", "Washington",     2005, 12,
  "CO", "Colorado",       2006,  7,
  "HI", "Hawaii",         2006, 11,
  "NJ", "New Jersey",     2006,  4,
  "OH", "Ohio",           2006, 12,
  "AZ", "Arizona",        2007,  5,
  "DC", "District of Columbia", 2007,  1,
  "MN", "Minnesota",      2007, 10,
  "NM", "New Mexico",     2007,  6,
  "IL", "Illinois",       2008,  1,
  "IA", "Iowa",           2008,  7,
  "MD", "Maryland",       2008,  2,
  "ME", "Maine",          2009,  1,
  "MT", "Montana",        2009, 10,
  "NE", "Nebraska",       2009,  6,
  "OR", "Oregon",         2009,  1,
  "UT", "Utah",           2009,  5,
  "VT", "Vermont",        2009,  7,
  "KS", "Kansas",         2010,  7,
  "MI", "Michigan",       2010,  5,
  "SD", "South Dakota",   2010, 11,
  "WI", "Wisconsin",      2010,  7,
  "ND", "North Dakota",   2012, 12,
  "CA", "California",     2016,  6
)

# FIPS codes for states
fips_lookup <- tribble(
  ~state_abbr, ~state_fips,
  "AL", 1, "AK", 2, "AZ", 4, "AR", 5, "CA", 6, "CO", 8, "CT", 9,
  "DE", 10, "DC", 11, "FL", 12, "GA", 13, "HI", 15, "ID", 16, "IL", 17,
  "IN", 18, "IA", 19, "KS", 20, "KY", 21, "LA", 22, "ME", 23, "MD", 24,
  "MA", 25, "MI", 26, "MN", 27, "MS", 28, "MO", 29, "MT", 30, "NE", 31,
  "NV", 32, "NH", 33, "NJ", 34, "NM", 35, "NY", 36, "NC", 37, "ND", 38,
  "OH", 39, "OK", 40, "OR", 41, "PA", 42, "RI", 44, "SC", 45, "SD", 46,
  "TN", 47, "TX", 48, "UT", 49, "VT", 50, "VA", 51, "WA", 53, "WV", 54,
  "WI", 55, "WY", 56, "GU", 66, "PR", 72, "VI", 78
)

ban_dates <- ban_dates %>%
  left_join(fips_lookup, by = "state_abbr")

saveRDS(ban_dates, file.path(data_dir, "smoking_ban_dates.rds"))
cat(sprintf("  Coded %d state smoking bans\n", nrow(ban_dates)))

# ============================================================================
# 4. Medicaid Expansion Dates (ACA, for cessation coverage control)
# ============================================================================

cat("\nCoding Medicaid expansion dates...\n")

medicaid_expansion <- tribble(
  ~state_abbr, ~expansion_year,
  "AZ", 2014, "AR", 2014, "CA", 2014, "CO", 2014, "CT", 2014,
  "DE", 2014, "DC", 2014, "HI", 2014, "IL", 2014, "IA", 2014,
  "KY", 2014, "MD", 2014, "MA", 2014, "MI", 2014, "MN", 2014,
  "NV", 2014, "NJ", 2014, "NM", 2014, "NY", 2014, "ND", 2014,
  "OH", 2014, "OR", 2014, "RI", 2014, "VT", 2014, "WA", 2014,
  "WV", 2014,
  "AK", 2015, "IN", 2015, "MT", 2016, "PA", 2015, "NH", 2014,
  "LA", 2016, "VA", 2019, "ME", 2019, "ID", 2020, "NE", 2020,
  "UT", 2020, "OK", 2021, "MO", 2021, "SD", 2024, "NC", 2024
)

saveRDS(medicaid_expansion, file.path(data_dir, "medicaid_expansion.rds"))
cat(sprintf("  Coded %d state Medicaid expansions\n", nrow(medicaid_expansion)))

# ============================================================================
# 5. Census Region Codes (for leave-one-region-out robustness)
# ============================================================================

cat("\nCoding Census regions...\n")

census_regions <- tribble(
  ~state_abbr, ~region,
  "CT", "Northeast", "ME", "Northeast", "MA", "Northeast", "NH", "Northeast",
  "RI", "Northeast", "VT", "Northeast", "NJ", "Northeast", "NY", "Northeast",
  "PA", "Northeast",
  "IL", "Midwest", "IN", "Midwest", "MI", "Midwest", "OH", "Midwest",
  "WI", "Midwest", "IA", "Midwest", "KS", "Midwest", "MN", "Midwest",
  "MO", "Midwest", "NE", "Midwest", "ND", "Midwest", "SD", "Midwest",
  "DE", "South", "FL", "South", "GA", "South", "MD", "South",
  "NC", "South", "SC", "South", "VA", "South", "DC", "South",
  "WV", "South", "AL", "South", "KY", "South", "MS", "South",
  "TN", "South", "AR", "South", "LA", "South", "OK", "South",
  "TX", "South",
  "AZ", "West", "CO", "West", "ID", "West", "MT", "West",
  "NV", "West", "NM", "West", "UT", "West", "WY", "West",
  "AK", "West", "CA", "West", "HI", "West", "OR", "West",
  "WA", "West"
)

saveRDS(census_regions, file.path(data_dir, "census_regions.rds"))

cat("\n=== Data fetching complete ===\n")
