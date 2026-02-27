###############################################################################
# 04_robustness.R — Robustness checks
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
panel <- read_csv(file.path(DATA_DIR, "analysis_panel.csv"), show_col_types = FALSE)

###############################################################################
# 1. Bacon Decomposition (diagnose TWFE bias)
###############################################################################

cat("\n=== Bacon Decomposition ===\n")

if (requireNamespace("bacondecomp", quietly = TRUE)) {
  library(bacondecomp)

  # Balance panel for Bacon decomposition
  panel_balanced <- panel %>%
    group_by(la_id) %>%
    filter(n() == 10) %>%  # Keep LAs with all 10 years
    ungroup()

  cat("Balanced panel for Bacon:", nrow(panel_balanced), "obs,",
      n_distinct(panel_balanced$la_id), "LAs\n")

  tryCatch({
    bacon_se <- bacon(se_share ~ treated, data = panel_balanced,
                      id_var = "la_id", time_var = "year")
    cat("Bacon decomposition for self-employment share:\n")
    print(summary(bacon_se))
    write_csv(bacon_se, file.path(TAB_DIR, "bacon_decomp.csv"))
  }, error = function(e) {
    cat("Bacon decomposition failed:", conditionMessage(e), "\n")
  })
} else {
  cat("bacondecomp not installed, skipping.\n")
}

###############################################################################
# 2. TWFE with region × year trends
###############################################################################

cat("\n=== TWFE with region trends ===\n")

# Extract region from LA code (first letter indicates country, E=England)
panel <- panel %>%
  mutate(
    country = case_when(
      str_starts(la_code, "E") ~ "England",
      str_starts(la_code, "S") ~ "Scotland",
      str_starts(la_code, "W") ~ "Wales",
      str_starts(la_code, "N") ~ "NIreland",
      TRUE ~ "Other"
    ),
    # Broad region from LA code prefix
    region = case_when(
      str_starts(la_code, "E06") ~ "UA",
      str_starts(la_code, "E07") ~ "NMD",
      str_starts(la_code, "E08") ~ "Met",
      str_starts(la_code, "E09") ~ "London",
      str_starts(la_code, "S") ~ "Scotland",
      str_starts(la_code, "W") ~ "Wales",
      TRUE ~ "Other"
    )
  )

panel <- panel %>% mutate(region_id = as.integer(factor(region)))
twfe_region <- feols(se_share ~ treated | la_code + year + region_id^year,
                     data = panel, cluster = ~la_code)
cat("TWFE with region × year FE:\n")
summary(twfe_region)

###############################################################################
# 3. Excluding London (different labour market dynamics)
###############################################################################

cat("\n=== Excluding London ===\n")

# Set seed for reproducible bootstrap SEs in robustness checks
set.seed(20240473)

panel_no_london <- panel %>% filter(region != "London")

