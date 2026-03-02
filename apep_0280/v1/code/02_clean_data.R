# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 02_clean_data.R - Construct analysis dataset
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

# ============================================================================
# 1. Load and combine BRFSS annual files
# ============================================================================

cat("Loading BRFSS annual files...\n")

brfss_files <- list.files(file.path(data_dir, "brfss"),
                          pattern = "brfss_\\d+\\.rds$",
                          full.names = TRUE)

cat(sprintf("  Found %d BRFSS files\n", length(brfss_files)))

df_list <- list()
for (f in brfss_files) {
  yr <- as.integer(str_extract(basename(f), "\\d+"))
  tryCatch({
    d <- readRDS(f)
    df_list[[as.character(yr)]] <- d
    cat(sprintf("  [%d] %d obs\n", yr, nrow(d)))
  }, error = function(e) {
    cat(sprintf("  [%d] ERROR: %s\n", yr, e$message))
  })
}

df_raw <- bind_rows(df_list)
cat(sprintf("\nCombined: %d observations across %d years\n",
            nrow(df_raw), n_distinct(df_raw$year)))

# ============================================================================
# 2. Construct smoking outcome variables
# ============================================================================

cat("\nConstructing smoking variables...\n")

# The _SMOKER3 / SMOKDAY2 coding varies across years.
# General approach: use SMOKE100 (ever smoked 100+ cigarettes) and SMOKDAY2
# to construct consistent current smoking status.

