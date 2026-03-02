###############################################################################
# 02_clean_data.R — Construct analysis dataset
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
###############################################################################

source("00_packages.R")

cat("=== Phase 2: Data Cleaning & Panel Construction ===\n")

# ---- 1. Load and combine PPD files ----
ppd_dir <- file.path(data_dir, "ppd")
ppd_files <- list.files(ppd_dir, pattern = "pp-\\d{4}\\.csv$", full.names = TRUE)

ppd_cols <- c(
  "txn_id", "price", "date_transfer", "postcode", "property_type",
  "old_new", "duration", "paon", "saon", "street", "locality",
  "town", "district", "county", "ppd_cat", "record_status"
)

cat("  Loading PPD files...\n")

# Column names matching the select indices
selected_cols <- c("txn_id", "price", "date_transfer", "postcode",
                   "property_type", "old_new", "duration",
                   "town", "district", "county", "ppd_cat")

ppd_list <- lapply(ppd_files, function(f) {
  cat(sprintf("    Reading %s\n", basename(f)))
  dt <- fread(f, header = FALSE,
              select = c(1:7, 12:15),
              col.names = selected_cols)
  dt
})
ppd <- rbindlist(ppd_list)
rm(ppd_list)
gc()

cat(sprintf("  PPD loaded: %s transactions\n", format(nrow(ppd), big.mark = ",")))

# ---- 2. Clean PPD ----
# Parse dates
ppd[, date_transfer := as.Date(substr(date_transfer, 1, 10), format = "%Y-%m-%d")]
ppd[, year := year(date_transfer)]
ppd[, quarter := quarter(date_transfer)]
ppd[, yearq := year + (quarter - 1) / 4]

# Clean postcodes (trim whitespace, uppercase)
ppd[, postcode := str_trim(toupper(postcode))]

# Filter: standard residential transactions only (PPD Category A)
ppd <- ppd[ppd_cat == "A"]

# Filter: valid property types (D=Detached, S=Semi, T=Terraced, F=Flat)
ppd <- ppd[property_type %in% c("D", "S", "T", "F")]

# Drop records with missing postcode or price
ppd <- ppd[!is.na(postcode) & postcode != "" & !is.na(price) & price > 0]

# Classify construction vintage
# old_new: Y = newly built, N = established residential property
ppd[, is_new_build := (old_new == "Y")]

# A property is "post-2009" if it's a new build sold on or after 2009-01-01
# A property is "pre-2009" if it's established (N) or a new build sold before 2009
ppd[, post2009_build := (is_new_build == TRUE & date_transfer >= as.Date("2009-01-01"))]
ppd[, pre2009_build := !post2009_build]

# Flood Re eligible: pre-2009 construction
ppd[, flood_re_eligible := pre2009_build]

# Log price
ppd[, log_price := log(price)]

cat(sprintf("  After cleaning: %s transactions\n", format(nrow(ppd), big.mark = ",")))
cat(sprintf("  Pre-2009 builds:  %s (%.1f%%)\n",
            format(sum(ppd$pre2009_build), big.mark = ","),
            100 * mean(ppd$pre2009_build)))
cat(sprintf("  Post-2009 builds: %s (%.1f%%)\n",
            format(sum(ppd$post2009_build), big.mark = ","),
            100 * mean(ppd$post2009_build)))

# ---- 3. Load and merge flood risk data ----
flood_file <- file.path(data_dir, "flood", "open_flood_risk_by_postcode.csv")

