##──────────────────────────────────────────────────────────────────────────────
## 01b_fetch_prices_dhs.R — Fetch cocoa prices and DHS data
##──────────────────────────────────────────────────────────────────────────────

library(httr)
library(jsonlite)
library(data.table)

DATA_DIR <- here::here("output", "apep_0451", "v1", "data")

## ── 2. World Cocoa Prices from FRED ─────────────────────────────────────────
FRED_KEY <- Sys.getenv("FRED_API_KEY")
if (nchar(FRED_KEY) == 0) stop("FRED_API_KEY not set in environment")

fred_url <- paste0(
  "https://api.stlouisfed.org/fred/series/observations?",
  "series_id=PCOCOUSDM&api_key=", FRED_KEY,
  "&file_type=json&observation_start=1980-01-01&frequency=a"
)
fred_resp <- GET(fred_url)
fred_data <- content(fred_resp, "parsed")

cocoa_prices <- data.table(
  year = as.integer(substr(sapply(fred_data$observations, `[[`, "date"), 1, 4)),
  price_usd_mt = as.numeric(sapply(fred_data$observations, `[[`, "value"))
)
cocoa_prices <- cocoa_prices[!is.na(price_usd_mt)]

## Supplement with World Bank Pink Sheet for pre-2003 prices
historical_cocoa <- data.table(
  year = c(1980L, 1981L, 1982L, 1983L, 1984L, 1985L, 1986L, 1987L, 1988L,
           1989L, 1990L, 1991L, 1992L, 1993L, 1994L, 1995L, 1996L, 1997L,
           1998L, 1999L, 2000L, 2001L, 2002L),
  price_usd_mt = c(2608, 2080, 1737, 2117, 2383, 2254, 2099, 1994, 1564,
                    1237, 1267, 1195, 1098, 1117, 1400, 1432, 1461, 1620,
                    1686, 1138, 906, 1087, 1778)
)

cocoa_full <- rbind(
  historical_cocoa[year < 2003],
  cocoa_prices[year >= 2003]
)
setorder(cocoa_full, year)
fwrite(cocoa_full, file.path(DATA_DIR, "cocoa_prices.csv"))
cat("Cocoa prices saved. Years:", range(cocoa_full$year), "\n")

## ── 3. Regional Cocoa Production Shares ─────────────────────────────────────
cocoa_shares <- data.table(
  region = c("Western", "Ashanti", "Brong Ahafo", "Eastern",
             "Central", "Volta", "Greater Accra", "Northern",
             "Upper East", "Upper West"),
  geo1_gh = c(1L, 7L, 8L, 5L, 2L, 6L, 3L, 9L, 10L, 4L),
  cocoa_share = c(0.55, 0.20, 0.12, 0.08, 0.03, 0.01, 0.00, 0.00, 0.00, 0.00),
  forest_belt = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)
)
fwrite(cocoa_shares, file.path(DATA_DIR, "cocoa_regional_shares.csv"))
cat("Regional cocoa shares saved.\n")

## ── 4. DHS Health Indicators ────────────────────────────────────────────────
indicators <- c(
  "CM_ECMR_C_IMR",   # Infant mortality
  "CM_ECMR_C_U5M",   # Under-5 mortality
  "FE_FRTR_W_TFR",   # Total fertility rate
  "RH_DELP_C_DHF",   # Delivery in health facility
  "RH_ANCN_W_N4P"    # 4+ ANC visits
)

dhs_all <- list()
for (ind in indicators) {
  url <- paste0("https://api.dhsprogram.com/rest/dhs/data?",
                "countryIds=GH&indicatorIds=", ind,
                "&breakdown=subnational&f=json")
  resp <- GET(url)
  dat <- content(resp, "parsed")
  records <- dat$Data

  if (length(records) > 0) {
    dhs_dt <- rbindlist(lapply(records, function(r) {
      data.table(
        indicator = ind,
        survey_year = as.integer(r$SurveyYear),
        region = as.character(r$CharacteristicLabel),
        value = as.numeric(r$Value),
        ci_low = if (!is.null(r$CILow)) as.numeric(r$CILow) else NA_real_,
        ci_high = if (!is.null(r$CIHigh)) as.numeric(r$CIHigh) else NA_real_
      )
    }))
    dhs_all[[ind]] <- dhs_dt
    cat("  ", ind, ":", nrow(dhs_dt), "records\n")
  }
  Sys.sleep(1)
}

dhs_panel <- rbindlist(dhs_all)
fwrite(dhs_panel, file.path(DATA_DIR, "dhs_regional_panel.csv"))
cat("DHS panel saved:", nrow(dhs_panel), "records.\n")

cat("\n=== Data fetch complete ===\n")
cat("Files:\n")
for (f in list.files(DATA_DIR)) {
  sz <- file.info(file.path(DATA_DIR, f))$size
  cat(sprintf("  %s (%s)\n", f, format(sz, big.mark = ",")))
}
