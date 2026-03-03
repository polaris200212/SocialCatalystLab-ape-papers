## ===========================================================================
## 03_main_analysis.R — Primary Regressions
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================
## Design: DVF data covers 2020-2024 (all post-reform).
##
## Identification Strategy:
## (A) Cross-sectional: Communes with higher pre-reform TH rates experienced
##     larger tax relief. We compare price levels across communes controlling
##     for observables and département FE.
## (B) Panel with reform_share interaction: The reform intensified from 80%
##     (2020) to 100% (2023). Commune FE + year FE allow identification from
##     the differential TIME TREND: if capitalization is real, high-TH communes
##     should see faster price growth as reform completes.
## (C) Fiscal substitution: High-TH communes may raise TFB to compensate,
##     partially offsetting the capitalization.
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("=== Loading analysis datasets ===\n")
dvf <- fread(file.path(DAT, "dvf_analysis.csv"))
panel <- fread(file.path(DAT, "panel_commune_year.csv"))

cat(sprintf("  DVF: %d transactions\n", nrow(dvf)))
cat(sprintf("  Panel: %d commune-years\n", nrow(panel)))

dvf[, code_commune := as.factor(code_commune)]
dvf[, dept := as.factor(dept)]
panel[, code_commune := as.factor(code_commune)]
panel[, dept := as.factor(dept)]

# Relative year (2020 = 0)
dvf[, rel_year := year - 2020]

# Standardize treatment intensity for interpretability
# A 1-SD increase in TH rate = meaningful policy variation
th_sd <- sd(dvf$th_rate_2017, na.rm = TRUE)
th_mean <- mean(dvf$th_rate_2017, na.rm = TRUE)
dvf[, th_std := (th_rate_2017 - th_mean) / th_sd]

cat(sprintf("  TH rate: mean = %.2f, SD = %.2f\n", th_mean, th_sd))

# ============================================================================
# 2. Summary Statistics
# ============================================================================

cat("\n=== Summary Statistics ===\n")

summ_year <- dvf[, .(
  N = .N,
  Mean_Price_m2 = round(mean(price_m2), 0),
  Median_Price_m2 = round(median(price_m2), 0),
  SD_Price_m2 = round(sd(price_m2), 0),
  Pct_Apartment = round(100 * mean(is_apartment), 1),
  Mean_Surface = round(mean(surface_reelle_bati), 1)
), by = year][order(year)]
print(summ_year)

fwrite(summ_year, file.path(TAB, "summary_by_year.csv"))

cat("\nBaseline TH rate percentiles:\n")
print(round(quantile(dvf$th_rate_2017, probs = c(0.10, 0.25, 0.50, 0.75, 0.90)), 2))


# ============================================================================
# 3. STRATEGY A: Cross-Sectional Identification
# ============================================================================

cat("\n=== Strategy A: Cross-Sectional ===\n")
cat("  (Département FE allow cross-commune TH variation to identify effect)\n")

# A1: Département FE + year FE — th_rate_2017 not absorbed
a1 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept + year,
            data = dvf,
            cluster = ~dept)

cat("\nA1: Cross-sectional (dept + year FE)\n")
summary(a1)

# A2: Département × year FE
a2 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf,
            cluster = ~dept)

cat("\nA2: Cross-sectional (dept×year FE)\n")
summary(a2)

# A3: Add commune-level controls (property type composition, surface)
a3 <- feols(log_price_m2 ~ th_rate_2017 + tfb_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf,
            cluster = ~dept)

cat("\nA3: Cross-sectional with TFB control\n")
summary(a3)


# ============================================================================
# 4. STRATEGY B: Panel — Differential Time Trends
# ============================================================================

cat("\n=== Strategy B: Panel (Commune FE + Year FE) ===\n")
cat("  (Exploits reform intensification 2020-2024: reform_share varies over time)\n")

# The reform went from ~80% to 100% between 2020-2023.
# With commune FE, identification comes from: high-TH communes experiencing
# faster price growth relative to low-TH communes as reform completes.

# B1: th_rate_2017 × year interaction (event study)
b1 <- feols(log_price_m2 ~ i(rel_year, treatment_intensity, ref = 0) +
              is_apartment + log(surface_reelle_bati) |
              code_commune + year,
            data = dvf,
            cluster = ~dept)

cat("\nB1: Event study (th_rate × year dummies)\n")
summary(b1)

# B2: Same with département × year FE
b2 <- feols(log_price_m2 ~ i(rel_year, treatment_intensity, ref = 0) +
              is_apartment + log(surface_reelle_bati) |
              code_commune + dept^year,
            data = dvf,
            cluster = ~dept)

cat("\nB2: Event study with dept×year FE\n")
summary(b2)

# Save event study model
saveRDS(b1, file.path(DAT, "event_study_model.rds"))

