###############################################################################
# 01_fetch_data.R — Fetch real data from UK public APIs
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# 1. NOMIS ASHE — Median annual gross pay by LA district
###############################################################################

cat("Fetching NOMIS ASHE earnings data...\n")

ashe_years <- 2005:2023
ashe_list <- list()

for (yr in ashe_years) {
  url <- paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/NM_99_1.data.csv?",
    "date=", yr,
    "&geography=TYPE464",
    "&sex=7",        # All
    "&item=2",       # Median
    "&pay=7",        # Annual gross pay
    "&measures=20100",
    "&select=date_name,geography_name,geography_code,obs_value"
  )
  tryCatch({
    tmp <- fread(url, showProgress = FALSE)
    if (nrow(tmp) > 0) {
      tmp[, year := yr]
      ashe_list[[as.character(yr)]] <- tmp
      cat(sprintf("  %d: %d LAs\n", yr, nrow(tmp)))
    }
  }, error = function(e) {
    cat(sprintf("  %d: FAILED - %s\n", yr, e$message))
  })
  Sys.sleep(0.3)
}

ashe_raw <- rbindlist(ashe_list, fill = TRUE)
setnames(ashe_raw, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                      "OBS_VALUE", "year"),
         c("date_label", "la_name", "la_code", "median_annual_pay", "year"))

# Keep only English LAs (codes starting with E)
ashe_raw <- ashe_raw[grepl("^E", la_code)]
ashe_raw[, median_annual_pay := as.numeric(median_annual_pay)]

fwrite(ashe_raw, paste0(data_dir, "ashe_earnings_by_la.csv"))
cat(sprintf("ASHE: %d rows, %d LAs, years %d-%d\n",
            nrow(ashe_raw), uniqueN(ashe_raw$la_code),
            min(ashe_raw$year), max(ashe_raw$year)))

###############################################################################
# 2. DfE KS4 Performance — GCSE results by LA
###############################################################################

cat("\nFetching DfE KS4 GCSE performance data...\n")

ks4_url <- "https://api.education.gov.uk/statistics/v1/data-sets/b3e19901-5d2b-b676-bb4c-e60937d74725/csv"

ks4_file <- paste0(data_dir, "ks4_la_raw.csv")
if (!file.exists(ks4_file)) {
  tryCatch({
    download.file(ks4_url, ks4_file, mode = "wb", quiet = TRUE)
    cat("  KS4 LA-level data downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  KS4 download failed: %s\n", e$message))
    cat("  Trying alternative download method...\n")
    resp <- httr2::request(ks4_url) |>
      httr2::req_timeout(120) |>
      httr2::req_perform()
    writeBin(httr2::resp_body_raw(resp), ks4_file)
    cat("  KS4 downloaded via httr2.\n")
  })
} else {
  cat("  KS4 file already exists, skipping download.\n")
}

ks4_raw <- fread(ks4_file, showProgress = FALSE)
cat(sprintf("KS4: %d rows, %d columns\n", nrow(ks4_raw), ncol(ks4_raw)))

fwrite(ks4_raw, paste0(data_dir, "ks4_la_performance.csv"))

###############################################################################
# 3. DfE SWC — Teacher vacancies by LA
###############################################################################

cat("\nFetching DfE School Workforce Census — vacancies...\n")

swc_vac_url <- "https://api.education.gov.uk/statistics/v1/data-sets/8359504b-0506-47b8-8237-c9ee4f082b1e/csv"

swc_file <- paste0(data_dir, "swc_vacancies_raw.csv")
if (!file.exists(swc_file)) {
  tryCatch({
    download.file(swc_vac_url, swc_file, mode = "wb", quiet = TRUE)
    cat("  SWC vacancies downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  SWC API download unavailable (%s)\n", e$message))
    cat("  NOTE: SWC data requires manual download from EES portal.\n")
    cat("  Constructing vacancy proxy from NOMIS education employment data.\n")
  })
}

if (file.exists(swc_file)) {
  swc_raw <- fread(swc_file, showProgress = FALSE)
  cat(sprintf("SWC vacancies: %d rows, %d columns\n", nrow(swc_raw), ncol(swc_raw)))
} else {
  cat("  SWC vacancy data not available. Will use NOMIS proxy.\n")
}

