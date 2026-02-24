##──────────────────────────────────────────────────────────────────────────────
## 02_clean_data.R — Process IPUMS Ghana census and construct variables
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(data.table)
library(ipumsr)

DATA_DIR <- here::here("output", "apep_0451", "v1", "data")

## ── 1. Load IPUMS Ghana Census Data ─────────────────────────────────────────
cat("Loading IPUMS Ghana census data...\n")
dt <- fread(file.path(DATA_DIR, "ipums_ghana.csv.gz"), nThread = 4)
cat("Raw records:", format(nrow(dt), big.mark = ","), "\n")
cat("Variables:", paste(names(dt), collapse = ", "), "\n")
cat("Years:", sort(unique(dt$YEAR)), "\n")

## ── 2. Map IPUMS codes to meaningful variables ──────────────────────────────

## Census year
dt[, census_year := as.integer(YEAR)]

## Age (keep as-is, numeric)
dt[, age := as.integer(AGE)]

## Sex: IPUMS SEX = 1 (Male), 2 (Female)
dt[, female := as.integer(SEX == 2)]

## Education attainment (EDATTAIN harmonized)
## 0 = NIU, 1 = Less than primary, 2 = Primary, 3 = Secondary, 4 = University
dt[, edattain := as.integer(EDATTAIN)]
dt[, completed_primary := as.integer(edattain >= 2)]
dt[, completed_secondary := as.integer(edattain >= 3)]
dt[, completed_university := as.integer(edattain >= 4)]

## School attendance (SCHOOL) — Ghana IPUMS coding
## 1 = Yes, in school; 3 = No, not in school; 4 = Not stated; 9 = Unknown
dt[, in_school := fifelse(SCHOOL == 1, 1L, fifelse(SCHOOL == 3, 0L, NA_integer_))]

## Literacy (LIT) — Ghana IPUMS coding
## 0 = NIU/Unknown, 1 = No (illiterate), 2 = Yes (literate), 9 = Unknown
dt[, literate := fifelse(LIT == 2, 1L, fifelse(LIT == 1, 0L, NA_integer_))]

## Employment status (EMPSTAT)
## 0 = NIU, 1 = Employed, 2 = Unemployed, 3 = Inactive
dt[, employed := fifelse(EMPSTAT == 1, 1L,
                  fifelse(EMPSTAT %in% c(2, 3), 0L, NA_integer_))]
dt[, in_labor_force := fifelse(EMPSTAT %in% c(1, 2), 1L,
                        fifelse(EMPSTAT == 3, 0L, NA_integer_))]

## General industry (INDGEN)
## 10 = Agriculture, 20 = Mining, 30 = Manufacturing, etc.
dt[, works_agriculture := fifelse(INDGEN == 10 & employed == 1, 1L,
                           fifelse(employed == 1, 0L, NA_integer_))]

## Class of worker (CLASSWK)
## 1 = Self-employed, 2 = Wage/salary, 3 = Unpaid family worker
dt[, self_employed := as.integer(CLASSWK == 1 & employed == 1)]
dt[, unpaid_family := as.integer(CLASSWK == 3 & employed == 1)]

## Urban residence (URBAN)
## 1 = Urban, 2 = Rural, 0 = Unknown
dt[, urban := fifelse(URBAN == 1, 1L, fifelse(URBAN == 2, 0L, NA_integer_))]

## Region (GEO1_GH) — IPUMS harmonized first-level geography
dt[, geo1 := as.integer(GEO1_GH)]

## District (GEO2_GH) — IPUMS harmonized second-level geography
## Available for 2000 and 2010 only (0/missing for 1984)
dt[, geo2 := as.integer(GEO2_GH)]

## Children (NCHILD = number of own children in household)
dt[, nchild := as.integer(NCHILD)]

## Person weight
dt[, pw := as.numeric(PERWT)]

## ── 3. Merge regional cocoa shares ──────────────────────────────────────────
## IPUMS GEO1_GH uses codes 288001-288010 (country prefix 288 + region)
## Map: 288001=Western, 288002=Central, 288003=Greater Accra, 288004=Volta,
##       288005=Eastern, 288006=Ashanti, 288007=Brong Ahafo,
##       288008=Northern, 288009=Upper East, 288010=Upper West
cocoa_shares <- data.table(
  geo1 = c(288001L, 288002L, 288003L, 288004L, 288005L,
           288006L, 288007L, 288008L, 288009L, 288010L),
  region_name = c("Western", "Central", "Greater Accra", "Volta", "Eastern",
                  "Ashanti", "Brong Ahafo", "Northern", "Upper East", "Upper West"),
  cocoa_share = c(0.55, 0.03, 0.00, 0.01, 0.08, 0.20, 0.12, 0.00, 0.00, 0.00),
  forest_belt = c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
)
dt <- merge(dt, cocoa_shares, by = "geo1", all.x = TRUE)

