## ============================================================================
## 06_tables.R — Connected Backlash (apep_0464 v2)
## Generate all publication-quality LaTeX tables
##
## v2 changes:
##   - Table 2: 6 models (m6 = continuous treatment with carbon rate)
##   - Table 3: 3 models (d3 = continuous treatment, weighted)
##   - Table 4: 10 elections (2002-2024), reference = 2014 (election 6)
##   - NEW: Inference Comparison table (clustered SE, RI, block RI, WCB)
##   - NEW: SAR vs SEM vs SDM model comparison table
##   - NEW: Placebo Party Outcomes table (RN vs Green vs Center-right)
## ============================================================================

source("00_packages.R")

DATA_DIR   <- "../data"
TABLES_DIR <- "../tables"
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## LOAD DATA
## ============================================================================

cat("\n=== Loading data for tables ===\n")

panel            <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel       <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
main_results     <- readRDS(file.path(DATA_DIR, "main_results.rds"))
dept_results     <- readRDS(file.path(DATA_DIR, "dept_results.rds"))
es_results       <- readRDS(file.path(DATA_DIR, "event_study_results.rds"))
fuel_vuln        <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
network_exposure <- readRDS(file.path(DATA_DIR, "network_exposure.rds"))
carbon_tax       <- read_csv(file.path(DATA_DIR, "carbon_tax_schedule.csv"),
                             show_col_types = FALSE)

## v2: Load robustness and structural results
robustness_results  <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
structural_results  <- readRDS(file.path(DATA_DIR, "structural_results.rds"))

## Filter dept_panel to 96 metropolitan departements only
metro_codes <- c(sprintf("%02d", 1:19), "2A", "2B", sprintf("%02d", 21:95))
dept_panel <- dept_panel %>% filter(dept_code %in% metro_codes)

cat("  Commune panel:     ", nrow(panel), "obs\n")
cat("  Departement panel: ", nrow(dept_panel), "obs (", n_distinct(dept_panel$dept_code), " depts)\n")
cat("  Main models:       ", length(main_results), "\n")
cat("  Dept models:       ", length(dept_results), "\n")

## ============================================================================
## HELPER: format numbers consistently
## ============================================================================

fmt <- function(x, digits = 3) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

fmt0 <- function(x) {
  formatC(x, format = "f", digits = 0, big.mark = ",")
}

## ============================================================================
## TABLE 1: Summary Statistics
## ============================================================================

cat("\n=== Table 1: Summary Statistics ===\n")

## --- Panel A: Commune-level variables ---

## Define the variables and their display labels
commune_vars <- c("rn_share", "turnout", "co2_commute",
                  "network_fuel_norm", "own_carbon_burden")
commune_labels <- c("RN vote share (\\%)",
                    "Turnout (\\%)",
                    "Commuting CO$_2$ (tCO$_2$e/worker/yr)",
                    "Network fuel exposure (SCI-weighted)",
                    "Own carbon burden (\\euro/worker/yr)")

