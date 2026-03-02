## ============================================================================
## 02_clean_data.R — Construct Bartik IV, treatment variables, analysis sample
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

## ---- 1. Load data ----
panel <- readRDS(file.path(DATA, "panel_county_quarter.rds"))
qcew_shares <- readRDS(file.path(DATA, "qcew_2018_shares.rds"))
qcew_national <- readRDS(file.path(DATA, "qcew_national_quarterly.rds"))

cat(sprintf("Panel: %d rows\n", nrow(panel)))
cat(sprintf("QCEW 2018 shares: %d rows\n", nrow(qcew_shares)))
cat(sprintf("QCEW national: %d rows\n", nrow(qcew_national)))

## ---- 2. Get 2018 county industry shares for Bartik ----

# From QCEW 2018 annual singlefile: county × 2-digit NAICS employment
qcew_ind <- qcew_shares[agglvl_code == 74, .(
  county_fips = as.character(area_fips),
  industry = as.character(industry_code),
  emp = as.numeric(annual_avg_emplvl)
)]
qcew_ind <- qcew_ind[!is.na(emp) & emp >= 0]
cat(sprintf("QCEW 2018 industry detail: %d rows, %d industries, %d counties\n",
            nrow(qcew_ind), uniqueN(qcew_ind$industry), uniqueN(qcew_ind$county_fips)))

## ---- 3. Construct Bartik shift-share instrument ----
cat("Constructing Bartik instrument...\n")

# Step 1: Base-period shares (2018 annual average)
base_emp <- copy(qcew_ind)
setnames(base_emp, "emp", "base_emp")

# Total base employment per county
base_total <- base_emp[, .(base_total = sum(base_emp, na.rm = TRUE)), by = county_fips]
base_emp <- merge(base_emp, base_total, by = "county_fips")
base_emp[, share := base_emp / base_total]

cat(sprintf("  Base shares: %d county-industries, %d counties\n",
            nrow(base_emp), uniqueN(base_emp$county_fips)))

# Step 2: National industry growth rates from QCEW national quarterly data
national_ind <- qcew_national[, .(
  industry = as.character(industry_code),
  year = as.integer(year),
  quarter = as.integer(qtr),
  nat_emp = as.numeric(month3_emplvl)
)]
national_ind <- national_ind[!is.na(nat_emp) & nat_emp > 0]

# Compute growth relative to 2018 baseline (average of 4 quarters)
national_base <- national_ind[year == 2018, .(
  nat_base = mean(nat_emp, na.rm = TRUE)
), by = industry]

national_ind <- merge(national_ind, national_base, by = "industry")
national_ind[, nat_growth := (nat_emp - nat_base) / nat_base]

cat(sprintf("  National growth: %d industry-quarters, %d industries\n",
            nrow(national_ind), uniqueN(national_ind$industry)))

# Step 3: Construct predicted employment (Bartik)
bartik_list <- list()
for (yr in 2018:2024) {
  for (qtr in 1:4) {
    nat_q <- national_ind[year == yr & quarter == qtr, .(industry, nat_growth)]
    if (nrow(nat_q) == 0) next

    # For each county: sum of (base share_k * national growth_k)
    bk <- merge(base_emp[, .(county_fips, industry, share)], nat_q, by = "industry")
    bk_county <- bk[, .(
      bartik = sum(share * nat_growth, na.rm = TRUE)
    ), by = county_fips]
    bk_county[, year := yr]
    bk_county[, quarter := qtr]
    bartik_list[[length(bartik_list) + 1]] <- bk_county
  }
}

bartik <- rbindlist(bartik_list)
cat(sprintf("Bartik instrument: %d county-quarters\n", nrow(bartik)))

# Also construct Bartik excluding healthcare (NAICS 62)
base_emp_no62 <- base_emp[industry != "62"]
base_total_no62 <- base_emp_no62[, .(base_total_no62 = sum(base_emp, na.rm = TRUE)), by = county_fips]
base_emp_no62 <- merge(base_emp_no62, base_total_no62, by = "county_fips")
base_emp_no62[, share_no62 := base_emp / base_total_no62]

