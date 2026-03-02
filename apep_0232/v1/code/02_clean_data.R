###############################################################################
# 02_clean_data.R — Merge and construct analysis variables
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

# Load raw data
brw <- readRDS("../data/brw_shocks.rds")
state_emp <- readRDS("../data/state_employment.rds")
state_poverty <- readRDS("../data/state_poverty.rds")
state_snap <- readRDS("../data/state_snap.rds")
state_pop <- readRDS("../data/state_population.rds")
state_gdp <- readRDS("../data/state_gdp.rds")
state_homeown <- readRDS("../data/state_homeownership.rds")
state_info <- readRDS("../data/state_info.rds")
transfers <- readRDS("../data/bea_transfers.rds")

# ===========================================================================
# 1. CONSTRUCT HtM PROXIES (annual, state-level)
# ===========================================================================

# --- Poverty rate (primary HtM proxy) ---
htm_poverty <- state_poverty %>%
  left_join(state_info, by = c("state_fips" = "fips")) %>%
  select(state_abbr = abbr, year, poverty_rate) %>%
  filter(!is.na(state_abbr))

# --- SNAP recipiency rate (secondary proxy) ---
# Need population for per-capita calculation
htm_snap <- state_snap %>%
  left_join(state_info, by = c("state_fips" = "fips")) %>%
  left_join(
    state_pop %>% select(state_abbr, year, population),
    by = c("abbr" = "state_abbr", "year")
  ) %>%
  mutate(snap_rate = snap_recipients / population) %>%
  select(state_abbr = abbr, year, snap_rate) %>%
  filter(!is.na(snap_rate), snap_rate > 0, snap_rate < 1)

# Merge HtM proxies
htm_annual <- htm_poverty %>%
  left_join(htm_snap, by = c("state_abbr", "year")) %>%
  left_join(
    state_homeown %>% select(state_abbr, year, homeown_rate),
    by = c("state_abbr", "year")
  )

cat(sprintf("HtM data: %d state-year obs, %d states\n",
            nrow(htm_annual), n_distinct(htm_annual$state_abbr)))

# ===========================================================================
# 2. CONSTRUCT PRE-DETERMINED HtM MEASURES
# ===========================================================================
# Use 5-year rolling average lagged by 2 years for pre-determination
# For observation in year t, HtM is average of [t-6, t-2]

htm_predetermined <- htm_annual %>%
  group_by(state_abbr) %>%
  arrange(year) %>%
  mutate(
    # 5-year rolling mean poverty rate
    poverty_5yr = zoo::rollmean(poverty_rate, k = 5, fill = NA, align = "right"),
    snap_5yr = zoo::rollmean(snap_rate, k = 5, fill = NA, align = "right"),
    homeown_5yr = zoo::rollmean(homeown_rate, k = 5, fill = NA, align = "right")
  ) %>%
  ungroup() %>%
  # Lag by 2 years for pre-determination
  mutate(
    htm_year = year + 2  # These will be applied to observations in htm_year
  ) %>%
  select(state_abbr, htm_year, poverty_5yr, snap_5yr, homeown_5yr)

# Also compute time-invariant cross-sectional HtM measure (average over full sample)
htm_cross_section <- htm_annual %>%
  filter(year >= 1995, year <= 2005) %>%  # Pre-sample average
  group_by(state_abbr) %>%
  summarise(
    htm_poverty_xs = mean(poverty_rate, na.rm = TRUE),
    htm_snap_xs = mean(snap_rate, na.rm = TRUE),
    homeown_xs = mean(homeown_rate, na.rm = TRUE),
    .groups = "drop"
  )

cat("Cross-sectional HtM variation:\n")
cat(sprintf("  Poverty rate: min=%.1f%%, max=%.1f%%, sd=%.1f%%\n",
            100*min(htm_cross_section$htm_poverty_xs, na.rm=T),
            100*max(htm_cross_section$htm_poverty_xs, na.rm=T),
            100*sd(htm_cross_section$htm_poverty_xs, na.rm=T)))

# ===========================================================================
# 3. CONSTRUCT MONTHLY ANALYSIS PANEL
# ===========================================================================

