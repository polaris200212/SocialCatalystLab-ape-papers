#' ---
#' Selective Licensing and Crime Displacement
#' 06_tables.R — Generate all tables
#' ---

source("code/00_packages.R")
library(modelsummary)
library(kableExtra)
options("modelsummary_format_numeric_latex" = "plain")

# ============================================================================
# LOAD DATA
# ============================================================================

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, month := as.Date(month)]
licensing <- fread(file.path(DATA_DIR, "licensing_dates.csv"))
cat_results <- fread(file.path(DATA_DIR, "category_results.csv"))
main_results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
robustness <- tryCatch(readRDS(file.path(DATA_DIR, "robustness_results.rds")),
                        error = function(e) NULL)

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================

message("Table 1: Summary statistics...")

panel_2013 <- panel[year >= 2013]

sum_treated <- panel_2013[ever_treated == 1, .(
  `Mean Crime (LSOA-month)` = mean(total_crime, na.rm = TRUE),
  `SD Crime` = sd(total_crime, na.rm = TRUE),
  `Crime Rate (per 1000)` = mean(crime_rate, na.rm = TRUE),
  `N LSOAs` = uniqueN(lsoa_code),
  `N LAs` = uniqueN(la_code),
  `N LSOA-months` = .N
)]

sum_control <- panel_2013[ever_treated == 0, .(
  `Mean Crime (LSOA-month)` = mean(total_crime, na.rm = TRUE),
  `SD Crime` = sd(total_crime, na.rm = TRUE),
  `Crime Rate (per 1000)` = mean(crime_rate, na.rm = TRUE),
  `N LSOAs` = uniqueN(lsoa_code),
  `N LAs` = uniqueN(la_code),
  `N LSOA-months` = .N
)]

tab1 <- rbind(
  cbind(Group = "Ever-Licensed LAs", sum_treated),
  cbind(Group = "Never-Licensed LAs", sum_control)
)

tab1_latex <- kbl(tab1, format = "latex", booktabs = TRUE,
                   caption = "Summary Statistics: Ever-Licensed vs. Never-Licensed Local Authorities",
                   label = "summary",
                   digits = 2) |>
  kable_styling(latex_options = "hold_position")

writeLines(tab1_latex, file.path(TAB_DIR, "tab1_summary.tex"))

# ============================================================================
# TABLE 2: Main DiD Results
# ============================================================================

message("Table 2: Main DiD results...")

models <- list(
  "TWFE (Count)" = main_results$twfe_basic,
  "TWFE (Rate)" = main_results$twfe_rate
)

# Add LA-level if available
if (!is.null(robustness) && !is.null(robustness$la_level)) {
  models[["LA-Level"]] = robustness$la_level
}

# Add borough-wide if available
bw <- tryCatch(readRDS(file.path(DATA_DIR, "borough_wide_results.rds")),
                error = function(e) NULL)
if (!is.null(bw)) {
  models[["Borough-Wide"]] = bw
}

tab2_file <- file.path(TAB_DIR, "tab2_main_results.tex")
modelsummary(
  models,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("licensed" = "Selective Licensing"),
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  output = tab2_file,
  title = "Effect of Selective Licensing on Crime",
  notes = "Standard errors clustered at the Local Authority level in parentheses."
)

# Post-process Table 2: add label and C&S ATT panel
tab2_lines <- readLines(tab2_file)

# Find and modify specific lines
for (i in seq_along(tab2_lines)) {
  # Add label after caption
  if (grepl("caption=\\{Effect of Selective Licensing on Crime\\}", tab2_lines[i])) {
    tab2_lines[i] <- paste0(tab2_lines[i], "\nlabel={tab:main},")
  }
}

# Load C&S ATT and insert before \end{talltblr}
cs_att_obj <- tryCatch(readRDS(file.path(DATA_DIR, "cs_did_att.rds")), error = function(e) NULL)
if (!is.null(cs_att_obj)) {
  cs_est <- sprintf("%.3f", cs_att_obj$overall.att)
  cs_se  <- sprintf("(%.3f)", cs_att_obj$overall.se)
  end_idx <- grep("\\\\end\\{talltblr\\}", tab2_lines)
  if (length(end_idx) > 0) {
    cs_lines <- c(
      "\\midrule",
      paste0("\\SetCell[c=5]{l} \\textit{Callaway--Sant'Anna (LA--quarter aggregation)} \\\\"),
      "\\midrule",
      paste0("ATT & \\SetCell[c=4]{c} ", cs_est, " \\\\"),
      paste0("& \\SetCell[c=4]{c} ", cs_se, " \\\\")
    )
    tab2_lines <- c(tab2_lines[1:(end_idx[1]-1)], cs_lines, tab2_lines[end_idx[1]:length(tab2_lines)])
  }
}

writeLines(tab2_lines, tab2_file)

# ============================================================================
# TABLE 3: Crime Category Decomposition
# ============================================================================

message("Table 3: Crime categories...")

cat_results[, stars := fifelse(p_value < 0.01, "***",
                                fifelse(p_value < 0.05, "**",
                                        fifelse(p_value < 0.1, "*", "")))]
