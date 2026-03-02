## ============================================================================
## 03_main_analysis.R — Primary Regressions
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

## ========================================================================
## 1. LOAD AND PREPARE DATA
## ========================================================================
cat("=== Loading analysis panel ===\n")

panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))

cat("Panel dimensions:", nrow(panel), "x", ncol(panel), "\n")
cat("Columns:", paste(names(panel), collapse = ", "), "\n")
cat("Regions:", length(unique(panel$fr_region)), "\n")
cat("Year range:", range(panel$year), "\n")
cat("DVF non-missing:", sum(!is.na(panel$log_price_m2)), "\n")

# Analysis dataset: drop missing outcome/exposure
ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk)]
cat("\nAnalysis sample:", nrow(ad), "observations\n")
cat("  Units:", length(unique(ad$fr_region)), "\n")
cat("  Periods:", length(unique(ad$yq)), "\n")
cat("  Year range:", range(ad$year), "\n")

## ========================================================================
## 2. MAIN REGRESSIONS — HOUSING PRICES
## ========================================================================
cat("\n=== Running main regressions ===\n")

# ---- Model 1: Baseline — Log SCI(UK) × Post-Referendum ----
m1 <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
              fr_region + yq,
            data = ad, cluster = ~fr_region)
cat("\nModel 1 — Housing prices × Post-Referendum:\n")
summary(m1)

# ---- Model 2: Separate uncertainty and trade friction effects ----
m2 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
              log_sci_uk:post_transition |
              fr_region + yq,
            data = ad, cluster = ~fr_region)
cat("\nModel 2 — Separate referendum + transition:\n")
summary(m2)

# ---- Model 3: German placebo (should be null) ----
m3 <- feols(log_price_m2 ~ log_sci_de:post_referendum |
              fr_region + yq,
            data = ad, cluster = ~fr_region)
cat("\nModel 3 — German placebo:\n")
summary(m3)

# ---- Model 4: UK + Germany horse race ----
m4 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
              log_sci_de:post_referendum |
              fr_region + yq,
            data = ad, cluster = ~fr_region)
cat("\nModel 4 — UK + German placebo (horse race):\n")
summary(m4)

# ---- Model 5: Transaction volume ----
ad_trans <- ad[!is.na(log_transactions)]
if (nrow(ad_trans) > 0) {
  m5 <- feols(log_transactions ~ log_sci_uk:post_referendum |
                fr_region + yq,
              data = ad_trans, cluster = ~fr_region)
  cat("\nModel 5 — Transaction volume:\n")
  summary(m5)
} else {
  m5 <- NULL
  cat("\nModel 5: No transaction data available.\n")
}

# Save regression results
results <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5)

## ========================================================================
## 3. UNEMPLOYMENT AND FIRM CREATION (if available)
## ========================================================================

# Try loading INSEE unemployment data
unemp_file <- file.path(data_dir, "insee_unemployment_region.rds")
if (file.exists(unemp_file)) {
  cat("\n=== Unemployment analysis ===\n")
  unemp_raw <- readRDS(unemp_file)
  # Parse and merge — structure depends on what INSEE package returned
  cat("  Unemployment data:", nrow(unemp_raw), "observations\n")
  cat("  Columns:", paste(names(unemp_raw), collapse = ", "), "\n")
  # Attempt to merge with panel — will depend on column structure
  # For now, flag as available
  results$unemp_available <- TRUE
} else {
  cat("\nNo unemployment data available.\n")
  results$unemp_available <- FALSE
}

# Try loading firm creation data
firms_file <- file.path(data_dir, "insee_firms_region.rds")
if (file.exists(firms_file)) {
  cat("\n=== Firm creation analysis ===\n")
  firms_raw <- readRDS(firms_file)
  cat("  Firm creation data:", nrow(firms_raw), "observations\n")
  results$firms_available <- TRUE
} else {
  cat("\nNo firm creation data available.\n")
  results$firms_available <- FALSE
}

# Placeholder models for unemployment and firm creation
results$m6 <- NULL  # Unemployment
results$m7 <- NULL  # Unemployment German placebo
results$m8 <- NULL  # Firm creation

## ========================================================================
## 4. EVENT STUDY — QUARTER-BY-QUARTER EFFECTS
## ========================================================================
cat("\n=== Event study ===\n")

# Determine the reference quarter
# If data starts at 2020, the referendum (2016Q3) is well before our sample
# The relevant event is the transition end (2021Q1)
# Reference period: the last pre-transition quarter

min_year <- min(ad$year)
cat("Data starts:", min_year, "\n")

if (min_year <= 2016) {
  # We have pre-referendum data — do referendum event study
  ref_quarter <- ad[year == 2016 & quarter == 2, unique(t)]
  if (length(ref_quarter) == 0) ref_quarter <- min(ad$t) + 8
  ad[, ref_period := t - ref_quarter]
  event_label <- "Brexit Referendum (2016 Q3)"
  cat("  Event study around referendum. Reference: 2016Q2 (t =", ref_quarter, ")\n")
} else {
  # Data starts post-2016 — do transition event study
  ref_quarter <- ad[year == 2020 & quarter == 4, unique(t)]
  if (length(ref_quarter) == 0) ref_quarter <- min(ad[year == 2020]$t) + 3
  ad[, ref_period := t - ref_quarter]
  event_label <- "End of Transition Period (2021 Q1)"
  cat("  Event study around transition end. Reference: 2020Q4 (t =", ref_quarter, ")\n")
}

cat("  Period range:", range(ad$ref_period), "\n")

# Event study regression
es_model <- feols(log_price_m2 ~ i(ref_period, log_sci_uk, ref = 0) |
                    fr_region + yq,
                  data = ad, cluster = ~fr_region)
cat("\nEvent study coefficients:\n")
summary(es_model)

results$event_study <- es_model
results$event_label <- event_label

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
cat("Results saved to:", file.path(data_dir, "main_results.rds"), "\n")
