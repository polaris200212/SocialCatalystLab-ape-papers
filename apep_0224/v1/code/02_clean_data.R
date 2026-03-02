## ============================================================================
## 02_clean_data.R — Merge and prepare analysis dataset
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir <- "../data"

## ============================================================================
## 1. Load raw data
## ============================================================================

mortality <- read_csv(file.path(data_dir, "cdc_mortality_state_year.csv"),
                      show_col_types = FALSE)
treatment <- read_csv(file.path(data_dir, "treatment_dates.csv"),
                      show_col_types = FALSE)
medicaid  <- read_csv(file.path(data_dir, "medicaid_expansion.csv"),
                      show_col_types = FALSE)

# Load population if available
pop_file <- file.path(data_dir, "census_population_state_year.csv")
has_pop <- file.exists(pop_file)
if (has_pop) {
  population <- read_csv(pop_file, show_col_types = FALSE)
}

## ============================================================================
## 2. State name to FIPS crosswalk
## ============================================================================

state_xwalk <- tibble(
  state = c(state.name, "District of Columbia"),
  state_abb = c(state.abb, "DC"),
  state_fips = c(
    "01","02","04","05","06","08","09","10","11","12","13","15","16",
    "17","18","19","20","21","22","23","24","25","26","27","28","29",
    "30","31","32","33","34","35","36","37","38","39","40","41","42",
    "44","45","46","47","48","49","50","51","53","54","55","56"
  )
)

## ============================================================================
## 3. Build analysis panel
## ============================================================================

# Start with suicide data
suicide <- mortality %>%
  filter(cause == "Suicide") %>%
  select(state, year, suicide_deaths = deaths, suicide_aadr = aadr)

# Add placebo outcomes
heart <- mortality %>%
  filter(cause == "Heart Disease") %>%
  select(state, year, heart_deaths = deaths, heart_aadr = aadr)

cancer <- mortality %>%
  filter(cause == "Cancer") %>%
  select(state, year, cancer_deaths = deaths, cancer_aadr = aadr)

panel <- suicide %>%
  left_join(heart, by = c("state", "year")) %>%
  left_join(cancer, by = c("state", "year"))

# Add state identifiers
panel <- panel %>%
  left_join(state_xwalk, by = "state") %>%
  filter(!is.na(state_fips))  # Drop territories

# Add treatment indicator
panel <- panel %>%
  left_join(
    treatment %>% select(state, treatment_year, treatment_year_alt),
    by = "state"
  ) %>%
  mutate(
    # For Callaway-Sant'Anna: first_treat = 0 for never-treated
    first_treat = if_else(is.na(treatment_year), 0L, as.integer(treatment_year)),
    first_treat_alt = if_else(is.na(treatment_year_alt), 0L, as.integer(treatment_year_alt)),
    # Binary treatment indicator
    treated = as.integer(!is.na(treatment_year) & year >= treatment_year),
    treated_alt = as.integer(!is.na(treatment_year_alt) & year >= treatment_year_alt),
    # Treatment group (for descriptive plots)
    treat_group = if_else(is.na(treatment_year), "Never Treated",
                          paste0("Treated (", treatment_year, ")"))
  )

# Add Medicaid expansion indicator
panel <- panel %>%
  left_join(medicaid %>% select(state, medicaid_year), by = "state") %>%
  mutate(
    medicaid_expanded = as.integer(!is.na(medicaid_year) & year >= medicaid_year)
  )

# Add population data if available
if (has_pop) {
  panel <- panel %>%
    left_join(
      population %>% select(state_name, year, total_pop, youth_share),
      by = c("state" = "state_name", "year")
    )
}

# Create numeric state ID for fixest
panel <- panel %>%
  mutate(state_id = as.integer(factor(state)))

## ============================================================================
## 4. Summary statistics
## ============================================================================

cat("\n=== Panel Summary ===\n")
cat(sprintf("States: %d\n", n_distinct(panel$state)))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("Observations: %d\n", nrow(panel)))
cat(sprintf("Treated states: %d\n", sum(panel$first_treat > 0 & panel$year == 2017)))
cat(sprintf("Never-treated states: %d\n", sum(panel$first_treat == 0 & panel$year == 2017)))

# Treatment cohort distribution
cat("\n=== Treatment Cohorts ===\n")
panel %>%
  filter(first_treat > 0, year == max(year)) %>%
  count(first_treat, name = "n_states") %>%
  arrange(first_treat) %>%
  print(n = 30)

# Outcome summary
cat("\n=== Outcome Summary ===\n")
panel %>%
  group_by(treated) %>%
  summarise(
    n = n(),
    mean_suicide_aadr = mean(suicide_aadr, na.rm = TRUE),
    sd_suicide_aadr = sd(suicide_aadr, na.rm = TRUE),
    mean_suicide_deaths = mean(suicide_deaths, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

## ============================================================================
## 5. Log-transform outcome for percent interpretation
## ============================================================================

panel <- panel %>%
  mutate(
    ln_suicide_aadr = log(suicide_aadr),
    ln_heart_aadr = log(heart_aadr),
    ln_cancer_aadr = log(cancer_aadr),
    ln_suicide_deaths = log(suicide_deaths)
  )

## ============================================================================
## 6. Save analysis dataset
## ============================================================================

write_csv(panel, file.path(data_dir, "analysis_panel.csv"))
cat(sprintf("\nAnalysis panel saved: %d rows\n", nrow(panel)))

# Also save summary stats for the paper
summary_stats <- panel %>%
  summarise(
    n_states = n_distinct(state),
    n_years = n_distinct(year),
    n_obs = n(),
    n_treated = n_distinct(state[first_treat > 0]),
    n_control = n_distinct(state[first_treat == 0]),
    mean_suicide_rate = mean(suicide_aadr, na.rm = TRUE),
    sd_suicide_rate = sd(suicide_aadr, na.rm = TRUE),
    min_suicide_rate = min(suicide_aadr, na.rm = TRUE),
    max_suicide_rate = max(suicide_aadr, na.rm = TRUE),
    mean_suicide_deaths = mean(suicide_deaths, na.rm = TRUE)
  )

write_csv(summary_stats, file.path(data_dir, "summary_statistics.csv"))
cat("Summary statistics saved.\n")
