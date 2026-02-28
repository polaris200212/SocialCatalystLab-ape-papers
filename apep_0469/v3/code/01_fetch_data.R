## ============================================================================
## 01_fetch_data.R — Data Acquisition for apep_0469 v3
## MLP PANEL via Azure Blob Storage + CenSoc from Harvard Dataverse
## ============================================================================
## REPLICATION NOTE:
## - Pre-built MLP linked panels are hosted in Azure Blob Storage
## - Requires AZURE_STORAGE_CONNECTION_STRING in .env
## - CenSoc WWII Enlistment-Census-1940: Harvard Dataverse (free download)
## - County shapefiles: tigris R package
## ============================================================================

source("code/00_packages.R")

REPO_ROOT <- system("git rev-parse --show-toplevel", intern = TRUE)
source(file.path(REPO_ROOT, "scripts/lib/azure_data.R"))

data_dir <- "data"
dir.create(data_dir, showWarnings = FALSE)

## --------------------------------------------------------------------------
## 1. MLP Linked Panels from Azure
## --------------------------------------------------------------------------

cat("=== Reading MLP Linked Panels from Azure ===\n")

con <- apep_azure_connect()

## 1a. Two-period panel: 1940-1950 (71.8M rows, split into parts)
panel_40_50_file <- file.path(data_dir, "mlp_linked_40_50.rds")
if (!file.exists(panel_40_50_file)) {
  cat("Reading linked_1940_1950 from Azure (multi-part)...\n")
  # Read all parts
  dt_40_50 <- apep_azure_query(con, "
    SELECT * FROM read_parquet('az://derived/mlp_panel/linked_1940_1950_part*.parquet')
  ")
  setDT(dt_40_50)
  cat(sprintf("  Linked 1940-1950: %s rows, %d columns\n",
      format(nrow(dt_40_50), big.mark = ","), ncol(dt_40_50)))
  cat(sprintf("  Columns: %s\n", paste(names(dt_40_50), collapse = ", ")))
  saveRDS(dt_40_50, panel_40_50_file)
  rm(dt_40_50); gc()
} else {
  cat("MLP 1940-1950 panel already cached:", panel_40_50_file, "\n")
}

## 1b. Three-period panel: 1930-1940-1950
panel_30_40_50_file <- file.path(data_dir, "mlp_linked_30_40_50.rds")
if (!file.exists(panel_30_40_50_file)) {
  cat("Reading linked_1930_1940_1950 from Azure...\n")
  dt_30_40_50 <- apep_azure_read(con, "derived/mlp_panel/linked_1930_1940_1950.parquet")
  setDT(dt_30_40_50)
  cat(sprintf("  Linked 1930-1940-1950: %s rows, %d columns\n",
      format(nrow(dt_30_40_50), big.mark = ","), ncol(dt_30_40_50)))
  cat(sprintf("  Columns: %s\n", paste(names(dt_30_40_50), collapse = ", ")))
  saveRDS(dt_30_40_50, panel_30_40_50_file)
  rm(dt_30_40_50); gc()
} else {
  cat("MLP 1930-1940-1950 panel already cached:", panel_30_40_50_file, "\n")
}

## 1c. Link diagnostics
diag_file <- file.path(data_dir, "link_diagnostics.rds")
if (!file.exists(diag_file)) {
  cat("Reading link_diagnostics from Azure...\n")
  diag <- apep_azure_read(con, "derived/mlp_panel/link_diagnostics.parquet")
  setDT(diag)
  cat(sprintf("  Diagnostics: %s rows\n", format(nrow(diag), big.mark = ",")))
  saveRDS(diag, diag_file)
  rm(diag); gc()
} else {
  cat("Link diagnostics already cached:", diag_file, "\n")
}

## 1d. Full-count married-women aggregates (SQL on raw census files)
mw_agg_file <- file.path(data_dir, "married_women_aggregate.rds")
if (!file.exists(mw_agg_file)) {
  cat("Computing married-women aggregates from full-count censuses...\n")

  mw_agg <- list()
  for (yr in c(1930, 1940, 1950)) {
    sample_name <- c("1930" = "us1930d", "1940" = "us1940b", "1950" = "us1950b")
    path <- sprintf("raw/ipums_fullcount/%s.parquet", sample_name[as.character(yr)])

    # LFP measure depends on year
    if (yr == 1930) {
      lf_expr <- "CASE WHEN CLASSWKR > 0 THEN 1 ELSE 0 END"
    } else {
      lf_expr <- "CASE WHEN EMPSTAT IN (1, 2) THEN 1 ELSE 0 END"
    }

    sql <- sprintf("
      SELECT
        STATEFIP AS statefip,
        %d AS year,
        COUNT(*) AS n_married_women,
        AVG(%s) AS lfp_married_women,
        AVG(AGE) AS mean_age
      FROM 'az://%s'
      WHERE SEX = 2
        AND MARST IN (1, 2)
        AND AGE >= 18
        AND AGE <= 55
      GROUP BY STATEFIP
    ", yr, lf_expr, path)

    agg_yr <- apep_azure_query(con, sql)
    setDT(agg_yr)
    mw_agg[[as.character(yr)]] <- agg_yr
    cat(sprintf("  %d: %d states, mean married-women LFP = %.4f\n",
        yr, nrow(agg_yr),
        weighted.mean(agg_yr$lfp_married_women, agg_yr$n_married_women)))
  }

  mw_agg_dt <- rbindlist(mw_agg)
  saveRDS(mw_agg_dt, mw_agg_file)
  cat("Saved married-women aggregates.\n")
  rm(mw_agg, mw_agg_dt); gc()
} else {
  cat("Married-women aggregates already cached:", mw_agg_file, "\n")
}

## 1e. Full-count population denominators by state/sex/year (for IPW)
pop_denom_file <- file.path(data_dir, "population_denominators.rds")
if (!file.exists(pop_denom_file)) {
  cat("Computing population denominators from full-count censuses...\n")

  pop_list <- list()
  for (yr in c(1930, 1940, 1950)) {
    sample_name <- c("1930" = "us1930d", "1940" = "us1940b", "1950" = "us1950b")
    path <- sprintf("raw/ipums_fullcount/%s.parquet", sample_name[as.character(yr)])

    # Age groups for IPW: 18-25, 26-35, 36-45, 46-55
    sql <- sprintf("
      SELECT
        STATEFIP AS statefip,
        SEX AS sex,
        RACE AS race,
        CASE
          WHEN AGE >= 18 AND AGE <= 25 THEN '18-25'
          WHEN AGE >= 26 AND AGE <= 35 THEN '26-35'
          WHEN AGE >= 36 AND AGE <= 45 THEN '36-45'
          WHEN AGE >= 46 AND AGE <= 55 THEN '46-55'
        END AS age_group,
        %d AS year,
        COUNT(*) AS n_pop
      FROM 'az://%s'
      WHERE AGE >= 18 AND AGE <= 55
      GROUP BY STATEFIP, SEX, RACE, age_group
    ", yr, path)

    pop_yr <- apep_azure_query(con, sql)
    setDT(pop_yr)
    pop_list[[as.character(yr)]] <- pop_yr
    cat(sprintf("  %d: %s cells\n", yr, format(nrow(pop_yr), big.mark = ",")))
  }

  pop_denom <- rbindlist(pop_list)
  saveRDS(pop_denom, pop_denom_file)
  cat("Saved population denominators.\n")
  rm(pop_list, pop_denom); gc()
} else {
  cat("Population denominators already cached:", pop_denom_file, "\n")
}

## 1f. Full-count all-women aggregate by state/year (for decomposition comparison)
allwomen_file <- file.path(data_dir, "allwomen_aggregate.rds")
if (!file.exists(allwomen_file)) {
  cat("Computing all-women aggregates from full-count censuses...\n")

  aw_list <- list()
  for (yr in c(1940, 1950)) {
    sample_name <- c("1940" = "us1940b", "1950" = "us1950b")
    path <- sprintf("raw/ipums_fullcount/%s.parquet", sample_name[as.character(yr)])

    sql <- sprintf("
      SELECT
        STATEFIP AS statefip,
        %d AS year,
        COUNT(*) AS n_all_women,
        AVG(CASE WHEN EMPSTAT IN (1, 2) THEN 1.0 ELSE 0.0 END) AS lfp_all_women,
        SUM(CASE WHEN MARST IN (1, 2) THEN 1 ELSE 0 END) AS n_married_women,
        AVG(CASE WHEN MARST IN (1, 2) THEN
          CASE WHEN EMPSTAT IN (1, 2) THEN 1.0 ELSE 0.0 END
        END) AS lfp_married_women_subset
      FROM 'az://%s'
      WHERE SEX = 2
        AND AGE >= 18
        AND AGE <= 55
      GROUP BY STATEFIP
    ", yr, path)

    aw_yr <- apep_azure_query(con, sql)
    setDT(aw_yr)
    aw_list[[as.character(yr)]] <- aw_yr
    cat(sprintf("  %d: %d states, all-women LFP = %.4f, married-women LFP = %.4f\n",
        yr, nrow(aw_yr),
        weighted.mean(aw_yr$lfp_all_women, aw_yr$n_all_women),
        weighted.mean(aw_yr$lfp_married_women_subset, aw_yr$n_married_women, na.rm = TRUE)))
  }

  allwomen_dt <- rbindlist(aw_list)
  saveRDS(allwomen_dt, allwomen_file)
  rm(aw_list, allwomen_dt); gc()
} else {
  cat("All-women aggregates already cached:", allwomen_file, "\n")
}

apep_azure_disconnect(con)


## --------------------------------------------------------------------------
## 2. CenSoc WWII Army Enlistment Records
## --------------------------------------------------------------------------

cat("\n=== CenSoc WWII Enlistment Data ===\n")

censoc_rds <- file.path(data_dir, "censoc_enlistment.rds")

if (!file.exists(censoc_rds)) {
  urls <- list(
    enlist_census = "https://dataverse.harvard.edu/api/access/datafile/10410790",
    enlist_raw    = "https://dataverse.harvard.edu/api/access/datafile/10410797"
  )
  censoc_file <- file.path(data_dir, "censoc_enlistment_census_1940.csv")
  cat("Downloading CenSoc Enlistment-Census-1940...\n")
  download_success <- FALSE
  tryCatch({
    download.file(urls$enlist_census, censoc_file, mode = "wb", quiet = FALSE)
    if (file.size(censoc_file) > 1000) {
      censoc <- fread(censoc_file, nThread = getDTthreads())
      cat(sprintf("CenSoc records: %s\n", format(nrow(censoc), big.mark = ",")))
      saveRDS(censoc, censoc_rds)
      download_success <- TRUE
    }
  }, error = function(e) cat("Download failed:", conditionMessage(e), "\n"))
  if (!download_success) {
    tryCatch({
      raw_file <- file.path(data_dir, "censoc_enlistment_raw.csv")
      download.file(urls$enlist_raw, raw_file, mode = "wb", quiet = FALSE)
      if (file.size(raw_file) > 1000) {
        censoc <- fread(raw_file, nThread = getDTthreads())
        saveRDS(censoc, censoc_rds)
      }
    }, error = function(e) cat("Fallback failed:", conditionMessage(e), "\n"))
  }
} else {
  cat("CenSoc data already exists:", censoc_rds, "\n")
}


## --------------------------------------------------------------------------
## 3. County Shapefiles
## --------------------------------------------------------------------------

cat("\n=== County Shapefiles ===\n")

shp_file <- file.path(data_dir, "counties_1940.rds")
if (!file.exists(shp_file)) {
  tryCatch({
    counties <- tigris::counties(year = 2020, cb = TRUE) |>
      sf::st_transform(crs = 5070)
    counties$fips <- as.integer(paste0(counties$STATEFP, counties$COUNTYFP))
    saveRDS(counties, shp_file)
    cat(sprintf("County shapefiles: %d counties\n", nrow(counties)))
  }, error = function(e) cat("WARNING: Could not download county shapefiles.\n"))
} else {
  cat("County shapefiles already exist:", shp_file, "\n")
}


## --------------------------------------------------------------------------
## Summary
## --------------------------------------------------------------------------

cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("  MLP 1940-1950:         %s\n", ifelse(file.exists(panel_40_50_file), "READY", "PENDING")))
cat(sprintf("  MLP 1930-1940-1950:    %s\n", ifelse(file.exists(panel_30_40_50_file), "READY", "PENDING")))
cat(sprintf("  Link diagnostics:      %s\n", ifelse(file.exists(diag_file), "READY", "PENDING")))
cat(sprintf("  Married-women agg:     %s\n", ifelse(file.exists(mw_agg_file), "READY", "PENDING")))
cat(sprintf("  Population denoms:     %s\n", ifelse(file.exists(pop_denom_file), "READY", "PENDING")))
cat(sprintf("  All-women agg:         %s\n", ifelse(file.exists(allwomen_file), "READY", "PENDING")))
cat(sprintf("  CenSoc:               %s\n", ifelse(file.exists(censoc_rds), "READY", "PENDING")))
cat(sprintf("  County shapes:         %s\n", ifelse(file.exists(shp_file), "READY", "PENDING")))
cat("\nProceed to 02_clean_data.R\n")