# Extract event study coefficients
es_coefs <- as.data.table(coeftable(b1))
es_coefs[, term := rownames(coeftable(b1))]
fwrite(es_coefs, file.path(TAB, "event_study_coefs.csv"))

# B3: Linear trend interaction — does price growth accelerate with TH rate?
dvf[, year_centered := year - 2022]  # Center at midpoint
b3 <- feols(log_price_m2 ~ treatment_intensity:year_centered +
              is_apartment + log(surface_reelle_bati) |
              code_commune + year,
            data = dvf,
            cluster = ~dept)

cat("\nB3: Linear differential trend\n")
summary(b3)


# ============================================================================
# 5. Quartile-Based Analysis (Sharper Contrast)
# ============================================================================

cat("\n=== Quartile-Based Analysis ===\n")

dvf_q1q4 <- dvf[th_quartile %in% c("Q1", "Q4")]
dvf_q1q4[, high_th := as.integer(th_quartile == "Q4")]

# Cross-sectional: Q4 vs Q1 level difference
q_xs <- feols(log_price_m2 ~ high_th +
                is_apartment + log(surface_reelle_bati) |
                dept^year,
              data = dvf_q1q4,
              cluster = ~dept)

cat("\nQuartile cross-sectional (Q4 vs Q1, dept×year FE):\n")
summary(q_xs)

# Event study for Q4 vs Q1
es_bin <- feols(log_price_m2 ~ i(rel_year, high_th, ref = 0) +
                  is_apartment + log(surface_reelle_bati) |
                  code_commune + year,
                data = dvf_q1q4,
                cluster = ~dept)

cat("\nQuartile event study (Q4 vs Q1):\n")
summary(es_bin)

saveRDS(es_bin, file.path(DAT, "event_study_binned.rds"))


# ============================================================================
# 6. Fiscal Substitution: TFB Response
# ============================================================================

cat("\n=== Fiscal Substitution ===\n")

# Key question: Did communes with higher TH dependence raise TFB to compensate?
# REI panel: 2017, 2020, 2022, 2024

# Load REI directly for fiscal substitution (not from DVF panel)
rei_clean <- fread(file.path(DAT, "rei_clean.csv"))
rei_clean[, code_commune := as.character(code_commune)]

# Build fiscal panel from REI data
th_baseline <- fread(file.path(DAT, "th_baseline_2017.csv"))
th_baseline[, code_commune := as.character(code_commune)]

tfb_baseline <- rei_clean[year == 2017 & !is.na(taux_tfb),
                          .(code_commune, tfb_rate_2017 = taux_tfb)]

tfb_panel <- rei_clean[!is.na(taux_tfb), .(code_commune, year, taux_tfb)]
tfb_panel <- merge(tfb_panel, th_baseline, by = "code_commune", all.x = TRUE)
tfb_panel <- merge(tfb_panel, tfb_baseline, by = "code_commune", all.x = TRUE)
tfb_panel <- tfb_panel[!is.na(th_rate_2017)]
tfb_panel[, dept := substr(code_commune, 1, 2)]

rei_years <- sort(unique(tfb_panel$year))
cat(sprintf("  REI years with TFB data: %s\n", paste(rei_years, collapse = ", ")))
cat(sprintf("  Communes in fiscal panel: %d\n", uniqueN(tfb_panel$code_commune)))

