# =============================================================================
# 01_fetch_data.R — Fetch panel data from Azure for descriptive analysis
# =============================================================================
# Queries the derived MLP panel files on Azure + raw census files for
# population denominators. Saves local summaries for paper analysis.
# =============================================================================

source("00_packages.R")
source(file.path(REPO_ROOT, "scripts/lib/azure_data.R"))

con <- apep_azure_connect()

# --- Decade pairs ---
DECADE_PAIRS <- list(
  c(1900L, 1910L), c(1910L, 1920L), c(1920L, 1930L),
  c(1930L, 1940L), c(1940L, 1950L)
)

CENSUS_SAMPLES <- c(
  "1900" = "us1900m", "1910" = "us1910m", "1920" = "us1920c",
  "1930" = "us1930d", "1940" = "us1940b", "1950" = "us1950b"
)

# Helper: panel file path (1940-1950 split into 2 parts due to Azure block limit)
panel_path <- function(y1, y2) {
  if (y1 == 1940L && y2 == 1950L) {
    "derived/mlp_panel/linked_1940_1950_part*.parquet"
  } else {
    sprintf("derived/mlp_panel/linked_%d_%d.parquet", y1, y2)
  }
}

# =============================================================================
# 1. Panel summary statistics (row counts, column counts)
# =============================================================================
cat("\n=== Panel Summary ===\n")

panel_summary <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  res <- apep_azure_query(con, sprintf(
    "SELECT COUNT(*) AS n_rows FROM 'az://%s'", path
  ))

  cols <- apep_azure_query(con, sprintf(
    "SELECT column_name FROM (DESCRIBE SELECT * FROM 'az://%s')", path
  ))

  panel_summary <- bind_rows(panel_summary, tibble(
    pair = sprintf("%d-%d", y1, y2),
    y1 = y1, y2 = y2,
    n_rows = res$n_rows,
    n_cols = nrow(cols)
  ))
  cat(sprintf("  %d→%d: %s rows, %d columns\n", y1, y2, fmt(res$n_rows), nrow(cols)))
}

# Three-census panel
res3 <- apep_azure_query(con,
  "SELECT COUNT(*) AS n_rows FROM 'az://derived/mlp_panel/linked_1920_1930_1940.parquet'"
)
cat(sprintf("  1920→1930→1940 (balanced): %s rows\n", fmt(res3$n_rows)))

panel_summary <- bind_rows(panel_summary, tibble(
  pair = "1920-1930-1940", y1 = 1920L, y2 = 1940L,
  n_rows = res3$n_rows, n_cols = NA_integer_
))

saveRDS(panel_summary, file.path(DATA_DIR, "panel_summary.rds"))

# =============================================================================
# 2. Census population denominators (for link rates)
# =============================================================================
cat("\n=== Census Population Counts ===\n")

census_pop <- tibble()
for (yr in names(CENSUS_SAMPLES)) {
  sample <- CENSUS_SAMPLES[yr]
  path <- sprintf("raw/ipums_fullcount/%s.parquet", sample)

  res <- apep_azure_query(con, sprintf(
    "SELECT COUNT(*) AS n_total,
            SUM(CASE WHEN SEX = 1 THEN 1 ELSE 0 END) AS n_male,
            SUM(CASE WHEN SEX = 2 THEN 1 ELSE 0 END) AS n_female,
            SUM(CASE WHEN RACE = 1 THEN 1 ELSE 0 END) AS n_white,
            SUM(CASE WHEN RACE = 2 THEN 1 ELSE 0 END) AS n_black,
            AVG(AGE) AS mean_age
     FROM 'az://%s'", path
  ))

  census_pop <- bind_rows(census_pop, tibble(
    year = as.integer(yr),
    n_total = res$n_total,
    n_male = res$n_male,
    n_female = res$n_female,
    n_white = res$n_white,
    n_black = res$n_black,
    mean_age = res$mean_age
  ))
  cat(sprintf("  %s: %s total\n", yr, fmt(res$n_total)))
}

saveRDS(census_pop, file.path(DATA_DIR, "census_pop.rds"))

# =============================================================================
# 3. Link rates by demographics (from diagnostics file if available,
#    otherwise compute directly)
# =============================================================================
cat("\n=== Link Rate Diagnostics ===\n")

# Try the pre-built diagnostics file first
diag_exists <- tryCatch({
  apep_azure_query(con,
    "SELECT COUNT(*) AS n FROM 'az://derived/mlp_panel/link_diagnostics.parquet'"
  )
  TRUE
}, error = function(e) FALSE)

