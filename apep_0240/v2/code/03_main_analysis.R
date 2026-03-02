## 03_main_analysis.R — Primary regressions
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"
panel <- fread(paste0(data_dir, "panel_annual.csv"))

cat("Loaded panel:", nrow(panel), "county-years\n")
cat("States:", n_distinct(panel$state_abbr), "\n")
cat("Counties:", n_distinct(panel$fips), "\n")

# ============================================================================
# 1. SUMMARY STATISTICS
# ============================================================================
cat("\n--- Summary Statistics ---\n")

sumstats <- panel %>%
  group_by(treated) %>%
  summarize(
    n_counties = n_distinct(fips),
    n_states = n_distinct(state_abbr),
    mean_zhvi = mean(zhvi, na.rm = TRUE),
    sd_zhvi = sd(zhvi, na.rm = TRUE),
    mean_flood_decl = mean(n_flood_decl_pre, na.rm = TRUE),
    pct_high_flood = mean(high_flood, na.rm = TRUE),
    .groups = "drop"
  )
print(sumstats)

# ============================================================================
# 2. PRIMARY SPECIFICATION: Triple-Difference (DDD)
# ============================================================================
cat("\n--- Primary DDD Regression ---\n")

# Model 1: Basic DDD with county + state-year FE
m1 <- feols(log_zhvi ~ post_x_flood + post + high_flood |
              fips + state_abbr^year,
            data = panel, cluster = ~state_abbr)

# Model 2: DDD with county + state-year FE (dropping absorbed terms)
m2 <- feols(log_zhvi ~ post_x_flood |
              fips + state_abbr^year,
            data = panel, cluster = ~state_abbr)

# Model 3: Using any_flood instead of high_flood
panel <- panel %>%
  mutate(post_x_anyflood = post * any_flood)

m3 <- feols(log_zhvi ~ post_x_anyflood |
              fips + state_abbr^year,
            data = panel, cluster = ~state_abbr)

# Model 4: Continuous flood exposure (intensive margin)
panel <- panel %>%
  mutate(post_x_flood_count = post * n_flood_decl_pre)

m4 <- feols(log_zhvi ~ post_x_flood_count |
              fips + state_abbr^year,
            data = panel, cluster = ~state_abbr)

cat("\nModel 1 (DDD basic):\n")
print(summary(m1))

cat("\nModel 2 (DDD absorbed):\n")
print(summary(m2))

cat("\nModel 3 (Any flood):\n")
print(summary(m3))

cat("\nModel 4 (Continuous exposure):\n")
print(summary(m4))

# ============================================================================
# 3. EVENT STUDY — Dynamic Treatment Effects
# ============================================================================
cat("\n--- Event Study ---\n")

# Create relative time indicators for treated counties
# Only for treated states (year_adopted > 0)
event_panel <- panel %>%
  filter(year_adopted > 0) %>%
  mutate(
    rel_year = year - year_adopted,
    # Bin extreme values
    rel_year_binned = case_when(
      rel_year <= -6 ~ -6L,
      rel_year >= 8 ~ 8L,
      TRUE ~ as.integer(rel_year)
    )
  )

# Event study: effect of disclosure on flood vs non-flood counties over time
es_model <- feols(log_zhvi ~ i(rel_year_binned, high_flood, ref = -1) |
                    fips + state_abbr^year,
                  data = event_panel, cluster = ~state_abbr)

cat("\nEvent Study Model:\n")
print(summary(es_model))

# ============================================================================
# 4. CALLAWAY-SANT'ANNA (CS-DiD)
# ============================================================================
cat("\n--- Callaway-Sant'Anna DiD ---\n")

# Prepare data for CS-DiD
# Need: group (cohort year), time, id, outcome
cs_data <- panel %>%
  filter(high_flood == 1 | any_flood == 0) %>%  # Compare high-flood vs no-flood
  mutate(
    # CS requires group = first treatment year (0 = never treated)
    group = cohort,
    id = county_id,
    time = year,
    Y = log_zhvi
  ) %>%
  filter(!is.na(Y), !is.infinite(Y)) %>%
  # CS-DiD needs balanced panel — keep years with good coverage
  filter(year >= 2000, year <= 2023)

# Check panel balance
panel_check <- cs_data %>%
  group_by(id) %>%
  summarize(n_years = n_distinct(time), .groups = "drop")

# Keep counties that appear in at least 20 of 24 years
balanced_ids <- panel_check %>% filter(n_years >= 20) %>% pull(id)
cs_data_bal <- cs_data %>% filter(id %in% balanced_ids)

cat("CS-DiD panel:", n_distinct(cs_data_bal$id), "counties,",
    n_distinct(cs_data_bal$time), "years,",
    n_distinct(cs_data_bal$group[cs_data_bal$group > 0]), "cohorts.\n")

# Only run CS-DiD if we have enough variation
n_cohorts <- n_distinct(cs_data_bal$group[cs_data_bal$group > 0])
if (n_cohorts >= 3 && n_distinct(cs_data_bal$id) >= 50) {
  cs_result <- tryCatch({
    att_gt(
      yname = "Y",
      tname = "time",
      idname = "id",
      gname = "group",
      data = as.data.frame(cs_data_bal),
      control_group = "nevertreated",
      anticipation = 0,
      est_method = "reg",
      clustervars = "id",
      base_period = "universal"
    )
  }, error = function(e) {
    cat("CS-DiD error:", e$message, "\n")
    NULL
  })

  if (!is.null(cs_result)) {
    cat("\nCS-DiD Group-Time ATTs:\n")
    agg_overall <- aggte(cs_result, type = "simple")
    cat("Overall ATT:", round(agg_overall$overall.att, 4),
        "(SE:", round(agg_overall$overall.se, 4), ")\n")

    # Dynamic effects
    agg_dynamic <- aggte(cs_result, type = "dynamic",
                         min_e = -5, max_e = 8)

    # Save CS results
    saveRDS(cs_result, paste0(data_dir, "cs_result.rds"))
    saveRDS(agg_dynamic, paste0(data_dir, "cs_dynamic.rds"))
    saveRDS(agg_overall, paste0(data_dir, "cs_overall.rds"))
  }
} else {
  cat("Insufficient variation for CS-DiD (", n_cohorts, "cohorts,",
      n_distinct(cs_data_bal$id), "counties).\n")
  cat("Proceeding with TWFE results only.\n")
}

# ============================================================================
# 5. SAVE RESULTS
# ============================================================================

# Save regression objects
saveRDS(list(m1 = m1, m2 = m2, m3 = m3, m4 = m4),
        paste0(data_dir, "main_models.rds"))
saveRDS(es_model, paste0(data_dir, "event_study_model.rds"))
saveRDS(sumstats, paste0(data_dir, "summary_stats.rds"))

cat("\n============================================\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("Key results:\n")
cat("  DDD coefficient (post × high_flood):", round(coef(m2)["post_x_flood"], 4), "\n")
cat("  Standard error:", round(se(m2)["post_x_flood"], 4), "\n")
cat("  p-value:", round(fixest::pvalue(m2)["post_x_flood"], 4), "\n")
