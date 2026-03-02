# =============================================================================
# 04_robustness.R — ABE comparison, cross-pair consistency, IPW validation
# =============================================================================

source("00_packages.R")
source(file.path(REPO_ROOT, "scripts/lib/azure_data.R"))

con <- apep_azure_connect()

# =============================================================================
# 1. ABE vs MLP link rate comparison (for overlapping pairs)
# =============================================================================
cat("\n=== ABE vs MLP Comparison ===\n")

CENSUS_SAMPLES <- c(
  "1920" = "us1920c", "1930" = "us1930d", "1940" = "us1940b"
)

# Only use ABE pairs where we have a corresponding MLP decade-pair panel
# 1920→1940 is an ABE crosswalk but not a MLP decade pair (it's a 20-year span)
ABE_PAIRS <- list(c(1920L, 1930L), c(1930L, 1940L))

abe_detail <- tibble()
for (pair in ABE_PAIRS) {
  y1 <- pair[1]; y2 <- pair[2]

  # ABE: link rates by race and sex
  abe_path <- sprintf("raw/census_linking_project/crosswalk_%d_%d.parquet", y1, y2)
  census_path <- sprintf("raw/ipums_fullcount/%s.parquet", CENSUS_SAMPLES[as.character(y1)])

  q <- sprintf("
    WITH abe_linked AS (
      SELECT a.histid_%d AS histid
      FROM 'az://%s' a
    ),
    pop AS (
      SELECT HISTID, SEX, RACE
      FROM 'az://%s'
    ),
    combined AS (
      SELECT p.SEX AS sex, p.RACE AS race,
             CASE WHEN a.histid IS NOT NULL THEN 1 ELSE 0 END AS linked
      FROM pop p
      LEFT JOIN abe_linked a ON p.HISTID = a.histid
    )
    SELECT sex, race, SUM(linked) AS n_linked, COUNT(*) AS n_total,
           SUM(linked) * 1.0 / COUNT(*) AS link_rate
    FROM combined
    WHERE race IN (1, 2) AND sex IN (1, 2)
    GROUP BY sex, race
  ", y1, abe_path, census_path)

  abe_res <- apep_azure_query(con, q)
  abe_res$source <- "ABE"
  abe_res$pair <- sprintf("%d-%d", y1, y2)

  # MLP: same breakdown
  mlp_path <- if (y1 == 1940L && y2 == 1950L) {
    "derived/mlp_panel/linked_1940_1950_part*.parquet"
  } else {
    sprintf("derived/mlp_panel/linked_%d_%d.parquet", y1, y2)
  }

  q_mlp <- sprintf("
    WITH mlp_linked AS (
      SELECT histid_%d AS histid
      FROM 'az://%s'
    ),
    pop AS (
      SELECT HISTID, SEX, RACE
      FROM 'az://%s'
    ),
    combined AS (
      SELECT p.SEX AS sex, p.RACE AS race,
             CASE WHEN m.histid IS NOT NULL THEN 1 ELSE 0 END AS linked
      FROM pop p
      LEFT JOIN mlp_linked m ON p.HISTID = m.histid
    )
    SELECT sex, race, SUM(linked) AS n_linked, COUNT(*) AS n_total,
           SUM(linked) * 1.0 / COUNT(*) AS link_rate
    FROM combined
    WHERE race IN (1, 2) AND sex IN (1, 2)
    GROUP BY sex, race
  ", y1, mlp_path, census_path)

  mlp_res <- apep_azure_query(con, q_mlp)
  mlp_res$source <- "MLP"
  mlp_res$pair <- sprintf("%d-%d", y1, y2)

  abe_detail <- bind_rows(abe_detail, abe_res, mlp_res)
  cat(sprintf("  %d→%d: ABE overall=%.1f%%, MLP overall=%.1f%%\n",
              y1, y2,
              sum(abe_res$n_linked) / sum(abe_res$n_total) * 100,
              sum(mlp_res$n_linked) / sum(mlp_res$n_total) * 100))
}

abe_detail <- abe_detail %>%
  mutate(
    sex_label = ifelse(sex == 1, "Male", "Female"),
    race_label = ifelse(race == 1, "White", "Black")
  )

saveRDS(abe_detail, file.path(DATA_DIR, "abe_mlp_comparison.rds"))

# =============================================================================
# 2. Cross-pair consistency check
# =============================================================================
cat("\n=== Cross-Pair Consistency ===\n")

# Check: people in both 1920-1930 and 1930-1940 panels should have
# consistent demographics (same sex, compatible age, similar race)

cross_check <- apep_azure_query(con, "
  WITH p1 AS (
    SELECT histid_1930 AS histid,
           sex_1930 AS sex_p1, age_1930 AS age_p1, race_1930 AS race_p1
    FROM 'az://derived/mlp_panel/linked_1920_1930.parquet'
  ),
  p2 AS (
    SELECT histid_1930 AS histid,
           sex_1930 AS sex_p2, age_1930 AS age_p2, race_1930 AS race_p2
    FROM 'az://derived/mlp_panel/linked_1930_1940.parquet'
  ),
  matched AS (
    SELECT p1.histid,
           p1.sex_p1, p2.sex_p2,
           p1.age_p1, p2.age_p2,
           p1.race_p1, p2.race_p2
    FROM p1
    INNER JOIN p2 ON p1.histid = p2.histid
  )
  SELECT
    COUNT(*) AS n_overlap,
    SUM(CASE WHEN sex_p1 = sex_p2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS sex_match_rate,
    SUM(CASE WHEN ABS(age_p1 - age_p2) <= 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS age_match_rate,
    SUM(CASE WHEN race_p1 = race_p2 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS race_match_rate,
    AVG(ABS(age_p1 - age_p2)) AS mean_age_diff
  FROM matched
")

cat(sprintf("  Overlap: %s individuals in both panels\n", fmt(cross_check$n_overlap)))
cat(sprintf("  Sex match: %.2f%%\n", cross_check$sex_match_rate * 100))
cat(sprintf("  Age match (±1): %.2f%%\n", cross_check$age_match_rate * 100))
cat(sprintf("  Race match: %.2f%%\n", cross_check$race_match_rate * 100))

saveRDS(cross_check, file.path(DATA_DIR, "cross_pair_consistency.rds"))

# =============================================================================
# 3. Link overlap: how many individuals appear in multiple decade pairs?
# =============================================================================
cat("\n=== Link Overlap Across Pairs ===\n")

# For 1920: check if same person is in both 1910-1920 and 1920-1930
overlap_1920_count <- apep_azure_query(con, "
  SELECT COUNT(*) AS n_both
  FROM (SELECT histid_1920 AS histid FROM 'az://derived/mlp_panel/linked_1910_1920.parquet') a
  INNER JOIN (SELECT histid_1920 AS histid FROM 'az://derived/mlp_panel/linked_1920_1930.parquet') b
  ON a.histid = b.histid
")

cat(sprintf("  Individuals in both 1910-1920 AND 1920-1930: %s\n",
            fmt(overlap_1920_count$n_both)))

saveRDS(overlap_1920_count, file.path(DATA_DIR, "overlap_1920.rds"))

apep_azure_disconnect(con)
cat("\nRobustness analysis complete.\n")
