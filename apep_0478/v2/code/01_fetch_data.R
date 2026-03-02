# =============================================================================
# 01_fetch_data.R — Going Up Alone (apep_0478)
# Fetch elevator operator and building service worker data from Azure Census
# =============================================================================

source("00_packages.R")
source("../../../../scripts/lib/azure_data.R")

cat("\n========================================\n")
cat("FETCHING DATA FROM AZURE\n")
cat("========================================\n\n")

con <- apep_azure_connect()

# ─────────────────────────────────────────────────────────────────────────────
# NYC county FIPS codes (COUNTYICP values)
# New York County (Manhattan) = 610
# Kings County (Brooklyn) = 470
# Queens County = 810
# Bronx County = 050
# Richmond County (Staten Island) = 850
# ─────────────────────────────────────────────────────────────────────────────

NYC_COUNTIES <- "610, 470, 810, 50, 850"

# ─────────────────────────────────────────────────────────────────────────────
# PART 1: State-level aggregates across all 6 censuses (1900-1950)
# For SCM (using states as units) and descriptive atlas
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 1: Building state-level panel from 6 censuses...\n")

state_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)
  cat(sprintf("  Processing %d (%s)...\n", yr, sample))

  query <- sprintf("
    SELECT
      %d AS year,
      STATEFIP,
      COUNT(*) AS total_pop,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_elevator_ops,
      SUM(CASE WHEN OCC1950 IN (%d, %d, %d, %d, %d, %d) THEN 1 ELSE 0 END) AS n_bldg_service_all,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_janitors,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_porters,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_guards,
      SUM(CASE WHEN OCC1950 > 0 AND OCC1950 < 980 THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      SUM(CASE WHEN OCC1950 = %d AND AGE < 25 THEN 1 ELSE 0 END) AS n_elev_young,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 50 THEN 1 ELSE 0 END) AS n_elev_old,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev,
      SUM(CASE WHEN IND1950 >= 306 AND IND1950 <= 499 THEN 1 ELSE 0 END) AS n_manufacturing,
      SUM(CASE WHEN BPL >= 100 THEN 1 ELSE 0 END) AS n_foreign_born
    FROM 'az://%s'
    GROUP BY STATEFIP
  ",
    yr,
    OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD, OCC_CHARWOMAN, OCC_HOUSEKEEPER,
    OCC_JANITOR, OCC_PORTER, OCC_GUARD,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    blob
  )

  state_panels[[as.character(yr)]] <- apep_azure_query(con, query)
  cat(sprintf("    -> %d states\n", nrow(state_panels[[as.character(yr)]])))
}

state_panel <- rbindlist(state_panels)
cat(sprintf("\nState panel: %d rows\n", nrow(state_panel)))
fwrite(state_panel, file.path(DATA_DIR, "state_panel.csv"))
cat("  Saved: state_panel.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 1b: NYC county-level data (separate from rest of NY state)
# For SCM we need NYC as a distinct unit
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 1b: NYC county-level data...\n")

nyc_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)
  cat(sprintf("  Processing %d...\n", yr))

  query <- sprintf("
    SELECT
      %d AS year,
      CASE WHEN STATEFIP = 36 AND COUNTYICP IN (%s) THEN 1 ELSE 0 END AS is_nyc,
      STATEFIP,
      COUNT(*) AS total_pop,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_elevator_ops,
      SUM(CASE WHEN OCC1950 IN (%d, %d, %d, %d, %d, %d) THEN 1 ELSE 0 END) AS n_bldg_service_all,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_janitors,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_porters,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_guards,
      SUM(CASE WHEN OCC1950 > 0 AND OCC1950 < 980 THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      SUM(CASE WHEN OCC1950 = %d AND AGE < 25 THEN 1 ELSE 0 END) AS n_elev_young,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 50 THEN 1 ELSE 0 END) AS n_elev_old,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev,
      SUM(CASE WHEN IND1950 >= 306 AND IND1950 <= 499 THEN 1 ELSE 0 END) AS n_manufacturing,
      SUM(CASE WHEN BPL >= 100 THEN 1 ELSE 0 END) AS n_foreign_born
    FROM 'az://%s'
    WHERE STATEFIP = 36
    GROUP BY 2, STATEFIP
  ",
    yr, NYC_COUNTIES,
    OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD, OCC_CHARWOMAN, OCC_HOUSEKEEPER,
    OCC_JANITOR, OCC_PORTER, OCC_GUARD,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    blob
  )

  nyc_panels[[as.character(yr)]] <- apep_azure_query(con, query)
}

