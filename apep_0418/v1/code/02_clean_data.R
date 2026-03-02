##############################################################################
# 02_clean_data.R — Construct analysis dataset
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 2: Cleaning and constructing analysis dataset ===\n\n")

###############################################################################
# 1. Load raw data
###############################################################################
cbp_county <- readRDS(file.path(DATA_DIR, "cbp_county_2021.rds"))
msa_delineation <- readRDS(file.path(DATA_DIR, "msa_delineation.rds"))
nat_unemp_2022 <- readRDS(file.path(DATA_DIR, "national_unemp_2022.rds"))

cat("National unemployment rate 2022:", round(nat_unemp_2022, 2), "%\n\n")

###############################################################################
# 2. Aggregate county CBP data to MSA/non-MSA level
###############################################################################
cat("--- Aggregating county data to MSA level ---\n")

# Map counties to CBSAs
county_cbsa <- msa_delineation %>%
  select(fips, cbsa_code, cbsa_title, metro_micro) %>%
  distinct()

# Merge CBP data with MSA assignments
cbp_msa <- cbp_county %>%
  left_join(county_cbsa, by = "fips")

# Non-MSA counties: assign a synthetic "non-MSA" identifier using state + "NM"
cbp_msa <- cbp_msa %>%
  mutate(
    area_code = ifelse(is.na(cbsa_code),
                       paste0(state_fips, "NM"),
                       cbsa_code),
    area_type = ifelse(is.na(cbsa_code), "non-MSA", "MSA")
  )

# Aggregate to area level
area_data <- cbp_msa %>%
  group_by(area_code, area_type) %>%
  summarise(
    total_emp = sum(total_emp, na.rm = TRUE),
    total_estab = sum(total_estab, na.rm = TRUE),
    ff_emp = sum(ff_emp, na.rm = TRUE),
    n_counties = n(),
    state_fips = first(state_fips),
    cbsa_title = first(cbsa_title),
    .groups = "drop"
  ) %>%
  mutate(
    ff_share = ff_emp / total_emp * 100  # Percentage
  )

cat("  Total areas:", nrow(area_data), "\n")
cat("  MSAs:", sum(area_data$area_type == "MSA"), "\n")
cat("  Non-MSAs:", sum(area_data$area_type == "non-MSA"), "\n")

###############################################################################
# 3. Add unemployment data
###############################################################################
cat("\n--- Adding unemployment data ---\n")

# Try loading LAUS data
if (file.exists(file.path(DATA_DIR, "laus_county_2022.rds"))) {
  laus_df <- readRDS(file.path(DATA_DIR, "laus_county_2022.rds"))

  # Aggregate to MSA level using employment weights
  laus_msa <- laus_df %>%
    left_join(county_cbsa, by = "fips") %>%
    left_join(cbp_county %>% select(fips, total_emp), by = "fips") %>%
    mutate(
      area_code = ifelse(is.na(cbsa_code),
                         paste0(str_sub(fips, 1, 2), "NM"),
                         cbsa_code)
    ) %>%
    group_by(area_code) %>%
    summarise(
      unemp_rate = weighted.mean(unemp_rate, total_emp, na.rm = TRUE),
      .groups = "drop"
    )

  area_data <- area_data %>%
    left_join(laus_msa, by = "area_code")

  cat("  Areas with unemployment data:", sum(!is.na(area_data$unemp_rate)), "\n")
} else {
  cat("  LAUS data not available. Using BLS flat file approach...\n")
  # Alternative: download annual averages
  bls_url <- "https://www.bls.gov/lau/laucnty22.txt"
  bls_file <- file.path(DATA_DIR, "bls_laus_2022.txt")

  if (!file.exists(bls_file)) {
    download.file(bls_url, bls_file)
  }

  # Read BLS LAUS file (pipe-delimited with headers)
  bls_lines <- readLines(bls_file)
  # Find header line
  header_idx <- grep("LAUS|Code|FIPS|State", bls_lines[1:10])[1]
  if (is.na(header_idx)) header_idx <- 6

  # Try reading as pipe-delimited
  bls_raw <- tryCatch({
    read.delim(bls_file, sep = "|", header = FALSE, skip = header_idx,
               strip.white = TRUE, stringsAsFactors = FALSE)
  }, error = function(e) {
    # Read as comma-separated
    read.csv(bls_file, header = FALSE, skip = header_idx, strip.white = TRUE)
  })

  if (ncol(bls_raw) >= 9) {
    laus_df <- bls_raw %>%
      mutate(
        state_fips = str_pad(trimws(as.character(V2)), 2, pad = "0"),
        county_fips = str_pad(trimws(as.character(V3)), 3, pad = "0"),
        fips = paste0(state_fips, county_fips),
        unemp_rate = as.numeric(gsub("[^0-9.]", "", V9))
      ) %>%
      filter(!is.na(unemp_rate), nchar(fips) == 5)

    saveRDS(laus_df, file.path(DATA_DIR, "laus_county_2022.rds"))

    laus_msa <- laus_df %>%
      left_join(county_cbsa, by = "fips") %>%
      left_join(cbp_county %>% select(fips, total_emp), by = "fips") %>%
      mutate(
        area_code = ifelse(is.na(cbsa_code),
                           paste0(state_fips, "NM"),
                           cbsa_code)
      ) %>%
      group_by(area_code) %>%
      summarise(
        unemp_rate = weighted.mean(unemp_rate, total_emp, na.rm = TRUE),
        .groups = "drop"
      )

    area_data <- area_data %>%
      left_join(laus_msa, by = "area_code")

    cat("  Areas with unemployment data:", sum(!is.na(area_data$unemp_rate)), "\n")
  }
}

