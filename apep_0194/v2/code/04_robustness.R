################################################################################
# 04_robustness.R — Robustness Checks
# Paper: Digital Exodus or Digital Magnet?
################################################################################

tryCatch(script_dir <- dirname(sys.frame(1)$ofile), error = function(e) {
  args <- commandArgs(trailingOnly = FALSE)
  f <- grep("^--file=", args, value = TRUE)
  script_dir <<- if (length(f) > 0) dirname(sub("^--file=", "", f)) else "."
})
source(file.path(script_dir, "00_packages.R"))

cat("=== Robustness Checks ===\n")

###############################################################################
# 1. Load data and main results
###############################################################################

qcew_panel <- read_csv(file.path(DATA_DIR, "qcew_panel.csv"),
                       show_col_types = FALSE) %>%
  mutate(state_f = factor(state_abbr), time_f = factor(yearqtr))

bfs_panel <- read_csv(file.path(DATA_DIR, "bfs_panel.csv"),
                      show_col_types = FALSE) %>%
  mutate(state_f = factor(state_abbr), time_f = factor(yearqtr))

cs_results <- tryCatch(readRDS(file.path(DATA_DIR, "cs_results.rds")),
                       error = function(e) list())

cat("Data loaded.\n")

###############################################################################
# 2. Sun-Abraham Interaction-Weighted Estimator
###############################################################################

cat("\n--- Sun-Abraham IW Estimator ---\n")

