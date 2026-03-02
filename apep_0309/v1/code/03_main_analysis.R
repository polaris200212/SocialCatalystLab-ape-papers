## ============================================================
## 03_main_analysis.R
## Primary DR estimation of PDMP network spillover effects
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

## ============================================================
## 1. DOUBLY ROBUST DiD: Primary Specification
##    Treatment: high_exposure_50 (≥50% neighbors have must-query PDMP)
##    Outcome: total overdose death rate per 100,000
## ============================================================

cat("=== PRIMARY ANALYSIS: DR DiD for PDMP Network Exposure ===\n\n")

# --- 1a. Prepare data for DRDID ---
# DRDID works with repeated cross-sections or panel data
# We have a balanced panel: state × year

# Focus on post-2015 period (VSRR data with consistent measurement)
# Use 2015 as pre-period and construct 2-period panels for each post year

# Covariate matrix for propensity score and outcome regression
covariates <- c("log_pop", "log_income", "pct_bachelors", "pct_white",
                "pct_uninsured", "unemployment_rate", "own_pdmp",
                "has_naloxone", "has_good_samaritan", "has_medicaid_expansion",
                "degree")

# --- 1b. Callaway-Sant'Anna (2021) with DR ---
# This handles the staggered adoption of network exposure properly

cat("Running Callaway-Sant'Anna DR estimator...\n")

cs_data <- panel %>%
  filter(year >= 2006, !is.na(total_overdose_rate)) %>%
  mutate(
    state_id = as.integer(factor(state_abbr)),
    # For CS: first treatment period (0 = never treated)
    g = first_high_exposure_year
  ) %>%
  filter(!is.na(log_pop), !is.na(log_income))

# Callaway-Sant'Anna with DR (doubly robust) and not-yet-treated control
# First try with not-yet-treated; if singular, try simpler formula
cs_out <- tryCatch({
  att_gt(
    yname = "total_overdose_rate",
    tname = "year",
    idname = "state_id",
    gname = "g",
    data = cs_data,
    control_group = "notyettreated",
    est_method = "dr",  # doubly robust
    xformla = ~ log_pop + pct_white + unemployment_rate + own_pdmp,
    clustervars = "state_id",
    print_details = FALSE
  )
}, error = function(e) {
  cat("CS-DiD (simple formula) error:", e$message, "\n")
  # Fallback: no covariates
  tryCatch({
    att_gt(
      yname = "total_overdose_rate",
      tname = "year",
      idname = "state_id",
      gname = "g",
      data = cs_data,
      control_group = "notyettreated",
      est_method = "reg",
      print_details = FALSE
    )
  }, error = function(e2) {
    cat("CS-DiD (no covariates) error:", e2$message, "\n")
    NULL
  })
})

if (!is.null(cs_out)) {
  # Aggregate to event-study
  cs_es <- aggte(cs_out, type = "dynamic", na.rm = TRUE)
  cat("\nCS-DiD Event Study (Dynamic ATT):\n")
  print(summary(cs_es))

  # Aggregate to simple ATT
  cs_simple <- aggte(cs_out, type = "simple", na.rm = TRUE)
  cat("\nCS-DiD Simple ATT:\n")
  cat("  ATT =", round(cs_simple$overall.att, 3), "\n")
  cat("  SE  =", round(cs_simple$overall.se, 3), "\n")
  cat("  95% CI: [", round(cs_simple$overall.att - 1.96 * cs_simple$overall.se, 3),
      ",", round(cs_simple$overall.att + 1.96 * cs_simple$overall.se, 3), "]\n")

  # Group-specific ATTs
  cs_group <- aggte(cs_out, type = "group", na.rm = TRUE)
  cat("\nCS-DiD Group ATTs:\n")
  print(summary(cs_group))
}

## ============================================================
## 2. TWFE Benchmark (for comparison/Goodman-Bacon decomp)
## ============================================================

cat("\n\n=== TWFE BENCHMARK ===\n")

