###############################################################################
# 01_fetch_data.R — Fetch all data from UK public APIs
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
#
# Data sources:
#   1. DfE KS4 — School-level Progress 8 / Attainment 8 (EES + archived)
#   2. GIAS — School characteristics (academy status, FSM%, LA)
#   3. NOMIS ASHE — LA-level median private-sector earnings
#   4. DfE SWC — Teacher vacancy rates by LA
#   5. STPCD — Teacher pay scales (with London bands)
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# 1. DfE KS4 — School-level Performance Data
###############################################################################

cat("=== FETCHING KS4 SCHOOL-LEVEL DATA ===\n\n")

# --- 2023/24: Direct CSV from EES data catalogue ---
cat("Fetching 2023/24 KS4 school-level from EES data catalogue...\n")
ks4_2324_url <- "https://explore-education-statistics.service.gov.uk/data-catalogue/data-set/c8f753ef-b76f-41a3-8949-13382e131054/csv"
ks4_2324_file <- paste0(data_dir, "ks4_school_2324_raw.csv")

if (!file.exists(ks4_2324_file)) {
  tryCatch({
    download.file(ks4_2324_url, ks4_2324_file, mode = "wb", quiet = FALSE)
    cat("  2023/24 KS4 downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  2023/24 EES download failed: %s\n", e$message))
    cat("  Trying httr2...\n")
    tryCatch({
      resp <- request(ks4_2324_url) |>
        req_timeout(180) |>
        req_perform()
      writeBin(resp_body_raw(resp), ks4_2324_file)
      cat("  2023/24 downloaded via httr2.\n")
    }, error = function(e2) {
      cat(sprintf("  httr2 also failed: %s\n", e2$message))
    })
  })
} else {
  cat("  2023/24 file already exists.\n")
}

# --- School info (school type, P8 banding) for 2023/24 ---
cat("Fetching 2023/24 school info from EES...\n")
ks4_info_url <- "https://explore-education-statistics.service.gov.uk/data-catalogue/data-set/d7ce19cb-916b-45d6-9dc1-3e581e16fa1a/csv"
ks4_info_file <- paste0(data_dir, "ks4_school_info_2324.csv")

if (!file.exists(ks4_info_file)) {
  tryCatch({
    download.file(ks4_info_url, ks4_info_file, mode = "wb", quiet = TRUE)
    cat("  School info downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  School info download failed: %s\n", e$message))
  })
}

# --- Historical years: Try EES supplementary files ---
# Each EES release has supplementary Excel files with school-level data.
# We need to discover the correct file GUIDs for each release.

# Try the EES API to find releases and their files
cat("\nFetching historical KS4 releases from EES API...\n")

# EES publication slug for KS4
ks4_pub_slug <- "key-stage-4-performance"

# Attempt to get list of releases via EES API
ees_releases <- tryCatch({
  resp <- request("https://explore-education-statistics.service.gov.uk/api/find-statistics/key-stage-4-performance") |>
    req_timeout(30) |>
    req_perform()
  fromJSON(resp_body_string(resp))
}, error = function(e) {
  cat(sprintf("  EES API failed: %s\n", e$message))
  NULL
})

# Alternative: Download historical KS4 from Compare School Performance
# archived data on gov.uk
cat("\nFetching historical KS4 from gov.uk archived performance tables...\n")

# The DfE publishes school-level KS4 data as downloadable CSVs
# via the statistics collection page
# These are the direct links to the underlying data files
historical_ks4_urls <- list(
  "2022-2023" = "https://content.explore-education-statistics.service.gov.uk/api/releases/aec30e5d-7a58-4ed1-8ba3-9efaf864ca45/files",
  "2021-2022" = "https://content.explore-education-statistics.service.gov.uk/api/releases/6a93c816-2080-4d44-b929-fc4e50e3e543/files",
  "2018-2019" = "https://content.explore-education-statistics.service.gov.uk/api/releases/4926d8b3-4416-44e1-8462-cd0a3d53e8a3/files",
  "2017-2018" = "https://content.explore-education-statistics.service.gov.uk/api/releases/3c3e46a1-fd4a-4dc1-b19e-ef38b5f3b922/files",
  "2016-2017" = "https://content.explore-education-statistics.service.gov.uk/api/releases/95f1f2b2-dac4-4c0b-b8f2-7a3d2b50f4a1/files"
)

