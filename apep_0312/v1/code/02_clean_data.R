## 02_clean_data.R — Variable construction and data cleaning
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

# =============================================================================
# PART A: Clean Newspaper Panel
# =============================================================================

news_panel <- fread(file.path(DATA_DIR, "newspaper_panel.csv"))
wc_dates   <- fread(file.path(DATA_DIR, "workers_comp_dates.csv"))

# Merge newspaper data with workers' comp adoption dates
news_panel <- merge(news_panel, wc_dates, by = "state_name", all.x = TRUE)

# Construct accident coverage index
# Primary: accident pages / total pages (per 1000 pages)
news_panel[, accident_index := fifelse(
  total_pages > 0,
  (accident_pages / total_pages) * 1000,
  NA_real_
)]

# Combined accident index (all terms)
news_panel[, combined_accident_pages := accident_pages + mine_pages + factory_pages]
news_panel[, combined_index := fifelse(
  total_pages > 0,
  (combined_accident_pages / total_pages) * 1000,
  NA_real_
)]

# Log transformation for skewed data
news_panel[, log_accident := log1p(accident_pages)]
news_panel[, log_total := log1p(total_pages)]

# Treatment indicator: workers' comp in effect
news_panel[, treated := fifelse(!is.na(adoption_year) & year >= adoption_year, 1L, 0L)]

# Time relative to adoption
news_panel[, rel_time := year - adoption_year]

# Adoption cohort groups for C&S
# Early: 1911-1913, Mid: 1914-1915, Late: 1917-1920, Never: after 1920
news_panel[, cohort := fcase(
  adoption_year <= 1913, "Early (1911-1913)",
  adoption_year <= 1915, "Mid (1914-1915)",
  adoption_year <= 1920, "Late (1917-1920)",
  default = "Never (post-1920)"
)]

# Filter to states with adequate newspaper coverage
# Require >= 100 total pages in at least 15 of 21 years
coverage_check <- news_panel[, .(
  years_adequate = sum(total_pages >= 100, na.rm = TRUE),
  mean_pages = mean(total_pages, na.rm = TRUE)
), by = state_name]

adequate_states <- coverage_check[years_adequate >= 15, state_name]
cat("States with adequate newspaper coverage:", length(adequate_states), "\n")

news_clean <- news_panel[state_name %in% adequate_states]
cat("Newspaper panel after filtering:", nrow(news_clean), "obs,",
    length(unique(news_clean$state_name)), "states\n")

fwrite(news_clean, file.path(DATA_DIR, "newspaper_clean.csv"))

# =============================================================================
# PART B: Clean IPUMS Data
# =============================================================================

ipums <- fread(file.path(DATA_DIR, "ipums_1910_1920.csv.gz"))

# Merge with workers' comp dates
ipums <- merge(ipums, wc_dates[, .(statefip, adoption_year, first_treat)],
               by.x = "STATEFIP", by.y = "statefip", all.x = TRUE)

# Treatment: workers' comp in effect in state at census year
ipums[, treated := fifelse(!is.na(adoption_year) & YEAR >= adoption_year, 1L, 0L)]

# --- Dangerous Occupation Classification ---
# Based on historical occupation injury rates (BLS, Bureau of Mines)
# OCC1950 codes for high-risk occupations in the Progressive Era

# Mining occupations (OCC1950: 502-504)
# Manufacturing operatives (OCC1950: 600-690)
# Construction (OCC1950: 250-285)
# Railroad workers (OCC1950: 410-441)
# Lumbermen/woodchoppers (OCC1950: 740)

ipums[, dangerous_occ := fcase(
  OCC1950 >= 502 & OCC1950 <= 504, 1L,  # Mining
  OCC1950 >= 600 & OCC1950 <= 690, 1L,  # Manufacturing operatives
  OCC1950 >= 250 & OCC1950 <= 285, 1L,  # Construction
  OCC1950 >= 410 & OCC1950 <= 441, 1L,  # Railroad
  OCC1950 == 740, 1L,                     # Lumbermen
  default = 0L
)]

# Broad industry classification
ipums[, industry_group := fcase(
  IND1950 >= 206 & IND1950 <= 239, "Mining",
  IND1950 >= 306 & IND1950 <= 499, "Manufacturing",
  IND1950 >= 506 & IND1950 <= 598, "Construction/Transportation",
  IND1950 >= 606 & IND1950 <= 699, "Trade",
  IND1950 >= 806 & IND1950 <= 846, "Services",
  IND1950 >= 906 & IND1950 <= 936, "Public Administration",
  IND1950 >= 100 & IND1950 <= 126, "Agriculture",
  default = "Other"
)]

