## ============================================================================
## 02_clean_data.R — Data cleaning and variable construction
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- 1. Load data ----
cat("Loading data...\n")
panel_hcbs <- readRDS(file.path(DATA, "panel_hcbs_state_month.rds"))
panel_nonhcbs <- readRDS(file.path(DATA, "panel_nonhcbs_state_month.rds"))
mw_annual <- readRDS(file.path(DATA, "mw_annual.rds"))
first_increase <- readRDS(file.path(DATA, "first_increase.rds"))
state_pop <- readRDS(file.path(DATA, "state_population.rds"))

## ---- 2. State abbreviation mapping ----
# NPPES uses full state names; FRED uses abbreviations
state_xwalk <- data.table(
  state_name_full = c(state.name, "District of Columbia"),
  state_abbr = c(state.abb, "DC")
)
# T-MSIS/NPPES state field is the two-letter abbreviation
# Verify
cat(sprintf("Unique states in HCBS panel: %d\n", uniqueN(panel_hcbs$state)))
cat(sprintf("Sample states: %s\n", paste(head(sort(unique(panel_hcbs$state))), collapse = ", ")))

## ---- 3. Merge minimum wage data ----
# panel_hcbs$state should be two-letter abbreviation (from NPPES)
panel_hcbs[, year_for_mw := year]
panel_hcbs <- merge(panel_hcbs, mw_annual[, .(state_abbr, year, min_wage, mw_change)],
                    by.x = c("state", "year_for_mw"),
                    by.y = c("state_abbr", "year"),
                    all.x = TRUE)

# Add first treatment year
panel_hcbs <- merge(panel_hcbs, first_increase,
                    by.x = "state", by.y = "state_abbr",
                    all.x = TRUE)

# Never-treated states: set first_treat_year = 0 (convention for CS)
panel_hcbs[is.na(first_treat_year), first_treat_year := 0]

# Do the same for non-HCBS panel (falsification)
panel_nonhcbs[, year_for_mw := year]
panel_nonhcbs <- merge(panel_nonhcbs, mw_annual[, .(state_abbr, year, min_wage, mw_change)],
                       by.x = c("state", "year_for_mw"),
                       by.y = c("state_abbr", "year"),
                       all.x = TRUE)
panel_nonhcbs <- merge(panel_nonhcbs, first_increase,
                       by.x = "state", by.y = "state_abbr",
                       all.x = TRUE)
panel_nonhcbs[is.na(first_treat_year), first_treat_year := 0]

## ---- 4. Add population denominators ----
# Create state FIPS mapping
state_fips_map <- data.table(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
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

panel_hcbs <- merge(panel_hcbs, state_fips_map, by.x = "state", by.y = "state_abbr", all.x = TRUE)
panel_hcbs <- merge(panel_hcbs, state_pop[, .(state_fips, year, population)],
                    by.x = c("state_fips", "year"), by.y = c("state_fips", "year"),
                    all.x = TRUE)

## ---- 5. Construct outcome variables ----
cat("Constructing outcome variables...\n")

# Per-capita outcomes (per 100,000 population)
panel_hcbs[, providers_per_100k := n_providers / population * 100000]
panel_hcbs[, spending_per_capita := total_paid / population]
panel_hcbs[, claims_per_capita := total_claims / population]
panel_hcbs[, beneficiaries_per_100k := total_beneficiaries / population * 100000]

# Log outcomes (for elasticity interpretation)
panel_hcbs[, log_providers := log(n_providers + 1)]
panel_hcbs[, log_spending := log(total_paid + 1)]
panel_hcbs[, log_claims := log(total_claims + 1)]
panel_hcbs[, log_beneficiaries := log(total_beneficiaries + 1)]

# Spending per provider
panel_hcbs[n_providers > 0, spending_per_provider := total_paid / n_providers]
panel_hcbs[n_providers > 0, claims_per_provider := total_claims / n_providers]
panel_hcbs[n_providers > 0, beneficiaries_per_provider := total_beneficiaries / n_providers]

## ---- 6. Create time variables for DiD ----
# Numeric time: months since Jan 2018 = 1
panel_hcbs[, time_period := (year - 2018) * 12 + month_num]

# Numeric state ID
panel_hcbs[, state_id := as.integer(factor(state))]

# Treatment cohort in time_period units (for monthly CS)
# Most MW changes happen Jan 1, so first_treat_month = January of first_treat_year
panel_hcbs[first_treat_year > 0, first_treat_period := (first_treat_year - 2018) * 12 + 1]
panel_hcbs[first_treat_year == 0, first_treat_period := 0]

# Also create annual version for annual CS
panel_hcbs[, annual_state_id := paste0(state, "_", year)]

# Binary treatment indicator
panel_hcbs[, treated := as.integer(first_treat_year > 0)]
panel_hcbs[, post := as.integer(year >= first_treat_year & first_treat_year > 0)]

# Log minimum wage
panel_hcbs[min_wage > 0, log_mw := log(min_wage)]

## ---- 7. Build annual panel for CS estimator ----
# CS works better with balanced panels; aggregate monthly to annual
cat("Building annual panel...\n")
panel_hcbs_annual <- panel_hcbs[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = max(n_providers),  # peak monthly providers in year
  avg_monthly_providers = mean(n_providers),
  population = first(population),
  min_wage = first(min_wage),
  first_treat_year = first(first_treat_year),
  state_id = first(state_id),
  state_fips = first(state_fips)
), by = .(state, year)]

