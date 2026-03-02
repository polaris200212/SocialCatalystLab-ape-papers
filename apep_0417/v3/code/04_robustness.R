## ============================================================
## 04_robustness.R — Robustness checks and placebo tests
## Paper: Where Medicaid Goes Dark (apep_0417 v2)
## Changes from v1: Replace broken tight-threshold with full-time
## (≥36 claims), add Medicaid-pop denominator spec, region×quarter FE,
## total claims outcome, MD/DO vs all-clinicians comparison
## ============================================================

source("00_packages.R")

cat("\n=== Load Data ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
panel_mdonly <- readRDS(file.path(DATA_DIR, "analysis_panel_mdonly.rds"))
panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]
panel <- panel[!quarter %in% c("2024Q4")]
panel[, treat_intensity := post_unwind * net_disenroll_pct / 100]

panel_mdonly <- panel_mdonly[!is.na(total_pop) & total_pop > 0 &
                             state_fips %in% sprintf("%02d", c(1:56))]
panel_mdonly <- panel_mdonly[!quarter %in% c("2024Q4")]
panel_mdonly[, treat_intensity := post_unwind * net_disenroll_pct / 100]

cat("  Panel rows:", nrow(panel), "\n")

cat("\n=== Robustness 1: Full-Time Provider Threshold (≥36 claims/quarter) ===\n")

# n_providers_ft already computed in 01_fetch_data.R (≥36 claims/quarter)
panel[, ln_providers_ft := log(n_providers_ft + 1)]

