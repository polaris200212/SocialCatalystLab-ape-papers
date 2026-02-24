## ============================================================================
## 06_tables.R — LaTeX tables for paper
## v2 revision: Add CIs, decomposition table, restructure
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

pre <- panel[month_date < as.Date("2020-03-01")]
post <- panel[month_date >= as.Date("2020-04-01")]

tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: State-Level Monthly Medicaid Billing (Clean HCBS)}",
  "\\label{tab:sumstats}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\hline\\hline",
  " & \\multicolumn{3}{c}{HCBS (Clean T-codes)} & \\multicolumn{3}{c}{Behavioral Health (H-codes)} \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}",
  " & Mean & SD & Median & Mean & SD & Median \\\\",
  "\\hline",
  "\\multicolumn{7}{l}{\\textit{Panel A: Pre-Period (Jan 2018 -- Feb 2020)}} \\\\[3pt]"
)

tab1_lines <- c(tab1_lines,
  sprintf("Total Paid (\\$M) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          sd(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          median(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          mean(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6,
          sd(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6,
          median(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6),
  sprintf("Total Claims (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          median(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          mean(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3,
          median(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3),
  sprintf("Active Providers & %.0f & %.0f & %.0f & %.0f & %.0f & %.0f \\\\",
          mean(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          sd(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          median(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          mean(pre[service_type == "BH"]$n_providers, na.rm = TRUE),
          sd(pre[service_type == "BH"]$n_providers, na.rm = TRUE),
          median(pre[service_type == "BH"]$n_providers, na.rm = TRUE)),
  sprintf("Beneficiaries (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          median(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          mean(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          median(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3)
)

# Panel B: Treatment variation
tab1_lines <- c(tab1_lines,
  "[6pt]",
  "\\multicolumn{7}{l}{\\textit{Panel B: Treatment Variation}} \\\\[3pt]",
  sprintf("\\multicolumn{4}{l}{Peak stringency (April 2020)} & \\multicolumn{3}{l}{Mean = %.1f, SD = %.1f} \\\\",
          mean(state_treatment$peak_stringency, na.rm = TRUE),
          sd(state_treatment$peak_stringency, na.rm = TRUE)),
  sprintf("\\multicolumn{4}{l}{States with stay-at-home orders} & \\multicolumn{3}{l}{%d of 51} \\\\",
          sum(!state_treatment$never_treated)),
  sprintf("\\multicolumn{4}{l}{Observations (state $\\times$ service $\\times$ month)} & \\multicolumn{3}{l}{%s} \\\\",
          format(nrow(panel), big.mark = ",")),
  sprintf("\\multicolumn{4}{l}{States} & \\multicolumn{3}{l}{%d} \\\\",
          uniqueN(panel$state)),
  sprintf("\\multicolumn{4}{l}{Months (excl.~March 2020)} & \\multicolumn{3}{l}{%d} \\\\",
          uniqueN(panel$month_date)),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} HCBS = Home and Community-Based Services, restricted to genuinely in-home T-codes (T1019, T1020, T2016, T2017, T2022, and related home-based codes; see Appendix Table \\ref{tab:hcpcs}). BH = Behavioral Health (H-codes). Data from T-MSIS Medicaid Provider Spending, January 2018--September 2024. State assignment via NPPES practice address. Peak stringency is the April 2020 average of the Oxford COVID-19 Government Response Tracker Stringency Index (0--100 scale).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(TABLES, "tab1_sumstats.tex"))

## ---- Table 2: Main DDD Results (with 95% CIs — WS6) ----
cat("Table 2: Main DDD results with CIs...\n")

extract_result <- function(model, model_name) {
  ct <- coeftable(model)
  coef_val <- ct[1, "Estimate"]
  se_val <- ct[1, "Std. Error"]
  pval <- ct[1, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  ci_lo <- coef_val - 1.96 * se_val
  ci_hi <- coef_val + 1.96 * se_val
  n_obs <- model$nobs
  list(coef = coef_val, se = se_val, pval = pval, stars = stars,
       ci_lo = ci_lo, ci_hi = ci_hi, n = n_obs, name = model_name)
}

m1 <- extract_result(results$m1_paid, "Log Paid")
m2 <- extract_result(results$m2_claims, "Log Claims")
m3 <- extract_result(results$m3_providers, "Log Providers")
m4 <- extract_result(results$m4_benef, "Log Beneficiaries")
m5 <- extract_result(results$m5_intensive, "Log Paid/Provider")
m6 <- extract_result(results$m6_benef_prov, "Log Benef./Provider")

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Triple-Difference Estimates: Effect of Lockdown Stringency on HCBS vs Behavioral Health}",
  "\\label{tab:main_ddd}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) & (4) & (5) & (6) \\\\",
  " & Log & Log & Log & Log & Log Paid & Log Benef. \\\\",
  " & Paid & Claims & Providers & Benef. & /Provider & /Provider \\\\",
  "\\hline",
  sprintf("Stringency $\\times$ HCBS $\\times$ Post & %.3f%s & %.3f%s & %.3f%s & %.3f%s & %.3f%s & %.3f%s \\\\",
          m1$coef, m1$stars, m2$coef, m2$stars, m3$coef, m3$stars,
          m4$coef, m4$stars, m5$coef, m5$stars, m6$coef, m6$stars),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) & (%.3f) & (%.3f) & (%.3f) \\\\",
          m1$se, m2$se, m3$se, m4$se, m5$se, m6$se),
  sprintf("95\\%% CI & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] \\\\",
          m1$ci_lo, m1$ci_hi, m2$ci_lo, m2$ci_hi, m3$ci_lo, m3$ci_hi,
          m4$ci_lo, m4$ci_hi, m5$ci_lo, m5$ci_hi, m6$ci_lo, m6$ci_hi),
  sprintf("\\relax[\\textit{p}-value] & [%.3f] & [%.3f] & [%.3f] & [%.3f] & [%.3f] & [%.3f] \\\\",
          m1$pval, m2$pval, m3$pval, m4$pval, m5$pval, m6$pval),
  "[6pt]",
  "\\hline",
  "State $\\times$ Service FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "Service $\\times$ Month FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "State $\\times$ Month FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "Clustering & State & State & State & State & State & State \\\\",
  sprintf("Observations & %s & %s & %s & %s & %s & %s \\\\",
          format(m1$n, big.mark = ","), format(m2$n, big.mark = ","),
          format(m3$n, big.mark = ","), format(m4$n, big.mark = ","),
          format(m5$n, big.mark = ","), format(m6$n, big.mark = ",")),
  sprintf("States & %d & %d & %d & %d & %d & %d \\\\",
          uniqueN(panel$state), uniqueN(panel$state), uniqueN(panel$state),
          uniqueN(panel$state), uniqueN(panel$state), uniqueN(panel$state)),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} Triple-difference estimates using the clean HCBS classification (genuinely in-home T-codes only; see Appendix Table \\ref{tab:hcpcs}). The treatment variable is the interaction of state-level peak lockdown stringency (April 2020 Oxford Stringency Index, standardized 0--1), an indicator for HCBS services, and a post-lockdown indicator (April 2020+). March 2020 is excluded (partial treatment exposure). All specifications include state $\\times$ service type, service type $\\times$ month, and state $\\times$ month fixed effects. Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets. All log outcomes use $\\log(Y + 1)$ to handle zero-valued cells. $^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(TABLES, "tab2_main_ddd.tex"))

## ---- Table 3: DDD Decomposition (NEW — WS2) ----
cat("Table 3: DDD decomposition...\n")

extract_did <- function(model) {
  ct <- coeftable(model)
  coef_val <- ct[1, "Estimate"]
  se_val <- ct[1, "Std. Error"]
  pval <- ct[1, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  ci_lo <- coef_val - 1.96 * se_val
  ci_hi <- coef_val + 1.96 * se_val
  list(coef = coef_val, se = se_val, pval = pval, stars = stars,
       ci_lo = ci_lo, ci_hi = ci_hi, n = model$nobs)
}

hcbs_paid <- extract_did(results$m_hcbs_did)
hcbs_claims <- extract_did(results$m_hcbs_did_claims)
hcbs_prov <- extract_did(results$m_hcbs_did_prov)
bh_paid <- extract_did(results$m_bh_did)
bh_claims <- extract_did(results$m_bh_did_claims)
bh_prov <- extract_did(results$m_bh_did_prov)

tab3_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Decomposition: Separate Difference-in-Differences for HCBS and Behavioral Health}",
  "\\label{tab:decomposition}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\hline\\hline",
  " & Log Paid & Log Claims & Log Providers \\\\",
  "\\hline",
  "\\multicolumn{4}{l}{\\textit{Panel A: HCBS Only}} \\\\[3pt]",
  sprintf("Stringency $\\times$ Post & %.3f%s & %.3f%s & %.3f%s \\\\",
          hcbs_paid$coef, hcbs_paid$stars, hcbs_claims$coef, hcbs_claims$stars,
          hcbs_prov$coef, hcbs_prov$stars),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          hcbs_paid$se, hcbs_claims$se, hcbs_prov$se),
  sprintf("95\\%% CI & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] \\\\",
          hcbs_paid$ci_lo, hcbs_paid$ci_hi, hcbs_claims$ci_lo, hcbs_claims$ci_hi,
          hcbs_prov$ci_lo, hcbs_prov$ci_hi),
  "[6pt]",
  "\\multicolumn{4}{l}{\\textit{Panel B: Behavioral Health Only}} \\\\[3pt]",
  sprintf("Stringency $\\times$ Post & %.3f%s & %.3f%s & %.3f%s \\\\",
          bh_paid$coef, bh_paid$stars, bh_claims$coef, bh_claims$stars,
          bh_prov$coef, bh_prov$stars),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\",
          bh_paid$se, bh_claims$se, bh_prov$se),
  sprintf("95\\%% CI & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] \\\\",
          bh_paid$ci_lo, bh_paid$ci_hi, bh_claims$ci_lo, bh_claims$ci_hi,
          bh_prov$ci_lo, bh_prov$ci_hi),
  "[6pt]",
  "\\hline",
  "State FE & Yes & Yes & Yes \\\\",
  "Month FE & Yes & Yes & Yes \\\\",
  "Clustering & State & State & State \\\\",
  sprintf("Obs.~(HCBS) & %s & %s & %s \\\\",
          format(hcbs_paid$n, big.mark = ","), format(hcbs_claims$n, big.mark = ","),
          format(hcbs_prov$n, big.mark = ",")),
  sprintf("Obs.~(BH) & %s & %s & %s \\\\",
          format(bh_paid$n, big.mark = ","), format(bh_claims$n, big.mark = ","),
          format(bh_prov$n, big.mark = ",")),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} Separate difference-in-differences regressions for HCBS (Panel A) and behavioral health (Panel B). Each panel reports $\\hat{\\beta}$ from $Y_{s,t} = \\beta (\\text{Stringency}_s \\times \\text{Post}_t) + \\gamma_s + \\delta_t + \\varepsilon_{s,t}$. The DDD estimate (Table \\ref{tab:main_ddd}) equals the difference between Panels A and B. A large negative coefficient in Panel A with a near-zero coefficient in Panel B indicates the DDD is driven by HCBS declining in high-stringency states, not by BH rising.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab3_lines, file.path(TABLES, "tab3_decomposition.tex"))

