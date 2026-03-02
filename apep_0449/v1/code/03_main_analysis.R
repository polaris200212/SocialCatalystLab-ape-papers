## ============================================================================
## 03_main_analysis.R — Primary RDD Estimates
## Criminal Politicians and Local Development (apep_0449)
##
## Estimates:
##   Panel A: Nightlights outcomes (full sample)
##     (1) nl_growth — proportional growth replicating Prakash et al.
##     (2) nl_change — level change
##     (3) log_nl_post controlling for log_nl_pre
##   Panel B: Village Directory amenity outcomes (post-2008 subsample)
##     Changes and levels for electricity, schools, banking, post offices
## ============================================================================
source("00_packages.R")

cat("\n================================================================\n")
cat("MAIN RDD ANALYSIS\n")
cat("================================================================\n\n")

## ============================================================================
## 1. LOAD DATA
## ============================================================================
cat("-- 1. Loading datasets --\n")

rdd <- readRDS(file.path(DATA_DIR, "rdd_analysis.rds"))
cat("  Full RDD sample:", nrow(rdd), "elections\n")
cat("  Years:", paste(sort(unique(rdd$year)), collapse = ", "), "\n")
cat("  With NL outcomes:", sum(!is.na(rdd$nl_growth)), "\n\n")

rdd_post08 <- readRDS(file.path(DATA_DIR, "rdd_post08_full.rds"))
cat("  Post-2008 sample:", nrow(rdd_post08), "elections\n")
cat("  VD 2011 vars available:",
    paste(grep("^pc11_vd_", names(rdd_post08), value = TRUE), collapse = ", "),
    "\n")
cat("  VD 2001 vars available:",
    paste(grep("^pc01_vd_", names(rdd_post08), value = TRUE), collapse = ", "),
    "\n\n")

## ============================================================================
## 2. HELPER FUNCTIONS
## ============================================================================

## Wrapper around rdrobust that handles errors gracefully and extracts
## key statistics into a tidy list
run_rd <- function(Y, X, covs = NULL, label = "Outcome", data = rdd,
                   cluster = NULL, p = 1) {
  ## Subset to non-missing observations
  keep <- !is.na(data[[Y]]) & !is.na(data[[X]])
  if (!is.null(covs)) {
    for (cv in covs) {
      if (cv %in% names(data)) {
        keep <- keep & !is.na(data[[cv]])
      }
    }
  }
  d <- data[keep, ]
  n_total <- nrow(d)

  if (n_total < 50) {
    cat("  [SKIP]", label, "- only", n_total, "obs with non-missing data\n")
    return(NULL)
  }

  ## Build covariate matrix (drop columns not in data)
  cov_mat <- NULL
  cov_names_used <- NULL
  if (!is.null(covs)) {
    cov_cols <- intersect(covs, names(d))
    if (length(cov_cols) > 0) {
      cov_mat <- as.matrix(d[, ..cov_cols])
      ## Drop columns with zero variance (cause rdrobust to fail)
      col_vars <- apply(cov_mat, 2, var, na.rm = TRUE)
      good_cols <- !is.na(col_vars) & col_vars > 0
      if (sum(good_cols) > 0) {
        cov_mat <- cov_mat[, good_cols, drop = FALSE]
        cov_names_used <- cov_cols[good_cols]
      } else {
        cov_mat <- NULL
      }
    }
  }

  ## Build cluster vector
  cl_vec <- NULL
  if (!is.null(cluster) && cluster %in% names(d)) {
    cl_vec <- d[[cluster]]
  }

  ## Run rdrobust
  rd_fit <- tryCatch({
    rdrobust::rdrobust(
      y    = d[[Y]],
      x    = d[[X]],
      covs = cov_mat,
      p    = p,
      cluster = cl_vec,
      all  = TRUE
    )
  }, error = function(e) {
    cat("  [ERROR]", label, ":", conditionMessage(e), "\n")
    return(NULL)
  })

  if (is.null(rd_fit)) return(NULL)

  ## Extract results
  ## Conventional estimate
  tau_conv <- rd_fit$coef["Conventional", ]
  se_conv  <- rd_fit$se["Conventional", ]
  pv_conv  <- rd_fit$pv["Conventional", ]

  ## Bias-corrected robust estimate (preferred)
  tau_bc <- rd_fit$coef["Bias-Corrected", ]
  se_rb  <- rd_fit$se["Robust", ]
  pv_rb  <- rd_fit$pv["Robust", ]
  ci_rb  <- rd_fit$ci["Robust", ]

  ## Bandwidth and sample sizes
  bw_left  <- rd_fit$bws["h", "left"]
  bw_right <- rd_fit$bws["h", "right"]
  n_left   <- rd_fit$N_h[1]
  n_right  <- rd_fit$N_h[2]
  n_eff    <- n_left + n_right

  res <- list(
    label      = label,
    outcome    = Y,
    n_total    = n_total,
    n_eff      = n_eff,
    n_left     = n_left,
    n_right    = n_right,
    bw_left    = bw_left,
    bw_right   = bw_right,
    tau_conv   = as.numeric(tau_conv),
    se_conv    = as.numeric(se_conv),
    pv_conv    = as.numeric(pv_conv),
    tau_bc     = as.numeric(tau_bc),
    se_rb      = as.numeric(se_rb),
    pv_rb      = as.numeric(pv_rb),
    ci_rb_lo   = as.numeric(ci_rb[1]),
    ci_rb_hi   = as.numeric(ci_rb[2]),
    covariates = cov_names_used,
    rd_object  = rd_fit
  )

  ## Print summary
  stars <- ""
  if (res$pv_rb < 0.01) stars <- "***"
  else if (res$pv_rb < 0.05) stars <- "**"
  else if (res$pv_rb < 0.10) stars <- "*"

  cat(sprintf("  %-35s  tau = %7.4f  (se = %6.4f)  p = %.3f %s\n",
              label, res$tau_bc, res$se_rb, res$pv_rb, stars))
  cat(sprintf("  %35s  N_eff = %d (L=%d, R=%d)  bw = [%.2f, %.2f]\n",
              "", res$n_eff, res$n_left, res$n_right, res$bw_left, res$bw_right))

  return(res)
}

