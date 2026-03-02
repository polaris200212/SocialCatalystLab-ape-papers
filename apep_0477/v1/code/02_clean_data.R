###############################################################################
# 02_clean_data.R — Link EPC to Land Registry, construct analysis sample
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"

###############################################################################
# 1. Load data
###############################################################################

cat("=== Loading data ===\n")
lr <- read_parquet(file.path(DATA_DIR, "land_registry_2015_2025.parquet"))
epc <- read_parquet(file.path(DATA_DIR, "epc_domestic.parquet"))

setDT(lr)
setDT(epc)

cat(sprintf("Land Registry: %s rows\n", format(nrow(lr), big.mark = ",")))
cat(sprintf("EPC: %s rows\n", format(nrow(epc), big.mark = ",")))

###############################################################################
# 2. Standardize postcodes for matching
###############################################################################

# Clean postcodes: uppercase, single space
lr[, postcode_clean := gsub("\\s+", " ", trimws(toupper(postcode)))]
epc[, postcode_clean := gsub("\\s+", " ", trimws(toupper(
  ifelse(is.na(postcode), POSTCODE, postcode)
)))]

###############################################################################
# 3. Link EPC to Land Registry
###############################################################################

cat("\n=== Linking EPC to Land Registry ===\n")

# Strategy: For each Land Registry transaction, find the most recent EPC
# assessment for the same postcode + property type BEFORE the transaction date.
# This ensures we're using the EPC that was available to the buyer.

# First, create a simplified EPC lookup by postcode
epc_lookup <- epc[, .(
  epc_key = LMK_KEY,
  postcode_clean,
  epc_score,
  epc_band = CURRENT_ENERGY_RATING,
  epc_date = fifelse(!is.na(INSPECTION_DATE), INSPECTION_DATE, LODGEMENT_DATE),
  tenure = TENURE,
  epc_prop_type = PROPERTY_TYPE,
  floor_area = as.numeric(TOTAL_FLOOR_AREA),
  heating_cost = as.numeric(HEATING_COST_CURRENT),
  lighting_cost = as.numeric(LIGHTING_COST_CURRENT)
)]

epc_lookup <- epc_lookup[!is.na(epc_date)]

# Sort by postcode and date for efficient matching
setkey(epc_lookup, postcode_clean, epc_date)
setkey(lr, postcode_clean, date_transfer)

# Rolling join: for each LR transaction, find the most recent EPC at same postcode
# This is a many-to-many situation (multiple transactions and EPCs per postcode)
# We use a rolling join to get the nearest prior EPC

# First, prepare for rolling join
lr[, txn_date_num := as.numeric(date_transfer)]
epc_lookup[, epc_date_num := as.numeric(epc_date)]

# For large datasets, do postcode-level merge then filter
merged <- merge(lr, epc_lookup, by = "postcode_clean", allow.cartesian = TRUE)

# Keep only EPCs lodged before the transaction date (buyer had access)
merged <- merged[epc_date <= date_transfer]

# For each transaction, keep the MOST RECENT EPC
merged[, date_diff := as.numeric(date_transfer - epc_date)]
merged <- merged[date_diff <= 365 * 5]  # EPC valid for 10 years, keep within 5

setorder(merged, txn_id, date_diff)
matched <- merged[, .SD[1], by = txn_id]

cat(sprintf("Matched: %s transactions with EPC data (%.1f%% match rate)\n",
            format(nrow(matched), big.mark = ","),
            100 * nrow(matched) / nrow(lr)))

###############################################################################
# 4. Construct analysis variables
###############################################################################

cat("\n=== Constructing variables ===\n")

# Log price
matched[, log_price := log(price)]

# Period assignment
matched[, period := fcase(
  date_transfer < as.Date("2018-04-01"), "Pre-MEES",
  date_transfer < as.Date("2021-10-01"), "Post-MEES Pre-Crisis",
  date_transfer < as.Date("2023-07-01"), "Crisis",
  default = "Post-Crisis"
)]
matched[, period := factor(period, levels = PERIOD_LABELS)]

# Year-quarter
matched[, yq := paste0(year(date_transfer), "Q", quarter(date_transfer))]

# Tenure indicators
matched[, is_rental := grepl("Rental \\(private\\)", tenure, ignore.case = TRUE)]
matched[, is_owner := grepl("Owner", tenure, ignore.case = TRUE)]

# EPC band boundaries — distance to each
for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  nm <- paste0("dist_", EPC_BAND_NAMES[i])
  matched[, (nm) := epc_score - b]
}

# Indicator: above each boundary
for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  nm <- paste0("above_", EPC_BAND_NAMES[i])
  matched[, (nm) := as.integer(epc_score >= b)]
}

# Local authority from postcode (first part)
matched[, postcode_area := sub(" .*", "", postcode_clean)]

# Property type dummies
matched[, is_flat := property_type == "F"]
matched[, is_new := old_new == "Y"]

###############################################################################
# 5. Sample restrictions
###############################################################################

cat("\n=== Sample restrictions ===\n")
n_start <- nrow(matched)

# Drop extreme prices (below £10K or above £10M)
matched <- matched[price >= 10000 & price <= 10000000]
cat(sprintf("  After price filter: %s (dropped %s)\n",
            format(nrow(matched), big.mark = ","),
            format(n_start - nrow(matched), big.mark = ",")))

# Drop if floor area missing or extreme
matched <- matched[!is.na(floor_area) & floor_area >= 10 & floor_area <= 500]
cat(sprintf("  After floor area filter: %s\n",
            format(nrow(matched), big.mark = ",")))

# Focus on 2015+ transactions (post-EPC availability, pre-MEES for baseline)
matched <- matched[date_transfer >= as.Date("2015-01-01")]
cat(sprintf("  After date filter (2015+): %s\n",
            format(nrow(matched), big.mark = ",")))

###############################################################################
# 6. Summary statistics
###############################################################################

cat("\n=== Analysis Sample Summary ===\n")
cat(sprintf("Total matched transactions: %s\n",
            format(nrow(matched), big.mark = ",")))
cat(sprintf("Unique postcodes: %s\n",
            format(uniqueN(matched$postcode_clean), big.mark = ",")))
cat(sprintf("Date range: %s to %s\n",
            min(matched$date_transfer), max(matched$date_transfer)))

cat("\nBy period:\n")
print(matched[, .(N = .N, mean_price = mean(price),
                   median_price = median(price),
                   mean_epc = mean(epc_score)),
              by = period][order(period)])

cat("\nBy EPC band:\n")
print(matched[, .(N = .N, mean_price = mean(price),
                   mean_log_price = mean(log_price)),
              by = epc_band][order(epc_band)])

cat("\nNear boundaries (±10 score points):\n")
for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  n_near <- sum(abs(matched$epc_score - b) <= 10)
  cat(sprintf("  %s (score %d): %s transactions\n",
              EPC_BAND_NAMES[i], b, format(n_near, big.mark = ",")))
}

cat("\nBy tenure:\n")
print(matched[, .(N = .N, pct = .N/nrow(matched)*100), by = tenure])

###############################################################################
# 7. Save analysis dataset
###############################################################################

write_parquet(matched, file.path(DATA_DIR, "analysis_sample.parquet"))
cat(sprintf("\nSaved analysis sample: %s\n",
            file.path(DATA_DIR, "analysis_sample.parquet")))
