## ============================================================
## 06_tables.R — Summary statistics and regression tables
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

tab_dir <- file.path(BASE_DIR, "tables")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(BASE_DIR, "data", "district_panel.csv"))

# ══════════════════════════════════════════════════════════════
# TABLE 1: Summary Statistics
# ══════════════════════════════════════════════════════════════

cat("Table 1: Summary statistics...\n")

# Pre-treatment period summary (2012-2015)
pre <- panel[year <= 2015]

# Baseline district characteristics (one per district)
base <- panel[year == 2012, .(
  dist_id, pc11_state_id, cohort, pop_2011, hh_2011,
  lit_rate_2011, sc_share_2011, st_share_2011,
  worker_share_2011, female_share_2011, rural_share
)]

# Panel A: District characteristics
stats_base <- data.table(
  Variable = c("Population (2011 Census)", "Households",
               "Literacy Rate", "SC Share", "ST Share",
               "Worker Share", "Female Share", "Rural Share"),
  Mean = c(
    mean(base$pop_2011, na.rm = TRUE),
    mean(base$hh_2011, na.rm = TRUE),
    mean(base$lit_rate_2011, na.rm = TRUE),
    mean(base$sc_share_2011, na.rm = TRUE),
    mean(base$st_share_2011, na.rm = TRUE),
    mean(base$worker_share_2011, na.rm = TRUE),
    mean(base$female_share_2011, na.rm = TRUE),
    mean(base$rural_share, na.rm = TRUE)
  ),
  SD = c(
    sd(base$pop_2011, na.rm = TRUE),
    sd(base$hh_2011, na.rm = TRUE),
    sd(base$lit_rate_2011, na.rm = TRUE),
    sd(base$sc_share_2011, na.rm = TRUE),
    sd(base$st_share_2011, na.rm = TRUE),
    sd(base$worker_share_2011, na.rm = TRUE),
    sd(base$female_share_2011, na.rm = TRUE),
    sd(base$rural_share, na.rm = TRUE)
  ),
  N = rep(nrow(base), 8)
)

# Panel B: Nightlights (pre-treatment)
stats_nl <- data.table(
  Variable = c("Log Nightlights (Total)", "Log Nightlights (Rural)",
               "Log Nightlights (Per Capita)"),
  Mean = c(
    mean(pre$log_nl, na.rm = TRUE),
    mean(pre$log_nl_rural, na.rm = TRUE),
    mean(pre$log_nl_pc, na.rm = TRUE)
  ),
  SD = c(
    sd(pre$log_nl, na.rm = TRUE),
    sd(pre$log_nl_rural, na.rm = TRUE),
    sd(pre$log_nl_pc, na.rm = TRUE)
  ),
  N = rep(nrow(pre), 3)
)

stats_all <- rbind(stats_base, stats_nl)
stats_all[, Mean := round(Mean, 3)]
stats_all[, SD := round(SD, 3)]

# Write to LaTeX
tab1 <- kbl(stats_all, format = "latex", booktabs = TRUE,
            caption = "Summary Statistics",
            label = "tab:sumstats") |>
  kable_styling(latex_options = "hold_position") |>
  pack_rows("Panel A: District Characteristics (2011 Census)", 1, 8) |>
  pack_rows("Panel B: Nightlights (Pre-Treatment, 2012--2015)", 9, 11)

writeLines(tab1, file.path(tab_dir, "table1_sumstats.tex"))

# ══════════════════════════════════════════════════════════════
# TABLE 2: Covariate Balance Across Cohorts
# ══════════════════════════════════════════════════════════════

cat("Table 2: Covariate balance...\n")

balance <- base[, .(
  N = .N,
  Pop = round(mean(pop_2011, na.rm = TRUE)),
  Literacy = round(mean(lit_rate_2011, na.rm = TRUE), 3),
  Rural = round(mean(rural_share, na.rm = TRUE), 3),
  SC_ST = round(mean(sc_share_2011 + st_share_2011, na.rm = TRUE), 3),
  Workers = round(mean(worker_share_2011, na.rm = TRUE), 3)
), by = cohort]

balance <- balance[order(cohort)]
setnames(balance, c("Cohort", "Districts", "Mean Pop.",
                     "Literacy", "Rural Share", "SC/ST Share", "Worker Share"))

tab2 <- kbl(balance, format = "latex", booktabs = TRUE,
            caption = "Covariate Balance Across Treatment Cohorts",
            label = "tab:balance") |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "Each row shows the mean baseline characteristics of districts in states that declared ODF in the indicated year.",
           threeparttable = TRUE)

