## ============================================================================
## 02_clean_data.R — Clean IPUMS 1910 extract for RDD analysis
## Project: The First Retirement Age (apep_0442)
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load raw IPUMS data ----
cat("Loading IPUMS 1910 data...\n")

# Find the DDI and data files
ddi_file <- list.files(data_dir, pattern = "\\.xml$", full.names = TRUE)[1]
dat_file <- list.files(data_dir, pattern = "\\.(csv\\.gz|dat\\.gz)$", full.names = TRUE)[1]

if (is.na(ddi_file) || is.na(dat_file)) {
  stop("IPUMS data files not found in data/. Run 01_fetch_data.py first.")
}

cat("  DDI:", basename(ddi_file), "\n")
cat("  Data:", basename(dat_file), "\n")

ddi <- read_ipums_ddi(ddi_file)
raw <- read_ipums_micro(ddi, verbose = FALSE)
setDT(raw)
cat("  Raw rows:", format(nrow(raw), big.mark = ","), "\n")

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
cat("Males 45-90:", format(nrow(dt), big.mark = ","), "\n")

## ---- 4. Construct outcome variables ----
# Labor force participation (LABFORCE: 0=N/A, 1=Not in LF, 2=In LF)
dt[, in_labor_force := as.integer(LABFORCE == 2)]

# Occupation: classify into broad categories
# OCC1950 codes: 0-99 = Professional/Technical, 100-199 = Farmers,
# 200-299 = Managers, 300-399 = Clerical, 400-499 = Sales,
# 500-599 = Craftsmen, 600-699 = Operatives, 700-799 = Service,
# 800-899 = Farm laborers, 900-970 = Laborers, 980 = Non-occupational, 999 = N/A
dt[, has_occupation := as.integer(OCC1950 < 980)]

# Professional or managerial occupation
dt[, professional := as.integer(OCC1950 < 100 & OCC1950 > 0)]

# Farm occupation (farmer or farm laborer)
dt[, farm_occ := as.integer((OCC1950 >= 100 & OCC1950 < 200) |
                             (OCC1950 >= 800 & OCC1950 < 900))]

# Manual labor (operatives + laborers)
dt[, manual_labor := as.integer((OCC1950 >= 600 & OCC1950 < 700) |
                                 (OCC1950 >= 900 & OCC1950 < 980))]

# Home ownership (OWNERSHP: 0=N/A, 1=Owned, 2=Rented)
dt[, owns_home := as.integer(OWNERSHP == 1)]

# Household head (RELATE: 1=Head)
dt[, is_head := as.integer(RELATE == 1)]

# Lives independently (head or spouse, not in someone else's household)
dt[, independent := as.integer(RELATE <= 2)]

# Literate (LIT: 1=No, 2=Cannot write, 3=Cannot read/write, 4=Reads and writes)
dt[, literate := as.integer(LIT == 4)]

# Native born (NATIVITY: 0=N/A, 1=Native born, 2-5=Foreign born)
dt[, native_born := as.integer(NATIVITY <= 1)]

# Married (MARST: 1=Married spouse present, 2=Married spouse absent)
dt[, married := as.integer(MARST <= 2)]

# Urban residence (URBAN: 1=Rural, 2=Urban)
dt[, urban := as.integer(URBAN == 2)]

## ---- 5. Create RDD running variable ----
dt[, age_centered := AGE - 62]  # Centered at cutoff
dt[, above_62 := as.integer(AGE >= 62)]  # Treatment indicator

## ---- 6. Summary statistics ----
cat("\n--- Sample Composition ---\n")
cat("Total males 45-90:", format(nrow(dt), big.mark = ","), "\n")
cat("Union veterans:", format(sum(dt$union_veteran), big.mark = ","), "\n")
cat("Confederate veterans:", format(sum(dt$confed_veteran), big.mark = ","), "\n")
cat("Non-veterans:", format(sum(dt$any_veteran == 0), big.mark = ","), "\n")

cat("\n--- Union Veterans by Age Group ---\n")
union <- dt[union_veteran == 1]
cat("Ages 45-61 (below cutoff):", sum(union$AGE < 62), "\n")
cat("Ages 62-90 (above cutoff):", sum(union$AGE >= 62), "\n")
cat("Mean age:", round(mean(union$AGE), 1), "\n")
cat("LFP rate:", round(mean(union$in_labor_force, na.rm = TRUE), 3), "\n")

## ---- 7. Save cleaned data ----
outfile <- file.path(data_dir, "census_1910_veterans.rds")
saveRDS(dt, outfile)
cat("\nSaved cleaned data to", outfile, "\n")
cat("File size:", round(file.size(outfile) / 1e6, 1), "MB\n")

# Also save just veterans for quick access
union_file <- file.path(data_dir, "union_veterans.rds")
saveRDS(dt[union_veteran == 1], union_file)
cat("Saved Union veterans to", union_file, "\n")

confed_file <- file.path(data_dir, "confed_veterans.rds")
saveRDS(dt[confed_veteran == 1], confed_file)
cat("Saved Confederate veterans to", confed_file, "\n")

# Clean up raw data from memory
rm(raw)
gc()

cat("\nData cleaning complete.\n")
