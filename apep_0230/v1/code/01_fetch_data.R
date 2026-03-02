## 01_fetch_data.R - Download and prepare raw data
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ─────────────────────────────────────────────────────────────
## 1. Neighbourhood Planning data from MHCLG/Locality
## ─────────────────────────────────────────────────────────────

np_url <- "https://neighbourhoodplanning.org/wp-content/uploads/240322-Neighbourhood-Planning-Data@22March2024.xlsx"
np_file <- file.path(data_dir, "np_data.xlsx")

if (!file.exists(np_file)) {
  cat("Downloading Neighbourhood Planning data...\n")
  download.file(np_url, np_file, mode = "wb", quiet = TRUE)
  cat("  Done.\n")
} else {
  cat("NP data already downloaded.\n")
}

## Read and clean NP data
np_raw <- read_excel(np_file, sheet = 1)
names(np_raw) <- c("area_name", "la_name", "la2", "progress", "referendum_date", "turnout_pct", "yes_pct")

np <- np_raw %>%
  filter(grepl("Plan Made|Passed Referendum", progress)) %>%
  mutate(
    referendum_date = as.Date(referendum_date),
    referendum_year = year(referendum_date),
    la_clean = str_replace_all(la_name,
      "\\s*(Borough|District|County|City|Metropolitan|Royal Borough of|London Borough of)\\s*(Council)?\\s*$", ""),
    la_clean = str_replace_all(la_clean,
      "\\s*(Council of the Isles of Scilly|, City of|, County of)$", ""),
    la_clean = str_trim(la_clean),
    la_upper = toupper(la_clean)
  )

cat(sprintf("Neighbourhood plans loaded: %d made/passed, %d unique LAs\n",
            nrow(np), n_distinct(np$la_name)))

## Build LA-level treatment panel: first NP referendum year per LA
la_first_np <- np %>%
  group_by(la_name, la_upper) %>%
  summarise(
    first_np_year = min(referendum_year, na.rm = TRUE),
    cumulative_nps = n(),
    .groups = "drop"
  )

cat(sprintf("LAs with neighbourhood plans: %d\n", nrow(la_first_np)))
cat(sprintf("Treatment years range: %d to %d\n",
            min(la_first_np$first_np_year), max(la_first_np$first_np_year)))

## Also build year-by-year cumulative NP count per LA
np_yearly <- np %>%
  group_by(la_name, la_upper, referendum_year) %>%
  summarise(new_nps = n(), .groups = "drop") %>%
  arrange(la_name, referendum_year)

## ─────────────────────────────────────────────────────────────
## 2. Land Registry Price Paid Data
## ─────────────────────────────────────────────────────────────
## Download annual CSVs and aggregate to district x year

lr_summary_file <- file.path(data_dir, "land_registry_la_year.csv")

if (!file.exists(lr_summary_file)) {
  cat("Downloading and processing Land Registry data year by year...\n")

  years <- 2005:2023  # Wide window for pre-trends
  lr_all <- list()

  for (yr in years) {
    url <- sprintf("http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-%d.csv", yr)
    tmp_file <- file.path(data_dir, sprintf("pp-%d.csv", yr))

    cat(sprintf("  Downloading %d...", yr))

    tryCatch({
      if (!file.exists(tmp_file)) {
        download.file(url, tmp_file, mode = "wb", quiet = TRUE)
      }

      ## Read with data.table for speed (no header in LR data)
      dt <- fread(tmp_file, header = FALSE, select = c(2, 3, 13),
                  col.names = c("price", "date", "district"))

      ## Aggregate to district x year
      dt[, year := year(as.Date(date))]
      summary_yr <- dt[, .(
        median_price = median(price, na.rm = TRUE),
        mean_price   = mean(price, na.rm = TRUE),
        n_transactions = .N
      ), by = .(district, year)]

      lr_all[[as.character(yr)]] <- summary_yr
      cat(sprintf(" %s districts, %s transactions\n",
                  format(uniqueN(summary_yr$district), big.mark = ","),
                  format(sum(summary_yr$n_transactions), big.mark = ",")))

      ## Remove raw file to save space
      file.remove(tmp_file)

    }, error = function(e) {
      cat(sprintf(" ERROR: %s\n", e$message))
    })
  }

  lr_panel <- rbindlist(lr_all)
  fwrite(lr_panel, lr_summary_file)
  cat(sprintf("Land Registry panel saved: %d district-year observations\n", nrow(lr_panel)))

} else {
  cat("Land Registry panel already processed.\n")
  lr_panel <- fread(lr_summary_file)
}

## ─────────────────────────────────────────────────────────────
## 3. Save processed datasets
## ─────────────────────────────────────────────────────────────

saveRDS(np, file.path(data_dir, "np_clean.rds"))
saveRDS(la_first_np, file.path(data_dir, "la_first_np.rds"))
saveRDS(np_yearly, file.path(data_dir, "np_yearly.rds"))

cat("\nAll data fetched and saved.\n")
