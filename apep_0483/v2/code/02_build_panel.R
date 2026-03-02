###############################################################################
# 02_build_panel.R — Construct analysis panels
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
#
# Two panels:
#   A) LA × year panel (2018/19-2024/25) — main FE specification
#   B) School-level cross-section (2023/24) — academy DDD
#
# Merges: KS4 outcomes + competitiveness ratio + vacancies + covariates
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

###############################################################################
# 1. LA-Level Panel from Multi-Year KS4
###############################################################################

cat("=== BUILDING LA-LEVEL PANEL ===\n\n")

la_raw <- fread(paste0(data_dir, "ks4_la_multiyear_raw.csv"), showProgress = FALSE)
cat(sprintf("Multi-year KS4: %d rows, %d columns\n", nrow(la_raw), ncol(la_raw)))

# Filter to LA-level, all pupils (totals, not subgroups)
la_dt <- la_raw[geographic_level == "Local authority"]
cat(sprintf("LA-level rows: %d\n", nrow(la_dt)))

# Identify the "all pupils" breakdown
cat(sprintf("Breakdown topics: %s\n",
            paste(unique(la_dt$breakdown_topic), collapse="; ")))

# Filter to total/all breakdowns
# The "Total" breakdown should give us the aggregate for each LA
if ("breakdown_topic" %in% names(la_dt)) {
  la_total <- la_dt[breakdown_topic == "Total" | breakdown_topic == ""]
  if (nrow(la_total) == 0) {
    # Try sex == "Total" or similar
    la_total <- la_dt[sex == "Total" & (ethnicity_major == "Total" | ethnicity_major == "")]
    if (nrow(la_total) == 0) {
      # Take unique LA × year with minimal filters
      breakdown_cols <- grep("sex|ethnicity|fsm|sen|disadvantage|first_language|prior_attainment|mobility",
                             names(la_dt), value = TRUE)
      cat(sprintf("Breakdown cols: %s\n", paste(breakdown_cols, collapse=", ")))
      # Take the first row per LA × year as the "total" row
      cat("Using sex=Total filter...\n")
      la_total <- la_dt[sex == "Total"]
    }
  }
} else {
  la_total <- la_dt
}

cat(sprintf("After total filter: %d rows\n", nrow(la_total)))

# Still may have multiple breakdowns — deduplicate to one row per LA × year
# Use breakdown_topic == "Total" to get aggregate rows
la_total <- la_total[breakdown_topic == "Total"]
cat(sprintf("After breakdown_topic=Total: %d rows\n", nrow(la_total)))

# Keep only years with Progress 8 data (2018/19 onwards)
la_total <- la_total[time_period >= 201819]
cat(sprintf("Years 2018/19+: %d rows\n", nrow(la_total)))
cat(sprintf("Time periods: %s\n", paste(sort(unique(la_total$time_period)), collapse=", ")))
cat(sprintf("Unique LAs: %d\n", uniqueN(la_total$new_la_code)))

# Extract key variables
# Progress 8 and Attainment 8
p8_col <- grep("progress8_average", names(la_total), value = TRUE)[1]
a8_col <- grep("attainment8_average", names(la_total), value = TRUE)[1]

cat(sprintf("P8 column: %s\n", p8_col))
cat(sprintf("A8 column: %s\n", a8_col))

la_panel <- data.table(
  la_code = la_total$new_la_code,
  la_name = la_total$la_name,
  time_period = la_total$time_period,
  year = as.integer(substr(as.character(la_total$time_period), 1, 4))
)

if (!is.na(p8_col)) la_panel[, progress8 := as.numeric(la_total[[p8_col]])]
if (!is.na(a8_col)) la_panel[, attainment8 := as.numeric(la_total[[a8_col]])]

# Also extract number of pupils if available
pupils_col <- grep("progress8_pupil_count|t_pupils|t_inp8calc", names(la_total), value = TRUE)[1]
if (!is.na(pupils_col)) la_panel[, n_pupils := as.numeric(la_total[[pupils_col]])]

