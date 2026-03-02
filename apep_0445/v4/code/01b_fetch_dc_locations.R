###############################################################################
# 01b_fetch_dc_locations.R
# Fetch and geocode data center locations from EIA Form 860 and public DBs
# APEP-0445 v4
# v4 addition: Extract generator-level operating year for DC vintage analysis
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

cat("=== Fetching Data Center Location Data ===\n\n")

###############################################################################
# Source 1: EIA Form 860 — Generator-level data with plant coordinates
# Plants with NAICS 518210 (Data Processing, Hosting, and Related Services)
# or co-located with data center operations
###############################################################################

cat("=== Step 1: Download EIA Form 860 plant data ===\n")

# EIA Form 860 provides plant-level data including lat/lon and NAICS codes
# The 2023 dataset (latest available) captures the most complete picture
eia_urls <- c(
  "https://www.eia.gov/electricity/data/eia860/xls/eia8602024.zip",
  "https://www.eia.gov/electricity/data/eia860/archive/xls/eia8602023.zip",
  "https://www.eia.gov/electricity/data/eia860/archive/xls/eia8602022.zip"
)

eia_zip <- file.path(data_dir, "eia860.zip")
eia_dir <- file.path(data_dir, "eia860")
dir.create(eia_dir, showWarnings = FALSE)

eia_downloaded <- FALSE
for (url in eia_urls) {
  if (eia_downloaded) break
  tryCatch({
    download.file(url, eia_zip, mode = "wb", quiet = TRUE, timeout = 120)
    # Try R unzip first, fall back to system unzip
    res <- tryCatch(unzip(eia_zip, exdir = eia_dir, overwrite = TRUE),
                    warning = function(w) NULL, error = function(e) NULL)
    if (is.null(res) || length(res) == 0) {
      cat("  R unzip failed, trying system unzip...\n")
      system2("unzip", args = c("-o", eia_zip, "-d", eia_dir), stdout = FALSE, stderr = FALSE)
    }
    # Check if files were extracted
    if (length(list.files(eia_dir, recursive = TRUE)) > 0) {
      eia_downloaded <- TRUE
      cat("EIA-860 downloaded from:", url, "\n")
    } else {
      cat("  Extraction produced no files\n")
    }
  }, error = function(e) {
    cat("  Download failed:", substr(e$message, 1, 60), "\n")
  })
}

if (!eia_downloaded) {
  cat("WARNING: Could not download EIA-860 data. Trying API fallback.\n")
}

# Parse plant-level data from the 2___Plant sheet
plant_file <- list.files(eia_dir, pattern = "2___Plant", full.names = TRUE, recursive = TRUE)
if (length(plant_file) == 0) {
  plant_file <- list.files(eia_dir, pattern = "Plant.*\\.xlsx$", full.names = TRUE, recursive = TRUE)
}