## ============================================================================
## 3. PANEL A: NIGHTLIGHTS RDD (FULL SAMPLE)
## ============================================================================
cat("-- 2. Panel A: Nightlights RDD --\n\n")

## Baseline covariates for nightlights regressions
nl_covs <- c("lit_rate_01", "sc_share_01", "st_share_01", "log_pop_01")

## (A1) NL Growth — main specification replicating Prakash et al.
cat("  [A1] Nightlights growth (proportional):\n")
res_nl_growth <- run_rd(
  Y = "nl_growth", X = "margin", covs = nl_covs,
  label = "NL Growth (post-pre)/pre", data = rdd
)

## (A2) NL Change — level difference
cat("\n  [A2] Nightlights change (levels):\n")
res_nl_change <- run_rd(
  Y = "nl_change", X = "margin", covs = nl_covs,
  label = "NL Change (post - pre)", data = rdd
)

## (A3) Log NL Post controlling for Log NL Pre
## rdrobust does not have a "control for baseline" option directly,
## so we include log_nl_pre in the covariate matrix
cat("\n  [A3] Log NL (post), controlling for log NL (pre):\n")
nl_covs_wlag <- c("log_nl_pre", nl_covs)
res_log_nl <- run_rd(
  Y = "log_nl_post", X = "margin", covs = nl_covs_wlag,
  label = "Log NL Post (ctrl pre)", data = rdd
)

## Also run without covariates for comparison
cat("\n  [A4] NL Growth — no covariates:\n")
res_nl_growth_nocov <- run_rd(
  Y = "nl_growth", X = "margin", covs = NULL,
  label = "NL Growth (no covs)", data = rdd
)

## State-clustered standard errors
cat("\n  [A5] NL Growth — state clustered:\n")
## Create a state cluster variable
rdd[, state_cluster := as.integer(as.factor(eci_state_name))]
res_nl_growth_cl <- run_rd(
  Y = "nl_growth", X = "margin", covs = nl_covs,
  label = "NL Growth (state clust)", data = rdd,
  cluster = "state_cluster"
)

cat("\n")

## ============================================================================
## 4. PANEL B: VILLAGE DIRECTORY OUTCOMES (POST-2008)
## ============================================================================
cat("-- 3. Panel B: Village Directory Outcomes (Post-2008) --\n\n")

## Identify VD 2011 outcome variables available
vd11_vars <- grep("^pc11_vd_", names(rdd_post08), value = TRUE)
vd01_vars <- grep("^pc01_vd_", names(rdd_post08), value = TRUE)

