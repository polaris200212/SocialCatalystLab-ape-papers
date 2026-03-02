## ============================================================================
## 02_clean_data.R — Construct analysis panels
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

source("00_packages.R")
DATA <- "../data"
load(file.path(DATA, "01_raw_data.RData"))

## ---- 1. State × Category × Month Panel ----
cat("Building state × category × month panel...\n")

# Focus on BH and HCBS categories for DDD
panel_raw <- tmsis_agg[service_cat %in% c("BH", "HCBS")]

# Aggregate to state × category × month
panel <- panel_raw[, .(
  total_paid = sum(total_paid, na.rm = TRUE),
  total_claims = sum(total_claims, na.rm = TRUE),
  total_benes = sum(total_benes, na.rm = TRUE),
  n_providers = uniqueN(npi)
), by = .(state, service_cat, month)]

# Log outcomes
panel[, `:=`(
  log_paid = log(total_paid + 1),
  log_claims = log(total_claims + 1),
  log_benes = log(total_benes + 1),
  log_providers = log(n_providers + 1)
)]

# Merge unwinding treatment
panel <- merge(panel, unwinding, by = "state", all.x = TRUE)

# Treatment indicators
panel[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  # Relative time (months since unwinding start)
  rel_month = as.integer(difftime(month, unwind_start, units = "days")) %/% 30,
  # Year-month numeric for fixest
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  # State numeric ID
  state_id = as.integer(factor(state))
)]

# DDD interaction
panel[, post_bh := post * bh]
panel[, post_bh_intensity := post * bh * disenroll_rate]

cat(sprintf("Panel: %s rows\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("States: %d, Months: %d, Categories: %d\n",
            uniqueN(panel$state), uniqueN(panel$month),
            uniqueN(panel$service_cat)))

## ---- 2. Provider-Level Panel (for exit/entry analysis) ----
cat("Building provider-level panel...\n")

# Monthly provider presence
prov_panel <- tmsis_agg[service_cat %in% c("BH", "HCBS"),
                         .(total_paid = sum(total_paid),
                           total_claims = sum(total_claims)),
                         by = .(npi, service_cat, state, month)]

# Mark first and last observed month per provider
prov_panel[, `:=`(
  first_month = min(month),
  last_month = max(month)
), by = .(npi, service_cat)]

# Provider entry/exit events
prov_events <- prov_panel[, .(
  first_month = min(month),
  last_month = max(month),
  total_months = uniqueN(month),
  total_paid = sum(total_paid)
), by = .(npi, service_cat, state)]

# Merge unwinding dates
prov_events <- merge(prov_events, unwinding[, .(state, unwind_start)],
                      by = "state", all.x = TRUE)

# Classify entry/exit relative to unwinding
prov_events[, `:=`(
  entered_post = first_month >= unwind_start,
  exited_post = last_month >= unwind_start &
    last_month < as.Date("2024-12-01"),  # Not just end of data
  was_active_pre = first_month < unwind_start
)]

## ---- 3. State-level entry/exit rates by category ----
cat("Computing entry/exit rates...\n")

# Monthly exit rate: share of previously active providers not billing this month
# Create balanced month sequence
all_months <- sort(unique(panel$month))

