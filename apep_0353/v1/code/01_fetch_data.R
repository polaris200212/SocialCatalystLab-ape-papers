## ============================================================================
## 01_fetch_data.R — Build county × quarter HCBS panel + fetch QCEW + ACS
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

## ---- 1. Verify T-MSIS Parquet ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path)
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. Load NPPES extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (!file.exists(nppes_path)) stop("NPPES extract not found at: ", nppes_path)
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]

## ---- 3. Download Census ZCTA-to-county crosswalk ----
xwalk_path <- file.path(DATA, "zcta_county_rel.csv")
if (!file.exists(xwalk_path)) {
  cat("Downloading Census ZCTA-to-county relationship file...\n")
  xwalk_url <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_county20_natl.txt"
  resp <- GET(xwalk_url, write_disk(xwalk_path, overwrite = TRUE), timeout(120))
  if (status_code(resp) != 200) stop("Failed to download ZCTA-county crosswalk")
}
cat("Loading ZCTA-to-county crosswalk...\n")
xwalk <- fread(xwalk_path, sep = "|")

# Build ZIP5 -> county FIPS mapping (take highest-population county per ZIP)
# GEOID_COUNTY_20 is a 5-digit FIPS; extract state from first 2 digits
xwalk <- xwalk[!is.na(GEOID_COUNTY_20) & GEOID_COUNTY_20 != "" &
                !is.na(GEOID_ZCTA5_20) & GEOID_ZCTA5_20 != ""]
xwalk[, county_fips_str := sprintf("%05s", as.character(GEOID_COUNTY_20))]
xwalk[, zcta_str := sprintf("%05s", as.character(GEOID_ZCTA5_20))]

zip_county <- xwalk[, .(
  county_fips = county_fips_str[which.max(AREALAND_PART)],
  state_fips = substr(county_fips_str[which.max(AREALAND_PART)], 1, 2)
), by = .(zip5 = zcta_str)]

cat(sprintf("ZIP-county crosswalk: %d ZIPs mapped to counties\n", nrow(zip_county)))

## ---- 4. Build NPI -> county mapping ----
nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]
npi_geo <- merge(
  nppes[, .(npi, state_nppes = state, zip5, entity_type)],
  zip_county[, .(zip5, county_fips, state_fips)],
  by = "zip5", all.x = TRUE
)
cat(sprintf("NPI-county match rate: %.1f%%\n",
            100 * mean(!is.na(npi_geo$county_fips))))

## ---- 5. Build county × quarter HCBS panel from T-MSIS ----
cat("Aggregating T-MSIS HCBS claims by billing NPI × month (Arrow)...\n")

