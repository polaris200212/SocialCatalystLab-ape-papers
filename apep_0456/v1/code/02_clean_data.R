## ==========================================================================
## 02_clean_data.R — Process DVF and compute distances to ZFE boundaries
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- 1. Load and combine DVF data ----
cat("Loading DVF data...\n")

dvf_raw_dir <- file.path(data_dir, "dvf_raw")
# Only load departmental files (not the full national file)
dvf_files <- list.files(dvf_raw_dir, pattern = "dvf_20[0-9]{2}_[0-9]+\\.csv\\.gz$", full.names = TRUE)
# Focus on Paris departments (75, 92, 93, 94) since we only have Paris ZFE boundary
paris_deps <- c("75", "92", "93", "94")
dvf_files <- dvf_files[grepl(paste0("_(", paste(paris_deps, collapse="|"), ")\\.csv\\.gz$"), dvf_files)]
cat("Loading", length(dvf_files), "DVF files for Paris departments...\n")

dvf_list <- lapply(dvf_files, function(f) {
  cat("  Reading:", basename(f), "\n")
  df <- fread(f, select = c(
    "id_mutation", "date_mutation", "nature_mutation", "valeur_fonciere",
    "code_postal", "code_commune", "nom_commune", "code_departement",
    "type_local", "surface_reelle_bati", "nombre_pieces_principales",
    "nombre_lots", "surface_terrain", "longitude", "latitude"
  ), na.strings = c("", "NA"))
  return(df)
})

dvf <- rbindlist(dvf_list)
cat("Total DVF rows loaded:", nrow(dvf), "\n")

# ---- 2. Clean DVF ----
cat("Cleaning DVF...\n")

# Filter to sales only (Vente)
dvf <- dvf[nature_mutation == "Vente"]

# Remove missing prices, coordinates, or surface
dvf <- dvf[!is.na(valeur_fonciere) & valeur_fonciere > 0]
dvf <- dvf[!is.na(longitude) & !is.na(latitude)]
dvf <- dvf[!is.na(surface_reelle_bati) & surface_reelle_bati > 0]

# Filter to residential properties
dvf <- dvf[type_local %in% c("Appartement", "Maison")]

# Create price per sqm
dvf[, price_sqm := valeur_fonciere / surface_reelle_bati]

# Remove extreme outliers (below 500 EUR/sqm or above 30,000 EUR/sqm)
dvf <- dvf[price_sqm >= 500 & price_sqm <= 30000]

# Parse date and extract year/month
dvf[, date_mutation := as.Date(date_mutation)]
dvf[, year := year(date_mutation)]
dvf[, month := month(date_mutation)]
dvf[, yearmonth := year * 100 + month]

# Log price per sqm
dvf[, log_price_sqm := log(price_sqm)]

cat("DVF after cleaning:", nrow(dvf), "transactions\n")

# ---- 3. Load ZFE boundaries ----
cat("Loading ZFE boundaries...\n")

zfe_dir <- file.path(data_dir, "zfe_boundaries")

# Function to safely load a ZFE GeoJSON
load_zfe <- function(file, city_name, start_date) {
  if (!file.exists(file)) {
    cat("  MISSING:", file, "\n")
    return(NULL)
  }
  tryCatch({
    g <- st_read(file, quiet = TRUE)
    # Ensure WGS84
    g <- st_transform(g, 4326)
    # Union all features into single polygon
    g <- st_union(g)
    g_sf <- st_sf(
      city = city_name,
      zfe_start = as.Date(start_date),
      geometry = g
    )
    cat("  Loaded:", city_name, "\n")
    return(g_sf)
  }, error = function(e) {
    cat("  ERROR loading", city_name, ":", e$message, "\n")
    return(NULL)
  })
}

# ZFE start dates (Crit'Air 5 restriction = first meaningful enforcement)
# Paris Grand Paris Métropole: June 1, 2019 (Crit'Air 5 ban)
# Lyon: January 1, 2020 (Crit'Air 5 ban)
# Grenoble: 2019 (pilot), formalized 2020
# Strasbourg: January 1, 2022 (Crit'Air 5 ban)

