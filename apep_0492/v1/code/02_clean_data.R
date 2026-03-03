# ==============================================================================
# 02_clean_data.R — Construct Analysis Variables
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
ppd <- fread(file.path(data_dir, "ppd_england_2018_2023.csv"))

# ==============================================================================
# 1. Create Analysis Periods
# ==============================================================================

ppd[, period := fcase(
  date_transfer < as.Date("2020-03-01"), "pre_covid",
  date_transfer >= as.Date("2020-03-01") & date_transfer < as.Date("2020-07-01"), "covid_lockdown",
  date_transfer >= as.Date("2020-07-01") & date_transfer < as.Date("2021-04-01"), "pre_reform",
  date_transfer >= as.Date("2021-04-01") & date_transfer < as.Date("2023-04-01"), "post_reform",
  default = "post_scheme"
)]

# Analysis sample: exclude COVID lockdown
ppd_analysis <- ppd[period != "covid_lockdown"]

cat(sprintf("Analysis sample: %s rows (excluding COVID lockdown)\n",
            format(nrow(ppd_analysis), big.mark = ",")))

# ==============================================================================
# 2. Price Bins for Bunching Analysis
# ==============================================================================

# Create £1,000 bins
ppd_analysis[, price_bin_1k := floor(price / 1000) * 1000]

# Create £500 bins (robustness)
ppd_analysis[, price_bin_500 := floor(price / 500) * 500]

# Create £2,000 bins (robustness)
ppd_analysis[, price_bin_2k := floor(price / 2000) * 2000]

# Distance to regional cap in £1,000 bins
ppd_analysis[, dist_bin_1k := floor(dist_to_cap / 1000) * 1000]

# ==============================================================================
# 3. Treatment Intensity Variable
# ==============================================================================

# Cap reduction intensity: how much did the cap drop for each region?
ppd_analysis[, cap_reduction := (cap_pre2021 - cap_2021) / cap_pre2021]
ppd_analysis[, cap_reduction_pct := 100 * cap_reduction]

# Treatment: post-reform x high-reduction region
ppd_analysis[, treat_intensity := fifelse(post_reform, cap_reduction, 0)]

# ==============================================================================
# 4. Geocode Border-Zone Postcodes for Spatial RDD
# ==============================================================================

# For spatial RDD, we need lat/lon of properties near regional borders
# Identify border postcodes by postcode area adjacency patterns

# Border postcode areas (areas that straddle or abut regional boundaries)
border_pc_areas <- list(
  NE_YH = list(
    r1_areas = c("DL", "DH"),                    # North East side
    r2_areas = c("HG", "YO", "LS", "BD", "HX"),  # Yorkshire side
    r1 = "North East", r2 = "Yorkshire and The Humber"
  ),
  EoE_LON = list(
    r1_areas = c("EN", "CM", "SS", "WD", "AL", "SG"),  # East of England side
    r2_areas = c("N", "E", "IG", "RM", "HA"),            # London side
    r1 = "East of England", r2 = "London"
  ),
  SE_LON = list(
    r1_areas = c("KT", "TN", "BR", "DA"),   # South East side
    r2_areas = c("SE", "CR", "SW", "SM"),     # London side
    r1 = "South East", r2 = "London"
  )
)

# Geocode these border postcodes via postcodes.io
# Only unique postcodes from border areas (much smaller set)
border_pcs <- unique(ppd_analysis[pc_area %in% unlist(lapply(border_pc_areas, function(x) c(x$r1_areas, x$r2_areas))),
                                   postcode_clean])

cat(sprintf("Border postcodes to geocode: %s\n", format(length(border_pcs), big.mark = ",")))

geocode_file <- file.path(data_dir, "border_postcode_coords.csv")

if (file.exists(geocode_file)) {
  cat("Loading cached border postcode coordinates...\n")
  border_coords <- fread(geocode_file)
} else {
  cat("Geocoding border postcodes via postcodes.io...\n")

  batch_size <- 100
  n_batches <- ceiling(length(border_pcs) / batch_size)
  results <- vector("list", n_batches)

  for (i in seq_len(n_batches)) {
    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, length(border_pcs))
    batch_pcs <- border_pcs[start_idx:end_idx]

    if (i %% 100 == 0 || i == 1) {
      cat(sprintf("  Batch %d/%d (%.1f%%)\n", i, n_batches, 100 * i / n_batches))
    }

    tryCatch({
      resp <- httr2::request("https://api.postcodes.io/postcodes") |>
        httr2::req_body_json(list(postcodes = batch_pcs)) |>
        httr2::req_perform()

      body <- httr2::resp_body_json(resp)

      batch_results <- lapply(body$result, function(x) {
        if (!is.null(x$result)) {
          data.table(
            postcode_clean = gsub(" ", "", x$query),
            latitude = if (!is.null(x$result$latitude)) x$result$latitude else NA_real_,
            longitude = if (!is.null(x$result$longitude)) x$result$longitude else NA_real_
          )
        } else {
          data.table(
            postcode_clean = gsub(" ", "", x$query),
            latitude = NA_real_,
            longitude = NA_real_
          )
        }
      })

      results[[i]] <- rbindlist(batch_results, fill = TRUE)
    }, error = function(e) {
      cat(sprintf("  Error in batch %d: %s\n", i, e$message))
      results[[i]] <- data.table(
        postcode_clean = batch_pcs,
        latitude = NA_real_,
        longitude = NA_real_
      )
    })

    if (i %% 50 == 0) Sys.sleep(0.5)
  }

  border_coords <- rbindlist(results, fill = TRUE)
  fwrite(border_coords, geocode_file)
  cat(sprintf("Geocoded %s border postcodes\n", format(nrow(border_coords), big.mark = ",")))
}

