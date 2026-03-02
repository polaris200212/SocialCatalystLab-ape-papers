###############################################################################
# 04_robustness.R — Robustness checks for "Divine Forgiveness Beliefs"
# Paper: apep_0218
#
# Produces:
#   (a) Education x Attendance interaction regressions
#   (b) Continuous education regressions
#   (c) Year fixed effects regressions
#   (d) Ordered logit for EA034 high gods
#   (e) GSS behavioral outcome correlations
###############################################################################

source("00_packages.R")
library(sandwich)
library(lmtest)
library(MASS)

cat("\n========================================================================\n")
cat("  ROBUSTNESS CHECKS: Divine Forgiveness Beliefs (apep_0218)\n")
cat("========================================================================\n\n")

data_dir <- "../data"

# Load data
gss <- readRDS(file.path(data_dir, "gss_clean.rds"))
ea  <- readRDS(file.path(data_dir, "ea_clean.rds"))

###############################################################################
# (a) Education x Attendance interaction
###############################################################################
cat("--- (a) Education x Attendance Interaction ---\n\n")

gss_reg <- gss %>%
  mutate(
    log_income = ifelse(realinc_num > 0, log(realinc_num), NA_real_),
    relig_cat  = factor(relig_cat, levels = c("Protestant", "Catholic", "Jewish", "Other", "None"))
  ) %>%
  filter(
    !is.na(age_num) & !is.na(female) & !is.na(college) &
    !is.na(log_income) & !is.na(attend_num) & !is.na(relig_cat)
  )

formula_interact <- "~ age_num + female + college + log_income + attend_num + college:attend_num + relig_cat"

interact_models <- list()

# Heaven
if (sum(!is.na(gss_reg$heaven)) > 100) {
  interact_models[["heaven"]] <- lm(as.formula(paste("heaven", formula_interact)), data = gss_reg)
  cat("  Heaven interaction model: N =", nobs(interact_models[["heaven"]]), "\n")
}

# Hell
if (sum(!is.na(gss_reg$hell)) > 100) {
  interact_models[["hell"]] <- lm(as.formula(paste("hell", formula_interact)), data = gss_reg)
  cat("  Hell interaction model: N =", nobs(interact_models[["hell"]]), "\n")
}

# Forgive3
if (sum(!is.na(gss_reg$forgive3)) > 100) {
  interact_models[["forgive3"]] <- lm(as.formula(paste("forgive3", formula_interact)), data = gss_reg)
  cat("  Forgive3 interaction model: N =", nobs(interact_models[["forgive3"]]), "\n")
}

saveRDS(interact_models, file.path(data_dir, "results_interact_models.rds"))
cat("  Saved results_interact_models.rds\n\n")

# Print interaction coefficients
for (nm in names(interact_models)) {
  m <- interact_models[[nm]]
  ct <- coef(summary(m))
  interact_row <- ct[grep("college:attend_num", rownames(ct)), , drop = FALSE]
  if (nrow(interact_row) > 0) {
    cat("  ", nm, ": college x attend coef =",
        round(interact_row[1, 1], 4), " (SE =", round(interact_row[1, 2], 4),
        ", p =", round(interact_row[1, 4], 4), ")\n")
  }
}
cat("\n")


###############################################################################
# (b) Continuous education (educ_num instead of college)
###############################################################################
cat("--- (b) Continuous Education Regressions ---\n\n")

formula_educ <- "~ age_num + female + educ_num + log_income + attend_num + relig_cat"

educ_models <- list()

if (sum(!is.na(gss_reg$heaven)) > 100) {
  educ_models[["heaven"]] <- lm(as.formula(paste("heaven", formula_educ)), data = gss_reg)
}
if (sum(!is.na(gss_reg$hell)) > 100) {
  educ_models[["hell"]] <- lm(as.formula(paste("hell", formula_educ)), data = gss_reg)
}
if (sum(!is.na(gss_reg$forgive3)) > 100) {
  educ_models[["forgive3"]] <- lm(as.formula(paste("forgive3", formula_educ)), data = gss_reg)
}
if (sum(!is.na(gss_reg$cope4)) > 100) {
  educ_models[["cope4"]] <- lm(as.formula(paste("cope4", formula_educ)), data = gss_reg)
}

