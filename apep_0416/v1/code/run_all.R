## ============================================================================
## run_all.R — Complete analysis pipeline using pre-merged data
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

library(data.table)
library(dplyr)
library(tidyr)
library(fixest)
library(did)
library(ggplot2)
library(scales)
library(patchwork)
library(modelsummary)
library(kableExtra)
library(bacondecomp)

options(scipen = 999)
setFixest_nthreads(4)

# APEP theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40", size = base_size),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(color = "gray50", hjust = 0)
    )
}
theme_set(theme_apep())

apep_colors <- c("Behavioral Health" = "#E63946", "HCBS" = "#457B9D",
                  "CPT/Other" = "#A8DADC", "BH" = "#E63946", "HCBS" = "#457B9D")

DATA <- "../data"
FIGS <- "../figures"
TABS <- "../tables"
dir.create(FIGS, showWarnings = FALSE, recursive = TRUE)
dir.create(TABS, showWarnings = FALSE, recursive = TRUE)

## ========== PHASE 1: LOAD DATA ==========
cat("=== Phase 1: Loading Data ===\n")

tmsis_agg <- fread(file.path(DATA, "bh_hcbs_npi.csv"))
tmsis_agg[, month := as.Date(paste0(month, "-01"))]
tmsis_agg[, npi := as.character(npi)]
# Truncate at Oct 2024 to exclude incomplete months (Nov-Dec 2024 have claims runout)
tmsis_agg <- tmsis_agg[month <= as.Date("2024-10-01")]
cat(sprintf("BH+HCBS: %s rows, %d states, %d months (truncated at Oct 2024)\n",
            format(nrow(tmsis_agg), big.mark = ","),
            uniqueN(tmsis_agg$state), uniqueN(tmsis_agg$month)))

# Pre-aggregated CPT data for placebo
cpt_data <- fread(file.path(DATA, "cpt_state_month.csv"))
cpt_data[, month := as.Date(paste0(month, "-01"))]
cpt_data <- cpt_data[month <= as.Date("2024-10-01")]
cat(sprintf("CPT: %s state-months\n", format(nrow(cpt_data), big.mark = ",")))

# Unwinding treatment data
unwinding <- data.table(
  state = c("AR","AZ","FL","ID","KS","NH","OH","SD","WV",
            "AL","CT","GA","IN","IA","ME","MI","MS","NE","NV","NM","NC","ND","OK","PA","RI","SC","TN","TX","UT","VT","VA","WI","WY",
            "AK","CO","DE","HI","IL","KY","LA","MD","MA","MN","MO","MT","NJ","NY","OR","WA","DC",
            "CA"),
  unwind_start = as.Date(c(rep("2023-04-01",9), rep("2023-05-01",24), rep("2023-06-01",17), rep("2023-07-01",1))),
  disenroll_rate = c(0.45,0.42,0.48,0.46,0.37,0.42,0.40,0.50,0.45,
                     0.38,0.28,0.43,0.40,0.33,0.27,0.35,0.40,0.35,0.43,0.30,0.12,0.35,0.38,0.33,0.30,0.42,0.45,0.50,0.38,0.22,0.40,0.35,0.42,
                     0.25,0.30,0.35,0.18,0.32,0.35,0.38,0.30,0.22,0.25,0.38,0.57,0.28,0.18,0.26,0.20,0.20,
                     0.22),
  procedural_share = c(0.82,0.65,0.78,0.80,0.68,0.73,0.68,0.78,0.75,
                       0.72,0.48,0.75,0.70,0.55,0.50,0.60,0.72,0.62,0.70,0.55,0.30,0.58,0.65,0.55,0.52,0.72,0.75,0.80,0.68,0.40,0.62,0.58,0.70,
                       0.55,0.50,0.62,0.42,0.58,0.60,0.65,0.52,0.38,0.45,0.65,0.85,0.48,0.35,0.48,0.38,0.40,
                       0.45)
)

## ========== PHASE 2: BUILD PANELS ==========
cat("\n=== Phase 2: Building Panels ===\n")

# State × Category × Month panel (BH and HCBS)
panel <- tmsis_agg[service_cat %in% c("BH", "HCBS"),
  .(total_paid = sum(total_paid, na.rm = TRUE),
    total_claims = sum(total_claims, na.rm = TRUE),
    total_benes = sum(total_benes, na.rm = TRUE),
    n_providers = uniqueN(npi)),
  by = .(state, service_cat, month)]

