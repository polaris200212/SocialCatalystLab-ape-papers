## 03_main_analysis.R — Main DDD analysis: Gender × Mandate Type × Party-Term
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
out_tables <- "../tables"
dir.create(out_tables, showWarnings = FALSE, recursive = TRUE)

## Load analysis sample
df <- readRDS(file.path(data_dir, "analysis_post83.rds"))
cat(sprintf("Analysis sample: %s observations\n", format(nrow(df), big.mark = ",")))

## Drop free votes (Gewissensentscheidungen) for main analysis
## These have no party line to deviate from
df_whipped <- df[free_vote == 0]
cat(sprintf("Whipped votes only: %s observations\n",
            format(nrow(df_whipped), big.mark = ",")))

## Create party-period identifier for FE
df_whipped[, party_period := paste0(ppg, "_", elecper)]

## ============================================================
## TABLE 1: Summary Statistics
## ============================================================
cat("\n=== TABLE 1: Summary Statistics ===\n\n")

## Panel A: Full sample
summary_full <- df_whipped[, .(
  `Mean` = c(
    mean(deviate_own),
    mean(female),
    mean(district),
    mean(dualcand == 1, na.rm = TRUE),
    mean(elecsafe_overall, na.rm = TRUE),
    mean(seniority)
  ),
  `SD` = c(
    sd(deviate_own),
    sd(female),
    sd(district),
    sd(dualcand == 1, na.rm = TRUE),
    sd(elecsafe_overall, na.rm = TRUE),
    sd(seniority)
  ),
  `N` = c(
    sum(!is.na(deviate_own)),
    sum(!is.na(female)),
    sum(!is.na(district)),
    sum(!is.na(dualcand)),
    sum(!is.na(elecsafe_overall)),
    sum(!is.na(seniority))
  )
)]
summary_full[, Variable := c("Rebel (deviate from party)", "Female", "District mandate",
                              "Dual candidate", "Electoral safety", "Seniority")]
cat("Panel A: Full Sample\n")
print(summary_full[, .(Variable, Mean = round(Mean, 4), SD = round(SD, 4), N)])

## Panel B: By Gender × Mandate
cat("\nPanel B: Rebellion Rate by Gender × Mandate\n")
cell_means <- df_whipped[, .(
  rebellion_rate = mean(deviate_own) * 100,
  n_votes = .N,
  n_mps = uniqueN(id_de_parliament)
), by = .(female, district)]
cell_means[, Gender := fifelse(female == 1, "Female", "Male")]
cell_means[, Mandate := fifelse(district == 1, "District", "List")]
print(cell_means[, .(Gender, Mandate, rebellion_rate = round(rebellion_rate, 3),
                      n_votes, n_mps)])

## Compute raw DDD
cat("\nRaw DDD (before FE):\n")
raw_diff_dist <- cell_means[Gender == "Female" & Mandate == "District"]$rebellion_rate -
                 cell_means[Gender == "Male" & Mandate == "District"]$rebellion_rate
raw_diff_list <- cell_means[Gender == "Female" & Mandate == "List"]$rebellion_rate -
                 cell_means[Gender == "Male" & Mandate == "List"]$rebellion_rate
cat(sprintf("  Gender gap (District): %.3f pp\n", raw_diff_dist))
cat(sprintf("  Gender gap (List):     %.3f pp\n", raw_diff_list))
cat(sprintf("  DDD (District - List): %.3f pp\n", raw_diff_dist - raw_diff_list))

## ============================================================
## TABLE 2: Main Regression Results (DDD)
## ============================================================
cat("\n=== TABLE 2: Main Regression Results ===\n\n")

## Model 1: Baseline — Female only
m1 <- feols(deviate_own ~ female | party_period,
            data = df_whipped, cluster = "id_de_parliament")

## Model 2: Add district
m2 <- feols(deviate_own ~ female + district | party_period,
            data = df_whipped, cluster = "id_de_parliament")

## Model 3: DDD — Female × District
m3 <- feols(deviate_own ~ female * district | party_period,
            data = df_whipped, cluster = "id_de_parliament")

## Model 4: DDD + controls
m4 <- feols(deviate_own ~ female * district + elecsafe_overall +
              seniority | party_period,
            data = df_whipped, cluster = "id_de_parliament")

## Model 5: DDD + controls + vote FE
m5 <- feols(deviate_own ~ female * district + elecsafe_overall +
              seniority | party_period + vote_id,
            data = df_whipped, cluster = "id_de_parliament")

## Model 6: Triple interaction with electoral safety
m6 <- feols(deviate_own ~ female * district * elecsafe_overall +
              seniority | party_period,
            data = df_whipped, cluster = "id_de_parliament")

cat("Model results:\n")
etable(m1, m2, m3, m4, m5, m6,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
       se.below = TRUE)

## Save coefficient table
sink(file.path(out_tables, "table2_main_results.txt"))
etable(m1, m2, m3, m4, m5, m6,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
       se.below = TRUE,
       fitstat = c("n", "r2", "ar2"))
sink()

## ============================================================
## TABLE 3: Heterogeneity by Party
## ============================================================
cat("\n=== TABLE 3: Heterogeneity by Party ===\n\n")

