## 03_main_analysis.R — Primary DiD and DDD estimation
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
panel[, state_fips := str_pad(as.character(state_fips), width = 2, pad = "0")]

race_long <- fread(file.path(DATA_DIR, "race_panel.csv"))
race_long[, fips := str_pad(as.character(fips), width = 5, pad = "0")]

cat("=== ANALYSIS 1: First Stage — Jail Population (DiD) ===\n")

# --- 1a. TWFE (baseline) ---
twfe_jail <- feols(
  jail_rate ~ treated | fips + year,
  data = panel[!is.na(jail_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Jail Rate:\n")
summary(twfe_jail)

# --- 1b. Callaway & Sant'Anna (2021) ---
# CS-DiD requires: panel, outcome, unit ID, time, treatment time (0=never)
cs_data <- panel[!is.na(jail_rate) & !is.na(treatment_year)]
cs_data[, fips_num := as.integer(factor(fips))]

cat("\nCS-DiD estimation for jail rate...\n")
set.seed(2024)
cs_jail <- att_gt(
  yname  = "jail_rate",
  tname  = "year",
  idname = "fips_num",
  gname  = "treatment_year",
  data   = as.data.frame(cs_data),
  control_group = "nevertreated",
  est_method = "dr",       # Doubly robust
  base_period = "universal",
  bstrap = TRUE,
  cband  = TRUE,
  biters = 1000
)

cat("\nCS-DiD group-time ATT summary:\n")
summary(cs_jail)

# Aggregate: simple ATT
cs_jail_agg <- aggte(cs_jail, type = "simple")
cat("\nCS-DiD Simple ATT (Jail Rate):\n")
summary(cs_jail_agg)

# Aggregate: dynamic (event study)
cs_jail_es <- aggte(cs_jail, type = "dynamic", min_e = -8, max_e = 6)
cat("\nCS-DiD Event Study (Jail Rate):\n")
summary(cs_jail_es)

# Save event study for plotting
es_jail_df <- data.frame(
  event_time = cs_jail_es$egt,
  att = cs_jail_es$att.egt,
  se = cs_jail_es$se.egt,
  ci_lower = cs_jail_es$att.egt - 1.96 * cs_jail_es$se.egt,
  ci_upper = cs_jail_es$att.egt + 1.96 * cs_jail_es$se.egt
)
fwrite(es_jail_df, file.path(DATA_DIR, "es_jail_rate.csv"))

cat("\n=== ANALYSIS 2: First Stage — Pretrial vs Sentenced ===\n")

# Pretrial jail population rate
panel[, pretrial_rate := fifelse(total_pop_15to64 > 0,
                                  total_jail_pretrial / total_pop_15to64 * 100000, NA_real_)]
panel[, sentenced_rate := fifelse(total_pop_15to64 > 0,
                                   total_jail_sentenced / total_pop_15to64 * 100000, NA_real_)]

twfe_pretrial <- feols(
  pretrial_rate ~ treated | fips + year,
  data = panel[!is.na(pretrial_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Pretrial Rate:\n")
summary(twfe_pretrial)

twfe_sentenced <- feols(
  sentenced_rate ~ treated | fips + year,
  data = panel[!is.na(sentenced_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Sentenced Rate:\n")
summary(twfe_sentenced)

# CS-DiD for pretrial
cs_pretrial_data <- panel[!is.na(pretrial_rate) & !is.na(treatment_year)]
cs_pretrial_data[, fips_num := as.integer(factor(fips))]

set.seed(2024)
cs_pretrial <- tryCatch({
  att_gt(
    yname  = "pretrial_rate",
    tname  = "year",
    idname = "fips_num",
    gname  = "treatment_year",
    data   = as.data.frame(cs_pretrial_data),
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("CS-DiD pretrial failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_pretrial)) {
  cs_pretrial_agg <- aggte(cs_pretrial, type = "simple")
  cat("\nCS-DiD Simple ATT (Pretrial Rate):\n")
  summary(cs_pretrial_agg)

  cs_pretrial_es <- aggte(cs_pretrial, type = "dynamic", min_e = -8, max_e = 6)
  es_pretrial_df <- data.frame(
    event_time = cs_pretrial_es$egt,
    att = cs_pretrial_es$att.egt,
    se = cs_pretrial_es$se.egt,
    ci_lower = cs_pretrial_es$att.egt - 1.96 * cs_pretrial_es$se.egt,
    ci_upper = cs_pretrial_es$att.egt + 1.96 * cs_pretrial_es$se.egt
  )
  fwrite(es_pretrial_df, file.path(DATA_DIR, "es_pretrial_rate.csv"))
}

cat("\n=== ANALYSIS 3: Main Outcome — Homicide Mortality ===\n")

twfe_homicide <- feols(
  homicide_rate ~ treated | fips + year,
  data = panel[!is.na(homicide_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Homicide Rate:\n")
summary(twfe_homicide)

# CS-DiD for homicides
cs_hom_data <- panel[!is.na(homicide_rate) & !is.na(treatment_year)]
cs_hom_data[, fips_num := as.integer(factor(fips))]

set.seed(2024)
cs_homicide <- tryCatch({
  att_gt(
    yname  = "homicide_rate",
    tname  = "year",
    idname = "fips_num",
    gname  = "treatment_year",
    data   = as.data.frame(cs_hom_data),
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("CS-DiD homicide failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_homicide)) {
  cs_hom_agg <- aggte(cs_homicide, type = "simple")
  cat("\nCS-DiD Simple ATT (Homicide Rate):\n")
  summary(cs_hom_agg)

  cs_hom_es <- aggte(cs_homicide, type = "dynamic", min_e = -8, max_e = 6)
  es_hom_df <- data.frame(
    event_time = cs_hom_es$egt,
    att = cs_hom_es$att.egt,
    se = cs_hom_es$se.egt,
    ci_lower = cs_hom_es$att.egt - 1.96 * cs_hom_es$se.egt,
    ci_upper = cs_hom_es$att.egt + 1.96 * cs_hom_es$se.egt
  )
  fwrite(es_hom_df, file.path(DATA_DIR, "es_homicide_rate.csv"))
}

cat("\n=== ANALYSIS 4: DDD — Racial Decomposition ===\n")

# DDD: race × treated, with race×county, race×year, county×year FE
ddd_data <- race_long[!is.na(jail_rate_race)]
ddd_data[, `:=`(
  fips_race = paste0(fips, "_", race),
  year_race = paste0(year, "_", race)
)]

# DDD: Black × treated interaction
ddd_jail <- feols(
  jail_rate_race ~ is_black:treated | fips_race + year_race + fips^year,
  data = ddd_data,
  cluster = ~state_fips
)
cat("\nDDD Jail Rate (Black × Treated):\n")
summary(ddd_jail)

# Also run for homicide if available
ddd_hom_data <- race_long[!is.na(homicide_rate_race)]
if (nrow(ddd_hom_data) > 100) {
  ddd_hom_data[, `:=`(
    fips_race = paste0(fips, "_", race),
    year_race = paste0(year, "_", race)
  )]

  ddd_homicide <- feols(
    homicide_rate_race ~ is_black:treated | fips_race + year_race + fips^year,
    data = ddd_hom_data,
    cluster = ~state_fips
  )
  cat("\nDDD Homicide Rate (Black × Treated):\n")
  summary(ddd_homicide)
} else {
  cat("Insufficient race-specific homicide data for DDD\n")
  ddd_homicide <- NULL
}

cat("\n=== ANALYSIS 5: TWFE with Controls ===\n")

# Full specification with controls
twfe_jail_ctrl <- feols(
  jail_rate ~ treated + poverty_rate + unemp_rate + log_pop | fips + year,
  data = panel[!is.na(jail_rate) & !is.na(poverty_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Jail Rate (with controls):\n")
summary(twfe_jail_ctrl)

# State × year FE (absorbs statewide reforms)
twfe_jail_sxyr <- feols(
  jail_rate ~ treated | fips + state_fips^year,
  data = panel[!is.na(jail_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Jail Rate (State × Year FE):\n")
summary(twfe_jail_sxyr)

# Homicide with state × year FE
twfe_hom_sxyr <- feols(
  homicide_rate ~ treated | fips + state_fips^year,
  data = panel[!is.na(homicide_rate)],
  cluster = ~state_fips
)
cat("\nTWFE Homicide Rate (State × Year FE):\n")
summary(twfe_hom_sxyr)

cat("\n=== ANALYSIS 6: Black-White Jail Ratio ===\n")

twfe_bw_ratio <- feols(
  bw_jail_ratio ~ treated | fips + year,
  data = panel[!is.na(bw_jail_ratio) & is.finite(bw_jail_ratio)],
  cluster = ~state_fips
)
cat("\nTWFE Black/White Jail Ratio:\n")
summary(twfe_bw_ratio)

cat("\n=== SAVING RESULTS ===\n")

# Save key results for table generation
results <- list(
  twfe_jail = twfe_jail,
  twfe_jail_ctrl = twfe_jail_ctrl,
  twfe_jail_sxyr = twfe_jail_sxyr,
  twfe_pretrial = twfe_pretrial,
  twfe_sentenced = twfe_sentenced,
  twfe_homicide = twfe_homicide,
  twfe_hom_sxyr = twfe_hom_sxyr,
  twfe_bw_ratio = twfe_bw_ratio,
  ddd_jail = ddd_jail,
  cs_jail_agg = if (exists("cs_jail_agg")) cs_jail_agg else NULL,
  cs_hom_agg = if (exists("cs_hom_agg")) cs_hom_agg else NULL,
  cs_pretrial_agg = if (exists("cs_pretrial_agg")) cs_pretrial_agg else NULL
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))

# Summary statistics for the paper
cat("\n=== SUMMARY STATISTICS ===\n")

summ_treated <- panel[ever_treated == 1 & year >= 2005, .(
  N = .N,
  mean_jail_rate = mean(jail_rate, na.rm = TRUE),
  sd_jail_rate = sd(jail_rate, na.rm = TRUE),
  mean_homicide = mean(homicide_rate, na.rm = TRUE),
  mean_black_jail = mean(black_jail_rate, na.rm = TRUE),
  mean_white_jail = mean(white_jail_rate, na.rm = TRUE),
  mean_pop = mean(total_pop, na.rm = TRUE)
)]

summ_control <- panel[ever_treated == 0 & year >= 2005, .(
  N = .N,
  mean_jail_rate = mean(jail_rate, na.rm = TRUE),
  sd_jail_rate = sd(jail_rate, na.rm = TRUE),
  mean_homicide = mean(homicide_rate, na.rm = TRUE),
  mean_black_jail = mean(black_jail_rate, na.rm = TRUE),
  mean_white_jail = mean(white_jail_rate, na.rm = TRUE),
  mean_pop = mean(total_pop, na.rm = TRUE)
)]

cat("Treated counties:\n")
print(summ_treated)
cat("\nControl counties:\n")
print(summ_control)

# Save summary stats
summ_all <- panel[year >= 2005, .(
  jail_rate_mean = mean(jail_rate, na.rm = TRUE),
  jail_rate_sd = sd(jail_rate, na.rm = TRUE),
  jail_rate_p25 = quantile(jail_rate, 0.25, na.rm = TRUE),
  jail_rate_p75 = quantile(jail_rate, 0.75, na.rm = TRUE),
  homicide_rate_mean = mean(homicide_rate, na.rm = TRUE),
  homicide_rate_sd = sd(homicide_rate, na.rm = TRUE),
  total_pop_mean = mean(total_pop, na.rm = TRUE),
  poverty_rate_mean = mean(poverty_rate, na.rm = TRUE),
  black_share_mean = mean(black_share, na.rm = TRUE),
  unemp_rate_mean = mean(unemp_rate, na.rm = TRUE),
  N_counties = length(unique(fips)),
  N_obs = .N
)]

fwrite(summ_all, file.path(DATA_DIR, "summary_statistics.csv"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
