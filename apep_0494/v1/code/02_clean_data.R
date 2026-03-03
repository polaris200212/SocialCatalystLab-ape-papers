## ===========================================================================
## 02_clean_data.R — Variable Construction and Panel Assembly
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. Load DVF
# ============================================================================

cat("=== Loading DVF residential transactions ===\n")
dvf <- fread(file.path(DAT, "dvf_residential.csv"))
cat(sprintf("  Loaded: %d transactions\n", nrow(dvf)))

# ============================================================================
# 2. Load and Process Tax Rate Data (REI)
# ============================================================================

cat("\n=== Processing tax rate data ===\n")

# Load parsed REI files (produced by 01b_parse_rei.R)
rei_files <- list.files(DAT, pattern = "rei_\\d{4}_parsed\\.csv$", full.names = TRUE)

if (length(rei_files) == 0) {
  stop("No parsed REI files found. Run 01b_parse_rei.R first.")
}

cat(sprintf("  Found %d parsed REI files: %s\n", length(rei_files),
            paste(basename(rei_files), collapse = ", ")))

rei_list <- lapply(rei_files, fread)
rei <- rbindlist(rei_list, fill = TRUE)

# Standardize year column
if ("annee" %in% names(rei) && !"year" %in% names(rei)) {
  setnames(rei, "annee", "year")
}

# Ensure numeric types
rei[, taux_th := as.numeric(taux_th)]
rei[, taux_tfb := as.numeric(taux_tfb)]
rei[, year := as.integer(year)]

# Clean commune codes: ensure 5-character format
rei[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]

# Exclude Alsace-Moselle
rei <- rei[!substr(code_commune, 1, 2) %in% c("67", "68", "57")]

cat(sprintf("\nREI panel: %d commune-years, %d unique communes, years %s\n",
            nrow(rei), uniqueN(rei$code_commune),
            paste(sort(unique(rei$year)), collapse = ", ")))


# ============================================================================
# 3. Construct Treatment Variables
# ============================================================================

cat("\n=== Constructing treatment variables ===\n")

# Pre-reform TH rate (2017 — last year before first relief)
th_2017 <- rei[year == 2017, .(code_commune, th_rate_2017 = taux_th)]

if (nrow(th_2017) == 0) {
  # Try 2016 if 2017 not available
  th_2017 <- rei[year == max(year[year <= 2017]),
                 .(code_commune, th_rate_2017 = taux_th)]
  cat(sprintf("  Using %d as baseline year (2017 not available)\n",
              max(rei$year[rei$year <= 2017])))
}

cat(sprintf("  Communes with baseline TH rate: %d\n", nrow(th_2017)))
cat(sprintf("  Mean TH rate (2017): %.2f%%\n", mean(th_2017$th_rate_2017, na.rm = TRUE)))
cat(sprintf("  SD TH rate: %.2f%%\n", sd(th_2017$th_rate_2017, na.rm = TRUE)))
cat(sprintf("  Range: %.2f%% to %.2f%%\n",
            min(th_2017$th_rate_2017, na.rm = TRUE),
            max(th_2017$th_rate_2017, na.rm = TRUE)))

# TH rate quartiles for binned analysis
th_2017[, th_quartile := cut(th_rate_2017,
                             breaks = quantile(th_rate_2017, probs = 0:4/4, na.rm = TRUE),
                             labels = paste0("Q", 1:4),
                             include.lowest = TRUE)]

# Pre-reform TFB rate (for fiscal substitution baseline)
tfb_2017 <- rei[year == 2017, .(code_commune, tfb_rate_2017 = taux_tfb)]

if (nrow(tfb_2017) == 0) {
  tfb_2017 <- rei[year == max(year[year <= 2017]),
                  .(code_commune, tfb_rate_2017 = taux_tfb)]
}

# Compute TF rate changes (fiscal substitution measure)
tfb_change <- rei[, .(taux_tfb = mean(taux_tfb, na.rm = TRUE)), by = .(code_commune, year)]
tfb_change <- dcast(tfb_change, code_commune ~ year, value.var = "taux_tfb")

# Calculate TFB change from 2017 to latest available year
latest_yr <- max(rei$year, na.rm = TRUE)
if (as.character(latest_yr) %in% names(tfb_change) & "2017" %in% names(tfb_change)) {
  tfb_change[, tfb_change_pct := get(as.character(latest_yr)) - `2017`]
  tfb_change[, tfb_change_rel := tfb_change_pct / `2017` * 100]
  cat(sprintf("\n  TFB rate change 2017-%d:\n", latest_yr))
  cat(sprintf("    Mean: +%.2f pp (%.1f%%)\n",
              mean(tfb_change$tfb_change_pct, na.rm = TRUE),
              mean(tfb_change$tfb_change_rel, na.rm = TRUE)))
}


# ============================================================================
# 4. Merge DVF with Treatment Variables
# ============================================================================

cat("\n=== Merging DVF with tax treatment ===\n")

# Ensure consistent commune code format in DVF
dvf[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]

# Merge baseline TH rate
dvf <- merge(dvf, th_2017, by = "code_commune", all.x = TRUE)
dvf <- merge(dvf, tfb_2017, by = "code_commune", all.x = TRUE)

