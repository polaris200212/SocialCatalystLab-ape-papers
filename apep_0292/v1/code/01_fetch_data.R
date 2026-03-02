## 01_fetch_data.R — Fetch NYC Open Data (PLUTO, LL84, DOF Sales, DOB Permits)
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

# ============================================================
# Helper: paginated Socrata fetch
# ============================================================
fetch_socrata <- function(base_url, query_params = list(), max_rows = 500000) {
  all_rows <- list()
  offset <- 0
  page_size <- 50000

  repeat {
    params <- c(query_params, list(
      `$limit` = page_size,
      `$offset` = offset
    ))

    url <- modify_url(base_url, query = params)
    cat("  Fetching offset", offset, "...\n")

    resp <- GET(url, timeout(180))
    if (status_code(resp) != 200) {
      warning("HTTP ", status_code(resp), " at offset ", offset)
      break
    }

    page <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE)
    if (length(page) == 0 || nrow(page) == 0) break

    all_rows[[length(all_rows) + 1]] <- page
    offset <- offset + nrow(page)
    cat("    Got", nrow(page), "rows (total:", offset, ")\n")

    if (nrow(page) < page_size || offset >= max_rows) break
    Sys.sleep(1)
  }

  if (length(all_rows) == 0) return(tibble())
  bind_rows(all_rows)
}

# ============================================================
# 1. NYC PLUTO — All buildings (property characteristics)
# ============================================================
cat("\n=== Fetching NYC PLUTO data ===\n")

pluto_url <- "https://data.cityofnewyork.us/resource/64uk-42ks.json"

# Use correct column names (verified from API response)
pluto_fields <- paste(
  "bbl", "borough", "block", "lot", "zipcode",
  "bldgarea", "lotarea", "numfloors", "unitsres", "unitstotal",
  "assessland", "assesstot", "yearbuilt", "yearalter1", "yearalter2",
  "landuse", "bldgclass", "numbldgs",
  "cd", "ct2010", "cb2010",
  sep = ","
)

pluto_raw <- fetch_socrata(
  pluto_url,
  query_params = list(`$select` = pluto_fields),
  max_rows = 900000
)

cat("PLUTO rows fetched:", nrow(pluto_raw), "\n")
saveRDS(pluto_raw, file.path(data_dir, "pluto_raw.rds"))

# ============================================================
# 2. NYC LL84 Benchmarking — Energy data for buildings >25K sq ft
# ============================================================
cat("\n=== Fetching NYC LL84 benchmarking data ===\n")

ll84_url <- "https://data.cityofnewyork.us/resource/5zyy-y8am.json"

# Correct column names from API
ll84_fields <- paste(
  "property_id", "property_name", "nyc_borough_block_and_lot",
  "property_gfa_calculated", "property_gfa_self_reported",
  "site_eui_kbtu_ft", "source_eui_kbtu_ft",
  "energy_star_score", "national_median_energy_star",
  "site_energy_use_kbtu", "year_ending", "report_year",
  "year_built", "number_of_buildings",
  "direct_ghg_emissions_metric", "indirect_location_based_ghg",
  "total_location_based_ghg", "borough",
  sep = ","
)

ll84_raw <- fetch_socrata(
  ll84_url,
  query_params = list(`$select` = ll84_fields),
  max_rows = 100000
)

cat("LL84 (2023+ dataset) rows:", nrow(ll84_raw), "\n")

# Also fetch the 2022 dataset (calendar year 2021)
ll84_2022_url <- "https://data.cityofnewyork.us/resource/7x5e-2fxh.json"

ll84_2022_fields <- paste(
  "property_id", "property_name", "nyc_borough_block_and_lot",
  "property_gfa_calculated", "property_gfa_self_reported",
  "site_eui_kbtu_ft", "source_eui_kbtu_ft",
  "energy_star_score", "national_median_energy_star",
  "site_energy_use_kbtu", "year_ending", "report_year",
  "year_built",
  "direct_ghg_emissions_metric",
  sep = ","
)

ll84_2022_raw <- fetch_socrata(
  ll84_2022_url,
  query_params = list(`$select` = ll84_2022_fields),
  max_rows = 100000
)
cat("LL84 (2022 dataset) rows:", nrow(ll84_2022_raw), "\n")

# Also fetch the 2021 dataset (calendar year 2020)
ll84_2021_url <- "https://data.cityofnewyork.us/resource/usc3-8zwd.json"

ll84_2021_raw <- fetch_socrata(
  ll84_2021_url,
  query_params = list(`$select` = ll84_2022_fields),
  max_rows = 100000
)
cat("LL84 (2021 dataset) rows:", nrow(ll84_2021_raw), "\n")

# Combine all LL84 years
ll84_combined <- bind_rows(
  ll84_raw %>% mutate(dataset = "2023plus"),
  ll84_2022_raw %>% mutate(dataset = "2022"),
  ll84_2021_raw %>% mutate(dataset = "2021")
)

saveRDS(ll84_combined, file.path(data_dir, "ll84_raw.rds"))

# ============================================================
# 3. NYC DOF Rolling Sales — Property transactions
# ============================================================
cat("\n=== Fetching NYC DOF Rolling Sales ===\n")

# NYC citywide annualized sales
sales_url <- "https://data.cityofnewyork.us/resource/usep-8jbt.json"

sales_raw <- fetch_socrata(
  sales_url,
  query_params = list(),
  max_rows = 500000
)

cat("DOF sales rows:", nrow(sales_raw), "\n")

if (nrow(sales_raw) > 0) {
  saveRDS(sales_raw, file.path(data_dir, "sales_raw.rds"))
}

# ============================================================
# 4. NYC DOB Job Filings — Building permits (investment proxy)
# ============================================================
cat("\n=== Fetching NYC DOB Job Filings ===\n")

# DOB job applications filed
permits_url <- "https://data.cityofnewyork.us/resource/ic3t-wcy2.json"

permits_raw <- fetch_socrata(
  permits_url,
  query_params = list(
    `$where` = "pre__filing_date > '2014-01-01'"
  ),
  max_rows = 500000
)

cat("DOB permit rows:", nrow(permits_raw), "\n")

if (nrow(permits_raw) > 0) {
  saveRDS(permits_raw, file.path(data_dir, "permits_raw.rds"))
} else {
  # Try alternative DOB endpoint
  cat("Trying alternative DOB endpoint...\n")
  permits_url2 <- "https://data.cityofnewyork.us/resource/rvhx-8trz.json"
  permits_raw <- fetch_socrata(
    permits_url2,
    query_params = list(`$limit` = 200000),
    max_rows = 200000
  )
  cat("Alt DOB permit rows:", nrow(permits_raw), "\n")
  if (nrow(permits_raw) > 0) {
    saveRDS(permits_raw, file.path(data_dir, "permits_raw.rds"))
  }
}

# ============================================================
# Summary
# ============================================================
cat("\n=== Data Fetch Summary ===\n")
cat("PLUTO:", nrow(pluto_raw), "rows\n")
cat("LL84:", nrow(ll84_combined), "rows\n")
cat("Sales:", nrow(sales_raw), "rows\n")
cat("Permits:", nrow(permits_raw), "rows\n")
cat("All data saved to:", data_dir, "\n")