df <- df_raw %>%
  filter(
    !is.na(state_fips),
    state_fips <= 56,  # Exclude territories
    !is.na(wt),
    wt > 0
  ) %>%
  mutate(
    # Current smoker: smoked 100+ cigarettes AND currently smokes every day or some days
    # SMOKE100: 1=Yes, 2=No
    # SMOKDAY2: 1=Every day, 2=Some days, 3=Not at all
    # _SMOKER3: 1=everyday, 2=someday, 3=former, 4=never, 9=refused
    current_smoker = case_when(
      !is.na(smoke_status) & smoke_status %in% c(1, 2) ~ 1L,
      !is.na(smoke_status) & smoke_status == 3 ~ 0L,
      !is.na(smoke_everyday) & smoke_everyday %in% c(1, 2) ~ 1L,
      !is.na(smoke_everyday) & smoke_everyday %in% c(3, 4) ~ 0L,
      !is.na(smoke100) & smoke100 == 2 ~ 0L,  # Never smoked 100
      TRUE ~ NA_integer_
    ),

    # Everyday smoker (intensive margin)
    everyday_smoker = case_when(
      !is.na(smoke_status) & smoke_status == 1 ~ 1L,
      !is.na(smoke_status) & smoke_status %in% c(2, 3) ~ 0L,
      !is.na(smoke_everyday) & smoke_everyday == 1 ~ 1L,
      !is.na(smoke_everyday) & smoke_everyday %in% c(2, 3, 4) ~ 0L,
      TRUE ~ NA_integer_
    ),

    # Ever smoker (for conditioning)
    ever_smoker = case_when(
      !is.na(smoke100) & smoke100 == 1 ~ 1L,
      !is.na(smoke100) & smoke100 == 2 ~ 0L,
      current_smoker == 1 ~ 1L,
      TRUE ~ NA_integer_
    ),

    # Quit attempt (among current/recent smokers)
    # STOPSMK2: 1=Yes, 2=No, 7/9=DK/Refused
    quit_attempt_clean = case_when(
      !is.na(quit_attempt) & quit_attempt == 1 ~ 1L,
      !is.na(quit_attempt) & quit_attempt == 2 ~ 0L,
      TRUE ~ NA_integer_
    ),

    # Former smoker (ever smoked but quit)
    former_smoker = case_when(
      ever_smoker == 1 & current_smoker == 0 ~ 1L,
      ever_smoker == 1 & current_smoker == 1 ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# ============================================================================
# 3. Clean demographics
# ============================================================================

cat("Cleaning demographics...\n")

df <- df %>%
  mutate(
    # Age groups
    age_group = case_when(
      age_raw >= 18 & age_raw <= 24 ~ "18-24",
      age_raw >= 25 & age_raw <= 34 ~ "25-34",
      age_raw >= 35 & age_raw <= 44 ~ "35-44",
      age_raw >= 45 & age_raw <= 54 ~ "45-54",
      age_raw >= 55 & age_raw <= 64 ~ "55-64",
      age_raw >= 65 ~ "65+",
      TRUE ~ NA_character_
    ),

    # Sex: 1=Male, 2=Female
    female = case_when(
      sex == 2 ~ 1L,
      sex == 1 ~ 0L,
      TRUE ~ NA_integer_
    ),

    # Income: simplified
    high_income = case_when(
      income >= 5 ~ 1L,  # $50k+ (varies by year)
      income %in% c(1, 2, 3, 4) ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# Education: detect coding scheme per year, then apply correct cutpoint
# BRFSS _EDUCAG: 1=no HS, 2=HS grad, 3=some college, 4=college grad, 9=DK/Missing
# BRFSS EDUCA:   1=none, 2=elem, 3=some HS, 4=HS grad, 5=some college, 6=college grad, 9=Refused
# Both have max=9, so check whether values 5 or 6 exist (only in EDUCA)
edu_scheme <- df %>%
  group_by(year) %>%
  summarise(
    has_5or6 = any(education %in% c(5, 6), na.rm = TRUE),
    .groups = "drop"
  )

cat("Education coding scheme by year:\n")
for (i in seq_len(nrow(edu_scheme))) {
  scheme <- ifelse(edu_scheme$has_5or6[i], "EDUCA (1-6)", "_EDUCAG (1-4)")
  cat(sprintf("  %d: %s\n", edu_scheme$year[i], scheme))
}

df <- df %>%
  left_join(edu_scheme, by = "year") %>%
  mutate(
    college = case_when(
      has_5or6 & education == 6 ~ 1L,                  # EDUCA: 6 = college grad
      has_5or6 & education %in% c(1,2,3,4,5) ~ 0L,     # EDUCA: below college grad
      !has_5or6 & education == 4 ~ 1L,                  # _EDUCAG: 4 = college grad
      !has_5or6 & education %in% c(1,2,3) ~ 0L,         # _EDUCAG: below college grad
      TRUE ~ NA_integer_                                 # 9=DK/Missing → NA
    )
  ) %>%
  select(-has_5or6)

cat(sprintf("Education fix check: overall college rate = %.1f%%\n",
            100 * weighted.mean(df$college, df$wt, na.rm = TRUE)))

# ============================================================================
# 4. Merge smoking ban treatment
# ============================================================================

cat("Merging treatment variables...\n")

ban_dates <- readRDS(file.path(data_dir, "smoking_ban_dates.rds"))
fips_lookup <- readRDS(file.path(data_dir, "smoking_ban_dates.rds")) %>%
  select(state_abbr, state_fips) %>%
  distinct()

# Add all FIPS codes
all_fips <- tribble(
  ~state_abbr, ~state_fips,
  "AL", 1, "AK", 2, "AZ", 4, "AR", 5, "CA", 6, "CO", 8, "CT", 9,
  "DE", 10, "DC", 11, "FL", 12, "GA", 13, "HI", 15, "ID", 16, "IL", 17,
  "IN", 18, "IA", 19, "KS", 20, "KY", 21, "LA", 22, "ME", 23, "MD", 24,
  "MA", 25, "MI", 26, "MN", 27, "MS", 28, "MO", 29, "MT", 30, "NE", 31,
  "NV", 32, "NH", 33, "NJ", 34, "NM", 35, "NY", 36, "NC", 37, "ND", 38,
  "OH", 39, "OK", 40, "OR", 41, "PA", 42, "RI", 44, "SC", 45, "SD", 46,
  "TN", 47, "TX", 48, "UT", 49, "VT", 50, "VA", 51, "WA", 53, "WV", 54,
  "WI", 55, "WY", 56
)

# Create treatment indicator
# first_treat = year of ban adoption (0 if never treated, per `did` package convention)
treatment_key <- ban_dates %>%
  select(state_fips, ban_year, ban_month) %>%
  rename(first_treat = ban_year)

df <- df %>%
  left_join(treatment_key, by = "state_fips") %>%
  mutate(
    first_treat = replace_na(first_treat, 0),  # 0 = never treated
    ban_month = replace_na(ban_month, 0),
    # Treatment indicator using interview month for precision
    treated = case_when(
      first_treat == 0 ~ 0L,
      year > first_treat ~ 1L,
      year == first_treat & !is.na(month) & month >= ban_month ~ 1L,
      year == first_treat & is.na(month) ~ NA_integer_,  # Ambiguous
      TRUE ~ 0L
    )
  ) %>%
  left_join(all_fips, by = "state_fips")

# ============================================================================
# 5. Merge Medicaid expansion
# ============================================================================

medicaid <- readRDS(file.path(data_dir, "medicaid_expansion.rds"))

df <- df %>%
  left_join(medicaid, by = "state_abbr") %>%
  mutate(
    medicaid_expanded = case_when(
      !is.na(expansion_year) & year >= expansion_year ~ 1L,
      TRUE ~ 0L
    )
  )

# ============================================================================
# 6. Merge Census regions
# ============================================================================

regions <- readRDS(file.path(data_dir, "census_regions.rds"))
df <- df %>% left_join(regions, by = "state_abbr")

# ============================================================================
# 7. Create state-year aggregates for DiD
# ============================================================================

cat("Creating state-year panel...\n")

# State-year aggregates (weighted)
state_year <- df %>%
  filter(!is.na(current_smoker)) %>%
  group_by(state_fips, state_abbr, year, first_treat, region, medicaid_expanded) %>%
  summarise(
    smoking_rate = weighted.mean(current_smoker, wt, na.rm = TRUE),
    everyday_rate = weighted.mean(everyday_smoker, wt, na.rm = TRUE),
    n_obs = n(),
    n_smokers = sum(current_smoker * wt, na.rm = TRUE),
    n_total = sum(wt, na.rm = TRUE),
    pct_female = weighted.mean(female, wt, na.rm = TRUE),
    pct_college = weighted.mean(college, wt, na.rm = TRUE),
    pct_high_income = weighted.mean(high_income, wt, na.rm = TRUE),
    .groups = "drop"
  )

# Quit attempt rate (among ever-smokers only)
quit_panel <- df %>%
  filter(ever_smoker == 1, !is.na(quit_attempt_clean)) %>%
  group_by(state_fips, state_abbr, year, first_treat, region) %>%
  summarise(
    quit_rate = weighted.mean(quit_attempt_clean, wt, na.rm = TRUE),
    n_smokers_quit = n(),
    .groups = "drop"
  )

state_year <- state_year %>%
  left_join(quit_panel, by = c("state_fips", "state_abbr", "year",
                                "first_treat", "region"))

# ============================================================================
# 8. Summary statistics
# ============================================================================

cat("\n=== Summary Statistics ===\n")
cat(sprintf("State-year panel: %d obs (%d states × %d years)\n",
            nrow(state_year), n_distinct(state_year$state_fips),
            n_distinct(state_year$year)))
cat(sprintf("Treated states: %d\n",
            as.integer(n_distinct(state_year$state_fips[state_year$first_treat > 0]))))
cat(sprintf("Never-treated states: %d\n",
            as.integer(n_distinct(state_year$state_fips[state_year$first_treat == 0]))))
cat(sprintf("Year range: %d - %d\n", min(state_year$year), max(state_year$year)))
cat(sprintf("Avg smoking rate: %.1f%%\n", mean(state_year$smoking_rate) * 100))
cat(sprintf("Avg quit attempt rate: %.1f%%\n",
            mean(state_year$quit_rate, na.rm = TRUE) * 100))

# ============================================================================
# 9. Save analysis datasets
# ============================================================================

saveRDS(df, file.path(data_dir, "brfss_individual.rds"))
saveRDS(state_year, file.path(data_dir, "state_year_panel.rds"))

cat("\n=== Datasets saved ===\n")
cat(sprintf("  Individual-level: %s (%d obs)\n",
            file.path(data_dir, "brfss_individual.rds"), nrow(df)))
cat(sprintf("  State-year panel: %s (%d obs)\n",
            file.path(data_dir, "state_year_panel.rds"), nrow(state_year)))
