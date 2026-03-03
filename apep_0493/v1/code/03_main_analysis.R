# =============================================================================
# 03_main_analysis.R — Main DiD estimation
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

source("00_packages.R")

panel <- fread(file.path(data_dir, "analysis_panel.csv")) |>
  mutate(date = as.Date(date))

cat("Panel loaded:", nrow(panel), "rows,", n_distinct(panel$la_code), "LAs\n")

# =============================================================================
# 1. TWFE DiD (Binary Treatment)
# =============================================================================
cat("\n=== Two-Way Fixed Effects DiD ===\n")

# Main specification: claimant_rate ~ treat × post | LA FE + month FE
mod_twfe <- feols(
  claimant_rate ~ treat_binary:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nTWFE (Binary Treatment):\n")
summary(mod_twfe)

# Continuous treatment
mod_cont <- feols(
  claimant_rate ~ treat_continuous:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nTWFE (Continuous Treatment):\n")
summary(mod_cont)

# =============================================================================
# 2. Event Study (Binary Treatment)
# =============================================================================
cat("\n=== Event Study ===\n")

# Create relative time bins (quarterly to reduce noise)
panel <- panel |>
  mutate(
    rel_quarter = floor(rel_month / 3),
    # Cap at [-8, +16] quarters relative to reform
    rel_quarter_binned = pmax(pmin(rel_quarter, 16), -8)
  )

# Event study with quarterly bins
mod_es <- feols(
  claimant_rate ~ i(rel_quarter_binned, treat_binary, ref = -1) | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nEvent Study coefficients:\n")
summary(mod_es)

# Save event study data for plotting
es_data <- as.data.frame(coeftable(mod_es)) |>
  tibble::rownames_to_column("term") |>
  filter(str_detect(term, "rel_quarter")) |>
  mutate(
    quarter = as.numeric(str_extract(term, "-?\\d+")),
    estimate = Estimate,
    se = `Std. Error`,
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se
  )

fwrite(es_data, file.path(data_dir, "event_study_coefs.csv"))

# =============================================================================
# 3. Pre-Trends Test
# =============================================================================
cat("\n=== Pre-Trends Test ===\n")

# Joint F-test on pre-reform coefficients
pre_coefs <- es_data |> filter(quarter < -1)
cat("Pre-reform coefficients:\n")
print(pre_coefs |> select(quarter, estimate, se))

# Wald test for joint significance of pre-trends
pre_terms <- paste0("rel_quarter_binned::", pre_coefs$quarter, ":treat_binary")
wald_result <- tryCatch({
  wald(mod_es, pre_terms)
}, error = function(e) {
  cat("  Wald test error:", e$message, "\n")
  NULL
})

if (!is.null(wald_result)) {
  cat("\nWald test for pre-trends (H0: all pre-reform coefficients = 0):\n")
  print(wald_result)
}

# =============================================================================
# 4. Tercile Analysis (Dose-Response)
# =============================================================================
cat("\n=== Dose-Response (Tercile Analysis) ===\n")

# Create tercile dummies
panel <- panel |>
  mutate(
    tercile_2 = as.integer(treat_tercile == 2),  # Middle cut
    tercile_3 = as.integer(treat_tercile == 3)    # Highest CTS (protected)
  )

# Reference group: tercile 1 (most cut)
mod_tercile <- feols(
  claimant_rate ~ tercile_2:post + tercile_3:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nTercile analysis (ref = most cut LAs):\n")
summary(mod_tercile)

# =============================================================================
# 5. Log Specification
# =============================================================================
cat("\n=== Log Specification ===\n")

mod_log <- feols(
  log_claimant_rate ~ treat_binary:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nLog specification:\n")
summary(mod_log)

# =============================================================================
# 6. Save Results
# =============================================================================
cat("\n=== Saving results ===\n")

results <- list(
  twfe_binary = mod_twfe,
  twfe_continuous = mod_cont,
  event_study = mod_es,
  tercile = mod_tercile,
  log_spec = mod_log
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("Results saved to main_results.rds\n")

# Print summary table
cat("\n=== MAIN RESULTS SUMMARY ===\n")
cat(sprintf("%-30s %10s %10s %10s\n", "Specification", "Estimate", "SE", "p-value"))
cat(paste(rep("-", 62), collapse = ""), "\n")

specs <- list(
  list("Binary DiD (level)", mod_twfe),
  list("Continuous DiD (level)", mod_cont),
  list("Binary DiD (log)", mod_log)
)

for (s in specs) {
  ct <- coeftable(s[[2]])
  cat(sprintf("%-30s %10.4f %10.4f %10.4f\n",
              s[[1]], ct[1, 1], ct[1, 2], ct[1, 4]))
}