saveRDS(educ_models, file.path(data_dir, "results_educ_models.rds"))
cat("  Saved results_educ_models.rds\n")

for (nm in names(educ_models)) {
  m <- educ_models[[nm]]
  ct <- coef(summary(m))
  educ_row <- ct["educ_num", , drop = FALSE]
  cat("  ", nm, ": educ_num coef =",
      round(educ_row[1, 1], 4), " (SE =", round(educ_row[1, 2], 4),
      ", p =", round(educ_row[1, 4], 4), ")\n")
}
cat("\n")


###############################################################################
# (c) Year fixed effects
###############################################################################
cat("--- (c) Year Fixed Effects Regressions ---\n\n")

formula_yearfe <- "~ age_num + female + college + log_income + attend_num + relig_cat + factor(year)"
formula_base_c <- "~ age_num + female + college + log_income + attend_num + relig_cat"

yearfe_models <- list()

# Helper: only add year FE if outcome is observed in 2+ years
fit_yearfe <- function(outcome, data) {
  d <- data[!is.na(data[[outcome]]), ]
  n_years <- length(unique(d$year))
  if (n_years >= 2) {
    f <- as.formula(paste(outcome, formula_yearfe))
  } else {
    # Fallback: no year FE if only 1 year has data
    cat("  Note:", outcome, "has data in only", n_years, "year(s); skipping year FE.\n")
    f <- as.formula(paste(outcome, formula_base_c))
  }
  lm(f, data = d)
}

if (sum(!is.na(gss_reg$heaven)) > 100) {
  yearfe_models[["heaven"]] <- fit_yearfe("heaven", gss_reg)
}
if (sum(!is.na(gss_reg$hell)) > 100) {
  yearfe_models[["hell"]] <- fit_yearfe("hell", gss_reg)
}
if (sum(!is.na(gss_reg$forgive3)) > 100) {
  yearfe_models[["forgive3"]] <- fit_yearfe("forgive3", gss_reg)
}
if (sum(!is.na(gss_reg$cope4)) > 100) {
  yearfe_models[["cope4"]] <- fit_yearfe("cope4", gss_reg)
}

saveRDS(yearfe_models, file.path(data_dir, "results_yearfe_models.rds"))
cat("  Saved results_yearfe_models.rds\n")

for (nm in names(yearfe_models)) {
  m <- yearfe_models[[nm]]
  ct <- coef(summary(m))
  # Report college coefficient (main variable of interest)
  college_row <- ct["college", , drop = FALSE]
  cat("  ", nm, ": college coef (w/ year FE) =",
      round(college_row[1, 1], 4), " (SE =", round(college_row[1, 2], 4),
      ", p =", round(college_row[1, 4], 4), ")\n")
}
cat("\n")


###############################################################################
# (d) Ordered logit for EA034 high gods
###############################################################################
cat("--- (d) Ordered Logit: EA034 High Gods by Region ---\n\n")

ea_ologit <- ea %>%
  filter(!is.na(high_gods_num) & !is.na(region)) %>%
  mutate(
    high_gods_ord = factor(high_gods_num, levels = 0:3, ordered = TRUE),
    world_region = case_when(
      grepl("Africa|Macaronesia", region, ignore.case = TRUE) ~ "Africa",
      grepl("Europe|Caucasus", region, ignore.case = TRUE) ~ "Europe",
      grepl("Asia|China|Mongolia|Indo-China|Malesia|Siberia|Far East|Indian|Arabian",
            region, ignore.case = TRUE) ~ "Asia",
      grepl("Australia|Pacific|New Zealand|Papuasia", region, ignore.case = TRUE) ~ "Oceania",
      grepl("U\\.S\\.A|Canada|Subarctic America", region, ignore.case = TRUE) ~ "North America",
      grepl("Mexico|Central America|Caribbean", region, ignore.case = TRUE) ~ "Central Am./Carib.",
      grepl("South America|Brazil", region, ignore.case = TRUE) ~ "South America",
      TRUE ~ "Other"
    ),
    world_region = factor(world_region)
  )

