# =============================================================================
# 02_clean_data.R - Data Cleaning and Variable Construction
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

source("00_packages.R")

data_dir <- "../data"

# Load raw data
cat("Loading raw CPS data...\n")
cps_raw <- readRDS(file.path(data_dir, "cps_voting_raw.rds"))
state_panel <- readRDS(file.path(data_dir, "state_treatment_panel.rds"))
voting_laws <- readRDS(file.path(data_dir, "concurrent_voting_laws.rds"))
state_xwalk <- readRDS(file.path(data_dir, "state_crosswalk.rds"))
reforms <- readRDS(file.path(data_dir, "reform_timing.rds"))

cat(sprintf("Raw CPS: %d observations across years %s\n",
            nrow(cps_raw), paste(sort(unique(cps_raw$year)), collapse = ", ")))

# =============================================================================
# 1. CLEAN CPS MICRODATA
# =============================================================================

# The CPS voting supplement uses different coding schemes across years.
# Census API variables:
#   PES1 (voted): 1 = Yes, 2 = No, -1/-2/-3/-9 = Missing/NA
#   PES2 (registered): 1 = Yes, 2 = No
#   PTDTRACE/PRDTRACE (race): 1=White, 2=Black, 3=AIAN, 4=Asian, etc.
#   PEHSPNON (Hispanic): 1=Hispanic, 2=Non-Hispanic
#   PESEX: 1=Male, 2=Female
#   PRCITSHP (citizenship): 1-4=Citizen, 5=Not citizen
#   PEEDUCA (education): 31-46 scale (31=less than 1st grade ... 46=doctorate)
#
# IPUMS CPS (if used):
#   VOTED: 1=Did not vote, 2=Voted, 96-99=NIU/Missing
#   VOREG: 1=Not registered, 2=Registered
#   RACE: 100=White, 200=Black, etc.
#   HISPAN: 0=Not Hispanic, 100-412=Hispanic origin codes
#   SEX: 1=Male, 2=Female
#   CITIZEN: 1-4=Various citizen types, 5=Not citizen
#   EDUC: Various codes

# Detect data source (Census API vs IPUMS)
is_ipums <- any(cps_raw$race > 50, na.rm = TRUE)  # IPUMS race codes are 100+

cat(sprintf("Data source detected: %s\n", ifelse(is_ipums, "IPUMS CPS", "Census API")))

if (is_ipums) {
  # IPUMS coding
  cps_clean <- cps_raw %>%
    filter(!is.na(weight), weight > 0) %>%
    mutate(
      # Voting (IPUMS: 2 = Voted)
      voted_binary = if_else(voted == 2, 1L, 0L),
      # Registration (IPUMS: 2 = Registered)
      reg_binary = if_else(!is.na(registered) & registered == 2, 1L, 0L),
      # Race (IPUMS: 100=White, 200=Black, 300=AIAN, 651=Asian)
      race_cat = case_when(
        race == 100 & (is.na(hispan) | hispan == 0) ~ "white_nh",
        race == 200 & (is.na(hispan) | hispan == 0) ~ "black_nh",
        hispan > 0 & !is.na(hispan) ~ "hispanic",
        TRUE ~ "other"
      ),
      # Citizenship (IPUMS: 1-4 = citizen)
      is_citizen = citizen %in% 1:4,
      # Sex
      female = sex == 2,
      # Age groups
      age_group = case_when(
        age >= 18 & age <= 24 ~ "18-24",
        age >= 25 & age <= 44 ~ "25-44",
        age >= 45 & age <= 64 ~ "45-64",
        age >= 65 ~ "65+",
        TRUE ~ NA_character_
      ),
      # Education (IPUMS EDUC: roughly <73 = no college, >=100 = BA+)
      college = educ >= 100
    )
} else {
  # Census API coding
  # Race: 1=White, 2=Black (consistent across all years)
  # Voted: 1=Yes, 2=No, negative=missing
  # Hispanic: 1=Hispanic, 2=Non-Hispanic (2004+ only; NA for 1996-2002)
  # Citizenship: 1-4=citizen, 5=not citizen
  # Education: PEEDUCA scale (39=HS diploma, 43=BA)
  cps_clean <- cps_raw %>%
    filter(!is.na(weight), weight > 0) %>%
    # Remove observations with missing/invalid voted responses
    filter(voted > 0) %>%
    mutate(
      # Voting (Census: 1 = Yes, 2 = No)
      voted_binary = if_else(voted == 1, 1L, 0L),
      # Registration (1 = Yes, 2 = No; handle negatives)
      reg_binary = if_else(!is.na(registered) & registered == 1, 1L, 0L),
      # Race categories
      # For 1996-2002: no Hispanic variable, so White/Black include Hispanics
      # For 2004+: use PEHSPNON to separate non-Hispanic
      # We accept this minor inconsistency (Black-Hispanic share is <3%)
      race_cat = case_when(
        race == 1 & (is.na(hispan) | hispan == 2) ~ "white_nh",
        race == 2 & (is.na(hispan) | hispan == 2) ~ "black_nh",
        (!is.na(hispan) & hispan == 1) ~ "hispanic",
        TRUE ~ "other"
      ),
      # Citizenship (Census PRCITSHP: 1-4 = citizen, 5 = not citizen)
      is_citizen = is.na(citizen) | citizen %in% 1:4,
      # Sex
      female = sex == 2,
      # Age groups
      age_group = case_when(
        age >= 18 & age <= 24 ~ "18-24",
        age >= 25 & age <= 44 ~ "25-44",
        age >= 45 & age <= 64 ~ "45-64",
        age >= 65 ~ "65+",
        TRUE ~ NA_character_
      ),
      # Education (Census PEEDUCA: 39=HS diploma, 40=Some college, 43=BA, ...)
      college = if_else(!is.na(educ), educ >= 43, NA)
    )
}

