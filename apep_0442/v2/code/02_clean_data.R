## ============================================================================
## 02_clean_data.R — Clean IPUMS 1910 extract for RDD analysis
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## NOTE: Uses the 1.4% oversampled sample (us1910l) because the full-count
## census (us1910m) does not include the VETCIVWR variable needed to
## identify Civil War veterans. This is the largest IPUMS sample with
## veteran identification available.
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load raw IPUMS 1910 data ----
cat("Loading IPUMS 1910 data (1.4% oversampled sample)...\n")

# Find the DDI and data files in the extract directory
extract_dir <- file.path(data_dir, "1910_census")
if (!dir.exists(extract_dir)) {
  extract_dir <- data_dir
}

ddi_file <- list.files(extract_dir, pattern = "\\.xml$", full.names = TRUE)[1]
dat_file <- list.files(extract_dir, pattern = "\\.(csv\\.gz|dat\\.gz)$", full.names = TRUE)[1]

if (is.na(ddi_file) || is.na(dat_file)) {
  stop("IPUMS 1910 data files not found. Run 01_fetch_data.py first.")
}

cat("  DDI:", basename(ddi_file), "\n")
cat("  Data:", basename(dat_file), "\n")

ddi <- read_ipums_ddi(ddi_file)
raw <- read_ipums_micro(ddi, verbose = TRUE)
setDT(raw)
cat("  Raw rows:", format(nrow(raw), big.mark = ","), "\n")
cat("  Memory:", format(object.size(raw), units = "MB"), "\n")

## ---- 2. Recode VETCIVWR (Civil War veteran status) ----
# IPUMS VETCIVWR codes:
#   0 = Not a veteran
#   1 = Union Army
#   2 = Union Navy
#   3 = Confederate Army
#   4 = Confederate Navy
#   9 = Unknown/missing

raw[, veteran_type := fcase(
  VETCIVWR == 1, "Union Army",
  VETCIVWR == 2, "Union Navy",
  VETCIVWR == 3, "Confederate Army",
  VETCIVWR == 4, "Confederate Navy",
  default = "Not veteran"
)]

raw[, union_veteran := as.integer(veteran_type %in% c("Union Army", "Union Navy"))]
raw[, confed_veteran := as.integer(veteran_type %in% c("Confederate Army", "Confederate Navy"))]
raw[, any_veteran := as.integer(union_veteran == 1 | confed_veteran == 1)]

## ---- 3. Filter to analysis sample ----
# Males aged 45-90 (wide range around age 62 cutoff)
dt <- raw[SEX == 1 & AGE >= 45 & AGE <= 90]
cat("\nMales 45-90:", format(nrow(dt), big.mark = ","), "\n")

# Free raw data
rm(raw)
gc()

## ---- 4. Construct outcome variables ----
# Labor force participation (LABFORCE: 0=N/A, 1=Not in LF, 2=In LF)
dt[, in_labor_force := as.integer(LABFORCE == 2)]

# Occupation classifications (OCC1950 codes)
dt[, has_occupation := as.integer(OCC1950 < 980)]
dt[, professional := as.integer(OCC1950 < 100 & OCC1950 > 0)]
dt[, farm_occ := as.integer((OCC1950 >= 100 & OCC1950 < 200) |
                             (OCC1950 >= 800 & OCC1950 < 900))]
dt[, manual_labor := as.integer((OCC1950 >= 600 & OCC1950 < 700) |
                                 (OCC1950 >= 900 & OCC1950 < 980))]

# Home ownership (OWNERSHP: 0=N/A, 1=Owned, 2=Rented)
dt[, owns_home := as.integer(OWNERSHP == 1)]

# Household head (RELATE: 1=Head)
dt[, is_head := as.integer(RELATE == 1)]

# Lives independently (head or spouse)
dt[, independent := as.integer(RELATE <= 2)]

# Literate (LIT: 4=Reads and writes)
dt[, literate := as.integer(LIT == 4)]

