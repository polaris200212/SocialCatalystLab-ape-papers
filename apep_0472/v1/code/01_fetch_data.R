#' ---
#' Selective Licensing and Crime Displacement
#' 01_fetch_data.R — Fetch crime data from Police API + licensing dates
#' ---

source("code/00_packages.R")

# ============================================================================
# 1. SELECTIVE LICENSING ADOPTION DATES (compiled from council websites,
#    NRLA Licensing 365, House of Commons Library SN04634)
# ============================================================================

message("Building licensing adoption date panel...")

licensing_dates <- tribble(
  ~la_name,              ~la_code,   ~adoption_date,  ~coverage,
  # Borough/city-wide schemes (cleanest treatment)
  "Newham",              "E09000025", "2013-01-01",   "borough",
  "Liverpool",           "E08000012", "2015-04-01",   "city",
  "Nottingham",          "E06000018", "2018-08-01",   "city",
  "Waltham Forest",      "E09000031", "2020-05-01",   "borough",
  "Enfield",             "E09000010", "2021-09-01",   "14_wards",
  "Birmingham",          "E08000025", "2023-06-05",   "25_wards",
  "Brent",               "E09000005", "2024-04-01",   "borough",
  "Tower Hamlets",       "E09000030", "2024-04-01",   "borough",
  "Lambeth",             "E09000022", "2024-09-02",   "borough",
  # Sub-area schemes (LA-level intent-to-treat)
  "Rotherham",           "E08000018", "2015-06-01",   "sub_area",
  "Doncaster",           "E08000017", "2015-06-01",   "sub_area",
  "Hartlepool",          "E06000001", "2015-06-01",   "partial",
  "Harrow",              "E09000015", "2018-03-14",   "2_wards",
  "Burnley",             "E07000117", "2019-01-01",   "sub_area",
  "Middlesbrough",       "E06000002", "2021-06-14",   "ward",
  "Salford",             "E08000006", "2022-09-01",   "sub_area",
  "Bradford",            "E08000032", "2022-06-01",   "sub_area",
  "Sefton",              "E08000014", "2023-03-01",   "sub_area",
  "Blackpool",           "E06000009", "2025-04-01",   "central",
  "Leeds",               "E08000035", "2026-02-09",   "partial",
  "Westminster",         "E09000033", "2025-11-24",   "sub_area",
  # Additional confirmed schemes
  "Croydon",             "E09000008", "2015-10-01",   "partial",
  "Barking and Dagenham","E09000002", "2017-09-01",   "partial",
  "Peterborough",        "E06000031", "2016-12-01",   "sub_area",
  "Coventry",            "E08000026", "2019-03-01",   "sub_area",
  "Stoke-on-Trent",      "E06000021", "2019-06-01",   "sub_area",
  "Leicester",           "E06000016", "2020-03-01",   "sub_area",
  "Manchester",          "E08000003", "2022-01-01",   "sub_area",
  "Wolverhampton",       "E08000031", "2019-07-01",   "sub_area",
  "Oldham",              "E08000004", "2022-06-01",   "sub_area",
  "Luton",               "E06000032", "2022-01-01",   "sub_area"
) |>
  mutate(
    adoption_date = as.Date(adoption_date),
    # For DiD: first treated month is the first FULL month after adoption
    first_treated_month = floor_date(adoption_date %m+% months(1), "month")
  )

message("  ", nrow(licensing_dates), " LAs with licensing dates compiled")
write_csv(licensing_dates, file.path(DATA_DIR, "licensing_dates.csv"))

# ============================================================================
# 2. POLICE API — BULK CRIME DATA BY LSOA-MONTH
# ============================================================================
#
# The Police API endpoint for LSOA-level aggregated data:
#   https://data.police.uk/data/
#
# For a national LSOA-month panel, we use the BULK DOWNLOAD approach:
# data.police.uk provides downloadable CSV archives by police force and month.
# This is far more efficient than querying the API point-by-point.
#
# Alternative: Use the API's /crimes-no-location endpoint for force-level
# or download the complete dataset from:
#   https://data.police.uk/data/
#
# For this paper, we use the API to fetch crime counts for each police force
# at the LSOA level, aggregated monthly.
# ============================================================================

message("Fetching crime data from Police API...")

# --- Helper: Fetch all crime for a force in a specific month ---
fetch_force_crime <- function(force_id, date_str) {
  url <- sprintf("https://data.police.uk/api/crimes-no-location?category=all-crime&force=%s&date=%s",
                 force_id, date_str)
  tryCatch({
    resp <- request(url) |>
      req_timeout(30) |>
      req_retry(max_tries = 3) |>
      req_perform()
    fromJSON(rawToChar(resp$body))
  }, error = function(e) {
    message("  Error for ", force_id, " ", date_str, ": ", e$message)
    NULL
  })
}

