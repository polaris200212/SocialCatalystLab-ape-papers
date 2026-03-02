##############################################################################
# 06_tables.R — All tables for paper
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

source("00_packages.R")

data_dir <- "../data"
tab_dir  <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
rob_results <- tryCatch(readRDS(file.path(data_dir, "robustness_results.rds")),
                        error = function(e) NULL)

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================
cat("Creating Table 1: Summary statistics...\n")

# Cross-sectional summary (one row per CSP)
cs_data <- panel[!duplicated(csp_name)]

# Panel summary
summ_vars <- c("total_offences_rate", "betting_density", "shops_current", "population")

# Add crime type rates if they exist
crime_rate_cols <- grep("_rate$", names(panel), value = TRUE)
crime_rate_cols <- crime_rate_cols[crime_rate_cols %in% names(panel)]

# Build summary table
make_summ <- function(dt, vars) {
  out <- data.table(
    Variable = character(),
    N = integer(),
    Mean = numeric(),
    SD = numeric(),
    P25 = numeric(),
    Median = numeric(),
    P75 = numeric()
  )
  for (v in vars) {
    if (v %in% names(dt)) {
      x <- dt[[v]]
      x <- x[!is.na(x) & is.finite(x)]
      out <- rbind(out, data.table(
        Variable = v,
        N = length(x),
        Mean = mean(x),
        SD = sd(x),
        P25 = quantile(x, 0.25),
        Median = median(x),
        P75 = quantile(x, 0.75)
      ))
    }
  }
  out
}

# Panel-level variables
panel_summ <- make_summ(panel, c("total_offences_rate", crime_rate_cols, "population"))

# Cross-sectional variables
cs_summ <- make_summ(cs_data, c("betting_density", "shops_current"))

# Combine
tab1 <- rbind(
  data.table(Panel = "Panel Variables (CSP × Quarter)", panel_summ),
  data.table(Panel = "Cross-Section (CSP)", cs_summ)
)

# Clean variable names for display
tab1[, Variable := gsub("_rate$", " (per 10k)", Variable)]
tab1[, Variable := gsub("_", " ", Variable)]
tab1[, Variable := tools::toTitleCase(Variable)]

# Format numbers
for (col in c("Mean", "SD", "P25", "Median", "P75")) {
  tab1[, (col) := round(get(col), 2)]
}

fwrite(tab1, file.path(tab_dir, "tab1_summary_stats.csv"))

# LaTeX version
tab1_tex <- kableExtra::kbl(tab1[, -1],  # drop Panel grouping column
                             format = "latex",
                             booktabs = TRUE,
                             caption = "Summary Statistics",
                             label = "tab:summary") |>
  kableExtra::pack_rows(index = table(tab1$Panel)) |>
  kableExtra::kable_styling(latex_options = c("hold_position"))

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary_stats.tex"))

# ============================================================================
# TABLE 2: Main Results — Crime Rate DiD
# ============================================================================
cat("Creating Table 2: Main DiD results...\n")

# Collect models for the main table
main_models <- list()
model_labels <- character()

if (!is.null(results$m_total_crime)) {
  main_models[[length(main_models) + 1]] <- results$m_total_crime
  model_labels <- c(model_labels, "Total Crime")
}
if (!is.null(results$m_violence)) {
  main_models[[length(main_models) + 1]] <- results$m_violence
  model_labels <- c(model_labels, "Violence")
}
if (!is.null(results$m_theft)) {
  main_models[[length(main_models) + 1]] <- results$m_theft
  model_labels <- c(model_labels, "Theft")
}
if (!is.null(results$m_criminal_damage)) {
  main_models[[length(main_models) + 1]] <- results$m_criminal_damage
  model_labels <- c(model_labels, "Criminal Damage")
}
if (!is.null(results$m_robbery)) {
  main_models[[length(main_models) + 1]] <- results$m_robbery
  model_labels <- c(model_labels, "Robbery")
}
if (!is.null(results$m_public_order)) {
  main_models[[length(main_models) + 1]] <- results$m_public_order
  model_labels <- c(model_labels, "Public Order")
}

names(main_models) <- model_labels

tab2 <- modelsummary(
  main_models,
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  coef_rename = c("betting_density:post" = "Density $\\times$ Post"),
  output = file.path(tab_dir, "tab2_main_results.tex"),
  title = "Effect of Betting Density on Crime Rates",
  notes = c("Standard errors clustered at CSP level in parentheses.",
            "All models include CSP and quarter fixed effects.",
            "Density = betting shops per 10,000 population (pre-policy).",
            "Crime rates per 10,000 population.")
)

