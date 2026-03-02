###############################################################################
# 04_robustness.R — Robustness checks and diagnostics
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
# Memory-efficient: loads subsets, frees memory between tests
###############################################################################

source("00_packages.R")

cat("=== Phase 4: Robustness Checks ===\n")

# Helper: load subset of parquet efficiently
load_subset <- function(filter_expr = NULL) {
  ppd <- read_parquet(file.path(data_dir, "analysis_panel.parquet"))
  setDT(ppd)
  if (!is.null(filter_expr)) ppd <- ppd[eval(parse(text = filter_expr))]
  ppd[, yq := factor(paste0(year, "Q", quarter))]
  ppd
}

# Read main results for summary
main_res <- fread(file.path(tab_dir, "main_results.csv"))

# ---- 2. Placebo: Very Low flood risk areas ----
cat("\n--- Placebo: Very Low Flood Risk Areas ---\n")

ppd_vlow <- load_subset("year >= 2009 & flood_risk %in% c('Very Low', 'No Risk')")
ppd_vlow[, in_vlow := (flood_risk == "Very Low")]
ppd_vlow[, ddd_placebo := in_vlow * post_floodre * flood_re_eligible]
ppd_vlow[, dd_vlow_post := in_vlow * post_floodre]
ppd_vlow[, dd_vlow_elig := in_vlow * flood_re_eligible]
ppd_vlow[, dd_post_elig := post_floodre * flood_re_eligible]

m_placebo_vlow <- feols(
  log_price ~ ddd_placebo + dd_vlow_post + dd_post_elig + dd_vlow_elig +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_vlow,
  cluster = ~ pc_district + yq
)

placebo_vlow_coef <- coef(m_placebo_vlow)["ddd_placebo"]
placebo_vlow_se <- se(m_placebo_vlow)["ddd_placebo"]
placebo_vlow_p <- 2 * pnorm(-abs(placebo_vlow_coef / placebo_vlow_se))
cat(sprintf("  Placebo DDD (Very Low risk): %.4f (SE: %.4f, p = %.4f)\n",
            placebo_vlow_coef, placebo_vlow_se, placebo_vlow_p))
rm(ppd_vlow, m_placebo_vlow); gc()

# ---- 3. Placebo: Low flood risk areas ----
cat("\n--- Placebo: Low Flood Risk Areas ---\n")

# Use sampling for memory efficiency — Low + No Risk is ~13M rows
ppd_low <- load_subset("year >= 2009 & flood_risk %in% c('Low', 'No Risk')")
ppd_low[, in_low := (flood_risk == "Low")]
ppd_low[, ddd_placebo := in_low * post_floodre * flood_re_eligible]
ppd_low[, dd_low_post := in_low * post_floodre]
ppd_low[, dd_low_elig := in_low * flood_re_eligible]
ppd_low[, dd_post_elig := post_floodre * flood_re_eligible]

m_placebo_low <- feols(
  log_price ~ ddd_placebo + dd_low_post + dd_post_elig + dd_low_elig +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_low,
  cluster = ~ pc_district + yq,
  lean = TRUE
)

placebo_low_coef <- coef(m_placebo_low)["ddd_placebo"]
placebo_low_se <- se(m_placebo_low)["ddd_placebo"]
placebo_low_p <- 2 * pnorm(-abs(placebo_low_coef / placebo_low_se))
cat(sprintf("  Placebo DDD (Low risk): %.4f (SE: %.4f, p = %.4f)\n",
            placebo_low_coef, placebo_low_se, placebo_low_p))
rm(ppd_low, m_placebo_low); gc()

# ---- 4. Alternative flood zone definitions ----
cat("\n--- Alternative Flood Zone Definitions ---\n")

ppd_main <- load_subset("year >= 2009")

# Broader: High + Medium + Low
ppd_main[, in_broad_flood := flood_risk %in% c("High", "Medium", "Low")]
ppd_main[, ddd_broad := in_broad_flood * post_floodre * flood_re_eligible]
ppd_main[, dd_broad_post := in_broad_flood * post_floodre]
ppd_main[, dd_broad_elig := in_broad_flood * flood_re_eligible]

m_broad <- feols(
  log_price ~ ddd_broad + dd_broad_post + dd_post_eligible + dd_broad_elig +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq,
  lean = TRUE
)
broad_coef <- coef(m_broad)["ddd_broad"]
broad_se <- se(m_broad)["ddd_broad"]
cat(sprintf("  DDD (Broad flood zone H+M+L): %.4f (SE: %.4f)\n", broad_coef, broad_se))
rm(m_broad); gc()

# Narrower: High only
ppd_main[, in_high_only := (flood_risk == "High")]
ppd_main[, ddd_high_only := in_high_only * post_floodre * flood_re_eligible]
ppd_main[, dd_high_post := in_high_only * post_floodre]
ppd_main[, dd_high_elig := in_high_only * flood_re_eligible]

m_high <- feols(
  log_price ~ ddd_high_only + dd_high_post + dd_post_eligible + dd_high_elig +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq,
  lean = TRUE
)
high_coef <- coef(m_high)["ddd_high_only"]
high_se <- se(m_high)["ddd_high_only"]
cat(sprintf("  DDD (High only): %.4f (SE: %.4f)\n", high_coef, high_se))
rm(m_high); gc()

# ---- 5. Donut estimation ----
cat("\n--- Donut Estimation (exclude 2016H1) ---\n")

ppd_donut <- ppd_main[!(year == 2016 & quarter %in% c(1, 2))]
ppd_donut[, yq := factor(paste0(year, "Q", quarter))]

