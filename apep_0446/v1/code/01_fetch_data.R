## ─── 01_fetch_data.R ───────────────────────────────────────────
## Fetch monthly mandi-level price data from CEDA Ashoka AgMarkNet API
## OPTIMIZED: Focused fetch — key commodities, sampled districts
## ────────────────────────────────────────────────────────────────
source("00_packages.R")

CEDA_BASE <- "https://agmarknet.ceda.ashoka.edu.in/api"
CEDA_HEADERS <- c(
  "Content-Type"  = "application/json",
  "Origin"        = "https://agmarknet.ceda.ashoka.edu.in",
  "Referer"       = "https://agmarknet.ceda.ashoka.edu.in/"
)

## ─── Step 1: Get metadata ──────────────────────────────────────
cat("── Fetching CEDA metadata ──\n")

states_dt <- as.data.table(
  fromJSON(content(GET(paste0(CEDA_BASE, "/states"),
                       add_headers(.headers = CEDA_HEADERS)),
                   "text", encoding = "UTF-8"))$data)
setnames(states_dt, c("census_state_id", "census_state_name"),
         c("state_id", "state_name"))
cat(sprintf("  States: %d\n", nrow(states_dt)))

comm_dt <- as.data.table(
  fromJSON(content(GET(paste0(CEDA_BASE, "/commodities"),
                       add_headers(.headers = CEDA_HEADERS)),
                   "text", encoding = "UTF-8"))$data)
setnames(comm_dt, "commodity_disp_name", "commodity_name")
cat(sprintf("  Commodities: %d\n", nrow(comm_dt)))

## Target commodities (verified IDs)
targets <- c("Onion" = 23, "Tomato" = 78, "Wheat" = 1, "Soyabean" = 13)

for (nm in names(targets)) {
  match <- comm_dt[commodity_id == targets[nm]]
  if (nrow(match) > 0) {
    cat(sprintf("  ✓ %s → ID %d ('%s')\n", nm, targets[nm], match$commodity_name[1]))
  }
}

## ─── Step 2: Get districts (sampled) ─────────────────────────────
cat("\n── Fetching districts ──\n")

## Focus on major agricultural states
priority_states <- c(
  ## Early e-NAM (Phase 1A, Apr 2016) — 9 states
  "Uttar Pradesh", "Gujarat", "Maharashtra", "Madhya Pradesh",
  "Telangana", "Haryana", "Rajasthan", "Himachal Pradesh", "Jharkhand",
  ## Phase 1B (Nov 2016) — 2 states
  "Andhra Pradesh", "Tamil Nadu",
  ## Phase 1C (Mar 2017) — 4 states
  "Punjab", "Chhattisgarh", "Uttarakhand", "West Bengal",
  ## Phase 1D (Mar 2018) — 3 states
  "Odisha", "Karnataka", "Kerala",
  ## Never-treated controls
  "Bihar", "Assam"
)

all_dists <- list()
for (i in seq_len(nrow(states_dt))) {
  if (!(states_dt$state_name[i] %in% priority_states)) next
  sid <- states_dt$state_id[i]
  resp <- GET(paste0(CEDA_BASE, "/districts?state_id=", sid),
              add_headers(.headers = CEDA_HEADERS))
  dd <- fromJSON(content(resp, "text", encoding = "UTF-8"))$data
  if (!is.null(dd) && nrow(dd) > 0) {
    dd <- as.data.table(dd)
    setnames(dd, c("census_district_id", "census_district_name"),
             c("district_id", "district_name"), skip_absent = TRUE)
    dd$state_id <- sid
    dd$state_name <- states_dt$state_name[i]
    all_dists[[length(all_dists) + 1]] <- dd
  }
  Sys.sleep(0.02)
}
districts_dt <- rbindlist(all_dists, fill = TRUE)
cat(sprintf("  Total districts available: %d\n", nrow(districts_dt)))

## Sample up to 6 districts per state for tractability
## This gives us ~120 districts × 4 commodities = ~480 API calls
set.seed(42)
sampled <- districts_dt[, {
  n <- min(.N, 6)
  .SD[sample(.N, n)]
}, by = state_name]
cat(sprintf("  Sampled districts: %d (up to 6/state)\n", nrow(sampled)))

fwrite(states_dt, file.path(data_dir, "ceda_states.csv"))
fwrite(districts_dt, file.path(data_dir, "ceda_districts.csv"))
fwrite(comm_dt, file.path(data_dir, "ceda_commodities.csv"))

