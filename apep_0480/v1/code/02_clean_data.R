##############################################################################
# 02_clean_data.R — Build CSP-quarter panel for DR-DiD analysis
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

source("00_packages.R")

data_dir <- "../data"

# ============================================================================
# 1. CRIME PANEL (from parsed ODS files)
# ============================================================================
cat("\n=== Crime Panel (CSP × Quarter × Offence Group) ===\n")

crime <- fread(file.path(data_dir, "crime_csp_panel.csv"), showProgress = FALSE)
cat("Raw crime rows:", format(nrow(crime), big.mark = ","), "\n")
cat("Financial years:", paste(sort(unique(crime$financial_year)), collapse = ", "), "\n")
cat("Quarters:", paste(sort(unique(crime$quarter)), collapse = ", "), "\n")
cat("Unique CSPs:", uniqueN(crime$csp_name), "\n")
cat("Offence groups:", paste(sort(unique(crime$offence_group)), collapse = "; "), "\n")

# Drop "Unassigned" CSPs (police force residuals)
crime <- crime[!grepl("^Unassigned", csp_name)]
cat("After dropping Unassigned:", format(nrow(crime), big.mark = ","), "rows,",
    uniqueN(crime$csp_name), "CSPs\n")

# Convert offence_count to numeric
crime[, offence_count := suppressWarnings(as.numeric(offence_count))]
crime[is.na(offence_count), offence_count := 0]

# Create numeric year-quarter identifier
# Financial year 2015/16 Q1 = Apr-Jun 2015 = calendar 2015Q2
crime[, fy_start := as.integer(substr(financial_year, 1, 4))]
crime[, cal_year := fifelse(quarter <= 3, fy_start, fy_start + 1L)]
crime[, cal_quarter := fifelse(quarter == 1, 2L,
                       fifelse(quarter == 2, 3L,
                       fifelse(quarter == 3, 4L, 1L)))]
crime[, yq := cal_year + (cal_quarter - 1) / 4]
crime[, yq_label := paste0(cal_year, "Q", cal_quarter)]

# Aggregate total crime per CSP-quarter
total_crime <- crime[, .(total_offences = sum(offence_count, na.rm = TRUE)),
                     by = .(csp_name, financial_year, quarter, yq, yq_label)]

cat("Total crime panel:", nrow(total_crime), "CSP-quarter obs\n")
cat("Year-quarter range:", min(total_crime$yq), "to", max(total_crime$yq), "\n")

# Create crime by category (for mechanism analysis)
crime_by_group <- crime[, .(offences = sum(offence_count, na.rm = TRUE)),
                        by = .(csp_name, financial_year, quarter, yq, yq_label, offence_group)]

# Pivot to wide format for key crime types
crime_wide <- dcast(crime_by_group, csp_name + financial_year + quarter + yq + yq_label ~ offence_group,
                    value.var = "offences", fill = 0)

# Clean column names
old_names <- names(crime_wide)
new_names <- gsub(" ", "_", tolower(old_names))
new_names <- gsub("[^a-z0-9_]", "", new_names)
setnames(crime_wide, old_names, new_names)

# Add total crime
crime_wide <- merge(crime_wide, total_crime[, .(csp_name, yq, total_offences)],
                    by = c("csp_name", "yq"), all.x = TRUE)

cat("Crime categories:", paste(names(crime_wide)[6:ncol(crime_wide)], collapse = ", "), "\n")

# ============================================================================
# 2. TREATMENT VARIABLE (Betting Shop Density)
# ============================================================================
cat("\n=== Treatment Variable ===\n")

treatment <- fread(file.path(data_dir, "treatment_betting_density.csv"))
cat("Treatment data:", nrow(treatment), "CSPs\n")
cat("Shops summary:\n")
print(summary(treatment$shops_current))

# ============================================================================
# 3. POPULATION DATA (NOMIS)
# ============================================================================
cat("\n=== Population Data ===\n")

pop <- fread(file.path(data_dir, "nomis_population_panel.csv"), showProgress = FALSE)
pop_slim <- pop[, .(la_name = GEOGRAPHY_NAME, la_code = GEOGRAPHY_CODE,
                    year = as.integer(DATE), population = OBS_VALUE)]

cat("Population panel:", nrow(pop_slim), "LA-year obs\n")
cat("Years:", paste(sort(unique(pop_slim$year)), collapse = ", "), "\n")

# Match population LA names to CSP names
# Population data uses LA names which should be closer to CSP names
pop_csps <- unique(pop_slim$la_name)
treatment_csps <- unique(treatment$csp_name)
pop_overlap <- length(intersect(pop_csps, treatment_csps))
cat("Population ∩ Treatment name match:", pop_overlap, "\n")

