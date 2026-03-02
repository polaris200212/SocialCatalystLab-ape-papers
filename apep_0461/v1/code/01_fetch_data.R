## 01_fetch_data.R — Fetch data from World Bank WDI, FRED, and DHS
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Fetching World Bank WDI data ===\n")

# Define indicators
wb_indicators <- c(
  "SH.DYN.MORT",       # Under-5 mortality rate (per 1,000 live births)
  "SP.DYN.IMRT.IN",    # Infant mortality rate (per 1,000 live births)
  "SH.DYN.NMRT",       # Neonatal mortality rate (per 1,000 live births)
  "NY.GDP.PETR.RT.ZS",  # Oil rents (% of GDP)
  "NY.GDP.NGAS.RT.ZS",  # Natural gas rents (% of GDP)
  "NY.GDP.TOTL.RT.ZS",  # Total natural resources rents (% of GDP)
  "SH.XPD.CHEX.GD.ZS",  # Current health expenditure (% of GDP)
  "SH.XPD.GHED.GD.ZS",  # Domestic general government health expenditure (% GDP)
  "MS.MIL.XPND.GD.ZS",  # Military expenditure (% of GDP)
  "SH.IMM.IDPT",        # DPT immunization (% of children 12-23 months)
  "SH.IMM.MEAS",        # Measles immunization (% of children 12-23 months)
  "NY.GDP.PCAP.CD",     # GDP per capita (current US$)
  "NY.GDP.PCAP.KD",     # GDP per capita (constant 2015 US$)
  "SP.POP.TOTL",        # Population
  "SP.URB.TOTL.IN.ZS",  # Urban population (% of total)
  "SE.PRM.ENRR",        # School enrollment, primary (% gross)
  "SE.SEC.ENRR",        # School enrollment, secondary (% gross)
  "SP.POP.GROW",        # Population growth (annual %)
  "CC.EST",             # Control of Corruption: Estimate
  "GE.EST"              # Government Effectiveness: Estimate
)

# Fetch WDI data for all countries, 2000-2024
wdi_raw <- WDI(
  indicator = wb_indicators,
  country = "all",
  start = 2000,
  end = 2024,
  extra = TRUE  # Include income group, region, etc.
)

cat(sprintf("  WDI raw: %d rows, %d columns\n", nrow(wdi_raw), ncol(wdi_raw)))

# Filter to actual countries (remove aggregates)
wdi <- wdi_raw %>%
  filter(
    !is.na(iso3c),
    region != "Aggregates"  # Remove regional aggregates
  )

cat(sprintf("  WDI countries only: %d rows, %d unique countries\n",
            nrow(wdi), n_distinct(wdi$iso3c)))

# Save
saveRDS(wdi, "../data/wdi_panel.rds")
cat("  Saved: wdi_panel.rds\n")

# === FRED: Oil prices ===
cat("\n=== Fetching FRED oil price data ===\n")

fredr_set_key(Sys.getenv("FRED_API_KEY"))

oil_monthly <- fredr(
  series_id = "DCOILBRENTEU",
  observation_start = as.Date("2000-01-01"),
  observation_end = as.Date("2024-12-31"),
  frequency = "m"
)

cat(sprintf("  FRED Brent crude: %d monthly observations\n", nrow(oil_monthly)))

# Create annual average oil price
oil_annual <- oil_monthly %>%
  mutate(year = lubridate::year(date)) %>%
  group_by(year) %>%
  summarise(
    oil_price_brent = mean(value, na.rm = TRUE),
    oil_price_sd = sd(value, na.rm = TRUE),
    .groups = "drop"
  )

cat(sprintf("  Annual oil prices: %d years (%d to %d)\n",
            nrow(oil_annual), min(oil_annual$year), max(oil_annual$year)))

saveRDS(oil_annual, "../data/oil_prices.rds")
saveRDS(oil_monthly, "../data/oil_prices_monthly.rds")
cat("  Saved: oil_prices.rds, oil_prices_monthly.rds\n")

