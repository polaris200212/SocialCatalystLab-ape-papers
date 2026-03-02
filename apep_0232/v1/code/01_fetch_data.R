###############################################################################
# 01_fetch_data.R — Fetch all data from APIs
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

BEA_KEY <- Sys.getenv("BEA_API_KEY")
FRED_KEY <- Sys.getenv("FRED_API_KEY")

# ===========================================================================
# 1. BU-ROGERS-WU MONETARY POLICY SHOCKS (from Fed website)
# ===========================================================================
cat("Fetching BRW monetary policy shocks...\n")

brw_url <- "https://www.federalreserve.gov/econres/feds/files/brw-shock-series.csv"
brw_raw <- read.csv(brw_url, stringsAsFactors = FALSE)

# Parse the BRW data — the CSV has an unusual structure with blank rows
# Use the "updated" columns (left side)
brw <- brw_raw %>%
  select(month, BRW_monthly..updated.) %>%
  rename(month_str = month, brw_monthly = BRW_monthly..updated.) %>%
  filter(month_str != "" & !is.na(month_str)) %>%
  mutate(
    brw_monthly = as.numeric(brw_monthly),
    year = as.integer(gsub("m.*", "", month_str)),
    month_num = as.integer(gsub(".*m", "", month_str)),
    date = as.Date(paste(year, month_num, "01", sep = "-"))
  ) %>%
  filter(!is.na(brw_monthly)) %>%
  select(date, year, month_num, brw_monthly)

cat(sprintf("  BRW shocks: %d months (%s to %s)\n",
            nrow(brw), min(brw$date), max(brw$date)))
cat(sprintf("  Mean: %.4f, SD: %.4f\n", mean(brw$brw_monthly), sd(brw$brw_monthly)))

saveRDS(brw, "../data/brw_shocks.rds")

# ===========================================================================
# 2. STATE NONFARM EMPLOYMENT (FRED, monthly)
# ===========================================================================
cat("Fetching state employment from FRED...\n")

# State FIPS and abbreviations
state_info <- tibble(
  fips = c("01","02","04","05","06","08","09","10","11","12",
           "13","15","16","17","18","19","20","21","22","23",
           "24","25","26","27","28","29","30","31","32","33",
           "34","35","36","37","38","39","40","41","42","44",
           "45","46","47","48","49","50","51","53","54","55","56"),
  abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
           "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
           "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
           "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
           "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  name = c("Alabama","Alaska","Arizona","Arkansas","California","Colorado",
           "Connecticut","Delaware","District of Columbia","Florida",
           "Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
           "Kentucky","Louisiana","Maine","Maryland","Massachusetts",
           "Michigan","Minnesota","Mississippi","Missouri","Montana",
           "Nebraska","Nevada","New Hampshire","New Jersey","New Mexico",
           "New York","North Carolina","North Dakota","Ohio","Oklahoma",
           "Oregon","Pennsylvania","Rhode Island","South Carolina",
           "South Dakota","Tennessee","Texas","Utah","Vermont","Virginia",
           "Washington","West Virginia","Wisconsin","Wyoming")
)

saveRDS(state_info, "../data/state_info.rds")

# FRED series IDs for state nonfarm employment: {ABBR}NA (seasonally adjusted)
# e.g., CANA for California, TXNA for Texas
emp_list <- list()
for (i in 1:nrow(state_info)) {
  abbr <- state_info$abbr[i]
  series_id <- paste0(abbr, "NA")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1990-01-01"),
      observation_end = as.Date("2024-12-01"),
      frequency = "m"
    )
    if (nrow(obs) > 0) {
      emp_list[[abbr]] <- obs %>%
        select(date, value) %>%
        mutate(state_abbr = abbr, emp = value) %>%
        select(date, state_abbr, emp)
    }
  }, error = function(e) {
    cat(sprintf("  Warning: Failed to fetch %s: %s\n", series_id, e$message))
  })

  Sys.sleep(0.15)  # Rate limiting
}

state_emp <- bind_rows(emp_list) %>%
  mutate(
    year = year(date),
    month_num = month(date),
    log_emp = log(emp)
  )

cat(sprintf("  State employment: %d obs, %d states, %s to %s\n",
            nrow(state_emp), n_distinct(state_emp$state_abbr),
            min(state_emp$date), max(state_emp$date)))

