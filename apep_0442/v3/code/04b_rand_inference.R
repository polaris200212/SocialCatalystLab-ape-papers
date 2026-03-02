## ============================================================================
## 04b_rand_inference.R — Randomization inference for RDD
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== RANDOMIZATION INFERENCE ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))

## Running variable: age at 1907 minus 62 (same as main analysis)
cross[, running := age_1907 - 62]
cross[, above := as.integer(running >= 0)]
panel[, running := age_1907 - 62]
panel[, above := as.integer(running >= 0)]

## ---- Settings ----
N_PERM <- 5000
set.seed(20260224)

## Helper: simple diff-in-means (above - below cutoff)
diff_in_means <- function(y, above) {
  mean(y[above == 1], na.rm = TRUE) - mean(y[above == 0], na.rm = TRUE)
}

## =========================================================================
## 1. CROSS-SECTION RI
## =========================================================================
cat("--- 1. CROSS-SECTION RI (N_perm =", N_PERM, ") ---\n")

## Get optimal bandwidth from main analysis
main_fit <- rdrobust(cross$lfp_1910, cross$running, c = 0)
main_bw <- main_fit$bws[1, 1]
cat("Using bandwidth:", round(main_bw, 2), "\n")

dt_bw <- cross[abs(running) <= main_bw]
cat("N within bandwidth:", nrow(dt_bw), "( below:", sum(dt_bw$above == 0),
    " above:", sum(dt_bw$above == 1), ")\n")

## Observed diff-in-means
obs_cross <- diff_in_means(dt_bw$lfp_1910, dt_bw$above)
cat("Observed diff-in-means:", round(obs_cross, 4), "\n")

## Permutation distribution: permute above/below assignment
perm_cross <- numeric(N_PERM)
cat("Running permutations")
for (i in seq_len(N_PERM)) {
  if (i %% 1000 == 0) cat(".")
  perm_above <- sample(dt_bw$above)
  perm_cross[i] <- diff_in_means(dt_bw$lfp_1910, perm_above)
}
cat("\n")

ri_pval_cross <- mean(abs(perm_cross) >= abs(obs_cross), na.rm = TRUE)
cat("RI p-value (two-sided):", round(ri_pval_cross, 4), "\n\n")

## =========================================================================
## 2. PANEL RI
## =========================================================================
cat("--- 2. PANEL RI ---\n")

panel_fit <- rdrobust(panel$delta_lfp, panel$running, c = 0)
panel_bw <- panel_fit$bws[1, 1]
cat("Using bandwidth:", round(panel_bw, 2), "\n")

dt_bw_p <- panel[abs(running) <= panel_bw]
cat("N within bandwidth:", nrow(dt_bw_p), "( below:", sum(dt_bw_p$above == 0),
    " above:", sum(dt_bw_p$above == 1), ")\n")

obs_panel <- diff_in_means(dt_bw_p$delta_lfp, dt_bw_p$above)
cat("Observed diff-in-means:", round(obs_panel, 4), "\n")

perm_panel <- numeric(N_PERM)
cat("Running permutations")
for (i in seq_len(N_PERM)) {
  if (i %% 1000 == 0) cat(".")
  perm_above <- sample(dt_bw_p$above)
  perm_panel[i] <- diff_in_means(dt_bw_p$delta_lfp, perm_above)
}
cat("\n")

ri_pval_panel <- mean(abs(perm_panel) >= abs(obs_panel), na.rm = TRUE)
cat("RI p-value (two-sided):", round(ri_pval_panel, 4), "\n\n")

## =========================================================================
## 3. FIRST STAGE RI
## =========================================================================
cat("--- 3. FIRST STAGE RI ---\n")

fs_fit <- rdrobust(cross$under_1907_act, cross$running, c = 0)
fs_bw <- fs_fit$bws[1, 1]
cat("Using bandwidth:", round(fs_bw, 2), "\n")

dt_bw_fs <- cross[abs(running) <= fs_bw]
cat("N within bandwidth:", nrow(dt_bw_fs), "( below:", sum(dt_bw_fs$above == 0),
    " above:", sum(dt_bw_fs$above == 1), ")\n")

obs_fs <- diff_in_means(dt_bw_fs$under_1907_act, dt_bw_fs$above)
cat("Observed diff-in-means:", round(obs_fs, 4), "\n")

perm_fs <- numeric(N_PERM)
cat("Running permutations")
for (i in seq_len(N_PERM)) {
  if (i %% 1000 == 0) cat(".")
  perm_above <- sample(dt_bw_fs$above)
  perm_fs[i] <- diff_in_means(dt_bw_fs$under_1907_act, perm_above)
}
cat("\n")

ri_pval_fs <- mean(abs(perm_fs) >= abs(obs_fs), na.rm = TRUE)
cat("RI p-value (two-sided):", round(ri_pval_fs, 4), "\n")

## =========================================================================
## SAVE
## =========================================================================
ri_results <- list(
  cross_section = list(observed = obs_cross, permutations = perm_cross,
                       pvalue = ri_pval_cross, N_perm = N_PERM),
  panel = list(observed = obs_panel, permutations = perm_panel,
               pvalue = ri_pval_panel, N_perm = N_PERM),
  first_stage = list(observed = obs_fs, permutations = perm_fs,
                     pvalue = ri_pval_fs, N_perm = N_PERM)
)

saveRDS(ri_results, file.path(data_dir, "ri_results.rds"))
cat("\nRI results saved.\n")
cat("=== RANDOMIZATION INFERENCE COMPLETE ===\n")
