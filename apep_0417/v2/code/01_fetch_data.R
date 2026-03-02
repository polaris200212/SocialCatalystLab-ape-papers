## ============================================================
## 01_fetch_data.R — Load T-MSIS + NPPES, build provider panel
## Paper: Where Medicaid Goes Dark (apep_0417 v2)
## Change from v1: Dual specialty classification — all clinicians
## (NPs mapped to clinical specialty) + MD/DO-only robustness
## ============================================================

source("00_packages.R")

cat("\n=== Step 1: Load NPPES Extract ===\n")
nppes <- read_parquet(NPPES_PATH) |>
  as.data.table()

cat("  NPPES rows:", nrow(nppes), "\n")

# Specialty classification using NUCC taxonomy codes
# Focus on individual providers (entity_type == 1)
nppes_indiv <- nppes[entity_type == 1 & !is.na(taxonomy_1)]

# --- PRIMARY: All-clinicians classification ---
# Maps NP/PA taxonomy codes to their clinical specialty
classify_specialty_inclusive <- function(tax) {
  case_when(
    # Primary Care (MD/DO)
    str_starts(tax, "207Q") ~ "Primary Care",
    tax == "207R00000X"     ~ "Primary Care",  # General Internal Medicine
    str_starts(tax, "208D") ~ "Primary Care",  # General Practice
    tax == "208000000X"     ~ "Primary Care",  # General Pediatrics

    # NP → Clinical Specialty (NUCC subcategories)
    tax == "363LF0000X" ~ "Primary Care",   # Family NP
    tax == "363LP2300X" ~ "Primary Care",   # Primary Care NP
    tax == "363LA2200X" ~ "Primary Care",   # Adult Health NP
    tax == "363LC1500X" ~ "Primary Care",   # Community Health NP
    tax == "363LP0200X" ~ "Primary Care",   # Pediatric NP
    tax == "363LG0600X" ~ "Primary Care",   # Gerontology NP
    tax == "363LN0005X" ~ "Primary Care",   # Neonatal NP
    tax == "363LA2100X" ~ "Primary Care",   # Acute Care NP
    tax == "363LP0808X" ~ "Psychiatry",     # Psych/Mental Health NP
    tax == "363LW0102X" ~ "OB-GYN",         # Women's Health NP

    # PA → Clinical Specialty
    tax == "363A00000X" ~ "Primary Care",   # PA - general
    tax == "363AM0700X" ~ "Primary Care",   # PA - Medical
    tax == "363AS0400X" ~ "Surgery",        # PA - Surgical

    # Remaining NP/PA with non-specific codes → Primary Care
    # (most NPs are in primary care settings)
    str_starts(tax, "363L") ~ "Primary Care",
    str_starts(tax, "363A") ~ "Primary Care",

    # Psychiatry (MD/DO)
    str_starts(tax, "2084") ~ "Psychiatry",

    # Behavioral Health (non-MD)
    str_starts(tax, "101Y") ~ "Behavioral Health",
    str_starts(tax, "1041") ~ "Behavioral Health",
    str_starts(tax, "104100") ~ "Behavioral Health",
    str_starts(tax, "103T") ~ "Behavioral Health",
    str_starts(tax, "103K") ~ "Behavioral Health",
    str_starts(tax, "106H") ~ "Behavioral Health",

    # Dental
    str_starts(tax, "1223") ~ "Dental",
    str_starts(tax, "122300") ~ "Dental",

    # OB-GYN
    str_starts(tax, "207V") ~ "OB-GYN",

    # Surgery
    str_starts(tax, "2086") ~ "Surgery",
    str_starts(tax, "207X") ~ "Surgery",
    str_starts(tax, "207T") ~ "Surgery",
    str_starts(tax, "208200") ~ "Surgery",
    str_starts(tax, "208C") ~ "Surgery",
    str_starts(tax, "208G") ~ "Surgery",
    str_starts(tax, "204E") ~ "Surgery",

    TRUE ~ NA_character_
  )
}