saveRDS(state_emp, "../data/state_employment.rds")

# ===========================================================================
# 3. STATE POVERTY RATES (FRED, annual — primary HtM proxy)
# ===========================================================================
cat("Fetching state poverty rates from FRED...\n")

# FRED series: PPAACA{FIPS5}A156NCEN
pov_list <- list()
for (i in 1:nrow(state_info)) {
  fips <- state_info$fips[i]
  fips5 <- paste0(fips, "000")
  series_id <- paste0("PPAACA", fips5, "A156NCEN")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1989-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      pov_list[[fips]] <- obs %>%
        select(date, value) %>%
        mutate(state_fips = fips, poverty_rate = value / 100) %>%
        select(date, state_fips, poverty_rate)
    }
  }, error = function(e) {
    cat(sprintf("  Warning: Failed for FIPS %s: %s\n", fips, e$message))
  })

  Sys.sleep(0.15)
}

state_poverty <- bind_rows(pov_list) %>%
  mutate(year = year(date))

cat(sprintf("  State poverty: %d obs, %d states\n",
            nrow(state_poverty), n_distinct(state_poverty$state_fips)))

saveRDS(state_poverty, "../data/state_poverty.rds")

# ===========================================================================
# 4. SNAP RECIPIENCY RATES (FRED, annual — second HtM proxy)
# ===========================================================================
cat("Fetching SNAP recipiency from FRED...\n")

# FRED series: BR{FIPS5}CAA647NCEN
snap_list <- list()
for (i in 1:nrow(state_info)) {
  fips <- state_info$fips[i]
  fips5 <- paste0(fips, "000")
  series_id <- paste0("BR", fips5, "CAA647NCEN")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1989-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      snap_list[[fips]] <- obs %>%
        select(date, value) %>%
        mutate(state_fips = fips, snap_recipients = value) %>%
        select(date, state_fips, snap_recipients)
    }
  }, error = function(e) NULL)

  Sys.sleep(0.15)
}

state_snap <- bind_rows(snap_list) %>%
  mutate(year = year(date))

cat(sprintf("  SNAP data: %d obs, %d states\n",
            nrow(state_snap), n_distinct(state_snap$state_fips)))

saveRDS(state_snap, "../data/state_snap.rds")

# ===========================================================================
# 5. STATE POPULATION (FRED, annual — for per-capita calculations)
# ===========================================================================
cat("Fetching state population from FRED...\n")

pop_list <- list()
for (i in 1:nrow(state_info)) {
  abbr <- state_info$abbr[i]
  series_id <- paste0(abbr, "POP")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1990-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      pop_list[[abbr]] <- obs %>%
        select(date, value) %>%
        mutate(state_abbr = abbr, population = value * 1000) %>%
        select(date, state_abbr, population)
    }
  }, error = function(e) NULL)

  Sys.sleep(0.15)
}

state_pop <- bind_rows(pop_list) %>%
  mutate(year = year(date))

cat(sprintf("  State population: %d obs, %d states\n",
            nrow(state_pop), n_distinct(state_pop$state_abbr)))

saveRDS(state_pop, "../data/state_population.rds")

# ===========================================================================
# 6. BEA TRANSFER RECEIPTS (annual, for fiscal transfer analysis)
# ===========================================================================
cat("Fetching BEA transfer receipts by state...\n")

fetch_bea <- function(table, line_code, years, geo = "STATE") {
  url <- paste0(
    "https://apps.bea.gov/api/data/",
    "?UserID=", BEA_KEY,
    "&method=GetData",
    "&DataSetName=Regional",
    "&TableName=", table,
    "&LineCode=", line_code,
    "&GeoFips=", geo,
    "&Year=", paste(years, collapse = ","),
    "&ResultFormat=JSON"
  )
  resp <- GET(url)
  data <- content(resp, as = "parsed")
  results <- data$BEAAPI$Results$Data

  if (is.null(results) || length(results) == 0) return(tibble())

  bind_rows(lapply(results, function(r) {
    tibble(
      geo_fips = r$GeoFips %||% NA_character_,
      geo_name = r$GeoName %||% NA_character_,
      year = as.integer(r$TimePeriod %||% NA),
      value = as.numeric(gsub(",", "", r$DataValue %||% NA))
    )
  }))
}

