##############################################################################
# 03_main_analysis.R — DiD, Event Study, RDD
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")

panel <- read_csv(file.path(data_dir, "analysis_panel.csv"), show_col_types = FALSE)
cat("Panel loaded:", nrow(panel), "rows\n")
cat("Municipalities:", n_distinct(panel$gem_no), "\n")
cat("Years:", paste(sort(unique(panel$year)), collapse = ", "), "\n")
cat("Treated:", sum(panel$treated == 1 & panel$year == min(panel$year)), "\n")
cat("Control:", sum(panel$treated == 0 & panel$year == min(panel$year)), "\n")

# ══════════════════════════════════════════════════════════════════════════════
# 1. BASELINE DiD: TWFE
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== TWFE Difference-in-Differences ===\n")

# Primary: log total employment
m1 <- feols(log_emp_total ~ treat_post | gem_no + year, data = panel,
            cluster = ~gem_no)
cat("\n--- Total Employment ---\n")
summary(m1)

# Tertiary sector (services, includes tourism)
m2 <- feols(log_emp_tertiary ~ treat_post | gem_no + year, data = panel,
            cluster = ~gem_no)
cat("\n--- Tertiary Employment ---\n")
summary(m2)

# Secondary sector (construction)
m3 <- feols(log_emp_secondary ~ treat_post | gem_no + year, data = panel,
            cluster = ~gem_no)
cat("\n--- Secondary Employment ---\n")
summary(m3)

# New construction
m4 <- feols(log_new_dwellings ~ treat_post | gem_no + year, data = panel,
            cluster = ~gem_no)
cat("\n--- New Dwelling Construction ---\n")
summary(m4)

# Store for tables
main_models <- list(
  total = m1, tertiary = m2, secondary = m3, construction = m4
)

# ══════════════════════════════════════════════════════════════════════════════
# 2. EVENT STUDY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Event Study ===\n")

# Create relative time indicators
# Treatment onset: 2016 (first year Lex Weber building restrictions fully operational)
# March 2012: initiative passes
# Jan 2016: implementing ordinance takes effect
panel <- panel %>%
  mutate(
    rel_year = year - 2016,
    rel_year_factor = factor(rel_year)
  )

# Drop the omitted category (t = -1)
panel$rel_year_factor <- relevel(panel$rel_year_factor, ref = "-1")

# Event study: total employment
es1 <- feols(log_emp_total ~ i(rel_year, treated, ref = -1) | gem_no + year,
             data = panel, cluster = ~gem_no)
cat("\n--- Event Study: Total Employment ---\n")
summary(es1)

# Event study: tertiary employment
es2 <- feols(log_emp_tertiary ~ i(rel_year, treated, ref = -1) | gem_no + year,
             data = panel, cluster = ~gem_no)
cat("\n--- Event Study: Tertiary Employment ---\n")
summary(es2)

# Event study: construction
es3 <- feols(log_new_dwellings ~ i(rel_year, treated, ref = -1) | gem_no + year,
             data = panel, cluster = ~gem_no)
cat("\n--- Event Study: New Dwellings ---\n")
summary(es3)

es_models <- list(total = es1, tertiary = es2, construction = es3)

# ══════════════════════════════════════════════════════════════════════════════
# 3. CALLAWAY-SANT'ANNA (robust to heterogeneous treatment timing)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Callaway-Sant'Anna DiD ===\n")

# For CS, define treatment cohort: all treated municipalities start in 2016
# Never-treated municipalities get cohort = 0
panel_cs <- panel %>%
  mutate(
    cohort = ifelse(treated == 1, 2016, 0)
  )

cs_att <- tryCatch({
  att_gt(
    yname = "log_emp_total",
    tname = "year",
    idname = "gem_no",
    gname = "cohort",
    data = as.data.frame(panel_cs),
    control_group = "nevertreated",
    est_method = "dr",
    clustervars = "gem_no"
  )
}, error = function(e) {
  cat("CS estimation error:", e$message, "\n")
  NULL
})

