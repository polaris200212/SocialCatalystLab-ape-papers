# =============================================================================
# 01c_county_panel.R — Going Up Alone v4 (apep_0478)
# Build county-level panel from full-count census data (1900-1950)
# For geographic maps and metro-level variation analysis
# =============================================================================

source("00_packages.R")
source("../../../../scripts/lib/azure_data.R")

cat("\n========================================\n")
cat("COUNTY-LEVEL PANEL (1900-1950)\n")
cat("========================================\n\n")

con <- apep_azure_connect()

# ─────────────────────────────────────────────────────────────────────────────
# County-level aggregates for all census years
# ─────────────────────────────────────────────────────────────────────────────

county_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)
  cat(sprintf("  Processing %d (%s)...\n", yr, sample))

  query <- sprintf("
    SELECT
      %d AS year,
      STATEFIP,
      COUNTYICP,
      COUNT(*) AS total_pop,
      SUM(CASE WHEN %s THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_elevator_ops,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_janitors,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_porters,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_guards,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev
    FROM 'az://%s'
    WHERE COUNTYICP IS NOT NULL AND COUNTYICP > 0
    GROUP BY STATEFIP, COUNTYICP
    HAVING SUM(CASE WHEN %s THEN 1 ELSE 0 END) >= 100
  ",
    yr,
    OCC1950_EMPLOYED_SQL,
    OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    blob,
    OCC1950_EMPLOYED_SQL
  )

  county_panels[[as.character(yr)]] <- apep_azure_query(con, query)
  cat(sprintf("    -> %d counties with 100+ employed\n",
      nrow(county_panels[[as.character(yr)]])))
}

county_panel <- rbindlist(county_panels)

# Add per-10k rates
county_panel[, `:=`(
  elev_per_10k_emp = ifelse(total_employed > 0,
                            n_elevator_ops / total_employed * 10000, NA)
)]

# Identify metro areas
county_panel <- merge(county_panel, METRO_COUNTIES,
                      by = c("STATEFIP", "COUNTYICP"), all.x = TRUE)
county_panel[, is_metro := !is.na(metro_name)]

cat(sprintf("\nCounty panel: %d rows (%d unique state-county pairs)\n",
    nrow(county_panel),
    county_panel[, uniqueN(paste(STATEFIP, COUNTYICP))]))

# Summary of metro areas
metro_summary <- county_panel[is_metro == TRUE & year == 1940,
                               .(metro_name, n_elevator_ops, total_employed,
                                 elev_per_10k_emp)]
setorder(metro_summary, -n_elevator_ops)
cat("\n  Top metros by elevator operators (1940):\n")
print(metro_summary)

fwrite(county_panel, file.path(DATA_DIR, "county_panel.csv"))
cat("\n  Saved: county_panel.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# Metro-level summary panel (top ~25 metros across all years)
# ─────────────────────────────────────────────────────────────────────────────

metro_panel <- county_panel[is_metro == TRUE, .(
  year, metro_name, STATEFIP, COUNTYICP,
  n_elevator_ops, total_employed, total_pop,
  elev_per_10k_emp, n_elev_female, n_elev_black, mean_age_elev
)]

fwrite(metro_panel, file.path(DATA_DIR, "metro_panel.csv"))
cat("  Saved: metro_panel.csv\n")

apep_azure_disconnect(con)

cat("\n========================================\n")
cat("COUNTY-LEVEL PANEL COMPLETE\n")
cat("========================================\n")