# Remove duplicate rows (same LA × year)
la_panel <- unique(la_panel, by = c("la_code", "year"))
cat(sprintf("Unique LA × year: %d\n", nrow(la_panel)))

# Exclude COVID years (2019/20, 2020/21) — no Progress 8 calculated
la_panel <- la_panel[!(year %in% c(2019, 2020))]
cat(sprintf("After excluding COVID years: %d rows\n", nrow(la_panel)))
cat(sprintf("Years: %s\n", paste(sort(unique(la_panel$year)), collapse=", ")))

# Progress 8 summary
cat(sprintf("Progress 8 non-missing: %d (%.1f%%)\n",
            sum(!is.na(la_panel$progress8)),
            100 * mean(!is.na(la_panel$progress8))))
cat(sprintf("Progress 8 range: [%.2f, %.2f]\n",
            min(la_panel$progress8, na.rm = TRUE),
            max(la_panel$progress8, na.rm = TRUE)))

###############################################################################
# 2. Build and Merge Competitiveness Ratio
###############################################################################

cat("\n=== BUILDING COMPETITIVENESS RATIO ===\n\n")

# Build competitiveness from ASHE + STPCD
ashe <- fread(paste0(data_dir, "ashe_earnings_by_la.csv"))
stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))
la_bands <- fread(paste0(data_dir, "la_band_mapping.csv"))

# Assign STPCD band to ASHE LAs
ashe[, band := "rest_of_england"]
ashe[la_bands, band := i.band, on = .(la_code)]

# Merge teacher pay by band × year
comp <- merge(ashe, stpcd[, .(year, band, teacher_pay_mid)],
              by = c("year", "band"), all.x = TRUE)

# Competitiveness ratio: teacher/private (higher = teaching more attractive)
comp[, comp_ratio := teacher_pay_mid / median_annual_pay]

# Save for other scripts
fwrite(comp, paste0(data_dir, "competitiveness_by_la.csv"))
cat(sprintf("Competitiveness: %d rows, %d LAs, years %d-%d\n",
            nrow(comp), uniqueN(comp$la_code),
            min(comp$year), max(comp$year)))
cat(sprintf("Competitiveness: %d rows\n", nrow(comp)))

# The LA codes in KS4 are upper-tier (E06, E08, E09, E10)
# ASHE is at district level (E07 + upper-tier)
# For E07 districts, we need to aggregate to their parent E10 county

# Check which LA codes match directly
direct_match <- la_panel$la_code[la_panel$la_code %in% comp$la_code]
cat(sprintf("Direct LA code matches: %d of %d\n",
            uniqueN(direct_match), uniqueN(la_panel$la_code)))

# For non-matching codes, these are counties (E10) that need district aggregation
# or LAs with different code formats
unmatched <- unique(la_panel$la_code[!la_panel$la_code %in% comp$la_code])
cat(sprintf("Unmatched LA codes: %d\n", length(unmatched)))
if (length(unmatched) > 0) {
  cat(sprintf("  Examples: %s\n", paste(head(unmatched, 10), collapse=", ")))
}

# Aggregate district-level ASHE to upper-tier LA level
# E07 districts → E10 counties (need lookup)
# Use GIAS to build district-to-county mapping
gias_file <- paste0(data_dir, "gias_raw.csv")
if (file.exists(gias_file)) {
  gias <- fread(gias_file, showProgress = FALSE,
                select = c("LA (code)", "GOR (name)"))
  setnames(gias, c("la_code_gias", "region_name"))

  # GIAS LA codes are upper-tier codes matching KS4
  # We'll map from the KS4 codes
  cat("Building district-to-upper-tier mapping from GIAS...\n")
}

# For ASHE, aggregate by the district codes that map to each upper-tier LA
# Strategy: compute mean earnings across districts within each county
# For already upper-tier codes (E06, E08, E09), direct match

# Create mapping: E10 county code → list of E07 district codes
# This is based on the ONS standard geography hierarchy
# We'll construct it from the data itself
ashe <- fread(paste0(data_dir, "ashe_earnings_by_la.csv"))
stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))
la_bands <- fread(paste0(data_dir, "la_band_mapping.csv"))

