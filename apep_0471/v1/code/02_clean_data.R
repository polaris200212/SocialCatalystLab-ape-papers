## 02_clean_data.R — Build LA × month panel for apep_0471
## Merges Companies House formations, UC rollout dates, NOMIS outcomes

source("00_packages.R")

data_dir <- "../data"

cat("=== Loading data ===\n")

# 1. Companies House formations
ch <- read_parquet(file.path(data_dir, "ch_formations_2013_2019.parquet"))
cat(sprintf("Companies House formations: %s\n", comma(nrow(ch))))

# 2. Postcode lookup
pc_lookup <- read_csv(file.path(data_dir, "nspl_lookup.csv"), show_col_types = FALSE)
cat(sprintf("Postcode lookups: %s\n", comma(nrow(pc_lookup))))

# 3. UC rollout dates
uc_dates <- read_csv(file.path(data_dir, "uc_rollout_dates.csv"), show_col_types = FALSE) %>%
  mutate(first_treat_date = ym(first_treat_month))
cat(sprintf("UC rollout LAs: %d\n", nrow(uc_dates)))

# 4. Population
pop <- read_csv(file.path(data_dir, "population_la.csv"), show_col_types = FALSE)

# 5. NOMIS APS
nomis <- read_csv(file.path(data_dir, "nomis_aps_raw.csv"), show_col_types = FALSE)

cat("\n=== Step 1: Merge Companies House with LA codes ===\n")

# Join CH formations to LA codes via postcode
ch_geo <- ch %>%
  left_join(pc_lookup %>% select(postcode, la_code),
            by = "postcode")

match_rate <- mean(!is.na(ch_geo$la_code))
cat(sprintf("Postcode → LA match rate: %.1f%%\n", match_rate * 100))

# Filter to England, Wales, Scotland (exclude NI - different benefit system)
# NI LA codes start with "N", Scotland with "S", Wales with "W", England with "E"
ch_geo <- ch_geo %>%
  filter(!is.na(la_code), str_detect(la_code, "^[ESW]"))

cat(sprintf("Formations in GB (excl NI): %s\n", comma(nrow(ch_geo))))

cat("\n=== Step 2: Aggregate to LA × month ===\n")

# Monthly formation counts by LA
la_month <- ch_geo %>%
  group_by(la_code, inc_ym) %>%
  summarise(
    n_formations = n(),
    n_private_ltd = sum(CompanyCategory == "Private Limited Company", na.rm = TRUE),
    # Sectors with high self-employment propensity
    n_construction = sum(sic_section == "F", na.rm = TRUE),
    n_professional = sum(sic_section == "M", na.rm = TRUE),
    n_transport = sum(sic_section == "H", na.rm = TRUE),
    n_admin = sum(sic_section == "N", na.rm = TRUE),
    # Placebo sectors (low self-employment)
    n_public_admin = sum(sic_section == "O", na.rm = TRUE),
    n_financial = sum(sic_section == "K", na.rm = TRUE),
    .groups = "drop"
  )

# Get LA names from population data (authoritative source)
la_names <- pop %>%
  distinct(GEOGRAPHY_CODE, GEOGRAPHY_NAME) %>%
  rename(la_code = GEOGRAPHY_CODE, la_name_geo = GEOGRAPHY_NAME)

# Create balanced panel: all LAs × all months
all_las <- la_month %>% distinct(la_code) %>% filter(!is.na(la_code)) %>%
  left_join(la_names, by = "la_code")
all_months <- tibble(inc_ym = seq(ymd("2013-01-01"), ymd("2019-12-01"), by = "month"))

panel <- crossing(all_las, all_months) %>%
  left_join(la_month, by = c("la_code", "inc_ym")) %>%
  mutate(across(starts_with("n_"), ~replace_na(.x, 0L)))

cat(sprintf("Balanced panel: %s LA × month observations\n", comma(nrow(panel))))
cat(sprintf("LAs: %d, Months: %d\n", n_distinct(panel$la_code), n_distinct(panel$inc_ym)))

cat("\n=== Step 3: Merge UC treatment dates ===\n")

# Fuzzy match LA names between DWP schedule and NOMIS/ONS
# DWP uses council names; ONS uses geographic names
# We'll match on cleaned versions

clean_la <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("\\s*(borough|metropolitan|county|district|city|council|royal borough of|london borough of|the)\\s*", " ") %>%
    str_replace_all("\\s+", " ") %>%
    str_trim() %>%
    str_replace_all("&", "and")
}

uc_dates_clean <- uc_dates %>%
  mutate(la_clean = clean_la(la_name))

panel_las <- panel %>%
  distinct(la_code, la_name_geo) %>%
  mutate(la_clean = clean_la(la_name_geo))

