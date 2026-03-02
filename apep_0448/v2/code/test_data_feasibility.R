## Quick feasibility check: Can we measure HCBS provider activity by state × month?
source("00_packages.R")

SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")

cat("Opening T-MSIS...\n")
tmsis_ds <- open_dataset(tmsis_path)
cat(sprintf("Schema: %s\n", paste(names(tmsis_ds), collapse = ", ")))

cat("Loading NPPES...\n")
nppes <- as.data.table(read_parquet(nppes_path))
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

# Quick test: HCBS (T-code) providers by state × month, 2020-2022
cat("\nQuerying HCBS T-code billing by state × month (2020-2022)...\n")
hcbs_monthly <- tmsis_ds |>
  filter(
    substr(HCPCS_CODE, 1, 1) == "T",
    CLAIM_FROM_MONTH >= "2020-01",
    CLAIM_FROM_MONTH <= "2022-12"
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    paid = sum(TOTAL_PAID, na.rm = TRUE),
    claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(hcbs_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("HCBS provider-months: %s\n", format(nrow(hcbs_monthly), big.mark = ",")))

# Join state (ensure NPI types match)
nppes[, npi := as.character(npi)]
npi_state <- nppes[!is.na(state) & state != "", .(npi, state)]
hcbs_monthly <- merge(hcbs_monthly, npi_state, by.x = "billing_npi", by.y = "npi", all.x = TRUE)
cat(sprintf("State match rate: %.1f%%\n", 100 * mean(!is.na(hcbs_monthly$state))))

# Collapse to state × month
panel <- hcbs_monthly[!is.na(state), .(
  n_providers = uniqueN(billing_npi),
  total_paid = sum(paid),
  total_claims = sum(claims),
  total_benes = sum(benes)
), by = .(state, CLAIM_FROM_MONTH)]

setorder(panel, state, CLAIM_FROM_MONTH)
cat(sprintf("\nState × month panel: %d rows, %d states\n", nrow(panel), uniqueN(panel$state)))

# Show a few states around the June 2021 early termination
cat("\n=== Sample: Texas (early terminator, June 26) vs California (kept benefits) ===\n")
for (st in c("TX", "CA")) {
  sub <- panel[state == st & CLAIM_FROM_MONTH >= "2021-03" & CLAIM_FROM_MONTH <= "2021-12"]
  cat(sprintf("\n%s:\n", st))
  print(sub[, .(month = CLAIM_FROM_MONTH, providers = n_providers, paid_M = round(total_paid / 1e6, 1))])
}

cat("\n=== FEASIBILITY CONFIRMED ===\n")
