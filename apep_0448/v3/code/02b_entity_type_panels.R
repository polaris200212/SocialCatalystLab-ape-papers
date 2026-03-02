## ============================================================================
## 02b_entity_type_panels.R — Build entity-type-stratified state×month panels
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- 1. Load NPI-month data and treatment timing ----
hcbs_npi <- readRDS(file.path(DATA, "hcbs_npi_month.rds"))
ui_term <- readRDS(file.path(DATA, "ui_termination.rds"))
month_to_period <- readRDS(file.path(DATA, "month_to_period.rds"))

cat("=== Entity Type Panel Construction ===\n")
cat(sprintf("Total NPI-months: %s\n", format(nrow(hcbs_npi), big.mark = ",")))
cat(sprintf("Unique NPIs: %s\n", format(uniqueN(hcbs_npi$billing_npi), big.mark = ",")))
cat("\nEntity type distribution (unique NPIs):\n")
print(hcbs_npi[, .(n_npis = uniqueN(billing_npi)), by = entity_type])

## ---- 2. Build entity-type-stratified state×month panels ----
build_entity_panel <- function(dt, type_val, type_label) {
  sub <- dt[entity_type == type_val]
  cat(sprintf("\n%s (Type %d): %s NPI-months, %s unique NPIs\n",
              type_label, type_val, format(nrow(sub), big.mark = ","),
              format(uniqueN(sub$billing_npi), big.mark = ",")))

  panel <- sub[, .(
    n_providers = uniqueN(billing_npi),
    total_paid = sum(paid),
    total_claims = sum(claims),
    total_benes = sum(benes)
  ), by = .(state, CLAIM_FROM_MONTH)]

  panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
  setorder(panel, state, month_date)

  # Merge treatment timing
  panel <- merge(panel, ui_term[, .(state, termination_date, first_full_month)],
                 by = "state", all.x = TRUE)
  panel[, early_terminator := !is.na(termination_date)]
  panel[, treated := early_terminator & month_date >= first_full_month]

  # Merge period mapping
  panel <- merge(panel, month_to_period, by = "month_date", all.x = TRUE)

  # State numeric ID (same mapping as main panel)
  panel[, state_id := as.integer(factor(state))]

  # CS-DiD group variable
  group_map <- unique(panel[early_terminator == TRUE, .(state, first_full_month)])
  group_map <- merge(group_map, month_to_period, by.x = "first_full_month",
                     by.y = "month_date")
  setnames(group_map, "period", "g_period")
  panel <- merge(panel, group_map[, .(state, g_period)],
                 by = "state", all.x = TRUE)
  panel[is.na(g_period), g_period := 0L]

  # Log outcomes
  panel[, ln_providers := log(n_providers + 1)]
  panel[, ln_claims := log(total_claims + 1)]
  panel[, ln_paid := log(total_paid + 1)]
  panel[, ln_benes := log(total_benes + 1)]

  cat(sprintf("  Panel: %d rows (%d states × %d months)\n",
              nrow(panel), uniqueN(panel$state), uniqueN(panel$month_date)))
  cat(sprintf("  Treated states: %d, Control: %d\n",
              uniqueN(panel[early_terminator == TRUE, state]),
              uniqueN(panel[early_terminator == FALSE, state])))

  panel
}

type1_panel <- build_entity_panel(hcbs_npi, 1L, "Individual")
type2_panel <- build_entity_panel(hcbs_npi, 2L, "Organization")

## ---- 3. Validate: Type 1 + Type 2 ≈ Total ----
main_panel <- readRDS(file.path(DATA, "hcbs_analysis.rds"))
# Compare a sample state-month
check_state <- "TX"
check_month <- as.Date("2021-06-01")
n_main <- main_panel[state == check_state & month_date == check_month, n_providers]
n_t1 <- type1_panel[state == check_state & month_date == check_month, n_providers]
n_t2 <- type2_panel[state == check_state & month_date == check_month, n_providers]
cat(sprintf("\nValidation (%s, %s): Main=%d, Type1=%d, Type2=%d, Sum=%d\n",
            check_state, check_month, n_main, n_t1, n_t2, n_t1 + n_t2))
# Note: Sum may slightly differ from main if any NPI has no entity_type match

## ---- 4. Pre-treatment balance by entity type ----
cat("\n=== Pre-Treatment Balance (Jan 2018 - May 2021) ===\n")
pre_t1 <- type1_panel[month_date < as.Date("2021-06-01"), .(
  mean_providers = mean(n_providers)
), by = early_terminator]
pre_t2 <- type2_panel[month_date < as.Date("2021-06-01"), .(
  mean_providers = mean(n_providers)
), by = early_terminator]

cat("Type 1 (Individual) pre-treatment means:\n")
print(pre_t1)
cat("\nType 2 (Organization) pre-treatment means:\n")
print(pre_t2)

## ---- 5. Save ----
saveRDS(type1_panel, file.path(DATA, "hcbs_type1.rds"))
saveRDS(type2_panel, file.path(DATA, "hcbs_type2.rds"))

cat("\n=== Entity type panels saved ===\n")
