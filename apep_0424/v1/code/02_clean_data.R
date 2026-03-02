## ============================================================================
## 02_clean_data.R -- Build state x quarter analysis panel
## ============================================================================

source("00_packages.R")
DATA <- "../data"

bh_monthly <- readRDS(file.path(DATA, "bh_provider_monthly.rds"))
npi_state <- readRDS(file.path(DATA, "npi_state.rds"))
parity_dates <- readRDS(file.path(DATA, "parity_dates.rds"))

## 1. Merge provider-month data with state
bh_monthly[, billing_npi := as.character(billing_npi)]
npi_state[, npi := as.character(npi)]

panel_raw <- merge(bh_monthly, npi_state[, .(npi, state)],
                   by.x = "billing_npi", by.y = "npi", all.x = TRUE)

cat(sprintf("Match rate: %.1f%%\n", 100 * mean(!is.na(panel_raw$state))))

valid_states <- c(state.abb, "DC")
panel_raw <- panel_raw[state %in% valid_states]

## 2. State x month x service panel
state_month <- panel_raw[, .(
  total_paid       = sum(total_paid, na.rm = TRUE),
  total_claims     = sum(total_claims, na.rm = TRUE),
  total_beneficiaries = sum(total_beneficiaries, na.rm = TRUE),
  n_providers      = uniqueN(billing_npi)
), by = .(state, year, month_num, claim_month, service_type)]

state_month[, month_date := as.Date(paste0(claim_month, "-01"))]
state_month[, state_id := as.integer(factor(state))]

## 3. Collapse to quarterly panel
state_month[, quarter := ceiling(month_num / 3)]
panel_q <- state_month[, .(
  n_providers        = mean(n_providers),
  total_claims       = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  total_paid         = sum(total_paid)
), by = .(state, state_id, year, quarter, service_type)]

panel_q[, time_q := (year - 2018) * 4 + quarter]
panel_q[, ln_providers := log(n_providers + 1)]
panel_q[, ln_claims := log(total_claims + 1)]
panel_q[, ln_beneficiaries := log(total_beneficiaries + 1)]
panel_q[, ln_paid := log(total_paid + 1)]

## 4. Merge treatment variable
panel_q <- merge(panel_q, parity_dates[, .(state, first_treat_q)],
                 by = "state", all.x = TRUE)
panel_q[is.na(first_treat_q), first_treat_q := 0]
panel_q[, post := as.integer(first_treat_q > 0 & time_q >= first_treat_q)]
panel_q[, treated_state := as.integer(first_treat_q > 0)]

## 5. Add unemployment
if (file.exists(file.path(DATA, "state_unemployment.rds"))) {
  unemp <- readRDS(file.path(DATA, "state_unemployment.rds"))
  unemp_q <- unemp[, .(unemp_rate = mean(unemp_rate, na.rm = TRUE)),
                    by = .(state, year, quarter = ceiling(month_num / 3))]
  panel_q <- merge(panel_q, unemp_q, by = c("state", "year", "quarter"), all.x = TRUE)
}

## 6. Separate panels
panel_bh <- panel_q[service_type == "behavioral_health"]
panel_pc <- panel_q[service_type == "personal_care"]

# Balance check: keep states present >= 20 quarters
bh_counts <- panel_bh[, .N, by = state]
panel_bh <- panel_bh[state %in% bh_counts[N >= 20]$state]

pc_counts <- panel_pc[, .N, by = state]
panel_pc <- panel_pc[state %in% pc_counts[N >= 20]$state]

cat(sprintf("\nBH panel: %d state-quarters, %d states (%d treated, %d control)\n",
            nrow(panel_bh), uniqueN(panel_bh$state),
            uniqueN(panel_bh[treated_state == 1]$state),
            uniqueN(panel_bh[treated_state == 0]$state)))
cat(sprintf("PC panel: %d state-quarters, %d states\n",
            nrow(panel_pc), uniqueN(panel_pc$state)))

saveRDS(panel_q, file.path(DATA, "panel_full.rds"))
saveRDS(panel_bh, file.path(DATA, "panel_bh.rds"))
saveRDS(panel_pc, file.path(DATA, "panel_pc.rds"))
saveRDS(state_month, file.path(DATA, "state_month.rds"))

cat("\n=== Data cleaning complete ===\n")
