## 01b_fetch_older.R — Download older NBI years with correct URL pattern
source("00_packages.R")

data_dir <- "../data"

## Older years use "hwybronlyonefile" instead of "hwybronefiledel"
older_years <- c(2000, 2002, 2004, 2005, 2006, 2008, 2010, 2012, 2014, 2016)

for (yr in older_years) {
  csv_file <- file.path(data_dir, sprintf("nbi_%d.csv", yr))
  if (file.exists(csv_file)) {
    cat(sprintf("%d: already exists\n", yr))
    next
  }

  zip_url <- sprintf("https://www.fhwa.dot.gov/bridge/nbi/%dhwybronlyonefile.zip", yr)
  zip_file <- file.path(data_dir, sprintf("nbi_%d.zip", yr))

  cat(sprintf("Trying %d: %s\n", yr, zip_url))
  tryCatch({
    download.file(zip_url, zip_file, mode = "wb", quiet = TRUE)
    csv_names <- unzip(zip_file, list = TRUE)$Name
    main_csv <- csv_names[grepl("[.]txt$|[.]csv$", csv_names, ignore.case = TRUE)]
    if (length(main_csv) == 0) main_csv <- csv_names[1]
    unzip(zip_file, files = main_csv[1], exdir = data_dir)
    extracted <- file.path(data_dir, main_csv[1])
    if (file.exists(extracted) && extracted != csv_file) {
      file.rename(extracted, csv_file)
    }
    file.remove(zip_file)
    cat(sprintf("  Success! %.1f MB\n", file.size(csv_file) / 1e6))
  }, error = function(e) {
    cat(sprintf("  Failed: %s\n", e$message))
  })
}

## Now rebuild the panel with all available years
cat("\nRebuilding panel with all available years...\n")
csv_files <- list.files(data_dir, pattern = "^nbi_[0-9]{4}[.]csv$", full.names = TRUE)
cat(sprintf("Found %d year files\n", length(csv_files)))

all_bridges <- list()
for (f in csv_files) {
  yr <- as.integer(gsub(".*nbi_([0-9]{4})[.]csv", "\\1", f))
  cat(sprintf("Reading %d...\n", yr))

  header <- names(fread(f, nrows = 0))

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
    "SERVICE_ON_042A", "SERVICE_UND_042B",
    "DECK_AREA_SQ_METER_NBI_COMPUTED"
  )

  use_cols <- intersect(want_cols, header)
  dt <- fread(f, select = use_cols, showProgress = FALSE)
  dt[, nbi_year := yr]
  all_bridges[[as.character(yr)]] <- dt
  cat(sprintf("  %s bridges\n", format(nrow(dt), big.mark = ",")))
}

nbi_panel <- rbindlist(all_bridges, fill = TRUE)
cat(sprintf("\nTotal: %s observations, %s unique bridges, %d years\n",
            format(nrow(nbi_panel), big.mark = ","),
            format(uniqueN(nbi_panel$STRUCTURE_NUMBER_008), big.mark = ","),
            uniqueN(nbi_panel$nbi_year)))

fwrite(nbi_panel, file.path(data_dir, "nbi_panel_raw.csv"))
cat("Saved: nbi_panel_raw.csv\n")
