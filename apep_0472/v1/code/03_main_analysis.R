#' ---
#' Selective Licensing and Crime Displacement
#' 03_main_analysis.R — Main DiD estimation
#' ---

source("code/00_packages.R")

# ============================================================================
# 1. LOAD ANALYSIS PANEL
# ============================================================================

message("Loading analysis panel...")
panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, month := as.Date(month)]

message("  Observations: ", format(nrow(panel), big.mark = ","))
message("  Treated LAs:  ", length(unique(panel[ever_treated == 1]$la_code)))

# Filter to post-2012 to ensure pre-treatment periods for first cohort (2013)
panel <- panel[year >= 2011]

# ============================================================================
# 2. TWFE DiD (BASELINE — acknowledging potential bias)
# ============================================================================

message("\n=== TWFE DiD (baseline) ===")

# Basic TWFE specification
twfe_basic <- feols(
  total_crime ~ licensed | lsoa_id + time_period,
  data = panel,
  cluster = ~la_code
)
summary(twfe_basic)

# TWFE with crime rate as outcome
twfe_rate <- feols(
  crime_rate ~ licensed | lsoa_id + time_period,
  data = panel,
  cluster = ~la_code
)
summary(twfe_rate)

# ============================================================================
# 3. EVENT STUDY (TWFE — for visual pre-trends check)
# ============================================================================

message("\n=== Event Study ===")

# Create relative time bins (quarterly, capped at -12 to +12 quarters)
panel[, rel_quarter := floor(rel_time / 3)]
panel[, rel_quarter := pmin(pmax(rel_quarter, -12), 12)]
panel[is.na(rel_quarter), rel_quarter := NA]

# Event study with relative quarter dummies (ref: -1)
es_data <- panel[ever_treated == 1 | ever_treated == 0]  # all units
es_data[ever_treated == 0, rel_quarter := NA]  # never-treated have no relative time

# Using fixest sunab()-style event study
# First: create integer cohort and time variables for sunab
panel[, cohort_year := fifelse(ever_treated == 1, year(first_treated_month), 10000L)]
panel[, year_month_int := as.integer(format(month, "%Y%m"))]

# Event study with fixest
es_twfe <- feols(
  total_crime ~ i(rel_quarter, ever_treated, ref = -1) | lsoa_id + time_period,
  data = panel[!is.na(rel_quarter) | ever_treated == 0],
  cluster = ~la_code
)

# Save event study coefficients
es_coefs <- as.data.table(broom::tidy(es_twfe, conf.int = TRUE))
fwrite(es_coefs, file.path(DATA_DIR, "event_study_coefs.csv"))

# Joint pre-trend test
pre_coefs <- es_coefs[grepl("rel_quarter::-", term) & !grepl("-1:", term)]
if (nrow(pre_coefs) > 0) {
  joint_f <- wald(es_twfe, paste0("rel_quarter::", seq(-12, -2), ":ever_treated"))
  message("Joint pre-trend F-test p-value: ", round(joint_f$p, 4))
}

# ============================================================================
# 4. CALLAWAY & SANT'ANNA (2021) — Heterogeneity-Robust DiD
# ============================================================================

message("\n=== Callaway & Sant'Anna DiD ===")

# Prepare data for did package
# Need: id (LSOA), time (period), cohort (first treatment period), outcome
cs_data <- panel[, .(
  id = lsoa_id,
  time = as.integer(format(month, "%Y%m")),
  cohort = fifelse(ever_treated == 1, as.integer(format(first_treated_month, "%Y%m")), 0L),
  y = total_crime,
  y_rate = crime_rate,
  la = la_id
)]

# Aggregate to LA-quarter for computational feasibility (LSOA-month is too large)
la_quarter <- panel[, .(
  total_crime = sum(total_crime, na.rm = TRUE),
  n_lsoas = uniqueN(lsoa_code),
  crime_per_lsoa = mean(total_crime, na.rm = TRUE),
  crime_rate = mean(crime_rate, na.rm = TRUE),
  population = mean(population, na.rm = TRUE)
), by = .(la_code, la_id, year, quarter, ever_treated, cohort)]

la_quarter[, time := year * 4 + quarter]

# Get first_treated_month for each LA and merge
la_first <- panel[ever_treated == 1, .(first_treated_month = first_treated_month[1]), by = la_code]
la_quarter <- merge(la_quarter, la_first, by = "la_code", all.x = TRUE)
la_quarter[!is.na(first_treated_month),
           cohort_q := year(first_treated_month) * 4 + quarter(first_treated_month)]
la_quarter[is.na(first_treated_month), cohort_q := 0L]

