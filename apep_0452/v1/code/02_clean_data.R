## 02_clean_data.R — Variable construction and panel assembly
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")
load(file.path(data_dir, "raw_data.RData"))

# ============================================================
# A. CLEAN MERCURY IMPORT DATA
# ============================================================

cat("--- Cleaning mercury imports ---\n")

# Process aggregate mercury imports (OEC format)
if (nrow(mercury_raw) > 0) {
  # OEC uses "Country ID" like "afgh" for Afghanistan, "afago" for Angola etc.
  # Map OEC country IDs to ISO3C
  mercury_agg <- mercury_raw %>%
    rename(
      year = Year,
      country_oec = `Country ID`,
      country_name_oec = Country,
      value = `Trade Value`
    ) %>%
    mutate(
      # Extract ISO2 from OEC code (strip "af" continent prefix)
      iso2_guess = toupper(str_sub(country_oec, 3, 5)),
      iso3c = countrycode(country_name_oec, "country.name", "iso3c",
                           warn = FALSE)
    ) %>%
    filter(!is.na(iso3c), iso3c %in% african_countries) %>%
    group_by(iso3c, year) %>%
    summarise(
      hg_import_value = sum(as.numeric(value), na.rm = TRUE),
      .groups = "drop"
    )
} else {
  mercury_agg <- tibble(iso3c = character(), year = integer(),
                        hg_import_value = numeric())
}

cat("  Mercury aggregate records:", nrow(mercury_agg), "\n")
cat("  Countries with data:", n_distinct(mercury_agg$iso3c), "\n")
cat("  Year range:", range(mercury_agg$year), "\n")

# ============================================================
# B. CLEAN BILATERAL MERCURY DATA (for trade partner analysis)
# ============================================================

if (nrow(mercury_bilateral) > 0) {
  # OEC bilateral format has Importer Country, Exporter Country columns
  imp_col <- grep("Importer.*Country$", names(mercury_bilateral), value = TRUE)[1]
  exp_col <- grep("Exporter.*Country$", names(mercury_bilateral), value = TRUE)[1]

  mercury_bilat <- mercury_bilateral %>%
    rename(
      year = Year,
      value = `Trade Value`,
      importer_name = !!imp_col,
      exporter_name = !!exp_col
    ) %>%
    mutate(
      reporter_iso3 = countrycode(importer_name, "country.name", "iso3c", warn = FALSE),
      partner_iso3  = countrycode(exporter_name, "country.name", "iso3c", warn = FALSE),
      value = as.numeric(value)
    ) %>%
    filter(!is.na(reporter_iso3), reporter_iso3 %in% african_countries,
           !is.na(value), value > 0, !is.na(partner_iso3)) %>%
    mutate(
      partner_is_eu = partner_iso3 %in% eu_members_2010,
      partner_region = case_when(
        partner_is_eu ~ "EU",
        partner_iso3 %in% c("TUR") ~ "Turkey",
        partner_iso3 %in% c("ARE") ~ "UAE",
        partner_iso3 %in% c("IND") ~ "India",
        partner_iso3 %in% c("CHN","HKG") ~ "China/HK",
        partner_iso3 %in% c("MEX") ~ "Mexico",
        partner_iso3 %in% c("SGP") ~ "Singapore",
        partner_iso3 %in% african_countries ~ "Africa (intra)",
        TRUE ~ "Other"
      )
    ) %>%
    select(reporter_iso3, partner_iso3, partner_region, partner_is_eu,
           year, value)
} else {
  mercury_bilat <- tibble()
}

cat("  Bilateral records:", nrow(mercury_bilat), "\n")

# Compute EU import share (pre-ban: 2005-2010)
if (nrow(mercury_bilat) > 0) {
  eu_share_preban <- mercury_bilat %>%
    filter(year >= 2005, year <= 2010) %>%
    group_by(reporter_iso3) %>%
    summarise(
      total_hg_preban    = sum(value, na.rm = TRUE),
      eu_hg_preban       = sum(value[partner_is_eu], na.rm = TRUE),
      eu_share_preban    = ifelse(total_hg_preban > 0,
                                   eu_hg_preban / total_hg_preban, 0),
      n_years_reporting  = n_distinct(year),
      .groups = "drop"
    ) %>%
    rename(iso3c = reporter_iso3)
} else {
  eu_share_preban <- tibble(iso3c = african_countries,
                             total_hg_preban = 0,
                             eu_hg_preban = 0,
                             eu_share_preban = 0,
                             n_years_reporting = 0)
}