# --- ROBUSTNESS: MD/DO-only classification (v1 behavior, NP/PA excluded) ---
classify_specialty_md_only <- function(tax) {
  case_when(
    # Primary Care (MD/DO only)
    str_starts(tax, "207Q") ~ "Primary Care",
    tax == "207R00000X"     ~ "Primary Care",
    str_starts(tax, "208D") ~ "Primary Care",
    tax == "208000000X"     ~ "Primary Care",

    # Psychiatry (MD/DO only)
    str_starts(tax, "2084") ~ "Psychiatry",

    # Behavioral Health (non-MD, kept same)
    str_starts(tax, "101Y") ~ "Behavioral Health",
    str_starts(tax, "1041") ~ "Behavioral Health",
    str_starts(tax, "104100") ~ "Behavioral Health",
    str_starts(tax, "103T") ~ "Behavioral Health",
    str_starts(tax, "103K") ~ "Behavioral Health",
    str_starts(tax, "106H") ~ "Behavioral Health",

    # Dental
    str_starts(tax, "1223") ~ "Dental",
    str_starts(tax, "122300") ~ "Dental",

    # OB-GYN
    str_starts(tax, "207V") ~ "OB-GYN",

    # Surgery
    str_starts(tax, "2086") ~ "Surgery",
    str_starts(tax, "207X") ~ "Surgery",
    str_starts(tax, "207T") ~ "Surgery",
    str_starts(tax, "208200") ~ "Surgery",
    str_starts(tax, "208C") ~ "Surgery",
    str_starts(tax, "208G") ~ "Surgery",
    str_starts(tax, "204E") ~ "Surgery",

    TRUE ~ NA_character_
  )
}

# Apply both classifications
nppes_indiv[, specialty_inclusive := classify_specialty_inclusive(taxonomy_1)]
nppes_indiv[, specialty_mdonly := classify_specialty_md_only(taxonomy_1)]

# Primary measure: all clinicians (6 specialties, NPs folded into clinical)
nppes_inclusive <- nppes_indiv[!is.na(specialty_inclusive)]
# Robustness: MD/DO only (6 specialties, NPs excluded)
nppes_mdonly <- nppes_indiv[!is.na(specialty_mdonly)]

cat("  All-clinicians classified:", nrow(nppes_inclusive), "\n")
cat("  MD/DO-only classified:", nrow(nppes_mdonly), "\n")
cat("\n  All-clinicians specialty distribution:\n")
print(nppes_inclusive[, .N, by = specialty_inclusive][order(-N)])
cat("\n  MD/DO-only specialty distribution:\n")
print(nppes_mdonly[, .N, by = specialty_mdonly][order(-N)])

# Provider type from credential (for reporting)
nppes_indiv[, provider_type := case_when(
  str_detect(credential, "(?i)\\bMD\\b|\\bM\\.D\\b") ~ "MD",
  str_detect(credential, "(?i)\\bDO\\b|\\bD\\.O\\b") ~ "DO",
  str_detect(credential, "(?i)\\bNP\\b|\\bFNP\\b|\\bARNP\\b|\\bCRNP\\b|\\bAPRN\\b|\\bDNP\\b") ~ "NP",
  str_detect(credential, "(?i)\\bPA\\b|\\bPA-C\\b|\\bPAC\\b") ~ "PA",
  str_detect(credential, "(?i)\\bDDS\\b|\\bDMD\\b|\\bD\\.D\\.S\\b|\\bD\\.M\\.D\\b") ~ "DDS/DMD",
  str_detect(credential, "(?i)\\bLCSW\\b|\\bMSW\\b|\\bLISW\\b") ~ "LCSW",
  str_detect(credential, "(?i)\\bLPC\\b|\\bLMHC\\b|\\bLMFT\\b") ~ "LPC/LMHC",
  str_detect(credential, "(?i)\\bPH\\.?D\\b|\\bPSY\\.?D\\b") ~ "PhD/PsyD",
  TRUE ~ "Other"
)]