# Get all unique ASHE codes and KS4 codes
ks4_codes <- unique(la_panel$la_code)

# E06 (Unitary), E08 (Met Borough), E09 (London Borough) → direct match
# E10 (County) → need to aggregate from E07 (District) children
e10_codes <- ks4_codes[grepl("^E10", ks4_codes)]
cat(sprintf("E10 counties needing aggregation: %d\n", length(e10_codes)))

# Build county → district mapping using known ONS hierarchy
# County code E10XXXX → districts E07XXXX share the same middle digits
# This isn't always true, so we use a lookup approach
# First, try to match by position/numbering conventions

# The ONS approach: E10 counties contain E07 districts
# The last 4 digits of E07 codes map to their parent E10
# E.g., E10000002 (Buckinghamshire) contains E07000004-E07000007

# Build competitiveness at upper-tier level
comp_upper <- comp[!grepl("^E07", la_code)]  # Already upper-tier
cat(sprintf("Direct upper-tier competitiveness obs: %d\n", nrow(comp_upper)))

# For E10 counties: average the E07 district competitiveness
if (length(e10_codes) > 0) {
  # Use a known mapping file or approximate with population-weighted average
  # For now, compute unweighted mean of all E07 districts in ASHE by year
  # and assign to E10 counties based on naming convention

  # Simpler approach: match E10 counties by LA name
  ks4_county_names <- unique(la_panel[grepl("^E10", la_code), .(la_code, la_name)])
  cat(sprintf("County names to match: %s\n",
              paste(ks4_county_names$la_name, collapse="; ")))

  # For each county, find districts with the county in their name
  for (i in seq_len(nrow(ks4_county_names))) {
    county_name <- ks4_county_names$la_name[i]
    county_code <- ks4_county_names$la_code[i]

    # Find ASHE districts that belong to this county
    # Use approximate name matching
    district_codes <- ashe[grepl("^E07", la_code) &
                             grepl(county_name, la_name, ignore.case = TRUE),
                           unique(la_code)]

    if (length(district_codes) > 0) {
      # Average competitiveness across districts by year
      county_comp <- comp[la_code %in% district_codes,
                          .(median_annual_pay = mean(median_annual_pay, na.rm = TRUE),
                            comp_ratio = mean(comp_ratio, na.rm = TRUE)),
                          by = year]
      county_comp[, la_code := county_code]

      comp_upper <- rbind(comp_upper, county_comp, fill = TRUE)
    }
  }
}

cat(sprintf("Upper-tier competitiveness: %d rows, %d LAs\n",
            nrow(comp_upper), uniqueN(comp_upper$la_code)))

# Merge with LA panel
la_panel <- merge(la_panel, comp_upper[, .(la_code, year, comp_ratio,
                                            median_annual_pay)],
                  by = c("la_code", "year"), all.x = TRUE)

cat(sprintf("Competitiveness merged: %d of %d obs (%.1f%%)\n",
            sum(!is.na(la_panel$comp_ratio)), nrow(la_panel),
            100 * mean(!is.na(la_panel$comp_ratio))))

# Assign STPCD band
la_panel[, band := "rest_of_england"]
la_panel[la_bands, band := i.band, on = .(la_code)]

# Merge STPCD teacher pay
la_panel <- merge(la_panel, stpcd[, .(year, band, teacher_pay_mid)],
                  by = c("year", "band"), all.x = TRUE)

# Recompute comp_ratio where we have both teacher pay and private pay
# Definition: teacher/private (higher = teaching more attractive)
la_panel[!is.na(teacher_pay_mid) & !is.na(median_annual_pay),
         comp_ratio := teacher_pay_mid / median_annual_pay]

###############################################################################
# 3. Merge Vacancy Data
###############################################################################

cat("\n=== MERGING VACANCY DATA ===\n\n")

