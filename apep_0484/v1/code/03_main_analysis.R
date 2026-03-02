###############################################################################
# 03_main_analysis.R — Triple-Difference estimation
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
###############################################################################

source("00_packages.R")

cat("=== Phase 3: Main Analysis ===\n")

# ---- 1. Load analysis panel ----
ppd <- read_parquet(file.path(data_dir, "analysis_panel.parquet"))
setDT(ppd)

cat(sprintf("  Loaded %s transactions\n", format(nrow(ppd), big.mark = ",")))

# ---- 2. Sample restriction ----
# Focus on 2009-2025 for the DDD (post-2009 builds need to exist)
ppd_main <- ppd[year >= 2009]
cat(sprintf("  After restricting to 2009+: %s transactions\n",
            format(nrow(ppd_main), big.mark = ",")))

# Create year-quarter factor for FE
ppd_main[, yq := factor(paste0(year, "Q", quarter))]

# ---- 3. Main DDD specification ----
cat("\n--- Main Triple-Difference Results ---\n")

# Specification 1: Simple DDD with postcode and year-quarter FE
# Y_ipzt = β1(FloodZone × Post2016 × Pre2009) + controls + pc_FE + yq_FE
m1 <- feols(
  log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

# Specification 2: Add property type controls
m2 <- feols(
  log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

# Specification 3: District × year-quarter FE (absorbs local trends)
m3 <- feols(
  log_price ~ ddd + dd_flood_eligible +
    i(property_type) + i(duration) |
    pc_district + la_name^yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

# Specification 4: Postcode-level FE (most saturated)
m4 <- feols(
  log_price ~ ddd + dd_flood_eligible +
    i(property_type) + i(duration) |
    postcode + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

# Display results
cat("\n  DDD Coefficient (Flood Zone × Post-2016 × Pre-2009):\n")
cat(sprintf("  Spec 1 (District + YQ FE):      %.4f (SE: %.4f)\n",
            coef(m1)["ddd"], se(m1)["ddd"]))
cat(sprintf("  Spec 2 (+ Property controls):   %.4f (SE: %.4f)\n",
            coef(m2)["ddd"], se(m2)["ddd"]))
cat(sprintf("  Spec 3 (District × YQ FE):      %.4f (SE: %.4f)\n",
            coef(m3)["ddd"], se(m3)["ddd"]))
cat(sprintf("  Spec 4 (Postcode + YQ FE):      %.4f (SE: %.4f)\n",
            coef(m4)["ddd"], se(m4)["ddd"]))

# ---- 4. Event Study ----
cat("\n--- Event Study (DDD by Year) ---\n")

# Free main model memory before event study (results already printed/saved)
main_coefs <- list(
  m1 = list(coef = coef(m1)["ddd"], se = se(m1)["ddd"], n = nobs(m1)),
  m2 = list(coef = coef(m2)["ddd"], se = se(m2)["ddd"], n = nobs(m2)),
  m3 = list(coef = coef(m3)["ddd"], se = se(m3)["ddd"], n = nobs(m3)),
  m4 = list(coef = coef(m4)["ddd"], se = se(m4)["ddd"], n = nobs(m4))
)
rm(m1, m2, m3, m4); gc()

# Memory-efficient event study: year-by-year 2-period DDD
# For each year t, use data from year t and reference year 2015
ppd_main[, flood_eligible := as.numeric(in_flood_zone) * as.numeric(flood_re_eligible)]
ref_year <- 2015
event_years <- sort(unique(ppd_main$year))
event_years <- event_years[event_years != ref_year]

es_list <- list()
for (yr in event_years) {
  sub <- ppd_main[year %in% c(ref_year, yr)]
  sub[, post_yr := as.numeric(year == yr)]
  sub[, ddd_yr := flood_eligible * post_yr]
  sub[, dd_flood_yr := as.numeric(in_flood_zone) * post_yr]
  sub[, dd_elig_yr := as.numeric(flood_re_eligible) * post_yr]

  m_yr <- tryCatch(
    feols(
      log_price ~ ddd_yr + dd_flood_yr + dd_elig_yr + flood_eligible +
        i(property_type) + i(duration) |
        pc_district + yq,
      data = sub,
      cluster = ~ pc_district + yq,
      lean = TRUE
    ),
    error = function(e) NULL
  )

  if (!is.null(m_yr)) {
    es_list[[as.character(yr)]] <- data.table(
      year = yr,
      estimate = coef(m_yr)["ddd_yr"],
      se = se(m_yr)["ddd_yr"],
      t = coef(m_yr)["ddd_yr"] / se(m_yr)["ddd_yr"],
      p = 2 * pnorm(-abs(coef(m_yr)["ddd_yr"] / se(m_yr)["ddd_yr"]))
    )
    cat(sprintf("  Year %d: %.4f (SE: %.4f)\n", yr,
                coef(m_yr)["ddd_yr"], se(m_yr)["ddd_yr"]))
  }
  rm(sub, m_yr); gc()
}

es_coefs <- rbindlist(es_list)
es_coefs <- rbind(es_coefs,
                  data.table(year = ref_year, estimate = 0, se = 0, t = NA, p = NA))
es_coefs <- es_coefs[order(year)]
es_coefs[, ci_lo := estimate - 1.96 * se]
es_coefs[, ci_hi := estimate + 1.96 * se]

fwrite(es_coefs, file.path(tab_dir, "event_study_coefs.csv"))

# Pre-trend test (joint significance of pre-2016 coefficients)
pre_es <- es_coefs[year < 2016 & year != ref_year]
if (nrow(pre_es) > 0) {
  # Chi-squared test: sum of (beta/se)^2
  chi2_stat <- sum((pre_es$estimate / pre_es$se)^2, na.rm = TRUE)
  chi2_p <- pchisq(chi2_stat, df = nrow(pre_es), lower.tail = FALSE)
  cat(sprintf("\n  Pre-trend joint test: chi2(%d) = %.2f, p = %.4f\n",
              nrow(pre_es), chi2_stat, chi2_p))
}

# ---- 5. Heterogeneity by flood risk level ----
cat("\n--- Heterogeneity by Flood Risk Level ---\n")

ppd_main[, in_high := (flood_risk == "High")]
ppd_main[, in_medium := (flood_risk == "Medium")]
ppd_main[, ddd_high := in_high * post_floodre * flood_re_eligible]
ppd_main[, ddd_medium := in_medium * post_floodre * flood_re_eligible]

m_het_risk <- feols(
  log_price ~ ddd_high + ddd_medium +
    in_high * post_floodre + in_medium * post_floodre +
    in_high * flood_re_eligible + in_medium * flood_re_eligible +
    i(property_type) + i(duration) |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

cat(sprintf("  DDD (High flood risk):   %.4f (SE: %.4f)\n",
            coef(m_het_risk)["ddd_high"], se(m_het_risk)["ddd_high"]))
cat(sprintf("  DDD (Medium flood risk): %.4f (SE: %.4f)\n",
            coef(m_het_risk)["ddd_medium"], se(m_het_risk)["ddd_medium"]))

# ---- 6. Heterogeneity by property type ----
cat("\n--- Heterogeneity by Property Type ---\n")

het_results <- list()
for (ptype in c("D", "S", "T", "F")) {
  m_sub <- feols(
    log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible |
      pc_district + yq,
    data = ppd_main[property_type == ptype],
    cluster = ~ pc_district + yq
  )
  het_results[[ptype]] <- data.table(
    property_type = ptype,
    estimate = coef(m_sub)["ddd"],
    se = se(m_sub)["ddd"],
    n = nobs(m_sub)
  )
  cat(sprintf("  %s: %.4f (SE: %.4f, N = %s)\n",
              ptype, coef(m_sub)["ddd"], se(m_sub)["ddd"],
              format(nobs(m_sub), big.mark = ",")))
}
het_dt <- rbindlist(het_results)
fwrite(het_dt, file.path(tab_dir, "heterogeneity_property_type.csv"))

# ---- 7. Heterogeneity by price quartile (proxy for Council Tax band) ----
cat("\n--- Heterogeneity by Price Quartile ---\n")

ppd_main[, price_quartile := cut(price,
  breaks = quantile(price, probs = c(0, 0.25, 0.5, 0.75, 1)),
  labels = c("Q1", "Q2", "Q3", "Q4"),
  include.lowest = TRUE)]

het_price <- list()
for (q in c("Q1", "Q2", "Q3", "Q4")) {
  m_sub <- feols(
    log_price ~ ddd + dd_flood_post + dd_post_eligible + dd_flood_eligible |
      pc_district + yq,
    data = ppd_main[price_quartile == q],
    cluster = ~ pc_district + yq
  )
  het_price[[q]] <- data.table(
    quartile = q,
    estimate = coef(m_sub)["ddd"],
    se = se(m_sub)["ddd"],
    n = nobs(m_sub)
  )
  cat(sprintf("  %s: %.4f (SE: %.4f, N = %s)\n",
              q, coef(m_sub)["ddd"], se(m_sub)["ddd"],
              format(nobs(m_sub), big.mark = ",")))
}
het_price_dt <- rbindlist(het_price)
fwrite(het_price_dt, file.path(tab_dir, "heterogeneity_price_quartile.csv"))

# ---- 8. Transaction volume DDD ----
cat("\n--- Transaction Volume Effects ---\n")

vol <- read_parquet(file.path(data_dir, "volume_panel.parquet"))
setDT(vol)
vol[, yq := factor(paste0(year, "Q", quarter))]
vol[, post_floodre := as.numeric(year > 2016 | (year == 2016 & quarter >= 2))]
vol[, in_flood_num := as.numeric(in_flood_zone)]

# Aggregate to postcode-quarter
vol_agg <- vol[year >= 2009, .(
  n_txns = sum(n_txns),
  n_new_build = sum(n_new_build),
  share_new_build = sum(n_new_build) / sum(n_txns)
), by = .(postcode, year, quarter, in_flood_num, yq, post_floodre)]

# DD interaction (numeric to avoid collinearity labeling issues)
vol_agg[, dd_vol := in_flood_num * post_floodre]

m_vol <- feols(
  log(n_txns + 1) ~ dd_vol |
    postcode + yq,
  data = vol_agg,
  cluster = ~ postcode + yq
)

cat(sprintf("  Volume effect (Flood Zone × Post): %.4f (SE: %.4f)\n",
            coef(m_vol)["dd_vol"], se(m_vol)["dd_vol"]))

# ---- 9. New construction moral hazard ----
cat("\n--- Moral Hazard: New Construction in Flood Zones ---\n")

# Share of new builds in flood zones over time
moral_hazard <- ppd[, .(
  share_new_build = mean(is_new_build),
  n_new_build = sum(is_new_build),
  n_total = .N
), by = .(year, in_flood_zone)]

fwrite(moral_hazard, file.path(tab_dir, "moral_hazard_newbuild.csv"))

# Use numeric versions to avoid collinearity labeling issues
ppd_main[, in_flood_num := as.numeric(in_flood_zone)]
ppd_main[, post_floodre_num := as.numeric(post_floodre)]
ppd_main[, dd_moral := in_flood_num * post_floodre_num]

m_moral <- feols(
  is_new_build ~ dd_moral |
    pc_district + yq,
  data = ppd_main,
  cluster = ~ pc_district + yq
)

cat(sprintf("  New build share effect (Flood Zone × Post): %.4f (SE: %.4f)\n",
            coef(m_moral)["dd_moral"], se(m_moral)["dd_moral"]))

# ---- 10. Save main results ----
main_results <- data.table(
  specification = c("District + YQ FE", "Property controls",
                    "District × YQ FE", "Postcode + YQ FE"),
  ddd_coef = c(main_coefs$m1$coef, main_coefs$m2$coef,
               main_coefs$m3$coef, main_coefs$m4$coef),
  ddd_se = c(main_coefs$m1$se, main_coefs$m2$se,
             main_coefs$m3$se, main_coefs$m4$se),
  n_obs = c(main_coefs$m1$n, main_coefs$m2$n,
            main_coefs$m3$n, main_coefs$m4$n)
)
fwrite(main_results, file.path(tab_dir, "main_results.csv"))

# Save results objects (models freed for memory)
save(main_coefs, m_het_risk, m_vol, m_moral,
     es_coefs, het_dt, het_price_dt, moral_hazard,
     file = file.path(data_dir, "main_models.RData"))

cat("\nMain analysis complete.\n")
