###############################################################################
# 01_fetch_data.R — Download EPC Register and Land Registry PPD
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# 1. Land Registry Price Paid Data (2015-2025)
###############################################################################

cat("=== Downloading Land Registry Price Paid Data ===\n")

lr_base <- "https://price-paid-data.publicdata.landregistry.gov.uk"
lr_years <- 2015:2025

lr_cols <- c(
  "txn_id", "price", "date_transfer", "postcode", "property_type",
  "old_new", "duration", "paon", "saon", "street", "locality",
  "town", "district", "county", "ppd_cat", "record_status"
)

lr_all <- list()

for (yr in lr_years) {
  lr_file <- file.path(DATA_DIR, sprintf("pp-%d.csv", yr))

  if (!file.exists(lr_file)) {
    url <- sprintf("%s/pp-%d.csv", lr_base, yr)
    cat(sprintf("Downloading Land Registry %d...\n", yr))
    tryCatch({
      download.file(url, lr_file, mode = "wb", quiet = TRUE)
      cat(sprintf("  Downloaded: %s (%.1f MB)\n", lr_file,
                  file.size(lr_file) / 1e6))
    }, error = function(e) {
      # Try part1/part2 for larger years
      url1 <- sprintf("%s/pp-%d-part1.csv", lr_base, yr)
      url2 <- sprintf("%s/pp-%d-part2.csv", lr_base, yr)
      f1 <- file.path(DATA_DIR, sprintf("pp-%d-part1.csv", yr))
      f2 <- file.path(DATA_DIR, sprintf("pp-%d-part2.csv", yr))
      download.file(url1, f1, mode = "wb", quiet = TRUE)
      download.file(url2, f2, mode = "wb", quiet = TRUE)
      # Combine
      system(sprintf("cat '%s' '%s' > '%s'", f1, f2, lr_file))
      unlink(c(f1, f2))
      cat(sprintf("  Downloaded (split): %s (%.1f MB)\n", lr_file,
                  file.size(lr_file) / 1e6))
    })
  } else {
    cat(sprintf("  Already exists: %s\n", lr_file))
  }

  dt <- fread(lr_file, header = FALSE,
              colClasses = list(character = c(1, 4:16)))
  setnames(dt, lr_cols)
  dt <- dt[, .(txn_id, price, date_transfer, postcode, property_type,
               old_new, paon, saon, street, ppd_cat, record_status)]
  dt[, year := yr]
  lr_all[[as.character(yr)]] <- dt
}

lr <- rbindlist(lr_all, fill = TRUE)
cat(sprintf("\nLand Registry: %s transactions loaded (%d-%d)\n",
            format(nrow(lr), big.mark = ","), min(lr_years), max(lr_years)))

# Parse date and filter to valid transactions
lr[, date_transfer := as.Date(date_transfer)]
lr <- lr[!is.na(price) & price > 0 & !is.na(postcode) & postcode != ""]

# Focus on standard price paid (Category A) and current records
lr <- lr[ppd_cat == "A" & record_status == "A"]
lr[, c("ppd_cat", "record_status") := NULL]

# Property type labels
lr[, prop_type_label := fcase(
  property_type == "D", "Detached",
  property_type == "S", "Semi-detached",
  property_type == "T", "Terraced",
  property_type == "F", "Flat",
  property_type == "O", "Other"
)]

cat(sprintf("After filtering: %s standard transactions\n",
            format(nrow(lr), big.mark = ",")))

# Save as parquet for efficient later use
write_parquet(lr, file.path(DATA_DIR, "land_registry_2015_2025.parquet"))
cat("Saved: land_registry_2015_2025.parquet\n")

###############################################################################
# 2. EPC Register — Bulk Download
###############################################################################

cat("\n=== EPC Register ===\n")

# The EPC register requires registration at epc.opendatacommunities.org
# and provides bulk CSV downloads. We assume the user has registered
# and downloaded the domestic certificates file.

epc_file <- file.path(DATA_DIR, "epc_domestic_certificates.csv")
epc_parquet <- file.path(DATA_DIR, "epc_domestic.parquet")

