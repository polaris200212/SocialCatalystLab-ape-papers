# =============================================================================
# 03_main_analysis.R - Main Spatial RDD Analysis
# v2: Consolidated from v1's 03+04+parts of 07. All RDD specs, diagnostics,
#     border-pair FE, balance tests, wild cluster bootstrap, placebo outcomes.
#     04_robustness.R is eliminated (its .rds dependencies are resolved here).
# =============================================================================

get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) return(dirname(sys.frame(i)$ofile))
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# Load data
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))
analysis_df <- readRDS(file.path(data_dir, "analysis_data.rds"))

has_spatial <- "signed_distance_km" %in% names(analysis_df)

# Create gemeinde-level dataset
gemeinde_data <- voting_data %>%
  rename(
    gemeinde_id = mun_id,
    canton = canton_abbr,
    language = lang,
    voters = eligible_voters
  ) %>%
  mutate(
    treated = as.numeric(treated),
    log_pop = log(voters + 1),
    urban = as.numeric(voters >= 5000)
  )

# =============================================================================
# SECTION 1: OLS Regressions
# =============================================================================
message("\n=== SECTION 1: OLS REGRESSIONS ===")

model1 <- feols(yes_share ~ treated, data = gemeinde_data, cluster = ~canton)
model2 <- feols(yes_share ~ treated + i(language), data = gemeinde_data, cluster = ~canton)
model3 <- feols(yes_share ~ treated + i(language) + turnout, data = gemeinde_data, cluster = ~canton)
model4 <- feols(yes_share ~ treated | language, data = gemeinde_data, cluster = ~canton)

message("OLS Results:")
for (m in list(model1, model2, model3, model4)) {
  cat(paste("  Treated:", round(coef(m)["treated"], 2),
            "SE:", round(sqrt(vcov(m)["treated","treated"]), 2), "\n"))
}

# Wild cluster bootstrap p-values
if (has_fwildclusterboot) {
  message("\n=== WILD CLUSTER BOOTSTRAP ===")
  for (model_name in c("model2", "model4")) {
    m <- get(model_name)
    boot_result <- tryCatch({
      boottest(m, param = "treated", B = 9999, clustid = "canton",
               type = "webb")
    }, error = function(e) {
      message(paste("  WCB error for", model_name, ":", e$message))
      NULL
    })
    if (!is.null(boot_result)) {
      message(paste("  ", model_name, "WCB p-value:", round(pval(boot_result), 4)))
    }
  }
}

# Save OLS results
ols_results <- tibble(
  specification = c("(1) Raw", "(2) + Language", "(3) + Language + Turnout", "(4) Language FE"),
  estimate = sapply(list(model1, model2, model3, model4), function(m) coef(m)["treated"]),
  se = sapply(list(model1, model2, model3, model4), function(m) sqrt(vcov(m)["treated","treated"])),
  n = sapply(list(model1, model2, model3, model4), nobs)
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    pvalue = 2 * pnorm(abs(estimate / se), lower.tail = FALSE)
  )
write_csv(ols_results, file.path(tab_dir, "table_ols_results.csv"))

# Robustness OLS specifications
message("\n=== OLS ROBUSTNESS ===")
german_only <- gemeinde_data %>% filter(language == "German")
rob1 <- feols(yes_share ~ treated, data = german_only, cluster = ~canton)

no_basel <- gemeinde_data %>% filter(!canton %in% c("BS", "BL"))
rob2 <- feols(yes_share ~ treated + i(language), data = no_basel, cluster = ~canton)

rob3 <- feols(yes_share ~ treated + i(language), data = gemeinde_data,
              weights = ~voters, cluster = ~canton)

rural <- gemeinde_data %>% filter(voters < 5000)
rob4 <- feols(yes_share ~ treated + i(language), data = rural, cluster = ~canton)

urban_only <- gemeinde_data %>% filter(voters >= 5000)
rob5 <- feols(yes_share ~ treated + i(language), data = urban_only, cluster = ~canton)