m_donut <- feols(
  log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_donut,
  cluster = ~ pc_district + yq,
  lean = TRUE
)
donut_coef <- coef(m_donut)["ddd"]
donut_se <- se(m_donut)["ddd"]
cat(sprintf("  DDD (Donut): %.4f (SE: %.4f)\n", donut_coef, donut_se))
rm(ppd_donut, m_donut); gc()

# ---- 6. Leave-one-out by region (top 10 postcode areas) ----
cat("\n--- Leave-One-Out by Postcode Area ---\n")

top_areas <- ppd_main[, .N, by = pc_area][order(-N)][1:10, pc_area]

loo_results <- list()
for (area in top_areas) {
  m_loo <- feols(
    log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible +
      i(property_type) + i(duration) |
      pc_district + yq,
    data = ppd_main[pc_area != area],
    cluster = ~ pc_district + yq,
    lean = TRUE
  )
  loo_results[[area]] <- data.table(
    excluded_area = area,
    ddd_coef = coef(m_loo)["ddd"],
    ddd_se = se(m_loo)["ddd"]
  )
  cat(sprintf("  Excluding %s: DDD = %.4f (SE: %.4f)\n",
              area, coef(m_loo)["ddd"], se(m_loo)["ddd"]))
  rm(m_loo); gc()
}
loo_dt <- rbindlist(loo_results)
fwrite(loo_dt, file.path(tab_dir, "leave_one_out.csv"))

# ---- 7. Freehold vs Leasehold split ----
cat("\n--- Freehold vs Leasehold ---\n")

tenure_results <- list()
for (tenure in c("F", "L")) {
  m_tenure <- feols(
    log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible |
      pc_district + yq,
    data = ppd_main[duration == tenure],
    cluster = ~ pc_district + yq,
    lean = TRUE
  )
  label <- ifelse(tenure == "F", "Freehold", "Leasehold")
  tenure_results[[tenure]] <- data.table(
    tenure = label,
    ddd_coef = coef(m_tenure)["ddd"],
    ddd_se = se(m_tenure)["ddd"],
    n = nobs(m_tenure)
  )
  cat(sprintf("  %s: DDD = %.4f (SE: %.4f, N = %s)\n",
              label, coef(m_tenure)["ddd"], se(m_tenure)["ddd"],
              format(nobs(m_tenure), big.mark = ",")))
  rm(m_tenure); gc()
}
fwrite(rbindlist(tenure_results), file.path(tab_dir, "tenure_split.csv"))

# Free main data before extended sample
rm(ppd_main); gc()

# ---- 8. Extended pre-period (2005-2025) ----
cat("\n--- Extended Sample (2005-2025) ---\n")

ppd_ext <- load_subset("year >= 2005")

m_ext <- feols(
  log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_ext,
  cluster = ~ pc_district + yq,
  lean = TRUE
)

ext_coef <- coef(m_ext)["ddd"]
ext_se <- se(m_ext)["ddd"]
ext_n <- nobs(m_ext)
cat(sprintf("  DDD (2005-2025): %.4f (SE: %.4f, N = %s)\n",
            ext_coef, ext_se, format(ext_n, big.mark = ",")))
rm(ppd_ext, m_ext); gc()

# ---- 9. HonestDiD sensitivity analysis ----
cat("\n--- HonestDiD Sensitivity Analysis ---\n")

tryCatch({
  es_data <- fread(file.path(tab_dir, "event_study_coefs.csv"))
  es_data <- es_data[year != 2015]

  pre_periods <- es_data[year < 2016]
  post_periods <- es_data[year >= 2016]

  if (nrow(pre_periods) >= 2 && nrow(post_periods) >= 1) {
    betahat <- c(pre_periods$estimate, post_periods$estimate)
    n_pre <- nrow(pre_periods)
    n_post <- nrow(post_periods)
    se_vec <- c(pre_periods$se, post_periods$se)
    sigma <- diag(se_vec^2)

    delta_rm_results <- createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.5)
    )

    cat("  HonestDiD bounds (Relative Magnitudes):\n")
    print(delta_rm_results)
    save(delta_rm_results, file = file.path(data_dir, "honestdid_results.RData"))
  } else {
    cat("  Insufficient event study coefficients for HonestDiD.\n")
  }
}, error = function(e) {
  cat(sprintf("  HonestDiD failed: %s\n", e$message))
})

# ---- 10. Compile robustness summary ----
cat("\n=== Robustness Summary ===\n")

rob_summary <- data.table(
  Test = c("Main (+ Controls)", "Main (District x YQ FE)",
           "Placebo: Very Low risk", "Placebo: Low risk",
           "Broad flood zone (H+M+L)", "High risk only",
           "Donut (excl 2016H1)", "Extended (2005+)"),
  Coefficient = c(
    main_res$ddd_coef[2], main_res$ddd_coef[3],
    placebo_vlow_coef, placebo_low_coef,
    broad_coef, high_coef,
    donut_coef, ext_coef
  ),
  SE = c(
    main_res$ddd_se[2], main_res$ddd_se[3],
    placebo_vlow_se, placebo_low_se,
    broad_se, high_se,
    donut_se, ext_se
  )
)
rob_summary[, Stars := ifelse(abs(Coefficient / SE) > 2.576, "***",
                        ifelse(abs(Coefficient / SE) > 1.960, "**",
                        ifelse(abs(Coefficient / SE) > 1.645, "*", "")))]

print(rob_summary)
fwrite(rob_summary, file.path(tab_dir, "robustness_summary.csv"))

# Save key results (no heavy model objects)
save(rob_summary, loo_dt,
     file = file.path(data_dir, "robustness_models.RData"))

cat("\nRobustness checks complete.\n")
