# =============================================================================
# 01_fetch_data.R - Data Acquisition
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
#
# Data sources:
# 1. CPS Voting and Registration Supplement (Census Bureau API)
# 2. State felon voting rights reform database (compiled from NCSL/Brennan)
# 3. State concurrent voting law panel (NCSL)
# =============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# 1. CPS VOTING SUPPLEMENT DATA
# =============================================================================
# Strategy: Query Census CPS API for November voting supplement microdata.
# Available years vary; we fetch what we can and note gaps.
#
# Census CPS API endpoint: api.census.gov/data/{year}/cps/voting/nov
# =============================================================================

cat("\n=== Fetching CPS Voting Supplement Data ===\n")

# Years to fetch (biennial, November of even years)
cps_years <- seq(1996, 2024, by = 2)

# Function to fetch CPS voting data from Census API
fetch_cps_voting <- function(year) {
  # Variable names differ slightly across eras
  # Post-2002 use PES1/PES2; some years use different race vars
  base_url <- sprintf(
    "https://api.census.gov/data/%d/cps/voting/nov", year
  )

  # Try to discover available variables first
  vars_url <- paste0(base_url, "/variables.json")
  vars_resp <- tryCatch(GET(vars_url, timeout(30)), error = function(e) NULL)

  if (is.null(vars_resp) || status_code(vars_resp) != 200) {
    cat(sprintf("  Year %d: API endpoint not available\n", year))
    return(NULL)
  }

  vars_json <- content(vars_resp, as = "text", encoding = "UTF-8")
  available_vars <- names(fromJSON(vars_json)$variables)

  # Map to harmonized names based on what's available
  var_map <- list()

  # Voted
  if ("PES1" %in% available_vars) var_map$voted <- "PES1"
  else if ("pes1" %in% available_vars) var_map$voted <- "pes1"

  # Registered
  if ("PES2" %in% available_vars) var_map$registered <- "PES2"
  else if ("pes2" %in% available_vars) var_map$registered <- "pes2"

  # Race (pre-2003: PERACE; post-2003: PTDTRACE/PRDTRACE)
  if ("PTDTRACE" %in% available_vars) var_map$race <- "PTDTRACE"
  else if ("PRDTRACE" %in% available_vars) var_map$race <- "PRDTRACE"
  else if ("PERACE" %in% available_vars) var_map$race <- "PERACE"
  else if ("ptdtrace" %in% available_vars) var_map$race <- "ptdtrace"
  else if ("prdtrace" %in% available_vars) var_map$race <- "prdtrace"
  else if ("perace" %in% available_vars) var_map$race <- "perace"

  # Hispanic origin (may not exist pre-2003; PERACE has combined codes)
  if ("PEHSPNON" %in% available_vars) var_map$hispan <- "PEHSPNON"
  else if ("pehspnon" %in% available_vars) var_map$hispan <- "pehspnon"
  else if ("PRPERTYP" %in% available_vars) var_map$hispan <- "PRPERTYP"

  # Age
  if ("PRTAGE" %in% available_vars) var_map$age <- "PRTAGE"
  else if ("prtage" %in% available_vars) var_map$age <- "prtage"
  else if ("PEAGE" %in% available_vars) var_map$age <- "PEAGE"

  # Sex
  if ("PESEX" %in% available_vars) var_map$sex <- "PESEX"
  else if ("pesex" %in% available_vars) var_map$sex <- "pesex"

  # Education
  if ("PEEDUCA" %in% available_vars) var_map$educ <- "PEEDUCA"
  else if ("peeduca" %in% available_vars) var_map$educ <- "peeduca"

  # State FIPS (most years: GESTFIPS; 2024: STATE)
  if ("GESTFIPS" %in% available_vars) var_map$state <- "GESTFIPS"
  else if ("gestfips" %in% available_vars) var_map$state <- "gestfips"
  else if ("STATE" %in% available_vars) var_map$state <- "STATE"
  else if ("state" %in% available_vars) var_map$state <- "state"
  else if ("GESTCEN" %in% available_vars) var_map$state <- "GESTCEN"

  # Weight
  if ("PWSSWGT" %in% available_vars) var_map$weight <- "PWSSWGT"
  else if ("pwsswgt" %in% available_vars) var_map$weight <- "pwsswgt"
  else if ("PESUPPWT" %in% available_vars) var_map$weight <- "PESUPPWT"

  # Citizenship
  if ("PRCITSHP" %in% available_vars) var_map$citizen <- "PRCITSHP"
  else if ("prcitshp" %in% available_vars) var_map$citizen <- "prcitshp"

  # Check we have essential variables
  essential <- c("voted", "race", "state", "weight")
  missing_essential <- setdiff(essential, names(var_map))
  if (length(missing_essential) > 0) {
    cat(sprintf("  Year %d: Missing essential variables: %s\n",
                year, paste(missing_essential, collapse = ", ")))
    cat(sprintf("  Available vars sample: %s\n",
                paste(head(available_vars, 20), collapse = ", ")))
    return(NULL)
  }

  # Build query
  get_vars <- unique(unlist(var_map))
  query_url <- sprintf("%s?get=%s&for=state:*", base_url,
                       paste(get_vars, collapse = ","))

  # Add Census API key if available
  census_key <- Sys.getenv("CENSUS_API_KEY")
  if (nchar(census_key) > 0) {
    query_url <- paste0(query_url, "&key=", census_key)
  }

  resp <- tryCatch(GET(query_url, timeout(120)), error = function(e) NULL)

  if (is.null(resp) || status_code(resp) != 200) {
    cat(sprintf("  Year %d: API query failed (status %s)\n",
                year, ifelse(is.null(resp), "error", status_code(resp))))
    return(NULL)
  }

  raw <- content(resp, as = "text", encoding = "UTF-8")
  mat <- fromJSON(raw)

  # First row is headers
  headers <- mat[1, ]
  df <- as.data.frame(mat[-1, ], stringsAsFactors = FALSE)
  names(df) <- headers

  # Rename to harmonized names
  rename_map <- setNames(unlist(var_map), names(var_map))
  for (nm in names(rename_map)) {
    if (rename_map[nm] %in% names(df)) {
      df[[nm]] <- df[[rename_map[nm]]]
    }
  }

  df$year <- year
  df$state_fips <- as.integer(df$state)

  # Convert numeric columns
  for (col in c("voted", "registered", "age", "sex", "weight")) {
    if (col %in% names(df)) df[[col]] <- as.numeric(df[[col]])
  }
  if ("race" %in% names(df)) df$race <- as.integer(df$race)
  if ("hispan" %in% names(df)) df$hispan <- as.integer(df$hispan)
  if ("educ" %in% names(df)) df$educ <- as.integer(df$educ)
  if ("citizen" %in% names(df)) df$citizen <- as.integer(df$citizen)

  cat(sprintf("  Year %d: %d observations fetched\n", year, nrow(df)))

  # Select harmonized columns
  keep_cols <- intersect(
    c("year", "state_fips", "voted", "registered", "race", "hispan",
      "age", "sex", "educ", "weight", "citizen"),
    names(df)
  )
  return(df[, keep_cols])
}