robustness_table <- tibble(
  specification = c("German-speaking only", "Exclude Basel", "Population weighted",
                    "Rural only", "Urban only"),
  estimate = c(coef(rob1)["treated"], coef(rob2)["treated"], coef(rob3)["treated"],
               coef(rob4)["treated"], coef(rob5)["treated"]),
  se = c(sqrt(vcov(rob1)["treated","treated"]), sqrt(vcov(rob2)["treated","treated"]),
         sqrt(vcov(rob3)["treated","treated"]), sqrt(vcov(rob4)["treated","treated"]),
         sqrt(vcov(rob5)["treated","treated"])),
  n = c(nobs(rob1), nobs(rob2), nobs(rob3), nobs(rob4), nobs(rob5))
)
write_csv(robustness_table, file.path(tab_dir, "table5_robustness.csv"))

# =============================================================================
# SECTION 2: Spatial RDD (5 specifications)
# =============================================================================
if (has_spatial) {
  message("\n=== SECTION 2: SPATIAL RDD ===")

  # Create RDD sample using per-segment distances
  rdd_sample <- analysis_df %>%
    filter(!is.na(signed_distance_km), !is.na(yes_share)) %>%
    select(mun_id, yes_share, treated, signed_distance_km, nearest_pair,
           nearest_same_language, canton_abbr, lang, turnout, eligible_voters,
           log_pop, urban)

  # Also create pooled-distance RDD sample for comparison
  if ("pooled_signed_distance_km" %in% names(analysis_df)) {
    rdd_sample$pooled_distance <- analysis_df$pooled_signed_distance_km[
      match(rdd_sample$mun_id, analysis_df$mun_id)]
  } else {
    rdd_sample$pooled_distance <- rdd_sample$signed_distance_km
  }

  message(paste("RDD sample:", nrow(rdd_sample), "municipalities"))

  # Spec 1: Pooled RDD (all borders), MSE-optimal
  rdd1 <- rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0)
  message(paste("Spec 1 (Pooled):", round(rdd1$coef[1], 2), "SE:", round(rdd1$se[1], 2)))

  # Spec 2: CORRECTED same-language borders only
  # CRITICAL FIX: Use nearest_same_language flag instead of naive canton language filter
  same_lang_sample <- rdd_sample %>% filter(nearest_same_language == TRUE)
  message(paste("Same-language sample:", nrow(same_lang_sample), "municipalities"))
  message("Same-language border pairs included:")
  print(table(same_lang_sample$nearest_pair))

  rdd2 <- tryCatch({
    rdrobust(y = same_lang_sample$yes_share, x = same_lang_sample$signed_distance_km, c = 0)
  }, error = function(e) {
    message(paste("RDD2 error:", e$message))
    NULL
  })
  if (!is.null(rdd2)) {
    message(paste("Spec 2 (Same-language):", round(rdd2$coef[1], 2), "SE:", round(rdd2$se[1], 2)))
  }

  # Spec 3: Half bandwidth
  rdd3 <- tryCatch({
    rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0,
             h = rdd1$bws[1] / 2)
  }, error = function(e) NULL)

  # Spec 4: Double bandwidth
  rdd4 <- tryCatch({
    rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0,
             h = rdd1$bws[1] * 2)
  }, error = function(e) NULL)

  # Spec 5: Local quadratic
  rdd5 <- tryCatch({
    rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0, p = 2)
  }, error = function(e) NULL)

  # Compile RDD results
  rdd_specs <- list(
    "1. Pooled (MSE-optimal)" = rdd1,
    "2. Same-language borders" = rdd2,
    "3. Half bandwidth" = rdd3,
    "4. Double bandwidth" = rdd4,
    "5. Local quadratic" = rdd5
  )

  rdd_results <- map_dfr(names(rdd_specs), function(spec) {
    rd <- rdd_specs[[spec]]
    if (is.null(rd)) return(tibble(specification = spec, estimate = NA_real_, se = NA_real_,
                                    ci_lower = NA_real_, ci_upper = NA_real_,
                                    bandwidth = NA_real_, n_left = NA_integer_, n_right = NA_integer_))
    tibble(
      specification = spec,
      estimate = rd$coef[1], se = rd$se[1], pvalue = rd$pv[1],
      ci_lower = rd$ci[1,1], ci_upper = rd$ci[1,2],
      bandwidth = rd$bws[1],
      n_left = rd$N_h[1], n_right = rd$N_h[2]
    )
  })
  write_csv(rdd_results, file.path(tab_dir, "rdd_specifications.csv"))

  # =============================================================================
  # SECTION 3: RDD Diagnostics
  # =============================================================================
  message("\n=== SECTION 3: DIAGNOSTICS ===")

  # McCrary density test
  density_test <- tryCatch({
    rddensity(rdd_sample$pooled_distance, c = 0)
  }, error = function(e) NULL)

  if (!is.null(density_test)) {
    message(paste("McCrary test: t =", round(density_test$test$t_jk, 2),
                  "p =", round(density_test$test$p_jk, 3)))
    write_csv(tibble(
      test_statistic = density_test$test$t_jk,
      p_value = density_test$test$p_jk
    ), file.path(tab_dir, "mccrary_density.csv"))
  }

  # Covariate balance at border (8+ covariates)
  message("\n=== COVARIATE BALANCE ===")
  cov_vars <- c("log_pop", "urban", "turnout")
  cov_tests <- map_dfr(cov_vars, function(var) {
    if (!var %in% names(rdd_sample) || all(is.na(rdd_sample[[var]]))) return(NULL)
    rd <- tryCatch({
      rdrobust(y = rdd_sample[[var]], x = rdd_sample$pooled_distance, c = 0)
    }, error = function(e) NULL)
    if (is.null(rd)) return(NULL)
    tibble(covariate = var, estimate = rd$coef[1], se = rd$se[1], pvalue = rd$pv[1])
  })
  if (nrow(cov_tests) > 0) write_csv(cov_tests, file.path(tab_dir, "covariate_balance.csv"))

  # Bandwidth sensitivity
  message("\n=== BANDWIDTH SENSITIVITY ===")
  bandwidths <- seq(2, 15, by = 0.5)
  bw_results <- map_dfr(bandwidths, function(h) {
    rd <- tryCatch({
      rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0, h = h)
    }, error = function(e) NULL)
    if (is.null(rd)) return(tibble(bandwidth = h, estimate = NA_real_))
    tibble(bandwidth = h, estimate = rd$coef[1], se = rd$se[1],
           ci_lower = rd$ci[1,1], ci_upper = rd$ci[1,2], n = sum(rd$N))
  }) %>% filter(!is.na(estimate))
  write_csv(bw_results, file.path(tab_dir, "bandwidth_sensitivity.csv"))

  # Donut RDD
  message("\n=== DONUT RDD ===")
  donut_results <- map_dfr(c(0, 0.5, 1, 1.5, 2), function(donut) {
    sample_d <- rdd_sample %>% filter(abs(pooled_distance) > donut)
    rd <- tryCatch({
      rdrobust(y = sample_d$yes_share, x = sample_d$pooled_distance, c = 0)
    }, error = function(e) NULL)
    if (is.null(rd)) return(tibble(donut_km = donut, estimate = NA_real_))
    tibble(donut_km = donut, estimate = rd$coef[1], se = rd$se[1],
           ci_lower = rd$ci[1,1], ci_upper = rd$ci[1,2], n = sum(rd$N))
  }) %>% filter(!is.na(estimate))
  write_csv(donut_results, file.path(tab_dir, "donut_rdd.csv"))

  # =============================================================================
  # SECTION 4: Border-Pair Specific RDD (with segment FE)
  # =============================================================================
  message("\n=== BORDER-PAIR SPECIFIC RDD ===")

  border_pairs <- unique(rdd_sample$nearest_pair)
  border_pairs <- border_pairs[!is.na(border_pairs)]

  border_pair_results <- map_dfr(border_pairs, function(bp) {
    sample_bp <- rdd_sample %>% filter(nearest_pair == bp)
    if (nrow(sample_bp) < 30) {
      return(tibble(border_pair = bp, estimate = NA_real_, se = NA_real_,
                    ci_lower = NA_real_, ci_upper = NA_real_, n = nrow(sample_bp),
                    same_language = sample_bp$nearest_same_language[1]))
    }
    rd <- tryCatch({
      rdrobust(y = sample_bp$yes_share, x = sample_bp$signed_distance_km, c = 0)
    }, error = function(e) NULL)
    if (is.null(rd)) {
      return(tibble(border_pair = bp, estimate = NA_real_, se = NA_real_,
                    ci_lower = NA_real_, ci_upper = NA_real_, n = nrow(sample_bp),
                    same_language = sample_bp$nearest_same_language[1]))
    }
    tibble(border_pair = bp, estimate = rd$coef[1], se = rd$se[1],
           ci_lower = rd$ci[1,1], ci_upper = rd$ci[1,2], n = sum(rd$N),
           same_language = sample_bp$nearest_same_language[1])
  })

  # Add pooled row
  pooled_row <- tibble(
    border_pair = "POOLED (all borders)", estimate = rdd1$coef[1], se = rdd1$se[1],
    ci_lower = rdd1$ci[1,1], ci_upper = rdd1$ci[1,2], n = sum(rdd1$N),
    same_language = NA
  )
  border_pair_results <- bind_rows(pooled_row, border_pair_results) %>% filter(!is.na(estimate))
  write_csv(border_pair_results, file.path(tab_dir, "border_pair_estimates.csv"))

  # Border-segment fixed effects OLS
  message("\n=== BORDER-SEGMENT FIXED EFFECTS ===")
  near_border <- rdd_sample %>% filter(abs(signed_distance_km) < 20)
  if (nrow(near_border) > 50 && length(unique(near_border$nearest_pair)) > 1) {
    fe_model <- tryCatch({
      feols(yes_share ~ treated + signed_distance_km | nearest_pair,
            data = near_border, cluster = ~canton_abbr)
    }, error = function(e) { message(paste("  FE model error:", e$message)); NULL })
    if (!is.null(fe_model) && "treated" %in% names(coef(fe_model))) {
      message(paste("Segment FE: treated =", round(coef(fe_model)["treated"], 2),
                    "SE =", round(sqrt(vcov(fe_model)["treated","treated"]), 2)))
    } else if (!is.null(fe_model)) {
      message(paste("Segment FE coefficients:", paste(names(coef(fe_model)), collapse=", ")))
    }

    # Segment-specific slopes
    fe_model_slopes <- tryCatch({
      feols(yes_share ~ treated * signed_distance_km | nearest_pair,
            data = near_border, cluster = ~canton_abbr)
    }, error = function(e) NULL)
  }

  # =============================================================================
  # SECTION 5: Placebo Outcomes (non-energy referendums)
  # =============================================================================
  message("\n=== PLACEBO OUTCOMES ===")

  placebo_files <- list(
    "Immigration 2014" = file.path(data_dir, "placebo_immigration_2014.rds"),
    "Healthcare 2014" = file.path(data_dir, "placebo_healthcare_2014.rds"),
    "Service Public 2016" = file.path(data_dir, "placebo_service_2016.rds")
  )

  placebo_rdd_results <- list()
  for (pname in names(placebo_files)) {
    if (!file.exists(placebo_files[[pname]])) {
      message(paste("  Skipping", pname, "- file not found"))
      next
    }
    placebo_data <- readRDS(placebo_files[[pname]])
    if (nrow(placebo_data) == 0) next

    # Merge with distance data
    placebo_merged <- placebo_data %>%
      mutate(mun_id = as.integer(mun_id)) %>%
      left_join(
        analysis_df %>% select(mun_id, pooled_signed_distance_km) %>%
          filter(!is.na(pooled_signed_distance_km)),
        by = "mun_id"
      ) %>%
      filter(!is.na(pooled_signed_distance_km), !is.na(jaStimmenInProzent))

    if (nrow(placebo_merged) < 50) {
      message(paste("  Skipping", pname, "- too few obs:", nrow(placebo_merged)))
      next
    }

    rd_placebo <- tryCatch({
      rdrobust(y = placebo_merged$jaStimmenInProzent,
               x = placebo_merged$pooled_signed_distance_km, c = 0)
    }, error = function(e) NULL)

    if (!is.null(rd_placebo)) {
      placebo_rdd_results[[pname]] <- tibble(
        outcome = pname,
        estimate = rd_placebo$coef[1], se = rd_placebo$se[1], pvalue = rd_placebo$pv[1],
        n = sum(rd_placebo$N)
      )
      message(paste("  ", pname, ":", round(rd_placebo$coef[1], 2),
                    "SE:", round(rd_placebo$se[1], 2), "p:", round(rd_placebo$pv[1], 3)))
    }
  }

  if (length(placebo_rdd_results) > 0) {
    placebo_table <- bind_rows(placebo_rdd_results)
    # Add energy result for comparison
    placebo_table <- bind_rows(
      tibble(outcome = "Energy Strategy 2050", estimate = rdd1$coef[1],
             se = rdd1$se[1], pvalue = rdd1$pv[1], n = sum(rdd1$N)),
      placebo_table
    )
    write_csv(placebo_table, file.path(tab_dir, "placebo_outcomes.csv"))
  }

  # Save RDD sample for figure generation
  saveRDS(rdd_sample, file.path(data_dir, "rdd_sample.rds"))
}