cat("\n  Provider type distribution:\n")
print(nppes_indiv[!is.na(specialty_inclusive), .N, by = provider_type][order(-N)])

cat("\n=== Step 2: Build ZCTA-County Crosswalk ===\n")

# Download Census ZCTA-to-county relationship file
xwalk_file <- file.path(DATA_DIR, "zcta_county_xwalk.csv")
if (!file.exists(xwalk_file)) {
  url <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_county20_natl.txt"
  cat("  Downloading ZCTA-county crosswalk...\n")
  download.file(url, xwalk_file, quiet = TRUE)
}

xwalk <- fread(xwalk_file, sep = "|")
# Keep the county with largest area overlap per ZCTA
xwalk <- xwalk[, .(
  county_fips = sprintf("%05d", GEOID_COUNTY_20[which.max(AREALAND_PART)])
), by = .(zcta5 = sprintf("%05d", GEOID_ZCTA5_20))]

cat("  ZCTA-county mappings:", nrow(xwalk), "\n")

# Map providers to counties
nppes_indiv[, zip5_clean := str_pad(zip5, 5, pad = "0")]
nppes_indiv <- merge(nppes_indiv, xwalk,
                     by.x = "zip5_clean", by.y = "zcta5",
                     all.x = TRUE)

cat("  Providers mapped to county:", sum(!is.na(nppes_indiv$county_fips)), "/",
    nrow(nppes_indiv),
    sprintf("(%.1f%%)", 100 * mean(!is.na(nppes_indiv$county_fips))), "\n")

# Create NPI lookups: one for each classification
# All-clinicians lookup
npi_lookup_inclusive <- nppes_indiv[!is.na(county_fips) & !is.na(specialty_inclusive),
  .(npi = as.character(npi), specialty = specialty_inclusive, county_fips, state,
    provider_type, enumeration_date, deactivation_date)]
setkey(npi_lookup_inclusive, npi)

# MD/DO-only lookup
npi_lookup_mdonly <- nppes_indiv[!is.na(county_fips) & !is.na(specialty_mdonly),
  .(npi = as.character(npi), specialty = specialty_mdonly, county_fips, state,
    provider_type, enumeration_date, deactivation_date)]
setkey(npi_lookup_mdonly, npi)

cat("  NPI lookup (all clinicians):", nrow(npi_lookup_inclusive), "\n")
cat("  NPI lookup (MD/DO only):", nrow(npi_lookup_mdonly), "\n")

cat("\n=== Step 3: Build County-Specialty-Quarter Panel from T-MSIS ===\n")

# Open T-MSIS lazily
tmsis <- open_dataset(TMSIS_PATH)
cat("  T-MSIS schema:", paste(names(tmsis), collapse = ", "), "\n")

# Process in Arrow: aggregate by billing NPI × month, then collect
cat("  Scanning T-MSIS (this takes a few minutes)...\n")

