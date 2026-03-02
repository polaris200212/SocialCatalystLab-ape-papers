###############################################################################
# 03_main_analysis.R — Main DiD estimation
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

cat("=== Loading analysis panel ===\n")
panel <- read_csv(file.path(DATA_DIR, "analysis_panel.csv"), show_col_types = FALSE)

# Fix known bad fuzzy matches — set them to 2018 (final wave, conservative)
bad_matches <- c("county durham", "stockton-on-tees", "newcastle upon tyne",
                 "york", "bradford", "lincoln", "wellingborough",
                 "stratford-on-avon", "east hertfordshire", "westminster",
                 "greenwich", "kingston upon thames", "folkestone and hythe",
                 "cardiff")

panel <- panel %>%
  mutate(
    # These LAs were matched to wrong LAs by fuzzy matching
    # Assign to 2018 (all LAs were on UC by Dec 2018)
    first_treat = if_else(la_name_clean %in% bad_matches & first_treat != 2018,
                          2018L, first_treat),
    first_treat = if_else(first_treat == 0, 2018L, first_treat),
    treated = if_else(year >= first_treat, 1L, 0L)
  )

cat("Panel:", nrow(panel), "obs,", n_distinct(panel$la_code), "LAs\n")
cat("Treatment cohorts:\n")
print(panel %>% distinct(la_code, first_treat) %>% count(first_treat))

# Save corrected panel
write_csv(panel, file.path(DATA_DIR, "analysis_panel.csv"))

###############################################################################
# 1. TWFE Baseline (for comparison)
###############################################################################

cat("\n=== TWFE Estimation ===\n")

# Naive TWFE
twfe_se <- feols(se_share ~ treated | la_code + year, data = panel,
                 cluster = ~la_code)
cat("\n--- TWFE: Self-employment share ---\n")
summary(twfe_se)

twfe_emp <- feols(emp_rate ~ treated | la_code + year, data = panel,
                  cluster = ~la_code)
cat("\n--- TWFE: Employment rate ---\n")
summary(twfe_emp)

# TWFE event study (for pre-trend visualization)
panel <- panel %>%
  mutate(
    rel_year = year - first_treat,
    rel_year_factor = factor(rel_year)
  )

# Sun-Abraham event study via fixest
cat("\n--- Sun-Abraham Event Study ---\n")
sa_se <- feols(se_share ~ sunab(first_treat, year) | la_code + year,
               data = panel, cluster = ~la_code)
summary(sa_se)

sa_emp <- feols(emp_rate ~ sunab(first_treat, year) | la_code + year,
                data = panel, cluster = ~la_code)
summary(sa_emp)

###############################################################################
# 2. Callaway-Sant'Anna Estimation
###############################################################################

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# Set seed for reproducible bootstrap standard errors
set.seed(20240473)

# Prepare data for CS estimator
# CS requires: outcome, time, id, group (first_treat year)
# All LAs are eventually treated (by 2018), so use "notyettreated" control group

cs_se <- att_gt(
  yname = "se_share",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel,
  control_group = "notyettreated",
  est_method = "dr",  # doubly robust
  base_period = "universal"
)

cat("\n--- CS ATT(g,t): Self-employment share ---\n")
summary(cs_se)

# Aggregate to overall ATT
cs_se_agg <- aggte(cs_se, type = "simple")
cat("\n--- CS Overall ATT: Self-employment share ---\n")
summary(cs_se_agg)

# Dynamic (event study) aggregation
cs_se_dynamic <- aggte(cs_se, type = "dynamic", min_e = -5, max_e = 3)
cat("\n--- CS Dynamic: Self-employment share ---\n")
summary(cs_se_dynamic)

# Group-specific ATT
cs_se_group <- aggte(cs_se, type = "group")
cat("\n--- CS Group ATT: Self-employment share ---\n")
summary(cs_se_group)

# Employment rate
cs_emp <- att_gt(
  yname = "emp_rate",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_emp_agg <- aggte(cs_emp, type = "simple")
cat("\n--- CS Overall ATT: Employment rate ---\n")
summary(cs_emp_agg)

cs_emp_dynamic <- aggte(cs_emp, type = "dynamic", min_e = -5, max_e = 3)
cat("\n--- CS Dynamic: Employment rate ---\n")
summary(cs_emp_dynamic)

# Economic activity rate
cs_econ_active <- att_gt(
  yname = "econ_active_rate",
  tname = "year",
  idname = "la_id",
  gname = "first_treat",
  data = panel,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_econ_active_agg <- aggte(cs_econ_active, type = "simple")
cat("\n--- CS Overall ATT: Economic activity rate ---\n")
summary(cs_econ_active_agg)

###############################################################################
# 3. Save results
###############################################################################

cat("\n=== Saving results ===\n")

# Save key estimates
results <- tibble(
  outcome = c("Self-employment share", "Employment rate", "Economic activity rate"),
  twfe_coef = c(coef(twfe_se)["treated"], coef(twfe_emp)["treated"], NA),
  twfe_se = c(se(twfe_se)["treated"], se(twfe_emp)["treated"], NA),
  cs_att = c(cs_se_agg$overall.att, cs_emp_agg$overall.att, cs_econ_active_agg$overall.att),
  cs_se = c(cs_se_agg$overall.se, cs_emp_agg$overall.se, cs_econ_active_agg$overall.se)
)

cat("\n========================================\n")
cat("MAIN RESULTS SUMMARY\n")
cat("========================================\n")
print(results)
cat("========================================\n")

write_csv(results, file.path(TAB_DIR, "main_results.csv"))

# Save CS objects for figures
saveRDS(cs_se, file.path(DATA_DIR, "cs_se_share.rds"))
saveRDS(cs_emp, file.path(DATA_DIR, "cs_emp_rate.rds"))
saveRDS(cs_econ_active, file.path(DATA_DIR, "cs_econ_active_rate.rds"))
# Save aggregated objects (frozen SE from single bootstrap run)
saveRDS(cs_se_agg, file.path(DATA_DIR, "cs_se_share_agg.rds"))
saveRDS(cs_emp_agg, file.path(DATA_DIR, "cs_emp_rate_agg.rds"))
saveRDS(cs_econ_active_agg, file.path(DATA_DIR, "cs_econ_active_rate_agg.rds"))
# Save group-specific ATTs
cs_se_group <- aggte(cs_se, type = "group")
saveRDS(cs_se_group, file.path(DATA_DIR, "cs_se_share_group.rds"))
saveRDS(cs_se_dynamic, file.path(DATA_DIR, "cs_se_dynamic.rds"))
saveRDS(cs_emp_dynamic, file.path(DATA_DIR, "cs_emp_dynamic.rds"))
saveRDS(sa_se, file.path(DATA_DIR, "sa_se.rds"))
saveRDS(sa_emp, file.path(DATA_DIR, "sa_emp.rds"))

cat("\nAll results saved.\n")
