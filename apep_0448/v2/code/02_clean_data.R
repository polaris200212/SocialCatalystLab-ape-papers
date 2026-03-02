## ============================================================================
## 02_clean_data.R — Variable construction and panel preparation
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"
panel <- readRDS(file.path(DATA, "panel.rds"))
ui_term <- readRDS(file.path(DATA, "ui_termination.rds"))

cat(sprintf("Panel loaded: %d rows\n", nrow(panel)))

## ---- 1. Create analysis variables ----

# Relative time (months since first full treatment month)
panel[early_terminator == TRUE, rel_time := as.integer(
  round(difftime(month_date, first_full_month, units = "days") / 30.44)
)]
panel[early_terminator == FALSE, rel_time := NA_integer_]

# For event study with never-treated: assign relative time using July 2021 as reference
panel[, rel_time_ref := as.integer(
  round(difftime(month_date, as.Date("2021-07-01"), units = "days") / 30.44)
)]

# Year and month components
panel[, year := year(month_date)]
panel[, month := month(month_date)]

# State numeric ID
panel[, state_id := as.integer(factor(state))]

# Pre-treatment average (Jan 2018 - May 2021) for normalization
pre_means <- panel[month_date < as.Date("2021-06-01"),
                   .(pre_mean_providers = mean(n_providers),
                     pre_mean_claims = mean(total_claims),
                     pre_mean_paid = mean(total_paid),
                     pre_mean_benes = mean(total_benes)),
                   by = .(state, service_type)]

panel <- merge(panel, pre_means, by = c("state", "service_type"), all.x = TRUE)

# Normalized outcomes (relative to pre-treatment mean)
panel[, norm_providers := n_providers / pmax(pre_mean_providers, 1)]
panel[, norm_claims := total_claims / pmax(pre_mean_claims, 1)]
panel[, norm_paid := total_paid / pmax(pre_mean_paid, 1)]
panel[, norm_benes := total_benes / pmax(pre_mean_benes, 1)]

## ---- 2. State characteristics for balance table ----
hcbs_pre <- panel[service_type == "HCBS" & month_date < as.Date("2020-03-01"), .(
  mean_providers = mean(n_providers),
  mean_claims = mean(total_claims),
  mean_paid = mean(total_paid),
  mean_benes = mean(total_benes)
), by = .(state, early_terminator)]

# Medicaid expansion status
expansion_states <- c("AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "HI",
                      "IL", "IN", "IA", "KY", "LA", "ME", "MD", "MA", "MI",
                      "MN", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "ND",
                      "OH", "OK", "OR", "PA", "RI", "VA", "VT", "WA", "WV")
hcbs_pre[, medicaid_expansion := state %in% expansion_states]

saveRDS(hcbs_pre, file.path(DATA, "state_characteristics.rds"))

## ---- 3. Create HCBS-only panel for main analysis ----
hcbs_main <- panel[service_type == "HCBS"]

# For CS-DiD: need group variable (first treated period, 0 for never-treated)
# Convert month_date to integer period for did package
all_months <- sort(unique(hcbs_main$month_date))
month_to_period <- data.table(month_date = all_months, period = seq_along(all_months))
hcbs_main <- merge(hcbs_main, month_to_period, by = "month_date")

# Group variable: period of first full treatment month (0 for never-treated)
group_map <- unique(hcbs_main[early_terminator == TRUE, .(state, first_full_month)])
group_map <- merge(group_map, month_to_period, by.x = "first_full_month", by.y = "month_date")
setnames(group_map, "period", "g_period")
hcbs_main <- merge(hcbs_main, group_map[, .(state, g_period)],
                    by = "state", all.x = TRUE)
hcbs_main[is.na(g_period), g_period := 0L]

cat(sprintf("HCBS main panel: %d rows\n", nrow(hcbs_main)))
cat(sprintf("Treatment groups: %s\n", paste(sort(unique(hcbs_main[g_period > 0, g_period])), collapse = ", ")))
cat(sprintf("Never-treated: %d states\n", uniqueN(hcbs_main[g_period == 0, state])))

## ---- 4. Create BH panel for placebo ----
bh_main <- panel[service_type == "BH"]
bh_main <- merge(bh_main, month_to_period, by = "month_date")
bh_main <- merge(bh_main, group_map[, .(state, g_period)],
                  by = "state", all.x = TRUE)
bh_main[is.na(g_period), g_period := 0L]

## ---- 5. Summary statistics ----
cat("\n=== Summary Statistics ===\n")
cat("\nHCBS panel by treatment status:\n")
print(hcbs_main[, .(
  states = uniqueN(state),
  months = uniqueN(month_date),
  mean_providers = round(mean(n_providers), 0),
  mean_claims = round(mean(total_claims), 0),
  mean_paid_M = round(mean(total_paid) / 1e6, 1),
  mean_benes = round(mean(total_benes), 0)
), by = early_terminator])

## ---- 6. Save analysis-ready data ----
saveRDS(hcbs_main, file.path(DATA, "hcbs_analysis.rds"))
saveRDS(bh_main, file.path(DATA, "bh_analysis.rds"))
saveRDS(month_to_period, file.path(DATA, "month_to_period.rds"))

cat("\n=== Data cleaning complete ===\n")