if (diag_exists) {
  link_diag <- apep_azure_read(con, "derived/mlp_panel/link_diagnostics.parquet")
  cat("  Loaded pre-built diagnostics:", fmt(nrow(link_diag)), "rows\n")
} else {
  cat("  Pre-built diagnostics not found. Computing from panel files...\n")

  link_diag <- tibble()
  for (pair in DECADE_PAIRS) {
    y1 <- pair[1]; y2 <- pair[2]
    pp <- panel_path(y1, y2)
    census_path <- sprintf("raw/ipums_fullcount/%s.parquet", CENSUS_SAMPLES[as.character(y1)])

    # Link rates by state, race, sex
    q <- sprintf("
      WITH linked AS (
        SELECT statefip_%d AS statefip,
               race_%d AS race,
               sex_%d AS sex,
               age_%d AS age
        FROM 'az://%s'
      ),
      pop AS (
        SELECT STATEFIP AS statefip, RACE AS race, SEX AS sex, AGE AS age
        FROM 'az://%s'
      ),
      linked_agg AS (
        SELECT statefip, race, sex,
               CASE WHEN age < 20 THEN '0-19'
                    WHEN age < 40 THEN '20-39'
                    WHEN age < 60 THEN '40-59'
                    ELSE '60+' END AS age_group,
               COUNT(*) AS n_linked
        FROM linked
        GROUP BY statefip, race, sex, age_group
      ),
      pop_agg AS (
        SELECT statefip, race, sex,
               CASE WHEN age < 20 THEN '0-19'
                    WHEN age < 40 THEN '20-39'
                    WHEN age < 60 THEN '40-59'
                    ELSE '60+' END AS age_group,
               COUNT(*) AS n_total
        FROM pop
        GROUP BY statefip, race, sex, age_group
      )
      SELECT p.statefip, p.race, p.sex, p.age_group,
             p.n_total, COALESCE(l.n_linked, 0) AS n_linked,
             COALESCE(l.n_linked, 0) * 1.0 / p.n_total AS link_rate
      FROM pop_agg p
      LEFT JOIN linked_agg l
        ON p.statefip = l.statefip AND p.race = l.race
        AND p.sex = l.sex AND p.age_group = l.age_group
    ", y1, y1, y1, y1, pp, census_path)

    res <- apep_azure_query(con, q)
    res$pair <- sprintf("%d_%d", y1, y2)
    link_diag <- bind_rows(link_diag, res)
    cat(sprintf("    %d→%d: computed link rates for %d cells\n", y1, y2, nrow(res)))
  }
}

saveRDS(link_diag, file.path(DATA_DIR, "link_diagnostics.rds"))

# =============================================================================
# 4. Descriptive statistics from panels (occupational mobility, migration, etc.)
# =============================================================================
cat("\n=== Panel Descriptive Statistics ===\n")

panel_desc <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  # Build query based on available variables
  # SEI only available in 1920, 1930, 1940 (not 1900, 1910, or 1950)
  sei_years <- c(1920L, 1930L, 1940L)
  has_sei <- (y1 %in% sei_years) && (y2 %in% sei_years)

  sei_clause <- if (has_sei) {
    sprintf(
      "AVG(sei_%d) AS mean_sei_y1,
       AVG(sei_%d) AS mean_sei_y2,
       AVG(sei_%d - sei_%d) AS mean_delta_sei,
       STDDEV(sei_%d - sei_%d) AS sd_delta_sei,",
      y1, y2, y2, y1, y2, y1
    )
  } else { "" }

  q <- sprintf("
    SELECT
      COUNT(*) AS n,
      AVG(age_%d) AS mean_age_y1,
      AVG(age_%d) AS mean_age_y2,
      %s
      SUM(CASE WHEN statefip_%d != statefip_%d THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS mover_rate,
      SUM(CASE WHEN sex_%d = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_male,
      SUM(CASE WHEN race_%d = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_white,
      SUM(CASE WHEN farm_%d = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_farm_y1,
      SUM(CASE WHEN farm_%d = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_farm_y2,
      SUM(CASE WHEN farm_%d = 2 AND farm_%d != 2 THEN 1 ELSE 0 END) * 1.0 /
        NULLIF(SUM(CASE WHEN farm_%d = 2 THEN 1 ELSE 0 END), 0) AS farm_exit_rate,
      SUM(CASE WHEN marst_%d >= 1 AND marst_%d <= 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_married_y1,
      SUM(CASE WHEN marst_%d >= 1 AND marst_%d <= 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_married_y2
    FROM 'az://%s'
  ", y1, y2, sei_clause, y1, y2, y1, y1, y1, y2, y1, y2, y1, y1, y1, y2, y2, path)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  res$y1 <- y1; res$y2 <- y2
  panel_desc <- bind_rows(panel_desc, res)

  cat(sprintf("  %d→%d: N=%s, mover_rate=%.1f%%, male=%.1f%%\n",
              y1, y2, fmt(res$n), res$mover_rate * 100, res$pct_male * 100))
}

saveRDS(panel_desc, file.path(DATA_DIR, "panel_desc.rds"))

# =============================================================================
# 5. Occupation transition data (top occupation groups)
# =============================================================================
cat("\n=== Occupation Transitions ===\n")

# Use OCC1950 major groups
# 000-099: Professional
# 100-199: Farmers/farm managers
# 200-299: Managers
# 300-399: Clerical
# 400-499: Sales
# 500-599: Craftsmen
# 600-699: Operatives
# 700-799: Service
# 800-899: Farm laborers
# 900-970: Laborers

occ_transitions <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  q <- sprintf("
    SELECT
      CASE
        WHEN occ1950_%d < 100 THEN 'Professional'
        WHEN occ1950_%d < 200 THEN 'Farmer'
        WHEN occ1950_%d < 300 THEN 'Manager'
        WHEN occ1950_%d < 400 THEN 'Clerical'
        WHEN occ1950_%d < 500 THEN 'Sales'
        WHEN occ1950_%d < 600 THEN 'Craftsman'
        WHEN occ1950_%d < 700 THEN 'Operative'
        WHEN occ1950_%d < 800 THEN 'Service'
        WHEN occ1950_%d < 900 THEN 'Farm laborer'
        WHEN occ1950_%d <= 970 THEN 'Laborer'
        ELSE 'Other'
      END AS occ_y1,
      CASE
        WHEN occ1950_%d < 100 THEN 'Professional'
        WHEN occ1950_%d < 200 THEN 'Farmer'
        WHEN occ1950_%d < 300 THEN 'Manager'
        WHEN occ1950_%d < 400 THEN 'Clerical'
        WHEN occ1950_%d < 500 THEN 'Sales'
        WHEN occ1950_%d < 600 THEN 'Craftsman'
        WHEN occ1950_%d < 700 THEN 'Operative'
        WHEN occ1950_%d < 800 THEN 'Service'
        WHEN occ1950_%d < 900 THEN 'Farm laborer'
        WHEN occ1950_%d <= 970 THEN 'Laborer'
        ELSE 'Other'
      END AS occ_y2,
      COUNT(*) AS n
    FROM 'az://%s'
    WHERE occ1950_%d <= 970 AND occ1950_%d <= 970
    GROUP BY occ_y1, occ_y2
    ORDER BY n DESC
  ", y1, y1, y1, y1, y1, y1, y1, y1, y1, y1,
     y2, y2, y2, y2, y2, y2, y2, y2, y2, y2,
     path, y1, y2)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  occ_transitions <- bind_rows(occ_transitions, res)

  # Compute switching rate
  same <- sum(res$n[res$occ_y1 == res$occ_y2])
  total <- sum(res$n)
  cat(sprintf("  %d→%d: %s workers, %.1f%% switched occupation group\n",
              y1, y2, fmt(total), (1 - same/total) * 100))
}

saveRDS(occ_transitions, file.path(DATA_DIR, "occ_transitions.rds"))

# =============================================================================
# 6. Migration patterns (top state-to-state flows)
# =============================================================================
cat("\n=== Migration Patterns ===\n")

migration <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  q <- sprintf("
    SELECT statefip_%d AS origin, statefip_%d AS dest, COUNT(*) AS n
    FROM 'az://%s'
    WHERE statefip_%d != statefip_%d
    GROUP BY origin, dest
    ORDER BY n DESC
    LIMIT 50
  ", y1, y2, path, y1, y2)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  migration <- bind_rows(migration, res)
  cat(sprintf("  %d→%d: top flow %d→%d (%s movers)\n",
              y1, y2, res$origin[1], res$dest[1], fmt(res$n[1])))
}

saveRDS(migration, file.path(DATA_DIR, "migration_flows.rds"))

# =============================================================================
# 7. Link rate by state (for maps)
# =============================================================================
cat("\n=== State-Level Link Rates ===\n")

state_link_rates <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  pp <- panel_path(y1, y2)
  cp <- sprintf("raw/ipums_fullcount/%s.parquet", CENSUS_SAMPLES[as.character(y1)])

  q <- sprintf("
    WITH linked AS (
      SELECT statefip_%d AS statefip, COUNT(*) AS n_linked
      FROM 'az://%s'
      GROUP BY statefip
    ),
    pop AS (
      SELECT STATEFIP AS statefip, COUNT(*) AS n_total
      FROM 'az://%s'
      GROUP BY statefip
    )
    SELECT p.statefip, p.n_total, COALESCE(l.n_linked, 0) AS n_linked,
           COALESCE(l.n_linked, 0) * 1.0 / p.n_total AS link_rate
    FROM pop p
    LEFT JOIN linked l ON p.statefip = l.statefip
    ORDER BY p.statefip
  ", y1, pp, cp)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  state_link_rates <- bind_rows(state_link_rates, res)
}

saveRDS(state_link_rates, file.path(DATA_DIR, "state_link_rates.rds"))

# =============================================================================
# 8. ABE crosswalk comparison
# =============================================================================
cat("\n=== ABE Crosswalk Comparison ===\n")

# Only compare ABE pairs where we have a matching MLP decade-pair panel
# 1920→1940 ABE crosswalk exists but no MLP decade pair (20-year span)
ABE_PAIRS <- list(c(1920L, 1930L), c(1930L, 1940L))

abe_comparison <- tibble()
for (pair in ABE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]

  # MLP link count
  mlp_path <- panel_path(y1, y2)
  mlp_n <- tryCatch({
    apep_azure_query(con, sprintf(
      "SELECT COUNT(*) AS n FROM 'az://%s'", mlp_path
    ))$n
  }, error = function(e) NA_integer_)

  # ABE link count
  abe_path <- sprintf("raw/census_linking_project/crosswalk_%d_%d.parquet", y1, y2)
  abe_n <- tryCatch({
    apep_azure_query(con, sprintf(
      "SELECT COUNT(*) AS n FROM 'az://%s'", abe_path
    ))$n
  }, error = function(e) NA_integer_)

  abe_comparison <- bind_rows(abe_comparison, tibble(
    pair = sprintf("%d-%d", y1, y2),
    mlp_n = mlp_n, abe_n = abe_n
  ))
  cat(sprintf("  %d→%d: MLP=%s, ABE=%s\n",
              y1, y2, fmt(mlp_n), fmt(abe_n)))
}

saveRDS(abe_comparison, file.path(DATA_DIR, "abe_comparison.rds"))

# =============================================================================
# 9. Three-census panel descriptives
# =============================================================================
cat("\n=== Three-Census Panel ===\n")

tri_desc <- apep_azure_query(con, "
  SELECT
    COUNT(*) AS n,
    AVG(age_1920) AS mean_age_1920,
    AVG(age_1930) AS mean_age_1930,
    AVG(age_1940) AS mean_age_1940,
    AVG(sei_1920) AS mean_sei_1920,
    AVG(sei_1930) AS mean_sei_1930,
    AVG(sei_1940) AS mean_sei_1940,
    SUM(CASE WHEN statefip_1920 != statefip_1930 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS mover_20_30,
    SUM(CASE WHEN statefip_1930 != statefip_1940 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS mover_30_40,
    SUM(CASE WHEN statefip_1920 != statefip_1940 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS mover_20_40,
    SUM(CASE WHEN sex_1920 = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_male,
    SUM(CASE WHEN race_1920 = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_white
  FROM 'az://derived/mlp_panel/linked_1920_1930_1940.parquet'
")

cat(sprintf("  N=%s, mean SEI: %.1f→%.1f→%.1f\n",
            fmt(tri_desc$n), tri_desc$mean_sei_1920,
            tri_desc$mean_sei_1930, tri_desc$mean_sei_1940))

saveRDS(tri_desc, file.path(DATA_DIR, "tri_panel_desc.rds"))

# =============================================================================
# 10. Variable availability matrix
# =============================================================================
cat("\n=== Variable Availability ===\n")

var_avail <- tibble(
  variable = c("HISTID", "STATEFIP", "COUNTYICP", "AGE", "SEX", "RACE",
               "BPL", "NATIVITY", "MARST", "RELATE",
               "OCC1950", "IND1950", "FARM",
               "CLASSWKR",
               "OCCSCORE", "SEI",
               "LIT", "EDUC", "SCHOOL",
               "EMPSTAT", "INCWAGE", "OWNERSHP", "FAMSIZE", "NCHILD",
               "SERIAL", "PERNUM", "PERWT"),
  y1900 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,T,F,T,F,F,T,T,T,T,T,T),
  y1910 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,T,F,F,T,T,T,T,T,T),
  y1920 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,F,T,T,T,T,T,T),
  y1930 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,F,T,T,T,T,T,T),
  y1940 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,T,T,T,T,T,T,T,T,T),
  y1950 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,F,T,T,T,T,F,F,T,T,T,T)
)

saveRDS(var_avail, file.path(DATA_DIR, "var_availability.rds"))

# =============================================================================
# Cleanup
# =============================================================================
apep_azure_disconnect(con)
cat("\nData fetch complete. All summaries saved to", DATA_DIR, "\n")
