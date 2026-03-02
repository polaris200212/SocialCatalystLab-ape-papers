## ============================================================================
## 01_fetch_data.R — Data acquisition (bulk Sirene parquet approach)
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")
library(arrow)

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# ===========================================================================
# 1. COMMUNE POPULATION DATA
# ===========================================================================
cat("=== Fetching commune population data ===\n")

pop_file <- file.path(data_dir, "commune_population_panel.csv")
if (file.exists(pop_file) && file.size(pop_file) > 1000) {
  cat("  Population data already exists, skipping download.\n")
  pop_panel <- fread(pop_file)
} else {
  url_map <- c(
    "2022" = "https://static.data.gouv.fr/resources/communes-et-villes-de-france-en-csv-excel-json-parquet-et-feather/20241126-161130/communes-france-2022.csv",
    "2023" = "https://static.data.gouv.fr/resources/communes-et-villes-de-france-en-csv-excel-json-parquet-et-feather/20241126-160308/communes-france-2023.csv",
    "2024" = "https://static.data.gouv.fr/resources/communes-et-villes-de-france-en-csv-excel-json-parquet-et-feather/20241126-160035/communes-france-2024.csv",
    "2025" = "https://static.data.gouv.fr/resources/communes-et-villes-de-france-en-csv-excel-json-parquet-et-feather/20250221-162232/communes-france-2025.csv"
  )

  pop_list <- list()
  for (yr_str in names(url_map)) {
    yr <- as.integer(yr_str)
    cat(sprintf("  Downloading communes-%d.csv...\n", yr))
    tryCatch({
      tmp <- fread(url_map[yr_str], showProgress = FALSE, encoding = "UTF-8")
      if ("population" %in% names(tmp) && "code_insee" %in% names(tmp)) {
        pop_list[[yr_str]] <- tmp[, .(
          code_insee = code_insee,
          commune_name = nom_standard,
          population = as.integer(population),
          superficie_km2 = as.numeric(superficie_km2),
          densite = as.numeric(densite),
          dep_code = dep_code,
          reg_code = reg_code,
          data_year = yr
        )]
        cat(sprintf("    Got %d communes for %d\n", nrow(pop_list[[yr_str]]), yr))
      }
    }, error = function(e) cat(sprintf("    WARN: %s\n", e$message)))
  }

  pop_panel <- rbindlist(pop_list, fill = TRUE)
  fwrite(pop_panel, pop_file)
}
cat(sprintf("Population panel: %d rows\n", nrow(pop_panel)))

# Use most recent year for cross-sectional analysis
pop_latest <- pop_panel[data_year == max(data_year)]

# ===========================================================================
# 2. IDENTIFY COMMUNES NEAR THRESHOLDS
# ===========================================================================
rdd_thresholds <- c(500, 1000, 1500, 3500, 10000)

# Filter to metropolitan France
pop_metro <- pop_latest[!grepl("^97", dep_code)]
pop_metro <- pop_metro[!code_insee %in% c("75056", "69123", "13055")]
pop_metro <- pop_metro[!is.na(population) & population > 0]

# Communes within 50% of any RDD threshold
near_threshold <- pop_metro[
  sapply(population, function(p) any(abs(p - rdd_thresholds) / rdd_thresholds < 0.5))
]
target_communes <- near_threshold$code_insee
cat(sprintf("Target communes near thresholds: %d\n", length(target_communes)))

# ===========================================================================
# 3. SIRENE BULK DATA — Process parquet file
# ===========================================================================
cat("\n=== Processing Sirene bulk establishment data ===\n")

parquet_file <- file.path(data_dir, "StockEtablissement_utf8.parquet")
sirene_out <- file.path(data_dir, "sirene_creations.csv")
stock_out <- file.path(data_dir, "sirene_stock.csv")

if (!file.exists(parquet_file)) {
  cat("  Downloading Sirene stock parquet (2GB)...\n")
  download.file(
    "https://object.files.data.gouv.fr/data-pipeline-open/siren/stock/StockEtablissement_utf8.parquet",
    parquet_file, mode = "wb", quiet = FALSE
  )
}

cat("  Opening parquet file with Arrow...\n")
etab <- open_dataset(parquet_file)

# Check available columns
cols <- names(etab)
cat(sprintf("  Parquet columns: %d\n", length(cols)))
cat(sprintf("  Key columns present: codeCommuneEtablissement=%s, dateCreationEtablissement=%s\n",
            "codeCommuneEtablissement" %in% cols,
            "dateCreationEtablissement" %in% cols))

# Also check for etatAdministratifEtablissement
cat(sprintf("  etatAdministratifEtablissement=%s\n",
            "etatAdministratifEtablissement" %in% cols))

# ===========================================================================
# 3a. CREATION COUNTS by commune-year
# ===========================================================================
cat("  Extracting creation counts for target communes...\n")

# Process in chunks to avoid memory issues
# Filter to target communes and extract creation year
creation_data <- etab %>%
  select(codeCommuneEtablissement, dateCreationEtablissement) %>%
  filter(codeCommuneEtablissement %in% target_communes) %>%
  collect()

cat(sprintf("  Raw establishment records for target communes: %d\n", nrow(creation_data)))

# Convert to data.table and extract year
setDT(creation_data)
creation_data[, creation_year := as.integer(substr(dateCreationEtablissement, 1, 4))]

# Count creations by commune-year (2008-2024)
sirene_creations <- creation_data[
  creation_year >= 2008 & creation_year <= 2024,
  .(n_creations = .N),
  by = .(code_insee = codeCommuneEtablissement, year = creation_year)
]

# Ensure all commune-year combinations exist (fill missing with 0)
all_combos <- CJ(
  code_insee = target_communes,
  year = 2008:2024
)
sirene_creations <- merge(all_combos, sirene_creations,
                          by = c("code_insee", "year"), all.x = TRUE)
sirene_creations[is.na(n_creations), n_creations := 0L]

fwrite(sirene_creations, sirene_out)
cat(sprintf("  Sirene creation data: %d commune-year observations\n", nrow(sirene_creations)))
cat(sprintf("  Unique communes: %d\n", uniqueN(sirene_creations$code_insee)))

# ===========================================================================
# 3b. STOCK of active establishments
# ===========================================================================
cat("  Extracting active establishment stock...\n")

stock_data <- etab %>%
  select(codeCommuneEtablissement, etatAdministratifEtablissement) %>%
  filter(
    codeCommuneEtablissement %in% target_communes,
    etatAdministratifEtablissement == "A"
  ) %>%
  group_by(codeCommuneEtablissement) %>%
  summarise(n_active = n()) %>%
  collect()

setDT(stock_data)
setnames(stock_data, "codeCommuneEtablissement", "code_insee")

fwrite(stock_data, stock_out)
cat(sprintf("  Stock data: %d communes with active establishments\n", nrow(stock_data)))

# Clean up
rm(creation_data, etab)
gc()

cat("\n=== Data acquisition complete ===\n")
cat(sprintf("  Population panel: %s\n", pop_file))
cat(sprintf("  Sirene creations: %s\n", sirene_out))
cat(sprintf("  Sirene stock: %s\n", stock_out))