dc_eia <- NULL
eia_plants <- NULL
if (length(plant_file) > 0) {
  cat("Reading plant file:", plant_file[1], "\n")
  tryCatch({
    # EIA 860 plant file has a header row
    sheets <- readxl::excel_sheets(plant_file[1])
    cat("  Available sheets:", paste(sheets, collapse = ", "), "\n")

    # Try to find the right sheet
    plant_sheet <- sheets[grepl("Plant", sheets, ignore.case = TRUE)][1]
    if (is.na(plant_sheet)) plant_sheet <- sheets[1]

    eia_raw <- readxl::read_excel(plant_file[1], sheet = plant_sheet, skip = 1)
    cat("  Raw plant records:", nrow(eia_raw), "\n")
    cat("  Columns:", paste(head(names(eia_raw), 20), collapse = ", "), "\n")

    # Identify key columns (names vary by year)
    names_lower <- tolower(names(eia_raw))

    # Find NAICS column (EIA uses "Primary Purpose (NAICS Code)")
    naics_col <- names(eia_raw)[grepl("naics|primary.purpose", names_lower)][1]
    lat_col <- names(eia_raw)[grepl("latit", names_lower)][1]
    lon_col <- names(eia_raw)[grepl("longit", names_lower)][1]
    state_col <- names(eia_raw)[grepl("^state$", names_lower)][1]
    plant_id_col <- names(eia_raw)[grepl("plant.*code|plant.*id", names_lower)][1]
    plant_name_col <- names(eia_raw)[grepl("plant.*name", names_lower)][1]
    capacity_col <- names(eia_raw)[grepl("nameplate|capacity", names_lower)][1]

    cat("  NAICS column:", naics_col, "\n")
    cat("  Lat column:", lat_col, "\n")
    cat("  Lon column:", lon_col, "\n")

    if (!is.na(naics_col) && !is.na(lat_col) && !is.na(lon_col)) {
      eia_plants <- eia_raw %>%
        mutate(
          naics = as.character(.data[[naics_col]]),
          latitude = as.numeric(.data[[lat_col]]),
          longitude = as.numeric(.data[[lon_col]]),
          plant_name = if (!is.na(plant_name_col)) as.character(.data[[plant_name_col]]) else NA,
          plant_id = if (!is.na(plant_id_col)) as.character(.data[[plant_id_col]]) else NA,
          state_code = if (!is.na(state_col)) as.character(.data[[state_col]]) else NA
        ) %>%
        filter(!is.na(latitude), !is.na(longitude),
               abs(latitude) > 0, abs(longitude) > 0)

      cat("  Plants with valid coordinates:", nrow(eia_plants), "\n")

      # Filter to data center-related NAICS codes
      # 518210: Data Processing, Hosting, and Related Services
      # 518: Data Processing, Hosting, Related Services (broader)
      # Also check for "data center" in plant name
      dc_eia <- eia_plants %>%
        filter(
          grepl("^518", naics, ignore.case = TRUE) |
          grepl("data.?cent|server.?farm|colocation|colo.?facility|cloud|hosting",
                plant_name, ignore.case = TRUE)
        )

      cat("\n  Data center plants (NAICS 518* or name match):", nrow(dc_eia), "\n")

      if (nrow(dc_eia) > 0) {
        cat("  NAICS distribution:\n")
        print(table(dc_eia$naics))
        cat("  Sample plant names:\n")
        print(head(dc_eia$plant_name, 10))
      }
    } else {
      cat("  WARNING: Could not identify required columns\n")
    }
  }, error = function(e) {
    cat("  ERROR reading plant file:", e$message, "\n")
  })
}


###############################################################################
# v4 addition: Extract generator-level operating year data
# This enables vintage analysis separating pre-2018 legacy from post-2018 new
###############################################################################

cat("\n=== Step 1b: Extract generator-level operating year ===\n")

gen_file <- list.files(eia_dir, pattern = "3_1_Generator", full.names = TRUE, recursive = TRUE)
if (length(gen_file) == 0) {
  gen_file <- list.files(eia_dir, pattern = "Generator.*\\.xlsx$", full.names = TRUE, recursive = TRUE)
}

