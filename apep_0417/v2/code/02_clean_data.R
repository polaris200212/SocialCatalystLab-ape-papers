## ============================================================
## 02_clean_data.R — Merge population data, construct analysis panel
## Paper: Where Medicaid Goes Dark (apep_0417 v2)
## Changes from v1: Expand to all continental counties (~3108),
## add Medicaid population denominator, build dual panels
## ============================================================

source("00_packages.R")

cat("\n=== Load constructed data ===\n")
panel <- readRDS(file.path(DATA_DIR, "county_specialty_quarter.rds"))
panel_mdonly <- readRDS(file.path(DATA_DIR, "county_specialty_quarter_mdonly.rds"))
cat("  All-clinicians panel rows:", nrow(panel), "\n")
cat("  MD/DO-only panel rows:", nrow(panel_mdonly), "\n")

cat("\n=== Step 1: Fetch County Population from Census ACS ===\n")

# Census API for county-level population
census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) == 0) {
  env_file <- file.path(dirname(ROOT), "..", ".env")
  if (file.exists(env_file)) {
    env_lines <- readLines(env_file)
    for (line in env_lines) {
      if (grepl("^CENSUS_API_KEY=", line)) {
        census_key <- sub("CENSUS_API_KEY=", "", line)
        census_key <- gsub("['\"]", "", census_key)
      }
    }
  }
}

pop_file <- file.path(DATA_DIR, "county_population.rds")
# Force re-download: fix B27010_005E (under-19 only) → B27007 (all ages Medicaid)
if (!file.exists(pop_file) || !"public_coverage_all_ages" %in% names(readRDS(pop_file))) {
  cat("  Fetching county population from Census ACS 5-year...\n")

  base_url <- "https://api.census.gov/data/2022/acs/acs5"

  # Total population
  vars <- "B01003_001E,B27010_001E"
  url <- sprintf("%s?get=%s&for=county:*&key=%s", base_url, vars, census_key)
  resp <- jsonlite::fromJSON(url)
  pop_raw <- as.data.table(resp[-1, ])
  names(pop_raw) <- c("total_pop", "health_ins_universe", "state_fips", "county_code")

  pop_raw[, `:=`(
    county_fips = paste0(state_fips, county_code),
    total_pop = as.numeric(total_pop),
    health_ins_universe = as.numeric(health_ins_universe)
  )]

  # Medicaid/means-tested public coverage: C27007 (all ages, 3 age groups)
  # C27007_003E = Under 19 with Medicaid/means-tested public coverage
  # C27007_006E = 19-64 with Medicaid/means-tested public coverage
  # C27007_009E = 65+ with Medicaid/means-tested public coverage
  med_vars <- "C27007_003E,C27007_006E,C27007_009E"
  url2 <- sprintf("%s?get=%s&for=county:*&key=%s", base_url, med_vars, census_key)
  resp2 <- jsonlite::fromJSON(url2)
  pub_cov <- as.data.table(resp2[-1, ])
  names(pub_cov) <- c("med_under19", "med_19_64", "med_65plus", "state_fips", "county_code")
  pub_cov[, `:=`(
    county_fips = paste0(state_fips, county_code),
    med_under19 = as.numeric(med_under19),
    med_19_64 = as.numeric(med_19_64),
    med_65plus = as.numeric(med_65plus)
  )]
  pub_cov[, public_coverage := med_under19 + med_19_64 + med_65plus]

  county_pop <- merge(pop_raw[, .(county_fips, total_pop, health_ins_universe)],
                      pub_cov[, .(county_fips, public_coverage)],
                      by = "county_fips", all.x = TRUE)

  county_pop[, medicaid_share := public_coverage / total_pop]

  # Mark as corrected version
  county_pop[, public_coverage_all_ages := TRUE]

  saveRDS(county_pop, pop_file)
  cat("  Saved county_population.rds:", nrow(county_pop), "counties\n")
  cat("  Medicaid/public coverage: C27007 (all ages, 3 age groups summed)\n")
  cat("  Mean medicaid share:", round(mean(county_pop$medicaid_share, na.rm = TRUE), 3), "\n")
} else {
  county_pop <- readRDS(pop_file)
  cat("  Loaded county_population.rds:", nrow(county_pop), "counties\n")
}

cat("\n=== Step 2: Download USDA Rural-Urban Codes ===\n")

