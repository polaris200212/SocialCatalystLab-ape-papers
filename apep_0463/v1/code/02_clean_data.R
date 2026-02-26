## ============================================================
## 02_clean_data.R — Variable Construction & Panel Building
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
fewsnet_raw <- readRDS(file.path(data_dir, "fewsnet_raw.rds"))
bank_branches <- readRDS(file.path(data_dir, "bank_branches.rds"))
ucdp_raw <- readRDS(file.path(data_dir, "ucdp_raw.rds"))

## ---------------------------------------------------------
## 1. Clean FEWS NET price data
## ---------------------------------------------------------
cat("Cleaning FEWS NET data...\n")

prices <- as.data.table(fewsnet_raw)

## Parse dates
prices[, date := as.Date(period_date)]
prices[, year := year(date)]
prices[, month := month(date)]
prices[, week := floor_date(date, "week")]

## Rename columns for clarity
setnames(prices, "admin_1", "state")
setnames(prices, "value", "price")

## Convert price to numeric
prices[, price := as.numeric(price)]

## Drop rows with missing price or state
prices <- prices[!is.na(price) & price > 0 & state != ""]

## Standardize product names
prices[, product_clean := trimws(product)]

## Select key commodities for analysis
## Focus on staple foods most commonly traded in cash
key_products <- c(
  "Rice (Milled)", "Rice (5% Broken)",
  "Maize (White)", "Maize (Yellow)",
  "Cowpeas (Brown)", "Cowpeas (White)",
  "Gari (White)", "Gari (Yellow)",
  "Millet", "Sorghum (White)", "Sorghum (Red)",
  "Groundnuts (Shelled)",
  "Bread",
  "Gasoline", "Diesel"
)

prices_key <- prices[product_clean %in% key_products]
cat(sprintf("  Key products: %s (of %s total)\n",
            length(key_products), length(unique(prices$product_clean))))
cat(sprintf("  Observations with key products: %s\n", nrow(prices_key)))

## ---------------------------------------------------------
## 2. Construct price indices per state-week-commodity
## ---------------------------------------------------------
## Some states have multiple markets — average across markets within state
state_week_prices <- prices_key[,
  .(
    price_mean = mean(price, na.rm = TRUE),
    price_median = median(price, na.rm = TRUE),
    n_markets = .N
  ),
  by = .(state, week, product_clean, unit)
]

## Log prices
state_week_prices[, log_price := log(price_mean)]

cat(sprintf("  State-week-commodity panel: %s observations\n",
            nrow(state_week_prices)))
cat(sprintf("  States: %s, Weeks: %s\n",
            length(unique(state_week_prices$state)),
            length(unique(state_week_prices$week))))

## ---------------------------------------------------------
## 3. Create aggregate food price index per state-week
## ---------------------------------------------------------
## Simple average of log prices across all commodities (excluding fuel)
food_products <- key_products[!key_products %in% c("Gasoline", "Diesel")]

food_index <- state_week_prices[product_clean %in% food_products,
  .(
    log_food_price_idx = mean(log_price, na.rm = TRUE),
    n_products = .N,
    mean_price = mean(price_mean, na.rm = TRUE)
  ),
  by = .(state, week)
]

cat(sprintf("  Food price index: %s state-week observations\n", nrow(food_index)))

## ---------------------------------------------------------
## 4. Define treatment period and merge treatment intensity
## ---------------------------------------------------------
## Key dates:
## - Oct 26, 2022: CBN announces redesign
## - Jan 31, 2023: Old notes deadline
## - Feb 10, 2023: Extended deadline
## - Feb 25, 2023: Presidential election
## - Mar 3, 2023: Supreme Court restores old notes
## - Post-March: Gradual normalization

## Define treatment windows
food_index[, crisis_acute := as.integer(week >= as.Date("2023-01-30") &
                                         week <= as.Date("2023-03-06"))]
food_index[, crisis_broad := as.integer(week >= as.Date("2023-01-01") &
                                         week <= as.Date("2023-06-30"))]