zfe_list <- list(
  load_zfe(file.path(zfe_dir, "zfe_paris.geojson"), "Paris", "2019-06-01")
)
# Note: Lyon, Grenoble, Strasbourg boundaries unavailable; focusing on Paris

# Keep only successfully loaded
zfe_list <- Filter(Negate(is.null), zfe_list)
cat("ZFE boundaries loaded:", length(zfe_list), "\n")

if (length(zfe_list) == 0) {
  stop("No ZFE boundaries loaded. Cannot proceed.")
}

zfe_all <- do.call(rbind, zfe_list)

# ---- 4. Assign DVF transactions to nearest ZFE city ----
cat("Assigning transactions to ZFE cities...\n")

# Map departments to cities (Paris ZFE only)
# Ensure type matches DVF data
dvf[, code_departement := as.character(code_departement)]
dept_city_map <- data.table(
  code_departement = c("75", "92", "93", "94"),
  zfe_city = c("Paris", "Paris", "Paris", "Paris")
)

dvf <- merge(dvf, dept_city_map, by = "code_departement", all.x = FALSE)
cat("DVF with city assignment:", nrow(dvf), "\n")

# ---- 5. Compute signed distance to ZFE boundary ----
cat("Computing distances to ZFE boundaries...\n")
cat("  This may take several minutes for large datasets...\n")

# Convert DVF to sf object
dvf_sf <- st_as_sf(dvf, coords = c("longitude", "latitude"), crs = 4326)

# Process city by city
dvf$dist_to_boundary <- NA_real_
dvf$inside_zfe <- NA_integer_

for (city_name in unique(dvf$zfe_city)) {
  cat("  Processing", city_name, "...\n")

  # Get city ZFE polygon
  zfe_city <- zfe_all[zfe_all$city == city_name, ]
  if (nrow(zfe_city) == 0) {
    cat("    No ZFE boundary for", city_name, "- skipping\n")
    next
  }

  # Get transactions for this city
  idx <- which(dvf$zfe_city == city_name)
  city_sf <- dvf_sf[idx, ]

  # Check inside/outside
  inside <- as.integer(st_within(city_sf, zfe_city, sparse = FALSE)[, 1])

  # Compute distance to boundary (in meters)
  # Use projected CRS for accurate distance (Lambert-93 for France)
  city_proj <- st_transform(city_sf, 2154)  # Lambert-93
  zfe_proj <- st_transform(zfe_city, 2154)
  boundary <- st_boundary(zfe_proj)

  dist_m <- as.numeric(st_distance(city_proj, boundary))

  # Sign: positive inside, negative outside
  signed_dist <- ifelse(inside == 1, dist_m, -dist_m)

  dvf$dist_to_boundary[idx] <- signed_dist
  dvf$inside_zfe[idx] <- inside

  cat("    Transactions:", length(idx),
      "| Inside:", sum(inside == 1, na.rm = TRUE),
      "| Outside:", sum(inside == 0, na.rm = TRUE), "\n")
}

# Remove transactions with NA distance
dvf <- dvf[!is.na(dist_to_boundary)]
cat("DVF with distances:", nrow(dvf), "\n")

# ---- 6. Add ZFE timing variables ----
cat("Adding ZFE timing variables...\n")

zfe_dates <- data.table(
  zfe_city = c("Paris", "Lyon", "Grenoble", "Strasbourg"),
  zfe_start = as.Date(c("2019-06-01", "2020-01-01", "2019-07-01", "2022-01-01"))
)