###############################################################################
# 4. Construct treatment variable
###############################################################################
cat("\n--- Constructing treatment variable ---\n")

# Energy community via statistical area pathway requires:
# (a) FF employment >= 0.17% AND (b) unemployment >= national average

area_data <- area_data %>%
  mutate(
    above_ff_threshold = ff_share >= 0.17,
    above_unemp_threshold = unemp_rate >= nat_unemp_2022,
    energy_community = above_ff_threshold & above_unemp_threshold,
    # Running variable: centered at threshold
    running_var = ff_share - 0.17
  )

cat("  Areas above FF threshold (0.17%):", sum(area_data$above_ff_threshold, na.rm = TRUE), "\n")
cat("  Areas above unemp threshold:", sum(area_data$above_unemp_threshold, na.rm = TRUE), "\n")
cat("  Energy communities (both):", sum(area_data$energy_community, na.rm = TRUE), "\n")

###############################################################################
# 5. Add ACS demographics
###############################################################################
cat("\n--- Merging ACS demographics ---\n")

if (file.exists(file.path(DATA_DIR, "acs_msa_demographics.rds"))) {
  acs_df <- readRDS(file.path(DATA_DIR, "acs_msa_demographics.rds"))

  area_data <- area_data %>%
    left_join(
      acs_df %>% select(cbsa_code, pop, med_income, pct_bachelors, pct_white),
      by = c("area_code" = "cbsa_code")
    )

  cat("  Areas with ACS data:", sum(!is.na(area_data$pop)), "\n")
}

###############################################################################
# 6. Process EIA generator data — construct outcomes
###############################################################################
cat("\n--- Processing EIA 860 generator data ---\n")

eia_gen <- readRDS(file.path(DATA_DIR, "eia860_generators_2023.rds"))

# Identify clean energy technologies
clean_tech_patterns <- c(
  "Solar", "Wind", "Onshore Wind", "Offshore Wind",
  "Solar Photovoltaic", "Solar Thermal",
  "Batteries", "Battery", "Storage",
  "Geothermal", "Hydroelectric"
)

# Look at column names to identify key fields
gen_cols <- names(eia_gen)
cat("  Generator columns:", paste(head(gen_cols, 10), collapse = ", "), "...\n")

# Standardize column names (EIA uses varying conventions)
eia_gen_clean <- eia_gen %>%
  rename_with(tolower) %>%
  rename_with(~gsub("[[:space:].]+", "_", .x))

# Find relevant columns
status_col <- names(eia_gen_clean)[grepl("status", names(eia_gen_clean))][1]
tech_col <- names(eia_gen_clean)[grepl("technol", names(eia_gen_clean))][1]
cap_col <- names(eia_gen_clean)[grepl("nameplate.*capacity|capacity.*mw", names(eia_gen_clean))][1]
state_col <- names(eia_gen_clean)[grepl("^state$", names(eia_gen_clean))][1]
county_col <- names(eia_gen_clean)[grepl("^county$", names(eia_gen_clean))][1]
year_col <- names(eia_gen_clean)[grepl("operating.*year|year.*oper", names(eia_gen_clean))][1]
plant_code_col <- names(eia_gen_clean)[grepl("plant.*code", names(eia_gen_clean))][1]

