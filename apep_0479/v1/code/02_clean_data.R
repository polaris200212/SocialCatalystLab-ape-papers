## ============================================================
## 02_clean_data.R — Construct analysis dataset
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"

## ---- 1. Load raw data ----
sod_raw <- readRDS(file.path(data_dir, "sod_raw.rds"))
fin_raw <- readRDS(file.path(data_dir, "financials_raw.rds"))
qcew_raw <- readRDS(file.path(data_dir, "qcew_raw.rds"))
pop_raw  <- readRDS(file.path(data_dir, "population_raw.rds"))

# FDIC API returns columns prefixed with "data." — strip the prefix
names(sod_raw) <- gsub("^data\\.", "", names(sod_raw))
names(fin_raw) <- gsub("^data\\.", "", names(fin_raw))

cat("Raw data loaded.\n")
cat(sprintf("  SOD: %s records\n", format(nrow(sod_raw), big.mark = ",")))
cat(sprintf("  Financials: %s records\n", format(nrow(fin_raw), big.mark = ",")))
cat(sprintf("  QCEW: %s records\n", format(nrow(qcew_raw), big.mark = ",")))


## ---- 2. Clean FDIC Financials → identify Durbin-affected banks ----

# Clean asset data
fin_clean <- fin_raw %>%
  mutate(
    CERT = as.integer(CERT),
    ASSET = as.numeric(ASSET),  # Assets in thousands
    year = as.integer(substr(REPDTE, 1, 4)),
    asset_billions = ASSET / 1e6  # Convert to billions
  ) %>%
  filter(!is.na(CERT), !is.na(ASSET)) %>%
  select(CERT, year, ASSET, asset_billions)

# Identify Durbin-affected banks: assets > $10B as of June 2010
durbin_banks_2010 <- fin_clean %>%
  filter(year == 2010, asset_billions > 10) %>%
  distinct(CERT) %>%
  pull(CERT)

cat(sprintf("\nDurbin-affected banks (>$10B, June 2010): %d\n", length(durbin_banks_2010)))

# Also track bank size over time for robustness
bank_size_panel <- fin_clean %>%
  mutate(durbin_affected = CERT %in% durbin_banks_2010) %>%
  select(CERT, year, asset_billions, durbin_affected)


## ---- 3. Clean FDIC SOD → county-level branch counts ----

sod_clean <- sod_raw %>%
  mutate(
    CERT = as.integer(CERT),
    YEAR = as.integer(YEAR),
    STCNTYBR = as.character(STCNTYBR),
    DEPSUMBR = as.numeric(DEPSUMBR),
    # Pad FIPS to 5 digits
    county_fips = str_pad(STCNTYBR, 5, pad = "0"),
    state_fips  = substr(county_fips, 1, 2),
    # Flag full-service branches (BRSERTYP 11 = full service head office,
    # 12 = full service branch)
    is_full_service = BRSERTYP %in% c(11, 12),
    # Flag Durbin-affected bank
    is_durbin_bank = CERT %in% durbin_banks_2010
  ) %>%
  filter(
    !is.na(county_fips),
    county_fips != "00000",
    nchar(county_fips) == 5,
    YEAR >= 2005, YEAR <= 2019
  )

cat(sprintf("SOD cleaned: %s records\n", format(nrow(sod_clean), big.mark = ",")))

# County × year panel: branch counts and deposits
county_branches <- sod_clean %>%
  group_by(county_fips, state_fips, YEAR) %>%
  summarise(
    n_branches_total    = n(),
    n_branches_full     = sum(is_full_service),
    n_branches_durbin   = sum(is_durbin_bank),
    n_branches_exempt   = sum(!is_durbin_bank),
    deposits_total      = sum(DEPSUMBR, na.rm = TRUE),
    deposits_durbin     = sum(DEPSUMBR[is_durbin_bank], na.rm = TRUE),
    deposits_exempt     = sum(DEPSUMBR[!is_durbin_bank], na.rm = TRUE),
    n_banks_unique      = n_distinct(CERT),
    n_durbin_banks      = n_distinct(CERT[is_durbin_bank]),
    .groups = "drop"
  ) %>%
  rename(year = YEAR)


