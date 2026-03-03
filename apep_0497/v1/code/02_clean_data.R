## =============================================================================
## 02_clean_data.R — Clean and construct analysis panel
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== DATA CLEANING ===\n\n")

## =============================================================================
## 1. Process CdD DVF — Commune-Level Price Aggregates (2014-2020)
## =============================================================================

cat("--- Processing CdD commune-level DVF (2014-2020) ---\n")

cdd <- fread(file.path(data_dir, "dvf", "dvf_commune_2014_2020.csv"), encoding = "UTF-8")

## Clean year
cdd[, year := as.integer(substr(anneemut, 1, 4))]

## Key variables for our panel:
## vfmed_ventem = median price for house sales (vente maison)
## vfmed_ventea = median price for apartment sales (vente appartement)
## vfm2_ventea = price per m2 for apartment sales
## nbmut_ventem = number of house sales
## nbmut_ventea = number of apartment sales
## codgeo_2020 = commune code

## Create commune-level panel from CdD
cdd_panel <- cdd[, .(
  code_commune = codgeo_2020,
  year = year,
  median_price_house = as.numeric(vfmed_ventem),
  median_price_apt = as.numeric(vfmed_ventea),
  price_m2_apt = as.numeric(vfm2_ventea),
  n_sales_house = as.integer(nbmut_ventem),
  n_sales_apt = as.integer(nbmut_ventea),
  n_sales_total = as.integer(nbmut_vente),
  dept_name = dep_name,
  region_name = reg_name
)]

## Compute combined price metrics
cdd_panel[, n_sales_residential := n_sales_house + n_sales_apt]

## Weighted average median price (using counts as weights)
cdd_panel[, median_price := fifelse(
  n_sales_house > 0 & n_sales_apt > 0,
  (median_price_house * n_sales_house + median_price_apt * n_sales_apt) /
    (n_sales_house + n_sales_apt),
  fifelse(n_sales_house > 0, median_price_house, median_price_apt)
)]

## Log price
cdd_panel[median_price > 0, log_price := log(median_price)]

## Standardize commune code
cdd_panel[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]
cdd_panel[, code_dept := substr(code_commune, 1, 2)]

## Drop overseas + Alsace-Moselle for consistency
cdd_panel <- cdd_panel[!code_dept %in% c("67", "68", "57", "97", "98")]

cat("CdD panel: ", format(nrow(cdd_panel), big.mark = ","), "rows,",
    uniqueN(cdd_panel$code_commune), "communes,",
    uniqueN(cdd_panel$year), "years\n")

## =============================================================================
## 2. Process Geo-DVF Transactions (2021-2024) → Aggregate to Commune Level
## =============================================================================

cat("\n--- Processing geo-DVF transactions (2021-2024) ---\n")

dvf_dir <- file.path(data_dir, "dvf")
geo_files <- list.files(dvf_dir, pattern = "dvf_geo_202[1-4]\\.csv\\.gz", full.names = TRUE)

if (length(geo_files) > 0) {
  geo_list <- list()
  for (f in geo_files) {
    yr <- as.integer(gsub(".*geo_(\\d{4}).*", "\\1", basename(f)))
    cat("  Reading geo-DVF", yr, "...\n")
    dt <- fread(cmd = paste("gzip -dc", shQuote(f)),
                select = c("id_mutation", "date_mutation", "nature_mutation",
                           "valeur_fonciere", "code_commune",
                           "code_departement", "type_local",
                           "surface_reelle_bati"),
                colClasses = list(character = c("code_commune", "code_departement")))

    ## Filter: sales of residential properties only
    dt <- dt[nature_mutation == "Vente" &
               type_local %in% c("Maison", "Appartement")]
    dt[, valeur_fonciere := as.numeric(gsub(",", ".", as.character(valeur_fonciere)))]
    dt <- dt[!is.na(valeur_fonciere) & valeur_fonciere > 10000]

    dt[, year := yr]
    dt[, surface := as.numeric(surface_reelle_bati)]

    ## Aggregate to commune level
    commune_agg <- dt[, .(
      median_price_house = median(valeur_fonciere[type_local == "Maison"], na.rm = TRUE),
      median_price_apt = median(valeur_fonciere[type_local == "Appartement"], na.rm = TRUE),
      n_sales_house = sum(type_local == "Maison"),
      n_sales_apt = sum(type_local == "Appartement"),
      n_sales_total = .N,
      n_sales_residential = .N,
      price_m2_apt = median(valeur_fonciere[type_local == "Appartement" &
                                              !is.na(surface) & surface > 10] /
                              surface[type_local == "Appartement" &
                                        !is.na(surface) & surface > 10],
                            na.rm = TRUE)
    ), by = .(code_commune, year)]

    commune_agg[, code_commune := str_pad(code_commune, 5, pad = "0")]
    commune_agg[, code_dept := substr(code_commune, 1, 2)]

    ## Combined median price
    commune_agg[, median_price := fifelse(
      n_sales_house > 0 & n_sales_apt > 0,
      (median_price_house * n_sales_house + median_price_apt * n_sales_apt) /
        (n_sales_house + n_sales_apt),
      fifelse(n_sales_house > 0, median_price_house, median_price_apt)
    )]
    commune_agg[median_price > 0, log_price := log(median_price)]

    geo_list[[as.character(yr)]] <- commune_agg
    cat("    ", yr, ":", format(nrow(commune_agg), big.mark = ","), "communes\n")
  }

  geo_panel <- rbindlist(geo_list, fill = TRUE)
  geo_panel <- geo_panel[!code_dept %in% c("67", "68", "57", "97", "98")]
} else {
  cat("  No geo-DVF files found\n")
  geo_panel <- NULL
}

