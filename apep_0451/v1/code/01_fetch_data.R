##──────────────────────────────────────────────────────────────────────────────
## 01_fetch_data.R — Fetch IPUMS International extract and cocoa prices
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(httr)
library(jsonlite)
library(data.table)

DATA_DIR <- here::here("output", "apep_0451", "v1", "data")
dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)

## ── 1. IPUMS International Extract ──────────────────────────────────────────
## Submit extract for Ghana 1984, 2000, 2010 censuses
## Variables: AGE, SEX, EDATTAIN, EDATTAIND, EMPSTAT, EMPSTATD,
##            GEO1_GH, GEO2_GH, URBAN, CLASSWK, INDGEN,
##            NCHILD, CHBORN, LIT, SCHOOL, PERWT, HHWT

IPUMS_KEY <- Sys.getenv("IPUMS_API_KEY")
if (nchar(IPUMS_KEY) == 0) stop("IPUMS_API_KEY not set in environment")

## Build extract JSON manually to ensure empty objects {} not arrays []
empty_obj <- setNames(list(), character(0))
extract_def <- list(
  description = "Ghana 1984-2000-2010 census for apep_0451",
  dataStructure = list(rectangular = list(on = "P")),
  samples = list(
    "gh1984a" = empty_obj,
    "gh2000a" = empty_obj,
    "gh2010a" = empty_obj
  ),
  variables = list(
    "AGE"       = empty_obj,
    "SEX"       = empty_obj,
    "EDATTAIN"  = empty_obj,
    "EDATTAIND" = empty_obj,
    "EMPSTAT"   = empty_obj,
    "EMPSTATD"  = empty_obj,
    "GEO1_GH"   = empty_obj,
    "GEO2_GH"   = empty_obj,
    "URBAN"     = empty_obj,
    "CLASSWK"   = empty_obj,
    "INDGEN"    = empty_obj,
    "LIT"       = empty_obj,
    "SCHOOL"    = empty_obj,
    "NCHILD"    = empty_obj,
    "CHBORN"    = empty_obj,
    "PERWT"     = empty_obj,
    "HHWT"      = empty_obj
  ),
  dataFormat = "csv"
)

cat("Submitting IPUMS International extract...\n")
resp <- POST(
  "https://api.ipums.org/extracts/?collection=ipumsi&version=2",
  add_headers(Authorization = IPUMS_KEY),
  content_type_json(),
  body = toJSON(extract_def, auto_unbox = TRUE)
)

if (http_error(resp)) {
  cat("Response:", content(resp, "text"), "\n")
  stop("IPUMS extract submission failed")
}

extract_info <- content(resp, "parsed")
extract_num <- extract_info$number
cat("Extract submitted successfully. Number:", extract_num, "\n")

## Poll for completion
poll_url <- paste0("https://api.ipums.org/extracts/", extract_num,
                   "?collection=ipumsi&version=2")
max_polls <- 60  # 30 minutes max
for (i in seq_len(max_polls)) {
  Sys.sleep(30)
  status_resp <- GET(poll_url, add_headers(Authorization = IPUMS_KEY))
  status_info <- content(status_resp, "parsed")
  current_status <- status_info$status
  cat(sprintf("[%s] Poll %d: %s\n", Sys.time(), i, current_status))

  if (current_status == "completed") {
    cat("Extract ready!\n")
    break
  } else if (current_status == "failed") {
    stop("IPUMS extract failed")
  }
}
if (current_status != "completed") stop("Extract timed out after 30 minutes")

## Download
download_links <- status_info$downloadLinks
data_url <- download_links$data$url
ddi_url <- download_links$ddiCodebook$url

cat("Downloading data...\n")
download.file(data_url, file.path(DATA_DIR, "ipums_ghana.csv.gz"),
              mode = "wb",
              headers = c(Authorization = IPUMS_KEY))

cat("Downloading DDI codebook...\n")
download.file(ddi_url, file.path(DATA_DIR, "ipums_ghana.xml"),
              mode = "wb",
              headers = c(Authorization = IPUMS_KEY))

cat("IPUMS data downloaded successfully.\n")

## ── 2. World Cocoa Prices from FRED ─────────────────────────────────────────
FRED_KEY <- Sys.getenv("FRED_API_KEY")
if (nchar(FRED_KEY) == 0) stop("FRED_API_KEY not set in environment")

## Annual cocoa prices (2003-2025)
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
## Source: World Bank Commodity Price Data (Pink Sheet)
## Historical cocoa prices (USD/mt, nominal annual averages)
historical_cocoa <- data.table(
  year = c(1980L, 1981L, 1982L, 1983L, 1984L, 1985L, 1986L, 1987L, 1988L,
           1989L, 1990L, 1991L, 1992L, 1993L, 1994L, 1995L, 1996L, 1997L,
           1998L, 1999L, 2000L, 2001L, 2002L),
  price_usd_mt = c(2608, 2080, 1737, 2117, 2383, 2254, 2099, 1994, 1564,
                    1237, 1267, 1195, 1098, 1117, 1400, 1432, 1461, 1620,
                    1686, 1138, 906, 1087, 1778)
)

## Merge: use historical for pre-2003, FRED for 2003+
cocoa_full <- rbind(
  historical_cocoa[year < 2003],
  cocoa_prices[year >= 2003]
)
setorder(cocoa_full, year)

fwrite(cocoa_full, file.path(DATA_DIR, "cocoa_prices.csv"))
cat("Cocoa prices saved. Years:", range(cocoa_full$year), "\n")
cat("Price range: $", min(cocoa_full$price_usd_mt), "- $",
    max(cocoa_full$price_usd_mt), "/mt\n")

## ── 3. Regional Cocoa Production Shares ─────────────────────────────────────
## Sources: COCOBOD Annual Reports; Kolavalli & Vigneri (2011);
## Vigneri (2005); Asamoah & Owusu-Ansah (2017)
## Shares are % of national cocoa production, averaged over late 1990s/early 2000s

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

## ── 4. DHS Health Indicators (supplementary pre-trends) ─────────────────────
## Fetch key health indicators from DHS STATcompiler API for extended trends

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
        survey_year = r$SurveyYear,
        region = r$CharacteristicLabel,
        value = as.numeric(r$Value),
        ci_low = as.numeric(r$CILow),
        ci_high = as.numeric(r$CIHigh)
      )
    }))
    dhs_all[[ind]] <- dhs_dt
  }
  Sys.sleep(1)  # Rate limiting
}

dhs_panel <- rbindlist(dhs_all)
fwrite(dhs_panel, file.path(DATA_DIR, "dhs_regional_panel.csv"))
cat("DHS panel saved:", nrow(dhs_panel), "records across",
    uniqueN(dhs_panel$indicator), "indicators.\n")

cat("\n=== Data fetch complete ===\n")
cat("Files in", DATA_DIR, ":\n")
list.files(DATA_DIR)