## Compute summary statistics for commune panel
compute_sumstats <- function(df, vars, labels) {
  stats_list <- lapply(seq_along(vars), function(i) {
    v <- vars[i]
    x <- df[[v]]
    if (is.null(x)) {
      ## Variable might not exist — return NAs
      return(data.frame(
        Variable = labels[i],
        Mean = NA_real_, SD = NA_real_,
        Min = NA_real_, Max = NA_real_,
        N = 0L,
        stringsAsFactors = FALSE
      ))
    }
    x <- x[!is.na(x)]
    data.frame(
      Variable = labels[i],
      Mean = mean(x),
      SD   = sd(x),
      Min  = min(x),
      Max  = max(x),
      N    = length(x),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, stats_list)
}

panel_a <- compute_sumstats(panel, commune_vars, commune_labels)

## --- Panel B: Departement-level variables ---

dept_vars <- c("rn_share", "turnout", "co2_commute",
               "network_fuel_norm", "own_carbon_burden",
               "n_communes", "total_registered")
dept_labels <- c("RN vote share (\\%)",
                 "Turnout (\\%)",
                 "Commuting CO$_2$ (tCO$_2$e/worker/yr)",
                 "Network fuel exposure (SCI-weighted)",
                 "Own carbon burden (\\euro/worker/yr)",
                 "Number of communes",
                 "Registered voters")

panel_b <- compute_sumstats(dept_panel, dept_vars, dept_labels)

## Build the combined kable
sumstats_combined <- rbind(
  data.frame(Variable = "\\textit{Panel A: Commune level}",
             Mean = NA, SD = NA, Min = NA, Max = NA, N = NA,
             stringsAsFactors = FALSE),
  panel_a,
  data.frame(Variable = "\\textit{Panel B: D\\'{e}partement level}",
             Mean = NA, SD = NA, Min = NA, Max = NA, N = NA,
             stringsAsFactors = FALSE),
  panel_b
)

## Format numeric columns
sumstats_display <- sumstats_combined %>%
  mutate(
    Mean = ifelse(is.na(Mean), "", fmt(Mean)),
    SD   = ifelse(is.na(SD),   "", fmt(SD)),
    Min  = ifelse(is.na(Min),  "", fmt(Min)),
    Max  = ifelse(is.na(Max),  "", fmt(Max)),
    N    = ifelse(is.na(N),    "", fmt0(N))
  )

tab1_tex <- kbl(sumstats_display,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                col.names = c("", "Mean", "SD", "Min", "Max", "$N$"),
                align = c("l", rep("c", 5)),
                caption = "Summary Statistics") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10) %>%
  row_spec(1, bold = TRUE, hline_after = FALSE) %>%
  row_spec(1 + nrow(panel_a) + 1, bold = TRUE, hline_after = FALSE) %>%
  footnote(general = paste("Commune-level panel covers",
                           n_distinct(panel$code_commune), "communes across",
                           n_distinct(panel$id_election), "elections",
                           "(2002--2024). D\\\\'{e}partement-level panel aggregates",
                           "commune data to", n_distinct(dept_panel$dept_code),
                           "d\\\\'{e}partements. RN vote share is the",
                           "Rassemblement National (formerly Front National)",
                           "first-round vote share. Network fuel exposure is the",
                           "SCI-weighted average commuting CO$_2$ of connected",
                           "d\\\\'{e}partements.",
                           "Own carbon burden ($N < 960$) is available only for",
                           "elections after the carbon tax introduction (2014--2024),",
                           "as the tax rate was zero prior to 2014."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab1_tex, file.path(TABLES_DIR, "tab_summary.tex"))
cat("  Saved tab_summary.tex\n")

## ============================================================================
## TABLE 2: Main Results — Commune Level (v2: 6 models)
## ============================================================================

cat("\n=== Table 2: Main Commune-Level Results (v2: 6 models) ===\n")

## Use fixest::etable() with tex output
tab2_tex <- etable(
  main_results$m1, main_results$m2, main_results$m3,
  main_results$m4, main_results$m5, main_results$m6,
  headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
  se.below = TRUE,
  tex = TRUE,
  fitstat = ~ n + r2 + wr2,
  style.tex = style.tex(
    main = "base",
    depvar.title = "Dep.\\ var.",
    fixef.title = "\\midrule Fixed Effects",
    fixef.suffix = " FE",
    yesNo = c("Yes", "No"),
    tablefoot = FALSE
  ),
  dict = c(
    ## Binary post interactions (both orderings)
    "own_fuel_std:post_carbon"     = "Own fuel $\\times$ Post carbon",
    "post_carbon:own_fuel_std"     = "Own fuel $\\times$ Post carbon",
    "network_fuel_std:post_carbon" = "Network fuel $\\times$ Post carbon",
    "post_carbon:network_fuel_std" = "Network fuel $\\times$ Post carbon",
    "own_fuel_std:post_gj"         = "Own fuel $\\times$ Post GJ",
    "post_gj:own_fuel_std"         = "Own fuel $\\times$ Post GJ",
    "network_fuel_std:post_gj"     = "Network fuel $\\times$ Post GJ",
    "post_gj:network_fuel_std"     = "Network fuel $\\times$ Post GJ",
    ## Triple interactions
    "own_fuel_std:post_carbon:is_pres"     = "Own $\\times$ Post $\\times$ Pres.",
    "post_carbon:own_fuel_std:is_pres"     = "Own $\\times$ Post $\\times$ Pres.",
    "is_pres:own_fuel_std:post_carbon"     = "Own $\\times$ Post $\\times$ Pres.",
    "post_carbon:network_fuel_std:is_pres" = "Network $\\times$ Post $\\times$ Pres.",
    "network_fuel_std:post_carbon:is_pres" = "Network $\\times$ Post $\\times$ Pres.",
    "is_pres:network_fuel_std:post_carbon" = "Network $\\times$ Post $\\times$ Pres.",
    ## v2: Continuous treatment interactions (both orderings)
    "own_fuel_std:rate_eur_tco2"     = "Own fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "rate_eur_tco2:own_fuel_std"     = "Own fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "network_fuel_std:rate_eur_tco2" = "Network fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "rate_eur_tco2:network_fuel_std" = "Network fuel $\\times$ Rate (\\euro/tCO$_2$)",
    ## Fixed effects
    code_commune     = "Commune",
    id_election      = "Election"
  ),
  title = "Effect of Fuel Vulnerability on RN Vote Share: Commune Level"
)

writeLines(tab2_tex, file.path(TABLES_DIR, "tab_main_commune.tex"))
cat("  Saved tab_main_commune.tex\n")

## ============================================================================
## TABLE 3: Main Results — Departement Level (v2: 3 models)
## ============================================================================

cat("\n=== Table 3: Departement-Level Results (v2: 3 models) ===\n")

tab3_tex <- etable(
  dept_results$d1, dept_results$d2, dept_results$d3,
  headers = c("(1) Unweighted", "(2) Pop-weighted", "(3) Continuous"),
  se.below = TRUE,
  tex = TRUE,
  fitstat = ~ n + r2 + wr2,
  style.tex = style.tex(
    main = "base",
    depvar.title = "Dep.\\ var.",
    fixef.title = "\\midrule Fixed Effects",
    fixef.suffix = " FE",
    yesNo = c("Yes", "No"),
    tablefoot = FALSE
  ),
  dict = c(
    ## Binary post interactions (both orderings)
    "own_fuel_std:post_carbon"     = "Own fuel $\\times$ Post carbon",
    "post_carbon:own_fuel_std"     = "Own fuel $\\times$ Post carbon",
    "network_fuel_std:post_carbon" = "Network fuel $\\times$ Post carbon",
    "post_carbon:network_fuel_std" = "Network fuel $\\times$ Post carbon",
    ## v2: Continuous treatment interactions (both orderings)
    "own_fuel_std:rate_eur_tco2"     = "Own fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "rate_eur_tco2:own_fuel_std"     = "Own fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "network_fuel_std:rate_eur_tco2" = "Network fuel $\\times$ Rate (\\euro/tCO$_2$)",
    "rate_eur_tco2:network_fuel_std" = "Network fuel $\\times$ Rate (\\euro/tCO$_2$)",
    ## Fixed effects
    dept_code        = "D\\'{e}partement",
    id_election      = "Election"
  ),
  title = "Effect of Fuel Vulnerability on RN Vote Share: D\\'{e}partement Level"
)

writeLines(tab3_tex, file.path(TABLES_DIR, "tab_main_dept.tex"))
cat("  Saved tab_main_dept.tex\n")

## ============================================================================
## TABLE 4: Event Study Coefficients (v2: 10 elections)
## ============================================================================

cat("\n=== Table 4: Event Study Coefficients (v2: 10 elections) ===\n")

## Extract coefficients from the joint event study model (es_both)
## which includes both own and network exposure interacted with election dummies
## v2: 10 elections, reference = election 6 (2014)

extract_es_coefs <- function(model, var_prefix) {
  ct <- coeftable(model)
  idx <- grepl(var_prefix, rownames(ct))
  if (sum(idx) == 0) return(NULL)

  tibble(
    term = rownames(ct)[idx],
    estimate = ct[idx, "Estimate"],
    se = ct[idx, "Std. Error"]
  ) %>%
    mutate(
      election_num = as.integer(gsub(".*::(\\d+):.*", "\\1", term)),
      year = c(`1` = 2002L, `2` = 2004L, `3` = 2007L, `4` = 2009L,
               `5` = 2012L, `7` = 2017L, `8` = 2019L,
               `9` = 2022L, `10` = 2024L)[as.character(election_num)],
      stars = case_when(
        abs(estimate / se) > 2.576 ~ "***",
        abs(estimate / se) > 1.960 ~ "**",
        abs(estimate / se) > 1.645 ~ "*",
        TRUE ~ ""
      )
    ) %>%
    ## Add the reference year (2014, election_num = 6)
    bind_rows(
      tibble(term = "ref", estimate = 0, se = NA_real_,
             election_num = 6L, year = 2014L, stars = "")
    ) %>%
    arrange(year)
}

es_own_coefs     <- extract_es_coefs(es_results$es_both, "own_fuel_std")
es_network_coefs <- extract_es_coefs(es_results$es_both, "network_fuel_std")

## v2: Build table with 10 elections
es_years_display <- c("2002", "2004", "2007", "2009", "2012",
                       "2014 (ref.)", "2017", "2019", "2022", "2024")
es_years_numeric <- c(2002, 2004, 2007, 2009, 2012, 2014, 2017, 2019, 2022, 2024)

es_table <- tibble(
  Year = es_years_display,
  year_num = es_years_numeric
)

## Format own exposure column
if (!is.null(es_own_coefs)) {
  es_table$own_est <- sapply(es_table$year_num, function(yr) {
    row <- es_own_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014) return("---")
    paste0(fmt(row$estimate), row$stars)
  })
  es_table$own_se <- sapply(es_table$year_num, function(yr) {
    row <- es_own_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014 || is.na(row$se)) return("")
    paste0("(", fmt(row$se), ")")
  })
} else {
  es_table$own_est <- rep("", 10)
  es_table$own_se  <- rep("", 10)
}

