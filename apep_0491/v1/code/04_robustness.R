## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")
DATA <- "../data"
panel <- readRDS(file.path(DATA, "analysis_panel_clean.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))

robustness <- list()

## ============================================================================
## 1. NOT-YET-TREATED CONTROL GROUP
## ============================================================================

cat("=== Robustness 1: Not-yet-treated controls ===\n")

cs_murder_nyt <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_nyt <- aggte(cs_murder_nyt, type = "simple")
cat(sprintf("Not-yet-treated ATT: %.3f (SE: %.3f)\n",
            agg_nyt$overall.att, agg_nyt$overall.se))
robustness$nyt <- agg_nyt

## ============================================================================
## 2. DROP 2021 (UCR TRANSITION YEAR)
## ============================================================================

cat("\n=== Robustness 2: Drop 2021 ===\n")

panel_no2021 <- panel[year != 2021]

cs_murder_no2021 <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel_no2021),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_no2021 <- aggte(cs_murder_no2021, type = "simple")
cat(sprintf("Drop 2021 ATT: %.3f (SE: %.3f)\n",
            agg_no2021$overall.att, agg_no2021$overall.se))
robustness$no2021 <- agg_no2021

## ============================================================================
## 3. PRE-COVID SAMPLE (2000-2019)
## ============================================================================

cat("\n=== Robustness 3: Pre-COVID (2000-2019) ===\n")

panel_precovid <- panel[year <= 2019]

cs_murder_precovid <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel_precovid),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_precovid <- aggte(cs_murder_precovid, type = "simple")
cat(sprintf("Pre-COVID ATT: %.3f (SE: %.3f)\n",
            agg_precovid$overall.att, agg_precovid$overall.se))
robustness$precovid <- agg_precovid

## ============================================================================
## 4. DROP 2018 WAVE (largest cohort — 8 states)
## ============================================================================

cat("\n=== Robustness 4: Drop 2018 cohort ===\n")

panel_no2018 <- panel[!(g == 2018)]

cs_murder_no2018 <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel_no2018),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_no2018 <- aggte(cs_murder_no2018, type = "simple")
cat(sprintf("Drop 2018 wave ATT: %.3f (SE: %.3f)\n",
            agg_no2018$overall.att, agg_no2018$overall.se))
robustness$no2018 <- agg_no2018

## ============================================================================
## 5. LEAVE-ONE-STATE-OUT (jackknife)
## ============================================================================

cat("\n=== Robustness 5: Leave-one-state-out ===\n")

## Exclude MI and MN (adopted 2024, no post-treatment data in 2000-2023 panel)
## Also exclude CT (always-treated, dropped by CS-DiD)
treated_states <- unique(panel[treated == TRUE & erpo_year >= 2000 & erpo_year <= 2023]$state_abb)
treated_states <- treated_states[!treated_states %in% c("CT")]
loo_results <- data.table(
  dropped_state = character(),
  att = numeric(),
  se  = numeric()
)

for (st in treated_states) {
  panel_loo <- panel[state_abb != st]
  tryCatch({
    cs_loo <- att_gt(
      yname  = "murder_rate",
      tname  = "year",
      idname = "state_id",
      gname  = "g",
      data   = as.data.frame(panel_loo),
      control_group = "nevertreated",
      anticipation  = 0,
      base_period   = "universal",
      est_method    = "dr",
      bstrap        = TRUE,
      biters        = 500,
      clustervars   = "state_id"
    )
    agg_loo <- aggte(cs_loo, type = "simple")
    loo_results <- rbind(loo_results, data.table(
      dropped_state = st,
      att = agg_loo$overall.att,
      se  = agg_loo$overall.se
    ))
  }, error = function(e) {
    cat(sprintf("  Warning: LOO failed for %s: %s\n", st, e$message))
  })
}

cat("Leave-one-out range:\n")
cat(sprintf("  ATT range: [%.3f, %.3f]\n", min(loo_results$att), max(loo_results$att)))
cat(sprintf("  Main ATT:  %.3f\n", results$agg_murder$overall.att))
robustness$loo <- loo_results

