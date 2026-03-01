# =============================================================================
# 01_fetch_data.R — Going Up Alone v4 (apep_0478)
# Fetch elevator operator and building service worker data from Azure Census
# v4: OCC1950 special code cleaning applied to all employed denominators
# =============================================================================

source("00_packages.R")
source("../../../../scripts/lib/azure_data.R")

cat("\n========================================\n")
cat("FETCHING DATA FROM AZURE (v4 — cleaned denominators)\n")
cat("========================================\n\n")

con <- apep_azure_connect()

NYC_COUNTIES <- paste(NYC_COUNTYICP, collapse = ", ")

# ─────────────────────────────────────────────────────────────────────────────
# PART 1: State-level aggregates across all 6 censuses (1900-1950)
# v4: Uses OCC1950_EMPLOYED_SQL for cleaned denominator
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 1: Building state-level panel from 6 censuses...\n")
cat("  NOTE: Excluding OCC1950 special codes (0, 979-999) from employed counts\n\n")

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
      SUM(CASE WHEN %s THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      SUM(CASE WHEN OCC1950 = %d AND AGE < 25 THEN 1 ELSE 0 END) AS n_elev_young,
      SUM(CASE WHEN OCC1950 = %d AND AGE >= 50 THEN 1 ELSE 0 END) AS n_elev_old,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev,
      SUM(CASE WHEN IND1950 >= 306 AND IND1950 <= 499 THEN 1 ELSE 0 END) AS n_manufacturing,
      SUM(CASE WHEN BPL >= 100 THEN 1 ELSE 0 END) AS n_foreign_born,
      -- v4: Track special code counts for validation
      SUM(CASE WHEN OCC1950 = 0 THEN 1 ELSE 0 END) AS n_occ_zero,
      SUM(CASE WHEN OCC1950 = 979 THEN 1 ELSE 0 END) AS n_occ_979,
      SUM(CASE WHEN OCC1950 >= 980 AND OCC1950 <= 987 THEN 1 ELSE 0 END) AS n_occ_980_987,
      SUM(CASE WHEN OCC1950 = 990 THEN 1 ELSE 0 END) AS n_occ_990,
      SUM(CASE WHEN OCC1950 = 995 THEN 1 ELSE 0 END) AS n_occ_995,
      SUM(CASE WHEN OCC1950 = 999 THEN 1 ELSE 0 END) AS n_occ_999
    FROM 'az://%s'
    GROUP BY STATEFIP
  ",
    yr,
    OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD, OCC_CHARWOMAN, OCC_HOUSEKEEPER,
    OCC_JANITOR, OCC_PORTER, OCC_GUARD,
    OCC1950_EMPLOYED_SQL,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    blob
  )

  state_panels[[as.character(yr)]] <- apep_azure_query(con, query)
  cat(sprintf("    -> %d states\n", nrow(state_panels[[as.character(yr)]])))
}

state_panel <- rbindlist(state_panels)

# Report special code exclusion impact
special_codes_national <- state_panel[, .(
  n_occ_zero = sum(n_occ_zero),
  n_occ_979 = sum(n_occ_979),
  n_occ_980_987 = sum(n_occ_980_987),
  n_occ_990 = sum(n_occ_990),
  n_occ_995 = sum(n_occ_995),
  n_occ_999 = sum(n_occ_999),
  total_pop = sum(total_pop),
  total_employed = sum(total_employed)
), by = year]
special_codes_national[, pct_excluded := (total_pop - total_employed) / total_pop * 100]
cat("\n  Special code exclusion impact by year:\n")
print(special_codes_national[, .(year, total_pop, total_employed, pct_excluded,
                                  n_occ_979, n_occ_999)])

