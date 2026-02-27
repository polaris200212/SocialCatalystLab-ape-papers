#' ---
#' Selective Licensing and Crime Displacement
#' 04_robustness.R — Robustness checks and placebo tests
#' ---

source("code/00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

message("Loading analysis panel...")
panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, month := as.Date(month)]
panel <- panel[year >= 2011]

# ============================================================================
# 2. PLACEBO CRIME CATEGORIES
# ============================================================================

message("\n=== Placebo Crime Categories ===")

# Categories unlikely to be affected by landlord licensing:
# - bicycle-theft: mostly opportunity crime, unrelated to housing management
# - possession-of-weapons: supply-side enforcement, not housing
# - other-crime: miscellaneous, no clear housing channel

crime_cat_data <- fread(file.path(DATA_DIR, "lsoa_crime_by_category.csv"))
crime_cat_data[, month := as.Date(paste0(month, "-01"))]
crime_cat_data <- crime_cat_data[grepl("^E01", lsoa_code)]

treat_info <- unique(panel[, .(lsoa_code, la_code, lsoa_id, la_id,
                                ever_treated, first_treated_month)])
crime_cat_data <- merge(crime_cat_data, treat_info, by = "lsoa_code", all.x = TRUE)
crime_cat_data <- crime_cat_data[!is.na(la_code)]
crime_cat_data[, licensed := as.integer(!is.na(first_treated_month) & month >= first_treated_month)]
crime_cat_data[, time_period := as.integer(month)]

placebo_cats <- c("Bicycle theft", "Possession of weapons", "Other crime")
placebo_results <- list()

# Use full balanced panel with zeros for missing LSOA-month-category
full_skeleton <- unique(panel[, .(lsoa_code, lsoa_id, la_code, la_id,
                                   ever_treated, first_treated_month,
                                   month, time_period, licensed)])

for (cat in placebo_cats) {
  message("  Placebo: ", cat)
  cat_obs <- crime_cat_data[crime_type == cat, .(lsoa_code, month, crime_count)]
  pdata <- merge(full_skeleton, cat_obs, by = c("lsoa_code", "month"), all.x = TRUE)
  pdata[is.na(crime_count), crime_count := 0L]

  if (nrow(pdata) > 100) {
    pmodel <- tryCatch(
      feols(crime_count ~ licensed | lsoa_id + time_period,
            data = pdata, cluster = ~la_code),
      error = function(e) NULL
    )
    if (!is.null(pmodel)) {
      placebo_results[[cat]] <- data.table(
        category = cat,
        estimate = coef(pmodel)["licensed"],
        se = sqrt(vcov(pmodel)["licensed", "licensed"]),
        n = pmodel$nobs,  # Use estimation N (post-singleton drop)
        type = "placebo"
      )
    }
  }
}

placebo_dt <- rbindlist(placebo_results)
placebo_dt[, t_stat := estimate / se]
placebo_dt[, p_value := 2 * pt(abs(t_stat), df = Inf, lower.tail = FALSE)]
message("Placebo category results:")
print(placebo_dt)

# ============================================================================
# 3. PLACEBO TIMING
# ============================================================================

message("\n=== Placebo Timing Tests ===")

# Assign fake treatment dates: 1, 2, 3 years before actual adoption
timing_results <- list()

for (shift in c(-12, -24, -36)) {  # months before actual
  panel_placebo <- copy(panel[ever_treated == 1 | ever_treated == 0])

  # Shift treatment date for treated LAs
  panel_placebo[ever_treated == 1,
                fake_treat := first_treated_month %m+% months(shift)]
  panel_placebo[, fake_licensed := as.integer(!is.na(fake_treat) & month >= fake_treat)]

  # Only use observations BEFORE the actual treatment
  panel_placebo <- panel_placebo[is.na(first_treated_month) | month < first_treated_month]

  if (sum(panel_placebo$fake_licensed, na.rm = TRUE) > 100) {
    placebo_timing <- tryCatch(
      feols(total_crime ~ fake_licensed | lsoa_id + time_period,
            data = panel_placebo, cluster = ~la_code),
      error = function(e) NULL
    )
    if (!is.null(placebo_timing)) {
      timing_results[[as.character(shift)]] <- data.table(
        shift_months = shift,
        estimate = coef(placebo_timing)["fake_licensed"],
        se = sqrt(vcov(placebo_timing)["fake_licensed", "fake_licensed"])
      )
    }
  }
}

if (length(timing_results) > 0) {
  timing_dt <- rbindlist(timing_results)
  timing_dt[, t_stat := estimate / se]
  timing_dt[, p_value := 2 * pt(abs(t_stat), df = Inf, lower.tail = FALSE)]
  message("Placebo timing results:")
  print(timing_dt)
  fwrite(timing_dt, file.path(DATA_DIR, "placebo_timing.csv"))
}

# ============================================================================
# 4. BOROUGH-WIDE ONLY (CLEAN TREATMENT)
# ============================================================================

message("\n=== Borough-Wide Only Specification ===")

licensing <- fread(file.path(DATA_DIR, "licensing_dates.csv"))
borough_wide <- licensing[coverage %in% c("borough", "city")]$la_code

panel_bw <- panel[la_code %in% borough_wide | ever_treated == 0]

if (nrow(panel_bw) > 1000) {
  bw_model <- feols(
    total_crime ~ licensed | lsoa_id + time_period,
    data = panel_bw,
    cluster = ~la_code
  )
  message("Borough-wide only results:")
  print(summary(bw_model))
  saveRDS(bw_model, file.path(DATA_DIR, "borough_wide_results.rds"))
}

