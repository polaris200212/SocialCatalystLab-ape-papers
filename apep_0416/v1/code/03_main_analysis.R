## ============================================================================
## 03_main_analysis.R — DDD estimation, event studies, Callaway-Sant'Anna
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

source("00_packages.R")
DATA <- "../data"
load(file.path(DATA, "02_analysis_data.RData"))

RESULTS <- "../data"

## ---- 1. DDD: Billing Volume ----
cat("=== DDD Estimation: Billing Volume ===\n")

# Primary: log(total_paid) ~ post × BH with state×month and cat×month FE
# This absorbs all state-level shocks and all category-level trends
ddd_paid <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel,
  cluster = ~state
)
cat("DDD (log paid):\n")
summary(ddd_paid)

# Claims volume
ddd_claims <- feols(
  log_claims ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel,
  cluster = ~state
)
cat("\nDDD (log claims):\n")
summary(ddd_claims)

# Provider count
ddd_providers <- feols(
  log_providers ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel,
  cluster = ~state
)
cat("\nDDD (log providers):\n")
summary(ddd_providers)

## ---- 2. DDD with Intensity ----
cat("\n=== DDD with Unwinding Intensity ===\n")

# Dose-response: interact post×BH with disenrollment rate
ddd_intensity <- feols(
  log_paid ~ post_bh + post_bh_intensity |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel,
  cluster = ~state
)
cat("DDD with intensity (log paid):\n")
summary(ddd_intensity)

## ---- 3. Event Study ----
cat("\n=== Event Study ===\n")

# Create event-time bins (cap at -24 and +18, bin endpoints)
panel[, event_time := rel_month]
panel[event_time < -24, event_time := -24]
panel[event_time > 18, event_time := 18]

# Event study: interact relative time × BH
# Reference period: t = -1
es_model <- feols(
  log_paid ~ i(event_time, bh, ref = -1) |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel,
  cluster = ~state
)
cat("Event study coefficients:\n")
summary(es_model)

## ---- 4. Exit Rate DDD ----
cat("\n=== Exit Rate DDD ===\n")

ddd_exit <- feols(
  exit_rate ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = exit_entry[!is.na(exit_rate)],
  cluster = ~state
)
cat("DDD (exit rate):\n")
summary(ddd_exit)

# Entry rate
ddd_entry <- feols(
  net_entry_rate ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = exit_entry[!is.na(net_entry_rate)],
  cluster = ~state
)
cat("\nDDD (net entry rate):\n")
summary(ddd_entry)

## ---- 5. HHI (Market Concentration) DDD ----
cat("\n=== Market Concentration DDD ===\n")

ddd_hhi <- feols(
  log_hhi ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = hhi_state,
  cluster = ~state
)
cat("DDD (log HHI):\n")
summary(ddd_hhi)

## ---- 6. Callaway-Sant'Anna (BH only, staggered DiD) ----
cat("\n=== Callaway-Sant'Anna: BH providers only ===\n")

# Prepare panel for CS: need state × month panel for BH only
bh_panel <- panel[service_cat == "BH"]

# Convert unwinding start to numeric month
bh_panel[, first_treat := as.integer(format(unwind_start, "%Y")) * 12 +
           as.integer(format(unwind_start, "%m"))]

# Need balanced panel with state_id and year_month
bh_balanced <- CJ(state = unique(bh_panel$state),
                   month = unique(bh_panel$month))
bh_balanced <- merge(bh_balanced, bh_panel, by = c("state", "month"), all.x = TRUE)

# Fill NAs for missing state-months
bh_balanced[, `:=`(
  state_id = as.integer(factor(state)),
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m"))
)]

# Fill first_treat
bh_balanced[, first_treat := first_treat[!is.na(first_treat)][1],
             by = state]

# Replace NA outcomes with 0 (state-month with no BH billing)
bh_balanced[is.na(log_paid), log_paid := 0]

# Run CS estimator
cs_out <- tryCatch({
  att_gt(
    yname = "log_paid",
    tname = "year_month",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(bh_balanced[!is.na(first_treat)]),
    control_group = "notyettreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS estimation failed:", e$message, "\n")
  cat("Falling back to never-treated control group...\n")
  # All states treated, so try not-yet-treated
  NULL
})

if (!is.null(cs_out)) {
  cat("\nCS ATT(g,t) summary:\n")
  cs_agg <- aggte(cs_out, type = "simple")
  cat(sprintf("ATT (simple): %.4f (SE: %.4f)\n",
              cs_agg$overall.att, cs_agg$overall.se))

  cs_es <- aggte(cs_out, type = "dynamic")
  cat("CS event study:\n")
  print(summary(cs_es))
}

## ---- 7. Within-BH DiD (state-level, continuous intensity) ----
cat("\n=== Within-BH DiD with Continuous Intensity ===\n")

bh_only <- panel[service_cat == "BH"]
did_bh_intensity <- feols(
  log_paid ~ post:disenroll_rate | state + year_month,
  data = bh_only,
  cluster = ~state
)
cat("BH-only DiD with intensity:\n")
summary(did_bh_intensity)

## ---- 8. Save results ----
results <- list(
  ddd_paid = ddd_paid,
  ddd_claims = ddd_claims,
  ddd_providers = ddd_providers,
  ddd_intensity = ddd_intensity,
  es_model = es_model,
  ddd_exit = ddd_exit,
  ddd_entry = ddd_entry,
  ddd_hhi = ddd_hhi,
  cs_out = cs_out,
  did_bh_intensity = did_bh_intensity
)

save(results, file = file.path(RESULTS, "03_results.RData"))
cat("\nSaved: 03_results.RData\n")
