## ============================================================================
## 02_clean_data.R — Data Cleaning and Variable Construction (GADM1 — SUPERSEDED)
## APEP-0460: Across the Channel
##
## NOTE: This script processed GADM1-level SCI data (13 French regions).
## It has been superseded by 02b_upgrade_gadm2.R which processes GADM2-level
## data (96 French départements). The actual analysis pipeline uses 02b.
## This file is retained for documentation purposes only.
## ============================================================================
stop("This script is superseded by 02b_upgrade_gadm2.R. Run that instead.")
source("00_packages.R")

## ========================================================================
## 1. SOCIAL CONNECTEDNESS INDEX — EXTRACT FRANCE × UK PAIRS
## ========================================================================
cat("=== Processing SCI data ===\n")

# Read the GADM1 SCI file (CSV format)
sci_file <- file.path(data_dir, "gadm1.csv")
cat("Reading SCI from:", sci_file, "\n")

# Read only FR-GB rows to save memory (file is 10M rows)
sci_raw <- fread(sci_file)
cat("  SCI raw dimensions:", nrow(sci_raw), "x", ncol(sci_raw), "\n")
cat("  Columns:", paste(names(sci_raw), collapse = ", "), "\n")

# Extract France (mainland) × UK (mainland) pairs
# France mainland: user_country = "FR" AND user_region starts with "FRA."
# UK mainland: friend_country = "GB" AND friend_region starts with "GBR."
sci_fr_uk <- sci_raw[
  (user_country == "FR" & grepl("^FRA\\.", user_region) &
     friend_country == "GB" & grepl("^GBR\\.", friend_region)) |
    (user_country == "GB" & grepl("^GBR\\.", user_region) &
       friend_country == "FR" & grepl("^FRA\\.", friend_region))
]

cat("  France-UK mainland pairs:", nrow(sci_fr_uk), "\n")

# Standardize: FR in column 1, UK in column 2
sci_fr_uk[, `:=`(
  fr_region = ifelse(user_country == "FR", user_region, friend_region),
  uk_region = ifelse(user_country == "GB", user_region, friend_region)
)]
# Remove duplicates (each pair appears twice)
sci_fr_uk <- sci_fr_uk[user_country == "FR"]

cat("  Unique FR regions:", length(unique(sci_fr_uk$fr_region)), "\n")
cat("  Unique UK regions:", length(unique(sci_fr_uk$uk_region)), "\n")
cat("  FR regions:", paste(sort(unique(sci_fr_uk$fr_region)), collapse = ", "), "\n")
cat("  UK regions:", paste(sort(unique(sci_fr_uk$uk_region)), collapse = ", "), "\n")

# GADM1 regions for France (post-2016 reform):
# FRA.1_1  = Auvergne-Rhône-Alpes
# FRA.2_1  = Bourgogne-Franche-Comté
# FRA.3_1  = Bretagne
# FRA.4_1  = Centre-Val de Loire
# FRA.5_1  = Corse
# FRA.6_1  = Grand Est
# FRA.7_1  = Hauts-de-France
# FRA.8_1  = Île-de-France
# FRA.9_1  = Normandie
# FRA.10_1 = Nouvelle-Aquitaine
# FRA.11_1 = Occitanie
# FRA.12_1 = Pays de la Loire
# FRA.13_1 = Provence-Alpes-Côte d'Azur

# UK GADM1:
# GBR.1_1 = England
# GBR.2_1 = Northern Ireland
# GBR.3_1 = Scotland
# GBR.4_1 = Wales

region_names <- data.table(
  fr_region = paste0("FRA.", 1:13, "_1"),
  region_name = c("Auvergne-Rhône-Alpes", "Bourgogne-Franche-Comté",
                  "Bretagne", "Centre-Val de Loire", "Corse",
                  "Grand Est", "Hauts-de-France", "Île-de-France",
                  "Normandie", "Nouvelle-Aquitaine", "Occitanie",
                  "Pays de la Loire", "Provence-Alpes-Côte d'Azur"),
  region_code = c("84","27","53","24","94","44","32","11","28","75","76","52","93")
)

# Similarly for Germany (placebo) and Switzerland (positive placebo)
sci_fr_de <- sci_raw[
  user_country == "FR" & grepl("^FRA\\.", user_region) &
    friend_country == "DE" & grepl("^DEU\\.", friend_region)
]
sci_fr_de[, `:=`(fr_region = user_region, de_region = friend_region)]
cat("  France-Germany pairs:", nrow(sci_fr_de), "\n")