## ---- Table 4: Robustness (with N per row — Stage C reviewer request) ----
cat("Table 4: Robustness checks...\n")

rob_models <- list(
  list(model = results$m1_paid, label = "Baseline (Clean HCBS, Peak Stringency)"),
  list(model = robustness$r1_binary, label = "Binary Treatment (Median Split)"),
  list(model = robustness$r2_cumul, label = "Cumulative Stringency (Mar--Jun)"),
  list(model = robustness$r3_no_never, label = "Excl.~Never-Lockdown States"),
  list(model = robustness$r5_cpt, label = "Alt.~Comparison: CPT Professional"),
  list(model = robustness$r9_all_hcbs, label = "All T-codes (Original Classification)"),
  list(model = robustness$r8_monthly, label = "Monthly Stringency (Post Only)")
)

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Triple-Difference Estimates}",
  "\\label{tab:robustness}",
  "\\small",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  "Specification & Coefficient & SE & 95\\% CI & \\textit{p}-value & N \\\\",
  "\\hline"
)

for (r in rob_models) {
  ct <- coeftable(r$model)
  coef_val <- ct[1, "Estimate"]
  se_val <- ct[1, "Std. Error"]
  pval <- ct[1, "Pr(>|t|)"]
  ci_lo <- coef_val - 1.96 * se_val
  ci_hi <- coef_val + 1.96 * se_val
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  tab4_lines <- c(tab4_lines,
    sprintf("%s & %.3f%s & (%.3f) & [%.3f, %.3f] & [%.3f] & %s \\\\",
            r$label, coef_val, stars, se_val, ci_lo, ci_hi, pval,
            format(r$model$nobs, big.mark = ","))
  )
}

