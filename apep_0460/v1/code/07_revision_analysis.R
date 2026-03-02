## ============================================================================
## 07_revision_analysis.R — Stage C Revision: Identification & Mechanism Tests
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

cat("=== Loading data for revision analysis ===\n")

panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk)]
cat("Analysis sample:", nrow(ad), "observations\n")
cat("Units:", length(unique(ad$fr_region)), "\n")

## ========================================================================
## WORKSTREAM 1: IDENTIFICATION STRENGTHENING
## ========================================================================

## ---- 1a. General International Openness Control ----
cat("\n=== 1a. General international openness control ===\n")

# Construct total non-UK foreign SCI (DE + CH) as "general openness" measure
ad[, total_foreign_nonuk := sci_total_de + sci_total_ch]
ad[, log_total_foreign_nonuk := log(total_foreign_nonuk + 1)]

# Also construct total foreign SCI (UK + DE + CH)
ad[, total_foreign_all := sci_total_uk + sci_total_de + sci_total_ch]
ad[, log_total_foreign_all := log(total_foreign_all + 1)]

# Model 1a: UK effect controlling for general openness (non-UK foreign × Post)
m1a <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
               log_total_foreign_nonuk:post_referendum |
               fr_region + yq,
             data = ad, cluster = ~fr_region)
cat("\nModel 1a — UK + general openness control:\n")
summary(m1a)

## ---- 1b. Residualized UK Exposure ----
cat("\n=== 1b. Residualized UK exposure ===\n")

# Regress log_sci_uk on log_sci_de (cross-section, one obs per dept)
dept_data <- unique(ad[, .(fr_region, log_sci_uk, log_sci_de, log_sci_ch)])

# First stage: UK SCI = f(German SCI)
resid_reg <- lm(log_sci_uk ~ log_sci_de, data = dept_data)
cat("First stage R²:", summary(resid_reg)$r.squared, "\n")
cat("Correlation UK-DE:", cor(dept_data$log_sci_uk, dept_data$log_sci_de), "\n")
dept_data[, log_sci_uk_resid := resid(resid_reg)]

# Merge residualized exposure back to panel
ad <- merge(ad, dept_data[, .(fr_region, log_sci_uk_resid)],
            by = "fr_region", all.x = TRUE)

# Model 1b: Residualized UK exposure
m1b <- feols(log_price_m2 ~ log_sci_uk_resid:post_referendum |
               fr_region + yq,
             data = ad, cluster = ~fr_region)
cat("\nModel 1b — Residualized UK exposure (orthogonal to DE):\n")
summary(m1b)

# Also: residualize on BOTH DE and CH
resid_reg2 <- lm(log_sci_uk ~ log_sci_de + log_sci_ch, data = dept_data)
cat("First stage R² (DE + CH):", summary(resid_reg2)$r.squared, "\n")
dept_data[, log_sci_uk_resid2 := resid(resid_reg2)]

ad <- merge(ad[, -"log_sci_uk_resid2", with = FALSE],
            dept_data[, .(fr_region, log_sci_uk_resid2)],
            by = "fr_region", all.x = TRUE)

m1b2 <- feols(log_price_m2 ~ log_sci_uk_resid2:post_referendum |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
cat("\nModel 1b2 — Residualized UK exposure (orthogonal to DE + CH):\n")
summary(m1b2)

## ---- 1c. Additional Country Placebos ----
cat("\n=== 1c. Triple horse race (UK + DE + CH) ===\n")

# Triple horse race: all three countries simultaneously
m1c <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
               log_sci_de:post_referendum +
               log_sci_ch:post_referendum |
               fr_region + yq,
             data = ad[!is.na(log_sci_ch)], cluster = ~fr_region)
cat("\nModel 1c — Triple horse race (UK + DE + CH):\n")
summary(m1c)

# German placebo alone (already have) but rerun for completeness
m_de_alone <- feols(log_price_m2 ~ log_sci_de:post_referendum |
                      fr_region + yq,
                    data = ad, cluster = ~fr_region)

# Swiss placebo alone
m_ch_alone <- feols(log_price_m2 ~ log_sci_ch:post_referendum |
                      fr_region + yq,
                    data = ad[!is.na(log_sci_ch)], cluster = ~fr_region)