cat("  Countries with EU share data:", nrow(eu_share_preban), "\n")

# ============================================================
# C. CLEAN GOLD EXPORT DATA
# ============================================================

cat("\n--- Cleaning gold exports ---\n")

if (nrow(gold_raw) > 0) {
  gold_agg <- gold_raw %>%
    rename(year = Year, value = `Trade Value`) %>%
    mutate(
      country_name_oec = Country,
      iso3c = countrycode(country_name_oec, "country.name", "iso3c", warn = FALSE)
    ) %>%
    filter(!is.na(iso3c), iso3c %in% african_countries) %>%
    group_by(iso3c, year) %>%
    summarise(
      gold_export_value = sum(as.numeric(value), na.rm = TRUE),
      .groups = "drop"
    )
} else {
  gold_agg <- tibble(iso3c = character(), year = integer(),
                      gold_export_value = numeric())
}

cat("  Gold export records:", nrow(gold_agg), "\n")

# ============================================================
# D. CLEAN PLACEBO COMMODITY (FERTILIZER)
# ============================================================

if (nrow(fertilizer_raw) > 0) {
  fertilizer_agg <- fertilizer_raw %>%
    rename(year = Year, value = `Trade Value`) %>%
    mutate(
      country_name_oec = Country,
      iso3c = countrycode(country_name_oec, "country.name", "iso3c", warn = FALSE)
    ) %>%
    filter(!is.na(iso3c), iso3c %in% african_countries) %>%
    group_by(iso3c, year) %>%
    summarise(
      fert_import_value = sum(as.numeric(value), na.rm = TRUE),
      .groups = "drop"
    )
} else {
  fertilizer_agg <- tibble(iso3c = character(), year = integer(),
                            fert_import_value = numeric())
}

# ============================================================
# E. CLEAN WDI AND WGI
# ============================================================

cat("\n--- Cleaning WDI/WGI ---\n")

wdi_clean <- wdi_data %>%
  filter(iso3c %in% african_countries) %>%
  select(iso3c, year,
         gdp_pc = NY.GDP.PCAP.CD,
         population = SP.POP.TOTL,
         gdp = NY.GDP.MKTP.CD,
         trade_pct_gdp = NE.TRD.GNFS.ZS) %>%
  mutate(log_gdp_pc = log(pmax(gdp_pc, 1)),
         log_pop    = log(pmax(population, 1)))

wgi_clean <- wgi_data %>%
  filter(iso3c %in% african_countries) %>%
  select(iso3c, year,
         corruption_control = CC.EST,
         rule_of_law = RL.EST,
         govt_effectiveness = GE.EST,
         regulatory_quality = RQ.EST)

cat("  WDI rows:", nrow(wdi_clean), "\n")
cat("  WGI rows:", nrow(wgi_clean), "\n")

# ============================================================
# F. BUILD BALANCED PANEL
# ============================================================

cat("\n--- Building balanced panel ---\n")

panel <- expand.grid(
  iso3c = african_countries,
  year  = 2000:2023,
  stringsAsFactors = FALSE
) %>%
  as_tibble() %>%
  # Add country names
  mutate(country_name = countrycode(iso3c, "iso3c", "country.name")) %>%
  # Merge mercury imports
  left_join(mercury_agg, by = c("iso3c", "year")) %>%
  mutate(hg_import_value = replace_na(hg_import_value, 0)) %>%
  # Merge gold exports
  left_join(gold_agg, by = c("iso3c", "year")) %>%
  mutate(gold_export_value = replace_na(gold_export_value, 0)) %>%
  # Merge fertilizer (placebo)
  left_join(fertilizer_agg, by = c("iso3c", "year")) %>%
  mutate(fert_import_value = replace_na(fert_import_value, 0)) %>%
  # Merge WDI
  left_join(wdi_clean, by = c("iso3c", "year")) %>%
  # Merge WGI
  left_join(wgi_clean, by = c("iso3c", "year")) %>%
  # Merge EU share
  left_join(eu_share_preban, by = "iso3c") %>%
  mutate(eu_share_preban = replace_na(eu_share_preban, 0),
         total_hg_preban = replace_na(total_hg_preban, 0)) %>%
  # Merge Minamata ratification
  left_join(
    minamata_ratification %>% select(iso3c, ratification_year, treatment_year, nap_year),
    by = "iso3c"
  ) %>%
  # Merge ASGM indicators
  left_join(asgm_countries, by = "iso3c") %>%
  mutate(
    asgm_level = replace_na(asgm_level, "none"),
    is_asgm_country = asgm_level != "none",
    est_miners_thousands = replace_na(est_miners_thousands, 0)
  )