# Fetch all years
cps_list <- list()
for (yr in cps_years) {
  cat(sprintf("Fetching year %d...\n", yr))
  result <- fetch_cps_voting(yr)
  if (!is.null(result)) {
    cps_list[[as.character(yr)]] <- result
  }
  Sys.sleep(1)  # Rate limiting
}

cat(sprintf("\nSuccessfully fetched %d of %d years from Census API.\n",
            length(cps_list), length(cps_years)))

# If we got at least some years, combine and save
if (length(cps_list) > 0) {
  cps_raw <- bind_rows(cps_list)
  saveRDS(cps_raw, file.path(data_dir, "cps_voting_raw.rds"))
  cat(sprintf("Saved %d total observations to cps_voting_raw.rds\n", nrow(cps_raw)))
} else {
  cat("WARNING: Census CPS API returned no data. Trying IPUMS fallback...\n")
}

# If Census API didn't return enough years, try IPUMS CPS
fetched_years <- as.integer(names(cps_list))
missing_years <- setdiff(cps_years, fetched_years)

if (length(missing_years) > 0 && requireNamespace("ipumsr", quietly = TRUE)) {
  cat(sprintf("\nAttempting IPUMS CPS for %d missing years: %s\n",
              length(missing_years), paste(missing_years, collapse = ", ")))

  ipums_key <- Sys.getenv("IPUMS_API_KEY")
  if (nchar(ipums_key) > 0) {
    library(ipumsr)
    set_ipums_api_key(ipums_key)

    # Construct sample names for November supplements
    # IPUMS CPS naming: cps{YYYY}_{MM}s for supplements
    nov_samples <- paste0("cps", missing_years, "_11s")

    tryCatch({
      extract_def <- define_extract_cps(
        description = "CPS Voting Supplement for APEP-0265",
        samples = nov_samples,
        variables = c("YEAR", "STATEFIP", "AGE", "SEX", "RACE", "HISPAN",
                      "EDUC", "CITIZEN", "VOTED", "VOREG", "VOSUPPWT")
      )

      submitted <- submit_extract(extract_def)
      cat(sprintf("IPUMS extract submitted (ID: %s). Waiting for completion...\n",
                  submitted$number))

      ready <- wait_for_extract(submitted, timeout = 1800)  # 30 min timeout
      downloaded <- download_extract(ready, download_dir = data_dir)
      ipums_data <- read_ipums_micro(downloaded)

      # Harmonize to match Census API format
      ipums_clean <- ipums_data %>%
        transmute(
          year = YEAR,
          state_fips = as.integer(STATEFIP),
          voted = as.numeric(VOTED),
          registered = as.numeric(VOREG),
          race = as.integer(RACE),
          hispan = as.integer(HISPAN),
          age = as.numeric(AGE),
          sex = as.numeric(SEX),
          educ = as.integer(EDUC),
          weight = as.numeric(VOSUPPWT),
          citizen = as.integer(CITIZEN)
        )

      # Save IPUMS data
      saveRDS(ipums_clean, file.path(data_dir, "cps_voting_ipums.rds"))
      cat(sprintf("IPUMS: %d observations saved\n", nrow(ipums_clean)))

      # Combine with Census API data if both exist
      if (length(cps_list) > 0) {
        cps_raw <- bind_rows(readRDS(file.path(data_dir, "cps_voting_raw.rds")),
                             ipums_clean)
        saveRDS(cps_raw, file.path(data_dir, "cps_voting_raw.rds"))
        cat(sprintf("Combined dataset: %d observations\n", nrow(cps_raw)))
      } else {
        saveRDS(ipums_clean, file.path(data_dir, "cps_voting_raw.rds"))
      }
    }, error = function(e) {
      cat(sprintf("IPUMS extract failed: %s\n", e$message))
      cat("Proceeding with available Census API data.\n")
    })
  }
}