# Merge state employment with BRW shocks
panel_monthly <- state_emp %>%
  filter(date >= as.Date("1994-01-01"), date <= as.Date("2020-12-01")) %>%
  left_join(brw, by = c("date", "year", "month_num")) %>%
  # Add cross-sectional HtM
  left_join(htm_cross_section, by = "state_abbr") %>%
  # Add time-varying HtM
  left_join(htm_predetermined, by = c("state_abbr", "year" = "htm_year")) %>%
  # Create interaction terms
  mutate(
    # Standardize HtM measures
    htm_std = (htm_poverty_xs - mean(htm_poverty_xs, na.rm = TRUE)) /
      sd(htm_poverty_xs, na.rm = TRUE),
    snap_std = (htm_snap_xs - mean(htm_snap_xs, na.rm = TRUE)) /
      sd(htm_snap_xs, na.rm = TRUE),
    homeown_std = (homeown_xs - mean(homeown_xs, na.rm = TRUE)) /
      sd(homeown_xs, na.rm = TRUE),
    # Monetary shock × HtM interaction
    mp_htm = brw_monthly * htm_std,
    mp_snap = brw_monthly * snap_std,
    mp_homeown = brw_monthly * homeown_std,
    # Time identifiers
    year_month = paste0(year, "-", sprintf("%02d", month_num)),
    state_id = as.integer(factor(state_abbr))
  ) %>%
  # Compute employment changes for local projections
  group_by(state_abbr) %>%
  arrange(date) %>%
  mutate(
    # Forward changes at various horizons (for local projections)
    d_emp_0  = 100 * (log_emp - lag(log_emp, 1)),
    d_emp_6  = 100 * (lead(log_emp, 6) - lag(log_emp, 1)),
    d_emp_12 = 100 * (lead(log_emp, 12) - lag(log_emp, 1)),
    d_emp_18 = 100 * (lead(log_emp, 18) - lag(log_emp, 1)),
    d_emp_24 = 100 * (lead(log_emp, 24) - lag(log_emp, 1)),
    d_emp_36 = 100 * (lead(log_emp, 36) - lag(log_emp, 1)),
    d_emp_48 = 100 * (lead(log_emp, 48) - lag(log_emp, 1)),
    # Lagged controls
    d_emp_lag1 = lag(d_emp_0, 1),
    d_emp_lag2 = lag(d_emp_0, 2),
    d_emp_lag3 = lag(d_emp_0, 3),
    d_emp_lag6 = lag(d_emp_0, 6),
    d_emp_lag12 = lag(d_emp_0, 12)
  ) %>%
  ungroup()

cat(sprintf("Monthly panel: %d obs, %d states, %s to %s\n",
            nrow(panel_monthly), n_distinct(panel_monthly$state_abbr),
            min(panel_monthly$date), max(panel_monthly$date)))

saveRDS(panel_monthly, "../data/panel_monthly.rds")

# ===========================================================================
# 4. CONSTRUCT ANNUAL PANEL (for fiscal transfer analysis)
# ===========================================================================

# Reshape BEA transfers to wide format (state-level only, exclude national/regional)
transfers_wide <- transfers %>%
  filter(!grepl("United States|Far West|Great|Mid|New Eng|Plains|Rocky|Southeast|Southwest", geo_name)) %>%
  # Extract state FIPS
  mutate(
    state_fips = substr(geo_fips, 1, 2)
  ) %>%
  filter(state_fips %in% state_info$fips) %>%
  select(state_fips, year, category, value) %>%
  pivot_wider(names_from = category, values_from = value, names_prefix = "tr_")

# State GDP panel
gdp_panel <- state_gdp %>%
  mutate(state_fips = substr(geo_fips, 1, 2)) %>%
  filter(nchar(geo_fips) == 5) %>%
  select(state_fips, year, gdp_millions)

# Annual employment (from monthly, take annual average)
emp_annual <- state_emp %>%
  group_by(state_abbr, year) %>%
  summarise(emp_annual = mean(emp, na.rm = TRUE), .groups = "drop")

# Merge everything
panel_annual <- transfers_wide %>%
  left_join(state_info, by = c("state_fips" = "fips")) %>%
  left_join(gdp_panel, by = c("state_fips", "year")) %>%
  left_join(emp_annual, by = c("abbr" = "state_abbr", "year")) %>%
  left_join(htm_annual, by = c("abbr" = "state_abbr", "year")) %>%
  left_join(
    state_pop %>% select(state_abbr, year, population),
    by = c("abbr" = "state_abbr", "year")
  ) %>%
  filter(!is.na(abbr)) %>%
  # Per-capita and ratio variables
  mutate(
    transfers_pc = tr_total / population * 1000,  # per capita (values in thousands)
    gdp_pc = gdp_millions * 1e6 / population,
    transfer_gdp_ratio = tr_total / (gdp_millions * 1000),  # both in thousands
    log_gdp = log(gdp_millions),
    log_emp = log(emp_annual),
    log_transfers = log(tr_total)
  ) %>%
  # Create changes
  group_by(abbr) %>%
  arrange(year) %>%
  mutate(
    d_log_gdp = log_gdp - lag(log_gdp),
    d_log_emp = log_emp - lag(log_emp),
    d_transfer_ratio = transfer_gdp_ratio - lag(transfer_gdp_ratio)
  ) %>%
  ungroup() %>%
  # Add cross-sectional HtM
  left_join(htm_cross_section, by = c("abbr" = "state_abbr"))

cat(sprintf("Annual panel: %d obs, %d states, %d years\n",
            nrow(panel_annual), n_distinct(panel_annual$abbr),
            n_distinct(panel_annual$year)))

