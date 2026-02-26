## ============================================================================
## 02b_upgrade_gadm2.R — Upgrade from GADM1 to GADM2 (département-level)
## Run AFTER 02_clean_data.R has produced the GADM1 results
## This replaces the SCI exposure with higher-resolution GADM2 data
## ============================================================================
source("00_packages.R")

gadm2_csv <- file.path(data_dir, "gadm2_fr_all.csv")

if (!file.exists(gadm2_csv)) {
  stop("GADM2 extracted pairs not found. Run the extraction step first.\n",
       "Expected file: ", gadm2_csv)
}

## ========================================================================
## 1. READ AND PROCESS GADM2 SCI DATA
## ========================================================================
cat("=== Reading GADM2 SCI data ===\n")

sci2 <- fread(gadm2_csv)
cat("GADM2 pairs loaded:", nrow(sci2), "rows\n")
cat("Columns:", paste(names(sci2), collapse = ", "), "\n")

# Filter to mainland France (FRA.*) and UK/DE/CH only
fr_regions2 <- unique(c(
  sci2[grepl("^FRA\\.", user_region)]$user_region,
  sci2[grepl("^FRA\\.", friend_region)]$friend_region
))
fr_regions2 <- fr_regions2[grepl("^FRA\\.", fr_regions2)]

uk_regions2 <- unique(c(
  sci2[grepl("^GBR\\.", user_region)]$user_region,
  sci2[grepl("^GBR\\.", friend_region)]$friend_region
))

cat("Unique mainland French GADM2 regions:", length(fr_regions2), "\n")
cat("Unique UK GADM2 regions:", length(uk_regions2), "\n")

## ========================================================================
## 2. CONSTRUCT EXPOSURE MEASURES
## ========================================================================
cat("\n=== Constructing département exposure ===\n")

# FR → UK pairs (mainland France only)
sci2_fr_uk <- sci2[
  user_country == "FR" & grepl("^FRA\\.", user_region) &
    friend_country == "GB" & grepl("^GBR\\.", friend_region)
]
sci2_fr_uk[, `:=`(fr_gadm2 = user_region, uk_gadm2 = friend_region)]

# UK → FR pairs (reverse direction)
sci2_uk_fr <- sci2[
  user_country == "GB" & grepl("^GBR\\.", user_region) &
    friend_country == "FR" & grepl("^FRA\\.", friend_region)
]
sci2_uk_fr[, `:=`(fr_gadm2 = friend_region, uk_gadm2 = user_region)]

# Combine and deduplicate
sci2_fr_uk_all <- rbind(
  sci2_fr_uk[, .(fr_gadm2, uk_gadm2, scaled_sci)],
  sci2_uk_fr[, .(fr_gadm2, uk_gadm2, scaled_sci)]
)
sci2_fr_uk_all <- unique(sci2_fr_uk_all, by = c("fr_gadm2", "uk_gadm2"))
cat("FR-UK unique pairs:", nrow(sci2_fr_uk_all), "\n")

# Construct département exposure at GADM2 level
dept2_exposure <- sci2_fr_uk_all[, .(
  sci_total_uk = sum(scaled_sci),
  sci_mean_uk = mean(scaled_sci),
  n_uk_connections = .N,
  sci_hhi = sum((scaled_sci / sum(scaled_sci))^2)
), by = fr_gadm2]

dept2_exposure[, log_sci_uk := log(sci_total_uk + 1)]

cat("\nGADM2 exposure variation:\n")
cat("  Mean SCI total UK:", mean(dept2_exposure$sci_total_uk), "\n")
cat("  SD SCI total UK:", sd(dept2_exposure$sci_total_uk), "\n")
cat("  CV:", sd(dept2_exposure$sci_total_uk) / mean(dept2_exposure$sci_total_uk), "\n")
cat("  Range:", range(dept2_exposure$sci_total_uk), "\n")
cat("  Units:", nrow(dept2_exposure), "\n")

# Germany (placebo)
sci2_fr_de <- sci2[
  user_country == "FR" & grepl("^FRA\\.", user_region) &
    friend_country == "DE" & grepl("^DEU\\.", friend_region)
]
sci2_fr_de[, `:=`(fr_gadm2 = user_region, de_gadm2 = friend_region)]

if (nrow(sci2_fr_de) > 0) {
  dept2_exposure_de <- sci2_fr_de[, .(
    sci_total_de = sum(scaled_sci),
    sci_mean_de = mean(scaled_sci)
  ), by = fr_gadm2]

  dept2_exposure <- merge(dept2_exposure, dept2_exposure_de,
                          by = "fr_gadm2", all.x = TRUE)
  dept2_exposure[, log_sci_de := log(sci_total_de + 1)]
}

