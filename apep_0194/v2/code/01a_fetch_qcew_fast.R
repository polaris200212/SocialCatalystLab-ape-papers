################################################################################
# 01a_fetch_qcew_fast.R — Fast QCEW Data via Bulk CSV Downloads
# Downloads annual CSV zip files (one download per year, not per industry/quarter)
################################################################################

tryCatch(script_dir <- dirname(sys.frame(1)$ofile), error = function(e) {
  args <- commandArgs(trailingOnly = FALSE)
  f <- grep("^--file=", args, value = TRUE)
  script_dir <<- if (length(f) > 0) dirname(sub("^--file=", "", f)) else "."
})
source(file.path(script_dir, "00_packages.R"))

cat("=== Fast QCEW Data Fetch (Bulk CSVs) ===\n")

# Check if already fetched
if (file.exists(file.path(DATA_DIR, "qcew_raw.csv"))) {
  cat("QCEW data already exists. Skipping.\n")
  q("no")
}

target_naics <- c("10", "51", "5112", "5415", "52", "23", "44-45")
industry_labels <- c("Total", "Information", "Software Publishers",
                     "Computer Systems Design", "Finance & Insurance",
                     "Construction", "Retail Trade")
naics_to_label <- setNames(industry_labels, target_naics)

years <- 2015:2024
all_results <- list()

for (yr in years) {
  zip_url <- sprintf("https://data.bls.gov/cew/data/files/%d/csv/%d_qtrly_by_industry.zip", yr, yr)
  zip_path <- file.path(DATA_DIR, sprintf("qcew_%d_qtrly.zip", yr))

  if (!file.exists(zip_path)) {
    cat("  Downloading", yr, "quarterly industry ZIP...\n")
    tryCatch({
      download.file(zip_url, zip_path, mode = "wb", quiet = TRUE)
      cat("    Downloaded:", round(file.size(zip_path) / 1e6, 1), "MB\n")
    }, error = function(e) {
      cat("    FAILED:", e$message, "\n")
      next
    })
  } else {
    cat("  ", yr, "ZIP already exists\n")
  }

  # List files in the ZIP to find relevant ones
  tryCatch({
    zip_contents <- unzip(zip_path, list = TRUE)$Name

    for (naics in target_naics) {
      # File naming: YYYY.qX.by_industry/YYYY.qX-CSVs/YYYY.qX NAICS [code].csv
      # Pattern varies; search for files matching our NAICS codes
      pattern <- sprintf("%s\\.csv$", gsub("-", ".", naics))
      # Try multiple patterns
      matching <- grep(naics, zip_contents, value = TRUE)
      # Filter to private sector files or overall files
      if (length(matching) == 0) next

      for (f in matching) {
        tryCatch({
          tmp_dir <- tempdir()
          unzip(zip_path, files = f, exdir = tmp_dir, overwrite = TRUE)
          csv_path <- file.path(tmp_dir, f)

          if (file.exists(csv_path)) {
            df <- read_csv(csv_path, show_col_types = FALSE)
            df_filtered <- df %>%
              filter(own_code == 5,
                     agglvl_code %in% c(50, 51, 54, 55, 56, 57, 58, 74),
                     grepl("^\\d{2}000$", area_fips))

            if (nrow(df_filtered) > 0) {
              df_out <- df_filtered %>%
                mutate(
                  year = yr,
                  quarter = qtr,
                  industry = naics_to_label[naics],
                  naics = naics
                )
              all_results[[length(all_results) + 1]] <- df_out
            }
            unlink(csv_path)
          }
        }, error = function(e) NULL)
      }
    }

    cat("    Processed", yr, "\n")
  }, error = function(e) {
    cat("    Error processing", yr, ":", e$message, "\n")
  })
}

if (length(all_results) > 0) {
  qcew_raw <- bind_rows(all_results)
  write_csv(qcew_raw, file.path(DATA_DIR, "qcew_raw.csv"))
  cat("QCEW data saved:", nrow(qcew_raw), "rows\n")
} else {
  cat("ERROR: No QCEW data fetched.\n")
}

cat("=== Done ===\n")
