###############################################################################
# 02_clean_data.R — Construct analysis panel
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

###############################################################################
# 1. Load raw data
###############################################################################

# Use education-authority-aligned ASHE data (with county aggregates)
ashe_edu_file <- paste0(data_dir, "ashe_education_la.csv")
if (file.exists(ashe_edu_file)) {
  ashe <- fread(ashe_edu_file)
  cat("Using education-authority-aligned ASHE data.\n")
} else {
  ashe <- fread(paste0(data_dir, "ashe_earnings_by_la.csv"))
  cat("Using raw ASHE data (district level).\n")
}
ks4   <- fread(paste0(data_dir, "ks4_la_performance.csv"))
stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))

###############################################################################
# 2. Clean ASHE earnings — private-sector proxy
###############################################################################

cat("Cleaning ASHE earnings...\n")

ashe_clean <- ashe[!is.na(median_annual_pay) & median_annual_pay > 0,
                   .(la_code, la_name, year, median_annual_pay)]
ashe_clean <- unique(ashe_clean, by = c("la_code", "year"))

cat(sprintf("  ASHE: %d rows, %d LAs, years %d-%d\n",
            nrow(ashe_clean), uniqueN(ashe_clean$la_code),
            min(ashe_clean$year), max(ashe_clean$year)))

###############################################################################
# 3. Clean KS4 GCSE data
###############################################################################

cat("Cleaning KS4 GCSE data...\n")

# Filter to LA level, Total breakdown, Total sex
ks4_la <- ks4[geographic_level == "Local authority" &
              breakdown_topic == "Total" &
              sex == "Total"]

# Extract year (first 4 digits of time_period)
ks4_la[, year := as.integer(substr(as.character(time_period), 1, 4))]

# Create clean outcome variables
ks4_la[, att8 := as.numeric(attainment8_average)]

# Progress 8 (available from 2016/17 onwards)
p8_col <- names(ks4_la)[grepl("progress8_average", names(ks4_la))]
if (length(p8_col) > 0) {
  ks4_la[, prog8 := as.numeric(get(p8_col[1]))]
}

# Pupil count
ks4_la[, n_pupils := as.numeric(pupil_count)]

# School count
ks4_la[, n_schools := as.numeric(school_count)]

# English+Maths basics pass rate
ks4_la[, basics_94 := as.numeric(engmath_94_percent)]
ks4_la[, basics_95 := as.numeric(engmath_95_percent)]

# Select and de-duplicate
ks4_clean <- ks4_la[, .(la_code = new_la_code, la_name, year,
                        att8, prog8, n_pupils, n_schools,
                        basics_94, basics_95)]
ks4_clean <- ks4_clean[!is.na(la_code) & la_code != ""]
ks4_clean <- unique(ks4_clean, by = c("la_code", "year"))

# Drop COVID-affected years (2019/20, 2020/21) — no real exams
ks4_clean <- ks4_clean[!(year %in% c(2019, 2020))]

cat(sprintf("  KS4: %d rows, %d LAs, years %s\n",
            nrow(ks4_clean), uniqueN(ks4_clean$la_code),
            paste(sort(unique(ks4_clean$year)), collapse = ",")))

###############################################################################
# 4. KS4 by FSM status (for equity analysis)
###############################################################################

cat("Extracting FSM-stratified outcomes...\n")

ks4_fsm <- ks4[geographic_level == "Local authority" &
               breakdown_topic == "FSM status" &
               sex == "Total" &
               fsm_status %in% c("FSM eligible", "Not known to be FSM eligible")]

ks4_fsm[, year := as.integer(substr(as.character(time_period), 1, 4))]
ks4_fsm[, att8 := as.numeric(attainment8_average)]

ks4_fsm_clean <- ks4_fsm[, .(la_code = new_la_code, year, fsm_status, att8)]
ks4_fsm_clean <- ks4_fsm_clean[!is.na(la_code) & la_code != "" & !is.na(att8)]
ks4_fsm_clean <- ks4_fsm_clean[!(year %in% c(2019, 2020))]

# Compute FSM achievement gap within LA-year
ks4_gap <- dcast(ks4_fsm_clean, la_code + year ~ fsm_status,
                 value.var = "att8")
setnames(ks4_gap, c("la_code", "year", "att8_fsm", "att8_nonfsm"))
ks4_gap[, fsm_gap := att8_nonfsm - att8_fsm]

cat(sprintf("  FSM gap data: %d LA-year obs\n", nrow(ks4_gap)))

###############################################################################
# 5. Merge into analysis panel
###############################################################################

cat("Building analysis panel...\n")

# Start from ASHE as backbone
panel <- merge(ashe_clean, stpcd[, .(year, teacher_pay_mid, m1_rest)],
               by = "year", all.x = TRUE)