sci_fr_ch <- sci_raw[
  user_country == "FR" & grepl("^FRA\\.", user_region) &
    friend_country == "CH" & grepl("^CHE\\.", friend_region)
]
sci_fr_ch[, `:=`(fr_region = user_region, ch_region = friend_region)]
cat("  France-Switzerland pairs:", nrow(sci_fr_ch), "\n")

# Save
saveRDS(sci_fr_uk, file.path(data_dir, "sci_france_uk.rds"))
saveRDS(sci_fr_de, file.path(data_dir, "sci_france_germany.rds"))
saveRDS(sci_fr_ch, file.path(data_dir, "sci_france_switzerland.rds"))
saveRDS(region_names, file.path(data_dir, "region_names.rds"))

# Free memory
rm(sci_raw)
gc()

## ========================================================================
## 2. CONSTRUCT EXPOSURE MEASURES
## ========================================================================
cat("\n=== Constructing Brexit exposure measures ===\n")

# For each French region: total SCI to UK, Germany, Switzerland
dept_exposure <- sci_fr_uk[, .(
  sci_total_uk = sum(scaled_sci),
  sci_mean_uk = mean(scaled_sci),
  n_uk_connections = .N,
  sci_hhi = sum((scaled_sci / sum(scaled_sci))^2)
), by = fr_region]

dept_exposure_de <- sci_fr_de[, .(
  sci_total_de = sum(scaled_sci),
  sci_mean_de = mean(scaled_sci)
), by = fr_region]

dept_exposure_ch <- sci_fr_ch[, .(
  sci_total_ch = sum(scaled_sci),
  sci_mean_ch = mean(scaled_sci)
), by = fr_region]

# Merge
dept_exposure <- merge(dept_exposure, dept_exposure_de, by = "fr_region", all.x = TRUE)
dept_exposure <- merge(dept_exposure, dept_exposure_ch, by = "fr_region", all.x = TRUE)
dept_exposure <- merge(dept_exposure, region_names, by = "fr_region", all.x = TRUE)

# Log transforms
dept_exposure[, `:=`(
  log_sci_uk = log(sci_total_uk + 1),
  log_sci_de = log(sci_total_de + 1),
  log_sci_ch = log(sci_total_ch + 1)
)]

cat("\nExposure by region (sorted by UK SCI):\n")
print(dept_exposure[order(-sci_total_uk), .(region_name, sci_total_uk, sci_total_de, sci_total_ch)])

cat("\nCorrelation UK-DE:", cor(dept_exposure$sci_total_uk, dept_exposure$sci_total_de), "\n")
cat("Correlation UK-CH:", cor(dept_exposure$sci_total_uk, dept_exposure$sci_total_ch, use = "complete"), "\n")

saveRDS(dept_exposure, file.path(data_dir, "dept_exposure.rds"))

## ========================================================================
## 3. DVF — AGGREGATE HOUSING DATA TO REGION-QUARTER
## ========================================================================
cat("\n=== Processing DVF housing transactions ===\n")

dvf_dir <- file.path(data_dir, "dvf")
dvf_files <- list.files(dvf_dir, pattern = "\\.csv\\.gz$", full.names = TRUE)
cat("DVF files found:", length(dvf_files), "\n")

# Département to region mapping
dept_to_region <- data.table(
  code_departement = c(
    "01","03","07","15","26","38","42","43","63","69","73","74",  # ARA
    "21","25","39","58","70","71","89","90",  # BFC
    "22","29","35","56",  # Bretagne
    "18","28","36","37","41","45",  # CVL
    "2A","2B",  # Corse
    "08","10","51","52","54","55","57","67","68","88",  # Grand Est
    "02","59","60","62","80",  # Hauts-de-France
    "75","77","78","91","92","93","94","95",  # IDF
    "14","27","50","61","76",  # Normandie
    "16","17","19","23","24","33","40","47","64","79","86","87",  # N-Aq
    "09","11","12","30","31","32","34","46","48","65","66","81","82",  # Occitanie
    "44","49","53","72","85",  # Pays de la Loire
    "04","05","06","13","83","84"  # PACA
  ),
  region_code = c(
    rep("84",12), rep("27",8), rep("53",4), rep("24",6), rep("94",2),
    rep("44",10), rep("32",5), rep("11",8), rep("28",5), rep("75",12),
    rep("76",13), rep("52",5), rep("93",6)
  ),
  fr_region = c(
    rep("FRA.1_1",12), rep("FRA.2_1",8), rep("FRA.3_1",4), rep("FRA.4_1",6),
    rep("FRA.5_1",2), rep("FRA.6_1",10), rep("FRA.7_1",5), rep("FRA.8_1",8),
    rep("FRA.9_1",5), rep("FRA.10_1",12), rep("FRA.11_1",13), rep("FRA.12_1",5),
    rep("FRA.13_1",6)
  )
)