# Attempt exact match on cleaned names
matched <- panel_las %>%
  inner_join(uc_dates_clean %>% select(la_clean, first_treat_date, first_treat_month),
             by = "la_clean")

cat(sprintf("Exact matches: %d / %d DWP LAs\n", nrow(matched), nrow(uc_dates)))

# For unmatched, try partial matching
unmatched_dwp <- uc_dates_clean %>%
  anti_join(matched, by = "la_clean")

unmatched_panel <- panel_las %>%
  anti_join(matched, by = "la_clean")

if (nrow(unmatched_dwp) > 0) {
  cat(sprintf("Attempting fuzzy match for %d remaining DWP LAs...\n", nrow(unmatched_dwp)))
  # Use agrep for approximate matching
  fuzzy_matches <- list()
  for (i in seq_len(nrow(unmatched_dwp))) {
    hits <- agrep(unmatched_dwp$la_clean[i], unmatched_panel$la_clean,
                  max.distance = 0.3, value = FALSE)
    if (length(hits) == 1) {
      fuzzy_matches[[length(fuzzy_matches) + 1]] <- tibble(
        la_code = unmatched_panel$la_code[hits],
        la_name_geo = unmatched_panel$la_name_geo[hits],
        first_treat_date = unmatched_dwp$first_treat_date[i],
        first_treat_month = unmatched_dwp$first_treat_month[i],
        la_clean = unmatched_panel$la_clean[hits]
      )
    }
  }
  if (length(fuzzy_matches) > 0) {
    fuzzy_df <- bind_rows(fuzzy_matches)
    matched <- bind_rows(matched, fuzzy_df)
    cat(sprintf("Fuzzy matches added: %d. Total matched: %d\n",
                nrow(fuzzy_df), nrow(matched)))
  }
}

# Deduplicate matched: keep earliest treatment date per LA
matched_dedup <- matched %>%
  group_by(la_code) %>%
  summarise(
    first_treat_date = min(first_treat_date),
    first_treat_month = min(first_treat_month),
    .groups = "drop"
  )

cat(sprintf("Unique matched LAs: %d\n", nrow(matched_dedup)))

# Merge treatment dates into panel
panel <- panel %>%
  left_join(
    matched_dedup %>% select(la_code, first_treat_date, first_treat_month),
    by = "la_code"
  ) %>%
  mutate(
    # Treatment indicator
    treated = !is.na(first_treat_date) & inc_ym >= first_treat_date,
    # For CS-DiD: first_treat as numeric period
    # Convert dates to period numbers (months since Jan 2013)
    period = as.numeric(difftime(inc_ym, ymd("2013-01-01"), units = "days")) / 30.44,
    period = round(period),
    first_treat_period = ifelse(
      !is.na(first_treat_date),
      round(as.numeric(difftime(first_treat_date, ymd("2013-01-01"), units = "days")) / 30.44),
      0  # Never-treated
    ),
    # Time relative to treatment (for event study)
    rel_time = ifelse(!is.na(first_treat_date), period - first_treat_period, NA_real_),
    # Months since treatment (for MIF timing analysis)
    months_post = ifelse(treated, rel_time, NA_real_)
  )

# Summary of treatment variation
treat_summary <- panel %>%
  filter(!is.na(first_treat_date)) %>%
  distinct(la_code, first_treat_date) %>%
  count(first_treat_date, name = "n_las") %>%
  arrange(first_treat_date)

cat("\nTreatment cohort summary:\n")
print(treat_summary, n = 40)

n_treated <- n_distinct(panel$la_code[!is.na(panel$first_treat_date)])
n_never <- n_distinct(panel$la_code[is.na(panel$first_treat_date)])
cat(sprintf("\nTreated LAs: %d, Never-treated LAs: %d\n", n_treated, n_never))

cat("\n=== Step 4: Merge population denominators ===\n")

# Clean population data (from NM_31_1 — total population, used as denominator)
pop_clean <- pop %>%
  rename(pop_year = DATE_NAME, la_code_pop = GEOGRAPHY_CODE,
         la_name_pop = GEOGRAPHY_NAME, pop_total = OBS_VALUE) %>%
  mutate(
    year = as.numeric(str_extract(pop_year, "\\d{4}")),
    # Use total population as denominator (working-age unavailable via this API)
    pop_wa = pop_total
  ) %>%
  filter(!is.na(pop_wa)) %>%
  select(la_code_pop, year, pop_wa)

# Merge population (use year matching)
panel <- panel %>%
  mutate(year = year(inc_ym)) %>%
  left_join(pop_clean, by = c("la_code" = "la_code_pop", "year")) %>%
  mutate(
    # Formation rate per 1000 working-age population
    formation_rate = (n_formations / pop_wa) * 1000,
    formation_rate_plt = (n_private_ltd / pop_wa) * 1000,
    construction_rate = (n_construction / pop_wa) * 1000,
    professional_rate = (n_professional / pop_wa) * 1000,
    # Placebo rate
    public_admin_rate = (n_public_admin / pop_wa) * 1000
  )

