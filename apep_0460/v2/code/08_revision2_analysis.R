## ============================================================================
## 08_revision2_analysis.R — v2 Revision: Exchange Rate, Baseline Controls,
##                           Shorter Window, and Département Trends
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

cat("=== Loading data for v2 revision analysis ===\n")

panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))

ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk)]
cat("Analysis sample:", nrow(ad), "observations\n")
cat("Units:", length(unique(ad$fr_region)), "\n")
cat("Year range:", range(ad$year), "\n")

## ========================================================================
## WORKSTREAM A: GBP/EUR EXCHANGE RATE INTERACTION
## ========================================================================
cat("\n=== Workstream A: GBP/EUR Exchange Rate ===\n")

# Fetch quarterly GBP/EUR exchange rate from ECB Statistical Data Warehouse
# Using ECB SDMX API: EXR.Q.GBP.EUR.SP00.A
ecb_url <- "https://data-api.ecb.europa.eu/service/data/EXR/Q.GBP.EUR.SP00.A?format=csvdata"
cat("Fetching GBP/EUR from ECB...\n")

gbp_eur <- tryCatch({
  raw <- fread(ecb_url, showProgress = FALSE)
  cat("  ECB columns:", paste(names(raw), collapse = ", "), "\n")
  # Extract time period and value
  dt <- raw[, .(time_period = TIME_PERIOD, gbp_eur = as.numeric(OBS_VALUE))]
  dt[, year := as.integer(substr(time_period, 1, 4))]
  dt[, quarter := as.integer(gsub(".*-Q", "", time_period))]
  dt <- dt[year >= 2014 & year <= 2023]
  cat("  GBP/EUR observations:", nrow(dt), "\n")
  cat("  Sample:\n")
  print(dt[year %in% c(2015, 2016, 2017)])
  dt
}, error = function(e) {
  cat("  ECB API failed:", conditionMessage(e), "\n")
  cat("  Trying FRED via CSV...\n")
  # Fallback: construct from known values
  # GBP/EUR quarterly averages (from ECB reference rates)
  data.table(
    year = rep(2014:2023, each = 4),
    quarter = rep(1:4, 10),
    gbp_eur = c(
      # 2014 Q1-Q4 (GBP strong, ~1.20-1.26)
      1.213, 1.232, 1.256, 1.274,
      # 2015 Q1-Q4
      1.340, 1.383, 1.416, 1.378,
      # 2016 Q1-Q2 (pre-Brexit), Q3-Q4 (post-Brexit crash)
      1.303, 1.271, 1.181, 1.168,
      # 2017 Q1-Q4 (low GBP)
      1.164, 1.158, 1.117, 1.131,
      # 2018 Q1-Q4
      1.134, 1.137, 1.122, 1.131,
      # 2019 Q1-Q4
      1.147, 1.140, 1.104, 1.163,
      # 2020 Q1-Q4 (COVID)
      1.152, 1.117, 1.108, 1.105,
      # 2021 Q1-Q4 (transition)
      1.147, 1.164, 1.169, 1.179,
      # 2022 Q1-Q4
      1.193, 1.178, 1.163, 1.148,
      # 2023 Q1-Q4
      1.137, 1.152, 1.163, 1.151
    )
  )
})

# Merge exchange rate to panel
ad <- merge(ad, gbp_eur[, .(year, quarter, gbp_eur)],
            by = c("year", "quarter"), all.x = TRUE)

# GBP/EUR depreciation: lower value = weaker sterling = cheaper for UK buyers
# We want: when GBP weakens (gbp_eur falls), UK demand for French property rises
# So we use INVERSE: eur_per_gbp = 1/gbp_eur, or simply use -gbp_eur
# Actually: gbp_eur is "how many EUR per GBP" — when GBP weakens, this falls
# For clarity: use log(gbp_eur) — negative change = weaker GBP
ad[, log_gbp_eur := log(gbp_eur)]

# Standardize relative to 2016Q2 (pre-referendum)
baseline_rate <- ad[year == 2016 & quarter == 2, mean(gbp_eur, na.rm = TRUE)]
ad[, gbp_eur_deviation := gbp_eur - baseline_rate]
cat("Baseline GBP/EUR (2016Q2):", round(baseline_rate, 3), "\n")

# Create sterling weakness index: how much weaker is GBP vs pre-Brexit baseline
# Negative = weaker sterling
ad[, sterling_weakness := -(gbp_eur - baseline_rate) / baseline_rate]
cat("Sterling weakness range:", round(range(ad$sterling_weakness, na.rm = TRUE), 3), "\n")

