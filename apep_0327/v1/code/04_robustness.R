## ============================================================================
## 04_robustness.R — Triple-diff, placebo, RI, sensitivity analysis
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load panels ----
annual <- readRDS(file.path(DATA, "panel_annual.rds"))
ddd_panel <- readRDS(file.path(DATA, "panel_ddd.rds"))
monthly <- readRDS(file.path(DATA, "panel_monthly.rds"))

annual[, treat_cohort := fifelse(first_treat_year == 0, 10000L, first_treat_year)]

cat("=== ROBUSTNESS CHECKS ===\n")

## ========================================================================
## 1. TRIPLE-DIFFERENCE (DDD): HCBS vs NON-HCBS × MW INCREASE
## ========================================================================

cat("\n--- Triple-Difference (DDD) ---\n")
cat("HCBS providers (near-MW wages) vs non-HCBS (physician wages >> MW)\n")

ddd_1 <- feols(log_prov ~ hcbs * log_mw | unit_num + year,
               data = ddd_panel[!is.na(log_prov)],
               cluster = ~state)

cat("DDD result (interaction = differential MW effect on HCBS):\n")
summary(ddd_1)

## ========================================================================
## 2. PLACEBO: NON-HCBS PROVIDERS SHOULD NOT RESPOND TO MW
## ========================================================================

cat("\n--- Placebo: Non-HCBS Medicaid Providers ---\n")

placebo_twfe <- feols(log_providers_nonhcbs ~ log_mw | state + year,
                       data = annual[!is.na(log_providers_nonhcbs)],
                       cluster = ~state)

cat("Placebo TWFE (non-HCBS providers ~ log MW):\n")
summary(placebo_twfe)