cat("  VD 2011 outcomes:", paste(vd11_vars, collapse = ", "), "\n")
cat("  VD 2001 baselines:", paste(vd01_vars, collapse = ", "), "\n\n")

## Friendly labels for VD outcomes
vd_labels <- c(
  "pc11_vd_power_all"    = "Electricity (all sources)",
  "pc11_vd_m_sch_gov"    = "Middle school (govt)",
  "pc11_vd_s_sch_gov"    = "Secondary school (govt)",
  "pc11_vd_comm_bank"    = "Commercial bank",
  "pc11_vd_post_off"     = "Post office"
)

## VD covariates (same census baseline)
vd_covs <- c("lit_rate_01", "sc_share_01", "st_share_01", "log_pop_01")

## Store results
vd_results_levels <- list()
vd_results_changes <- list()

## --- 4a. VD Levels (2011) ---
cat("  --- VD 2011 Levels ---\n")
for (v11 in vd11_vars) {
  lbl <- ifelse(v11 %in% names(vd_labels), vd_labels[[v11]], v11)
  res <- run_rd(
    Y = v11, X = "margin", covs = vd_covs,
    label = paste0(lbl, " (level)"),
    data = rdd_post08
  )
  if (!is.null(res)) {
    vd_results_levels[[v11]] <- res
  }
}

## --- 4b. VD Changes (2011 - 2001) where baseline exists ---
cat("\n  --- VD Changes (2011 - 2001) ---\n")
for (v11 in vd11_vars) {
  ## Find corresponding 2001 variable
  v01 <- gsub("pc11", "pc01", v11)
  if (!(v01 %in% names(rdd_post08))) {
    cat("    No 2001 baseline for", v11, "- skipping change\n")
    next
  }

  ## Compute change variable
  change_var <- paste0("chg_", gsub("pc11_vd_", "", v11))
  rdd_post08[, (change_var) := get(v11) - get(v01)]

  lbl <- ifelse(v11 %in% names(vd_labels), vd_labels[[v11]], v11)
  res <- run_rd(
    Y = change_var, X = "margin", covs = vd_covs,
    label = paste0("D ", lbl),
    data = rdd_post08
  )
  if (!is.null(res)) {
    vd_results_changes[[change_var]] <- res
  }
}

## --- 4c. VD Levels controlling for 2001 baseline ---
cat("\n  --- VD 2011 Levels (controlling for 2001 baseline) ---\n")
vd_results_ctrl <- list()
for (v11 in vd11_vars) {
  v01 <- gsub("pc11", "pc01", v11)
  if (!(v01 %in% names(rdd_post08))) next

  lbl <- ifelse(v11 %in% names(vd_labels), vd_labels[[v11]], v11)
  res <- run_rd(
    Y = v11, X = "margin", covs = c(v01, vd_covs),
    label = paste0(lbl, " (ctrl 01)"),
    data = rdd_post08
  )
  if (!is.null(res)) {
    vd_results_ctrl[[v11]] <- res
  }
}

cat("\n")

## ============================================================================
## 5. COMPILE SUMMARY TABLE
## ============================================================================
cat("-- 4. Summary of All RDD Estimates --\n\n")

## Collect all results into a single list
all_results <- list(
  nl_growth         = res_nl_growth,
  nl_change         = res_nl_change,
  log_nl_post       = res_log_nl,
  nl_growth_nocov   = res_nl_growth_nocov,
  nl_growth_cluster = res_nl_growth_cl
)

## Add VD results
for (nm in names(vd_results_levels))  all_results[[paste0("vd_lev_", nm)]]  <- vd_results_levels[[nm]]
for (nm in names(vd_results_changes)) all_results[[paste0("vd_chg_", nm)]]  <- vd_results_changes[[nm]]
for (nm in names(vd_results_ctrl))    all_results[[paste0("vd_ctrl_", nm)]] <- vd_results_ctrl[[nm]]

## Remove NULLs
all_results <- all_results[!sapply(all_results, is.null)]

