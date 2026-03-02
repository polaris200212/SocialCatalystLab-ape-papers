## 02_clean_data.R — Construct analysis variables
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Loading data ===\n")
wdi <- readRDS("../data/wdi_panel.rds")
oil_annual <- readRDS("../data/oil_prices.rds")

cat(sprintf("  WDI: %d rows, %d countries\n", nrow(wdi), n_distinct(wdi$iso3c)))

# ============================================================
# 1. Construct treatment variable
# ============================================================
cat("\n=== Constructing treatment variables ===\n")

# Pre-2014 average oil rents (2010-2013)
pre_oil_rents <- wdi %>%
  filter(year >= 2010, year <= 2013) %>%
  group_by(iso3c, country) %>%
  summarise(
    oil_rents_pre = mean(NY.GDP.PETR.RT.ZS, na.rm = TRUE),
    gas_rents_pre = mean(NY.GDP.NGAS.RT.ZS, na.rm = TRUE),
    total_rents_pre = mean(NY.GDP.TOTL.RT.ZS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # Replace NaN with 0 (countries with no oil)
  mutate(across(ends_with("_pre"), ~ifelse(is.nan(.), 0, .)))

cat(sprintf("  Countries with oil rents data: %d\n", sum(!is.na(pre_oil_rents$oil_rents_pre))))
cat(sprintf("  Countries with oil rents > 5%%: %d\n", sum(pre_oil_rents$oil_rents_pre > 5)))
cat(sprintf("  Countries with oil rents > 10%%: %d\n", sum(pre_oil_rents$oil_rents_pre > 10)))

# ============================================================
# 2. Build analysis panel
# ============================================================
cat("\n=== Building analysis panel ===\n")

panel <- wdi %>%
  filter(year >= 2005, year <= 2023) %>%
  left_join(pre_oil_rents, by = c("iso3c", "country")) %>%
  left_join(oil_annual, by = "year") %>%
  mutate(
    # Treatment variables
    post2014 = as.integer(year >= 2014),
    treatment_continuous = oil_rents_pre * post2014,

    # Binary treatment (top quartile of oil rents)
    high_oil = as.integer(oil_rents_pre > quantile(pre_oil_rents$oil_rents_pre, 0.75, na.rm = TRUE)),
    treatment_binary = high_oil * post2014,

    # Tercile treatment
    oil_tercile = case_when(
      oil_rents_pre <= 0.1 ~ "None",
      oil_rents_pre <= 5 ~ "Low",
      oil_rents_pre > 5 ~ "High"
    ),
    oil_tercile = factor(oil_tercile, levels = c("None", "Low", "High")),

    # Log GDP per capita (constant 2015 USD)
    log_gdppc = log(NY.GDP.PCAP.KD),

    # Event time relative to 2014
    event_time = year - 2014,

    # Rename variables for convenience
    u5_mortality = SH.DYN.MORT,
    infant_mortality = SP.DYN.IMRT.IN,
    neonatal_mortality = SH.DYN.NMRT,
    health_exp = SH.XPD.CHEX.GD.ZS,
    gov_health_exp = SH.XPD.GHED.GD.ZS,
    military_exp = MS.MIL.XPND.GD.ZS,
    dpt_immunization = SH.IMM.IDPT,
    measles_immunization = SH.IMM.MEAS,
    gdp_pc = NY.GDP.PCAP.CD,
    gdp_pc_constant = NY.GDP.PCAP.KD,
    population = SP.POP.TOTL,
    urban_pct = SP.URB.TOTL.IN.ZS,
    pop_growth = SP.POP.GROW,
    primary_enrollment = SE.PRM.ENRR,
    secondary_enrollment = SE.SEC.ENRR,
    corruption_control = CC.EST,
    gov_effectiveness = GE.EST
  )

cat(sprintf("  Panel: %d obs, %d countries, years %d-%d\n",
            nrow(panel), n_distinct(panel$iso3c),
            min(panel$year), max(panel$year)))

# ============================================================
# 3. Filter to developing countries (analysis sample)
# ============================================================
cat("\n=== Filtering to developing countries ===\n")

# Exclude high-income OECD members as of 2013
oecd_high_income <- c("AUS", "AUT", "BEL", "CAN", "CHE", "CZE", "DEU", "DNK",
                       "ESP", "EST", "FIN", "FRA", "GBR", "GRC", "HUN", "IRL",
                       "ISL", "ISR", "ITA", "JPN", "KOR", "LUX", "LVA", "NLD",
                       "NOR", "NZL", "POL", "PRT", "SVK", "SVN", "SWE", "USA")

# Also exclude very small countries (population < 500K in 2013)
small_countries <- wdi %>%
  filter(year == 2013, SP.POP.TOTL < 500000) %>%
  pull(iso3c)

panel_dev <- panel %>%
  filter(
    !iso3c %in% oecd_high_income,
    !iso3c %in% small_countries,
    !is.na(oil_rents_pre),  # Need treatment variable
    !is.na(u5_mortality)     # Need outcome
  )

cat(sprintf("  Developing countries panel: %d obs, %d countries\n",
            nrow(panel_dev), n_distinct(panel_dev$iso3c)))

# Count treated countries
treated_counts <- panel_dev %>%
  filter(year == 2013) %>%
  summarise(
    n_high_oil = sum(oil_rents_pre > 5, na.rm = TRUE),
    n_any_oil = sum(oil_rents_pre > 0.1, na.rm = TRUE),
    n_no_oil = sum(oil_rents_pre <= 0.1, na.rm = TRUE)
  )

cat(sprintf("  High oil (>5%%): %d countries\n", treated_counts$n_high_oil))
cat(sprintf("  Some oil (>0.1%%): %d countries\n", treated_counts$n_any_oil))
cat(sprintf("  No oil (<=0.1%%): %d countries\n", treated_counts$n_no_oil))

# ============================================================
# 4. Summary statistics
# ============================================================
cat("\n=== Computing summary statistics ===\n")

# Pre-period summary by treatment group
summary_stats <- panel_dev %>%
  filter(year >= 2005, year <= 2013) %>%
  mutate(group = ifelse(oil_rents_pre > 5, "High Oil", "Low/No Oil")) %>%
  group_by(group) %>%
  summarise(
    n_countries = n_distinct(iso3c),
    mean_u5_mort = mean(u5_mortality, na.rm = TRUE),
    sd_u5_mort = sd(u5_mortality, na.rm = TRUE),
    mean_health_exp = mean(health_exp, na.rm = TRUE),
    mean_military_exp = mean(military_exp, na.rm = TRUE),
    mean_dpt = mean(dpt_immunization, na.rm = TRUE),
    mean_gdppc = mean(gdp_pc_constant, na.rm = TRUE),
    mean_urban = mean(urban_pct, na.rm = TRUE),
    mean_oil_rents = mean(oil_rents_pre, na.rm = TRUE),
    .groups = "drop"
  )

print(summary_stats)

# ============================================================
# 5. Full panel with OECD (for robustness)
# ============================================================
panel_full <- panel %>%
  filter(
    !iso3c %in% small_countries,
    !is.na(oil_rents_pre),
    !is.na(u5_mortality)
  )

cat(sprintf("\n  Full panel (incl. OECD): %d obs, %d countries\n",
            nrow(panel_full), n_distinct(panel_full$iso3c)))

# ============================================================
# Save
# ============================================================
saveRDS(panel_dev, "../data/panel_dev.rds")
saveRDS(panel_full, "../data/panel_full.rds")
saveRDS(pre_oil_rents, "../data/pre_oil_rents.rds")

cat("\n=== Clean data saved ===\n")
