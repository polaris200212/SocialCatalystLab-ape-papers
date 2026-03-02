## ============================================================
## 04_robustness.R — Robustness checks
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"

cat("=== Loading data ===\n")
cy <- readRDS(file.path(data_dir, "panel_commune_year.rds"))
panel <- readRDS(file.path(data_dir, "panel_transactions.rds"))

## -------------------------------------------------------
## 1. Placebo Test: Pre-Treatment Trends
## -------------------------------------------------------

cat("\n=== Placebo: Restrict to pre-treatment period ===\n")

## Create a fake treatment at 2022 using pre-treatment data only
cy_pre <- cy %>%
  filter(year < 2024) %>%
  mutate(
    fake_post = as.integer(year >= 2022),
    fake_treat_post = treated * fake_post
  )

placebo_m <- feols(mean_log_price_sqm ~ fake_treat_post |
                     code_commune + year,
                   data = cy_pre, cluster = ~dep)

cat("Placebo test (fake treatment in 2022):\n")
print(summary(placebo_m))

## -------------------------------------------------------
## 2. Matched Sample DiD
## -------------------------------------------------------

cat("\n=== Matched Sample DiD ===\n")

## Compute pre-treatment means for matching
pre_means <- cy %>%
  filter(year < 2024) %>%
  group_by(code_commune, treated, dep) %>%
  summarise(
    pre_price = mean(mean_price_sqm, na.rm = TRUE),
    pre_volume = mean(n_transactions, na.rm = TRUE),
    pre_surface = mean(mean_surface, na.rm = TRUE),
    pre_apt_share = mean(share_apartments, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(pre_price), !is.na(pre_volume))

## Propensity score matching
library(MatchIt)

match_out <- tryCatch({
  matchit(treated ~ pre_price + pre_volume + pre_surface + pre_apt_share,
          data = pre_means, method = "nearest", ratio = 5,
          distance = "glm", caliper = 0.25)
}, error = function(e) {
  cat(sprintf("  Matching failed: %s\n", e$message))
  NULL
})

if (!is.null(match_out)) {
  matched_ids <- match.data(match_out)$code_commune
  cat(sprintf("  Matched sample: %d communes (%d treated, %d control)\n",
              length(matched_ids),
              sum(pre_means$treated[pre_means$code_commune %in% matched_ids] == 1),
              sum(pre_means$treated[pre_means$code_commune %in% matched_ids] == 0)))

  cy_matched <- cy %>% filter(code_commune %in% matched_ids)
  panel_matched <- panel %>% filter(code_commune %in% matched_ids)

  ## Re-run main DiD on matched sample
  m_matched <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                      data = cy_matched, cluster = ~dep)

  cat("  Matched sample DiD:\n")
  print(summary(m_matched))

  saveRDS(m_matched, file.path(data_dir, "matched_results.rds"))
  saveRDS(matched_ids, file.path(data_dir, "matched_commune_ids.rds"))
}

## -------------------------------------------------------
## 3. Département × Year FE (absorb all regional shocks)
## -------------------------------------------------------

cat("\n=== Département × Year FE ===\n")

## Already in main results but show separately for robustness table
m_dxy <- feols(mean_log_price_sqm ~ treat_post | code_commune + dep^year,
               data = cy, cluster = ~dep)
cat("  Dep × Year FE:\n")
summary(m_dxy)

## -------------------------------------------------------
## 4. Exclude Announcement Period (2023-H2)
## -------------------------------------------------------

cat("\n=== Donut: Exclude Aug-Dec 2023 ===\n")

## The decree was published August 25, 2023
## Exclude transactions in the second half of 2023 to avoid anticipation
panel_donut <- panel %>%
  filter(!(year == 2023 & quarter >= 3))

cy_donut <- panel_donut %>%
  group_by(code_commune, dep, year, treated, treatment_group, zone_2023) %>%
  summarise(
    n_transactions = n(),
    mean_price_sqm = mean(price_sqm, na.rm = TRUE),
    mean_log_price_sqm = mean(log_price_sqm, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    post = as.integer(year >= 2024),
    treat_post = treated * post,
    log_transactions = log(n_transactions + 1)
  )

m_donut <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                  data = cy_donut, cluster = ~dep)

cat("  Donut DiD (exclude 2023-H2):\n")
print(summary(m_donut))

## -------------------------------------------------------
## 5. Property Type Heterogeneity
## -------------------------------------------------------

cat("\n=== Property Type Heterogeneity ===\n")

## Houses only
panel_houses <- panel %>% filter(property_type == "Maison")
m_houses <- feols(log_price_sqm ~ treat_post | code_commune + year,
                   data = panel_houses, cluster = ~dep)

## Apartments only
panel_apts <- panel %>% filter(property_type == "Appartement")
m_apts <- feols(log_price_sqm ~ treat_post | code_commune + year,
                 data = panel_apts, cluster = ~dep)

cat("  Houses:\n")
print(coeftable(m_houses))
cat("  Apartments:\n")
print(coeftable(m_apts))

## -------------------------------------------------------
## 6. Randomization Inference
## -------------------------------------------------------

cat("\n=== Randomization Inference ===\n")