cat(sprintf("\nState panel: %d rows\n", nrow(state_panel)))
fwrite(state_panel, file.path(DATA_DIR, "state_panel.csv"))
cat("  Saved: state_panel.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 1b: NYC borough-level data
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 1b: NYC borough-level data...\n")

nyc_panels <- list()

for (yr in YEARS) {
  sample <- SAMPLES[as.character(yr)]
  blob <- sprintf("raw/ipums_fullcount/%s.parquet", sample)
  cat(sprintf("  Processing %d...\n", yr))

  query <- sprintf("
    SELECT
      %d AS year,
      COUNTYICP,
      COUNT(*) AS total_pop,
      SUM(CASE WHEN OCC1950 = %d THEN 1 ELSE 0 END) AS n_elevator_ops,
      SUM(CASE WHEN OCC1950 IN (%d, %d, %d, %d, %d, %d) THEN 1 ELSE 0 END) AS n_bldg_service_all,
      SUM(CASE WHEN %s THEN 1 ELSE 0 END) AS total_employed,
      SUM(CASE WHEN OCC1950 = %d AND SEX = 2 THEN 1 ELSE 0 END) AS n_elev_female,
      SUM(CASE WHEN OCC1950 = %d AND RACE = 2 THEN 1 ELSE 0 END) AS n_elev_black,
      AVG(CASE WHEN OCC1950 = %d THEN CAST(AGE AS DOUBLE) ELSE NULL END) AS mean_age_elev
    FROM 'az://%s'
    WHERE STATEFIP = 36 AND COUNTYICP IN (%s)
    GROUP BY COUNTYICP
  ",
    yr,
    OCC_ELEVATOR,
    OCC_ELEVATOR, OCC_JANITOR, OCC_PORTER, OCC_GUARD, OCC_CHARWOMAN, OCC_HOUSEKEEPER,
    OCC1950_EMPLOYED_SQL,
    OCC_ELEVATOR, OCC_ELEVATOR, OCC_ELEVATOR,
    blob, NYC_COUNTIES
  )

  nyc_panels[[as.character(yr)]] <- apep_azure_query(con, query)
}

nyc_detail <- rbindlist(nyc_panels)
# Add borough names
borough_names <- data.table(
  COUNTYICP = NYC_COUNTYICP,
  borough = c("Manhattan", "Brooklyn", "Queens", "Bronx", "Staten Island")
)
nyc_detail <- merge(nyc_detail, borough_names, by = "COUNTYICP", all.x = TRUE)
fwrite(nyc_detail, file.path(DATA_DIR, "nyc_borough_detail.csv"))
cat("  Saved: nyc_borough_detail.csv\n")

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
      SUM(CASE WHEN %s THEN 1 ELSE 0 END) AS total_employed,
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
    OCC1950_EMPLOYED_SQL,
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

fwrite(linked_bldg, file.path(DATA_DIR, "linked_bldg_service_1940_1950.csv"))
cat("  Saved: linked_bldg_service_1940_1950.csv\n")

# ─────────────────────────────────────────────────────────────────────────────
# PART 5: Entry analysis — who BECAME an elevator operator between censuses?
# v4 new: Track people who were NOT elevator operators in 1940 but WERE in 1950
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 5: Entry analysis (1940→1950)...\n")

query_entrants <- "
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
    c40.MARST AS marst_1940,
    c40.OCC1950 AS occ1950_1940,
    c40.OCCSCORE AS occscore_1940,
    c50.OCC1950 AS occ1950_1950,
    c50.OCCSCORE AS occscore_1950,
    c50.STATEFIP AS statefip_1950
  FROM xwalk xw
  JOIN 'az://raw/ipums_fullcount/us1940b.parquet' c40
    ON xw.histid_1940 = c40.HISTID
  JOIN 'az://raw/ipums_fullcount/us1950b.parquet' c50
    ON xw.histid_1950 = c50.HISTID
  WHERE ABS((c50.AGE - c40.AGE) - 10) <= 3
    AND c40.OCC1950 != 761
    AND c50.OCC1950 = 761
"

entrants <- apep_azure_query(con, query_entrants)
cat(sprintf("  People who entered elevator operation by 1950: %s\n",
    format(nrow(entrants), big.mark = ",")))
fwrite(entrants, file.path(DATA_DIR, "entrants_1940_1950.csv"))
cat("  Saved: entrants_1940_1950.csv\n")

apep_azure_disconnect(con)

cat("\n========================================\n")
cat("DATA FETCH COMPLETE\n")
cat("========================================\n")
cat("Files saved in:", DATA_DIR, "\n")