# Drop LAs with missing population
panel <- panel %>% filter(!is.na(pop_wa), pop_wa > 0)

cat(sprintf("Final panel: %s observations\n", comma(nrow(panel))))
cat(sprintf("LAs with population: %d\n", n_distinct(panel$la_code)))

cat("\n=== Step 5: NOMIS APS panel ===\n")

# Reshape NOMIS to wide format: one row per LA × year
nomis_wide <- nomis %>%
  filter(MEASURES_NAME == "Variable") %>%
  mutate(
    year = as.numeric(str_extract(DATE_NAME, "^\\d{4}")),
    variable = case_when(
      str_detect(VARIABLE_NAME, "(?i)self employed") ~ "self_emp_rate",
      str_detect(VARIABLE_NAME, "(?i)employment rate") ~ "emp_rate",
      str_detect(VARIABLE_NAME, "(?i)employees") ~ "employee_rate",
      str_detect(VARIABLE_NAME, "(?i)unemployment rate") ~ "unemp_rate",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(variable)) %>%
  select(GEOGRAPHY_CODE, GEOGRAPHY_NAME, year, variable, OBS_VALUE) %>%
  # Deduplicate: take first value for any LA × year × variable combo
  group_by(GEOGRAPHY_CODE, GEOGRAPHY_NAME, year, variable) %>%
  summarise(OBS_VALUE = first(OBS_VALUE), .groups = "drop") %>%
  pivot_wider(names_from = variable, values_from = OBS_VALUE)

write_csv(nomis_wide, file.path(data_dir, "nomis_aps_panel.csv"))
cat(sprintf("NOMIS panel: %s observations (%d LAs × %d years)\n",
            comma(nrow(nomis_wide)),
            n_distinct(nomis_wide$GEOGRAPHY_CODE),
            n_distinct(nomis_wide$year)))

cat("\n=== Step 6: Create annual panel for secondary analysis ===\n")

# Aggregate monthly panel to annual for NOMIS merge
annual_panel <- panel %>%
  group_by(la_code, la_name_geo, year, first_treat_date, first_treat_month) %>%
  summarise(
    annual_formations = sum(n_formations),
    annual_plt = sum(n_private_ltd),
    annual_construction = sum(n_construction),
    annual_professional = sum(n_professional),
    annual_public_admin = sum(n_public_admin),
    pop_wa = first(pop_wa),
    .groups = "drop"
  ) %>%
  mutate(
    annual_formation_rate = (annual_formations / pop_wa) * 1000,
    annual_plt_rate = (annual_plt / pop_wa) * 1000,
    treated_year = !is.na(first_treat_date) & year >= year(first_treat_date),
    first_treat_year = ifelse(!is.na(first_treat_date), year(first_treat_date), 0)
  ) %>%
  left_join(
    nomis_wide %>% select(GEOGRAPHY_CODE, year, any_of(c("self_emp_rate", "emp_rate", "unemp_rate"))),
    by = c("la_code" = "GEOGRAPHY_CODE", "year")
  )

# Ensure required columns exist (may be missing if NOMIS data incomplete)
for (col in c("self_emp_rate", "emp_rate", "unemp_rate")) {
  if (!col %in% names(annual_panel)) {
    annual_panel[[col]] <- NA_real_
  }
}

write_parquet(annual_panel, file.path(data_dir, "annual_panel.parquet"))
cat(sprintf("Annual panel: %s observations\n", comma(nrow(annual_panel))))

cat("\n=== Step 7: Save final monthly panel ===\n")
write_parquet(panel, file.path(data_dir, "monthly_panel.parquet"))
cat("Monthly panel saved.\n")

cat("\n=== Panel Summary Statistics ===\n")
cat(sprintf("Monthly panel: %d LAs × %d months = %s obs\n",
            n_distinct(panel$la_code), n_distinct(panel$inc_ym), comma(nrow(panel))))
cat(sprintf("Treated LAs: %d (%.0f%%)\n",
            n_treated, 100 * n_treated / (n_treated + n_never)))
cat(sprintf("Mean monthly formations per LA: %.1f\n", mean(panel$n_formations)))
cat(sprintf("Mean formation rate (per 1000 WA pop): %.2f\n",
            mean(panel$formation_rate, na.rm = TRUE)))
cat(sprintf("Study window: %s to %s\n",
            min(panel$inc_ym), max(panel$inc_ym)))

cat("\nData cleaning complete. Ready for analysis.\n")