gen_operating_year <- NULL
if (length(gen_file) > 0) {
  cat("Reading generator file:", gen_file[1], "\n")
  tryCatch({
    gen_sheets <- readxl::excel_sheets(gen_file[1])
    cat("  Available sheets:", paste(gen_sheets, collapse = ", "), "\n")

    # Find the operable generators sheet (typically "Operable" or first sheet)
    gen_sheet <- gen_sheets[grepl("Operable|Exist", gen_sheets, ignore.case = TRUE)][1]
    if (is.na(gen_sheet)) gen_sheet <- gen_sheets[1]

    gen_raw <- readxl::read_excel(gen_file[1], sheet = gen_sheet, skip = 1)
    cat("  Raw generator records:", nrow(gen_raw), "\n")

    gen_names_lower <- tolower(names(gen_raw))

    # Find plant ID and operating year columns
    gen_plant_id_col <- names(gen_raw)[grepl("plant.*code|plant.*id", gen_names_lower)][1]
    gen_opyear_col <- names(gen_raw)[grepl("operating.year|initial.*year.*commercial|year.*commercial", gen_names_lower)][1]

    # Fallback: try broader patterns
    if (is.na(gen_opyear_col)) {
      gen_opyear_col <- names(gen_raw)[grepl("^operating|commercial.*operation", gen_names_lower)][1]
    }

    cat("  Plant ID column:", gen_plant_id_col, "\n")
    cat("  Operating year column:", gen_opyear_col, "\n")

    if (!is.na(gen_plant_id_col) && !is.na(gen_opyear_col)) {
      gen_operating_year <- gen_raw %>%
        mutate(
          plant_id = as.character(.data[[gen_plant_id_col]]),
          operating_year = as.numeric(.data[[gen_opyear_col]])
        ) %>%
        filter(!is.na(plant_id), !is.na(operating_year)) %>%
        group_by(plant_id) %>%
        summarize(
          plant_operating_year = min(operating_year, na.rm = TRUE),
          n_generators = n(),
          .groups = "drop"
        )
      cat("  Plants with operating year data:", nrow(gen_operating_year), "\n")
      cat("  Year range:", min(gen_operating_year$plant_operating_year),
          "-", max(gen_operating_year$plant_operating_year), "\n")
    } else {
      cat("  WARNING: Could not identify operating year column in generator data\n")
    }
  }, error = function(e) {
    cat("  ERROR reading generator file:", e$message, "\n")
  })
} else {
  cat("  WARNING: No generator-level file found in EIA-860 data\n")
}

# Merge operating year into DC EIA plants
if (!is.null(dc_eia) && nrow(dc_eia) > 0 && !is.null(gen_operating_year)) {
  dc_eia <- dc_eia %>%
    left_join(gen_operating_year, by = "plant_id")
  n_with_year <- sum(!is.na(dc_eia$plant_operating_year))
  cat("  DC plants with operating year:", n_with_year, "/", nrow(dc_eia), "\n")
  if (n_with_year > 0) {
    cat("  DC plant year distribution:\n")
    cat("    Pre-2018:", sum(dc_eia$plant_operating_year < 2018, na.rm = TRUE), "\n")
    cat("    Post-2018:", sum(dc_eia$plant_operating_year >= 2018, na.rm = TRUE), "\n")
  }
}


###############################################################################
# Source 2: Compile data center locations from public lists
# Using multiple triangulation sources
###############################################################################

cat("\n=== Step 2: Compile data center locations from public databases ===\n")

# Approach: Use the Wikipedia list of data centers + major operator locations
# These are well-documented public sources

# Major hyperscale and colocation operators with known US facilities
# Source: Company annual reports, SEC filings, industry databases
dc_known <- data.frame(
  operator = character(), facility = character(),
  city = character(), state = character(),
  latitude = numeric(), longitude = numeric(),
  type = character(), year_opened = integer(),
  stringsAsFactors = FALSE
)

# We'll use the EIA data as primary and supplement with a curated list
# of major hyperscale facilities from public sources

# Download cloudscene or similar public DC directory
# Fallback: Use EIA-identified facilities as the primary source

# Additional source: EPA GHGRP (Greenhouse Gas Reporting Program)
# Large data centers report under NAICS 518210 if they have on-site generation
cat("Attempting EPA GHGRP data for large facility identification...\n")
ghgrp_url <- "https://data.epa.gov/efservice/PUB_DIM_FACILITY/NAICS_CODE/518210/CSV"
ghgrp_file <- file.path(data_dir, "ghgrp_datacenters.csv")

ghgrp_dc <- NULL
tryCatch({
  download.file(ghgrp_url, ghgrp_file, quiet = TRUE, timeout = 60)
  ghgrp_dc <- read.csv(ghgrp_file, stringsAsFactors = FALSE)
  cat("  EPA GHGRP data center facilities:", nrow(ghgrp_dc), "\n")
  if (nrow(ghgrp_dc) > 0) {
    cat("  Columns:", paste(head(names(ghgrp_dc), 15), collapse = ", "), "\n")
  }
}, error = function(e) {
  cat("  EPA GHGRP download failed:", substr(e$message, 1, 60), "\n")
})

