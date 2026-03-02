## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- read_csv(file.path(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

dir.create("../tables", showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## 1. Placebo outcomes (Cancer, Heart Disease)
## ============================================================================

cat("\n=== 1. Placebo Outcomes ===\n")

# Heart disease — should NOT be affected by school training mandates
cs_heart <- att_gt(
  yname  = "heart_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)
cs_heart_agg <- aggte(cs_heart, type = "simple")
cs_heart_es  <- aggte(cs_heart, type = "dynamic", min_e = -7, max_e = 10)

cat("Heart Disease ATT:", cs_heart_agg$overall.att,
    "SE:", cs_heart_agg$overall.se, "\n")

# Cancer — should NOT be affected
cs_cancer <- att_gt(
  yname  = "cancer_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)
cs_cancer_agg <- aggte(cs_cancer, type = "simple")
cs_cancer_es  <- aggte(cs_cancer, type = "dynamic", min_e = -7, max_e = 10)

cat("Cancer ATT:", cs_cancer_agg$overall.att,
    "SE:", cs_cancer_agg$overall.se, "\n")

# Save placebo event studies
write_csv(
  tibble(
    event_time = cs_heart_es$egt,
    att = cs_heart_es$att.egt,
    se = cs_heart_es$se.egt,
    outcome = "Heart Disease"
  ),
  file.path(data_dir, "event_study_placebo_heart.csv")
)
write_csv(
  tibble(
    event_time = cs_cancer_es$egt,
    att = cs_cancer_es$att.egt,
    se = cs_cancer_es$se.egt,
    outcome = "Cancer"
  ),
  file.path(data_dir, "event_study_placebo_cancer.csv")
)

## ============================================================================
## 2. Alternative treatment timing (effective year = treatment year)
## ============================================================================

cat("\n=== 2. Alternative Treatment Timing ===\n")

cs_alt <- att_gt(
  yname  = "suicide_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat_alt",
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)
cs_alt_agg <- aggte(cs_alt, type = "simple")
cat("Alternative timing ATT:", cs_alt_agg$overall.att,
    "SE:", cs_alt_agg$overall.se, "\n")

## ============================================================================
## 3. Never-treated only as control group
## ============================================================================

cat("\n=== 3. Never-Treated Control Group ===\n")

cs_never <- att_gt(
  yname  = "suicide_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel,
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal"
)
cs_never_agg <- aggte(cs_never, type = "simple")
cs_never_es  <- aggte(cs_never, type = "dynamic", min_e = -7, max_e = 10)
cat("Never-treated control ATT:", cs_never_agg$overall.att,
    "SE:", cs_never_agg$overall.se, "\n")

write_csv(
  tibble(
    event_time = cs_never_es$egt,
    att = cs_never_es$att.egt,
    se = cs_never_es$se.egt
  ),
  file.path(data_dir, "event_study_cs_nevertreated.csv")
)

## ============================================================================
## 4. Leave-one-cohort-out
## ============================================================================

cat("\n=== 4. Leave-One-Cohort-Out ===\n")

cohorts <- unique(panel$first_treat[panel$first_treat > 0])
loco_results <- tibble()

for (g in sort(cohorts)) {
  panel_sub <- panel %>% filter(first_treat != g)
  tryCatch({
    cs_sub <- att_gt(
      yname  = "suicide_aadr",
      tname  = "year",
      idname = "state_id",
      gname  = "first_treat",
      data   = panel_sub,
      control_group = "notyettreated",
      anticipation  = 0,
      base_period   = "universal"
    )
    agg_sub <- aggte(cs_sub, type = "simple")
    loco_results <- bind_rows(loco_results, tibble(
      dropped_cohort = g,
      att = agg_sub$overall.att,
      se = agg_sub$overall.se
    ))
    cat(sprintf("  Dropped cohort %d: ATT = %.3f (SE = %.3f)\n",
                g, agg_sub$overall.att, agg_sub$overall.se))
  }, error = function(e) {
    cat(sprintf("  Dropped cohort %d: ERROR - %s\n", g, e$message))
  })
}

write_csv(loco_results, file.path(data_dir, "leave_one_cohort_out.csv"))

## ============================================================================
## 5. Heterogeneity by youth population share
## ============================================================================

cat("\n=== 5. Heterogeneity by Youth Share ===\n")

if ("youth_share" %in% names(panel) && sum(!is.na(panel$youth_share)) > 100) {
  # Compute baseline (pre-treatment) youth share per state
  baseline_youth <- panel %>%
    filter(year < first_treat | first_treat == 0) %>%
    group_by(state_id) %>%
    summarise(baseline_youth_share = mean(youth_share, na.rm = TRUE), .groups = "drop") %>%
    mutate(high_youth = as.integer(baseline_youth_share > median(baseline_youth_share, na.rm = TRUE)))

  panel_het <- panel %>%
    left_join(baseline_youth, by = "state_id")

  # Split sample: high vs low youth share
  for (group_label in c("high", "low")) {
    sub <- panel_het %>% filter(high_youth == (if (group_label == "high") 1L else 0L))
    tryCatch({
      cs_sub <- att_gt(
        yname  = "suicide_aadr",
        tname  = "year",
        idname = "state_id",
        gname  = "first_treat",
        data   = sub,
        control_group = "notyettreated",
        anticipation  = 0,
        base_period   = "universal"
      )
      agg_sub <- aggte(cs_sub, type = "simple")
      cat(sprintf("  %s youth share: ATT = %.3f (SE = %.3f)\n",
                  group_label, agg_sub$overall.att, agg_sub$overall.se))
    }, error = function(e) {
      cat(sprintf("  %s youth share: ERROR - %s\n", group_label, e$message))
    })
  }
} else {
  cat("  Youth population data unavailable. Skipping heterogeneity analysis.\n")
}

## ============================================================================
## 6. Heterogeneity by baseline suicide rate
## ============================================================================

cat("\n=== 6. Heterogeneity by Baseline Suicide Rate ===\n")

baseline_suicide <- panel %>%
  filter(year <= 2005) %>%
  group_by(state_id, state) %>%
  summarise(baseline_rate = mean(suicide_aadr, na.rm = TRUE), .groups = "drop") %>%
  mutate(high_baseline = as.integer(baseline_rate > median(baseline_rate)))

panel_base <- panel %>%
  left_join(baseline_suicide %>% select(state_id, high_baseline), by = "state_id")

for (group_label in c("high", "low")) {
  sub <- panel_base %>% filter(high_baseline == (if (group_label == "high") 1L else 0L))
  tryCatch({
    cs_sub <- att_gt(
      yname  = "suicide_aadr",
      tname  = "year",
      idname = "state_id",
      gname  = "first_treat",
      data   = sub,
      control_group = "notyettreated",
      anticipation  = 0,
      base_period   = "universal"
    )
    agg_sub <- aggte(cs_sub, type = "simple")
    cat(sprintf("  %s baseline rate: ATT = %.3f (SE = %.3f)\n",
                group_label, agg_sub$overall.att, agg_sub$overall.se))
  }, error = function(e) {
    cat(sprintf("  %s baseline rate: ERROR - %s\n", group_label, e$message))
  })
}

## ============================================================================
## 7. HonestDiD sensitivity analysis
## ============================================================================

cat("\n=== 7. HonestDiD Sensitivity ===\n")

if (requireNamespace("HonestDiD", quietly = TRUE)) {
  library(HonestDiD)

  # Use the TWFE event study for HonestDiD (it needs standard regression output)
  panel_sa <- panel %>%
    mutate(cohort = if_else(first_treat == 0, 10000L, first_treat))

  sa_model <- feols(suicide_aadr ~ sunab(cohort, year) | state_id + year,
                    data = panel_sa, cluster = ~state_id)

  tryCatch({
    # Extract coefficients and variance-covariance matrix
    beta_hat <- coef(sa_model)
    sigma_hat <- vcov(sa_model)

    # Identify pre and post periods
    coef_names <- names(beta_hat)
    pre_idx <- grep("year::-[0-9]", coef_names)
    post_idx <- grep("year::[0-9]", coef_names)

    if (length(pre_idx) > 0 && length(post_idx) > 0) {
      # Relative magnitudes approach
      honest_result <- createSensitivityResults_relativeMagnitudes(
        betahat = beta_hat,
        sigma = sigma_hat,
        numPrePeriods = length(pre_idx),
        numPostPeriods = length(post_idx),
        Mbarvec = seq(0, 2, by = 0.5)
      )
      cat("HonestDiD sensitivity results:\n")
      print(honest_result)

      write_csv(as_tibble(honest_result),
                file.path(data_dir, "honestdid_sensitivity.csv"))
    } else {
      cat("  Could not identify pre/post coefficients for HonestDiD.\n")
    }
  }, error = function(e) {
    cat(sprintf("  HonestDiD failed: %s\n", e$message))
  })
} else {
  cat("  HonestDiD package not available. Skipping.\n")
}

## ============================================================================
## 8. Wild cluster bootstrap
## ============================================================================

cat("\n=== 8. Wild Cluster Bootstrap ===\n")

# Simple TWFE with wild bootstrap p-value
twfe_base <- feols(suicide_aadr ~ treated | state_id + year,
                   data = panel, cluster = ~state_id)

# Use fwildclusterboot if available
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)
  set.seed(12345)
  boot_result <- boottest(twfe_base, param = "treated", B = 9999, clustid = "state_id")
  cat("Wild cluster bootstrap p-value:", boot_result$p_val, "\n")
} else {
  cat("  fwildclusterboot not available. Using standard cluster SEs.\n")
  cat("  Standard cluster SE p-value:",
      2 * pnorm(-abs(coef(twfe_base)["treated"] / sqrt(vcov(twfe_base)["treated","treated"]))), "\n")
}

## ============================================================================
## 9. Summary of all robustness checks
## ============================================================================

cat("\n=== Robustness Summary ===\n")

robustness_summary <- tibble(
  check = c(
    "Placebo: Heart Disease", "Placebo: Cancer",
    "Alt. treatment timing", "Never-treated control"
  ),
  att = c(
    cs_heart_agg$overall.att, cs_cancer_agg$overall.att,
    cs_alt_agg$overall.att, cs_never_agg$overall.att
  ),
  se = c(
    cs_heart_agg$overall.se, cs_cancer_agg$overall.se,
    cs_alt_agg$overall.se, cs_never_agg$overall.se
  ),
  pvalue = 2 * pnorm(-abs(att / se))
)

print(robustness_summary)
write_csv(robustness_summary, file.path(data_dir, "robustness_summary.csv"))
cat("\nAll robustness checks saved.\n")