# Since the exact file GUIDs for supplementary Excel files change per release,
# we'll try the EES data catalogue approach for years that have it.
# For older years, we'll use the Compare School Performance download.

# Try Compare School Performance download for each historical year
years_needed <- c("2022-2023", "2021-2022", "2018-2019", "2017-2018", "2016-2017")

for (yr in years_needed) {
  yr_file <- paste0(data_dir, "ks4_school_", gsub("-", "", yr), "_raw.csv")
  if (file.exists(yr_file)) {
    cat(sprintf("  %s: file already exists, skipping.\n", yr))
    next
  }

  # Try the Compare School Performance download link
  csp_url <- paste0(
    "https://www.compare-school-performance.service.gov.uk/download-data",
    "?currentstep=datatypes&regiontype=all&la=0",
    "&downloadYear=", yr,
    "&datatypes=ks4"
  )

  tryCatch({
    resp <- request(csp_url) |>
      req_timeout(120) |>
      req_headers(
        "User-Agent" = "Mozilla/5.0 (compatible; APEP-research/1.0)",
        "Accept" = "text/csv,application/csv,*/*"
      ) |>
      req_perform()

    ct <- resp_content_type(resp)
    body <- resp_body_raw(resp)

    if (length(body) > 10000) {
      writeBin(body, yr_file)
      cat(sprintf("  %s: downloaded (%s bytes).\n", yr, format(length(body), big.mark = ",")))
    } else {
      cat(sprintf("  %s: response too small (%d bytes), likely HTML redirect.\n", yr, length(body)))
    }
  }, error = function(e) {
    cat(sprintf("  %s: download failed - %s\n", yr, e$message))
  })
  Sys.sleep(1)
}

# If CSP downloads failed, try the archived gov.uk performance tables
# These are available as ZIP files from the DfE statistics collection
cat("\nChecking for alternative KS4 sources (gov.uk statistics)...\n")

# The DfE published school-level data in SFR (Statistical First Release) format
# These CSV files are available from the gov.uk content delivery network
archive_urls <- list(
  "2022-2023" = "https://content.explore-education-statistics.service.gov.uk/api/releases/aec30e5d-7a58-4ed1-8ba3-9efaf864ca45/files",
  "2021-2022" = "https://content.explore-education-statistics.service.gov.uk/api/releases/6a93c816-2080-4d44-b929-fc4e50e3e543/files"
)

# For the EES data catalogue, try getting the data via the API
# EES has a query API that can return school-level data
cat("\nTrying EES query API for school-level KS4...\n")

# The v1 paper used this dataset ID for LA-level KS4
# For school-level, we need the institution-level dataset
# Let's check what datasets are available in the KS4 publication
ees_datasets_url <- "https://explore-education-statistics.service.gov.uk/api/find-statistics/key-stage-4-performance"

ees_pub <- tryCatch({
  resp <- request(ees_datasets_url) |>
    req_timeout(30) |>
    req_perform()
  fromJSON(resp_body_string(resp))
}, error = function(e) {
  cat(sprintf("  EES publication API failed: %s\n", e$message))
  NULL
})

if (!is.null(ees_pub)) {
  cat("  EES KS4 publication found. Checking for data sets...\n")
  if ("dataSets" %in% names(ees_pub)) {
    cat(sprintf("  Found %d datasets.\n", length(ees_pub$dataSets)))
  }
}

# Final approach: use the EES data catalogue for 2023/24 and
# construct the panel from whatever school-level data we can get
# If historical years fail, we use LA-level data for pre-period
# and school-level for post-period (with appropriate methodology)

cat("\n=== KS4 FETCH SUMMARY ===\n")
ks4_files <- list.files(data_dir, pattern = "ks4_school.*\\.csv$")
cat(sprintf("  Files obtained: %d\n", length(ks4_files)))
for (f in ks4_files) {
  sz <- file.size(paste0(data_dir, f))
  cat(sprintf("    %s: %s bytes\n", f, format(sz, big.mark = ",")))
}

###############################################################################
# 2. GIAS — Get Information About Schools
###############################################################################

cat("\n=== FETCHING GIAS SCHOOL DATA ===\n\n")

