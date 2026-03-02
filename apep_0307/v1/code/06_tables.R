## ============================================================================
## 06_tables.R — All tables for Medicaid unwinding paper
## ============================================================================

source("00_packages.R")
options("modelsummary_format_numeric_latex" = "plain")

## ---- Load data ----
hcbs     <- readRDS(file.path(DATA, "hcbs_state_month.rds"))
nonhcbs  <- readRDS(file.path(DATA, "nonhcbs_state_month.rds"))
treat    <- readRDS(file.path(DATA, "treatment_timing.rds"))
results  <- readRDS(file.path(DATA, "main_results.rds"))
rob      <- readRDS(file.path(DATA, "robustness_results.rds"))
sumstats <- readRDS(file.path(DATA, "sumstats.rds"))
hhi_data <- readRDS(file.path(DATA, "hcbs_hhi.rds"))
cs_agg   <- tryCatch(readRDS(file.path(DATA, "cs_agg.rds")), error = function(e) NULL)

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary Statistics...\n")

pre  <- hcbs[month_date < as.Date("2023-04-01")]
post <- hcbs[month_date >= as.Date("2023-04-01")]

tab1 <- data.table(
  Variable = c("Active HCBS Providers", "Monthly Billing (\\$M)",
               "Monthly Claims", "Monthly Beneficiaries",
               "Provider Exit Rate", "Provider Entry Rate",
               "Net Entry", "Individual Providers (share)",
               "Sole Proprietors (share)"),
  `Pre Mean` = c(
    sprintf("%.0f", mean(pre$n_providers)),
    sprintf("%.2f", mean(pre$total_paid) / 1e6),
    sprintf("%.0f", mean(pre$total_claims)),
    sprintf("%.0f", mean(pre$total_benef)),
    sprintf("%.4f", mean(pre$exit_rate, na.rm = TRUE)),
    sprintf("%.4f", mean(pre$entry_rate, na.rm = TRUE)),
    sprintf("%.1f", mean(pre$net_entry)),
    sprintf("%.3f", mean(pre$n_individual / pre$n_providers)),
    sprintf("%.3f", mean(pre$n_sole_prop / pre$n_providers))
  ),
  `Pre SD` = c(
    sprintf("%.0f", sd(pre$n_providers)),
    sprintf("%.2f", sd(pre$total_paid) / 1e6),
    sprintf("%.0f", sd(pre$total_claims)),
    sprintf("%.0f", sd(pre$total_benef)),
    sprintf("%.4f", sd(pre$exit_rate, na.rm = TRUE)),
    sprintf("%.4f", sd(pre$entry_rate, na.rm = TRUE)),
    sprintf("%.1f", sd(pre$net_entry)),
    "", ""
  ),
  `Post Mean` = c(
    sprintf("%.0f", mean(post$n_providers)),
    sprintf("%.2f", mean(post$total_paid) / 1e6),
    sprintf("%.0f", mean(post$total_claims)),
    sprintf("%.0f", mean(post$total_benef)),
    sprintf("%.4f", mean(post$exit_rate, na.rm = TRUE)),
    sprintf("%.4f", mean(post$entry_rate, na.rm = TRUE)),
    sprintf("%.1f", mean(post$net_entry)),
    sprintf("%.3f", mean(post$n_individual / post$n_providers)),
    sprintf("%.3f", mean(post$n_sole_prop / post$n_providers))
  ),
  `Post SD` = c(
    sprintf("%.0f", sd(post$n_providers)),
    sprintf("%.2f", sd(post$total_paid) / 1e6),
    sprintf("%.0f", sd(post$total_claims)),
    sprintf("%.0f", sd(post$total_benef)),
    sprintf("%.4f", sd(post$exit_rate, na.rm = TRUE)),
    sprintf("%.4f", sd(post$entry_rate, na.rm = TRUE)),
    sprintf("%.1f", sd(post$net_entry)),
    "", ""
  )
)

tab1_tex <- kbl(tab1, format = "latex", booktabs = TRUE,
                caption = "Summary Statistics: HCBS Provider Panel",
                label = "tab:sumstats",
                align = c("l", rep("c", 4)), escape = FALSE) |>
  kable_styling(latex_options = "hold_position") |>
  add_header_above(c(" " = 1, "Pre-Unwinding" = 2, "Post-Unwinding" = 2))

writeLines(tab1_tex, file.path(TAB, "tab1_sumstats.tex"))

## ---- Table 2: Treatment Cohort Summary ----
cat("Table 2: Treatment cohorts...\n")

