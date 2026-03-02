## ============================================================
## 03_main_analysis.R — RDD estimates at 250 threshold
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

out_dir <- file.path(WORK_DIR, "data")
tab_dir <- file.path(WORK_DIR, "tables")

sample_A <- readRDS(file.path(out_dir, "sample_250_A.rds"))
sample_B <- readRDS(file.path(out_dir, "sample_250_B.rds"))
sample_500 <- readRDS(file.path(out_dir, "sample_500.rds"))

# ── Helper function for RDD estimation ───────────────────────
run_rdd <- function(data, outcome, rv = "rv_250", cutoff = 0,
                    kernel = "triangular", p = 1) {
  y <- data[[outcome]]
  x <- data[[rv]]
  valid <- !is.na(y) & !is.na(x)

  if (sum(valid) < 100) {
    return(list(coef = NA, se = NA, ci_l = NA, ci_u = NA,
                pval = NA, bw = NA, n_eff = NA, n_left = NA, n_right = NA))
  }

  fit <- tryCatch(
    rdrobust(y = y[valid], x = x[valid], c = cutoff, kernel = kernel, p = p),
    error = function(e) NULL
  )

  if (is.null(fit)) {
    return(list(coef = NA, se = NA, ci_l = NA, ci_u = NA,
                pval = NA, bw = NA, n_eff = NA, n_left = NA, n_right = NA))
  }

  list(
    coef    = fit$coef["Robust", ],
    se      = fit$se["Robust", ],
    ci_l    = fit$ci["Robust", "CI Lower"],
    ci_u    = fit$ci["Robust", "CI Upper"],
    pval    = fit$pv["Robust", ],
    bw      = fit$bws[1, 1],  # MSE-optimal bandwidth
    n_eff   = fit$N_h[1] + fit$N_h[2],
    n_left  = fit$N_h[1],
    n_right = fit$N_h[2]
  )
}

# ── Primary outcomes at 250 threshold ────────────────────────
outcomes_primary <- c(
  "literacy_11"          = "Literacy Rate (2011)",
  "f_lit_11"             = "Female Literacy Rate (2011)",
  "m_lit_11"             = "Male Literacy Rate (2011)",
  "gender_lit_gap_11"    = "Gender Literacy Gap (2011)",
  "worker_share_11"      = "Worker Share (2011)",
  "f_worker_share_11"    = "Female Worker Share (2011)",
  "nonag_share_11"       = "Non-Agricultural Worker Share (2011)",
  "f_nonag_share_11"     = "Female Non-Ag Worker Share (2011)",
  "pop_growth"           = "Population Growth (2001-2011)",
  "log_nl_post_dmsp"     = "Log Nightlights (DMSP 2005-2013)",
  "log_nl_post_viirs"    = "Log Nightlights (VIIRS 2015-2023)"
)

cat("=== RDD ESTIMATES AT 250 THRESHOLD (Sample A: Special Category States) ===\n\n")

results_A <- list()
for (var in names(outcomes_primary)) {
  res <- run_rdd(sample_A, var)
  results_A[[var]] <- res
  cat(sprintf("%-40s  coef=% .4f  se=%.4f  p=%.3f  bw=%.0f  N_eff=%s\n",
              outcomes_primary[var],
              ifelse(is.na(res$coef), NA, res$coef),
              ifelse(is.na(res$se), NA, res$se),
              ifelse(is.na(res$pval), NA, res$pval),
              ifelse(is.na(res$bw), NA, res$bw),
              ifelse(is.na(res$n_eff), "NA", format(res$n_eff, big.mark = ","))))
}

cat("\n=== RDD ESTIMATES AT 250 THRESHOLD (Sample B: Extended Designated) ===\n\n")

results_B <- list()
for (var in names(outcomes_primary)) {
  res <- run_rdd(sample_B, var)
  results_B[[var]] <- res
  cat(sprintf("%-40s  coef=% .4f  se=%.4f  p=%.3f  bw=%.0f  N_eff=%s\n",
              outcomes_primary[var],
              ifelse(is.na(res$coef), NA, res$coef),
              ifelse(is.na(res$se), NA, res$se),
              ifelse(is.na(res$pval), NA, res$pval),
              ifelse(is.na(res$bw), NA, res$bw),
              ifelse(is.na(res$n_eff), "NA", format(res$n_eff, big.mark = ","))))
}

# ── Comparison: 500 threshold in non-designated areas ────────
cat("\n=== COMPARISON: RDD AT 500 THRESHOLD (Non-Designated Areas) ===\n\n")

results_500 <- list()
for (var in names(outcomes_primary)) {
  res <- run_rdd(sample_500, var, rv = "rv_500")
  results_500[[var]] <- res
  cat(sprintf("%-40s  coef=% .4f  se=%.4f  p=%.3f  bw=%.0f  N_eff=%s\n",
              outcomes_primary[var],
              ifelse(is.na(res$coef), NA, res$coef),
              ifelse(is.na(res$se), NA, res$se),
              ifelse(is.na(res$pval), NA, res$pval),
              ifelse(is.na(res$bw), NA, res$bw),
              ifelse(is.na(res$n_eff), "NA", format(res$n_eff, big.mark = ","))))
}

# ── Save results ─────────────────────────────────────────────
saveRDS(results_A, file.path(out_dir, "results_250_A.rds"))
saveRDS(results_B, file.path(out_dir, "results_250_B.rds"))
saveRDS(results_500, file.path(out_dir, "results_500.rds"))

cat("\nMain analysis complete.\n")
