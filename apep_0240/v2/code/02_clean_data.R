## 02_clean_data.R — Variable construction and panel assembly
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"

# ============================================================================
# 1. Load raw data
# ============================================================================

treatment <- read_csv(paste0(data_dir, "treatment_disclosure_laws.csv"),
                      show_col_types = FALSE)
zhvi_raw <- fread(paste0(data_dir, "zhvi_county.csv"))
fema_raw <- read_csv(paste0(data_dir, "fema_flood_declarations.csv"),
                     show_col_types = FALSE)

# ============================================================================
# 2. Clean ZHVI — Reshape to long panel
# ============================================================================
cat("Reshaping ZHVI to long format...\n")

# Identify date columns (YYYY-MM-DD format)
date_cols <- names(zhvi_raw)[grep("^\\d{4}-\\d{2}", names(zhvi_raw))]

# Keep county identifiers and date columns
zhvi_long <- zhvi_raw %>%
  select(RegionID, SizeRank, RegionName, RegionType, StateName, State,
         Metro, StateCodeFIPS, MunicipalCodeFIPS, all_of(date_cols)) %>%
  pivot_longer(cols = all_of(date_cols),
               names_to = "date",
               values_to = "zhvi") %>%
  mutate(
    date = as.Date(date),
    year = year(date),
    month = month(date),
    # Create 5-digit FIPS
    fips_state = sprintf("%02d", as.integer(StateCodeFIPS)),
    fips_county = sprintf("%03d", as.integer(MunicipalCodeFIPS)),
    fips = paste0(fips_state, fips_county),
    state_abbr = State,
    log_zhvi = log(zhvi)
  ) %>%
  filter(!is.na(zhvi), year >= 1997, year <= 2024)

cat("ZHVI panel:", n_distinct(zhvi_long$fips), "counties,",
    n_distinct(zhvi_long$date), "months.\n")

# ============================================================================
# 3. Construct Flood Exposure Measure
# ============================================================================
cat("Constructing flood exposure measure...\n")

# Count flood-related disaster declarations per county (pre-treatment, before 1992)
# Use declarations from 1953-1991 for pre-period exposure measure
# This avoids endogeneity from post-treatment declarations
fema_clean <- fema_raw %>%
  mutate(
    decl_year = year(as.Date(declarationDate)),
    fips_state = sprintf("%02d", as.integer(fipsStateCode)),
    fips_county = sprintf("%03d", as.integer(fipsCountyCode)),
    fips = paste0(fips_state, fips_county)
  ) %>%
  filter(!is.na(fips_county), fips_county != "000") # Remove state-level entries

# Pre-treatment flood exposure: count declarations before 1992
flood_exposure_pre <- fema_clean %>%
  filter(decl_year >= 1953, decl_year <= 1991) %>%
  group_by(fips, fips_state) %>%
  summarize(
    n_flood_decl_pre = n_distinct(disasterNumber),
    .groups = "drop"
  )

# Also compute total historical flood exposure (for robustness)
flood_exposure_total <- fema_clean %>%
  filter(decl_year >= 1953, decl_year <= 2018) %>%
  group_by(fips, fips_state) %>%
  summarize(
    n_flood_decl_total = n_distinct(disasterNumber),
    .groups = "drop"
  )

# Create binary high-flood indicator
# "High flood" = county in top tertile of pre-treatment flood declarations
# within its state
flood_exposure <- flood_exposure_pre %>%
  left_join(flood_exposure_total, by = c("fips", "fips_state")) %>%
  mutate(n_flood_decl_total = replace_na(n_flood_decl_total, 0))

# For counties NOT in the declarations data, they have 0 flood exposure
all_counties <- zhvi_long %>%
  distinct(fips, fips_state, state_abbr) %>%
  filter(!is.na(fips))

flood_merged <- all_counties %>%
  left_join(flood_exposure, by = c("fips", "fips_state")) %>%
  mutate(
    n_flood_decl_pre = replace_na(n_flood_decl_pre, 0),
    n_flood_decl_total = replace_na(n_flood_decl_total, 0)
  )