# Try broader GHGRP query
if (is.null(ghgrp_dc) || nrow(ghgrp_dc) == 0) {
  ghgrp_url2 <- "https://data.epa.gov/efservice/PUB_DIM_FACILITY/NAICS_CODE/BEGINNING/518/CSV"
  tryCatch({
    download.file(ghgrp_url2, ghgrp_file, quiet = TRUE, timeout = 60)
    ghgrp_dc <- read.csv(ghgrp_file, stringsAsFactors = FALSE)
    cat("  EPA GHGRP (broader NAICS 518*):", nrow(ghgrp_dc), "facilities\n")
  }, error = function(e) {
    cat("  EPA GHGRP broader query also failed\n")
  })
}


###############################################################################
# Source 3: HIFLD Open Data — Critical Infrastructure (if available)
###############################################################################

cat("\n=== Step 3: HIFLD Open Data ===\n")

# Homeland Infrastructure Foundation-Level Data (HIFLD)
# Has point locations for many facility types
hifld_url <- "https://opendata.arcgis.com/api/v3/datasets/data-centers/downloads/data?format=csv&spatialRefId=4326"
hifld_file <- file.path(data_dir, "hifld_datacenters.csv")

hifld_dc <- NULL
tryCatch({
  download.file(hifld_url, hifld_file, quiet = TRUE, timeout = 60)
  hifld_dc <- read.csv(hifld_file, stringsAsFactors = FALSE)
  cat("  HIFLD data centers:", nrow(hifld_dc), "\n")
}, error = function(e) {
  cat("  HIFLD download failed (expected, may need different endpoint)\n")
})


###############################################################################
# Step 4: Combine all sources and geocode to census tracts
###############################################################################

cat("\n=== Step 4: Combine sources and geocode to census tracts ===\n")

# Combine all data center locations with coordinates
all_dc <- data.frame(
  latitude = numeric(), longitude = numeric(),
  source = character(), name = character(),
  stringsAsFactors = FALSE
)

# Add EIA-identified facilities (with operating year for vintage analysis)
if (!is.null(dc_eia) && nrow(dc_eia) > 0) {
  eia_locs <- dc_eia %>%
    select(latitude, longitude, plant_name,
           any_of("plant_operating_year")) %>%
    mutate(source = "EIA-860", name = plant_name) %>%
    select(latitude, longitude, source, name,
           any_of("plant_operating_year"))
  all_dc <- bind_rows(all_dc, eia_locs)
  cat("  Added", nrow(eia_locs), "EIA-860 facilities\n")
}

# Add GHGRP facilities
if (!is.null(ghgrp_dc) && nrow(ghgrp_dc) > 0) {
  lat_col_g <- names(ghgrp_dc)[grepl("lat", tolower(names(ghgrp_dc)))][1]
  lon_col_g <- names(ghgrp_dc)[grepl("lon", tolower(names(ghgrp_dc)))][1]
  name_col_g <- names(ghgrp_dc)[grepl("name|facility", tolower(names(ghgrp_dc)))][1]

  if (!is.na(lat_col_g) && !is.na(lon_col_g)) {
    ghgrp_locs <- ghgrp_dc %>%
      mutate(
        latitude = as.numeric(.data[[lat_col_g]]),
        longitude = as.numeric(.data[[lon_col_g]]),
        name = if (!is.na(name_col_g)) as.character(.data[[name_col_g]]) else "GHGRP Facility",
        source = "EPA-GHGRP"
      ) %>%
      filter(!is.na(latitude), !is.na(longitude)) %>%
      select(latitude, longitude, source, name)
    all_dc <- bind_rows(all_dc, ghgrp_locs)
    cat("  Added", nrow(ghgrp_locs), "EPA GHGRP facilities\n")
  }
}

