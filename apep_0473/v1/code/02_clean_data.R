###############################################################################
# 02_clean_data.R — Clean data and construct analysis panel
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

###############################################################################
# 1. Parse UC rollout dates
###############################################################################

cat("=== Parsing UC rollout dates ===\n")

uc_raw <- read_csv(file.path(DATA_DIR, "uc_rollout_2018_raw.csv"), show_col_types = FALSE)

# Map table_id to approximate rollout year
# Based on DWP phase documentation (NAO 2018):
# Tables 1-2: Phase 1-2 (2016)
# Tables 3-6: Phase 3-4 (2017)
# Tables 7-30: Phase 5-8 (2018)
rollout_year_map <- tibble(
  table_id = 1:30,
  rollout_year = c(2016, 2016, 2016, 2017, 2017, 2017, 2017, 2018,
                   rep(2018, 22))
)

uc_dates <- uc_raw %>%
  left_join(rollout_year_map, by = "table_id") %>%
  rename(la_name_uc = `Local authority`) %>%
  select(la_name_uc, rollout_year) %>%
  # Clean LA names
  mutate(la_name_clean = la_name_uc %>%
           str_to_lower() %>%
           str_replace_all("\\s+", " ") %>%
           str_trim() %>%
           str_replace("^london borough of ", "") %>%
           str_replace(" borough council$| city council$| district council$| county council$| county borough council$| metropolitan borough council$| council$| metropolitan council$", "") %>%
           str_replace(" borough$| city$| district$| county$", "") %>%
           str_trim())

# Keep earliest rollout date per LA
uc_dates <- uc_dates %>%
  group_by(la_name_clean) %>%
  slice_min(rollout_year, n = 1, with_ties = FALSE) %>%
  ungroup()

cat("Unique LAs with rollout dates:", nrow(uc_dates), "\n")
cat("By year:\n")
print(uc_dates %>% count(rollout_year))

###############################################################################
# 2. Clean APS data — self-employment share
###############################################################################

cat("\n=== Cleaning APS self-employment share ===\n")

aps_share <- read_csv(file.path(DATA_DIR, "aps_se_share_raw.csv"),
                      show_col_types = FALSE)

# Filter: Apr-Mar periods only (non-overlapping annual data)
# Deduplicate
aps_clean <- aps_share %>%
  filter(grepl("^Apr", DATE_NAME), !is.na(OBS_VALUE)) %>%
  distinct(GEOGRAPHY_CODE, DATE_NAME, .keep_all = TRUE) %>%
  mutate(
    year = as.integer(str_extract(DATE_NAME, "\\d{4}")),
    la_code = GEOGRAPHY_CODE,
    la_name = GEOGRAPHY_NAME,
    se_share = OBS_VALUE
  ) %>%
  select(la_code, la_name, year, se_share)

cat("Self-emp share:", nrow(aps_clean), "obs,",
    n_distinct(aps_clean$la_code), "LAs,",
    "years", paste(range(aps_clean$year), collapse = "-"), "\n")

###############################################################################
# 3. Clean APS employment rate
###############################################################################

cat("\n=== Cleaning APS employment rate ===\n")

aps_emp <- read_csv(file.path(DATA_DIR, "aps_employment_rate_raw.csv"),
                    show_col_types = FALSE)

emp_clean <- aps_emp %>%
  filter(grepl("^Apr", DATE_NAME), !is.na(OBS_VALUE),
         VARIABLE_CODE == 45) %>%
  distinct(GEOGRAPHY_CODE, DATE_NAME, .keep_all = TRUE) %>%
  mutate(
    year = as.integer(str_extract(DATE_NAME, "\\d{4}")),
    la_code = GEOGRAPHY_CODE,
    emp_rate = OBS_VALUE
  ) %>%
  select(la_code, year, emp_rate)

cat("Employment rate:", nrow(emp_clean), "obs\n")

###############################################################################
# 4. Clean APS economic activity rate
###############################################################################

cat("\n=== Cleaning APS economic activity rate ===\n")

aps_econ_active <- read_csv(file.path(DATA_DIR, "aps_econ_activity_raw.csv"),
                            show_col_types = FALSE)

econ_active_clean <- aps_econ_active %>%
  filter(grepl("^Apr", DATE_NAME), !is.na(OBS_VALUE),
         VARIABLE_CODE == 18) %>%
  distinct(GEOGRAPHY_CODE, DATE_NAME, .keep_all = TRUE) %>%
  mutate(
    year = as.integer(str_extract(DATE_NAME, "\\d{4}")),
    la_code = GEOGRAPHY_CODE,
    econ_active_rate = OBS_VALUE
  ) %>%
  select(la_code, year, econ_active_rate)

cat("Economic activity rate:", nrow(econ_active_clean), "obs\n")

###############################################################################
# 5. Merge APS variables
###############################################################################