writeLines(tab2, file.path(tab_dir, "table2_balance.tex"))

# ══════════════════════════════════════════════════════════════
# TABLE 3: Main Results
# ══════════════════════════════════════════════════════════════

cat("Table 3: Main results...\n")

twfe <- readRDS(file.path(BASE_DIR, "data", "twfe_results.rds"))
cs_att <- readRDS(file.path(BASE_DIR, "data", "cs_att.rds"))

# Build main results table
models <- list(
  "TWFE\nBinary" = twfe$m1,
  "TWFE\nWeighted" = twfe$m2,
  "TWFE\nRural NL" = twfe$m3,
  "TWFE\nPer Capita" = twfe$m4,
  "TWFE\nState Trends" = twfe$m5
)

options("modelsummary_format_numeric_latex" = "plain")

tab3 <- modelsummary(
  models,
  output = file.path(tab_dir, "table3_main_results.tex"),
  stars = c('*' = .1, '**' = .05, '***' = .01),
  coef_map = c(
    "post_odf" = "Post-ODF",
    "treat_weighted" = "ODF Exposure"
  ),
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  title = "Effect of ODF Declaration on District Nightlights",
  notes = list(
    "Standard errors clustered at the state level in parentheses.",
    paste0("CS-DiD simple ATT (not shown): ", round(cs_att$overall.att, 4),
           " (SE = ", round(cs_att$overall.se, 4), ").")
  )
)

# ══════════════════════════════════════════════════════════════
# TABLE 4: Robustness Checks
# ══════════════════════════════════════════════════════════════

cat("Table 4: Robustness...\n")

rob <- readRDS(file.path(BASE_DIR, "data", "robustness_results.rds"))

# Collect robustness estimates
rob_rows <- data.table(
  Specification = character(),
  Estimate = numeric(),
  SE = numeric(),
  N = integer()
)

add_row <- function(name, model) {
  if (!is.null(model)) {
    rob_rows <<- rbind(rob_rows, data.table(
      Specification = name,
      Estimate = round(coef(model)[1], 4),
      SE = round(se(model)[1], 4),
      N = nobs(model)
    ))
  }
}

add_row("Main specification", twfe$m1)
add_row("Exposure-weighted treatment", twfe$m2)
add_row("Rural-only nightlights", twfe$m3)
add_row("Per-capita nightlights", twfe$m4)
add_row("State-specific linear trends", twfe$m5)
add_row("Placebo: Urban districts", rob$placebo_urban)
add_row("Placebo: Fake dates (-3 years)", rob$placebo_fake)
add_row("Tier 1 states only", rob$sens_tier1)
add_row("Mid-cohort states (2017--2018)", rob$sens_mid)
add_row("Alternative: Mean luminosity", rob$alt_mean)
add_row("Alternative: Lit area", rob$alt_lit)

# Add CS-DiD and RI
rob_rows <- rbind(rob_rows, data.table(
  Specification = "CS-DiD (simple ATT)",
  Estimate = round(cs_att$overall.att, 4),
  SE = round(cs_att$overall.se, 4),
  N = nrow(panel)
))
rob_rows <- rbind(rob_rows, data.table(
  Specification = paste0("RI p-value (500 permutations)"),
  Estimate = round(rob$ri_pvalue, 3),
  SE = NA_real_,
  N = NA_integer_
))

tab4 <- kbl(rob_rows, format = "latex", booktabs = TRUE,
            caption = "Robustness Checks",
            label = "tab:robustness") |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "All specifications include district and year fixed effects with state-clustered standard errors unless noted.",
           threeparttable = TRUE)

writeLines(tab4, file.path(tab_dir, "table4_robustness.tex"))

# ══════════════════════════════════════════════════════════════
# TABLE 5: Heterogeneity
# ══════════════════════════════════════════════════════════════

cat("Table 5: Heterogeneity...\n")

het_models <- list(
  "Rural Share" = rob$het_rural,
  "Literacy" = rob$het_lit,
  "SC/ST Share" = rob$het_scst,
  "District Size" = rob$het_size
)

# Filter out NULLs
het_models <- het_models[!sapply(het_models, is.null)]

if (length(het_models) > 0) {
  tab5 <- modelsummary(
    het_models,
    output = file.path(tab_dir, "table5_heterogeneity.tex"),
    stars = c('*' = .1, '**' = .05, '***' = .01),
    gof_map = c("nobs", "r.squared"),
    title = "Heterogeneous Effects by District Characteristics",
    notes = "Standard errors clustered at the state level."
  )
}

cat("\nAll tables saved to:", tab_dir, "\n")
