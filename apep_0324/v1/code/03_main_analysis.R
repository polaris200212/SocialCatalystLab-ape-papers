###############################################################################
# 03_main_analysis.R — AIPW estimation of fear → punitiveness
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

source("00_packages.R")

df <- readRDS("../data/gss_analysis.rds")
cat("Analysis sample:", nrow(df), "observations\n")

###############################################################################
# A) Prepare covariates for AIPW
###############################################################################

# Covariate list for propensity score and outcome models
covariate_cols <- c("age_c", "age_sq", "female", "black", "other_race",
                    "educ_years", "college", "parent_educ_avg",
                    "married", "has_children",
                    "log_realinc", "conservative",
                    "urban", "violent_rate")

# Function to prepare analysis-ready data for a given outcome
prep_aipw_data <- function(data, outcome_var, covs = covariate_cols) {
  d <- data %>%
    select(afraid, all_of(outcome_var), all_of(covs), year, region_f) %>%
    filter(complete.cases(.))

  # Create year dummies (exclude first year as reference)
  year_dummies <- model.matrix(~ factor(year), data = d)[, -1]
  # Create region dummies (exclude first region as reference)
  region_dummies <- model.matrix(~ region_f, data = d)[, -1]

  X <- cbind(
    d %>% select(all_of(covs)) %>% as.matrix(),
    year_dummies,
    region_dummies
  )

  list(
    A = d$afraid,
    Y = d[[outcome_var]],
    X = X,
    data = d,
    n = nrow(d)
  )
}

###############################################################################
# B) AIPW Estimation Function
###############################################################################

run_aipw <- function(A, Y, X, label = "") {
  cat(sprintf("\n--- AIPW: %s ---\n", label))
  cat("N =", length(A), ", Treated =", sum(A), ", Control =", sum(1 - A), "\n")
  cat("Treatment rate:", round(mean(A), 3), "\n")
  cat("Outcome rate:", round(mean(Y), 3), "\n")

  tryCatch({
    # Use AIPW package with cross-fitting
    aipw_obj <- AIPW$new(
      Y = Y,
      A = A,
      W = X,
      Q.SL.library = c("SL.glm", "SL.ranger"),
      g.SL.library = c("SL.glm", "SL.ranger"),
      k_split = 5,
      verbose = FALSE
    )

    aipw_obj$fit()
    aipw_obj$summary()

    # Extract results
    res <- aipw_obj$result
    ate <- res$Estimate[res$Estimand == "ATE"]
    se  <- res$SE[res$Estimand == "ATE"]
    ci_lo <- ate - 1.96 * se
    ci_hi <- ate + 1.96 * se

    cat(sprintf("ATE = %.4f (SE = %.4f), 95%% CI: [%.4f, %.4f]\n",
                ate, se, ci_lo, ci_hi))
    cat(sprintf("p-value = %.4f\n", 2 * pnorm(-abs(ate / se))))

    return(list(
      ate = ate, se = se, ci_lo = ci_lo, ci_hi = ci_hi,
      p = 2 * pnorm(-abs(ate / se)),
      n = length(A),
      n_treated = sum(A),
      label = label,
      aipw_obj = aipw_obj
    ))
  }, error = function(e) {
    cat("AIPW failed:", e$message, "\n")
    cat("Falling back to simple IPW...\n")

    # Fallback: logistic regression + IPW
    ps_model <- glm(A ~ X, family = binomial)
    ps <- fitted(ps_model)
    ps <- pmax(pmin(ps, 0.95), 0.05)  # trim

    w1 <- A / ps
    w0 <- (1 - A) / (1 - ps)

    ate <- weighted.mean(Y[A == 1], w1[A == 1]) -
      weighted.mean(Y[A == 0], w0[A == 0])

    # Bootstrap SE
    set.seed(42)
    boot_ates <- replicate(500, {
      idx <- sample(length(A), replace = TRUE)
      ps_b <- fitted(glm(A[idx] ~ X[idx, ], family = binomial))
      ps_b <- pmax(pmin(ps_b, 0.95), 0.05)
      w1_b <- A[idx] / ps_b
      w0_b <- (1 - A[idx]) / (1 - ps_b)
      weighted.mean(Y[idx][A[idx] == 1], w1_b[A[idx] == 1]) -
        weighted.mean(Y[idx][A[idx] == 0], w0_b[A[idx] == 0])
    })
    se <- sd(boot_ates)

    cat(sprintf("IPW ATE = %.4f (SE = %.4f)\n", ate, se))

    return(list(
      ate = ate, se = se,
      ci_lo = ate - 1.96 * se, ci_hi = ate + 1.96 * se,
      p = 2 * pnorm(-abs(ate / se)),
      n = length(A),
      n_treated = sum(A),
      label = label,
      aipw_obj = NULL
    ))
  })
}

