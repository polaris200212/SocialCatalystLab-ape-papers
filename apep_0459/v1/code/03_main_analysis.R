## 03_main_analysis.R — Primary DiD specifications
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
output_dir <- "../"

analysis <- fread(paste0(data_dir, "analysis_panel.csv"))
cat("Analysis panel loaded:", nrow(analysis), "state-years\n")

## ============================================================================
## TABLE 1: Summary Statistics
## ============================================================================

cat("\n=== Summary Statistics ===\n")

## Pre-treatment means by treatment status
pre_treat <- analysis[year <= 2021]
pre_means <- pre_treat[, .(
  share_no_ba = weighted.mean(share_no_ba, n_state_gov, na.rm = TRUE),
  mean_wages = weighted.mean(mean_wages, n_state_gov, na.rm = TRUE),
  pct_female = weighted.mean(pct_female, n_state_gov, na.rm = TRUE),
  pct_black = weighted.mean(pct_black, n_state_gov, na.rm = TRUE),
  mean_age = weighted.mean(mean_age, n_state_gov, na.rm = TRUE),
  n_states = uniqueN(state_fips),
  mean_state_gov_emp = mean(n_state_gov, na.rm = TRUE),
  mean_unemp = mean(unemp_rate, na.rm = TRUE)
), by = .(group = ifelse(first_treat > 0, "Treated", "Never-treated"))]

print(pre_means)

## ============================================================================
## SPECIFICATION 1: TWFE (Baseline)
## ============================================================================

cat("\n=== TWFE Regression ===\n")

## Standard TWFE for comparison
twfe <- feols(share_no_ba ~ treated | state_fips + year,
              data = analysis,
              weights = ~n_state_gov,
              cluster = ~state_fips)
cat("TWFE coefficient on treatment:\n")
print(summary(twfe))

## ============================================================================
## SPECIFICATION 2: Callaway-Sant'Anna (Primary)
## ============================================================================

cat("\n=== Callaway-Sant'Anna DiD ===\n")

## Prepare data for CS estimator
cs_data <- as.data.frame(analysis[, .(
  state_fips, year, first_treat, share_no_ba, n_state_gov,
  unemp_rate, share_no_ba_private
)])

## CS ATT(g,t) — never-treated as comparison
cs_out <- tryCatch({
  att_gt(
    yname = "share_no_ba",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = cs_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "reg",
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS estimation error:", conditionMessage(e), "\n")
  cat("Trying with default base_period...\n")
  att_gt(
    yname = "share_no_ba",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = cs_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "reg"
  )
})

cat("CS ATT(g,t) results:\n")
print(summary(cs_out))

## Aggregate to event study
es_cs <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 2)
cat("\nCS Event Study:\n")
print(summary(es_cs))

## Overall ATT
att_overall <- aggte(cs_out, type = "simple")
cat("\nCS Overall ATT:\n")
print(summary(att_overall))

## Group-specific ATT
att_group <- aggte(cs_out, type = "group")
cat("\nCS Group ATT:\n")
print(summary(att_group))

## ============================================================================
## SPECIFICATION 3: Sun & Abraham (Sensitivity Check)
## ============================================================================

cat("\n=== Sun & Abraham Estimator ===\n")

## Create relative time variable
analysis[, rel_time := ifelse(first_treat > 0, year - first_treat, -1000)]

## Sun-Abraham via fixest
sunab_out <- feols(share_no_ba ~ sunab(first_treat, year) | state_fips + year,
                   data = analysis[first_treat == 0 | first_treat > 0],
                   weights = ~n_state_gov,
                   cluster = ~state_fips)
cat("Sun-Abraham results:\n")
print(summary(sunab_out))

## ============================================================================
## SPECIFICATION 4: Triple-Difference (DDD) Placebo
## ============================================================================

cat("\n=== Triple-Difference (State Gov vs Private) ===\n")

## Reshape to long format with sector dimension
ddd_state <- analysis[, .(state_fips, year, first_treat, treated, n_state_gov,
                          outcome = share_no_ba, sector = "State gov")]
ddd_private <- analysis[, .(state_fips, year, first_treat, treated, n_state_gov,
                            outcome = share_no_ba_private, sector = "Private")]

ddd_data <- rbind(ddd_state, ddd_private)
ddd_data[, is_state_gov := as.integer(sector == "State gov")]

## DDD: treatment × state_gov interaction
ddd_reg <- feols(outcome ~ treated * is_state_gov | state_fips^is_state_gov + year^is_state_gov,
                 data = ddd_data,
                 weights = ~n_state_gov,
                 cluster = ~state_fips)
cat("DDD coefficient (treated:is_state_gov):\n")
print(summary(ddd_reg))

## ============================================================================
## SPECIFICATION 5: Heterogeneity by Policy Strength
## ============================================================================

cat("\n=== Heterogeneity by Policy Strength ===\n")

## Split by strong vs moderate policies
analysis[, strong_policy := as.integer(strength == "strong" & treated == 1)]
analysis[, moderate_policy := as.integer(strength == "moderate" & treated == 1)]

hetero_strength <- feols(share_no_ba ~ strong_policy + moderate_policy | state_fips + year,
                         data = analysis,
                         weights = ~n_state_gov,
                         cluster = ~state_fips)
cat("Heterogeneity by policy strength:\n")
print(summary(hetero_strength))

## ============================================================================
## SAVE RESULTS
## ============================================================================

## Save key objects for figures and tables
save(twfe, cs_out, es_cs, att_overall, att_group, sunab_out, ddd_reg,
     hetero_strength, analysis,
     file = paste0(data_dir, "main_results.RData"))

cat("\n=== Main analysis complete. Results saved. ===\n")
