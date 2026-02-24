## ============================================================================
## 02_clean_data.R — Additional cleaning, summary statistics, balance checks
## ============================================================================

source("00_packages.R")

DATA <- "../data"
panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

## ---- 1. Summary statistics ----
cat("=== Summary Statistics ===\n\n")

# Overall panel dimensions
cat(sprintf("Panel: %d states × %d service types × %d months = %d obs\n",
            uniqueN(panel$state), uniqueN(panel$service_type),
            uniqueN(panel$month_date), nrow(panel)))

# By service type
sumstats_service <- panel[, .(
  mean_paid = mean(total_paid),
  sd_paid = sd(total_paid),
  mean_claims = mean(total_claims),
  mean_providers = mean(n_providers),
  mean_beneficiaries = mean(total_beneficiaries),
  n_obs = .N
), by = service_type]

cat("\nBy service type:\n")
print(sumstats_service)

# By period
sumstats_period <- panel[, .(
  mean_paid_hcbs = mean(total_paid[service_type == "HCBS"]),
  mean_paid_bh = mean(total_paid[service_type == "BH"]),
  ratio_hcbs_bh = mean(total_paid[service_type == "HCBS"]) /
    mean(total_paid[service_type == "BH"]),
  n_months = uniqueN(month_date)
), by = post]

cat("\nBy pre/post:\n")
print(sumstats_period)

# Treatment variation
cat("\n=== Treatment Variation ===\n")
cat(sprintf("Peak stringency (April 2020):\n"))
cat(sprintf("  Mean: %.1f, SD: %.1f\n",
            mean(state_treatment$peak_stringency, na.rm = TRUE),
            sd(state_treatment$peak_stringency, na.rm = TRUE)))
cat(sprintf("  Min: %.1f (%s), Max: %.1f (%s)\n",
            min(state_treatment$peak_stringency, na.rm = TRUE),
            state_treatment[peak_stringency == min(peak_stringency, na.rm = TRUE)]$state[1],
            max(state_treatment$peak_stringency, na.rm = TRUE),
            state_treatment[peak_stringency == max(peak_stringency, na.rm = TRUE)]$state[1]))

# Quartile distribution
cat("\nStringency quartiles:\n")
q_breaks <- quantile(state_treatment$peak_stringency, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
state_treatment[, sq := cut(peak_stringency, breaks = q_breaks, include.lowest = TRUE,
                            labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)"))]
print(state_treatment[, .N, by = sq])

## ---- 2. Pre-trend check (raw means) ----
cat("\n=== Pre-Trend Diagnostics (Visual) ===\n")

# Create HCBS-BH ratio by stringency group × month
panel[, sq := cut(peak_stringency,
                  breaks = quantile(peak_stringency, probs = c(0, 0.5, 1), na.rm = TRUE),
                  include.lowest = TRUE, labels = c("Low Stringency", "High Stringency"))]

# Pre-period parallel trends: HCBS/BH ratio by stringency group
pre_trends <- panel[month_date < as.Date("2020-03-01"), .(
  mean_log_paid = mean(log_paid)
), by = .(sq, service_type, month_date)]

cat("Pre-period trends computed. See figures for visual inspection.\n")

## ---- 3. Balance table (high vs low stringency states) ----
if (file.exists(file.path(DATA, "state_pop.rds"))) {
  state_pop <- readRDS(file.path(DATA, "state_pop.rds"))
  balance <- merge(state_treatment, state_pop, by = "state", all.x = TRUE)

  # Pre-period HCBS and BH outcomes
  pre_outcomes <- panel[month_date < as.Date("2020-03-01"), .(
    pre_hcbs_paid = mean(total_paid[service_type == "HCBS"]),
    pre_bh_paid = mean(total_paid[service_type == "BH"]),
    pre_hcbs_providers = mean(n_providers[service_type == "HCBS"]),
    pre_bh_providers = mean(n_providers[service_type == "BH"])
  ), by = state]

  balance <- merge(balance, pre_outcomes, by = "state", all.x = TRUE)

  # Split by median stringency
  balance[, high_stringency := peak_stringency > median(peak_stringency, na.rm = TRUE)]

  balance_table <- balance[, .(
    pop_mean = mean(pop_total, na.rm = TRUE),
    pre_hcbs_mean = mean(pre_hcbs_paid, na.rm = TRUE),
    pre_bh_mean = mean(pre_bh_paid, na.rm = TRUE),
    pre_hcbs_prov = mean(pre_hcbs_providers, na.rm = TRUE),
    pre_bh_prov = mean(pre_bh_providers, na.rm = TRUE),
    n_states = .N
  ), by = high_stringency]

  cat("\nBalance table (high vs low stringency):\n")
  print(balance_table)

  saveRDS(balance, file.path(DATA, "balance.rds"))
}

## ---- 4. Save cleaned data with additional variables ----
saveRDS(panel, file.path(DATA, "panel_analysis.rds"))

cat("\n=== Cleaning complete ===\n")
