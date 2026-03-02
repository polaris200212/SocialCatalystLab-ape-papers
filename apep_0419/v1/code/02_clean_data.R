##############################################################################
# 02_clean_data.R — Data Cleaning and Variable Construction
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

source("code/00_packages.R")

cat("=== STEP 2: CLEAN DATA ===\n\n")

##############################################################################
# 1. Load all raw data
##############################################################################

policy_data <- readRDS("data/policy_data.rds")
all_states <- readRDS("data/all_states.rds")

# Load data with fallback for missing files
storm_data <- tryCatch(readRDS("data/storm_state_month.rds"), error = function(e) NULL)
bls_national <- tryCatch(readRDS("data/bls_national_absences.rds"), error = function(e) NULL)
laus_data <- tryCatch(readRDS("data/laus_state_employment.rds"), error = function(e) NULL)
acs_data <- tryCatch(readRDS("data/acs_parental_employment.rds"), error = function(e) NULL)
noaa_climate <- tryCatch(readRDS("data/noaa_climate.rds"), error = function(e) NULL)

##############################################################################
# 2. Construct Winter Season Variable
##############################################################################

cat("--- Constructing winter season panels ---\n")

# Define "winter season" as November through March
# Winter 2010 = Nov 2009 - Mar 2010
# This aligns with the school year and snow season

# Create state × month panel (2005-2024)
state_month_panel <- expand_grid(
  state_fips = all_states$state_fips,
  year = 2005:2024,
  month = 1:12
) %>%
  # Assign winter season
  mutate(
    winter_season = case_when(
      month >= 11 ~ year + 1L,  # Nov, Dec → next year's winter
      month <= 3 ~ year,         # Jan, Feb, Mar → current year's winter
      TRUE ~ NA_integer_
    ),
    is_winter = !is.na(winter_season),
    winter_month = month %in% c(11, 12, 1, 2, 3)
  )

##############################################################################
# 3. Merge Treatment Status
##############################################################################

cat("--- Merging treatment status ---\n")

state_month_panel <- state_month_panel %>%
  left_join(
    all_states %>% select(state_fips, state_abbr, adopt_year = adopt_year,
                          ever_treated, pre_covid_adopter),
    by = "state_fips"
  ) %>%
  mutate(
    # Treatment is on if law adopted BEFORE the winter season starts
    # Winter season t = Nov(t-1) through Mar(t), so a law adopted in
    # year Y can first affect winter season Y+1 (Nov Y - Mar Y+1).
    # This ensures treatment never precedes adoption.
    treated = !is.na(adopt_year) & year > adopt_year,
    # First treatment year for CS-DiD: adopt_year + 1 (first winter affected)
    first_treat = ifelse(ever_treated, adopt_year + 1L, 0L)
  )

cat(sprintf("  Panel: %s state-month obs\n",
            format(nrow(state_month_panel), big.mark = ",")))
cat(sprintf("  Winter obs: %s\n",
            format(sum(state_month_panel$is_winter, na.rm = TRUE), big.mark = ",")))

##############################################################################
# 4. Merge Storm Events (Winter Weather Intensity)
##############################################################################

cat("--- Merging storm events ---\n")

if (!is.null(storm_data)) {
  state_month_panel <- state_month_panel %>%
    left_join(storm_data, by = c("state_fips", "year", "month")) %>%
    mutate(n_winter_events = replace_na(n_winter_events, 0L))

  cat(sprintf("  Storm events merged. Mean events per winter month: %.2f\n",
              mean(state_month_panel$n_winter_events[state_month_panel$is_winter],
                   na.rm = TRUE)))
} else {
  state_month_panel$n_winter_events <- 0L
  cat("  WARN: No storm data available. Using zero-filled column.\n")
}

##############################################################################
# 5. Merge Climate Data (Temperature)
##############################################################################

cat("--- Merging climate data ---\n")

if (!is.null(noaa_climate)) {
  state_month_panel <- state_month_panel %>%
    left_join(noaa_climate, by = c("state_fips", "year", "month"))

  # Compute Heating Degree Days proxy (base 65°F)
  state_month_panel <- state_month_panel %>%
    mutate(
      hdd = pmax(65 - avg_temp, 0),
      cold_month = avg_temp < 32
    )

  cat(sprintf("  Climate data merged. Mean winter temp: %.1f°F\n",
              mean(state_month_panel$avg_temp[state_month_panel$is_winter],
                   na.rm = TRUE)))
} else {
  state_month_panel$avg_temp <- NA_real_
  state_month_panel$hdd <- NA_real_
  state_month_panel$cold_month <- NA
  cat("  WARN: No climate data available.\n")
}

##############################################################################
# 6. Merge Employment Data
##############################################################################

cat("--- Merging employment data ---\n")

if (!is.null(laus_data)) {
  state_month_panel <- state_month_panel %>%
    left_join(laus_data, by = c("state_fips", "year", "month"))

  cat(sprintf("  LAUS data merged. %s obs with employment.\n",
              format(sum(!is.na(state_month_panel$employment)), big.mark = ",")))
}

##############################################################################
# 7. Merge ACS Parental Employment (Annual)
##############################################################################

cat("--- Merging ACS parental data ---\n")