# SA uses fixest's sunab() function
sa_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>%
    filter(industry == ind) %>%
    mutate(
      # Cohort for sunab: year-quarter of treatment, Inf for never-treated
      cohort_sa = ifelse(treated_state == 1, treat_yearqtr, Inf)
    )

  tryCatch({
    fit_sa <- feols(
      log_emp ~ sunab(cohort_sa, yearqtr) | state_f + time_f,
      data = df, cluster = ~state_f
    )

    sa_results[[ind]] <- fit_sa

    # Overall ATT from Sun-Abraham
    sa_agg <- summary(fit_sa, agg = "ATT")
    cat(sprintf("  %-25s ATT = %7.4f (SE = %.4f)\n",
                ind, sa_agg$coeftable[1, 1], sa_agg$coeftable[1, 2]))

  }, error = function(e) {
    cat("  SA failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(sa_results, file.path(DATA_DIR, "sa_results.rds"))

###############################################################################
# 3. Placebo Outcomes — Non-tech sectors should show no effect
###############################################################################

cat("\n--- Placebo Tests ---\n")

placebo_results <- list()

for (ind in c("Finance & Insurance", "Construction")) {
  df <- qcew_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  fit <- feols(log_emp ~ treat | state_f + time_f,
               data = df, cluster = ~state_f)
  placebo_results[[ind]] <- fit

  cat(sprintf("  PLACEBO %-20s β = %7.4f (SE = %.4f) p = %.4f\n",
              ind,
              coef(fit)["treat"],
              se(fit)["treat"],
              fixest::pvalue(fit)["treat"]))
}

saveRDS(placebo_results, file.path(DATA_DIR, "placebo_results.rds"))

###############################################################################
# 4. Fisher Randomization Inference
###############################################################################

cat("\n--- Randomization Inference ---\n")

# Permute treatment assignment across states 1,000 times
info_df <- qcew_panel %>% filter(industry == "Information")

# Get actual estimate
actual_fit <- feols(log_emp ~ treat | state_f + time_f,
                    data = info_df, cluster = ~state_f)
actual_beta <- coef(actual_fit)["treat"]

n_perms <- 1000
treated_states <- unique(info_df$state_abbr[info_df$treated_state == 1])
all_states <- unique(info_df$state_abbr)
n_treated <- length(treated_states)

perm_betas <- numeric(n_perms)

set.seed(12345)  # Reproducibility seed for randomization inference
cat("  Running", n_perms, "permutations...\n")

for (p in 1:n_perms) {
  # Randomly assign treatment to same number of states
  fake_treated <- sample(all_states, n_treated)

  perm_df <- info_df %>%
    mutate(
      fake_treat_state = ifelse(state_abbr %in% fake_treated, 1, 0),
      fake_treat = fake_treat_state * post
    )

  tryCatch({
    fit_p <- feols(log_emp ~ fake_treat | state_f + time_f,
                   data = perm_df, cluster = ~state_f)
    perm_betas[p] <- coef(fit_p)["fake_treat"]
  }, error = function(e) {
    perm_betas[p] <- NA
  })
}

perm_betas <- perm_betas[!is.na(perm_betas)]
ri_pvalue <- mean(abs(perm_betas) >= abs(actual_beta))

cat(sprintf("  Actual β = %.4f, RI p-value = %.4f (n_valid = %d)\n",
            actual_beta, ri_pvalue, length(perm_betas)))

ri_results <- list(
  actual_beta = actual_beta,
  perm_betas = perm_betas,
  ri_pvalue = ri_pvalue
)
saveRDS(ri_results, file.path(DATA_DIR, "ri_results.rds"))

###############################################################################
# 4b. Wild Cluster Bootstrap (Webb 6-point distribution)
###############################################################################

cat("\n--- Wild Cluster Bootstrap ---\n")

# Manual WCB implementation since fwildclusterboot is unavailable
# Following Cameron, Gelbach & Miller (2008) with Webb (2023) weights
wcb_pvalues <- list()
n_boot <- 999
set.seed(54321)

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>% filter(industry == ind) %>% drop_na(log_emp)

  tryCatch({
    # Original fit
    fit_orig <- feols(log_emp ~ treat | state_f + time_f, data = df, cluster = ~state_f)
    orig_beta <- coef(fit_orig)["treat"]
    orig_t <- orig_beta / se(fit_orig)["treat"]

    # Get state clusters
    states <- unique(df$state_f)
    n_clusters <- length(states)

    # Restricted model (null imposed)
    fit_r <- feols(log_emp ~ 1 | state_f + time_f, data = df)
    resid_r <- residuals(fit_r)
    fitted_r <- fitted(fit_r)

    boot_t <- numeric(n_boot)

    for (b in 1:n_boot) {
      # Webb 6-point weights: (-sqrt(3/2), -1, -sqrt(1/2), sqrt(1/2), 1, sqrt(3/2))
      webb_vals <- c(-sqrt(3/2), -1, -sqrt(1/2), sqrt(1/2), 1, sqrt(3/2))
      weights <- sample(webb_vals, n_clusters, replace = TRUE)
      names(weights) <- states

      # Apply cluster-level weights to restricted residuals
      boot_y <- fitted_r + resid_r * weights[as.character(df$state_f)]
      df_boot <- df
      df_boot$log_emp <- boot_y

      tryCatch({
        fit_b <- feols(log_emp ~ treat | state_f + time_f, data = df_boot, cluster = ~state_f)
        boot_t[b] <- coef(fit_b)["treat"] / se(fit_b)["treat"]
      }, error = function(e) {
        boot_t[b] <<- NA
      })
    }

    boot_t <- boot_t[!is.na(boot_t)]
    wcb_pval <- mean(abs(boot_t) >= abs(orig_t))

    cat(sprintf("  %-25s WCB p-value = %.4f (n_boot = %d)\n", ind, wcb_pval, length(boot_t)))
    wcb_pvalues[[ind]] <- list(
      beta = orig_beta,
      t_stat = orig_t,
      wcb_pvalue = wcb_pval,
      n_boot = length(boot_t)
    )
  }, error = function(e) {
    cat(sprintf("  %-25s WCB failed: %s\n", ind, e$message))
  })
}

saveRDS(wcb_pvalues, file.path(DATA_DIR, "wcb_results.rds"))

###############################################################################
# 5. HonestDiD Sensitivity Analysis
###############################################################################

cat("\n--- HonestDiD Sensitivity ---\n")

# Apply to CS-DiD results for Information sector
if ("Information" %in% names(cs_results)) {
  tryCatch({
    cs_info <- cs_results[["Information"]]

    # Get event study aggregation
    es_info <- aggte(cs_info, type = "dynamic", min_e = -8, max_e = 8)

    # Extract pre-treatment coefficients for sensitivity
    pre_idx <- which(es_info$egt < 0)
    post_idx <- which(es_info$egt >= 0)

    if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
      # Construct beta and sigma for HonestDiD
      beta_hat <- es_info$att.egt
      sigma_hat <- matrix(0, nrow = length(beta_hat), ncol = length(beta_hat))
      diag(sigma_hat) <- es_info$se.egt^2

      # Original CS delta
      honest_out <- tryCatch({
        HonestDiD::createSensitivityResults(
          betahat = beta_hat,
          sigma = sigma_hat,
          numPrePeriods = length(pre_idx),
          numPostPeriods = length(post_idx),
          Mvec = seq(0, 0.05, by = 0.01)
        )
      }, error = function(e) {
        cat("  HonestDiD sensitivity failed:", e$message, "\n")
        NULL
      })

      if (!is.null(honest_out)) {
        cat("  HonestDiD sensitivity bounds computed.\n")
        print(head(honest_out))
        saveRDS(honest_out, file.path(DATA_DIR, "honestdid_results.rds"))
      }
    } else {
      cat("  Insufficient pre/post periods for HonestDiD\n")
    }
  }, error = function(e) {
    cat("  HonestDiD setup failed:", e$message, "\n")
  })
} else {
  cat("  No CS results for Information sector\n")
}

###############################################################################
# 6. Pre-trend tests
###############################################################################

cat("\n--- Pre-trend tests ---\n")

# Formal test: joint significance of pre-treatment coefficients
for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>%
    filter(industry == ind) %>%
    mutate(
      # Create pre-treatment-only indicators
      pre_treat = ifelse(treated_state == 1 & !is.na(rel_time) & rel_time < 0, 1, 0),
      # Linear pre-trend
      pre_trend = ifelse(pre_treat == 1, rel_time, 0)
    )

  tryCatch({
    fit_trend <- feols(log_emp ~ pre_trend | state_f + time_f,
                       data = df, cluster = ~state_f)

    cat(sprintf("  %-25s Pre-trend slope = %7.5f (p = %.4f)\n",
                ind,
                coef(fit_trend)["pre_trend"],
                fixest::pvalue(fit_trend)["pre_trend"]))
  }, error = function(e) {
    cat("  Pre-trend test failed for", ind, ":", e$message, "\n")
  })
}

