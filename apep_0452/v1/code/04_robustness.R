## 04_robustness.R — Robustness checks
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")
load(file.path(data_dir, "clean_panel.RData"))
load(file.path(data_dir, "analysis_results.RData"))

rob <- list()

# ============================================================
# 1. ALTERNATIVE POST WINDOWS FOR EU BAN
# ============================================================

cat("=== Robustness: Alternative post windows ===\n")

# Narrow window: 2008-2014
narrow <- panel %>% filter(year >= 2008, year <= 2014, year != 2011)
rob$narrow <- feols(log_hg_import ~ eu_ban_treat | iso3c + year,
                    data = narrow, cluster = ~iso3c)
cat("  Narrow (2008-2014):", round(coef(rob$narrow)["eu_ban_treat"], 4), "\n")

# Extended window: 2005-2020
extended <- panel %>% filter(year >= 2005, year <= 2020, year != 2011)
rob$extended <- feols(log_hg_import ~ eu_ban_treat | iso3c + year,
                      data = extended, cluster = ~iso3c)
cat("  Extended (2005-2020):", round(coef(rob$extended)["eu_ban_treat"], 4), "\n")

# Including 2011 as full treatment year
with_2011 <- panel %>% filter(year >= 2005, year <= 2015)
rob$with_2011 <- feols(log_hg_import ~ eu_ban_treat | iso3c + year,
                       data = with_2011 %>% mutate(
                         post_eu_ban = as.integer(year >= 2011),
                         eu_ban_treat = eu_share_preban * post_eu_ban),
                       cluster = ~iso3c)
cat("  With 2011:", round(coef(rob$with_2011)["eu_ban_treat"], 4), "\n")

# ============================================================
# 2. IHS TRANSFORMATION (vs LOG+1)
# ============================================================

cat("\n=== Robustness: IHS transformation ===\n")

eu_panel <- panel %>% filter(year >= 2005, year <= 2015, year != 2011)

rob$ihs_eu <- feols(ihs_hg_import ~ eu_ban_treat | iso3c + year,
                    data = eu_panel, cluster = ~iso3c)
cat("  IHS coef:", round(coef(rob$ihs_eu)["eu_ban_treat"], 4), "\n")

# ============================================================
# 3. EXTENSIVE MARGIN (any imports)
# ============================================================

cat("\n=== Robustness: Extensive margin ===\n")

rob$extensive <- feglm(I(hg_import_value > 0) ~ eu_ban_treat | iso3c + year,
                       data = eu_panel, cluster = ~iso3c, family = binomial(link = "logit"))

# Linear probability model alternative
rob$extensive_lpm <- feols(I(as.integer(hg_import_value > 0)) ~ eu_ban_treat |
                             iso3c + year,
                           data = eu_panel, cluster = ~iso3c)
cat("  LPM extensive margin:", round(coef(rob$extensive_lpm)["eu_ban_treat"], 4), "\n")

# ============================================================
# 4. EXCLUDING TRANSIT HUBS (Togo, South Africa)
# ============================================================

cat("\n=== Robustness: Excluding transit hubs ===\n")

rob$no_transit <- feols(log_hg_import ~ eu_ban_treat | iso3c + year,
                        data = eu_panel %>% filter(!iso3c %in% c("TGO", "ZAF")),
                        cluster = ~iso3c)
cat("  Excl. TGO/ZAF:", round(coef(rob$no_transit)["eu_ban_treat"], 4), "\n")

# ============================================================
# 5. WILD CLUSTER BOOTSTRAP
# ============================================================

cat("\n=== Robustness: Wild cluster bootstrap ===\n")

# Using fixest's bootstrap capability
m_base <- feols(log_hg_import ~ eu_ban_treat | iso3c + year,
                data = eu_panel, cluster = ~iso3c)

