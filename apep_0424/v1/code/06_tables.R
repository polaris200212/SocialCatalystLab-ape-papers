## ============================================================================
## 06_tables.R -- Generate all tables
## ============================================================================

source("00_packages.R")
DATA <- "../data"
TABS <- "../tables"
dir.create(TABS, showWarnings = FALSE)

panel_bh <- readRDS(file.path(DATA, "panel_bh.rds"))
parity_dates <- readRDS(file.path(DATA, "parity_dates.rds"))
twfe_results <- readRDS(file.path(DATA, "twfe_results.rds"))
cs_results <- readRDS(file.path(DATA, "cs_results.rds"))

state_month <- readRDS(file.path(DATA, "state_month.rds"))

## --------------------------------------------------------------------------
## Table 1: Summary Statistics
## --------------------------------------------------------------------------

bh_sm <- state_month[service_type == "behavioral_health"]

vars_to_summarize <- c("n_providers", "total_claims", "total_beneficiaries", "total_paid")
var_labels <- c("Unique Billing NPIs", "Total Claims", "Unique Beneficiaries",
                "Total Medicaid Paid (\\$)")

rows <- list()
for (i in seq_along(vars_to_summarize)) {
  v <- vars_to_summarize[i]
  x <- bh_sm[[v]]
  rows[[i]] <- sprintf("%s & %s & %s & %s & %s \\\\",
                        var_labels[i],
                        format(round(mean(x)), big.mark = ","),
                        format(round(sd(x)), big.mark = ","),
                        format(round(min(x)), big.mark = ","),
                        format(round(max(x)), big.mark = ","))
}

tex <- paste0(
  "\\begin{table}[H]\n\\centering\n",
  "\\caption{Summary Statistics: Behavioral Health Claims by State-Month}\n",
  "\\label{tab:summary}\n\\begin{threeparttable}\n",
  "\\begin{tabular}{lrrrr}\n\\toprule\n",
  "Variable & Mean & Std. Dev. & Min & Max \\\\\n\\midrule\n",
  paste(unlist(rows), collapse = "\n"), "\n",
  "\\bottomrule\n\\end{tabular}\n",
  sprintf("\\begin{tablenotes}[flushleft]\n\\small\n\\item \\textit{Notes:} N = %s state-month observations across %d states and %d months (January 2018--December 2024). Behavioral health services defined as HCPCS H-prefix codes. Source: T-MSIS, NPPES.\n\\end{tablenotes}\n",
          format(nrow(bh_sm), big.mark = ","), uniqueN(bh_sm$state), uniqueN(bh_sm$month_date)),
  "\\end{threeparttable}\n\\end{table}\n"
)
writeLines(tex, file.path(TABS, "tab1_summary.tex"))
cat("Table 1 saved.\n")

## --------------------------------------------------------------------------
## Table 2: TWFE Main Results
## --------------------------------------------------------------------------

etable(twfe_results$twfe_prov, twfe_results$twfe_claim,
       twfe_results$twfe_benef, twfe_results$twfe_paid,
       tex = TRUE, style.tex = style.tex("aer"),
       fitstat = ~r2 + n,
       headers = c("ln(Providers)", "ln(Claims)", "ln(Beneficiaries)", "ln(Paid)"),
       title = "Effect of Telehealth Parity on Behavioral Health: TWFE",
       label = "tab:twfe",
       notes = "Standard errors clustered at state level. All specifications include state and quarter fixed effects. Sample: 51 states/DC, Q1 2018--Q4 2024.",
       file = file.path(TABS, "tab2_twfe.tex"))
cat("Table 2 saved.\n")

## --------------------------------------------------------------------------
## Table 3: CS ATT Summary
## --------------------------------------------------------------------------