# --- Helper: Fetch street-level crime for a poly-bounded area ---
# The API limit is ~1 mile radius or custom polygon with ≤100 points
# For national coverage, bulk downloads are better.

# --- Approach: Use API to get LSOA-level crime summaries ---
# For each treated/control LA, we can get crime data by month

# Build LSOA-level crime panel using bulk street-level data
# The Police API has a /crimes-street/all-crime?poly= endpoint
# but the most scalable approach is bulk CSV downloads from data.police.uk

# For this paper, we'll use a two-stage approach:
# Stage 1: Download bulk crime CSVs from data.police.uk for key forces
# Stage 2: Aggregate to LSOA-month level

# The bulk data is available at: https://data.police.uk/data/
# It allows downloading by date range and police force
# Each CSV row = one crime incident with LSOA code, category, month

# Since bulk download requires manual interaction, we'll use the API
# to build a more targeted panel around treated and control LAs.

# --- Build LA-to-police-force mapping ---
# Map Local Authorities to Police Force Areas (needed for API queries)

message("Building LA to Police Force mapping via postcodes.io...")

# Use sample postcodes from each treated LA to identify police forces
la_force_map <- licensing_dates |>
  select(la_name, la_code)

# For efficiency, use a pre-built mapping of LAs to police forces
# based on ONS geography lookups
# Most metropolitan boroughs map to their regional force
la_to_force <- tribble(
  ~la_code,    ~force_id,
  "E09000025", "metropolitan",  # Newham -> Met Police
  "E08000012", "merseyside",    # Liverpool
  "E06000018", "nottinghamshire", # Nottingham
  "E09000031", "metropolitan",  # Waltham Forest -> Met
  "E09000010", "metropolitan",  # Enfield -> Met
  "E08000025", "west-midlands", # Birmingham
  "E09000005", "metropolitan",  # Brent -> Met
  "E09000030", "metropolitan",  # Tower Hamlets -> Met
  "E09000022", "metropolitan",  # Lambeth -> Met
  "E08000018", "south-yorkshire", # Rotherham
  "E08000017", "south-yorkshire", # Doncaster
  "E06000001", "cleveland",     # Hartlepool
  "E09000015", "metropolitan",  # Harrow -> Met
  "E07000117", "lancashire",    # Burnley
  "E06000002", "cleveland",     # Middlesbrough
  "E08000006", "greater-manchester", # Salford
  "E08000032", "west-yorkshire", # Bradford
  "E08000014", "merseyside",    # Sefton
  "E06000009", "lancashire",    # Blackpool
  "E08000035", "west-yorkshire", # Leeds
  "E09000033", "metropolitan",  # Westminster -> Met
  "E09000008", "metropolitan",  # Croydon -> Met
  "E09000002", "metropolitan",  # Barking -> Met
  "E06000031", "cambridgeshire", # Peterborough
  "E08000026", "west-midlands", # Coventry
  "E06000021", "staffordshire", # Stoke
  "E06000016", "leicestershire", # Leicester
  "E08000003", "greater-manchester", # Manchester
  "E08000031", "west-midlands", # Wolverhampton
  "E08000004", "greater-manchester", # Oldham
  "E06000032", "bedfordshire"   # Luton
)

# ============================================================================
# 3. DOWNLOAD POLICE BULK DATA
# ============================================================================
# The data.police.uk site provides monthly CSVs.
# Direct URL pattern for archive downloads:
#   https://data.police.uk/data/archive/{YYYY-MM}.zip
# Each zip contains: {force}/{YYYY-MM}-street.csv with columns:
#   Crime ID, Month, Reported by, Falls within, Longitude, Latitude,
#   Location, LSOA code, LSOA name, Crime type, Last outcome category, Context

# We download monthly archives and extract LSOA-level crime counts

CRIME_DIR <- file.path(DATA_DIR, "crime_raw")
dir.create(CRIME_DIR, showWarnings = FALSE, recursive = TRUE)

# Download police bulk data for the analysis period (2013-2024)
# Focus on months around treatment dates
download_police_month <- function(year, month) {
  date_str <- sprintf("%04d-%02d", year, month)
  zip_path <- file.path(CRIME_DIR, paste0(date_str, ".zip"))
  csv_pattern <- paste0("*-street.csv")

  if (file.exists(zip_path) && file.size(zip_path) > 1000) {
    return(invisible(NULL))
  }

  url <- sprintf("https://data.police.uk/data/archive/%s.zip", date_str)
  tryCatch({
    download.file(url, zip_path, mode = "wb", quiet = TRUE)
    message("  Downloaded: ", date_str)
  }, error = function(e) {
    message("  Failed to download ", date_str, ": ", e$message)
    if (file.exists(zip_path)) file.remove(zip_path)
  })
}

