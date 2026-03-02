## ============================================================
## 03_main_analysis.R — Primary regressions (TWFE + CS-DiD)
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

# ── Load panel ────────────────────────────────────────────────
panel <- fread(file.path(BASE_DIR, "data", "district_panel.csv"))
panel[, dist_id := as.factor(dist_id)]

cat("Panel loaded:", nrow(panel), "obs,", uniqueN(panel$dist_id), "districts\n")

# ══════════════════════════════════════════════════════════════
# 1. TWFE SPECIFICATIONS
# ══════════════════════════════════════════════════════════════

cat("\n=== TWFE Regressions ===\n")

# Model 1: Binary treatment, log nightlights
m1 <- feols(log_nl ~ post_odf | dist_id + year,
            data = panel, cluster = ~pc11_state_id)

# Model 2: Exposure-weighted treatment
m2 <- feols(log_nl ~ treat_weighted | dist_id + year,
            data = panel, cluster = ~pc11_state_id)

# Model 3: Rural-only nightlights
m3 <- feols(log_nl_rural ~ post_odf | dist_id + year,
            data = panel, cluster = ~pc11_state_id)

# Model 4: Per-capita nightlights
m4 <- feols(log_nl_pc ~ post_odf | dist_id + year,
            data = panel, cluster = ~pc11_state_id)

# Model 5: Binary treatment with state-specific trends
m5 <- feols(log_nl ~ post_odf | dist_id + year + pc11_state_id[year],
            data = panel, cluster = ~pc11_state_id)

cat("\nModel 1 (Binary, all districts):\n")
print(summary(m1))
cat("\nModel 2 (Exposure-weighted):\n")
print(summary(m2))
cat("\nModel 3 (Rural-only NL):\n")
print(summary(m3))

# Save TWFE results
twfe_results <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5)
saveRDS(twfe_results, file.path(BASE_DIR, "data", "twfe_results.rds"))

# ══════════════════════════════════════════════════════════════
# 2. TWFE EVENT STUDY
# ══════════════════════════════════════════════════════════════

cat("\n=== TWFE Event Study ===\n")

# Create event-time dummies (bin endpoints at -5 and +5)
panel[, rel_time_binned := pmin(pmax(rel_time, -5L), 5L)]

# Event study with relative time indicators (omit -1)
es_twfe <- feols(log_nl ~ i(rel_time_binned, ref = -1) | dist_id + year,
                  data = panel, cluster = ~pc11_state_id)

cat("TWFE Event Study:\n")
print(summary(es_twfe))

saveRDS(es_twfe, file.path(BASE_DIR, "data", "es_twfe.rds"))

# ══════════════════════════════════════════════════════════════
# 3. CALLAWAY-SANT'ANNA (2021) HETEROGENEITY-ROBUST DiD
# ══════════════════════════════════════════════════════════════

cat("\n=== Callaway-Sant'Anna DiD ===\n")

# Prepare data for did package
# Need: yname, tname, idname, gname
cs_data <- copy(panel)
cs_data[, dist_num := as.integer(as.factor(dist_id))]

# CS-DiD requires cohort = 0 for never-treated
# All states eventually treated, so use "not-yet-treated" as comparison
# Set cohort for all (they all get treated eventually)
cat("Cohort distribution:\n")
print(table(cs_data[year == 2012, cohort]))

# Run CS-DiD
cs_out <- tryCatch({
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "dist_num",
    gname = "cohort",
    data = as.data.frame(cs_data),
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "dr",
    clustervars = "pc11_state_id",
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS-DiD error:", conditionMessage(e), "\n")
  cat("Falling back to simpler specification...\n")
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "dist_num",
    gname = "cohort",
    data = as.data.frame(cs_data),
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "reg",
    base_period = "universal"
  )
})

cat("\nCS-DiD Group-Time ATTs:\n")
print(summary(cs_out))

# Aggregate to event study
cs_es <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
cat("\nCS-DiD Event Study Aggregation:\n")
print(summary(cs_es))

# Aggregate to simple ATT
cs_att <- aggte(cs_out, type = "simple")
cat("\nCS-DiD Simple ATT:\n")
print(summary(cs_att))

# Aggregate by cohort
cs_cohort <- aggte(cs_out, type = "group")
cat("\nCS-DiD ATT by Cohort:\n")
print(summary(cs_cohort))

# Save CS-DiD results
saveRDS(cs_out, file.path(BASE_DIR, "data", "cs_did_out.rds"))
saveRDS(cs_es, file.path(BASE_DIR, "data", "cs_es.rds"))
saveRDS(cs_att, file.path(BASE_DIR, "data", "cs_att.rds"))
saveRDS(cs_cohort, file.path(BASE_DIR, "data", "cs_cohort.rds"))

# ══════════════════════════════════════════════════════════════
# 4. SUMMARY OF MAIN RESULTS
# ══════════════════════════════════════════════════════════════

cat("\n\n========================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("========================================\n")
cat("TWFE (binary):       coef =", round(coef(m1), 4),
    "  SE =", round(se(m1), 4), "\n")
cat("TWFE (weighted):     coef =", round(coef(m2), 4),
    "  SE =", round(se(m2), 4), "\n")
cat("TWFE (rural NL):     coef =", round(coef(m3), 4),
    "  SE =", round(se(m3), 4), "\n")
cat("CS-DiD (simple ATT): coef =", round(cs_att$overall.att, 4),
    "  SE =", round(cs_att$overall.se, 4), "\n")
cat("========================================\n")
