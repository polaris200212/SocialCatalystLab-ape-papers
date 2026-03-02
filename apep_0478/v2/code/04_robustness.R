# =============================================================================
# 04_robustness.R — Going Up Alone v2 (apep_0478)
# IPW reweighting + compressed SCM robustness + individual-level checks
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS (v2)\n")
cat("========================================\n\n")

scm_panel  <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked     <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))

nyc_statefip <- 36L
comparison_states <- c(17, 42, 25, 6, 26, 39, 34, 11, 24)
scm_panel[, treat_post := as.integer(STATEFIP == nyc_statefip & post == 1)]

# ─────────────────────────────────────────────────────────────────────────────
# R1: IPW Reweighting — Address linkage selection bias (46.7% rate)
# ─────────────────────────────────────────────────────────────────────────────

cat("R1: Inverse Probability Weighting for linkage bias...\n\n")

# The linked panel has a 46.7% linkage rate. We need to verify that
# linked individuals are not systematically different from the full population.
# Strategy: Estimate P(linked | X) using the linked vs. full population,
# then reweight.

# Load full population data for elevator operators from 1940
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

# Mark which were linked
linked_ids <- linked[is_elevator_1940 == 1]$histid_1940
full_elev_1940[, is_linked := as.integer(HISTID %in% linked_ids)]
cat(sprintf("  Linkage rate: %.1f%%\n",
    mean(full_elev_1940$is_linked) * 100))

# Predict linkage
full_elev_1940[, `:=`(
  is_female = as.integer(SEX == 2),
  is_black = as.integer(RACE == 2),
  is_native = as.integer(BPL < 100),
  is_married = as.integer(MARST %in% c(1, 2)),
  age_centered = AGE - median(AGE),
  is_nyc = as.integer(STATEFIP == 36 & COUNTYICP %in% c(610, 470, 810, 50, 850))
)]

logit_link <- glm(
  is_linked ~ age_centered + I(age_centered^2) +
    is_female + is_black + is_native + is_married + is_nyc,
  data = full_elev_1940, family = binomial(link = "logit")
)
cat("\n  Linkage prediction model:\n")
print(summary(logit_link))

# Compute IPW weights for linked sample
full_elev_1940[, p_link := predict(logit_link, type = "response")]
full_elev_1940[, ipw := 1 / p_link]

# Trim extreme weights at 99th percentile
trim_99 <- quantile(full_elev_1940[is_linked == 1]$ipw, 0.99)
full_elev_1940[ipw > trim_99, ipw := trim_99]

cat(sprintf("  IPW weight range: [%.2f, %.2f] (trimmed at 99th pct: %.2f)\n",
    min(full_elev_1940[is_linked == 1]$ipw),
    max(full_elev_1940[is_linked == 1]$ipw),
    trim_99))

# Merge IPW weights back to linked panel
ipw_weights <- full_elev_1940[is_linked == 1, .(HISTID, ipw)]
setnames(ipw_weights, "HISTID", "histid_1940")
linked_ipw <- merge(linked, ipw_weights, by = "histid_1940", all.x = TRUE)
linked_ipw[is.na(ipw), ipw := 1]

# Re-run core displacement regressions with IPW weights
cat("\n  IPW-weighted displacement regressions:\n")

cat("  (a) Occupational persistence (weighted):\n")
reg_stay_ipw <- feols(
  stayed_same_occ ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)
print(summary(reg_stay_ipw))

cat("\n  (b) OCCSCORE change (weighted):\n")
reg_occ_ipw <- feols(
  occscore_change ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)
print(summary(reg_occ_ipw))

cat("\n  (c) Interstate mobility (weighted):\n")
reg_move_ipw <- feols(
  interstate_mover ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_ipw, cluster = ~statefip_1940, weights = ~ipw
)
print(summary(reg_move_ipw))

# NYC persistence with IPW
elev_ipw <- linked_ipw[is_elevator_1940 == 1]
cat("\n  (d) NYC persistence (weighted):\n")
reg_nyc_ipw <- feols(
  still_elevator_1950 ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_ipw, cluster = ~statefip_1940, weights = ~ipw
)
print(summary(reg_nyc_ipw))

# Save IPW weights and linkage model
saveRDS(logit_link, file.path(DATA_DIR, "linkage_logit.rds"))
fwrite(ipw_weights, file.path(DATA_DIR, "ipw_weights.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# R2: SCM Robustness — Compressed (key checks only)
# ─────────────────────────────────────────────────────────────────────────────

cat("\n\nR2: SCM robustness (compressed)...\n")

# Event study
cat("  Event study...\n")
es_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]
reg_es <- feols(
  elev_per_10k_pop ~ i(year, is_nyc, ref = 1940) | STATEFIP + year,
  data = es_panel, cluster = ~STATEFIP
)
print(summary(reg_es))

es_coefs <- as.data.frame(coeftable(reg_es))
es_coefs$year <- as.integer(gsub("year::|:is_nyc", "", rownames(es_coefs)))
fwrite(es_coefs, file.path(DATA_DIR, "event_study_coefs.csv"))

# Triple difference
cat("\n  Triple difference...\n")
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
print(summary(reg_ddd))

# ─────────────────────────────────────────────────────────────────────────────
# R3: Individual-level robustness — age heterogeneity
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR3: Displacement by age group...\n")
reg_age <- feols(
  stayed_same_occ ~ is_elevator_1940 * age_group_1940 |
    statefip_1940 + race_1940 + sex_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_age))

# ─────────────────────────────────────────────────────────────────────────────
# R4: Comparison group robustness — exclude janitors (largest group)
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR4: Comparison group robustness — exclude janitors...\n")
linked_no_jan <- linked[occ1950_1940 != 770 | is_elevator_1940 == 1]
reg_stay_nojan <- feols(
  stayed_same_occ ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked_no_jan, cluster = ~statefip_1940
)
print(summary(reg_stay_nojan))

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