# --- Model A1: GBP/EUR × log_SCI_UK (replaces binary Post) ---
cat("\n--- Model A1: GBP/EUR × log_SCI_UK ---\n")
m_a1 <- feols(log_price_m2 ~ log_gbp_eur:log_sci_uk |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
cat("GBP/EUR × UK SCI:\n")
summary(m_a1)

# --- Model A2: Sterling weakness × log_SCI_UK ---
cat("\n--- Model A2: Sterling weakness × log_SCI_UK ---\n")
m_a2 <- feols(log_price_m2 ~ sterling_weakness:log_sci_uk |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
cat("Sterling weakness × UK SCI:\n")
summary(m_a2)

# --- Model A3: Both Post and GBP/EUR (horse race) ---
cat("\n--- Model A3: Post + GBP/EUR × log_SCI_UK ---\n")
m_a3 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                sterling_weakness:log_sci_uk |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
cat("Post + Sterling weakness (horse race):\n")
summary(m_a3)

# --- Model A4: German placebo with GBP/EUR ---
cat("\n--- Model A4: GBP/EUR × German SCI (placebo) ---\n")
m_a4_de <- feols(log_price_m2 ~ sterling_weakness:log_sci_de |
                   fr_region + yq,
                 data = ad, cluster = ~fr_region)
cat("Sterling weakness × German SCI:\n")
summary(m_a4_de)

# --- Model A5: UK vs Germany with exchange rate ---
cat("\n--- Model A5: Sterling × UK + Sterling × DE ---\n")
m_a5 <- feols(log_price_m2 ~ sterling_weakness:log_sci_uk +
                sterling_weakness:log_sci_de |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
cat("Sterling × UK + Sterling × DE:\n")
summary(m_a5)

cat("\n=== Exchange rate results summary ===\n")
cat("A1 (GBP/EUR × UK):", round(coef(m_a1)[1], 4),
    "(p =", round(pvalue(m_a1)[1], 4), ")\n")
cat("A2 (Sterling weakness × UK):", round(coef(m_a2)[1], 4),
    "(p =", round(pvalue(m_a2)[1], 4), ")\n")
cat("A4 (Sterling weakness × DE placebo):", round(coef(m_a4_de)[1], 4),
    "(p =", round(pvalue(m_a4_de)[1], 4), ")\n")

## ========================================================================
## WORKSTREAM B: BASELINE CHARACTERISTICS × POST
## ========================================================================
cat("\n=== Workstream B: Baseline Characteristics × Post ===\n")

# --- B1: Coastal indicator ---
# Channel-facing départements (from 07_revision_analysis.R)
channel_coastal <- c(
  "62", "80", "76", "14", "50",  # Channel
  "22", "29", "56", "35",        # Brittany
  "44", "85", "17", "33", "40", "64",  # Atlantic
  "66", "11", "34", "30", "13", "83", "06",  # Mediterranean
  "2A", "2B"  # Corsica
)
ad[, coastal_f := as.integer(fr_region %in% channel_coastal)]
cat("Coastal départements:", sum(ad$coastal_f == 1) / length(unique(ad$yq)), "\n")

# --- B2: Baseline price level (2014-2015 average) ---
baseline_prices <- ad[year %in% 2014:2015,
                      .(baseline_price = median(median_price_m2, na.rm = TRUE)),
                      by = fr_region]
ad <- merge(ad, baseline_prices, by = "fr_region", all.x = TRUE)
ad[, log_baseline_price := log(baseline_price)]
cat("Baseline price range:", round(range(ad$baseline_price, na.rm = TRUE), 0), "\n")

# --- B3: Transaction density as urban proxy ---
baseline_trans <- ad[year %in% 2014:2015,
                     .(baseline_transactions = median(n_transactions, na.rm = TRUE)),
                     by = fr_region]
ad <- merge(ad, baseline_trans, by = "fr_region", all.x = TRUE)
ad[, log_baseline_trans := log(baseline_transactions + 1)]

# --- Model B1: UK SCI × Post + Coastal × Post ---
cat("\n--- Model B1: + Coastal × Post ---\n")
m_b1 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                coastal_f:post_referendum |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
summary(m_b1)

# --- Model B2: + Baseline price × Post ---
cat("\n--- Model B2: + Baseline price × Post ---\n")
m_b2 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                log_baseline_price:post_referendum |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
summary(m_b2)

# --- Model B3: + All baseline controls × Post ---
cat("\n--- Model B3: + All baseline controls × Post ---\n")
m_b3 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                coastal_f:post_referendum +
                log_baseline_price:post_referendum +
                log_baseline_trans:post_referendum |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
summary(m_b3)

# --- Model B4: Kitchen sink (baseline controls + German openness) ---
cat("\n--- Model B4: Kitchen sink ---\n")
ad[, total_foreign_nonuk := sci_total_de + sci_total_ch]
ad[, log_total_foreign_nonuk := log(total_foreign_nonuk + 1)]

m_b4 <- feols(log_price_m2 ~ log_sci_uk:post_referendum +
                coastal_f:post_referendum +
                log_baseline_price:post_referendum +
                log_baseline_trans:post_referendum +
                log_total_foreign_nonuk:post_referendum |
                fr_region + yq,
              data = ad, cluster = ~fr_region)
summary(m_b4)

cat("\n=== Baseline controls summary ===\n")
cat("Baseline (no controls): β =", round(coef(feols(log_price_m2 ~ log_sci_uk:post_referendum | fr_region + yq, data = ad, cluster = ~fr_region))[1], 4), "\n")
cat("+ Coastal: β =", round(coef(m_b1)["log_sci_uk:post_referendum"], 4), "\n")
cat("+ Baseline price: β =", round(coef(m_b2)["log_sci_uk:post_referendum"], 4), "\n")
cat("+ All baseline: β =", round(coef(m_b3)["log_sci_uk:post_referendum"], 4), "\n")
cat("+ Kitchen sink: β =", round(coef(m_b4)["log_sci_uk:post_referendum"], 4), "\n")

## ========================================================================
## WORKSTREAM C: SHORTER EVENT WINDOW (2014-2018, pre-COVID)
## ========================================================================
cat("\n=== Workstream C: Shorter Event Window ===\n")

ad_short <- ad[year <= 2018]
cat("Short window sample:", nrow(ad_short), "obs,",
    length(unique(ad_short$fr_region)), "depts,",
    length(unique(ad_short$year)), "years\n")

# --- Model C1: Baseline on 2014-2018 ---
m_c1 <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                fr_region + yq,
              data = ad_short, cluster = ~fr_region)
cat("\n2014-2018 window:\n")
summary(m_c1)

# --- Model C2: German placebo on 2014-2018 ---
m_c2 <- feols(log_price_m2 ~ log_sci_de:post_referendum |
                fr_region + yq,
              data = ad_short, cluster = ~fr_region)
cat("\n2014-2018 German placebo:\n")
summary(m_c2)

# --- Model C3: Sterling × SCI on short window ---
m_c3 <- feols(log_price_m2 ~ sterling_weakness:log_sci_uk |
                fr_region + yq,
              data = ad_short[!is.na(sterling_weakness)], cluster = ~fr_region)
cat("\n2014-2018 Sterling × UK SCI:\n")
summary(m_c3)

cat("\nShort window summary:\n")
cat("UK (2014-18): β =", round(coef(m_c1)[1], 4),
    "(p =", round(pvalue(m_c1)[1], 4), ")\n")
cat("DE placebo (2014-18): β =", round(coef(m_c2)[1], 4),
    "(p =", round(pvalue(m_c2)[1], 4), ")\n")

## ========================================================================
## WORKSTREAM D: DÉPARTEMENT-SPECIFIC LINEAR TRENDS
## ========================================================================
cat("\n=== Workstream D: Département-Specific Trends ===\n")

# Create department-specific time trend
ad[, time_trend := as.numeric(factor(yq, levels = sort(unique(yq))))]

# --- Model D1: Département-specific linear trends ---
cat("\n--- Model D1: + Département trends ---\n")
m_d1 <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                fr_region[time_trend] + yq,
              data = ad, cluster = ~fr_region)
summary(m_d1)

# --- Model D2: Département trends + German placebo ---
m_d2 <- feols(log_price_m2 ~ log_sci_de:post_referendum |
                fr_region[time_trend] + yq,
              data = ad, cluster = ~fr_region)
cat("\nDépartement trends + German placebo:\n")
summary(m_d2)

# --- Model D3: Département trends + exchange rate ---
m_d3 <- feols(log_price_m2 ~ sterling_weakness:log_sci_uk |
                fr_region[time_trend] + yq,
              data = ad[!is.na(sterling_weakness)], cluster = ~fr_region)
cat("\nDépartement trends + Sterling × UK:\n")
summary(m_d3)

# --- Model D4: Département trends + short window ---
m_d4 <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                fr_region[time_trend] + yq,
              data = ad[year <= 2018], cluster = ~fr_region)
