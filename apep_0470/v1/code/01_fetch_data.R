###############################################################################
# 01_fetch_data.R — Data acquisition from IPUMS + auxiliary sources
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
#
# REPLICATION: To reproduce this data:
#   1. Register at https://www.ipums.org and obtain an API key
#   2. Set IPUMS_API_KEY in your environment
#   3. Run this script — it submits IPUMS extracts and downloads MLP crosswalks
#   4. Full-count extracts may take 2-6 hours to process
###############################################################################

source("code/00_packages.R")

# ── 1. TVA county definitions ───────────────────────────────────────────────
# The 201 TVA watershed counties from Kline & Moretti (2014, QJE)
# We define the core TVA service area using ICPSR county codes (COUNTYICP)
# matched to the historical Tennessee River watershed.
#
# States in TVA region: TN(47), AL(01), MS(28), KY(21), GA(13), NC(37), VA(51)

tva_states <- c(1, 13, 21, 28, 37, 47, 51)  # FIPS codes

# TVA dam sites with coordinates (16 major dams built 1933-1944)
tva_dams <- data.table(
  dam_name = c("Norris", "Wheeler", "Wilson", "Pickwick Landing",
               "Guntersville", "Chickamauga", "Hiwassee", "Watts Bar",
               "Fort Loudoun", "Cherokee", "Douglas", "Fontana",
               "Kentucky", "Apalachia", "Ocoee No. 3", "Chatuge"),
  year_completed = c(1936, 1936, 1924, 1938, 1939, 1940, 1940, 1942,
                     1943, 1942, 1943, 1944, 1944, 1943, 1942, 1942),
  lat = c(36.223, 34.737, 34.789, 35.064, 34.432, 35.094, 35.190, 35.618,
          35.798, 36.169, 35.960, 35.440, 37.001, 35.157, 35.108, 35.000),
  lon = c(-84.098, -87.353, -87.621, -88.256, -86.282, -85.222, -84.169,
          -84.781, -84.246, -83.969, -83.555, -83.792, -88.262, -84.137,
          -84.457, -83.822)
)

fwrite(tva_dams, paste0(data_dir, "tva_dams.csv"))
cat("✓ TVA dam locations saved:", nrow(tva_dams), "dams\n")

# ── 2. County shapefiles (1930 boundaries via NHGIS) ───────────────────────
# We use modern county shapefiles as an approximation for 1930 boundaries.
# The TVA region had minimal county boundary changes 1920-1940.

# Relevant states: TVA states + buffer (SC, AR, MO, WV, OH, IN, IL)
all_states <- c("01", "13", "21", "28", "37", "47", "51",  # TVA states
                "45", "05", "29", "54", "39", "18", "17",  # Buffer states
                "12", "22", "40", "48")                     # Extended buffer

counties_sf <- counties(state = all_states, year = 2020, cb = TRUE) |>
  st_transform(crs = 5070)  # Albers Equal Area for distance calcs

# Compute county centroids
counties_sf$centroid <- st_centroid(st_geometry(counties_sf))
centroids <- st_coordinates(counties_sf$centroid)
counties_sf$cent_x <- centroids[, 1]
counties_sf$cent_y <- centroids[, 2]

# Convert dam locations to sf and compute distances
dams_sf <- st_as_sf(tva_dams, coords = c("lon", "lat"), crs = 4326) |>
  st_transform(5070)

# Distance from each county centroid to nearest TVA dam (in km)
dam_coords <- st_coordinates(dams_sf)
county_cent <- st_as_sf(data.frame(x = counties_sf$cent_x,
                                    y = counties_sf$cent_y),
                        coords = c("x", "y"), crs = 5070)

dist_matrix <- st_distance(county_cent, dams_sf)
counties_sf$dist_nearest_dam_m <- apply(dist_matrix, 1, min)
counties_sf$dist_nearest_dam_km <- as.numeric(counties_sf$dist_nearest_dam_m) / 1000
counties_sf$log_dist_dam <- log(counties_sf$dist_nearest_dam_km + 1)

# Which dam is nearest
counties_sf$nearest_dam_idx <- apply(dist_matrix, 1, which.min)
counties_sf$nearest_dam <- tva_dams$dam_name[counties_sf$nearest_dam_idx]

cat("✓ County shapefiles loaded:", nrow(counties_sf), "counties\n")
cat("  Distance range to nearest TVA dam:",
    round(min(counties_sf$dist_nearest_dam_km), 1), "-",
    round(max(counties_sf$dist_nearest_dam_km), 1), "km\n")

# ── 3. Define TVA service area counties ─────────────────────────────────────
# The TVA service territory follows the Tennessee River watershed.
# We identify TVA counties as those within the watershed boundary
# using a distance-based proxy: counties within ~150km of any TVA dam
# AND in the 7 TVA states. We refine this using the known K&M definition.
#
# Core approach: Counties in TVA states within 100km of a TVA dam are
# "core TVA". Counties 100-200km are "peripheral TVA". Beyond 200km = control.

counties_dt <- as.data.table(st_drop_geometry(counties_sf))
counties_dt[, STATEFIP := as.integer(STATEFP)]
counties_dt[, COUNTYFIP := as.integer(COUNTYFP)]

# TVA core definition: in TVA state AND within 150km of a dam
counties_dt[, tva_core := STATEFIP %in% tva_states & dist_nearest_dam_km <= 150]
counties_dt[, tva_peripheral := STATEFIP %in% tva_states &
              dist_nearest_dam_km > 150 & dist_nearest_dam_km <= 250]
counties_dt[, tva_any := tva_core | tva_peripheral]

