## 04_robustness.R — Robustness checks and placebo tests
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

panel <- fread(file.path(DATA_DIR, "panel_quarterly.csv"))
annual <- fread(file.path(DATA_DIR, "panel_annual.csv"))
treat <- fread(file.path(DATA_DIR, "treatment_clean.csv"))

# Recode late adopters as never-treated
late_deps <- treat[reversal_year >= 2025, dep_code]
panel[dep_code %in% late_deps, `:=`(
  treated = FALSE, post = 0L, first_treat_q = 0L,
  intensity = 0, share_pct = 0
)]
annual[dep_code %in% late_deps, `:=`(
  treated = FALSE, post = 0L, reversal_year = 0L, share_pct = 0
)]

# ── 1. Placebo: Autoroute Accidents ──────────────────────────────────
# Speed limits on autoroutes were never changed → should show no effect

cat("=== Placebo: Autoroute Accidents ===\n")

twfe_placebo_auto <- feols(accidents_auto ~ post | dep_id + t,
                           data = panel, cluster = ~dep_id)
cat("Autoroute placebo (TWFE):\n")
summary(twfe_placebo_auto)

# ── 2. Placebo: Urban Départementale Accidents ───────────────────────
# Speed limits within agglomeration (50 km/h) were never changed

cat("\n=== Placebo: Urban Routes Départementales ===\n")

twfe_placebo_urban <- feols(accidents_urban ~ post | dep_id + t,
                            data = panel, cluster = ~dep_id)
cat("Urban départementales placebo (TWFE):\n")
summary(twfe_placebo_urban)

# ── 3. Excluding COVID Lockdown Period ───────────────────────────────
# Drop Q1-Q2 2020 (first national lockdown March-May, second October-Dec 2020)

cat("\n=== Excluding COVID Periods ===\n")

panel_no_covid <- panel[!(year == 2020 & quarter %in% 1:3)]
cat(sprintf("Obs after excluding Q1-Q3 2020: %d (from %d)\n",
            nrow(panel_no_covid), nrow(panel)))

twfe_nocovid <- feols(accidents ~ post | dep_id + t,
                      data = panel_no_covid, cluster = ~dep_id)
cat("TWFE excluding Q1-Q3 2020:\n")
summary(twfe_nocovid)

# ── 4. Post-2021 Adopters Only ───────────────────────────────────────
# Focus on departments that reversed after COVID's worst impact

cat("\n=== Post-2021 Adopters Only ===\n")

late_adopters <- treat[reversal_year >= 2022 & reversal_year < 2025, dep_code]
cat(sprintf("Late adopters (2022-2024): %d départements\n", length(late_adopters)))

panel_late <- panel[dep_code %in% late_adopters | treated == FALSE]
panel_late[!(dep_code %in% late_adopters), first_treat_q := 0L]

twfe_late <- feols(accidents ~ post | dep_id + t,
                   data = panel_late, cluster = ~dep_id)
cat("TWFE - Post-2021 adopters only:\n")
summary(twfe_late)

# ── 5. Triple-Difference: Treated Road × Treated Dept × Post ────────
# Stack treated road and autoroute outcomes for each département

cat("\n=== Triple-Difference (DDD) ===\n")

ddd_data <- rbind(
  panel[, .(dep_code, dep_id, year, quarter, t, first_treat_q, post, treated,
            accidents = accidents, share_pct = share_pct,
            road_type = "dept_rural")],
  panel[, .(dep_code, dep_id, year, quarter, t, first_treat_q, post, treated,
            accidents = accidents_auto, share_pct = share_pct,
            road_type = "autoroute")]
)
ddd_data[, dept_road := as.integer(road_type == "dept_rural")]
ddd_data[, cell_id := paste(dep_code, road_type)]
ddd_data[, cell_num := as.integer(factor(cell_id))]

# DDD: post × dept_road is the triple-difference coefficient (Eq. 3)
twfe_ddd <- feols(accidents ~ post:dept_road + post |
                    cell_num + t,
                  data = ddd_data, cluster = ~dep_id)
cat("DDD result (one-way clustering, dep_id):\n")
summary(twfe_ddd)

# ── 5a2. DDD with Two-Way Clustered SEs ───────────────────────────────
# Cluster by département AND quarter for robustness

cat("\n=== DDD Two-Way Clustering (dep × quarter) ===\n")

twfe_ddd_2way <- feols(accidents ~ post:dept_road + post |
                         cell_num + t,
                       data = ddd_data, cluster = ~dep_id + t)
cat("DDD result (two-way clustering, dep_id + t):\n")
summary(twfe_ddd_2way)

# ── 5b. DDD Event Study ──────────────────────────────────────────────
# Relative-time dummies × dept_road in the full stacked sample
# Never-treated départements have rel_time = NA → contribute through FE only

cat("\n=== DDD Event Study ===\n")

ddd_data[, rel_time := fifelse(first_treat_q > 0, t - first_treat_q, NA_integer_)]
ddd_data[, rel_bin := pmin(pmax(rel_time, -8L), 12L)]

# Full stacked sample: never-treated contribute to cell and time FE
ddd_es <- feols(accidents ~ i(rel_bin, dept_road, ref = -1) +
                  i(rel_bin, ref = -1) |
                  cell_num + t,
                data = ddd_data,
                cluster = ~dep_id)
cat("DDD Event Study:\n")
ct_es <- coeftable(ddd_es)
dr_rows <- grepl("dept_road", rownames(ct_es))
print(ct_es[dr_rows, ])

# ── 5c. DDD Intensity ────────────────────────────────────────────────
# Interact share_pct with dept_road in DDD framework

cat("\n=== DDD Intensity (share × dept_road) ===\n")

