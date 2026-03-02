## 01_fetch_data.R — Data acquisition from Chronicling America + IPUMS
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

# =============================================================================
# PART A: Workers' Compensation Adoption Dates
# Source: Fishback & Kantor (1998, 2000)
# =============================================================================

wc_dates <- data.table(
  state_name = c(
    "Wisconsin", "California", "Illinois", "Kansas", "Massachusetts",
    "New Hampshire", "New Jersey", "Ohio", "Washington",
    "Maryland", "Michigan", "Rhode Island",
    "Arizona", "Connecticut", "Iowa", "Minnesota", "Nebraska", "Nevada",
    "New York", "Oregon", "Texas", "West Virginia",
    "Louisiana", "Kentucky",
    "Colorado", "Indiana", "Maine", "Montana", "Oklahoma", "Pennsylvania",
    "Vermont", "Wyoming",
    "Delaware", "Idaho", "New Mexico", "South Dakota", "Utah",
    "Virginia",
    "Alabama", "Missouri", "North Dakota", "Tennessee",
    "Georgia",
    "North Carolina", "Florida", "South Carolina", "Arkansas", "Mississippi"
  ),
  adoption_year = c(
    rep(1911, 9),
    rep(1912, 3),
    rep(1913, 10),
    rep(1914, 2),
    rep(1915, 8),
    rep(1917, 5),
    1918,
    rep(1919, 4),
    1920,
    1929, 1935, 1935, 1939, 1948
  )
)

# Add FIPS codes
state_fips <- data.table(
  state_name = c(state.name, "District of Columbia"),
  statefip = c(
    1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
    36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56
  )
)

wc_dates <- merge(wc_dates, state_fips, by = "state_name", all.x = TRUE)

# For newspaper panel: define "never treated" as adoption_year > 1920
wc_dates[, first_treat := ifelse(adoption_year <= 1920, adoption_year, 0)]

fwrite(wc_dates, file.path(DATA_DIR, "workers_comp_dates.csv"))
cat("Workers' comp dates saved:", nrow(wc_dates), "states\n")

# =============================================================================
# PART B: Chronicling America Newspaper Data
# Source: Library of Congress API (loc.gov)
# =============================================================================

# States with adequate newspaper coverage in Chronicling America
# (Verified via API: 18+ states with 1000+ pages for accident terms)
target_states <- c(
  "alabama", "arizona", "california", "colorado", "connecticut",
  "georgia", "idaho", "illinois", "indiana", "iowa",
  "kansas", "kentucky", "louisiana", "maine", "maryland",
  "massachusetts", "michigan", "minnesota", "mississippi", "missouri",
  "montana", "nebraska", "nevada", "new york", "north carolina",
  "north dakota", "ohio", "oklahoma", "oregon", "pennsylvania",
  "south carolina", "south dakota", "tennessee", "texas",
  "utah", "vermont", "virginia", "washington", "west virginia",
  "wisconsin", "wyoming"
)

# Search terms for workplace accidents
accident_terms <- c(
  "industrial+accident",
  "factory+explosion",
  "mine+disaster",
  "killed+in+mine",
  "workplace+death"
)

# Function to query Chronicling America
query_ca <- function(term, state, year, max_retries = 3) {
  url <- paste0(
    "https://www.loc.gov/collections/chronicling-america/?fo=json",
    "&q=", term,
    "&fa=location_state:", gsub(" ", "+", state),
    "&dates=", year, "/", year,
    "&dl=page",
    "&per_page=1"
  )

  for (attempt in 1:max_retries) {
    tryCatch({
      Sys.sleep(0.5)  # Rate limiting
      resp <- GET(url, timeout(30))
      if (status_code(resp) == 200) {
        json <- content(resp, as = "parsed")
        total <- json$pagination$of %||% 0
        return(as.integer(total))
      }
      Sys.sleep(2)
    }, error = function(e) {
      if (attempt == max_retries) return(NA_integer_)
      Sys.sleep(5)
    })
  }
  return(NA_integer_)
}