# Add RI results (both outcomes)
tab4_lines <- c(tab4_lines,
  sprintf("RI: Log Paid (%d perms) & %.3f & (%.3f) & --- & [%.3f] & %s \\\\",
          length(robustness$ri_perm_coefs_paid),
          robustness$ri_actual_coef_paid,
          sd(robustness$ri_perm_coefs_paid),
          robustness$ri_pvalue_paid,
          format(results$m1_paid$nobs, big.mark = ",")),
  sprintf("RI: Log Claims (%d perms) & %.3f & (%.3f) & --- & [%.3f] & %s \\\\",
          length(robustness$ri_perm_coefs_claims),
          robustness$ri_actual_coef_claims,
          sd(robustness$ri_perm_coefs_claims),
          robustness$ri_pvalue_claims,
          format(results$m1_paid$nobs, big.mark = ","))
)

# Add WCB if available
if (!is.na(robustness$wcb_pvalue)) {
  tab4_lines <- c(tab4_lines,
    sprintf("Wild Cluster Bootstrap (9999 reps) & --- & --- & [%.2f, %.2f] & [%.3f] & %s \\\\",
            robustness$wcb_ci[1], robustness$wcb_ci[2], robustness$wcb_pvalue,
            format(results$m1_paid$nobs, big.mark = ","))
  )
}

