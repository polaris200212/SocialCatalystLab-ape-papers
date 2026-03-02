##############################################################################
# 03_main_analysis.R — Main DR-DiD analysis
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

source("00_packages.R")

data_dir <- "../data"
out_dir  <- ".."

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
cat("Panel loaded:", nrow(panel), "rows,", uniqueN(panel$csp_name), "CSPs\n")

# ============================================================================
# 1. FIRST STAGE: Document Betting Shop Closures
# ============================================================================
cat("\n=== First Stage: Betting Shop Closure Pattern ===\n")

# The GC premises register shows CURRENT (post-closure) shops
# We know from industry sources that ~700 shops closed in 2019-2020
# The treatment variable (shops_current) is the SURVIVING count
# Pre-policy count ≈ shops_current × 1.15 (approx 15% closed)
# High-density areas lost MORE shops proportionally

# For the paper, we document the cross-sectional pattern
density_summary <- panel[!duplicated(csp_name), .(
  csp_name, shops_current, betting_density, high_density, population = mean_pop
)]
density_summary <- density_summary[order(-shops_current)]

cat("Top 10 CSPs by betting shop count:\n")
print(head(density_summary[, .(csp_name, shops_current, betting_density)], 10))

cat("\nDensity distribution:\n")
cat("  Mean:", round(mean(density_summary$betting_density, na.rm = TRUE), 2), "\n")
cat("  SD:", round(sd(density_summary$betting_density, na.rm = TRUE), 2), "\n")
cat("  P25:", round(quantile(density_summary$betting_density, 0.25, na.rm = TRUE), 2), "\n")
cat("  P50:", round(quantile(density_summary$betting_density, 0.50, na.rm = TRUE), 2), "\n")
cat("  P75:", round(quantile(density_summary$betting_density, 0.75, na.rm = TRUE), 2), "\n")

# ============================================================================
# 2. MAIN SPECIFICATION: Continuous Treatment DiD (fixest)
# ============================================================================
cat("\n=== Main Specification: Continuous Treatment DiD ===\n")

# Primary outcome: total crime rate per 10,000
# Y_{it} = α_i + λ_t + β(Density_i × Post_t) + ε_{it}
# Cluster SE at CSP level

# Baseline: total crime
m1 <- feols(total_offences_rate ~ betting_density:post | csp_id + time_id,
            data = panel, cluster = ~csp_id)
cat("\n--- Model 1: Total Crime Rate ---\n")
print(summary(m1))

