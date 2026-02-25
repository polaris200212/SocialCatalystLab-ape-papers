# ============================================================================
# 01_fetch_data.R — Fetch CPI data from MoSPI eSankhyiki API
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

# ── MoSPI CPI API ─────────────────────────────────────────────────────────
base_url <- "https://api.mospi.gov.in/api/cpi/getCPIIndex"

# Fetch all state × group data for a given year and sector
fetch_cpi_year <- function(year, sector_code = 3, base_year = "2012",
                           series = "Current", page_size = 200) {
  all_data <- list()
  page <- 1
  repeat {
    url <- paste0(
      base_url,
      "?base_year=", base_year,
      "&series=", series,
      "&sector_code=", sector_code,
      "&year=", year,
      "&limit=", page_size,
      "&page=", page
    )
    resp <- GET(url)
    if (status_code(resp) != 200) {
      warning("API error for year ", year, " page ", page, ": status ", status_code(resp))
      break
    }
    json <- content(resp, as = "text", encoding = "UTF-8")
    parsed <- fromJSON(json, flatten = TRUE)
    if (length(parsed$data) == 0) break
    all_data[[page]] <- as.data.table(parsed$data)
    total_pages <- parsed$meta_data$totalPages
    if (page >= total_pages) break
    page <- page + 1
    Sys.sleep(0.3)  # Polite rate limiting
  }
  if (length(all_data) == 0) return(NULL)
  rbindlist(all_data, fill = TRUE)
}

# ── Fetch all years (2013-2025) for Combined sector ──────────────────────
cat("Fetching CPI data from MoSPI API...\n")
years <- 2013:2025
cpi_list <- list()

for (yr in years) {
  cat("  Fetching year", yr, "... ")
  dt <- fetch_cpi_year(yr, sector_code = 3)  # 3 = Combined
  if (!is.null(dt) && nrow(dt) > 0) {
    cpi_list[[as.character(yr)]] <- dt
    cat(nrow(dt), "records\n")
  } else {
    cat("no data\n")
  }
}

cpi_combined <- rbindlist(cpi_list, fill = TRUE)
cat("Total Combined records:", nrow(cpi_combined), "\n")

# ── Also fetch Rural and Urban for heterogeneity analysis ────────────────
cat("\nFetching Rural CPI...\n")
cpi_rural_list <- list()
for (yr in years) {
  cat("  Year", yr, "... ")
  dt <- fetch_cpi_year(yr, sector_code = 1)  # 1 = Rural
  if (!is.null(dt) && nrow(dt) > 0) {
    cpi_rural_list[[as.character(yr)]] <- dt
    cat(nrow(dt), "records\n")
  } else {
    cat("no data\n")
  }
}
cpi_rural <- rbindlist(cpi_rural_list, fill = TRUE)

cat("\nFetching Urban CPI...\n")
cpi_urban_list <- list()
for (yr in years) {
  cat("  Year", yr, "... ")
  dt <- fetch_cpi_year(yr, sector_code = 2)  # 2 = Urban
  if (!is.null(dt) && nrow(dt) > 0) {
    cpi_urban_list[[as.character(yr)]] <- dt
    cat(nrow(dt), "records\n")
  } else {
    cat("no data\n")
  }
}
cpi_urban <- rbindlist(cpi_urban_list, fill = TRUE)

# ── Save raw data ─────────────────────────────────────────────────────────
fwrite(cpi_combined, "../data/cpi_combined_raw.csv")
fwrite(cpi_rural, "../data/cpi_rural_raw.csv")
fwrite(cpi_urban, "../data/cpi_urban_raw.csv")

cat("\nData saved to data/ directory.\n")
cat("Combined:", nrow(cpi_combined), "records\n")
cat("Rural:", nrow(cpi_rural), "records\n")
cat("Urban:", nrow(cpi_urban), "records\n")
