##############################################################################
# 02_clean_data.R — Construct treatment variables and analysis dataset
# APEP-0221: Educational Content Restriction Laws and Teacher Labor Markets
##############################################################################

source("00_packages.R")

cat("=== Constructing analysis dataset ===\n")

# Load raw QWI data
qwi_raw <- readRDS("../data/qwi_raw.rds")

# ============================================================================
# TREATMENT CODING: Educational Content Restriction Laws
# ============================================================================
# Sources: PEN America Index of Educational Gag Orders, Heritage Foundation,
#          UCLA CRT Forward Tracking Project, Chalkbeat CRT Map
#
# Inclusion criteria: State-level law or binding executive order that restricts
# K-12 instruction on race, gender, or "divisive concepts." Must be enacted
# (signed by governor or issued as executive order), not just introduced.
#
# Treatment timing: Quarter in which the law becomes effective.
# ============================================================================

treatment_laws <- tribble(
  ~state_fips, ~state_name,    ~bill,           ~signed_date,   ~effective_date, ~stringency,
  "16",        "Idaho",        "HB 377",        "2021-04-28",   "2021-07-01",    "strong",
  "40",        "Oklahoma",     "HB 1775",       "2021-05-07",   "2021-07-01",    "strong",
  "47",        "Tennessee",    "SB 623/HB 580", "2021-05-25",   "2021-07-01",    "strong",
  "19",        "Iowa",         "HF 802",        "2021-06-08",   "2021-07-01",    "strong",
  "48",        "Texas",        "HB 3979",       "2021-06-15",   "2021-09-01",    "moderate",
  "45",        "South Carolina","Budget Proviso","2021-06-29",  "2021-07-01",    "weak",
  "33",        "New Hampshire","HB 2",          "2021-06-25",   "2021-11-01",    "strong",
  "04",        "Arizona",      "HB 2906",       "2021-07-09",   "2021-09-29",    "moderate",
  "38",        "North Dakota", "HB 1508",       "2021-04-19",   "2021-08-01",    "moderate",
  "12",        "Florida",      "HB 7 (STOP WOKE)","2022-03-22","2022-07-01",    "strong",
  "13",        "Georgia",      "HB 1084",       "2022-04-28",   "2022-07-01",    "moderate",
  "28",        "Mississippi",  "SB 2113",       "2022-03-14",   "2022-07-01",    "moderate",
  "01",        "Alabama",      "HB 312",        "2022-04-14",   "2022-07-01",    "moderate",
  "46",        "South Dakota", "EO 2022-02",    "2022-04-05",   "2022-04-05",    "weak",
  "51",        "Virginia",     "EO 1",          "2022-01-15",   "2022-01-15",    "weak",
  "49",        "Utah",         "HB 427",        "2022-03-23",   "2022-05-04",    "moderate",
  "22",        "Louisiana",    "HB 122",        "2022-06-15",   "2022-08-01",    "moderate",
  "54",        "West Virginia","HB 2595",       "2022-03-10",   "2022-06-07",    "moderate",
  "05",        "Arkansas",     "SB 294/EO",     "2023-03-08",   "2023-08-01",    "strong",
  "18",        "Indiana",      "HB 1608",       "2023-05-01",   "2023-07-01",    "moderate",
  "21",        "Kentucky",     "SB 150",        "2023-03-29",   "2023-06-29",    "moderate",
  "30",        "Montana",      "HB 30",         "2023-02-17",   "2023-07-01",    "weak",
  "37",        "North Carolina","HB 823",       "2023-10-11",   "2023-10-11",    "moderate"
)

# Convert dates and compute treatment quarter
treatment_laws <- treatment_laws %>%
  mutate(
    effective_date = as.Date(effective_date),
    treat_year = year(effective_date),
    treat_quarter = quarter(effective_date),
    # First full quarter after effective date
    first_full_q_year = ifelse(
      day(effective_date) <= 15 & month(effective_date) %in% c(1, 4, 7, 10),
      treat_year,
      ifelse(treat_quarter == 4, treat_year + 1, treat_year)
    ),
    first_full_q = ifelse(
      day(effective_date) <= 15 & month(effective_date) %in% c(1, 4, 7, 10),
      treat_quarter,
      ifelse(treat_quarter == 4, 1, treat_quarter + 1)
    ),
    # Treatment cohort as year-quarter numeric
    treat_yq = first_full_q_year + (first_full_q - 1) / 4,
    # Cohort label
    cohort_label = paste0(first_full_q_year, "Q", first_full_q),
    # Stringency score: strong=3, moderate=2, weak=1
    stringency_score = case_when(
      stringency == "strong" ~ 3L,
      stringency == "moderate" ~ 2L,
      stringency == "weak" ~ 1L
    )
  )

cat(sprintf("Treatment database: %d states\n", nrow(treatment_laws)))
cat("Treatment cohorts:\n")
print(table(treatment_laws$cohort_label))

