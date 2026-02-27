## 03_main_analysis.R — Primary DiD estimation for apep_0471
## Callaway & Sant'Anna staggered DiD

source("00_packages.R")

data_dir <- "../data"

cat("=== Loading panel data ===\n")
panel <- read_parquet(file.path(data_dir, "monthly_panel.parquet"))
annual <- read_parquet(file.path(data_dir, "annual_panel.parquet"))

cat(sprintf("Monthly: %s obs | Annual: %s obs\n",
            comma(nrow(panel)), comma(nrow(annual))))

# Create numeric LA id for did package
la_ids <- panel %>%
  distinct(la_code) %>%
  mutate(la_id = row_number())

panel <- panel %>% left_join(la_ids, by = "la_code")
annual <- annual %>% left_join(la_ids, by = "la_code")

# ============================================================
# SECTION A: Callaway & Sant'Anna — Monthly Panel
# ============================================================
cat("\n=== CS-DiD: Monthly firm formation rate ===\n")

# Quarterly aggregation for computational feasibility
# (monthly with 300+ LAs is very demanding)
quarterly <- panel %>%
  mutate(quarter = floor_date(inc_ym, "quarter")) %>%
  group_by(la_id, la_code, la_name_geo, quarter, first_treat_period) %>%
  summarise(
    formation_rate = sum(n_formations) / first(pop_wa) * 1000 / 3, # Monthly avg
    plt_rate = sum(n_private_ltd) / first(pop_wa) * 1000 / 3,
    construction_rate = sum(n_construction) / first(pop_wa) * 1000 / 3,
    professional_rate = sum(n_professional) / first(pop_wa) * 1000 / 3,
    public_admin_rate = sum(n_public_admin) / first(pop_wa) * 1000 / 3,
    .groups = "drop"
  ) %>%
  mutate(
    qtr_num = as.numeric(difftime(quarter, ymd("2013-01-01"), units = "days")) / 91.31,
    qtr_num = round(qtr_num),
    first_treat_qtr = round(first_treat_period / 3)
  )

# Never-treated LAs: set first_treat to 0 (did package convention)
quarterly <- quarterly %>%
  mutate(first_treat_qtr = ifelse(first_treat_qtr == 0, 0, first_treat_qtr))

cat(sprintf("Quarterly panel: %s obs, %d LAs, %d quarters\n",
            comma(nrow(quarterly)), n_distinct(quarterly$la_id), n_distinct(quarterly$qtr_num)))
cat(sprintf("Treatment cohorts: %d\n",
            n_distinct(quarterly$first_treat_qtr[quarterly$first_treat_qtr > 0])))

# Main CS-DiD estimation
cat("\nRunning Callaway-Sant'Anna estimation...\n")
cs_out <- att_gt(
  yname = "formation_rate",
  tname = "qtr_num",
  idname = "la_id",
  gname = "first_treat_qtr",
  data = as.data.frame(quarterly),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  base_period = "universal"
)

cat("CS-DiD estimation complete.\n")

# Overall ATT
cat("\n--- Overall ATT ---\n")
agg_overall <- aggte(cs_out, type = "simple")
summary(agg_overall)

# Dynamic effects (event study)
cat("\n--- Dynamic ATT (Event Study) ---\n")
agg_dynamic <- aggte(cs_out, type = "dynamic", min_e = -8, max_e = 8)
summary(agg_dynamic)

# Save CS results
saveRDS(cs_out, file.path(data_dir, "cs_did_main.rds"))
saveRDS(agg_overall, file.path(data_dir, "cs_att_overall.rds"))
saveRDS(agg_dynamic, file.path(data_dir, "cs_att_dynamic.rds"))

# ============================================================
# SECTION B: TWFE as Benchmark (with Sun-Abraham correction)
# ============================================================
cat("\n=== TWFE Benchmark ===\n")

# Standard TWFE (biased under heterogeneous effects)
twfe_naive <- feols(
  formation_rate ~ treated | la_id + period,
  data = panel %>% mutate(la_id = as.factor(la_id)),
  cluster = ~la_code
)

cat("TWFE (naive):\n")
summary(twfe_naive)

# Sun-Abraham interaction-weighted estimator
cat("\n=== Sun-Abraham Event Study ===\n")
panel_sa <- panel %>%
  filter(!is.na(first_treat_period) | first_treat_period == 0) %>%
  mutate(
    cohort = ifelse(first_treat_period == 0, Inf, first_treat_period),
    la_id_fct = as.factor(la_id)
  )

sa_out <- feols(
  formation_rate ~ sunab(cohort, period) | la_id_fct + period,
  data = panel_sa,
  cluster = ~la_code
)

cat("Sun-Abraham event study:\n")
summary(sa_out)

saveRDS(sa_out, file.path(data_dir, "sunab_main.rds"))

# ============================================================
# SECTION C: Annual Panel — Self-Employment Rate (NOMIS)
# ============================================================
cat("\n=== Annual panel: Self-employment rate ===\n")

annual_sa <- annual %>%
  filter(!is.na(self_emp_rate)) %>%
  mutate(
    la_id_fct = as.factor(la_id),
    first_treat_yr = ifelse(first_treat_year == 0, Inf, first_treat_year)
  )

cat(sprintf("Annual panel with self-employment: %s obs, %d LAs\n",
            comma(nrow(annual_sa)), n_distinct(annual_sa$la_id)))

if (nrow(annual_sa) > 100) {
  # TWFE
  twfe_se <- feols(
    self_emp_rate ~ treated_year | la_id_fct + year,
    data = annual_sa,
    cluster = ~la_code
  )
  cat("TWFE — Self-employment rate:\n")
  summary(twfe_se)

  # Sun-Abraham
  sa_se <- feols(
    self_emp_rate ~ sunab(first_treat_yr, year) | la_id_fct + year,
    data = annual_sa,
    cluster = ~la_code
  )
  cat("Sun-Abraham — Self-employment rate:\n")
  summary(sa_se)

  saveRDS(twfe_se, file.path(data_dir, "twfe_selfempl.rds"))
  saveRDS(sa_se, file.path(data_dir, "sunab_selfempl.rds"))
} else {
  cat("SKIPPING self-employment analysis: insufficient NOMIS data available.\n")
  cat("NOMIS APS data may require NOMIS_API_KEY for full download.\n")
}

# ============================================================
# SECTION D: MIF Timing Test
# ============================================================
cat("\n=== MIF Timing Test: 0-12 months vs 12+ months ===\n")

# The Minimum Income Floor binds after 12 months of self-employment start-up period
# If MIF matters, we should see effects differ before and after 12 months post-treatment
panel_mif <- panel %>%
  filter(!is.na(first_treat_date)) %>%
  mutate(
    la_id_fct = as.factor(la_id),
    # Phase of treatment
    phase = case_when(
      rel_time < 0 ~ "pre",
      rel_time >= 0 & rel_time < 12 ~ "startup_period",  # MIF not yet binding
      rel_time >= 12 ~ "mif_binding",  # MIF applies
      TRUE ~ NA_character_
    ),
    startup = as.numeric(phase == "startup_period"),
    mif = as.numeric(phase == "mif_binding")
  )

mif_test <- feols(
  formation_rate ~ startup + mif | la_id_fct + period,
  data = panel_mif,
  cluster = ~la_code
)

cat("MIF timing test (0-12m vs 12+m post-treatment):\n")
summary(mif_test)

saveRDS(mif_test, file.path(data_dir, "mif_timing.rds"))

cat("\n=== Main analysis complete ===\n")
cat("Results saved to", data_dir, "\n")
