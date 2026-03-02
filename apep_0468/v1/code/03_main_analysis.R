# ==============================================================================
# 03_main_analysis.R — Primary estimation
# APEP-0468: Where Does Workfare Work?
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
tab_dir <- "../tables"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("=== Panel loaded ===\n")
cat("N:", nrow(panel), "| Districts:", length(unique(panel$dist_id_11)),
    "| Years:", min(panel$year), "-", max(panel$year), "\n")

# ==============================================================================
# 1. Callaway-Sant'Anna (2021) Group-Time ATT
# ==============================================================================
cat("\n=== Callaway-Sant'Anna DiD ===\n")

# Prepare data for did::att_gt
# gname = first treated period (0 for never treated — but all are treated)
# We use Phase III as the latest group; no never-treated units
# CS-DiD with not-yet-treated as control

# Ensure balanced panel: keep only districts present in all years
cs_data <- copy(panel)
year_count <- cs_data[, .N, by = dist_id_11]
n_years <- length(unique(cs_data$year))
balanced_dists <- year_count[N == n_years]$dist_id_11
cs_data <- cs_data[dist_id_11 %in% balanced_dists]
cs_data[, id := as.integer(as.factor(dist_id_11))]
cat("Balanced panel:", length(balanced_dists), "districts,",
    n_years, "years,", nrow(cs_data), "obs\n")

# CS-DiD requires numeric id, time, group
cat("Cohorts:\n")
print(cs_data[, .(N_districts = uniqueN(dist_id_11)), by = first_treat])

# Primary: log nightlights
cat("\nEstimating CS-DiD (log_light)...\n")
cs_out <- att_gt(
  yname = "log_light",
  tname = "year",
  idname = "id",
  gname = "first_treat",
  data = as.data.frame(cs_data),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",      # Doubly-robust (Sant'Anna & Zhao 2020)
  base_period = "universal",
  clustervars = "id",
  print_details = FALSE
)

cat("\nGroup-time ATT estimates:\n")
summary(cs_out)

# Save raw group-time results
saveRDS(cs_out, file.path(data_dir, "cs_att_gt.rds"))

# ==============================================================================
# 2. Aggregate to event-study
# ==============================================================================
cat("\n=== Event Study Aggregation ===\n")

# Dynamic event study
cs_es <- aggte(cs_out, type = "dynamic", min_e = -6, max_e = 6)
cat("\nEvent Study (dynamic):\n")
summary(cs_es)

# Simple ATT (overall)
cs_simple <- aggte(cs_out, type = "simple")
cat("\nSimple ATT:\n")
summary(cs_simple)

# Group-level ATT
cs_group <- aggte(cs_out, type = "group")
cat("\nGroup-level ATT:\n")
summary(cs_group)

# Calendar-time ATT
cs_cal <- aggte(cs_out, type = "calendar")
cat("\nCalendar-time ATT:\n")
summary(cs_cal)

saveRDS(list(es = cs_es, simple = cs_simple, group = cs_group, cal = cs_cal),
        file.path(data_dir, "cs_aggregations.rds"))

# ==============================================================================
# 3. Pre-trends test
# ==============================================================================
cat("\n=== Pre-trends Tests ===\n")

# Extract pre-treatment coefficients
es_results <- data.table(
  event_time = cs_es$egt,
  att = cs_es$att.egt,
  se = cs_es$se.egt
)
es_results[, ci_lo := att - 1.96 * se]
es_results[, ci_hi := att + 1.96 * se]

pre_coefs <- es_results[event_time < 0]
cat("Pre-treatment coefficients:\n")
print(pre_coefs)

# Joint F-test for pre-trends = 0
if (nrow(pre_coefs) > 0) {
  pre_chi2 <- sum((pre_coefs$att / pre_coefs$se)^2)
  pre_pval <- 1 - pchisq(pre_chi2, df = nrow(pre_coefs))
  cat(sprintf("\nJoint pre-trends test: chi2(%d) = %.2f, p = %.4f\n",
              nrow(pre_coefs), pre_chi2, pre_pval))
}

# ==============================================================================
# 4. TWFE Baseline (for comparison)
# ==============================================================================
cat("\n=== TWFE Baseline ===\n")

# Standard TWFE
twfe_base <- feols(log_light ~ treated | dist_id_11 + year,
                   data = panel, cluster = ~pc01_state_id)
cat("\nTWFE (district + year FE, state-clustered):\n")
summary(twfe_base)

