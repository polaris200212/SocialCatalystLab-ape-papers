# =============================================================================
# 03_main_analysis.R — Link rates, balance tables, descriptive patterns
# =============================================================================

source("00_packages.R")
source(file.path(REPO_ROOT, "scripts/lib/azure_data.R"))

con <- apep_azure_connect()

DECADE_PAIRS <- list(
  c(1900L, 1910L), c(1910L, 1920L), c(1920L, 1930L),
  c(1930L, 1940L), c(1940L, 1950L)
)

CENSUS_SAMPLES <- c(
  "1900" = "us1900m", "1910" = "us1910m", "1920" = "us1920c",
  "1930" = "us1930d", "1940" = "us1940b", "1950" = "us1950b"
)

# Helper: panel file path (1940-1950 split into 2 parts)
panel_path <- function(y1, y2) {
  if (y1 == 1940L && y2 == 1950L) {
    "derived/mlp_panel/linked_1940_1950_part*.parquet"
  } else {
    sprintf("derived/mlp_panel/linked_%d_%d.parquet", y1, y2)
  }
}

# SEI is only in v1 extracts for 1920, 1930, 1940
SEI_YEARS <- c(1920L, 1930L, 1940L)

# =============================================================================
# 1. Balance tables: linked vs unlinked populations
# =============================================================================
cat("\n=== Balance Tables: Linked vs Unlinked ===\n")

