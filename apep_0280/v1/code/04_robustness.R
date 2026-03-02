# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 04_robustness.R - Robustness checks
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

state_year <- readRDS(file.path(data_dir, "state_year_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

cat("=== Robustness Checks ===\n\n")

# ============================================================================
# 1. HonestDiD Sensitivity Analysis
# ============================================================================

cat("--- 1. HonestDiD Sensitivity (Rambachan & Roth) ---\n")

honest_smoking <- tryCatch({
  cs_obj <- results$cs_smoking
  es_obj <- results$es_smoking

  # Extract pre and post period indices
  e_vec <- es_obj$egt
  pre_idx <- which(e_vec < 0)
  post_idx <- which(e_vec >= 0)

  if (length(pre_idx) >= 2 & length(post_idx) >= 1) {
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = es_obj$att.egt,
      sigma = es_obj$se.egt^2 * diag(length(es_obj$att.egt)),
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01)
    )
    cat("  HonestDiD results computed\n")
    honest_result
  } else {
    cat("  Insufficient pre/post periods for HonestDiD\n")
    NULL
  }
}, error = function(e) {
  cat(sprintf("  HonestDiD error: %s\n", e$message))
  NULL
})

# ============================================================================
# 2. Leave-One-Region-Out
# ============================================================================

cat("\n--- 2. Leave-One-Region-Out ---\n")

regions_list <- c("Northeast", "Midwest", "South", "West")
loro_results <- list()

for (reg in regions_list) {
  cat(sprintf("  Dropping %s...\n", reg))
  df_sub <- state_year %>% filter(region != reg)

  tryCatch({
    cs_sub <- att_gt(
      yname = "smoking_rate",
      tname = "year",
      idname = "state_fips",
      gname = "first_treat",
      data = df_sub,
      control_group = "nevertreated",
      est_method = "dr",
      base_period = "universal",
      panel = TRUE,
      allow_unbalanced_panel = TRUE
    )
    att_sub <- aggte(cs_sub, type = "simple")
    loro_results[[reg]] <- list(
      att = att_sub$overall.att,
      se = att_sub$overall.se,
      region_dropped = reg
    )
    cat(sprintf("    ATT = %.4f (SE = %.4f)\n", att_sub$overall.att, att_sub$overall.se))
  }, error = function(e) {
    cat(sprintf("    Error: %s\n", e$message))
  })
}

# ============================================================================
# 3. Drop Partial-Exposure Year
# ============================================================================

cat("\n--- 3. Drop Partial-Exposure Adoption Year ---\n")

# Redefine first_treat as the year AFTER adoption (full exposure)
state_year_full <- state_year %>%
  mutate(first_treat_full = ifelse(first_treat > 0, first_treat + 1, 0))