if (!is.null(cs_att)) {
  cat("\n--- CS Group-Time ATT ---\n")
  summary(cs_att)

  # Aggregate to simple ATT
  cs_agg <- aggte(cs_att, type = "simple")
  cat("\n--- CS Aggregate ATT ---\n")
  summary(cs_agg)

  # Aggregate to event study
  cs_es <- aggte(cs_att, type = "dynamic")
  cat("\n--- CS Event Study ---\n")
  summary(cs_es)
}

# ══════════════════════════════════════════════════════════════════════════════
# 4. RDD AT THE 20% THRESHOLD
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== RDD at 20% Second Home Threshold ===\n")

# Running variable: second home share centered at 20%
panel <- panel %>%
  mutate(running = share_secondhome - 20)

# Post-treatment outcomes only
post_data <- panel %>%
  filter(post == 1) %>%
  group_by(gem_no) %>%
  summarise(
    mean_log_emp = mean(log_emp_total, na.rm = TRUE),
    mean_log_tertiary = mean(log_emp_tertiary, na.rm = TRUE),
    mean_log_construction = mean(log_new_dwellings, na.rm = TRUE),
    running = first(running),
    share_secondhome = first(share_secondhome),
    treated = first(treated),
    .groups = "drop"
  ) %>%
  filter(!is.na(running), is.finite(mean_log_emp))

# RDD: total employment
rdd1 <- tryCatch({
  rdrobust(y = post_data$mean_log_emp, x = post_data$running, c = 0)
}, error = function(e) {
  cat("RDD error:", e$message, "\n")
  NULL
})

if (!is.null(rdd1)) {
  cat("\n--- RDD: Total Employment ---\n")
  summary(rdd1)
}

# RDD: tertiary employment
rdd2 <- tryCatch({
  rdrobust(y = post_data$mean_log_tertiary, x = post_data$running, c = 0)
}, error = function(e) {
  cat("RDD error:", e$message, "\n")
  NULL
})

if (!is.null(rdd2)) {
  cat("\n--- RDD: Tertiary Employment ---\n")
  summary(rdd2)
}

# Density test at cutoff (McCrary test equivalent)
density_test <- tryCatch({
  rddensity(X = post_data$running, c = 0)
}, error = function(e) {
  cat("Density test error:", e$message, "\n")
  NULL
})

if (!is.null(density_test)) {
  cat("\n--- Density Test at Cutoff ---\n")
  summary(density_test)
}

# ══════════════════════════════════════════════════════════════════════════════
# 5. DOSE-RESPONSE (continuous treatment)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Dose-Response ===\n")

# Among treated municipalities, does higher second home share → larger effect?
panel <- panel %>%
  mutate(
    dose = pmax(share_secondhome - 20, 0),  # excess over threshold
    dose_post = dose * post
  )

dr1 <- feols(log_emp_total ~ dose_post | gem_no + year, data = panel,
             cluster = ~gem_no)
cat("\n--- Dose-Response: Total Employment ---\n")
summary(dr1)

dr2 <- feols(log_emp_tertiary ~ dose_post | gem_no + year, data = panel,
             cluster = ~gem_no)
cat("\n--- Dose-Response: Tertiary Employment ---\n")
summary(dr2)

dr3 <- feols(log_new_dwellings ~ dose_post | gem_no + year, data = panel,
             cluster = ~gem_no)
cat("\n--- Dose-Response: New Dwellings ---\n")
summary(dr3)

# ══════════════════════════════════════════════════════════════════════════════
# SAVE RESULTS
# ══════════════════════════════════════════════════════════════════════════════
save(main_models, es_models, cs_att, cs_agg, cs_es,
     rdd1, rdd2, density_test, dr1, dr2, dr3,
     panel, post_data,
     file = file.path(data_dir, "main_results.RData"))
cat("\nSaved main_results.RData\n")