# Add placebo (March 2019)
ct_placebo <- coeftable(robustness$r4_placebo)
coef_p <- ct_placebo[1, "Estimate"]
se_p <- ct_placebo[1, "Std. Error"]
pval_p <- ct_placebo[1, "Pr(>|t|)"]
stars_p <- ifelse(pval_p < 0.01, "***", ifelse(pval_p < 0.05, "**", ifelse(pval_p < 0.1, "*", "")))
tab4_lines <- c(tab4_lines,
  sprintf("Placebo (March 2019) & %.3f%s & (%.3f) & [%.3f, %.3f] & [%.3f] & %s \\\\",
          coef_p, stars_p, se_p, coef_p - 1.96*se_p, coef_p + 1.96*se_p, pval_p,
          format(robustness$r4_placebo$nobs, big.mark = ","))
)

# Add additional placebo dates (Stage C)
if (!is.null(robustness$placebo_results)) {
  for (pname in names(robustness$placebo_results)) {
    pr <- robustness$placebo_results[[pname]]
    if (!is.na(pr$coef)) {
      stars_pr <- ifelse(pr$pval < 0.01, "***", ifelse(pr$pval < 0.05, "**", ifelse(pr$pval < 0.1, "*", "")))
      tab4_lines <- c(tab4_lines,
        sprintf("Placebo (%s) & %.3f%s & (%.3f) & [%.3f, %.3f] & [%.3f] & %s \\\\",
                pname, pr$coef, stars_pr, pr$se,
                pr$coef - 1.96 * pr$se, pr$coef + 1.96 * pr$se, pr$pval,
                format(pr$n, big.mark = ","))
      )
    }
  }
}

# Add LOO summary (Stage C)
if (!is.null(robustness$loo_coefs)) {
  loo_min <- min(robustness$loo_coefs, na.rm = TRUE)
  loo_max <- max(robustness$loo_coefs, na.rm = TRUE)
  tab4_lines <- c(tab4_lines,
    sprintf("Leave-One-Out Range & [%.3f, %.3f] & --- & --- & --- & --- \\\\",
            loo_min, loo_max)
  )
}

tab4_lines <- c(tab4_lines,
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} All specifications use the same three-way fixed effects (state $\\times$ service, service $\\times$ month, state $\\times$ month) and cluster standard errors at the state level. Outcome is log total paid unless noted. Baseline uses clean HCBS classification and peak April 2020 stringency (standardized 0--1). ``All T-codes'' uses the original broad T-prefix classification. For RI, SE column reports the permutation distribution SD; the $p$-value is the share of permuted coefficients exceeding the actual in absolute value. Wild cluster bootstrap was attempted but failed due to singleton fixed effect removal in the three-way FE specification. Placebo tests assign treatment at various pre-period dates on pre-period data only. Leave-one-out reports the range of baseline coefficients when each state is dropped in turn. All outcomes use $\\log(Y + 1)$ to handle zero-valued cells.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(TABLES, "tab4_robustness.tex"))

## ---- Table A1: HCPCS Code Classification (NEW — WS1) ----
cat("Table A1: HCPCS code classification...\n")