gias_file <- paste0(data_dir, "gias_raw.csv")
if (!file.exists(gias_file)) {
  # Try today's date first, then yesterday's, then fallback
  dates_to_try <- format(Sys.Date() - 0:3, "%Y%m%d")

  for (dt in dates_to_try) {
    gias_url <- paste0(
      "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata",
      dt, ".csv"
    )
    cat(sprintf("  Trying GIAS extract for %s...\n", dt))
    tryCatch({
      download.file(gias_url, gias_file, mode = "wb", quiet = TRUE)
      sz <- file.size(gias_file)
      if (sz > 1000000) {  # Should be >50MB
        cat(sprintf("  GIAS downloaded: %s bytes\n", format(sz, big.mark = ",")))
        break
      } else {
        file.remove(gias_file)
        cat(sprintf("  File too small (%s bytes), trying next date.\n", format(sz, big.mark = ",")))
      }
    }, error = function(e) {
      cat(sprintf("  Failed: %s\n", e$message))
    })
    Sys.sleep(0.5)
  }
} else {
  cat("  GIAS file already exists.\n")
}

if (file.exists(gias_file)) {
  gias_raw <- fread(gias_file, showProgress = FALSE)
  cat(sprintf("  GIAS: %d establishments, %d columns\n", nrow(gias_raw), ncol(gias_raw)))
} else {
  cat("  WARNING: GIAS download failed. Will construct school metadata from KS4 data.\n")
}

###############################################################################
# 3. NOMIS ASHE — Median annual gross pay by LA
###############################################################################

cat("\n=== FETCHING ASHE EARNINGS DATA ===\n\n")

ashe_file <- paste0(data_dir, "ashe_earnings_by_la.csv")
if (!file.exists(ashe_file)) {
  ashe_years <- 2010:2023
  ashe_list <- list()

  for (yr in ashe_years) {
    # All employees (sex=7), median (item=2), annual gross pay (pay=7)
    url <- paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/NM_99_1.data.csv?",
      "date=", yr,
      "&geography=TYPE464",
      "&sex=7",
      "&item=2",
      "&pay=7",
      "&measures=20100",
      "&select=date_name,geography_name,geography_code,obs_value"
    )
    tryCatch({
      tmp <- fread(url, showProgress = FALSE)
      if (nrow(tmp) > 0) {
        tmp[, year := yr]
        ashe_list[[as.character(yr)]] <- tmp
        cat(sprintf("  ASHE %d: %d LAs\n", yr, nrow(tmp)))
      }
    }, error = function(e) {
      cat(sprintf("  ASHE %d: FAILED - %s\n", yr, e$message))
    })
    Sys.sleep(0.3)
  }

  if (length(ashe_list) > 0) {
    ashe_raw <- rbindlist(ashe_list, fill = TRUE)
    setnames(ashe_raw, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                          "OBS_VALUE", "year"),
             c("date_label", "la_name", "la_code", "median_annual_pay", "year"))
    ashe_raw <- ashe_raw[grepl("^E", la_code)]
    ashe_raw[, median_annual_pay := as.numeric(median_annual_pay)]
    fwrite(ashe_raw, ashe_file)
    cat(sprintf("\nASHE total: %d rows, %d LAs, years %d-%d\n",
                nrow(ashe_raw), uniqueN(ashe_raw$la_code),
                min(ashe_raw$year), max(ashe_raw$year)))
  }
} else {
  cat("  ASHE file already exists.\n")
  ashe_raw <- fread(ashe_file)
  cat(sprintf("  ASHE: %d rows\n", nrow(ashe_raw)))
}

# Also fetch ASHE for education sector specifically (SIC 85)
# to compute teacher-vs-private wage ratio more precisely
cat("\nFetching ASHE education sector earnings...\n")
ashe_edu_file <- paste0(data_dir, "ashe_education_la.csv")
if (!file.exists(ashe_edu_file)) {
  edu_list <- list()
  for (yr in 2010:2023) {
    # SIC 2007 section P (Education) = 85
    url <- paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/NM_99_1.data.csv?",
      "date=", yr,
      "&geography=TYPE464",
      "&sex=7",
      "&item=2",
      "&pay=7",
      "&measures=20100",
      "&industry=150",  # SIC section P: Education
      "&select=date_name,geography_name,geography_code,obs_value"
    )
    tryCatch({
      tmp <- fread(url, showProgress = FALSE)
      if (nrow(tmp) > 0) {
        tmp[, year := yr]
        edu_list[[as.character(yr)]] <- tmp
      }
    }, error = function(e) {
      # Silently skip
    })
    Sys.sleep(0.3)
  }

  if (length(edu_list) > 0) {
    ashe_edu <- rbindlist(edu_list, fill = TRUE)
    setnames(ashe_edu, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                          "OBS_VALUE", "year"),
             c("date_label", "la_name", "la_code", "edu_median_pay", "year"))
    ashe_edu <- ashe_edu[grepl("^E", la_code)]
    ashe_edu[, edu_median_pay := as.numeric(edu_median_pay)]
    fwrite(ashe_edu, ashe_edu_file)
    cat(sprintf("  ASHE Education: %d rows\n", nrow(ashe_edu)))
  } else {
    cat("  ASHE Education sector data not available at LA level.\n")
  }
} else {
  cat("  ASHE education file already exists.\n")
}

