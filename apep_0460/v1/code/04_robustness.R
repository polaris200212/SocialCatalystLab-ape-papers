## ============================================================================
## 04_robustness.R — Robustness Checks
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

cat("=== Loading data and main results ===\n")

panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
results <- readRDS(file.path(data_dir, "main_results.rds"))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))
sci_fr_uk <- readRDS(file.path(data_dir, "sci_france_uk.rds"))

# Analysis dataset
ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk)]
cat("Analysis sample:", nrow(ad), "observations\n")
cat("Units:", length(unique(ad$fr_region)), "\n")

# Determine event reference period (matching 03_main_analysis.R)
min_year <- min(ad$year)
if (min_year <= 2016) {
  ref_quarter <- ad[year == 2016 & quarter == 2, unique(t)]
  if (length(ref_quarter) == 0) ref_quarter <- min(ad$t) + 8
} else {
  ref_quarter <- ad[year == 2020 & quarter == 4, unique(t)]
  if (length(ref_quarter) == 0) ref_quarter <- min(ad[year == 2020]$t) + 3
}
ad[, ref_period := t - ref_quarter]

robust_results <- list()

## ========================================================================
## 1. PERMUTATION INFERENCE
## ========================================================================
cat("\n=== Permutation inference (2000 draws) ===\n")

actual_coef <- coef(results$m1)[1]
cat("Actual coefficient:", actual_coef, "\n")

set.seed(42)
n_perms <- 2000
perm_coefs <- numeric(n_perms)

# Get unique units and their exposure
unit_exposure <- unique(ad[, .(fr_region, log_sci_uk)])
n_units <- nrow(unit_exposure)
cat("Number of units to permute:", n_units, "\n")