# ============================================================
# G. CONSTRUCT TREATMENT VARIABLES
# ============================================================

cat("--- Constructing treatment variables ---\n")

panel <- panel %>%
  mutate(
    # EU Ban treatment
    post_eu_ban = as.integer(year >= 2012),
    eu_ban_treat = eu_share_preban * post_eu_ban,
    high_eu_depend = as.integer(eu_share_preban > median(
      eu_share_preban[eu_share_preban > 0], na.rm = TRUE)),

    # Minamata treatment
    minamata_ratified = as.integer(!is.na(ratification_year) & year >= treatment_year),
    nap_submitted = as.integer(!is.na(nap_year) & year >= nap_year),
    # For Callaway-Sant'Anna: first treatment year (0 = never treated)
    first_treat_minamata = ifelse(is.na(treatment_year), 0L, treatment_year),

    # Outcome variables (logs with small constant for zeros)
    log_hg_import   = log(hg_import_value + 1),
    log_gold_export = log(gold_export_value + 1),
    log_fert_import = log(fert_import_value + 1),

    # Inverse hyperbolic sine (handles zeros better)
    ihs_hg_import   = log(hg_import_value + sqrt(hg_import_value^2 + 1)),
    ihs_gold_export = log(gold_export_value + sqrt(gold_export_value^2 + 1)),

    # Numeric country ID for panel estimators
    country_id = as.integer(factor(iso3c))
  )

# ============================================================
# H. IDENTIFY BALANCED REPORTERS (mercury data quality)
# ============================================================

mercury_reporting <- panel %>%
  filter(year >= 2005, year <= 2020) %>%
  group_by(iso3c) %>%
  summarise(
    years_with_hg = sum(hg_import_value > 0),
    total_years = n(),
    pct_reporting = years_with_hg / total_years,
    .groups = "drop"
  )

balanced_reporters <- mercury_reporting %>%
  filter(pct_reporting >= 0.5) %>%
  pull(iso3c)

panel <- panel %>%
  mutate(balanced_reporter = iso3c %in% balanced_reporters)

cat("  Balanced mercury reporters (50%+ years):", length(balanced_reporters), "\n")
cat("  Total panel rows:", nrow(panel), "\n")
cat("  Countries:", n_distinct(panel$iso3c), "\n")
cat("  Years:", range(panel$year), "\n")

# ============================================================
# I. SUMMARY STATISTICS
# ============================================================

cat("\n--- Summary statistics ---\n")

panel %>%
  filter(year >= 2005, year <= 2020) %>%
  summarise(
    n_countries = n_distinct(iso3c),
    n_years = n_distinct(year),
    mean_hg_imports = mean(hg_import_value, na.rm = TRUE),
    median_hg_imports = median(hg_import_value, na.rm = TRUE),
    countries_with_hg = sum(hg_import_value > 0),
    mean_gold_exports = mean(gold_export_value, na.rm = TRUE),
    minamata_ratifiers = n_distinct(iso3c[minamata_ratified == 1]),
    asgm_countries = n_distinct(iso3c[is_asgm_country])
  ) %>%
  glimpse()

# ============================================================
# SAVE CLEAN DATA
# ============================================================

save(panel, mercury_bilat, eu_share_preban, balanced_reporters,
     minamata_ratification, asgm_countries,
     african_countries, eu_members_2010,
     file = file.path(data_dir, "clean_panel.RData"))

cat("\nClean panel saved.\n")