###############################################################################
# 4. DfE SWC — Teacher Vacancies by LA
###############################################################################

cat("\n=== FETCHING SWC VACANCY DATA ===\n\n")

swc_file <- paste0(data_dir, "swc_vacancies_raw.csv")
if (!file.exists(swc_file)) {
  swc_url <- "https://explore-education-statistics.service.gov.uk/data-catalogue/data-set/8359504b-0506-47b8-8237-c9ee4f082b1e/csv"
  tryCatch({
    download.file(swc_url, swc_file, mode = "wb", quiet = FALSE)
    cat("  SWC vacancies downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  SWC download failed: %s\n", e$message))
    # Try httr2
    tryCatch({
      resp <- request(swc_url) |>
        req_timeout(120) |>
        req_perform()
      writeBin(resp_body_raw(resp), swc_file)
      cat("  SWC downloaded via httr2.\n")
    }, error = function(e2) {
      cat(sprintf("  httr2 also failed: %s\n", e2$message))
    })
  })
}

if (file.exists(swc_file)) {
  swc_raw <- fread(swc_file, showProgress = FALSE)
  cat(sprintf("  SWC vacancies: %d rows, %d columns\n", nrow(swc_raw), ncol(swc_raw)))
} else {
  cat("  WARNING: SWC vacancy data not available.\n")
}

###############################################################################
# 5. STPCD Teacher Pay Scales (with London bands)
###############################################################################

cat("\n=== CONSTRUCTING STPCD PAY SCALES ===\n\n")

# Main pay range M1 (starting) and M6 (top of main scale)
# Four bands: Inner London, Outer London, Fringe, Rest of England
# Source: STPCD published annually by DfE
stpcd <- data.table(
  year = rep(2010:2023, each = 4),
  band = rep(c("inner_london", "outer_london", "fringe", "rest_of_england"), 14),

  # M1 (starting salary) by band and year
  m1 = c(
    # 2010
    25000, 23763, 22259, 21588,
    # 2011 (frozen)
    25000, 23763, 22259, 21588,
    # 2012 (frozen)
    25000, 23763, 22259, 21588,
    # 2013 (+1%)
    25117, 23881, 22366, 21804,
    # 2014 (+1%)
    25368, 24120, 22590, 22023,
    # 2015 (+1%)
    25623, 24361, 22816, 22244,
    # 2016 (+1%)
    25879, 24604, 23044, 22467,
    # 2017 (+2% on M1)
    27819, 26622, 24210, 23720,
    # 2018 (+3.5% on M1)
    28660, 27397, 24712, 24373,
    # 2019 (+2.75%)
    29664, 28355, 25543, 25714,
    # 2020 (+5.5% on M1)
    32157, 29915, 26948, 25714,
    # 2021 (freeze except M1)
    32157, 29915, 26948, 25714,
    # 2022 (+8.9% on M1)
    34502, 31350, 27597, 28000,
    # 2023 (+6.5%)
    36745, 33814, 29344, 30000
  ),

  # M6 (top of main scale) by band and year
  m6 = c(
    # 2010
    34768, 33584, 32166, 31552,
    # 2011
    34768, 33584, 32166, 31552,
    # 2012
    34768, 33584, 32166, 31552,
    # 2013
    35116, 33920, 32488, 31868,
    # 2014
    35467, 34259, 32813, 32187,
    # 2015
    35822, 34601, 33141, 32509,
    # 2016
    36180, 34947, 33472, 32831,
    # 2017
    37253, 35927, 34290, 33824,
    # 2018
    38633, 37258, 35571, 35971,
    # 2019
    40490, 39066, 37255, 38174,
    # 2020
    40490, 39066, 37255, 38174,
    # 2021
    40490, 39066, 37255, 38174,
    # 2022
    41604, 40083, 38226, 38810,
    # 2023
    44373, 42624, 40625, 41333
  )
)

