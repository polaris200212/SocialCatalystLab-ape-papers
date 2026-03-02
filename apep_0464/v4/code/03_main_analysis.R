## ============================================================================
## 03_main_analysis.R — Connected Backlash (apep_0464 v3)
## Main reduced-form regressions — expanded panel (10 elections)
## v3: Département-level as PRIMARY specification (N=960)
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"

## Load analysis panels
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))

cat("Commune panel:", nrow(panel), "obs\n")
cat("Département panel:", nrow(dept_panel), "obs\n")
cat("Elections:", paste(sort(unique(panel$year)), collapse = ", "), "\n")

## ============================================================================
## TABLE 1: Summary Statistics
## ============================================================================

cat("\n=== Summary Statistics ===\n")

sumstats_commune <- panel %>%
  summarize(
    across(c(rn_share, turnout, co2_commute, network_fuel_norm,
             own_carbon_burden, network_carbon_burden),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE),
                min = ~min(., na.rm = TRUE),
                max = ~max(., na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  ) %>%
  pivot_longer(everything(),
               names_to = c("variable", "stat"),
               names_sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = stat, values_from = value)

cat("\nCommune-level summary statistics:\n")
print(sumstats_commune, n = 20)

## ============================================================================
## v3: DÉPARTEMENT-LEVEL AS PRIMARY SPECIFICATION (N=960)
## ============================================================================

cat("\n=== v3: Département-Level Regressions (PRIMARY) ===\n")

dept_panel <- dept_panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

## Model D1: Département-level with département + election FE (UNWEIGHTED)
d1 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon |
              dept_code + id_election,
            data = dept_panel,
            cluster = ~dept_code)

## Model D2: Weighted by registered voters
d2 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon |
              dept_code + id_election,
            data = dept_panel,
            cluster = ~dept_code,
            weights = ~total_registered)

## Model D3: Continuous treatment at département level
d3 <- feols(rn_share ~ own_fuel_std:rate_eur_tco2 +
              network_fuel_std:rate_eur_tco2 |
              dept_code + id_election,
            data = dept_panel,
            cluster = ~dept_code,
            weights = ~total_registered)

## v3: Model D4 — Two-way clustering (dept + election)
d4 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon |
              dept_code + id_election,
            data = dept_panel,
            cluster = ~dept_code + id_election)

cat("\n--- Département Results (PRIMARY) ---\n")
etable(d1, d2, d3, d4,
       headers = c("Unweighted", "Pop-weighted", "Continuous", "Two-way cluster"),
       se.below = TRUE)

dept_results <- list(d1 = d1, d2 = d2, d3 = d3, d4 = d4)
saveRDS(dept_results, file.path(DATA_DIR, "dept_results.rds"))

## ============================================================================
## COMMUNE-LEVEL SPECIFICATIONS (ANCILLARY)
## ============================================================================

cat("\n=== Commune-level Regressions (Ancillary) ===\n")

## Standardize exposure variables
panel <- panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