# ============================================================================
# 4. IMD 2019
# ============================================================================
cat("\n=== IMD 2019 ===\n")

imd_file <- file.path(data_dir, "imd_2019_la.xlsx")
if (file.exists(imd_file)) {
  # Sheet 1 is Notes (empty), Sheet 2 "IMD" has the data
  imd <- as.data.table(readxl::read_excel(imd_file, sheet = "IMD"))
  cat("IMD columns:", paste(head(names(imd), 8), collapse = ", "), "\n")
  imd_cols <- names(imd)
  score_col <- grep("IMD.*Average.*score|Average.*score", imd_cols, value = TRUE, ignore.case = TRUE)
  code_col <- grep("code", imd_cols, value = TRUE, ignore.case = TRUE)[1]
  name_col <- grep("name", imd_cols, value = TRUE, ignore.case = TRUE)[1]

  if (length(score_col) > 0 && !is.na(code_col)) {
    imd_slim <- imd[, c(code_col, name_col, score_col[1]), with = FALSE]
    setnames(imd_slim, c("la_code", "la_name_imd", "imd_score"))
    imd_slim[, imd_score := as.numeric(imd_score)]
    imd_slim <- imd_slim[!is.na(imd_score)]
    cat("IMD data:", nrow(imd_slim), "LAs with IMD scores\n")
  }
}

# ============================================================================
# 5. LAND REGISTRY PROPERTY PRICES
# ============================================================================
cat("\n=== Land Registry ===\n")

lr_file <- file.path(data_dir, "land_registry_district_year.csv")
if (file.exists(lr_file)) {
  lr <- fread(lr_file)
  cat("Land Registry:", nrow(lr), "district-year obs\n")
  cat("Years:", paste(sort(unique(lr$year)), collapse = ", "), "\n")
  cat("Unique districts:", uniqueN(lr$district), "\n")
}

# ============================================================================
# 6. BUILD ANALYSIS PANEL
# ============================================================================
cat("\n=== Building Analysis Panel ===\n")

# The crime data is at CSP × fiscal-quarter level
# Treatment is at CSP level (cross-sectional)
# Population is at LA × year level (need to map LA → CSP)

# Step 1: Merge treatment onto crime panel
panel <- merge(crime_wide, treatment, by = "csp_name", all.x = TRUE)

# CSPs without treatment data get 0 shops (conservative)
panel[is.na(shops_current), shops_current := 0]
cat("Panel after treatment merge:", nrow(panel), "rows,", uniqueN(panel$csp_name), "CSPs\n")

# Step 2: Merge population (use CSP name ~ LA name matching)
# Since population is annual, assign to all quarters in that year
pop_for_merge <- pop_slim[, .(csp_name = la_name, year, population)]
# Use cal_year from crime for the merge
panel[, merge_year := as.integer(substr(financial_year, 1, 4))]
panel <- merge(panel, pop_for_merge, by.x = c("csp_name", "merge_year"),
               by.y = c("csp_name", "year"), all.x = TRUE)

# For CSPs without direct population match, try to interpolate
pop_matched <- panel[!is.na(population), uniqueN(csp_name)]
cat("CSPs with population match:", pop_matched, "\n")

# Fill forward/backward population within CSP
panel[, population := nafill(population, type = "locf"), by = csp_name]
panel[, population := nafill(population, type = "nocb"), by = csp_name]

# Step 3: Construct key variables
# Treatment intensity: shops per 10,000 population
# Use mean population across years as denominator for consistency
panel[, mean_pop := mean(population, na.rm = TRUE), by = csp_name]
panel[, betting_density := shops_current / (mean_pop / 10000)]
panel[is.na(betting_density) | is.infinite(betting_density), betting_density := 0]

# Binary treatment: above-median density
median_density <- median(panel[!duplicated(csp_name) & betting_density > 0, betting_density])
panel[, high_density := as.integer(betting_density >= median_density)]
cat("Median betting density (among positive):", round(median_density, 2), "\n")

# Quintiles of exposure
panel[, density_quintile := cut(betting_density,
                                breaks = quantile(betting_density[!duplicated(csp_name)],
                                                  probs = seq(0, 1, 0.2), na.rm = TRUE),
                                labels = FALSE, include.lowest = TRUE)]