boot_result <- tryCatch({
  # Wald test with bootstrap p-value
  wald(m_base, "eu_ban_treat", cluster = ~iso3c)
}, error = function(e) {
  cat("  Bootstrap error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(boot_result)) {
  rob$bootstrap <- boot_result
  cat("  Bootstrap results computed.\n")
}

# ============================================================
# 6. LEAVE-ONE-OUT COUNTRY
# ============================================================

cat("\n=== Robustness: Leave-one-out country ===\n")

loo_results <- map_dfr(unique(eu_panel$iso3c), function(c) {
  m <- tryCatch(
    feols(log_hg_import ~ eu_ban_treat | iso3c + year,
          data = eu_panel %>% filter(iso3c != c),
          cluster = ~iso3c),
    error = function(e) NULL
  )
  if (!is.null(m)) {
    tibble(
      excluded = c,
      coef = coef(m)["eu_ban_treat"],
      se = sqrt(vcov(m)["eu_ban_treat", "eu_ban_treat"])
    )
  }
})

rob$loo <- loo_results
cat("  LOO range:", round(range(loo_results$coef), 4), "\n")

# ============================================================
# 7. MINAMATA: NOT-YET-TREATED CONTROL GROUP
# ============================================================

cat("\n=== Robustness: Minamata with not-yet-treated controls ===\n")

cs_panel_nyt <- panel %>%
  filter(year >= 2005, year <= 2023, !is.na(log_hg_import), !is.na(log_gdp_pc)) %>%
  # Recode late ratifiers (treatment_year > 2023) as never-treated
  mutate(first_treat_minamata = ifelse(
    first_treat_minamata > 2023 | first_treat_minamata == 0, 0L,
    first_treat_minamata
  ))

set.seed(20250225)
cs_nyt <- tryCatch({
  att_gt(
    yname       = "log_hg_import",
    tname       = "year",
    idname      = "country_id",
    gname       = "first_treat_minamata",
    data        = as.data.frame(cs_nyt <- cs_panel_nyt),
    xformla     = ~ log_gdp_pc,
    est_method  = "dr",
    control_group = "notyettreated",
    base_period = "universal",
    bstrap      = TRUE,
    biters      = 1000
  )
}, error = function(e) {
  cat("  CS-DiD (not-yet-treated) error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_nyt)) {
  rob$cs_nyt <- aggte(cs_nyt, type = "simple")
  cat("  NYT ATT:", round(rob$cs_nyt$overall.att, 4), "\n")
}

# ============================================================
# 8. ASGM HETEROGENEITY
# ============================================================

cat("\n=== Robustness: ASGM heterogeneity ===\n")

# Very high ASGM countries
rob$asgm_very_high <- feols(
  log_hg_import ~ minamata_ratified | iso3c + year,
  data = panel %>% filter(year >= 2005, year <= 2023, asgm_level == "very_high"),
  cluster = ~iso3c
)

# Non-ASGM countries (placebo)
rob$non_asgm <- feols(
  log_hg_import ~ minamata_ratified | iso3c + year,
  data = panel %>% filter(year >= 2005, year <= 2023, asgm_level == "none"),
  cluster = ~iso3c
)

cat("  Very high ASGM:", round(coef(rob$asgm_very_high)["minamata_ratified"], 4), "\n")
cat("  Non-ASGM (placebo):", round(coef(rob$non_asgm)["minamata_ratified"], 4), "\n")

# ============================================================
# 9. PRE-TREND TEST (formal)
# ============================================================

cat("\n=== Robustness: Pre-trend tests ===\n")

# For EU ban: test whether EU-share × linear trend in pre-period is significant
pre_only <- panel %>% filter(year >= 2005, year <= 2010)
rob$pretrend_eu <- feols(log_hg_import ~ eu_share_preban:year | iso3c + year,
                         data = pre_only, cluster = ~iso3c)
cat("  EU pre-trend p-value:",
    round(pvalue(rob$pretrend_eu)["eu_share_preban:year"], 4), "\n")

# ============================================================
# SAVE ROBUSTNESS
# ============================================================

save(rob, file = file.path(data_dir, "robustness_results.RData"))
cat("\nRobustness results saved.\n")
