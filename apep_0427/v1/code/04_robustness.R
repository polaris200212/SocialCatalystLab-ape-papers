# =============================================================================
# 04_robustness.R — Robustness Checks
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Running robustness checks for apep_0427 ===\n")

sector_panel   <- readRDS("../data/sector_panel.rds")
cross_country  <- readRDS("../data/cross_country_panel.rds")

# =============================================================
# 1. Event Study: Sector-Exposure Bartik
# =============================================================
cat("\n--- Robustness 1: Event Study (Sector Exposure) ---\n")

# Create event-time dummies relative to 2023Q1
sector_es <- sector_panel %>%
  mutate(
    event_time = (yq - 2023.0) * 4,  # quarters relative to Jan 2023
    event_time = round(event_time)  # integer quarters
  ) %>%
  filter(event_time >= -20 & event_time <= 10)

# Interaction with exposure for each event time
# Using fixest sunab-style: exposure x event_time dummies
es_model <- feols(
  youth_share ~ i(event_time, exposure, ref = -1) | sector + yq,
  data = sector_es,
  cluster = ~sector
)
cat("Event study model (sector exposure):\n")
summary(es_model)

saveRDS(es_model, "../data/event_study_sector.rds")

# =============================================================
# 2. Placebo Test: Prime-Age Workers (25-54)
# =============================================================
cat("\n--- Robustness 2: Placebo (Prime-Age Workers) ---\n")

# Prime-age employment should not respond to apprenticeship subsidy changes
sector_prime <- sector_panel %>%
  mutate(prime_share = ifelse(!is.na(emp_total) & emp_total > 0,
                              emp_prime / emp_total * 100, NA))

m_placebo <- feols(
  prime_share ~ bartik_reduction | sector + yq,
  data = sector_prime,
  cluster = ~sector
)
cat("Placebo (prime-age share):\n")
summary(m_placebo)

saveRDS(m_placebo, "../data/placebo_prime_age.rds")

# =============================================================
# 3. Leave-One-Sector-Out
# =============================================================
cat("\n--- Robustness 3: Leave-One-Sector-Out ---\n")

sectors <- unique(sector_panel$sector)
loso_results <- map_dfr(sectors, function(s) {
  d <- sector_panel %>% filter(sector != s)
  m <- tryCatch({
    feols(youth_share ~ bartik_reduction | sector + yq,
          data = d, cluster = ~sector)
  }, error = function(e) return(NULL))
  if (is.null(m)) return(NULL)
  tibble(
    excluded_sector = s,
    coef = coef(m)["bartik_reduction"],
    se = se(m)["bartik_reduction"],
    n = nobs(m)
  )
})

cat("Leave-one-sector-out results:\n")
print(loso_results)

saveRDS(loso_results, "../data/loso_results.rds")

# =============================================================
# 4. Permutation Inference (Randomization Inference)
# =============================================================
cat("\n--- Robustness 4: Permutation Inference ---\n")

set.seed(42)
n_perms <- 1000

# Observed test statistic
obs_stat <- coef(feols(
  youth_share ~ bartik_reduction | sector + yq,
  data = sector_panel, cluster = ~sector
))["bartik_reduction"]

# Permute sector exposure assignment
perm_stats <- replicate(n_perms, {
  perm_data <- sector_panel %>%
    mutate(
      perm_exposure = sample(unique(exposure), n(), replace = TRUE),
      perm_bartik = perm_exposure * post_reduction
    )
  m <- tryCatch({
    coef(feols(
      youth_share ~ perm_bartik | sector + yq,
      data = perm_data, cluster = ~sector
    ))["perm_bartik"]
  }, error = function(e) NA_real_)
  return(m)
})

perm_stats <- na.omit(perm_stats)
ri_p <- mean(abs(perm_stats) >= abs(obs_stat))

cat(sprintf("Observed statistic: %.4f\n", obs_stat))
cat(sprintf("RI p-value (two-sided): %.4f (based on %d permutations)\n",
            ri_p, length(perm_stats)))