cs_no_london <- att_gt(
  yname = "se_share",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel_no_london,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_no_london_agg <- aggte(cs_no_london, type = "simple")
cat("CS ATT (excl. London):\n")
summary(cs_no_london_agg)

###############################################################################
# 4. England only (exclude Scotland/Wales)
###############################################################################

cat("\n=== England only ===\n")

panel_england <- panel %>% filter(country == "England")

cs_england <- att_gt(
  yname = "se_share",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel_england,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_england_agg <- aggte(cs_england, type = "simple")
cat("CS ATT (England only):\n")
summary(cs_england_agg)

###############################################################################
# 5. Exclude fuzzy-matched LAs (treatment timing sensitivity)
###############################################################################

cat("\n=== Excluding fuzzy-matched/reassigned LAs ===\n")

bad_matches <- c("county durham", "stockton-on-tees", "newcastle upon tyne",
                 "york", "bradford", "lincoln", "wellingborough",
                 "stratford-on-avon", "east hertfordshire", "westminster",
                 "greenwich", "kingston upon thames", "folkestone and hythe",
                 "cardiff")

panel_exact <- panel %>% filter(!la_name_clean %in% bad_matches)
cat("Panel after excluding fuzzy matches:", nrow(panel_exact), "obs,",
    n_distinct(panel_exact$la_code), "LAs\n")

cs_exact <- att_gt(
  yname = "se_share",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel_exact,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_exact_agg <- aggte(cs_exact, type = "simple")
cat("CS ATT (exact matches only):\n")
summary(cs_exact_agg)

###############################################################################
# 6. Alternative control group: not-yet-treated vs. never-treated
###############################################################################

cat("\n=== Alternative estimator: did2s (Gardner) ===\n")

# Manual two-stage imputation estimator (Gardner 2022)
# Stage 1: Estimate FE model on untreated observations
untreated <- panel %>% filter(treated == 0)
stage1 <- feols(se_share ~ 1 | la_code + year, data = untreated)

# Predict for all observations
panel$se_share_hat <- predict(stage1, newdata = panel)
panel$se_share_resid <- panel$se_share - panel$se_share_hat

# Stage 2: Regress residual on treatment
stage2 <- feols(se_share_resid ~ treated, data = panel, cluster = ~la_code)
cat("Two-stage imputation estimate:\n")
summary(stage2)

###############################################################################
# 6. Placebo: Restrict to pre-treatment period only
###############################################################################

cat("\n=== Placebo test: fake treatment in 2014 ===\n")

panel_pre <- panel %>%
  filter(year <= 2015) %>%
  mutate(
    fake_treat_year = if_else(first_treat <= 2017, 2014L, 2015L),
    fake_treated = if_else(year >= fake_treat_year, 1L, 0L)
  )

twfe_placebo <- feols(se_share ~ fake_treated | la_code + year,
                      data = panel_pre, cluster = ~la_code)
cat("Placebo TWFE (fake 2014 treatment):\n")
summary(twfe_placebo)

###############################################################################
# 7. HonestDiD sensitivity analysis
###############################################################################

cat("\n=== HonestDiD Sensitivity ===\n")

tryCatch({
  # Use the SA event study for HonestDiD
  sa_se <- readRDS(file.path(DATA_DIR, "sa_se.rds"))

  # Extract coefficients and variance-covariance matrix
  beta <- coef(sa_se)
  V <- vcov(sa_se)

  # Identify pre-treatment and post-treatment coefficients
  pre_idx <- grep("year::-", names(beta))
  post_idx <- grep("year::0|year::1", names(beta))

  if (length(pre_idx) > 0 && length(post_idx) > 0) {
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = beta[c(pre_idx, post_idx)],
      sigma = V[c(pre_idx, post_idx), c(pre_idx, post_idx)],
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.5, by = 0.1)
    )
    cat("HonestDiD results:\n")
    print(honest_result)
    write_csv(as.data.frame(honest_result), file.path(TAB_DIR, "honestdid.csv"))
  } else {
    cat("Could not identify pre/post coefficients for HonestDiD.\n")
  }
}, error = function(e) {
  cat("HonestDiD failed:", conditionMessage(e), "\n")
})

###############################################################################
# 8. Summary of robustness results
###############################################################################

cat("\n========================================\n")
cat("ROBUSTNESS SUMMARY\n")
cat("========================================\n")

# Load main CS ATT from saved AGGREGATED object (same bootstrap run as Table 3)
cs_se_main_agg <- readRDS(file.path(DATA_DIR, "cs_se_share_agg.rds"))

results <- tibble(
  specification = c(
    "Main CS ATT",
    "TWFE with region × year FE",
    "CS excl. London",
    "CS England only",
    "CS exact matches only",
    "Placebo (fake 2014)"
  ),
  estimate = c(
    cs_se_main_agg$overall.att,
    coef(twfe_region)["treated"],
    cs_no_london_agg$overall.att,
    cs_england_agg$overall.att,
    cs_exact_agg$overall.att,
    coef(twfe_placebo)["fake_treated"]
  ),
  se = c(
    cs_se_main_agg$overall.se,
    se(twfe_region)["treated"],
    cs_no_london_agg$overall.se,
    cs_england_agg$overall.se,
    cs_exact_agg$overall.se,
    se(twfe_placebo)["fake_treated"]
  )
)

print(results)
write_csv(results, file.path(TAB_DIR, "robustness_summary.csv"))

# Save panel with region info
write_csv(panel, file.path(DATA_DIR, "analysis_panel.csv"))

cat("\nRobustness checks complete.\n")
