###############################################################################
# 01_fetch_data.R — Download all datasets
# Paper: Divine Forgiveness Beliefs (apep_0218)
###############################################################################

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# 1. GSS Cumulative Data (Stata format)
###############################################################################
cat("\n=== Downloading GSS Cumulative Data ===\n")
gss_url <- "https://gss.norc.org/content/dam/gss/get-the-data/documents/stata/GSS_stata.zip"
gss_zip <- file.path(data_dir, "GSS_stata.zip")

if (!file.exists(gss_zip)) {
  cat("Downloading GSS (~47 MB)...\n")
  download.file(gss_url, gss_zip, mode = "wb", quiet = FALSE)
} else {
  cat("GSS zip already exists, skipping download.\n")
}

# Extract
gss_dir <- file.path(data_dir, "gss")
dir.create(gss_dir, showWarnings = FALSE)
if (length(list.files(gss_dir, pattern = "\\.dta$")) == 0) {
  cat("Extracting GSS data...\n")
  unzip(gss_zip, exdir = gss_dir)
}
cat("GSS files:", list.files(gss_dir, pattern = "\\.dta$"), "\n")

###############################################################################
# 2. D-PLACE Ethnographic Atlas (EA)
###############################################################################
cat("\n=== Downloading D-PLACE Ethnographic Atlas ===\n")
ea_base <- "https://raw.githubusercontent.com/D-PLACE/dplace-dataset-ea/master/cldf/"
ea_dir <- file.path(data_dir, "dplace_ea")
dir.create(ea_dir, showWarnings = FALSE)

ea_files <- c("data.csv", "variables.csv", "codes.csv", "societies.csv")
for (f in ea_files) {
  dest <- file.path(ea_dir, f)
  if (!file.exists(dest)) {
    tryCatch({
      cat(sprintf("  Downloading EA %s...\n", f))
      download.file(paste0(ea_base, f), dest, quiet = TRUE)
    }, error = function(e) {
      cat(sprintf("  Warning: EA %s not found: %s\n", f, e$message))
    })
  }
}
cat("EA files:", list.files(ea_dir), "\n")

###############################################################################
# 3. D-PLACE SCCS (Standard Cross-Cultural Sample)
###############################################################################
cat("\n=== Downloading D-PLACE SCCS ===\n")
sccs_base <- "https://raw.githubusercontent.com/D-PLACE/dplace-dataset-sccs/master/cldf/"
sccs_dir <- file.path(data_dir, "dplace_sccs")
dir.create(sccs_dir, showWarnings = FALSE)

sccs_files <- c("data.csv", "variables.csv", "codes.csv", "societies.csv")
for (f in sccs_files) {
  dest <- file.path(sccs_dir, f)
  if (!file.exists(dest)) {
    tryCatch({
      cat(sprintf("  Downloading SCCS %s...\n", f))
      download.file(paste0(sccs_base, f), dest, quiet = TRUE)
    }, error = function(e) {
      cat(sprintf("  Warning: SCCS %s not found: %s\n", f, e$message))
    })
  }
}
cat("SCCS files:", list.files(sccs_dir), "\n")

###############################################################################
# 4. Pulotu (Austronesian Supernatural Beliefs)
###############################################################################
cat("\n=== Downloading Pulotu ===\n")
pulotu_base <- "https://raw.githubusercontent.com/D-PLACE/dplace-dataset-pulotu/master/cldf/"
pulotu_dir <- file.path(data_dir, "pulotu")
dir.create(pulotu_dir, showWarnings = FALSE)

# Pulotu uses different file names
pulotu_files <- c("responses.csv", "questions.csv", "codes.csv", "cultures.csv")
# Try the standard CLDF names first, then Pulotu-specific names
for (f in c("data.csv", "parameters.csv", "codes.csv", "societies.csv", "languages.csv")) {
  dest <- file.path(pulotu_dir, f)
  if (!file.exists(dest)) {
    tryCatch({
      cat(sprintf("  Downloading Pulotu %s...\n", f))
      download.file(paste0(pulotu_base, f), dest, quiet = TRUE)
    }, error = function(e) {
      cat(sprintf("  Note: %s not found, trying alternatives...\n", f))
    })
  }
}