if (nrow(tfb_panel) > 1000) {

  tfb_panel[, post := as.integer(year >= 2020)]
  tfb_panel[, code_commune := as.factor(code_commune)]
  tfb_panel[, dept := as.factor(dept)]
  tfb_panel[, rel_year := year - 2020]

  # Cross-sectional: TFB change 2017→2024 vs TH_2017
  tfb_wide <- dcast(tfb_panel, code_commune + th_rate_2017 + tfb_rate_2017 + dept ~ year,
                    value.var = "taux_tfb", fun.aggregate = mean)

  if ("2024" %in% names(tfb_wide) && "2017" %in% names(tfb_wide)) {
    tfb_wide[, delta_tfb := `2024` - `2017`]
    tfb_wide <- tfb_wide[!is.na(delta_tfb)]

    cat(sprintf("\n  Mean TFB change 2017→2024: +%.2f pp\n",
                mean(tfb_wide$delta_tfb, na.rm = TRUE)))
    cat(sprintf("  Corr(TH_2017, delta_TFB): %.3f\n",
                cor(tfb_wide$th_rate_2017, tfb_wide$delta_tfb, use = "complete.obs")))

    # Regression: TFB change on TH_2017 (cross-sectional)
    fs_xs <- feols(delta_tfb ~ th_rate_2017 | dept,
                   data = tfb_wide,
                   cluster = ~dept)

    cat("\nFiscal substitution (cross-sectional):\n")
    summary(fs_xs)

    # With TFB baseline control
    fs_xs2 <- feols(delta_tfb ~ th_rate_2017 + tfb_rate_2017 | dept,
                    data = tfb_wide,
                    cluster = ~dept)

    cat("\nWith TFB baseline control:\n")
    summary(fs_xs2)

    sink(file.path(TAB, "fiscal_substitution.tex"))
    etable(fs_xs, fs_xs2,
           dict = c("th_rate_2017" = "TH Rate (2017)",
                    "tfb_rate_2017" = "TFB Rate (2017)"),
           se.below = TRUE,
           fitstat = ~ n + r2,
           tex = TRUE,
           title = "Fiscal Substitution: TFB Rate Change (2017--2024) on Baseline TH Rate",
           label = "tab:fiscal_sub")
    sink()
  }

  # Panel event study for TFB
  if (length(rei_years) >= 3) {
    fs_es <- feols(taux_tfb ~ i(rel_year, th_rate_2017, ref = 0) |
                     code_commune + year,
                   data = tfb_panel[year %in% rei_years],
                   cluster = ~dept)

    cat("\nTFB Event Study:\n")
    summary(fs_es)

    saveRDS(fs_es, file.path(DAT, "fiscal_substitution_es.rds"))
  }

  if ("delta_tfb" %in% names(tfb_wide)) {
    fwrite(tfb_wide[, .(code_commune, th_rate_2017, tfb_rate_2017, delta_tfb)],
           file.path(DAT, "fiscal_change_panel.csv"))
  }
}


# ============================================================================
# 7. Net Capitalization Decomposition
# ============================================================================

cat("\n=== Net Capitalization ===\n")

fiscal_file <- file.path(DAT, "fiscal_change_panel.csv")
if (file.exists(fiscal_file)) {
  fiscal <- fread(fiscal_file)
  fiscal[, net_benefit := th_rate_2017 - delta_tfb]

  cat(sprintf("  Mean TH rate (2017): %.2f pp\n", mean(fiscal$th_rate_2017, na.rm = TRUE)))
  cat(sprintf("  Mean TFB increase: +%.2f pp\n", mean(fiscal$delta_tfb, na.rm = TRUE)))
  cat(sprintf("  Mean net fiscal benefit: %.2f pp\n", mean(fiscal$net_benefit, na.rm = TRUE)))
  cat(sprintf("  Substitution rate: %.1f%%\n",
              100 * mean(fiscal$delta_tfb, na.rm = TRUE) / mean(fiscal$th_rate_2017, na.rm = TRUE)))

  # Merge to DVF and estimate net capitalization
  dvf_net <- merge(dvf, fiscal[, .(code_commune = as.factor(code_commune), delta_tfb, net_benefit)],
                   by = "code_commune", all.x = TRUE)

  if (sum(!is.na(dvf_net$net_benefit)) > 10000) {
    m_net <- feols(log_price_m2 ~ net_benefit +
                     is_apartment + log(surface_reelle_bati) |
                     dept^year,
                   data = dvf_net,
                   cluster = ~dept)

    cat("\nNet capitalization (cross-sectional, net_benefit = TH_2017 - delta_TFB):\n")
    summary(m_net)
  }
}


# ============================================================================
# 8. Save Summary
# ============================================================================

cat("\n=== Key Estimates Summary ===\n")

results <- data.table(
  model = c("A1: XS (dept+year)", "A2: XS (dept×year)", "A3: XS + TFB control",
            "B1: Panel ES", "B3: Panel trend"),
  coefficient = c(coef(a1)["th_rate_2017"], coef(a2)["th_rate_2017"],
                  coef(a3)["th_rate_2017"],
                  NA_real_, coef(b3)["treatment_intensity:year_centered"]),
  se = c(se(a1)["th_rate_2017"], se(a2)["th_rate_2017"],
         se(a3)["th_rate_2017"],
         NA_real_, se(b3)["treatment_intensity:year_centered"]),
  n_obs = c(a1$nobs, a2$nobs, a3$nobs, b1$nobs, b3$nobs)
)
results[, t_stat := coefficient / se]

cat("\n")
print(results)

fwrite(results, file.path(TAB, "main_estimates_summary.csv"))

# Save main table
sink(file.path(TAB, "main_results.tex"))
etable(a1, a2, a3,
       dict = c("th_rate_2017" = "TH Rate (2017)",
                "tfb_rate_2017" = "TFB Rate (2017)",
                "is_apartment" = "Apartment",
                "log(surface_reelle_bati)" = "Log Surface"),
       se.below = TRUE,
       fitstat = ~ n + r2 + wr2,
       tex = TRUE,
       title = "Cross-Sectional Effect of TH Abolition on Property Prices",
       label = "tab:main_results")
sink()

cat("\n=== Main analysis complete ===\n")
