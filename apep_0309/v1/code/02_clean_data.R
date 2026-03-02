## ============================================================
## 02_clean_data.R
## Construct analysis dataset: merge CDC, ACS, PDMP dates,
## and build network exposure variable
## ============================================================

source("00_packages.R")

data_dir <- "../data/"

## ============================================================
## 1. Load all data
## ============================================================

cat("Loading data files...\n")

vsrr <- read_csv(paste0(data_dir, "cdc_vsrr_overdose.csv"), show_col_types = FALSE)
nchs <- read_csv(paste0(data_dir, "cdc_nchs_drug_poisoning.csv"), show_col_types = FALSE)
acs <- read_csv(paste0(data_dir, "census_acs_covariates.csv"), show_col_types = FALSE)
pdmp <- read_csv(paste0(data_dir, "pdmp_must_query_dates.csv"), show_col_types = FALSE)
adj <- read_csv(paste0(data_dir, "state_adjacency.csv"), show_col_types = FALSE)
concurrent <- read_csv(paste0(data_dir, "concurrent_opioid_policies.csv"), show_col_types = FALSE)
fips <- read_csv(paste0(data_dir, "state_fips_crosswalk.csv"), show_col_types = FALSE)

## ============================================================
## 2. Build outcome panel: overdose deaths by state-year
## ============================================================

cat("Building outcome panel...\n")

