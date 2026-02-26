## ============================================================================
## 03_main_analysis.R — Connected Backlash (apep_0464 v2)
## Main reduced-form regressions — expanded panel (10 elections)
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
## MAIN SPECIFICATION: OLS (Commune-level)
## ============================================================================

cat("\n=== Main Regressions (Commune-level) ===\n")

## Standardize exposure variables for interpretable coefficients
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

## Model 4: OLS — Using post-GJ indicator instead
m4 <- feols(rn_share ~ own_fuel_std:post_gj +
              network_fuel_std:post_gj |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## Model 5: Add election-type interactions (presidential vs European)
panel <- panel %>%
  mutate(is_pres = as.integer(election_type == "presidential"))

m5 <- feols(rn_share ~ own_fuel_std:post_carbon +
              network_fuel_std:post_carbon +
              own_fuel_std:post_carbon:is_pres +
              network_fuel_std:post_carbon:is_pres |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

## v2: Model 6 — Continuous treatment (carbon rate)
m6 <- feols(rn_share ~ own_fuel_std:rate_eur_tco2 +
              network_fuel_std:rate_eur_tco2 |
              code_commune + id_election,
            data = panel,
            cluster = ~dept_code)

cat("\n--- Model Results ---\n")
etable(m1, m2, m3, m4, m5, m6,
       headers = c("Own Only", "Network Only", "Both", "Post-GJ",
                    "Pres x Euro", "Continuous"),
       se.below = TRUE)

## Save results
main_results <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5, m6 = m6)
saveRDS(main_results, file.path(DATA_DIR, "main_results.rds"))

## ============================================================================
## DÉPARTEMENT-LEVEL REGRESSIONS
## ============================================================================

cat("\n=== Département-level Regressions ===\n")

dept_panel <- dept_panel %>%
  mutate(
    own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
      sd(co2_commute, na.rm = TRUE),
    network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
      sd(network_fuel_norm, na.rm = TRUE)
  )

## Model D1: Département-level with département + election FE
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

## v2: Model D3: Continuous treatment at département level
d3 <- feols(rn_share ~ own_fuel_std:rate_eur_tco2 +
              network_fuel_std:rate_eur_tco2 |
              dept_code + id_election,
            data = dept_panel,
            cluster = ~dept_code,
            weights = ~total_registered)

cat("\n--- Département Results ---\n")
etable(d1, d2, d3,
       headers = c("Unweighted", "Pop-weighted", "Continuous"),
       se.below = TRUE)

dept_results <- list(d1 = d1, d2 = d2, d3 = d3)
saveRDS(dept_results, file.path(DATA_DIR, "dept_results.rds"))

## ============================================================================
## EVENT STUDY SPECIFICATION (v2: 10 elections, 5 pre-treatment periods)
## ============================================================================

cat("\n=== Event Study (v2: 10 elections) ===\n")

## Create election-specific treatment interactions
## Reference: 2012 Presidential (last pre-carbon-tax election)
panel <- panel %>%
  mutate(
    election_num = case_when(
      year == 2002 ~ 1,
      year == 2004 ~ 2,
      year == 2007 ~ 3,
      year == 2009 ~ 4,
      year == 2012 ~ 5,
      year == 2014 ~ 6,
      ## Reference = 5 (2012, last pre-carbon-tax)
      year == 2017 ~ 7,
      year == 2019 ~ 8,
      year == 2022 ~ 9,
      year == 2024 ~ 10,
      TRUE ~ NA_real_
    )
  )

## Event study: interact network exposure with each election indicator
## Omitting election 5 (2012) as reference — last pre-carbon-tax election
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

cat("\nEvent study — Own exposure:\n")
summary(es_own)

cat("\nEvent study — Network exposure:\n")
summary(es_network)

## Save event study results
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
    ## Add reference period
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

cat("\nv2 KEY: Pre-treatment coefficients (2002-2012) should be near zero.\n")
pre_coefs <- es_network_data %>% filter(year <= 2012)
cat("  Pre-treatment range: [", round(min(pre_coefs$estimate), 3), ",",
    round(max(pre_coefs$estimate), 3), "]\n")
cat("  Any pre-treatment |t| > 1.96?",
    any(abs(pre_coefs$estimate / pre_coefs$se) > 1.96, na.rm = TRUE), "\n")

## ============================================================================
## SCI vs. GEOGRAPHIC DISTANCE
## ============================================================================

cat("\n=== SCI vs. Geographic Distance ===\n")

sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
cat("SCI matrix statistics:\n")
cat("  Mean scaled_sci:", mean(sci_matrix$scaled_sci), "\n")
cat("  SD scaled_sci:", sd(sci_matrix$scaled_sci), "\n")

## ============================================================================
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("MAIN ANALYSIS COMPLETE (v2: 10-election panel)\n")
cat(strrep("=", 60), "\n")

cat("\nKey results (Model 3, binary post):\n")
cat("  Own fuel x Post:    ", coef(m3)["own_fuel_std:post_carbon"],
    " (", se(m3)["own_fuel_std:post_carbon"], ")\n")
cat("  Network fuel x Post:", coef(m3)["network_fuel_std:post_carbon"],
    " (", se(m3)["network_fuel_std:post_carbon"], ")\n")

cat("\nKey results (Model 6, continuous treatment):\n")
net_name <- names(coef(m6))[grepl("network", names(coef(m6)))]
own_name <- names(coef(m6))[grepl("own", names(coef(m6)))]
if (length(own_name) > 0) cat("  Own fuel x Rate:    ", coef(m6)[own_name[1]],
    " (", se(m6)[own_name[1]], ")\n")
if (length(net_name) > 0) cat("  Network fuel x Rate:", coef(m6)[net_name[1]],
    " (", se(m6)[net_name[1]], ")\n")
cat("\n")