###############################################################################
# C) Main Results: Effect of fear on punitive attitudes
###############################################################################

cat("\n\n========================================\n")
cat("MAIN RESULTS: Fear → Punitive Attitudes\n")
cat("========================================\n")

results <- list()

# Outcome 1: Death penalty support
d1 <- prep_aipw_data(df, "favor_deathpen")
results$deathpen <- run_aipw(d1$A, d1$Y, d1$X, "Death Penalty Support")

# Outcome 2: Courts too lenient
d2 <- prep_aipw_data(df, "courts_too_lenient")
results$courts <- run_aipw(d2$A, d2$Y, d2$X, "Courts Too Lenient")

# Outcome 3: Crime spending
d3 <- prep_aipw_data(df, "want_more_crime_spending")
results$crime_spend <- run_aipw(d3$A, d3$Y, d3$X, "Want More Crime Spending")

# Outcome 4: Gun permits
d4 <- prep_aipw_data(df, "favor_gun_permits")
results$gun_permits <- run_aipw(d4$A, d4$Y, d4$X, "Favor Gun Permits")

###############################################################################
# D) Placebo Tests: Effect on unrelated outcomes
###############################################################################

cat("\n\n========================================\n")
cat("PLACEBO TESTS: Fear → Unrelated Attitudes\n")
cat("========================================\n")

# Space spending
d_p1 <- prep_aipw_data(df, "want_more_space_spending")
results$placebo_space <- run_aipw(d_p1$A, d_p1$Y, d_p1$X, "Placebo: Space Spending")

# Science spending
d_p2 <- prep_aipw_data(df, "want_more_sci_spending")
results$placebo_sci <- run_aipw(d_p2$A, d_p2$Y, d_p2$X, "Placebo: Science Spending")

# Environment spending
d_p3 <- prep_aipw_data(df, "want_more_envir_spending")
results$placebo_envir <- run_aipw(d_p3$A, d_p3$Y, d_p3$X, "Placebo: Environment Spending")

###############################################################################
# E) Summary Table
###############################################################################

cat("\n\n========================================\n")
cat("RESULTS SUMMARY\n")
cat("========================================\n")

summary_df <- tibble(
  outcome = sapply(results, `[[`, "label"),
  ate = sapply(results, `[[`, "ate"),
  se = sapply(results, `[[`, "se"),
  ci_lo = sapply(results, `[[`, "ci_lo"),
  ci_hi = sapply(results, `[[`, "ci_hi"),
  p_value = sapply(results, `[[`, "p"),
  n = sapply(results, `[[`, "n"),
  n_treated = sapply(results, `[[`, "n_treated"),
  significant = sapply(results, function(x) x$p < 0.05),
  type = c(rep("Main", 4), rep("Placebo", 3))
)

print(summary_df %>% select(outcome, ate, se, p_value, n, significant, type), n = 20)

saveRDS(results, file = "../data/main_results.rds")
saveRDS(summary_df, file = "../data/results_summary.rds")

cat("\nSaved: ../data/main_results.rds\n")
cat("Saved: ../data/results_summary.rds\n")

cat("\n=== Main Analysis Complete ===\n")
