## 04_robustness.R — Robustness checks for apep_0471

source("00_packages.R")

data_dir <- "../data"
panel <- read_parquet(file.path(data_dir, "monthly_panel.parquet"))
annual <- read_parquet(file.path(data_dir, "annual_panel.parquet"))

la_ids <- panel %>% distinct(la_code) %>% mutate(la_id = row_number())
panel <- panel %>% left_join(la_ids, by = "la_code")
annual <- annual %>% left_join(la_ids, by = "la_code")

# ============================================================
# 1. PLACEBO TEST: Public Administration (SIC Section O)
# ============================================================
cat("=== Placebo: Public admin formations ===\n")
# Public admin firms should NOT respond to UC - no self-employment channel

twfe_placebo <- feols(
  public_admin_rate ~ treated | as.factor(la_id) + period,
  data = panel,
  cluster = ~la_code
)
cat("Placebo (public admin):\n")
summary(twfe_placebo)

saveRDS(twfe_placebo, file.path(data_dir, "robustness_placebo_pubadmin.rds"))

# ============================================================
# 2. PLACEBO: High-income LAs (low benefit dependency)
# ============================================================
cat("\n=== Placebo: Low-formation areas ===\n")
# LAs in top quartile of pre-treatment formation rate (high-baseline areas)
# — these are less dependent on benefits, so UC should matter less

pre_formation <- panel %>%
  filter(inc_ym < ymd("2016-01-01")) %>%
  group_by(la_code) %>%
  summarise(mean_rate = mean(formation_rate, na.rm = TRUE), .groups = "drop")

q75 <- quantile(pre_formation$mean_rate, 0.75, na.rm = TRUE)

high_formation_las <- pre_formation %>%
  filter(mean_rate >= q75) %>%
  pull(la_code)

cat(sprintf("High-formation LAs (top quartile, n=%d)\n", length(high_formation_las)))

twfe_highinc <- feols(
  formation_rate ~ treated | as.factor(la_id) + period,
  data = panel %>% filter(la_code %in% high_formation_las),
  cluster = ~la_code
)
cat("Placebo (high-formation LAs, top quartile):\n")
summary(twfe_highinc)

saveRDS(twfe_highinc, file.path(data_dir, "robustness_placebo_highinc.rds"))

# ============================================================
# 3. ALTERNATIVE ESTIMATOR: de Chaisemartin & d'Haultfoeuille
# ============================================================
cat("\n=== Bacon Decomposition ===\n")

# Bacon decomposition to diagnose TWFE bias
annual_bacon <- annual %>%
  filter(!is.na(annual_formation_rate), first_treat_year > 0 | first_treat_year == 0) %>%
  mutate(
    treat_indicator = as.numeric(treated_year),
    la_id_num = as.numeric(as.factor(la_code))
  )

tryCatch({
  bacon_out <- bacon(
    annual_formation_rate ~ treat_indicator,
    data = annual_bacon,
    id_var = "la_id_num",
    time_var = "year"
  )
  cat("Bacon decomposition:\n")
  print(summary(bacon_out))
  saveRDS(bacon_out, file.path(data_dir, "bacon_decomp.rds"))
}, error = function(e) {
  cat("Bacon decomposition failed:", conditionMessage(e), "\n")
})

# ============================================================
# 4. HETEROGENEITY: By baseline benefit dependency
# ============================================================
cat("\n=== Heterogeneity: By baseline formation rate ===\n")

pre_baseline <- panel %>%
  filter(inc_ym < ymd("2016-01-01")) %>%
  group_by(la_code) %>%
  summarise(pre_rate = mean(formation_rate, na.rm = TRUE), .groups = "drop")

panel_het <- panel %>%
  left_join(pre_baseline, by = "la_code") %>%
  mutate(
    high_unemp = pre_rate <= median(pre_rate, na.rm = TRUE),  # Low-formation = proxy for disadvantaged
    treated_x_highunemp = treated * high_unemp
  )