cs_tab <- data.table(
  Outcome = c("ln(Providers)", "ln(Beneficiaries)", "ln(Claims)", "ln(Paid)"),
  ATT = c(cs_results$att_prov$overall.att, cs_results$att_benef$overall.att,
          cs_results$att_claim$overall.att, cs_results$att_paid$overall.att),
  SE = c(cs_results$att_prov$overall.se, cs_results$att_benef$overall.se,
         cs_results$att_claim$overall.se, cs_results$att_paid$overall.se)
)
cs_tab[, pct := sprintf("%.1f\\%%", (exp(ATT) - 1) * 100)]
cs_tab[, pval := 2 * pnorm(-abs(ATT / SE))]
cs_tab[, stars := fifelse(pval < 0.01, "***", fifelse(pval < 0.05, "**",
              fifelse(pval < 0.1, "*", "")))]

tex3 <- paste0(
  "\\begin{table}[H]\n\\centering\n",
  "\\caption{Callaway-Sant'Anna Overall ATT Estimates}\n\\label{tab:cs_att}\n",
  "\\begin{threeparttable}\n\\begin{tabular}{lccc}\n\\toprule\n",
  "Outcome & ATT & Std. Error & Implied \\% Change \\\\\n\\midrule\n"
)
for (i in 1:nrow(cs_tab)) {
  tex3 <- paste0(tex3, sprintf("%s & %.4f%s & (%.4f) & %s \\\\\n",
                                cs_tab$Outcome[i], cs_tab$ATT[i], cs_tab$stars[i],
                                cs_tab$SE[i], cs_tab$pct[i]))
}
tex3 <- paste0(tex3,
  sprintf("\\bottomrule\n\\end{tabular}\n\\begin{tablenotes}[flushleft]\n\\small\n\\item \\textit{Notes:} Callaway and Sant'Anna (2021) doubly robust estimator with never-treated comparison group. Bootstrap standard errors (1,000 iterations). %d treated states, %d control states. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n",
          uniqueN(panel_bh[treated_state == 1]$state),
          uniqueN(panel_bh[treated_state == 0]$state)))
writeLines(tex3, file.path(TABS, "tab3_cs_att.tex"))
cat("Table 3 saved.\n")

## --------------------------------------------------------------------------
## Table 4: Adoption Dates
## --------------------------------------------------------------------------

state_names <- c(state.name, "District of Columbia")
names(state_names) <- c(state.abb, "DC")
statutes <- c(
  GA="SB 118", NJ="A 1467", WV="HB 2024", KY="HB 140", VA="HB 81",
  HI="HB 907", MN="SF 3019", CO="HB 21-1190", NM="HB 245", IN="SB 3",
  MS="HB 1531", AR="Act 829", ND="HB 1247", LA="HB 449", MO="SB 5",
  CT="PA 21-9", ME="LD 1034", MT="SB 101", OK="SB 674",
  NH="HB 602", DE="HB 348", IL="SB 2294", SC="HB 3726",
  IA="HF 2548", AZ="SB 1089", NE="LB 400"
)

tex4 <- paste0(
  "\\begin{table}[H]\n\\centering\n\\caption{Telehealth Payment Parity Law Adoption Dates}\n",
  "\\label{tab:adoption}\n\\begin{threeparttable}\n",
  "\\begin{tabular}{llll}\n\\toprule\nState & Effective Date & Statute & Year \\\\\n\\midrule\n"
)
ordered <- parity_dates[order(parity_date)]
for (i in 1:nrow(ordered)) {
  st <- ordered$state[i]
  tex4 <- paste0(tex4, sprintf("%s & %s & %s & %d \\\\\n",
                                state_names[st], format(ordered$parity_date[i], "%B %d, %Y"),
                                statutes[st], ordered$parity_year[i]))
}
tex4 <- paste0(tex4,
  "\\bottomrule\n\\end{tabular}\n\\begin{tablenotes}[flushleft]\n\\small\n",
  "\\item \\textit{Notes:} Permanent state laws requiring Medicaid to reimburse telehealth at parity with in-person services. Compiled from CCHPCA, NCSL, and state legislative records.\n",
  "\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
writeLines(tex4, file.path(TABS, "tab4_adoption.tex"))
cat("Table 4 saved.\n")

cat("\n=== All tables generated ===\n")