exit_entry <- rbindlist(lapply(all_months[-1], function(m) {
  prev_m <- all_months[which(all_months == m) - 1]

  # Active providers last month
  active_prev <- prov_panel[month == prev_m, .(npi, service_cat, state)]
  # Active providers this month
  active_curr <- prov_panel[month == m, .(npi, service_cat, state)]

  # Exits: were active last month, not this month
  exits <- active_prev[!active_curr, on = .(npi, service_cat, state)]
  # Entries: active this month, not last month
  entries <- active_curr[!active_prev, on = .(npi, service_cat, state)]

  # Rates by state × category
  base_counts <- active_prev[, .(n_prev = .N), by = .(state, service_cat)]
  exit_counts <- exits[, .(n_exit = .N), by = .(state, service_cat)]
  entry_counts <- entries[, .(n_entry = .N), by = .(state, service_cat)]

  result <- merge(base_counts, exit_counts, by = c("state", "service_cat"),
                   all.x = TRUE)
  result <- merge(result, entry_counts, by = c("state", "service_cat"),
                   all.x = TRUE)
  result[is.na(n_exit), n_exit := 0]
  result[is.na(n_entry), n_entry := 0]
  result[, `:=`(
    month = m,
    exit_rate = n_exit / n_prev,
    entry_rate = n_entry / n_prev,
    net_entry_rate = (n_entry - n_exit) / n_prev
  )]
  result
}))

# Merge unwinding treatment onto exit/entry panel
exit_entry <- merge(exit_entry, unwinding, by = "state", all.x = TRUE)
exit_entry[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  rel_month = as.integer(difftime(month, unwind_start, units = "days")) %/% 30,
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]
exit_entry[, post_bh := post * bh]

## ---- 4. HHI (market concentration) panel ----
cat("Computing HHI...\n")

# Provider market shares within state × category × month
hhi_panel <- prov_panel[, .(provider_paid = sum(total_paid)),
                         by = .(state, service_cat, month, npi)]
hhi_panel[, state_cat_total := sum(provider_paid),
           by = .(state, service_cat, month)]
hhi_panel[, market_share := provider_paid / state_cat_total]
hhi_panel[, hhi_contribution := market_share^2]

# Aggregate HHI
hhi_state <- hhi_panel[, .(
  hhi = sum(hhi_contribution),
  n_providers = uniqueN(npi)
), by = .(state, service_cat, month)]

# Merge treatment
hhi_state <- merge(hhi_state, unwinding, by = "state", all.x = TRUE)
hhi_state[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  rel_month = as.integer(difftime(month, unwind_start, units = "days")) %/% 30,
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  state_id = as.integer(factor(state)),
  log_hhi = log(hhi + 0.0001)
)]
hhi_state[, post_bh := post * bh]

## ---- 5. Add CPT panel for placebo ----
cat("Building CPT placebo panel...\n")

panel_cpt <- tmsis_agg[service_cat == "CPT",
                        .(total_paid = sum(total_paid, na.rm = TRUE),
                          total_claims = sum(total_claims, na.rm = TRUE),
                          n_providers = uniqueN(npi)),
                        by = .(state, month)]
panel_cpt[, service_cat := "CPT"]
panel_cpt[, `:=`(
  log_paid = log(total_paid + 1),
  log_claims = log(total_claims + 1),
  log_providers = log(n_providers + 1)
)]

panel_cpt <- merge(panel_cpt, unwinding, by = "state", all.x = TRUE)
panel_cpt[, `:=`(
  post = as.integer(month >= unwind_start),
  rel_month = as.integer(difftime(month, unwind_start, units = "days")) %/% 30,
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]

## ---- 6. Summary statistics ----
cat("\n=== Summary Statistics ===\n")

cat("\nBH vs HCBS provider counts (pre-unwinding average):\n")
pre_summary <- panel[post == 0, .(
  mean_providers = mean(n_providers),
  mean_paid = mean(total_paid),
  mean_claims = mean(total_claims)
), by = service_cat]
print(pre_summary)

cat("\nBH vs HCBS provider counts (post-unwinding average):\n")
post_summary <- panel[post == 1, .(
  mean_providers = mean(n_providers),
  mean_paid = mean(total_paid),
  mean_claims = mean(total_claims)
), by = service_cat]
print(post_summary)

## ---- 7. Save analysis data ----
save(panel, exit_entry, hhi_state, panel_cpt, prov_events, unwinding,
     all_months, census_pop, unemp,
     file = file.path(DATA, "02_analysis_data.RData"))
cat("\nSaved: 02_analysis_data.RData\n")