# Query total newspaper pages per state-year (for normalization)
query_total_pages <- function(state, year, max_retries = 3) {
  url <- paste0(
    "https://www.loc.gov/collections/chronicling-america/?fo=json",
    "&fa=location_state:", gsub(" ", "+", state),
    "&dates=", year, "/", year,
    "&dl=page",
    "&per_page=1"
  )

  for (attempt in 1:max_retries) {
    tryCatch({
      Sys.sleep(0.5)
      resp <- GET(url, timeout(30))
      if (status_code(resp) == 200) {
        json <- content(resp, as = "parsed")
        return(as.integer(json$pagination$of %||% 0))
      }
      Sys.sleep(2)
    }, error = function(e) {
      if (attempt == max_retries) return(NA_integer_)
      Sys.sleep(5)
    })
  }
  return(NA_integer_)
}

# Collect newspaper data for state-year panel
years <- 1900:1920
cat("Fetching newspaper data for", length(target_states), "states,",
    length(years), "years...\n")

# Check if we already have the data
news_file <- file.path(DATA_DIR, "newspaper_panel.csv")
if (file.exists(news_file)) {
  cat("Newspaper data already exists, loading from file.\n")
  news_panel <- fread(news_file)
} else {
  results <- list()
  i <- 1

  for (st in target_states) {
    cat(sprintf("  State: %s (%d/%d)\n", st, which(target_states == st),
                length(target_states)))

    for (yr in years) {
      # Get total pages for normalization
      total_pages <- query_total_pages(st, yr)

      # Get accident pages for primary term
      accident_pages <- query_ca("industrial+accident", st, yr)

      # Get mine disaster pages
      mine_pages <- query_ca("mine+disaster", st, yr)

      # Get factory explosion pages
      factory_pages <- query_ca("factory+explosion", st, yr)

      results[[i]] <- data.table(
        state_name_lower = st,
        year = yr,
        total_pages = total_pages,
        accident_pages = accident_pages,
        mine_pages = mine_pages,
        factory_pages = factory_pages
      )
      i <- i + 1
    }
  }

  news_panel <- rbindlist(results)

  # Clean state names to title case
  news_panel[, state_name := tools::toTitleCase(state_name_lower)]
  news_panel[state_name == "New York", state_name := "New York"]
  news_panel[state_name == "North Carolina", state_name := "North Carolina"]
  news_panel[state_name == "North Dakota", state_name := "North Dakota"]
  news_panel[state_name == "South Carolina", state_name := "South Carolina"]
  news_panel[state_name == "South Dakota", state_name := "South Dakota"]
  news_panel[state_name == "West Virginia", state_name := "West Virginia"]
  news_panel[state_name == "New Hampshire", state_name := "New Hampshire"]
  news_panel[state_name == "New Jersey", state_name := "New Jersey"]
  news_panel[state_name == "New Mexico", state_name := "New Mexico"]
  news_panel[state_name == "Rhode Island", state_name := "Rhode Island"]

  fwrite(news_panel, news_file)
  cat("Newspaper panel saved:", nrow(news_panel), "observations\n")
}

# =============================================================================
# PART C: Load IPUMS Census Data
# =============================================================================

ipums_file <- file.path(DATA_DIR, "ipums_1910_1920.csv.gz")
if (!file.exists(ipums_file)) {
  stop("IPUMS data file not found. Download from IPUMS API first.")
}

cat("Loading IPUMS data...\n")
ipums <- fread(ipums_file)
cat("IPUMS data loaded:", format(nrow(ipums), big.mark = ","), "observations\n")
cat("  Years:", unique(ipums$YEAR), "\n")
cat("  States:", length(unique(ipums$STATEFIP)), "\n")

# Save summary
ipums_summary <- ipums[, .(n = .N), by = YEAR]
cat("  Observations by year:\n")
print(ipums_summary)

fwrite(ipums_summary, file.path(DATA_DIR, "ipums_summary.csv"))

cat("\n=== Data acquisition complete ===\n")