# === DHS API: Nigeria state-level data ===
cat("\n=== Fetching DHS Nigeria state-level data ===\n")

# Function to fetch DHS data
fetch_dhs <- function(indicator_ids, survey_ids = NULL) {
  base_url <- "https://api.dhsprogram.com/rest/dhs/data"
  params <- list(
    countryIds = "NG",
    breakdown = "subnational",
    indicatorIds = paste(indicator_ids, collapse = ","),
    f = "json",
    perpage = 5000
  )
  if (!is.null(survey_ids)) {
    params$surveyIds <- paste(survey_ids, collapse = ",")
  }

  resp <- GET(base_url, query = params, timeout(30))
  if (status_code(resp) != 200) {
    warning(sprintf("DHS API returned status %d", status_code(resp)))
    return(tibble())
  }

  data <- fromJSON(content(resp, "text", encoding = "UTF-8"))
  records <- data$Data
  if (is.null(records) || nrow(records) == 0) {
    warning("DHS API returned no records")
    return(tibble())
  }

  df <- as_tibble(records)
  cat(sprintf("    DHS API returned columns: %s\n", paste(names(df), collapse=", ")))

  # Use whatever column names the API returns
  df %>%
    rename_with(tolower) %>%
    rename(any_of(c(
      survey_id = "surveyid",
      survey_year = "surveyyear",
      indicator_id = "indicatorid",
      indicator_label = "indicator",
      region = "characteristiclabel",
      value = "value",
      ci_low = "cilow",
      ci_high = "cihigh",
      denominator = "denominatorweighted"
    ))) %>%
    mutate(
      value = as.numeric(value),
      survey_year = as.integer(survey_year)
    )
}

# Key health indicators
dhs_indicators <- c(
  "CM_ECMR_C_U5M",  # Under-5 mortality
  "CM_ECMR_C_IMR",  # Infant mortality
  "CM_ECMR_C_NNR",  # Neonatal mortality
  "CH_VACS_C_BAS",   # Basic vaccination
  "CH_VACS_C_NON",   # No vaccination
  "CN_NUTS_C_HA2",   # Stunting (height for age)
  "CN_NUTS_C_WA2",   # Underweight
  "CN_ANMC_W_ANY",   # Anemia in women
  "RH_ANCN_W_N4P",   # 4+ ANC visits
  "RH_DELP_C_DHF"    # Delivery in health facility
)

# Fetch from state-level surveys (2013, 2018, 2024)
dhs_surveys <- c("NG2013DHS", "NG2018DHS", "NG2024DHS")
dhs_data <- fetch_dhs(dhs_indicators, dhs_surveys)

cat(sprintf("  DHS Nigeria: %d records, %d indicators, %d states\n",
            nrow(dhs_data),
            n_distinct(dhs_data$indicator_id),
            n_distinct(dhs_data$region)))

if (nrow(dhs_data) > 0) {
  cat(sprintf("  Survey years: %s\n",
              paste(sort(unique(dhs_data$survey_year)), collapse = ", ")))
  cat(sprintf("  Indicators: %s\n",
              paste(unique(dhs_data$indicator_id), collapse = ", ")))
}

saveRDS(dhs_data, "../data/dhs_nigeria.rds")
cat("  Saved: dhs_nigeria.rds\n")

# Also fetch zone-level data from earlier surveys for pre-trends
dhs_zone_surveys <- c("NG2003DHS", "NG2008DHS", "NG2010MIS", "NG2013DHS", "NG2018DHS", "NG2024DHS")
dhs_zones <- fetch_dhs(c("CM_ECMR_C_U5M", "CM_ECMR_C_IMR"), dhs_zone_surveys)

cat(sprintf("  DHS zones (for pre-trends): %d records\n", nrow(dhs_zones)))
saveRDS(dhs_zones, "../data/dhs_nigeria_zones.rds")
cat("  Saved: dhs_nigeria_zones.rds\n")

cat("\n=== All data fetched successfully ===\n")