dvf <- merge(dvf, zfe_dates, by = "zfe_city", all.x = TRUE)
# ZFE enforcement phases (Paris)
# Phase 0: Pre/weak enforcement (2020) - Crit'Air 5 only + COVID
# Phase 1: Medium enforcement (2021-H1) - Crit'Air 4 announced
# Phase 2: Full Crit'Air 4 (2021-H2 to 2023-H1)
# Phase 3: Crit'Air 3 (2023-H2 onward)
dvf[, post_zfe := as.integer(date_mutation >= zfe_start)]
dvf[, enforcement_phase := fcase(
  year == 2020, 0L,
  year == 2021 & month < 6, 1L,
  year == 2021 & month >= 6, 2L,
  year == 2022, 2L,
  year == 2023 & month < 7, 2L,
  year == 2023 & month >= 7, 3L,
  year >= 2024, 3L,
  default = 0L
)]
# For pre/post comparisons, use 2020 as "low enforcement" baseline
dvf[, strong_enforcement := as.integer(enforcement_phase >= 2)]

cat("Enforcement phase distribution:\n")
print(dvf[, .N, by = enforcement_phase][order(enforcement_phase)])
cat("Pre-ZFE (2020, weak):", sum(dvf$enforcement_phase == 0), "\n")
cat("Post-ZFE (strong, 2021H2+):", sum(dvf$strong_enforcement == 1), "\n")

# ---- 7. Create analysis distance variable ----
# Convert to km for readability
dvf[, dist_km := dist_to_boundary / 1000]

# ---- 7b. Assign boundary segments ----
# Project each transaction to nearest point on boundary, then bin by position along boundary
cat("Assigning boundary segments...\n")
dvf_proj <- st_as_sf(dvf, coords = c("longitude", "latitude"), crs = 4326)
dvf_proj <- st_transform(dvf_proj, 2154)

# Get boundary line
zfe_proj <- st_transform(zfe_all, 2154)
boundary_line <- st_boundary(zfe_proj)

# Sample points along boundary at ~1km intervals for segment anchors
boundary_pts <- st_line_sample(boundary_line, density = 1/1000)  # 1 point per km
boundary_pts <- st_cast(boundary_pts, "POINT")

# For each transaction, find nearest boundary point (= segment assignment)
nn <- st_nearest_feature(dvf_proj, boundary_pts)
dvf$boundary_segment <- nn

# Create coarser segments (~5km) for FE
dvf[, segment_5km := ceiling(boundary_segment / 5)]

cat("  Boundary segments assigned:", length(unique(dvf$segment_5km)), "segments (5km)\n")

# ---- 7c. Year-quarter variable ----
dvf[, quarter := ceiling(month / 3)]
dvf[, yearqtr := paste0(year, "Q", quarter)]

# ---- 8. Save cleaned dataset ----
cat("Saving cleaned dataset...\n")

# Save key variables only
analysis_vars <- c(
  "id_mutation", "date_mutation", "year", "month", "yearmonth",
  "quarter", "yearqtr",
  "code_departement", "code_commune", "nom_commune", "zfe_city",
  "valeur_fonciere", "surface_reelle_bati", "nombre_pieces_principales",
  "nombre_lots", "type_local", "surface_terrain",
  "longitude", "latitude",
  "price_sqm", "log_price_sqm",
  "dist_to_boundary", "dist_km", "inside_zfe",
  "boundary_segment", "segment_5km",
  "zfe_start", "post_zfe", "enforcement_phase", "strong_enforcement"
)

dvf_out <- dvf[, ..analysis_vars]
fwrite(dvf_out, file.path(data_dir, "dvf_zfe_analysis.csv"))

cat("\n=== Cleaning Summary ===\n")
cat("Final dataset:", nrow(dvf_out), "transactions\n")
cat("Cities:", paste(unique(dvf_out$zfe_city), collapse = ", "), "\n")
cat("Years:", paste(range(dvf_out$year), collapse = "-"), "\n")
cat("Distance range:", round(min(dvf_out$dist_km), 2), "to",
    round(max(dvf_out$dist_km), 2), "km\n")
cat("Saved to:", file.path(data_dir, "dvf_zfe_analysis.csv"), "\n")

# Summary by city and period
cat("\n=== By City and Period ===\n")
dvf_out[, .(
  n = .N,
  mean_price_sqm = round(mean(price_sqm), 0),
  median_price_sqm = round(median(price_sqm), 0),
  mean_dist_km = round(mean(dist_km), 2)
), by = .(zfe_city, post_zfe)] |> print()