# =============================================================================
# 2. STATE FELON VOTING RIGHTS REFORM DATABASE
# =============================================================================
# Compiled from NCSL, Brennan Center, Ballotpedia
# Treatment = first November even-year election at which reform is operative
# =============================================================================

cat("\n=== Constructing Treatment Timing Database ===\n")

# Reform database: state_fips, reform_year (calendar year effective),
# first_election (first eligible November election year), reform_type
reforms <- tribble(
  ~state_fips, ~state_abbr, ~reform_year, ~first_election, ~reform_type, ~notes,
  # Pre-2000 reforms
  48, "TX", 1997, 1998, "legislative", "Automatic restoration upon completion",
  # 2000-2004 reforms
  9,  "CT", 2001, 2002, "legislative", "Restored voting during probation",
  35, "NM", 2001, 2002, "legislative", "Automatic restoration after completion",
  56, "WY", 2003, 2004, "legislative", "First-time nonviolent felons after completion",
  # 2005-2008 reforms
  31, "NE", 2005, 2006, "legislative", "Eliminated 2-year waiting period",
  30, "MT", 2005, 2006, "legislative", "Automatic restoration after completion",
  44, "RI", 2006, 2008, "legislative", "Restored voting during probation",
  24, "MD", 2007, 2008, "legislative", "Restored voting during probation",
  # 2009-2012 reforms
  53, "WA", 2009, 2010, "legislative", "Restored voting during probation",
  # 2013-2016 reforms
  10, "DE", 2013, 2014, "legislative", "Eliminated 5-year waiting period",
  51, "VA", 2016, 2016, "executive", "McAuliffe mass clemency for completed sentences",
  # 2017-2018 reforms
  34, "NJ", 2018, 2018, "legislative", "Restored voting during probation",
  36, "NY", 2018, 2018, "executive", "Parole voting by executive order",
  # 2019 reforms (effective for 2020 election)
  12, "FL", 2019, 2020, "ballot", "Amendment 4 (passed Nov 2018, effective Jan 2019)",
  8,  "CO", 2019, 2020, "legislative", "Restored voting during parole",
  21, "KY", 2019, 2020, "executive", "Beshear executive order for nonviolent felons",
  22, "LA", 2019, 2020, "legislative", "Restored after completion (was 5-year wait)",
  38, "ND", 2019, 2020, "legislative", "Restored voting during probation",
  32, "NV", 2019, 2020, "legislative", "Automatic restoration upon release",
  6,  "CA", 2020, 2020, "ballot", "Prop 17: restored parole voting",
  # 2021-2024 reforms (effective for 2022/2024 elections)
  9,  "CT", 2021, 2022, "legislative", "Expanded: voting during parole (upgrade)",
  36, "NY", 2021, 2022, "legislative", "Legislated parole voting (upgrade from EO)",
  53, "WA", 2022, 2022, "legislative", "Expanded: automatic upon release from prison",
  41, "OR", 2022, 2022, "legislative", "Expanded: voting while incarcerated",
  27, "MN", 2023, 2024, "legislative", "Automatic restoration upon release",
  35, "NM", 2023, 2024, "legislative", "Expanded: voting while incarcerated"
)