nyc_detail <- rbindlist(nyc_panels)
fwrite(nyc_detail, file.path(DATA_DIR, "nyc_detail.csv"))
cat("  Saved: nyc_detail.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 2: National-level aggregates for descriptive atlas
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 2: National aggregates...\n")

national_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)
  cat(sprintf("  Processing %d...\n", yr))

  query <- sprintf("
    SELECT
      %d AS year,
      COUNT(*) AS total_pop,
      SUM(CASE WHEN OCC1950 > 0 AND OCC1950 < 980 THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_elevator_ops,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 1 THEN 1 ELSE 0 END) AS n_elev_male,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 1 THEN 1 ELSE 0 END) AS n_elev_white,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      SUM(CASE WHEN OCC1950 = %d AND RACE NOT IN (1, 2) THEN 1 ELSE 0 END) AS n_elev_other_race,
      SUM(CASE WHEN OCC1950 = %d AND AGE < 20 THEN 1 ELSE 0 END) AS n_elev_under20,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 20 AND AGE < 30 THEN 1 ELSE 0 END) AS n_elev_20s,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 30 AND AGE < 40 THEN 1 ELSE 0 END) AS n_elev_30s,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 40 AND AGE < 50 THEN 1 ELSE 0 END) AS n_elev_40s,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 50 AND AGE < 60 THEN 1 ELSE 0 END) AS n_elev_50s,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 60 THEN 1 ELSE 0 END) AS n_elev_60plus,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_janitors,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_porters,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_guards
    FROM 'az://%s'
  ",
    yr,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    OCC_ELEVATOR,
    OCC_JANITOR, OCC_PORTER, OCC_GUARD,
    blob
  )

  national_panels[[as.character(yr)]] <- apep_azure_query(con, query)
}

national <- rbindlist(national_panels)
fwrite(national, file.path(DATA_DIR, "national_aggregates.csv"))
cat("  Saved: national_aggregates.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 3: Industry distribution of elevator operators
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 3: Industry distribution...\n")

ind_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)

  query <- sprintf("
    SELECT
      %d AS year,
      IND1950,
      COUNT(*) AS n_operators
    FROM 'az://%s'
    WHERE OCC1950 = %d
    GROUP BY IND1950
    ORDER BY n_operators DESC
  ", yr, blob, OCC_ELEVATOR)

  ind_panels[[as.character(yr)]] <- apep_azure_query(con, query)
}