# Switzerland
sci2_fr_ch <- sci2[
  user_country == "FR" & grepl("^FRA\\.", user_region) &
    friend_country == "CH" & grepl("^CHE\\.", friend_region)
]
sci2_fr_ch[, `:=`(fr_gadm2 = user_region, ch_gadm2 = friend_region)]

if (nrow(sci2_fr_ch) > 0) {
  dept2_exposure_ch <- sci2_fr_ch[, .(
    sci_total_ch = sum(scaled_sci),
    sci_mean_ch = mean(scaled_sci)
  ), by = fr_gadm2]

  dept2_exposure <- merge(dept2_exposure, dept2_exposure_ch,
                          by = "fr_gadm2", all.x = TRUE)
  dept2_exposure[, log_sci_ch := log(sci_total_ch + 1)]
}

## ========================================================================
## 3. MAP GADM2 TO DÉPARTEMENT CODES (VERIFIED MAPPING)
## ========================================================================
cat("\n=== Mapping GADM2 to département codes ===\n")

# Use the verified mapping from GADM 3.6 shapefile (CC_2 field)
# This mapping was extracted from gadm36_FRA_2_sp.rds and saved as CSV
mapping_file <- file.path(data_dir, "gadm2_dept_mapping.csv")

if (file.exists(mapping_file)) {
  cat("Loading verified GADM2 mapping from CSV...\n")
  gadm2_to_dept <- fread(mapping_file)
} else {
  cat("Mapping CSV not found. Building from GADM 3.6 shapefile...\n")
  gadm36_file <- "/tmp/gadm36_FRA_2_sp.rds"
  if (!file.exists(gadm36_file)) {
    download.file("https://geodata.ucdavis.edu/gadm/gadm3.6/Rsp/gadm36_FRA_2_sp.rds",
                  gadm36_file, mode = "wb", quiet = TRUE)
  }
  sp <- readRDS(gadm36_file)
  d <- sp@data
  gadm2_to_dept <- data.table(
    fr_gadm2 = d$GID_2,
    code_departement = d$CC_2,
    dept_name = d$NAME_2,
    region_name = d$NAME_1
  )
  fwrite(gadm2_to_dept, mapping_file)
}

cat("Mapping table:", nrow(gadm2_to_dept), "départements\n")

# Verify the mapping matches actual GADM2 codes in SCI data
actual_codes <- sort(unique(dept2_exposure$fr_gadm2))
mapped_codes <- sort(gadm2_to_dept$fr_gadm2)

matched <- sum(actual_codes %in% mapped_codes)
unmatched_actual <- actual_codes[!actual_codes %in% mapped_codes]

cat("Matched:", matched, "/", length(actual_codes), "SCI codes\n")
if (length(unmatched_actual) > 0) {
  cat("WARNING: Unmatched SCI codes:", paste(unmatched_actual, collapse = ", "), "\n")
}

# Merge mapping with exposure
dept2_exposure <- merge(dept2_exposure,
                        gadm2_to_dept[, .(fr_gadm2, code_departement, dept_name, region_name)],
                        by = "fr_gadm2", all.x = TRUE)

cat("\nExposure by département (top 15 by UK SCI):\n")
print(dept2_exposure[order(-sci_total_uk),
                     .(dept_name, code_departement, region_name,
                       sci_total_uk, sci_total_de, sci_total_ch)][1:min(15, .N)])

cat("\nCorrelation UK-DE:", cor(dept2_exposure$sci_total_uk,
                               dept2_exposure$sci_total_de, use = "complete"), "\n")
cat("Correlation UK-CH:", cor(dept2_exposure$sci_total_uk,
                               dept2_exposure$sci_total_ch, use = "complete"), "\n")

## ========================================================================
## 4. BUILD DÉPARTEMENT-LEVEL ANALYSIS PANEL
## ========================================================================
cat("\n=== Building département-level panel ===\n")

# DVF is already at département level — read it fresh from the raw files
dvf_dir <- file.path(data_dir, "dvf")
dvf_files <- list.files(dvf_dir, pattern = "\\.csv\\.gz$", full.names = TRUE)