rucc_file <- file.path(DATA_DIR, "rucc.rds")
if (!file.exists(rucc_file)) {
  cat("  Downloading USDA Rural-Urban Continuum Codes (XLSX)...\n")
  tmp_xlsx <- tempfile(fileext = ".xlsx")
  url <- "https://www.ers.usda.gov/media/5767/2023-rural-urban-continuum-codes.xlsx"
  download.file(url, tmp_xlsx, quiet = TRUE, mode = "wb")
  rucc_raw <- as.data.table(readxl::read_excel(tmp_xlsx))
  fips_col <- grep("fips|FIPS", names(rucc_raw), value = TRUE)[1]
  rucc_col <- grep("rucc|RUCC", names(rucc_raw), value = TRUE)
  rucc_col <- rucc_col[grep("2023|code", rucc_col, ignore.case = TRUE)][1]
  if (is.na(rucc_col)) rucc_col <- grep("rucc|RUCC", names(rucc_raw), value = TRUE)[1]
  rucc <- rucc_raw[, .(county_fips = sprintf("%05d", as.integer(.SD[[fips_col]])),
                       rucc_code = as.integer(.SD[[rucc_col]]))]
  rucc <- rucc[!is.na(rucc_code)]
  rucc[, urban := rucc_code <= 3]
  saveRDS(rucc, rucc_file)
  cat("  Saved rucc.rds:", nrow(rucc), "counties\n")
} else {
  rucc <- readRDS(rucc_file)
  cat("  Loaded rucc.rds:", nrow(rucc), "counties\n")
}

cat("\n=== Step 3: Download TIGER/Line County Shapefiles ===\n")

shapes_file <- file.path(DATA_DIR, "county_shapes.rds")
if (!file.exists(shapes_file)) {
  cat("  Downloading county shapefiles...\n")
  url <- "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_500k.zip"
  tmp <- tempfile(fileext = ".zip")
  download.file(url, tmp, quiet = TRUE)
  tmp_dir <- tempdir()
  unzip(tmp, exdir = tmp_dir)
  shp <- st_read(file.path(tmp_dir, "cb_2022_us_county_500k.shp"), quiet = TRUE)
  shp <- shp |>
    mutate(county_fips = GEOID) |>
    select(county_fips, NAME, STATEFP, geometry)
  shp <- st_transform(shp, 5070)
  saveRDS(shp, shapes_file)
  cat("  Saved county_shapes.rds:", nrow(shp), "features\n")
} else {
  shp <- readRDS(shapes_file)
  cat("  Loaded county_shapes.rds:", nrow(shp), "features\n")
}

cat("\n=== Step 4: Construct Unwinding Treatment Variable ===\n")

unwinding <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  unwind_start = c(
    "2023-06","2023-06","2023-04","2023-04","2023-07","2023-06","2023-05",
    "2023-07","2023-07","2023-05","2023-06","2023-06","2023-04","2023-07",
    "2023-05","2023-05","2023-05","2023-06","2023-07","2023-06",
    "2023-06","2023-06","2023-07","2023-07","2023-06","2023-07","2023-06",
    "2023-05","2023-06","2023-04",
    "2023-06","2023-05","2023-07","2023-07","2023-06","2023-05","2023-05",
    "2023-10","2023-05","2023-06",
    "2023-06","2023-04","2023-06","2023-06","2023-05","2023-06","2023-05",
    "2023-06","2023-05","2023-06","2023-05"
  ),
  net_disenroll_pct = c(
    20.5, 8.2, 14.0, 28.5, 10.5, 30.2, 12.8, 15.3, 18.0, 22.0,
    19.5, 6.5, 25.0, 10.0, 18.5, 14.2, 16.0, 15.0, 18.0, 1.4,
    13.5, 8.0, 15.5, 10.0, 20.0, 22.5, 12.0, 14.0, 21.0, 26.0,
    12.0, 16.5, 9.0, 5.0, 18.0, 16.0, 15.5, 3.5, 17.0, 14.0,
    22.5, 19.0, 18.5, 28.0, 16.5, 8.5, 18.0, 10.0, 16.0, 14.5, 10.5
  )
)

unwinding[, `:=`(
  unwind_year = as.integer(substr(unwind_start, 1, 4)),
  unwind_month = as.integer(substr(unwind_start, 6, 7))
)]
unwinding[, unwind_quarter := paste0(unwind_year, "Q", ceiling(unwind_month / 3))]
unwinding[, cohort := unwind_quarter]

state_fips_lookup <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56")
)

unwinding <- merge(unwinding, state_fips_lookup, by = "state")

cat("  Unwinding cohorts:\n")
print(unwinding[, .N, by = cohort][order(cohort)])

saveRDS(unwinding, file.path(DATA_DIR, "unwinding_treatment.rds"))
cat("  Saved unwinding_treatment.rds\n")

cat("\n=== Step 5: Build Balanced Panel Using ALL Continental Counties ===\n")

# Use full county list from shapefiles (not just T-MSIS-observed counties)
continental_fips <- shp$county_fips[shp$STATEFP %in% sprintf("%02d", c(1:56))]
cat("  Total counties from shapefile (50 states + DC):", length(continental_fips), "\n")

