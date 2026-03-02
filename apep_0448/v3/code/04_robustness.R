## ============================================================================
## 04_robustness.R — Robustness checks
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"
hcbs <- readRDS(file.path(DATA, "hcbs_analysis.rds"))
bh <- readRDS(file.path(DATA, "bh_analysis.rds"))
ui_term <- readRDS(file.path(DATA, "ui_termination.rds"))

cat("Data loaded for robustness checks\n")

## ---- 1. Bacon Decomposition ----
cat("\n=== Bacon Decomposition ===\n")

# Need binary treatment for bacon
library(bacondecomp)
bacon_data <- copy(hcbs[, .(state_id, period, ln_providers, treated)])

bacon_out <- tryCatch({
  bacon(ln_providers ~ treated, data = as.data.frame(bacon_data),
        id_var = "state_id", time_var = "period")
}, error = function(e) {
  cat("Bacon decomposition error:", e$message, "\n")
  NULL
})

if (!is.null(bacon_out)) {
  cat("\nBacon Decomposition Results:\n")
  bacon_summary <- as.data.table(bacon_out)
  cat(sprintf("  Total TWFE estimate: %.4f\n", sum(bacon_summary$estimate * bacon_summary$weight)))
  print(bacon_summary[, .(type, mean_est = round(mean(estimate), 4),
                          mean_wt = round(mean(weight), 4),
                          total_wt = round(sum(weight), 4)),
                      by = type])
}

## ---- 2. Within-Region Analysis (South only) ----
cat("\n=== Within-Region: South ===\n")

south_states <- c("AL", "AR", "DE", "DC", "FL", "GA", "KY", "LA", "MD",
                  "MS", "NC", "OK", "SC", "TN", "TX", "VA", "WV")
hcbs_south <- hcbs[state %in% south_states]

twfe_south <- feols(ln_providers ~ treated | state + period,
                    data = hcbs_south, cluster = ~state)
cat(sprintf("South only: β = %.4f (SE = %.4f), N states = %d\n",
            coef(twfe_south), se(twfe_south), uniqueN(hcbs_south$state)))

## ---- 3. Within-Region: Midwest ----
cat("\n=== Within-Region: Midwest ===\n")

midwest_states <- c("IA", "IL", "IN", "KS", "MI", "MN", "MO", "ND",
                    "NE", "OH", "SD", "WI")
hcbs_midwest <- hcbs[state %in% midwest_states]

twfe_midwest <- feols(ln_providers ~ treated | state + period,
                      data = hcbs_midwest, cluster = ~state)
cat(sprintf("Midwest only: β = %.4f (SE = %.4f), N states = %d\n",
            coef(twfe_midwest), se(twfe_midwest), uniqueN(hcbs_midwest$state)))

## ---- 4. Placebo Treatment Date (2019) ----
cat("\n=== Placebo: 2019 Treatment Date ===\n")

hcbs_placebo <- copy(hcbs)
# Shift treatment to July 2019 (one year earlier)
hcbs_placebo[, placebo_first_month := first_full_month - years(2)]
hcbs_placebo[, placebo_treated := early_terminator & month_date >= placebo_first_month]
# Restrict to pre-COVID period only
hcbs_placebo <- hcbs_placebo[month_date < as.Date("2020-03-01")]

twfe_placebo <- feols(ln_providers ~ placebo_treated | state + period,
                      data = hcbs_placebo, cluster = ~state)
cat(sprintf("Placebo (2019): β = %.4f (SE = %.4f), p = %.3f\n",
            coef(twfe_placebo), se(twfe_placebo), coeftable(twfe_placebo)[, "Pr(>|t|)"]))

## ---- 5. Exclude outlier states ----
cat("\n=== Sensitivity: Exclude NY, CA ===\n")

hcbs_no_outliers <- hcbs[!state %in% c("NY", "CA")]
twfe_no_outliers <- feols(ln_providers ~ treated | state + period,
                          data = hcbs_no_outliers, cluster = ~state)
cat(sprintf("Excl NY/CA: β = %.4f (SE = %.4f)\n",
            coef(twfe_no_outliers), se(twfe_no_outliers)))

## ---- 6. Intensive margin robustness ----
cat("\n=== Intensive Margin: Beneficiaries per Provider ===\n")

twfe_benes_per <- feols(log(benes_per_provider + 1) ~ treated | state + period,
                        data = hcbs, cluster = ~state)
cat(sprintf("Benes/provider: β = %.4f (SE = %.4f)\n",
            coef(twfe_benes_per), se(twfe_benes_per)))

## ---- 7. Randomization Inference ----
cat("\n=== Randomization Inference (1000 permutations) ===\n")

set.seed(42)
n_perms <- 1000
perm_coefs <- numeric(n_perms)

# Get the actual treatment states
treated_states <- unique(hcbs[early_terminator == TRUE, state])
all_states <- unique(hcbs$state)
n_treated <- length(treated_states)

# Actual estimate
actual_coef <- coef(feols(ln_providers ~ treated | state + period,
                          data = hcbs, cluster = ~state))

