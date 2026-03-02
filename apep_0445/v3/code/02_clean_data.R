###############################################################################
# 02_clean_data.R
# Merge and clean all data sources, construct analysis dataset
# APEP-0445 v3
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

cat("=== Loading raw data ===\n")

acs <- readRDS(file.path(data_dir, "acs_tract_poverty.rds"))
lodes <- readRDS(file.path(data_dir, "lodes_tract_employment.rds"))
covs <- readRDS(file.path(data_dir, "acs_covariates.rds"))

cat("ACS tracts:", nrow(acs), "\n")
cat("LODES records:", nrow(lodes), "\n")
cat("Covariate tracts:", nrow(covs), "\n")

# Load broadband data if available
broadband_file <- file.path(data_dir, "acs_broadband.rds")
has_broadband <- file.exists(broadband_file)
if (has_broadband) {
  broadband <- readRDS(broadband_file)
  cat("Broadband tracts:", nrow(broadband), "\n")
} else {
  cat("WARNING: Broadband data not available\n")
}


cat("\n=== Step 1: Construct OZ designation status ===\n")

# Try to load official CDFI OZ designation data
oz_file_rds <- file.path(data_dir, "oz_designations_raw.rds")
oz_source <- "none"
oz_tracts <- character(0)

if (file.exists(oz_file_rds)) {
  oz_raw <- readRDS(oz_file_rds)

  # CDFI xlsx format: first 3 rows are header notes, row 4 is column header
  # Columns: State, County, Census Tract Number, Tract Type, ACS Data Source
  # Try both column-name detection and positional detection
  names_lower <- tolower(names(oz_raw))

  # Method 1: Look for column names containing tract/fips/geoid/census
  tract_col <- names(oz_raw)[grepl("tract|fips|geoid|census", names_lower)][1]

  # Method 2: Check if data has header row embedded (CDFI format)
  if (is.na(tract_col)) {
    # Look for the row that contains "Census" to find actual header
    header_row <- which(apply(oz_raw, 1, function(r) any(grepl("Census", r, ignore.case = TRUE))))[1]
    if (!is.na(header_row)) {
      # The tract FIPS is typically in column 3 (Census Tract Number)
      tract_col_idx <- which(grepl("census|tract", oz_raw[header_row, ], ignore.case = TRUE))[1]
      if (!is.na(tract_col_idx)) {
        # Extract data below the header row
        data_rows <- (header_row + 1):nrow(oz_raw)
        oz_tracts <- unique(as.character(oz_raw[[tract_col_idx]][data_rows]))
        oz_tracts <- oz_tracts[!is.na(oz_tracts) & nchar(oz_tracts) >= 10]
        # Pad to 11 digits
        oz_tracts <- sprintf("%011s", oz_tracts)
        oz_tracts <- gsub(" ", "0", oz_tracts)
        cat("Official CDFI OZ designated tracts loaded:", length(oz_tracts), "\n")
        oz_source <- "cdfi_official"
      }
    }
  } else {
    oz_tracts <- unique(as.character(oz_raw[[tract_col]]))
    oz_tracts <- oz_tracts[!is.na(oz_tracts) & nchar(oz_tracts) >= 10]
    oz_tracts <- sprintf("%011s", oz_tracts)
    oz_tracts <- gsub(" ", "0", oz_tracts)
    cat("Official CDFI OZ designated tracts loaded:", length(oz_tracts), "\n")
    oz_source <- "cdfi_official"
  }

  if (oz_source == "none") {
    cat("WARNING: Could not parse OZ tract data from CDFI file.\n")
    cat("  Columns found:", paste(names(oz_raw), collapse = ", "), "\n")
    cat("  First rows:\n")
    print(head(oz_raw, 6))
  }
} else {
  cat("OZ designation file not found.\n")
}

# Fallback: approximation with LOUD warning
if (length(oz_tracts) == 0) {
  cat("\n")
  cat("*************************************************************\n")
  cat("*** WARNING: OFFICIAL OZ DATA UNAVAILABLE                 ***\n")
  cat("*** Using approximation: top 25% of eligible tracts/state ***\n")
  cat("*** Results should be interpreted with CAUTION             ***\n")
  cat("*************************************************************\n")
  cat("\n")
  oz_source <- "approximation"
}

