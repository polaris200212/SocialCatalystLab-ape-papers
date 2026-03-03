################################################################################
# 01_fetch_data.R — Data Acquisition
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
#
# Data sources:
#   1. T-MSIS Medicaid Provider Spending (local Parquet, 2.74 GB)
#   2. NPPES Bulk Extract (local Parquet or build from CMS download)
#   3. FEC Individual Contributions (bulk download from fec.gov)
#   4. Medicare Physician/Supplier PUF (data.cms.gov Socrata API)
#   5. Census ACS 5-Year (tidycensus API)
#   6. FRED state unemployment (fredr API)
################################################################################

source("00_packages.R")

cat("=== Step 1: Load T-MSIS ===\n")

# Open T-MSIS Parquet lazily (Arrow — no memory load)
tmsis_path <- file.path(DATA_DIR, "tmsis.parquet")
stopifnot(file.exists(tmsis_path))
tmsis <- open_dataset(tmsis_path)

cat("T-MSIS Parquet opened. Schema:\n")
print(tmsis$schema)

# Build provider-level annual summary from T-MSIS
# Aggregate: billing NPI × year → total paid, total claims, total beneficiaries
cat("Building provider × year Medicaid summary...\n")
provider_medicaid <- tmsis |>
  mutate(year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4))) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year) |>
  summarise(
    medicaid_paid = sum(TOTAL_PAID, na.rm = TRUE),
    medicaid_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    medicaid_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect()

setDT(provider_medicaid)
setnames(provider_medicaid, "BILLING_PROVIDER_NPI_NUM", "npi")
cat("Provider × year Medicaid summary:", nrow(provider_medicaid), "rows,",
    uniqueN(provider_medicaid$npi), "unique NPIs\n")

# Also compute HCBS-specific revenue (T/H/S codes)
cat("Building HCBS-specific revenue...\n")
provider_hcbs <- tmsis |>
  filter(grepl("^[THS]", HCPCS_CODE)) |>
  mutate(year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4))) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year) |>
  summarise(
    hcbs_paid = sum(TOTAL_PAID, na.rm = TRUE),
    hcbs_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect()

setDT(provider_hcbs)
setnames(provider_hcbs, "BILLING_PROVIDER_NPI_NUM", "npi")

# Merge HCBS flag
provider_medicaid <- merge(provider_medicaid, provider_hcbs,
                           by = c("npi", "year"), all.x = TRUE)
provider_medicaid[is.na(hcbs_paid), hcbs_paid := 0]
provider_medicaid[is.na(hcbs_claims), hcbs_claims := 0]
provider_medicaid[, hcbs_share := hcbs_paid / fifelse(medicaid_paid > 0, medicaid_paid, 1)]

cat("T-MSIS processing complete.\n\n")

# ============================================================================
cat("=== Step 2: Load/Build NPPES Extract ===\n")

nppes_path <- file.path(DATA_DIR, "nppes_extract.parquet")

if (file.exists(nppes_path)) {
  cat("Loading existing NPPES extract...\n")
  nppes <- read_parquet(nppes_path) |> setDT()
} else {
  cat("NPPES extract not found. Downloading from CMS...\n")
  # Download NPPES full replacement monthly file
  nppes_url <- "https://download.cms.gov/nppes/NPI_Files.html"
  stop("NPPES bulk file must be downloaded manually from CMS. ",
       "Download the Full Replacement Monthly NPI File from:\n",
       nppes_url, "\n",
       "Then run the NPPES extraction code in template_01_load_data.R")
}

# Ensure NPI is character (T-MSIS has character NPI)
nppes[, npi := as.character(npi)]

# Rename NPPES columns to analysis names
# The NPPES extract uses: state, zip5, taxonomy_1
# We rename to: practice_state, practice_zip5, taxonomy_code
if ("state" %in% names(nppes) & !"practice_state" %in% names(nppes)) {
  setnames(nppes, "state", "practice_state")
}
if ("zip5" %in% names(nppes) & !"practice_zip5" %in% names(nppes)) {
  setnames(nppes, "zip5", "practice_zip5")
}
if ("taxonomy_1" %in% names(nppes) & !"taxonomy_code" %in% names(nppes)) {
  setnames(nppes, "taxonomy_1", "taxonomy_code")
}

# Ensure key fields
required_cols <- c("npi", "entity_type", "last_name", "first_name",
                   "practice_state", "practice_zip5", "taxonomy_code",
                   "credential", "gender")
missing <- setdiff(required_cols, names(nppes))
if (length(missing) > 0) {
  cat("WARNING: Missing NPPES columns:", paste(missing, collapse = ", "), "\n")
}

# Filter to individual providers (Entity Type 1) for name matching
nppes_individuals <- nppes[entity_type == "1"]
cat("NPPES individuals:", nrow(nppes_individuals), "providers\n")

# Select available NPPES columns for merge
nppes_merge_cols <- intersect(
  c("npi", "entity_type", "practice_state", "practice_zip5", "taxonomy_code",
    "credential", "gender", "last_name", "first_name"),
  names(nppes)
)

# Merge T-MSIS with NPPES to get state assignment
provider_panel <- merge(provider_medicaid, nppes[, ..nppes_merge_cols],
                        by = "npi", all.x = TRUE)

cat("Matched to NPPES:", sum(!is.na(provider_panel$practice_state)), "of",
    nrow(provider_panel), "rows\n\n")

# ============================================================================
cat("=== Step 3: Download FEC Individual Contributions ===\n")

# FEC bulk data: individual contributions for each election cycle
# Files are at: https://www.fec.gov/files/bulk-downloads/20XX/indivXX.zip
fec_dir <- file.path(LOCAL_DATA, "fec")
dir.create(fec_dir, recursive = TRUE, showWarnings = FALSE)

# Election cycles covering T-MSIS period (2018-2024)
cycles <- c(2018, 2020, 2022, 2024)

download_fec_cycle <- function(cycle, dest_dir) {
  yr <- substr(cycle, 3, 4)
  zip_file <- file.path(dest_dir, paste0("indiv", yr, ".zip"))
  txt_file <- file.path(dest_dir, paste0("itcont_", cycle, ".txt"))

  if (file.exists(txt_file)) {
    cat("  FEC", cycle, "already downloaded.\n")
    return(invisible(NULL))
  }

  # Use direct S3 URL (avoids redirect issues with R's download.file)
  url <- paste0("https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/",
                 cycle, "/indiv", yr, ".zip")
  cat("  Downloading FEC", cycle, "from S3...\n")

  # Use system curl with -L (follow redirects) for reliability
  exit_code <- system2("curl", args = c("-L", "-o", shQuote(zip_file),
                                         "--progress-bar", shQuote(url)),
                        stdout = "", stderr = "")

  if (exit_code == 0 && file.exists(zip_file) && file.size(zip_file) > 1000) {
    cat("  Extracting FEC", cycle, "...\n")
    unzip(zip_file, exdir = dest_dir)
    extracted <- list.files(dest_dir, pattern = "^itcont\\.txt$", full.names = TRUE)
    if (length(extracted) > 0) {
      file.rename(extracted[1], txt_file)
    }
    unlink(zip_file)
    cat("  FEC", cycle, "downloaded and extracted.\n")
  } else {
    cat("  FAILED to download FEC", cycle, ".\n")
    cat("  Please download manually from https://www.fec.gov/data/browse-data/?tab=bulk-data\n")
    unlink(zip_file)
  }
}

for (cyc in cycles) {
  download_fec_cycle(cyc, fec_dir)
}

# Parse FEC bulk files
# FEC individual contribution format (pipe-delimited, no header):
# https://www.fec.gov/campaign-finance-data/contributions-individuals-file-description/
fec_cols <- c("CMTE_ID", "AMNDT_IND", "RPT_TP", "TRANSACTION_PGI",
              "IMAGE_NUM", "TRANSACTION_TP", "ENTITY_TP", "NAME",
              "CITY", "STATE", "ZIP_CODE", "EMPLOYER", "OCCUPATION",
              "TRANSACTION_DT", "TRANSACTION_AMT", "OTHER_ID",
              "TRAN_ID", "FILE_NUM", "MEMO_CD", "MEMO_TEXT", "SUB_ID")

parse_fec_cycle <- function(cycle, fec_dir) {
  yr <- substr(cycle, 3, 4)
  txt_file <- file.path(fec_dir, paste0("itcont_", cycle, ".txt"))

  if (!file.exists(txt_file)) {
    cat("  FEC", cycle, "file not found. Skipping.\n")
    return(NULL)
  }

  cat("  Parsing FEC", cycle, "...\n")

  # Read with fread (fast, handles pipe-delimited)
  # Select columns: CMTE_ID(1), NAME(8), CITY(9), STATE(10), ZIP_CODE(11),
  #                  EMPLOYER(12), OCCUPATION(13), TRANSACTION_DT(14), TRANSACTION_AMT(15)
  selected_cols <- c(1, 8:15)
  selected_names <- fec_cols[selected_cols]
  dt <- fread(txt_file, sep = "|", header = FALSE, quote = "",
              select = selected_cols,
              col.names = selected_names)

  # Filter to healthcare-related occupations
  health_occupations <- c("PHYSICIAN", "DOCTOR", "SURGEON", "NURSE",
                          "THERAPIST", "PSYCHOLOGIST", "PSYCHIATRIST",
                          "SOCIAL WORKER", "COUNSELOR", "PHARMACIST",
                          "DENTIST", "OPTOMETRIST", "PODIATRIST",
                          "HOME HEALTH", "HEALTH CARE", "HEALTHCARE",
                          "MEDICAL", "HOSPITAL", "CLINIC",
                          "CHIROPRACTOR", "VETERINARIAN",
                          "REGISTERED NURSE", "NURSE PRACTITIONER",
                          "PHYSICAL THERAPIST", "OCCUPATIONAL THERAPIST",
                          "SPEECH THERAPIST", "RESPIRATORY THERAPIST",
                          "CERTIFIED NURSING", "CAREGIVER",
                          "BEHAVIORAL HEALTH", "MENTAL HEALTH")

  pattern <- paste(health_occupations, collapse = "|")

  dt_health <- dt[grepl(pattern, OCCUPATION, ignore.case = TRUE) |
                   grepl(pattern, EMPLOYER, ignore.case = TRUE)]

  # Parse name field (format: "LAST, FIRST MIDDLE")
  dt_health[, `:=`(
    donor_last = str_trim(str_extract(NAME, "^[^,]+")),
    donor_first = str_trim(str_extract(NAME, "(?<=,\\s?)\\S+")),
    donor_state = STATE,
    donor_zip5 = substr(ZIP_CODE, 1, 5),
    amount = as.numeric(TRANSACTION_AMT),
    date = TRANSACTION_DT,
    committee_id = CMTE_ID,
    cycle = cycle
  )]

  dt_health <- dt_health[!is.na(donor_last) & !is.na(donor_first)]

  cat("    Healthcare donations:", nrow(dt_health), "records\n")
  return(dt_health[, .(donor_last, donor_first, donor_state, donor_zip5,
                       OCCUPATION, EMPLOYER, amount, date, committee_id, cycle)])
}

cat("Parsing FEC bulk files...\n")
fec_list <- lapply(cycles, parse_fec_cycle, fec_dir = fec_dir)
fec_all <- rbindlist(fec_list[!sapply(fec_list, is.null)])
cat("Total healthcare FEC records:", nrow(fec_all), "\n")
cat("Unique donors (name × state × zip):",
    uniqueN(fec_all, by = c("donor_last", "donor_first", "donor_state", "donor_zip5")), "\n\n")

# ============================================================================
cat("=== Step 4: Download Medicare Physician PUF ===\n")

# Medicare Physician & Other Suppliers PUF from data.cms.gov
# We need this for cross-payer revenue denominator
medicare_dir <- file.path(LOCAL_DATA, "medicare_puf")
dir.create(medicare_dir, recursive = TRUE, showWarnings = FALSE)

# Use Socrata API to get summary by NPI
# API endpoint: https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners
# Dataset ID varies by year

fetch_medicare_puf <- function(year, dest_dir) {
  outfile <- file.path(dest_dir, paste0("medicare_puf_", year, ".parquet"))
  if (file.exists(outfile)) {
    cat("  Medicare PUF", year, "already exists.\n")
    return(read_parquet(outfile) |> setDT())
  }

  # CMS data.gov Socrata endpoints
  # These dataset IDs are for the Provider Utilization and Payment Data
  datasets <- list(
    "2018" = "https://data.cms.gov/data-api/v1/dataset/a29c69cb-8e4c-4636-8d74-0abfeb8c9a42/data",
    "2019" = "https://data.cms.gov/data-api/v1/dataset/c175441d-87b2-400b-a27f-c11b47ecef72/data",
    "2020" = "https://data.cms.gov/data-api/v1/dataset/b76f69ff-a3da-4be5-aece-b2c7a7e69e73/data",
    "2021" = "https://data.cms.gov/data-api/v1/dataset/8889d81e-5c7e-4c09-8a57-1f257bf3aa49/data",
    "2022" = "https://data.cms.gov/data-api/v1/dataset/94463e7f-e8a6-48c5-8e12-5e7b5e5ed8d4/data"
  )

  url <- datasets[[as.character(year)]]
  if (is.null(url)) {
    cat("  No Medicare PUF endpoint for", year, "— skipping.\n")
    return(NULL)
  }

  cat("  Fetching Medicare PUF", year, "...\n")

  # Paginate through the API (max 5000 rows per request)
  all_data <- list()
  offset <- 0
  page_size <- 5000

  repeat {
    req_url <- paste0(url, "?size=", page_size, "&offset=", offset)
    resp <- tryCatch(
      fromJSON(req_url, flatten = TRUE),
      error = function(e) {
        cat("    Error at offset", offset, ":", conditionMessage(e), "\n")
        return(NULL)
      }
    )

    if (is.null(resp) || length(resp) == 0 || nrow(resp) == 0) break
    all_data[[length(all_data) + 1]] <- resp
    offset <- offset + page_size
    if (nrow(resp) < page_size) break
    if (offset > 2000000) break  # Safety limit
    if (offset %% 50000 == 0) cat("    Fetched", offset, "rows...\n")
  }

  if (length(all_data) == 0) {
    cat("  No data returned for Medicare PUF", year, "\n")
    return(NULL)
  }

  dt <- rbindlist(all_data, fill = TRUE)
  cat("  Medicare PUF", year, ":", nrow(dt), "rows\n")

  # Select key fields and aggregate to NPI level
  npi_col <- intersect(c("Rndrng_NPI", "rndrng_npi", "npi"), names(dt))
  pay_col <- intersect(c("Avg_Mdcr_Pymt_Amt", "avg_mdcr_pymt_amt",
                          "Tot_Mdcr_Pymt_Amt", "tot_mdcr_pymt_amt"), names(dt))
  svc_col <- intersect(c("Tot_Srvcs", "tot_srvcs"), names(dt))

  if (length(npi_col) > 0 && length(pay_col) > 0) {
    setnames(dt, npi_col[1], "npi", skip_absent = TRUE)
    setnames(dt, pay_col[1], "medicare_paid", skip_absent = TRUE)
    if (length(svc_col) > 0) setnames(dt, svc_col[1], "medicare_services", skip_absent = TRUE)

    dt[, medicare_paid := as.numeric(medicare_paid)]
    if ("medicare_services" %in% names(dt)) {
      dt[, medicare_services := as.numeric(medicare_services)]
    }

    # Aggregate to NPI level
    agg <- dt[, .(
      medicare_paid_total = sum(medicare_paid, na.rm = TRUE),
      medicare_services_total = if ("medicare_services" %in% names(.SD))
        sum(medicare_services, na.rm = TRUE) else NA_real_
    ), by = npi]

    agg[, year := year]
    write_parquet(agg, outfile)
    cat("  Saved:", outfile, "\n")
    return(agg)
  } else {
    cat("  Could not find NPI/payment columns. Available:", paste(names(dt)[1:10], collapse = ", "), "\n")
    return(NULL)
  }
}

cat("Fetching Medicare PUF (years with available endpoints)...\n")
medicare_list <- lapply(2018:2022, fetch_medicare_puf, dest_dir = medicare_dir)
medicare_all <- rbindlist(medicare_list[!sapply(medicare_list, is.null)], fill = TRUE)
if (nrow(medicare_all) == 0) {
  cat("WARNING: No Medicare PUF data retrieved. Will use Medicaid revenue alone.\n")
  cat("  Medicaid dependence will be measured as total Medicaid paid (continuous).\n")
} else {
  cat("Medicare PUF records:", nrow(medicare_all), "\n")
}
cat("\n")

# ============================================================================
cat("=== Step 5: Census ACS County Demographics ===\n")

acs_file <- file.path(LOCAL_DATA, "acs_county.parquet")

if (file.exists(acs_file)) {
  cat("Loading existing ACS data...\n")
  acs_county <- read_parquet(acs_file) |> setDT()
} else {
  cat("Fetching ACS 5-Year county data...\n")

  acs_vars <- c(
    total_pop = "B01003_001",
    median_income = "B19013_001",
    poverty_rate = "B17001_002",
    pct_uninsured = "B27010_001",
    pct_65plus = "B01001_020"  # Proxy: male 65-66
  )

  acs_list <- list()
  for (yr in 2018:2023) {
    tryCatch({
      dt <- get_acs(geography = "county", variables = acs_vars,
                     year = yr, survey = "acs5") |> setDT()
      dt[, year := yr]
      acs_list[[length(acs_list) + 1]] <- dt
      cat("  ACS", yr, ":", nrow(dt), "rows\n")
    }, error = function(e) {
      cat("  ACS", yr, "error:", conditionMessage(e), "\n")
    })
  }

  acs_county <- rbindlist(acs_list, fill = TRUE)
  acs_county[, fips := GEOID]

  # Pivot wider
  acs_wide <- dcast(acs_county, fips + year ~ variable, value.var = "estimate")
  write_parquet(acs_wide, acs_file)
  cat("ACS county data saved:", nrow(acs_wide), "rows\n")
  acs_county <- acs_wide
}

# ============================================================================
cat("=== Step 6: FRED State Unemployment ===\n")

fred_file <- file.path(LOCAL_DATA, "fred_state_unemp.parquet")

if (file.exists(fred_file)) {
  cat("Loading existing FRED data...\n")
  state_unemp <- read_parquet(fred_file) |> setDT()
} else {
  cat("Fetching state unemployment rates from FRED...\n")

  # State FIPS to FRED series mapping
  state_fips <- data.table(
    state = state.abb,
    fips = sprintf("%02d", match(state.abb, state.abb))
  )

  unemp_list <- list()
  for (st in state.abb) {
    series_id <- paste0(st, "UR")
    tryCatch({
      dt <- fredr(series_id = series_id,
                  observation_start = as.Date("2017-01-01"),
                  observation_end = as.Date("2025-01-01"),
                  frequency = "a") |> setDT()
      dt[, state := st]
      unemp_list[[length(unemp_list) + 1]] <- dt
    }, error = function(e) {
      cat("  FRED error for", st, ":", conditionMessage(e), "\n")
    })
  }

  if (length(unemp_list) > 0) {
    state_unemp <- rbindlist(unemp_list, fill = TRUE)
    state_unemp[, `:=`(year = year(date), unemp_rate = value)]
    state_unemp <- state_unemp[, .(state, year, unemp_rate)]
    write_parquet(state_unemp, fred_file)
    cat("FRED state unemployment saved:", nrow(state_unemp), "rows\n")
  } else {
    cat("WARNING: No FRED data retrieved. FRED_API_KEY may not be set.\n")
    state_unemp <- data.table(state = character(), year = integer(), unemp_rate = numeric())
    write_parquet(state_unemp, fred_file)
  }
}

# ============================================================================
cat("=== Step 7: FEC Committee-to-Candidate Linkage ===\n")

# Download committee master file to link committee_id → candidate_id → party
cm_file <- file.path(fec_dir, "committee_master.txt")
ccl_file <- file.path(fec_dir, "ccl.txt")

# Committee-Candidate Linkage file
for (cyc in c(2018, 2020, 2022, 2024)) {
  yr <- substr(cyc, 3, 4)
  ccl_out <- file.path(fec_dir, paste0("ccl_", cyc, ".txt"))
  cm_out <- file.path(fec_dir, paste0("cm_", cyc, ".txt"))
  cn_out <- file.path(fec_dir, paste0("cn_", cyc, ".txt"))

  if (!file.exists(ccl_out)) {
    ccl_url <- paste0("https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/",
                       cyc, "/ccl", yr, ".zip")
    tmp <- tempfile(fileext = ".zip")
    exit_code <- system2("curl", args = c("-L", "-s", "-o", shQuote(tmp), shQuote(ccl_url)),
                          stdout = "", stderr = "")
    if (exit_code == 0 && file.exists(tmp) && file.size(tmp) > 100) {
      unzip(tmp, exdir = fec_dir)
      extracted <- list.files(fec_dir, pattern = "^ccl\\.txt$", full.names = TRUE)
      if (length(extracted) > 0) file.rename(extracted[1], ccl_out)
      cat("  CCL", cyc, "downloaded.\n")
    } else {
      cat("  CCL", cyc, "download failed.\n")
    }
    unlink(tmp)
  }

  if (!file.exists(cn_out)) {
    cn_url <- paste0("https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/",
                      cyc, "/cn", yr, ".zip")
    tmp <- tempfile(fileext = ".zip")
    exit_code <- system2("curl", args = c("-L", "-s", "-o", shQuote(tmp), shQuote(cn_url)),
                          stdout = "", stderr = "")
    if (exit_code == 0 && file.exists(tmp) && file.size(tmp) > 100) {
      unzip(tmp, exdir = fec_dir)
      extracted <- list.files(fec_dir, pattern = "^cn\\.txt$", full.names = TRUE)
      if (length(extracted) > 0) file.rename(extracted[1], cn_out)
      cat("  CN", cyc, "downloaded.\n")
    } else {
      cat("  CN", cyc, "download failed.\n")
    }
    unlink(tmp)
  }
}

# Parse candidate master files to get party affiliation
parse_candidates <- function(cycle, fec_dir) {
  yr <- substr(cycle, 3, 4)
  cn_file <- file.path(fec_dir, paste0("cn_", cycle, ".txt"))
  if (!file.exists(cn_file)) return(NULL)

  cn <- fread(cn_file, sep = "|", header = FALSE, quote = "",
              select = c(1, 2, 3, 5, 6),
              col.names = c("candidate_id", "candidate_name", "party",
                           "state", "office"))
  cn[, cycle := cycle]
  return(cn)
}

parse_ccl <- function(cycle, fec_dir) {
  yr <- substr(cycle, 3, 4)
  ccl_file <- file.path(fec_dir, paste0("ccl_", cycle, ".txt"))
  if (!file.exists(ccl_file)) return(NULL)

  # CCL format: CAND_ID(1) | CAND_ELECTION_YR(2) | FEC_ELECTION_YR(3) | CMTE_ID(4) | ...
  ccl <- fread(ccl_file, sep = "|", header = FALSE, quote = "",
               select = c(1, 4),
               col.names = c("candidate_id", "committee_id"))
  # Ensure character type for committee_id
  ccl[, committee_id := as.character(committee_id)]
  ccl[, cycle := cycle]
  return(ccl)
}

cat("Parsing candidate and committee linkage files...\n")
cn_list <- lapply(cycles, parse_candidates, fec_dir = fec_dir)
cn_all <- rbindlist(cn_list[!sapply(cn_list, is.null)], fill = TRUE)

ccl_list <- lapply(cycles, parse_ccl, fec_dir = fec_dir)
ccl_all <- rbindlist(ccl_list[!sapply(ccl_list, is.null)], fill = TRUE)

# Merge: committee → candidate → party
committee_party <- merge(ccl_all, cn_all[, .(candidate_id, party, office, cycle)],
                         by = c("candidate_id", "cycle"), all.x = TRUE)
committee_party <- unique(committee_party[, .(committee_id, cycle, party, office)])

# Tag donations with party
fec_all <- merge(fec_all, committee_party,
                 by = c("committee_id", "cycle"), all.x = TRUE)

cat("FEC donations tagged with party:", sum(!is.na(fec_all$party)), "of", nrow(fec_all), "\n")
cat("Party distribution:\n")
print(fec_all[!is.na(party), .N, by = party][order(-N)])

# ============================================================================
cat("\n=== Saving intermediate data ===\n")

write_parquet(provider_panel, file.path(LOCAL_DATA, "provider_panel_raw.parquet"))
write_parquet(fec_all, file.path(LOCAL_DATA, "fec_healthcare_donations.parquet"))
if (nrow(medicare_all) > 0) {
  write_parquet(medicare_all, file.path(LOCAL_DATA, "medicare_puf_all.parquet"))
}

cat("\n=== Data acquisition complete ===\n")
cat("Files saved to:", LOCAL_DATA, "\n")
cat("  provider_panel_raw.parquet:", nrow(provider_panel), "rows\n")
cat("  fec_healthcare_donations.parquet:", nrow(fec_all), "rows\n")
cat("  medicare_puf_all.parquet:", nrow(medicare_all), "rows\n")