## Map PPG codes to party names
## Based on composition analysis:
## ppg=1: SPD, ppg=2: CDU/CSU, ppg=4: FDP, ppg=5: Greens, ppg=6: Linke, ppg=19: AfD
party_map <- c("1" = "SPD", "2" = "CDU/CSU", "4" = "FDP",
               "5" = "Greens", "6" = "Linke/PDS", "19" = "AfD")

## Run DDD separately by party (only parties with enough female members)
party_results <- list()
for (p in c("1", "2", "4", "5", "6")) {
  sub <- df_whipped[ppg == as.numeric(p)]
  if (nrow(sub) < 1000 || sum(sub$female) < 100) next

  m <- tryCatch(
    feols(deviate_own ~ female * district + elecsafe_overall |
            as.factor(elecper),
          data = sub, cluster = "id_de_parliament"),
    error = function(e) NULL
  )

  if (!is.null(m)) {
    party_results[[party_map[p]]] <- m
    cat(sprintf("\n%s (N=%s, Female=%s):\n",
                party_map[p], format(nrow(sub), big.mark = ","),
                format(sum(sub$female), big.mark = ",")))
    coef_fe <- coeftable(m)
    if ("female:district" %in% rownames(coef_fe)) {
      cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
                  coef_fe["female:district", 1],
                  coef_fe["female:district", 2],
                  coef_fe["female:district", 4]))
    }
    cat(sprintf("  Female: %.4f (SE=%.4f, p=%.3f)\n",
                coef_fe["female", 1],
                coef_fe["female", 2],
                coef_fe["female", 4]))
  }
}

## Save party results
if (length(party_results) > 0) {
  sink(file.path(out_tables, "table3_party_heterogeneity.txt"))
  do.call(etable, c(party_results, list(se.below = TRUE,
                                          fitstat = c("n", "r2"))))
  sink()
}

## ============================================================
## TABLE 4: Policy Domain Heterogeneity
## ============================================================
cat("\n=== TABLE 4: Policy Domain Heterogeneity ===\n\n")

## Feminine policy areas (health, education, social welfare, civil rights)
m_fem <- feols(deviate_own ~ female * district + elecsafe_overall +
                 seniority | party_period,
               data = df_whipped[feminine_policy == 1],
               cluster = "id_de_parliament")

## Masculine policy areas (defense, foreign trade, science)
m_masc <- feols(deviate_own ~ female * district + elecsafe_overall +
                  seniority | party_period,
                data = df_whipped[masculine_policy == 1],
                cluster = "id_de_parliament")

## All other policy areas
m_other <- feols(deviate_own ~ female * district + elecsafe_overall +
                   seniority | party_period,
                 data = df_whipped[feminine_policy == 0 & masculine_policy == 0],
                 cluster = "id_de_parliament")

cat("Policy Domain Results:\n")
etable(m_fem, m_masc, m_other,
       headers = c("Feminine", "Masculine", "Other"),
       se.below = TRUE)

sink(file.path(out_tables, "table4_policy_heterogeneity.txt"))
etable(m_fem, m_masc, m_other,
       headers = c("Feminine", "Masculine", "Other"),
       se.below = TRUE,
       fitstat = c("n", "r2"))
sink()

## ============================================================
## TABLE 5: Time Evolution
## ============================================================
cat("\n=== TABLE 5: Time Evolution ===\n\n")

## Early period (WP 10-13, 1983-1998)
m_early <- feols(deviate_own ~ female * district + elecsafe_overall |
                   party_period,
                 data = df_whipped[elecper %between% c(10, 13)],
                 cluster = "id_de_parliament")

## Middle period (WP 14-16, 1998-2009)
m_mid <- feols(deviate_own ~ female * district + elecsafe_overall |
                 party_period,
               data = df_whipped[elecper %between% c(14, 16)],
               cluster = "id_de_parliament")

## Late period (WP 17-19, 2009-2021)
m_late <- feols(deviate_own ~ female * district + elecsafe_overall |
                  party_period,
                data = df_whipped[elecper %between% c(17, 19)],
                cluster = "id_de_parliament")

cat("Time Period Results:\n")
etable(m_early, m_mid, m_late,
       headers = c("1983-1998", "1998-2009", "2009-2021"),
       se.below = TRUE)

sink(file.path(out_tables, "table5_time_evolution.txt"))
etable(m_early, m_mid, m_late,
       headers = c("1983-1998", "1998-2009", "2009-2021"),
       se.below = TRUE,
       fitstat = c("n", "r2"))
sink()

## ============================================================
## Save Key Results for Paper
## ============================================================
cat("\n=== Key Results Summary ===\n\n")
main_coefs <- coeftable(m4)
cat("Main specification (Model 4):\n")
print(main_coefs)

## Save all models for figure generation
results <- list(
  m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5, m6 = m6,
  m_fem = m_fem, m_masc = m_masc, m_other = m_other,
  m_early = m_early, m_mid = m_mid, m_late = m_late,
  party_results = party_results,
  cell_means = cell_means,
  raw_ddd = raw_diff_dist - raw_diff_list
)
saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("Results saved to main_results.rds\n")