cat("DE alone:", round(coef(m_de_alone)[1], 4), "(p =", round(pvalue(m_de_alone)[1], 4), ")\n")
cat("CH alone:", round(coef(m_ch_alone)[1], 4), "(p =", round(pvalue(m_ch_alone)[1], 4), ")\n")

## ---- 1d. Joint Pre-Trend F-Test ----
cat("\n=== 1d. Joint pre-trend F-test ===\n")

# Set up event study reference period
min_year <- min(ad$year)
if (min_year <= 2016) {
  ref_quarter <- ad[year == 2016 & quarter == 2, unique(t)]
  if (length(ref_quarter) == 0) ref_quarter <- min(ad$t) + 8
} else {
  ref_quarter <- ad[year == 2020 & quarter == 4, unique(t)]
}
ad[, ref_period := t - ref_quarter]

# Run event study
es_model <- feols(log_price_m2 ~ i(ref_period, log_sci_uk, ref = 0) |
                    fr_region + yq,
                  data = ad, cluster = ~fr_region)

# Extract pre-treatment coefficients
es_coefs <- coeftable(es_model)
pre_coefs <- es_coefs[grepl("ref_period.*:log_sci_uk", rownames(es_coefs)), ]
# Get the period numbers
pre_periods <- as.numeric(gsub("ref_period::(-?[0-9]+):log_sci_uk", "\\1",
                               rownames(pre_coefs)))
pre_mask <- pre_periods < 0
n_pre <- sum(pre_mask)

cat("Pre-treatment coefficients:", n_pre, "\n")
cat("Pre-treatment periods:", sort(pre_periods[pre_mask]), "\n")

# Wald test for joint significance of all pre-treatment coefficients
if (n_pre > 0) {
  pre_names <- rownames(pre_coefs)[pre_mask]
  cat("Testing joint significance of:", paste(pre_names, collapse = ", "), "\n")

  # Use wald() from fixest
  wald_test <- wald(es_model, pre_names)
  cat("\nWald test for joint significance of pre-treatment coefficients:\n")
  cat("  F-statistic:", wald_test$stat, "\n")
  cat("  p-value:", wald_test$p, "\n")
  cat("  df1:", wald_test$df1, "\n")
  cat("  df2:", wald_test$df2, "\n")

  # Also test excluding the τ=-4 outlier
  pre_names_no_outlier <- pre_names[pre_periods[pre_mask] != -4]
  if (length(pre_names_no_outlier) > 0 & length(pre_names_no_outlier) < length(pre_names)) {
    wald_test_no_outlier <- wald(es_model, pre_names_no_outlier)
    cat("\nWald test EXCLUDING τ=-4 outlier:\n")
    cat("  F-statistic:", wald_test_no_outlier$stat, "\n")
    cat("  p-value:", wald_test_no_outlier$p, "\n")
  }
}

## ========================================================================
## WORKSTREAM 2: MECHANISM EVIDENCE
## ========================================================================

## ---- 2a. Property Type Heterogeneity ----
cat("\n=== 2a. Property type heterogeneity ===\n")

# Re-read DVF with property type distinction
dvf_dir <- file.path(data_dir, "dvf")
dvf_files <- list.files(dvf_dir, pattern = "\\.csv\\.gz$", full.names = TRUE)

dvf_by_type <- list()
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

    dvf_by_type[[basename(ff)]] <- dt
  }, error = function(e) {
    cat("    Error:", conditionMessage(e), "\n")
  })
}

dvf <- rbindlist(dvf_by_type, fill = TRUE)
cat("Total DVF transactions:", nrow(dvf), "\n")
cat("Houses:", sum(dvf$type_local == "Maison"), "\n")
cat("Apartments:", sum(dvf$type_local == "Appartement"), "\n")