# TWFE with controls
twfe_ctrl <- feols(log_light ~ treated + i(rain_tercile) |
                     dist_id_11 + year,
                   data = panel, cluster = ~pc01_state_id)
cat("\nTWFE with rainfall controls:\n")
summary(twfe_ctrl)

# TWFE event study using fixest
panel[, event_time_f := relevel(as.factor(event_time), ref = "-1")]
twfe_es <- feols(log_light ~ i(event_time, ref = -1) | dist_id_11 + year,
                 data = panel[event_time >= -6 & event_time <= 6],
                 cluster = ~pc01_state_id)
cat("\nTWFE Event Study:\n")
summary(twfe_es)

saveRDS(list(base = twfe_base, ctrl = twfe_ctrl, es = twfe_es),
        file.path(data_dir, "twfe_results.rds"))

# ==============================================================================
# 5. Heterogeneity by baseline characteristics
# ==============================================================================
cat("\n=== Heterogeneity Analysis ===\n")

# A. By rainfall (arid vs wet)
cat("\nBy rainfall tercile:\n")
for (rt in levels(panel$rain_tercile)) {
  sub <- panel[rain_tercile == rt]
  if (nrow(sub) > 100) {
    m <- feols(log_light ~ treated | dist_id_11 + year,
               data = sub, cluster = ~pc01_state_id)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", rt,
                coef(m)["treated"], se(m)["treated"]))
  }
}

# B. By agricultural labor share
cat("\nBy agricultural labor share tercile:\n")
for (at in levels(panel$ag_labor_tercile)) {
  sub <- panel[ag_labor_tercile == at]
  if (nrow(sub) > 100) {
    m <- feols(log_light ~ treated | dist_id_11 + year,
               data = sub, cluster = ~pc01_state_id)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", at,
                coef(m)["treated"], se(m)["treated"]))
  }
}

# C. By SC/ST share
cat("\nBy SC/ST share tercile:\n")
for (st in levels(panel$scst_tercile)) {
  sub <- panel[scst_tercile == st]
  if (nrow(sub) > 100) {
    m <- feols(log_light ~ treated | dist_id_11 + year,
               data = sub, cluster = ~pc01_state_id)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", st,
                coef(m)["treated"], se(m)["treated"]))
  }
}

# D. By baseline luminosity
cat("\nBy baseline luminosity tercile:\n")
for (lt in levels(panel$light_tercile)) {
  sub <- panel[light_tercile == lt]
  if (nrow(sub) > 100) {
    m <- feols(log_light ~ treated | dist_id_11 + year,
               data = sub, cluster = ~pc01_state_id)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", lt,
                coef(m)["treated"], se(m)["treated"]))
  }
}

# E. CS-DiD heterogeneity: by rainfall
cat("\nCS-DiD by rainfall tercile:\n")
het_rain <- list()
for (rt in levels(panel$rain_tercile)) {
  sub <- copy(panel[rain_tercile == rt & dist_id_11 %in% balanced_dists])
  sub[, id := as.integer(as.factor(dist_id_11))]
  tryCatch({
    cs_sub <- att_gt(
      yname = "log_light", tname = "year", idname = "id",
      gname = "first_treat", data = as.data.frame(sub),
      control_group = "notyettreated", anticipation = 0,
      est_method = "dr", base_period = "universal",
      clustervars = "id", print_details = FALSE
    )
    agg <- aggte(cs_sub, type = "simple")
    het_rain[[rt]] <- list(att = agg$overall.att, se = agg$overall.se)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", rt,
                agg$overall.att, agg$overall.se))
  }, error = function(e) {
    cat(sprintf("  %s: CS-DiD failed — %s\n", rt, e$message))
  })
}

# F. CS-DiD heterogeneity: by ag labor share
cat("\nCS-DiD by agricultural labor share tercile:\n")
het_ag <- list()
for (at in levels(panel$ag_labor_tercile)) {
  sub <- copy(panel[ag_labor_tercile == at & dist_id_11 %in% balanced_dists])
  sub[, id := as.integer(as.factor(dist_id_11))]
  tryCatch({
    cs_sub <- att_gt(
      yname = "log_light", tname = "year", idname = "id",
      gname = "first_treat", data = as.data.frame(sub),
      control_group = "notyettreated", anticipation = 0,
      est_method = "dr", base_period = "universal",
      clustervars = "id", print_details = FALSE
    )
    agg <- aggte(cs_sub, type = "simple")
    het_ag[[at]] <- list(att = agg$overall.att, se = agg$overall.se)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", at,
                agg$overall.att, agg$overall.se))
  }, error = function(e) {
    cat(sprintf("  %s: CS-DiD failed — %s\n", at, e$message))
  })
}