# HCBS = T-codes, H-codes, S-codes (Medicaid-specific services)
hcbs_by_npi_month <- tmsis_ds |>
  filter(
    substr(HCPCS_CODE, 1, 1) %in% c("T", "H", "S")
  ) |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7)),
    quarter = as.integer(ceiling(month_num / 3))
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year, quarter) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    n_codes = n_distinct(HCPCS_CODE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(hcbs_by_npi_month, "BILLING_PROVIDER_NPI_NUM", "npi")
cat(sprintf("HCBS NPI-quarter rows: %s\n", format(nrow(hcbs_by_npi_month), big.mark = ",")))

# Also get non-HCBS (placebo) claims by NPI × quarter
cat("Aggregating non-HCBS claims for placebo outcomes...\n")
non_hcbs_by_npi_month <- tmsis_ds |>
  filter(
    !(substr(HCPCS_CODE, 1, 1) %in% c("T", "H", "S"))
  ) |>
  mutate(
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7)),
    quarter = as.integer(ceiling(month_num / 3))
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year, quarter) |>
  summarize(
    non_hcbs_paid = sum(TOTAL_PAID, na.rm = TRUE),
    non_hcbs_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    non_hcbs_benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(non_hcbs_by_npi_month, "BILLING_PROVIDER_NPI_NUM", "npi")
cat(sprintf("Non-HCBS NPI-quarter rows: %s\n", format(nrow(non_hcbs_by_npi_month), big.mark = ",")))

## ---- 6. Join NPI -> county, collapse to county × quarter ----
hcbs_by_npi_month <- merge(hcbs_by_npi_month, npi_geo[, .(npi, county_fips, state_fips, entity_type)],
                           by = "npi", all.x = TRUE)

# County × quarter HCBS panel
panel_hcbs <- hcbs_by_npi_month[!is.na(county_fips), .(
  hcbs_providers = uniqueN(npi),
  hcbs_paid = sum(total_paid),
  hcbs_claims = sum(total_claims),
  hcbs_benes = sum(total_benes),
  hcbs_indiv_providers = uniqueN(npi[entity_type == 1]),
  hcbs_org_providers = uniqueN(npi[entity_type == 2])
), by = .(county_fips, state_fips, year, quarter)]

panel_hcbs[, yearqtr := year + (quarter - 1) / 4]

# Non-HCBS placebo panel
non_hcbs_by_npi_month <- merge(non_hcbs_by_npi_month,
                                npi_geo[, .(npi, county_fips, state_fips)],
                                by = "npi", all.x = TRUE)

panel_non_hcbs <- non_hcbs_by_npi_month[!is.na(county_fips), .(
  non_hcbs_providers = uniqueN(npi),
  non_hcbs_paid = sum(non_hcbs_paid),
  non_hcbs_claims = sum(non_hcbs_claims),
  non_hcbs_benes = sum(non_hcbs_benes)
), by = .(county_fips, state_fips, year, quarter)]

# Merge HCBS + non-HCBS panels
panel <- merge(panel_hcbs, panel_non_hcbs,
               by = c("county_fips", "state_fips", "year", "quarter"),
               all = TRUE)
panel[is.na(hcbs_providers), hcbs_providers := 0]
panel[is.na(non_hcbs_providers), non_hcbs_providers := 0]

cat(sprintf("County-quarter panel: %d rows, %d counties, %d quarters\n",
            nrow(panel), uniqueN(panel$county_fips),
            uniqueN(paste(panel$year, panel$quarter))))

# Clean up large intermediates
rm(hcbs_by_npi_month, non_hcbs_by_npi_month)
gc()

## ---- 7. County quarterly employment from Census QWI ----
cat("\nLoading county quarterly employment from Census QWI...\n")

qwi_cache <- file.path(DATA, "qwi_county_emp.rds")
if (file.exists(qwi_cache)) {
  qwi_emp <- readRDS(qwi_cache)
  cat(sprintf("Loaded cached QWI: %d rows\n", nrow(qwi_emp)))
} else {
  # Read pre-downloaded QWI JSON files (one per state per quarter)
  qwi_dir <- file.path(DATA, "qwi")
  qwi_list <- list()

  state_codes <- sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56))

  for (yr in 2018:2024) {
    for (qtr in 1:4) {
      for (st in state_codes) {
        f <- file.path(qwi_dir, sprintf("tmp_%d_q%d_%s.json", yr, qtr, st))
        if (!file.exists(f) || file.size(f) < 10) next
        d <- tryCatch({
          raw <- fromJSON(readLines(f, warn = FALSE))
          if (is.null(raw) || nrow(raw) < 2) return(NULL)
          df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
          names(df) <- raw[1, ]
          df
        }, error = function(e) NULL)
        if (!is.null(d) && nrow(d) > 0) {
          qwi_list[[length(qwi_list) + 1]] <- data.table(
            county_fips = paste0(d$state, d$county),
            year = as.integer(d$year),
            quarter = as.integer(d$quarter),
            total_emp = as.numeric(d$Emp)
          )
        }
      }
    }
    cat(sprintf("  QWI year %d loaded\n", yr))
  }

  if (length(qwi_list) > 0) {
    qwi_emp <- rbindlist(qwi_list)
    qwi_emp <- qwi_emp[!is.na(total_emp) & total_emp > 0]
    saveRDS(qwi_emp, qwi_cache)
    cat(sprintf("QWI county employment: %d rows, %d counties\n",
                nrow(qwi_emp), uniqueN(qwi_emp$county_fips)))
  } else {
    stop("No QWI data loaded. Check data/qwi/ directory.")
  }
}

## ---- 7b. QCEW industry shares (2018) for Bartik instrument ----
cat("\nLoading QCEW 2018 annual data for Bartik base shares...\n")