for (i in 1:n_perms) {
  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))
  # Randomly assign treatment to same number of states
  perm_states <- sample(all_states, n_treated)
  hcbs_perm <- copy(hcbs)
  hcbs_perm[, perm_treated := (state %in% perm_states) & month_date >= as.Date("2021-07-01")]
  perm_fit <- tryCatch(
    feols(ln_providers ~ perm_treated | state + period, data = hcbs_perm, cluster = ~state),
    error = function(e) NULL
  )
  perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit) else NA_real_
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(actual_coef))
cat(sprintf("RI p-value (two-sided): %.3f\n", ri_pvalue))
cat(sprintf("Actual coef: %.4f, Perm mean: %.4f, Perm SD: %.4f\n",
            actual_coef, mean(perm_coefs), sd(perm_coefs)))

## ---- 7b. Randomization Inference (CS-DiD) ----
cat("\n=== CS-DiD Randomization Inference (1000 permutations) ===\n")

# Load main results to get the actual CS-DiD ATT
main_results <- readRDS(file.path(DATA, "main_results.rds"))
actual_cs_att <- main_results$cs_agg$providers$overall.att

n_perms_cs <- 1000
cs_perm_atts <- numeric(n_perms_cs)

# Get state-level treatment group assignment (g_period)
state_g <- unique(hcbs[, .(state_id, g_period)])
setorder(state_g, state_id)
original_g <- state_g$g_period

set.seed(123)
for (i in 1:n_perms_cs) {
  if (i %% 20 == 0) cat(sprintf("  CS-DiD permutation %d/%d\n", i, n_perms_cs))

  # Permute treatment assignment across states (preserving cohort structure)
  perm_g <- sample(original_g)
  state_g_perm <- data.table(state_id = state_g$state_id, perm_g = perm_g)

  hcbs_perm <- merge(hcbs[, !c("g_period"), with = FALSE], state_g_perm, by = "state_id")
  setnames(hcbs_perm, "perm_g", "g_period")
  hcbs_perm[, g_period := as.numeric(g_period)]

  perm_cs <- tryCatch({
    att_gt(
      yname = "ln_providers",
      tname = "period",
      idname = "state_id",
      gname = "g_period",
      data = as.data.frame(hcbs_perm),
      control_group = "nevertreated",
      est_method = "dr",
      base_period = "universal",
      bstrap = FALSE,
      cband = FALSE
    )
  }, error = function(e) NULL)

  if (!is.null(perm_cs)) {
    perm_agg <- aggte(perm_cs, type = "simple")
    cs_perm_atts[i] <- perm_agg$overall.att
  } else {
    cs_perm_atts[i] <- NA_real_
  }
}

cs_perm_atts <- cs_perm_atts[!is.na(cs_perm_atts)]
ri_pvalue_cs <- mean(abs(cs_perm_atts) >= abs(actual_cs_att))
cat(sprintf("CS-DiD RI p-value (two-sided): %.3f\n", ri_pvalue_cs))
cat(sprintf("Actual CS-DiD ATT: %.4f, Perm mean: %.4f, Perm SD: %.4f\n",
            actual_cs_att, mean(cs_perm_atts), sd(cs_perm_atts)))
cat(sprintf("Valid CS-DiD permutations: %d/%d\n", length(cs_perm_atts), n_perms_cs))

## ---- 8. Triple-diff (HCBS vs BH × early termination × post) ----
cat("\n=== Triple-Difference (HCBS vs BH) ===\n")

panel <- readRDS(file.path(DATA, "panel.rds"))
panel[, is_hcbs := as.integer(service_type == "HCBS")]
panel[, post := as.integer(month_date >= as.Date("2021-07-01"))]

# Create period variable
all_months <- sort(unique(panel$month_date))
month_map <- data.table(month_date = all_months, period = seq_along(all_months))
panel <- merge(panel, month_map, by = "month_date")

ddd_fit <- feols(ln_providers ~ early_terminator:is_hcbs:post +
                   early_terminator:post + is_hcbs:post |
                   state^service_type + service_type^period + state^period,
                 data = panel, cluster = ~state)

cat("Triple-diff (HCBS vs BH × early term × post):\n")
print(summary(ddd_fit))

## ---- 9. Save robustness results ----
robust_results <- list(
  bacon = bacon_out,
  south_only = twfe_south,
  midwest_only = twfe_midwest,
  placebo_2019 = twfe_placebo,
  no_outliers = twfe_no_outliers,
  intensive_benes = twfe_benes_per,
  ri_pvalue = ri_pvalue,
  ri_actual = actual_coef,
  ri_distribution = perm_coefs,
  ri_pvalue_cs = ri_pvalue_cs,
  ri_actual_cs = actual_cs_att,
  ri_distribution_cs = cs_perm_atts,
  triple_diff = ddd_fit
)

saveRDS(robust_results, file.path(DATA, "robustness_results.rds"))
cat("\n=== Robustness checks complete ===\n")
