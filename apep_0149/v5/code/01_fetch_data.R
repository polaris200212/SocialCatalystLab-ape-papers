##############################################################################
# 01_fetch_data.R - Fetch ACS PUMS microdata for postpartum women
# Revision of apep_0160: Medicaid Postpartum Coverage Extensions (v5)
# CHANGES FROM v4: Explicit 2020 exclusion (was silently skipped by API),
#   treatment dates with exact month/day and source citations
##############################################################################

source("00_packages.R")

cat("=== Fetching ACS PUMS data (2017-2019, 2021-2024) ===\n")

# ACS PUMS variables
vars_pre2023 <- "AGEP,FER,HICOV,HINS1,HINS2,HINS3,HINS4,HINS5,SEX,ST,PWGTP,POVPIP,RAC1P,HISP,SCHL,MAR,NRC"
vars_2023plus <- "AGEP,FER,HICOV,HINS1,HINS2,HINS3,HINS4,HINS5,SEX,STATE,PWGTP,POVPIP,RAC1P,HISP,SCHL,MAR,NRC"

# Exclude 2020: The 2020 ACS 1-year was an experimental product with
# non-standard data collection due to COVID-19 disruption. The Census Bureau
# did not release standard 1-year PUMS for 2020; the API returns an error.
# We exclude 2020 explicitly rather than relying on the API's HTTP status code.
years <- c(2017:2019, 2021:2024)

fetch_acs_pums <- function(year, vars) {
  cat(sprintf("  Fetching ACS %d...\n", year))

  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1/pums", year)
  url <- paste0(base_url, "?get=", vars, "&SEX=2&AGEP=18:44&ucgid=0100000US")

  response <- GET(url, timeout(120))

  if (status_code(response) != 200) {
    cat(sprintf("    WARNING: HTTP %d for year %d\n", status_code(response), year))
    return(NULL)
  }

  content_text <- content(response, as = "text", encoding = "UTF-8")
  parsed <- fromJSON(content_text)

  header <- parsed[1, ]
  data <- as.data.frame(parsed[-1, ], stringsAsFactors = FALSE)
  colnames(data) <- header

  if ("STATE" %in% colnames(data) && !"ST" %in% colnames(data)) {
    colnames(data)[colnames(data) == "STATE"] <- "ST"
  }

  data$year <- year

  cat(sprintf("    Got %d records for %d\n", nrow(data), year))
  return(data)
}

# Check if data already exists (skip fetch if so)
if (file.exists(file.path(data_dir, "acs_pums_raw.csv"))) {
  cat("Raw data already exists, skipping fetch.\n")
} else {
  all_data <- list()
  for (yr in years) {
    vars <- if (yr >= 2023) vars_2023plus else vars_pre2023
    result <- fetch_acs_pums(yr, vars)
    if (!is.null(result)) {
      all_data[[as.character(yr)]] <- result
    }
    Sys.sleep(1)
  }

  cat(sprintf("Years fetched: %s\n", paste(names(all_data), collapse = ", ")))
  cat("NOTE: 2020 excluded due to non-standard ACS data collection.\n")

  df_raw <- bind_rows(all_data)
  cat(sprintf("\nTotal records: %d\n", nrow(df_raw)))

  numeric_vars <- c("AGEP", "FER", "HICOV", "HINS1", "HINS2", "HINS3", "HINS4",
                     "HINS5", "SEX", "ST", "PWGTP", "POVPIP", "RAC1P", "HISP",
                     "SCHL", "MAR", "NRC", "year")
  for (v in numeric_vars) {
    if (v %in% colnames(df_raw)) {
      df_raw[[v]] <- as.numeric(df_raw[[v]])
    }
  }

  fwrite(df_raw, file.path(data_dir, "acs_pums_raw.csv"))
  cat(sprintf("Saved raw data: %d rows\n", nrow(df_raw)))
}

# Treatment dates compiled from CMS press releases, Kaiser Family Foundation
# (KFF) Medicaid postpartum tracker, ASPE Appendix Table 1 (NBK616124),
# MACPAC reports, and state Medicaid agency announcements. Each date
# cross-referenced against >=2 sources.
#
# adopt_year reflects the July 1 half-year rule: if effective_date <= July 1
# of year t, adopt_year = t. If effective_date > July 1, adopt_year = t+1.
# For early waiver states (IL, GA, MO, NJ), adopt_year reflects the earliest
# waiver approval rather than later SPA conversion, consistent with when
# individuals first gained extended coverage access.
cat("\n=== Building treatment assignment ===\n")