# Function to build a balanced analysis panel
build_analysis_panel <- function(raw_panel, all_counties, label) {
  cat("\n  Building balanced panel:", label, "\n")

  # 6 specialties (no NP/PA category — NPs folded into clinical specialties)
  specs <- c("Primary Care", "Psychiatry", "Behavioral Health",
             "Dental", "OB-GYN", "Surgery")
  quarters <- sort(unique(raw_panel$quarter))

  # Create fully balanced skeleton from ALL counties
  all_combos <- CJ(
    county_fips = all_counties,
    specialty   = specs,
    quarter     = quarters
  )

  cat("    Skeleton size:", nrow(all_combos), "\n")

  # Filter raw panel to 6 specialties
  raw_panel <- raw_panel[specialty %in% specs]

  # Merge observed data
  panel_bal <- merge(all_combos, raw_panel,
                     by = c("county_fips", "specialty", "quarter"),
                     all.x = TRUE)

  # Fill zeros for missing county-specialty-quarters
  panel_bal[is.na(n_providers), n_providers := 0]
  panel_bal[is.na(n_providers_ft), n_providers_ft := 0]
  panel_bal[is.na(total_claims), total_claims := 0]
  panel_bal[is.na(total_benes), total_benes := 0]
  panel_bal[is.na(total_paid), total_paid := 0.0]
  panel_bal[is.na(n_md), n_md := 0]
  panel_bal[is.na(n_do), n_do := 0]
  panel_bal[is.na(n_np), n_np := 0]
  panel_bal[is.na(n_pa), n_pa := 0]

  # Fill time-invariant county variables
  panel_bal[, state_fips := substr(county_fips, 1, 2)]
  panel_bal[, year := as.integer(substr(quarter, 1, 4))]

  # Merge population
  panel_bal <- merge(panel_bal,
                     county_pop[, .(county_fips, total_pop, public_coverage, medicaid_share)],
                     by = "county_fips", all.x = TRUE)

  # Merge rural-urban
  panel_bal <- merge(panel_bal, rucc[, .(county_fips, rucc_code, urban)],
                     by = "county_fips", all.x = TRUE)

  # Merge unwinding treatment
  unwind_vars <- unique(unwinding[, .(state_fips, cohort, unwind_start,
                                       net_disenroll_pct, unwind_quarter)])
  panel_bal <- merge(panel_bal, unwind_vars, by = "state_fips", all.x = TRUE)

  # Compute derived variables
  panel_bal[, qtr_num := as.integer(factor(quarter, levels = sort(unique(quarter))))]
  panel_bal[, post_unwind := quarter >= unwind_quarter]
  panel_bal[is.na(post_unwind), post_unwind := FALSE]

  # Providers per 10K total population
  panel_bal[, providers_per_10k := ifelse(!is.na(total_pop) & total_pop > 0,
                                           n_providers / total_pop * 10000, NA_real_)]

  # Providers per 10K Medicaid population (public coverage)
  panel_bal[, providers_per_10k_medicaid := ifelse(
    !is.na(public_coverage) & public_coverage > 0,
    n_providers / public_coverage * 10000, NA_real_)]

  # Desert indicators
  panel_bal[, is_desert := providers_per_10k < 1 | n_providers == 0]
  panel_bal[, is_desert_medicaid := providers_per_10k_medicaid < 1 | n_providers == 0]

  # Log providers and claims
  panel_bal[, ln_providers := log(n_providers + 1)]
  panel_bal[, ln_claims := log(total_claims + 1)]

  # County-specialty FE identifier
  panel_bal[, cs_id := paste(county_fips, specialty, sep = "_")]

  cat("    Balanced panel rows:", nrow(panel_bal), "\n")
  cat("    Unique counties:", uniqueN(panel_bal$county_fips), "\n")
  cat("    Zeros (no providers):", sum(panel_bal$n_providers == 0),
      sprintf("(%.1f%%)", 100 * mean(panel_bal$n_providers == 0)), "\n")
  cat("    Missing population:", sum(is.na(panel_bal$total_pop)), "\n")

  panel_bal
}

# Build both panels using ALL continental counties
panel_balanced <- build_analysis_panel(panel, continental_fips, "All clinicians")
panel_balanced_mdonly <- build_analysis_panel(panel_mdonly, continental_fips, "MD/DO only")

cat("\n=== Step 6: Save ===\n")

saveRDS(panel_balanced, file.path(DATA_DIR, "analysis_panel.rds"))
saveRDS(panel_balanced_mdonly, file.path(DATA_DIR, "analysis_panel_mdonly.rds"))
cat("  Saved analysis_panel.rds (all clinicians)\n")
cat("  Saved analysis_panel_mdonly.rds\n")

cat("\nData construction complete.\n")