bartik_no62_list <- list()
for (yr in 2018:2024) {
  for (qtr in 1:4) {
    nat_q <- national_ind[year == yr & quarter == qtr &
                            industry != "62", .(industry, nat_growth)]
    if (nrow(nat_q) == 0) next
    bk <- merge(base_emp_no62[, .(county_fips, industry, share_no62)],
                nat_q, by = "industry")
    bk_county <- bk[, .(
      bartik_no62 = sum(share_no62 * nat_growth, na.rm = TRUE)
    ), by = county_fips]
    bk_county[, year := yr]
    bk_county[, quarter := qtr]
    bartik_no62_list[[length(bartik_no62_list) + 1]] <- bk_county
  }
}

bartik_no62 <- rbindlist(bartik_no62_list)

## ---- 4. Merge Bartik into panel ----
panel <- merge(panel, bartik, by = c("county_fips", "year", "quarter"), all.x = TRUE)
panel <- merge(panel, bartik_no62, by = c("county_fips", "year", "quarter"), all.x = TRUE)

## ---- 5. Construct treatment/outcome variables ----

# Employment-to-population ratio (labor market tightness proxy)
# total_emp comes from QWI (already merged in 01_fetch_data.R)
panel[, emp_pop := fifelse(population > 0 & !is.na(total_emp),
                            total_emp / population, NA_real_)]

# Log outcomes (add 1 for zeros)
panel[, ln_hcbs_providers := log(hcbs_providers + 1)]
panel[, ln_hcbs_claims := log(hcbs_claims + 1)]
panel[, ln_hcbs_paid := log(hcbs_paid + 1)]
panel[, ln_hcbs_benes := log(hcbs_benes + 1)]

# Claims per beneficiary (intensive margin)
panel[, claims_per_bene := fifelse(hcbs_benes > 0, hcbs_claims / hcbs_benes, NA_real_)]

# Placebo outcomes
panel[, ln_non_hcbs_providers := log(non_hcbs_providers + 1)]
panel[, ln_non_hcbs_paid := log(non_hcbs_paid + 1)]

# State x quarter FE identifier
panel[, state_qtr := paste(state_fips, year, quarter, sep = "_")]

# Time variable (for fixest)
panel[, time_id := (year - 2018) * 4 + quarter]

## ---- 6. Define analysis sample ----

# Drop counties with:
# - Missing employment data
# - Population < 1000 (too small for stable HCBS supply)
# - Missing Bartik instrument
panel[, in_sample := !is.na(emp_pop) & !is.na(bartik) &
        !is.na(population) & population >= 1000 &
        !is.na(county_fips)]

cat(sprintf("\nSample restriction:\n"))
cat(sprintf("  Total county-quarters: %d\n", nrow(panel)))
cat(sprintf("  In-sample: %d (%.1f%%)\n", sum(panel$in_sample),
            100 * mean(panel$in_sample)))
cat(sprintf("  Counties in sample: %d\n", uniqueN(panel[in_sample == TRUE]$county_fips)))

# Create RUCC (Rural-Urban Continuum Code) proxy from population
panel[, urban := fifelse(population >= 50000, 1L, 0L)]

## ---- 7. Summary statistics ----
cat("\nSummary of analysis variables (in-sample):\n")
smpl <- panel[in_sample == TRUE]
vars <- c("hcbs_providers", "hcbs_claims", "hcbs_paid", "hcbs_benes",
           "emp_pop", "total_emp", "bartik",
           "population", "poverty_rate", "elderly_share")
for (v in vars) {
  if (v %in% names(smpl)) {
    x <- smpl[[v]]
    x <- x[!is.na(x)]
    cat(sprintf("  %-25s mean=%-12.2f sd=%-12.2f N=%d\n",
                v, mean(x), sd(x), length(x)))
  }
}

## ---- 8. Save analysis panel ----
saveRDS(panel, file.path(DATA, "analysis_panel.rds"))

# Save base-period industry shares for later Bartik diagnostics
saveRDS(base_emp, file.path(DATA, "base_industry_shares.rds"))
saveRDS(national_ind, file.path(DATA, "national_industry_growth.rds"))

cat("\n=== Data cleaning complete ===\n")