for (i in 1:n_perms) {
  if (i %% 500 == 0) cat("  Permutation", i, "/", n_perms, "\n")

  # Shuffle exposure across units
  ad_perm <- copy(ad)
  shuffle_idx <- sample(n_units)
  exposure_map <- data.table(
    fr_region = unit_exposure$fr_region,
    log_sci_uk_perm = unit_exposure$log_sci_uk[shuffle_idx]
  )
  ad_perm <- merge(ad_perm, exposure_map, by = "fr_region")

  tryCatch({
    m_perm <- feols(log_price_m2 ~ log_sci_uk_perm:post_referendum |
                      fr_region + yq,
                    data = ad_perm, cluster = ~fr_region)
    perm_coefs[i] <- coef(m_perm)[1]
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
perm_pvalue <- mean(abs(perm_coefs) >= abs(actual_coef))
cat("Permutation p-value:", perm_pvalue,
    "(", sum(abs(perm_coefs) >= abs(actual_coef)), "/", length(perm_coefs), ")\n")

robust_results$permutation <- list(
  actual = actual_coef,
  perm_coefs = perm_coefs,
  p_value = perm_pvalue
)

## ========================================================================
## 2. LEAVE-ONE-UK-COUNTRY-OUT
## ========================================================================
cat("\n=== Leave-one-UK-country-out ===\n")

# GADM2 UK codes: GBR.{country}.{subregion}_1
# Extract the country code (GBR.1 = England, GBR.2 = NI, GBR.3 = Scotland, GBR.4 = Wales)
sci_fr_uk[, uk_country_code := sub("^(GBR\\.[0-9]+)\\..*$", "\\1", uk_gadm2)]

# Map fr_gadm2 → code_departement for merging with panel
dept_map <- readRDS(file.path(data_dir, "dept_exposure.rds"))
dept_map_slim <- dept_map[, .(fr_gadm2, code_departement)]
sci_fr_uk_mapped <- merge(sci_fr_uk, dept_map_slim, by = "fr_gadm2")

uk_countries <- sort(unique(sci_fr_uk$uk_country_code))
cat("UK countries:", paste(uk_countries, collapse = ", "), "\n")

uk_country_labels <- c(
  "GBR.1" = "England",
  "GBR.2" = "Northern Ireland",
  "GBR.3" = "Scotland",
  "GBR.4" = "Wales"
)

looro_results <- data.frame(
  uk_country = character(),
  uk_label = character(),
  coefficient = numeric(),
  se = numeric(),
  n_gadm2_dropped = integer(),
  stringsAsFactors = FALSE
)

for (uk_c in uk_countries) {
  dropped_n <- length(unique(sci_fr_uk[uk_country_code == uk_c]$uk_gadm2))
  cat("  Dropping:", uk_country_labels[uk_c], "(", uk_c, ",",
      dropped_n, "GADM2 regions)\n")

  # Recompute exposure dropping this UK country
  sci_minus_c <- sci_fr_uk_mapped[uk_country_code != uk_c]
  exposure_c <- sci_minus_c[, .(
    log_sci_uk_j = log(sum(scaled_sci) + 1)
  ), by = .(fr_region = code_departement)]

  ad_c <- merge(ad[, -"log_sci_uk_j", with = FALSE][, .SD, .SDcols = !grepl("^log_sci_uk_j$", names(ad))],
                exposure_c, by = "fr_region", all.x = TRUE)

  tryCatch({
    m_c <- feols(log_price_m2 ~ log_sci_uk_j:post_referendum |
                   fr_region + yq,
                 data = ad_c[!is.na(log_sci_uk_j)], cluster = ~fr_region)

    looro_results <- rbind(looro_results, data.frame(
      uk_country = uk_c,
      uk_label = uk_country_labels[uk_c],
      coefficient = coef(m_c)[1],
      se = se(m_c)[1],
      n_gadm2_dropped = dropped_n,
      stringsAsFactors = FALSE
    ))
    cat("    beta =", round(coef(m_c)[1], 4), "(SE =", round(se(m_c)[1], 4), ")\n")
  }, error = function(e) {
    cat("    Estimation failed:", conditionMessage(e), "\n")
  })
}

cat("\nLeave-one-country-out summary:\n")
print(looro_results)
cat("Baseline:", actual_coef, "\n")

robust_results$looro <- looro_results

## ========================================================================
## 3. UK COUNTRY DECOMPOSITION
## ========================================================================
cat("\n=== UK country decomposition ===\n")

# Test effect using SCI to each UK country separately
uk_country_results <- data.frame(
  uk_country = character(),
  coefficient = numeric(),
  se = numeric(),
  n_gadm2 = integer(),
  stringsAsFactors = FALSE
)

for (uk_c in uk_countries) {
  sci_single <- sci_fr_uk_mapped[uk_country_code == uk_c]
  n_g2 <- length(unique(sci_single$uk_gadm2))
  exposure_single <- sci_single[, .(
    log_sci_uk_single = log(sum(scaled_sci) + 1)
  ), by = .(fr_region = code_departement)]

  ad_single <- merge(ad, exposure_single, by = "fr_region", all.x = TRUE)

  tryCatch({
    m_single <- feols(log_price_m2 ~ log_sci_uk_single:post_referendum |
                        fr_region + yq,
                      data = ad_single[!is.na(log_sci_uk_single)],
                      cluster = ~fr_region)

    uk_country_results <- rbind(uk_country_results, data.frame(
      uk_country = uk_country_labels[uk_c],
      coefficient = coef(m_single)[1],
      se = se(m_single)[1],
      n_gadm2 = n_g2,
      stringsAsFactors = FALSE
    ))
    cat("  ", uk_country_labels[uk_c], "(", n_g2, "regions): beta =",
        round(coef(m_single)[1], 4), "(SE =", round(se(m_single)[1], 4), ")\n")
  }, error = function(e) {
    cat("  ", uk_country_labels[uk_c], ": estimation failed\n")
  })
}

# Progressively restrictive UK sets
distance_bands <- list(
  "All UK" = uk_countries,
  "Exclude NI" = uk_countries[uk_countries != "GBR.2"],
  "England only" = "GBR.1",
  "Non-England UK" = uk_countries[uk_countries != "GBR.1"]
)

dist_coefs <- data.frame(band = character(), coef = numeric(),
                         se = numeric(), n_uk_regions = integer(),
                         stringsAsFactors = FALSE)

for (band_name in names(distance_bands)) {
  band_countries <- distance_bands[[band_name]]
  sci_band <- sci_fr_uk_mapped[uk_country_code %in% band_countries]
  n_reg <- length(unique(sci_band$uk_gadm2))

  exposure_band <- sci_band[, .(
    log_sci_uk_band = log(sum(scaled_sci) + 1)
  ), by = .(fr_region = code_departement)]

  ad_band <- merge(ad, exposure_band, by = "fr_region", all.x = TRUE)

  tryCatch({
    m_band <- feols(log_price_m2 ~ log_sci_uk_band:post_referendum |
                      fr_region + yq,
                    data = ad_band[!is.na(log_sci_uk_band)], cluster = ~fr_region)
    dist_coefs <- rbind(dist_coefs, data.frame(
      band = band_name,
      coef = coef(m_band)[1],
      se = se(m_band)[1],
      n_uk_regions = n_reg
    ))
    cat("  ", band_name, "(", n_reg, "GADM2 regions): beta =",
        round(coef(m_band)[1], 4), "(SE =", round(se(m_band)[1], 4), ")\n")
  }, error = function(e) {
    cat("  ", band_name, ": estimation failed\n")
  })
}

robust_results$distance <- dist_coefs
robust_results$uk_country <- uk_country_results

## ========================================================================
## 4. POPULATION-WEIGHTED VS PROBABILITY-WEIGHTED SCI
## ========================================================================
cat("\n=== Population vs probability weighting ===\n")

# Population-weighted: total SCI (already main measure)
# Probability-weighted: mean SCI = total / n_connections
ad[, prob_weighted_uk := sci_total_uk / n_uk_connections]
ad[, log_prob_uk := log(prob_weighted_uk + 1)]

m_pop <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                 fr_region + yq,
               data = ad, cluster = ~fr_region)

m_prob <- feols(log_price_m2 ~ log_prob_uk:post_referendum |
                  fr_region + yq,
                data = ad, cluster = ~fr_region)

cat("Population-weighted: β =", round(coef(m_pop)[1], 4),
    "(SE =", round(se(m_pop)[1], 4), ")\n")
cat("Probability-weighted: β =", round(coef(m_prob)[1], 4),
    "(SE =", round(se(m_prob)[1], 4), ")\n")

robust_results$weighting <- list(
  pop_weighted = m_pop,
  prob_weighted = m_prob
)

## ========================================================================
## 5. SWISS FRANC POSITIVE PLACEBO (JAN 2015)
## ========================================================================
cat("\n=== Swiss franc positive placebo ===\n")

if ("log_sci_ch" %in% names(ad) && any(!is.na(ad$log_sci_ch))) {
  ad[, post_chf := as.integer(year > 2015 | (year == 2015 & quarter >= 1))]

  m_swiss <- tryCatch({
    feols(log_price_m2 ~ log_sci_ch:post_chf |
            fr_region + yq,
          data = ad[!is.na(log_sci_ch)], cluster = ~fr_region)
  }, error = function(e) {
    cat("  Swiss placebo failed:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(m_swiss)) {
    cat("Swiss franc placebo: β =", round(coef(m_swiss)[1], 4),
        "(SE =", round(se(m_swiss)[1], 4), ")\n")
    robust_results$swiss_placebo <- m_swiss
  }
} else {
  cat("  No Swiss SCI data available.\n")
}

## ========================================================================
## 6. COVID CONTROL
## ========================================================================
cat("\n=== COVID period control ===\n")

ad[, covid_period := as.integer(year == 2020 | year == 2021)]

m_covid <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                   log_sci_uk:covid_period |
                   fr_region + yq,
                 data = ad, cluster = ~fr_region)
cat("With COVID control:\n")
summary(m_covid)

robust_results$covid <- m_covid

## ========================================================================
## 7. ALTERNATIVE CLUSTERING
## ========================================================================
cat("\n=== Alternative clustering ===\n")

# With 13 regions, clustering is already at the region level
# Try: region-clustered (baseline), two-way (region + quarter), HC robust

m_region_cluster <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                            fr_region + yq,
                          data = ad, cluster = ~fr_region)
cat("Region-clustered SE:", se(m_region_cluster)[1], "\n")

m_twoway <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                    fr_region + yq,
                  data = ad, cluster = ~fr_region + yq)
cat("Two-way clustered SE:", se(m_twoway)[1], "\n")

m_hetero <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                    fr_region + yq,
                  data = ad, vcov = "hetero")