## Format network exposure column
if (!is.null(es_network_coefs)) {
  es_table$net_est <- sapply(es_table$year_num, function(yr) {
    row <- es_network_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014) return("---")
    paste0(fmt(row$estimate), row$stars)
  })
  es_table$net_se <- sapply(es_table$year_num, function(yr) {
    row <- es_network_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014 || is.na(row$se)) return("")
    paste0("(", fmt(row$se), ")")
  })
} else {
  es_table$net_est <- rep("", 10)
  es_table$net_se  <- rep("", 10)
}

## Interleave estimate and SE rows for a publication-style layout
es_rows <- list()
for (i in seq_len(nrow(es_table))) {
  es_rows[[length(es_rows) + 1]] <- c(
    as.character(es_table$Year[i]),
    es_table$own_est[i],
    es_table$net_est[i]
  )
  ## Only add SE row if there is an SE to show
  if (es_table$own_se[i] != "" || es_table$net_se[i] != "") {
    es_rows[[length(es_rows) + 1]] <- c(
      "",
      es_table$own_se[i],
      es_table$net_se[i]
    )
  }
}

es_df <- do.call(rbind, es_rows) %>%
  as.data.frame(stringsAsFactors = FALSE)
names(es_df) <- c("Election Year", "Own Exposure", "Network Exposure")