qcew_cache <- file.path(DATA, "qcew_raw.rds")
if (file.exists(qcew_cache)) {
  cat("Loading cached QCEW data...\n")
  qcew <- readRDS(qcew_cache)
} else {
  # Read the QCEW 2018 annual singlefile
  zip_file <- file.path(DATA, "qcew_2018_annual.zip")
  if (!file.exists(zip_file)) stop("QCEW 2018 annual zip not found. Download it first.")

  csv_dir <- file.path(DATA, "qcew_2018_annual")
  if (!dir.exists(csv_dir)) {
    dir.create(csv_dir, showWarnings = FALSE)
    unzip(zip_file, exdir = csv_dir)
  }

  csv_files <- list.files(csv_dir, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
  cat(sprintf("  Found %d CSV files in QCEW 2018 annual\n", length(csv_files)))

  qcew_2018 <- fread(csv_files[1], showProgress = FALSE)
  cat(sprintf("  Raw QCEW 2018: %d rows, columns: %s\n", nrow(qcew_2018),
              paste(head(names(qcew_2018), 10), collapse = ", ")))

  # Keep county-level (area_fips = 5-digit), private sector (own_code=5)
  # 2-digit NAICS (agglvl_code 74) + total private (agglvl_code 71)
  counties_needed <- unique(panel$county_fips)
  qcew_2018 <- qcew_2018[own_code == 5 & area_fips %in% counties_needed]
  qcew_2018 <- qcew_2018[agglvl_code %in% c(71, 74)]

  cat(sprintf("  Filtered QCEW 2018: %d rows, %d counties\n",
              nrow(qcew_2018), uniqueN(qcew_2018$area_fips)))

  qcew <- qcew_2018
  saveRDS(qcew, qcew_cache)
}

## ---- 7c. QCEW national quarterly data for Bartik growth rates ----
cat("\nLoading QCEW national quarterly data for Bartik shifts...\n")

nat_qcew_cache <- file.path(DATA, "qcew_national.rds")
if (file.exists(nat_qcew_cache)) {
  qcew_national <- readRDS(nat_qcew_cache)
  cat(sprintf("Loaded cached national QCEW: %d rows\n", nrow(qcew_national)))
} else {
  nat_dir <- file.path(DATA, "qcew_national")
  nat_list <- list()

  for (yr in 2018:2024) {
    for (qtr in 1:4) {
      f <- file.path(nat_dir, sprintf("%d_q%d.csv", yr, qtr))
      if (!file.exists(f) || file.size(f) < 10) next
      d <- tryCatch(fread(f, showProgress = FALSE), error = function(e) data.table())
      if (nrow(d) > 0 && "own_code" %in% names(d)) {
        # Keep private sector, 2-digit NAICS
        d <- d[own_code == 5 & nchar(as.character(industry_code)) == 2 & industry_code != "10"]
        if (nrow(d) > 0) {
          nat_list[[length(nat_list) + 1]] <- d[, .(
            industry_code = as.character(industry_code),
            year = as.integer(year), qtr = as.integer(qtr),
            month3_emplvl = as.numeric(month3_emplvl)
          )]
        }
      }
    }
  }

  qcew_national <- rbindlist(nat_list, fill = TRUE)
  saveRDS(qcew_national, nat_qcew_cache)
  cat(sprintf("National QCEW: %d rows, %d industries\n",
              nrow(qcew_national), uniqueN(qcew_national$industry_code)))
}

cat(sprintf("QCEW data ready: %d county-industry rows + %d national rows\n",
            nrow(qcew), nrow(qcew_national)))

## ---- 8. Fetch Census ACS county demographics ----
cat("\nFetching Census ACS 5-year county data...\n")

acs_path <- file.path(DATA, "acs_county.rds")
if (!file.exists(acs_path)) {
  # Variables: population, poverty, median income, elderly share, uninsurance
  acs_vars <- paste(c(
    "B01003_001E",  # Total population
    "B17001_002E",  # Below poverty
    "B19013_001E",  # Median household income
    "B01001_020E", "B01001_021E", "B01001_022E", "B01001_023E",
    "B01001_024E", "B01001_025E",  # Males 65+
    "B01001_044E", "B01001_045E", "B01001_046E", "B01001_047E",
    "B01001_048E", "B01001_049E",  # Females 65+
    "B27010_017E", "B27010_033E", "B27010_050E", "B27010_066E",  # Uninsured by age
    "NAME"
  ), collapse = ",")

  acs_list <- list()
  # Valid state FIPS codes (skip non-existent ones)
  valid_states <- c(sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56)))
  for (st in valid_states) {
    url <- sprintf(
      "https://api.census.gov/data/2022/acs/acs5?get=%s&for=county:*&in=state:%s",
      acs_vars, st
    )
    r <- tryCatch(GET(url, timeout(30)), error = function(e) NULL)
    if (!is.null(r) && status_code(r) == 200) {
      d <- tryCatch(fromJSON(content(r, "text", encoding = "UTF-8")), error = function(e) NULL)
      if (!is.null(d) && is.matrix(d) && nrow(d) > 1 && ncol(d) == length(d[1, ])) {
        header <- d[1, ]
        df <- as.data.frame(d[-1, , drop = FALSE], stringsAsFactors = FALSE)
        if (ncol(df) == length(header)) {
          names(df) <- header
          acs_list[[st]] <- df
        }
      }
    }
  }

  if (length(acs_list) > 0) {
    acs_raw <- rbindlist(acs_list, fill = TRUE)

    # Convert to numeric
    num_cols <- setdiff(names(acs_raw), c("NAME", "state", "county"))
    for (col in num_cols) {
      acs_raw[, (col) := as.numeric(get(col))]
    }

    acs_raw[, county_fips := paste0(sprintf("%02d", as.integer(state)),
                                     sprintf("%03d", as.integer(county)))]
    acs_raw[, population := B01003_001E]
    acs_raw[, poverty_n := B17001_002E]
    acs_raw[, poverty_rate := fifelse(population > 0, poverty_n / population, NA_real_)]
    acs_raw[, median_income := B19013_001E]

    # Elderly (65+) = sum of male 65+ and female 65+
    elderly_cols_m <- paste0("B01001_0", 20:25, "E")
    elderly_cols_f <- paste0("B01001_0", 44:49, "E")
    acs_raw[, elderly_n := rowSums(.SD, na.rm = TRUE), .SDcols = c(elderly_cols_m, elderly_cols_f)]
    acs_raw[, elderly_share := fifelse(population > 0, elderly_n / population, NA_real_)]

    # Uninsured
    unins_cols <- c("B27010_017E", "B27010_033E", "B27010_050E", "B27010_066E")
    acs_raw[, uninsured_n := rowSums(.SD, na.rm = TRUE), .SDcols = unins_cols]
    acs_raw[, uninsured_rate := fifelse(population > 0, uninsured_n / population, NA_real_)]

    acs <- acs_raw[, .(county_fips, county_name = NAME, population, poverty_rate,
                        median_income, elderly_share, uninsured_rate)]

    saveRDS(acs, acs_path)
    cat(sprintf("ACS county data: %d counties\n", nrow(acs)))
  }
} else {
  acs <- readRDS(acs_path)
  cat(sprintf("Loaded cached ACS: %d counties\n", nrow(acs)))
}

## ---- 9. Merge everything into analysis panel ----
cat("\nBuilding analysis panel...\n")

# Merge QWI employment
panel <- merge(panel, qwi_emp, by = c("county_fips", "year", "quarter"), all.x = TRUE)
cat(sprintf("  After QWI merge: %d rows, emp available for %.1f%%\n",
            nrow(panel), 100 * mean(!is.na(panel$total_emp))))

# Merge ACS
panel <- merge(panel, acs, by = "county_fips", all.x = TRUE)

cat(sprintf("Final panel: %d county-quarters, %d counties, %d states\n",
            nrow(panel), uniqueN(panel$county_fips),
            uniqueN(panel$state_fips)))

## ---- 10. Save ----
saveRDS(panel, file.path(DATA, "panel_county_quarter.rds"))
saveRDS(npi_geo, file.path(DATA, "npi_geo.rds"))
saveRDS(qcew, file.path(DATA, "qcew_2018_shares.rds"))
saveRDS(qcew_national, file.path(DATA, "qcew_national_quarterly.rds"))

cat("\n=== Data preparation complete ===\n")