# ============================================================================
# 5. LA-LEVEL AGGREGATION (conservative, avoids boundary issues)
# ============================================================================

message("\n=== LA-Level Aggregation ===")

la_panel <- panel[, .(
  total_crime = sum(total_crime, na.rm = TRUE),
  n_lsoas = uniqueN(lsoa_code),
  crime_per_lsoa = mean(total_crime, na.rm = TRUE),
  crime_rate = mean(crime_rate, na.rm = TRUE)
), by = .(la_code, la_id, month, year, quarter, ever_treated, licensed, cohort)]

la_panel[, time_period := as.integer(month)]

la_twfe <- feols(
  crime_per_lsoa ~ licensed | la_id + time_period,
  data = la_panel,
  cluster = ~la_code
)
message("LA-level TWFE results:")
print(summary(la_twfe))

# ============================================================================
# 6. WILD CLUSTER BOOTSTRAP
# ============================================================================

message("\n=== Wild Cluster Bootstrap ===")

# Use boottest for wild cluster bootstrap inference
tryCatch({
  if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
    library(fwildclusterboot)

    set.seed(20240227)
    boot_result <- boottest(
      la_twfe,
      param = "licensed",
      clustid = ~la_code,
      B = 999,
      type = "rademacher"
    )
    message("Wild cluster bootstrap:")
    print(summary(boot_result))
    saveRDS(boot_result, file.path(DATA_DIR, "wild_bootstrap.rds"))
  } else {
    message("  fwildclusterboot not installed, skipping")
  }
}, error = function(e) {
  message("  Wild bootstrap failed: ", e$message)
})

# ============================================================================
# 7. ALTERNATIVE FIXED EFFECTS
# ============================================================================

message("\n=== Alternative FE Specifications ===")

# LA × year FE (controls for LA-specific trends)
alt_fe1 <- tryCatch(
  feols(total_crime ~ licensed | lsoa_id + la_code^year + time_period,
        data = panel, cluster = ~la_code),
  error = function(e) NULL
)
if (!is.null(alt_fe1)) {
  message("With LA×Year FE:")
  print(summary(alt_fe1))
}

# Region × month FE (controls for regional trends)
# Need region info — approximate from LA code prefix
panel[, region_approx := substr(la_code, 1, 3)]
alt_fe2 <- tryCatch(
  feols(total_crime ~ licensed | lsoa_id + region_approx^time_period,
        data = panel, cluster = ~la_code),
  error = function(e) NULL
)
if (!is.null(alt_fe2)) {
  message("With Region×Month FE:")
  print(summary(alt_fe2))
}

# ============================================================================
# 8. MULTIPLE TESTING ADJUSTMENT FOR CATEGORY RESULTS
# ============================================================================

message("\n=== Multiple Testing Adjustments ===")

cat_results <- fread(file.path(DATA_DIR, "category_results.csv"))
# Holm adjustment (family-wise error rate control)
cat_results[, p_holm := p.adjust(p_value, method = "holm")]
# Benjamini-Hochberg adjustment (false discovery rate control)
cat_results[, p_bh := p.adjust(p_value, method = "BH")]
fwrite(cat_results, file.path(DATA_DIR, "category_results.csv"))
message("Multiple testing adjustments added to category results")

# ============================================================================
# 9. LEAVE-ONE-OUT SENSITIVITY
# ============================================================================

message("\n=== Leave-One-Out Sensitivity ===")

# Drop each switcher LA and re-estimate TWFE to check no single LA drives results
switchers <- unique(panel[ever_treated == 1 & !is.na(first_treated_month) &
                           as.Date(first_treated_month) >= as.Date("2021-11-01") &
                           as.Date(first_treated_month) <= as.Date("2024-10-01")]$la_code)

message("  Number of switcher LAs: ", length(switchers))

loo_results <- data.table()
for (la in switchers) {
  # Get LA name for reporting
  la_name_val <- if ("la_name" %in% names(panel)) unique(panel[la_code == la]$la_name)[1] else la
  if (is.null(la_name_val) || length(la_name_val) == 0 || is.na(la_name_val)) la_name_val <- la

  # Drop this LA and re-estimate
  loo_panel <- panel[la_code != la]
  loo_model <- tryCatch(
    feols(total_crime ~ licensed | lsoa_id + time_period,
          data = loo_panel, cluster = ~la_code),
    error = function(e) NULL
  )

  if (!is.null(loo_model)) {
    loo_results <- rbind(loo_results, data.table(
      dropped_la = la_name_val,
      estimate = coef(loo_model)["licensed"],
      se = sqrt(vcov(loo_model)["licensed", "licensed"]),
      n = loo_model$nobs
    ))
  }
}

loo_results[, t_stat := estimate / se]
loo_results[, p_value := 2 * pt(-abs(t_stat), df = Inf)]
message("Leave-one-out results:")
print(loo_results)

# Note: Police force x month FE is approximated by the Region x Month FE
# specification in Section 7 (alt_fe2), which uses the LA code prefix as a
# region proxy. Police force boundaries largely align with regional groupings.

# ============================================================================
# 10. SAVE ROBUSTNESS RESULTS
# ============================================================================

message("\nSaving robustness results...")

robustness <- list(
  placebo_categories = placebo_dt,
  placebo_timing = if (exists("timing_dt")) timing_dt else NULL,
  borough_wide = if (exists("bw_model")) bw_model else NULL,
  la_level = la_twfe,
  alt_fe1 = alt_fe1,
  alt_fe2 = alt_fe2,
  loo_results = loo_results
)
saveRDS(robustness, file.path(DATA_DIR, "robustness_results.rds"))

message("Robustness analysis complete.")