het_unemp <- feols(
  formation_rate ~ treated + treated_x_highunemp | as.factor(la_id) + period,
  data = panel_het,
  cluster = ~la_code
)
cat("Heterogeneity by baseline unemployment:\n")
summary(het_unemp)

saveRDS(het_unemp, file.path(data_dir, "robustness_het_unemp.rds"))

# ============================================================
# 5. HETEROGENEITY: By sector (self-employment-intensive)
# ============================================================
cat("\n=== Heterogeneity: Construction vs Professional ===\n")

twfe_construction <- feols(
  construction_rate ~ treated | as.factor(la_id) + period,
  data = panel,
  cluster = ~la_code
)
cat("Construction sector:\n")
summary(twfe_construction)

twfe_professional <- feols(
  professional_rate ~ treated | as.factor(la_id) + period,
  data = panel,
  cluster = ~la_code
)
cat("Professional services sector:\n")
summary(twfe_professional)

saveRDS(twfe_construction, file.path(data_dir, "robustness_construction.rds"))
saveRDS(twfe_professional, file.path(data_dir, "robustness_professional.rds"))

# ============================================================
# 6. SENSITIVITY: Wild cluster bootstrap
# ============================================================
cat("\n=== Wild cluster bootstrap ===\n")

tryCatch({
  library(fwildclusterboot)

  twfe_main <- feols(
    formation_rate ~ treated | as.factor(la_id) + period,
    data = panel,
    cluster = ~la_code
  )

  set.seed(20240271)  # Fixed seed for reproducibility
  boot_out <- boottest(
    twfe_main,
    param = "treated",
    clustid = "la_code",
    B = 999,
    type = "webb"
  )

  cat("Wild cluster bootstrap p-value:\n")
  print(boot_out)

  saveRDS(boot_out, file.path(data_dir, "robustness_wcb.rds"))
}, error = function(e) {
  cat("Wild cluster bootstrap failed:", conditionMessage(e), "\n")
  cat("Falling back to CR2 small-sample correction...\n")

  library(clubSandwich)
  twfe_main <- feols(
    formation_rate ~ treated | as.factor(la_id) + period,
    data = panel,
    cluster = ~la_code
  )
  cr2_se <- coef_test(twfe_main, vcov = "CR2", cluster = panel$la_code)
  cat("CR2 small-sample corrected SEs:\n")
  print(cr2_se)
})

# ============================================================
# 7. SENSITIVITY: Exclude early adopters (pilot areas)
# ============================================================
cat("\n=== Sensitivity: Exclude pilot LAs (treated before 2017) ===\n")

panel_nopilot <- panel %>%
  filter(is.na(first_treat_date) | first_treat_date >= ymd("2017-01-01"))

twfe_nopilot <- feols(
  formation_rate ~ treated | as.factor(la_id) + period,
  data = panel_nopilot,
  cluster = ~la_code
)
cat("Excluding pilot areas (treated pre-2017):\n")
summary(twfe_nopilot)

saveRDS(twfe_nopilot, file.path(data_dir, "robustness_nopilot.rds"))

# ============================================================
# 8. PRE-TREND TEST: Joint F-test
# ============================================================
cat("\n=== Pre-trend test ===\n")

# Load CS dynamic results
agg_dynamic <- readRDS(file.path(data_dir, "cs_att_dynamic.rds"))

# Pre-treatment effects
pre_effects <- data.frame(
  e = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt
) %>%
  filter(e < 0)

if (nrow(pre_effects) > 0) {
  # Joint test: H0: all pre-treatment effects = 0
  chi2 <- sum((pre_effects$att / pre_effects$se)^2)
  df <- nrow(pre_effects)
  p_value <- pchisq(chi2, df, lower.tail = FALSE)

  cat(sprintf("Pre-trend joint test: chi2(%d) = %.2f, p = %.4f\n", df, chi2, p_value))

  pretrend_test <- list(chi2 = chi2, df = df, p_value = p_value)
  saveRDS(pretrend_test, file.path(data_dir, "pretrend_test.rds"))
}

cat("\n=== Robustness checks complete ===\n")
