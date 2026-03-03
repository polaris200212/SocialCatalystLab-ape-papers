################################################################################
# 03_main_analysis.R — Primary DDD Regressions and Event Studies
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
################################################################################

source("00_packages.R")

cat("=== Loading analysis panel ===\n")
panel <- read_parquet(file.path(LOCAL_DATA, "analysis_panel.parquet")) |> setDT()
cat("Panel:", nrow(panel), "provider-cycles,", uniqueN(panel$npi), "providers\n\n")

# ============================================================================
cat("=== Descriptive Statistics ===\n")

# Table 1: Summary statistics by expansion status and Medicaid dependence
summary_stats <- panel[, .(
  N_providers = uniqueN(npi),
  N_obs = .N,
  mean_medicaid_paid = mean(medicaid_paid, na.rm = TRUE),
  mean_medicaid_share = mean(medicaid_share, na.rm = TRUE),
  donation_rate = mean(any_donation, na.rm = TRUE),
  mean_donation_amt = mean(total_donations[any_donation == TRUE], na.rm = TRUE),
  dem_share_donors = mean(dem_share[any_donation == TRUE], na.rm = TRUE)
), by = .(expansion_state, medicaid_share_q)]

cat("Summary by expansion status × Medicaid dependence:\n")
print(summary_stats)

# Pre-treatment balance check (2018 cycle only)
pre_balance <- panel[cycle == 2018, .(
  mean_medicaid_paid = mean(medicaid_paid, na.rm = TRUE),
  mean_medicaid_share = mean(medicaid_share, na.rm = TRUE),
  donation_rate = mean(any_donation, na.rm = TRUE),
  mean_donation_amt = mean(total_donations[any_donation == TRUE], na.rm = TRUE)
), by = .(expansion_state)]

cat("\nPre-treatment balance (2018 cycle):\n")
print(pre_balance)

# ============================================================================
cat("\n=== Main DDD Regressions ===\n")

# Outcome 1: Any donation (extensive margin)
# DDD: post_expansion × medicaid_share, with provider FE and state×cycle FE
# NOTE ON ESTIMATOR CHOICE: TWFE is the primary specification for this DDD design.
# The Goodman-Bacon (2021) / Sun-Abraham (2021) critique of TWFE applies to
# standard two-way (unit + time) DiD with staggered adoption. In our DDD, the
# coefficient of interest is the interaction (post_expansion × medicaid_share),
# where medicaid_share is a CONTINUOUS provider-level variable. The negative-
# weighting problem arises from comparing already-treated to newly-treated units
# as controls; in the DDD, the third difference (high vs. low Medicaid dependence
# within the same state-time cell) is not subject to this concern because the
# comparison is within cell, not across differently-timed cohorts.
#
# Nevertheless, we estimate Callaway-Sant'Anna group-time ATTs in 04_robustness.R
# as a staggered-robust sensitivity check. The CS-DiD ATT (0.0014) is smaller and
# insignificant, which we report transparently in the paper.
cat("--- Extensive Margin: Any Donation ---\n")

# Basic DDD (no FE)
m1_basic <- feols(any_donation ~ post_expansion * medicaid_share |
                    practice_state + cycle,
                  data = panel, cluster = ~practice_state)

# Full DDD with provider FE
m1_full <- feols(any_donation ~ post_expansion * medicaid_share |
                   npi + practice_state^cycle,
                 data = panel, cluster = ~practice_state)

# With controls (use unemp_rate if available)
has_unemp <- "unemp_rate" %in% names(panel) && sum(!is.na(panel$unemp_rate)) > 100
if (has_unemp) {
  m1_controls <- feols(any_donation ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) + unemp_rate |
                         npi + practice_state^cycle,
                       data = panel, cluster = ~practice_state)
} else {
  m1_controls <- feols(any_donation ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) |
                         npi + practice_state^cycle,
                       data = panel, cluster = ~practice_state)
}

cat("\nExtensive margin results:\n")
etable(m1_basic, m1_full, m1_controls,
       headers = c("Basic", "Provider FE", "Controls"),
       se.below = TRUE)

# Outcome 2: Total donation amount (intensive margin, conditional on any)
cat("\n--- Intensive Margin: Donation Amount ---\n")

