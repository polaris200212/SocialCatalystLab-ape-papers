## ============================================================================
## 04e_spillovers.R — Household Spillover Effects
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## Pension income to the veteran may affect labor supply of other household
## members: wives may reduce market work (income effect), or adult children
## may change labor supply. We test for spillovers by examining labor outcomes
## of co-resident household members at the veteran's age-62 threshold.
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load full census data ----
all_data <- readRDS(file.path(data_dir, "census_1910_veterans.rds"))
union_vets <- all_data[union_veteran == 1]

cat("=== Household Spillover Analysis ===\n")
cat("Union veteran households:", format(length(unique(union_vets$SERIAL)), big.mark = ","), "\n")

## ---- 2. Identify household members of Union veterans ----
# Load the full raw data to find non-veteran household members
# For census data: use the already-filtered males 45-90 dataset
# We need the FULL household — reload with broader criteria

# Strategy: use SERIAL (household ID) to link veterans to their household
# The census_1910_veterans.rds already has SERIAL for all males 45-90
# We need other household members (wives, children)

# Since we only have males 45-90 in our filtered dataset, we need to reload
# raw data. However, for memory efficiency, we'll load the full extract
# and keep only households containing Union veterans.

vet_serials <- unique(union_vets$SERIAL)
cat("Unique veteran household serials:", format(length(vet_serials), big.mark = ","), "\n")

# Re-read raw data, filtering to veteran households only
cat("Loading raw data for veteran households...\n")

extract_dir <- file.path(data_dir, "1910_census")
if (!dir.exists(extract_dir)) extract_dir <- data_dir

ddi_file <- list.files(extract_dir, pattern = "\\.xml$", full.names = TRUE)[1]
dat_file <- list.files(extract_dir, pattern = "\\.(csv\\.gz|dat\\.gz)$", full.names = TRUE)[1]