dvf_all <- list()
for (ff in dvf_files) {
  cat("  Reading:", basename(ff), "\n")
  tryCatch({
    dt <- fread(cmd = paste("gunzip -c", ff),
                select = c("date_mutation", "nature_mutation", "valeur_fonciere",
                           "code_departement", "type_local", "surface_reelle_bati"),
                fill = TRUE)

    dt <- dt[nature_mutation == "Vente" & type_local %in% c("Appartement", "Maison")]
    dt[, date_mutation := as.Date(date_mutation)]
    dt[, `:=`(year = year(date_mutation), quarter = quarter(date_mutation))]
    dt[, valeur_fonciere := as.numeric(gsub(",", ".", as.character(valeur_fonciere)))]
    dt <- dt[!is.na(valeur_fonciere) & valeur_fonciere > 10000 & valeur_fonciere < 10000000]
    dt[, surface_reelle_bati := as.numeric(surface_reelle_bati)]
    dt <- dt[!is.na(surface_reelle_bati) & surface_reelle_bati > 5]
    dt[, price_m2 := valeur_fonciere / surface_reelle_bati]
    dt <- dt[price_m2 > 100 & price_m2 < 50000]

    dvf_all[[basename(ff)]] <- dt
    cat("    Kept", nrow(dt), "transactions\n")
  }, error = function(e) {
    cat("    Error:", conditionMessage(e), "\n")
  })
}

dvf <- rbindlist(dvf_all, fill = TRUE)
cat("Total DVF transactions:", nrow(dvf), "\n")

# Aggregate to département × quarter
dvf_dept_qtr <- dvf[, .(
  median_price_m2 = median(price_m2, na.rm = TRUE),
  mean_price_m2 = mean(price_m2, na.rm = TRUE),
  n_transactions = .N,
  sd_price_m2 = sd(price_m2, na.rm = TRUE)
), by = .(code_departement, year, quarter)]

dvf_dept_qtr[, `:=`(
  yq = paste0(year, "Q", quarter),
  log_price_m2 = log(median_price_m2),
  log_transactions = log(n_transactions)
)]

cat("DVF département panel:", nrow(dvf_dept_qtr), "dept-quarter obs\n")
saveRDS(dvf_dept_qtr, file.path(data_dir, "dvf_dept_quarter.rds"))

# Build panel: departments × quarters
mapped_depts <- dept2_exposure[!is.na(code_departement)]$code_departement
cat("Départements with SCI data:", length(mapped_depts), "\n")

time_grid <- data.table(expand.grid(
  year = 2014:2023,
  quarter = 1:4,
  stringsAsFactors = FALSE
))
time_grid[, `:=`(
  yq = paste0(year, "Q", quarter),
  t = (year - 2014) * 4 + quarter,
  post_referendum = as.integer(year > 2016 | (year == 2016 & quarter >= 3)),
  post_transition = as.integer(year >= 2021)
)]
setorder(time_grid, year, quarter)

panel2 <- CJ(code_departement = mapped_depts, t = time_grid$t)
panel2 <- merge(panel2, time_grid, by = "t")
panel2 <- merge(panel2, dept2_exposure[!is.na(code_departement),
                                       .(code_departement, sci_total_uk, sci_mean_uk,
                                         n_uk_connections, sci_hhi, log_sci_uk,
                                         sci_total_de, log_sci_de,
                                         sci_total_ch, log_sci_ch,
                                         fr_gadm2, dept_name, region_name)],
                by = "code_departement", all.x = TRUE)

# Treatment interactions
panel2[, `:=`(
  treat_uk_post = log_sci_uk * post_referendum,
  treat_uk_transition = log_sci_uk * post_transition,
  placebo_de_post = log_sci_de * post_referendum
)]

# Merge DVF outcomes
panel2 <- merge(panel2, dvf_dept_qtr[, .(code_departement, year, quarter,
                                         log_price_m2, log_transactions,
                                         n_transactions, median_price_m2)],
                by = c("code_departement", "year", "quarter"), all.x = TRUE)

cat("\nDépartement panel:", nrow(panel2), "obs (",
    length(unique(panel2$code_departement)), "depts x",
    length(unique(panel2$t)), "quarters)\n")
cat("DVF non-missing:", sum(!is.na(panel2$log_price_m2)), "\n")

# Use 'fr_region' as the unit identifier for compatibility with 03-06 scripts
panel2[, fr_region := code_departement]

# Save — REPLACE the analysis panel with département-level version
saveRDS(panel2, file.path(data_dir, "analysis_panel.rds"))
saveRDS(dept2_exposure, file.path(data_dir, "dept_exposure.rds"))

# Also save the raw SCI pairs for robustness scripts
saveRDS(sci2_fr_uk_all, file.path(data_dir, "sci_france_uk.rds"))

cat("\n=== GADM2 upgrade complete ===\n")
cat("Analysis panel upgraded to département level (96 units).\n")
cat("Scripts 03-06 can be re-run without changes.\n")