## ============================================================================
## 6. HONESTDID SENSITIVITY (Rambachan & Roth 2023)
## ============================================================================

cat("\n=== Robustness 6: HonestDiD sensitivity ===\n")

tryCatch({
  es_obj <- results$es_murder

  ## Extract event-study coefficients and variance-covariance
  betahat <- es_obj$att.egt
  sigma   <- es_obj$V_analytical

  ## Identify pre and post periods
  event_times <- es_obj$egt
  pre_idx  <- which(event_times < 0)
  post_idx <- which(event_times >= 0)

  if (length(pre_idx) >= 2 && length(post_idx) >= 1 && !is.null(sigma)) {
    ## Relative magnitudes approach
    honest_rm <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma   = sigma,
      numPrePeriods  = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mbarvec = seq(0, 2, by = 0.5)
    )
    cat("HonestDiD relative magnitudes:\n")
    print(honest_rm)
    robustness$honestdid <- honest_rm
  } else {
    cat("  Insufficient pre/post periods for HonestDiD.\n")
    robustness$honestdid <- NULL
  }
}, error = function(e) {
  cat(sprintf("  HonestDiD failed: %s\n", e$message))
  robustness$honestdid <- NULL
})

## ============================================================================
## 7. WILD CLUSTER BOOTSTRAP (TWFE) — manual Rademacher weights
## ============================================================================
## fwildclusterboot is unavailable under R 4.3.2. We implement the wild cluster
## bootstrap manually following Cameron, Gelbach & Miller (2008) using
## Rademacher weights (+1/-1 with equal probability), clustering at the state
## level.  The TWFE coefficient on `post` is re-estimated in each bootstrap
## draw by re-weighting the score equations.  The resulting empirical p-value
## is comparable to what fwildclusterboot::boottest() would produce.
## ============================================================================

cat("\n=== Robustness 7: Wild cluster bootstrap (Rademacher, B=999) ===\n")

tryCatch({
  library(fixest)

  ## Fit the baseline TWFE model on the full panel
  ## Convert logical `post` to numeric to get a clean coefficient name
  panel[, post_num := as.integer(post)]
  twfe_base <- feols(murder_rate ~ post_num | state_id + year,
                     data = panel, cluster = ~state_id)

  ## Cluster-level residuals needed for the wild bootstrap score
  ## We work with the restricted model (impose H0: beta_post = 0) to get
  ## the score bootstrap p-value (Wu/Mammen approach adapted for cluster)
  ## Here we use the unrestricted residuals for confidence interval bootstrap.

  coef_obs <- coef(twfe_base)["post_num"]
  se_obs   <- se(twfe_base)["post_num"]
  cat(sprintf("  TWFE (cluster SE): coef = %.4f, SE = %.4f, t = %.3f\n",
              coef_obs, se_obs, coef_obs / se_obs))

  ## Residuals from the within-transformed model
  panel_df          <- as.data.frame(panel)
  panel_df$post_num <- as.integer(panel_df$post)
  panel_df$res      <- resid(twfe_base)

  ## State-level cluster means of residuals (for clustering)
  state_res <- tapply(panel_df$res, panel_df$state_id, identity)
  states    <- names(state_res)
  n_clusters <- length(states)

  set.seed(1234)
  B <- 999
  boot_coefs <- numeric(B)

  for (b in seq_len(B)) {
    ## Draw Rademacher weights: +1 or -1, one per cluster
    weights_b <- sample(c(-1L, 1L), size = n_clusters, replace = TRUE)
    names(weights_b) <- states

    ## Apply cluster weight to residuals → perturbed outcome
    panel_df$w_b <- weights_b[as.character(panel_df$state_id)]
    panel_df$y_b <- fitted(twfe_base) + panel_df$res * panel_df$w_b

    ## Re-estimate TWFE on perturbed outcome
    fit_b <- tryCatch(
      feols(y_b ~ post_num | state_id + year,
            data = panel_df, cluster = ~state_id, warn = FALSE),
      error = function(e) NULL
    )
    boot_coefs[b] <- if (is.null(fit_b)) NA_real_ else coef(fit_b)["post_num"]
  }

  boot_coefs <- boot_coefs[!is.na(boot_coefs)]
  n_valid    <- length(boot_coefs)

  ## Bootstrap SE and percentile CI
  boot_se    <- sd(boot_coefs)
  boot_ci    <- quantile(boot_coefs, c(0.025, 0.975))

  ## Wild bootstrap p-value (symmetric, H0: beta = 0)
  ## Centre the distribution around zero before computing p-value
  boot_centered <- boot_coefs - mean(boot_coefs)
  boot_pval     <- mean(abs(boot_centered) >= abs(coef_obs))

  cat(sprintf("  Bootstrap SE (B=%d valid): %.4f\n", n_valid, boot_se))
  cat(sprintf("  Bootstrap 95%% CI: [%.4f, %.4f]\n", boot_ci[1], boot_ci[2]))
  cat(sprintf("  Wild bootstrap p-value (H0: coef=0): %.4f\n", boot_pval))

  robustness$wild_boot <- list(
    coef_obs   = coef_obs,
    se_obs     = se_obs,
    boot_se    = boot_se,
    boot_ci    = boot_ci,
    boot_pval  = boot_pval,
    boot_coefs = boot_coefs,
    n_valid    = n_valid
  )
}, error = function(e) {
  cat(sprintf("  Wild cluster bootstrap failed: %s\n", e$message))
  robustness$wild_boot <- NULL
})

