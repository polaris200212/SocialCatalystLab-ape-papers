## 01_fetch_data.R — Download BAAC road accident data + treatment panel
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

# ── 1. Download BAAC Data (2015-2024) ────────────────────────────────

baac_base_url <- "https://www.data.gouv.fr/api/1/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere-annees-de-2005-a-2024/"

cat("Fetching BAAC resource metadata from data.gouv.fr...\n")
resources <- jsonlite::fromJSON(baac_base_url)$resources

# We need: Caracteristiques (dep, date, agg), Lieux (catr, vma), Usagers (grav)
years <- 2015:2024

download_baac <- function(year, file_type) {
  # Match resource by title patterns
  pattern <- switch(file_type,
    "caract" = paste0("caract.*", year),
    "lieux"  = paste0("lieu.*", year),
    "usagers" = paste0("usager.*", year)
  )

  matches <- resources[grepl(pattern, resources$title, ignore.case = TRUE), ]

  if (nrow(matches) == 0) {
    # Try alternative patterns (including data.gouv.fr misspellings)
    alt_patterns <- switch(file_type,
      "caract" = c(paste0("caracteristiques.*", year),
                   paste0("carcteristiques.*", year)),
      "lieux"  = c(paste0("lieux.*", year)),
      "usagers" = c(paste0("usagers.*", year))
    )
    for (alt_pat in alt_patterns) {
      matches <- resources[grepl(alt_pat, resources$title, ignore.case = TRUE), ]
      if (nrow(matches) > 0) break
    }
  }

  if (nrow(matches) == 0) {
    warning(sprintf("No resource found for %s_%d", file_type, year))
    return(NULL)
  }

  # Take the first (most recent) match
  url <- matches$url[1]
  dest <- file.path(DATA_DIR, sprintf("%s_%d.csv", file_type, year))

  if (file.exists(dest)) {
    cat(sprintf("  %s_%d.csv already exists, skipping\n", file_type, year))
    return(dest)
  }

  cat(sprintf("  Downloading %s_%d.csv...\n", file_type, year))
  tryCatch({
    download.file(url, dest, mode = "wb", quiet = TRUE)
    dest
  }, error = function(e) {
    warning(sprintf("Failed to download %s_%d: %s", file_type, year, e$message))
    NULL
  })
}

for (year in years) {
  cat(sprintf("Year %d:\n", year))
  download_baac(year, "caract")
  download_baac(year, "lieux")
  download_baac(year, "usagers")
}

# ── 2. Copy Treatment Panel ──────────────────────────────────────────

treatment_src <- here::here("data", "france_90kmh_reversals.csv")
treatment_dest <- file.path(DATA_DIR, "treatment_panel.csv")

if (file.exists(treatment_src)) {
  file.copy(treatment_src, treatment_dest, overwrite = TRUE)
  cat("Treatment panel copied to", treatment_dest, "\n")
} else {
  stop("Treatment panel not found at: ", treatment_src)
}

# ── 3. Download population data from INSEE ───────────────────────────

# Population by département for rate calculations
# Using INSEE SDMX API for "population par département"
pop_file <- file.path(DATA_DIR, "population_dept.csv")

if (!file.exists(pop_file)) {
  cat("Downloading département population data...\n")

  # Use a simple approach: download population estimates from INSEE BDM
  # Key: 001782249 = metropolitan département population estimates
  pop_url <- "https://www.insee.fr/fr/statistiques/fichier/2012692/TCRD_004.xlsx"

  tryCatch({
    pop_temp <- file.path(DATA_DIR, "pop_raw.xlsx")
    download.file(pop_url, pop_temp, mode = "wb", quiet = TRUE)
    cat("Population data downloaded\n")
  }, error = function(e) {
    cat("INSEE population download failed, will construct from API\n")
  })
}

# ── 4. Verify Downloads ─────────────────────────────────────────────

cat("\n=== Download Summary ===\n")
files <- list.files(DATA_DIR, pattern = "\\.csv$")
cat(sprintf("CSV files in data/: %d\n", length(files)))
for (f in sort(files)) {
  sz <- file.size(file.path(DATA_DIR, f))
  cat(sprintf("  %s: %.1f KB\n", f, sz / 1024))
}

cat("\nData fetch complete.\n")