## ─── Step 3: Fetch price data ──────────────────────────────────
cat("\n── Fetching price data ──\n")

fetch_prices <- function(sid, cid, did) {
  body <- toJSON(list(
    state_id = sid, commodity_id = cid, district_id = did,
    calculation_type = "monthly", start_date = "2007-01-01", end_date = "2025-12-31",
    chart_type = "datadownload"
  ), auto_unbox = TRUE)

  resp <- tryCatch(
    POST(paste0(CEDA_BASE, "/prices"),
         add_headers(.headers = CEDA_HEADERS),
         body = body, encode = "raw", timeout(30)),
    error = function(e) NULL)

  if (is.null(resp) || status_code(resp) != 200) return(NULL)
  txt <- content(resp, "text", encoding = "UTF-8")
  if (nchar(txt) < 20) return(NULL)

  tryCatch({
    dt <- as.data.table(fromJSON(txt)$data)
    if (nrow(dt) > 0) dt else NULL
  }, error = function(e) NULL)
}

total_calls <- nrow(sampled) * length(targets)
cat(sprintf("  Expected API calls: %d\n", total_calls))

all_prices <- list()
total_rows <- 0
api_calls <- 0
t0 <- Sys.time()

for (comm_name in names(targets)) {
  cid <- targets[comm_name]
  cat(sprintf("\n  ── %s (ID: %d) ──\n", comm_name, cid))

  for (j in seq_len(nrow(sampled))) {
    sid <- sampled$state_id[j]
    did <- sampled$district_id[j]

    prices <- fetch_prices(sid, cid, did)
    api_calls <- api_calls + 1

    if (!is.null(prices) && nrow(prices) > 0) {
      prices$commodity_query <- comm_name
      all_prices[[length(all_prices) + 1]] <- prices
      total_rows <- total_rows + nrow(prices)
    }

    if (api_calls %% 50 == 0) {
      elapsed <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
      eta <- elapsed / api_calls * (total_calls - api_calls)
      cat(sprintf("    Calls: %d/%d | Rows: %s | ETA: %.0f min\n",
                  api_calls, total_calls, format(total_rows, big.mark = ","),
                  eta))
    }
    Sys.sleep(0.01)
  }
}

cat(sprintf("\n── Price fetching done: %d calls, %s rows, %.1f min ──\n",
            api_calls, format(total_rows, big.mark = ","),
            as.numeric(difftime(Sys.time(), t0, units = "mins"))))

price_panel <- rbindlist(all_prices, fill = TRUE)
fwrite(price_panel, file.path(data_dir, "ceda_raw_prices.csv"))
cat(sprintf("✓ Saved ceda_raw_prices.csv (%s rows)\n",
            format(nrow(price_panel), big.mark = ",")))

## ─── Step 4: e-NAM treatment mapping ───────────────────────────
cat("\n── Creating state treatment mapping ──\n")

state_treatment <- data.table(
  state_name = c(
    "Uttar Pradesh", "Gujarat", "Maharashtra", "Madhya Pradesh",
    "Telangana", "Haryana", "Rajasthan", "Himachal Pradesh",
    "Jharkhand",
    "Andhra Pradesh", "Tamil Nadu",
    "Punjab", "Chhattisgarh", "Uttarakhand", "West Bengal",
    "Odisha", "Karnataka", "Kerala"
  ),
  enam_first_date = as.Date(c(
    rep("2016-04-14", 9),
    rep("2016-11-01", 2),
    rep("2017-03-01", 4),
    rep("2018-03-01", 3)
  )),
  enam_phase = c(
    rep("1A", 9), rep("1B", 2), rep("1C", 4), rep("1D", 3)
  ),
  enam_mandis_phase1 = c(
    100, 79, 60, 58, 47, 54, 25, 19, 19,
    22, 23, 19, 14, 16, 17, 10, 2, NA
  )
)

fwrite(state_treatment, file.path(data_dir, "state_enam_treatment.csv"))

cat(sprintf("\n══════════════════════════════════════════════════════\n"))
cat(sprintf("  FETCH SUMMARY\n"))
cat(sprintf("  Price rows:     %s\n", format(nrow(price_panel), big.mark = ",")))
cat(sprintf("  Unique mandis:  %d\n", uniqueN(price_panel$market_id)))
cat(sprintf("  States:         %d\n", uniqueN(price_panel$state_name)))
cat(sprintf("  Date range:     %s to %s\n", min(price_panel$t), max(price_panel$t)))
cat(sprintf("══════════════════════════════════════════════════════\n"))