ind_dist <- rbindlist(ind_panels)
fwrite(ind_dist, file.path(DATA_DIR, "industry_distribution.csv"))
cat("  Saved: industry_distribution.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 4: Individual-level data for MLP linked panel (1940 → 1950)
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 4: Building linked individual panel (1940→1950)...\n")
cat("  Step 4a: Extract MLP links for 1940→1950...\n")

n_links <- apep_azure_query(con, "
  WITH raw_links AS (
    SELECT histid_1940, histid_1950
    FROM 'az://raw/ipums_mlp/v2/mlp_crosswalk_v2.parquet'
    WHERE histid_1940 IS NOT NULL AND histid_1950 IS NOT NULL
  ),
  dedup AS (
    SELECT histid_1940, histid_1950
    FROM raw_links
    QUALIFY COUNT(*) OVER (PARTITION BY histid_1940) = 1
        AND COUNT(*) OVER (PARTITION BY histid_1950) = 1
  )
  SELECT COUNT(*) AS n_links FROM dedup
")$n_links
cat(sprintf("  Total 1:1 MLP links 1940→1950: %s\n", format(n_links, big.mark = ",")))

cat("  Step 4b: Join crosswalk with Census data for building service workers...\n")

# Extract linked panel for building service workers only
query_linked <- sprintf("
  WITH xwalk AS (
    SELECT histid_1940, histid_1950
    FROM 'az://raw/ipums_mlp/v2/mlp_crosswalk_v2.parquet'
    WHERE histid_1940 IS NOT NULL AND histid_1950 IS NOT NULL
    QUALIFY COUNT(*) OVER (PARTITION BY histid_1940) = 1
        AND COUNT(*) OVER (PARTITION BY histid_1950) = 1
  )
  SELECT
    xw.histid_1940, xw.histid_1950,
    c40.STATEFIP AS statefip_1940,
    c40.COUNTYICP AS countyicp_1940,
    c40.AGE AS age_1940,
    c40.SEX AS sex_1940,
    c40.RACE AS race_1940,
    c40.BPL AS bpl_1940,
    c40.NATIVITY AS nativity_1940,
    c40.MARST AS marst_1940,
    c40.OCC1950 AS occ1950_1940,
    c40.IND1950 AS ind1950_1940,
    c40.SEI AS sei_1940,
    c40.OCCSCORE AS occscore_1940,
    c40.CLASSWKR AS classwkr_1940,
    c50.STATEFIP AS statefip_1950,
    c50.COUNTYICP AS countyicp_1950,
    c50.AGE AS age_1950,
    c50.SEX AS sex_1950,
    c50.RACE AS race_1950,
    c50.OCC1950 AS occ1950_1950,
    c50.IND1950 AS ind1950_1950,
    c50.CLASSWKR AS classwkr_1950,
    c50.OCCSCORE AS occscore_1950,
    c50.AGE - c40.AGE AS age_diff,
    CASE WHEN c40.STATEFIP != c50.STATEFIP THEN 1 ELSE 0 END AS interstate_mover
  FROM xwalk xw
  JOIN 'az://raw/ipums_fullcount/us1940b.parquet' c40
    ON xw.histid_1940 = c40.HISTID
  JOIN 'az://raw/ipums_fullcount/us1950b.parquet' c50
    ON xw.histid_1950 = c50.HISTID
  WHERE ABS((c50.AGE - c40.AGE) - 10) <= 3
    AND c40.OCC1950 IN (%s)
",
  paste(BLDG_SERVICE_OCCS, collapse = ", ")
)

cat("  Running linked panel query (building service workers only)...\n")
linked_bldg <- apep_azure_query(con, query_linked)
cat(sprintf("  Linked building service workers: %s rows\n", format(nrow(linked_bldg), big.mark = ",")))
cat(sprintf("    Elevator operators: %s\n",
    format(sum(linked_bldg$occ1950_1940 == OCC_ELEVATOR), big.mark = ",")))
cat(sprintf("    Janitors: %s\n",
    format(sum(linked_bldg$occ1950_1940 == OCC_JANITOR), big.mark = ",")))
cat(sprintf("    Porters: %s\n",
    format(sum(linked_bldg$occ1950_1940 == OCC_PORTER), big.mark = ",")))
cat(sprintf("    Guards/doorkeepers: %s\n",
    format(sum(linked_bldg$occ1950_1940 == OCC_GUARD), big.mark = ",")))

fwrite(linked_bldg, file.path(DATA_DIR, "linked_bldg_service_1940_1950.csv"))
cat("  Saved: linked_bldg_service_1940_1950.csv\n")

apep_azure_disconnect(con)

cat("\n========================================\n")
cat("DATA FETCH COMPLETE\n")
cat("========================================\n")
cat("Files saved in:", DATA_DIR, "\n")