dvf_all <- list()
for (ff in dvf_files) {
  cat("  Reading:", basename(ff), "\n")
  tryCatch({
    dt <- fread(cmd = paste("gunzip -c", ff),
                select = c("date_mutation", "nature_mutation", "valeur_fonciere",
                           "code_departement", "type_local", "surface_reelle_bati"),
                fill = TRUE)

    # Keep sales of apartments and houses
    dt <- dt[nature_mutation == "Vente" & type_local %in% c("Appartement", "Maison")]

    # Parse date
    dt[, date_mutation := as.Date(date_mutation)]
    dt[, `:=`(year = year(date_mutation), quarter = quarter(date_mutation))]

    # Clean price
    dt[, valeur_fonciere := as.numeric(gsub(",", ".", as.character(valeur_fonciere)))]
    dt <- dt[!is.na(valeur_fonciere) & valeur_fonciere > 10000 & valeur_fonciere < 10000000]

    # Price per m2
    dt[, surface_reelle_bati := as.numeric(surface_reelle_bati)]
    dt <- dt[!is.na(surface_reelle_bati) & surface_reelle_bati > 5]
    dt[, price_m2 := valeur_fonciere / surface_reelle_bati]
    dt <- dt[price_m2 > 100 & price_m2 < 50000]

    # Map to region
    dt <- merge(dt, dept_to_region[, .(code_departement, fr_region)],
                by = "code_departement", all.x = TRUE)
    dt <- dt[!is.na(fr_region)]

    dvf_all[[basename(ff)]] <- dt
    cat("    Kept", nrow(dt), "transactions\n")
  }, error = function(e) {
    cat("    Error:", conditionMessage(e), "\n")
  })
}

if (length(dvf_all) > 0) {
  dvf <- rbindlist(dvf_all, fill = TRUE)
  cat("\nTotal DVF transactions:", nrow(dvf), "\n")

  # Aggregate to region × quarter
  dvf_region_qtr <- dvf[, .(
    median_price = median(valeur_fonciere, na.rm = TRUE),
    mean_price = mean(valeur_fonciere, na.rm = TRUE),
    median_price_m2 = median(price_m2, na.rm = TRUE),
    mean_price_m2 = mean(price_m2, na.rm = TRUE),
    n_transactions = .N,
    sd_price_m2 = sd(price_m2, na.rm = TRUE)
  ), by = .(fr_region, year, quarter)]

  dvf_region_qtr[, `:=`(
    yq = paste0(year, "Q", quarter),
    log_median_price = log(median_price),
    log_price_m2 = log(median_price_m2),
    log_transactions = log(n_transactions)
  )]

  cat("DVF panel:", nrow(dvf_region_qtr), "region-quarter obs\n")
  cat("Regions:", length(unique(dvf_region_qtr$fr_region)), "\n")
  cat("Year range:", range(dvf_region_qtr$year), "\n")

  saveRDS(dvf_region_qtr, file.path(data_dir, "dvf_region_quarter.rds"))
  rm(dvf, dvf_all); gc()
}

## ========================================================================
## 4. INSEE — UNEMPLOYMENT BY REGION (QUARTERLY)
## ========================================================================
cat("\n=== Fetching INSEE unemployment by region ===\n")

# Use the insee package to get localized unemployment rates
# We need to search for the right idbanks
tryCatch({
  unemp_search <- search_insee("taux de chômage")
  cat("  Found", nrow(unemp_search), "series\n")

  # Check column names
  cat("  Columns:", paste(names(unemp_search), collapse = ", "), "\n")

  # Filter for regional quarterly data
  # Look for series containing region codes
  region_pattern <- paste0("(", paste(c("Auvergne","Bourgogne","Bretagne","Centre",
                                        "Corse","Grand Est","Hauts-de-France",
                                        "Île-de-France","Normandie","Nouvelle-Aquitaine",
                                        "Occitanie","Pays de la Loire","Provence"), collapse = "|"), ")")

  # Try different column name patterns
  title_col <- intersect(names(unemp_search), c("TITLE_FR", "title_fr", "Title", "label"))
  if (length(title_col) > 0) {
    title_col <- title_col[1]
    unemp_reg <- unemp_search[grepl(region_pattern, unemp_search[[title_col]], ignore.case = TRUE), ]
    cat("  Regional series:", nrow(unemp_reg), "\n")

    if (nrow(unemp_reg) > 0) {
      unemp_ids <- unemp_reg$idbank[1:min(50, nrow(unemp_reg))]
      unemp_data <- get_insee_idbank(unemp_ids)
      cat("  Downloaded", nrow(unemp_data), "observations\n")
      saveRDS(unemp_data, file.path(data_dir, "insee_unemployment_region.rds"))
    }
  } else {
    cat("  Column names don't match expected pattern.\n")
    cat("  Available columns:", paste(names(unemp_search), collapse = ", "), "\n")
    # Try to get data with known idbanks for regional unemployment
    # These are standard INSEE BDM series IDs for regional unemployment
    cat("  Trying manual idbank approach...\n")
  }
}, error = function(e) {
  cat("  Error:", conditionMessage(e), "\n")
})