food_index[, post_announce := as.integer(week >= as.Date("2022-10-24"))]
food_index[, post_deadline := as.integer(week >= as.Date("2023-01-30"))]

## Event time (weeks relative to deadline = Jan 30, 2023)
food_index[, event_week := as.integer(difftime(week, as.Date("2023-01-30"),
                                                units = "weeks"))]

## Merge treatment intensity
food_index <- merge(
  food_index,
  bank_branches[, .(state, branches_per_100k, cash_scarcity_std,
                     branches_2021, pop_2021_m)],
  by = "state",
  all.x = TRUE
)

## Create state numeric ID for FE
food_index[, state_id := as.integer(factor(state))]

## Year-month for coarser analysis
food_index[, year_month := floor_date(week, "month")]

cat(sprintf("  Matched to treatment intensity: %s of %s rows\n",
            sum(!is.na(food_index$cash_scarcity_std)), nrow(food_index)))

## ---------------------------------------------------------
## 5. Construct conflict control variable
## ---------------------------------------------------------
cat("Constructing conflict controls...\n")

## Aggregate UCDP events to state-month
ucdp <- as.data.table(ucdp_raw)
## First row is a metadata header (#date+start etc.) — remove it
ucdp <- ucdp[!grepl("^#", date_start)]
## Parse dates (format: "2009-06-09 00:00:00.000")
ucdp[, date_start := as.Date(substr(date_start, 1, 10))]
ucdp[, year_month := floor_date(date_start, "month")]

## Clean state names to match FEWS NET
ucdp[, state := gsub(" state$", "", adm_1)]
ucdp[, state := gsub(" territory$", "", state)]
ucdp[, state := trimws(state)]

## Map to FEWS NET state names
state_map <- c(
  "Federal Capital" = "FCT",
  "Abuja" = "FCT"
)
ucdp[, state := ifelse(state %in% names(state_map), state_map[state], state)]

## Count events per state-month
conflict_monthly <- ucdp[state %in% unique(food_index$state),
  .(
    n_conflict_events = .N,
    n_fatalities = sum(as.numeric(best), na.rm = TRUE)
  ),
  by = .(state, year_month)
]

## Merge conflict data with food index
food_index <- merge(
  food_index,
  conflict_monthly,
  by = c("state", "year_month"),
  all.x = TRUE
)
food_index[is.na(n_conflict_events), n_conflict_events := 0]
food_index[is.na(n_fatalities), n_fatalities := 0]

## ---------------------------------------------------------
## 6. Restrict to analysis sample
## ---------------------------------------------------------
## Use 2019-2024 for main analysis (5 years around the crisis)
analysis <- food_index[week >= as.Date("2019-01-01") &
                        week <= as.Date("2024-06-30")]

## Balanced panel check
state_week_counts <- analysis[, .N, by = state]
cat("\nObservations per state:\n")
print(state_week_counts[order(-N)])

## Extended sample for long pre-trends (2010-2024)
analysis_extended <- food_index[week >= as.Date("2010-01-01") &
                                 week <= as.Date("2024-06-30")]

## ---------------------------------------------------------
## 7. Save analysis datasets
## ---------------------------------------------------------
saveRDS(state_week_prices, file.path(data_dir, "state_week_prices.rds"))
saveRDS(food_index, file.path(data_dir, "food_index_full.rds"))
saveRDS(analysis, file.path(data_dir, "analysis.rds"))
saveRDS(analysis_extended, file.path(data_dir, "analysis_extended.rds"))

cat("\nCleaning complete. Analysis sample:\n")
cat(sprintf("  States: %s\n", length(unique(analysis$state))))
cat(sprintf("  Weeks: %s to %s\n", min(analysis$week), max(analysis$week)))
cat(sprintf("  Observations: %s\n", nrow(analysis)))
cat(sprintf("  Mean cash scarcity (std): %.3f (sd: %.3f)\n",
            mean(analysis$cash_scarcity_std, na.rm = TRUE),
            sd(analysis$cash_scarcity_std, na.rm = TRUE)))