balance_tables <- list()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  pp <- panel_path(y1, y2)
  census_path <- sprintf("raw/ipums_fullcount/%s.parquet", CENSUS_SAMPLES[as.character(y1)])

  # Variables available in this year
  has_sei <- y1 %in% SEI_YEARS
  has_lit <- y1 %in% c(1900L, 1910L, 1920L, 1930L)
  has_educ <- y1 %in% c(1940L, 1950L)

  sei_col <- if (has_sei) sprintf("AVG(CASE WHEN linked = 1 THEN sei ELSE NULL END) AS mean_sei_linked,
    AVG(CASE WHEN linked = 0 THEN sei ELSE NULL END) AS mean_sei_unlinked,") else ""

  lit_col <- if (has_lit) sprintf("AVG(CASE WHEN linked = 1 THEN CAST(lit AS DOUBLE) ELSE NULL END) AS mean_lit_linked,
    AVG(CASE WHEN linked = 0 THEN CAST(lit AS DOUBLE) ELSE NULL END) AS mean_lit_unlinked,") else ""

  educ_col <- if (has_educ) sprintf("AVG(CASE WHEN linked = 1 THEN CAST(educ AS DOUBLE) ELSE NULL END) AS mean_educ_linked,
    AVG(CASE WHEN linked = 0 THEN CAST(educ AS DOUBLE) ELSE NULL END) AS mean_educ_unlinked,") else ""

  q <- sprintf("
    WITH pop AS (
      SELECT HISTID, AGE AS age, SEX AS sex, RACE AS race,
             BPL AS bpl, FARM AS farm, MARST AS marst
             %s %s %s
      FROM 'az://%s'
    ),
    linked_ids AS (
      SELECT histid_%d AS histid FROM 'az://%s'
    ),
    combined AS (
      SELECT p.*,
             CASE WHEN l.histid IS NOT NULL THEN 1 ELSE 0 END AS linked
      FROM pop p
      LEFT JOIN linked_ids l ON p.HISTID = l.histid
    )
    SELECT
      SUM(linked) AS n_linked,
      COUNT(*) - SUM(linked) AS n_unlinked,
      AVG(CASE WHEN linked = 1 THEN CAST(age AS DOUBLE) ELSE NULL END) AS mean_age_linked,
      AVG(CASE WHEN linked = 0 THEN CAST(age AS DOUBLE) ELSE NULL END) AS mean_age_unlinked,
      AVG(CASE WHEN linked = 1 THEN CAST(sex = 1 AS DOUBLE) ELSE NULL END) AS pct_male_linked,
      AVG(CASE WHEN linked = 0 THEN CAST(sex = 1 AS DOUBLE) ELSE NULL END) AS pct_male_unlinked,
      AVG(CASE WHEN linked = 1 THEN CAST(race = 1 AS DOUBLE) ELSE NULL END) AS pct_white_linked,
      AVG(CASE WHEN linked = 0 THEN CAST(race = 1 AS DOUBLE) ELSE NULL END) AS pct_white_unlinked,
      AVG(CASE WHEN linked = 1 THEN CAST(bpl < 100 AS DOUBLE) ELSE NULL END) AS pct_native_linked,
      AVG(CASE WHEN linked = 0 THEN CAST(bpl < 100 AS DOUBLE) ELSE NULL END) AS pct_native_unlinked,
      AVG(CASE WHEN linked = 1 THEN CAST(farm = 2 AS DOUBLE) ELSE NULL END) AS pct_farm_linked,
      AVG(CASE WHEN linked = 0 THEN CAST(farm = 2 AS DOUBLE) ELSE NULL END) AS pct_farm_unlinked,
      %s %s %s
      COUNT(*) AS n_total
    FROM combined
  ",
    if (has_sei) ", SEI AS sei" else "",
    if (has_lit) ", LIT AS lit" else "",
    if (has_educ) ", EDUC AS educ" else "",
    census_path,
    y1, pp,
    sei_col, lit_col, educ_col
  )

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  balance_tables[[length(balance_tables) + 1]] <- res
  cat(sprintf("  %d→%d: linked=%s, unlinked=%s (link rate=%.1f%%)\n",
              y1, y2, fmt(res$n_linked), fmt(res$n_unlinked),
              res$n_linked / res$n_total * 100))
}

balance_df <- bind_rows(balance_tables)
saveRDS(balance_df, file.path(DATA_DIR, "balance_tables.rds"))

# =============================================================================
# 2. Race-specific descriptive patterns
# =============================================================================
cat("\n=== Race-Specific Patterns ===\n")

race_patterns <- tibble()
for (pair in DECADE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  has_sei <- (y1 %in% SEI_YEARS) && (y2 %in% SEI_YEARS)

  sei_clause <- if (has_sei) sprintf(
    "AVG(sei_%d) AS mean_sei_y1, AVG(sei_%d) AS mean_sei_y2,", y1, y2
  ) else ""

  q <- sprintf("
    SELECT
      race_%d AS race,
      COUNT(*) AS n,
      %s
      SUM(CASE WHEN statefip_%d != statefip_%d THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS mover_rate,
      SUM(CASE WHEN farm_%d = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_farm_y1,
      SUM(CASE WHEN farm_%d = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_farm_y2
    FROM 'az://%s'
    WHERE race_%d IN (1, 2)
    GROUP BY race_%d
  ", y1, sei_clause, y1, y2, y1, y2, path, y1, y1)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  res$race_label <- ifelse(res$race == 1, "White", "Black")
  race_patterns <- bind_rows(race_patterns, res)
}

saveRDS(race_patterns, file.path(DATA_DIR, "race_patterns.rds"))

# =============================================================================
# 3. SEI distribution within individuals (for density plots)
# =============================================================================
cat("\n=== SEI Distributions ===\n")

sei_distributions <- tibble()
# SEI only available in 1920, 1930, 1940 — so only pairs 1920-1930 and 1930-1940
sei_pairs <- list(c(1920L, 1930L), c(1930L, 1940L))
for (pair in sei_pairs) {
  y1 <- pair[1]; y2 <- pair[2]
  path <- panel_path(y1, y2)

  # Sample 50K observations for density estimation
  q <- sprintf("
    SELECT sei_%d AS sei_y1, sei_%d AS sei_y2,
           sei_%d - sei_%d AS delta_sei,
           race_%d AS race
    FROM 'az://%s'
    WHERE sei_%d IS NOT NULL AND sei_%d IS NOT NULL
      AND sei_%d > 0 AND sei_%d > 0
    USING SAMPLE 50000
  ", y1, y2, y2, y1, y1, path, y1, y2, y1, y2)

  res <- apep_azure_query(con, q)
  res$pair <- sprintf("%d-%d", y1, y2)
  sei_distributions <- bind_rows(sei_distributions, res)
  cat(sprintf("  %d→%d: %s obs sampled, mean delta SEI=%.2f\n",
              y1, y2, fmt(nrow(res)), mean(res$delta_sei, na.rm = TRUE)))
}

saveRDS(sei_distributions, file.path(DATA_DIR, "sei_distributions.rds"))

# =============================================================================
# 4. IPW weight diagnostics (if available)
# =============================================================================
cat("\n=== IPW Weight Diagnostics ===\n")

ipw_exists <- tryCatch({
  apep_azure_query(con,
    "SELECT COUNT(*) AS n FROM 'az://derived/mlp_panel/selection_weights.parquet'"
  )
  TRUE
}, error = function(e) FALSE)

if (ipw_exists) {
  ipw_diag <- apep_azure_query(con, "
    SELECT pair,
           COUNT(*) AS n,
           AVG(ipw) AS mean_ipw,
           PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ipw) AS p1,
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ipw) AS p25,
           PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ipw) AS p50,
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ipw) AS p75,
           PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ipw) AS p99
    FROM 'az://derived/mlp_panel/selection_weights.parquet'
    GROUP BY pair
    ORDER BY pair
  ")
  saveRDS(ipw_diag, file.path(DATA_DIR, "ipw_diagnostics.rds"))
  cat("  IPW diagnostics saved.\n")
} else {
  cat("  IPW weights not yet available on Azure.\n")
  saveRDS(NULL, file.path(DATA_DIR, "ipw_diagnostics.rds"))
}

apep_azure_disconnect(con)
cat("\nMain analysis complete.\n")