donors_panel <- panel[any_donation == TRUE]

m2_full <- feols(log(total_donations + 1) ~ post_expansion * medicaid_share |
                   npi + practice_state^cycle,
                 data = donors_panel, cluster = ~practice_state)

if (has_unemp) {
  m2_controls <- feols(log(total_donations + 1) ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) + unemp_rate |
                         npi + practice_state^cycle,
                       data = donors_panel, cluster = ~practice_state)
} else {
  m2_controls <- feols(log(total_donations + 1) ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) |
                         npi + practice_state^cycle,
                       data = donors_panel, cluster = ~practice_state)
}

cat("\nIntensive margin results:\n")
etable(m2_full, m2_controls,
       headers = c("Log Amount", "With Controls"),
       se.below = TRUE)

# Outcome 3: Democratic donation share (direction)
cat("\n--- Direction: Democratic Share of Donations ---\n")

m3_full <- feols(dem_share ~ post_expansion * medicaid_share |
                   npi + practice_state^cycle,
                 data = donors_panel, cluster = ~practice_state)

if (has_unemp) {
  m3_controls <- feols(dem_share ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) + unemp_rate |
                         npi + practice_state^cycle,
                       data = donors_panel, cluster = ~practice_state)
} else {
  m3_controls <- feols(dem_share ~ post_expansion * medicaid_share +
                         log(medicaid_paid + 1) |
                         npi + practice_state^cycle,
                       data = donors_panel, cluster = ~practice_state)
}

cat("\nDem share results:\n")
etable(m3_full, m3_controls,
       headers = c("Dem Share", "With Controls"),
       se.below = TRUE)

# Outcome 4: Number of donations (engagement intensity)
cat("\n--- Engagement Intensity: Number of Donations ---\n")

m4_full <- feols(log(n_donations + 1) ~ post_expansion * medicaid_share |
                   npi + practice_state^cycle,
                 data = panel, cluster = ~practice_state)

cat("\nDonation count results:\n")
etable(m4_full, se.below = TRUE)

# ============================================================================
cat("\n=== Event Study ===\n")

# Create event-time variable relative to expansion
panel[, event_time := fifelse(
  expansion_state,
  cycle - first_post_cycle,
  NA_integer_
)]

# For event study, need to interact event-time dummies with medicaid_share
# Event times: -2 (2 cycles before), 0 (expansion cycle), +2, +4
# Normalize: -2 as reference (omit)
panel[, event_time_cat := factor(event_time)]

# Simple DiD event study (without continuous medicaid_share interaction)
# High vs low Medicaid dependence
panel[, high_medicaid := medicaid_share > median(medicaid_share, na.rm = TRUE)]

es_data <- panel[expansion_state == TRUE & !is.na(event_time)]

if (nrow(es_data) > 100) {
  m_es <- feols(any_donation ~ i(event_time, high_medicaid, ref = -2) |
                  npi + cycle,
                data = es_data, cluster = ~practice_state)

  cat("\nEvent study (high vs low Medicaid dependence):\n")
  print(summary(m_es))
}

# ============================================================================
cat("\n=== Callaway-Sant'Anna Staggered DiD ===\n")

# CS-DiD requires: group (first treatment period), time, outcome, id
# Group = first_post_cycle (or 0 for never-treated)
cs_data <- panel[, .(
  id = as.numeric(factor(npi)),
  group = cohort,
  time = cycle,
  y = as.numeric(any_donation),
  y_amt = total_donations,
  med_share = medicaid_share
)]

# Remove NAs
cs_data <- cs_data[!is.na(group) & !is.na(time) & !is.na(y)]

if (nrow(cs_data) > 1000) {
  tryCatch({
    cs_out <- att_gt(
      yname = "y",
      tname = "time",
      idname = "id",
      gname = "group",
      data = as.data.frame(cs_data),
      control_group = "nevertreated",
      est_method = "dr",
      base_period = "universal"
    )

    cat("\nCallaway-Sant'Anna group-time ATTs:\n")
    print(summary(cs_out))

    # Aggregate to event-study
    cs_es <- aggte(cs_out, type = "dynamic")
    cat("\nCS Event Study:\n")
    print(summary(cs_es))

    # Aggregate to overall
    cs_overall <- aggte(cs_out, type = "simple")
    cat("\nCS Overall ATT:\n")
    print(summary(cs_overall))

    # Save for plotting
    saveRDS(cs_out, file.path(LOCAL_DATA, "cs_did_results.rds"))
    saveRDS(cs_es, file.path(LOCAL_DATA, "cs_event_study.rds"))
  }, error = function(e) {
    cat("\nCS-DiD error:", conditionMessage(e), "\n")
    cat("Proceeding with TWFE results.\n")
  })
}

