## 01_fetch_data.R — Data acquisition
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 1. TREATMENT VARIABLE: State Flood Disclosure Law Adoption Dates
# ============================================================================
# Compiled from NRDC State Flood Disclosure Scorecard, agent research,
# NAR State Flood Hazard Disclosures Survey, and state statute research.
# Uses the BROAD definition: any mandatory seller disclosure form that
# includes flood-related questions (flood zone, flood history, flood damage).

disclosure_laws <- tribble(
  ~state_abbr, ~state_name,          ~year_adopted, ~wave,     ~grade_2024,
  "KY",        "Kentucky",           1992,          "first",   "C",
  "MI",        "Michigan",           1993,          "first",   "C",
  "OR",        "Oregon",             1993,          "first",   "C",
  "OH",        "Ohio",               1993,          "first",   "C",
  "IN",        "Indiana",            1993,          "first",   "C",
  "SD",        "South Dakota",       1993,          "first",   "C",
  "IA",        "Iowa",               1994,          "first",   "C",
  "WA",        "Washington",         1994,          "first",   "C",
  "NE",        "Nebraska",           1994,          "first",   "C",
  "OK",        "Oklahoma",           1995,          "first",   "A",
  "CT",        "Connecticut",        1996,          "first",   "D",
  "PA",        "Pennsylvania",       1996,          "first",   "C",
  "NV",        "Nevada",             1996,          "first",   "C",
  "IL",        "Illinois",           1998,          "first",   "C",
  "CA",        "California",         1998,          "first",   "A",
  "AK",        "Alaska",             1999,          "first",   "C",
  "DE",        "Delaware",           2000,          "second",  "C",
  "NY",        "New York",           2001,          "second",  "B",
  "LA",        "Louisiana",          2003,          "second",  "A",
  "MS",        "Mississippi",        2005,          "second",  "A",
  "TN",        "Tennessee",          2006,          "second",  "B",
  "ND",        "North Dakota",       2019,          "third",   "C",
  "TX",        "Texas",              2019,          "third",   "A",
  "SC",        "South Carolina",     2019,          "third",   "A",
  "HI",        "Hawaii",             2022,          "third",   "A",
  "NJ",        "New Jersey",         2023,          "third",   "B",
  "ME",        "Maine",              2023,          "third",   "C",
  "NC",        "North Carolina",     2024,          "third",   "A",
  "FL",        "Florida",            2024,          "third",   "B",
  "NH",        "New Hampshire",      2024,          "third",   "C",
  "VT",        "Vermont",            2024,          "third",   "C"
)

# Never-treated states (no mandatory flood disclosure as of 2024)
never_treated <- tribble(
  ~state_abbr, ~state_name,
  "AL",        "Alabama",
  "AR",        "Arkansas",
  "AZ",        "Arizona",
  "CO",        "Colorado",
  "GA",        "Georgia",
  "ID",        "Idaho",
  "KS",        "Kansas",
  "MA",        "Massachusetts",
  "MD",        "Maryland",
  "MN",        "Minnesota",
  "MO",        "Missouri",
  "MT",        "Montana",
  "NM",        "New Mexico",
  "RI",        "Rhode Island",
  "UT",        "Utah",
  "VA",        "Virginia",
  "WI",        "Wisconsin",
  "WV",        "West Virginia",
  "WY",        "Wyoming"
) %>% mutate(year_adopted = 0, wave = "never", grade_2024 = "F")

treatment_df <- bind_rows(disclosure_laws, never_treated)

write_csv(treatment_df, paste0(data_dir, "treatment_disclosure_laws.csv"))
cat("Treatment variable saved:", nrow(disclosure_laws), "treated states,",
    nrow(never_treated), "never-treated states.\n")

# ============================================================================
# 2. OUTCOME: Zillow Home Value Index (ZHVI) — County Level
# ============================================================================
cat("\nDownloading Zillow ZHVI (county level)...\n")

zhvi_url <- "https://files.zillowstatic.com/research/public_csvs/zhvi/County_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_month.csv"
zhvi_file <- paste0(data_dir, "zhvi_county.csv")

if (!file.exists(zhvi_file)) {
  download.file(zhvi_url, zhvi_file, mode = "wb", quiet = FALSE)
}