# Violence
if ("violence_against_the_person_rate" %in% names(panel)) {
  m2 <- feols(violence_against_the_person_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 2: Violence Rate ---\n")
  print(summary(m2))
}

# Theft offences
if ("theft_offences_rate" %in% names(panel)) {
  m3 <- feols(theft_offences_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 3: Theft Rate ---\n")
  print(summary(m3))
}

# Criminal damage
if ("criminal_damage_and_arson_rate" %in% names(panel)) {
  m4 <- feols(criminal_damage_and_arson_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 4: Criminal Damage Rate ---\n")
  print(summary(m4))
}

# Drug offences (placebo — should be unaffected by betting shop closures)
if ("drug_offences_rate" %in% names(panel)) {
  m5 <- feols(drug_offences_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 5: Drug Offences Rate (Placebo) ---\n")
  print(summary(m5))
}

# Robbery
if ("robbery_rate" %in% names(panel)) {
  m6 <- feols(robbery_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 6: Robbery Rate ---\n")
  print(summary(m6))
}

# Public order
if ("public_order_offences_rate" %in% names(panel)) {
  m7 <- feols(public_order_offences_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Model 7: Public Order Rate ---\n")
  print(summary(m7))
}

# ============================================================================
# 3. BINARY TREATMENT: DR-DiD (Sant'Anna & Zhao 2020)
# ============================================================================
cat("\n=== Binary Treatment DR-DiD ===\n")

# For DRDID, we need pre and post periods (2 periods)
# Pre: 2017/18 (FY before announcement, yq in [2017.25, 2018.0])
# Post: 2021/22 (FY well after implementation, yq in [2021.25, 2022.0])

# Collapse to pre/post means
panel_2period <- panel[financial_year %in% c("2017/18", "2021/22")]
panel_2period[, period := fifelse(financial_year == "2017/18", 0L, 1L)]

# Collapse to CSP × period means
panel_drdid <- panel_2period[, .(
  total_crime_rate = mean(total_offences_rate, na.rm = TRUE),
  violence_rate = mean(get("violence_against_the_person_rate"), na.rm = TRUE),
  theft_rate = mean(get("theft_offences_rate"), na.rm = TRUE)
), by = .(csp_name, csp_id, period, high_density, betting_density, imd_score)]

# Drop CSPs with missing outcome
panel_drdid <- panel_drdid[!is.na(total_crime_rate) & is.finite(total_crime_rate)]

cat("DR-DiD panel:", nrow(panel_drdid), "CSP-period obs\n")
cat("Treated (high density):", uniqueN(panel_drdid[high_density == 1, csp_name]), "\n")
cat("Control (low density):", uniqueN(panel_drdid[high_density == 0, csp_name]), "\n")

# Run DR-DiD using DRDID package
tryCatch({
  # Need balanced panel with pre and post for each unit
  balanced <- panel_drdid[, .(n_periods = .N), by = csp_id][n_periods == 2, csp_id]
  panel_drdid_bal <- panel_drdid[csp_id %in% balanced]
  panel_drdid_bal <- panel_drdid_bal[order(csp_id, period)]

  cat("Balanced panel:", uniqueN(panel_drdid_bal$csp_id), "CSPs × 2 periods\n")

  # Improved local DR-DiD
  if (!is.na(panel_drdid_bal$imd_score[1]) && sum(!is.na(panel_drdid_bal$imd_score)) > 10) {
    drdid_result <- DRDID::drdid(
      yname = "total_crime_rate",
      tname = "period",
      idname = "csp_id",
      dname = "high_density",
      xformla = ~ imd_score,
      data = as.data.frame(panel_drdid_bal)
    )
    cat("\n--- DR-DiD Result (Total Crime) ---\n")
    print(summary(drdid_result))
  } else {
    # Without covariates
    drdid_result <- DRDID::drdid(
      yname = "total_crime_rate",
      tname = "period",
      idname = "csp_id",
      dname = "high_density",
      data = as.data.frame(panel_drdid_bal)
    )
    cat("\n--- DR-DiD Result (Total Crime, no covariates) ---\n")
    print(summary(drdid_result))
  }
}, error = function(e) {
  cat("DR-DiD error:", conditionMessage(e), "\n")
  cat("Falling back to standard DiD with binary treatment...\n")

  m_binary <- feols(total_offences_rate ~ high_density:post | csp_id + time_id,
                    data = panel, cluster = ~csp_id)
  cat("\n--- Binary DiD (fallback) ---\n")
  print(summary(m_binary))
})

# ============================================================================
# 4. EVENT STUDY
# ============================================================================
cat("\n=== Event Study ===\n")

# Trim extreme event times for cleaner estimation
panel_es <- panel[event_time >= -16 & event_time <= 20]

# Event study with continuous treatment
es_model <- feols(total_offences_rate ~ i(event_time, betting_density, ref = -1) |
                    csp_id + time_id,
                  data = panel_es, cluster = ~csp_id)

cat("Event study coefficients:\n")
es_coefs <- coeftable(es_model)
print(es_coefs)

# ============================================================================
# 5. PROPERTY PRICES (Secondary Outcome)
# ============================================================================
cat("\n=== Property Price Analysis ===\n")

if ("log_mean_price" %in% names(panel)) {
  # Property prices are annual (district-year), so collapse to CSP-year panel
  # to avoid duplicating annual values across quarters
  price_annual <- panel[!is.na(log_mean_price),
                        .(log_mean_price = mean(log_mean_price, na.rm = TRUE),
                          betting_density = betting_density[1],
                          post = as.integer(any(post == 1)),
                          csp_id = csp_id[1],
                          population = mean(population, na.rm = TRUE)),
                        by = .(csp_name, merge_year)]
  price_annual[, year_id := as.integer(factor(merge_year))]
  cat("Annual price panel:", nrow(price_annual), "CSP-year obs,",
      uniqueN(price_annual$csp_name), "CSPs\n")

  if (nrow(price_annual) > 100) {
    m_price <- feols(log_mean_price ~ betting_density:post | csp_id + year_id,
                     data = price_annual, cluster = ~csp_id)
    cat("\n--- Property Prices (Log Mean, Annual Panel) ---\n")
    print(summary(m_price))
  } else {
    cat("Insufficient price data for regression\n")
  }
}

# ============================================================================
# 6. SAVE RESULTS
# ============================================================================
cat("\n=== Saving Results ===\n")

results <- list()
results$m_total_crime <- m1
if (exists("m2")) results$m_violence <- m2
if (exists("m3")) results$m_theft <- m3
if (exists("m4")) results$m_criminal_damage <- m4
if (exists("m5")) results$m_drug_placebo <- m5
if (exists("m6")) results$m_robbery <- m6
if (exists("m7")) results$m_public_order <- m7
if (exists("drdid_result")) results$drdid <- drdid_result
results$es_model <- es_model
if (exists("m_price")) results$m_price <- m_price

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("Results saved to main_results.rds\n")