# Create within-state quantiles of flood exposure
# Use ntile to avoid NAs when all values in a group are identical
flood_merged <- flood_merged %>%
  group_by(fips_state) %>%
  mutate(
    flood_pctile = ifelse(n() > 1 & var(n_flood_decl_pre) > 0,
                          percent_rank(n_flood_decl_pre), 0),
    # High flood: county has above-median flood declarations within state
    # AND at least 1 declaration (avoids labeling zero-flood counties as "high")
    high_flood = as.integer(n_flood_decl_pre > 0 &
                            n_flood_decl_pre >= median(n_flood_decl_pre[n_flood_decl_pre > 0],
                                                       na.rm = TRUE)),
    any_flood = as.integer(n_flood_decl_pre > 0)
  ) %>%
  ungroup() %>%
  mutate(
    high_flood = replace_na(high_flood, 0),
    flood_pctile = replace_na(flood_pctile, 0)
  )

cat("Flood exposure:", sum(flood_merged$high_flood), "high-flood counties,",
    sum(flood_merged$any_flood), "counties with any flood declaration.\n")

# ============================================================================
# 4. Merge Treatment, Outcome, and Flood Exposure
# ============================================================================
cat("Assembling analysis panel...\n")

# Merge treatment info
panel <- zhvi_long %>%
  left_join(treatment %>% select(state_abbr, year_adopted, wave, grade_2024),
            by = "state_abbr") %>%
  left_join(flood_merged %>% select(fips, high_flood, any_flood,
                                     n_flood_decl_pre, flood_pctile),
            by = "fips") %>%
  filter(!is.na(year_adopted)) %>%  # Only states in our treatment/control groups
  mutate(
    # Treatment indicators
    post = as.integer(year >= year_adopted & year_adopted > 0),
    treated = as.integer(year_adopted > 0),
    # DDD interaction
    post_x_flood = post * high_flood,
    # Cohort for CS-DiD (0 = never treated)
    cohort = ifelse(year_adopted > 0, year_adopted, 0),
    # County numeric ID for FE
    county_id = as.integer(factor(fips)),
    state_id = as.integer(factor(state_abbr))
  )

# Collapse to annual for main analysis (reduce noise)
panel_annual <- panel %>%
  group_by(fips, state_abbr, fips_state, year, county_id, state_id,
           year_adopted, wave, grade_2024, cohort, treated,
           high_flood, any_flood, n_flood_decl_pre, flood_pctile) %>%
  summarize(
    zhvi = mean(zhvi, na.rm = TRUE),
    log_zhvi = mean(log_zhvi, na.rm = TRUE),
    n_months = n(),
    .groups = "drop"
  ) %>%
  mutate(
    post = as.integer(year >= year_adopted & year_adopted > 0),
    post_x_flood = post * high_flood,
    rel_year = ifelse(year_adopted > 0, year - year_adopted, NA_integer_)
  )

cat("Annual panel:", nrow(panel_annual), "county-years,",
    n_distinct(panel_annual$fips), "counties,",
    n_distinct(panel_annual$year), "years.\n")

# ============================================================================
# 5. Save analysis-ready datasets
# ============================================================================

fwrite(panel_annual, paste0(data_dir, "panel_annual.csv"))
fwrite(flood_merged, paste0(data_dir, "flood_exposure.csv"))

cat("\n============================================\n")
cat("DATA CLEANING COMPLETE\n")
cat("============================================\n")
cat("Saved: panel_annual.csv (", nrow(panel_annual), " rows)\n")
cat("Saved: flood_exposure.csv (", nrow(flood_merged), " rows)\n")

# Summary statistics
cat("\nSummary:\n")
cat("  Treated states:", sum(treatment$year_adopted > 0), "\n")
cat("  Never-treated states:", sum(treatment$year_adopted == 0), "\n")
cat("  Years:", min(panel_annual$year), "-", max(panel_annual$year), "\n")
cat("  Counties:", n_distinct(panel_annual$fips), "\n")
cat("  High-flood counties:", sum(flood_merged$high_flood), "\n")
cat("  Mean pre-treatment flood declarations:", round(mean(flood_merged$n_flood_decl_pre), 2), "\n")