## ---- 4. Construct Durbin Exposure Measure ----
## Treatment intensity = pre-Durbin (2010) share of county deposits in
## banks with assets > $10B

durbin_exposure <- county_branches %>%
  filter(year == 2010) %>%
  mutate(
    durbin_exposure = deposits_durbin / deposits_total,
    durbin_exposure = ifelse(is.nan(durbin_exposure) | is.na(durbin_exposure),
                             0, durbin_exposure)
  ) %>%
  select(county_fips, durbin_exposure, deposits_total_2010 = deposits_total,
         n_branches_2010 = n_branches_total)

cat(sprintf("\nDurbin exposure distribution:\n"))
cat(sprintf("  Mean: %.3f\n", mean(durbin_exposure$durbin_exposure)))
cat(sprintf("  Median: %.3f\n", median(durbin_exposure$durbin_exposure)))
cat(sprintf("  SD: %.3f\n", sd(durbin_exposure$durbin_exposure)))
cat(sprintf("  Min: %.3f, Max: %.3f\n",
            min(durbin_exposure$durbin_exposure),
            max(durbin_exposure$durbin_exposure)))
cat(sprintf("  Counties with exposure > 0: %d / %d\n",
            sum(durbin_exposure$durbin_exposure > 0),
            nrow(durbin_exposure)))


## ---- 5. Clean QCEW → county banking employment ----

# Add estabs column if missing
if (!"annual_avg_estabs_count" %in% names(qcew_raw)) {
  qcew_raw$annual_avg_estabs_count <- NA_real_
}

qcew_clean <- qcew_raw %>%
  mutate(
    county_fips = str_pad(area_fips, 5, pad = "0"),
    state_fips  = substr(county_fips, 1, 2),
    employment  = as.numeric(annual_avg_emplvl),
    avg_wage    = as.numeric(annual_avg_wkly_wage),
    n_estabs    = as.numeric(annual_avg_estabs_count),
    year        = as.integer(year)
  ) %>%
  filter(
    !is.na(employment),
    employment > 0,
    nchar(county_fips) == 5,
    county_fips != "00000",
    # Exclude "US" and state-level aggregates
    !grepl("^US|^C[0-9]", area_fips)
  )

# Separate banking from non-banking for DDD
qcew_banking <- qcew_clean %>%
  filter(industry_code == "522110") %>%
  select(county_fips, state_fips, year,
         bank_emp = employment, bank_wage = avg_wage,
         bank_estabs = n_estabs)

qcew_retail <- qcew_clean %>%
  filter(industry_code == "44-45") %>%
  select(county_fips, year,
         retail_emp = employment, retail_wage = avg_wage)

qcew_mfg <- qcew_clean %>%
  filter(industry_code == "31-33") %>%
  select(county_fips, year,
         mfg_emp = employment, mfg_wage = avg_wage)

qcew_health <- qcew_clean %>%
  filter(industry_code == "62") %>%
  select(county_fips, year,
         health_emp = employment, health_wage = avg_wage)

cat(sprintf("\nQCEW banking: %d county-years\n", nrow(qcew_banking)))
cat(sprintf("QCEW retail: %d county-years\n", nrow(qcew_retail)))
cat(sprintf("QCEW manufacturing: %d county-years\n", nrow(qcew_mfg)))


## ---- 6. Clean Population Data ----

pop_clean <- pop_raw %>%
  mutate(
    population = as.numeric(POP),
    county_fips = if ("fips" %in% names(.)) {
      str_pad(fips, 5, pad = "0")
    } else {
      paste0(str_pad(state, 2, pad = "0"), str_pad(county, 3, pad = "0"))
    },
    year = as.integer(year)
  ) %>%
  filter(!is.na(population), population > 0) %>%
  select(county_fips, year, population) %>%
  distinct(county_fips, year, .keep_all = TRUE)