cohort_sum <- treat[, .(
  N_States = .N,
  Mean_Disenroll = sprintf("%.1f\\%%", mean(disenroll_rate) * 100),
  Mean_Procedural = sprintf("%.1f\\%%", mean(procedural_share) * 100),
  States = paste(state, collapse = ", ")
), by = unwinding_month]
setorder(cohort_sum, unwinding_month)
setnames(cohort_sum, c("Unwinding Month", "N States",
                        "Mean Disenroll. Rate", "Mean Procedural Share",
                        "States"))

tab2_tex <- kbl(cohort_sum[, 1:4], format = "latex", booktabs = TRUE,
                caption = "Medicaid Unwinding Treatment Cohorts",
                label = "tab:cohorts",
                align = c("l", "c", "c", "c"), escape = FALSE) |>
  kable_styling(latex_options = "hold_position")

writeLines(tab2_tex, file.path(TAB, "tab2_cohorts.tex"))

## ---- Table 3: Main TWFE Results ----
cat("Table 3: Main TWFE results...\n")

models_main <- list(
  "Log Providers" = results$twfe_providers,
  "Log Billing" = results$twfe_paid,
  "Exit Rate" = results$twfe_exit,
  "Net Entry" = results$twfe_net_entry
)

cm <- c("post" = "Post $\\times$ Treated")

modelsummary(
  models_main,
  stars = c('*' = .1, '**' = .05, '***' = .01),
  coef_map = cm,
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  output = file.path(TAB, "tab3_main_twfe.tex"),
  title = "Main Results: Effect of Medicaid Unwinding on HCBS Providers",
  escape = FALSE
)

## ---- Table 4: Treatment Intensity ----
cat("Table 4: Treatment intensity...\n")

models_intensity <- list(
  "Disenroll. Rate" = results$intensity,
  "Procedural Share" = results$procedural,
  "Individual" = results$het_individual,
  "Organization" = results$het_org,
  "Sole Proprietor" = results$het_sole_prop
)

modelsummary(
  models_intensity,
  stars = c('*' = .1, '**' = .05, '***' = .01),
  gof_map = c("nobs", "r.squared"),
  output = file.path(TAB, "tab4_intensity_het.tex"),
  title = "Treatment Intensity and Heterogeneity",
  escape = FALSE
)

## ---- Table 5: Robustness Checks ----
cat("Table 5: Robustness...\n")

b <- coef(results$twfe_providers)["post"]
s <- se(results$twfe_providers)["post"]
p <- fixest::pvalue(results$twfe_providers)["post"]
b2 <- coef(rob$placebo)["post"]
s2 <- se(rob$placebo)["post"]
p2 <- fixest::pvalue(rob$placebo)["post"]

rob_rows <- data.table(
  Specification = c("Baseline TWFE",
                    "Placebo: Non-HCBS Providers",
                    "Permutation (1,000 draws)",
                    "Leave-one-out range"),
  Coefficient = c(sprintf("%.4f", b),
                  sprintf("%.4f", b2),
                  sprintf("%.4f", b),
                  sprintf("[%.4f, %.4f]",
                          min(rob$loo$coef, na.rm = TRUE),
                          max(rob$loo$coef, na.rm = TRUE))),
  SE = c(sprintf("(%.4f)", s),
         sprintf("(%.4f)", s2),
         "--", "--"),
  `p-value` = c(sprintf("%.3f", p),
                sprintf("%.3f", p2),
                sprintf("%.3f", rob$perm_p),
                "--"),
  N = c(format(nobs(results$twfe_providers), big.mark = ","),
        format(nobs(rob$placebo), big.mark = ","),
        "--", "--")
)

# Add CS-DiD row
if (!is.null(cs_agg)) {
  rob_rows <- rbind(
    rob_rows[1:2],
    data.table(Specification = "Callaway-Sant'Anna (2021)",
               Coefficient = sprintf("%.4f", cs_agg$overall.att),
               SE = sprintf("(%.4f)", cs_agg$overall.se),
               `p-value` = "--",
               N = "--"),
    rob_rows[3:4]
  )
}

tab5_tex <- kbl(rob_rows, format = "latex", booktabs = TRUE,
                caption = "Robustness Checks",
                label = "tab:robustness",
                align = c("l", "c", "c", "c", "c")) |>
  kable_styling(latex_options = "hold_position")

writeLines(tab5_tex, file.path(TAB, "tab5_robustness.tex"))

## ---- Table 6: Market Concentration ----
cat("Table 6: Market concentration...\n")

models_hhi <- list(
  "Log HHI" = rob$hhi,
  "Log Firms" = rob$nfirms,
  "Top Firm Share" = rob$topshare
)

modelsummary(
  models_hhi,
  stars = c('*' = .1, '**' = .05, '***' = .01),
  gof_map = c("nobs", "r.squared"),
  output = file.path(TAB, "tab6_concentration.tex"),
  title = "Market Concentration Effects",
  escape = FALSE
)

cat("\n=== All tables saved ===\n")