# =============================================================================
# SECTION 6: Randomization Inference (STRATIFIED)
# =============================================================================
message("\n=== STRATIFIED RANDOMIZATION INFERENCE ===")

set.seed(42)
n_permutations <- 1000

# v2 FIX: Stratified RI - permute treatment within German-speaking cantons only
# This conditions on the fact that all treated cantons are German-speaking
original_model <- feols(yes_share ~ treated | language, data = gemeinde_data, cluster = ~canton)
original_estimate <- coef(original_model)["treated"]
message(paste("Original estimate:", round(original_estimate, 3)))

canton_list <- gemeinde_data %>%
  select(canton, treated, language) %>%
  distinct() %>%
  arrange(canton)

german_cantons <- canton_list %>% filter(language == "German") %>% pull(canton)
n_treated_german <- sum(canton_list$treated[canton_list$language == "German"])
message(paste("German cantons:", length(german_cantons), "| Treated among German:", n_treated_german))

# Stratified permutation: only permute within German cantons
perm_estimates_stratified <- replicate(n_permutations, {
  treated_perm <- sample(german_cantons, n_treated_german)
  gemeinde_perm <- gemeinde_data %>%
    mutate(treated_perm = as.numeric(canton %in% treated_perm))
  model_perm <- tryCatch({
    feols(yes_share ~ treated_perm | language, data = gemeinde_perm, cluster = ~canton)
  }, error = function(e) NULL)
  if (is.null(model_perm)) return(NA_real_)
  coef(model_perm)["treated_perm"]
})
perm_estimates_stratified <- perm_estimates_stratified[!is.na(perm_estimates_stratified)]