## Build summary data.frame
summary_df <- do.call(rbind, lapply(names(all_results), function(nm) {
  r <- all_results[[nm]]
  data.frame(
    spec      = nm,
    label     = r$label,
    tau_bc    = r$tau_bc,
    se_rb     = r$se_rb,
    pv_rb     = r$pv_rb,
    ci_lo     = r$ci_rb_lo,
    ci_hi     = r$ci_rb_hi,
    bw_l      = r$bw_left,
    bw_r      = r$bw_right,
    n_eff     = r$n_eff,
    n_total   = r$n_total,
    stringsAsFactors = FALSE
  )
}))

## Stars for significance
summary_df$stars <- ifelse(summary_df$pv_rb < 0.01, "***",
                    ifelse(summary_df$pv_rb < 0.05, "**",
                    ifelse(summary_df$pv_rb < 0.10, "*", "")))

## Print nicely
cat(sprintf("%-35s  %9s  %8s  %7s  %4s  %6s  %6s  %5s\n",
            "Outcome", "Estimate", "Rob. SE", "p-val", "", "BW(L)", "BW(R)", "N_eff"))
cat(paste(rep("-", 110), collapse = ""), "\n")

## Panel A header
cat("Panel A: Nightlights (Full Sample)\n")
nl_specs <- c("nl_growth", "nl_change", "log_nl_post", "nl_growth_nocov", "nl_growth_cluster")
for (s in nl_specs) {
  if (s %in% summary_df$spec) {
    row <- summary_df[summary_df$spec == s, ]
    cat(sprintf("  %-33s  %9.4f  %8.4f  %7.3f  %-3s  %6.2f  %6.2f  %5d\n",
                row$label, row$tau_bc, row$se_rb, row$pv_rb, row$stars,
                row$bw_l, row$bw_r, row$n_eff))
  }
}

## Panel B header
cat("\nPanel B: Village Directory — Levels (Post-2008)\n")
for (s in grep("^vd_lev_", summary_df$spec, value = TRUE)) {
  row <- summary_df[summary_df$spec == s, ]
  cat(sprintf("  %-33s  %9.4f  %8.4f  %7.3f  %-3s  %6.2f  %6.2f  %5d\n",
              row$label, row$tau_bc, row$se_rb, row$pv_rb, row$stars,
              row$bw_l, row$bw_r, row$n_eff))
}

cat("\nPanel C: Village Directory — Changes (Post-2008)\n")
for (s in grep("^vd_chg_", summary_df$spec, value = TRUE)) {
  row <- summary_df[summary_df$spec == s, ]
  cat(sprintf("  %-33s  %9.4f  %8.4f  %7.3f  %-3s  %6.2f  %6.2f  %5d\n",
              row$label, row$tau_bc, row$se_rb, row$pv_rb, row$stars,
              row$bw_l, row$bw_r, row$n_eff))
}

cat("\nPanel D: Village Directory — Levels ctrl. 2001 baseline (Post-2008)\n")
for (s in grep("^vd_ctrl_", summary_df$spec, value = TRUE)) {
  row <- summary_df[summary_df$spec == s, ]
  cat(sprintf("  %-33s  %9.4f  %8.4f  %7.3f  %-3s  %6.2f  %6.2f  %5d\n",
              row$label, row$tau_bc, row$se_rb, row$pv_rb, row$stars,
              row$bw_l, row$bw_r, row$n_eff))
}

cat(paste(rep("-", 110), collapse = ""), "\n")
cat("Notes: Bias-corrected estimates with robust SEs. * p<0.10, ** p<0.05, *** p<0.01\n")
cat("       Local linear (p=1), triangular kernel, MSE-optimal bandwidth.\n\n")

## ============================================================================
## 6. SAVE ALL RESULTS
## ============================================================================
cat("-- 5. Saving results --\n")

## Strip the full rd_objects to save space (keep everything else)
results_to_save <- lapply(all_results, function(r) {
  r$rd_object <- NULL
  r
})

saveRDS(
  list(
    results      = results_to_save,
    summary_df   = summary_df,
    full_objects = lapply(all_results, function(r) r$rd_object)
  ),
  file.path(DATA_DIR, "main_results.rds")
)

cat("  Saved:", file.path(DATA_DIR, "main_results.rds"), "\n")

## Also export summary table as CSV for easy inspection
fwrite(summary_df, file.path(TAB_DIR, "main_rdd_estimates.csv"))
cat("  Saved:", file.path(TAB_DIR, "main_rdd_estimates.csv"), "\n")

cat("\n================================================================\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat("================================================================\n")