# Add HIFLD facilities
if (!is.null(hifld_dc) && nrow(hifld_dc) > 0) {
  lat_col_h <- names(hifld_dc)[grepl("lat|y", tolower(names(hifld_dc)))][1]
  lon_col_h <- names(hifld_dc)[grepl("lon|x", tolower(names(hifld_dc)))][1]
  name_col_h <- names(hifld_dc)[grepl("name|facility", tolower(names(hifld_dc)))][1]

  if (!is.na(lat_col_h) && !is.na(lon_col_h)) {
    hifld_locs <- hifld_dc %>%
      mutate(
        latitude = as.numeric(.data[[lat_col_h]]),
        longitude = as.numeric(.data[[lon_col_h]]),
        name = if (!is.na(name_col_h)) as.character(.data[[name_col_h]]) else "HIFLD Facility",
        source = "HIFLD"
      ) %>%
      filter(!is.na(latitude), !is.na(longitude)) %>%
      select(latitude, longitude, source, name)
    all_dc <- bind_rows(all_dc, hifld_locs)
    cat("  Added", nrow(hifld_locs), "HIFLD facilities\n")
  }
}

cat("\n  Total combined data center locations:", nrow(all_dc), "\n")

# Deduplicate: merge facilities within ~500m of each other
if (nrow(all_dc) > 1) {
  # Ensure plant_operating_year column exists even if no EIA data had it
  if (!"plant_operating_year" %in% names(all_dc)) {
    all_dc$plant_operating_year <- NA_real_
  }
  all_dc <- all_dc %>%
    mutate(
      lat_round = round(latitude, 3),  # ~111m precision
      lon_round = round(longitude, 3)
    ) %>%
    group_by(lat_round, lon_round) %>%
    summarize(
      latitude = first(latitude),
      longitude = first(longitude),
      source = paste(unique(source), collapse = "+"),
      name = first(name),
      plant_operating_year = min(plant_operating_year, na.rm = TRUE),
      n_sources = n(),
      .groups = "drop"
    ) %>%
    mutate(plant_operating_year = ifelse(is.infinite(plant_operating_year),
                                          NA_real_, plant_operating_year)) %>%
    select(-lat_round, -lon_round)

  cat("  After deduplication:", nrow(all_dc), "unique locations\n")
}

# Geocode to census tracts using FCC Block API (free, no key needed)
# This maps lat/lon to census block FIPS, from which we extract tract
cat("\n  Geocoding to census tracts...\n")

geocode_to_tract <- function(lat, lon) {
  url <- sprintf(
    "https://geo.fcc.gov/api/census/block/find?latitude=%f&longitude=%f&censusYear=2020&format=json",
    lat, lon
  )
  tryCatch({
    resp <- httr::GET(url, httr::timeout(10))
    if (httr::status_code(resp) == 200) {
      result <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
      if (!is.null(result$Block$FIPS)) {
        return(substr(result$Block$FIPS, 1, 11))  # Tract = first 11 digits
      }
    }
    return(NA_character_)
  }, error = function(e) {
    return(NA_character_)
  })
}

# Geocode in batches with rate limiting
if (nrow(all_dc) > 0) {
  all_dc$tract_geoid <- NA_character_

  for (i in 1:nrow(all_dc)) {
    all_dc$tract_geoid[i] <- geocode_to_tract(
      all_dc$latitude[i], all_dc$longitude[i]
    )
    if (i %% 50 == 0) {
      cat(sprintf("    Geocoded %d/%d facilities\n", i, nrow(all_dc)))
    }
    Sys.sleep(0.15)  # Rate limiting for FCC API
  }

  n_geocoded <- sum(!is.na(all_dc$tract_geoid))
  cat(sprintf("  Successfully geocoded: %d/%d (%.0f%%)\n",
              n_geocoded, nrow(all_dc), n_geocoded / nrow(all_dc) * 100))
}


###############################################################################
# Step 5: Create tract-level data center presence variables
###############################################################################

cat("\n=== Step 5: Create tract-level DC presence variables ===\n")