# CS-DiD placebo
cs_placebo <- tryCatch({
  att_gt(
    yname = "log_providers_nonhcbs",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_year",
    data = as.data.frame(annual[!is.na(log_providers_nonhcbs)]),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS-DiD placebo error:", e$message, "\n")
  NULL
})

if (!is.null(cs_placebo)) {
  cs_placebo_agg <- aggte(cs_placebo, type = "simple")
  cat(sprintf("CS-DiD Placebo ATT: %.4f (SE: %.4f, p: %.4f)\n",
              cs_placebo_agg$overall.att, cs_placebo_agg$overall.se,
              2 * pnorm(-abs(cs_placebo_agg$overall.att / cs_placebo_agg$overall.se))))

  cs_placebo_es <- aggte(cs_placebo, type = "dynamic", min_e = -5, max_e = 5)
  saveRDS(cs_placebo_es, file.path(DATA, "cs_es_placebo.rds"))
}

## ========================================================================
## 3. PROVIDER HETEROGENEITY: INDIVIDUAL VS ORGANIZATIONAL
## ========================================================================

cat("\n--- Provider Heterogeneity ---\n")

het_individual <- feols(log_individual ~ log_mw | state + year,
                         data = annual[!is.na(log_individual)],
                         cluster = ~state)

het_org <- feols(log_org ~ log_mw | state + year,
                  data = annual[!is.na(log_org)],
                  cluster = ~state)

cat("Individual providers (sole practitioners, near-MW):\n")
summary(het_individual)
cat("\nOrganizational providers (agencies):\n")
summary(het_org)

## ========================================================================
## 4. DOSE-RESPONSE: MW "BITE" (KAITZ INDEX)
## ========================================================================

cat("\n--- Dose-Response: MW Bite ---\n")

# The "bite" = MW / median HCBS wage. Higher bite = more binding.
# Proxy: use log(MW) directly — states with higher MW have higher bite
# since HCBS wages are relatively uniform nationally (~$16/hr).
# We can also interact MW with a baseline HCBS wage proxy.

# Create high-MW vs low-MW treatment intensity
annual[, mw_high := as.integer(min_wage >= 12)]  # Above $12 threshold

dose_twfe <- feols(log_providers ~ mw_premium + I(mw_premium^2) | state + year,
                    data = annual, cluster = ~state)

cat("Dose-response (MW premium + squared):\n")
summary(dose_twfe)

## ========================================================================
## 5. RANDOMIZATION INFERENCE (Fisher Permutation)
## ========================================================================

cat("\n--- Randomization Inference ---\n")

# Permute treatment assignment across states 500 times
set.seed(42)
n_perms <- 500

# Get the actual TWFE coefficient
actual_coef <- coef(feols(log_providers ~ log_mw | state + year,
                          data = annual[!is.na(log_providers)]))[["log_mw"]]

cat(sprintf("Actual coefficient: %.6f\n", actual_coef))

# Generate permutation distribution
ri_coefs <- numeric(n_perms)
states_list <- unique(annual$state)
n_states <- length(states_list)

# Permutation: randomly reassign MW trajectories across states
for (i in seq_len(n_perms)) {
  perm_annual <- copy(annual)
  # Shuffle state MW assignments
  state_perm <- sample(states_list)
  mw_map <- data.table(state = states_list, perm_state = state_perm)
  perm_mw <- unique(annual[, .(state, year, log_mw)])
  setnames(perm_mw, "state", "perm_state")
  perm_mw <- merge(mw_map, perm_mw, by = "perm_state", allow.cartesian = TRUE)
  perm_annual <- merge(annual[, !c("log_mw"), with = FALSE],
                       perm_mw[, .(state, year, perm_log_mw = log_mw)],
                       by = c("state", "year"), all.x = TRUE)

  ri_fit <- tryCatch(
    feols(log_providers ~ perm_log_mw | state + year,
          data = perm_annual[!is.na(log_providers) & !is.na(perm_log_mw)]),
    error = function(e) NULL
  )
  if (!is.null(ri_fit)) {
    ri_coefs[i] <- coef(ri_fit)[["perm_log_mw"]]
  }
  if (i %% 100 == 0) cat(sprintf("  RI iteration %d/%d\n", i, n_perms))
}

ri_pvalue <- mean(abs(ri_coefs) >= abs(actual_coef))
cat(sprintf("Randomization Inference p-value: %.4f (two-sided)\n", ri_pvalue))
cat(sprintf("RI distribution: mean=%.6f, sd=%.6f\n", mean(ri_coefs), sd(ri_coefs)))

saveRDS(list(actual = actual_coef, perms = ri_coefs, pvalue = ri_pvalue),
        file.path(DATA, "ri_results.rds"))

## ========================================================================
## 6. MONTHLY SPECIFICATION
## ========================================================================

cat("\n--- Monthly TWFE ---\n")

monthly[, year_month := year * 100 + month_num]
monthly_twfe <- feols(log_providers ~ log_mw | state + year_month,
                       data = monthly[!is.na(log_providers)],
                       cluster = ~state)

cat("Monthly TWFE:\n")
summary(monthly_twfe)

## ========================================================================
## 7. EXCLUDE ARPA STATES WITH LARGE HCBS RATE INCREASES
## ========================================================================

cat("\n--- Excluding ARPA states with large HCBS rate increases ---\n")

# States with documented large HCBS rate increases (2021-2023)
arpa_rate_states <- c("NC", "CO", "VA", "NM", "NY", "CA")

excl_arpa <- feols(log_providers ~ log_mw | state + year,
                    data = annual[!state %in% arpa_rate_states & !is.na(log_providers)],
                    cluster = ~state)

cat("Excluding ARPA rate increase states:\n")
summary(excl_arpa)

## ========================================================================
## 8. SAVE ALL ROBUSTNESS RESULTS
## ========================================================================

robustness <- list(
  ddd = ddd_1,
  placebo = placebo_twfe,
  het_individual = het_individual,
  het_org = het_org,
  dose = dose_twfe,
  ri = list(actual = actual_coef, perms = ri_coefs, pvalue = ri_pvalue),
  monthly = monthly_twfe,
  excl_arpa = excl_arpa
)

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
