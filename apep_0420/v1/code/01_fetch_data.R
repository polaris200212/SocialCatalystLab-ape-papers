## 01_fetch_data.R — Download National Bridge Inventory data
## APEP-0420: The Visible and the Invisible
##
## Data source: FHWA National Bridge Inventory
## https://www.fhwa.dot.gov/bridge/nbi/ascii.cfm

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## We fetch NBI data for selected years spanning our study period
## Full panel would be 24 years × 50MB = 1.2GB; we sample key years
## to keep data manageable while maintaining a rich panel
years <- c(2000, 2002, 2004, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2023)

all_bridges <- list()

for (yr in years) {
  cat(sprintf("Fetching NBI data for %d...\n", yr))

  zip_url <- sprintf(
    "https://www.fhwa.dot.gov/bridge/nbi/%dhwybronefiledel.zip",
    yr
  )

  zip_file <- file.path(data_dir, sprintf("nbi_%d.zip", yr))
  csv_file <- file.path(data_dir, sprintf("nbi_%d.csv", yr))

  if (!file.exists(csv_file)) {
    tryCatch({
      download.file(zip_url, zip_file, mode = "wb", quiet = TRUE)
      csv_names <- unzip(zip_file, list = TRUE)$Name
      main_csv <- csv_names[grepl("\\.txt$|\\.csv$", csv_names, ignore.case = TRUE)]
      if (length(main_csv) == 0) main_csv <- csv_names[1]
      unzip(zip_file, files = main_csv[1], exdir = data_dir)
      extracted <- file.path(data_dir, main_csv[1])
      if (file.exists(extracted) && extracted != csv_file) {
        file.rename(extracted, csv_file)
      }
      file.remove(zip_file)
      cat(sprintf("  Downloaded and extracted %d (%.1f MB)\n", yr,
                  file.size(csv_file) / 1e6))
    }, error = function(e) {
      cat(sprintf("  WARNING: Could not download %d: %s\n", yr, e$message))
    })
  } else {
    cat(sprintf("  Already exists: %d\n", yr))
  }

  if (file.exists(csv_file)) {
    tryCatch({
      ## Read header to identify available columns
      header <- names(fread(csv_file, nrows = 0))

      ## Key columns we need
      want_cols <- c(
        "STATE_CODE_001", "COUNTY_CODE_003", "STRUCTURE_NUMBER_008",
        "YEAR_BUILT_027", "ADT_029", "YEAR_ADT_030",
        "DESIGN_LOAD_031", "DECK_COND_058", "SUPERSTRUCTURE_COND_059",
        "SUBSTRUCTURE_COND_060", "CHANNEL_COND_061",
        "FUNCTIONAL_CLASS_026", "STRUCTURE_KIND_043A",
        "STRUCTURE_TYPE_043B",
        "LAT_016", "LONG_017",
        "MAIN_UNIT_SPANS_045", "MAX_SPAN_LEN_MT_048",
        "STRUCTURE_LEN_MT_049", "DECK_WIDTH_MT_052",
        "SERVICE_ON_042A", "SERVICE_UND_042B"
      )

      ## Also check for computed columns
      computed <- c("DECK_AREA_SQ_METER_NBI_COMPUTED")
      want_cols <- c(want_cols, intersect(computed, header))

      use_cols <- intersect(want_cols, header)

      dt <- fread(csv_file, select = use_cols, showProgress = FALSE)
      dt[, nbi_year := yr]
      all_bridges[[as.character(yr)]] <- dt
      cat(sprintf("  Loaded %d: %s bridges\n", yr,
                  format(nrow(dt), big.mark = ",")))
    }, error = function(e) {
      cat(sprintf("  WARNING: Could not parse %d: %s\n", yr, e$message))
    })
  }
}

## Combine all years
if (length(all_bridges) > 0) {
  nbi_panel <- rbindlist(all_bridges, fill = TRUE)
  cat(sprintf("\nTotal observations: %s\n",
              format(nrow(nbi_panel), big.mark = ",")))
  cat(sprintf("Unique bridges: %s\n",
              format(length(unique(nbi_panel$STRUCTURE_NUMBER_008)),
                     big.mark = ",")))
  cat(sprintf("Years: %s\n",
              paste(sort(unique(nbi_panel$nbi_year)), collapse = ", ")))

  fwrite(nbi_panel, file.path(data_dir, "nbi_panel_raw.csv"))
  cat("Saved: nbi_panel_raw.csv\n")
} else {
  stop("ERROR: No NBI data could be downloaded.")
}

## Governor election data
cat("\nConstructing governor election year data...\n")

governor_election_years <- data.table(
  state_fips = c(
    1,2,4,5,6,8,9,10,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
    31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56
  ),
  cycle = c(
    2,2,2,2,2,2,2,0,2,2,2,2,2,0,2,2,99,99,2,2,2,2,2,99,0,0,
    2,2,2,99,2,2,0,0,2,2,2,2,2,2,2,2,2,0,2,99,0,0,2,2
  )
)

gov_elections <- list()
for (i in seq_len(nrow(governor_election_years))) {
  sfips <- governor_election_years$state_fips[i]
  cyc <- governor_election_years$cycle[i]

  if (cyc == 2) {
    elec_years <- seq(2002, 2022, by = 4)
  } else if (cyc == 0) {
    elec_years <- seq(2000, 2020, by = 4)
  } else {
    elec_years <- seq(2003, 2023, by = 4)
  }

  gov_elections[[i]] <- data.table(
    state_fips = sfips,
    year = elec_years,
    gov_election = 1L
  )
}
gov_elections <- rbindlist(gov_elections)
fwrite(gov_elections, file.path(data_dir, "governor_elections.csv"))
cat(sprintf("Governor election data: %d state-year observations\n",
            nrow(gov_elections)))

cat("\nData fetch complete.\n")