# Sample restrictions: working-age males in non-farm occupations
# This is the population most directly affected by workers' comp
ipums_analysis <- ipums[
  SEX == 1 &           # Male
  AGE >= 18 & AGE <= 65 &  # Working age
  LABFORCE == 2 &      # In labor force (employed or seeking)
  OCC1950 > 0 &        # Has an occupation code
  OCC1950 != 979 &     # Not "occupation not reported"
  industry_group != "Agriculture"  # Non-farm
]

# Demographic covariates for DR
ipums_analysis[, `:=`(
  white = fifelse(RACE == 1, 1L, 0L),
  foreign_born = fifelse(NATIVITY >= 4, 1L, 0L),  # Foreign born
  literate = fifelse(LIT == 4, 1L, 0L),            # Can read and write
  married = fifelse(MARST <= 2, 1L, 0L),           # Married
  has_children = fifelse(NCHILD > 0, 1L, 0L),
  age_sq = AGE^2,
  urban = fifelse(URBAN == 2, 1L, 0L)
)]

# Occupational income score (proxy for wages, pre-1940)
# OCCSCORE: Median income for occupation in 1950 (in hundreds of dollars)
ipums_analysis[, occ_income := OCCSCORE]

# Adoption cohort for C&S
ipums_analysis[, adoption_cohort := fcase(
  is.na(adoption_year) | adoption_year > 1920, 0L,  # Never treated (in window)
  default = as.integer(adoption_year)
)]

cat("IPUMS analysis sample:", format(nrow(ipums_analysis), big.mark = ","), "obs\n")
cat("  1910:", format(nrow(ipums_analysis[YEAR == 1910]), big.mark = ","), "\n")
cat("  1920:", format(nrow(ipums_analysis[YEAR == 1920]), big.mark = ","), "\n")
cat("  Treated:", format(sum(ipums_analysis$treated), big.mark = ","), "\n")
cat("  Dangerous occ:", round(mean(ipums_analysis$dangerous_occ) * 100, 1), "%\n")

fwrite(ipums_analysis, file.path(DATA_DIR, "ipums_analysis.csv"))

# =============================================================================
# PART C: State-Level Covariates (from IPUMS aggregation)
# =============================================================================

# Aggregate 1910 census data for state-level covariates
state_covs_1910 <- ipums[YEAR == 1910, .(
  pop_1910 = sum(PERWT, na.rm = TRUE),
  pct_urban_1910 = weighted.mean(URBAN == 2, PERWT, na.rm = TRUE) * 100,
  pct_foreign_1910 = weighted.mean(NATIVITY >= 4, PERWT, na.rm = TRUE) * 100,
  pct_literate_1910 = weighted.mean(LIT == 4, PERWT, na.rm = TRUE) * 100,
  pct_manufacturing_1910 = weighted.mean(
    IND1950 >= 306 & IND1950 <= 499,
    PERWT, na.rm = TRUE
  ) * 100,
  pct_mining_1910 = weighted.mean(
    IND1950 >= 206 & IND1950 <= 239,
    PERWT, na.rm = TRUE
  ) * 100
), by = STATEFIP]

state_covs_1910 <- merge(
  state_covs_1910,
  wc_dates[, .(statefip, adoption_year, first_treat, state_name)],
  by.x = "STATEFIP", by.y = "statefip", all.x = TRUE
)

fwrite(state_covs_1910, file.path(DATA_DIR, "state_covariates_1910.csv"))
cat("State covariates (1910) saved:", nrow(state_covs_1910), "states\n")

# =============================================================================
# PART D: Descriptive Statistics
# =============================================================================

# Summary table of workers' comp adoption
adoption_summary <- wc_dates[, .(n_states = .N), by = adoption_year][order(adoption_year)]
cat("\nWorkers' comp adoption timeline:\n")
print(adoption_summary)

# Summary of analysis sample
cat("\nIPUMS analysis sample summary:\n")
cat("  N observations:", format(nrow(ipums_analysis), big.mark = ","), "\n")
cat("  N states:", length(unique(ipums_analysis$STATEFIP)), "\n")
cat("  Share in dangerous occupations:", round(mean(ipums_analysis$dangerous_occ) * 100, 1), "%\n")
cat("  Mean occupational income score:", round(mean(ipums_analysis$occ_income, na.rm = TRUE), 1), "\n")

cat("\n=== Data cleaning complete ===\n")
