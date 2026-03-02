## 01_fetch_data.R — Data acquisition
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")

# ============================================================
# A. AFRICAN COUNTRY LIST
# ============================================================

african_countries <- c(
  "DZA","AGO","BEN","BWA","BFA","BDI","CMR","CPV","CAF","TCD",
  "COM","COG","COD","CIV","DJI","EGY","GNQ","ERI","SWZ","ETH",
  "GAB","GMB","GHA","GIN","GNB","KEN","LSO","LBR","LBY","MDG",
  "MWI","MLI","MRT","MUS","MAR","MOZ","NAM","NER","NGA","RWA",
  "STP","SEN","SYC","SLE","SOM","ZAF","SSD","SDN","TZA","TGO",
  "TUN","UGA","ZMB","ZWE"
)

cat("African countries:", length(african_countries), "\n")

# ============================================================
# B. OEC API — MERCURY IMPORTS (HS 280540)
# ============================================================

cat("\n--- Fetching mercury imports from OEC API ---\n")

fetch_oec <- function(hs_code, years, flow = "import", max_retry = 3) {
  all_data <- list()
  year_chunks <- split(years, ceiling(seq_along(years) / 5))

  drilldown <- if (flow == "import") "Importer+Country" else "Exporter+Country"

  for (yc in year_chunks) {
    year_str <- paste(yc, collapse = ",")
    url <- paste0(
      "https://oec.world/olap-proxy/data?cube=trade_i_baci_a_92",
      "&drilldowns=Year,", drilldown, ",HS6",
      "&measures=Trade+Value",
      "&HS6=", hs_code,
      "&Year=", year_str
    )

    for (attempt in 1:max_retry) {
      resp <- tryCatch(GET(url, timeout(60)), error = function(e) NULL)
      if (!is.null(resp) && status_code(resp) == 200) {
        txt <- content(resp, as = "text", encoding = "UTF-8")
        parsed <- tryCatch(fromJSON(txt), error = function(e) NULL)
        if (!is.null(parsed$data) && length(parsed$data) > 0) {
          df <- as.data.frame(parsed$data)
          all_data <- c(all_data, list(df))
          cat("  Fetched", nrow(df), "rows for years", year_str, "\n")
        }
        break
      }
      Sys.sleep(2 * attempt)
    }
    Sys.sleep(0.5)
  }

  if (length(all_data) == 0) return(data.frame())
  bind_rows(all_data)
}

# Mercury imports (HS6 = 280540 -> OEC code = 6280540)
mercury_raw <- fetch_oec("6280540", 2000:2023, "import")
cat("Total mercury import records:", nrow(mercury_raw), "\n")

# ============================================================
# C. OEC API — BILATERAL MERCURY (by Exporter for each Importer)
# ============================================================

cat("\n--- Fetching bilateral mercury data ---\n")

# Get bilateral flows with both importer and exporter
fetch_oec_bilateral <- function(hs_code, years) {
  all_data <- list()
  year_chunks <- split(years, ceiling(seq_along(years) / 3))

  for (yc in year_chunks) {
    year_str <- paste(yc, collapse = ",")
    url <- paste0(
      "https://oec.world/olap-proxy/data?cube=trade_i_baci_a_92",
      "&drilldowns=Year,Importer+Country,Exporter+Country,HS6",
      "&measures=Trade+Value",
      "&HS6=", hs_code,
      "&Year=", year_str
    )

    for (attempt in 1:3) {
      resp <- tryCatch(GET(url, timeout(90)), error = function(e) NULL)
      if (!is.null(resp) && status_code(resp) == 200) {
        txt <- content(resp, as = "text", encoding = "UTF-8")
        parsed <- tryCatch(fromJSON(txt), error = function(e) NULL)
        if (!is.null(parsed$data) && length(parsed$data) > 0) {
          all_data <- c(all_data, list(as.data.frame(parsed$data)))
          cat("  Bilateral:", nrow(as.data.frame(parsed$data)), "rows for", year_str, "\n")
        }
        break
      }
      Sys.sleep(3 * attempt)
    }
    Sys.sleep(1)
  }

  if (length(all_data) == 0) return(data.frame())
  bind_rows(all_data)
}

mercury_bilateral <- fetch_oec_bilateral("6280540", 2005:2022)
cat("Total bilateral records:", nrow(mercury_bilateral), "\n")

# ============================================================
# D. OEC API — GOLD EXPORTS (HS 7108)
# ============================================================

cat("\n--- Fetching gold exports ---\n")
# OEC prefix for HS chapter 71 (precious metals) is "14", not "6"
# Fetch all gold subcodes and combine
gold_811 <- fetch_oec("14710811", 2000:2023, "export")  # Gold powder
gold_812 <- fetch_oec("14710812", 2000:2023, "export")  # Unwrought gold (main)
gold_813 <- fetch_oec("14710813", 2000:2023, "export")  # Semi-manufactured gold
gold_raw <- bind_rows(gold_811, gold_812, gold_813)
cat("Gold export records:", nrow(gold_raw), "\n")

# ============================================================
# E. PLACEBO — FERTILIZER IMPORTS (HS 3105)
# ============================================================

cat("\n--- Fetching placebo commodity (fertilizer) ---\n")
# OEC prefix for HS chapter 31 (fertilizers) is "6"
# Fetch main NPK fertilizer subcodes and combine
fert_520 <- fetch_oec("6310520", 2005:2020, "import")  # NPK fertilizers (main)
fert_530 <- fetch_oec("6310530", 2005:2020, "import")  # DAP fertilizer
fert_590 <- fetch_oec("6310590", 2005:2020, "import")  # Other fertilizer mixes
fertilizer_raw <- bind_rows(fert_520, fert_530, fert_590)
cat("Fertilizer records:", nrow(fertilizer_raw), "\n")