rob1 <- feols(ln_providers_ft ~ treat_intensity |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("Full-time threshold (≥36 claims/quarter):\n")
cat("  Coef:", round(coef(rob1)["treat_intensity"], 4),
    "  SE:", round(se(rob1)["treat_intensity"], 4),
    "  p:", round(fixest::pvalue(rob1)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 2: Placebo Test — Pre-Period Fake Treatment ===\n")

panel[, fake_post := quarter >= "2021Q2"]
panel[, fake_treat := fake_post * net_disenroll_pct / 100]

panel_pre <- panel[quarter < unwind_quarter]

placebo <- feols(ln_providers ~ fake_treat |
                   cs_id + quarter,
                 data = panel_pre,
                 cluster = ~state_fips)
cat("Placebo (fake treatment 2021Q2):\n")
cat("  Coef:", round(coef(placebo)["fake_treat"], 4),
    "  SE:", round(se(placebo)["fake_treat"], 4),
    "  p:", round(fixest::pvalue(placebo)["fake_treat"], 4), "\n")

cat("\n=== Robustness 3: Binary Treatment (Early vs Late) ===\n")

panel[, early_adopter := unwind_quarter == "2023Q2"]
panel[, treat_binary := post_unwind * early_adopter]

rob3 <- feols(ln_providers ~ treat_binary |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("Binary treatment (early vs late):\n")
cat("  Coef:", round(coef(rob3)["treat_binary"], 4),
    "  SE:", round(se(rob3)["treat_binary"], 4), "\n")

cat("\n=== Robustness 4: Controlling for State Characteristics ===\n")

panel[, medicaid_share_x_qtr := medicaid_share * qtr_num]

rob4 <- feols(ln_providers ~ treat_intensity + medicaid_share_x_qtr |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("With Medicaid share × time control:\n")
cat("  Coef:", round(coef(rob4)["treat_intensity"], 4),
    "  SE:", round(se(rob4)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 5: Medicaid Population Denominator ===\n")

# Desert using Medicaid-specific denominator
rob5_med <- feols(is_desert_medicaid ~ treat_intensity |
                    cs_id + quarter,
                  data = panel[!is.na(is_desert_medicaid)],
                  cluster = ~state_fips)
cat("Desert (Medicaid pop denominator):\n")
cat("  Coef:", round(coef(rob5_med)["treat_intensity"], 4),
    "  SE:", round(se(rob5_med)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 6: Region × Quarter FE ===\n")

# Census region from state FIPS
region_lookup <- data.table(
  state_fips = sprintf("%02d", c(9,23,25,33,44,50, 34,36,42,
                                  17,18,26,39,55, 19,20,27,29,31,38,46,
                                  10,11,12,13,24,37,45,51,54, 1,21,28,47,
                                  5,22,40,48,
                                  4,8,16,30,32,35,49,56, 2,6,15,41,53)),
  region = c(rep("Northeast", 9), rep("Midwest", 12),
             rep("South", 17), rep("West", 13))
)
panel <- merge(panel, region_lookup, by = "state_fips", all.x = TRUE)
panel[, region_qtr := paste(region, quarter, sep = "_")]

rob6 <- feols(ln_providers ~ treat_intensity |
                cs_id + region_qtr,
              data = panel[!is.na(region)],
              cluster = ~state_fips)
cat("Region × quarter FE:\n")
cat("  Coef:", round(coef(rob6)["treat_intensity"], 4),
    "  SE:", round(se(rob6)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 7: Total Claims as Outcome ===\n")

rob7 <- feols(ln_claims ~ treat_intensity |
                cs_id + quarter,
              data = panel,
              cluster = ~state_fips)
cat("Total claims (log):\n")
cat("  Coef:", round(coef(rob7)["treat_intensity"], 4),
    "  SE:", round(se(rob7)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 8: MD/DO-Only Provider Measure ===\n")

rob8_mdonly <- feols(ln_providers ~ treat_intensity |
                       cs_id + quarter,
                     data = panel_mdonly,
                     cluster = ~state_fips)
cat("MD/DO only (v1 measure):\n")
cat("  Coef:", round(coef(rob8_mdonly)["treat_intensity"], 4),
    "  SE:", round(se(rob8_mdonly)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 9: MD vs NP within All-Clinicians Panel ===\n")

panel_pc <- panel[specialty == "Primary Care"]

rob9_md <- feols(log(n_md + 1) ~ treat_intensity |
                   cs_id + quarter,
                 data = panel_pc,
                 cluster = ~state_fips)

rob9_np <- feols(log(n_np + 1) ~ treat_intensity |
                   cs_id + quarter,
                 data = panel_pc,
                 cluster = ~state_fips)

cat("MD Primary Care:\n")
cat("  Coef:", round(coef(rob9_md)["treat_intensity"], 4),
    "  SE:", round(se(rob9_md)["treat_intensity"], 4), "\n")
cat("NP Primary Care:\n")
cat("  Coef:", round(coef(rob9_np)["treat_intensity"], 4),
    "  SE:", round(se(rob9_np)["treat_intensity"], 4), "\n")

cat("\n=== Robustness 10: Permutation Inference ===\n")

set.seed(42)
n_perms <- 500
observed_coef <- coef(feols(ln_providers ~ treat_intensity | cs_id + quarter,
                            data = panel, cluster = ~state_fips))["treat_intensity"]

perm_coefs <- numeric(n_perms)
states <- unique(panel$state_fips)
actual_timing <- unique(panel[, .(state_fips, unwind_quarter, net_disenroll_pct)])

cat("  Running", n_perms, "permutations...\n")
for (i in seq_len(n_perms)) {
  if (i %% 50 == 0) cat("    Permutation", i, "/", n_perms, "\n")

  shuffled <- copy(actual_timing)
  shuffled[, unwind_quarter := sample(unwind_quarter)]
  shuffled[, net_disenroll_pct := sample(net_disenroll_pct)]

  panel_perm <- merge(panel[, !c("unwind_quarter", "net_disenroll_pct", "post_unwind",
                                  "treat_intensity", "fake_post", "fake_treat",
                                  "early_adopter", "treat_binary",
                                  "medicaid_share_x_qtr"), with = FALSE],
                      shuffled, by = "state_fips")
  panel_perm[, post_unwind := quarter >= unwind_quarter]
  panel_perm[, treat_intensity := post_unwind * net_disenroll_pct / 100]

  tryCatch({
    m_perm <- feols(ln_providers ~ treat_intensity | cs_id + quarter,
                    data = panel_perm, cluster = ~state_fips)
    perm_coefs[i] <- coef(m_perm)["treat_intensity"]
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(observed_coef))

cat("  Observed coefficient:", round(observed_coef, 4), "\n")
cat("  RI p-value (two-sided):", round(ri_pvalue, 3), "\n")
cat("  RI 95% CI: [", round(quantile(perm_coefs, 0.025), 4), ",",
    round(quantile(perm_coefs, 0.975), 4), "]\n")

cat("\n=== Save Robustness Results ===\n")

robustness <- list(
  rob1_ft = rob1,
  placebo = placebo,
  rob3_binary = rob3,
  rob4_controls = rob4,
  rob5_medicaid_denom = rob5_med,
  rob6_region_qtr = rob6,
  rob7_claims = rob7,
  rob8_mdonly = rob8_mdonly,
  rob9_md = rob9_md,
  rob9_np = rob9_np,
  ri_pvalue = ri_pvalue,
  ri_observed = observed_coef,
  ri_distribution = perm_coefs
)

saveRDS(robustness, file.path(DATA_DIR, "robustness_results.rds"))
cat("  Saved robustness_results.rds\n")

cat("\nRobustness checks complete.\n")
