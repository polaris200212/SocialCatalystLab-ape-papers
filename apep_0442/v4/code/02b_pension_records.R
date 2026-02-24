## ============================================================================
## 02b_pension_records.R — Pension record construction for first stage
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== CONSTRUCTING PENSION RECORDS ===\n\n")

## Load merged data (from 02_clean_data.R)
dt <- readRDS(file.path(data_dir, "full_merged.rds"))

## ---- Parse pension law dates ----
## gen_penlaw_1900 and gen_penlaw_1910 contain dates like "18900627" or "19070206"
parse_pen_date <- function(x) {
  yr <- as.numeric(substr(x, 1, 4))
  mo <- as.numeric(substr(x, 5, 6))
  dy <- as.numeric(substr(x, 7, 8))
  as.Date(sprintf("%04d-%02d-%02d", yr, mo, dy), format = "%Y-%m-%d")
}

dt[, pen_law_date_1900 := tryCatch(parse_pen_date(pen_law_1900), error = function(e) as.Date(NA))]
dt[, pen_law_date_1910 := tryCatch(parse_pen_date(pen_law_1910), error = function(e) as.Date(NA))]

## ---- Categorize pension law ----
## Key pension laws:
## 18620714 = General Law (disability, 1862)
## 18900627 = Dependent Pension Act (disability, 1890)
## 19070206 = Age and Service Pension Act (age 62+)
## Various other amendments

dt[, pen_type_1900 := fifelse(grepl("^186207", pen_law_1900), "General (1862)",
                     fifelse(grepl("^189006", pen_law_1900), "Disability (1890)",
                     fifelse(grepl("^190702", pen_law_1900), "Age (1907)",
                     fifelse(!is.na(pen_law_1900) & pen_law_1900 != "", "Other",
                            "None"))))]

dt[, pen_type_1910 := fifelse(grepl("^186207", pen_law_1910), "General (1862)",
                     fifelse(grepl("^189006", pen_law_1910), "Disability (1890)",
                     fifelse(grepl("^190702", pen_law_1910), "Age (1907)",
                     fifelse(!is.na(pen_law_1910) & pen_law_1910 != "", "Other",
                            "None"))))]

## ---- First stage variables ----
## Binary: received any pension at 1910
dt[, has_pension_1910 := as.integer(!is.na(pen_amt_1910))]

## Binary: under 1907 Act specifically
dt[, under_1907_act := as.integer(grepl("^190702", pen_law_1910))]

## Pension dollar amount at 1910 (0 if no pension)
dt[, pen_dollars_1910 := fifelse(is.na(pen_amt_1910), 0, pen_amt_1910)]

## Pension dollar amount at 1900 (0 if no pension)
dt[, pen_dollars_1900 := fifelse(is.na(pen_amt_1900), 0, pen_amt_1900)]

## Change in pension amount
dt[, pen_change := pen_dollars_1910 - pen_dollars_1900]

## ---- Pension categories for heterogeneity ----
## (a) No prior pension → gained pension under 1907 Act
## (b) Had disability pension < $12 → topped up to ≥$12
## (c) Had disability pension ≥ $12 → no change from 1907 Act
## (d) No pension at either time

dt[, pension_group := fifelse(pen_dollars_1900 == 0 & under_1907_act == 1, "Gained (new)",
                     fifelse(pen_dollars_1900 > 0 & pen_dollars_1900 < 12 & under_1907_act == 1, "Topped up",
                     fifelse(pen_dollars_1900 >= 12, "Already high",
                     fifelse(pen_dollars_1900 > 0 & pen_dollars_1900 < 12 & under_1907_act == 0, "Disability only",
                            "No pension"))))]

## ---- Summary ----
cat("--- PENSION SUMMARY ---\n")
cat("Total veterans:", nrow(dt), "\n\n")

cat("Pension type at 1900:\n")
print(table(dt$pen_type_1900, useNA = "ifany"))

cat("\nPension type at 1910:\n")
print(table(dt$pen_type_1910, useNA = "ifany"))

cat("\nPension group:\n")
print(table(dt$pension_group, useNA = "ifany"))

cat("\nMean pension amount by group:\n")
dt[, .(mean_1900 = mean(pen_dollars_1900),
       mean_1910 = mean(pen_dollars_1910),
       mean_change = mean(pen_change),
       N = .N), by = pension_group][order(-N)]  |> print()

## Check first stage: pension receipt by age
cat("\nFirst stage: 1907 Act receipt by age near cutoff:\n")
alive_dt <- dt[alive_1910 == TRUE & !is.na(age_1907) & age_1907 >= 57 & age_1907 <= 70]
alive_dt[, .(pct_1907act = round(mean(under_1907_act) * 100, 1),
             mean_pen_1910 = round(mean(pen_dollars_1910), 1),
             N = .N), by = age_1907][order(age_1907)] |> print()

## ---- Save updated data ----
saveRDS(dt, file.path(data_dir, "full_merged.rds"))
cat("\nUpdated full_merged.rds saved.\n")

## Also update cross-section and panel samples
cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))

pen_vars <- c("pen_type_1900", "pen_type_1910", "has_pension_1910", "under_1907_act",
              "pen_dollars_1910", "pen_dollars_1900", "pen_change", "pension_group")

for (v in pen_vars) {
  cross[[v]] <- dt[[v]][match(cross$recidnum, dt$recidnum)]
  panel[[v]] <- dt[[v]][match(panel$recidnum, dt$recidnum)]
}

saveRDS(cross, file.path(data_dir, "cross_section_sample.rds"))
saveRDS(panel, file.path(data_dir, "panel_sample.rds"))

cat("Updated cross_section_sample.rds and panel_sample.rds.\n")
cat("\n=== PENSION RECORDS COMPLETE ===\n")