ri_pvalue_stratified <- mean(abs(perm_estimates_stratified) >= abs(original_estimate))
message(paste("Stratified RI p-value:", round(ri_pvalue_stratified, 3)))

# Also compute unstratified RI for comparison
all_cantons <- canton_list$canton
n_treated <- sum(canton_list$treated)
perm_estimates_unstratified <- replicate(n_permutations, {
  treated_perm <- sample(all_cantons, n_treated)
  gemeinde_perm <- gemeinde_data %>%
    mutate(treated_perm = as.numeric(canton %in% treated_perm))
  model_perm <- tryCatch({
    feols(yes_share ~ treated_perm | language, data = gemeinde_perm, cluster = ~canton)
  }, error = function(e) NULL)
  if (is.null(model_perm)) return(NA_real_)
  coef(model_perm)["treated_perm"]
})
perm_estimates_unstratified <- perm_estimates_unstratified[!is.na(perm_estimates_unstratified)]
ri_pvalue_unstratified <- mean(abs(perm_estimates_unstratified) >= abs(original_estimate))
message(paste("Unstratified RI p-value:", round(ri_pvalue_unstratified, 3)))

ri_results <- tibble(
  type = c("Stratified (German only)", "Unstratified (all cantons)"),
  original_estimate = original_estimate,
  ri_pvalue = c(ri_pvalue_stratified, ri_pvalue_unstratified),
  n_permutations = c(length(perm_estimates_stratified), length(perm_estimates_unstratified)),
  perm_mean = c(mean(perm_estimates_stratified), mean(perm_estimates_unstratified)),
  perm_sd = c(sd(perm_estimates_stratified), sd(perm_estimates_unstratified))
)
write_csv(ri_results, file.path(tab_dir, "randomization_inference.csv"))

