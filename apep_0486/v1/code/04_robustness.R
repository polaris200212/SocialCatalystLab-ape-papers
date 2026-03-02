## 04_robustness.R — Robustness checks and sensitivity analysis
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
panel[, state_fips := str_pad(as.character(state_fips), width = 2, pad = "0")]
panel[, pretrial_rate := fifelse(total_pop_15to64 > 0,
                                  total_jail_pretrial / total_pop_15to64 * 100000, NA_real_)]

cat("=== ROBUSTNESS 1: Pre-COVID Sample (2005-2019) ===\n")

pre_covid <- panel[year <= 2019]
rob_precovid <- feols(
  jail_rate ~ treated | fips + year,
  data = pre_covid[!is.na(jail_rate)],
  cluster = ~state_fips
)
cat("Pre-COVID jail rate:\n")
summary(rob_precovid)

rob_hom_precovid <- tryCatch({
  feols(
    homicide_rate ~ treated | fips + year,
    data = pre_covid[!is.na(homicide_rate)],
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("Pre-COVID homicide: insufficient data (CHR starts 2019)\n")
  NULL
})
if (!is.null(rob_hom_precovid)) {
  cat("Pre-COVID homicide rate:\n")
  summary(rob_hom_precovid)
}

cat("\n=== ROBUSTNESS 2: Pre-2020 Cohorts Only ===\n")

pre2020_cohort <- panel[treatment_year == 0 | treatment_year < 2020]
rob_precohort <- feols(
  jail_rate ~ treated | fips + year,
  data = pre2020_cohort[!is.na(jail_rate)],
  cluster = ~state_fips
)
cat("Pre-2020 cohorts jail rate:\n")
summary(rob_precohort)

cat("\n=== ROBUSTNESS 3: Leave-One-Out Influence ===\n")

large_counties <- c("17031", "06037", "48201", "42101", "48113") # Cook, LA, Harris, Philly, Dallas
loo_results <- list()

for (drop_fips in large_counties) {
  subset <- panel[fips != drop_fips & !is.na(jail_rate)]
  mod <- feols(
    jail_rate ~ treated | fips + year,
    data = subset,
    cluster = ~state_fips
  )
  county_name <- panel[fips == drop_fips, county_name[1]]
  loo_results[[drop_fips]] <- data.frame(
    dropped = county_name,
    fips = drop_fips,
    coef = coef(mod)["treated"],
    se = se(mod)["treated"],
    pval = pvalue(mod)["treated"]
  )
  cat(sprintf("  Drop %s (%s): coef=%.2f, se=%.2f, p=%.3f\n",
              county_name, drop_fips,
              coef(mod)["treated"], se(mod)["treated"], pvalue(mod)["treated"]))
}

loo_df <- bind_rows(loo_results)
fwrite(loo_df, file.path(DATA_DIR, "loo_results.csv"))

cat("\n=== ROBUSTNESS 4: Wild Cluster Bootstrap ===\n")

# Wild cluster bootstrap for main specification
set.seed(2024)
wcb_jail <- tryCatch({
  boottest(
    feols(jail_rate ~ treated | fips + year, data = panel[!is.na(jail_rate)],
          cluster = ~state_fips),
    param = "treated",
    clustid = "state_fips",
    B = 9999,
    type = "webb"
  )
}, error = function(e) {
  cat("Wild cluster bootstrap failed:", e$message, "\n")
  NULL
})

if (!is.null(wcb_jail)) {
  cat("\nWild Cluster Bootstrap (Jail Rate):\n")
  print(summary(wcb_jail))
}

cat("\n=== ROBUSTNESS 5: HonestDiD Sensitivity ===\n")

# Sensitivity to pre-trend violations using Rambachan & Roth (2023)
tryCatch({
  # Run a fixest event study for HonestDiD
  panel[, rel_time := fifelse(treatment_year > 0, year - treatment_year, NA_integer_)]
  panel[treatment_year == 0, rel_time := -1000L]  # Never treated

  # Bin relative time
  panel[, rel_time_binned := pmin(pmax(rel_time, -8L), 6L)]
  panel[rel_time == -1000L, rel_time_binned := NA_integer_]

  # Create event time dummies
  es_data <- panel[!is.na(jail_rate) & !is.na(rel_time_binned)]
  es_data[, rel_time_f := factor(rel_time_binned)]

  # TWFE event study (for HonestDiD)
  es_mod <- feols(
    jail_rate ~ i(rel_time_f, ref = "-1") | fips + year,
    data = es_data,
    cluster = ~state_fips
  )

  cat("Event study coefficients:\n")
  print(coeftable(es_mod))

  # HonestDiD: sensitivity to linear pre-trends
  honest_result <- tryCatch({
    betahat <- coef(es_mod)
    sigma <- vcov(es_mod)

    # Identify pre and post periods
    pre_idx <- grep("rel_time_f::-[2-8]", names(betahat))
    post_idx <- grep("rel_time_f::[0-6]", names(betahat))

    if (length(pre_idx) > 0 && length(post_idx) > 0) {
      honest <- HonestDiD::createSensitivityResults(
        betahat = betahat,
        sigma = sigma,
        numPrePeriods = length(pre_idx),
        numPostPeriods = length(post_idx),
        Mvec = seq(0, 0.5, by = 0.1),
        alpha = 0.05
      )
      cat("HonestDiD sensitivity results:\n")
      print(honest)
      honest
    } else {
      cat("Could not identify pre/post periods for HonestDiD\n")
      NULL
    }
  }, error = function(e) {
    cat("HonestDiD failed:", e$message, "\n")
    NULL
  })
}, error = function(e) {
  cat("Event study setup failed:", e$message, "\n")
})

cat("\n=== ROBUSTNESS 6: Race Placebo (AAPI) ===\n")

# AAPI population column may not exist in merged panel — check
if ("aapi_pop_15to64" %in% names(panel)) {
  panel[, aapi_jail_rate := fifelse(aapi_pop_15to64 > 10,
                                     aapi_jail_pop / aapi_pop_15to64 * 100000, NA_real_)]
} else {
  # Use total AAPI pop from Vera directly if available
  panel[, aapi_jail_rate := fifelse(!is.na(aapi_jail_pop) & total_pop_15to64 > 0,
                                     aapi_jail_pop / total_pop_15to64 * 100000, NA_real_)]
}

rob_aapi <- feols(
  aapi_jail_rate ~ treated | fips + year,
  data = panel[!is.na(aapi_jail_rate) & is.finite(aapi_jail_rate)],
  cluster = ~state_fips
)
cat("AAPI Placebo (should be null):\n")
summary(rob_aapi)

cat("\n=== ROBUSTNESS 7: Jail Admissions (Flow) ===\n")

panel[, jail_adm_rate := fifelse(total_pop_15to64 > 0,
                                  total_jail_adm / total_pop_15to64 * 100000, NA_real_)]

rob_adm <- feols(
  jail_adm_rate ~ treated | fips + year,
  data = panel[!is.na(jail_adm_rate)],
  cluster = ~state_fips
)
cat("Jail Admissions Rate:\n")
summary(rob_adm)

cat("\n=== ROBUSTNESS 8: Excluding 2020 ===\n")

rob_no2020 <- feols(
  jail_rate ~ treated | fips + year,
  data = panel[year != 2020 & !is.na(jail_rate)],
  cluster = ~state_fips
)
cat("Excluding 2020:\n")
summary(rob_no2020)

cat("\n=== ROBUSTNESS 9: Heterogeneity by Urbanicity ===\n")

for (urb in c("small/mid", "suburban", "urban")) {
  subset <- panel[urbanicity == urb & !is.na(jail_rate)]
  if (nrow(subset) > 100 && sum(subset$treated) > 0) {
    mod <- feols(jail_rate ~ treated | fips + year, data = subset, cluster = ~state_fips)
    cat(sprintf("\nUrbanicity = %s (N=%d):\n", urb, nrow(subset)))
    cat(sprintf("  coef=%.2f, se=%.2f, p=%.3f\n",
                coef(mod)["treated"], se(mod)["treated"], pvalue(mod)["treated"]))
  }
}

cat("\n=== ROBUSTNESS 10: Population-Weighted ===\n")

rob_weighted <- feols(
  jail_rate ~ treated | fips + year,
  data = panel[!is.na(jail_rate) & !is.na(total_pop)],
  weights = ~total_pop,
  cluster = ~state_fips
)
cat("Population-weighted:\n")
summary(rob_weighted)

cat("\n=== SAVING ALL ROBUSTNESS RESULTS ===\n")

rob_results <- list(
  precovid = rob_precovid,
  precohort = rob_precohort,
  loo = loo_df,
  no2020 = rob_no2020,
  aapi_placebo = rob_aapi,
  jail_adm = rob_adm,
  weighted = rob_weighted,
  hom_precovid = if (exists("rob_hom_precovid")) rob_hom_precovid else NULL
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== ROBUSTNESS CHECKS COMPLETE ===\n")