panel[, `:=`(log_paid = log(total_paid + 1),
             log_claims = log(total_claims + 1),
             log_providers = log(n_providers + 1))]

stopifnot(uniqueN(unwinding$state) == nrow(unwinding))  # no dupes
panel <- merge(panel, unwinding, by = "state", all.x = TRUE)
panel[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  rel_month = as.integer(difftime(month, unwind_start, units = "days")) %/% 30,
  year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]
panel[, `:=`(post_bh = post * bh,
             post_bh_intensity = post * bh * disenroll_rate)]

cat(sprintf("Panel: %s rows, %d states × %d categories × %d months\n",
            format(nrow(panel), big.mark = ","),
            uniqueN(panel$state), uniqueN(panel$service_cat), uniqueN(panel$month)))

# CPT panel for placebo (pre-aggregated)
panel_cpt <- copy(cpt_data)
panel_cpt[, `:=`(log_paid = log(total_paid + 1),
                  log_claims = log(total_claims + 1),
                  log_providers = log(n_providers + 1))]
panel_cpt <- merge(panel_cpt, unwinding, by = "state", all.x = TRUE)
panel_cpt[, `:=`(
  post = as.integer(month >= unwind_start),
  year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]

# Exit/Entry panel
cat("Computing exit/entry rates...\n")
prov_panel <- tmsis_agg[service_cat %in% c("BH", "HCBS"),
  .(total_paid = sum(total_paid), total_claims = sum(total_claims)),
  by = .(npi, service_cat, state, month)]

all_months <- sort(unique(panel$month))
exit_entry <- rbindlist(lapply(all_months[-1], function(m) {
  prev_m <- all_months[which(all_months == m) - 1]
  active_prev <- prov_panel[month == prev_m, .(npi, service_cat, state)]
  active_curr <- prov_panel[month == m, .(npi, service_cat, state)]
  exits <- active_prev[!active_curr, on = .(npi, service_cat, state)]
  entries <- active_curr[!active_prev, on = .(npi, service_cat, state)]
  base <- active_prev[, .(n_prev = .N), by = .(state, service_cat)]
  exit_n <- exits[, .(n_exit = .N), by = .(state, service_cat)]
  entry_n <- entries[, .(n_entry = .N), by = .(state, service_cat)]
  res <- merge(base, exit_n, by = c("state", "service_cat"), all.x = TRUE)
  res <- merge(res, entry_n, by = c("state", "service_cat"), all.x = TRUE)
  res[is.na(n_exit), n_exit := 0]
  res[is.na(n_entry), n_entry := 0]
  res[, `:=`(month = m, exit_rate = n_exit/n_prev, entry_rate = n_entry/n_prev,
             net_entry_rate = (n_entry - n_exit)/n_prev)]
  res
}))

exit_entry <- merge(exit_entry, unwinding, by = "state", all.x = TRUE)
exit_entry[, `:=`(post = as.integer(month >= unwind_start),
                   bh = as.integer(service_cat == "BH"),
                   year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
                   state_id = as.integer(factor(state)))]
exit_entry[, post_bh := post * bh]

# HHI panel
cat("Computing HHI...\n")
hhi_raw <- prov_panel[, .(paid = sum(total_paid)), by = .(state, service_cat, month, npi)]
hhi_raw[, total := sum(paid), by = .(state, service_cat, month)]
hhi_raw[, share := paid / total]
hhi_state <- hhi_raw[, .(hhi = sum(share^2), n_providers = uniqueN(npi)),
                      by = .(state, service_cat, month)]
hhi_state <- merge(hhi_state, unwinding, by = "state", all.x = TRUE)
hhi_state[, `:=`(post = as.integer(month >= unwind_start),
                  bh = as.integer(service_cat == "BH"),
                  year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
                  log_hhi = log(hhi + 0.0001))]
hhi_state[, post_bh := post * bh]

## ========== PHASE 3: MAIN ANALYSIS ==========
cat("\n=== Phase 3: Main Analysis ===\n")

# DDD: log(paid)
ddd_paid <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                  data = panel, cluster = ~state)
cat("DDD log_paid:\n"); print(summary(ddd_paid))