# Merge coordinates into analysis data
ppd_analysis <- merge(ppd_analysis, border_coords, by = "postcode_clean", all.x = TRUE)

# ==============================================================================
# 5. Compute Spatial RDD Distance Variables
# ==============================================================================

cat("Computing spatial RDD distances...\n")

border_pairs <- list(
  list(r1 = "North East", r2 = "Yorkshire and The Humber",
       gap = 228100 - 186100, label = "NE_YH"),
  list(r1 = "East of England", r2 = "London",
       gap = 600000 - 407400, label = "EoE_LON"),
  list(r1 = "South East", r2 = "London",
       gap = 600000 - 437600, label = "SE_LON")
)

for (bp in border_pairs) {
  r1_dt <- ppd_analysis[region == bp$r1 & new_build == TRUE &
                         post_reform == TRUE & !is.na(latitude)]
  r2_dt <- ppd_analysis[region == bp$r2 & new_build == TRUE &
                         post_reform == TRUE & !is.na(latitude)]

  cat(sprintf("  %s: %d in %s, %d in %s (with coords)\n",
              bp$label, nrow(r1_dt), bp$r1, nrow(r2_dt), bp$r2))

  if (nrow(r1_dt) > 10 && nrow(r2_dt) > 10) {
    # Convert to sf points
    r1_sf <- st_as_sf(r1_dt[, .(longitude, latitude, postcode_clean)],
                      coords = c("longitude", "latitude"), crs = 4326)
    r2_sf <- st_as_sf(r2_dt[, .(longitude, latitude, postcode_clean)],
                      coords = c("longitude", "latitude"), crs = 4326)

    # Compute distance matrices (this can be large, so limit to border zone)
    # First pass: identify properties within ~50km of each other
    # Use st_nearest_feature for efficiency
    r1_nearest <- st_nearest_feature(r1_sf, r2_sf)
    r1_dists <- as.numeric(st_distance(r1_sf, r2_sf[r1_nearest, ], by_element = TRUE))

    r2_nearest <- st_nearest_feature(r2_sf, r1_sf)
    r2_dists <- as.numeric(st_distance(r2_sf, r1_sf[r2_nearest, ], by_element = TRUE))

    # Signed distance: lower-cap side = negative, higher-cap side = positive
    signed_col <- paste0("signed_dist_", bp$label)
    ppd_analysis[, (signed_col) := NA_real_]

    # r1 is the lower-cap region (negative side)
    ppd_analysis[region == bp$r1 & new_build == TRUE & post_reform == TRUE & !is.na(latitude),
                 (signed_col) := -r1_dists]
    # r2 is the higher-cap region (positive side)
    ppd_analysis[region == bp$r2 & new_build == TRUE & post_reform == TRUE & !is.na(latitude),
                 (signed_col) := r2_dists]

    # Border zone: within 30km
    zone_col <- paste0("border_zone_", bp$label)
    ppd_analysis[, (zone_col) := FALSE]
    ppd_analysis[!is.na(get(signed_col)) & abs(get(signed_col)) <= 30000,
                 (zone_col) := TRUE]

    n_zone <- ppd_analysis[get(zone_col) == TRUE, .N]
    cat(sprintf("    -> %s in 30km border zone\n", format(n_zone, big.mark = ",")))
  }
}

# ==============================================================================
# 6. Save Analysis Dataset
# ==============================================================================

fwrite(ppd_analysis, file.path(data_dir, "ppd_analysis.csv"))
cat(sprintf("\nAnalysis dataset saved: %s rows\n", format(nrow(ppd_analysis), big.mark = ",")))

# Period summary
cat("\nPeriod summary:\n")
print(ppd_analysis[, .N, by = period][order(period)])

cat(sprintf("\nNew builds: %s\n", format(sum(ppd_analysis$new_build), big.mark = ",")))
cat(sprintf("Regions: %d\n", ppd_analysis[, uniqueN(region)]))