saveRDS(list(obs = obs_stat, perms = perm_stats, p = ri_p),
        "../data/permutation_inference.rds")

# =============================================================
# 5. Cross-Country Event Study
# =============================================================
cat("\n--- Robustness 5: Cross-Country Event Study ---\n")

cc_youth <- cross_country %>%
  filter(age_group == "Y15-24") %>%
  mutate(
    event_time = (yq - 2023.0) * 4,
    event_time = round(event_time)
  ) %>%
  filter(event_time >= -20 & event_time <= 10)

es_cc <- feols(
  emp_rate ~ i(event_time, france, ref = -1) | country + yq,
  data = cc_youth,
  cluster = ~country
)
cat("Cross-country event study:\n")
summary(es_cc)

saveRDS(es_cc, "../data/event_study_cross_country.rds")

# =============================================================
# 6. Pre-Trend Formal Tests
# =============================================================
cat("\n--- Robustness 6: Pre-Trend Tests ---\n")

# Test if pre-trend coefficients are jointly zero
pre_coefs <- coeftable(es_model) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(grepl("event_time::", term)) %>%
  mutate(
    et = as.numeric(gsub(".*::(-?\\d+):.*", "\\1", term))
  ) %>%
  filter(et < 0, et != -1)

cat(sprintf("Number of pre-period coefficients: %d\n", nrow(pre_coefs)))
if (nrow(pre_coefs) > 0) {
  cat(sprintf("Max absolute pre-period coefficient: %.4f\n",
              max(abs(pre_coefs$Estimate), na.rm = TRUE)))
}

# Wald test for joint significance of pre-period
tryCatch({
  wald_pre <- wald(es_model, paste0("event_time::", pre_coefs$et, ":exposure"))
  cat("Wald test for pre-trends:\n")
  print(wald_pre)
}, error = function(e) {
  cat("Wald test could not be computed (likely too few clusters).\n")
})

# =============================================================
# 7. Alternative Control Groups
# =============================================================
cat("\n--- Robustness 7: Alternative Control Groups ---\n")

# Exclude Germany (has its own strong apprenticeship system)
cc_no_de <- cross_country %>%
  filter(age_group == "Y15-24", country != "DE")

m_no_de <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_no_de,
  cluster = ~country
)
cat("Excluding Germany:\n")
summary(m_no_de)

# Only Southern European controls (Spain, Italy, Portugal)
cc_south <- cross_country %>%
  filter(age_group == "Y15-24", country %in% c("FR", "ES", "IT", "PT"))

m_south <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_south,
  cluster = ~country
)
cat("Southern European controls only:\n")
summary(m_south)

# Only neighboring countries (Belgium, Germany, Netherlands)
cc_neighbor <- cross_country %>%
  filter(age_group == "Y15-24", country %in% c("FR", "BE", "DE", "NL"))

m_neighbor <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_neighbor,
  cluster = ~country
)
cat("Neighboring controls only:\n")
summary(m_neighbor)

robustness_cc <- list(
  no_germany = m_no_de,
  southern_only = m_south,
  neighbors_only = m_neighbor
)

saveRDS(robustness_cc, "../data/robustness_control_groups.rds")

# =============================================================
# 8. Dose-Response: Continuous Exposure
# =============================================================
cat("\n--- Robustness 8: Dose-Response ---\n")

# Quintiles of exposure
sector_panel_q <- sector_panel %>%
  mutate(exposure_quintile = ntile(exposure, 5))

m_dose <- feols(
  youth_share ~ i(exposure_quintile, post_reduction, ref = 1) | sector + yq,
  data = sector_panel_q,
  cluster = ~sector
)
cat("Dose-response (quintiles):\n")
summary(m_dose)

saveRDS(m_dose, "../data/dose_response.rds")

cat("\n=== Robustness checks complete ===\n")