# Aggregate separately by property type
for (ptype in c("Maison", "Appartement")) {
  dvf_type <- dvf[type_local == ptype, .(
    median_price_m2 = median(price_m2, na.rm = TRUE),
    n_transactions = .N
  ), by = .(code_departement, year, quarter)]

  dvf_type[, `:=`(
    yq = paste0(year, "Q", quarter),
    log_price_m2 = log(median_price_m2),
    log_transactions = log(n_transactions)
  )]

  # Merge with exposure data
  panel_type <- merge(
    dvf_type,
    dept_exposure[!is.na(code_departement),
                  .(code_departement, log_sci_uk, log_sci_de, log_sci_ch,
                    sci_total_uk, sci_total_de, sci_total_ch)],
    by = "code_departement", all.x = TRUE
  )
  panel_type[, `:=`(
    fr_region = code_departement,
    post_referendum = as.integer(year > 2016 | (year == 2016 & quarter >= 3))
  )]

  ad_type <- panel_type[!is.na(log_price_m2) & !is.na(log_sci_uk)]
  cat("\n", ptype, "sample:", nrow(ad_type), "obs,",
      length(unique(ad_type$fr_region)), "depts\n")

  m_type <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                    fr_region + yq,
                  data = ad_type, cluster = ~fr_region)

  cat("  β =", round(coef(m_type)[1], 4),
      "(SE =", round(se(m_type)[1], 4),
      ", p =", round(pvalue(m_type)[1], 4), ")\n")

  if (ptype == "Maison") {
    m_houses <- m_type
    ad_houses <- ad_type
  } else {
    m_apartments <- m_type
    ad_apartments <- ad_type
  }
}

## ---- 2b. Geographic Heterogeneity ----
cat("\n=== 2b. Geographic heterogeneity ===\n")

# Define Channel-facing / coastal départements
# These are départements with direct English Channel or Atlantic coast access
# that would be natural destinations for UK buyers
channel_coastal <- c(
  "62",  # Pas-de-Calais (Channel)
  "80",  # Somme (Channel)
  "76",  # Seine-Maritime (Channel)
  "14",  # Calvados (Channel)
  "50",  # Manche (Channel)
  "22",  # Côtes-d'Armor (Brittany/Atlantic)
  "29",  # Finistère (Brittany/Atlantic)
  "56",  # Morbihan (Brittany/Atlantic)
  "35",  # Ille-et-Vilaine (Brittany)
  "44",  # Loire-Atlantique (Atlantic)
  "85",  # Vendée (Atlantic)
  "17",  # Charente-Maritime (Atlantic)
  "33",  # Gironde (Atlantic)
  "40",  # Landes (Atlantic)
  "64",  # Pyrénées-Atlantiques (Atlantic)
  "66",  # Pyrénées-Orientales (Mediterranean)
  "11",  # Aude (Mediterranean)
  "34",  # Hérault (Mediterranean)
  "30",  # Gard (Mediterranean)
  "13",  # Bouches-du-Rhône (Mediterranean)
  "83",  # Var (Mediterranean/Côte d'Azur)
  "06",  # Alpes-Maritimes (Côte d'Azur)
  "2A",  # Corse-du-Sud
  "2B"   # Haute-Corse
)

# Specifically Channel-facing (northern coast)
channel_facing <- c("62", "80", "76", "14", "50", "22", "29", "56", "35")

# UK buyer "hotspot" départements (Brittany, Dordogne, Charente, Lot)
uk_expat_hotspots <- c(
  "22",  # Côtes-d'Armor
  "29",  # Finistère
  "56",  # Morbihan
  "35",  # Ille-et-Vilaine
  "24",  # Dordogne
  "16",  # Charente
  "23",  # Creuse
  "46",  # Lot
  "87",  # Haute-Vienne
  "79",  # Deux-Sèvres
  "86",  # Vienne
  "17",  # Charente-Maritime
  "47"   # Lot-et-Garonne
)

ad[, coastal := as.integer(fr_region %in% channel_coastal)]
ad[, channel_facing := as.integer(fr_region %in% channel_facing)]
ad[, uk_hotspot := as.integer(fr_region %in% uk_expat_hotspots)]

cat("Coastal départements:", sum(ad$coastal == 1) / length(unique(ad$yq)), "\n")
cat("Channel-facing:", sum(ad$channel_facing == 1) / length(unique(ad$yq)), "\n")
cat("UK expat hotspots:", sum(ad$uk_hotspot == 1) / length(unique(ad$yq)), "\n")

# Interaction model: coastal / interior differential
m_geo_coastal <- feols(log_price_m2 ~ log_sci_uk:post_referendum:coastal +
                         log_sci_uk:post_referendum:i(coastal, keep = 0) |
                         fr_region + yq,
                       data = ad, cluster = ~fr_region)
cat("\nCoastal interaction:\n")
summary(m_geo_coastal)