# Save OZ source metadata
saveRDS(list(source = oz_source, n_tracts = length(oz_tracts)),
        file.path(data_dir, "oz_source_metadata.rds"))


cat("\n=== Step 2: Clean ACS data and identify eligibility ===\n")

tract_data <- acs %>%
  select(geoid, state, county, tract, poverty_rate, median_fam_income, total_pop) %>%
  filter(!is.na(poverty_rate), total_pop > 0)

# State-level median family income (for MFI eligibility check)
state_mfi <- tract_data %>%
  group_by(state) %>%
  summarize(state_median_fam_income = median(median_fam_income, na.rm = TRUE))

tract_data <- tract_data %>%
  left_join(state_mfi, by = "state") %>%
  mutate(
    eligible_poverty = poverty_rate >= 20,
    mfi_ratio = median_fam_income / state_median_fam_income,
    eligible_mfi = mfi_ratio <= 0.80,
    eligible_any = eligible_poverty | eligible_mfi,
    in_poverty_sample = eligible_poverty | (!eligible_mfi),
    # County FIPS for clustering
    county_fips = paste0(state, county)
  )

# Apply OZ designation
if (oz_source == "cdfi_official") {
  tract_data <- tract_data %>%
    mutate(oz_designated = geoid %in% oz_tracts)
} else {
  # Approximation fallback
  tract_data <- tract_data %>%
    group_by(state) %>%
    mutate(
      eligible_rank = ifelse(eligible_any, rank(-poverty_rate), NA),
      n_eligible = sum(eligible_any, na.rm = TRUE),
      oz_designated = eligible_any & (eligible_rank <= ceiling(n_eligible * 0.25))
    ) %>%
    ungroup() %>%
    select(-eligible_rank, -n_eligible)
}

cat("Total tracts:", nrow(tract_data), "\n")
cat("Eligible (poverty):", sum(tract_data$eligible_poverty), "\n")
cat("Eligible (MFI only):", sum(tract_data$eligible_mfi & !tract_data$eligible_poverty), "\n")
cat("OZ designated:", sum(tract_data$oz_designated), "\n")
cat("In poverty RDD sample:", sum(tract_data$in_poverty_sample), "\n")
cat("OZ data source:", oz_source, "\n")


cat("\n=== Step 3: Merge with LODES employment data ===\n")

pre_lodes <- lodes[year %in% c(2015, 2016, 2017)] %>%
  .[, .(
    pre_total_emp = mean(total_emp, na.rm = TRUE),
    pre_construction_emp = mean(construction_emp, na.rm = TRUE),
    pre_info_emp = mean(info_emp, na.rm = TRUE)
  ), by = tract_geoid]

post_lodes <- lodes[year %in% c(2019, 2020, 2021, 2022, 2023)] %>%
  .[, .(
    post_total_emp = mean(total_emp, na.rm = TRUE),
    post_construction_emp = mean(construction_emp, na.rm = TRUE),
    post_info_emp = mean(info_emp, na.rm = TRUE)
  ), by = tract_geoid]

panel_lodes <- lodes[, .(
  total_emp = sum(total_emp, na.rm = TRUE),
  construction_emp = sum(construction_emp, na.rm = TRUE),
  info_emp = sum(info_emp, na.rm = TRUE)
), by = .(tract_geoid, year)]

cat("Pre-period tracts:", nrow(pre_lodes), "\n")
cat("Post-period tracts:", nrow(post_lodes), "\n")


cat("\n=== Step 4: Construct analysis dataset ===\n")

analysis <- tract_data %>%
  left_join(covs, by = "geoid") %>%
  left_join(as_tibble(pre_lodes), by = c("geoid" = "tract_geoid")) %>%
  left_join(as_tibble(post_lodes), by = c("geoid" = "tract_geoid"))

# Merge broadband data if available
if (has_broadband) {
  analysis <- analysis %>%
    left_join(broadband, by = "geoid")
}