# Save treatment data
saveRDS(treatment_laws, "../data/treatment_laws.rds")
write_csv(treatment_laws, "../data/treatment_laws.csv")

# ============================================================================
# MERGE TREATMENT WITH QWI DATA
# ============================================================================

# Create panel dataset
panel <- qwi_raw %>%
  left_join(
    treatment_laws %>% select(state_fips, treat_yq, stringency, stringency_score,
                               cohort_label, first_full_q_year, first_full_q),
    by = "state_fips"
  ) %>%
  mutate(
    # Treatment indicators
    treated_state = !is.na(treat_yq),
    post = ifelse(treated_state, time_q >= treat_yq, FALSE),
    treat = as.integer(treated_state & post),
    # For CS estimator: first_treat = 0 for never-treated
    first_treat_q = ifelse(treated_state, treat_yq, 0),
    # Time index for CS (needs integer): convert year-quarter to sequential integer
    time_int = (year - 2015) * 4 + quarter,
    first_treat_int = ifelse(treated_state, (first_full_q_year - 2015) * 4 + first_full_q, 0),
    # Outcome variables
    log_emp = log(Emp + 1),
    sep_rate = Sep / (Emp + 1),
    hire_rate = HirA / (Emp + 1),
    log_earn = log(EarnS + 1),
    # State numeric ID for CS
    state_id = as.integer(factor(state_fips))
  )

cat(sprintf("\nPanel dataset: %d observations\n", nrow(panel)))
cat(sprintf("States: %d total, %d treated, %d never-treated\n",
            n_distinct(panel$state_fips),
            n_distinct(panel$state_fips[panel$treated_state]),
            n_distinct(panel$state_fips[!panel$treated_state])))
cat(sprintf("Time periods: %d quarters (%d-%d)\n",
            n_distinct(panel$time_int),
            min(panel$year), max(panel$year)))

# ============================================================================
# CREATE EDUCATION-SPECIFIC AND TRIPLE-DIFF DATASETS
# ============================================================================

# Education sector only
edu_panel <- panel %>% filter(industry == "61")

# Healthcare sector only
hc_panel <- panel %>% filter(industry == "62")

# Triple-diff: Education vs Healthcare
triple_diff <- panel %>%
  filter(industry %in% c("61", "62")) %>%
  mutate(
    is_education = as.integer(industry == "61"),
    DDD = treat * is_education
  )

# Compute education-healthcare gap by state-quarter
edu_hc_gap <- panel %>%
  filter(industry %in% c("61", "62")) %>%
  select(state_fips, year, quarter, time_q, time_int, industry, Emp, EarnS, Sep, HirA, TurnOvrS,
         treated_state, post, treat, first_treat_int, stringency, stringency_score, state_id) %>%
  pivot_wider(
    names_from = industry,
    values_from = c(Emp, EarnS, Sep, HirA, TurnOvrS),
    names_sep = "_"
  ) %>%
  mutate(
    # Gap variables: Education minus Healthcare (relative)
    emp_gap = log(Emp_61 + 1) - log(Emp_62 + 1),
    earn_gap = log(EarnS_61 + 1) - log(EarnS_62 + 1),
    sep_gap = Sep_61 / (Emp_61 + 1) - Sep_62 / (Emp_62 + 1),
    hire_gap = HirA_61 / (Emp_61 + 1) - HirA_62 / (Emp_62 + 1)
  )

cat(sprintf("\nEducation panel: %d obs\n", nrow(edu_panel)))
cat(sprintf("Healthcare panel: %d obs\n", nrow(hc_panel)))
cat(sprintf("Triple-diff panel: %d obs\n", nrow(triple_diff)))
cat(sprintf("Edu-HC gap panel: %d obs\n", nrow(edu_hc_gap)))

# ============================================================================
# SUMMARY STATISTICS
# ============================================================================

# Pre-treatment summary by treated/control
pre_stats <- edu_panel %>%
  filter(year <= 2020) %>%
  group_by(treated_state) %>%
  summarise(
    n_states = n_distinct(state_fips),
    mean_emp = mean(Emp, na.rm = TRUE),
    sd_emp = sd(Emp, na.rm = TRUE),
    mean_earn = mean(EarnS, na.rm = TRUE),
    mean_sep_rate = mean(Sep / (Emp + 1), na.rm = TRUE),
    mean_hire_rate = mean(HirA / (Emp + 1), na.rm = TRUE),
    mean_turnover = mean(TurnOvrS, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nPre-treatment summary (Education sector):\n")
print(pre_stats)

# Save all datasets
saveRDS(panel, "../data/panel.rds")
saveRDS(edu_panel, "../data/edu_panel.rds")
saveRDS(hc_panel, "../data/hc_panel.rds")
saveRDS(triple_diff, "../data/triple_diff.rds")
saveRDS(edu_hc_gap, "../data/edu_hc_gap.rds")

cat("\n=== Data cleaning complete ===\n")
