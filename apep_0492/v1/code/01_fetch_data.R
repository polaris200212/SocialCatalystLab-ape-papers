# ==============================================================================
# 01_fetch_data.R — Download Land Registry PPD + Assign Regions
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE)

# ==============================================================================
# 1. Download Land Registry Price Paid Data
# ==============================================================================

ppd_years <- 2018:2023
ppd_base_url <- "https://price-paid-data.publicdata.landregistry.gov.uk"

ppd_cols <- c(
  "transaction_id", "price", "date_transfer", "postcode",
  "property_type", "old_new", "duration", "paon", "saon",
  "street", "locality", "town", "district", "county",
  "ppd_category", "record_status"
)

ppd_list <- list()

for (yr in ppd_years) {
  dest <- file.path(data_dir, sprintf("pp-%d.csv", yr))
  url <- sprintf("%s/pp-%d.csv", ppd_base_url, yr)

  if (!file.exists(dest)) {
    cat(sprintf("Downloading PPD %d...\n", yr))
    tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
    }, error = function(e) {
      stop(sprintf("Failed to download PPD %d: %s\nPivot research question or fix the source.", yr, e$message))
    })
  } else {
    cat(sprintf("PPD %d already downloaded.\n", yr))
  }

  cat(sprintf("Reading PPD %d...\n", yr))
  dt <- fread(dest, header = FALSE, quote = "\"",
              col.names = ppd_cols,
              showProgress = FALSE)
  dt <- dt[, .(transaction_id, price, date_transfer, postcode,
               property_type, old_new, duration, district, county,
               ppd_category, record_status)]
  dt[, year := yr]
  ppd_list[[as.character(yr)]] <- dt
}

ppd <- rbindlist(ppd_list, use.names = TRUE, fill = TRUE)
rm(ppd_list)
gc()

cat(sprintf("PPD loaded: %s rows, %d years\n", format(nrow(ppd), big.mark = ","), length(ppd_years)))

# ==============================================================================
# 2. Clean PPD
# ==============================================================================

ppd[, date_transfer := as.Date(date_transfer)]
ppd[, year_month := format(date_transfer, "%Y-%m")]

# Filter to standard transactions only (Category A)
ppd <- ppd[ppd_category == "A"]

# Create new-build indicator
ppd[, new_build := (old_new == "Y")]

# Clean postcode (remove spaces for consistent matching)
ppd[, postcode_clean := gsub(" ", "", postcode)]

# Extract postcode area (letters before first digit)
ppd[, pc_area := gsub("[0-9].*", "", postcode_clean)]

cat(sprintf("After cleaning: %s rows\n", format(nrow(ppd), big.mark = ",")))

# ==============================================================================
# 3. Assign Regions via Postcode Area Mapping
# ==============================================================================

# Comprehensive mapping of postcode areas to English regions
# Source: Royal Mail postcode area definitions
# This covers all English postcode areas; Welsh/Scottish areas are excluded

pc_region_map <- rbind(
  # North East
  data.table(pc_area = c("DH", "DL", "NE", "SR", "TS"), region = "North East"),
  # North West
  data.table(pc_area = c("BB", "BL", "CA", "CH", "CW", "FY", "L", "LA", "M",
                          "OL", "PR", "SK", "WA", "WN"), region = "North West"),
  # Yorkshire and The Humber
  data.table(pc_area = c("BD", "DN", "HD", "HG", "HU", "HX", "LS", "S",
                          "WF", "YO"), region = "Yorkshire and The Humber"),
  # East Midlands
  data.table(pc_area = c("DE", "LE", "LN", "NG", "NN", "PE"), region = "East Midlands"),
  # West Midlands
  data.table(pc_area = c("B", "CV", "DY", "HR", "ST", "TF", "WR", "WS", "WV"),
             region = "West Midlands"),
  # South West
  data.table(pc_area = c("BA", "BH", "BS", "DT", "EX", "GL", "PL", "SN",
                          "SP", "TA", "TQ", "TR"), region = "South West"),
  # East of England
  data.table(pc_area = c("AL", "CB", "CM", "CO", "EN", "HP", "IP", "LU",
                          "NR", "SG", "SS", "WD"), region = "East of England"),
  # South East
  data.table(pc_area = c("BN", "CT", "GU", "KT", "ME", "MK", "OX", "PO",
                          "RG", "RH", "SL", "SO", "TN"), region = "South East"),
  # London
  data.table(pc_area = c("BR", "CR", "DA", "E", "EC", "HA", "IG", "N", "NW",
                          "RM", "SE", "SM", "SW", "TW", "UB", "W", "WC"),
             region = "London")
)