# Midpoint as typical teacher salary
stpcd[, teacher_pay_mid := (m1 + m6) / 2]

fwrite(stpcd, paste0(data_dir, "stpcd_pay_scales.csv"))
cat(sprintf("STPCD: %d rows (4 bands × %d years)\n", nrow(stpcd), uniqueN(stpcd$year)))

# Create LA-to-band mapping
# Inner London: 12 boroughs + City of London
# Outer London: 20 boroughs
# Fringe: parts of Surrey, Herts, Essex, Kent, Berks, Bucks, Beds, W.Sussex
# Rest of England: everything else
cat("Creating LA-to-STPCD band mapping...\n")

inner_london_codes <- c(
  "E09000001", "E09000007", "E09000012", "E09000013", "E09000014",
  "E09000019", "E09000020", "E09000022", "E09000023", "E09000025",
  "E09000028", "E09000030", "E09000033"  # City, Camden, Hackney, Hammersmith, Haringey, Islington, K&C, Lambeth, Lewisham, Newham, Southwark, Tower Hamlets, Westminster
)

outer_london_codes <- c(
  "E09000002", "E09000003", "E09000004", "E09000005", "E09000006",
  "E09000008", "E09000009", "E09000010", "E09000011", "E09000015",
  "E09000016", "E09000017", "E09000018", "E09000021", "E09000024",
  "E09000026", "E09000027", "E09000029", "E09000031", "E09000032"
)

# Fringe: selected LAs in surrounding counties
# Berkshire UAs, parts of Hertfordshire, Surrey, Essex, Kent, Sussex, Beds, Bucks
fringe_codes <- c(
  # Berkshire UAs
  "E06000036", "E06000037", "E06000038", "E06000039", "E06000040", "E06000041",
  # Hertfordshire districts
  "E07000095", "E07000096", "E07000098", "E07000099", "E07000102",
  "E07000103", "E07000240",
  # Surrey districts
  "E07000207", "E07000208", "E07000209", "E07000210", "E07000211",
  "E07000212", "E07000213", "E07000214",
  # Essex districts near London
  "E07000066", "E07000067", "E07000068", "E07000069", "E07000070",
  "E07000071", "E07000072", "E07000073", "E07000074", "E07000075",
  "E07000076", "E07000077",
  # Kent districts near London
  "E07000105", "E07000106", "E07000108", "E07000109", "E07000110",
  "E07000111", "E07000112", "E07000113",
  # West Sussex
  "E07000223", "E07000224", "E07000225", "E07000226", "E07000227",
  "E07000228", "E07000229",
  # Buckinghamshire UA
  "E06000060",
  # Beds UAs
  "E06000055", "E06000056", "E06000032"
)

la_band_map <- data.table(
  la_code = c(inner_london_codes, outer_london_codes, fringe_codes),
  band = c(
    rep("inner_london", length(inner_london_codes)),
    rep("outer_london", length(outer_london_codes)),
    rep("fringe", length(fringe_codes))
  )
)

fwrite(la_band_map, paste0(data_dir, "la_band_mapping.csv"))
cat(sprintf("  Band mapping: %d Inner London, %d Outer London, %d Fringe LAs\n",
            length(inner_london_codes), length(outer_london_codes), length(fringe_codes)))

###############################################################################
# 6. NOMIS — LA-level covariates for Bartik instrument
###############################################################################

cat("\n=== FETCHING LABOUR MARKET COVARIATES ===\n\n")