## Add model statistics at the bottom
n_obs <- nobs(es_results$es_both)
r2_w  <- fitstat(es_results$es_both, "wr2")[[1]]

es_df <- rbind(
  es_df,
  c("\\midrule Observations", fmt0(n_obs), ""),
  c("Within $R^2$", fmt(r2_w, 4), "")
)

tab4_tex <- kbl(es_df,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                align = c("l", "c", "c"),
                caption = "Event Study Coefficients: Election-Specific Effects of Fuel Vulnerability") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10) %>%
  add_header_above(c(" " = 1,
                     "Coefficient on Fuel Exposure $\\\\times$ Election" = 2),
                   escape = FALSE) %>%
  footnote(general = paste("Each column reports coefficients from a regression of",
                           "commune-level RN vote share on the interaction of",
                           "standardized fuel exposure with election indicators.",
                           "The reference period is 2014 (the year the carbon tax was introduced at its initial rate).",
                           "The v2 panel includes 5 pre-treatment elections (2002--2012) and",
                           "4 post-treatment elections (2017--2024).",
                           "Own exposure is the commune's d\\\\'{e}partement-level commuting",
                           "CO$_2$; network exposure is the SCI-weighted average of",
                           "connected d\\\\'{e}partements' commuting CO$_2$.",
                           "Standard errors clustered by d\\\\'{e}partement in parentheses.",
                           "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

## Post-process: center N and R-squared across both columns
tab4_tex <- gsub(
  paste0("\\\\midrule Observations & ", fmt0(n_obs), " & \\\\\\\\"),
  paste0("\\\\midrule Observations & \\\\multicolumn{2}{c}{", fmt0(n_obs), "} \\\\\\\\"),
  tab4_tex)
tab4_tex <- gsub(
  paste0("Within \\$R\\^2\\$ & ", fmt(r2_w, 4), " & \\\\\\\\"),
  paste0("Within $R^2$ & \\\\multicolumn{2}{c}{", fmt(r2_w, 4), "} \\\\\\\\"),
  tab4_tex)
writeLines(tab4_tex, file.path(TABLES_DIR, "tab_event_study.tex"))
cat("  Saved tab_event_study.tex\n")

## ============================================================================
## TABLE 5: Carbon Tax Schedule
## ============================================================================

cat("\n=== Table 5: Carbon Tax Schedule ===\n")

## Format the carbon tax schedule
ct_display <- carbon_tax %>%
  mutate(
    ## Flag frozen years
    frozen = ifelse(year >= 2019, TRUE, FALSE),
    Year = as.character(year),
    `Rate (\\euro/tCO$_2$)` = fmt(rate_eur_tco2, 1),
    `TICPE Diesel (c/L)` = fmt(ticpe_diesel_cl, 2),
    `TICPE SP95 (c/L)` = fmt(ticpe_sp95_cl, 2),
    `Carbon Component Diesel (c/L)` = fmt(carbon_diesel_cl, 2)
  ) %>%
  select(Year, `Rate (\\euro/tCO$_2$)`, `TICPE Diesel (c/L)`,
         `TICPE SP95 (c/L)`, `Carbon Component Diesel (c/L)`, frozen)

## Build kable
tab5_tex <- kbl(ct_display %>% select(-frozen),
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                align = c("l", rep("c", 4)),
                caption = "France Carbon Tax Schedule, 2013--2024") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10)

## Highlight the frozen rows (2019 onward) with italic
frozen_rows <- which(ct_display$frozen)
if (length(frozen_rows) > 0) {
  tab5_tex <- tab5_tex %>%
    row_spec(frozen_rows, italic = TRUE, color = "gray")
}

## Add a horizontal rule before the freeze
freeze_row <- min(frozen_rows) - 1
if (freeze_row > 0) {
  tab5_tex <- tab5_tex %>%
    row_spec(freeze_row, hline_after = TRUE)
}

tab5_tex <- tab5_tex %>%
  footnote(general = paste("Carbon tax rates from the Contribution Climat-\\'{E}nergie",
                           "(CCE), enacted in the 2014 Finance Law.",
                           "TICPE = Taxe Int\\'{e}rieure de Consommation sur les",
                           "Produits \\'{E}nerg\\'{e}tiques.",
                           "Rates were frozen at the 2018 level following the",
                           "\\textit{Gilets Jaunes} protests (italicized rows).",
                           "Carbon component diesel computed as rate $\\times$ 2.651 kg CO$_2$/L.",
                           "Sources: DGEC; Journal Officiel."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab5_tex, file.path(TABLES_DIR, "tab_carbon_tax.tex"))
cat("  Saved tab_carbon_tax.tex\n")

## ============================================================================
## TABLE 6: Top SCI Connections
## ============================================================================

cat("\n=== Table 6: Top SCI Connections ===\n")

## Load the SCI matrix and NUTS3 mapping for departement names
sci_matrix   <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
nuts3_dept   <- read_csv(file.path(DATA_DIR, "nuts3_dept_mapping.csv"),
                         show_col_types = FALSE)

## Create departement name lookup
dept_names <- nuts3_dept %>%
  select(dept_code, dept_name) %>%
  distinct()

## Compute top 20 departement pairs by raw SCI score
## Use the unnormalized scaled_sci for ranking (not row-normalized weights)
top_sci <- sci_matrix %>%
  ## Keep unique pairs (avoid double-counting A->B and B->A)
  filter(dept_from < dept_to) %>%
  arrange(desc(scaled_sci)) %>%
  head(20) %>%
  left_join(dept_names, by = c("dept_from" = "dept_code")) %>%
  rename(from_name = dept_name) %>%
  left_join(dept_names, by = c("dept_to" = "dept_code")) %>%
  rename(to_name = dept_name) %>%
  mutate(
    From = paste0(from_name, " (", dept_from, ")"),
    To   = paste0(to_name, " (", dept_to, ")"),
    `SCI Score` = fmt0(scaled_sci)
  )

## Check if geographic distance is available in the dataset
has_distance <- "distance_km" %in% names(sci_matrix)

if (has_distance) {
  top_sci <- top_sci %>%
    mutate(`Distance (km)` = fmt(distance_km, 0))
  sci_display <- top_sci %>%
    select(From, To, `SCI Score`, `Distance (km)`)
} else {
  sci_display <- top_sci %>%
    select(From, To, `SCI Score`)
}

tab6_tex <- kbl(sci_display,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                align = c("l", "l", "c", if (has_distance) "c"),
                caption = "Top 20 D\\'{e}partement Pairs by Facebook Social Connectedness Index") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 9) %>%
  footnote(general = paste("Social Connectedness Index (SCI) from Bailey et al.\\ (2018),",
                           "measured at the NUTS-3 level (French d\\'{e}partements).",
                           "SCI captures the relative probability of a Facebook",
                           "friendship between users in each pair of regions.",
                           "Higher values indicate stronger social ties.",
                           "Source: Facebook Data for Good, NUTS 2024 classification."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab6_tex, file.path(TABLES_DIR, "tab_top_sci.tex"))
cat("  Saved tab_top_sci.tex\n")

## ============================================================================
## TABLE 7 (v2 NEW): Inference Comparison
## ============================================================================

cat("\n=== Table 7: Inference Comparison (v2) ===\n")

## Compute clustered SE p-values from main model m3
m3 <- main_results$m3
m3_ct <- coeftable(m3)

## Helper to extract p-value from coeftable for a coefficient matching a pattern
get_clustered_p <- function(model, pattern) {
  ct <- coeftable(model)
  nms <- rownames(ct)
  idx <- grep(pattern, nms)
  if (length(idx) == 0) return(NA_real_)
  ## Use the t-statistic and compute two-sided p-value with dept-level DoF
  t_val <- ct[idx[1], "Estimate"] / ct[idx[1], "Std. Error"]
  n_clusters <- length(unique(panel$dept_code))
  2 * pt(abs(t_val), df = n_clusters - 1, lower.tail = FALSE)
}

p_clust_own <- get_clustered_p(m3, "own_fuel_std")
p_clust_net <- get_clustered_p(m3, "network_fuel_std")

## Standard RI p-values
ri <- robustness_results$randomization_inference
p_ri_own <- if (!is.null(ri)) ri$ri_p_own else NA_real_
p_ri_net <- if (!is.null(ri)) ri$ri_p_net else NA_real_

## Block RI p-values
bri <- robustness_results$block_ri
p_bri_own <- if (!is.null(bri)) bri$block_ri_p_own else NA_real_
p_bri_net <- if (!is.null(bri)) bri$block_ri_p_net else NA_real_

## Wild Cluster Bootstrap p-values
wcb <- robustness_results$wild_bootstrap
p_wcb_own <- if (!is.null(wcb) && !is.null(wcb$p_own)) wcb$p_own else NA_real_
p_wcb_net <- if (!is.null(wcb) && !is.null(wcb$p_network)) wcb$p_network else NA_real_

## Build the inference comparison table
## Rows: coefficient, Columns: inference method
inference_df <- data.frame(
  Coefficient = c("Own fuel $\\times$ Post",
                   "Network fuel $\\times$ Post"),
  `Clustered SE` = c(
    ifelse(is.na(p_clust_own), "---", fmt(p_clust_own, 4)),
    ifelse(is.na(p_clust_net), "---", fmt(p_clust_net, 4))
  ),
  `Standard RI` = c(
    ifelse(is.na(p_ri_own), "---", fmt(p_ri_own, 4)),
    ifelse(is.na(p_ri_net), "---", fmt(p_ri_net, 4))
  ),
  `Block RI` = c(
    ifelse(is.na(p_bri_own), "---", fmt(p_bri_own, 4)),
    ifelse(is.na(p_bri_net), "---", fmt(p_bri_net, 4))
  ),
  `Wild Cluster Bootstrap` = c(
    ifelse(is.na(p_wcb_own), "---", fmt(p_wcb_own, 4)),
    ifelse(is.na(p_wcb_net), "---", fmt(p_wcb_net, 4))
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

tab7_tex <- kbl(inference_df,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                col.names = c("Coefficient", "Clustered SE",
                              "Standard RI", "Block RI",
                              "Wild Cluster Bootstrap"),
                align = c("l", rep("c", 4)),
                caption = "Inference Comparison: $p$-Values Across Methods") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10) %>%
  add_header_above(c(" " = 1, "$p$-value" = 4), escape = FALSE) %>%
  footnote(general = paste("All $p$-values are two-sided and correspond to Model 3",
                           "(both own and network exposure, commune level).",
                           "Clustered SE uses d\\\\'{e}partement-level clustering",
                           "with $t$-distribution ($G-1$ degrees of freedom).",
                           "Standard RI permutes fuel vulnerability across all",
                           "d\\\\'{e}partements (5,000 permutations).",
                           "Block RI permutes within 13 metropolitan regions",
                           "(10,000 permutations), preserving spatial autocorrelation.",
                           "Wild Cluster Bootstrap uses Rademacher weights (9,999 replications)."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab7_tex, file.path(TABLES_DIR, "tab_inference.tex"))
cat("  Saved tab_inference.tex\n")

## ============================================================================
## TABLE 8 (v2 NEW): SAR vs SEM vs SDM Model Comparison
## ============================================================================

cat("\n=== Table 8: SAR vs SEM vs SDM Comparison (v2) ===\n")

## Extract parameters from structural_results
sar_ld <- structural_results$sar_ld
sem    <- structural_results$sem
sdm    <- structural_results$sdm

## Spatial parameter (rho for SAR/SDM, lambda for SEM)
spatial_sar <- if (!is.na(sar_ld$rho)) fmt(sar_ld$rho, 4) else "---"
spatial_sem <- if (!is.na(sem$lambda)) fmt(sem$lambda, 4) else "---"
spatial_sdm <- if (!is.na(sdm$rho)) fmt(sdm$rho, 4) else "---"

## Cost sensitivity (beta for delta_x)
beta_sar <- if (!is.null(sar_ld$beta) && "delta_x" %in% names(sar_ld$beta)) {
  fmt(sar_ld$beta["delta_x"], 4)
} else "---"
beta_sem <- if (!is.null(sem$beta) && "delta_x" %in% names(sem$beta)) {
  fmt(sem$beta["delta_x"], 4)
} else "---"
beta_sdm <- if (!is.null(sdm$beta) && "delta_x" %in% names(sdm$beta)) {
  fmt(sdm$beta["delta_x"], 4)
} else "---"

## WX coefficient (theta, SDM only)
theta_sdm <- "---"
if (!is.null(sdm$theta_names) && length(sdm$theta_names) > 0 && !is.null(sdm$beta)) {
  theta_val <- sdm$beta[sdm$theta_names[1]]
  if (!is.na(theta_val)) theta_sdm <- fmt(theta_val, 4)
}

## Sigma-squared
sig2_sar <- if (!is.na(sar_ld$sigma2)) fmt(sar_ld$sigma2, 4) else "---"
sig2_sem <- if (!is.na(sem$sigma2)) fmt(sem$sigma2, 4) else "---"
sig2_sdm <- if (!is.na(sdm$sigma2)) fmt(sdm$sigma2, 4) else "---"

## Log-likelihood
ll_sar <- if (!is.na(sar_ld$log_lik)) fmt(sar_ld$log_lik, 2) else "---"
ll_sem <- if (!is.na(sem$log_lik)) fmt(sem$log_lik, 2) else "---"
ll_sdm <- if (!is.na(sdm$log_lik)) fmt(sdm$log_lik, 2) else "---"

## AIC
aic_sar_val <- if (!is.na(sar_ld$aic)) fmt(sar_ld$aic, 2) else "---"
aic_sem_val <- if (!is.na(sem$aic)) fmt(sem$aic, 2) else "---"
aic_sdm_val <- if (!is.na(sdm$aic)) fmt(sdm$aic, 2) else "---"

## BIC
bic_sar_val <- if (!is.na(sar_ld$bic)) fmt(sar_ld$bic, 2) else "---"
bic_sem_val <- if (!is.na(sem$bic)) fmt(sem$bic, 2) else "---"
bic_sdm_val <- if (!is.na(sdm$bic)) fmt(sdm$bic, 2) else "---"

## Build the model comparison table
spatial_df <- data.frame(
  Parameter = c("Spatial parameter ($\\rho$/$\\lambda$)",
                "Cost sensitivity ($\\beta$)",
                "$W \\times X$ coefficient ($\\theta$)",
                "$\\sigma^2$",
                "Log-likelihood",
                "AIC",
                "BIC"),
  SAR = c(spatial_sar, beta_sar, "---", sig2_sar, ll_sar, aic_sar_val, bic_sar_val),
  SEM = c(spatial_sem, beta_sem, "---", sig2_sem, ll_sem, aic_sem_val, bic_sem_val),
  SDM = c(spatial_sdm, beta_sdm, theta_sdm, sig2_sdm, ll_sdm, aic_sdm_val, bic_sdm_val),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

## Add LR test row if available
mc <- structural_results$model_comparison
if (!is.null(mc) && !is.na(mc$lr_sar_vs_sdm_pval)) {
  lr_note <- sprintf("LR test SAR vs.\\ SDM: $\\chi^2 = %.3f$, $p = %.4f$",
                      mc$lr_sar_vs_sdm, mc$lr_sar_vs_sdm_pval)
} else {
  lr_note <- ""
}

tab8_tex <- kbl(spatial_df,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                align = c("l", "c", "c", "c"),
                caption = "Spatial Model Comparison: SAR vs.\\ SEM vs.\\ SDM") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10) %>%
  footnote(general = paste("Estimated on the long-difference cross-section",
                           "($\\Delta y$ = average post-carbon RN share $-$ average",
                           "pre-carbon RN share) across",
                           ifelse(!is.null(mc), mc$n_long_diff, "96"),
                           "d\\\\'{e}partements.",
                           "SAR: $y = \\rho W y + X\\beta + \\varepsilon$ (network contagion).",
                           "SEM: $y = X\\beta + u$, $u = \\lambda W u + \\varepsilon$ (correlated errors).",
                           "SDM: $y = \\rho W y + X\\beta + W X\\theta + \\varepsilon$ (contagion + spatial covariates).",
                           "Weight matrix $W$ is the row-normalized SCI.",
                           ifelse(lr_note != "", lr_note, "")),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab8_tex, file.path(TABLES_DIR, "tab_spatial_models.tex"))
cat("  Saved tab_spatial_models.tex\n")

## ============================================================================
## TABLE 9 (v2 NEW): Placebo Party Outcomes
## ============================================================================

cat("\n=== Table 9: Placebo Party Outcomes (v2) ===\n")

## Helper to format coefficient with stars
fmt_coef_stars <- function(coef_val, se_val) {
  if (is.na(coef_val) || is.na(se_val) || se_val == 0) return("---")
  t_val <- abs(coef_val / se_val)
  stars <- if (t_val > 2.576) "***" else if (t_val > 1.96) "**" else if (t_val > 1.645) "*" else ""
  paste0(fmt(coef_val, 4), stars)
}

## RN baseline (from main model m3)
rn_net_coef <- NA_real_; rn_net_se <- NA_real_; rn_n <- NA_integer_
ct_m3 <- coeftable(m3)
net_idx <- grep("network_fuel_std", rownames(ct_m3))
if (length(net_idx) > 0) {
  rn_net_coef <- ct_m3[net_idx[1], "Estimate"]
  rn_net_se   <- ct_m3[net_idx[1], "Std. Error"]
  rn_n        <- as.integer(nobs(m3))
}

## Green placebo
pg <- robustness_results$placebo_green
green_net_coef <- if (!is.null(pg)) pg$coef_network else NA_real_
green_net_se   <- if (!is.null(pg)) pg$se_network else NA_real_
green_n        <- if (!is.null(pg)) as.integer(pg$n_obs) else NA_integer_

## Center-right placebo
pr <- robustness_results$placebo_right
right_net_coef <- if (!is.null(pr)) pr$coef_network else NA_real_
right_net_se   <- if (!is.null(pr)) pr$se_network else NA_real_
right_n        <- if (!is.null(pr)) as.integer(pr$n_obs) else NA_integer_

## Build the placebo table
## Rows: party outcome, Columns: network coefficient, SE, N
placebo_df <- data.frame(
  Outcome = c("RN vote share (baseline)",
               "Green (EELV) vote share",
               "Center-right (LR/UMP) vote share"),
  Coefficient = c(
    fmt_coef_stars(rn_net_coef, rn_net_se),
    fmt_coef_stars(green_net_coef, green_net_se),
    fmt_coef_stars(right_net_coef, right_net_se)
  ),
  SE = c(
    ifelse(is.na(rn_net_se),    "---", paste0("(", fmt(rn_net_se, 4), ")")),
    ifelse(is.na(green_net_se), "---", paste0("(", fmt(green_net_se, 4), ")")),
    ifelse(is.na(right_net_se), "---", paste0("(", fmt(right_net_se, 4), ")"))
  ),
  N = c(
    ifelse(is.na(rn_n),    "---", fmt0(rn_n)),
    ifelse(is.na(green_n), "---", fmt0(green_n)),
    ifelse(is.na(right_n), "---", fmt0(right_n))
  ),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

tab9_tex <- kbl(placebo_df,
                format = "latex",
                booktabs = TRUE,
                escape = FALSE,
                linesep = "",
                col.names = c("Outcome Variable",
                              "Network fuel $\\times$ Post",
                              "", "$N$"),
                align = c("l", "c", "c", "c"),
                caption = "Placebo Party Outcomes: Network Coefficient by Party") %>%
  kable_styling(latex_options = c("hold_position"),
                font_size = 10) %>%
  footnote(general = paste("Each row reports the coefficient on Network fuel",
                           "$\\times$ Post carbon from the baseline specification (Model 3)",
                           "with a different dependent variable.",
                           "If network effects reflect populist backlash against the",
                           "carbon tax, they should be concentrated on RN vote share",
                           "and absent for Green and center-right parties.",
                           "All specifications include commune and election fixed effects",
                           "with standard errors clustered by d\\\\'{e}partement.",
                           "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab9_tex, file.path(TABLES_DIR, "tab_placebo_party.tex"))
cat("  Saved tab_placebo_party.tex\n")

## ============================================================================
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("TABLE GENERATION COMPLETE (v2)\n")
cat(strrep("=", 60), "\n")

tab_files <- list.files(TABLES_DIR, pattern = "\\.tex$")
cat("\nGenerated", length(tab_files), "table files:\n")
for (f in tab_files) cat("  ", f, "\n")

cat("\nTo include in paper.tex, use:\n")
cat("  \\input{tables/tab_summary.tex}\n")
cat("  \\input{tables/tab_main_commune.tex}\n")
cat("  \\input{tables/tab_main_dept.tex}\n")
cat("  \\input{tables/tab_event_study.tex}\n")
cat("  \\input{tables/tab_carbon_tax.tex}\n")
cat("  \\input{tables/tab_top_sci.tex}\n")
cat("  \\input{tables/tab_inference.tex}\n")
cat("  \\input{tables/tab_spatial_models.tex}\n")
cat("  \\input{tables/tab_placebo_party.tex}\n")