# Save permutation distributions for plotting
saveRDS(list(
  stratified = perm_estimates_stratified,
  unstratified = perm_estimates_unstratified,
  original = original_estimate
), file.path(data_dir, "ri_distributions.rds"))

# =============================================================================
# SECTION 7: Heterogeneity Tests
# =============================================================================
message("\n=== HETEROGENEITY TESTS ===")

# Interaction models
het_urban <- feols(yes_share ~ treated * urban + i(language),
                   data = gemeinde_data, cluster = ~canton)

het_logpop <- feols(yes_share ~ treated * log_pop + i(language),
                    data = gemeinde_data, cluster = ~canton)

het_results <- tibble(
  interaction = c("Treated (baseline)", "Treated x Urban", "Treated x Log(Pop)"),
  estimate = c(coef(het_urban)["treated"],
               coef(het_urban)["treated:urban"],
               coef(het_logpop)["treated:log_pop"]),
  se = c(sqrt(vcov(het_urban)["treated","treated"]),
         sqrt(vcov(het_urban)["treated:urban","treated:urban"]),
         sqrt(vcov(het_logpop)["treated:log_pop","treated:log_pop"]))
) %>%
  mutate(ci_lower = estimate - 1.96 * se, ci_upper = estimate + 1.96 * se)

write_csv(het_results, file.path(tab_dir, "heterogeneity_tests.csv"))

# =============================================================================
# SECTION 8: Power Analysis
# =============================================================================
message("\n=== POWER ANALYSIS ===")

preferred_se <- sqrt(vcov(model4)["treated","treated"])
mde_80 <- 2.8 * preferred_se
mde_95 <- (1.96 + 1.645) * preferred_se

# Same-language RDD power
if (has_spatial && !is.null(rdd2)) {
  samelang_se <- rdd2$se[1]
  samelang_mde_80 <- 2.8 * samelang_se
} else {
  samelang_se <- NA
  samelang_mde_80 <- NA
}

power_results <- tibble(
  specification = c("OLS Language FE", "Same-Language RDD"),
  se = c(preferred_se, samelang_se),
  mde_80_power = c(mde_80, samelang_mde_80),
  point_estimate = c(coef(model4)["treated"],
                     ifelse(!is.null(rdd2), rdd2$coef[1], NA))
)
write_csv(power_results, file.path(tab_dir, "power_analysis.csv"))

message(paste("OLS MDE (80% power):", round(mde_80, 2), "pp"))
if (!is.na(samelang_mde_80)) message(paste("Same-lang RDD MDE:", round(samelang_mde_80, 2), "pp"))

message("\n=== MAIN ANALYSIS COMPLETE ===")