if (file.exists(file.path(DATA, "hcpcs_distribution.rds"))) {
  hcpcs_dist <- readRDS(file.path(DATA, "hcpcs_distribution.rds"))
  hcpcs_dist <- hcpcs_dist[order(-total_paid_sum)]
  top_codes <- head(hcpcs_dist, 20)

  # Code descriptions
  code_desc <- data.table(
    HCPCS_CODE = c("T1019","T1020","T2016","T2017","T2022","T2025","T2028","T2033",
                   "T2034","T2036","T1005","T1015","T1023","T1024","T2003","T2005","T2007"),
    description = c("Personal care, 15 min","Personal care, per diem","Habilitation residential, per diem",
                     "Habilitation residential, 15 min","Case mgmt, per month","Waiver services NOS",
                     "Specialized supply","Supported employment","Crisis intervention",
                     "Therapeutic camping","Respite care, 15 min","FQHC visit","Screening",
                     "Eval/assessment","Non-emergency transport","Stretcher van transport","Ambulance transport")
  )

  top_codes <- merge(top_codes, code_desc, by = "HCPCS_CODE", all.x = TRUE)
  top_codes[is.na(description), description := "Other T-code"]

  tabA1_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{HCPCS Code Classification: T-Codes (HCBS) by In-Home Status}",
    "\\label{tab:hcpcs}",
    "\\small",
    "\\begin{tabular}{llrrr}",
    "\\hline\\hline",
    "Code & Description & Spending (\\$B) & Claims (M) & In-Home \\\\",
    "\\hline"
  )

  for (j in 1:nrow(top_codes)) {
    row <- top_codes[j]
    in_home <- ifelse(row$hcbs_clean, "Yes", "No")
    tabA1_lines <- c(tabA1_lines,
      sprintf("%s & %s & %.1f & %.1f & %s \\\\",
              row$HCPCS_CODE,
              substr(row$description, 1, 35),
              row$total_paid_sum / 1e9,
              row$total_claims_sum / 1e6,
              in_home)
    )
  }

  tabA1_lines <- c(tabA1_lines,
    "\\hline\\hline",
    "\\end{tabular}",
    "\\begin{minipage}{0.85\\textwidth}",
    "\\vspace{4pt}",
    "\\footnotesize",
    "\\textit{Notes:} Top 20 T-prefix HCPCS codes by cumulative spending (2018--2024) from T-MSIS. ``In-Home'' = Yes indicates codes classified as genuinely in-person home-based care in the clean HCBS subset. Codes classified as ``No'' include clinic-based visits (T1015), transportation (T2003, T2005, T2007), and facility-based screening/assessment (T1023, T1024). The clean HCBS subset is the primary classification used in all main analyses.",
    "\\end{minipage}",
    "\\end{table}"
  )

  writeLines(tabA1_lines, file.path(TABLES, "tabA1_hcpcs.tex"))
}

## ---- Table A2: Period-Specific (moved to appendix — WS6) ----
cat("Table A2: Period-specific effects (appendix)...\n")

m7 <- results$m7_periods
ct7 <- coeftable(m7)

tabA2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Period-Specific Triple-Difference Effects}",
  "\\label{tab:periods}",
  "\\begin{tabular}{lcc}",
  "\\hline\\hline",
  " & Log Total Paid & 95\\% CI \\\\",
  "\\hline"
)

period_names <- c("Lockdown (Apr--Jun 2020)", "Recovery (Jul--Dec 2020)",
                  "Post-Lockdown (2021)", "Post-Lockdown (2022+)")
for (i in 1:nrow(ct7)) {
  pval <- ct7[i, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  coef_val <- ct7[i, "Estimate"]
  se_val <- ct7[i, "Std. Error"]
  tabA2_lines <- c(tabA2_lines,
    sprintf("Stringency $\\times$ HCBS $\\times$ %s & %.3f%s & [%.2f, %.2f] \\\\",
            period_names[i], coef_val, stars,
            coef_val - 1.96 * se_val, coef_val + 1.96 * se_val),
    sprintf(" & (%.3f) & \\\\[3pt]", se_val)
  )
}

tabA2_lines <- c(tabA2_lines,
  "\\hline",
  "State $\\times$ Service FE & Yes & \\\\",
  "Service $\\times$ Month FE & Yes & \\\\",
  "State $\\times$ Month FE & Yes & \\\\",
  "Clustering & State & \\\\",
  sprintf("Observations & %s & \\\\", format(m7$nobs, big.mark = ",")),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.75\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} Period-specific triple-difference estimates from equation (\\ref{eq:periods}). Standard errors clustered at the state level. $^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tabA2_lines, file.path(TABLES, "tabA2_periods.tex"))

cat("\n=== All tables saved to", TABLES, "===\n")