# Teacher pay competitiveness ratio
panel[, comp_ratio := teacher_pay_mid / median_annual_pay]
panel[, log_comp := log(comp_ratio)]

# Merge KS4 outcomes
panel <- merge(panel, ks4_clean, by = c("la_code", "year"), all.x = TRUE,
               suffixes = c("", ".ks4"))

# Merge FSM gap
panel <- merge(panel, ks4_gap[, .(la_code, year, fsm_gap, att8_fsm, att8_nonfsm)],
               by = c("la_code", "year"), all.x = TRUE)

# Remove LA name duplicates
if ("la_name.ks4" %in% names(panel)) {
  panel[, la_name := fifelse(is.na(la_name), la_name.ks4, la_name)]
  panel[, la_name.ks4 := NULL]
}

###############################################################################
# 6. Construct treatment variable
###############################################################################

cat("Constructing treatment variable...\n")

# Treatment: LAs with the largest competitiveness DECLINE (2010 to 2019)
comp_2010 <- panel[year == 2010, .(la_code, comp_2010 = comp_ratio)]
comp_2019 <- panel[year == 2019, .(la_code, comp_2019 = comp_ratio)]
treat_df <- merge(comp_2010, comp_2019, by = "la_code")
treat_df[, comp_change := comp_2019 - comp_2010]
treat_df[, comp_pct_change := (comp_2019 - comp_2010) / comp_2010 * 100]

# Binary treatment: top quartile of competitiveness DECLINE
# Most negative comp_change = biggest decline in teacher attractiveness
q25 <- quantile(treat_df$comp_change, 0.25, na.rm = TRUE)
treat_df[, treated := fifelse(comp_change <= q25, 1L, 0L)]

cat(sprintf("  Q25 threshold: %.4f\n", q25))
cat(sprintf("  Treated (high shock): %d LAs\n", sum(treat_df$treated == 1)))
cat(sprintf("  Control (low shock): %d LAs\n", sum(treat_df$treated == 0)))

# Merge treatment
panel <- merge(panel, treat_df[, .(la_code, comp_change, comp_pct_change, treated)],
               by = "la_code", all.x = TRUE)

# Time indicators
panel[, post := fifelse(year >= 2011, 1L, 0L)]
panel[, austerity := fifelse(year >= 2011 & year <= 2019, 1L, 0L)]

# Numeric LA id for fixed effects
panel[, la_id := as.integer(factor(la_code))]

###############################################################################
# 7. Baseline covariates (2010)
###############################################################################

cat("Constructing baseline covariates...\n")

baseline <- panel[year == 2010, .(
  la_code,
  base_pay = median_annual_pay,
  base_comp = comp_ratio,
  base_att8 = att8,
  base_pupils = n_pupils
)]

# Urbanity proxy: LAs with higher baseline pay = more urban/expensive
baseline[, urban_proxy := fifelse(base_pay > median(base_pay, na.rm = TRUE),
                                  1L, 0L)]

# Region from LA code prefix
baseline[, region := fcase(
  grepl("^E06", la_code), "Unitary",
  grepl("^E07", la_code), "District",
  grepl("^E08", la_code), "Metropolitan",
  grepl("^E09", la_code), "London Borough",
  default = "Other"
)]

panel <- merge(panel, baseline[, .(la_code, base_pay, base_comp,
                                   base_att8, urban_proxy, region)],
               by = "la_code", all.x = TRUE)

###############################################################################
# 8. Save final panel
###############################################################################

fwrite(panel, paste0(data_dir, "analysis_panel.csv"))
fwrite(treat_df, paste0(data_dir, "treatment_assignment.csv"))

# Summary
cat("\n=== ANALYSIS PANEL ===\n")
cat(sprintf("  Total rows: %d\n", nrow(panel)))
cat(sprintf("  LAs: %d\n", uniqueN(panel$la_code)))
cat(sprintf("  Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("  Treated LAs: %d\n",
            uniqueN(panel[treated == 1]$la_code)))
cat(sprintf("  Control LAs: %d\n",
            uniqueN(panel[treated == 0]$la_code)))
cat(sprintf("  Att8 non-missing: %d obs\n",
            sum(!is.na(panel$att8))))
cat(sprintf("  FSM gap non-missing: %d obs\n",
            sum(!is.na(panel$fsm_gap))))

# Quick preview
cat("\nPanel head:\n")
print(head(panel[!is.na(att8), .(la_code, year, median_annual_pay,
                                  comp_ratio, att8, treated)]))

cat("\nCompetitiveness ratio by year and treatment:\n")
print(panel[!is.na(treated), .(
  mean_comp = round(mean(comp_ratio, na.rm = TRUE), 3),
  mean_att8 = round(mean(att8, na.rm = TRUE), 1),
  n_la = uniqueN(la_code)
), by = .(year, treated)][order(year, treated)])
