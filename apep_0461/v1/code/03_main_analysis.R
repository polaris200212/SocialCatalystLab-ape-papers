## 03_main_analysis.R — Primary regressions
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Loading panel data ===\n")
panel <- readRDS("../data/panel_dev.rds")
oil <- readRDS("../data/oil_prices.rds")

cat(sprintf("  Panel: %d obs, %d countries, years %d-%d\n",
            nrow(panel), n_distinct(panel$iso3c),
            min(panel$year), max(panel$year)))

# ============================================================
# 1. Main DiD specification: Continuous treatment
# ============================================================
cat("\n=== Main DiD: Continuous treatment ===\n")

# Baseline: No controls
m1 <- feols(u5_mortality ~ treatment_continuous | iso3c + year,
            data = panel, cluster = ~iso3c)

# With controls
m2 <- feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel, cluster = ~iso3c)

# With governance controls
m3 <- feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct +
              corruption_control + gov_effectiveness |
              iso3c + year,
            data = panel, cluster = ~iso3c)

cat("  Model 1 (baseline): "); print(coeftable(m1)["treatment_continuous",])
cat("  Model 2 (+ controls): "); print(coeftable(m2)["treatment_continuous",])
cat("  Model 3 (+ governance): "); print(coeftable(m3)["treatment_continuous",])

# ============================================================
# 2. Event study specification
# ============================================================
cat("\n=== Event study ===\n")

# Interact oil_rents_pre with event-time dummies
# Omit k = -1 (year 2013) as reference
panel <- panel %>%
  mutate(event_time_factor = factor(event_time))

es_model <- feols(u5_mortality ~ i(event_time_factor, oil_rents_pre, ref = "-1") +
                    log_gdppc + pop_growth + urban_pct |
                    iso3c + year,
                  data = panel, cluster = ~iso3c)

# Extract event-study coefficients
es_coefs <- as.data.frame(coeftable(es_model)) %>%
  rownames_to_column("term") %>%
  filter(grepl("event_time_factor", term)) %>%
  mutate(
    event_time = as.integer(gsub(".*::([-0-9]+):.*", "\\1", term)),
    estimate = Estimate,
    se = `Std. Error`,
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se
  ) %>%
  select(event_time, estimate, se, ci_low, ci_high)

# Add reference period
es_coefs <- bind_rows(
  es_coefs,
  tibble(event_time = -1, estimate = 0, se = 0, ci_low = 0, ci_high = 0)
) %>%
  arrange(event_time)

saveRDS(es_coefs, "../data/event_study_coefs.rds")
cat(sprintf("  Event study: %d periods\n", nrow(es_coefs)))
cat("  Pre-period coefficients:\n")
print(filter(es_coefs, event_time < 0))

# ============================================================
# 3. Binary treatment (high vs low oil)
# ============================================================
cat("\n=== Binary treatment DiD ===\n")

m4 <- feols(u5_mortality ~ treatment_binary + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel, cluster = ~iso3c)

cat("  Binary treatment: "); print(coeftable(m4)["treatment_binary",])

# ============================================================
# 4. Tercile treatment
# ============================================================
cat("\n=== Tercile treatment DiD ===\n")

m5 <- feols(u5_mortality ~ i(oil_tercile, post2014, ref = "None") +
              log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel, cluster = ~iso3c)

cat("  Tercile effects:\n"); print(coeftable(m5))

# ============================================================
# 5. Alternative outcomes
# ============================================================
cat("\n=== Alternative outcomes ===\n")

outcomes <- c("infant_mortality", "neonatal_mortality",
              "dpt_immunization", "measles_immunization",
              "primary_enrollment", "secondary_enrollment")

alt_results <- map_dfr(outcomes, function(y) {
  f <- as.formula(paste0(y, " ~ treatment_continuous + log_gdppc + pop_growth + urban_pct | iso3c + year"))
  m <- tryCatch(
    feols(f, data = panel, cluster = ~iso3c),
    error = function(e) NULL
  )
  if (is.null(m)) return(tibble(outcome = y, estimate = NA, se = NA, p_value = NA, n = NA))

  ct <- coeftable(m)["treatment_continuous",]
  tibble(
    outcome = y,
    estimate = ct[1],
    se = ct[2],
    p_value = ct[4],
    n = m$nobs
  )
})

cat("  Alternative outcome results:\n")
print(alt_results)

# ============================================================
# 6. Mechanism: Government health expenditure
# ============================================================
cat("\n=== Mechanism: Health expenditure ===\n")

m_health <- feols(health_exp ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
                    iso3c + year,
                  data = panel, cluster = ~iso3c)

m_gov_health <- feols(gov_health_exp ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
                        iso3c + year,
                      data = panel, cluster = ~iso3c)

m_military <- feols(military_exp ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
                      iso3c + year,
                    data = panel, cluster = ~iso3c)

cat("  Health exp: "); print(coeftable(m_health)["treatment_continuous",])
cat("  Gov health exp: "); print(coeftable(m_gov_health)["treatment_continuous",])
cat("  Military exp: "); print(coeftable(m_military)["treatment_continuous",])

# ============================================================
# Save all models
# ============================================================
results <- list(
  m1 = m1, m2 = m2, m3 = m3,
  m4 = m4, m5 = m5,
  es_model = es_model,
  m_health = m_health, m_gov_health = m_gov_health, m_military = m_military,
  alt_results = alt_results
)

saveRDS(results, "../data/main_results.rds")
cat("\n=== Main analysis complete ===\n")