# Outcomes
panel_hcbs_annual[, providers_per_100k := avg_monthly_providers / population * 100000]
panel_hcbs_annual[, spending_per_capita := total_paid / population]
panel_hcbs_annual[, log_providers := log(avg_monthly_providers + 1)]
panel_hcbs_annual[, log_spending := log(total_paid + 1)]
panel_hcbs_annual[min_wage > 0, log_mw := log(min_wage)]

cat(sprintf("Annual panel: %d state-years, %d states, years %d-%d\n",
            nrow(panel_hcbs_annual), uniqueN(panel_hcbs_annual$state),
            min(panel_hcbs_annual$year), max(panel_hcbs_annual$year)))

## ---- 8. Construct non-HCBS annual panel (falsification) ----
panel_nonhcbs[, time_period := (year - 2018) * 12 + month_num]
panel_nonhcbs[, state_id := as.integer(factor(state))]

panel_nonhcbs_annual <- panel_nonhcbs[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  n_providers = max(n_providers),
  avg_monthly_providers = mean(n_providers),
  min_wage = first(min_wage),
  first_treat_year = first(first_treat_year)
), by = .(state, year)]

panel_nonhcbs_annual[is.na(first_treat_year), first_treat_year := 0]
panel_nonhcbs_annual[, state_id := as.integer(factor(state))]
panel_nonhcbs_annual[, log_providers := log(avg_monthly_providers + 1)]

## ---- 9. Restrict to continental US + DC ----
# Drop territories and non-standard state codes
valid_states <- c(state.abb, "DC")
panel_hcbs <- panel_hcbs[state %in% valid_states]
panel_hcbs_annual <- panel_hcbs_annual[state %in% valid_states]
panel_nonhcbs_annual <- panel_nonhcbs_annual[state %in% valid_states]

cat(sprintf("\nFinal HCBS monthly panel: %d rows\n", nrow(panel_hcbs)))
cat(sprintf("Final HCBS annual panel: %d rows\n", nrow(panel_hcbs_annual)))
cat(sprintf("Final non-HCBS annual panel: %d rows\n", nrow(panel_nonhcbs_annual)))

## ---- 10. Treatment diagnostics ----
cat("\n=== Treatment Diagnostics ===\n")
treat_summary <- panel_hcbs_annual[year == 2020, .(
  state, first_treat_year, min_wage_2020 = min_wage
)]
treat_summary[, status := fifelse(first_treat_year == 0, "Never treated", paste0("Cohort ", first_treat_year))]

cat("Treatment cohort sizes:\n")
print(treat_summary[, .N, by = status][order(status)])

cat(sprintf("\nTotal states: %d\n", uniqueN(panel_hcbs_annual$state)))
cat(sprintf("Treated states: %d\n", uniqueN(panel_hcbs_annual[first_treat_year > 0, state])))
cat(sprintf("Never-treated states: %d\n", uniqueN(panel_hcbs_annual[first_treat_year == 0, state])))

## ---- 11. Save ----
saveRDS(panel_hcbs, file.path(DATA, "panel_hcbs_clean.rds"))
saveRDS(panel_hcbs_annual, file.path(DATA, "panel_hcbs_annual.rds"))
saveRDS(panel_nonhcbs_annual, file.path(DATA, "panel_nonhcbs_annual.rds"))

cat("\n=== Data cleaning complete ===\n")
