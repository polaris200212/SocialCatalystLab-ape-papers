## 03_main_analysis.R — Main DiD estimation
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

set.seed(42)

panel <- fread(file.path(DATA_DIR, "panel_quarterly.csv"))
annual <- fread(file.path(DATA_DIR, "panel_annual.csv"))
treat <- fread(file.path(DATA_DIR, "treatment_clean.csv"))

# ── 0. Exclude 2025-2026 adopters (no post-treatment BAAC data) ─────

# Morbihan (2025-07) and Eure (2026-02) reversed after our data ends
# Recode them as never-treated in the panel
late_deps <- treat[reversal_year >= 2025, dep_code]
cat("Excluding late adopters from treatment:", paste(late_deps, collapse = ", "), "\n")

panel[dep_code %in% late_deps, `:=`(
  treated = FALSE, post = 0L, first_treat_q = 0L,
  intensity = 0, share_pct = 0
)]
annual[dep_code %in% late_deps, `:=`(
  treated = FALSE, post = 0L, reversal_year = 0L, share_pct = 0
)]

n_treated <- uniqueN(panel[treated == TRUE, dep_code])
n_control <- uniqueN(panel[treated == FALSE, dep_code])
cat(sprintf("Analysis sample: %d treated, %d control départements\n", n_treated, n_control))

# ── 1. Treatment Rollout Visualization ───────────────────────────────

rollout <- treat[reversal_year < 2025, .(n = .N), by = .(reversal_year, reversal_quarter)]
rollout[, cohort_label := paste0(reversal_year, " Q", reversal_quarter)]
rollout[, cum_n := cumsum(n)]

cat("\nTreatment cohort sizes:\n")
print(rollout[order(reversal_year, reversal_quarter)])

# ── 2. Callaway-Sant'Anna DiD (Quarterly) ────────────────────────────

cat("\n=== Callaway-Sant'Anna: Total Accidents ===\n")

cs_accidents <- att_gt(
  yname = "accidents",
  tname = "t",
  idname = "dep_id",
  gname = "first_treat_q",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

# Aggregate: overall ATT
agg_overall <- aggte(cs_accidents, type = "simple")
cat("\nOverall ATT (accidents):\n")
summary(agg_overall)

# Aggregate: event study
es_accidents <- aggte(cs_accidents, type = "dynamic",
                      min_e = -8, max_e = 16)
cat("\nEvent study (accidents):\n")
summary(es_accidents)

# ── 3. CS-DiD for Fatalities ─────────────────────────────────────────

cat("\n=== Callaway-Sant'Anna: Fatalities ===\n")

cs_killed <- att_gt(
  yname = "killed",
  tname = "t",
  idname = "dep_id",
  gname = "first_treat_q",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_killed <- aggte(cs_killed, type = "simple")
cat("\nOverall ATT (fatalities):\n")
summary(agg_killed)

es_killed <- aggte(cs_killed, type = "dynamic",
                   min_e = -8, max_e = 16)

# ── 4. CS-DiD for Hospitalized ───────────────────────────────────────

cat("\n=== Callaway-Sant'Anna: Hospitalized ===\n")

cs_hosp <- att_gt(
  yname = "hospitalized",
  tname = "t",
  idname = "dep_id",
  gname = "first_treat_q",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_hosp <- aggte(cs_hosp, type = "simple")
cat("\nOverall ATT (hospitalized):\n")
summary(agg_hosp)

es_hosp <- aggte(cs_hosp, type = "dynamic",
                 min_e = -8, max_e = 16)

# ── 5. CS-DiD for Total Casualties ───────────────────────────────────

cat("\n=== Callaway-Sant'Anna: Total Casualties ===\n")

cs_total <- att_gt(
  yname = "total_casualties",
  tname = "t",
  idname = "dep_id",
  gname = "first_treat_q",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_total <- aggte(cs_total, type = "simple")
cat("\nOverall ATT (total casualties):\n")
summary(agg_total)

es_total <- aggte(cs_total, type = "dynamic",
                  min_e = -8, max_e = 16)

# ── 6. TWFE as Comparison ────────────────────────────────────────────

cat("\n=== TWFE Comparison ===\n")

twfe_acc <- feols(accidents ~ post | dep_id + t, data = panel, cluster = ~dep_id)
twfe_kill <- feols(killed ~ post | dep_id + t, data = panel, cluster = ~dep_id)
twfe_hosp <- feols(hospitalized ~ post | dep_id + t, data = panel, cluster = ~dep_id)
twfe_total <- feols(total_casualties ~ post | dep_id + t, data = panel, cluster = ~dep_id)

cat("\nTWFE Results:\n")
etable(twfe_acc, twfe_kill, twfe_hosp, twfe_total,
       headers = c("Accidents", "Killed", "Hospitalized", "Total Casualties"))

# ── 7. Sun-Abraham Estimator ─────────────────────────────────────────

cat("\n=== Sun-Abraham Event Study ===\n")

# For Sun-Abraham, create relative time variable
panel[, rel_time := fifelse(first_treat_q > 0, t - first_treat_q, NA_integer_)]

# SA with fixest::sunab
sa_acc <- feols(accidents ~ sunab(first_treat_q, t) | dep_id + t,
                data = panel[first_treat_q > 0 | first_treat_q == 0],
                cluster = ~dep_id)
cat("\nSun-Abraham ATT:\n")
summary(sa_acc)

# ── 8. Intensity-Weighted DiD ────────────────────────────────────────

cat("\n=== Intensity (Share of Network) ===\n")

twfe_intensity <- feols(accidents ~ intensity | dep_id + t,
                        data = panel, cluster = ~dep_id)
cat("\nIntensity TWFE:\n")
summary(twfe_intensity)

# ── 9. Annual Specification ──────────────────────────────────────────

cat("\n=== Annual Panel CS-DiD ===\n")

annual[, dep_id := as.integer(factor(dep_code))]
annual[, first_treat_yr := fifelse(reversal_year > 0, reversal_year, 0L)]

cs_annual <- att_gt(
  yname = "accidents",
  tname = "year",
  idname = "dep_id",
  gname = "first_treat_yr",
  data = as.data.frame(annual),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_annual <- aggte(cs_annual, type = "simple")
cat("\nAnnual ATT (accidents):\n")
summary(agg_annual)

es_annual <- aggte(cs_annual, type = "dynamic",
                   min_e = -4, max_e = 4)

# ── 10. Save Results ─────────────────────────────────────────────────

results <- list(
  cs_accidents = cs_accidents,
  cs_killed = cs_killed,
  cs_hosp = cs_hosp,
  cs_total = cs_total,
  es_accidents = es_accidents,
  es_killed = es_killed,
  es_hosp = es_hosp,
  es_total = es_total,
  agg_overall = agg_overall,
  agg_killed = agg_killed,
  agg_hosp = agg_hosp,
  agg_total = agg_total,
  twfe_acc = twfe_acc,
  twfe_kill = twfe_kill,
  twfe_hosp = twfe_hosp,
  twfe_total = twfe_total,
  sa_acc = sa_acc,
  twfe_intensity = twfe_intensity,
  cs_annual = cs_annual,
  es_annual = es_annual,
  agg_annual = agg_annual
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))
cat("\nAll results saved to main_results.rds\n")