# Merge data center location data (v3 addition)
dc_file <- file.path(data_dir, "dc_tract_presence.rds")
has_dc <- file.exists(dc_file)
if (has_dc) {
  dc_tract <- readRDS(dc_file)
  analysis <- analysis %>%
    left_join(dc_tract %>% select(tract_geoid, dc_count, dc_any),
              by = c("geoid" = "tract_geoid"))
  analysis$dc_any[is.na(analysis$dc_any)] <- 0L
  analysis$dc_count[is.na(analysis$dc_count)] <- 0L
  cat("Data center presence merged:", sum(analysis$dc_any), "tracts with DCs\n")
} else {
  cat("WARNING: Data center location data not available\n")
  analysis$dc_any <- 0L
  analysis$dc_count <- 0L
}

analysis <- analysis %>%
  mutate(
    delta_total_emp = post_total_emp - pre_total_emp,
    delta_construction_emp = post_construction_emp - pre_construction_emp,
    delta_info_emp = post_info_emp - pre_info_emp,
    log_post_total_emp = log(post_total_emp + 1),
    log_post_info_emp = log(post_info_emp + 1),
    log_pre_total_emp = log(pre_total_emp + 1),
    log_pre_info_emp = log(pre_info_emp + 1),
    pov_centered = poverty_rate - 20,
    urban = total_pop > 2000
  )

# Create broadband quartile if data available
if (has_broadband && "pct_broadband" %in% names(analysis)) {
  analysis <- analysis %>%
    mutate(
      broadband_quartile = ntile(pct_broadband, 4),
      broadband_quartile = ifelse(is.na(pct_broadband), NA, broadband_quartile)
    )
  cat("Broadband quartiles created\n")
}

# Filter to poverty RDD sample
rdd_sample <- analysis %>%
  filter(in_poverty_sample) %>%
  filter(!is.na(poverty_rate)) %>%
  filter(!is.na(post_total_emp) | !is.na(pre_total_emp))

cat("Final analysis dataset:", nrow(analysis), "tracts\n")
cat("RDD sample (poverty restriction):", nrow(rdd_sample), "\n")
cat("RDD sample within 10pp bandwidth:", sum(abs(rdd_sample$pov_centered) <= 10), "\n")
cat("RDD sample within 5pp bandwidth:", sum(abs(rdd_sample$pov_centered) <= 5), "\n")

# Save
saveRDS(analysis, file.path(data_dir, "analysis_full.rds"))
saveRDS(rdd_sample, file.path(data_dir, "rdd_sample.rds"))
saveRDS(panel_lodes, file.path(data_dir, "panel_lodes.rds"))

# Panel merged with tract info for event study
panel_merged <- as_tibble(panel_lodes) %>%
  inner_join(
    rdd_sample %>% select(geoid, poverty_rate, pov_centered, oz_designated,
                           eligible_poverty, total_pop, urban, county_fips,
                           pct_bachelors, pct_white, median_home_value,
                           dc_any, dc_count,
                           any_of(c("pct_broadband", "broadband_quartile"))),
    by = c("tract_geoid" = "geoid")
  )
saveRDS(panel_merged, file.path(data_dir, "panel_rdd.rds"))
cat("Panel RDD dataset:", nrow(panel_merged), "tract-years\n")

cat("\n=== Summary statistics ===\n")
cat(sprintf("  Poverty rate range: [%.1f%%, %.1f%%]\n",
            min(rdd_sample$poverty_rate), max(rdd_sample$poverty_rate)))
cat(sprintf("  Mean total employment (pre): %.1f\n",
            mean(rdd_sample$pre_total_emp, na.rm = TRUE)))
cat(sprintf("  Mean info employment (pre): %.1f\n",
            mean(rdd_sample$pre_info_emp, na.rm = TRUE)))
cat(sprintf("  OZ designation rate above cutoff: %.1f%%\n",
            mean(rdd_sample$oz_designated[rdd_sample$eligible_poverty]) * 100))
cat(sprintf("  OZ designation rate below cutoff: %.1f%%\n",
            mean(rdd_sample$oz_designated[!rdd_sample$eligible_poverty]) * 100))
cat(sprintf("  OZ data source: %s\n", oz_source))
cat(sprintf("  Tracts with data centers (RDD sample): %d (%.2f%%)\n",
            sum(rdd_sample$dc_any), mean(rdd_sample$dc_any) * 100))
cat(sprintf("  Total DCs in RDD sample tracts: %d\n",
            sum(rdd_sample$dc_count)))

cat("\n=== Data cleaning complete ===\n")
