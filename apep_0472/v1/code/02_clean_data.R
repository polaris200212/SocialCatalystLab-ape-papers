#' ---
#' Selective Licensing and Crime Displacement
#' 02_clean_data.R — Build analysis panel: LSOA-month crime × licensing status
#' ---

source("code/00_packages.R")

# ============================================================================
# 1. LOAD RAW DATA
# ============================================================================

message("Loading raw data...")

crime_total <- fread(file.path(DATA_DIR, "lsoa_crime_total.csv"))
crime_cat   <- fread(file.path(DATA_DIR, "lsoa_crime_by_category.csv"))
licensing   <- fread(file.path(DATA_DIR, "licensing_dates.csv"))
lsoa_la     <- fread(file.path(DATA_DIR, "lsoa_la_lookup.csv"))
pop_data    <- fread(file.path(DATA_DIR, "la_population.csv"))

message("  Crime total:     ", format(nrow(crime_total), big.mark = ","), " rows")
message("  Crime by cat:    ", format(nrow(crime_cat), big.mark = ","), " rows")
message("  Licensed LAs:    ", nrow(licensing))
message("  LSOA-LA lookup:  ", nrow(lsoa_la), " mappings")
message("  Population:      ", nrow(pop_data), " LA-year obs")

# ============================================================================
# 2. CLEAN AND STANDARDIZE
# ============================================================================

# Parse dates
crime_total[, month := as.Date(paste0(month, "-01"))]
crime_cat[, month := as.Date(paste0(month, "-01"))]
licensing[, adoption_date := as.Date(adoption_date)]
licensing[, first_treated_month := as.Date(first_treated_month)]

# Ensure LSOA codes are standardized
crime_total[, lsoa_code := str_trim(lsoa_code)]
crime_cat[, lsoa_code := str_trim(lsoa_code)]
if ("lsoa_code" %in% names(lsoa_la)) {
  lsoa_la[, lsoa_code := str_trim(lsoa_code)]
}

# Filter to England only (E01* LSOA codes)
crime_total <- crime_total[grepl("^E01", lsoa_code)]
crime_cat   <- crime_cat[grepl("^E01", lsoa_code)]

message("  After England filter:")
message("    Crime total: ", format(nrow(crime_total), big.mark = ","))
message("    Crime cat:   ", format(nrow(crime_cat), big.mark = ","))

# ============================================================================
# 2b. BALANCE THE PANEL (fill zero-crime LSOA-months)
# ============================================================================

message("Balancing panel: creating full LSOA x month grid...")

all_lsoas  <- sort(unique(crime_total$lsoa_code))
all_months <- sort(unique(crime_total$month))
message("  Unique LSOAs:  ", format(length(all_lsoas), big.mark = ","))
message("  Unique months: ", length(all_months))
message("  Full grid:     ", format(length(all_lsoas) * length(all_months), big.mark = ","))

full_grid <- CJ(lsoa_code = all_lsoas, month = all_months)
crime_total <- merge(full_grid, crime_total, by = c("lsoa_code", "month"), all.x = TRUE)
crime_total[is.na(total_crime), total_crime := 0L]

message("  After balancing: ", format(nrow(crime_total), big.mark = ","),
        " (was ", format(nrow(crime_total[total_crime > 0]), big.mark = ","),
        " with crime > 0)")

# ============================================================================
# 3. MERGE LSOA → LA
# ============================================================================

message("Merging LSOA to LA codes...")

# Check lookup format
if ("la_code" %in% names(lsoa_la) && "lsoa_code" %in% names(lsoa_la)) {
  # Standard lookup with separate columns
  lsoa_la_clean <- unique(lsoa_la[, .(lsoa_code, la_code, la_name)])
} else {
  # Fallback: try to extract from crime data LSOA names
  lsoa_la_clean <- unique(crime_total[, .(lsoa_code)])[, la_code := NA_character_]
  message("  WARNING: Using incomplete LSOA-LA mapping")
}

# Merge LA code onto crime data
crime_total <- merge(crime_total, lsoa_la_clean[, .(lsoa_code, la_code)],
                     by = "lsoa_code", all.x = TRUE)

match_rate <- mean(!is.na(crime_total$la_code))
message("  LA match rate: ", round(match_rate * 100, 1), "%")

# Drop unmatched
crime_total <- crime_total[!is.na(la_code)]

# ============================================================================
# 4. CONSTRUCT TREATMENT VARIABLES
# ============================================================================

message("Constructing treatment variables...")

# Merge licensing status
licensing_clean <- licensing[, .(la_code, first_treated_month, coverage)]

crime_total <- merge(crime_total, licensing_clean,
                     by = "la_code", all.x = TRUE)

# Treatment indicator: 1 if month >= first_treated_month
crime_total[, licensed := as.integer(!is.na(first_treated_month) & month >= first_treated_month)]

# Ever-treated indicator
crime_total[, ever_treated := as.integer(!is.na(first_treated_month))]

# Cohort: year of first treatment (for CS-DiD)
crime_total[, cohort := ifelse(ever_treated == 1,
                                year(first_treated_month),
                                0)]  # 0 = never treated

# Relative time (months since treatment)
crime_total[, rel_time := ifelse(ever_treated == 1,
                                  as.integer(difftime(month, first_treated_month, units = "days")) %/% 30,
                                  NA_integer_)]

# Time period (numeric for fixest)
crime_total[, time_period := as.integer(month)]