swc_file <- paste0(data_dir, "swc_vacancies_raw.csv")
if (file.exists(swc_file)) {
  swc <- fread(swc_file, showProgress = FALSE)

  # Filter to LA level
  swc_la <- swc[geographic_level == "Local authority"]

  # Get the vacancy rate column
  cat(sprintf("SWC columns: %s\n", paste(names(swc_la), collapse=", ")))

  # Filter to the relevant indicator
  if ("school_type" %in% names(swc_la)) {
    swc_total <- swc_la[school_type == "Total" | school_type == "State-funded secondary"]
  } else {
    swc_total <- swc_la
  }

  # Filter to Total state-funded schools, Total post grade
  swc_total <- swc_la[school_type == "Total state-funded schools" &
                        post_grade == "Total"]
  cat(sprintf("SWC Total rows: %d\n", nrow(swc_total)))

  # Extract vacancy rate
  swc_slim <- swc_total[, .(
    la_code = new_la_code,
    year = as.integer(substr(time_period, 1, 4)),
    vacancy_count = as.numeric(vacancy),
    vacancy_rate = as.numeric(rate)
  )]
  swc_slim <- swc_slim[!is.na(la_code) & la_code != ""]

  la_panel <- merge(la_panel, swc_slim, by = c("la_code", "year"), all.x = TRUE)
  cat(sprintf("Vacancy data merged: %d obs with vacancy_rate\n",
              sum(!is.na(la_panel$vacancy_rate))))
} else {
  cat("SWC file not found.\n")
}

###############################################################################
# 4. Create Analysis Variables
###############################################################################

cat("\n=== CREATING ANALYSIS VARIABLES ===\n\n")

# Numeric LA ID for FE
la_panel[, la_id := as.integer(as.factor(la_code))]

# Competitiveness terciles
la_panel[!is.na(comp_ratio), comp_tercile := cut(comp_ratio,
                                                  breaks = quantile(comp_ratio, c(0, 1/3, 2/3, 1)),
                                                  labels = c("Low", "Medium", "High"),
                                                  include.lowest = TRUE)]

# Baseline competitiveness (first year in panel per LA)
la_panel[, baseline_comp := comp_ratio[which.min(year)], by = la_code]

# Change in competitiveness (relative to 2018)
base_year <- min(la_panel$year, na.rm = TRUE)
la_panel[, comp_change := comp_ratio - baseline_comp]

cat("Panel summary:\n")
cat(sprintf("  Observations: %d\n", nrow(la_panel)))
cat(sprintf("  Unique LAs: %d\n", uniqueN(la_panel$la_code)))
cat(sprintf("  Years: %s\n", paste(sort(unique(la_panel$year)), collapse=", ")))
cat(sprintf("  Progress 8 coverage: %.1f%%\n",
            100 * mean(!is.na(la_panel$progress8))))
cat(sprintf("  Competitiveness coverage: %.1f%%\n",
            100 * mean(!is.na(la_panel$comp_ratio))))

# Save LA panel
fwrite(la_panel, paste0(data_dir, "la_panel.csv"))
cat(sprintf("\nLA panel saved: %s\n", paste0(data_dir, "la_panel.csv")))

###############################################################################
# 5. School-Level Panel (2023/24) for Academy DDD
###############################################################################

cat("\n=== BUILDING SCHOOL-LEVEL PANEL ===\n\n")

ks4_school <- fread(paste0(data_dir, "ks4_school_2324_raw.csv"), showProgress = FALSE)

# Filter to school level, total breakdown
ks4_school <- ks4_school[geographic_level == "School"]

# Filter to total/all pupils breakdown
if ("breakdown_topic" %in% names(ks4_school)) {
  ks4_school <- ks4_school[breakdown_topic == "Total"]
}

# Deduplicate: one row per school
ks4_school <- unique(ks4_school, by = "school_urn")
cat(sprintf("School-level obs (2023/24): %d\n", nrow(ks4_school)))

# Extract key variables
school_panel <- data.table(
  urn = ks4_school$school_urn,
  laestab = ks4_school$school_laestab,
  school_name = ks4_school$school_name,
  la_code = ks4_school$new_la_code,
  la_name = ks4_school$la_name,
  year = 2023L,
  school_type = ks4_school$establishment_type_group
)