cat("Heteroskedasticity-robust SE:", se(m_hetero)[1], "\n")

robust_results$clustering <- list(
  region = m_region_cluster,
  twoway = m_twoway,
  hetero = m_hetero
)

## ========================================================================
## 8. PRE-TREATMENT TRENDS TEST
## ========================================================================
cat("\n=== Pre-treatment trends test ===\n")

if (min_year <= 2016) {
  ad_pre <- ad[year < 2016 | (year == 2016 & quarter <= 2)]
} else {
  ad_pre <- ad[year == 2020]
}

if (nrow(ad_pre) > 10) {
  ad_pre[, time_trend := year + (quarter - 1) / 4]

  m_pretrend <- feols(log_price_m2 ~ log_sci_uk:time_trend |
                        fr_region + yq,
                      data = ad_pre, cluster = ~fr_region)
  cat("Pre-trend interaction: β =", round(coef(m_pretrend)[1], 6),
      "(SE =", round(se(m_pretrend)[1], 6), ")\n")

  robust_results$pretrend <- m_pretrend
} else {
  cat("  Insufficient pre-treatment data for trends test.\n")
}

## ========================================================================
## 9. STANDARDIZED (Z-SCORED) EXPOSURE
## ========================================================================
cat("\n=== Standardized exposure measure ===\n")

ad[, sci_uk_z := (sci_total_uk - mean(sci_total_uk)) / sd(sci_total_uk)]

m_std <- feols(log_price_m2 ~ sci_uk_z:post_referendum |
                 fr_region + yq,
               data = ad, cluster = ~fr_region)
cat("Standardized: 1 SD SCI → β =", round(coef(m_std)[1], 4),
    "(SE =", round(se(m_std)[1], 4), ")\n")

robust_results$standardized <- m_std

## ========================================================================
## SAVE ALL ROBUSTNESS RESULTS
## ========================================================================
saveRDS(robust_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
cat("Results saved to:", file.path(data_dir, "robustness_results.rds"), "\n")