cat_results[, category_clean := category]  # Names are already title case
cat_results[, est_str := sprintf("%.3f%s", estimate, stars)]
cat_results[, se_str := sprintf("(%.3f)", se)]
cat_results[, p_str := sprintf("%.3f", p_value)]

# Add Holm-adjusted p-values (compute here if not already present)
if (!"p_holm" %in% names(cat_results)) {
  cat_results[, p_holm := p.adjust(p_value, method = "holm")]
}
cat_results[, p_holm_str := sprintf("%.3f", p_holm)]

tab3 <- cat_results[order(p_value), .(
  Category = category_clean,
  Estimate = est_str,
  SE = se_str,
  `p-value` = p_str,
  `p (Holm)` = p_holm_str,
  N = format(n, big.mark = ",")
)]

tab3_latex <- kbl(tab3, format = "latex", booktabs = TRUE,
                   caption = "Effect of Selective Licensing by Crime Category",
                   label = "categories",
                   escape = FALSE) |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "TWFE DiD estimates. * p<0.1, ** p<0.05, *** p<0.01. Holm-adjusted p-values control the family-wise error rate across categories.")

writeLines(tab3_latex, file.path(TAB_DIR, "tab3_categories.tex"))

# ============================================================================
# TABLE 4: Robustness Checks
# ============================================================================

message("Table 4: Robustness...")

if (!is.null(robustness)) {
  # Collect robustness specifications
  rob_specs <- list()

  if (!is.null(robustness$la_level))
    rob_specs[["LA-Level Aggregation"]] <- robustness$la_level
  if (!is.null(robustness$alt_fe1))
    rob_specs[["LA x Year FE"]] <- robustness$alt_fe1
  if (!is.null(robustness$alt_fe2))
    rob_specs[["Region x Month FE"]] <- robustness$alt_fe2
  if (!is.null(bw))
    rob_specs[["Borough-Wide Only"]] <- bw

  if (length(rob_specs) > 0) {
    tab4_file <- file.path(TAB_DIR, "tab4_robustness.tex")
    modelsummary(
      rob_specs,
      stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
      coef_map = c("licensed" = "Selective Licensing"),
      gof_map = c("nobs", "r.squared"),
      output = tab4_file,
      title = "Robustness: Alternative Specifications",
      notes = "All specifications include LSOA and time FE. SE clustered at LA level."
    )
    # Post-process Table 4: add label
    tab4_lines <- readLines(tab4_file)
    for (i in seq_along(tab4_lines)) {
      if (grepl("caption=\\{Robustness: Alternative Specifications\\}", tab4_lines[i])) {
        tab4_lines[i] <- paste0(tab4_lines[i], "\nlabel={tab:robustness},")
      }
    }
    writeLines(tab4_lines, tab4_file)
  }
}

# ============================================================================
# TABLE 5: Placebo Tests
# ============================================================================

message("Table 5: Placebos...")

if (!is.null(robustness$placebo_categories)) {
  placebo <- robustness$placebo_categories
  placebo[, category_clean := str_replace_all(category, "-", " ") |> str_to_title()]
  placebo[, stars := fifelse(p_value < 0.01, "***",
                              fifelse(p_value < 0.05, "**",
                                      fifelse(p_value < 0.1, "*", "")))]

  tab5 <- placebo[, .(
    Category = category_clean,
    Estimate = sprintf("%.4f%s", estimate, stars),
    SE = sprintf("(%.4f)", se),
    `p-value` = sprintf("%.3f", p_value),
    N = format(n, big.mark = ",")
  )]

  tab5_latex <- kbl(tab5, format = "latex", booktabs = TRUE,
                     caption = "Placebo Crime Categories",
                     label = "placebo",
                     escape = FALSE) |>
    kable_styling(latex_options = "hold_position") |>
    footnote(general = "Categories unlikely affected by landlord licensing. No significant effects expected.")

  writeLines(tab5_latex, file.path(TAB_DIR, "tab5_placebo.tex"))
}

# ============================================================================
# TABLE 6: Licensing Adoption Dates
# ============================================================================

message("Table 6: Adoption dates...")

tab6 <- licensing |>
  filter(as.Date(adoption_date) >= "2013-01-01") |>
  arrange(adoption_date) |>
  select(la_name, adoption_date, coverage) |>
  mutate(
    adoption_date = format(as.Date(adoption_date), "%B %Y"),
    coverage = str_replace_all(coverage, "_", " ") |> str_to_title()
  ) |>
  rename(
    `Local Authority` = la_name,
    `Adoption Date` = adoption_date,
    Coverage = coverage
  )

tab6_latex <- kbl(tab6, format = "latex", booktabs = TRUE,
                   caption = "Selective Licensing Adoption Dates",
                   label = "adoption",
                   longtable = TRUE) |>
  kable_styling(latex_options = c("hold_position", "repeat_header"))

writeLines(tab6_latex, file.path(TAB_DIR, "tab6_adoption_dates.tex"))

message("All tables saved to: ", TAB_DIR)
message("Tables complete.")