# Post-treatment indicator
# FOBT stake cut implemented April 1, 2019 = 2019Q2 in calendar time
# 2018/19 Q4 = Jan-Mar 2019 = 2019Q1 (pre-treatment)
# 2019/20 Q1 = Apr-Jun 2019 = 2019Q2 (post-treatment)
panel[, post := as.integer(yq >= 2019.25)]

# Event time (quarters relative to treatment)
# Treatment at 2019Q2 (yq = 2019.25)
panel[, event_time := round((yq - 2019.25) * 4)]

# Crime rates per 10,000 population
crime_cols <- names(panel)[grepl("offences|criminal|drug|robbery|sexual|theft|violence|public|possession|miscellaneous", names(panel))]
for (col in crime_cols) {
  rate_col <- paste0(col, "_rate")
  panel[, (rate_col) := get(col) / (population / 10000)]
}

# Log crime rate (for proportional effects)
panel[, log_total_crime := log(total_offences + 1)]

# ============================================================================
# 7. MERGE IMD
# ============================================================================
if (exists("imd_slim")) {
  # Match IMD by LA name to CSP name
  # IMD has la_name_imd which should be similar to csp_name
  imd_for_merge <- imd_slim[, .(csp_name = la_name_imd, imd_score)]
  panel <- merge(panel, imd_for_merge, by = "csp_name", all.x = TRUE)
  cat("CSPs with IMD:", panel[!is.na(imd_score), uniqueN(csp_name)], "\n")
}

# ============================================================================
# 8. MERGE LAND REGISTRY
# ============================================================================
if (exists("lr")) {
  # Land Registry district names are UPPERCASE; CSP names are Title Case
  # Normalize LR district to title case for matching
  lr[, district_clean := tools::toTitleCase(tolower(district))]
  lr_for_merge <- lr[, .(csp_name = district_clean, year, mean_price, median_price,
                         log_mean_price, n_transactions)]
  panel <- merge(panel, lr_for_merge,
                 by.x = c("csp_name", "merge_year"),
                 by.y = c("csp_name", "year"), all.x = TRUE)
  lr_matched <- panel[!is.na(mean_price), uniqueN(csp_name)]
  cat("CSPs with property price data:", lr_matched, "\n")
}

# ============================================================================
# 9. CLEAN AND FINALIZE PANEL
# ============================================================================
cat("\n=== Final Panel ===\n")

# Create CSP numeric ID for fixed effects
panel[, csp_id := as.integer(factor(csp_name))]

# Create quarter numeric ID for time FE
panel[, time_id := as.integer(factor(yq))]

# Drop CSPs with missing population (can't compute rates)
panel_clean <- panel[!is.na(population) & population > 0]

cat("Panel dimensions:", nrow(panel_clean), "rows ×", ncol(panel_clean), "columns\n")
cat("CSPs:", uniqueN(panel_clean$csp_name), "\n")
cat("Quarters:", uniqueN(panel_clean$yq), "\n")
cat("Year-quarter range:", min(panel_clean$yq_label), "to", max(panel_clean$yq_label), "\n")
cat("Pre-treatment periods:", uniqueN(panel_clean[post == 0, yq]), "\n")
cat("Post-treatment periods:", uniqueN(panel_clean[post == 1, yq]), "\n")
cat("High-density CSPs:", uniqueN(panel_clean[high_density == 1, csp_name]), "\n")
cat("Low-density CSPs:", uniqueN(panel_clean[high_density == 0, csp_name]), "\n")

# Summary statistics
cat("\n=== Key Variable Summary ===\n")
cat("Betting density:\n")
print(summary(panel_clean[!duplicated(csp_name), betting_density]))
cat("\nTotal crime rate (per 10k):\n")
print(summary(panel_clean$total_offences_rate))
cat("\nPopulation:\n")
print(summary(panel_clean$population))

# Save
fwrite(panel_clean, file.path(data_dir, "analysis_panel.csv"))
cat("\nAnalysis panel saved:", file.path(data_dir, "analysis_panel.csv"), "\n")

# Also save a summary of the panel
panel_summary <- panel_clean[, .(
  n_quarters = .N,
  mean_crime_rate = mean(total_offences_rate, na.rm = TRUE),
  mean_density = mean(betting_density, na.rm = TRUE),
  mean_pop = mean(population, na.rm = TRUE),
  has_prices = sum(!is.na(mean_price)) > 0,
  has_imd = !is.na(imd_score[1])
), by = csp_name]

cat("\nCSPs with complete data (crime + pop + density):", nrow(panel_summary), "\n")
cat("CSPs also with property prices:", sum(panel_summary$has_prices), "\n")
cat("CSPs also with IMD:", sum(panel_summary$has_imd), "\n")