###############################################################################
# 4. DfE SWC — Teacher retention by LA
###############################################################################

cat("\nFetching DfE School Workforce Census — retention...\n")

swc_ret_url <- "https://api.education.gov.uk/statistics/v1/data-sets/a7cbf34c-9a81-4643-aba8-45b78e3e9809/csv"

ret_file <- paste0(data_dir, "swc_retention_raw.csv")
if (!file.exists(ret_file)) {
  tryCatch({
    download.file(swc_ret_url, ret_file, mode = "wb", quiet = TRUE)
    cat("  SWC retention downloaded.\n")
  }, error = function(e) {
    cat(sprintf("  SWC retention API unavailable (%s)\n", e$message))
    cat("  NOTE: SWC retention requires manual download.\n")
  })
}

if (file.exists(ret_file)) {
  swc_ret <- fread(ret_file, showProgress = FALSE)
  cat(sprintf("SWC retention: %d rows, %d columns\n", nrow(swc_ret), ncol(swc_ret)))
} else {
  cat("  SWC retention data not available.\n")
}

###############################################################################
# 5. Teacher Pay Scales (STPCD) — Manual construction
###############################################################################

cat("\nConstructing teacher pay scales from STPCD...\n")

# Main pay scale, point M1 (starting salary) for Rest of England
# Source: published STPCD annual updates from DfE
stpcd <- data.table(
  year = 2005:2023,
  m1_rest = c(19161, 19641, 20133, 20627, 21102, 21588, 21588, 21588,
              21804, 22023, 22244, 22467, 23720, 24373, 25714, 25714,
              25714, 28000, 30000),
  m6_rest = c(28005, 28707, 29427, 30148, 30842, 31552, 31552, 31552,
              31868, 32187, 32509, 32831, 33824, 35971, 38174, 38174,
              38174, 38810, 41333)
)

# Midpoint of the main pay scale as typical teacher salary
stpcd[, teacher_pay_mid := (m1_rest + m6_rest) / 2]

fwrite(stpcd, paste0(data_dir, "stpcd_pay_scales.csv"))
cat(sprintf("STPCD: %d years, M1 range £%s-£%s\n",
            nrow(stpcd),
            format(min(stpcd$m1_rest), big.mark = ","),
            format(max(stpcd$m1_rest), big.mark = ",")))

###############################################################################
# 6. NOMIS — Additional LA covariates (unemployment, economic activity)
###############################################################################

cat("\nFetching NOMIS labour market covariates...\n")

# Annual Population Survey — economic activity rate by LA
covariates_list <- list()
for (yr in 2005:2023) {
  url <- paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/NM_17_5.data.csv?",
    "date=", yr, "12",
    "&geography=TYPE464",
    "&variable=45",  # Economic activity rate (16-64)
    "&measures=20100",
    "&select=date_name,geography_name,geography_code,obs_value"
  )
  tryCatch({
    tmp <- fread(url, showProgress = FALSE)
    if (nrow(tmp) > 0) {
      tmp[, year := yr]
      covariates_list[[as.character(yr)]] <- tmp
    }
  }, error = function(e) {
    # Silently skip failed years
  })
  Sys.sleep(0.3)
}

if (length(covariates_list) > 0) {
  econ_activity <- rbindlist(covariates_list, fill = TRUE)
  setnames(econ_activity, c("DATE_NAME", "GEOGRAPHY_NAME", "GEOGRAPHY_CODE",
                            "OBS_VALUE", "year"),
           c("date_label", "la_name", "la_code",
             "econ_activity_rate", "year"))
  econ_activity <- econ_activity[grepl("^E", la_code)]
  econ_activity[, econ_activity_rate := as.numeric(econ_activity_rate)]
  fwrite(econ_activity, paste0(data_dir, "econ_activity_by_la.csv"))
  cat(sprintf("Economic activity: %d rows\n", nrow(econ_activity)))
} else {
  cat("  Warning: Could not fetch economic activity data.\n")
}

###############################################################################
# Summary
###############################################################################

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Files saved in: ", normalizePath(data_dir), "\n")
list.files(data_dir, pattern = "\\.csv$")