# Subgroup: Channel-facing only vs rest
m_channel <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                     fr_region + yq,
                   data = ad[channel_facing == 1], cluster = ~fr_region)
m_interior <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                      fr_region + yq,
                    data = ad[channel_facing == 0], cluster = ~fr_region)

cat("\nChannel-facing only: β =", round(coef(m_channel)[1], 4),
    "(SE =", round(se(m_channel)[1], 4), ")\n")
cat("Interior only: β =", round(coef(m_interior)[1], 4),
    "(SE =", round(se(m_interior)[1], 4), ")\n")

# UK expat hotspot subgroup
m_hotspot <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                     fr_region + yq,
                   data = ad[uk_hotspot == 1], cluster = ~fr_region)
m_nonhotspot <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                        fr_region + yq,
                      data = ad[uk_hotspot == 0], cluster = ~fr_region)

cat("\nUK hotspot: β =", round(coef(m_hotspot)[1], 4),
    "(SE =", round(se(m_hotspot)[1], 4), ")\n")
cat("Non-hotspot: β =", round(coef(m_nonhotspot)[1], 4),
    "(SE =", round(se(m_nonhotspot)[1], 4), ")\n")

## ========================================================================
## SAVE ALL REVISION RESULTS
## ========================================================================
cat("\n=== Saving revision results ===\n")

revision_results <- list(
  # Workstream 1
  m1a_openness = m1a,
  m1b_resid = m1b,
  m1b2_resid_all = m1b2,
  m1c_triple = m1c,
  m_de_alone = m_de_alone,
  m_ch_alone = m_ch_alone,
  resid_first_stage_r2 = summary(resid_reg)$r.squared,
  resid_first_stage_r2_all = summary(resid_reg2)$r.squared,
  wald_pretrend = if (exists("wald_test")) wald_test else NULL,
  wald_pretrend_no_outlier = if (exists("wald_test_no_outlier")) wald_test_no_outlier else NULL,

  # Workstream 2
  m_houses = m_houses,
  m_apartments = m_apartments,
  m_channel = m_channel,
  m_interior = m_interior,
  m_hotspot = m_hotspot,
  m_nonhotspot = m_nonhotspot,
  m_geo_coastal = m_geo_coastal
)

saveRDS(revision_results, file.path(data_dir, "revision_results.rds"))
cat("Revision results saved.\n")

## ========================================================================
## GENERATE NEW TABLES
## ========================================================================
cat("\n=== Generating revision tables ===\n")

# --- Table: Identification Strengthening ---
setFixest_dict(c(
  "log_sci_uk" = "Log SCI(UK)",
  "log_sci_de" = "Log SCI(Germany)",
  "log_sci_ch" = "Log SCI(Switzerland)",
  "log_total_foreign_nonuk" = "Log SCI(DE+CH)",
  "log_sci_uk_resid" = "Log SCI(UK, resid.)",
  "log_sci_uk_resid2" = "Log SCI(UK, resid. all)",
  "post_referendum" = "Post-Referendum",
  "fr_region" = "D\\'epartement",
  "yq" = "Quarter-Year"
))

# Baseline for comparison
m_baseline <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                      fr_region + yq,
                    data = ad, cluster = ~fr_region)

etable(m_baseline, m1a, m1b, m1b2, m1c,
       headers = c("Baseline", "Openness Ctrl", "Resid.(DE)", "Resid.(DE+CH)", "Triple Race"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_identification.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:identification",
       title = "Identification Strengthening: Controlling for General European Openness")

cat("  Saved tab_identification.tex\n")

# --- Table: Property Type Heterogeneity ---
etable(m_baseline, m_houses, m_apartments,
       headers = c("All Properties", "Houses", "Apartments"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_property_type.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:property_type",
       title = "Mechanism: Property Type Heterogeneity")

cat("  Saved tab_property_type.tex\n")

# --- Table: Geographic Heterogeneity ---
etable(m_baseline, m_channel, m_interior, m_hotspot, m_nonhotspot,
       headers = c("All", "Channel", "Interior", "UK Hotspot", "Non-Hotspot"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_geographic.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:geographic",
       title = "Mechanism: Geographic Heterogeneity")

cat("  Saved tab_geographic.tex\n")

cat("\n=== Revision analysis complete ===\n")