# ============================================================================
cat("\n=== Mechanism Decomposition ===\n")

# Mechanism 1: By provider specialty
# Physicians vs. nurses/therapists vs. HCBS workers
panel[, provider_type := fcase(
  grepl("^(207|208|209)", taxonomy_code), "Physician",
  grepl("^(363|364|367)", taxonomy_code), "Nurse/NP",
  grepl("^(225|229|231)", taxonomy_code), "Therapist",
  grepl("^(171|174|372)", taxonomy_code), "Social/Behavioral",
  default = "Other"
)]

cat("\n--- By Provider Type ---\n")
# Helper to extract interaction coefficient (handles TRUE suffix)
get_interaction <- function(m) {
  cn <- names(coef(m))
  idx <- grep("post_expansion.*:.*medicaid_share", cn)
  if (length(idx) == 0) return(list(coef = NA, se = NA, p = NA))
  nm <- cn[idx[1]]
  list(coef = coef(m)[nm], se = se(m)[nm], p = fixest::pvalue(m)[nm])
}

for (ptype in c("Physician", "Nurse/NP", "Therapist", "Social/Behavioral")) {
  sub <- panel[provider_type == ptype]
  if (nrow(sub) > 100 & sum(sub$any_donation) > 10) {
    m <- tryCatch(feols(any_donation ~ post_expansion * medicaid_share |
                 npi + practice_state^cycle,
               data = sub, cluster = ~practice_state), error = function(e) NULL)
    if (!is.null(m)) {
      res <- get_interaction(m)
      cat("\n", ptype, ":\n")
      cat("  DDD coef:", res$coef, "  SE:", res$se, "  p:", res$p, "\n")
    }
  }
}

# Mechanism 2: By HCBS dependence
panel[, high_hcbs := pre_hcbs_share > 0.5]

cat("\n--- HCBS vs. Non-HCBS Providers ---\n")
for (hcbs_flag in c(TRUE, FALSE)) {
  sub <- panel[high_hcbs == hcbs_flag]
  if (nrow(sub) > 100) {
    m <- tryCatch(feols(any_donation ~ post_expansion * medicaid_share |
                 npi + practice_state^cycle,
               data = sub, cluster = ~practice_state), error = function(e) NULL)
    if (!is.null(m)) {
      res <- get_interaction(m)
      label <- ifelse(hcbs_flag, "High HCBS", "Low HCBS")
      cat("\n", label, ":\n")
      cat("  DDD coef:", res$coef, "  SE:", res$se, "\n")
    }
  }
}

# Mechanism 3: By gender (Bonica et al. show women lean Dem, men lean Rep)
cat("\n--- By Gender ---\n")
for (g in c("M", "F")) {
  sub <- panel[gender == g]
  if (nrow(sub) > 100) {
    m <- tryCatch(feols(any_donation ~ post_expansion * medicaid_share |
                 npi + practice_state^cycle,
               data = sub, cluster = ~practice_state), error = function(e) NULL)
    if (!is.null(m)) {
      res <- get_interaction(m)
      cat("\n Gender =", g, ":\n")
      cat("  DDD coef:", res$coef, "  SE:", res$se, "\n")
    }
  }
}

# ============================================================================
cat("\n=== Saving main results ===\n")

# Save all model objects
main_models <- list(
  extensive_basic = m1_basic,
  extensive_full = m1_full,
  extensive_controls = m1_controls,
  intensive_full = m2_full,
  intensive_controls = m2_controls,
  direction_full = m3_full,
  direction_controls = m3_controls,
  engagement = m4_full
)
saveRDS(main_models, file.path(LOCAL_DATA, "main_models.rds"))

cat("\n=== Main analysis complete ===\n")