# Run CS-DiD at LA-quarter level
tryCatch({
  cs_out <- att_gt(
    yname  = "crime_per_lsoa",
    tname  = "time",
    idname = "la_id",
    gname  = "cohort_q",
    data   = as.data.frame(la_quarter),
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "dr",
    base_period = "varying"
  )

  message("CS-DiD ATT(g,t) results:")
  print(summary(cs_out))

  # Aggregate to event-study
  cs_es <- aggte(cs_out, type = "dynamic", min_e = -8, max_e = 8)
  message("\nCS-DiD Event Study:")
  print(summary(cs_es))

  # Aggregate to simple ATT
  cs_att <- aggte(cs_out, type = "simple")
  message("\nCS-DiD Simple ATT:")
  print(summary(cs_att))

  # Save results
  saveRDS(cs_out, file.path(DATA_DIR, "cs_did_results.rds"))
  saveRDS(cs_es, file.path(DATA_DIR, "cs_did_event_study.rds"))
  saveRDS(cs_att, file.path(DATA_DIR, "cs_did_att.rds"))

}, error = function(e) {
  message("CS-DiD failed: ", e$message)
  message("Falling back to TWFE estimates only")
})

# ============================================================================
# 5. SUN & ABRAHAM (2021) — Interaction-Weighted Estimator
# ============================================================================

message("\n=== Sun & Abraham DiD ===")

# Using fixest's sunab() function
sa_did <- tryCatch({
  feols(
    crime_per_lsoa ~ sunab(cohort_q, time) | la_id + time,
    data = la_quarter[cohort_q > 0 | ever_treated == 0],
    cluster = ~la_code
  )
}, error = function(e) {
  message("Sun-Abraham failed: ", e$message)
  NULL
})

if (!is.null(sa_did)) {
  message("Sun-Abraham ATT:")
  print(summary(sa_did))
  saveRDS(sa_did, file.path(DATA_DIR, "sa_did_results.rds"))
}

# ============================================================================
# 6. CRIME CATEGORY DECOMPOSITION
# ============================================================================

message("\n=== Crime Category Decomposition ===")

# Load category data
crime_cat_data <- fread(file.path(DATA_DIR, "lsoa_crime_by_category.csv"))
crime_cat_data[, month := as.Date(paste0(month, "-01"))]
crime_cat_data <- crime_cat_data[grepl("^E01", lsoa_code)]

# Merge treatment info
treat_info <- unique(panel[, .(lsoa_code, la_code, lsoa_id, la_id,
                                ever_treated, first_treated_month, cohort)])
crime_cat_data <- merge(crime_cat_data, treat_info, by = "lsoa_code", all.x = TRUE)
crime_cat_data <- crime_cat_data[!is.na(la_code)]

# Add treatment status
crime_cat_data[, licensed := as.integer(!is.na(first_treated_month) & month >= first_treated_month)]
crime_cat_data[, time_period := as.integer(month)]

# Run TWFE for each crime category
# IMPORTANT: Use full balanced panel with zeros for missing LSOA-month-category
categories <- c("Anti-social behaviour", "Violence and sexual offences", "Burglary",
                 "Criminal damage and arson", "Other theft", "Shoplifting",
                 "Public order", "Drugs", "Robbery", "Vehicle crime")

# Get the full LSOA-month skeleton from the main panel
full_skeleton <- unique(panel[, .(lsoa_code, lsoa_id, la_code, la_id,
                                   ever_treated, first_treated_month, cohort,
                                   month, time_period, licensed)])

cat_results <- list()
for (cat in categories) {
  message("  Category: ", cat)
  cat_obs <- crime_cat_data[crime_type == cat, .(lsoa_code, month, crime_count)]
  # Merge onto full skeleton — missing = zero crime for this category
  cat_data <- merge(full_skeleton, cat_obs, by = c("lsoa_code", "month"), all.x = TRUE)
  cat_data[is.na(crime_count), crime_count := 0L]

  if (nrow(cat_data) > 100) {
    cat_model <- tryCatch({
      feols(crime_count ~ licensed | lsoa_id + time_period,
            data = cat_data, cluster = ~la_code)
    }, error = function(e) NULL)

    if (!is.null(cat_model)) {
      cat_results[[cat]] <- data.table(
        category = cat,
        estimate = coef(cat_model)["licensed"],
        se = sqrt(vcov(cat_model)["licensed", "licensed"]),
        n = cat_model$nobs  # Use estimation N (post-singleton drop)
      )
      cat_results[[cat]][, t_stat := estimate / se]
      cat_results[[cat]][, p_value := 2 * pt(abs(t_stat), df = Inf, lower.tail = FALSE)]
    }
  }
}

cat_results_dt <- rbindlist(cat_results)
message("\nCrime Category Results:")
print(cat_results_dt[order(p_value)])
fwrite(cat_results_dt, file.path(DATA_DIR, "category_results.csv"))

# ============================================================================
# 7. SAVE ALL MAIN RESULTS
# ============================================================================

message("\nSaving all main results...")

# Create results summary
results <- list(
  twfe_basic = twfe_basic,
  twfe_rate = twfe_rate,
  es_twfe = es_twfe,
  category_results = cat_results_dt
)
saveRDS(results, file.path(DATA_DIR, "main_results.rds"))

message("Main analysis complete.")