# Merge region into PPD
ppd <- merge(ppd, pc_region_map, by = "pc_area", all.x = TRUE)

# Check assignment coverage
n_total <- nrow(ppd)
n_assigned <- sum(!is.na(ppd$region))
n_missing <- sum(is.na(ppd$region))
cat(sprintf("Region assignment: %s assigned, %s missing (%.1f%%)\n",
            format(n_assigned, big.mark = ","),
            format(n_missing, big.mark = ","),
            100 * n_missing / n_total))

# Show unmatched postcode areas (should be Wales/Scotland)
if (n_missing > 0) {
  unmatched <- ppd[is.na(region), .N, by = pc_area][order(-N)]
  cat("Unmatched postcode areas (likely Wales/Scotland):\n")
  print(head(unmatched, 20))
}

# Keep England only (9 regions)
england_regions <- c("North East", "North West", "Yorkshire and The Humber",
                     "East Midlands", "West Midlands", "South West",
                     "East of England", "South East", "London")

ppd <- ppd[region %in% england_regions]

cat(sprintf("England-only PPD: %s rows\n", format(nrow(ppd), big.mark = ",")))

# ==============================================================================
# 4. Add Latitude/Longitude from postcodes.io (sample for spatial RDD)
# ==============================================================================

# For the spatial RDD at regional borders, we need lat/lon coordinates
# Only geocode postcodes near borders (much smaller set)
# We'll do this in 02_clean_data.R after identifying border transactions

# For now, save postcode area mapping
lookup_file <- file.path(data_dir, "postcode_region_lookup.csv")
fwrite(pc_region_map, lookup_file)

# ==============================================================================
# 5. Add Help to Buy Regional Caps
# ==============================================================================

htb_caps <- data.table(
  region = england_regions,
  cap_2021 = c(186100, 224400, 228100, 261900, 255600, 349000, 407400, 437600, 600000),
  cap_pre2021 = 600000  # Uniform cap before April 2021
)

ppd <- merge(ppd, htb_caps, by = "region", all.x = TRUE)

# Reform indicator
ppd[, post_reform := date_transfer >= as.Date("2021-04-01")]

# Active cap at time of transaction
ppd[, active_cap := fifelse(post_reform, cap_2021, cap_pre2021)]

# Distance to active cap (in £)
ppd[, dist_to_cap := price - active_cap]

# Relative price (price / cap)
ppd[, rel_price := price / active_cap]

# ==============================================================================
# 6. Summary Statistics
# ==============================================================================

cat("\n=== SUMMARY STATISTICS ===\n")
cat(sprintf("Total transactions (England, 2018-2023): %s\n",
            format(nrow(ppd), big.mark = ",")))
cat(sprintf("New builds: %s (%.1f%%)\n",
            format(sum(ppd$new_build), big.mark = ","),
            100 * mean(ppd$new_build)))
cat(sprintf("Post-reform (April 2021+): %s\n",
            format(sum(ppd$post_reform), big.mark = ",")))
cat(sprintf("Regions covered: %d\n", ppd[, uniqueN(region)]))

cat("\nNew builds by region and period:\n")
print(ppd[new_build == TRUE, .N, by = .(region, post_reform)][order(region, post_reform)])

cat("\nMedian price by region (new builds, post-reform):\n")
print(ppd[new_build == TRUE & post_reform == TRUE,
          .(median_price = as.double(median(price)), cap = as.double(first(cap_2021)),
            pct_below_cap = 100 * mean(price <= cap_2021)),
          by = region][order(cap)])

# ==============================================================================
# 7. Save Processed Data
# ==============================================================================

fwrite(ppd, file.path(data_dir, "ppd_england_2018_2023.csv"))
cat(sprintf("\nProcessed data saved: %s\n", file.path(data_dir, "ppd_england_2018_2023.csv")))

# === DATA VALIDATION (required) ===
stopifnot("Expected 9 English regions" = ppd[, uniqueN(region)] == 9)
stopifnot("Expected 6 years of data" = ppd[, uniqueN(year)] == 6)
stopifnot("Expected new builds present" = sum(ppd$new_build) > 100000)
stopifnot("Expected post-reform data" = sum(ppd$post_reform) > 500000)
cat("Data validation passed:", nrow(ppd), "rows,",
    ppd[, uniqueN(region)], "regions,",
    ppd[, uniqueN(year)], "years\n")
