## ============================================================================
## 04_robustness.R -- Robustness checks
## ============================================================================

source("00_packages.R")
DATA <- "../data"

panel_bh <- readRDS(file.path(DATA, "panel_bh.rds"))
panel_pc <- readRDS(file.path(DATA, "panel_pc.rds"))
cs_results <- readRDS(file.path(DATA, "cs_results.rds"))
twfe_results <- readRDS(file.path(DATA, "twfe_results.rds"))

## --------------------------------------------------------------------------
## 1. Bacon Decomposition
## --------------------------------------------------------------------------

panel_bh_annual <- panel_bh[, .(
  ln_providers = mean(ln_providers),
  post = max(post)
), by = .(state, state_id, year, treated_state, first_treat_q)]

panel_bh_annual[, first_treat_year := fifelse(first_treat_q == 0, 0L,
                                                as.integer(2018 + floor((first_treat_q - 1) / 4)))]

annual_counts <- panel_bh_annual[, .N, by = state]
balanced <- panel_bh_annual[state %in% annual_counts[N == max(N)]$state]

bacon_out <- tryCatch({
  bacon(ln_providers ~ post, data = as.data.frame(balanced),
        id_var = "state_id", time_var = "year")
}, error = function(e) { cat("Bacon error:", e$message, "\n"); NULL })

if (!is.null(bacon_out)) {
  saveRDS(bacon_out, file.path(DATA, "bacon_decomp.rds"))
  cat("Bacon decomposition saved.\n")
}

## --------------------------------------------------------------------------
## 2. Placebo: Personal Care Providers (T-codes)
## --------------------------------------------------------------------------

set.seed(2024)

cs_pc <- tryCatch({
  att_gt(
    yname = "ln_providers", tname = "time_q", idname = "state_id",
    gname = "first_treat_q", data = as.data.frame(panel_pc),
    control_group = "nevertreated", bstrap = TRUE, biters = 500
  )
}, error = function(e) { cat("PC CS error:", e$message, "\n"); NULL })

if (!is.null(cs_pc)) {
  es_pc <- aggte(cs_pc, type = "dynamic", min_e = -8, max_e = 8)
  att_pc <- aggte(cs_pc, type = "group")
  saveRDS(list(cs_pc = cs_pc, es_pc = es_pc, att_pc = att_pc),
          file.path(DATA, "placebo_pc_results.rds"))
  cat(sprintf("Placebo (PC) ATT: %.4f (SE: %.4f)\n", att_pc$overall.att, att_pc$overall.se))
}

## --------------------------------------------------------------------------
## 3. Placebo: Fake Treatment Dates (2 years early)
## --------------------------------------------------------------------------

panel_placebo <- copy(panel_bh)
panel_placebo[first_treat_q > 0, fake_treat := first_treat_q - 8L]
panel_placebo[first_treat_q == 0, fake_treat := 0L]
# Only keep pre-real-treatment periods
panel_placebo <- panel_placebo[first_treat_q == 0 | time_q < first_treat_q]
panel_placebo[fake_treat < 1 & fake_treat != 0, fake_treat := 1L]

cs_fake <- tryCatch({
  att_gt(
    yname = "ln_providers", tname = "time_q", idname = "state_id",
    gname = "fake_treat", data = as.data.frame(panel_placebo[fake_treat >= 0]),
    control_group = "nevertreated", bstrap = TRUE, biters = 500
  )
}, error = function(e) { cat("Fake date error:", e$message, "\n"); NULL })

if (!is.null(cs_fake)) {
  att_fake <- aggte(cs_fake, type = "group")
  saveRDS(list(cs_fake = cs_fake, att_fake = att_fake),
          file.path(DATA, "placebo_fake_results.rds"))
  cat(sprintf("Placebo (fake dates) ATT: %.4f (SE: %.4f)\n",
              att_fake$overall.att, att_fake$overall.se))
}

## --------------------------------------------------------------------------
## 4. Leave-One-Out Sensitivity
## --------------------------------------------------------------------------

treated_states <- unique(panel_bh[treated_state == 1]$state)
loo_list <- list()
for (drop_st in treated_states) {
  p <- panel_bh[state != drop_st]
  m <- feols(ln_providers ~ post | state_id + time_q, data = p, cluster = ~state)
  loo_list[[drop_st]] <- data.table(
    dropped = drop_st,
    coef = coef(m)["post"],
    se = se(m)["post"]
  )
}
loo_dt <- rbindlist(loo_list)
saveRDS(loo_dt, file.path(DATA, "loo_results.rds"))
cat(sprintf("LOO range: [%.4f, %.4f]\n", min(loo_dt$coef), max(loo_dt$coef)))

## --------------------------------------------------------------------------
## 5. Excluding COVID period (post-pandemic only)
## --------------------------------------------------------------------------

# Post-Jan 2022 (time_q >= 17)
panel_post <- panel_bh[time_q >= 17]
if (uniqueN(panel_post[treated_state == 1]$state) >= 5) {
  twfe_post <- feols(ln_providers ~ post | state_id + time_q,
                     data = panel_post, cluster = ~state)
  saveRDS(twfe_post, file.path(DATA, "twfe_post_covid.rds"))
  cat(sprintf("Post-COVID TWFE: %.4f (SE: %.4f)\n",
              coef(twfe_post)["post"], se(twfe_post)["post"]))
}

## --------------------------------------------------------------------------
## 6. HonestDiD Sensitivity
## --------------------------------------------------------------------------

tryCatch({
  es <- cs_results$es_prov
  pre_idx <- which(es$egt < 0)
  post_idx <- which(es$egt >= 0)

  if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
    betahat <- es$att.egt
    sigma <- diag(es$se.egt^2)

    honest <- HonestDiD::createSensitivityResults(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01)
    )
    saveRDS(honest, file.path(DATA, "honest_did.rds"))
    cat("HonestDiD saved.\n")
  }
}, error = function(e) cat("HonestDiD error:", e$message, "\n"))

cat("\n=== Robustness complete ===\n")