## Permute treatment assignment across communes and recompute DiD
set.seed(42)
n_perms <- 500

## Get commune-level treatment
commune_treat <- cy %>%
  distinct(code_commune, treated)

## Observed coefficient
obs_coef <- coef(feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                        data = cy, cluster = ~dep))["treat_post"]

ri_coefs <- numeric(n_perms)

cat(sprintf("  Running %d permutations...\n", n_perms))

for (i in 1:n_perms) {
  ## Shuffle treatment
  perm_treat <- commune_treat %>%
    mutate(treated_perm = sample(treated))

  cy_perm <- cy %>%
    left_join(perm_treat %>% select(code_commune, treated_perm),
              by = "code_commune") %>%
    mutate(treat_post_perm = treated_perm * post)

  fit_perm <- tryCatch({
    feols(mean_log_price_sqm ~ treat_post_perm | code_commune + year,
          data = cy_perm)
  }, error = function(e) NULL)

  if (!is.null(fit_perm)) {
    ri_coefs[i] <- coef(fit_perm)["treat_post_perm"]
  }

  if (i %% 100 == 0) cat(sprintf("    Permutation %d/%d\n", i, n_perms))
}

## RI p-value (two-sided)
ri_pval <- mean(abs(ri_coefs) >= abs(obs_coef))
cat(sprintf("\n  Observed coefficient: %.4f\n", obs_coef))
cat(sprintf("  RI p-value (two-sided): %.3f\n", ri_pval))

saveRDS(list(observed = obs_coef, permuted = ri_coefs, p_value = ri_pval),
        file.path(data_dir, "ri_results.rds"))

## -------------------------------------------------------
## 7. Hedonic-Controlled Transaction-Level Regressions
## -------------------------------------------------------

cat("\n=== Hedonic-Controlled Transaction-Level Regressions ===\n")

## Add property controls to address composition concerns
## Surface, property type, rooms as hedonic controls
m_hedonic <- feols(log_price_sqm ~ treat_post + log(surface) +
                     i(property_type) + pieces |
                     code_commune + year,
                   data = panel, cluster = ~dep)

m_hedonic_dxy <- feols(log_price_sqm ~ treat_post + log(surface) +
                         i(property_type) + pieces |
                         code_commune + dep^year,
                       data = panel, cluster = ~dep)

cat("  Hedonic (commune + year FE):\n")
print(coeftable(m_hedonic)["treat_post", ])
cat("  Hedonic (dept x year FE):\n")
print(coeftable(m_hedonic_dxy)["treat_post", ])

## -------------------------------------------------------
## 8. 2024-Only Specification (Drop Partial 2025)
## -------------------------------------------------------

cat("\n=== 2024-Only Specification (Excluding 2025) ===\n")

cy_no2025 <- cy %>% filter(year <= 2024)
panel_no2025 <- panel %>% filter(year <= 2024)

m_no2025_price <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                         data = cy_no2025, cluster = ~dep)

m_no2025_vol <- feols(log_transactions ~ treat_post | code_commune + year,
                       data = cy_no2025, cluster = ~dep)

m_no2025_tx <- feols(log_price_sqm ~ treat_post | code_commune + year,
                      data = panel_no2025, cluster = ~dep)

cat("  Price (CY, excl 2025):\n")
print(coeftable(m_no2025_price)["treat_post", ])
cat("  Volume (CY, excl 2025):\n")
print(coeftable(m_no2025_vol)["treat_post", ])
cat("  Price (TX, excl 2025):\n")
print(coeftable(m_no2025_tx)["treat_post", ])

## -------------------------------------------------------
## 9. Restricted Pre-Period (2021+, Drop 2020 COVID Year)
## -------------------------------------------------------

cat("\n=== Restricted Pre-Period (2021-2025, Drop 2020) ===\n")

cy_no2020 <- cy %>% filter(year >= 2021)
panel_no2020 <- panel %>% filter(year >= 2021)

m_no2020_price <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                         data = cy_no2020, cluster = ~dep)

m_no2020_vol <- feols(log_transactions ~ treat_post | code_commune + year,
                       data = cy_no2020, cluster = ~dep)

cat("  Price (CY, excl 2020):\n")
print(coeftable(m_no2020_price)["treat_post", ])
cat("  Volume (CY, excl 2020):\n")
print(coeftable(m_no2020_vol)["treat_post", ])

## -------------------------------------------------------
## 10. Save Robustness Summary
## -------------------------------------------------------

robustness <- list(
  placebo = placebo_m,
  matched = if (exists("m_matched")) m_matched else NULL,
  dep_year_fe = m_dxy,
  donut = m_donut,
  houses = m_houses,
  apartments = m_apts,
  ri = list(observed = obs_coef, permuted = ri_coefs, p_value = ri_pval),
  hedonic = m_hedonic,
  hedonic_dxy = m_hedonic_dxy,
  no2025_price = m_no2025_price,
  no2025_vol = m_no2025_vol,
  no2025_tx = m_no2025_tx,
  no2020_price = m_no2020_price,
  no2020_vol = m_no2020_vol
)
saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

cat("\nRobustness checks complete.\n")