# DDD: log(claims)
ddd_claims <- feols(log_claims ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                    data = panel, cluster = ~state)

# DDD: log(providers)
ddd_providers <- feols(log_providers ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                       data = panel, cluster = ~state)

# DDD with intensity
ddd_intensity <- feols(log_paid ~ post_bh + post_bh_intensity | state^year_month + service_cat^year_month + state^service_cat,
                       data = panel, cluster = ~state)

# Event study
panel[, event_time := rel_month]
panel[event_time < -24, event_time := -24]
panel[event_time > 18, event_time := 18]

es_model <- feols(log_paid ~ i(event_time, bh, ref = -1) | state^year_month + service_cat^year_month + state^service_cat,
                  data = panel, cluster = ~state)

# Exit/entry DDD
ddd_exit <- feols(exit_rate ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                  data = exit_entry[!is.na(exit_rate)], cluster = ~state)

ddd_entry <- feols(net_entry_rate ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                   data = exit_entry[!is.na(net_entry_rate)], cluster = ~state)

# HHI DDD
ddd_hhi <- feols(log_hhi ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                 data = hhi_state, cluster = ~state)

# Within-BH intensity DiD
bh_only <- panel[service_cat == "BH"]
did_bh_intensity <- feols(log_paid ~ post:disenroll_rate | state + year_month,
                          data = bh_only, cluster = ~state)

## ========== PHASE 4: ROBUSTNESS ==========
cat("\n=== Phase 4: Robustness ===\n")

# Placebo: BH vs CPT
panel_bh_cpt <- rbind(
  panel[service_cat == "BH", .(state, month, log_paid, year_month, state_id, unwind_start, service_cat)],
  panel_cpt[, .(state, month, log_paid, year_month, state_id, unwind_start, service_cat)]
)
panel_bh_cpt[, `:=`(post = as.integer(month >= unwind_start),
                     bh = as.integer(service_cat == "BH"))]
panel_bh_cpt[, post_bh := post * bh]

placebo_ddd <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                     data = panel_bh_cpt, cluster = ~state)

# Heterogeneity by entity type
panel_indiv <- tmsis_agg[service_cat %in% c("BH","HCBS") & entity_type == "1",
  .(total_paid = sum(total_paid)), by = .(state, service_cat, month)]
panel_indiv[, log_paid := log(total_paid + 1)]
panel_indiv <- merge(panel_indiv, unwinding, by = "state", all.x = TRUE)
panel_indiv[, `:=`(post = as.integer(month >= unwind_start), bh = as.integer(service_cat == "BH"),
                    year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
                    post_bh = as.integer(month >= unwind_start) * as.integer(service_cat == "BH"))]

ddd_indiv <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                   data = panel_indiv, cluster = ~state)

panel_org <- tmsis_agg[service_cat %in% c("BH","HCBS") & entity_type == "2",
  .(total_paid = sum(total_paid)), by = .(state, service_cat, month)]
panel_org[, log_paid := log(total_paid + 1)]
panel_org <- merge(panel_org, unwinding, by = "state", all.x = TRUE)
panel_org[, `:=`(post = as.integer(month >= unwind_start), bh = as.integer(service_cat == "BH"),
                  year_month = as.integer(format(month, "%Y")) * 12 + as.integer(format(month, "%m")),
                  post_bh = as.integer(month >= unwind_start) * as.integer(service_cat == "BH"))]

ddd_org <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                 data = panel_org, cluster = ~state)

# Procedural share heterogeneity
med_proc <- median(unwinding$procedural_share, na.rm = TRUE)
panel[, high_proc := procedural_share > med_proc]

ddd_high <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                  data = panel[high_proc == TRUE], cluster = ~state)
ddd_low <- feols(log_paid ~ post_bh | state^year_month + service_cat^year_month + state^service_cat,
                 data = panel[high_proc == FALSE], cluster = ~state)

# Pre-trend falsification: test differential trend between BH and HCBS pre-unwinding
panel_pre <- panel[month < as.Date("2023-04-01")]
panel_pre[, `:=`(fake_post = as.integer(month >= as.Date("2021-04-01")),
                  fake_post_bh = as.integer(month >= as.Date("2021-04-01")) * bh)]