cat("\n=== Merging APS variables ===\n")

panel <- aps_clean %>%
  left_join(emp_clean, by = c("la_code", "year")) %>%
  left_join(econ_active_clean, by = c("la_code", "year"))

cat("Panel:", nrow(panel), "obs,", n_distinct(panel$la_code), "LAs\n")

###############################################################################
# 6. Match UC rollout to LAs
###############################################################################

cat("\n=== Matching UC rollout dates ===\n")

# Clean panel LA names
panel <- panel %>%
  mutate(la_name_clean = la_name %>%
           str_to_lower() %>%
           str_replace_all("\\s+", " ") %>%
           str_trim() %>%
           str_replace("^london borough of ", "") %>%
           str_replace(", county of$|, city of$", "") %>%
           str_replace(" borough$| city$| district$| county$", "") %>%
           str_trim())

# Join
panel <- panel %>%
  left_join(uc_dates %>% select(la_name_clean, rollout_year),
            by = "la_name_clean")

matched <- sum(!is.na(panel$rollout_year))
unmatched <- sum(is.na(panel$rollout_year))
cat("Matched:", matched, "obs, Unmatched:", unmatched, "obs\n")

# For unmatched LAs, try fuzzy matching
if (unmatched > 0) {
  unmatched_las <- panel %>%
    filter(is.na(rollout_year)) %>%
    distinct(la_name, la_name_clean)

  cat("Unmatched LAs:", nrow(unmatched_las), "\n")
  cat("Sample:\n")
  print(head(unmatched_las, 10))

  uc_names <- uc_dates %>% distinct(la_name_clean, rollout_year)

  fuzzy_matches <- tibble()
  for (i in 1:nrow(unmatched_las)) {
    ula <- unmatched_las$la_name_clean[i]
    distances <- adist(ula, uc_names$la_name_clean)
    best_idx <- which.min(distances)
    best_dist <- min(distances)
    if (best_dist <= 10) {
      fuzzy_matches <- bind_rows(fuzzy_matches, tibble(
        la_name_clean = ula,
        rollout_year_fuzzy = uc_names$rollout_year[best_idx],
        match_name = uc_names$la_name_clean[best_idx],
        dist = best_dist
      ))
    }
  }

  if (nrow(fuzzy_matches) > 0) {
    cat("Fuzzy matches:", nrow(fuzzy_matches), "\n")
    print(fuzzy_matches %>% select(la_name_clean, match_name, dist) %>% head(15))

    panel <- panel %>%
      left_join(fuzzy_matches %>% select(la_name_clean, rollout_year_fuzzy),
                by = "la_name_clean") %>%
      mutate(rollout_year = coalesce(rollout_year, rollout_year_fuzzy)) %>%
      select(-rollout_year_fuzzy)
  }
}

# Remaining unmatched LAs become "never-treated" (first_treat = 0)
still_unmatched <- panel %>%
  filter(is.na(rollout_year)) %>%
  distinct(la_name)
cat("Still unmatched:", nrow(still_unmatched), "LAs\n")
if (nrow(still_unmatched) > 0) print(still_unmatched)

###############################################################################
# 7. Construct final panel
###############################################################################

cat("\n=== Constructing final panel ===\n")

panel_final <- panel %>%
  filter(year >= 2010, year <= 2019) %>%
  mutate(
    first_treat = if_else(is.na(rollout_year), 0L, as.integer(rollout_year)),
    treated = if_else(!is.na(rollout_year) & year >= rollout_year, 1L, 0L),
    la_id = as.integer(factor(la_code))
  )

cat("Final panel:", nrow(panel_final), "obs\n")
cat("LAs:", n_distinct(panel_final$la_code), "\n")
cat("Years:", paste(range(panel_final$year), collapse = "-"), "\n")

cat("\nTreatment cohort distribution:\n")
print(panel_final %>% distinct(la_code, first_treat) %>% count(first_treat))

cat("\nOutcome summary:\n")
panel_final %>%
  select(se_share, emp_rate, econ_active_rate) %>%
  summary() %>%
  print()

cat("\nPre/Post means (treated LAs):\n")
panel_final %>%
  filter(first_treat > 0) %>%
  mutate(post = if_else(year >= first_treat, "Post", "Pre")) %>%
  group_by(post) %>%
  summarise(
    se_share = mean(se_share, na.rm = TRUE),
    emp_rate = mean(emp_rate, na.rm = TRUE),
    econ_active_rate = mean(econ_active_rate, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  print()

###############################################################################
# 8. Save
###############################################################################

write_csv(panel_final, file.path(DATA_DIR, "analysis_panel.csv"))
cat("\nSaved:", file.path(DATA_DIR, "analysis_panel.csv"), "\n")
cat("Rows:", nrow(panel_final), "\n")

write_csv(uc_dates, file.path(DATA_DIR, "uc_rollout_dates.csv"))