# Also save as CSV for inspection
tab2_csv <- modelsummary(main_models,
                         stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
                         gof_map = c("nobs", "r.squared"),
                         output = "data.frame")
fwrite(tab2_csv, file.path(tab_dir, "tab2_main_results.csv"))

# ============================================================================
# TABLE 3: Placebo Tests
# ============================================================================
cat("Creating Table 3: Placebo tests...\n")

if (!is.null(rob_results)) {
  placebo_models <- list()
  placebo_labels <- character()

  if (!is.null(rob_results$placebo_drug)) {
    placebo_models[[length(placebo_models) + 1]] <- rob_results$placebo_drug
    placebo_labels <- c(placebo_labels, "Drug Offences")
  }
  if (!is.null(rob_results$placebo_sexual)) {
    placebo_models[[length(placebo_models) + 1]] <- rob_results$placebo_sexual
    placebo_labels <- c(placebo_labels, "Sexual Offences")
  }
  if (!is.null(rob_results$placebo_fake_date)) {
    placebo_models[[length(placebo_models) + 1]] <- rob_results$placebo_fake_date
    placebo_labels <- c(placebo_labels, "Fake Date (2017Q2)")
  }

  if (length(placebo_models) > 0) {
    names(placebo_models) <- placebo_labels
    modelsummary(
      placebo_models,
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      gof_map = c("nobs", "r.squared"),
      output = file.path(tab_dir, "tab3_placebo_tests.tex"),
      title = "Placebo Tests",
      notes = c("Standard errors clustered at CSP level.",
                "Columns 1-2: unrelated crime types. Column 3: fake treatment date.")
    )
  }
}

# ============================================================================
# TABLE 4: Robustness — Alternative Specifications
# ============================================================================
cat("Creating Table 4: Robustness checks...\n")

if (!is.null(rob_results)) {
  rob_models <- list(
    "Baseline" = results$m_total_crime,
    "Excl. COVID" = rob_results$r_no_covid,
    "COVID Interact" = rob_results$r_covid_interact,
    "Top/Bottom Tercile" = rob_results$r_tercile,
    "Hetero SE" = rob_results$r_hetero_se,
    "Two-way Cluster" = rob_results$r_twoway_se
  )

  modelsummary(
    rob_models,
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    output = file.path(tab_dir, "tab4_robustness.tex"),
    title = "Robustness: Alternative Specifications",
    notes = c("All models include CSP and quarter fixed effects.",
              "Column 1: baseline. Column 2: excludes 2020Q1-2021Q2.",
              "Column 3: controls for COVID × density interaction.",
              "Column 4: top vs bottom tercile only.",
              "Columns 5-6: alternative standard error specifications.")
  )
}

# ============================================================================
# TABLE 5: By Treatment Group Means
# ============================================================================
cat("Creating Table 5: Treatment group means...\n")

# Pre vs post means by treatment group
group_means <- panel[, .(
  crime_rate = mean(total_offences_rate, na.rm = TRUE),
  n_csps = uniqueN(csp_name),
  mean_pop = mean(population, na.rm = TRUE),
  mean_shops = mean(shops_current, na.rm = TRUE)
), by = .(high_density, post)]

group_means[, Treatment := fifelse(high_density == 1, "High Density", "Low Density")]
group_means[, Period := fifelse(post == 1, "Post (2019Q2+)", "Pre (2015Q2-2019Q1)")]

tab5 <- dcast(group_means, Treatment ~ Period,
              value.var = c("crime_rate", "n_csps", "mean_pop"))

fwrite(tab5, file.path(tab_dir, "tab5_group_means.csv"))

# LaTeX version
tab5_tex <- kableExtra::kbl(tab5,
                             format = "latex",
                             booktabs = TRUE,
                             caption = "Pre-Post Means by Treatment Group",
                             label = "tab:groupmeans",
                             digits = 2) |>
  kableExtra::kable_styling(latex_options = c("hold_position"))

writeLines(tab5_tex, file.path(tab_dir, "tab5_group_means.tex"))

cat("\n=== All tables saved to", tab_dir, "===\n")
cat("Files created:\n")
for (f in list.files(tab_dir)) {
  cat("  ", f, "\n")
}
