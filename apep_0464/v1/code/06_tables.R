## ============================================================================
## 06_tables.R — Connected Backlash (apep_0464)
## Generate all publication-quality LaTeX tables
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

## Filter dept_panel to 96 metropolitan départements only
metro_codes <- c(sprintf("%02d", 1:19), "2A", "2B", sprintf("%02d", 21:95))
dept_panel <- dept_panel %>% filter(dept_code %in% metro_codes)

cat("  Commune panel:     ", nrow(panel), "obs\n")
cat("  Département panel: ", nrow(dept_panel), "obs (", n_distinct(dept_panel$dept_code), " depts)\n")
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

## --- Panel B: Département-level variables ---

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
                           "(2012--2024). D\\\\'{e}partement-level panel aggregates",
                           "commune data to", n_distinct(dept_panel$dept_code),
                           "d\\\\'{e}partements. RN vote share is the",
                           "Rassemblement National (formerly Front National)",
                           "first-round vote share. Network fuel exposure is the",
                           "SCI-weighted average commuting CO$_2$ of connected",
                           "d\\\\'{e}partements.",
                           "Own carbon burden ($N < 576$) is available only for",
                           "elections after the carbon tax introduction (2014--2024),",
                           "as the tax rate was zero prior to 2014."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

writeLines(tab1_tex, file.path(TABLES_DIR, "tab_summary.tex"))
cat("  Saved tab_summary.tex\n")

## ============================================================================
## TABLE 2: Main Results — Commune Level
## ============================================================================

cat("\n=== Table 2: Main Commune-Level Results ===\n")

## Use fixest::etable() with tex output
tab2_tex <- etable(
  main_results$m1, main_results$m2, main_results$m3,
  main_results$m4, main_results$m5,
  headers = c("(1)", "(2)", "(3)", "(4)", "(5)"),
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
    "own_fuel_std:post_carbon"     = "Own fuel $\\times$ Post carbon",
    "post_carbon:own_fuel_std"     = "Own fuel $\\times$ Post carbon",
    "network_fuel_std:post_carbon" = "Network fuel $\\times$ Post carbon",
    "post_carbon:network_fuel_std" = "Network fuel $\\times$ Post carbon",
    "own_fuel_std:post_gj"         = "Own fuel $\\times$ Post GJ",
    "post_gj:own_fuel_std"         = "Own fuel $\\times$ Post GJ",
    "network_fuel_std:post_gj"     = "Network fuel $\\times$ Post GJ",
    "post_gj:network_fuel_std"     = "Network fuel $\\times$ Post GJ",
    "own_fuel_std:post_carbon:is_pres"     = "Own $\\times$ Post $\\times$ Pres.",
    "post_carbon:network_fuel_std:is_pres" = "Network $\\times$ Post $\\times$ Pres.",
    code_commune     = "Commune",
    id_election      = "Election"
  ),
  title = "Effect of Fuel Vulnerability on RN Vote Share: Commune Level"
)

writeLines(tab2_tex, file.path(TABLES_DIR, "tab_main_commune.tex"))
cat("  Saved tab_main_commune.tex\n")

## ============================================================================
## TABLE 3: Main Results — Département Level
## ============================================================================

cat("\n=== Table 3: Département-Level Results ===\n")

tab3_tex <- etable(
  dept_results$d1, dept_results$d2,
  headers = c("(1) Unweighted", "(2) Pop-weighted"),
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
    "own_fuel_std:post_carbon"     = "Own fuel $\\times$ Post carbon",
    "post_carbon:own_fuel_std"     = "Own fuel $\\times$ Post carbon",
    "network_fuel_std:post_carbon" = "Network fuel $\\times$ Post carbon",
    "post_carbon:network_fuel_std" = "Network fuel $\\times$ Post carbon",
    dept_code        = "D\\'{e}partement",
    id_election      = "Election"
  ),
  title = "Effect of Fuel Vulnerability on RN Vote Share: D\\'{e}partement Level"
)

writeLines(tab3_tex, file.path(TABLES_DIR, "tab_main_dept.tex"))
cat("  Saved tab_main_dept.tex\n")

## ============================================================================
## TABLE 4: Event Study Coefficients
## ============================================================================

cat("\n=== Table 4: Event Study Coefficients ===\n")

## Extract coefficients from the joint event study model (es_both)
## which includes both own and network exposure interacted with election dummies

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
      year = c(`1` = 2012L, `3` = 2017L, `4` = 2019L,
               `5` = 2022L, `6` = 2024L)[as.character(election_num)],
      stars = case_when(
        abs(estimate / se) > 2.576 ~ "***",
        abs(estimate / se) > 1.960 ~ "**",
        abs(estimate / se) > 1.645 ~ "*",
        TRUE ~ ""
      )
    ) %>%
    ## Add the reference year (2014, election_num = 2)
    bind_rows(
      tibble(term = "ref", estimate = 0, se = NA_real_,
             election_num = 2L, year = 2014L, stars = "")
    ) %>%
    arrange(year)
}

es_own_coefs     <- extract_es_coefs(es_results$es_both, "own_fuel_std")
es_network_coefs <- extract_es_coefs(es_results$es_both, "network_fuel_std")

## Build table combining both columns
es_table <- tibble(
  Year = c(2012, "2014 (ref.)", 2017, 2019, 2022, 2024)
)

## Format own exposure column
if (!is.null(es_own_coefs)) {
  es_table$own_est <- sapply(es_own_coefs$year, function(yr) {
    row <- es_own_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014) return("---")
    paste0(fmt(row$estimate), row$stars)
  })
  es_table$own_se <- sapply(es_own_coefs$year, function(yr) {
    row <- es_own_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014 || is.na(row$se)) return("")
    paste0("(", fmt(row$se), ")")
  })
} else {
  es_table$own_est <- rep("", 6)
  es_table$own_se  <- rep("", 6)
}

## Format network exposure column
if (!is.null(es_network_coefs)) {
  es_table$net_est <- sapply(es_network_coefs$year, function(yr) {
    row <- es_network_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014) return("---")
    paste0(fmt(row$estimate), row$stars)
  })
  es_table$net_se <- sapply(es_network_coefs$year, function(yr) {
    row <- es_network_coefs %>% filter(year == yr)
    if (nrow(row) == 0) return("")
    if (yr == 2014 || is.na(row$se)) return("")
    paste0("(", fmt(row$se), ")")
  })
} else {
  es_table$net_est <- rep("", 6)
  es_table$net_se  <- rep("", 6)
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
                           "Own exposure is the commune's d\\\\'{e}partement-level commuting",
                           "CO$_2$; network exposure is the SCI-weighted average of",
                           "connected d\\\\'{e}partements' commuting CO$_2$.",
                           "Standard errors clustered by d\\\\'{e}partement in parentheses.",
                           "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$."),
           general_title = "Notes:",
           escape = FALSE,
           threeparttable = TRUE)

## Post-process: center N and R² across both columns
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

## Load the SCI matrix and NUTS3 mapping for département names
sci_matrix   <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
nuts3_dept   <- read_csv(file.path(DATA_DIR, "nuts3_dept_mapping.csv"),
                         show_col_types = FALSE)

## Create département name lookup
dept_names <- nuts3_dept %>%
  select(dept_code, dept_name) %>%
  distinct()

## Compute top 20 département pairs by raw SCI score
## Use the unnormalized scaled_sci for ranking (not row-normalized weights)
top_sci <- sci_matrix %>%
  ## Keep unique pairs (avoid double-counting A→B and B→A)
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
## SUMMARY
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("TABLE GENERATION COMPLETE\n")
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