provider_months <- tmsis |>
  filter(!is.na(BILLING_PROVIDER_NPI_NUM)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes  = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

cat("  Provider-month rows:", nrow(provider_months), "\n")

# Parse month to quarter
provider_months[, `:=`(
  npi = BILLING_PROVIDER_NPI_NUM,
  year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
  month = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
)]
provider_months[, quarter := paste0(year, "Q", ceiling(month / 3))]

# Drop 2024Q4 (incomplete data — Nov/Dec claim lag)
provider_months <- provider_months[!(year == 2024 & month >= 10)]

cat("  After dropping 2024Q4:", nrow(provider_months), "\n")

# Aggregate to NPI × quarter
provider_quarters <- provider_months[, .(
  claims_quarter = sum(total_claims),
  benes_quarter  = sum(total_benes),
  paid_quarter   = sum(total_paid),
  months_active  = .N
), by = .(npi, quarter, year)]

cat("  Provider-quarter rows:", nrow(provider_quarters), "\n")

# Define "active" thresholds
provider_quarters[, `:=`(
  active_loose  = claims_quarter >= 1,
  active_strict = claims_quarter >= 4,    # ~1/month minimum
  active_ft     = claims_quarter >= 36    # Full-time (~12/month)
)]

cat("\n=== Step 4: Build County × Specialty × Quarter Panels ===\n")

# --- Function to build county-spec-quarter panel from a lookup ---
build_county_panel <- function(pq, lookup, label) {
  # Inner join to get specialty + county
  pq_joined <- merge(pq, lookup, by = "npi", all.x = FALSE)
  cat("  ", label, "— after join:", nrow(pq_joined), "\n")

  # Aggregate to county × specialty × quarter (strict threshold)
  csq <- pq_joined[active_strict == TRUE, .(
    n_providers    = uniqueN(npi),
    total_claims   = sum(claims_quarter),
    total_benes    = sum(benes_quarter),
    total_paid     = sum(paid_quarter),
    n_md           = uniqueN(npi[provider_type == "MD"]),
    n_do           = uniqueN(npi[provider_type == "DO"]),
    n_np           = uniqueN(npi[provider_type == "NP"]),
    n_pa           = uniqueN(npi[provider_type == "PA"])
  ), by = .(county_fips, specialty, quarter, year)]

  # Full-time threshold for robustness
  csq_ft <- pq_joined[active_ft == TRUE, .(
    n_providers_ft = uniqueN(npi)
  ), by = .(county_fips, specialty, quarter, year)]

  csq <- merge(csq, csq_ft,
               by = c("county_fips", "specialty", "quarter", "year"),
               all.x = TRUE)
  csq[is.na(n_providers_ft), n_providers_ft := 0]

  csq[, state_fips := substr(county_fips, 1, 2)]
  csq
}

# Build both panels
county_spec_qtr <- build_county_panel(provider_quarters, npi_lookup_inclusive,
                                       "All clinicians")
county_spec_qtr_mdonly <- build_county_panel(provider_quarters, npi_lookup_mdonly,
                                              "MD/DO only")

cat("  All-clinicians panel cells:", nrow(county_spec_qtr), "\n")
cat("    Unique counties:", uniqueN(county_spec_qtr$county_fips), "\n")
cat("    Unique specialties:", uniqueN(county_spec_qtr$specialty), "\n")
cat("  MD/DO-only panel cells:", nrow(county_spec_qtr_mdonly), "\n")

cat("\n=== Step 5: Save ===\n")

saveRDS(county_spec_qtr, file.path(DATA_DIR, "county_specialty_quarter.rds"))
saveRDS(county_spec_qtr_mdonly, file.path(DATA_DIR, "county_specialty_quarter_mdonly.rds"))
saveRDS(provider_quarters, file.path(DATA_DIR, "provider_quarters.rds"))
saveRDS(npi_lookup_inclusive, file.path(DATA_DIR, "npi_lookup.rds"))
saveRDS(npi_lookup_mdonly, file.path(DATA_DIR, "npi_lookup_mdonly.rds"))

cat("  Saved county_specialty_quarter.rds (all clinicians)\n")
cat("  Saved county_specialty_quarter_mdonly.rds\n")
cat("  Saved provider_quarters.rds\n")
cat("  Saved npi_lookup.rds (all clinicians)\n")
cat("  Saved npi_lookup_mdonly.rds\n")

cat("\n=== Summary Statistics ===\n")
cat("All-clinicians providers by specialty (strict threshold):\n")
print(county_spec_qtr[, .(
  counties = uniqueN(county_fips),
  avg_providers = round(mean(n_providers), 1),
  total_providers = sum(n_providers)
), by = specialty][order(-total_providers)])

cat("\nMD/DO-only providers by specialty:\n")
print(county_spec_qtr_mdonly[, .(
  counties = uniqueN(county_fips),
  avg_providers = round(mean(n_providers), 1),
  total_providers = sum(n_providers)
), by = specialty][order(-total_providers)])

cat("\nDone with data construction.\n")