# ============================================================
# F. WDI — GDP, POPULATION, TRADE
# ============================================================

cat("\n--- Fetching WDI data ---\n")
library(WDI)

wdi_indicators <- c(
  "NY.GDP.PCAP.CD",
  "SP.POP.TOTL",
  "NY.GDP.MKTP.CD",
  "NE.TRD.GNFS.ZS"
)

wdi_data <- WDI(
  country   = african_countries,
  indicator = wdi_indicators,
  start     = 2000,
  end       = 2023,
  extra     = TRUE
)
cat("WDI records:", nrow(wdi_data), "\n")

# ============================================================
# G. WGI — GOVERNANCE INDICATORS
# ============================================================

cat("\n--- Fetching governance indicators ---\n")

wgi_indicators <- c(
  "CC.EST", "RL.EST", "GE.EST", "RQ.EST"
)

wgi_data <- WDI(
  country   = african_countries,
  indicator = wgi_indicators,
  start     = 2000,
  end       = 2023,
  extra     = TRUE
)
cat("WGI records:", nrow(wgi_data), "\n")

# ============================================================
# H. MINAMATA RATIFICATION DATES (hardcoded from official source)
# ============================================================

minamata_ratification <- tribble(
  ~iso3c, ~ratification_date,    ~nap_year,
  "DJI",  "2014-09-23",          NA,
  "GAB",  "2014-09-24",          2024,
  "LSO",  "2014-11-12",          NA,
  "SYC",  "2015-01-13",          NA,
  "TCD",  "2015-09-24",          2022,
  "MRT",  "2015-08-18",          NA,
  "BWA",  "2016-06-03",          NA,
  "MLI",  "2016-05-27",          2020,
  "SEN",  "2016-03-03",          2019,
  "ZMB",  "2016-03-11",          2023,
  "BEN",  "2016-11-07",          NA,
  "GMB",  "2016-11-07",          NA,
  "SLE",  "2016-11-01",          2020,
  "BFA",  "2017-04-10",          2020,
  "GHA",  "2017-03-23",          2022,
  "TGO",  "2017-02-03",          2023,
  "MUS",  "2017-09-21",          NA,
  "NAM",  "2017-09-06",          NA,
  "RWA",  "2017-06-29",          2023,
  "GIN",  "2018-10-22",          2021,
  "GNB",  "2018-10-22",          NA,
  "NER",  "2018-02-01",          2022,
  "NGA",  "2018-02-01",          2021,
  "CIV",  "2019-10-01",          2023,
  "GNQ",  "2019-12-24",          NA,
  "ZAF",  "2019-04-29",          NA,
  "UGA",  "2019-03-01",          2021,
  "TZA",  "2020-10-05",          2022,
  "BDI",  "2021-03-26",          2020,
  "CMR",  "2021-03-10",          2024,
  "CAF",  "2021-03-31",          2021,
  "ZWE",  "2021-08-19",          2021,
  "ERI",  "2023-02-07",          2023,
  "KEN",  "2023-09-22",          2022,
  "MWI",  "2023-06-23",          NA,
  "ETH",  "2024-08-19",          NA,
  "LBR",  "2024-09-24",          NA,
  "MOZ",  "2024-02-19",          2024
) %>%
  mutate(
    ratification_date = as.Date(ratification_date),
    ratification_year = as.integer(format(ratification_date, "%Y")),
    treatment_year = ratification_year + 1L
  )

cat("Minamata ratifiers:", nrow(minamata_ratification), "\n")

# ============================================================
# I. ASGM COUNTRY INDICATORS
# ============================================================

asgm_countries <- tribble(
  ~iso3c, ~asgm_level,   ~est_miners_thousands,
  "GHA",  "very_high",   1000,
  "BFA",  "very_high",   700,
  "MLI",  "very_high",   600,
  "TZA",  "very_high",   800,
  "COD",  "very_high",   500,
  "SDN",  "very_high",   1000,
  "NER",  "high",        400,
  "SEN",  "high",        200,
  "GIN",  "high",        300,
  "SLE",  "high",        200,
  "ZWE",  "high",        350,
  "ZMB",  "moderate",    150,
  "UGA",  "moderate",    100,
  "KEN",  "moderate",    100,
  "LBR",  "moderate",    80,
  "CMR",  "moderate",    50,
  "NGA",  "moderate",    200,
  "CAF",  "moderate",    100,
  "MOZ",  "moderate",    100,
  "TGO",  "low",         20,
  "BEN",  "low",         10,
  "CIV",  "moderate",    200,
  "ETH",  "moderate",    150
)

# ============================================================
# J. EU MEMBER STATES (2010)
# ============================================================

eu_members_2010 <- c(
  "AUT","BEL","BGR","CYP","CZE","DNK","EST","FIN","FRA","DEU",
  "GRC","HUN","IRL","ITA","LVA","LTU","LUX","MLT","NLD","POL",
  "PRT","ROU","SVK","SVN","ESP","SWE","GBR"
)

# ============================================================
# SAVE RAW DATA
# ============================================================

cat("\n--- Saving ---\n")
save(mercury_raw, mercury_bilateral, gold_raw, fertilizer_raw,
     wdi_data, wgi_data, minamata_ratification, asgm_countries,
     african_countries, eu_members_2010,
     file = file.path(data_dir, "raw_data.RData"))

cat("Done. All raw data saved.\n")