# For states with multiple reforms, keep the FIRST reform for primary analysis
# (upgrades are secondary treatment intensification)
reforms_primary <- reforms %>%
  group_by(state_fips) %>%
  arrange(first_election) %>%
  slice(1) %>%
  ungroup()

cat(sprintf("Primary reforms: %d states\n", nrow(reforms_primary)))

# Reversal states (excluded from main sample)
reversals <- tribble(
  ~state_fips, ~state_abbr, ~expand_year, ~reverse_year, ~re_expand_year, ~notes,
  12, "FL", 2007, 2011, 2019, "Crist expanded → Scott reversed → Amendment 4",
  19, "IA", 2005, 2011, 2020, "Vilsack EO → Branstad reversed → Reynolds EO"
)

# Note: FL and IA's primary reform in reforms_primary is their FINAL expansion
# We flag them so they can be dropped in the main analysis
reversal_fips <- c(12, 19)

# Never-disenfranchise states (always allowed felon voting)
never_disenfranchise <- tribble(
  ~state_fips, ~state_abbr, ~notes,
  23, "ME", "Never disenfranchises",
  50, "VT", "Never disenfranchises",
  11, "DC", "Never disenfranchises (district)"
)

# States that never changed during study period (maintained disenfranchisement)
# These serve as the primary control group
# (States not in reforms, reversals, or never_disenfranchise)
all_state_fips <- c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56)
reform_fips <- unique(reforms_primary$state_fips)
never_dis_fips <- never_disenfranchise$state_fips

control_fips <- setdiff(all_state_fips,
                        c(reform_fips, reversal_fips, never_dis_fips))

cat(sprintf("Control states (never changed): %d\n", length(control_fips)))
cat(sprintf("Reversal states (FL, IA): %d\n", length(reversal_fips)))
cat(sprintf("Never-disenfranchise (ME, VT, DC): %d\n", length(never_dis_fips)))

# Save treatment database
saveRDS(reforms_primary, file.path(data_dir, "reform_timing.rds"))
saveRDS(reforms, file.path(data_dir, "reform_timing_all.rds"))
saveRDS(reversals, file.path(data_dir, "reversals.rds"))

# Create state-level treatment panel
state_panel <- expand_grid(
  state_fips = all_state_fips,
  year = seq(1996, 2024, by = 2)
) %>%
  left_join(
    reforms_primary %>% select(state_fips, first_election, reform_type),
    by = "state_fips"
  ) %>%
  mutate(
    # Treatment indicator
    post_reform = if_else(!is.na(first_election) & year >= first_election, 1L, 0L),
    # State category
    state_group = case_when(
      state_fips %in% never_dis_fips ~ "never_disenfranchise",
      state_fips %in% reversal_fips ~ "reversal",
      state_fips %in% reform_fips ~ "reform",
      TRUE ~ "control"
    ),
    # Treatment cohort for CS estimator (0 = never treated)
    treat_cohort = if_else(!is.na(first_election), first_election, 0L)
  )

saveRDS(state_panel, file.path(data_dir, "state_treatment_panel.rds"))
cat(sprintf("State treatment panel: %d state-year observations\n", nrow(state_panel)))

# =============================================================================
# 3. CONCURRENT VOTING LAW PANEL
# =============================================================================
# Compiled from NCSL databases on voter ID, registration, and early voting
# =============================================================================