cs_full_year <- tryCatch({
  att_gt(
    yname = "smoking_rate",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat_full",
    data = state_year_full,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    panel = TRUE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

if (!is.null(cs_full_year)) {
  att_full <- aggte(cs_full_year, type = "simple")
  cat(sprintf("  ATT (full-year exposure): %.4f (SE: %.4f)\n",
              att_full$overall.att, att_full$overall.se))
}

# ============================================================================
# 4. Not-Yet-Treated as Control Group
# ============================================================================

cat("\n--- 4. Not-Yet-Treated Control Group ---\n")

cs_nyt <- tryCatch({
  att_gt(
    yname = "smoking_rate",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = state_year,
    control_group = "notyettreated",
    est_method = "dr",
    base_period = "universal",
    panel = TRUE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

if (!is.null(cs_nyt)) {
  att_nyt <- aggte(cs_nyt, type = "simple")
  cat(sprintf("  ATT (not-yet-treated): %.4f (SE: %.4f)\n",
              att_nyt$overall.att, att_nyt$overall.se))
  es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -10, max_e = 15)
}

# ============================================================================
# 5. Placebo: Non-smoker population (quit attempts should be zero)
# ============================================================================

cat("\n--- 5. Placebo: Never-Smoker Population ---\n")

# Load individual data and construct never-smoker panel
if (file.exists(file.path(data_dir, "brfss_individual.rds"))) {
  df_ind <- readRDS(file.path(data_dir, "brfss_individual.rds"))

  never_panel <- df_ind %>%
    filter(ever_smoker == 0) %>%
    group_by(state_fips, year, first_treat) %>%
    summarise(
      smoking_rate = weighted.mean(current_smoker, wt, na.rm = TRUE),
      n_obs = n(),
      .groups = "drop"
    )

  # Among never-smokers, current smoking should be ~0 and unaffected by bans
  cs_placebo <- tryCatch({
    att_gt(
      yname = "smoking_rate",
      tname = "year",
      idname = "state_fips",
      gname = "first_treat",
      data = never_panel,
      control_group = "nevertreated",
      est_method = "dr",
      base_period = "universal",
      panel = TRUE,
      allow_unbalanced_panel = TRUE
    )
  }, error = function(e) {
    cat(sprintf("  Error: %s\n", e$message))
    NULL
  })

  if (!is.null(cs_placebo)) {
    att_placebo <- aggte(cs_placebo, type = "simple")
    cat(sprintf("  Placebo ATT (never-smokers): %.4f (SE: %.4f)\n",
                att_placebo$overall.att, att_placebo$overall.se))
  }
} else {
  cat("  Individual data not found, skipping placebo\n")
}

# ============================================================================
# 6. Randomization Inference
# ============================================================================

cat("\n--- 6. Randomization Inference (1000 permutations) ---\n")

# Save intermediate results before RI (which may crash)
robust_interim <- list(
  honest_smoking = honest_smoking,
  loro_results = loro_results,
  cs_full_year = cs_full_year,
  cs_nyt = cs_nyt
)
saveRDS(robust_interim, file.path(data_dir, "robustness_interim.rds"))
cat("  Saved interim robustness results\n")

set.seed(42)
n_perms <- 1000
att_main <- results$att_smoking$overall.att

perm_atts <- numeric(n_perms)
unique_states <- unique(state_year$state_fips)
original_treats <- state_year %>%
  select(state_fips, first_treat) %>%
  distinct()

for (i in seq_len(n_perms)) {
  if (i %% 50 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))

  perm_treats <- original_treats %>%
    mutate(first_treat = sample(first_treat))

  df_perm <- state_year %>%
    select(-first_treat) %>%
    left_join(perm_treats, by = "state_fips")

  tryCatch({
    cs_perm <- att_gt(
      yname = "smoking_rate",
      tname = "year",
      idname = "state_fips",
      gname = "first_treat",
      data = df_perm,
      control_group = "nevertreated",
      est_method = "reg",
      base_period = "universal",
      panel = TRUE,
      allow_unbalanced_panel = TRUE
    )
    att_perm <- aggte(cs_perm, type = "simple")
    perm_atts[i] <- att_perm$overall.att
  }, error = function(e) {
    perm_atts[i] <- NA
  })
}

ri_pvalue <- mean(abs(perm_atts) >= abs(att_main), na.rm = TRUE)
cat(sprintf("  RI p-value (two-sided): %.4f\n", ri_pvalue))
cat(sprintf("  Main ATT: %.4f | 95th pctile of permutation dist: %.4f\n",
            att_main, quantile(abs(perm_atts), 0.95, na.rm = TRUE)))

# ============================================================================
# 7. Compositional Decomposition: Some-Days Smoking Rate
# ============================================================================

cat("\n--- 7. Compositional Decomposition: Some-Days Smoking ---\n")

# Some-days rate = smoking_rate - everyday_rate
state_year <- state_year %>%
  mutate(somedays_rate = smoking_rate - everyday_rate)

cs_somedays <- tryCatch({
  att_gt(
    yname = "somedays_rate",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = state_year,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    panel = TRUE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

somedays_att <- NULL
if (!is.null(cs_somedays)) {
  somedays_att <- aggte(cs_somedays, type = "simple")
  cat(sprintf("  Some-days smoking ATT: %.4f (SE: %.4f)\n",
              somedays_att$overall.att, somedays_att$overall.se))
  pval_sd <- 2 * pnorm(-abs(somedays_att$overall.att / somedays_att$overall.se))
  cat(sprintf("  p-value: %.4f\n", pval_sd))
  cat("  If negative: supports compositional reclassification hypothesis\n")
  cat("  (some-day smokers quitting → everyday rate rises mechanically)\n")
}

# ============================================================================
# 8. Robustness: Drop 2016 Cohort (California)
# ============================================================================

cat("\n--- 8. Drop 2016 Cohort (California) ---\n")

state_year_no2016 <- state_year %>% filter(first_treat != 2016)

cs_no2016 <- tryCatch({
  att_gt(
    yname = "smoking_rate",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = state_year_no2016,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    panel = TRUE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat(sprintf("  Error: %s\n", e$message))
  NULL
})

att_no2016 <- NULL
if (!is.null(cs_no2016)) {
  att_no2016 <- aggte(cs_no2016, type = "simple")
  cat(sprintf("  ATT (drop 2016 cohort): %.4f (SE: %.4f)\n",
              att_no2016$overall.att, att_no2016$overall.se))
}

# ============================================================================
# 9. Save robustness results
# ============================================================================

robust_results <- list(
  honest_smoking = honest_smoking,
  loro_results = loro_results,
  cs_full_year = cs_full_year,
  cs_nyt = cs_nyt,
  ri_pvalue = ri_pvalue,
  perm_atts = perm_atts,
  cs_somedays = cs_somedays,
  somedays_att = somedays_att,
  cs_no2016 = cs_no2016,
  att_no2016 = att_no2016
)

saveRDS(robust_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