## ============================================================================
## 8. RANDOMIZATION INFERENCE
## ============================================================================

cat("\n=== Robustness 8: Randomization inference (1000 permutations) ===\n")

set.seed(42)
n_perms <- 1000
true_att <- results$agg_murder$overall.att
perm_atts <- numeric(n_perms)

for (i in seq_len(n_perms)) {
  ## Shuffle treatment assignment across states
  perm_panel <- copy(panel)
  state_list <- unique(perm_panel$state_abb)
  perm_g <- sample(panel[, .(g = first(g)), by = state_abb]$g)
  perm_map <- data.table(state_abb = state_list, g_perm = perm_g)
  perm_panel <- merge(perm_panel, perm_map, by = "state_abb")

  tryCatch({
    cs_perm <- att_gt(
      yname  = "murder_rate",
      tname  = "year",
      idname = "state_id",
      gname  = "g_perm",
      data   = as.data.frame(perm_panel),
      control_group = "nevertreated",
      anticipation  = 0,
      base_period   = "universal",
      est_method    = "reg",  # faster for permutations
      bstrap        = FALSE
    )
    agg_perm <- aggte(cs_perm, type = "simple")
    perm_atts[i] <- agg_perm$overall.att
  }, error = function(e) {
    perm_atts[i] <<- NA
  })

  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))
}

perm_atts <- perm_atts[!is.na(perm_atts)]
ri_p <- mean(abs(perm_atts) >= abs(true_att))
cat(sprintf("RI p-value (two-sided): %.4f (based on %d valid permutations)\n",
            ri_p, length(perm_atts)))
robustness$ri_pvalue <- ri_p
robustness$ri_dist <- perm_atts

## ============================================================================
## 9. LOG SPECIFICATION
## ============================================================================

cat("\n=== Robustness 9: Log murder rate ===\n")

