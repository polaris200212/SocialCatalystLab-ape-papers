# =============================================================================
# 04_robustness.R — Going Up Alone v4 (apep_0478)
# IPW reweighting + individual-level checks + OCC1950 cleaning sensitivity
# v4: Added OCC1950 sensitivity, PERWT validation, comparison group robustness
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS (v4)\n")
cat("========================================\n\n")

scm_panel  <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked     <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))

nyc_statefip <- 36L
comparison_states <- c(17, 42, 25, 6, 26, 39, 34, 11, 24)
scm_panel[, treat_post := as.integer(STATEFIP == nyc_statefip & post == 1)]

# ─────────────────────────────────────────────────────────────────────────────
# R1: IPW Reweighting — Address linkage selection bias
# ─────────────────────────────────────────────────────────────────────────────

cat("R1: Inverse Probability Weighting for linkage bias...\n\n")

source("../../../../scripts/lib/azure_data.R")
con <- apep_azure_connect()

cat("  Fetching 1940 elevator operator characteristics (full population)...\n")
full_elev_1940 <- apep_azure_query(con, sprintf("
  SELECT
    HISTID,
    AGE, SEX, RACE, BPL, MARST, NATIVITY,
    OCC1950, OCCSCORE,
    STATEFIP, COUNTYICP
  FROM 'az://raw/ipums_fullcount/us1940b.parquet'
  WHERE OCC1950 = %d
", 761L))
cat(sprintf("  Full 1940 elevator operators: %s\n",
    format(nrow(full_elev_1940), big.mark = ",")))

apep_azure_disconnect(con)

full_elev_1940 <- as.data.table(full_elev_1940)

linked_ids <- linked[is_elevator_1940 == 1]$histid_1940
full_elev_1940[, is_linked := as.integer(HISTID %in% linked_ids)]
cat(sprintf("  Linkage rate: %.1f%%\n",
    mean(full_elev_1940$is_linked) * 100))

full_elev_1940[, `:=`(
  is_female = as.integer(SEX == 2),
  is_black = as.integer(RACE == 2),
  is_native = as.integer(BPL < 100),
  is_married = as.integer(MARST %in% c(1, 2)),
  age_centered = AGE - median(AGE),
  is_nyc = as.integer(STATEFIP == 36 & COUNTYICP %in% NYC_COUNTYICP)
)]

logit_link <- glm(
  is_linked ~ age_centered + I(age_centered^2) +
    is_female + is_black + is_native + is_married + is_nyc,
  data = full_elev_1940, family = binomial(link = "logit")
)
cat("\n  Linkage prediction model:\n")
print(summary(logit_link))

full_elev_1940[, p_link := predict(logit_link, type = "response")]
full_elev_1940[, ipw := 1 / p_link]

trim_99 <- quantile(full_elev_1940[is_linked == 1]$ipw, 0.99)
full_elev_1940[ipw > trim_99, ipw := trim_99]

ipw_weights <- full_elev_1940[is_linked == 1, .(HISTID, ipw)]
setnames(ipw_weights, "HISTID", "histid_1940")
linked_ipw <- merge(linked, ipw_weights, by = "histid_1940", all.x = TRUE)
linked_ipw[is.na(ipw), ipw := 1]

# Re-run core displacement regressions with IPW
cat("\n  IPW-weighted displacement regressions:\n")

reg_stay_ipw <- feols(
  stayed_same_occ ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)

reg_occ_ipw <- feols(
  occscore_change ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)

reg_move_ipw <- feols(
  interstate_mover ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)

elev_ipw <- linked_ipw[is_elevator_1940 == 1]
reg_nyc_ipw <- feols(
  still_elevator_1950 ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_ipw, cluster = ~statefip_1940, weights = ~ipw
)

saveRDS(logit_link, file.path(DATA_DIR, "linkage_logit.rds"))
fwrite(ipw_weights, file.path(DATA_DIR, "ipw_weights.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# R2: SCM Robustness (event study + triple diff)
# ─────────────────────────────────────────────────────────────────────────────

cat("\n\nR2: SCM robustness...\n")

# Event study
es_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]
reg_es <- feols(
  elev_per_10k_pop ~ i(year, is_nyc, ref = 1940) | STATEFIP + year,
  data = es_panel, cluster = ~STATEFIP
)

es_coefs <- as.data.frame(coeftable(reg_es))
es_coefs$year <- as.integer(gsub("year::|:is_nyc", "", rownames(es_coefs)))
fwrite(es_coefs, file.path(DATA_DIR, "event_study_coefs.csv"))

# Triple difference
occ_state <- scm_panel[, .(
  STATEFIP, year, is_nyc, post,
  n_elevator = n_elevator_ops, n_janitors
)]
occ_long <- melt(occ_state,
                 id.vars = c("STATEFIP", "year", "is_nyc", "post"),
                 measure.vars = c("n_elevator", "n_janitors"),
                 variable.name = "occupation", value.name = "count")
occ_long[, is_elevator := as.integer(occupation == "n_elevator")]
occ_long[, ddd_treat := as.integer(is_elevator == 1 & STATEFIP == nyc_statefip & post == 1)]
occ_long_sub <- occ_long[STATEFIP %in% c(nyc_statefip, comparison_states)]

reg_ddd <- feols(
  log(count + 1) ~ ddd_treat |
    STATEFIP^occupation + year^occupation + STATEFIP^year,
  data = occ_long_sub, cluster = ~STATEFIP
)

# ─────────────────────────────────────────────────────────────────────────────
# R3: Age heterogeneity
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR3: Displacement by age group...\n")
reg_age <- feols(
  stayed_same_occ ~ is_elevator_1940 * age_group_1940 |
    statefip_1940 + race_1940 + sex_1940,
  data = linked, cluster = ~statefip_1940
)

# ─────────────────────────────────────────────────────────────────────────────
# R4: Comparison group robustness — exclude janitors
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR4: Comparison group robustness — exclude janitors...\n")
linked_no_jan <- linked[occ1950_1940 != 770 | is_elevator_1940 == 1]
reg_stay_nojan <- feols(
  stayed_same_occ ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_no_jan, cluster = ~statefip_1940
)

# ─────────────────────────────────────────────────────────────────────────────
# R5: OCC1950 Cleaning Sensitivity (v4 new)
# Compare per-10k rates with and without special code cleaning
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR5: OCC1950 cleaning sensitivity...\n")

state_raw <- fread(file.path(DATA_DIR, "state_panel.csv"))

# total_employed already uses cleaned denominator
# Compute "uncleaned" denominator: total_pop - people with OCC1950=0 only
# (the old v3 definition was OCC1950 > 0 AND OCC1950 < 980)
state_raw[, total_employed_v3 := total_employed +
            n_occ_979 + n_occ_990 + n_occ_995]

# National comparison
sensitivity <- state_raw[, .(
  n_elevator_ops = sum(n_elevator_ops),
  total_employed_v4 = sum(total_employed),
  total_employed_v3 = sum(total_employed_v3)
), by = year]
sensitivity[, `:=`(
  rate_v4 = n_elevator_ops / total_employed_v4 * 10000,
  rate_v3 = n_elevator_ops / total_employed_v3 * 10000,
  pct_diff = (total_employed_v4 - total_employed_v3) / total_employed_v3 * 100
)]
cat("  Sensitivity: v4 (strict) vs v3 (lenient) cleaning\n")
print(sensitivity[, .(year, rate_v4, rate_v3, pct_diff)])
fwrite(sensitivity, file.path(DATA_DIR, "occ1950_sensitivity.csv"))

# Save all robustness
rob <- list(
  event_study = reg_es, triple_diff = reg_ddd,
  age_heterogeneity = reg_age, no_janitor = reg_stay_nojan,
  stay_ipw = reg_stay_ipw, occ_ipw = reg_occ_ipw,
  move_ipw = reg_move_ipw, nyc_ipw = reg_nyc_ipw,
  linkage_logit = logit_link
)
saveRDS(rob, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat("========================================\n")