cat("  Key columns found:\n")
cat("    Status:", status_col, "\n")
cat("    Technology:", tech_col, "\n")
cat("    Capacity:", cap_col, "\n")
cat("    State:", state_col, "\n")
cat("    County:", county_col, "\n")
cat("    Year online:", year_col, "\n")

# Clean and classify generators
if (!is.null(tech_col) && !is.null(cap_col)) {
  eia_gen_clean$technology <- eia_gen_clean[[tech_col]]
  eia_gen_clean$capacity_mw <- as.numeric(eia_gen_clean[[cap_col]])

  if (!is.null(year_col)) {
    eia_gen_clean$year_online <- as.numeric(eia_gen_clean[[year_col]])
  }

  # Classify as clean energy
  eia_gen_clean <- eia_gen_clean %>%
    mutate(
      is_clean = grepl(
        paste(clean_tech_patterns, collapse = "|"),
        technology, ignore.case = TRUE
      )
    )

  cat("  Total generators:", nrow(eia_gen_clean), "\n")
  cat("  Clean energy generators:", sum(eia_gen_clean$is_clean, na.rm = TRUE), "\n")
}

# Get plant locations (county names + state)
eia_plant <- readRDS(file.path(DATA_DIR, "eia860_plants_2023.rds"))
eia_plant_clean <- eia_plant %>%
  rename_with(tolower) %>%
  rename_with(~gsub("[[:space:].]+", "_", .x))

cat("  Plant columns:", paste(head(names(eia_plant_clean), 10), collapse = ", "), "\n")

# EIA uses plant_code to link generators to plants
# Plants have state + county (as name, not FIPS)
plant_state_col <- names(eia_plant_clean)[grepl("^state$", names(eia_plant_clean))][1]
plant_county_col <- names(eia_plant_clean)[grepl("^county$", names(eia_plant_clean))][1]
plant_code_col2 <- names(eia_plant_clean)[grepl("plant.*code", names(eia_plant_clean))][1]

cat("  Plant state col:", plant_state_col, "\n")
cat("  Plant county col:", plant_county_col, "\n")
cat("  Plant code col:", plant_code_col2, "\n")

# Aggregate generators by state (EIA uses state postal codes)
post_ira_clean <- eia_gen_clean %>%
  filter(is_clean, !is.na(year_online), year_online >= 2023)
cat("  Post-IRA clean generators (2023+):", nrow(post_ira_clean), "\n")
cat("  Post-IRA clean capacity (MW):", round(sum(post_ira_clean$capacity_mw, na.rm = TRUE), 1), "\n")

saveRDS(eia_gen_clean, file.path(DATA_DIR, "eia_generators_clean.rds"))

###############################################################################
# 7. Link generators to MSA/non-MSA areas via plant county FIPS
###############################################################################
cat("\n--- Linking generators to MSA areas via plant county ---\n")

# The EIA plant file has county and state for each plant.
# We link generators -> plants -> county FIPS -> CBSA (MSA/non-MSA).
# This gives us area-level (not state-level) outcome variation.

# Build plant-level county FIPS from state + county name
# First, get state FIPS mapping
state_crosswalk <- tigris::fips_codes %>%
  select(state_code, state) %>%
  distinct() %>%
  rename(state_fips = state_code, state_postal = state)

# Try to find FIPS columns in plant data
plant_fips_col <- names(eia_plant_clean)[grepl("fips", names(eia_plant_clean), ignore.case = TRUE)]
cat("  Plant FIPS columns:", paste(plant_fips_col, collapse = ", "), "\n")

# Build plant -> CBSA mapping
# EIA plant file typically has state and county (name). We need county FIPS.
# Use tigris::fips_codes for state+county name -> FIPS lookup
county_lookup <- tigris::fips_codes %>%
  mutate(
    county_clean = tolower(gsub(" County| Parish| Borough| Census Area| Municipality| city", "",
                                 county)),
    fips = paste0(state_code, county_code)
  ) %>%
  select(state, county_clean, fips) %>%
  distinct()

# Get plant locations
plant_locs <- eia_plant_clean %>%
  mutate(
    plant_code_val = as.character(.data[[plant_code_col2]]),
    plant_state = as.character(.data[[plant_state_col]]),
    plant_county = tolower(as.character(.data[[plant_county_col]]))
  ) %>%
  select(plant_code_val, plant_state, plant_county)

# Match to FIPS via state + county name (take first match for duplicates)
plant_fips <- plant_locs %>%
  left_join(
    county_lookup %>% distinct(state, county_clean, .keep_all = TRUE),
    by = c("plant_state" = "state", "plant_county" = "county_clean")
  )