cs_log_murder <- att_gt(
  yname  = "log_murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_log <- aggte(cs_log_murder, type = "simple")
cat(sprintf("Log ATT (murder): %.4f (≈ %.1f%% change, SE: %.4f)\n",
            agg_log$overall.att,
            (exp(agg_log$overall.att) - 1) * 100,
            agg_log$overall.se))
robustness$log_murder <- agg_log

## ============================================================================
## 10. FORMAL PRE-TREND WALD TEST (from CS-DiD event-study influence functions)
## ============================================================================
## The Callaway & Sant'Anna (2021) att_gt object does not report a joint
## pre-trend test by default when using base_period = "universal" (the -1
## period is normalized to 0 and omitted from inference).  We compute a
## joint Wald statistic for H0: ATT(g, t) = 0 for all t < -1 using the
## influence-function-based sandwich covariance matrix from the dynamic
## aggregation (aggte type = "dynamic").
##
## The test statistic is:  W = beta_pre' V_pre^{-1} beta_pre ~ chi^2(k)
## where k = number of pre-periods (excluding the normalized -1 period).
## ============================================================================

cat("\n=== Robustness 10: Formal Wald pre-trend test (CS-DiD) ===\n")

compute_cs_pretest <- function(es_obj, label = "outcome") {
  egt      <- es_obj$egt
  att_egt  <- es_obj$att.egt
  inf_func <- es_obj$inf.function$dynamic.inf.func.e

  ## Exclude the reference period (egt == -1, which is always 0 / NA)
  pre_idx <- which(egt < -1)

  if (length(pre_idx) < 2) {
    cat(sprintf("  %s: fewer than 2 pre-periods available for Wald test.\n", label))
    return(NULL)
  }

  beta_pre <- att_egt[pre_idx]

  ## Sandwich covariance from influence functions: V = (1/n^2) * t(IF) %*% IF
  n  <- nrow(inf_func)
  V  <- (t(inf_func) %*% inf_func) / (n^2)
  V_pre <- V[pre_idx, pre_idx, drop = FALSE]

  ## Wald statistic
  W_stat <- tryCatch(
    as.numeric(t(beta_pre) %*% solve(V_pre) %*% beta_pre),
    error = function(e) NA_real_
  )
  df     <- length(pre_idx)
  p_val  <- pchisq(W_stat, df = df, lower.tail = FALSE)

  cat(sprintf("  %s: Wald chi2(%d) = %.3f, p = %.4f  [%s]\n",
              label, df, W_stat, p_val,
              ifelse(p_val > 0.10, "PASS: no evidence against PTA",
                     ifelse(p_val > 0.05, "MARGINAL", "FAIL: pre-trends detected"))))

  list(
    label     = label,
    W_stat    = W_stat,
    df        = df,
    p_val     = p_val,
    beta_pre  = beta_pre,
    pre_idx   = pre_idx,
    egt_pre   = egt[pre_idx]
  )
}

## Run for all four outcomes (murder is the primary)
pretest_murder   <- compute_cs_pretest(results$es_murder,   "Murder rate")
pretest_assault  <- compute_cs_pretest(results$es_assault,  "Assault rate")
pretest_robbery  <- compute_cs_pretest(results$es_robbery,  "Robbery rate")
pretest_violent  <- compute_cs_pretest(results$es_violent,  "Total violent rate")
pretest_property <- compute_cs_pretest(results$es_property, "Property rate (placebo)")

robustness$pretest_murder   <- pretest_murder
robustness$pretest_assault  <- pretest_assault
robustness$pretest_robbery  <- pretest_robbery
robustness$pretest_violent  <- pretest_violent
robustness$pretest_property <- pretest_property

## ============================================================================
## 11. GOODMAN-BACON DECOMPOSITION (manual, TWFE weights by cohort pair)
## ============================================================================
## The bacondecomp package (v0.1.1) has a known bug under R 4.3.2 that causes
## "subscript out of bounds" errors.  We implement the Goodman-Bacon (2021)
## decomposition analytically following the paper's Theorem 1.
##
## The 2x2 DiD weight for comparison (k, U) is:
##   w_{kU} = n_k * n_U * (D_k_bar * (1 - D_k_bar)) / (n * sum_j n_j D_j_bar (1-D_j_bar))
## where D_k_bar is the fraction of periods unit k is treated.
## We compute pairwise 2x2 DiD estimates between each (early, late) cohort pair
## and between each treated cohort and the never-treated group.
## ============================================================================

cat("\n=== Robustness 11: Goodman-Bacon decomposition (manual) ===\n")

tryCatch({
  ## Use the full panel, excluding always-treated (CT, g == 1999)
  ## and not-yet-treated in sample (MI, MN: g == 2024, never post in panel)
  panel_gb <- panel[g != 1999 & g != 2024]

  ## Cohort treatment years (g == 0 means never treated)
  cohorts_all <- sort(unique(panel_gb$g))
  cohorts_treated <- cohorts_all[cohorts_all > 0]
  never_g <- 0L

  years  <- sort(unique(panel_gb$year))
  T_len  <- length(years)

  ## Helper: compute 2x2 DiD ATT between two groups over a time window
  ## Group k is treated in period g_k; group l may be later-treated or never.
  ## Window = years where neither is treated early (clean comparison).
  did_2x2 <- function(dt, g_k, g_l) {
    ## g_l == 0 means never treated
    ## Use pre-period: years < g_k (neither group treated)
    ## Use post-period: years >= g_k and (g_l == 0 or years < g_l)
    pre_yrs  <- years[years < g_k]
    if (g_l == 0) {
      post_yrs <- years[years >= g_k]
    } else {
      ## For (early vs late): post window is g_k <= t < g_l
      post_yrs <- years[years >= g_k & years < g_l]
    }
    if (length(pre_yrs) == 0 || length(post_yrs) == 0) return(NA_real_)

    group_k <- dt[g == g_k]
    group_l <- dt[g == g_l]
    if (nrow(group_k) == 0 || nrow(group_l) == 0) return(NA_real_)

    y_k_post <- mean(group_k[year %in% post_yrs, murder_rate], na.rm = TRUE)
    y_k_pre  <- mean(group_k[year %in% pre_yrs,  murder_rate], na.rm = TRUE)
    y_l_post <- mean(group_l[year %in% post_yrs, murder_rate], na.rm = TRUE)
    y_l_pre  <- mean(group_l[year %in% pre_yrs,  murder_rate], na.rm = TRUE)

    (y_k_post - y_k_pre) - (y_l_post - y_l_pre)
  }

  ## Goodman-Bacon weights: proportional to n_k * n_l * variance in treatment timing
  ## Simplified: weight is n_k * n_l * D_k_bar * (1 - D_k_bar)
  ## where D_k_bar = fraction of sample periods unit-type k is treated
  n_total <- nrow(panel_gb)

  ## Count obs per cohort
  cohort_n <- panel_gb[, .(n_obs = .N), by = g]
  setkey(cohort_n, g)

  D_bar <- function(g_val) {
    ## Fraction of panel years treated for cohort g_val
    if (g_val == 0) return(0)
    sum(years >= g_val) / T_len
  }

  ## Enumerate all comparison pairs
  bacon_rows <- list()

  ## (a) Each treated cohort vs never-treated
  for (gk in cohorts_treated) {
    n_k  <- cohort_n[g == gk, n_obs]
    n_u  <- cohort_n[g == never_g, n_obs]
    if (length(n_k) == 0 || length(n_u) == 0 || n_u == 0) next
    d_k  <- D_bar(gk)
    att  <- did_2x2(panel_gb, gk, never_g)
    wt   <- n_k * n_u * d_k * (1 - d_k)
    bacon_rows[[length(bacon_rows) + 1]] <- data.table(
      type        = "Treated vs Never",
      cohort_k    = gk,
      cohort_l    = NA_integer_,
      n_k         = n_k,
      n_l         = n_u,
      weight_raw  = wt,
      att_2x2     = att
    )
  }

  ## (b) Early vs late treated cohorts (both directions)
  pairs <- combn(cohorts_treated, 2)
  for (j in seq_len(ncol(pairs))) {
    g_early <- min(pairs[, j])
    g_late  <- max(pairs[, j])
    n_e <- cohort_n[g == g_early, n_obs]
    n_l <- cohort_n[g == g_late,  n_obs]
    if (length(n_e) == 0 || length(n_l) == 0) next

    ## Early treated uses late as control (pre g_late window)
    d_e  <- D_bar(g_early)
    att_el <- did_2x2(panel_gb, g_early, g_late)
    wt_el  <- n_e * n_l * d_e * (1 - d_e)
    bacon_rows[[length(bacon_rows) + 1]] <- data.table(
      type        = "Early vs Late (early treated)",
      cohort_k    = g_early,
      cohort_l    = g_late,
      n_k         = n_e,
      n_l         = n_l,
      weight_raw  = wt_el,
      att_2x2     = att_el
    )

    ## Late treated uses already-treated early group as control (post g_early window)
    pre_late  <- years[years < g_early]
    post_late <- years[years >= g_late]
    if (length(pre_late) > 0 && length(post_late) > 0) {
      grp_e <- panel_gb[g == g_early]
      grp_l <- panel_gb[g == g_late]
      y_l_post <- mean(grp_l[year %in% post_late, murder_rate], na.rm = TRUE)
      y_l_pre  <- mean(grp_l[year %in% pre_late,  murder_rate], na.rm = TRUE)
      y_e_post <- mean(grp_e[year %in% post_late, murder_rate], na.rm = TRUE)
      y_e_pre  <- mean(grp_e[year %in% pre_late,  murder_rate], na.rm = TRUE)
      att_le  <- (y_l_post - y_l_pre) - (y_e_post - y_e_pre)
      d_l     <- D_bar(g_late)
      wt_le   <- n_l * n_e * d_l * (1 - d_l)
      bacon_rows[[length(bacon_rows) + 1]] <- data.table(
        type        = "Late vs Early (late treated, early as control)",
        cohort_k    = g_late,
        cohort_l    = g_early,
        n_k         = n_l,
        n_l         = n_e,
        weight_raw  = wt_le,
        att_2x2     = att_le
      )
    }
  }

  bacon_dt <- rbindlist(bacon_rows)

  ## Normalise weights to sum to 1
  total_wt <- sum(bacon_dt$weight_raw, na.rm = TRUE)
  bacon_dt[, weight := weight_raw / total_wt]

  ## Weighted average should approximate TWFE estimate
  bacon_dt_valid <- bacon_dt[!is.na(att_2x2)]
  twfe_implied <- sum(bacon_dt_valid$att_2x2 * bacon_dt_valid$weight_raw, na.rm = TRUE) /
                  sum(bacon_dt_valid$weight_raw, na.rm = TRUE)

  ## Get TWFE coefficient (may be named "post" or "postTRUE" depending on type)
  twfe_coef_names <- names(coef(results$twfe_murder))
  twfe_post_name  <- twfe_coef_names[grepl("post", twfe_coef_names, ignore.case = TRUE)][1]
  cat(sprintf("  TWFE murder (from feols): %.4f\n",
              coef(results$twfe_murder)[twfe_post_name]))
  cat(sprintf("  Goodman-Bacon implied:    %.4f\n", twfe_implied))

  ## Summary by comparison type
  summ <- bacon_dt_valid[, .(
    total_weight   = sum(weight),
    weighted_att   = sum(att_2x2 * weight_raw) / sum(weight_raw),
    n_comparisons  = .N
  ), by = type]
  cat("\n  Goodman-Bacon weight decomposition:\n")
  print(summ)

  robustness$bacon <- list(
    decomp        = bacon_dt,
    twfe_implied  = twfe_implied,
    summary       = summ
  )
}, error = function(e) {
  cat(sprintf("  Goodman-Bacon decomposition failed: %s\n", e$message))
  robustness$bacon <- NULL
})

## ============================================================================
## SAVE ALL ROBUSTNESS RESULTS
## ============================================================================

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))
cat("\nAll robustness results saved.\n")