if (!is.na(ddi_file) && !is.na(dat_file)) {
  ddi <- read_ipums_ddi(ddi_file)
  raw <- read_ipums_micro(ddi, verbose = TRUE)
  setDT(raw)

  # Filter to veteran households only
  hh_members <- raw[SERIAL %in% vet_serials]
  cat("Household members in veteran HHs:", format(nrow(hh_members), big.mark = ","), "\n")
  rm(raw)
  gc()

  # Add veteran's age to each household
  vet_ages <- union_vets[, .(vet_age = AGE[1], vet_age_centered = age_centered[1],
                              vet_above_62 = above_62[1]), by = SERIAL]
  hh_members <- merge(hh_members, vet_ages, by = "SERIAL", all.x = TRUE)

  ## ---- 3. Identify spouses (wives) ----
  cat("\n--- Spouse Analysis ---\n")

  # RELATE: 2 = Spouse; SEX: 2 = Female
  wives <- hh_members[SEX == 2 & RELATE == 2]
  cat("Wives of Union veterans:", format(nrow(wives), big.mark = ","), "\n")

  # Construct wife outcomes
  wives[, in_labor_force := as.integer(LABFORCE == 2)]
  wives[, has_occupation := as.integer(OCC1950 < 980)]

  # RDD at VETERAN'S age 62 on WIFE's labor supply
  spillover_results <- list()

  if (nrow(wives) >= 200) {
    tryCatch({
      rd_wife_lfp <- rdrobust(wives$in_labor_force, wives$vet_age, c = 62,
                               kernel = "triangular", p = 1)
      spillover_results$wife_lfp <- rd_wife_lfp

      cat("  Wife LFP at vet age 62:", round(rd_wife_lfp$coef["Conventional", 1], 4),
          "(SE:", round(rd_wife_lfp$se["Conventional", 1], 4),
          "), N:", rd_wife_lfp$N_h[1], "+", rd_wife_lfp$N_h[2], "\n")
    }, error = function(e) cat("  Wife LFP RDD: ERROR\n"))

    tryCatch({
      rd_wife_occ <- rdrobust(wives$has_occupation, wives$vet_age, c = 62,
                               kernel = "triangular", p = 1)
      spillover_results$wife_occ <- rd_wife_occ
      cat("  Wife occupation:", round(rd_wife_occ$coef["Conventional", 1], 4), "\n")
    }, error = function(e) cat("  Wife occupation RDD: ERROR\n"))
  } else {
    cat("  Too few wives for reliable RDD\n")
  }

  ## ---- 4. Children in household ----
  cat("\n--- Children Analysis ---\n")

  # Adult children (age 18+) living with veteran
  # RELATE: 3 = Child
  children <- hh_members[RELATE == 3 & AGE >= 18 & AGE <= 50]
  cat("Adult children (18-50) in veteran HHs:", format(nrow(children), big.mark = ","), "\n")

  children[, in_labor_force := as.integer(LABFORCE == 2)]

  if (nrow(children) >= 200) {
    tryCatch({
      rd_child_lfp <- rdrobust(children$in_labor_force, children$vet_age, c = 62,
                                kernel = "triangular", p = 1)
      spillover_results$child_lfp <- rd_child_lfp

      cat("  Child LFP at vet age 62:", round(rd_child_lfp$coef["Conventional", 1], 4),
          "(SE:", round(rd_child_lfp$se["Conventional", 1], 4),
          "), N:", rd_child_lfp$N_h[1], "+", rd_child_lfp$N_h[2], "\n")
    }, error = function(e) cat("  Child LFP RDD: ERROR\n"))
  } else {
    cat("  Too few adult children for reliable RDD\n")
  }

  ## ---- 5. Household-level outcomes ----
  cat("\n--- Household-Level Outcomes ---\n")

  # Household size, total earners, any female employment
  hh_summary <- hh_members[, .(
    hh_size = .N,
    n_earners = sum(LABFORCE == 2, na.rm = TRUE),
    any_female_work = as.integer(any(SEX == 2 & LABFORCE == 2, na.rm = TRUE)),
    n_children = sum(RELATE == 3),
    n_adults = sum(AGE >= 18)
  ), by = .(SERIAL, vet_age, vet_above_62)]

  for (outcome_name in c("n_earners", "hh_size", "any_female_work")) {
    tryCatch({
      rd <- rdrobust(hh_summary[[outcome_name]], hh_summary$vet_age, c = 62,
                      kernel = "triangular", p = 1)
      spillover_results[[paste0("hh_", outcome_name)]] <- rd

      cat(sprintf("  %-25s: coef = %7.4f (SE = %6.4f), N = %d + %d\n",
                  outcome_name, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                  rd$N_h[1], rd$N_h[2]))
    }, error = function(e) {
      cat(sprintf("  %-25s: ERROR\n", outcome_name))
    })
  }

  ## ---- 6. Summary table for spillovers ----
  spillover_table <- data.table(
    outcome = character(),
    sample = character(),
    coef = numeric(),
    se = numeric(),
    pvalue = numeric(),
    n_left = numeric(),
    n_right = numeric()
  )

  for (nm in names(spillover_results)) {
    rd <- spillover_results[[nm]]
    if (inherits(rd, "rdrobust")) {
      spillover_table <- rbind(spillover_table, data.table(
        outcome = nm,
        sample = ifelse(grepl("wife", nm), "Wives",
                        ifelse(grepl("child", nm), "Children", "Household")),
        coef = rd$coef["Conventional", 1],
        se = rd$se["Conventional", 1],
        pvalue = rd$pv["Conventional", 1],
        n_left = rd$N_h[1],
        n_right = rd$N_h[2]
      ))
    }
  }

  saveRDS(spillover_results, file.path(data_dir, "spillover_results.rds"))
  saveRDS(spillover_table, file.path(data_dir, "spillover_table.rds"))

  rm(hh_members, wives, children, hh_summary)
  gc()
} else {
  cat("Raw data files not found for spillover analysis.\n")
}

rm(all_data)
gc()

cat("\nSpillover analysis complete.\n")