# Download data: focus on key years around treatments
# Pre-period: 2011-2012 (earliest Police data)
# Treatment waves: 2013-2024
years_months <- expand.grid(
  year = 2011:2024,
  month = c(1, 4, 7, 10)  # Quarterly for efficiency; full monthly later if needed
)

message("Downloading Police bulk data (quarterly snapshots)...")
message("  This may take several minutes...")

for (i in seq_len(nrow(years_months))) {
  download_police_month(years_months$year[i], years_months$month[i])
  Sys.sleep(0.5)  # Rate limiting
}

# ============================================================================
# 4. PARSE BULK CRIME DATA INTO LSOA-MONTH PANEL
# ============================================================================

message("Parsing crime data into LSOA-month panel...")

# IMPORTANT: Police bulk archives are CUMULATIVE — each zip contains ALL data
# from the start of collection through that month. So we only need the LATEST
# archive, which contains everything.

zip_files <- sort(list.files(CRIME_DIR, pattern = "\\.zip$", full.names = TRUE))
latest_zip <- tail(zip_files, 1)
message("  Using latest archive (cumulative): ", basename(latest_zip))

# Parse the single latest archive, processing one force-CSV at a time
# to stay within memory limits
tmp_dir <- tempfile("crime_")
dir.create(tmp_dir, showWarnings = FALSE)

message("  Extracting archive...")
csv_files <- unzip(latest_zip, exdir = tmp_dir, junkpaths = FALSE)
street_files <- csv_files[grepl("-street\\.csv$", csv_files)]
message("  Found ", length(street_files), " force-month CSV files")

# Process force CSVs in batches to aggregate incrementally
# Write intermediate aggregations to disk
AGG_DIR <- file.path(DATA_DIR, "crime_agg")
dir.create(AGG_DIR, showWarnings = FALSE)

batch_size <- 20  # files per batch
n_batches <- ceiling(length(street_files) / batch_size)

for (b in seq_len(n_batches)) {
  batch_file <- file.path(AGG_DIR, sprintf("batch_%03d.csv", b))
  batch_total <- file.path(AGG_DIR, sprintf("total_%03d.csv", b))
  if (file.exists(batch_file) && file.size(batch_file) > 100) next

  idx <- ((b - 1) * batch_size + 1):min(b * batch_size, length(street_files))
  message("  Processing batch ", b, "/", n_batches, " (", length(idx), " files)")

  batch_list <- lapply(street_files[idx], function(f) {
    tryCatch({
      dt <- fread(f, select = c("Month", "LSOA code", "Crime type"),
                  showProgress = FALSE)
      setnames(dt, c("month", "lsoa_code", "crime_type"))
      # Filter to England only (E01* LSOAs)
      dt <- dt[grepl("^E01", lsoa_code)]
      dt
    }, error = function(e) NULL)
  })
  raw <- rbindlist(batch_list[!sapply(batch_list, is.null)])
  rm(batch_list); gc(verbose = FALSE)

  if (nrow(raw) > 0) {
    cat_agg <- raw[, .(crime_count = .N), by = .(month, lsoa_code, crime_type)]
    total_agg <- raw[, .(total_crime = .N), by = .(month, lsoa_code)]
    fwrite(cat_agg, batch_file)
    fwrite(total_agg, batch_total)
    rm(cat_agg, total_agg)
  }
  rm(raw); gc(verbose = FALSE)
}

# Clean up extracted files
unlink(tmp_dir, recursive = TRUE)

# Combine batch aggregations (much smaller since pre-filtered to England)
message("  Combining batch aggregations...")
cat_files <- list.files(AGG_DIR, pattern = "^batch_.*\\.csv$", full.names = TRUE)
total_files <- list.files(AGG_DIR, pattern = "^total_.*\\.csv$", full.names = TRUE)

lsoa_crime <- rbindlist(lapply(cat_files, fread))
# Re-aggregate across batches (same LSOA-month-category may appear in multiple force files)
lsoa_crime <- lsoa_crime[, .(crime_count = sum(crime_count)), by = .(month, lsoa_code, crime_type)]

lsoa_crime_total <- rbindlist(lapply(total_files, fread))
lsoa_crime_total <- lsoa_crime_total[, .(total_crime = sum(total_crime)), by = .(month, lsoa_code)]