###############################################################################
# 7. Excluding California (first mover / GDPR effect)
###############################################################################

cat("\n--- Excluding California ---\n")

excl_ca_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>%
    filter(industry == ind, state_abbr != "CA")

  tryCatch({
    fit <- feols(log_emp ~ treat | state_f + time_f,
                 data = df, cluster = ~state_f)
    excl_ca_results[[ind]] <- fit

    cat(sprintf("  %-25s β = %7.4f (SE = %.4f) p = %.4f\n",
                ind,
                coef(fit)["treat"],
                se(fit)["treat"],
                fixest::pvalue(fit)["treat"]))
  }, error = function(e) {
    cat("  Exclude CA failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(excl_ca_results, file.path(DATA_DIR, "excl_ca_results.rds"))

###############################################################################
# 8. Wage outcomes (compositional changes)
###############################################################################

cat("\n--- Wage robustness ---\n")

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  # Wage per worker
  fit_wage <- feols(log_wage ~ treat | state_f + time_f,
                    data = df, cluster = ~state_f)

  cat(sprintf("  %-25s Wage β = %7.4f (SE = %.4f) p = %.4f\n",
              ind,
              coef(fit_wage)["treat"],
              se(fit_wage)["treat"],
              fixest::pvalue(fit_wage)["treat"]))
}

###############################################################################
# 9. Enacted date as alternative treatment timing
###############################################################################

cat("\n--- Enacted date treatment ---\n")

privacy_laws_enacted <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                                 show_col_types = FALSE) %>%
  mutate(
    enacted_yearqtr = year(enacted_date) + (quarter(enacted_date) - 1) / 4
  )

enacted_panel <- qcew_panel %>%
  select(-treat_yearqtr, -post, -treat) %>%
  left_join(
    privacy_laws_enacted %>% select(state_abbr, enacted_yearqtr),
    by = "state_abbr"
  ) %>%
  mutate(
    post_enacted = ifelse(!is.na(enacted_yearqtr) & yearqtr >= enacted_yearqtr, 1, 0),
    treat_enacted = treated_state * post_enacted
  )

for (ind in c("Information", "Software Publishers")) {
  df <- enacted_panel %>% filter(industry == ind)
  if (nrow(df) < 100) next

  fit <- feols(log_emp ~ treat_enacted | state_f + time_f,
               data = df, cluster = ~state_f)

  cat(sprintf("  ENACTED %-20s β = %7.4f (SE = %.4f) p = %.4f\n",
              ind,
              coef(fit)["treat_enacted"],
              se(fit)["treat_enacted"],
              fixest::pvalue(fit)["treat_enacted"]))
}

###############################################################################
# 10. Minimum Detectable Effect (MDE) Calculation
###############################################################################

cat("\n--- Minimum Detectable Effect ---\n")

# MDE for state-level clustered DiD with G treated and N-G control clusters
# Formula: MDE = (t_alpha + t_beta) * sqrt(sigma2_cluster * (1/G + 1/(N-G)) / T)
# where sigma2_cluster accounts for within-cluster correlation

info_df_mde <- qcew_panel %>% filter(industry == "Information")

# Count effectively treated: states with treat_yearqtr within data range (≤ 2024.75)
max_yearqtr <- max(info_df_mde$yearqtr, na.rm = TRUE)
effectively_treated <- unique(info_df_mde$state_abbr[
  !is.na(info_df_mde$treat_yearqtr) & info_df_mde$treat_yearqtr <= max_yearqtr
])
n_treated_clusters <- length(effectively_treated)
n_control_clusters <- length(unique(info_df_mde$state_abbr)) - n_treated_clusters
n_total_clusters <- n_treated_clusters + n_control_clusters
n_periods <- length(unique(info_df_mde$yearqtr))

# Estimate ICC (intraclass correlation) for state-level clustering
state_means <- info_df_mde %>%
  group_by(state_abbr) %>%
  summarize(mean_y = mean(log_emp, na.rm = TRUE), .groups = "drop")

total_var <- var(info_df_mde$log_emp, na.rm = TRUE)
between_var <- var(state_means$mean_y, na.rm = TRUE)
within_var <- info_df_mde %>%
  group_by(state_abbr) %>%
  summarize(v = var(log_emp, na.rm = TRUE), .groups = "drop") %>%
  summarize(mean_v = mean(v, na.rm = TRUE)) %>%
  pull(mean_v)

icc <- between_var / (between_var + within_var)

# Design effect for MDE
# Using formula from Athey & Imbens (2022) for cluster-DiD
t_alpha <- qt(0.975, df = n_total_clusters - 2)  # two-tailed 5%
t_beta <- qt(0.80, df = n_total_clusters - 2)     # 80% power

# Residual SD from the TWFE regression
twfe_info <- tryCatch(readRDS(file.path(DATA_DIR, "twfe_results.rds")),
                      error = function(e) list())
if ("Information" %in% names(twfe_info)) {
  resid_sd <- sqrt(mean(residuals(twfe_info[["Information"]])^2))
} else {
  resid_sd <- sqrt(within_var)
}

# MDE with clustering (approximate)
cluster_factor <- sqrt(1 + (n_periods - 1) * icc)
mde <- (t_alpha + t_beta) * resid_sd * cluster_factor *
  sqrt(1/n_treated_clusters + 1/n_control_clusters) / sqrt(n_periods)

cat(sprintf("  Treated clusters: %d\n", n_treated_clusters))
cat(sprintf("  Control clusters: %d\n", n_control_clusters))
cat(sprintf("  Periods: %d\n", n_periods))
cat(sprintf("  ICC: %.4f\n", icc))
cat(sprintf("  Residual SD: %.4f\n", resid_sd))
cat(sprintf("  MDE (80%% power, 5%% sig): %.4f log points (%.1f%%)\n",
            mde, (exp(mde) - 1) * 100))

mde_results <- list(
  n_treated = n_treated_clusters,
  n_control = n_control_clusters,
  n_periods = n_periods,
  icc = icc,
  resid_sd = resid_sd,
  mde = mde,
  mde_pct = (exp(mde) - 1) * 100
)
saveRDS(mde_results, file.path(DATA_DIR, "mde_results.rds"))

###############################################################################
# 11. Law-Strength Heterogeneity
###############################################################################

cat("\n--- Law-Strength Heterogeneity ---\n")

# Strong: CA, CO, CT, OR (broad rights, dedicated enforcement, data minimization)
# Standard: VA, UT, TX (narrower scope, AG-only enforcement)
strong_states <- c("CA", "CO", "CT", "OR")

privacy_laws_str <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                             show_col_types = FALSE) %>%
  mutate(law_strength = ifelse(state_abbr %in% strong_states, "strong", "standard"))