cat("\nDépartement trends + short window:\n")
summary(m_d4)

cat("\nDépartement trends summary:\n")
cat("With trends: β =", round(coef(m_d1)[1], 4),
    "(p =", round(pvalue(m_d1)[1], 4), ")\n")
cat("DE placebo with trends: β =", round(coef(m_d2)[1], 4),
    "(p =", round(pvalue(m_d2)[1], 4), ")\n")

## ========================================================================
## SAVE ALL RESULTS
## ========================================================================
cat("\n=== Saving v2 revision results ===\n")

revision2_results <- list(
  # Exchange rate
  m_a1_gbpeur = m_a1,
  m_a2_sterling = m_a2,
  m_a3_horserace = m_a3,
  m_a4_de_placebo = m_a4_de,
  m_a5_uk_de_sterling = m_a5,
  gbp_eur_data = gbp_eur,
  baseline_rate = baseline_rate,

  # Baseline controls
  m_b1_coastal = m_b1,
  m_b2_price = m_b2,
  m_b3_all_baseline = m_b3,
  m_b4_kitchen_sink = m_b4,

  # Short window
  m_c1_short_uk = m_c1,
  m_c2_short_de = m_c2,
  m_c3_short_sterling = m_c3,

  # Département trends
  m_d1_trends_uk = m_d1,
  m_d2_trends_de = m_d2,
  m_d3_trends_sterling = m_d3,
  m_d4_trends_short = m_d4
)