## ========================================================================
## 5. INSEE — FIRM CREATION BY REGION (QUARTERLY)
## ========================================================================
cat("\n=== Fetching INSEE firm creations by region ===\n")

tryCatch({
  firm_search <- search_insee("créations d'entreprises")
  cat("  Found", nrow(firm_search), "series\n")

  # Get column info
  title_col <- intersect(names(firm_search), c("TITLE_FR", "title_fr", "Title", "label"))
  if (length(title_col) > 0) {
    title_col <- title_col[1]
    firm_reg <- firm_search[grepl(region_pattern, firm_search[[title_col]], ignore.case = TRUE), ]
    cat("  Regional series:", nrow(firm_reg), "\n")

    if (nrow(firm_reg) > 0) {
      firm_ids <- firm_reg$idbank[1:min(50, nrow(firm_reg))]
      firm_data <- get_insee_idbank(firm_ids)
      cat("  Downloaded", nrow(firm_data), "observations\n")
      saveRDS(firm_data, file.path(data_dir, "insee_firms_region.rds"))
    }
  }
}, error = function(e) {
  cat("  Error:", conditionMessage(e), "\n")
})

## ========================================================================
## 6. BUILD ANALYSIS PANEL
## ========================================================================
cat("\n=== Building analysis panel ===\n")

# Panel backbone: 13 regions × quarters from 2014Q1 to 2023Q4
fr_regions <- unique(dept_exposure$fr_region)

time_grid <- expand.grid(
  year = 2014:2023,
  quarter = 1:4,
  stringsAsFactors = FALSE
) %>%
  mutate(
    yq = paste0(year, "Q", quarter),
    t = (year - 2014) * 4 + quarter,
    post_referendum = as.integer(year > 2016 | (year == 2016 & quarter >= 3)),
    post_transition = as.integer(year >= 2021)
  ) %>%
  arrange(year, quarter) %>%
  as.data.table()

panel <- CJ(fr_region = fr_regions, t = time_grid$t)
panel <- merge(panel, time_grid, by = "t")
panel <- merge(panel, dept_exposure, by = "fr_region", all.x = TRUE)

# Treatment interactions
panel[, `:=`(
  treat_uk_post = log_sci_uk * post_referendum,
  treat_uk_transition = log_sci_uk * post_transition,
  placebo_de_post = log_sci_de * post_referendum
)]

# Standardized exposure
panel[, `:=`(
  sci_uk_z = (sci_total_uk - mean(sci_total_uk, na.rm = TRUE)) /
    sd(sci_total_uk, na.rm = TRUE),
  sci_de_z = (sci_total_de - mean(sci_total_de, na.rm = TRUE)) /
    sd(sci_total_de, na.rm = TRUE)
)]

cat("Panel:", nrow(panel), "obs (",
    length(unique(panel$fr_region)), "regions ×",
    length(unique(panel$t)), "quarters)\n")

# Merge DVF outcomes
if (file.exists(file.path(data_dir, "dvf_region_quarter.rds"))) {
  dvf_rq <- readRDS(file.path(data_dir, "dvf_region_quarter.rds"))
  panel <- merge(panel, dvf_rq[, .(fr_region, year, quarter,
                                    log_price_m2, log_median_price,
                                    log_transactions, n_transactions,
                                    median_price_m2)],
                 by = c("fr_region", "year", "quarter"), all.x = TRUE)
  cat("DVF merged. Non-missing price obs:", sum(!is.na(panel$log_price_m2)), "\n")
}

saveRDS(panel, file.path(data_dir, "analysis_panel.rds"))

cat("\n=== Data cleaning complete ===\n")
