###############################################################################
# 01_fetch_data.R
# Fetch data from Census ACS, LEHD/LODES, and OZ designation lists
# APEP-0445
###############################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

cat("=== Step 1: Fetch ACS 2011-2015 tract-level poverty data ===\n")

# We need poverty rate for ALL US tracts from ACS 2011-2015 (the vintage used for OZ)
# B17001_002E = population below poverty level
# B17001_001E = total population for poverty determination
# B19113_001E = median family income

states <- c(sprintf("%02d", 1:56))
states <- states[!states %in% c("03", "07", "14", "43", "52")]  # Remove non-states

acs_list <- list()
for (st in states) {
  url <- paste0(
    "https://api.census.gov/data/2015/acs/acs5?get=",
    "B17001_002E,B17001_001E,B19113_001E,B01003_001E,NAME",
    "&for=tract:*&in=state:", st
  )
  tryCatch({
    resp <- httr::GET(url)
    if (httr::status_code(resp) == 200) {
      raw <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      acs_list[[st]] <- df
      cat("  State", st, ":", nrow(df), "tracts\n")
    } else {
      cat("  State", st, ": HTTP", httr::status_code(resp), "\n")
    }
  }, error = function(e) {
    cat("  State", st, ": ERROR -", e$message, "\n")
  })
  Sys.sleep(0.3)  # Rate limiting
}

acs_raw <- bind_rows(acs_list)
cat("\nTotal tracts fetched:", nrow(acs_raw), "\n")

# Create GEOID (state + county + tract)
acs_raw <- acs_raw %>%
  mutate(
    geoid = paste0(state, county, tract),
    pov_below = as.numeric(B17001_002E),
    pov_total = as.numeric(B17001_001E),
    median_fam_income = as.numeric(B19113_001E),
    total_pop = as.numeric(B01003_001E)
  ) %>%
  filter(pov_total > 0) %>%
  mutate(poverty_rate = pov_below / pov_total * 100)

saveRDS(acs_raw, file.path(data_dir, "acs_tract_poverty.rds"))
cat("ACS data saved:", nrow(acs_raw), "tracts with poverty data\n\n")


cat("=== Step 2: Fetch OZ designation list ===\n")

# The CDFI Fund OZ list — try multiple sources
oz_url <- "https://www.cdfifund.gov/sites/cdfi/files/2024-01/QOZ-List.xlsx"
oz_file <- file.path(data_dir, "oz_list.xlsx")

tryCatch({
  download.file(oz_url, oz_file, mode = "wb", quiet = TRUE)
  oz_raw <- readxl::read_excel(oz_file)
  cat("OZ list from CDFI:", nrow(oz_raw), "records\n")
}, error = function(e) {
  cat("CDFI download failed, trying alternative...\n")
  # Alternative: use the Treasury's certified list via data.gov
  alt_url <- "https://data.cdfifund.gov/api/views/by3x-7acr/rows.csv?accessType=DOWNLOAD"
  tryCatch({
    download.file(alt_url, file.path(data_dir, "oz_list.csv"), quiet = TRUE)
    oz_raw <- read_csv(file.path(data_dir, "oz_list.csv"), show_col_types = FALSE)
    cat("OZ list from data.gov:", nrow(oz_raw), "records\n")
  }, error = function(e2) {
    cat("Alternative also failed. Will construct OZ status from Census/HUD data.\n")
    # Fallback: HUD publishes OZ tract list
    hud_url <- "https://www.huduser.gov/portal/datasets/qoz.html"
    cat("Manual download needed from:", hud_url, "\n")
    oz_raw <- NULL
  })
})

# Save whatever we got
if (exists("oz_raw") && !is.null(oz_raw)) {
  saveRDS(oz_raw, file.path(data_dir, "oz_designations_raw.rds"))
}


cat("\n=== Step 3: Fetch LODES WAC data for key years ===\n")

# Download LODES WAC (Workplace Area Characteristics) for pre/post OZ period
# Pre: 2015, 2016, 2017 (pre-treatment baseline)
# Post: 2019, 2020, 2021, 2022, 2023 (post-treatment)
# CNS09 = NAICS 51 (Information)
# CNS04 = NAICS 23 (Construction)
# C000 = Total employment