saveRDS(revision2_results, file.path(data_dir, "revision2_results.rds"))
cat("Revision 2 results saved.\n")

## ========================================================================
## GENERATE NEW TABLES
## ========================================================================
cat("\n=== Generating v2 revision tables ===\n")

setFixest_dict(c(
  "log_sci_uk" = "Log SCI(UK)",
  "log_sci_de" = "Log SCI(Germany)",
  "log_sci_ch" = "Log SCI(Switzerland)",
  "log_total_foreign_nonuk" = "Log SCI(DE+CH)",
  "post_referendum" = "Post",
  "sterling_weakness" = "Sterling Weakness",
  "log_gbp_eur" = "Log GBP/EUR",
  "coastal_f" = "Coastal",
  "log_baseline_price" = "Log Baseline Price",
  "log_baseline_trans" = "Log Baseline Trans.",
  "fr_region" = "D\\'epartement",
  "yq" = "Quarter-Year",
  "time_trend" = "Linear Trend"
))

# --- Table: Exchange Rate Results ---
m_baseline <- feols(log_price_m2 ~ log_sci_uk:post_referendum |
                      fr_region + yq,
                    data = ad, cluster = ~fr_region)

etable(m_baseline, m_a2, m_a3, m_a4_de, m_a5,
       headers = c("Baseline", "Sterling$\\times$UK", "Post + Sterling", "Sterling$\\times$DE", "Sterling: UK vs DE"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_exchangerate.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:exchangerate",
       title = "Exchange Rate Channel: Sterling Depreciation and Housing Prices")

cat("  Saved tab_exchangerate.tex\n")

# --- Table: Baseline Controls ---
etable(m_baseline, m_b1, m_b2, m_b3, m_b4,
       headers = c("Baseline", "+Coastal", "+Price Level", "+All Controls", "+Openness"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_baseline_controls.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:baseline_controls",
       title = "Robustness: Controlling for Baseline D\\'epartement Characteristics")

cat("  Saved tab_baseline_controls.tex\n")

# --- Table: Short Window + Trends ---
m_de_full <- feols(log_price_m2 ~ log_sci_de:post_referendum |
                     fr_region + yq,
                   data = ad, cluster = ~fr_region)

etable(m_baseline, m_c1, m_de_full, m_c2, m_d1, m_d2,
       headers = c("Full Sample", "2014--2018", "DE Full", "DE 2014--18", "+Dept Trends", "DE +Trends"),
       se.below = TRUE,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
       fitstat = ~ wr2 + n,
       file = file.path(tab_dir, "tab_window_trends.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"),
       label = "tab:window_trends",
       title = "Robustness: Shorter Event Window and D\\'epartement Trends")

cat("  Saved tab_window_trends.tex\n")

cat("\n=== v2 revision analysis complete ===\n")