# Filter to citizens aged 18+ with valid state FIPS
cps_clean <- cps_clean %>%
  filter(
    is_citizen,
    age >= 18,
    !is.na(age_group),
    state_fips %in% state_xwalk$state_fips,
    race_cat %in% c("white_nh", "black_nh", "hispanic")
  ) %>%
  # Remove invalid voted/registered
  filter(!is.na(voted_binary))

cat(sprintf("After cleaning: %d citizen observations 18+\n", nrow(cps_clean)))

# =============================================================================
# 2. CONSTRUCT DDD SUBGROUPS
# =============================================================================

# Low-felony-risk subgroup (spillover proxy):
#   Black women 50+ OR Black citizens with college degree
# High-felony-risk subgroup (directly affected):
#   Black men 25-44 without college degree

cps_clean <- cps_clean %>%
  mutate(
    # DDD risk category (within Black population)
    felony_risk = case_when(
      race_cat != "black_nh" ~ "not_black",
      # Low risk: women 50+ or college educated
      (female & age >= 50) | (!is.na(college) & college) ~ "low_risk",
      # High risk: men 25-44 without college
      (!female & age >= 25 & age <= 44 & (is.na(college) | !college)) ~ "high_risk",
      TRUE ~ "medium_risk"
    )
  )

cat("DDD subgroup distribution:\n")
print(table(cps_clean$felony_risk, cps_clean$race_cat))

# =============================================================================
# 3. MERGE WITH TREATMENT TIMING AND VOTING LAWS
# =============================================================================

cps_merged <- cps_clean %>%
  left_join(
    state_panel %>% select(state_fips, year, post_reform, state_group, treat_cohort),
    by = c("state_fips", "year")
  ) %>%
  left_join(voting_laws, by = c("state_fips", "year")) %>%
  left_join(state_xwalk, by = "state_fips")

# Fill NAs for states not in panel (shouldn't happen, but safe)
cps_merged <- cps_merged %>%
  mutate(
    post_reform = replace_na(post_reform, 0L),
    state_group = replace_na(state_group, "control"),
    treat_cohort = replace_na(treat_cohort, 0L),
    has_strict_voter_id = replace_na(has_strict_voter_id, 0L),
    has_same_day_reg = replace_na(has_same_day_reg, 0L),
    has_auto_voter_reg = replace_na(has_auto_voter_reg, 0L)
  )

# Key interaction terms for DD
cps_merged <- cps_merged %>%
  mutate(
    black = if_else(race_cat == "black_nh", 1L, 0L),
    white = if_else(race_cat == "white_nh", 1L, 0L),
    hispanic = if_else(race_cat == "hispanic", 1L, 0L),
    black_reform = black * post_reform,
    # State-year identifier for FE
    state_year = paste0(state_fips, "_", year)
  )

cat(sprintf("Merged dataset: %d observations\n", nrow(cps_merged)))

# Save cleaned microdata
saveRDS(cps_merged, file.path(data_dir, "cps_clean_micro.rds"))

# =============================================================================
# 4. COLLAPSE TO STATE × RACE × YEAR CELLS
# =============================================================================

