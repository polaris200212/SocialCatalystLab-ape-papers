## ============================================================================
## 03b_mechanisms.R — BLS OEWS Workforce Evidence (WS3)
## Fetch home health aide employment and wages by state, test scarring
## ============================================================================

source("00_packages.R")

DATA <- "../data"
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

cat("=== WS3: BLS OEWS Workforce Evidence ===\n\n")

## ---- 1. Fetch BLS OEWS data via API ----
bls_key <- Sys.getenv("BLS_API_KEY")

# SOC 31-1120: Home Health and Personal Care Aides
# BLS OEWS series format: OEUS{state_fips}00000031112001 (employment)
# and OEUS{state_fips}00000031112013 (median hourly wage)
# BUT: the OEWS API v2 uses a different endpoint

# Use BLS API v2 for public data
# Series IDs for OEWS annual data:
# Format: OEUS{state_fips}000000{soc_code}{data_type}
# state_fips = 2 digits, soc_code = 311120 (no dash), data_type = 01 (employment), 13 (median hourly wage)

fips_codes <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
            "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
            "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
            "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
            "WV","WI","WY"),
  fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,
                           20,21,22,23,24,25,26,27,28,29,30,31,32,33,
                           34,35,36,37,38,39,40,41,42,44,45,46,47,48,
                           49,50,51,53,54,55,56))
)

# Build series IDs
emp_series <- paste0("OEUS", fips_codes$fips, "00000031112001")
wage_series <- paste0("OEUS", fips_codes$fips, "00000031112013")

all_series <- c(emp_series, wage_series)

# BLS API allows max 50 series per request — split into batches
fetch_bls <- function(series_ids, start_year = 2018, end_year = 2023) {
  results <- list()
  batch_size <- 50

  for (i in seq(1, length(series_ids), batch_size)) {
    batch <- series_ids[i:min(i + batch_size - 1, length(series_ids))]

    body <- list(
      seriesid = batch,
      startyear = as.character(start_year),
      endyear = as.character(end_year)
    )

    # Add API key if available
    if (nchar(bls_key) > 0) {
      body$registrationkey <- bls_key
    }

    resp <- POST(
      "https://api.bls.gov/publicAPI/v2/timeseries/data/",
      body = toJSON(body, auto_unbox = TRUE),
      content_type_json(),
      encode = "raw"
    )

    if (status_code(resp) == 200) {
      parsed <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
      if (parsed$status == "REQUEST_SUCCEEDED" && !is.null(parsed$Results$series)) {
        series_df <- parsed$Results$series
        n_series <- if (is.data.frame(series_df)) nrow(series_df) else length(series_df)
        for (s in seq_len(n_series)) {
          tryCatch({
            sid <- series_df$seriesID[s]
            sdata <- series_df$data[[s]]
            if (!is.null(sdata) && is.data.frame(sdata) && nrow(sdata) > 0) {
              results[[sid]] <- data.table(
                series_id = sid,
                year = as.integer(sdata$year),
                period = sdata$period,
                value = as.numeric(sdata$value)
              )
            }
          }, error = function(e) {
            # Skip problematic series silently
          })
        }
      }
    } else {
      cat(sprintf("  BLS API batch %d returned status %d\n", ceiling(i/batch_size), status_code(resp)))
    }

    Sys.sleep(1)  # Rate limit
  }
  return(results)
}

cat("Fetching BLS OEWS data for SOC 31-1120 (Home Health/Personal Care Aides)...\n")
bls_results <- fetch_bls(all_series)

