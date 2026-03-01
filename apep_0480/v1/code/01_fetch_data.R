##############################################################################
# 01_fetch_data.R — Data acquisition for apep_0480
# Sources: Gambling Commission, Home Office (CSP crime), Land Registry,
#          NOMIS (claimant count + population), ONS (IMD 2019)
##############################################################################

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 1. GAMBLING COMMISSION — Licensing Authority Statistics (329 LAs, 2015-2025)
# ============================================================================
cat("\n=== Fetching Gambling Commission LA Statistics ===\n")

gc_url <- "https://assets.ctfassets.net/j16ev64qyf6l/7ilk3faYgiWQ9cAQEwTnpo/893072234c2e9787359787431c4e0af7/Licensing_Authority_Statistics_-_01_April_2015_-_31_March_2025.xlsx"
gc_file <- file.path(data_dir, "gc_la_statistics.xlsx")

if (!file.exists(gc_file)) {
  tryCatch({
    resp <- request(gc_url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(120) |>
      req_perform()
    writeBin(resp_body_raw(resp), gc_file)
    cat("  Downloaded GC LA statistics:", round(file.size(gc_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already downloaded:", round(file.size(gc_file) / 1e6, 1), "MB\n")
}

# ============================================================================
# 2. HOME OFFICE — Police Recorded Crime by CSP (pre-aggregated)
# ============================================================================
cat("\n=== Fetching Home Office CSP Crime Data ===\n")

# Two files covering 2016-2025 at CSP level (≈ local authority)
crime_urls <- list(
  early = "https://assets.publishing.service.gov.uk/media/6977911a3fd50ac304b79763/prc-csp-mar16-mar20-tables-290126.ods",
  late  = "https://assets.publishing.service.gov.uk/media/6977916e3fd50ac304b79765/prc-csp-mar21-sep25-tables-290126.ods"
)

for (nm in names(crime_urls)) {
  ext <- tools::file_ext(crime_urls[[nm]])
  out_file <- file.path(data_dir, paste0("crime_csp_", nm, ".", ext))
  if (!file.exists(out_file)) {
    cat("  Downloading crime CSP (", nm, ")...\n")
    tryCatch({
      resp <- request(crime_urls[[nm]]) |>
        req_headers("User-Agent" = "APEP-Research/1.0") |>
        req_timeout(300) |>
        req_perform()
      writeBin(resp_body_raw(resp), out_file)
      cat("    OK:", round(file.size(out_file) / 1e6, 1), "MB\n")
    }, error = function(e) {
      cat("    ERROR:", conditionMessage(e), "\n")
    })
  } else {
    cat("  Already have:", nm, "(", round(file.size(out_file) / 1e6, 1), "MB)\n")
  }
}

# Also fetch the ONS CSP-level crime data (has crime rates per 1000)
ons_csp_url <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/crimeandjustice/datasets/recordedcrimedatabycommunitysafetypartnershiparea/yearendingmarch2024/csptablesyemar24correction.xlsx"
ons_csp_file <- file.path(data_dir, "ons_csp_crime_ye_mar2024.xlsx")

if (!file.exists(ons_csp_file)) {
  cat("  Downloading ONS CSP crime data...\n")
  tryCatch({
    resp <- request(ons_csp_url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(120) |>
      req_perform()
    writeBin(resp_body_raw(resp), ons_csp_file)
    cat("    OK:", round(file.size(ons_csp_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("    ERROR:", conditionMessage(e), "\n")
  })
}

# Geographic reference table for CSP → LA mapping
geo_ref_url <- "https://assets.publishing.service.gov.uk/media/679790f63fd50ac304b79767/prc-geog-ref-table-290126.csv"
geo_ref_file <- file.path(data_dir, "crime_csp_geo_ref.csv")

if (!file.exists(geo_ref_file)) {
  cat("  Downloading CSP geographic reference...\n")
  tryCatch({
    resp <- request(geo_ref_url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(60) |>
      req_perform()
    writeBin(resp_body_raw(resp), geo_ref_file)
    cat("    OK:", file.size(geo_ref_file), "bytes\n")
  }, error = function(e) {
    cat("    ERROR:", conditionMessage(e), "\n")
  })
}

# Offence reference table
offence_ref_url <- "https://assets.publishing.service.gov.uk/media/6977908693ab96010b6c5879/prc-offence-ref-table-290126.ods"
offence_ref_file <- file.path(data_dir, "crime_offence_ref.ods")

if (!file.exists(offence_ref_file)) {
  cat("  Downloading offence reference...\n")
  tryCatch({
    resp <- request(offence_ref_url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(60) |>
      req_perform()
    writeBin(resp_body_raw(resp), offence_ref_file)
    cat("    OK:", file.size(offence_ref_file), "bytes\n")
  }, error = function(e) {
    cat("    ERROR:", conditionMessage(e), "\n")
  })
}

# ============================================================================
# 3. HM LAND REGISTRY — Price Paid Data (annual CSVs, 2015-2024)
# ============================================================================
cat("\n=== Fetching Land Registry Price Paid Data ===\n")

lr_dir <- file.path(data_dir, "land_registry")
dir.create(lr_dir, showWarnings = FALSE)

for (yr in 2015:2024) {
  csv_file <- file.path(lr_dir, paste0("pp-", yr, ".csv"))
  if (file.exists(csv_file)) {
    cat("  Already have:", yr, "(", round(file.size(csv_file) / 1e6, 1), "MB)\n")
    next
  }
  url <- paste0("http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-", yr, ".csv")
  cat("  Downloading Land Registry", yr, "...")
  tryCatch({
    resp <- request(url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(600) |>
      req_perform()
    writeBin(resp_body_raw(resp), csv_file)
    cat(" OK (", round(file.size(csv_file) / 1e6, 1), "MB)\n")
    Sys.sleep(1)
  }, error = function(e) {
    cat(" FAILED:", conditionMessage(e), "\n")
  })
}

# ============================================================================
# 4. NOMIS — DWP Claimant Count by Local Authority (monthly)
# ============================================================================
cat("\n=== Fetching NOMIS Claimant Count ===\n")

cc_file <- file.path(data_dir, "nomis_claimant_count.csv")
if (!file.exists(cc_file)) {
  tryCatch({
    url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv?geography=TYPE464&sex=0&age=0&measures=20100&time=2015-01-2024-06"
    resp <- request(url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(120) |>
      req_perform()
    writeLines(resp_body_string(resp), cc_file)
    cat("  Downloaded claimant count\n")
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already downloaded\n")
}

# ============================================================================
# 5. NOMIS — Mid-Year Population Estimates by LA (annual)
# ============================================================================
cat("\n=== Fetching NOMIS Population Estimates ===\n")

pop_file <- file.path(data_dir, "nomis_population.csv")
if (!file.exists(pop_file)) {
  tryCatch({
    url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=TYPE464&gender=0&age=200&measures=20100&time=2015-2023"
    resp <- request(url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(120) |>
      req_perform()
    writeLines(resp_body_string(resp), pop_file)
    cat("  Downloaded population estimates\n")
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already downloaded\n")
}

# ============================================================================
# 6. IMD 2019 — English Index of Multiple Deprivation (LA summaries)
# ============================================================================
cat("\n=== Fetching IMD 2019 ===\n")

imd_file <- file.path(data_dir, "imd_2019_la.xlsx")
if (!file.exists(imd_file)) {
  imd_url <- "https://assets.publishing.service.gov.uk/media/5d8b387740f0b6188537215d/File_10_-_IoD2019_Local_Authority_District_Summaries__lower-tier__.xlsx"
  tryCatch({
    resp <- request(imd_url) |>
      req_headers("User-Agent" = "APEP-Research/1.0") |>
      req_timeout(60) |>
      req_perform()
    writeBin(resp_body_raw(resp), imd_file)
    cat("  Downloaded IMD 2019:", round(file.size(imd_file) / 1e6, 1), "MB\n")
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already downloaded\n")
}

# ============================================================================
# SUMMARY
# ============================================================================
cat("\n=== Data Fetch Complete ===\n")
cat("Files in data directory:\n")
all_files <- list.files(data_dir, recursive = TRUE)
for (f in all_files) {
  full <- file.path(data_dir, f)
  cat(sprintf("  %-50s %s\n", f, paste0(round(file.size(full) / 1e6, 1), " MB")))
}