# Main analysis panel: weighted means by state × race × year
cell_data <- cps_merged %>%
  filter(race_cat %in% c("black_nh", "white_nh")) %>%
  group_by(state_fips, state_abbr, state_name, year, race_cat,
           post_reform, state_group, treat_cohort) %>%
  summarise(
    turnout = weighted.mean(voted_binary, weight, na.rm = TRUE),
    registered = weighted.mean(reg_binary, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    black = if_else(race_cat == "black_nh", 1L, 0L),
    black_reform = black * post_reform
  )

cat(sprintf("Cell-level panel: %d state-race-year cells\n", nrow(cell_data)))
cat(sprintf("  Black cells: %d\n", sum(cell_data$black == 1)))
cat(sprintf("  White cells: %d\n", sum(cell_data$black == 0)))

# Save cell data
saveRDS(cell_data, file.path(data_dir, "analysis_cells.rds"))

# =============================================================================
# 5. DDD PANEL (by felony-risk subgroup)
# =============================================================================

# Collapse by state × race × risk_group × year
ddd_data <- cps_merged %>%
  filter(race_cat %in% c("black_nh", "white_nh"),
         felony_risk %in% c("low_risk", "high_risk", "not_black")) %>%
  mutate(
    # For white respondents, create parallel "risk" categories based on same demographics
    risk_label = case_when(
      race_cat == "white_nh" & ((female & age >= 50) | (!is.na(college) & college)) ~ "low_risk_white",
      race_cat == "white_nh" & (!female & age >= 25 & age <= 44 & (is.na(college) | !college)) ~ "high_risk_white",
      race_cat == "white_nh" ~ "other_white",
      felony_risk == "low_risk" ~ "low_risk_black",
      felony_risk == "high_risk" ~ "high_risk_black",
      TRUE ~ "other_black"
    )
  ) %>%
  filter(risk_label %in% c("low_risk_black", "high_risk_black",
                            "low_risk_white", "high_risk_white")) %>%
  group_by(state_fips, state_abbr, year, risk_label,
           post_reform, state_group, treat_cohort) %>%
  summarise(
    turnout = weighted.mean(voted_binary, weight, na.rm = TRUE),
    registered = weighted.mean(reg_binary, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    black = if_else(grepl("black", risk_label), 1L, 0L),
    low_risk = if_else(grepl("low_risk", risk_label), 1L, 0L),
    black_reform = black * post_reform,
    low_risk_reform = low_risk * post_reform,
    black_low_risk = black * low_risk,
    triple = black * low_risk * post_reform
  )

cat(sprintf("DDD panel: %d state-risk-year cells\n", nrow(ddd_data)))
saveRDS(ddd_data, file.path(data_dir, "ddd_panel.rds"))

# =============================================================================
# 6. HISPANIC PLACEBO PANEL
# =============================================================================

placebo_data <- cps_merged %>%
  filter(race_cat %in% c("hispanic", "white_nh")) %>%
  group_by(state_fips, state_abbr, year, race_cat,
           post_reform, state_group, treat_cohort) %>%
  summarise(
    turnout = weighted.mean(voted_binary, weight, na.rm = TRUE),
    registered = weighted.mean(reg_binary, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    hispanic_ind = if_else(race_cat == "hispanic", 1L, 0L),
    hispanic_reform = hispanic_ind * post_reform
  )

saveRDS(placebo_data, file.path(data_dir, "placebo_hispanic.rds"))
cat(sprintf("Hispanic placebo panel: %d cells\n", nrow(placebo_data)))

# =============================================================================
# 7. SUMMARY OF DATA COVERAGE
# =============================================================================

cat("\n=== Data Coverage Summary ===\n")
cat(sprintf("Years covered: %s\n", paste(sort(unique(cps_merged$year)), collapse = ", ")))
cat(sprintf("States: %d\n", n_distinct(cps_merged$state_fips)))
cat(sprintf("Total citizen observations 18+: %d\n", nrow(cps_merged)))

# Coverage by race
race_counts <- cps_merged %>%
  group_by(race_cat) %>%
  summarise(n = n(), .groups = "drop")
cat("\nBy race:\n")
print(race_counts)

# Coverage by treatment group
cat("\nBy treatment group:\n")
group_counts <- cps_merged %>%
  group_by(state_group) %>%
  summarise(n_states = n_distinct(state_fips), n_obs = n(), .groups = "drop")
print(group_counts)

# Minimum cell size check
min_cells <- cell_data %>%
  group_by(race_cat) %>%
  summarise(min_n = min(n_obs), median_n = median(n_obs), .groups = "drop")
cat("\nMinimum cell sizes:\n")
print(min_cells)

cat("\n=== Data Cleaning Complete ===\n")