# LSOA numeric ID
crime_total[, lsoa_id := as.integer(as.factor(lsoa_code))]
crime_total[, la_id := as.integer(as.factor(la_code))]

# Year and quarter
crime_total[, year := year(month)]
crime_total[, quarter := quarter(month)]
crime_total[, year_quarter := paste0(year, "Q", quarter)]

message("  Treatment distribution:")
message("    Ever treated LAs:    ", length(unique(crime_total[ever_treated == 1]$la_code)))
message("    Never treated LAs:   ", length(unique(crime_total[ever_treated == 0]$la_code)))
message("    Treated observations: ", format(sum(crime_total$licensed), big.mark = ","))
message("    Control observations: ", format(sum(1 - crime_total$licensed), big.mark = ","))

# ============================================================================
# 5. ADD POPULATION FOR CRIME RATES
# ============================================================================

message("Adding population data for crime rates...")

# Merge population at LA-year level
crime_total[, year_for_pop := pmin(year, max(pop_data$year, na.rm = TRUE))]

crime_total <- merge(crime_total,
                     pop_data[, .(la_code = la_code, year, population)],
                     by.x = c("la_code", "year_for_pop"),
                     by.y = c("la_code", "year"),
                     all.x = TRUE)

# For LSOAs: approximate LSOA population as LA population / number of LSOAs in LA
lsoa_per_la <- crime_total[, .(n_lsoas = uniqueN(lsoa_code)), by = la_code]
crime_total <- merge(crime_total, lsoa_per_la, by = "la_code", all.x = TRUE)
crime_total[, lsoa_pop_approx := population / n_lsoas]

# Crime rate per 1000 (annual equivalent)
crime_total[, crime_rate := (total_crime / lsoa_pop_approx) * 1000 * 12]

# Winsorize extreme rates (data quality issues in tiny LSOAs)
p99 <- quantile(crime_total$crime_rate, 0.99, na.rm = TRUE)
crime_total[crime_rate > p99, crime_rate := p99]

# ============================================================================
# 6. CREATE CRIME CATEGORY PANELS
# ============================================================================

message("Creating crime category panels...")

# Key categories for analysis (names as they appear in Police API data)
key_categories <- c(
  "Anti-social behaviour",
  "Violence and sexual offences",
  "Burglary",
  "Criminal damage and arson",
  "Other theft",
  "Shoplifting",
  "Public order",
  "Drugs",
  "Robbery",
  "Vehicle crime",
  "Theft from the person"
)

# Placebo categories (unlikely affected by landlord licensing)
placebo_categories <- c(
  "Bicycle theft",
  "Other crime",
  "Possession of weapons"
)

# Aggregate categories to LSOA-month
crime_cat_wide <- dcast(crime_cat[crime_type %in% c(key_categories, placebo_categories)],
                         lsoa_code + month ~ crime_type,
                         value.var = "crime_count",
                         fill = 0)

# Ensure month is Date type (already parsed in line 32, dcast preserves it)
if (!inherits(crime_cat_wide$month, "Date")) {
  crime_cat_wide[, month := as.Date(paste0(month, "-01"))]
}
crime_cat_wide <- merge(crime_cat_wide,
                         unique(crime_total[, .(lsoa_code, la_code, lsoa_id, la_id,
                                                 ever_treated, licensed, cohort,
                                                 rel_time, time_period, year, quarter,
                                                 lsoa_pop_approx)]),
                         by = c("lsoa_code"),
                         all.x = TRUE,
                         allow.cartesian = TRUE)

# ============================================================================
# 7. CONSTRUCT DISPLACEMENT VARIABLES
# ============================================================================

message("Constructing displacement variables...")

# Identify LAs adjacent to treated LAs
# Use a simple approach: LAs that share a name prefix or are known neighbors
# Better approach: use LA boundary data to find geographic neighbors

# For now, create a "near treated" indicator based on police force area
# (LAs in the same police force as a treated LA are likely geographic neighbors)
crime_total <- merge(crime_total,
                     la_to_force <- data.table(
                       la_code = licensing$la_code,
                       treated_la = TRUE
                     ),
                     by = "la_code", all.x = TRUE)
crime_total[is.na(treated_la), treated_la := FALSE]

# Save analysis panel
message("Saving analysis panel...")
fwrite(crime_total, file.path(DATA_DIR, "analysis_panel.csv"))

# Save summary statistics
summary_stats <- crime_total[, .(
  n_lsoas = uniqueN(lsoa_code),
  n_las = uniqueN(la_code),
  n_months = uniqueN(month),
  n_obs = .N,
  mean_crime = mean(total_crime, na.rm = TRUE),
  mean_crime_rate = mean(crime_rate, na.rm = TRUE),
  sd_crime_rate = sd(crime_rate, na.rm = TRUE),
  pct_treated = mean(licensed, na.rm = TRUE) * 100
)]

message("\n=== ANALYSIS PANEL SUMMARY ===")
message("LSOAs:         ", format(summary_stats$n_lsoas, big.mark = ","))
message("LAs:           ", summary_stats$n_las)
message("Months:         ", summary_stats$n_months)
message("Observations:   ", format(summary_stats$n_obs, big.mark = ","))
message("Mean crime/LSOA-month: ", round(summary_stats$mean_crime, 1))
message("Mean crime rate:       ", round(summary_stats$mean_crime_rate, 1))
message("% treated obs:         ", round(summary_stats$pct_treated, 1), "%")
message("=============================\n")

fwrite(summary_stats, file.path(DATA_DIR, "summary_stats.csv"))
message("Data cleaning complete.")