ddd_data[, intensity_ddd := post * dept_road * share_pct / 100]
ddd_data[, intensity_auto := post * share_pct / 100]

twfe_ddd_intensity <- feols(accidents ~ intensity_ddd + intensity_auto |
                              cell_num + t,
                            data = ddd_data, cluster = ~dep_id)
cat("DDD Intensity result:\n")
summary(twfe_ddd_intensity)

# ── 6. Full Coverage Départements Only ───────────────────────────────
# Restrict to departments that restored 90 km/h on >50% of network

cat("\n=== High-Intensity Treatment (>50% network) ===\n")

high_treat <- treat[share_pct >= 50 & reversal_year < 2025, dep_code]
cat(sprintf("Departments with >50%% coverage: %d\n", length(high_treat)))

panel_high <- panel[dep_code %in% high_treat | treated == FALSE]
panel_high[!(dep_code %in% high_treat), first_treat_q := 0L]

twfe_high <- feols(accidents ~ post | dep_id + t,
                   data = panel_high, cluster = ~dep_id)
cat("TWFE - High coverage only:\n")
summary(twfe_high)

# Also CS-DiD for high-intensity
if (length(high_treat) >= 5) {
  cs_high <- att_gt(
    yname = "accidents",
    tname = "t",
    idname = "dep_id",
    gname = "first_treat_q",
    data = as.data.frame(panel_high),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
  agg_high <- aggte(cs_high, type = "simple")
  cat("\nCS-DiD ATT (high coverage only):\n")
  summary(agg_high)

  es_high <- aggte(cs_high, type = "dynamic", min_e = -8, max_e = 16)
}

# ── 7. Severity Ratio ────────────────────────────────────────────────
# (killed + hospitalized) / total accidents — intensity margin

cat("\n=== Severity Ratio ===\n")

panel[, severity := fifelse(accidents > 0, (killed + hospitalized) / accidents, NA_real_)]

twfe_severity <- feols(severity ~ post | dep_id + t,
                       data = panel[!is.na(severity)], cluster = ~dep_id)
cat("TWFE - Severity ratio:\n")
summary(twfe_severity)

# ── 8. Log Outcomes ──────────────────────────────────────────────────

cat("\n=== Log(Accidents + 1) ===\n")

panel[, log_acc := log(accidents + 1)]

twfe_log <- feols(log_acc ~ post | dep_id + t,
                  data = panel, cluster = ~dep_id)
cat("TWFE - Log accidents:\n")
summary(twfe_log)

# ── 9. Randomization Inference ───────────────────────────────────────
# Permute treatment assignment across départements

cat("\n=== Randomization Inference (500 permutations) ===\n")

set.seed(42)
n_perms <- 500

# Get the actual TWFE coefficient
actual_coef <- coef(feols(accidents ~ post | dep_id + t, data = panel))["post"]

# Get treatment info
treat_info <- unique(panel[first_treat_q > 0, .(dep_code, first_treat_q)])
n_treated_deps <- nrow(treat_info)
all_dep_codes <- unique(panel$dep_code)

perm_coefs <- numeric(n_perms)
for (i in 1:n_perms) {
  # Randomly assign treatment timing to same number of départements
  perm_deps <- sample(all_dep_codes, n_treated_deps)
  perm_timing <- sample(treat_info$first_treat_q, n_treated_deps)

  panel_perm <- copy(panel)
  panel_perm[, first_treat_q_perm := 0L]
  for (j in seq_along(perm_deps)) {
    panel_perm[dep_code == perm_deps[j], first_treat_q_perm := perm_timing[j]]
  }
  panel_perm[, post_perm := fifelse(first_treat_q_perm > 0 & t >= first_treat_q_perm, 1L, 0L)]

  perm_coefs[i] <- tryCatch(
    coef(feols(accidents ~ post_perm | dep_id + t, data = panel_perm))["post_perm"],
    error = function(e) NA_real_
  )
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(actual_coef))
cat(sprintf("Actual coefficient: %.3f\n", actual_coef))
cat(sprintf("RI p-value (two-sided): %.4f\n", ri_pvalue))
cat(sprintf("RI distribution: mean=%.3f, sd=%.3f, min=%.3f, max=%.3f\n",
            mean(perm_coefs), sd(perm_coefs), min(perm_coefs), max(perm_coefs)))

# ── 10. Bacon Decomposition ─────────────────────────────────────────

cat("\n=== Bacon Decomposition ===\n")

# Use bacondecomp package
if (requireNamespace("bacondecomp", quietly = TRUE)) {
  library(bacondecomp)
  bacon_out <- bacon(accidents ~ post,
                     data = as.data.frame(annual[, .(dep_code, year, accidents, post, dep_id)]),
                     id_var = "dep_id",
                     time_var = "year")
  cat("Bacon decomposition:\n")
  print(summary(bacon_out))
} else {
  cat("bacondecomp package not available. Install with: install.packages('bacondecomp')\n")
}

# ── 11. Save Robustness Results ──────────────────────────────────────

rob_results <- list(
  twfe_placebo_auto = twfe_placebo_auto,
  twfe_placebo_urban = twfe_placebo_urban,
  twfe_nocovid = twfe_nocovid,
  twfe_late = twfe_late,
  twfe_ddd = twfe_ddd,
  twfe_ddd_2way = twfe_ddd_2way,
  twfe_high = twfe_high,
  twfe_severity = twfe_severity,
  twfe_log = twfe_log,
  ri_pvalue = ri_pvalue,
  ri_actual = actual_coef,
  ri_distribution = perm_coefs,
  es_high = if (exists("es_high")) es_high else NULL,
  ddd_es = ddd_es,
  twfe_ddd_intensity = twfe_ddd_intensity
)

saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))
cat("\nRobustness results saved.\n")