## Model 1: OLS — Own exposure only
m1 <- feols(rn_share ~ own_fuel_std:post_carbon |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 2: OLS — Network exposure only
m2 <- feols(rn_share ~ network_fuel_std:post_carbon |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 3: OLS — Both own and network exposure
m3 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 4: Post-GJ indicator
m4 <- feols(rn_share ~ own_fuel_std:post_gj +
              network_fuel_std:post_gj |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 5: Election-type interactions
panel <- panel %>%
  mutate(is_pres = as.integer(election_type == "presidential"))

m5 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon +
              own_fuel_std:post_carbon:is_pres +
              network_fuel_std:post_carbon:is_pres |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 6: Continuous treatment (carbon rate)
m6 <- feols(rn_share ~ own_fuel_std:rate_eur_tco2 +
              network_fuel_std:rate_eur_tco2 |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

cat("\n--- Commune-Level Model Results ---\n")
etable(m1, m2, m3, m4, m5, m6,
       headers = c("Own Only", "Network Only", "Both", "Post-GJ",
                    "Pres x Euro", "Continuous"),
       se.below = TRUE)

main_results <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5, m6 = m6)
saveRDS(main_results, file.path(DATA_DIR, "main_results.rds"))

## ============================================================================
## EVENT STUDY SPECIFICATION (10 elections, ref = 2012)
## ============================================================================

cat("\n=== Event Study (10 elections) ===\n")

panel <- panel %>%
  mutate(
    election_num = case_when(
      year == 2002 ~ 1,
      year == 2004 ~ 2,
      year == 2007 ~ 3,
      year == 2009 ~ 4,
      year == 2012 ~ 5,
      year == 2014 ~ 6,
      year == 2017 ~ 7,
      year == 2019 ~ 8,
      year == 2022 ~ 9,
      year == 2024 ~ 10,
      TRUE ~ NA_real_
    )
  )

es_own <- feols(rn_share ~ i(election_num, own_fuel_std, ref = 5) |
                  code_commune + id_election,
                data = panel,
                cluster = ~dept_code)

es_network <- feols(rn_share ~ i(election_num, network_fuel_std, ref = 5) |
                      code_commune + id_election,
                    data = panel,
                    cluster = ~dept_code)

es_both <- feols(rn_share ~ i(election_num, own_fuel_std, ref = 5) +
                   i(election_num, network_fuel_std, ref = 5) |
                   code_commune + id_election,
                 data = panel,
                 cluster = ~dept_code)

cat("\nEvent study — Network exposure:\n")
summary(es_network)

es_results <- list(es_own = es_own, es_network = es_network, es_both = es_both)
saveRDS(es_results, file.path(DATA_DIR, "event_study_results.rds"))

## Extract coefficients for plotting
extract_es <- function(model, var_prefix) {
  coefs <- coeftable(model)
  idx <- grepl(var_prefix, rownames(coefs))
  tibble(
    election_num = as.integer(gsub(".*::(\\d+):.*", "\\1", rownames(coefs)[idx])),
    estimate = coefs[idx, "Estimate"],
    se = coefs[idx, "Std. Error"]
  ) %>%
    bind_rows(tibble(election_num = 5L, estimate = 0, se = 0)) %>%
    arrange(election_num) %>%
    mutate(
      ci_lo = estimate - 1.96 * se,
      ci_hi = estimate + 1.96 * se,
      year = c(2002, 2004, 2007, 2009, 2012, 2014,
               2017, 2019, 2022, 2024)[election_num]
    )
}

es_own_data <- extract_es(es_both, "own_fuel_std")
es_network_data <- extract_es(es_both, "network_fuel_std")

saveRDS(list(own = es_own_data, network = es_network_data),
        file.path(DATA_DIR, "event_study_data.rds"))

cat("\nEvent study coefficients (network exposure):\n")
print(es_network_data)

pre_coefs <- es_network_data %>% filter(year <= 2012)
cat("  Pre-treatment range: [", round(min(pre_coefs$estimate), 3), ",",
    round(max(pre_coefs$estimate), 3), "]\n")
cat("  Any pre-treatment |t| > 1.96?",
    any(abs(pre_coefs$estimate / pre_coefs$se) > 1.96, na.rm = TRUE), "\n")

## ============================================================================
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("MAIN ANALYSIS COMPLETE (v3: dept-level primary)\n")
cat(strrep("=", 60), "\n")

cat("\nv3 PRIMARY: Département-level Model D2 (pop-weighted):\n")
cat("  Own fuel x Post:    ", coef(d2)[grep("own_fuel_std", names(coef(d2)))],
    " (", se(d2)[grep("own_fuel_std", names(se(d2)))], ")\n")
cat("  Network fuel x Post:", coef(d2)[grep("network_fuel_std", names(coef(d2)))],
    " (", se(d2)[grep("network_fuel_std", names(se(d2)))], ")\n")

cat("\nv3 SENSITIVITY: Département-level Model D1 (unweighted):\n")
cat("  Own fuel x Post:    ", coef(d1)[grep("own_fuel_std", names(coef(d1)))],
    " (", se(d1)[grep("own_fuel_std", names(se(d1)))], ")\n")
cat("  Network fuel x Post:", coef(d1)[grep("network_fuel_std", names(coef(d1)))],
    " (", se(d1)[grep("network_fuel_std", names(se(d1)))], ")\n")

cat("\nAncillary: Commune-level Model 3:\n")
cat("  Own fuel x Post:    ", coef(m3)[grep("own_fuel_std", names(coef(m3)))],
    " (", se(m3)[grep("own_fuel_std", names(se(m3)))], ")\n")
cat("  Network fuel x Post:", coef(m3)[grep("network_fuel_std", names(coef(m3)))],
    " (", se(m3)[grep("network_fuel_std", names(se(m3)))], ")\n")
cat("\n")