cat(sprintf("Population: %d county-years\n", nrow(pop_clean)))


## ---- 7. Merge into Analysis Panel ----

panel <- county_branches %>%
  # Add Durbin exposure (time-invariant)
  left_join(durbin_exposure %>% select(county_fips, durbin_exposure),
            by = "county_fips") %>%
  # Add banking employment
  left_join(qcew_banking, by = c("county_fips", "state_fips", "year")) %>%
  # Add placebo sectors
  left_join(qcew_retail, by = c("county_fips", "year")) %>%
  left_join(qcew_mfg, by = c("county_fips", "year")) %>%
  left_join(qcew_health, by = c("county_fips", "year")) %>%
  # Add population
  left_join(pop_clean, by = c("county_fips", "year")) %>%
  # Create analysis variables
  mutate(
    # Treatment variables
    post = as.integer(year >= 2012),
    durbin_post = durbin_exposure * post,

    # Per capita measures (per 100,000)
    branches_pc = (n_branches_total / population) * 1e5,
    bank_emp_pc = (bank_emp / population) * 1e5,

    # Log outcomes
    log_branches    = log(n_branches_total + 1),
    log_branches_pc = log(branches_pc + 0.01),
    log_bank_emp    = log(bank_emp + 1),
    log_bank_emp_pc = log(bank_emp_pc + 0.01),
    log_bank_wage   = log(bank_wage + 1),

    # Share measures
    durbin_branch_share = n_branches_durbin / n_branches_total,
    exempt_branch_share = n_branches_exempt / n_branches_total,
    exempt_deposit_share = deposits_exempt / deposits_total,

    # Log deposits
    log_deposits_durbin = log(deposits_durbin + 1),
    log_deposits_exempt = log(deposits_exempt + 1),

    # Exposure quartiles for heterogeneity
    exposure_q = ntile(durbin_exposure, 4),
    exposure_high = as.integer(durbin_exposure > median(durbin_exposure, na.rm = TRUE))
  )

# Drop counties with missing key variables
panel_clean <- panel %>%
  filter(
    !is.na(durbin_exposure),
    !is.na(bank_emp),
    !is.na(population),
    population > 0
  )

cat(sprintf("\n=== Final panel ===\n"))
cat(sprintf("Observations: %s\n", format(nrow(panel_clean), big.mark = ",")))
cat(sprintf("Counties: %d\n", n_distinct(panel_clean$county_fips)))
cat(sprintf("States: %d\n", n_distinct(panel_clean$state_fips)))
cat(sprintf("Years: %d (%d to %d)\n",
            n_distinct(panel_clean$year),
            min(panel_clean$year), max(panel_clean$year)))


## ---- 8. Summary Statistics ----

cat("\n--- Summary Statistics ---\n")
panel_clean %>%
  summarise(
    across(c(durbin_exposure, n_branches_total, bank_emp, bank_wage,
             population, branches_pc, bank_emp_pc),
           list(mean = ~mean(.x, na.rm = TRUE),
                sd   = ~sd(.x, na.rm = TRUE),
                min  = ~min(.x, na.rm = TRUE),
                max  = ~max(.x, na.rm = TRUE)))
  ) %>%
  pivot_longer(everything()) %>%
  print(n = 30)


## ---- 9. Save ----

saveRDS(panel_clean, file.path(data_dir, "analysis_panel.rds"))
saveRDS(durbin_exposure, file.path(data_dir, "durbin_exposure.rds"))
saveRDS(bank_size_panel, file.path(data_dir, "bank_size_panel.rds"))

cat("\nSaved analysis_panel.rds, durbin_exposure.rds, bank_size_panel.rds\n")
cat("=== Data cleaning complete ===\n")