# Transfer categories to fetch
transfer_lines <- list(
  total = "1000",
  govt_transfers = "2000",
  retirement = "2100",
  social_security = "2110",
  medical = "2200",
  medicare = "2210",
  medicaid = "2221",
  income_maint = "2300",
  ssi = "2310",
  eitc = "2320",
  snap = "2330",
  ui_total = "2400",
  ui_state = "2410",
  veterans = "2500",
  education = "2600"
)

years_str <- as.character(2000:2023)

bea_transfers <- list()
for (name in names(transfer_lines)) {
  cat(sprintf("  Fetching %s (line %s)...\n", name, transfer_lines[[name]]))

  # Fetch state-level data
  df_state <- fetch_bea("SAINC35", transfer_lines[[name]], years_str, geo = "STATE")
  # Fetch national totals (needed for Bartik shift-share instrument)
  df_us <- fetch_bea("SAINC35", transfer_lines[[name]], years_str, geo = "US")

  df <- bind_rows(df_state, df_us)

  if (nrow(df) > 0) {
    df$category <- name
    bea_transfers[[name]] <- df
  }

  Sys.sleep(0.5)
}

transfers_all <- bind_rows(bea_transfers) %>%
  filter(!is.na(value))
# NOTE: Keep "United States" rows — needed for Bartik national totals in 02_clean_data.R

cat(sprintf("  BEA transfers: %d obs (%d state, %d national), %d categories\n",
            nrow(transfers_all),
            sum(!grepl("United States", transfers_all$geo_name)),
            sum(grepl("United States", transfers_all$geo_name)),
            n_distinct(transfers_all$category)))

saveRDS(transfers_all, "../data/bea_transfers.rds")

# ===========================================================================
# 7. BEA STATE GDP (annual)
# ===========================================================================
cat("Fetching BEA state GDP...\n")

state_gdp_list <- list()
# Fetch in year chunks to avoid API limits
for (yr_start in seq(2000, 2023, by = 5)) {
  yr_end <- min(yr_start + 4, 2023)
  yrs <- as.character(yr_start:yr_end)

  df <- fetch_bea("SAGDP1", "1", yrs)
  if (nrow(df) > 0) {
    state_gdp_list[[as.character(yr_start)]] <- df
  }
  Sys.sleep(0.5)
}

state_gdp <- bind_rows(state_gdp_list) %>%
  filter(!is.na(value), !grepl("United States|Far West|Great|Mid|New Eng|Plains|Rocky|Southeast|Southwest", geo_name)) %>%
  rename(gdp_millions = value)

cat(sprintf("  State GDP: %d obs, %d states\n",
            nrow(state_gdp), n_distinct(state_gdp$geo_name)))

saveRDS(state_gdp, "../data/state_gdp.rds")

# ===========================================================================
# 8. STATE HOMEOWNERSHIP RATES (FRED, annual)
# ===========================================================================
cat("Fetching state homeownership rates...\n")

home_list <- list()
for (i in 1:nrow(state_info)) {
  abbr <- state_info$abbr[i]
  series_id <- paste0(abbr, "HOWN")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1990-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      home_list[[abbr]] <- obs %>%
        select(date, value) %>%
        mutate(state_abbr = abbr, homeown_rate = value / 100) %>%
        select(date, state_abbr, homeown_rate)
    }
  }, error = function(e) NULL)

  Sys.sleep(0.15)
}

state_homeown <- bind_rows(home_list) %>%
  mutate(year = year(date))

cat(sprintf("  Homeownership: %d obs, %d states\n",
            nrow(state_homeown), n_distinct(state_homeown$state_abbr)))

saveRDS(state_homeown, "../data/state_homeownership.rds")

# ===========================================================================
# 9. FEDERAL FUNDS RATE (for context/controls)
# ===========================================================================
cat("Fetching federal funds rate...\n")

ffr <- fredr(
  series_id = "FEDFUNDS",
  observation_start = as.Date("1990-01-01"),
  observation_end = as.Date("2024-12-01"),
  frequency = "m"
) %>%
  select(date, value) %>%
  rename(ffr = value) %>%
  mutate(year = year(date), month_num = month(date))

saveRDS(ffr, "../data/fed_funds_rate.rds")

cat("\n=== DATA FETCH COMPLETE ===\n")
cat(sprintf("Files saved to: %s\n", normalizePath("../data")))