# Progress 8 and Attainment 8
school_panel[, progress8 := as.numeric(ks4_school$avg_p8score)]
school_panel[, attainment8 := as.numeric(ks4_school$avg_att8)]
school_panel[, n_pupils := as.numeric(ks4_school$t_pupils)]

cat(sprintf("  Schools with P8: %d (%.1f%%)\n",
            sum(!is.na(school_panel$progress8)),
            100 * mean(!is.na(school_panel$progress8))))

# Classify as academy or maintained from school_type
cat(sprintf("  School types: %s\n",
            paste(unique(school_panel$school_type), collapse="; ")))

# Academy types include all academy converters, sponsors, free schools, UTCs, studios
academy_types <- c("Sponsored academies", "Converter academies", "Free schools",
                   "University technical colleges (UTCs)", "Studio schools",
                   "Converter academies - special school",
                   "Sponsored academies - special school",
                   "Free schools - special school", "CTCs")
maintained_types <- c("Community school", "Voluntary aided school",
                      "Foundation school", "Voluntary controlled school",
                      "Community special school", "Foundation special school",
                      "Non-maintained special schools")
# Exclude independent and FE
school_panel[, academy := fifelse(school_type %in% academy_types, 1L, 0L)]
school_panel[, maintained := fifelse(school_type %in% maintained_types, 1L, 0L)]
# Drop schools that are neither (independent, FE)
school_panel <- school_panel[academy == 1 | maintained == 1]

cat(sprintf("  Academies: %d (%.1f%%)\n",
            sum(school_panel$academy), 100 * mean(school_panel$academy)))

# Merge GIAS for FSM%
gias_file <- paste0(data_dir, "gias_raw.csv")
if (file.exists(gias_file)) {
  gias <- fread(gias_file, showProgress = FALSE,
                select = c("URN", "PercentageFSM", "PhaseOfEducation (name)",
                            "TypeOfEstablishment (name)"))
  setnames(gias, c("urn", "fsm_pct", "phase", "est_type"))
  gias[, urn := as.character(urn)]
  gias[, fsm_pct := as.numeric(fsm_pct)]
  school_panel[, urn := as.character(urn)]

  school_panel <- merge(school_panel, gias[, .(urn, fsm_pct)],
                        by = "urn", all.x = TRUE)
  cat(sprintf("  FSM merged: %d obs (%.1f%%)\n",
              sum(!is.na(school_panel$fsm_pct)),
              100 * mean(!is.na(school_panel$fsm_pct))))
}

# Merge competitiveness ratio
school_panel <- merge(school_panel,
                      comp_upper[year == 2023, .(la_code, comp_ratio,
                                                  median_annual_pay)],
                      by = "la_code", all.x = TRUE)

# Assign STPCD band
school_panel[, band := "rest_of_england"]
school_panel[la_bands, band := i.band, on = .(la_code)]

cat(sprintf("  Competitiveness merged: %d obs (%.1f%%)\n",
            sum(!is.na(school_panel$comp_ratio)),
            100 * mean(!is.na(school_panel$comp_ratio))))

# Create school_id
school_panel[, school_id := as.integer(as.factor(urn))]

cat(sprintf("\nSchool panel summary:\n"))
cat(sprintf("  Observations: %d\n", nrow(school_panel)))
cat(sprintf("  With P8 + comp_ratio: %d\n",
            sum(!is.na(school_panel$progress8) & !is.na(school_panel$comp_ratio))))
cat(sprintf("  Academies: %d\n", sum(school_panel$academy)))
cat(sprintf("  Maintained: %d\n", sum(school_panel$maintained)))

# Save school panel
fwrite(school_panel, paste0(data_dir, "school_panel.csv"))
cat(sprintf("\nSchool panel saved: %s\n", paste0(data_dir, "school_panel.csv")))

# Also save a combined "analysis_panel" for backward compatibility with other scripts
# This is the LA panel (main analysis dataset)
fwrite(la_panel, paste0(data_dir, "analysis_panel.csv"))

cat("\n=== PANEL CONSTRUCTION COMPLETE ===\n")