saveRDS(panel_annual, "../data/panel_annual.rds")

# ===========================================================================
# 5. CONSTRUCT BARTIK INSTRUMENT (for fiscal transfer channel)
# ===========================================================================

# Bartik = sum_c (share_{s,c,t0} × ΔNational_{c,t})
# share = state's share of national category c, measured in t-5
# shift = national change in category c

# Get national totals (geo_name contains "United States" for national aggregates)
national_transfers <- transfers %>%
  filter(grepl("United States", geo_name)) %>%
  select(year, category, value) %>%
  rename(national_value = value)

cat(sprintf("  National transfer rows: %d\n", nrow(national_transfers)))

if (nrow(national_transfers) == 0) {
  cat("  WARNING: No national transfer data found. Bartik instrument will be empty.\n")
  cat("  This means bea_transfers.rds excluded 'United States' rows. Re-run 01_fetch_data.R.\n")
}

# State shares (lagged 5 years)
# BEA geo_fips for states are 5-digit strings like "01000" (state FIPS + "000")
# Extract 2-digit state FIPS to match state_info$fips
state_shares <- transfers %>%
  filter(!grepl("United States", geo_name)) %>%
  mutate(state_fips = substr(geo_fips, 1, 2)) %>%
  # BEA state-level records have geo_fips like "01000" (5 chars) or sometimes "01" (2 chars)
  # Keep all records where state_fips matches a known state
  filter(state_fips %in% state_info$fips) %>%
  left_join(state_info, by = c("state_fips" = "fips")) %>%
  left_join(national_transfers, by = c("year", "category")) %>%
  filter(!is.na(national_value), national_value != 0) %>%
  mutate(share = value / national_value) %>%
  # Lag shares by 5 years
  mutate(target_year = year + 5) %>%
  select(state_fips, abbr, target_year, category, share)

cat(sprintf("  State shares: %d obs across %d states\n",
            nrow(state_shares), n_distinct(state_shares$abbr)))

# National changes
national_changes <- national_transfers %>%
  group_by(category) %>%
  arrange(year) %>%
  mutate(d_national = national_value - lag(national_value)) %>%
  ungroup()

# Categories for Bartik (EXCLUDE UI for baseline — it's mechanically endogenous)
bartik_cats <- c("social_security", "medicare", "medicaid", "ssi", "eitc",
                 "snap", "veterans", "education")

# Construct Bartik instrument
bartik <- state_shares %>%
  filter(category %in% bartik_cats) %>%
  left_join(
    national_changes %>% select(year, category, d_national),
    by = c("target_year" = "year", "category")
  ) %>%
  filter(!is.na(d_national), !is.na(share)) %>%
  mutate(bartik_component = share * d_national) %>%
  group_by(state_fips, abbr, target_year) %>%
  summarise(bartik_transfer = sum(bartik_component, na.rm = TRUE), .groups = "drop") %>%
  rename(year = target_year)

cat(sprintf("  Bartik instrument constructed: %d state-year obs\n", nrow(bartik)))

# Merge Bartik into annual panel
panel_annual <- panel_annual %>%
  left_join(bartik %>% select(abbr, year, bartik_transfer),
            by = c("abbr", "year"))

cat(sprintf("Bartik instrument: %d state-year obs with non-missing Bartik\n",
            sum(!is.na(panel_annual$bartik_transfer))))

saveRDS(panel_annual, "../data/panel_annual.rds")

# ===========================================================================
# 6. SUMMARY STATISTICS
# ===========================================================================

cat("\n=== SUMMARY STATISTICS ===\n\n")

cat("Monthly Panel (1994-2020):\n")
cat(sprintf("  Observations: %s\n", format(nrow(panel_monthly), big.mark = ",")))
cat(sprintf("  States: %d\n", n_distinct(panel_monthly$state_abbr)))
cat(sprintf("  Months: %d\n", n_distinct(panel_monthly$date)))
cat(sprintf("  BRW shock SD: %.4f\n", sd(panel_monthly$brw_monthly, na.rm = TRUE)))
cat(sprintf("  HtM (poverty) range: %.1f%% to %.1f%%\n",
            100*min(htm_cross_section$htm_poverty_xs, na.rm=T),
            100*max(htm_cross_section$htm_poverty_xs, na.rm=T)))

cat("\nAnnual Panel (2000-2023):\n")
cat(sprintf("  Observations: %s\n", format(nrow(panel_annual), big.mark = ",")))
cat(sprintf("  Transfer-GDP ratio range: %.1f%% to %.1f%%\n",
            100*min(panel_annual$transfer_gdp_ratio, na.rm=T),
            100*max(panel_annual$transfer_gdp_ratio, na.rm=T)))

cat("\n=== DATA CLEANING COMPLETE ===\n")