# Use state + year_month + service_cat additive FE (interaction FE absorb the variable)
ddd_pretrend <- feols(log_paid ~ fake_post_bh + fake_post + bh | state + year_month,
                      data = panel_pre, cluster = ~state)

# Randomization inference
cat("Running randomization inference...\n")
set.seed(42)
n_perms <- 500
obs_coef <- coef(ddd_paid)["post_bh"]
states <- unique(panel$state)
perm_coefs <- numeric(n_perms)

for (i in 1:n_perms) {
  shuffled <- unwinding[sample(.N)]
  pmap <- data.table(state = states, fake_start = shuffled$unwind_start[1:length(states)])
  pp <- merge(panel, pmap, by = "state")
  pp[, `:=`(fp = as.integer(month >= fake_start), fpbh = as.integer(month >= fake_start) * bh)]
  mod <- tryCatch(
    feols(log_paid ~ fpbh | state^year_month + service_cat^year_month + state^service_cat,
          data = pp, cluster = ~state),
    error = function(e) NULL)
  perm_coefs[i] <- if (!is.null(mod)) coef(mod)["fpbh"] else NA
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(obs_coef), na.rm = TRUE)
cat(sprintf("RI p-value: %.4f (obs coef: %.4f)\n", ri_pvalue, obs_coef))

## ========== PHASE 5: FIGURES ==========
cat("\n=== Phase 5: Figures ===\n")

