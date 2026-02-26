## 02_clean_data.R — Clean and construct analysis variables
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"

## ============================================================================
## PART 1: Load and Clean ACS PUMS Data
## ============================================================================

cat("Loading ACS PUMS data...\n")
pums <- fread(paste0(data_dir, "acs_pums_raw.csv"))
cat("Raw observations:", nrow(pums), "\n")

## ---- Construct Key Variables ----

## Education: BA or higher vs. less than BA
## SCHL codes: 16=HS diploma, 17=GED, 18-19=some college, 20=associate,
##             21=bachelor's, 22=master's, 23=professional, 24=doctorate
pums[, has_ba := as.integer(SCHL >= 21)]
pums[, educ_cat := fcase(
  SCHL <= 17, "HS or less",
  SCHL %in% 18:20, "Some college/Associate",
  SCHL == 21, "Bachelor's",
  SCHL >= 22, "Graduate+"
)]

## Class of Worker
## COW: 1=private for-profit, 2=private nonprofit, 3=local gov,
##      4=state gov, 5=federal gov, 6=self-employed (incorporated),
##      7=self-employed (not inc), 8=unpaid family
pums[, cow_cat := fcase(
  COW == 4, "State government",
  COW == 3, "Local government",
  COW == 5, "Federal government",
  COW %in% c(1, 2), "Private sector",
  COW %in% c(6, 7), "Self-employed",
  COW == 8, "Other"
)]
pums[, is_state_gov := as.integer(COW == 4)]

## Race/ethnicity (simplified)
## RAC1P: 1=White, 2=Black/AA, 3-5=AI/AN, 6=Asian, 7=NH/PI, 8=Other, 9=Two+
pums[, race_cat := fcase(
  RAC1P == 1, "White",
  RAC1P == 2, "Black",
  RAC1P == 6, "Asian",
  default = "Other/Multiple"
)]

## State FIPS
pums[, state_fips := as.integer(ST)]

## Person weight
pums[, weight := as.numeric(PWGTP)]

## Year
pums[, year := as.integer(YEAR)]

## Wages (annual, positive only for wage earners)
pums[, wages := as.numeric(WAGP)]
pums[wages < 0, wages := NA]

## Age group
pums[, age_group := fcase(
  AGEP >= 25 & AGEP <= 34, "25-34",
  AGEP >= 35 & AGEP <= 44, "35-44",
  AGEP >= 45 & AGEP <= 54, "45-54",
  AGEP >= 55 & AGEP <= 64, "55-64"
)]

## Sex
pums[, female := as.integer(SEX == 2)]

cat("Variables constructed.\n")

## ============================================================================
## PART 2: Merge Treatment Variable
## ============================================================================

treatment <- fread(paste0(data_dir, "treatment_dates.csv"))

## Create state-level treatment panel
## All 51 FIPS codes (50 states + DC)
all_fips <- sort(unique(pums$state_fips))
all_years <- sort(unique(pums$year))

state_panel <- expand.grid(state_fips = all_fips, year = all_years) %>%
  as.data.table()

## Merge treatment dates
state_panel <- merge(state_panel,
                     treatment[, .(state_fips, first_treat, strength, policy_type)],
                     by = "state_fips", all.x = TRUE)

## Never-treated states get first_treat = 0 (for did package convention)
state_panel[is.na(first_treat), first_treat := 0]
state_panel[is.na(strength), strength := "none"]
state_panel[is.na(policy_type), policy_type := "none"]

## Binary treatment indicator
state_panel[, treated := as.integer(first_treat > 0 & year >= first_treat)]

cat("Treatment panel: ", nrow(state_panel), "state-years\n")
cat("Treated states:", state_panel[first_treat > 0, uniqueN(state_fips)], "\n")
cat("Never-treated states:", state_panel[first_treat == 0, uniqueN(state_fips)], "\n")

## ============================================================================
## PART 3: Construct State-Year Outcome Variables
## ============================================================================

cat("Constructing state-year outcomes...\n")

