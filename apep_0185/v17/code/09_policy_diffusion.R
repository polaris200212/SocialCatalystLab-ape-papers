################################################################################
# 09_policy_diffusion.R
# Policy Diffusion Test: Does network MW exposure predict future state MW increases?
#
# Unit: State-year panel (51 states, 2013-2022)
# Outcomes: (1) Binary: did state raise MW in t+1? (2) Continuous: Δlog(MW)_{s,t+1}
# Key regressor: State-average population-weighted network MW at time t
# Controls: State FE, year FE, lagged own MW
# Exclude: States at $15 ceiling
################################################################################

library(tidyverse)
library(fixest)

cat("=== Policy Diffusion Analysis ===\n\n")

# 1. Load panel and collapse to state-year
panel <- readRDS("../data/analysis_panel.rds")

# Extract year from yearq (format: "2012.1", "2012.2", etc.)
panel <- panel %>%
  mutate(year = as.integer(floor(as.numeric(as.character(yearq)))))

# Collapse to state-year: average population-weighted network MW exposure
state_year <- panel %>%
  filter(!is.na(network_mw_pop) & !is.na(state_fips)) %>%
  group_by(state_fips, year) %>%
  summarise(
    network_mw_pop = mean(network_mw_pop, na.rm = TRUE),
    network_mw_pop_dollar = mean(network_mw_pop_dollar, na.rm = TRUE),
    own_mw = mean(exp(log_min_wage), na.rm = TRUE),  # back to levels for readability
    log_own_mw = mean(log_min_wage, na.rm = TRUE),
    n_counties = n_distinct(county_fips),
    .groups = "drop"
  )

cat("State-year panel: ", nrow(state_year), " obs\n")
cat("States: ", n_distinct(state_year$state_fips), "\n")
cat("Years: ", paste(range(state_year$year), collapse = "-"), "\n\n")

# 2. Construct outcomes: MW change in t+1
state_year <- state_year %>%
  arrange(state_fips, year) %>%
  group_by(state_fips) %>%
  mutate(
    log_own_mw_lead = lead(log_own_mw, 1),
    delta_log_mw = lead(log_own_mw, 1) - log_own_mw,
    mw_increased = as.integer(delta_log_mw > 0.001),  # binary: did MW increase?
    own_mw_lead = lead(own_mw, 1)
  ) %>%
  ungroup() %>%
  filter(!is.na(delta_log_mw))  # drop last year (no lead)

# Exclude states already at $15 ceiling (own MW >= 14.50)
state_year_excl <- state_year %>%
  filter(own_mw < 14.50)

cat("After excluding $15 ceiling states: ", nrow(state_year_excl), " obs\n")
cat("States with MW increases: ", sum(state_year_excl$mw_increased, na.rm = TRUE), "\n")
cat("Fraction with MW increase: ", round(mean(state_year_excl$mw_increased, na.rm = TRUE), 3), "\n\n")

# 3. Regressions
cat("--- Linear Probability Model: MW increase in t+1 ---\n")
lpm <- feols(mw_increased ~ network_mw_pop + log_own_mw | state_fips + year,
             data = state_year_excl, cluster = ~state_fips)
summary(lpm)

cat("\n--- Continuous: Δlog(MW) in t+1 ---\n")
cont <- feols(delta_log_mw ~ network_mw_pop + log_own_mw | state_fips + year,
              data = state_year_excl, cluster = ~state_fips)
summary(cont)

# 4. Save results for LaTeX
sink("../tables/tab_policy_diffusion.tex")
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Policy Diffusion: Network Exposure and Future Minimum Wage Changes}\n")
cat("\\label{tab:diffusion}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) \\\\\n")
cat(" & MW Increase$_{s,t+1}$ & $\\Delta\\log$(MW)$_{s,t+1}$ \\\\\n")
cat("\\midrule\n")

# Extract coefficients
b1 <- round(coef(lpm)["network_mw_pop"], 3)
se1 <- round(sqrt(vcov(lpm)["network_mw_pop", "network_mw_pop"]), 3)
p1 <- pvalue(lpm)["network_mw_pop"]
stars1 <- ifelse(p1 < 0.01, "***", ifelse(p1 < 0.05, "**", ifelse(p1 < 0.10, "*", "")))

b2 <- round(coef(cont)["network_mw_pop"], 3)
se2 <- round(sqrt(vcov(cont)["network_mw_pop", "network_mw_pop"]), 3)
p2 <- pvalue(cont)["network_mw_pop"]
stars2 <- ifelse(p2 < 0.01, "***", ifelse(p2 < 0.05, "**", ifelse(p2 < 0.10, "*", "")))

cat(sprintf("Network MW$_t$ (pop-wtd) & %s%s & %s%s \\\\\n", b1, stars1, b2, stars2))
cat(sprintf(" & (%s) & (%s) \\\\\n", se1, se2))
cat("\\addlinespace\n")
cat("Lagged own MW & Yes & Yes \\\\\n")
cat("State FE & Yes & Yes \\\\\n")
cat("Year FE & Yes & Yes \\\\\n")
cat(sprintf("Observations & %d & %d \\\\\n", nobs(lpm), nobs(cont)))
cat(sprintf("States & %d & %d \\\\\n",
            n_distinct(state_year_excl$state_fips[!is.na(state_year_excl$mw_increased)]),
            n_distinct(state_year_excl$state_fips[!is.na(state_year_excl$delta_log_mw)])))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Unit of observation is state-year. Column 1: linear probability model where the dependent variable is an indicator for whether the state raised its minimum wage in year $t+1$. Column 2: dependent variable is $\\Delta\\log(\\text{MW})_{s,t+1}$. Network MW is the state-average population-weighted network minimum wage exposure at time $t$, constructed from county-level exposure collapsed to state-year means. States at the \\$15 ceiling are excluded. Standard errors clustered at the state level in parentheses. *** $p<0.01$, ** $p<0.05$, * $p<0.10$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("\nTable saved to ../tables/tab_policy_diffusion.tex\n")
cat("=== Policy Diffusion Analysis Complete ===\n")