if (file.exists(flood_file)) {
  cat("  Loading flood risk data...\n")
  # File has no header; columns: postcode, FID, PROB_4BAND, SUITABILITY, PUB_DATE, X, easting, northing, lat, lon
  flood <- fread(flood_file, header = FALSE,
                 col.names = c("postcode", "fid", "flood_risk", "suitability",
                               "pub_date", "x_col", "easting", "northing", "lat", "lon"))

  # Standardize postcode format
  flood[, postcode := str_trim(toupper(postcode))]

  # Standardize flood risk categories
  flood[, flood_risk := trimws(flood_risk)]
  flood[, flood_risk := fcase(
    flood_risk == "High", "High",
    flood_risk == "Medium", "Medium",
    flood_risk == "Low", "Low",
    flood_risk == "Very Low", "Very Low",
    flood_risk == "None", NA_character_,
    default = NA_character_
  )]

  # Keep only postcodes with actual flood risk (not "None")
  flood <- flood[!is.na(flood_risk), .(postcode, flood_risk)]
  flood <- unique(flood, by = "postcode")

  cat(sprintf("  Flood risk postcodes: %s\n", format(nrow(flood), big.mark = ",")))
  cat("  Distribution:\n")
  print(flood[, .N, by = flood_risk][order(-N)])

  # ---- Exclude Welsh postcodes (EA flood data covers England only) ----
  welsh_areas <- c("SA", "SY", "LL", "LD", "CF", "NP")
  ppd[, pc_area := gsub("[0-9].*", "", postcode)]
  n_welsh <- ppd[pc_area %in% welsh_areas, .N]
  ppd <- ppd[!(pc_area %in% welsh_areas)]
  ppd[, pc_area := NULL]
  cat(sprintf("  Excluded %s Welsh postcode transactions (%.1f%%)\n",
              format(n_welsh, big.mark = ","), 100 * n_welsh / (nrow(ppd) + n_welsh)))

  # Merge PPD with flood risk
  ppd <- merge(ppd, flood, by = "postcode", all.x = TRUE)

  # Properties not in flood data are "No Risk" (not in any flood zone)
  ppd[is.na(flood_risk), flood_risk := "No Risk"]

  # Create binary flood zone indicators
  ppd[, in_flood_zone := flood_risk %in% c("High", "Medium")]
  ppd[, in_any_flood := flood_risk %in% c("High", "Medium", "Low")]

  cat(sprintf("  Transactions in flood zones (High/Medium): %s (%.1f%%)\n",
              format(sum(ppd$in_flood_zone), big.mark = ","),
              100 * mean(ppd$in_flood_zone)))

} else {
  stop("ERROR: Flood risk data not found. Re-run 01_fetch_data.R to download the EA flood risk dataset.")
}

# ---- 4. Create treatment variables ----
# Post Flood Re: April 2016 onwards
ppd[, post_floodre := (date_transfer >= as.Date("2016-04-01"))]

# DDD interaction terms
ppd[, dd_flood_post := in_flood_zone * post_floodre]
ppd[, dd_flood_eligible := in_flood_zone * flood_re_eligible]
ppd[, dd_post_eligible := post_floodre * flood_re_eligible]
ppd[, ddd := in_flood_zone * post_floodre * flood_re_eligible]

# Event time (years relative to 2016)
ppd[, event_year := year - 2016]

# ---- 5. Create postcode-level panel for volume analysis ----
# Count transactions per postcode × year-quarter × vintage
vol_panel <- ppd[, .(
  n_txns = .N,
  mean_price = mean(price),
  median_price = median(price),
  n_new_build = sum(is_new_build),
  share_new_build = mean(is_new_build)
), by = .(postcode, year, quarter, in_flood_zone, flood_risk)]

# ---- 6. Extract geographic identifiers from postcode ----
# Postcode area (first 1-2 letters) as a coarse geographic control
ppd[, pc_area := str_extract(postcode, "^[A-Z]+")]
ppd[, pc_district := str_extract(postcode, "^[A-Z]+\\d+")]

# District from PPD as LA proxy
ppd[, la_name := district]

# ---- 7. Summary statistics ----
cat("\n=== Summary Statistics ===\n")
cat(sprintf("  Total transactions: %s\n", format(nrow(ppd), big.mark = ",")))
cat(sprintf("  Year range: %d - %d\n", min(ppd$year), max(ppd$year)))
cat(sprintf("  Unique postcodes: %s\n", format(uniqueN(ppd$postcode), big.mark = ",")))

cat("\n  By flood zone × eligibility:\n")
ppd[, .(
  N = .N,
  Mean_Price = round(mean(price)),
  Median_Price = round(median(price)),
  Pct_Freehold = round(100 * mean(duration == "F"), 1)
), by = .(Flood_Zone = in_flood_zone, Eligible = flood_re_eligible)] |>
  print()

cat("\n  By period:\n")
ppd[, .(
  N = .N,
  Mean_Price = round(mean(price)),
  Pct_NewBuild = round(100 * mean(is_new_build), 1)
), by = .(Period = ifelse(post_floodre, "Post Flood Re", "Pre Flood Re"))] |>
  print()

# ---- 8. Save analysis dataset ----
outfile <- file.path(data_dir, "analysis_panel.parquet")
write_parquet(ppd, outfile)
cat(sprintf("\n  Analysis panel saved: %s (%.1f MB)\n",
            outfile, file.size(outfile) / 1e6))

# Save volume panel
vol_file <- file.path(data_dir, "volume_panel.parquet")
write_parquet(vol_panel, vol_file)
cat(sprintf("  Volume panel saved:   %s (%.1f MB)\n",
            vol_file, file.size(vol_file) / 1e6))

cat("\nData cleaning complete.\n")