## =============================================================================
## 3. Combine DVF Panels
## =============================================================================

cat("\n--- Combining DVF panels ---\n")

## Stack CdD (2014-2020) and geo-DVF (2021-2024)
common_cols <- c("code_commune", "year", "code_dept",
                 "median_price", "log_price",
                 "median_price_house", "median_price_apt", "price_m2_apt",
                 "n_sales_house", "n_sales_apt", "n_sales_total",
                 "n_sales_residential")

## Ensure all columns exist
for (col in common_cols) {
  if (!col %in% names(cdd_panel)) cdd_panel[, (col) := NA]
  if (!is.null(geo_panel) && !col %in% names(geo_panel)) geo_panel[, (col) := NA]
}

if (!is.null(geo_panel)) {
  panel <- rbindlist(list(
    cdd_panel[, ..common_cols],
    geo_panel[, ..common_cols]
  ), fill = TRUE)
} else {
  panel <- cdd_panel[, ..common_cols]
}

cat("Combined panel:", format(nrow(panel), big.mark = ","), "rows,",
    uniqueN(panel$code_commune), "communes,",
    min(panel$year), "-", max(panel$year), "\n")

## =============================================================================
## 4. Process REI — Extract TH Rates from Excel
## =============================================================================

cat("\n--- Processing REI tax rates ---\n")

rei_dir <- file.path(data_dir, "rei")

## We need the 2017 REI for baseline treatment. Extract from ZIP.
rei_2017_zip <- file.path(rei_dir, "rei_2017.zip")
if (file.exists(rei_2017_zip) && file.size(rei_2017_zip) > 1e6) {
  ## Already extracted above
  rei_xlsx <- list.files(rei_dir, pattern = "REI_COMPLET_2017\\.xlsx",
                         recursive = TRUE, full.names = TRUE)[1]

  if (!is.na(rei_xlsx) && file.exists(rei_xlsx)) {
    cat("  Reading REI 2017 Excel:", rei_xlsx, "\n")

    ## Read first sheet to inspect
    sheets <- readxl::excel_sheets(rei_xlsx)
    cat("  Sheets:", paste(sheets, collapse = ", "), "\n")

    ## Read the main data sheet
    ## REI Excel typically has a header section; we need to find the data start
    rei_raw <- tryCatch({
      readxl::read_xlsx(rei_xlsx, sheet = 1, skip = 0, col_types = "text")
    }, error = function(e) {
      cat("  Error reading sheet 1:", e$message, "\n")
      readxl::read_xlsx(rei_xlsx, sheet = sheets[1], skip = 0, col_types = "text")
    })

    cat("  REI 2017: ", nrow(rei_raw), "rows,", ncol(rei_raw), "columns\n")
    cat("  Column names:", paste(head(names(rei_raw), 15), collapse = ", "), "...\n")

    ## REI Excel uses coded column names from DGFiP documentation:
    ## DEP = département code (2 chars), COM = commune code within dept (3 chars)
    ## H32 = taux communal de la taxe d'habitation (communal TH rate, %)
    ## H12 = taux départemental TH
    ## H32VOTE = taux voté (voted rate)
    ## Commune code = paste0(DEP, COM) → 5-digit INSEE code
    rei_dt <- as.data.table(rei_raw)

    ## Verify expected columns exist
    stopifnot("DEP column missing from REI" = "DEP" %in% names(rei_dt))
    stopifnot("COM column missing from REI" = "COM" %in% names(rei_dt))
    stopifnot("H32 column missing from REI" = "H32" %in% names(rei_dt))

    ## Construct commune code and extract TH rate
    rei_2017 <- data.table(
      code_commune = paste0(
        str_pad(as.character(rei_dt$DEP), 2, pad = "0"),
        str_pad(as.character(rei_dt$COM), 3, pad = "0")
      ),
      th_rate_2017 = as.numeric(rei_dt$H32)
    )

    ## Also extract departmental TH rate and TH base for richer analysis
    if ("H12" %in% names(rei_dt)) {
      rei_2017[, th_rate_dept := as.numeric(rei_dt$H12)]
    }
    if ("H11" %in% names(rei_dt)) {
      rei_2017[, th_base := as.numeric(rei_dt$H11)]
    }

    rei_2017 <- rei_2017[!is.na(th_rate_2017) & !is.na(code_commune) &
                            code_commune != "NANA" & nchar(code_commune) == 5]
    cat("  REI 2017 parsed:", nrow(rei_2017), "communes with TH rates\n")
    cat("  TH rate range:", paste(round(range(rei_2017$th_rate_2017, na.rm = TRUE), 2), collapse = " - "), "%\n")
    cat("  Mean TH rate:", round(mean(rei_2017$th_rate_2017, na.rm = TRUE), 2), "%\n")
  } else {
    cat("  REI 2017 Excel not found after extraction.\n")
    rei_2017 <- NULL
  }
} else {
  stop("FATAL: REI 2017 ZIP not found at ", rei_2017_zip,
       ". Run 01_fetch_data.R first to download REI data.")
}

