## ─── 02_clean_data.R ───────────────────────────────────────────
## Clean price data, merge treatment assignment, construct panel
## ────────────────────────────────────────────────────────────────
source("00_packages.R")

## ─── Load raw data ─────────────────────────────────────────────
cat("── Loading raw data ──\n")
prices <- fread(file.path(data_dir, "ceda_raw_prices.csv"))
state_treat <- fread(file.path(data_dir, "state_enam_treatment.csv"))
cat(sprintf("  Raw prices: %s rows\n", format(nrow(prices), big.mark = ",")))

## ─── Parse dates and identifiers ───────────────────────────────
cat("── Cleaning variables ──\n")

## The 't' column is the date
if ("t" %in% names(prices)) {
  prices[, date := as.Date(t)]
} else if ("date" %in% names(prices)) {
  prices[, date := as.Date(date)]
}

## Create year-month
prices[, ym := floor_date(date, "month")]
prices[, year := year(date)]
prices[, month := month(date)]

## Rename price columns if needed
if ("p_modal" %in% names(prices)) {
  setnames(prices, c("p_modal", "p_min", "p_max"),
           c("modal_price", "min_price", "max_price"), skip_absent = TRUE)
}

## Clean market names
if ("market_name" %in% names(prices)) {
  prices[, mandi_name := trimws(toupper(market_name))]
}
if ("state_name" %in% names(prices)) {
  prices[, state := trimws(state_name)]
}

## Create unique mandi ID
if ("market_id" %in% names(prices)) {
  prices[, mandi_id := market_id]
} else {
  prices[, mandi_id := as.integer(as.factor(paste(state, mandi_name)))]
}

## Commodity standardization
if ("cmdty" %in% names(prices)) {
  prices[, commodity := trimws(cmdty)]
} else if ("commodity_name" %in% names(prices)) {
  prices[, commodity := trimws(commodity_name)]
}

## ─── Remove outliers and missing ───────────────────────────────
cat("── Removing outliers ──\n")
n_before <- nrow(prices)

## Drop missing prices
prices <- prices[!is.na(modal_price) & modal_price > 0]

## Drop extreme outliers (>10x or <0.1x median within commodity-state-year)
prices[, med_price := median(modal_price, na.rm = TRUE),
       by = .(commodity, state, year)]
prices <- prices[modal_price > med_price * 0.1 & modal_price < med_price * 10]
prices[, med_price := NULL]

cat(sprintf("  Dropped %s outlier/missing rows (%d%% of data)\n",
            format(n_before - nrow(prices), big.mark = ","),
            round(100 * (n_before - nrow(prices)) / n_before)))

## ─── Aggregate to mandi × commodity × month ────────────────────
cat("── Aggregating to monthly ──\n")
monthly <- prices[, .(
  modal_price = mean(modal_price, na.rm = TRUE),
  min_price   = mean(min_price, na.rm = TRUE),
  max_price   = mean(max_price, na.rm = TRUE),
  price_sd    = sd(modal_price, na.rm = TRUE),
  n_days      = .N
), by = .(mandi_id, mandi_name, state, state_id, district_id,
          district_name, commodity, ym, year, month)]

cat(sprintf("  Monthly panel: %s observations\n",
            format(nrow(monthly), big.mark = ",")))

## ─── Merge treatment assignment ────────────────────────────────
cat("── Merging treatment assignment ──\n")

## Standardize state names for matching
state_treat[, state_upper := trimws(toupper(state_name))]
monthly[, state_upper := trimws(toupper(state))]

## Merge
monthly <- merge(monthly, state_treat[, .(state_upper, enam_first_date, enam_phase)],
                 by = "state_upper", all.x = TRUE)

## Treatment indicator
monthly[, enam_treated := !is.na(enam_first_date)]
monthly[, post_enam := ifelse(enam_treated, as.integer(ym >= enam_first_date), 0L)]

## First treatment year-month for CS-DiD
monthly[, first_treat_ym := fifelse(enam_treated, floor_date(enam_first_date, "month"),
                                     as.Date(NA))]

## Event time (months relative to treatment)
monthly[enam_treated == TRUE,
        event_time := as.integer(difftime(ym, first_treat_ym, units = "days")) %/% 30]

## Numeric time period for did package (months since Jan 2007)
monthly[, time_period := as.integer(difftime(ym, as.Date("2007-01-01"),
                                              units = "days")) %/% 30 + 1]

## Numeric first_treat for did package
monthly[, first_treat_period := fifelse(
  enam_treated,
  as.integer(difftime(first_treat_ym, as.Date("2007-01-01"), units = "days")) %/% 30 + 1,
  0L  # never-treated
)]

## Log price
monthly[, ln_price := log(modal_price)]

## ─── Compute price dispersion (CV) by state × commodity × month ──
cat("── Computing price dispersion ──\n")
dispersion <- monthly[, .(
  cv_price     = sd(modal_price, na.rm = TRUE) / mean(modal_price, na.rm = TRUE),
  iqr_price    = IQR(modal_price, na.rm = TRUE),
  mean_price   = mean(modal_price, na.rm = TRUE),
  n_mandis     = uniqueN(mandi_id),
  pct_enam     = mean(enam_treated, na.rm = TRUE)
), by = .(state, commodity, ym, year, month)]

## Treatment for dispersion: share of mandis in state-commodity that are e-NAM treated
dispersion[, state_upper := trimws(toupper(state))]
dispersion <- merge(dispersion,
                    state_treat[, .(state_upper, enam_first_date)],
                    by = "state_upper", all.x = TRUE)
dispersion[, post_enam := as.integer(!is.na(enam_first_date) & ym >= enam_first_date)]

## ─── Summary statistics ────────────────────────────────────────
cat("\n══════════════════════════════════════════════════════\n")
cat("  PANEL SUMMARY\n")
cat(sprintf("  Mandis:         %d\n", uniqueN(monthly$mandi_id)))
cat(sprintf("  States:         %d\n", uniqueN(monthly$state)))
cat(sprintf("  Commodities:    %d\n", uniqueN(monthly$commodity)))
cat(sprintf("  Time span:      %s to %s\n",
            min(monthly$ym), max(monthly$ym)))
cat(sprintf("  Observations:   %s\n", format(nrow(monthly), big.mark = ",")))
cat(sprintf("  e-NAM mandis:   %d (%d%%)\n",
            uniqueN(monthly[enam_treated == TRUE]$mandi_id),
            round(100 * uniqueN(monthly[enam_treated == TRUE]$mandi_id) /
                    uniqueN(monthly$mandi_id))))
cat(sprintf("  Never-treated:  %d\n",
            uniqueN(monthly[enam_treated == FALSE]$mandi_id)))
cat("══════════════════════════════════════════════════════\n")

## ─── Save clean data ───────────────────────────────────────────
fwrite(monthly, file.path(data_dir, "monthly_panel.csv"))
fwrite(dispersion, file.path(data_dir, "dispersion_panel.csv"))
cat("✓ Saved monthly_panel.csv and dispersion_panel.csv\n")