cat("  Plants with county FIPS match:", sum(!is.na(plant_fips$fips)), "of", nrow(plant_fips), "\n")

# Map FIPS to CBSA
plant_cbsa <- plant_fips %>%
  left_join(county_cbsa, by = "fips") %>%
  mutate(
    area_code = ifelse(is.na(cbsa_code),
                       paste0(substr(fips, 1, 2), "NM"),
                       cbsa_code)
  )

cat("  Plants mapped to CBSA:", sum(!is.na(plant_cbsa$area_code)), "\n")

# Link generators to plants then to areas
gen_plant_code_col <- names(eia_gen_clean)[grepl("plant.*code", names(eia_gen_clean))][1]

gen_with_area <- eia_gen_clean %>%
  filter(is_clean) %>%
  mutate(
    plant_code_val = as.character(.data[[gen_plant_code_col]]),
    gen_year = as.numeric(year_online),
    post_ira = ifelse(!is.na(gen_year) & gen_year >= 2023, 1, 0)
  ) %>%
  left_join(
    plant_cbsa %>% select(plant_code_val, area_code) %>%
      distinct(plant_code_val, .keep_all = TRUE),
    by = "plant_code_val"
  )

cat("  Clean generators with area assignment:", sum(!is.na(gen_with_area$area_code)), "of", nrow(gen_with_area), "\n")

# Aggregate clean energy capacity by area
area_clean_cap <- gen_with_area %>%
  filter(!is.na(area_code)) %>%
  group_by(area_code) %>%
  summarise(
    total_clean_mw = sum(capacity_mw, na.rm = TRUE),
    post_ira_clean_mw = sum(capacity_mw * post_ira, na.rm = TRUE),
    n_clean_gen = n(),
    n_post_ira = sum(post_ira),
    .groups = "drop"
  )

cat("  Areas with clean energy generators:", nrow(area_clean_cap), "\n")

# Merge area-level outcomes
area_data <- area_data %>%
  left_join(area_clean_cap, by = "area_code")

# Normalize by area employment
area_data <- area_data %>%
  mutate(
    total_clean_mw = replace_na(total_clean_mw, 0),
    post_ira_clean_mw = replace_na(post_ira_clean_mw, 0),
    n_clean_gen = replace_na(n_clean_gen, 0),
    n_post_ira = replace_na(n_post_ira, 0),
    clean_mw_per_1000emp = total_clean_mw / total_emp * 1000,
    post_ira_mw_per_1000emp = post_ira_clean_mw / total_emp * 1000
  )

###############################################################################
# 8. Restrict sample for RDD
###############################################################################
cat("\n--- Constructing RDD analysis sample ---\n")

# Main RDD sample: areas with unemployment >= national average
# (so the unemployment condition is mechanically satisfied)
rdd_sample <- area_data %>%
  filter(
    !is.na(unemp_rate),
    above_unemp_threshold,  # Condition on unemp >= national avg
    total_emp > 0,
    !is.na(ff_share)
  )

cat("  Full sample:", nrow(area_data), "areas\n")
cat("  RDD sample (unemp >= national):", nrow(rdd_sample), "areas\n")
cat("  RDD treated (energy community):", sum(rdd_sample$energy_community), "\n")
cat("  RDD control (not EC):", sum(!rdd_sample$energy_community), "\n")

# Summary of running variable
cat("\n  Running variable (FF share) summary:\n")
cat("    Mean:", round(mean(rdd_sample$ff_share), 4), "%\n")
cat("    Median:", round(median(rdd_sample$ff_share), 4), "%\n")
cat("    Min:", round(min(rdd_sample$ff_share), 4), "%\n")
cat("    Max:", round(max(rdd_sample$ff_share), 4), "%\n")
cat("    SD:", round(sd(rdd_sample$ff_share), 4), "%\n")
cat("    Areas near threshold (0.10-0.24%):",
    sum(rdd_sample$ff_share >= 0.10 & rdd_sample$ff_share <= 0.24), "\n")

###############################################################################
# 9. Save analysis datasets
###############################################################################
saveRDS(area_data, file.path(DATA_DIR, "area_data_full.rds"))
saveRDS(rdd_sample, file.path(DATA_DIR, "rdd_sample.rds"))

cat("\n=== Data cleaning complete ===\n")
cat("Analysis sample:", nrow(rdd_sample), "MSAs/non-MSAs\n")