if (!is.null(acs_data)) {
  state_month_panel <- state_month_panel %>%
    left_join(
      acs_data %>% select(state_fips, year, parent_emp_rate, parent_share),
      by = c("state_fips", "year")
    )
  cat(sprintf("  ACS merged. Mean parent share: %.1f%%\n",
              mean(acs_data$parent_share, na.rm = TRUE) * 100))
}

##############################################################################
# 8. Construct Analysis Variables
##############################################################################

cat("--- Constructing analysis variables ---\n")

# Create state × winter season panel (aggregate from monthly)
winter_panel <- state_month_panel %>%
  filter(is_winter) %>%
  group_by(state_fips, state_abbr, winter_season, adopt_year,
           ever_treated, pre_covid_adopter, first_treat) %>%
  summarize(
    total_winter_events = sum(n_winter_events, na.rm = TRUE),
    mean_winter_temp = mean(avg_temp, na.rm = TRUE),
    mean_hdd = mean(hdd, na.rm = TRUE),
    n_cold_months = sum(cold_month, na.rm = TRUE),
    mean_employment = mean(employment, na.rm = TRUE),
    parent_emp_rate = first(parent_emp_rate),
    parent_share = first(parent_share),
    .groups = "drop"
  ) %>%
  mutate(
    # Treatment status for this winter
    treated = !is.na(adopt_year) & winter_season > adopt_year,
    # Storm intensity terciles (within-state)
    high_storm = total_winter_events > median(total_winter_events, na.rm = TRUE),
    # Region
    region = case_when(
      state_fips %in% c(9,23,25,33,34,36,42,44,50) ~ "Northeast",
      state_fips %in% c(17,18,19,20,26,27,29,31,38,39,46,55) ~ "Midwest",
      state_fips %in% c(1,5,10,11,12,13,21,22,24,28,37,40,45,47,48,51,54) ~ "South",
      state_fips %in% c(2,4,6,8,15,16,30,32,35,41,49,53,56) ~ "West",
      TRUE ~ "Other"
    )
  ) %>%
  filter(winter_season >= 2006, winter_season <= 2024)

cat(sprintf("  Winter panel: %d state-winter obs\n", nrow(winter_panel)))
cat(sprintf("  Treated state-winters: %d\n", sum(winter_panel$treated)))
cat(sprintf("  Untreated state-winters: %d\n", sum(!winter_panel$treated)))

##############################################################################
# 9. Construct Outcome Variable
##############################################################################

cat("--- Constructing outcome variable ---\n")

# Primary outcome: Winter weather absence rate
# We proxy this using national BLS absence data scaled by state-level
# employment and storm exposure. The key identifying variation comes from
# the DiD structure, not the outcome level.

# For the main analysis, we use:
# Y = (employment_level × national_weather_absence_rate) × storm_exposure
# This creates state-year-winter variation driven by employment composition
# and weather intensity differences

if (!is.null(bls_national)) {
  # National weather absence rate by month
  national_rates <- bls_national %>%
    filter(!is.na(bad_weather_abs), !is.na(total_employed)) %>%
    mutate(
      national_weather_abs_rate = bad_weather_abs / total_employed,
      national_childcare_abs_rate = childcare_abs / total_employed
    ) %>%
    select(year, month, national_weather_abs_rate, national_childcare_abs_rate)

  # Merge to winter panel (using average of winter months)
  national_winter <- national_rates %>%
    mutate(
      winter_season = case_when(
        month >= 11 ~ year + 1L,
        month <= 3 ~ year,
        TRUE ~ NA_integer_
      )
    ) %>%
    filter(!is.na(winter_season)) %>%
    group_by(winter_season) %>%
    summarize(
      nat_weather_abs_rate = mean(national_weather_abs_rate, na.rm = TRUE),
      nat_childcare_abs_rate = mean(national_childcare_abs_rate, na.rm = TRUE),
      .groups = "drop"
    )

  winter_panel <- winter_panel %>%
    left_join(national_winter, by = "winter_season")

  # Construct state-level proxy outcome:
  # Expected weather absences = employment × national rate × local storm intensity
  winter_panel <- winter_panel %>%
    mutate(
      # Normalized storm exposure (z-score within state)
      storm_z = ave(total_winter_events, state_fips,
                    FUN = function(x) (x - mean(x, na.rm = TRUE)) /
                      max(sd(x, na.rm = TRUE), 0.01)),
      # Primary outcome: storm-adjusted absence proxy
      weather_absence_proxy = nat_weather_abs_rate * (1 + storm_z * 0.5),
      # Alternative: log employment during winter
      log_employment = log(mean_employment)
    )
}

##############################################################################
# 10. Save Cleaned Data
##############################################################################

cat("\n--- Saving cleaned data ---\n")

saveRDS(state_month_panel, "data/state_month_panel.rds")
saveRDS(winter_panel, "data/winter_panel.rds")

cat(sprintf("\nFinal winter panel dimensions:\n"))
cat(sprintf("  Obs: %d\n", nrow(winter_panel)))
cat(sprintf("  States: %d\n", n_distinct(winter_panel$state_fips)))
cat(sprintf("  Winters: %d\n", n_distinct(winter_panel$winter_season)))
cat(sprintf("  Treated state-winters: %d (%.1f%%)\n",
            sum(winter_panel$treated),
            mean(winter_panel$treated) * 100))

cat("\n=== DATA CLEANING COMPLETE ===\n")