# Drop transactions in communes without tax data
n_before <- nrow(dvf)
dvf <- dvf[!is.na(th_rate_2017)]
cat(sprintf("  Matched to tax data: %d of %d (%.1f%%)\n",
            nrow(dvf), n_before, 100 * nrow(dvf) / n_before))

# --- Treatment indicators ---
# DVF data covers 2020-2024. The TH reform phased in as:
#   2018: 30% relief (80% of households — income-eligible)
#   2019: 65% relief
#   2020: 80% relief (80% of households fully exempt)
#   2021: 100% for 80% + partial for remaining 20%
#   2022-2023: gradual extension to all households
#   2023: 100% abolition for all primary residences
#
# All DVF years are post-reform-start, but treatment intensifies over time.
# We use reform_share to capture the fraction of total relief implemented.
dvf[, reform_share := fcase(
  year == 2020, 0.80,  # 80% of households fully exempt
  year == 2021, 0.90,  # ~90% relief (80% full + 20% partial)
  year == 2022, 0.95,  # near-complete
  year == 2023, 1.00,  # full abolition
  year == 2024, 1.00,  # full abolition
  default = 0.80
)]

dvf[, post := as.integer(year >= 2020)]  # All years are post
dvf[, treatment_intensity := th_rate_2017]
dvf[, treatment := th_rate_2017 * reform_share]

# For cross-sectional design: high-TH vs low-TH communes over time
# The key variation is th_rate_2017 (cross-sectional) × year (time)

# Département code for clustering
dvf[, dept := substr(code_commune, 1, 2)]
# Handle Corsica (2A, 2B) and DOM
dvf[dept == "97", dept := substr(code_commune, 1, 3)]

# Log price
dvf[, log_price_m2 := log(price_m2)]

# Property type indicators
dvf[, is_apartment := as.integer(type_local == "Appartement")]
dvf[, is_house := as.integer(type_local == "Maison")]


# ============================================================================
# 5. Merge Year-Varying Tax Rates (for mechanism analysis)
# ============================================================================

cat("\n=== Adding year-varying tax rates ===\n")

# REI has years 2017, 2020, 2022, 2024
# For DVF years: map each DVF year to nearest REI year for TFB rates
# 2020 → REI 2020, 2021 → REI 2020, 2022 → REI 2022, 2023 → REI 2022, 2024 → REI 2024
rei_annual <- rei[, .(taux_th = mean(taux_th, na.rm = TRUE),
                      taux_tfb = mean(taux_tfb, na.rm = TRUE)),
                  by = .(code_commune, year)]

# Create mapping for each DVF year to nearest REI year
dvf[, rei_year := fcase(
  year == 2020, 2020L,
  year == 2021, 2020L,
  year == 2022, 2022L,
  year == 2023, 2022L,
  year == 2024, 2024L,
  default = 2020L
)]

dvf <- merge(dvf, rei_annual,
             by.x = c("code_commune", "rei_year"),
             by.y = c("code_commune", "year"),
             all.x = TRUE)

cat(sprintf("  Matched year-varying tax rates: %d of %d\n",
            sum(!is.na(dvf$taux_tfb)), nrow(dvf)))


# ============================================================================
# 6. Commune-Level Panel (Aggregated)
# ============================================================================

cat("\n=== Building commune-year panel ===\n")

panel <- dvf[, .(
  n_transactions = .N,
  mean_price_m2 = mean(price_m2),
  median_price_m2 = median(price_m2),
  log_mean_price = log(mean(price_m2)),
  mean_log_price = mean(log_price_m2),
  sd_price_m2 = sd(price_m2),
  pct_apartment = mean(is_apartment),
  mean_surface = mean(surface_reelle_bati)
), by = .(code_commune, year, dept, th_rate_2017, tfb_rate_2017,
          th_quartile)]

# Add year-varying tax rates to panel
panel <- merge(panel, rei_annual,
               by = c("code_commune", "year"),
               all.x = TRUE)

# Treatment variables
panel[, post := as.integer(year >= 2018)]
panel[, treatment := th_rate_2017 * post]

cat(sprintf("  Commune-year panel: %d rows\n", nrow(panel)))
cat(sprintf("  Communes: %d, Years: %d\n",
            uniqueN(panel$code_commune), uniqueN(panel$year)))


# ============================================================================
# 7. Save Analysis Datasets
# ============================================================================

cat("\n=== Saving analysis datasets ===\n")

fwrite(dvf, file.path(DAT, "dvf_analysis.csv"))
fwrite(panel, file.path(DAT, "panel_commune_year.csv"))
fwrite(th_2017, file.path(DAT, "th_baseline_2017.csv"))
fwrite(rei, file.path(DAT, "rei_clean.csv"))

cat(sprintf("  dvf_analysis.csv: %.1f MB (%d rows)\n",
            file.size(file.path(DAT, "dvf_analysis.csv")) / 1e6, nrow(dvf)))
cat(sprintf("  panel_commune_year.csv: %.1f MB (%d rows)\n",
            file.size(file.path(DAT, "panel_commune_year.csv")) / 1e6, nrow(panel)))

cat("\n=== Data cleaning complete ===\n")