if (nrow(all_dc) > 0 && sum(!is.na(all_dc$tract_geoid)) > 0) {
  # Ensure vintage column exists
  if (!"plant_operating_year" %in% names(all_dc)) {
    all_dc$plant_operating_year <- NA_real_
  }

  # Tract-level aggregation with vintage variables (v4)
  dc_tract <- all_dc %>%
    filter(!is.na(tract_geoid)) %>%
    group_by(tract_geoid) %>%
    summarize(
      dc_count = n(),
      dc_any = 1L,
      dc_multi_source = sum(grepl("\\+", source)),
      dc_names = paste(head(name, 3), collapse = "; "),
      dc_sources = paste(unique(unlist(strsplit(source, "\\+"))), collapse = "+"),
      # Vintage variables (v4 addition)
      dc_count_pre2018 = sum(plant_operating_year < 2018, na.rm = TRUE),
      dc_count_post2018 = sum(plant_operating_year >= 2018, na.rm = TRUE),
      dc_count_unknown_year = sum(is.na(plant_operating_year)),
      dc_any_pre2018 = as.integer(any(plant_operating_year < 2018, na.rm = TRUE)),
      dc_any_post2018 = as.integer(any(plant_operating_year >= 2018, na.rm = TRUE)),
      dc_min_year = suppressWarnings(min(plant_operating_year, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    mutate(dc_min_year = ifelse(is.infinite(dc_min_year), NA_real_, dc_min_year))

  cat("  Tracts with at least one data center:", nrow(dc_tract), "\n")
  cat("  Distribution of DCs per tract:\n")
  print(table(dc_tract$dc_count))

  # Also count ALL plants from EIA-860 (not just DC) per tract for reference
  if (!is.null(eia_plants) && nrow(eia_plants) > 0) {
    all_plants_tract <- eia_plants %>%
      mutate(tract_g = NA_character_)

    # For efficiency, only geocode plants in tracts we haven't already geocoded
    # Use a spatial join approach instead — convert to sf and overlay
    # But since we need census 2010 tracts (matching our analysis), use FCC API
    # Skip full plant geocoding (too many) — DC-specific geocoding is sufficient
  }

  saveRDS(dc_tract, file.path(data_dir, "dc_tract_presence.rds"))
  saveRDS(all_dc, file.path(data_dir, "dc_locations_raw.rds"))
  cat("  Data center tract-level data saved\n")
} else {
  cat("  WARNING: No data center locations could be geocoded.\n")
  cat("  Creating empty placeholder for downstream code.\n")
  dc_tract <- data.frame(
    tract_geoid = character(),
    dc_count = integer(),
    dc_any = integer(),
    dc_multi_source = integer(),
    dc_names = character(),
    dc_sources = character(),
    stringsAsFactors = FALSE
  )
  saveRDS(dc_tract, file.path(data_dir, "dc_tract_presence.rds"))
  saveRDS(all_dc, file.path(data_dir, "dc_locations_raw.rds"))
}

# Summary statistics
cat("\n=== Data Center Location Summary ===\n")
cat(sprintf("  Total unique DC locations: %d\n", nrow(all_dc)))
cat(sprintf("  Successfully geocoded to tracts: %d\n", sum(!is.na(all_dc$tract_geoid))))
cat(sprintf("  Unique tracts with DCs: %d\n", nrow(dc_tract)))
if (nrow(dc_tract) > 0) {
  cat(sprintf("  Mean DCs per tract (conditional): %.1f\n", mean(dc_tract$dc_count)))
  cat(sprintf("  Max DCs in a single tract: %d\n", max(dc_tract$dc_count)))
  cat("\n  --- Vintage Summary (v4) ---\n")
  cat(sprintf("  Tracts with pre-2018 DCs: %d\n", sum(dc_tract$dc_any_pre2018)))
  cat(sprintf("  Tracts with post-2018 DCs: %d\n", sum(dc_tract$dc_any_post2018)))
  cat(sprintf("  Tracts with unknown-year DCs only: %d\n",
              sum(dc_tract$dc_count_unknown_year > 0 &
                  dc_tract$dc_count_pre2018 == 0 &
                  dc_tract$dc_count_post2018 == 0)))
  cat(sprintf("  DCs with operating year data: %d / %d\n",
              sum(!is.na(all_dc$plant_operating_year)),
              nrow(all_dc)))
}

# Clean up
if (file.exists(eia_zip)) file.remove(eia_zip)
cat("\n=== Data center location fetch complete ===\n")
