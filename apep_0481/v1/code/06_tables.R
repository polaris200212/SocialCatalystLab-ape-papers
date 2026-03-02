## 06_tables.R — Generate all LaTeX tables
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_post83.rds"))
df_whipped <- df[free_vote == 0]
df_whipped[, party_period := paste0(ppg, "_", elecper)]
results <- readRDS(file.path(data_dir, "main_results.rds"))

## ============================================================
## Table 1: Summary Statistics (LaTeX)
## ============================================================

## Panel A: Full sample
sumstats <- df_whipped[, .(
  Variable = c("Party-line deviation", "Female", "District mandate",
               "Dual candidate", "Electoral safety", "Free vote (excluded)"),
  Mean = c(mean(deviate_own), mean(female), mean(district),
           mean(dualcand == 1, na.rm = TRUE),
           mean(elecsafe_overall, na.rm = TRUE),
           mean(df$free_vote == 1)),
  SD = c(sd(deviate_own), sd(female), sd(district),
         sd(dualcand == 1, na.rm = TRUE),
         sd(elecsafe_overall, na.rm = TRUE),
         sd(df$free_vote == 1)),
  N = c(.N, .N, .N,
        sum(!is.na(dualcand)),
        sum(!is.na(elecsafe_overall)),
        nrow(df))
)]

## Panel B: By gender
sumstats_gender <- df_whipped[, .(
  rebellion_rate = mean(deviate_own),
  district_share = mean(district),
  elecsafe = mean(elecsafe_overall, na.rm = TRUE),
  n_votes = .N,
  n_mps = uniqueN(id_de_parliament)
), by = .(Gender = fifelse(female == 1, "Female", "Male"))]

## Panel C: By party
party_map <- c("1" = "SPD", "2" = "CDU/CSU", "4" = "FDP",
               "5" = "Greens", "6" = "Linke/PDS", "19" = "AfD")
top_parties <- c(1, 2, 4, 5, 6, 19)
sumstats_party <- df_whipped[ppg %in% top_parties, .(
  `Rebellion (\\%)` = round(mean(deviate_own) * 100, 2),
  `Female (\\%)` = round(mean(female) * 100, 1),
  `District (\\%)` = round(mean(district) * 100, 1),
  `N (votes)` = format(.N, big.mark = ","),
  `N (MPs)` = uniqueN(id_de_parliament)
), by = .(Party = party_map[as.character(ppg)])]