## PRIMARY OUTCOME: Share of state government workers without BA
state_gov_educ <- pums[cow_cat == "State government",
  .(
    n_state_gov = sum(weight),
    n_no_ba = sum(weight * (1 - has_ba)),
    n_ba_plus = sum(weight * has_ba),
    mean_wages = weighted.mean(wages, weight, na.rm = TRUE),
    mean_wages_no_ba = weighted.mean(wages[has_ba == 0], weight[has_ba == 0], na.rm = TRUE),
    mean_wages_ba = weighted.mean(wages[has_ba == 1], weight[has_ba == 1], na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_black = weighted.mean(race_cat == "Black", weight, na.rm = TRUE),
    pct_white = weighted.mean(race_cat == "White", weight, na.rm = TRUE),
    mean_age = weighted.mean(AGEP, weight, na.rm = TRUE),
    pct_young = weighted.mean(AGEP <= 34, weight, na.rm = TRUE),
    unweighted_n = .N
  ),
  by = .(state_fips, year)]

state_gov_educ[, share_no_ba := n_no_ba / n_state_gov]
state_gov_educ[, share_ba_plus := n_ba_plus / n_state_gov]

## PLACEBO: Same outcomes for private sector
private_educ <- pums[cow_cat == "Private sector",
  .(
    n_private = sum(weight),
    n_no_ba_private = sum(weight * (1 - has_ba)),
    share_no_ba_private = sum(weight * (1 - has_ba)) / sum(weight),
    mean_wages_private = weighted.mean(wages, weight, na.rm = TRUE),
    pct_female_private = weighted.mean(female, weight, na.rm = TRUE),
    pct_black_private = weighted.mean(race_cat == "Black", weight, na.rm = TRUE),
    unweighted_n_private = .N
  ),
  by = .(state_fips, year)]

## PLACEBO: Federal government
federal_educ <- pums[cow_cat == "Federal government",
  .(
    n_federal = sum(weight),
    share_no_ba_federal = sum(weight * (1 - has_ba)) / sum(weight),
    unweighted_n_federal = .N
  ),
  by = .(state_fips, year)]

## PLACEBO: Local government
local_educ <- pums[cow_cat == "Local government",
  .(
    n_local = sum(weight),
    share_no_ba_local = sum(weight * (1 - has_ba)) / sum(weight),
    unweighted_n_local = .N
  ),
  by = .(state_fips, year)]

## Education detail for state gov
educ_detail <- pums[cow_cat == "State government",
  .(n = sum(weight)),
  by = .(state_fips, year, educ_cat)]
educ_detail <- dcast(educ_detail, state_fips + year ~ educ_cat,
                     value.var = "n", fill = 0)

## ============================================================================
## PART 4: Merge Everything
## ============================================================================

## State-level unemployment
unemp <- fread(paste0(data_dir, "state_unemployment.csv"))

## Build analysis dataset
analysis <- merge(state_panel, state_gov_educ, by = c("state_fips", "year"), all.x = TRUE)
analysis <- merge(analysis, private_educ, by = c("state_fips", "year"), all.x = TRUE)
analysis <- merge(analysis, federal_educ, by = c("state_fips", "year"), all.x = TRUE)
analysis <- merge(analysis, local_educ, by = c("state_fips", "year"), all.x = TRUE)
analysis <- merge(analysis, unemp[, .(state_fips, year, unemp_rate)],
                  by = c("state_fips", "year"), all.x = TRUE)

## Drop observations with too few state gov workers (small states, sampling noise)
analysis <- analysis[!is.na(share_no_ba) & unweighted_n >= 50]

## State names for display
state_names <- data.table(
  state_fips = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,
                 26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,
                 47,48,49,50,51,53,54,55,56),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California","Colorado",
                 "Connecticut","Delaware","DC","Florida","Georgia","Hawaii","Idaho",
                 "Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine",
                 "Maryland","Massachusetts","Michigan","Minnesota","Mississippi",
                 "Missouri","Montana","Nebraska","Nevada","New Hampshire",
                 "New Jersey","New Mexico","New York","North Carolina","North Dakota",
                 "Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
                 "Virginia","Washington","West Virginia","Wisconsin","Wyoming"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
                 "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
                 "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
                 "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
                 "WV","WI","WY")
)
analysis <- merge(analysis, state_names, by = "state_fips", all.x = TRUE)

## Sort
setorder(analysis, state_fips, year)

## Save
fwrite(analysis, paste0(data_dir, "analysis_panel.csv"))

cat("\n=== Analysis panel constructed ===\n")
cat("States:", uniqueN(analysis$state_fips), "\n")
cat("Years:", paste(range(analysis$year), collapse = "-"), "\n")
cat("State-years:", nrow(analysis), "\n")
cat("Treated state-years:", sum(analysis$treated), "\n")
cat("Mean share without BA (state gov):", round(mean(analysis$share_no_ba, na.rm = TRUE), 3), "\n")