if (length(bls_results) > 0) {
  bls_dt <- rbindlist(bls_results)

  # Keep only annual data (period = "A01")
  bls_dt <- bls_dt[period == "A01"]

  # Parse series ID to extract state and data type
  bls_dt[, state_fips := substr(series_id, 5, 6)]
  bls_dt[, data_type := substr(series_id, nchar(series_id) - 1, nchar(series_id))]
  bls_dt[, measure := fifelse(data_type == "01", "employment", "median_wage")]

  # Map FIPS to state abbreviation
  bls_dt <- merge(bls_dt, fips_codes, by.x = "state_fips", by.y = "fips", all.x = TRUE)
  bls_dt <- bls_dt[!is.na(state)]

  cat(sprintf("BLS OEWS data: %d observations, %d states, years %d-%d\n",
              nrow(bls_dt), uniqueN(bls_dt$state),
              min(bls_dt$year), max(bls_dt$year)))

  # Reshape to wide
  bls_wide <- dcast(bls_dt, state + year ~ measure, value.var = "value")

  cat("\nSample data (first 10 rows):\n")
  print(head(bls_wide, 10))

  ## ---- 2. Merge with stringency and analyze ----
  bls_wide <- merge(bls_wide, state_treatment[, .(state, peak_stringency)],
                    by = "state", all.x = TRUE)
  bls_wide[, peak_stringency_std := peak_stringency / 100]

  # Create pre/post indicator
  bls_wide[, post := as.integer(year >= 2020)]

  # Normalize to 2019 baseline
  base_2019 <- bls_wide[year == 2019, .(state, emp_2019 = employment, wage_2019 = median_wage)]
  bls_wide <- merge(bls_wide, base_2019, by = "state", all.x = TRUE)
  bls_wide[, emp_index := employment / emp_2019 * 100]
  bls_wide[, wage_index := median_wage / wage_2019 * 100]

  # Log employment
  bls_wide[, log_emp := log(employment + 1)]

  # Median split for plotting
  med_str <- median(state_treatment$peak_stringency, na.rm = TRUE)
  bls_wide[, str_group := fifelse(peak_stringency > med_str, "High Stringency", "Low Stringency")]

  ## ---- 3. DiD regressions on workforce ----
  cat("\n=== Workforce DiD: Employment of Home Health Aides ===\n")

  if (sum(!is.na(bls_wide$employment)) > 10) {
    # DiD: log employment ~ stringency × post | state + year
    m_emp_did <- feols(
      log_emp ~ peak_stringency_std:post | factor(state) + factor(year),
      data = bls_wide,
      cluster = ~state
    )
    cat("DiD: Log Employment of Home Health Aides\n")
    summary(m_emp_did)

    # DiD: median wage ~ stringency × post
    if (sum(!is.na(bls_wide$median_wage)) > 10) {
      m_wage_did <- feols(
        median_wage ~ peak_stringency_std:post | factor(state) + factor(year),
        data = bls_wide,
        cluster = ~state
      )
      cat("\nDiD: Median Wage of Home Health Aides\n")
      summary(m_wage_did)
    } else {
      m_wage_did <- NULL
      cat("Insufficient wage data for DiD\n")
    }
  } else {
    m_emp_did <- NULL
    m_wage_did <- NULL
    cat("Insufficient employment data for DiD\n")
  }

  ## ---- 4. Create trends for plotting ----
  workforce_trends <- bls_wide[, .(
    mean_emp = mean(employment, na.rm = TRUE),
    mean_wage = mean(median_wage, na.rm = TRUE),
    mean_emp_index = mean(emp_index, na.rm = TRUE),
    n_states = .N
  ), by = .(str_group, year)]

  cat("\nWorkforce trends by stringency group:\n")
  print(workforce_trends)

  ## ---- 5. Save results ----
  workforce_results <- list(
    bls_wide = bls_wide,
    workforce_trends = workforce_trends,
    m_emp_did = m_emp_did,
    m_wage_did = m_wage_did
  )

  saveRDS(workforce_results, file.path(DATA, "workforce_results.rds"))
  cat("\n=== Workforce analysis complete ===\n")

} else {
  cat("WARNING: No BLS data retrieved. Creating empty results.\n")
  # Create empty workforce results so downstream scripts don't fail
  workforce_results <- list(
    bls_wide = data.table(),
    workforce_trends = data.table(),
    m_emp_did = NULL,
    m_wage_did = NULL
  )
  saveRDS(workforce_results, file.path(DATA, "workforce_results.rds"))
}