# --- VSRR data: 2015-2023 (has drug-type breakdowns) ---
vsrr_wide <- vsrr %>%
  mutate(
    indicator_clean = case_when(
      indicator == "Number of Drug Overdose Deaths" ~ "total_overdose",
      indicator == "Opioids (T40.0-T40.4,T40.6)" ~ "all_opioids",
      indicator == "Natural & semi-synthetic opioids (T40.2)" ~ "rx_opioids",
      indicator == "Heroin (T40.1)" ~ "heroin",
      indicator == "Synthetic opioids, excl. methadone (T40.4)" ~ "synthetic_opioids",
      indicator == "Cocaine (T40.5)" ~ "cocaine",
      indicator == "Psychostimulants with abuse potential (T43.6)" ~ "psychostimulants",
      indicator == "Methadone (T40.3)" ~ "methadone",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(indicator_clean)) %>%
  select(state, year, indicator_clean, deaths_adj) %>%
  pivot_wider(names_from = indicator_clean, values_from = deaths_adj,
              values_fn = first)

# --- NCHS data: 1999-2015 (total drug poisoning only) ---
# The NCHS data uses state names, not abbreviations
nchs_clean <- nchs %>%
  left_join(fips %>% select(state, state_name), by = c("state" = "state_name")) %>%
  rename(state_abbr = state.y) %>%
  filter(!is.na(state_abbr)) %>%
  rename(total_overdose_nchs = deaths, pop_nchs = population,
         age_adj_rate_nchs = age_adjusted_rate) %>%
  select(state_abbr, year, total_overdose_nchs, pop_nchs, age_adj_rate_nchs)

# --- Combine: use NCHS for 2006-2014, VSRR for 2015-2023 ---
# For the overlap year 2015, prefer VSRR (more detail)
outcome_panel <- vsrr_wide %>%
  rename(state_abbr = state)

# Add NCHS years (2006-2014) with total overdose only
nchs_pre <- nchs_clean %>%
  filter(year >= 2006, year <= 2014) %>%
  rename(total_overdose = total_overdose_nchs) %>%
  mutate(state_abbr = state_abbr) %>%  # already has abbreviation
  select(state_abbr, year, total_overdose)

outcome_panel <- bind_rows(nchs_pre, outcome_panel) %>%
  arrange(state_abbr, year)

cat("  Outcome panel:", nrow(outcome_panel), "state-years\n")

## ============================================================
## 3. Merge ACS covariates
## ============================================================

cat("Merging ACS covariates...\n")

# ACS uses FIPS codes; need to merge via crosswalk
acs_clean <- acs %>%
  left_join(fips %>% select(state, state_fips), by = "state_fips") %>%
  filter(!is.na(state)) %>%
  select(state, year, pop, log_pop, median_hh_income, log_income,
         pct_bachelors, pct_white, pct_uninsured, unemployment_rate) %>%
  rename(state_abbr = state)

# Merge with outcome panel
panel <- outcome_panel %>%
  left_join(acs_clean, by = c("state_abbr", "year"))

cat("  After ACS merge:", nrow(panel), "rows,",
    sum(!is.na(panel$pop)), "with demographics\n")

## ============================================================
## 4. Merge PDMP mandate dates and compute treatment status
## ============================================================

cat("Computing own-state PDMP treatment...\n")

panel <- panel %>%
  left_join(pdmp %>% select(state, must_query_year),
            by = c("state_abbr" = "state")) %>%
  mutate(
    # Own-state PDMP must-query mandate active
    own_pdmp = ifelse(!is.na(must_query_year) & year >= must_query_year, 1, 0),
    # Years since own PDMP adoption (for event study)
    own_pdmp_rel_year = ifelse(!is.na(must_query_year),
                                year - must_query_year, NA_real_)
  )

cat("  Own PDMP active: ", sum(panel$own_pdmp), "state-years\n")

## ============================================================
## 5. Construct PDMP Network Exposure variable
## ============================================================

cat("Constructing PDMP network exposure...\n")

# For each state-year, compute the share of contiguous neighbors
# that have an active must-query PDMP mandate

# First, create state-year PDMP status lookup
pdmp_status <- panel %>%
  select(state_abbr, year, own_pdmp) %>%
  distinct()

# For each state-year, find neighbors and compute exposure
network_exposure <- adj %>%
  rename(state_abbr = state) %>%
  # Expand to all years
  crossing(year = 2006:2023) %>%
  # Look up neighbor PDMP status
  left_join(pdmp_status,
            by = c("neighbor" = "state_abbr", "year"),
            suffix = c("", "_neighbor")) %>%
  rename(neighbor_pdmp = own_pdmp) %>%
  # For each state-year: compute share of neighbors with PDMP
  group_by(state_abbr, year) %>%
  summarise(
    n_neighbors = n(),
    n_neighbors_pdmp = sum(neighbor_pdmp, na.rm = TRUE),
    share_neighbors_pdmp = n_neighbors_pdmp / n_neighbors,
    # Population-weighted version (needs neighbor populations)
    .groups = "drop"
  )

# Also compute population-weighted exposure
pop_lookup <- acs_clean %>% select(state_abbr, year, pop) %>% distinct()

network_exposure_popw <- adj %>%
  rename(state_abbr = state) %>%
  crossing(year = 2006:2023) %>%
  left_join(pdmp_status,
            by = c("neighbor" = "state_abbr", "year")) %>%
  rename(neighbor_pdmp = own_pdmp) %>%
  left_join(pop_lookup,
            by = c("neighbor" = "state_abbr", "year"),
            suffix = c("", "_neighbor")) %>%
  rename(neighbor_pop = pop) %>%
  group_by(state_abbr, year) %>%
  summarise(
    share_neighbors_pdmp_popw = sum(neighbor_pdmp * neighbor_pop, na.rm = TRUE) /
      sum(neighbor_pop, na.rm = TRUE),
    total_neighbor_pop = sum(neighbor_pop, na.rm = TRUE),
    .groups = "drop"
  )

# Merge both exposure measures
network_exposure <- network_exposure %>%
  left_join(network_exposure_popw, by = c("state_abbr", "year"))

# Merge into panel
panel <- panel %>%
  left_join(network_exposure, by = c("state_abbr", "year"))

# Create binary treatment indicators at various thresholds
panel <- panel %>%
  mutate(
    # Primary: >=50% of neighbors have must-query PDMP
    high_exposure_50 = ifelse(share_neighbors_pdmp >= 0.50, 1, 0),
    # Alternative thresholds
    high_exposure_25 = ifelse(share_neighbors_pdmp >= 0.25, 1, 0),
    high_exposure_75 = ifelse(share_neighbors_pdmp >= 0.75, 1, 0),
    # Population-weighted binary
    high_exposure_50_popw = ifelse(share_neighbors_pdmp_popw >= 0.50, 1, 0)
  )

cat("  Network exposure computed for", nrow(panel), "state-years\n")

## ============================================================
## 6. Compute overdose rates per 100,000
## ============================================================

cat("Computing overdose rates per 100,000...\n")

outcome_vars <- c("total_overdose", "all_opioids", "rx_opioids", "heroin",
                   "synthetic_opioids", "cocaine", "psychostimulants", "methadone")

for (v in outcome_vars) {
  rate_var <- paste0(v, "_rate")
  if (v %in% names(panel)) {
    panel[[rate_var]] <- panel[[v]] / panel$pop * 100000
  }
}

## ============================================================
## 7. Merge concurrent policies
## ============================================================

cat("Merging concurrent opioid policies...\n")

panel <- panel %>%
  left_join(concurrent, by = c("state_abbr" = "state")) %>%
  mutate(
    has_naloxone = ifelse(!is.na(naloxone_year) & year >= naloxone_year, 1, 0),
    has_good_samaritan = ifelse(!is.na(good_samaritan_year) & year >= good_samaritan_year, 1, 0),
    has_medicaid_expansion = ifelse(!is.na(medicaid_expansion_year) & year >= medicaid_expansion_year, 1, 0)
  )

## ============================================================
## 8. Network centrality measures
## ============================================================

cat("Computing network centrality...\n")

# Degree centrality = number of contiguous neighbors
degree_centrality <- adj %>%
  count(state, name = "degree") %>%
  rename(state_abbr = state)

panel <- panel %>%
  left_join(degree_centrality, by = "state_abbr")

## ============================================================
## 9. Define analysis sample and compute first-treatment year
## ============================================================

cat("Defining analysis sample...\n")

# Exclude non-contiguous states (AK, HI) — no land borders
panel <- panel %>%
  filter(!state_abbr %in% c("AK", "HI"))

# For network exposure treatment timing (for event study):
# First year when high_exposure_50 becomes 1
first_exposure <- panel %>%
  filter(high_exposure_50 == 1) %>%
  group_by(state_abbr) %>%
  summarise(first_high_exposure_year = min(year), .groups = "drop")

panel <- panel %>%
  left_join(first_exposure, by = "state_abbr") %>%
  mutate(
    # Never-exposed states get 0 (for Callaway-Sant'Anna)
    first_high_exposure_year = replace_na(first_high_exposure_year, 0),
    # Relative time for event study
    exposure_rel_year = ifelse(first_high_exposure_year > 0,
                                year - first_high_exposure_year, NA_real_)
  )

# Pre-treatment covariate means (2006-2011, before any PDMP mandate)
pre_treatment_means <- panel %>%
  filter(year >= 2006, year <= 2011) %>%
  group_by(state_abbr) %>%
  summarise(
    pre_overdose_rate = mean(total_overdose_rate, na.rm = TRUE),
    pre_pop = mean(pop, na.rm = TRUE),
    pre_income = mean(median_hh_income, na.rm = TRUE),
    pre_pct_white = mean(pct_white, na.rm = TRUE),
    pre_pct_bachelors = mean(pct_bachelors, na.rm = TRUE),
    pre_unemployment = mean(unemployment_rate, na.rm = TRUE),
    pre_pct_uninsured = mean(pct_uninsured, na.rm = TRUE),
    .groups = "drop"
  )

panel <- panel %>%
  left_join(pre_treatment_means, by = "state_abbr")

## ============================================================
## 10. Save analysis dataset
## ============================================================

cat("Saving analysis dataset...\n")
# Remove non-state entities (PR, US, YC) from NCHS data
panel <- panel %>% filter(!state_abbr %in% c("PR", "US", "YC"))
write_csv(panel, paste0(data_dir, "analysis_panel.csv"))

# Summary statistics
cat("\n==============================\n")
cat("Analysis Dataset Summary\n")
cat("==============================\n")
cat("Rows:", nrow(panel), "\n")
cat("States:", n_distinct(panel$state_abbr), "\n")
cat("Years:", min(panel$year), "-", max(panel$year), "\n")
cat("State-years with total overdose data:", sum(!is.na(panel$total_overdose_rate)), "\n")
cat("State-years with drug-type breakdowns:", sum(!is.na(panel$rx_opioids_rate)), "\n")
cat("States ever exposed (50%):", sum(panel$first_high_exposure_year > 0 & panel$year == 2023, na.rm = TRUE), "\n")
cat("Never-exposed states:", sum(panel$first_high_exposure_year == 0 & panel$year == 2023, na.rm = TRUE), "\n")
cat("\nMean overdose rate (per 100k):", round(mean(panel$total_overdose_rate, na.rm = TRUE), 1), "\n")
cat("SD:", round(sd(panel$total_overdose_rate, na.rm = TRUE), 1), "\n")
cat("Mean network PDMP exposure:", round(mean(panel$share_neighbors_pdmp, na.rm = TRUE), 3), "\n")
cat("==============================\n")