message("  LSOA-month-category observations: ", format(nrow(lsoa_crime), big.mark = ","))
message("  LSOA-month total observations: ", format(nrow(lsoa_crime_total), big.mark = ","))
message("  Unique LSOAs: ", format(uniqueN(lsoa_crime_total$lsoa_code), big.mark = ","))
message("  Unique months: ", uniqueN(lsoa_crime_total$month))

# Save
fwrite(lsoa_crime, file.path(DATA_DIR, "lsoa_crime_by_category.csv"))
fwrite(lsoa_crime_total, file.path(DATA_DIR, "lsoa_crime_total.csv"))

# ============================================================================
# 5. LSOA-TO-LA LOOKUP (via NSPL or ONS Open Geography)
# ============================================================================

message("Fetching LSOA-to-LA lookup...")

# Use paginated ArcGIS API for LSOA-to-LA lookup (primary approach)
message("  Fetching from ONS ArcGIS (paginated)...")
all_lookups <- list()
offset <- 0
repeat {
  url <- sprintf(
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LSOA11_LAD22_EW_LU/FeatureServer/0/query?where=1%%3D1&outFields=LSOA11CD,LAD22CD,LAD22NM&returnGeometry=false&f=json&resultOffset=%d&resultRecordCount=5000",
    offset
  )
  resp <- tryCatch(
    request(url) |> req_timeout(60) |> req_perform(),
    error = function(e) NULL
  )
  if (is.null(resp)) break
  raw <- resp_body_json(resp)
  if (length(raw$features) == 0) break
  dt <- rbindlist(lapply(raw$features, function(f) {
    data.table(lsoa_code = f$attributes$LSOA11CD,
               la_code = f$attributes$LAD22CD,
               la_name = f$attributes$LAD22NM)
  }))
  all_lookups[[length(all_lookups) + 1]] <- dt
  offset <- offset + 5000
  message("    Got ", nrow(dt), " rows (offset=", offset, ")")
  if (length(raw$features) < 5000) break
  Sys.sleep(0.3)
}

if (length(all_lookups) > 0) {
  lsoa_la_lookup <- rbindlist(all_lookups)
  message("  Got ", nrow(lsoa_la_lookup), " LSOA-to-LA mappings total")
} else {
  # Fallback: Download the CSV directly from ONS geoportal
  message("  ArcGIS paginated failed. Trying CSV download...")
  csv_url <- "https://www.arcgis.com/sharing/rest/content/items/42d1e451881a43faac1b2c70dc5261ee/data"
  lsoa_la_lookup <- tryCatch({
    fread(csv_url, select = c("LSOA11CD", "LAD22CD", "LAD22NM"))
  }, error = function(e) {
    message("  CSV fallback also failed: ", e$message)
    data.table(lsoa_code = character(0), la_code = character(0), la_name = character(0))
  })
  if (ncol(lsoa_la_lookup) == 3) setnames(lsoa_la_lookup, c("lsoa_code", "la_code", "la_name"))
}

fwrite(lsoa_la_lookup, file.path(DATA_DIR, "lsoa_la_lookup.csv"))

# ============================================================================
# 6. POPULATION DATA FROM NOMIS (for crime rates)
# ============================================================================

message("Fetching population data from NOMIS...")

# Use mid-year population estimates at LA level
# NM_2010_1 = Mid-Year Population Estimates
pop_url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_2010_1.data.csv?geography=TYPE464&date=2011-2024&sex=0&age=0&measures=20100&select=date_name,geography_code,geography_name,obs_value"

pop_data <- tryCatch({
  dt <- fread(pop_url, showProgress = FALSE)
  setnames(dt, c("year", "la_code", "la_name", "population"))
  dt[, year := as.integer(str_extract(year, "\\d{4}"))]
  message("  Got population data: ", nrow(dt), " LA-year observations")
  dt
}, error = function(e) {
  message("  NOMIS population fetch failed: ", e$message)
  message("  Trying alternative...")
  # Try simpler endpoint
  alt_url <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=TYPE464&date=latest&measures=20100&select=date_name,geography_code,geography_name,obs_value"
  fread(alt_url, showProgress = FALSE)
})

fwrite(pop_data, file.path(DATA_DIR, "la_population.csv"))

# ============================================================================
# 7. LAND REGISTRY — SKIPPED (not needed for main crime analysis)
# ============================================================================
# Land Registry PPD can be added later for property price analysis extension.

message("Data fetching complete.")
message("Files saved to: ", DATA_DIR)
message("Licensed LAs: ", nrow(licensing_dates))
