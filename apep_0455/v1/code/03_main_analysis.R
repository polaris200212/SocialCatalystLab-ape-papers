## ============================================================
## 03_main_analysis.R — DiD estimation: TLV expansion effects
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## -------------------------------------------------------
## 1. Load Data
## -------------------------------------------------------

cat("=== Loading panel data ===\n")
cy <- readRDS(file.path(data_dir, "panel_commune_year.rds"))
panel <- readRDS(file.path(data_dir, "panel_transactions.rds"))

cat(sprintf("  Commune-year: %d obs\n", nrow(cy)))
cat(sprintf("  Transaction-level: %d obs\n", nrow(panel)))

## -------------------------------------------------------
## 2. TWFE Difference-in-Differences
## -------------------------------------------------------

cat("\n=== TWFE DiD Estimation ===\n")

## NOTE ON CLUSTERING:
## Treatment varies at the commune level, but we cluster at the département
## level (96 clusters) following Bertrand, Duflo & Mullainathan (2004).
## Département clustering is MORE conservative than commune-level clustering
## (31,659 clusters) because it accounts for spatial correlation between
## communes within the same département. This is standard practice in
## French applied economics (e.g., Combes, Duranton & Gobillon 2019).

## 2a. Commune-year level: log mean price per sqm
## Primary specification with commune + year FE
m1 <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
            data = cy, cluster = ~dep)

## With département × year FE (absorbs all regional shocks)
m2 <- feols(mean_log_price_sqm ~ treat_post | code_commune + dep^year,
            data = cy, cluster = ~dep)

## 2b. Transaction volume (log)
m3 <- feols(log_transactions ~ treat_post | code_commune + year,
            data = cy, cluster = ~dep)

m4 <- feols(log_transactions ~ treat_post | code_commune + dep^year,
            data = cy, cluster = ~dep)

## 2c. Transaction-level: log price per sqm
m5 <- feols(log_price_sqm ~ treat_post | code_commune + year,
            data = panel, cluster = ~dep)

m6 <- feols(log_price_sqm ~ treat_post | code_commune + dep^year,
            data = panel, cluster = ~dep)

## Display results
cat("\n--- Table 1: Main DiD Results ---\n")
etable(m1, m2, m3, m4, m5, m6,
       headers = c("Price (CY)", "Price (D×Y)", "Volume (CY)", "Volume (D×Y)",
                    "Price (TX)", "Price (TX, D×Y)"),
       se.below = TRUE)

## Save estimates
main_results <- list(
  price_cy = m1, price_cy_dxy = m2,
  volume_cy = m3, volume_cy_dxy = m4,
  price_tx = m5, price_tx_dxy = m6
)
saveRDS(main_results, file.path(data_dir, "main_results.rds"))

## -------------------------------------------------------
## 3. Event Study
## -------------------------------------------------------

cat("\n=== Event Study ===\n")

## Create relative time indicators
## Treatment effective January 2024
## 2023 is the announcement year (decree August 2023)
## We use 2022 as the reference year (last clean pre-treatment year)

cy <- cy %>%
  mutate(
    rel_year = year - 2024,
    ## Interaction terms for event study
    treat_x_year = treated * factor(year)
  )

panel <- panel %>%
  mutate(rel_year = year - 2024)

## Event study at commune-year level
es1 <- feols(mean_log_price_sqm ~ i(year, treated, ref = 2022) |
               code_commune + year,
             data = cy, cluster = ~dep)

es2 <- feols(mean_log_price_sqm ~ i(year, treated, ref = 2022) |
               code_commune + dep^year,
             data = cy, cluster = ~dep)

## Event study for volume
es3 <- feols(log_transactions ~ i(year, treated, ref = 2022) |
               code_commune + year,
             data = cy, cluster = ~dep)

## Transaction-level event study
es4 <- feols(log_price_sqm ~ i(year, treated, ref = 2022) |
               code_commune + year,
             data = panel, cluster = ~dep)

cat("\n--- Event Study Coefficients (Price, CY) ---\n")
print(summary(es1))

## Save event study results
es_results <- list(
  price_cy = es1, price_cy_dxy = es2,
  volume_cy = es3, price_tx = es4
)
saveRDS(es_results, file.path(data_dir, "event_study_results.rds"))

## -------------------------------------------------------
## 4. Heterogeneity by Zone Type
## -------------------------------------------------------

cat("\n=== Heterogeneity by Zone Type ===\n")

## Split: zone touristique et tendue vs zone tendue
cy <- cy %>%
  mutate(is_tourism = as.integer(zone_2023 == "touristique_tendue"))

## Tourism communes only
m_tourism <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                    data = cy %>% filter(treated == 1 | is_tourism == 0),
                    subset = ~ (treated == 1 & is_tourism == 1) | treated == 0,
                    cluster = ~dep)

## Non-tourism expansion communes only
m_nontourism <- feols(mean_log_price_sqm ~ treat_post | code_commune + year,
                       data = cy %>% filter(treated == 1 | is_tourism == 0),
                       subset = ~ (treated == 1 & is_tourism == 0) | treated == 0,
                       cluster = ~dep)

cat("\n--- Tourism vs Non-Tourism Heterogeneity ---\n")
etable(m_tourism, m_nontourism,
       headers = c("Tourism Communes", "Non-Tourism"),
       se.below = TRUE)

saveRDS(list(tourism = m_tourism, nontourism = m_nontourism),
        file.path(data_dir, "heterogeneity_results.rds"))

## -------------------------------------------------------
## 5. Summary Statistics Table
## -------------------------------------------------------

cat("\n=== Summary Statistics ===\n")

sumstats <- panel %>%
  group_by(treated) %>%
  summarise(
    N = n(),
    Communes = n_distinct(code_commune),
    `Mean Price/m²` = mean(price_sqm, na.rm = TRUE),
    `SD Price/m²` = sd(price_sqm, na.rm = TRUE),
    `Median Price/m²` = median(price_sqm, na.rm = TRUE),
    `Mean Surface` = mean(surface, na.rm = TRUE),
    `Share Apartments` = mean(property_type == "Appartement", na.rm = TRUE),
    `Mean Rooms` = mean(pieces, na.rm = TRUE),
    .groups = "drop"
  )

print(as.data.frame(sumstats))
saveRDS(sumstats, file.path(data_dir, "summary_statistics.rds"))

cat("\nMain analysis complete.\n")
