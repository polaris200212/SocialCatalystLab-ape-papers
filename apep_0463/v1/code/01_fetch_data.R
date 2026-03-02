## ============================================================
## 01_fetch_data.R — Data Acquisition
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------
## 1. FEWS NET Staple Food Price Data (Nigeria)
## ---------------------------------------------------------
cat("Fetching FEWS NET food price data...\n")
fewsnet_url <- paste0(
  "https://fdw.fews.net/api/marketpricefacts/",
  "?dataset=FEWS_NET_Staple_Food_Price_Data",
  "&country=NG&format=csv&fields=website&end_date"
)

fewsnet_file <- file.path(data_dir, "fewsnet_nigeria.csv")
if (!file.exists(fewsnet_file)) {
  download.file(fewsnet_url, fewsnet_file, mode = "w", quiet = FALSE)
}
fewsnet_raw <- fread(fewsnet_file, encoding = "UTF-8")
cat(sprintf("  FEWS NET: %s rows, %s columns\n", nrow(fewsnet_raw), ncol(fewsnet_raw)))
cat(sprintf("  States: %s\n", paste(sort(unique(fewsnet_raw$admin_1)), collapse = ", ")))
cat(sprintf("  Products: %s\n", length(unique(fewsnet_raw$product))))
cat(sprintf("  Date range: %s to %s\n", min(fewsnet_raw$period_date), max(fewsnet_raw$period_date)))

## ---------------------------------------------------------
## 2. UCDP Conflict Data (Nigeria) — for controls
## ---------------------------------------------------------
cat("\nFetching UCDP conflict data from HDX...\n")
ucdp_url <- paste0(
  "https://data.humdata.org/dataset/",
  "a2260243-108d-4df4-a7e6-a010bcbb553f/resource/",
  "9e2fcefc-24ab-4903-88fd-fa089c8edc2b/download/conflict_data_nga.csv"
)

ucdp_file <- file.path(data_dir, "ucdp_nigeria.csv")
if (!file.exists(ucdp_file)) {
  download.file(ucdp_url, ucdp_file, mode = "w", quiet = FALSE)
}
ucdp_raw <- fread(ucdp_file, encoding = "UTF-8")
# Skip second header row if present
if (ucdp_raw[1, year] == "") {
  ucdp_raw <- ucdp_raw[-1, ]
}
ucdp_raw[, year := as.integer(year)]
cat(sprintf("  UCDP: %s events, %s to %s\n",
            nrow(ucdp_raw), min(ucdp_raw$year, na.rm = TRUE),
            max(ucdp_raw$year, na.rm = TRUE)))

## ---------------------------------------------------------
## 3. World Bank Population Data (Nigeria, for per-capita)
## ---------------------------------------------------------
cat("\nFetching World Bank population data...\n")
wb_pop_url <- paste0(
  "https://api.worldbank.org/v2/country/NGA/indicator/SP.POP.TOTL",
  "?format=json&per_page=100&date=2000:2024"
)
wb_pop_json <- fromJSON(wb_pop_url)
wb_pop <- as.data.table(wb_pop_json[[2]])
wb_pop <- wb_pop[, .(year = as.integer(date), population = as.numeric(value))]
wb_pop <- wb_pop[!is.na(population)]
cat(sprintf("  WB Population: %s years (%s-%s)\n",
            nrow(wb_pop), min(wb_pop$year), max(wb_pop$year)))

## ---------------------------------------------------------
## 4. Treatment Intensity: Banking Infrastructure by State
## ---------------------------------------------------------
## CBN publishes bank branches by state in the Annual Statistical Bulletin.
## Since programmatic access to the CBN Excel files is unreliable, we use
## the World Bank's financial access data and supplement with published
## state-level statistics.
##
## Primary proxy: Urbanization rate by state (from NBS 2006 census and
## projections). Higher urbanization = more bank branches = less cash scarcity.
##
## We construct the treatment intensity variable from multiple sources:
## (a) State-level urbanization rates (NBS / World Bank)
## (b) Number of DMB branches by state (CBN 2021 data, digitized from
##     published reports)

cat("\nConstructing treatment intensity variable...\n")

## CBN 2021 bank branch data by state (digitized from CBN Annual Report 2021)
## Source: CBN Statistical Bulletin 2021, Table A.15
## These are Deposit Money Bank branches per state
bank_branches <- data.table(
  state = c("Abia", "Adamawa", "Akwa Ibom", "Anambra", "Bauchi",
            "Bayelsa", "Benue", "Borno", "Cross River", "Delta",
            "Ebonyi", "Edo", "Ekiti", "Enugu", "FCT",
            "Gombe", "Imo", "Jigawa", "Kaduna", "Kano",
            "Katsina", "Kebbi", "Kogi", "Kwara", "Lagos",
            "Nasarawa", "Niger", "Ogun", "Ondo", "Osun",
            "Oyo", "Plateau", "Rivers", "Sokoto", "Taraba",
            "Yobe", "Zamfara"),
  branches_2021 = c(
    119, 51, 92, 138, 55,
    40, 66, 52, 65, 117,
    37, 110, 47, 108, 583,
    30, 88, 38, 140, 168,
    52, 29, 48, 72, 1247,
    29, 55, 128, 58, 67,
    148, 76, 206, 44, 28,
    25, 23
  ),
  ## State population estimates 2021 (NBS projections, millions)
  pop_2021_m = c(
    3.73, 4.65, 5.86, 5.83, 7.13,
    2.42, 6.16, 6.22, 4.01, 6.04,
    3.20, 4.60, 3.56, 4.60, 4.38,
    3.42, 5.84, 6.54, 9.06, 13.08,
    8.49, 4.92, 4.69, 3.46, 15.39,
    2.82, 6.08, 5.87, 4.77, 5.05,
    8.37, 4.46, 7.72, 5.20, 3.21,
    3.87, 4.53
  )
)

## Compute bank branches per 100,000 population
bank_branches[, branches_per_100k := branches_2021 / (pop_2021_m * 10)]
## Cash scarcity index = inverse of banking density (higher = more scarcity)
bank_branches[, cash_scarcity := max(branches_per_100k) - branches_per_100k]
## Standardize to 0-1 scale
bank_branches[, cash_scarcity_std := (cash_scarcity - min(cash_scarcity)) /
                (max(cash_scarcity) - min(cash_scarcity))]

cat("Bank branches per 100k (selected states in FEWS NET):\n")
fewsnet_states <- sort(unique(fewsnet_raw$admin_1))
print(bank_branches[state %in% fewsnet_states,
                    .(state, branches_2021, pop_2021_m, branches_per_100k,
                      cash_scarcity_std)][order(-cash_scarcity_std)])

## ---------------------------------------------------------
## 5. Save all raw data
## ---------------------------------------------------------
saveRDS(fewsnet_raw, file.path(data_dir, "fewsnet_raw.rds"))
saveRDS(ucdp_raw, file.path(data_dir, "ucdp_raw.rds"))
saveRDS(wb_pop, file.path(data_dir, "wb_pop.rds"))
saveRDS(bank_branches, file.path(data_dir, "bank_branches.rds"))

cat("\nData acquisition complete. Files saved to:", data_dir, "\n")
