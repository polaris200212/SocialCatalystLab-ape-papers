## ============================================================================
## 01_fetch_data.R — Download Costa Union Army data from NBER
## Project: The First Retirement Age v3
## Source: NBER "Early Indicators of Later Work Levels, Disease and Death"
## URL: https://www.nber.org/research/data/union-army-data-set
## ============================================================================

source("code/00_packages.R")

## Create download directory
dl_dir <- file.path(data_dir, "costa_ua_raw")
dir.create(dl_dir, showWarnings = FALSE, recursive = TRUE)

## Define datasets to download (Stata format for haven::read_dta)
datasets <- list(
  list(
    name = "Census records (1850/1860/1900/1910)",
    url  = "https://data.nber.org/uadata/cen_union_army_whites_stata.zip",
    zip  = file.path(dl_dir, "cen_union_army_whites_stata.zip"),
    prefix = "cen"
  ),
  list(
    name = "Military pension records",
    url  = "https://data.nber.org/uadata/mil_union_army_whites_stata.zip",
    zip  = file.path(dl_dir, "mil_union_army_whites_stata.zip"),
    prefix = "mil"
  ),
  list(
    name = "Military service records",
    url  = "https://data.nber.org/uadata/msr_union_army_whites_stata.zip",
    zip  = file.path(dl_dir, "msr_union_army_whites_stata.zip"),
    prefix = "msr"
  ),
  list(
    name = "Surgeons' certificates (disease/disability)",
    url  = "https://data.nber.org/uadata/dis_union_army_whites_stata.zip",
    zip  = file.path(dl_dir, "dis_union_army_whites_stata.zip"),
    prefix = "dis"
  )
)

## Also download codebook
codebook_url  <- "https://data.nber.org/uadata/Union_Army_Codebook.pdf"
codebook_path <- file.path(dl_dir, "Union_Army_Codebook.pdf")

## Download function with retry
download_with_retry <- function(url, dest, max_tries = 3) {
  if (file.exists(dest)) {
    cat("  Already exists:", basename(dest), "\n")
    return(TRUE)
  }
  for (i in seq_len(max_tries)) {
    cat(sprintf("  Attempt %d/%d: %s\n", i, max_tries, basename(dest)))
    result <- tryCatch(
      download.file(url, dest, mode = "wb", quiet = TRUE),
      error = function(e) e
    )
    if (!inherits(result, "error") && file.exists(dest) && file.size(dest) > 1000) {
      return(TRUE)
    }
    if (file.exists(dest)) file.remove(dest)
    Sys.sleep(2)
  }
  return(FALSE)
}

## Download all datasets
cat("=== Downloading Costa Union Army Data from NBER ===\n\n")

for (ds in datasets) {
  cat(sprintf("Dataset: %s\n", ds$name))
  success <- download_with_retry(ds$url, ds$zip)
  if (!success) {
    stop(sprintf("FATAL: Failed to download %s", ds$name))
  }

  ## Unzip
  exdir <- file.path(dl_dir, ds$prefix)
  if (!dir.exists(exdir) || length(list.files(exdir, pattern = "\\.dta$")) == 0) {
    cat("  Unzipping...\n")
    unzip(ds$zip, exdir = exdir)
  }

  ## List extracted files
  dta_files <- list.files(exdir, pattern = "\\.dta$", recursive = TRUE, full.names = TRUE)
  cat(sprintf("  Found %d .dta files:\n", length(dta_files)))
  for (f in dta_files) {
    sz <- file.size(f) / 1024^2
    cat(sprintf("    %s (%.1f MB)\n", basename(f), sz))
  }
  cat("\n")
}

## Download codebook
cat("Downloading codebook...\n")
download_with_retry(codebook_url, codebook_path)

cat("\n=== Download complete ===\n")
cat("All files saved to:", dl_dir, "\n")