## =============================================================================
## 5. Merge REI with Price Panel
## =============================================================================

cat("\n--- Merging treatment data ---\n")

if (!is.null(rei_2017) && nrow(rei_2017) > 0) {
  panel <- merge(panel, rei_2017, by = "code_commune", all.x = TRUE)
  cat("Merged REI:", sum(!is.na(panel$th_rate_2017)), "of", nrow(panel),
      "rows have TH rate data\n")
} else {
  cat("  WARNING: No REI data available. Will use CdD-only analysis.\n")
  panel[, th_rate_2017 := NA_real_]
}

## =============================================================================
## 6. Construct Treatment Variables
## =============================================================================

cat("\n--- Constructing treatment variables ---\n")

## Post-reform indicator
panel[, post := as.integer(year >= 2018)]

## Treatment dose (continuous)
panel[, th_dose := th_rate_2017]

## Standardize
panel[!is.na(th_dose), th_dose_std := (th_dose - mean(th_dose, na.rm = TRUE)) /
        sd(th_dose, na.rm = TRUE)]

## Treatment terciles
panel[!is.na(th_dose), th_tercile := as.integer(cut(th_dose,
  breaks = quantile(th_dose, c(0, 1/3, 2/3, 1), na.rm = TRUE),
  include.lowest = TRUE))]

## Relative year
panel[, rel_year := year - 2018]

## Log transactions
panel[n_sales_residential > 0, log_transactions := log(n_sales_residential)]

## Share apartments (time-varying composition control)
panel[n_sales_residential > 0, share_apartments := n_sales_apt / n_sales_residential]

## Log price per m2 (apartments only, where available)
panel[price_m2_apt > 0 & !is.na(price_m2_apt), log_price_m2 := log(price_m2_apt)]

## n_transactions alias
panel[, n_transactions := n_sales_residential]

## =============================================================================
## 7. Filter to Analysis Sample
## =============================================================================

cat("\n--- Filtering analysis sample ---\n")

## Keep communes with at least 4 years of price data
commune_coverage <- panel[!is.na(log_price), .N, by = code_commune]
keep_communes <- commune_coverage[N >= 4]$code_commune
panel <- panel[code_commune %in% keep_communes]

## Drop extreme prices
if (sum(!is.na(panel$median_price)) > 0) {
  p1 <- quantile(panel$median_price, 0.005, na.rm = TRUE)
  p99 <- quantile(panel$median_price, 0.995, na.rm = TRUE)
  panel <- panel[is.na(median_price) | (median_price >= p1 & median_price <= p99)]
}

## =============================================================================
## 8. Save
## =============================================================================

cat("\n--- Saving analysis panel ---\n")

fwrite(panel, file.path(data_dir, "analysis_panel.csv"))

cat("Final panel:", format(nrow(panel), big.mark = ","), "commune-years\n")
cat("  Communes:", uniqueN(panel$code_commune), "\n")
cat("  Years:", paste(range(panel$year), collapse = "-"), "\n")
cat("  Départements:", uniqueN(panel$code_dept), "\n")
cat("  Communes with TH rate:", sum(!is.na(unique(panel[!is.na(th_rate_2017)]$code_commune))), "\n")

## === DATA VALIDATION (required) ===
stopifnot("Expected 70+ départements" = uniqueN(panel$code_dept) >= 70)
stopifnot("Expected 2014-2020+ coverage" = all(2014:2020 %in% panel$year))
stopifnot("Expected 5000+ communes" = uniqueN(panel$code_commune) >= 5000)
cat("\nData validation passed.\n")