# Also try Pulotu-specific file names
for (f in c("responses.csv", "questions.csv", "cultures.csv")) {
  dest <- file.path(pulotu_dir, f)
  if (!file.exists(dest)) {
    tryCatch({
      cat(sprintf("  Trying Pulotu %s...\n", f))
      download.file(paste0(pulotu_base, f), dest, quiet = TRUE)
    }, error = function(e) {
      cat(sprintf("  %s not available\n", f))
    })
  }
}
cat("Pulotu files:", list.files(pulotu_dir), "\n")

###############################################################################
# 5. Seshat Moralizing Religion Dataset
###############################################################################
cat("\n=== Downloading Seshat Moralizing Religion ===\n")
seshat_dir <- file.path(data_dir, "seshat")
dir.create(seshat_dir, showWarnings = FALSE)

seshat_url <- "https://raw.githubusercontent.com/datasets/seshat/master/mr_dataset.04.2021.csv"
seshat_dest <- file.path(seshat_dir, "mr_dataset.csv")
if (!file.exists(seshat_dest)) {
  tryCatch({
    cat("  Downloading Seshat moralizing religion dataset...\n")
    download.file(seshat_url, seshat_dest, quiet = TRUE)
  }, error = function(e) {
    cat("  Primary URL failed, trying alternative...\n")
    # Try alternative URLs
    alt_urls <- c(
      "https://raw.githubusercontent.com/seshatdatabank/seshat/master/mr_dataset.04.2021.csv",
      "https://raw.githubusercontent.com/pesho-ivanov/seshat/master/mr_dataset.04.2021.csv"
    )
    for (url in alt_urls) {
      tryCatch({
        download.file(url, seshat_dest, quiet = TRUE)
        cat("  Downloaded from alternative URL.\n")
        break
      }, error = function(e2) NULL)
    }
  })
}

if (file.exists(seshat_dest)) {
  cat("Seshat file size:", file.size(seshat_dest), "bytes\n")
} else {
  cat("WARNING: Seshat data not downloaded. Will skip in analysis.\n")
}

###############################################################################
# 6. Economic covariates from FRED (for Part 2 correlations)
###############################################################################
cat("\n=== Downloading Economic Covariates ===\n")

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  econ_dir <- file.path(data_dir, "economic")
  dir.create(econ_dir, showWarnings = FALSE)

  # US-level economic indicators (for GSS correlations)
  fred_series <- c(
    "GINIALLRF" = "Gini coefficient",
    "A191RL1Q225SBEA" = "Real GDP growth",
    "UNRATE" = "Unemployment rate",
    "MEHOINUSA672N" = "Median household income",
    "B230RC0A052NBEA" = "Social benefits per capita"
  )

  fred_data <- list()
  for (series_id in names(fred_series)) {
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=1972-01-01",
      series_id, fred_key
    )
    tryCatch({
      resp <- jsonlite::fromJSON(url)
      if (!is.null(resp$observations)) {
        df <- resp$observations %>%
          select(date, value) %>%
          mutate(
            series = series_id,
            label = fred_series[series_id],
            date = as.Date(date),
            value = as.numeric(value),
            year = as.integer(format(date, "%Y"))
          )
        fred_data[[series_id]] <- df
        cat(sprintf("  %s (%s): %d obs\n", series_id, fred_series[series_id], nrow(df)))
      }
    }, error = function(e) {
      cat(sprintf("  Failed to download %s: %s\n", series_id, e$message))
    })
  }

  if (length(fred_data) > 0) {
    fred_combined <- bind_rows(fred_data)
    write_csv(fred_combined, file.path(econ_dir, "fred_indicators.csv"))
    cat("FRED data saved:", nrow(fred_combined), "total obs\n")
  }
} else {
  cat("No FRED API key, skipping economic covariates.\n")
}

cat("\n=== All downloads complete ===\n")
cat("Data directory contents:\n")
for (d in list.dirs(data_dir, recursive = FALSE)) {
  cat(sprintf("  %s: %d files\n", basename(d), length(list.files(d))))
}