lodes_years <- c(2015, 2016, 2017, 2019, 2020, 2021, 2022, 2023)
lodes_states <- c("al","az","ar","ca","co","ct","de","fl","ga","hi",
                   "id","il","in","ia","ks","ky","la","me","md","ma",
                   "mi","mn","ms","mo","mt","ne","nv","nh","nj","nm",
                   "ny","nc","nd","oh","ok","or","pa","ri","sc","sd",
                   "tn","tx","ut","vt","va","wa","wv","wi","wy","dc")

lodes_list <- list()
for (yr in lodes_years) {
  for (st in lodes_states) {
    url <- paste0(
      "https://lehd.ces.census.gov/data/lodes/LODES8/",
      st, "/wac/", st, "_wac_S000_JT00_", yr, ".csv.gz"
    )
    dest <- file.path(data_dir, paste0(st, "_wac_", yr, ".csv.gz"))
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      dt <- fread(cmd = paste("gunzip -c", dest),
                  select = c("w_geocode", "C000", "CNS04", "CNS09"))
      # Aggregate to tract level (first 11 chars of geocode)
      dt[, tract_geoid := substr(w_geocode, 1, 11)]
      tract_dt <- dt[, .(
        total_emp = sum(C000, na.rm = TRUE),
        construction_emp = sum(CNS04, na.rm = TRUE),
        info_emp = sum(CNS09, na.rm = TRUE)
      ), by = tract_geoid]
      tract_dt[, `:=`(year = yr, state_abbr = st)]
      lodes_list[[paste(st, yr)]] <- tract_dt
      file.remove(dest)  # Clean up
    }, error = function(e) {
      cat("  ", st, yr, ": failed -", substr(e$message, 1, 50), "\n")
    })
  }
  cat("Year", yr, "complete:", length(lodes_list), "state-years so far\n")
}

lodes_all <- rbindlist(lodes_list)
cat("\nTotal LODES records:", nrow(lodes_all), "\n")
cat("Unique tracts:", uniqueN(lodes_all$tract_geoid), "\n")
cat("Years:", sort(unique(lodes_all$year)), "\n")

saveRDS(lodes_all, file.path(data_dir, "lodes_tract_employment.rds"))
cat("LODES data saved\n\n")


cat("=== Step 4: Fetch tract-level covariates from ACS ===\n")

# Additional covariates: education, race, housing, urbanicity
cov_list <- list()
for (st in states) {
  url <- paste0(
    "https://api.census.gov/data/2015/acs/acs5?get=",
    "B15003_022E,B15003_001E,",  # Bachelor's degree, total 25+
    "B02001_002E,B02001_001E,",  # White alone, total race
    "B25077_001E,",               # Median home value
    "B23025_005E,B23025_002E",    # Unemployed, in labor force
    "&for=tract:*&in=state:", st
  )
  tryCatch({
    resp <- httr::GET(url)
    if (httr::status_code(resp) == 200) {
      raw <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      cov_list[[st]] <- df
    }
  }, error = function(e) NULL)
  Sys.sleep(0.3)
}

cov_raw <- bind_rows(cov_list)
cov_raw <- cov_raw %>%
  mutate(
    geoid = paste0(state, county, tract),
    pct_bachelors = as.numeric(B15003_022E) / pmax(as.numeric(B15003_001E), 1) * 100,
    pct_white = as.numeric(B02001_002E) / pmax(as.numeric(B02001_001E), 1) * 100,
    median_home_value = ifelse(as.numeric(B25077_001E) < 0, NA, as.numeric(B25077_001E)),
    unemployment_rate = as.numeric(B23025_005E) / pmax(as.numeric(B23025_002E), 1) * 100
  ) %>%
  select(geoid, pct_bachelors, pct_white, median_home_value, unemployment_rate)

saveRDS(cov_raw, file.path(data_dir, "acs_covariates.rds"))
cat("Covariates saved:", nrow(cov_raw), "tracts\n")

cat("\n=== All data fetched successfully ===\n")