## Treatment indicators
dt[, high_cocoa := as.integer(cocoa_share >= 0.08)]  # Western, Ashanti, Brong-Ahafo, Eastern
dt[, post2010 := as.integer(census_year == 2010)]
dt[, post2000 := as.integer(census_year >= 2000)]

## Cocoa price at census year
cocoa_prices <- fread(file.path(DATA_DIR, "cocoa_prices.csv"))
dt <- merge(dt, cocoa_prices, by.x = "census_year", by.y = "year", all.x = TRUE)

## Bartik treatment: cocoa_share × log(price)
dt[, log_price := log(price_usd_mt)]
dt[, bartik := cocoa_share * log_price]

## ── 4. Define analysis samples ──────────────────────────────────────────────

## Sample 1: School-age children (6-17) for enrollment analysis
dt[, school_age := as.integer(age >= 6 & age <= 17)]
dt[, primary_age := as.integer(age >= 6 & age <= 11)]
dt[, secondary_age := as.integer(age >= 12 & age <= 17)]

## Sample 2: Working-age adults (18-64) for employment analysis
dt[, working_age := as.integer(age >= 18 & age <= 64)]

## Sample 3: Young adults (18-30) for educational attainment analysis
dt[, young_adult := as.integer(age >= 18 & age <= 30)]

## ── 5. Summary statistics ───────────────────────────────────────────────────
cat("\n=== Sample sizes by census year ===\n")
dt[, .(N = .N,
       mean_age = weighted.mean(age, pw),
       pct_female = weighted.mean(female, pw) * 100,
       pct_urban = weighted.mean(urban, pw, na.rm = TRUE) * 100),
   by = census_year][order(census_year)] |> print()

cat("\n=== School-age (6-17) by year and cocoa intensity ===\n")
dt[school_age == 1, .(
  N = .N,
  pct_in_school = weighted.mean(in_school, pw, na.rm = TRUE) * 100,
  pct_literate = weighted.mean(literate, pw, na.rm = TRUE) * 100
), by = .(census_year, high_cocoa)][order(census_year, high_cocoa)] |> print()

cat("\n=== Working-age (18-64) by year and cocoa intensity ===\n")
dt[working_age == 1, .(
  N = .N,
  pct_employed = weighted.mean(employed, pw, na.rm = TRUE) * 100,
  pct_agriculture = weighted.mean(works_agriculture, pw, na.rm = TRUE) * 100,
  pct_completed_primary = weighted.mean(completed_primary, pw, na.rm = TRUE) * 100
), by = .(census_year, high_cocoa)][order(census_year, high_cocoa)] |> print()

cat("\n=== Regions and cocoa shares ===\n")
dt[census_year == 2000, .(N = .N, cocoa_share = first(cocoa_share),
                           forest_belt = first(forest_belt)),
   by = geo1][order(-cocoa_share)] |> print()

## ── 6. Save analysis dataset ────────────────────────────────────────────────
## Keep only needed columns
keep_cols <- c("census_year", "age", "female", "geo1", "geo2", "urban", "pw", "region_name",
               "edattain", "completed_primary", "completed_secondary",
               "completed_university", "in_school", "literate",
               "employed", "in_labor_force", "works_agriculture",
               "self_employed", "unpaid_family", "nchild",
               "cocoa_share", "forest_belt", "high_cocoa",
               "post2010", "post2000", "price_usd_mt", "log_price", "bartik",
               "school_age", "primary_age", "secondary_age",
               "working_age", "young_adult")

dt_clean <- dt[, ..keep_cols]
fwrite(dt_clean, file.path(DATA_DIR, "ghana_census_clean.csv.gz"))
cat("\nCleaned dataset saved:", format(nrow(dt_clean), big.mark = ","), "rows,",
    ncol(dt_clean), "columns\n")
cat("File size:", format(file.info(file.path(DATA_DIR, "ghana_census_clean.csv.gz"))$size,
                         big.mark = ","), "bytes\n")