cat("\n=== Constructing Concurrent Voting Law Panel ===\n")

# Strict voter ID law adoption (photo ID required to vote)
# Source: NCSL Voter ID Laws
strict_voter_id <- tribble(
  ~state_fips, ~state_abbr, ~vid_year,
  18, "IN", 2006,   # First strict photo ID law
  13, "GA", 2008,
  47, "TN", 2012,
  20, "KS", 2012,
  28, "MS", 2014,
  51, "VA", 2014,
  48, "TX", 2014,   # Implemented; later softened
  37, "NC", 2016,   # Attempted; blocked in court
  55, "WI", 2016,
  1,  "AL", 2014,
  45, "SC", 2013,
  29, "MO", 2017,
  5,  "AR", 2018,
  38, "ND", 2018
)

# Same-day registration adoption
# Source: NCSL Same Day Registration
sdr <- tribble(
  ~state_fips, ~state_abbr, ~sdr_year,
  27, "MN", 1974,
  55, "WI", 1976,
  23, "ME", 1973,
  16, "ID", 2001,
  30, "MT", 2006,
  19, "IA", 2008,
  37, "NC", 2008,  # Eliminated in 2013
  9,  "CT", 2012,
  6,  "CA", 2012,
  8,  "CO", 2013,
  24, "MD", 2013,
  51, "VA", 2022,
  32, "NV", 2020,
  11, "DC", 2010,
  17, "IL", 2014,
  15, "HI", 2018,
  36, "NY", 2023
)

# Automatic voter registration adoption
avr <- tribble(
  ~state_fips, ~state_abbr, ~avr_year,
  41, "OR", 2016,
  6,  "CA", 2018,
  50, "VT", 2017,
  8,  "CO", 2017,
  9,  "CT", 2016,
  13, "GA", 2016,
  17, "IL", 2018,
  24, "MD", 2019,
  25, "MA", 2020,
  27, "MN", 2023,
  34, "NJ", 2018,
  32, "NV", 2020,
  36, "NY", 2023,
  51, "VA", 2020,
  53, "WA", 2019,
  11, "DC", 2018
)

# Build concurrent law panel
voting_laws <- state_panel %>%
  select(state_fips, year) %>%
  left_join(strict_voter_id %>% select(state_fips, vid_year), by = "state_fips") %>%
  left_join(sdr %>% select(state_fips, sdr_year), by = "state_fips") %>%
  left_join(avr %>% select(state_fips, avr_year), by = "state_fips") %>%
  mutate(
    has_strict_voter_id = if_else(!is.na(vid_year) & year >= vid_year, 1L, 0L),
    has_same_day_reg = if_else(!is.na(sdr_year) & year >= sdr_year, 1L, 0L),
    has_auto_voter_reg = if_else(!is.na(avr_year) & year >= avr_year, 1L, 0L)
  ) %>%
  select(state_fips, year, has_strict_voter_id, has_same_day_reg, has_auto_voter_reg)

saveRDS(voting_laws, file.path(data_dir, "concurrent_voting_laws.rds"))
cat(sprintf("Concurrent voting laws panel: %d state-year observations\n",
            nrow(voting_laws)))

# =============================================================================
# 4. STATE FIPS CROSSWALK
# =============================================================================

state_xwalk <- tibble(
  state_fips = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,
                 25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,
                 45,46,47,48,49,50,51,53,54,55,56),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
                 "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
                 "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
                 "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
                 "WV","WI","WY"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California","Colorado",
                 "Connecticut","Delaware","District of Columbia","Florida",
                 "Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
                 "Kentucky","Louisiana","Maine","Maryland","Massachusetts",
                 "Michigan","Minnesota","Mississippi","Missouri","Montana",
                 "Nebraska","Nevada","New Hampshire","New Jersey","New Mexico",
                 "New York","North Carolina","North Dakota","Ohio","Oklahoma",
                 "Oregon","Pennsylvania","Rhode Island","South Carolina",
                 "South Dakota","Tennessee","Texas","Utah","Vermont","Virginia",
                 "Washington","West Virginia","Wisconsin","Wyoming")
)

saveRDS(state_xwalk, file.path(data_dir, "state_crosswalk.rds"))

cat("\n=== Data Acquisition Complete ===\n")
cat(sprintf("Files saved to %s/\n", data_dir))