law_strength_results <- list()

for (ind in c("Information", "Software Publishers", "Computer Systems Design")) {
  df <- qcew_panel %>%
    filter(industry == ind) %>%
    left_join(privacy_laws_str %>% select(state_abbr, law_strength),
              by = "state_abbr") %>%
    mutate(
      law_strength = ifelse(is.na(law_strength), "none", law_strength),
      treat_strong = ifelse(treat == 1 & law_strength == "strong", 1, 0),
      treat_standard = ifelse(treat == 1 & law_strength == "standard", 1, 0)
    )

  tryCatch({
    fit <- feols(log_emp ~ treat_strong + treat_standard | state_f + time_f,
                 data = df, cluster = ~state_f)
    law_strength_results[[ind]] <- fit

    cat(sprintf("  %-25s Strong: β = %7.4f (SE = %.4f), Standard: β = %7.4f (SE = %.4f)\n",
                ind,
                coef(fit)["treat_strong"], se(fit)["treat_strong"],
                coef(fit)["treat_standard"], se(fit)["treat_standard"]))

    # Wald test: strong = standard
    tryCatch({
      wt <- wald(fit, "treat_strong = treat_standard")
      cat(sprintf("    Wald test (strong=standard): F = %.3f, p = %.4f\n",
                  wt$stat, wt$p))
    }, error = function(e) NULL)
  }, error = function(e) {
    cat("  Law strength failed for", ind, ":", e$message, "\n")
  })
}