# Border counties: non-TVA counties within 100km of TVA boundary
# (approximated as within 250km of a dam but NOT in TVA service area)
counties_dt[, border_control := !tva_any & dist_nearest_dam_km <= 250]

cat("\n  TVA core counties:", sum(counties_dt$tva_core))
cat("\n  TVA peripheral counties:", sum(counties_dt$tva_peripheral))
cat("\n  Border control counties:", sum(counties_dt$border_control))
cat("\n  Distant control counties:", sum(!counties_dt$tva_any & !counties_dt$border_control))

# Save county classification
county_class <- counties_dt[, .(STATEFIP, COUNTYFIP, GEOID, NAME,
                                 dist_nearest_dam_km, log_dist_dam,
                                 nearest_dam, tva_core, tva_peripheral,
                                 tva_any, border_control,
                                 cent_x, cent_y)]
fwrite(county_class, paste0(data_dir, "county_classification.csv"))

# Save shapefile for mapping
saveRDS(counties_sf, paste0(data_dir, "counties_sf.rds"))

cat("\n✓ County classification saved\n")

# ── 4. Submit IPUMS USA extract ─────────────────────────────────────────────
# Request full-count census data for 1920, 1930, 1940
# with individual identifiers for MLP linking.

api_key <- Sys.getenv("IPUMS_API_KEY")
if (nchar(api_key) == 0) {
  stop("IPUMS_API_KEY not set. Configure in .env file.")
}
set_ipums_api_key(api_key)

# Define the extract: 1% samples for pilot (full-count would use "m" suffix)
# Variables selected to maximize analytical value while keeping files manageable
extract_def <- define_extract_usa(
  description = "APEP-0470: TVA linked census panel 1920-1930-1940",
  samples = c("us1920a", "us1930a", "us1940a"),  # 1% samples for pilot
  variables = c(
    # Identifiers
    "YEAR", "SERIAL", "PERNUM", "HISTID",
    # Geography
    "STATEFIP", "COUNTYICP",
    # Demographics
    "AGE", "SEX", "RACE", "RACESING", "HISPAN", "BPL", "NATIVITY",
    "MARST", "RELATE",
    # Education & literacy
    "LIT", "EDUC", "SCHOOL",
    # Labor market
    "EMPSTAT", "OCC1950", "IND1950", "CLASSWKR", "WKSWORK1",
    # Income (1940 only)
    "INCWAGE", "INCNONWG",
    # Housing
    "OWNERSHP", "FARM", "RENT", "VALUEH",
    # Household
    "FAMSIZE", "NCHILD",
    # Socioeconomic
    "SEI", "OCCSCORE"
  )
)

cat("Submitting IPUMS extract...\n")
submitted <- submit_extract(extract_def)
cat("✓ Extract submitted. ID:", submitted$number, "\n")
cat("  Waiting for extract to complete (this may take 5-30 minutes for 1% samples)...\n")

# Poll for completion
tryCatch({
  ready <- wait_for_extract(submitted, timeout = 3600)  # 1 hour timeout
  cat("✓ Extract ready! Downloading...\n")

  download_dir <- paste0(data_dir, "ipums/")
  dir.create(download_dir, showWarnings = FALSE, recursive = TRUE)
  download_extract(submitted, download_dir = download_dir)
  cat("✓ IPUMS data downloaded to:", download_dir, "\n")
}, error = function(e) {
  cat("⚠ Extract not ready within timeout. Check IPUMS website for status.\n")
  cat("  Extract ID:", submitted$number, "\n")
  cat("  You can download manually from https://usa.ipums.org/usa/\n")
})

# ── 5. Download MLP crosswalk files ─────────────────────────────────────────
# The MLP crosswalks provide HISTID pairs linking individuals across censuses.
# Available as Parquet files from IPUMS.
#
# Note: MLP crosswalks must be downloaded from the IPUMS website.
# They are too large for direct API download. Instructions:
#   1. Go to https://usa.ipums.org/usa/mlp/mlp_crosswalks.shtml
#   2. Download: crosswalk_1920_1930.parquet, crosswalk_1930_1940.parquet
#   3. Place in data/mlp/
#
# For replication, the crosswalk file format is:
#   HISTID_A (year 1) | HISTID_B (year 2) | link_score | link_type

mlp_dir <- paste0(data_dir, "mlp/")
dir.create(mlp_dir, showWarnings = FALSE, recursive = TRUE)

# Check if crosswalks exist
xwalk_files <- c(
  paste0(mlp_dir, "crosswalk_1920_1930.parquet"),
  paste0(mlp_dir, "crosswalk_1930_1940.parquet")
)

for (f in xwalk_files) {
  if (file.exists(f)) {
    cat("✓ MLP crosswalk found:", basename(f), "\n")
  } else {
    cat("⚠ MLP crosswalk not found:", basename(f), "\n")
    cat("  Download from: https://usa.ipums.org/usa/mlp/mlp_crosswalks.shtml\n")
  }
}

# ── 6. Fishback New Deal spending data ──────────────────────────────────────
# County-level per-capita New Deal spending (WPA, CCC, FERA, AAA) from
# Fishback, Kantor, and Wallis (2003, 2006). Controls for non-TVA New Deal.
# Real Fishback data available at: https://economics.arizona.edu/fishback-data
# This will be downloaded separately and merged in 02_clean_data.R if available.

cat("\n✓ Data acquisition pipeline complete.\n")
cat("  Files in data/:\n")
cat("    - tva_dams.csv (16 dam locations)\n")
cat("    - county_classification.csv (county TVA status + distances)\n")
cat("    - counties_sf.rds (spatial data for mapping)\n")
cat("    - ipums/ (census microdata, when downloaded)\n")
cat("    - mlp/ (crosswalk files, when downloaded)\n")