# BRES (Business Register and Employment Survey) — employment by industry by LA
# We need baseline (2010) industry employment shares for Bartik instrument
cat("Fetching BRES industry employment shares (2010 baseline)...\n")
bres_file <- paste0(data_dir, "bres_industry_2010.csv")
if (!file.exists(bres_file)) {
  # BRES dataset NM_189_1 — employees by industry section by LA
  bres_url <- paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/NM_189_1.data.csv?",
    "date=2010",
    "&geography=TYPE464",
    "&industry=150994945...150994965",  # SIC sections A-U
    "&employment_status=1",  # Employees
    "&measures=20100",
    "&select=date_name,geography_name,geography_code,industry_name,obs_value"
  )
  tryCatch({
    bres_raw <- fread(bres_url, showProgress = FALSE)
    if (nrow(bres_raw) > 0) {
      setnames(bres_raw, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                            "INDUSTRY_NAME", "OBS_VALUE"),
               c("date_label", "la_name", "la_code", "industry", "employment"))
      bres_raw <- bres_raw[grepl("^E", la_code)]
      bres_raw[, employment := as.numeric(employment)]
      fwrite(bres_raw, bres_file)
      cat(sprintf("  BRES 2010: %d rows, %d LAs, %d industries\n",
                  nrow(bres_raw), uniqueN(bres_raw$la_code),
                  uniqueN(bres_raw$industry)))
    }
  }, error = function(e) {
    cat(sprintf("  BRES fetch failed: %s\n", e$message))
  })
} else {
  cat("  BRES file already exists.\n")
}

# National industry wage growth (ASHE by industry, for Bartik)
cat("Fetching national ASHE by industry (for Bartik)...\n")
ashe_ind_file <- paste0(data_dir, "ashe_industry_national.csv")
if (!file.exists(ashe_ind_file)) {
  ind_list <- list()
  for (yr in 2010:2023) {
    url <- paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/NM_99_1.data.csv?",
      "date=", yr,
      "&geography=2092957699",  # Great Britain
      "&sex=7",
      "&item=2",
      "&pay=7",
      "&industry=150994945...150994965",  # SIC sections A-U
      "&measures=20100",
      "&select=date_name,geography_name,industry_name,obs_value"
    )
    tryCatch({
      tmp <- fread(url, showProgress = FALSE)
      if (nrow(tmp) > 0) {
        tmp[, year := yr]
        ind_list[[as.character(yr)]] <- tmp
      }
    }, error = function(e) {
      # Silently skip
    })
    Sys.sleep(0.3)
  }

  if (length(ind_list) > 0) {
    ashe_ind <- rbindlist(ind_list, fill = TRUE)
    setnames(ashe_ind, c("DATE_NAME", "GEOGRAPHY_NAME", "INDUSTRY_NAME",
                          "OBS_VALUE", "year"),
             c("date_label", "geo", "industry", "national_median_pay", "year"))
    ashe_ind[, national_median_pay := as.numeric(national_median_pay)]
    fwrite(ashe_ind, ashe_ind_file)
    cat(sprintf("  ASHE by industry (national): %d rows\n", nrow(ashe_ind)))
  } else {
    cat("  National ASHE by industry not available.\n")
  }
} else {
  cat("  ASHE industry file already exists.\n")
}

# Economic activity rate by LA (covariate)
cat("Fetching economic activity rates...\n")
econ_file <- paste0(data_dir, "econ_activity_by_la.csv")
if (!file.exists(econ_file)) {
  econ_list <- list()
  for (yr in 2010:2023) {
    url <- paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?",
      "date=", yr, "12",
      "&geography=TYPE464",
      "&variable=45",
      "&measures=20100",
      "&select=date_name,geography_name,geography_code,obs_value"
    )
    tryCatch({
      tmp <- fread(url, showProgress = FALSE)
      if (nrow(tmp) > 0) {
        tmp[, year := yr]
        econ_list[[as.character(yr)]] <- tmp
      }
    }, error = function(e) {
      # Silently skip
    })
    Sys.sleep(0.3)
  }

  if (length(econ_list) > 0) {
    econ_act <- rbindlist(econ_list, fill = TRUE)
    setnames(econ_act, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                          "OBS_VALUE", "year"),
             c("date_label", "la_name", "la_code", "econ_activity_rate", "year"))
    econ_act <- econ_act[grepl("^E", la_code)]
    econ_act[, econ_activity_rate := as.numeric(econ_activity_rate)]
    fwrite(econ_act, econ_file)
    cat(sprintf("  Economic activity: %d rows\n", nrow(econ_act)))
  }
} else {
  cat("  Economic activity file already exists.\n")
}

###############################################################################
# Summary
###############################################################################

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Files in data directory:\n")
for (f in sort(list.files(data_dir))) {
  sz <- file.size(paste0(data_dir, f))
  cat(sprintf("  %-45s %s\n", f, format(sz, big.mark = ",")))
}