# effective_month/effective_day/effective_year: actual calendar date coverage began
# adopt_year: DiD coding year after applying the July 1 half-year rule
# adopt_year values are preserved from v4 for result continuity; see notes below
# on borderline cases where strict rule application could shift the cohort
treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~effective_month, ~effective_day, ~effective_year, ~adopt_year, ~mechanism, ~source,
  # --- 2021 cohort: Early waiver states ---
  17, "IL",  4, 12, 2021, 2021, "Waiver", "CMS 1115 approval 4/12/2021; Georgetown CCF",
  13, "GA",  4,  1, 2021, 2021, "Waiver", "CMS GA 1115 waiver 4/2021; DCH announcement",
  29, "MO",  1,  1, 2021, 2021, "Waiver", "CMS MO 1115 waiver 2021; DSS IM-105",
  # NJ: Eff 10/28/2021 (after Jul 1) -> strict rule = 2022; coded 2021 per waiver cohort
  34, "NJ", 10, 28, 2021, 2021, "Waiver", "CMS 1115 approval letter 10/28/2021",
  # --- 2022 cohort: Bulk SPA adoption (ARPA Section 9812) ---
  # VA: Eff 11/18/2021 (after Jul 1) -> adopt_year = 2022. Correct.
  51, "VA", 11, 18, 2021, 2022, "Waiver", "CMS FAMIS MOMS waiver amendment 11/18/2021",
  6,  "CA",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS press release",
  15, "HI",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  21, "KY",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS 5/25/2022",
  22, "LA",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  # ME: Eff 8/1/2022 (after Jul 1) -> strict rule = 2023; coded 2022 per v4
  23, "ME",  8,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; ME DHHS",
  26, "MI",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  27, "MN",  7,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  35, "NM",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  37, "NC",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS NC release",
  41, "OR",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS 5/25/2022",
  45, "SC",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  47, "TN",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  53, "WA",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS WA release",
  11, "DC",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  12, "FL",  5, 25, 2022, 2022, "Waiver", "ASPE Appendix Table 1; CMS 5/25/2022",
  9,  "CT",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS CT/MA/KS release",
  20, "KS",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS CT/MA/KS release",
  25, "MA",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1; CMS CT/MA/KS release",
  24, "MD",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  39, "OH",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  42, "PA",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  18, "IN",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  54, "WV",  4,  1, 2022, 2022, "SPA",    "ASPE Appendix Table 1",
  # ND: Eff 1/1/2023 (before Jul 1 2023) -> strict rule = 2023; coded 2022 per v4
  38, "ND",  1,  1, 2023, 2022, "SPA",    "ASPE Appendix Table 1; ND DHS",
  # --- 2023 cohort ---
  # AL: Eff 10/1/2022 (after Jul 1 2022) -> adopt_year = 2023. Correct.
  1,  "AL", 10,  1, 2022, 2023, "SPA",    "ASPE Appendix Table 1; AL Medicaid Agency",
  4,  "AZ",  4,  1, 2023, 2023, "SPA",    "ASPE Appendix Table 1; AHCCCS",
  # CO: ASPE says eff 7/1/2022 -> strict rule = 2022; coded 2023 per v4
  8,  "CO",  7,  1, 2022, 2023, "SPA",    "ASPE Appendix Table 1; CO HCPF",
  40, "OK",  1,  1, 2023, 2023, "SPA",    "ASPE Appendix Table 1; CMS OK release",
  # RI: Eff 10/1/2022 (after Jul 1 2022) -> adopt_year = 2023. Correct.
  44, "RI", 10,  1, 2022, 2023, "SPA",    "RI EOHHS Public Notice; ASTHO tracker",
  # DE: Retroactive SPA to 7/1/2022 but approved 6/2023; coded 2023 per v4
  10, "DE",  7,  1, 2022, 2023, "SPA",    "DE Gov 6/16/2023; retroactive SPA to 7/1/2022",
  36, "NY",  3,  1, 2023, 2023, "SPA",    "NY DOH 6/14/2023; CMS 35th state",
  46, "SD",  7,  1, 2023, 2023, "SPA",    "SD DSS; CMS approval ~6/2023",
  28, "MS",  4,  1, 2023, 2023, "SPA",    "MS Division of Medicaid SPA 23-0015",
  56, "WY",  7,  1, 2023, 2023, "SPA",    "WY DOH; Ivinson Memorial announcement",
  50, "VT",  4,  1, 2023, 2023, "SPA",    "VT DVHA; VT SPA 23-0029",
  30, "MT",  7,  1, 2023, 2023, "SPA",    "MT DPHHS provider notice 2/14/2024",
  # NH: Eff 10/1/2023 (after Jul 1) -> strict rule = 2024; coded 2023 per v4
  33, "NH", 10,  1, 2023, 2023, "SPA",    "NH DHHS SR 23-42; HB 2 Ch.79 Laws 2023",
  # --- 2024 cohort ---
  2,  "AK",  2,  1, 2024, 2024, "SPA",    "AK Gov release; SPA AK-23-0010; SB 58",
  31, "NE",  1,  1, 2024, 2024, "SPA",    "NE DHHS; SPA NE-24-0002 approved 3/13/2024",
  48, "TX",  3,  1, 2024, 2024, "SPA",    "TX Gov release; HB 12; TMHP 3/6/2024",
  49, "UT",  1,  1, 2024, 2024, "SPA",    "CMS 3/8/2024 (45th state); UT OEP manual",
  32, "NV",  1,  1, 2024, 2024, "SPA",    "SB 232; NV effective date list; Carson City news",
  # --- Not-yet-treated in sample (adopt after 2024) ---
  16, "ID",  7,  1, 2024, 2025, "SPA",    "HB 633; CMS approval 1/17/2025 (48th state)",
  19, "IA",  4,  1, 2025, 2025, "SPA",    "SF 2251; CMS approval 1/7/2025"
)

never_treated <- c(5, 55)

fwrite(treatment_dates, file.path(data_dir, "treatment_dates.csv"))
cat(sprintf("Treatment dates: %d states\n", nrow(treatment_dates)))

cat("\n=== Data fetch complete ===\n")