cat("  Ordered logit sample: N =", nrow(ea_ologit), "\n")

# Set reference category (largest group)
ea_ologit$world_region <- relevel(ea_ologit$world_region, ref = "Africa")

ologit_fit <- tryCatch({
  polr(high_gods_ord ~ world_region, data = ea_ologit, Hess = TRUE)
}, error = function(e) {
  cat("  ERROR:", e$message, "\n")
  NULL
})

if (!is.null(ologit_fit)) {
  cat("  Ordered logit converged.\n")
  ct <- coef(summary(ologit_fit))
  # Compute p-values from t-values (normal approximation)
  pvals <- 2 * pnorm(-abs(ct[, "t value"]))
  ct_df <- data.frame(ct, p_value = round(pvals, 4))
  cat("\n")
  print(ct_df)
  cat("\n")
  saveRDS(ologit_fit, file.path(data_dir, "results_ologit_ea034.rds"))
  cat("  Saved results_ologit_ea034.rds\n\n")
} else {
  cat("  Ordered logit did not converge.\n\n")
}


###############################################################################
# (e) GSS behavioral outcome correlations
###############################################################################
cat("--- (e) GSS Behavioral Outcome Correlations ---\n\n")

# Check which behavioral variables are available and have data
behav_vars <- c("trust", "helpful", "happy", "health")
divine_vars <- c("forgive3", "cope4")

# Recode behavioral variables to numeric
gss_behav <- gss %>%
  mutate(
    trust_num   = as.numeric(trust),
    helpful_num = as.numeric(helpful),
    happy_num   = as.numeric(happy),
    health_num  = as.numeric(health)
  )

behav_num_vars <- c("trust_num", "helpful_num", "happy_num", "health_num")

# Check availability
for (v in behav_num_vars) {
  n_valid <- sum(!is.na(gss_behav[[v]]))
  cat("  ", v, ": N =", n_valid, "\n")
}
cat("\n")

# Build correlation matrix with divine temperament variables
cor_vars <- c(divine_vars, behav_num_vars)
cor_data <- gss_behav %>%
  dplyr::select(all_of(cor_vars)) %>%
  mutate(across(everything(), as.numeric))

# Pairwise complete correlations
n_complete <- sum(complete.cases(cor_data))
cat("  Complete cases across all vars:", n_complete, "\n")

# Compute pairwise correlation matrix
cor_mat <- cor(cor_data, use = "pairwise.complete.obs")
cat("\n  Correlation matrix:\n")
print(round(cor_mat, 3))
cat("\n")

# Compute p-values for key correlations
behav_cor_results <- map_dfr(behav_num_vars, function(bv) {
  map_dfr(divine_vars, function(dv) {
    d <- cor_data %>% filter(!is.na(.data[[dv]]) & !is.na(.data[[bv]]))
    if (nrow(d) < 10) {
      return(tibble(divine = dv, behavioral = bv, n = nrow(d), r = NA, p = NA))
    }
    ct <- cor.test(d[[dv]], d[[bv]])
    tibble(
      divine     = dv,
      behavioral = bv,
      n          = nrow(d),
      r          = round(ct$estimate, 3),
      p          = round(ct$p.value, 4)
    )
  })
})

cat("  Behavioral correlations with divine beliefs:\n")
print(behav_cor_results, n = Inf)
cat("\n")

saveRDS(cor_mat, file.path(data_dir, "results_behavioral_cor_mat.rds"))
saveRDS(behav_cor_results, file.path(data_dir, "results_behavioral_cors.rds"))
cat("  Saved results_behavioral_cor_mat.rds and results_behavioral_cors.rds\n")


###############################################################################
# Summary
###############################################################################
cat("\n========================================================================\n")
cat("  ROBUSTNESS CHECKS COMPLETE\n")
cat("========================================================================\n")

result_files <- list.files(data_dir, pattern = "^results_", full.names = TRUE)
cat("  Total result files:", length(result_files), "\n")
