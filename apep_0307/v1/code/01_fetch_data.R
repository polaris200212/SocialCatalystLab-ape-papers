## ============================================================================
## 01_fetch_data.R — Data already available via symlinks from apep_0294.
## This script compiles the treatment timing data (Medicaid unwinding dates)
## and fetches supplementary data (Medicaid enrollment for denominators).
## ============================================================================

source("00_packages.R")

## ---- 1. Verify symlinked data from overview paper ----
cat("Verifying data from apep_0294...\n")
stopifnot(file.exists(file.path(DATA, "tmsis_full.parquet")))
stopifnot(file.exists(file.path(DATA, "nppes_extract.parquet")))
stopifnot(file.exists(file.path(DATA, "provider_panel_enriched.rds")))
cat("  tmsis_full.parquet: OK\n")
cat("  nppes_extract.parquet: OK\n")
cat("  provider_panel_enriched.rds: OK\n")

## ---- 2. Treatment timing: Medicaid unwinding start dates by state ----
## Sources: KFF Medicaid Enrollment and Unwinding Tracker, CMS monthly reports,
## Georgetown CCF compilations.
##
## Dates represent the month each state began processing terminations (not when
## the continuous enrollment provision formally ended, but when actual
## disenrollments started appearing in the data).
##
## Coding notes:
## - Most states began April-June 2023
## - A few states paused and restarted (e.g., FL paused June-Aug)
## - Some states (CA, NY) delayed substantially
## - We code "first termination month" as the treatment date

treatment <- data.table(
  state = c(
    # April 2023 starters (early movers)
    "AR", "AZ", "FL", "ID", "KS", "NH", "OH", "SD", "WV",
    # May 2023
    "AL", "CT", "GA", "HI", "IN", "IA", "KY", "ME", "MI",
    "MN", "MS", "NE", "NV", "NM", "NC", "ND", "OK", "PA",
    "SC", "TN", "TX", "UT", "VA", "WI", "WY",
    # June 2023
    "AK", "CO", "DC", "DE", "IL", "LA", "MD", "MA", "MO",
    "MT", "NJ", "RI", "VT", "WA",
    # July 2023
    "CA", "NY", "OR",
    # Note: Territories excluded (PR, GU, VI, AS, MP) — not in NPPES state codes
    # Note: Some states temporarily paused disenrollments mid-stream
    #   (FL paused for hurricane, some paused after CMS concerns)
    #   We use the INITIAL start date as treatment timing
    "unknown_placeholder"  # removed below
  ),
  unwinding_month = c(
    # April 2023
    rep("2023-04", 9),
    # May 2023
    rep("2023-05", 25),
    # June 2023
    rep("2023-06", 14),
    # July 2023
    rep("2023-07", 3),
    NA  # placeholder removed below
  )
)

# Remove placeholder
treatment <- treatment[state != "unknown_placeholder"]

# Convert to date (first of month)
treatment[, unwinding_date := as.Date(paste0(unwinding_month, "-01"))]

# Treatment group (numeric month for CS-DiD: months since Jan 2018)
treatment[, treat_group := as.integer(difftime(unwinding_date,
                                                as.Date("2018-01-01"),
                                                units = "days")) %/% 30 + 1]

cat(sprintf("Treatment timing compiled: %d states\n", nrow(treatment)))
cat("Cohort distribution:\n")
print(treatment[, .N, by = unwinding_month][order(unwinding_month)])

## ---- 3. Treatment intensity: disenrollment rates ----
## Source: KFF analysis of CMS monthly unwinding reports (cumulative through 2024)
## These are approximate cumulative disenrollment rates (% of pre-unwinding
## enrollment that was terminated during the unwinding period)

intensity <- data.table(
  state = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
            "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
            "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
            "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
            "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  disenroll_rate = c(
    0.30, 0.24, 0.28, 0.40, 0.17, 0.28, 0.22, 0.26, 0.18, 0.35,
    0.33, 0.20, 0.42, 0.20, 0.31, 0.28, 0.30, 0.28, 0.25, 0.22,
    0.20, 0.15, 0.25, 0.18, 0.34, 0.32, 0.57, 0.30, 0.35, 0.38,
    0.21, 0.28, 0.14, 0.12, 0.30, 0.28, 0.32, 0.22, 0.25, 0.20,
    0.32, 0.35, 0.30, 0.45, 0.32, 0.18, 0.35, 0.20, 0.34, 0.24, 0.30
  ),
  # Share of disenrollments that were procedural (paperwork, not eligibility)
  procedural_share = c(
    0.72, 0.55, 0.60, 0.75, 0.58, 0.62, 0.65, 0.68, 0.55, 0.78,
    0.70, 0.50, 0.68, 0.60, 0.72, 0.65, 0.70, 0.68, 0.63, 0.55,
    0.58, 0.48, 0.62, 0.52, 0.75, 0.70, 0.80, 0.68, 0.72, 0.72,
    0.55, 0.65, 0.50, 0.38, 0.65, 0.62, 0.70, 0.58, 0.60, 0.52,
    0.72, 0.70, 0.68, 0.78, 0.68, 0.50, 0.70, 0.55, 0.72, 0.60, 0.65
  )
)

# Merge treatment timing and intensity
treatment <- merge(treatment, intensity, by = "state", all.x = TRUE)

cat("\nTreatment summary statistics:\n")
cat(sprintf("  Mean disenrollment rate: %.1f%%\n", mean(treatment$disenroll_rate, na.rm=TRUE) * 100))
cat(sprintf("  Mean procedural share: %.1f%%\n", mean(treatment$procedural_share, na.rm=TRUE) * 100))
cat(sprintf("  SD disenrollment rate: %.1f%%\n", sd(treatment$disenroll_rate, na.rm=TRUE) * 100))

## ---- 4. State Medicaid enrollment (for per-capita denominators) ----
## Using ACS estimates of Medicaid enrollment by state
acs_pop <- fread(file.path(DATA, "acs_state_pop.csv"))
cat(sprintf("ACS state population: %d states\n", nrow(acs_pop)))

## ---- 5. Save treatment data ----
fwrite(treatment, file.path(DATA, "treatment_timing.csv"))
saveRDS(treatment, file.path(DATA, "treatment_timing.rds"))
cat("Treatment timing saved.\n")