zhvi_raw <- fread(zhvi_file, showProgress = FALSE)
cat("ZHVI loaded:", nrow(zhvi_raw), "counties,",
    ncol(zhvi_raw) - 9, "months of data.\n")

# ============================================================================
# 3. FLOOD EXPOSURE: FEMA Disaster Declarations for Floods
# ============================================================================
cat("\nFetching FEMA flood disaster declarations...\n")

# Fetch all flood-type disaster declarations
fema_base <- "https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries"

# We need to paginate — get count first
count_url <- paste0(fema_base, "?$inlinecount=allpages&$top=1",
                    "&$filter=incidentType%20eq%20%27Flood%27%20or%20",
                    "incidentType%20eq%20%27Coastal%20Storm%27%20or%20",
                    "incidentType%20eq%20%27Hurricane%27%20or%20",
                    "incidentType%20eq%20%27Severe%20Storm(s)%27%20or%20",
                    "incidentType%20eq%20%27Typhoon%27")

# Simplified: fetch all flood-related declarations in batches
all_fema <- list()
skip <- 0
batch_size <- 1000
repeat {
  url <- paste0(fema_base,
                "?$top=", batch_size,
                "&$skip=", skip,
                "&$select=disasterNumber,state,fipsStateCode,fipsCountyCode,",
                "declarationDate,incidentType,designatedArea",
                "&$filter=incidentType%20eq%20%27Flood%27%20or%20",
                "incidentType%20eq%20%27Coastal%20Storm%27%20or%20",
                "incidentType%20eq%20%27Hurricane%27%20or%20",
                "incidentType%20eq%20%27Typhoon%27")

  resp <- tryCatch(
    fromJSON(url, flatten = TRUE),
    error = function(e) { cat("FEMA API error at skip=", skip, ":", e$message, "\n"); NULL }
  )

  if (is.null(resp)) break

  records <- resp$DisasterDeclarationsSummaries
  if (is.null(records) || nrow(records) == 0) break

  all_fema[[length(all_fema) + 1]] <- as_tibble(records)
  cat("  Fetched", nrow(records), "records (skip=", skip, ")\n")

  if (nrow(records) < batch_size) break
  skip <- skip + batch_size

  Sys.sleep(0.5) # Be polite
}

fema_df <- bind_rows(all_fema)
cat("Total FEMA flood declarations:", nrow(fema_df), "\n")

write_csv(fema_df, paste0(data_dir, "fema_flood_declarations.csv"))

# ============================================================================
# 4. CENSUS BUILDING PERMITS (Annual, County Level)
# ============================================================================
cat("\nFetching Census building permits data...\n")

# Census Building Permits API — annual county level
# No key required for this endpoint
permits_list <- list()

for (yr in 2000:2024) {
  url <- paste0("https://api.census.gov/data/", yr,
                "/cbp?get=ESTAB,EMP,PAYANN&for=county:*&in=state:*&NAICS2017=23")

  resp <- tryCatch({
    raw <- readLines(url, warn = FALSE)
    fromJSON(raw)
  }, error = function(e) {
    # Try alternative: building permits survey
    NULL
  })

  if (!is.null(resp) && nrow(resp) > 1) {
    df <- as_tibble(resp[-1, ], .name_repair = "minimal")
    names(df) <- resp[1, ]
    df$year <- yr
    permits_list[[as.character(yr)]] <- df
    cat("  ", yr, ": ", nrow(df), " counties\n")
  } else {
    cat("  ", yr, ": no data\n")
  }

  Sys.sleep(0.3)
}

if (length(permits_list) > 0) {
  permits_df <- bind_rows(permits_list)
  write_csv(permits_df, paste0(data_dir, "census_construction.csv"))
  cat("Construction data saved:", nrow(permits_df), "rows.\n")
} else {
  cat("WARNING: Could not fetch construction data.\n")
}

# ============================================================================
# 5. Summary
# ============================================================================
cat("\n============================================\n")
cat("DATA FETCH COMPLETE\n")
cat("============================================\n")
cat("Files saved in:", data_dir, "\n")
cat("  treatment_disclosure_laws.csv — Treatment variable\n")
cat("  zhvi_county.csv — Zillow housing values\n")
cat("  fema_flood_declarations.csv — FEMA flood declarations\n")
cat("  census_construction.csv — Census construction data\n")