if (file.exists(epc_parquet)) {
  cat("EPC parquet already exists. Loading...\n")
  epc <- read_parquet(epc_parquet)
  cat(sprintf("EPC register: %s certificates loaded\n",
              format(nrow(epc), big.mark = ",")))

} else if (file.exists(epc_file)) {
  cat("Reading EPC CSV (this may take several minutes for 30M+ rows)...\n")

  epc_cols <- c(
    "LMK_KEY", "POSTCODE", "CURRENT_ENERGY_EFFICIENCY",
    "CURRENT_ENERGY_RATING", "PROPERTY_TYPE", "BUILT_FORM",
    "INSPECTION_DATE", "LODGEMENT_DATE", "TENURE",
    "TOTAL_FLOOR_AREA", "NUMBER_HABITABLE_ROOMS",
    "ENVIRONMENT_IMPACT_CURRENT", "ENERGY_CONSUMPTION_CURRENT",
    "LIGHTING_COST_CURRENT", "HEATING_COST_CURRENT",
    "HOT_WATER_COST_CURRENT", "CONSTRUCTION_AGE_BAND",
    "TRANSACTION_TYPE", "UPRN"
  )

  epc <- fread(epc_file, select = epc_cols, showProgress = TRUE)

  # Parse dates
  epc[, INSPECTION_DATE := as.Date(INSPECTION_DATE, format = "%Y-%m-%d")]
  epc[, LODGEMENT_DATE := as.Date(LODGEMENT_DATE, format = "%Y-%m-%d")]

  # Ensure EPC score is numeric
  epc[, epc_score := as.numeric(CURRENT_ENERGY_EFFICIENCY)]
  epc <- epc[!is.na(epc_score) & epc_score >= 1 & epc_score <= 100]

  # Clean postcode
  epc[, postcode := gsub("\\s+", " ", trimws(toupper(POSTCODE)))]
  epc <- epc[postcode != ""]

  cat(sprintf("EPC register: %s valid certificates\n",
              format(nrow(epc), big.mark = ",")))

  write_parquet(epc, epc_parquet)
  cat("Saved: epc_domestic.parquet\n")

} else {
  # If no EPC file exists, try to download sample or provide instructions
  cat("WARNING: EPC bulk data not found.\n")
  cat("To download:\n")
  cat("  1. Register at https://epc.opendatacommunities.org/\n")
  cat("  2. Download 'All domestic certificates' CSV\n")
  cat("  3. Save to:", epc_file, "\n\n")

  cat("Attempting to create EPC sample from individual year downloads...\n")

  # Alternative: download year-by-year from the API
  # The opendatacommunities portal also offers downloads by local authority
  # For a working demo, we'll try the most recent years via the API

  epc_api_base <- "https://epc.opendatacommunities.org/api/v1/domestic/search"

  # We need an API token from the registration
  epc_token <- Sys.getenv("EPC_API_TOKEN")

  if (epc_token == "") {
    stop(paste0(
      "EPC bulk data not found and no API token configured.\n",
      "To run this analysis:\n",
      "  1. Register at https://epc.opendatacommunities.org/\n",
      "  2. Download 'All domestic certificates' CSV\n",
      "  3. Save to: ", epc_file, "\n",
      "Alternatively, set EPC_API_TOKEN in your environment."
    ))
  } else {
    cat("EPC API token found. Downloading via API...\n")

    # Download in batches by local authority or postcode area
    # The API returns max 10,000 results per request
    # For a full download, the bulk CSV is much faster

    cat("For full analysis, please download the bulk CSV instead.\n")
    cat("API download is too slow for 30M+ records.\n")
    stop("Please download EPC bulk data from epc.opendatacommunities.org")
  }
}

###############################################################################
# 3. Summary Statistics
###############################################################################

cat("\n=== Data Summary ===\n")
cat(sprintf("Land Registry: %s transactions (%s to %s)\n",
            format(nrow(lr), big.mark = ","),
            min(lr$date_transfer, na.rm = TRUE),
            max(lr$date_transfer, na.rm = TRUE)))
cat(sprintf("EPC Register: %s certificates\n",
            format(nrow(epc), big.mark = ",")))

# EPC score distribution near boundaries
for (b in EPC_BOUNDARIES) {
  n_near <- sum(abs(epc$epc_score - b) <= 5)
  cat(sprintf("  Near %s boundary (±5): %s certificates\n",
              EPC_BAND_NAMES[which(EPC_BOUNDARIES == b)],
              format(n_near, big.mark = ",")))
}

cat("\nData fetch complete.\n")