# Fig 1: Spending trends
trends <- panel[, .(total_paid = sum(total_paid) / 1e9), by = .(service_cat, month)]
p1 <- ggplot(trends, aes(x = month, y = total_paid, color = service_cat)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", color = "gray40") +
  annotate("text", x = as.Date("2023-06-01"), y = max(trends$total_paid) * 0.9,
           label = "Unwinding\nbegins", hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(values = apep_colors, name = "") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(title = "Medicaid Behavioral Health vs. HCBS Spending", x = NULL,
       y = "Total Paid ($ Billions)", caption = "Source: T-MSIS (HHS, 2026)")
ggsave(file.path(FIGS, "fig1_spending_trends.pdf"), p1, width = 8, height = 5)

# Fig 2: Event study
es_ct <- as.data.table(coeftable(es_model))
es_ct[, event_time := as.numeric(gsub("event_time::|:bh", "", rownames(coeftable(es_model))))]
es_ct <- es_ct[!is.na(event_time)]
setnames(es_ct, c("estimate", "se", "t", "p", "event_time"))
es_ct <- rbind(es_ct, data.table(estimate = 0, se = 0, t = 0, p = 1, event_time = -1))
es_ct[, `:=`(ci_lo = estimate - 1.96 * se, ci_hi = estimate + 1.96 * se)]

p2 <- ggplot(es_ct, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#E63946") +
  geom_point(color = "#E63946", size = 2) + geom_line(color = "#E63946") +
  labs(title = "Event Study: Differential Effect on BH vs. HCBS",
       subtitle = "DDD coefficients relative to t = -1",
       x = "Months Relative to Unwinding", y = "Coefficient (log paid)",
       caption = "95% CIs, state-clustered SEs.") +
  scale_x_continuous(breaks = seq(-24, 18, by = 6))
ggsave(file.path(FIGS, "fig2_event_study.pdf"), p2, width = 8, height = 5.5)

# Fig 3: Provider counts
prov_trends <- panel[, .(n_providers = sum(n_providers)), by = .(service_cat, month)]
p3 <- ggplot(prov_trends, aes(x = month, y = n_providers / 1000, color = service_cat)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", color = "gray40") +
  scale_color_manual(values = apep_colors, name = "") +
  labs(title = "Active Providers by Category", x = NULL, y = "Providers (Thousands)")
ggsave(file.path(FIGS, "fig3_provider_counts.pdf"), p3, width = 8, height = 5)

# Fig 4: Exit rates
exit_trends <- exit_entry[, .(exit_rate = mean(exit_rate, na.rm = TRUE)), by = .(service_cat, month)]
p4 <- ggplot(exit_trends, aes(x = month, y = exit_rate * 100, color = service_cat)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", color = "gray40") +
  scale_color_manual(values = apep_colors, name = "") +
  labs(title = "Monthly Provider Exit Rate", x = NULL, y = "Exit Rate (%)")
ggsave(file.path(FIGS, "fig4_exit_rates.pdf"), p4, width = 8, height = 5)

# Fig 5: Disenrollment map (skip if sf unavailable)
tryCatch({
  library(sf); library(tigris)
  options(tigris_use_cache = TRUE)
  st_sf <- states(cb = TRUE, resolution = "20m", year = 2022)
  st_sf <- st_sf[st_sf$STUSPS %in% c(state.abb, "DC"), ]
  st_sf <- shift_geometry(st_sf)
  map_d <- merge(st_sf, unwinding, by.x = "STUSPS", by.y = "state", all.x = TRUE)
  p5 <- ggplot(map_d) + geom_sf(aes(fill = disenroll_rate * 100), color = "white", size = 0.2) +
    scale_fill_viridis_c(name = "Disenroll %", option = "inferno", direction = -1) +
    labs(title = "Medicaid Unwinding: Disenrollment Rate by State") + theme_void() +
    theme(plot.title = element_text(face = "bold"), legend.position = "right")
  ggsave(file.path(FIGS, "fig5_disenrollment_map.pdf"), p5, width = 9, height = 6)
}, error = function(e) cat("Map skipped:", e$message, "\n"))

# Fig 6: Dose-response
change <- panel[, .(mean_paid = mean(total_paid)), by = .(state, service_cat, post)]
change_w <- dcast(change, state + service_cat ~ post, value.var = "mean_paid")
setnames(change_w, c("0", "1"), c("pre", "post_val"))
change_w[, pct_change := (post_val - pre) / pre * 100]
change_w <- merge(change_w, unwinding[, .(state, disenroll_rate)], by = "state")

p6 <- ggplot(change_w, aes(x = disenroll_rate * 100, y = pct_change, color = service_cat)) +
  geom_point(alpha = 0.7, size = 2) + geom_smooth(method = "lm", se = TRUE, alpha = 0.15) +
  scale_color_manual(values = apep_colors, name = "") +
  labs(title = "Dose-Response: Spending Change vs. Disenrollment", x = "Disenrollment Rate (%)",
       y = "Spending Change (%)")
ggsave(file.path(FIGS, "fig6_dose_response.pdf"), p6, width = 8, height = 5.5)

# Fig 7: RI
ri_df <- data.frame(coef = perm_coefs[!is.na(perm_coefs)])
p7 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "gray70", color = "white") +
  geom_vline(xintercept = obs_coef, color = "#E63946", linewidth = 1.2) +
  annotate("text", x = obs_coef, y = Inf, vjust = 2, hjust = -0.1,
           label = sprintf("Obs = %.3f\nRI p = %.3f", obs_coef, ri_pvalue),
           color = "#E63946", size = 3.5, fontface = "bold") +
  labs(title = "Randomization Inference", x = "DDD Coefficient", y = "Count")
ggsave(file.path(FIGS, "fig7_ri_distribution.pdf"), p7, width = 7, height = 5)

# Fig 8: HHI
hhi_trends <- hhi_state[, .(mean_hhi = mean(hhi, na.rm = TRUE)), by = .(service_cat, month)]
p8 <- ggplot(hhi_trends, aes(x = month, y = mean_hhi * 10000, color = service_cat)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", color = "gray40") +
  scale_color_manual(values = apep_colors, name = "") +
  labs(title = "Market Concentration (HHI) by Category", x = NULL, y = "HHI (0-10,000)")
ggsave(file.path(FIGS, "fig8_hhi_trends.pdf"), p8, width = 8, height = 5)

## ========== PHASE 6: TABLES ==========
cat("\n=== Phase 6: Tables ===\n")

# Tab 1: Summary stats
pre_s <- panel[post == 0, .(`Mean Paid ($M)` = mean(total_paid)/1e6, `SD ($M)` = sd(total_paid)/1e6,
                             `Mean Claims (K)` = mean(total_claims)/1e3, `Mean Providers` = mean(n_providers),
                             N = .N), by = .(Category = fifelse(service_cat == "BH", "Behavioral Health", "HCBS"))]
post_s <- panel[post == 1, .(`Mean Paid ($M)` = mean(total_paid)/1e6, `SD ($M)` = sd(total_paid)/1e6,
                              `Mean Claims (K)` = mean(total_claims)/1e3, `Mean Providers` = mean(n_providers),
                              N = .N), by = .(Category = fifelse(service_cat == "BH", "Behavioral Health", "HCBS"))]

writeLines(kable(pre_s, "latex", booktabs = TRUE, digits = 1, caption = "Summary Statistics: Pre-Unwinding (Jan 2018 -- Mar 2023)",
                 label = "tab:summary_pre") %>% kable_styling(latex_options = "hold_position"),
           file.path(TABS, "tab1_summary_pre.tex"))
writeLines(kable(post_s, "latex", booktabs = TRUE, digits = 1, caption = "Summary Statistics: Post-Unwinding (Apr 2023 -- Dec 2024)",
                 label = "tab:summary_post") %>% kable_styling(latex_options = "hold_position"),
           file.path(TABS, "tab1_summary_post.tex"))

# Tab 2: Main DDD (using etable for clean LaTeX)
options("modelsummary_format_numeric_latex" = "plain")
tab2_lines <- c(
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & Log Paid & Log Claims & Log Providers & Exit Rate & Net Entry & Log HHI \\\\",
  "\\midrule")
ms <- list(ddd_paid, ddd_claims, ddd_providers, ddd_exit, ddd_entry, ddd_hhi)
coefs <- sapply(ms, function(m) sprintf("%.3f", coef(m)[1]))
ses <- sapply(ms, function(m) sprintf("(%.3f)", fixest::se(m)[1]))
pvals <- sapply(ms, function(m) fixest::pvalue(m)[1])
stars <- sapply(pvals, function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", ""))))
coef_str <- paste(paste0(coefs, stars), collapse = " & ")
se_str <- paste(ses, collapse = " & ")
nobs <- sapply(ms, nobs)
r2 <- sapply(ms, function(m) sprintf("%.3f", r2(m, type = "r2")))
tab2_lines <- c(tab2_lines,
  paste0("Post $\\times$ BH & ", coef_str, " \\\\"),
  paste0(" & ", se_str, " \\\\"),
  "\\midrule",
  paste0("N & ", paste(nobs, collapse = " & "), " \\\\"),
  paste0("$R^2$ & ", paste(r2, collapse = " & "), " \\\\"),
  "\\bottomrule",
  "\\multicolumn{7}{l}{\\footnotesize Standard errors clustered at state level in parentheses.} \\\\",
  "\\multicolumn{7}{l}{\\footnotesize * $p<0.1$, ** $p<0.05$, *** $p<0.01$} \\\\",
  "\\end{tabular}")
writeLines(tab2_lines, file.path(TABS, "tab2_main_ddd.tex"))

# Tab 3: Intensity
ms3 <- list(ddd_paid, ddd_intensity, did_bh_intensity)
tab3_lines <- c(
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Baseline & Intensity & BH Only \\\\",
  "\\midrule")
# Row 1: post_bh
r1 <- c(sprintf("%.3f", coef(ms3[[1]])["post_bh"]),
        sprintf("%.3f", coef(ms3[[2]])["post_bh"]), "")
s1 <- c(sprintf("(%.3f)", fixest::se(ms3[[1]])["post_bh"]),
        sprintf("(%.3f)", fixest::se(ms3[[2]])["post_bh"]), "")
tab3_lines <- c(tab3_lines,
  paste0("Post $\\times$ BH & ", paste(r1, collapse = " & "), " \\\\"),
  paste0(" & ", paste(s1, collapse = " & "), " \\\\"))
# Row 2: post_bh_intensity
r2i <- c("", sprintf("%.3f", coef(ms3[[2]])["post_bh_intensity"]), "")
s2i <- c("", sprintf("(%.3f)", fixest::se(ms3[[2]])["post_bh_intensity"]), "")
tab3_lines <- c(tab3_lines,
  paste0("Post $\\times$ BH $\\times$ Disenroll & ", paste(r2i, collapse = " & "), " \\\\"),
  paste0(" & ", paste(s2i, collapse = " & "), " \\\\"))
# Row 3: post:disenroll_rate
r3 <- c("", "", sprintf("%.3f", coef(ms3[[3]])["post:disenroll_rate"]))
s3 <- c("", "", sprintf("(%.3f)", fixest::se(ms3[[3]])["post:disenroll_rate"]))
tab3_lines <- c(tab3_lines,
  paste0("Post $\\times$ Disenroll & ", paste(r3, collapse = " & "), " \\\\"),
  paste0(" & ", paste(s3, collapse = " & "), " \\\\"),
  "\\midrule",
  paste0("N & ", paste(sapply(ms3, nobs), collapse = " & "), " \\\\"),
  "\\bottomrule",
  "\\multicolumn{4}{l}{\\footnotesize Standard errors clustered at state level.} \\\\",
  "\\end{tabular}")
writeLines(tab3_lines, file.path(TABS, "tab3_intensity.tex"))

# Tab 4: Robustness
ms4 <- list(placebo_ddd, ddd_indiv, ddd_org, ddd_high, ddd_low, ddd_pretrend)
tab4_lines <- c(
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & BH vs CPT & Individual & Organization & High Proc & Low Proc & Pre-trend \\\\",
  "\\midrule")
# post_bh row (first 5 models)
r4a <- sapply(ms4[1:5], function(m) sprintf("%.3f", coef(m)["post_bh"]))
r4a <- c(r4a, "")
s4a <- sapply(ms4[1:5], function(m) sprintf("(%.3f)", fixest::se(m)["post_bh"]))
s4a <- c(s4a, "")
tab4_lines <- c(tab4_lines,
  paste0("Post $\\times$ BH & ", paste(r4a, collapse = " & "), " \\\\"),
  paste0(" & ", paste(s4a, collapse = " & "), " \\\\"))
# fake_post_bh row (last model only)
r4b <- c(rep("", 5), sprintf("%.3f", coef(ms4[[6]])["fake_post_bh"]))
s4b <- c(rep("", 5), sprintf("(%.3f)", fixest::se(ms4[[6]])["fake_post_bh"]))
tab4_lines <- c(tab4_lines,
  paste0("Fake Post $\\times$ BH & ", paste(r4b, collapse = " & "), " \\\\"),
  paste0(" & ", paste(s4b, collapse = " & "), " \\\\"),
  "\\midrule",
  paste0("N & ", paste(sapply(ms4, nobs), collapse = " & "), " \\\\"),
  "\\bottomrule",
  "\\multicolumn{7}{l}{\\footnotesize Standard errors clustered at state level.} \\\\",
  "\\end{tabular}")
writeLines(tab4_lines, file.path(TABS, "tab4_robustness.tex"))

# Tab 5: Unwinding cohorts
cohort_s <- unwinding[, .(`N States` = .N, `Mean Disenroll` = mean(disenroll_rate),
                           `Mean Procedural` = mean(procedural_share)),
                       by = .(Cohort = format(unwind_start, "%B %Y"))]
writeLines(kable(cohort_s, "latex", booktabs = TRUE, digits = 2,
                 caption = "Unwinding Cohorts", label = "tab:unwinding") %>%
             kable_styling(latex_options = "hold_position"),
           file.path(TABS, "tab5_unwinding.tex"))

## ========== SAVE ==========
cat("\n=== Saving results ===\n")
results <- list(ddd_paid = ddd_paid, ddd_claims = ddd_claims, ddd_providers = ddd_providers,
                ddd_intensity = ddd_intensity, es_model = es_model, ddd_exit = ddd_exit,
                ddd_entry = ddd_entry, ddd_hhi = ddd_hhi, did_bh_intensity = did_bh_intensity)
rob_results <- list(placebo_ddd = placebo_ddd, ddd_indiv = ddd_indiv, ddd_org = ddd_org,
                    ddd_high_proc = ddd_high, ddd_low_proc = ddd_low, ddd_pretrend = ddd_pretrend,
                    ri_pvalue = ri_pvalue, ri_coefs = perm_coefs, obs_coef = obs_coef)
save(results, rob_results, panel, exit_entry, hhi_state,
     file = file.path(DATA, "all_results.RData"))

cat("\n========================================\n")
cat("=== ANALYSIS COMPLETE ===\n")
cat(sprintf("Main DDD coef: %.4f (SE: %.4f, p: %.4f)\n",
            coef(ddd_paid)["post_bh"], se(ddd_paid)["post_bh"],
            fixest::pvalue(ddd_paid)["post_bh"]))
cat(sprintf("RI p-value: %.4f\n", ri_pvalue))
cat(sprintf("Figures: %d, Tables: %d\n",
            length(list.files(FIGS, "*.pdf")), length(list.files(TABS, "*.tex"))))
cat("========================================\n")