# Standard TWFE regression
twfe_total <- feols(
  total_overdose_rate ~ high_exposure_50 + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("\nTWFE: Total Overdose Rate ~ Network Exposure\n")
print(summary(twfe_total))

# With continuous exposure
twfe_cont <- feols(
  total_overdose_rate ~ share_neighbors_pdmp + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("\nTWFE: Continuous Network Exposure\n")
print(summary(twfe_cont))

# Population-weighted exposure
twfe_popw <- feols(
  total_overdose_rate ~ share_neighbors_pdmp_popw + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("\nTWFE: Population-Weighted Network Exposure\n")
print(summary(twfe_popw))

## ============================================================
## 3. Drug-Type Decomposition (VSRR period: 2015-2023)
## ============================================================

cat("\n\n=== DRUG-TYPE DECOMPOSITION ===\n")

drug_types <- c("rx_opioids_rate", "heroin_rate", "synthetic_opioids_rate",
                "cocaine_rate", "psychostimulants_rate")

drug_results <- list()

for (drug in drug_types) {
  cat("\n--- ", drug, " ---\n")

  # TWFE for each drug type
  fml <- as.formula(paste0(drug, " ~ high_exposure_50 + own_pdmp + ",
                           "has_naloxone + has_good_samaritan + has_medicaid_expansion | ",
                           "state_abbr + year"))

  drug_results[[drug]] <- feols(
    fml,
    data = panel %>% filter(year >= 2015, !is.na(.data[[drug]])),
    cluster = ~state_abbr
  )

  cat("  Coefficient:", round(coef(drug_results[[drug]])["high_exposure_50"], 3), "\n")
  cat("  SE:", round(se(drug_results[[drug]])["high_exposure_50"], 3), "\n")
  cat("  p-value:", round(fixest::pvalue(drug_results[[drug]])["high_exposure_50"], 3), "\n")
}

## ============================================================
## 4. AIPW Estimation (Cross-sectional DR)
## ============================================================

cat("\n\n=== AIPW CROSS-SECTIONAL DR ===\n")

# Use pre/post comparison: pre = 2010-2012, post = 2020-2022
# Treatment = high_exposure_50 in the post period

for (post_yr in c(2018, 2020, 2022)) {
  cat("\nAIPW: Post year =", post_yr, "\n")

  # Cross-section at post_yr
  cs_cross <- panel %>%
    filter(year == post_yr, !is.na(total_overdose_rate),
           !is.na(log_pop), !is.na(log_income)) %>%
    mutate(treatment = high_exposure_50)

  if (nrow(cs_cross) < 20) {
    cat("  Skipping: too few observations\n")
    next
  }

  # AIPW estimation
  aipw_fit <- tryCatch({
    AIPW_tmle <- AIPW$new(
      Y = cs_cross$total_overdose_rate,
      A = cs_cross$treatment,
      W = cs_cross %>% select(all_of(c("log_pop", "log_income", "pct_white",
                                        "unemployment_rate", "own_pdmp",
                                        "pre_overdose_rate"))) %>%
        as.data.frame(),
      Q.SL.library = c("SL.glm", "SL.ranger"),
      g.SL.library = c("SL.glm", "SL.ranger"),
      k_split = 5,
      verbose = FALSE
    )
    AIPW_tmle$fit()
    AIPW_tmle$summary()
  }, error = function(e) {
    cat("  AIPW error:", e$message, "\n")
    NULL
  })
}

## ============================================================
## 5. Network Position Heterogeneity
## ============================================================

cat("\n\n=== NETWORK POSITION HETEROGENEITY ===\n")

# Test: Do states with more borders (higher degree centrality)
# experience larger spillovers?

panel <- panel %>%
  mutate(high_degree = ifelse(degree >= median(degree, na.rm = TRUE), 1, 0))

het_degree <- feols(
  total_overdose_rate ~ high_exposure_50 * high_degree + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Degree Centrality Heterogeneity:\n")
print(summary(het_degree))

## ============================================================
## 6. Save results
## ============================================================

cat("\nSaving analysis results...\n")

results <- list(
  cs_out = cs_out,
  cs_es = if (exists("cs_es")) cs_es else NULL,
  cs_simple = if (exists("cs_simple")) cs_simple else NULL,
  twfe_total = twfe_total,
  twfe_cont = twfe_cont,
  twfe_popw = twfe_popw,
  drug_results = drug_results,
  het_degree = het_degree
)

saveRDS(results, paste0(data_dir, "main_results.rds"))
cat("Results saved to main_results.rds\n")

cat("\n==============================\n")
cat("Main analysis complete.\n")
cat("==============================\n")