## Write LaTeX
sink(file.path(tab_dir, "table1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Full Sample (whipped votes, WP 10--19)}} \\\\\n")
cat("\\midrule\n")
cat("Variable & Mean & SD & N \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(sumstats))) {
  cat(sprintf("%s & %.4f & %.4f & %s \\\\\n",
              sumstats$Variable[i], sumstats$Mean[i], sumstats$SD[i],
              format(sumstats$N[i], big.mark = ",")))
}
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: By Gender}} \\\\\n")
cat("\\midrule\n")
cat(" & Rebellion (\\%) & District (\\%) & N (votes) \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(sumstats_gender))) {
  cat(sprintf("%s & %.2f & %.1f & %s \\\\\n",
              sumstats_gender$Gender[i],
              sumstats_gender$rebellion_rate[i] * 100,
              sumstats_gender$district_share[i] * 100,
              format(sumstats_gender$n_votes[i], big.mark = ",")))
}
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel C: By Party}} \\\\\n")
cat("\\midrule\n")
cat("Party & Rebellion (\\%) & Female (\\%) & N (votes) \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(sumstats_party))) {
  cat(sprintf("%s & %s & %s & %s \\\\\n",
              sumstats_party$Party[i],
              sumstats_party$`Rebellion (\\%)`[i],
              sumstats_party$`Female (\\%)`[i],
              sumstats_party$`N (votes)`[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Sample restricted to whipped roll-call votes (\\textit{namentliche Abstimmungen}) in legislative periods 10--19 (1983--2021). Party-line deviation is a binary indicator equal to 1 if the legislator voted against the majority position of their parliamentary party group (\\textit{Fraktion}). Electoral safety is a continuous measure from 0 (certain to lose) to 1 (certain to win). Free votes (\\textit{Gewissensentscheidungen}) are excluded from the analysis sample.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

## ============================================================
## Table 2: Main Results (LaTeX via modelsummary)
## ============================================================

## Re-run models to ensure they're in memory
m1 <- feols(deviate_own ~ female | party_period,
            data = df_whipped, cluster = "id_de_parliament")
m2 <- feols(deviate_own ~ female + district | party_period,
            data = df_whipped, cluster = "id_de_parliament")
m3 <- feols(deviate_own ~ female * district | party_period,
            data = df_whipped, cluster = "id_de_parliament")
m4 <- feols(deviate_own ~ female * district + elecsafe_overall |
              party_period,
            data = df_whipped[!is.na(elecsafe_overall)],
            cluster = "id_de_parliament")
m5 <- feols(deviate_own ~ female * district + elecsafe_overall |
              party_period + vote_id,
            data = df_whipped[!is.na(elecsafe_overall)],
            cluster = "id_de_parliament")

models <- list(
  "(1)" = m1, "(2)" = m2, "(3)" = m3,
  "(4)" = m4, "(5)" = m5
)

cm <- c(
  "female" = "Female",
  "district" = "District",
  "female:district" = "Female $\\times$ District",
  "elecsafe_overall" = "Electoral Safety"
)

gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
  list("raw" = "r2.within", "clean" = "Within $R^2$", "fmt" = 6)
)

modelsummary(
  models,
  output = file.path(tab_dir, "table2_main.tex"),
  coef_map = cm,
  gof_map = gm,
  stars = c("*" = 0.05, "**" = 0.01, "***" = 0.001),
  title = "Gender, Mandate Type, and Party-Line Deviation",
  notes = list(
    "Standard errors clustered at legislator level in parentheses.",
    "All specifications include party $\\times$ period fixed effects.",
    "Column (5) adds vote fixed effects."
  ),
  escape = FALSE
)
cat("Table 2 saved.\n")

## ============================================================
## Table 3: Robustness Summary (LaTeX)
## ============================================================

rob <- readRDS(file.path(data_dir, "robustness_results.rds"))

sink(file.path(tab_dir, "table3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Specification & Female$\\times$District & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")

specs <- list(
  list("Main specification", m4),
  list("Strong party line ($\\geq$90\\% cohesion)", rob$r1a_strong),
  list("Final passage votes only", rob$r1b_final),
  list("Excl.\\ opposition-initiated RCVs", rob$r3_nooppo),
  list("Two-way clustering (legislator + vote)", rob$r7b_twoway)
)

for (s in specs) {
  if (!is.null(s[[2]]) && "female:district" %in% names(coef(s[[2]]))) {
    ct <- coeftable(s[[2]])
    cat(sprintf("%s & %.4f & %.4f & %.3f & %s \\\\\n",
                s[[1]],
                ct["female:district", 1],
                ct["female:district", 2],
                ct["female:district", 4],
                format(nobs(s[[2]]), big.mark = ",")))
  }
}

cat("\\midrule\n")
cat(sprintf("RI $p$-value (uncontrolled spec) & \\multicolumn{4}{c}{%.3f (999 permutations)} \\\\\n",
            rob$ri_pvalue))
if (!is.null(rob$ri_pvalue_pref)) {
  cat(sprintf("RI $p$-value (preferred spec) & \\multicolumn{4}{c}{%.3f (999 permutations)} \\\\\n",
              rob$ri_pvalue_pref))
}
cat(sprintf("MDE (80\\%% power, 5\\%% significance) & \\multicolumn{4}{c}{%.4f (%.1f\\%% of baseline)} \\\\\n",
            rob$mde, rob$mde / rob$baseline * 100))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} All specifications include party $\\times$ period fixed effects and control for electoral safety. Standard errors clustered at legislator level unless otherwise noted. Randomization inference permutes gender assignment within party-period cells.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 3 saved.\n")

cat("\nAll tables generated.\n")