saveRDS(law_strength_results, file.path(DATA_DIR, "law_strength_results.rds"))

###############################################################################
# 12. Save all robustness summary
###############################################################################

cat("\n--- Saving robustness results ---\n")

get_coef <- function(res, var) if (!is.null(res)) coef(res)[var] else NA_real_
get_se <- function(res, var) if (!is.null(res)) se(res)[var] else NA_real_
get_pv <- function(res, var) if (!is.null(res)) fixest::pvalue(res)[var] else NA_real_

robustness_summary <- tibble(
  check = c("Placebo: Finance", "Placebo: Construction",
            "Exclude CA: Info", "RI p-value: Info"),
  estimate = c(
    get_coef(placebo_results[["Finance & Insurance"]], "treat"),
    get_coef(placebo_results[["Construction"]], "treat"),
    get_coef(excl_ca_results[["Information"]], "treat"),
    actual_beta
  ),
  se = c(
    get_se(placebo_results[["Finance & Insurance"]], "treat"),
    get_se(placebo_results[["Construction"]], "treat"),
    get_se(excl_ca_results[["Information"]], "treat"),
    NA
  ),
  pvalue = c(
    get_pv(placebo_results[["Finance & Insurance"]], "treat"),
    get_pv(placebo_results[["Construction"]], "treat"),
    get_pv(excl_ca_results[["Information"]], "treat"),
    ri_pvalue
  )
)

write_csv(robustness_summary, file.path(DATA_DIR, "robustness_summary.csv"))

cat("\n=== Robustness checks complete ===\n")