# G. CS-DiD heterogeneity: by SC/ST share
cat("\nCS-DiD by SC/ST share tercile:\n")
het_scst <- list()
for (st in levels(panel$scst_tercile)) {
  sub <- copy(panel[scst_tercile == st & dist_id_11 %in% balanced_dists])
  sub[, id := as.integer(as.factor(dist_id_11))]
  tryCatch({
    cs_sub <- att_gt(
      yname = "log_light", tname = "year", idname = "id",
      gname = "first_treat", data = as.data.frame(sub),
      control_group = "notyettreated", anticipation = 0,
      est_method = "dr", base_period = "universal",
      clustervars = "id", print_details = FALSE
    )
    agg <- aggte(cs_sub, type = "simple")
    het_scst[[st]] <- list(att = agg$overall.att, se = agg$overall.se)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", st,
                agg$overall.att, agg$overall.se))
  }, error = function(e) {
    cat(sprintf("  %s: CS-DiD failed — %s\n", st, e$message))
  })
}

# H. CS-DiD heterogeneity: by baseline light
cat("\nCS-DiD by baseline light tercile:\n")
het_light <- list()
for (lt in levels(panel$light_tercile)) {
  sub <- copy(panel[light_tercile == lt & dist_id_11 %in% balanced_dists])
  sub[, id := as.integer(as.factor(dist_id_11))]
  tryCatch({
    cs_sub <- att_gt(
      yname = "log_light", tname = "year", idname = "id",
      gname = "first_treat", data = as.data.frame(sub),
      control_group = "notyettreated", anticipation = 0,
      est_method = "dr", base_period = "universal",
      clustervars = "id", print_details = FALSE
    )
    agg <- aggte(cs_sub, type = "simple")
    het_light[[lt]] <- list(att = agg$overall.att, se = agg$overall.se)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", lt,
                agg$overall.att, agg$overall.se))
  }, error = function(e) {
    cat(sprintf("  %s: CS-DiD failed — %s\n", lt, e$message))
  })
}

saveRDS(list(rain = het_rain, ag = het_ag, scst = het_scst, light = het_light),
        file.path(data_dir, "heterogeneity_results.rds"))

# ==============================================================================
# 6. Census mechanism analysis (2001→2011 structural change)
# ==============================================================================
cat("\n=== Census Mechanism Analysis ===\n")

census <- readRDS(file.path(data_dir, "census_change.rds"))

# Cross-sectional: Phase I vs Phase III
# Phase I treated 2 years earlier → more exposure
# Outcome: structural transformation (decline in ag labor, rise in non-farm)

# Worker composition changes
cat("Worker composition by phase:\n")
print(census[, .(
  d_ag_labor = mean(d_ag_labor_share, na.rm = TRUE),
  d_cult = mean(d_cult_share, na.rm = TRUE),
  pop_growth = mean(pop_growth, na.rm = TRUE),
  female_lfpr = mean(female_lfpr_11, na.rm = TRUE),
  N = .N
), by = mgnrega_phase][order(mgnrega_phase)])

# Regression: phase assignment → structural change
# Using backwardness_index as running variable (fuzzy assignment)
mech1 <- feols(d_ag_labor_share ~ i(mgnrega_phase, ref = 3) + backwardness_index,
               data = census, cluster = ~pc01_state_id)
cat("\nAg labor share change by phase:\n")
summary(mech1)

mech2 <- feols(pop_growth ~ i(mgnrega_phase, ref = 3) + backwardness_index,
               data = census, cluster = ~pc01_state_id)
cat("\nPopulation growth by phase:\n")
summary(mech2)

mech3 <- feols(female_lfpr_11 ~ i(mgnrega_phase, ref = 3) + backwardness_index +
                 lit_rate + sc_st_share,
               data = census, cluster = ~pc01_state_id)
cat("\nFemale LFPR by phase:\n")
summary(mech3)

saveRDS(list(mech1 = mech1, mech2 = mech2, mech3 = mech3),
        file.path(data_dir, "mechanism_results.rds"))

cat("\n=== Main Analysis Complete ===\n")