# Native born (NATIVITY: 0=N/A, 1=Native born, 2-5=Foreign born)
dt[, native_born := as.integer(NATIVITY <= 1)]

# Married (MARST: 1=Married spouse present, 2=Married spouse absent)
dt[, married := as.integer(MARST <= 2)]

# Urban residence (URBAN: 2=Urban)
dt[, urban := as.integer(URBAN == 2)]

# White (RACE: 1=White)
dt[, white := as.integer(RACE == 1)]

## ---- 5. Create RDD running variable ----
dt[, age_centered := AGE - 62]  # Centered at cutoff
dt[, above_62 := as.integer(AGE >= 62)]  # Treatment indicator

## ---- 6. Region classification ----
# Census regions for subgroup analysis
dt[, region := fcase(
  STATEFIP %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  STATEFIP %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  STATEFIP %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  STATEFIP %in% c(2, 4, 6, 8, 15, 16, 30, 32, 35, 41, 49, 53, 56), "West",
  default = "Other"
)]

# Border states (KY=21, MO=29, MD=24, WV=54, DE=10)
dt[, border_state := as.integer(STATEFIP %in% c(21, 29, 24, 54, 10))]

## ---- 7. Summary statistics ----
cat("\n--- Sample Composition (1910 Census, 1.4% Oversampled) ---\n")
cat("Total males 45-90:", format(nrow(dt), big.mark = ","), "\n")
cat("Union veterans:", format(sum(dt$union_veteran), big.mark = ","), "\n")
cat("Confederate veterans:", format(sum(dt$confed_veteran), big.mark = ","), "\n")
cat("Non-veterans:", format(sum(dt$any_veteran == 0), big.mark = ","), "\n")

cat("\n--- Union Veterans by Age Group ---\n")
union <- dt[union_veteran == 1]
cat("Total Union veterans:", format(nrow(union), big.mark = ","), "\n")
cat("Ages 45-61 (below cutoff):", format(sum(union$AGE < 62), big.mark = ","), "\n")
cat("Ages 62-90 (above cutoff):", format(sum(union$AGE >= 62), big.mark = ","), "\n")
cat("Mean age:", round(mean(union$AGE), 1), "\n")
cat("LFP rate:", round(mean(union$in_labor_force, na.rm = TRUE), 3), "\n")

cat("\n--- Confederate Veterans by Age Group ---\n")
confed <- dt[confed_veteran == 1]
cat("Total Confederate veterans:", format(nrow(confed), big.mark = ","), "\n")
cat("Ages 45-61 (below cutoff):", format(sum(confed$AGE < 62), big.mark = ","), "\n")
cat("Ages 62-90 (above cutoff):", format(sum(confed$AGE >= 62), big.mark = ","), "\n")

cat("\n--- Border State Veterans ---\n")
border_union <- dt[union_veteran == 1 & border_state == 1]
border_confed <- dt[confed_veteran == 1 & border_state == 1]
cat("Union veterans in border states:", format(nrow(border_union), big.mark = ","), "\n")
cat("Confederate veterans in border states:", format(nrow(border_confed), big.mark = ","), "\n")

## ---- 8. Save cleaned data ----
outfile <- file.path(data_dir, "census_1910_veterans.rds")
saveRDS(dt, outfile)
cat("\nSaved full dataset to", outfile, "\n")
cat("File size:", round(file.size(outfile) / 1e6, 1), "MB\n")

# Save veteran subsets for quick access
union_file <- file.path(data_dir, "union_veterans.rds")
saveRDS(dt[union_veteran == 1], union_file)
cat("Saved Union veterans:", format(nrow(dt[union_veteran == 1]), big.mark = ","), "to", union_file, "\n")

confed_file <- file.path(data_dir, "confed_veterans.rds")
saveRDS(dt[confed_veteran == 1], confed_file)
cat("Saved Confederate veterans:", format(nrow(dt[confed_veteran == 1]), big.mark = ","), "to", confed_file, "\n")

rm(dt, union, confed)
gc()

cat("\nData cleaning complete.\n")
