## ============================================================
## 06_tables.R — All Table Generation
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

analysis <- readRDS(file.path(data_dir, "analysis.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))
summ_stats <- readRDS(file.path(data_dir, "summ_stats.rds"))
bank_branches <- readRDS(file.path(data_dir, "bank_branches.rds"))

## ---------------------------------------------------------
## Table 1: Summary Statistics
## ---------------------------------------------------------
cat("Generating Table 1: Summary Statistics...\n")

## Panel A: State characteristics
fewsnet_states <- unique(analysis$state)
state_chars <- bank_branches[state %in% fewsnet_states,
  .(state, branches_2021, pop_2021_m, branches_per_100k, cash_scarcity_std)]

panel_a <- data.table(
  Variable = c("Bank branches (count)", "Population (millions)",
               "Bank branches per 100k", "Cash scarcity index (0-1)"),
  Mean = c(mean(state_chars$branches_2021),
           mean(state_chars$pop_2021_m),
           mean(state_chars$branches_per_100k),
           mean(state_chars$cash_scarcity_std)),
  SD = c(sd(state_chars$branches_2021),
         sd(state_chars$pop_2021_m),
         sd(state_chars$branches_per_100k),
         sd(state_chars$cash_scarcity_std)),
  Min = c(min(state_chars$branches_2021),
          min(state_chars$pop_2021_m),
          min(state_chars$branches_per_100k),
          min(state_chars$cash_scarcity_std)),
  Max = c(max(state_chars$branches_2021),
          max(state_chars$pop_2021_m),
          max(state_chars$branches_per_100k),
          max(state_chars$cash_scarcity_std)),
  N = nrow(state_chars)
)

## Panel B: Food prices
pre_crisis <- analysis[week < as.Date("2023-01-30")]
during_crisis <- analysis[crisis_acute == 1]
post_crisis <- analysis[week > as.Date("2023-03-06") & week <= as.Date("2023-12-31")]

panel_b <- data.table(
  Variable = c("Log food price index (pre-crisis)",
               "Log food price index (crisis)",
               "Log food price index (post-crisis)",
               "N products per state-week",
               "Conflict events (state-month)"),
  Mean = c(mean(pre_crisis$log_food_price_idx, na.rm = TRUE),
           mean(during_crisis$log_food_price_idx, na.rm = TRUE),
           mean(post_crisis$log_food_price_idx, na.rm = TRUE),
           mean(analysis$n_products, na.rm = TRUE),
           mean(analysis$n_conflict_events, na.rm = TRUE)),
  SD = c(sd(pre_crisis$log_food_price_idx, na.rm = TRUE),
         sd(during_crisis$log_food_price_idx, na.rm = TRUE),
         sd(post_crisis$log_food_price_idx, na.rm = TRUE),
         sd(analysis$n_products, na.rm = TRUE),
         sd(analysis$n_conflict_events, na.rm = TRUE)),
  Min = c(min(pre_crisis$log_food_price_idx, na.rm = TRUE),
          min(during_crisis$log_food_price_idx, na.rm = TRUE),
          min(post_crisis$log_food_price_idx, na.rm = TRUE),
          min(analysis$n_products, na.rm = TRUE),
          min(analysis$n_conflict_events, na.rm = TRUE)),
  Max = c(max(pre_crisis$log_food_price_idx, na.rm = TRUE),
          max(during_crisis$log_food_price_idx, na.rm = TRUE),
          max(post_crisis$log_food_price_idx, na.rm = TRUE),
          max(analysis$n_products, na.rm = TRUE),
          max(analysis$n_conflict_events, na.rm = TRUE)),
  N = c(nrow(pre_crisis), nrow(during_crisis), nrow(post_crisis),
        nrow(analysis), nrow(analysis))
)

## Combine and save
summ_table <- rbind(
  data.table(Panel = "A. State Characteristics", panel_a),
  data.table(Panel = "B. Food Prices and Controls", panel_b)
)

## Format for LaTeX
summ_tex <- summ_table[, .(
  Variable,
  Mean = sprintf("%.2f", Mean),
  SD = sprintf("%.2f", SD),
  Min = sprintf("%.2f", Min),
  Max = sprintf("%.2f", Max),
  N = formatC(N, format = "d", big.mark = ",")
)]

write.csv(summ_table, file.path(tab_dir, "table1_summary_stats.csv"),
          row.names = FALSE)

## ---------------------------------------------------------
## Table 2: Main Results
## ---------------------------------------------------------
cat("Generating Table 2: Main regression results...\n")

## Extract results from all models
models <- list(results$m1, results$m2, results$m3, results$m4)

## Export with etable
etable(
  results$m1, results$m2, results$m3, results$m4,
  tex = TRUE,
  file = file.path(tab_dir, "table2_main_results.tex"),
  replace = TRUE,
  dict = c(
    "cash_scarcity_std:crisis_acute" = "Cash Scarcity $\\times$ Crisis",
    "cash_scarcity_std:post_deadline" = "Cash Scarcity $\\times$ Post-Deadline",
    "cash_scarcity_std:post_announce" = "Cash Scarcity $\\times$ Post-Announce",
    "log1p(n_conflict_events)" = "Log(1 + Conflict Events)"
  ),
  se.below = TRUE,
  signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  fitstat = ~ n + wr2 + r2,
  title = "The Effect of Cash Scarcity on Food Prices",
  notes = paste0(
    "Standard errors clustered at the state level in parentheses. ",
    "The dependent variable is the log of the state-level food price index. ",
    "Cash Scarcity is the standardized inverse of bank branches per 100,000 population. ",
    "Crisis = weeks of Feb 1--Mar 6, 2023. ",
    "Post-Deadline = all weeks after Jan 30, 2023. ",
    "Post-Announce = all weeks after Oct 26, 2022. ",
    "All specifications include state and week fixed effects."
  )
)

## Also save as CSV for easy reading
main_csv <- data.table(
  Model = paste0("(", 1:4, ")"),
  Specification = c("Acute Crisis", "Post-Deadline", "With Conflict",
                     "Announcement + Crisis"),
  Coefficient = sapply(models, function(m) {
    cfs <- coef(m)
    cf <- cfs[grep("cash_scarcity_std:crisis_acute|cash_scarcity_std:post_deadline",
                    names(cfs))[1]]
    sprintf("%.4f", cf)
  }),
  SE = sapply(models, function(m) {
    ses <- se(m)
    s <- ses[grep("cash_scarcity_std:crisis_acute|cash_scarcity_std:post_deadline",
                   names(ses))[1]]
    sprintf("(%.4f)", s)
  }),
  N = sapply(models, nobs),
  States = 13
)

write.csv(main_csv, file.path(tab_dir, "table2_main_results.csv"),
          row.names = FALSE)

## ---------------------------------------------------------
## Table 3: Robustness — Bootstrap and RI
## ---------------------------------------------------------
cat("Generating Table 3: Inference robustness...\n")

boot_result <- results$boot_m1
m1 <- results$m1

inference_tab <- data.table(
  Method = c("Cluster-Robust SE", "Wild Cluster Bootstrap (Webb)",
             "Randomization Inference"),
  Estimate = sprintf("%.4f", robustness$actual_coef),
  `p-value` = c(
    sprintf("%.4f", fixest::pvalue(m1)["cash_scarcity_std:crisis_acute"]),
    if (!is.null(boot_result)) sprintf("%.4f", boot_result$p_val) else "N/A",
    sprintf("%.4f", robustness$ri_pval)
  ),
  `95% CI` = c(
    sprintf("[%.4f, %.4f]",
            coef(m1)["cash_scarcity_std:crisis_acute"] -
              1.96 * se(m1)["cash_scarcity_std:crisis_acute"],
            coef(m1)["cash_scarcity_std:crisis_acute"] +
              1.96 * se(m1)["cash_scarcity_std:crisis_acute"]),
    if (!is.null(boot_result))
      sprintf("[%.4f, %.4f]", boot_result$conf_int[1], boot_result$conf_int[2])
    else "N/A",
    "---"
  ),
  Clusters = c(13, 13, 13),
  Notes = c("State-level", "9,999 reps, 6-point weights",
            "999 permutations")
)

write.csv(inference_tab, file.path(tab_dir, "table3_inference.csv"),
          row.names = FALSE)

## ---------------------------------------------------------
## Table 4: Commodity Heterogeneity
## ---------------------------------------------------------
cat("Generating Table 4: Commodity heterogeneity...\n")

write.csv(robustness$hetero_results,
          file.path(tab_dir, "table4_commodity_hetero.csv"),
          row.names = FALSE)

## ---------------------------------------------------------
## Table 5: Treatment Intensity by State
## ---------------------------------------------------------
cat("Generating Table 5: Treatment intensity...\n")

treat_table <- bank_branches[state %in% fewsnet_states,
  .(State = state,
    `DMB Branches` = branches_2021,
    `Pop. (M)` = round(pop_2021_m, 2),
    `Branches/100k` = round(branches_per_100k, 1),
    `Cash Scarcity` = round(cash_scarcity_std, 3))
][order(-`Cash Scarcity`)]

write.csv(treat_table, file.path(tab_dir, "table5_treatment_intensity.csv"),
          row.names = FALSE)

cat("\nAll tables generated in:", tab_dir, "\n")
cat("Files:", paste(list.files(tab_dir), collapse = ", "), "\n")
