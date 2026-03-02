## ============================================================================
## 02_clean_data.R — Match LEIE exclusions to T-MSIS billing, build panels
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
##
## Key tasks:
##   1. Match LEIE NPIs to T-MSIS billing (all services)
##   2. Compute pre-exclusion service-specific market shares
##   3. Define treatment: excluded NPI × service-category × ZIP
##   4. Build ZIP × service-category × month panel
##   5. Define treatment cohorts for event study / CS-DiD
## ============================================================================

source("00_packages.R")

DATA <- "../data"
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")

## ---- Load intermediate data ----
leie <- readRDS(file.path(DATA, "leie_cleaned.rds"))
npi_geo <- readRDS(file.path(DATA, "npi_geography.rds"))
zip_county <- readRDS(file.path(DATA, "zip_county_xwalk.rds"))
county_demo <- readRDS(file.path(DATA, "county_demographics.rds"))
tmsis_ds <- open_dataset(file.path(SHARED_DATA, "tmsis.parquet"))

## ====================================================================
## 1. Build NPI × service-category × month panel from T-MSIS
## ====================================================================
cat("Building NPI × service × month panel from T-MSIS...\n")

# Define service categories by HCPCS prefix
# Group into economically meaningful buckets
npi_svc_month <- tmsis_ds |>
  mutate(
    svc_cat = case_when(
      substr(HCPCS_CODE, 1, 1) %in% c("T", "S") ~ "HCBS_TS",
      substr(HCPCS_CODE, 1, 1) == "H" ~ "BH_H",
      substr(HCPCS_CODE, 1, 1) %in% c("9") ~ "EM_PROC",
      substr(HCPCS_CODE, 1, 1) %in% c("0", "1", "2", "3", "4", "5", "6", "7", "8") ~ "MED_PROC",
      substr(HCPCS_CODE, 1, 1) %in% c("A", "B", "E", "K", "L") ~ "DME_SUPPLY",
      substr(HCPCS_CODE, 1, 1) %in% c("J") ~ "DRUGS",
      substr(HCPCS_CODE, 1, 1) %in% c("G", "Q") ~ "TEMP_CODES",
      TRUE ~ "OTHER"
    )
  ) |>
  group_by(SERVICING_PROVIDER_NPI_NUM, svc_cat, CLAIM_FROM_MONTH) |>
  summarize(
    paid = sum(TOTAL_PAID, na.rm = TRUE),
    claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(npi_svc_month, "SERVICING_PROVIDER_NPI_NUM", "npi")
npi_svc_month[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]

cat(sprintf("NPI × service × month: %s rows\n",
            format(nrow(npi_svc_month), big.mark = ",")))

# Merge ZIP geography
npi_svc_month <- merge(npi_svc_month, npi_geo[, .(npi, zip5, county_fips, state)],
                       by = "npi", all.x = TRUE)
npi_svc_month <- npi_svc_month[!is.na(zip5)]

cat(sprintf("After ZIP merge: %s rows\n",
            format(nrow(npi_svc_month), big.mark = ",")))

## ====================================================================
## 2. Match LEIE NPIs and compute service-level market shares
## ====================================================================
cat("Matching LEIE exclusions to T-MSIS billing...\n")

leie_npis <- unique(leie$npi)

# Excluded NPI billing by service category
excl_billing <- npi_svc_month[npi %in% leie_npis]
excl_billing <- merge(excl_billing,
                      leie[, .(npi, exclusion_date, SPECIALTY, EXCLTYPE, hcbs_related)],
                      by = "npi", all.x = TRUE)

excl_billing[, months_to_excl := as.integer(
  difftime(month_date, exclusion_date, units = "days") / 30.44
)]

cat(sprintf("Excluded NPI billing records: %s rows\n",
            format(nrow(excl_billing), big.mark = ",")))

# Pre-exclusion billing by NPI × service category (12 months before)
pre_excl <- excl_billing[
  months_to_excl >= -12 & months_to_excl < 0,
  .(
    pre_paid = sum(paid),
    pre_claims = sum(claims),
    pre_bene = sum(beneficiaries),
    pre_months = uniqueN(CLAIM_FROM_MONTH)
  ),
  by = .(npi, zip5, svc_cat, exclusion_date, SPECIALTY, EXCLTYPE, hcbs_related, state)
]

cat(sprintf("Excluded NPI × service pre-billing entries: %d\n", nrow(pre_excl)))
cat(sprintf("  With ≥3 months: %d\n", sum(pre_excl$pre_months >= 3)))

# Keep meaningful pre-billing (≥3 months active in that category)
pre_excl <- pre_excl[pre_months >= 3]

# Compute ZIP × service-category totals for market share
cat("Computing ZIP × service totals for market shares...\n")
zip_svc_annual <- npi_svc_month[, .(
  zip_total = sum(paid)
), by = .(zip5, svc_cat, year = year(month_date))]

# For each excluded NPI × service, compute their share in the ZIP
shares <- lapply(seq_len(nrow(pre_excl)), function(i) {
  row <- pre_excl[i]
  excl_year <- year(row$exclusion_date)
  # Use prior year totals, or same year if earliest
  prior_year <- excl_year - 1

  zip_total <- zip_svc_annual[
    zip5 == row$zip5 & svc_cat == row$svc_cat &
    year %in% c(prior_year, excl_year),
    mean(zip_total)
  ]

  data.table(
    npi = row$npi, zip5 = row$zip5, svc_cat = row$svc_cat,
    exclusion_date = row$exclusion_date,
    zip_annual_total = zip_total,
    provider_annual = row$pre_paid,
    market_share = fifelse(zip_total > 0, row$pre_paid / zip_total, 0)
  )
})
shares <- rbindlist(shares)

pre_excl <- merge(pre_excl, shares[, .(npi, zip5, svc_cat, exclusion_date,
                                        zip_annual_total, provider_annual, market_share)],
                  by = c("npi", "zip5", "svc_cat", "exclusion_date"))

cat("\nService-level market share distribution:\n")
cat(sprintf("  N pairs: %d\n", nrow(pre_excl)))
cat(sprintf("  Mean: %.1f%%\n", 100 * mean(pre_excl$market_share)))
cat(sprintf("  ≥5%%: %d\n", sum(pre_excl$market_share >= 0.05)))
cat(sprintf("  ≥10%%: %d\n", sum(pre_excl$market_share >= 0.10)))
cat(sprintf("  ≥20%%: %d\n", sum(pre_excl$market_share >= 0.20)))

## ====================================================================
## 3. Define analysis sample
## ====================================================================
# Require:
# - ≥3% service-level market share (lower threshold for more power)
# - ZIP-level service total ≥ $1,000/year (exclude trivial markets)
# - Include all years (2018-2024) for maximum power

analysis_excl <- pre_excl[
  market_share >= 0.03 &
  zip_annual_total >= 1000
]

cat(sprintf("\nAnalysis sample (≥3%% share, ≥$1K market): %d exclusion-service pairs\n",
            nrow(analysis_excl)))
cat(sprintf("  Unique NPIs: %d\n", uniqueN(analysis_excl$npi)))
cat(sprintf("  Unique ZIPs: %d\n", uniqueN(analysis_excl$zip5)))
cat(sprintf("  Unique states: %d\n", uniqueN(analysis_excl$state)))
cat(sprintf("  By service category:\n"))
print(analysis_excl[, .N, by = svc_cat][order(-N)])

saveRDS(analysis_excl, file.path(DATA, "analysis_exclusions.rds"))
saveRDS(pre_excl, file.path(DATA, "all_matched_exclusions.rds"))

## ====================================================================
## 4. Build ZIP × service-category × month panel
## ====================================================================
cat("Building ZIP × service × month panel...\n")

# Get all unique treated ZIPs and their states
treated_zips <- unique(analysis_excl$zip5)
treated_states <- unique(analysis_excl$state)
treated_svcs <- unique(analysis_excl$svc_cat)

# Aggregate to ZIP × service × month for treated states
zip_svc_panel <- npi_svc_month[
  zip5 %in% npi_geo[state %in% treated_states, unique(zip5)] &
  svc_cat %in% treated_svcs,
  .(
    total_paid = sum(paid),
    total_claims = sum(claims),
    total_bene = sum(beneficiaries),
    n_providers = uniqueN(npi)
  ),
  by = .(zip5, svc_cat, month_date)
]

# Month number
zip_svc_panel[, month_num := as.integer(
  (year(month_date) - 2018) * 12 + month(month_date)
)]

# Merge county and state info
zip_svc_panel <- merge(zip_svc_panel, zip_county, by = "zip5", all.x = TRUE)

# Get one state per ZIP (most common state for NPIs in that ZIP)
zip_state <- npi_geo[, .N, by = .(zip5, state)][order(zip5, -N)][, .SD[1], by = zip5]
zip_svc_panel <- merge(zip_svc_panel, zip_state[, .(zip5, state)],
                       by = "zip5", all.x = TRUE)

# For each treated ZIP × service, define first exclusion month
first_excl <- analysis_excl[, .(
  first_excl_date = min(exclusion_date),
  first_excl_npi = npi[which.min(exclusion_date)],
  n_exclusions = .N,
  max_share = max(market_share)
), by = .(zip5, svc_cat)]

first_excl[, excl_month := floor_date(first_excl_date, "month")]
first_excl[, excl_month_num := as.integer(
  (year(excl_month) - 2018) * 12 + month(excl_month)
)]

zip_svc_panel <- merge(zip_svc_panel,
                       first_excl[, .(zip5, svc_cat, excl_month, excl_month_num,
                                      n_exclusions, max_share)],
                       by = c("zip5", "svc_cat"), all.x = TRUE)

# Treatment group (0 = never treated)
zip_svc_panel[is.na(excl_month_num), excl_month_num := 0]
zip_svc_panel[, treated := excl_month_num > 0]
zip_svc_panel[, event_time := fifelse(treated, month_num - excl_month_num, NA_integer_)]

# Log outcomes
zip_svc_panel[, ln_paid := log(total_paid + 1)]
zip_svc_panel[, ln_providers := log(n_providers + 1)]
zip_svc_panel[, ln_bene := log(total_bene + 1)]

# Post indicator for treated units
zip_svc_panel[, post := fifelse(treated & month_num >= excl_month_num, 1L, 0L)]

# Unit ID for panel
zip_svc_panel[, unit_id := paste0(zip5, "_", svc_cat)]
zip_svc_panel[, unit_num := as.integer(factor(unit_id))]

cat(sprintf("ZIP × service × month panel: %s rows\n",
            format(nrow(zip_svc_panel), big.mark = ",")))
cat(sprintf("  Treated units: %d\n", uniqueN(zip_svc_panel[treated == TRUE, unit_id])))
cat(sprintf("  Control units: %d\n", uniqueN(zip_svc_panel[treated == FALSE, unit_id])))

# Merge demographics
zip_svc_panel <- merge(zip_svc_panel, county_demo,
                       by = "county_fips", all.x = TRUE)

saveRDS(zip_svc_panel, file.path(DATA, "zip_svc_panel.rds"))

## ====================================================================
## 5. Build rest-of-market panel (excl. excluded provider)
## ====================================================================
cat("Building rest-of-market panel...\n")

# For treated ZIP × service pairs, rebuild totals excluding the excluded NPI
excl_npi_info <- analysis_excl[, .(npi, zip5, svc_cat, exclusion_date)]

# Get billing for treated ZIP × service pairs, flag excluded NPIs
treated_billing <- npi_svc_month[
  zip5 %in% treated_zips & svc_cat %in% treated_svcs
]

# Flag excluded NPIs in their specific ZIP × service
treated_billing <- merge(treated_billing,
                         excl_npi_info[, .(npi, zip5, svc_cat, is_excluded = TRUE)],
                         by = c("npi", "zip5", "svc_cat"),
                         all.x = TRUE)
treated_billing[is.na(is_excluded), is_excluded := FALSE]

# Rest-of-market totals
rom_panel <- treated_billing[is_excluded == FALSE, .(
  rom_paid = sum(paid),
  rom_claims = sum(claims),
  rom_bene = sum(beneficiaries),
  rom_providers = uniqueN(npi)
), by = .(zip5, svc_cat, month_date)]

# Total market (including excluded)
total_panel <- treated_billing[, .(
  total_paid_all = sum(paid),
  total_providers_all = uniqueN(npi)
), by = .(zip5, svc_cat, month_date)]

rom_panel <- merge(rom_panel, total_panel, by = c("zip5", "svc_cat", "month_date"))

# Merge treatment timing
rom_panel <- merge(rom_panel,
                   first_excl[, .(zip5, svc_cat, excl_month, excl_month_num)],
                   by = c("zip5", "svc_cat"))

rom_panel[, month_num := as.integer(
  (year(month_date) - 2018) * 12 + month(month_date)
)]
rom_panel[, event_time := month_num - excl_month_num]
rom_panel[, post := as.integer(event_time >= 0)]
rom_panel[, unit_id := paste0(zip5, "_", svc_cat)]

# Log outcomes
rom_panel[, ln_rom_paid := log(rom_paid + 1)]
rom_panel[, ln_rom_providers := log(rom_providers + 1)]
rom_panel[, ln_rom_bene := log(rom_bene + 1)]

# Merge state/county/demographics
rom_panel <- merge(rom_panel, zip_state[, .(zip5, state)],
                   by = "zip5", all.x = TRUE)
rom_panel <- merge(rom_panel, zip_county, by = "zip5", all.x = TRUE)
rom_panel <- merge(rom_panel, county_demo, by = "county_fips", all.x = TRUE)
rom_panel[, state_month := paste0(state, "_", month_num)]

saveRDS(rom_panel, file.path(DATA, "rom_panel.rds"))

cat(sprintf("ROM panel: %s rows for %d treated units\n",
            format(nrow(rom_panel), big.mark = ","),
            uniqueN(rom_panel$unit_id)))

## ====================================================================
## 6. Summary
## ====================================================================
cat("\n=== Analysis Sample Summary ===\n")
cat(sprintf("Exclusion-service pairs: %d\n", nrow(analysis_excl)))
cat(sprintf("Unique excluded NPIs: %d\n", uniqueN(analysis_excl$npi)))
cat(sprintf("Unique treated ZIPs: %d\n", uniqueN(analysis_excl$zip5)))
cat(sprintf("Unique states: %d\n", uniqueN(analysis_excl$state)))
cat(sprintf("Mean service-level market share: %.1f%%\n",
            100 * mean(analysis_excl$market_share)))
cat(sprintf("Mean pre-exclusion annual billing: $%s\n",
            format(round(mean(analysis_excl$pre_paid)), big.mark = ",")))

cat("\n=== Data cleaning complete ===\n")
