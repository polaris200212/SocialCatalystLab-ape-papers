## ============================================================
## 03_main_analysis.R — RDD estimation (v2: expanded outcomes)
## Sharp RDD at the 1,000-inhabitant threshold
## + Fuzzy RD-IV + 3,500 threshold validation
## + Political pipeline, spending, entrepreneurship outcomes
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
dir.create("../tables", showWarnings = FALSE)

cat("=== MAIN RDD ANALYSIS (v2) ===\n")
cat("N =", nrow(df), "communes\n\n")

## ----------------------------------------------------------
## Helper function for RDD estimation
## ----------------------------------------------------------

run_rdd <- function(y, x, label, bw_manual = NULL) {
  valid <- !is.na(y) & is.finite(y)
  if (sum(valid) < 200) {
    cat("  ", label, ": too few obs (", sum(valid), ")\n")
    return(NULL)
  }

  result <- tryCatch({
    if (is.null(bw_manual)) {
      rd <- rdrobust(y = y[valid], x = x[valid], c = 0,
                     kernel = "triangular", p = 1, bwselect = "cerrd",
                     masspoints = "adjust")
    } else {
      # Manual bandwidth with HC1
      dat <- data.frame(y = y[valid], x = x[valid]) %>%
        filter(abs(x) <= bw_manual)
      if (nrow(dat) < 50) return(NULL)
      mod <- lm(y ~ I(x >= 0) + x + I((x >= 0) * x), data = dat)
      se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])
      pv <- 2 * pnorm(-abs(coef(mod)[2] / se))

      list(
        coef_conv = unname(coef(mod)[2]),
        se_conv = se,
        coef_bc = unname(coef(mod)[2]),
        se_robust = se,
        pv_robust = pv,
        bw = bw_manual,
        n_left = sum(dat$x < 0),
        n_right = sum(dat$x >= 0),
        ci_lower = unname(coef(mod)[2]) - 1.96 * se,
        ci_upper = unname(coef(mod)[2]) + 1.96 * se,
        name = label
      )
    }
  }, error = function(e) {
    cat("  ", label, ": error:", e$message, "\n")
    NULL
  })

  if (is.null(result)) return(NULL)

  # If rdrobust object, extract results
  if ("rdrobust" %in% class(result)) {
    rd <- result
    result <- list(
      name = label,
      coef_conv = rd$coef[1],
      se_conv = rd$se[1],
      coef_bc = rd$coef[2],
      se_robust = rd$se[3],
      pv_robust = rd$pv[3],
      bw = rd$bws[1, 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      ci_lower = rd$ci[3, 1],
      ci_upper = rd$ci[3, 2]
    )
  }

  cat(sprintf("  %s: coef=%.4f SE=%.4f p=%.4f BW=%d N=%d\n",
      label, result$coef_conv, result$se_robust, result$pv_robust,
      round(result$bw), result$n_left + result$n_right))

  return(result)
}

## ===========================================================
## 1. First Stage: Female councillor share
## ===========================================================

cat("--- First Stage: Female Councillor Share ---\n\n")

rd_first <- rdrobust(y = df$female_share, x = df$pop_centered, c = 0,
                     kernel = "triangular", p = 1, bwselect = "cerrd",
                     masspoints = "adjust")
cat("  rdrobust: BW=", round(rd_first$bws[1, 1]),
    " coef=", round(rd_first$coef[1], 4),
    " robust p=", round(rd_first$pv[3], 4), "\n")

# Manual bandwidths
cat("\nManual bandwidth first stage:\n")
for (bw in c(100, 200, 300, 500)) {
  sub <- df %>% filter(abs(pop_centered) <= bw)
  mod <- lm(female_share ~ above_threshold + pop_centered +
              I(above_threshold * pop_centered), data = sub)
  se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])
  cat("  BW=", bw, ": coef=", round(coef(mod)[2], 4),
      " SE=", round(se, 4), " N=", nrow(sub), "\n")
}

saveRDS(rd_first, "../data/rd_first_stage.rds")

## ===========================================================
## 2. Main Labor Market Outcomes (from v1)
## ===========================================================

cat("\n--- Main Labor Market Outcomes ---\n")

outcomes_labor <- list(
  list(name = "Female Employment Rate", var = "female_emp_rate"),
  list(name = "Female LFPR", var = "female_lfpr"),
  list(name = "Male Employment Rate", var = "male_emp_rate"),
  list(name = "Gender Employment Gap", var = "gender_emp_gap"),
  list(name = "Female Share of Employment", var = "female_share_employed"),
  list(name = "Total Employment Rate", var = "total_emp_rate"),
  list(name = "Unemployment Rate", var = "unemployment_rate")
)

results_labor <- list()
for (out in outcomes_labor) {
  r <- run_rdd(df[[out$var]], df$pop_centered, out$name)
  if (!is.null(r)) results_labor[[out$var]] <- r
}

## ===========================================================
## 3. NEW: Political Competition Outcomes (Compound Treatment)
## ===========================================================

cat("\n--- Political Competition Outcomes ---\n")
cat("(Testing whether non-parity aspects of the regime change matter)\n\n")

# Female mayor probability
results_political <- list()

r_mayor <- run_rdd(as.numeric(df$has_female_mayor), df$pop_centered,
                   "Female Mayor Probability")
if (!is.null(r_mayor)) results_political[["female_mayor"]] <- r_mayor

# Number of councillors (mechanical, for reference)
r_ncouncil <- run_rdd(df$n_councillors, df$pop_centered,
                       "Number of Councillors")
if (!is.null(r_ncouncil)) results_political[["n_councillors"]] <- r_ncouncil

# Candidacy outcomes (if available)
if (any(!is.na(df$female_candidate_share))) {
  r_fcand <- run_rdd(df$female_candidate_share, df$pop_centered,
                     "Female Candidate Share (2020)")
  if (!is.null(r_fcand)) results_political[["female_candidate_share"]] <- r_fcand

  r_ncand <- run_rdd(df$n_candidates, df$pop_centered,
                     "Total Candidates (2020)")
  if (!is.null(r_ncand)) results_political[["n_candidates"]] <- r_ncand

  r_nfcand <- run_rdd(df$n_female_candidates, df$pop_centered,
                       "Female Candidates (2020)")
  if (!is.null(r_nfcand)) results_political[["n_female_candidates"]] <- r_nfcand
}

## ===========================================================
## 4. NEW: Municipal Spending Outcomes
## ===========================================================

cat("\n--- Municipal Spending Outcomes ---\n")

results_spending <- list()

if (any(!is.na(df$spend_total_pc))) {
  spending_outcomes <- list(
    list(name = "Total Spending per Capita", var = "spend_total_pc"),
    list(name = "Social Spending per Capita", var = "spend_social_pc"),
    list(name = "Education Spending per Capita", var = "spend_education_pc"),
    list(name = "Family Spending per Capita", var = "spend_family_pc")
  )

  for (out in spending_outcomes) {
    y <- df[[out$var]]
    # Winsorize at 1st and 99th percentiles to handle outliers
    if (sum(!is.na(y) & is.finite(y)) > 100) {
      q01 <- quantile(y, 0.01, na.rm = TRUE)
      q99 <- quantile(y, 0.99, na.rm = TRUE)
      y[y < q01] <- q01
      y[y > q99] <- q99
    }
    r <- run_rdd(y, df$pop_centered, out$name)
    if (!is.null(r)) results_spending[[out$var]] <- r
  }

  # Social spending share (compositional)
  if (any(!is.na(df$avg_social_spending) & !is.na(df$avg_total_spending))) {
    df$social_share <- df$avg_social_spending / df$avg_total_spending
    df$social_share[!is.finite(df$social_share)] <- NA
    r <- run_rdd(df$social_share, df$pop_centered, "Social Spending Share")
    if (!is.null(r)) results_spending[["social_share"]] <- r
  }
} else {
  cat("  No spending data available\n")
}

## ===========================================================
## 5. NEW: Entrepreneurship Outcomes
## ===========================================================

cat("\n--- Entrepreneurship Outcomes ---\n")

results_entrep <- list()

# Female self-employment share from census
if ("female_self_emp_share" %in% names(df)) {
  r <- run_rdd(df$female_self_emp_share, df$pop_centered,
               "Female Self-Employment Share")
  if (!is.null(r)) results_entrep[["female_self_emp_share"]] <- r
}

## ===========================================================
## 6. Fuzzy RD-IV: Using threshold as instrument for female
##    councillor share → labor market outcomes
## ===========================================================

cat("\n--- Fuzzy RD-IV Specification ---\n")

results_fuzzy <- list()

# Use rdrobust fuzzy option
for (out in outcomes_labor[1:4]) {  # Main 4 outcomes
  y <- df[[out$var]]
  valid <- !is.na(y) & is.finite(y) & !is.na(df$female_share)

  if (sum(valid) < 500) next

  rd_fuzzy <- tryCatch(
    rdrobust(y = y[valid], x = df$pop_centered[valid], c = 0,
             fuzzy = df$female_share[valid],
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) {
      cat("  Fuzzy error for", out$name, ":", e$message, "\n")
      NULL
    }
  )

  if (!is.null(rd_fuzzy)) {
    cat(sprintf("  Fuzzy %s: coef=%.4f SE=%.4f p=%.4f\n",
        out$name, rd_fuzzy$coef[1], rd_fuzzy$se[3], rd_fuzzy$pv[3]))

    results_fuzzy[[out$var]] <- list(
      name = paste0(out$name, " (IV)"),
      coef_conv = rd_fuzzy$coef[1],
      se_robust = rd_fuzzy$se[3],
      pv_robust = rd_fuzzy$pv[3],
      bw = rd_fuzzy$bws[1, 1],
      n_left = rd_fuzzy$N_h[1],
      n_right = rd_fuzzy$N_h[2],
      ci_lower = rd_fuzzy$ci[3, 1],
      ci_upper = rd_fuzzy$ci[3, 2]
    )
  }
}

## ===========================================================
## 7. 3,500 Threshold Validation
##    (parity-only effect since PR was already in place)
## ===========================================================

cat("\n--- 3,500 Threshold Validation ---\n")
cat("Above 3,500: PR already in place before 2014; parity extended to 1,000-3,500 band\n")
cat("Testing at 3,500: both sides had PR, so any jump = parity effect from 2000 law\n\n")

results_3500 <- list()

# Restrict to communes 2000-5000 for local comparison
df_3500 <- df %>% filter(pop >= 2000 & pop <= 5000)
cat("  Communes in [2000, 5000]:", nrow(df_3500), "\n")

if (nrow(df_3500) > 200) {
  # First stage at 3,500
  r_fs_3500 <- run_rdd(df_3500$female_share, df_3500$pop_centered_3500,
                        "Female Share (3500)")
  if (!is.null(r_fs_3500)) results_3500[["female_share"]] <- r_fs_3500

  # Labor outcomes at 3,500
  for (out in outcomes_labor[1:4]) {
    r <- run_rdd(df_3500[[out$var]], df_3500$pop_centered_3500,
                 paste0(out$name, " (3500)"))
    if (!is.null(r)) results_3500[[paste0(out$var, "_3500")]] <- r
  }

  # Female mayor at 3,500
  r_mayor_3500 <- run_rdd(as.numeric(df_3500$has_female_mayor),
                           df_3500$pop_centered_3500, "Female Mayor (3500)")
  if (!is.null(r_mayor_3500)) results_3500[["female_mayor_3500"]] <- r_mayor_3500
}

## ===========================================================
## 8. Pre-treatment Placebo (2011)
## ===========================================================

cat("\n--- Pre-treatment Placebo: 2011 outcomes ---\n")

pre_vars <- c("female_emp_rate_2011", "female_lfpr_2011", "total_emp_rate_2011")
results_placebo <- list()

for (v in pre_vars) {
  if (!v %in% names(df)) next
  r <- run_rdd(df[[v]], df$pop_centered, v)
  if (!is.null(r)) results_placebo[[v]] <- r
}

## ===========================================================
## 9. Heterogeneity: Urban vs Rural
## ===========================================================

cat("\n--- Heterogeneity: Urban vs Rural ---\n")

results_het <- list()

if ("grille_densite" %in% names(df)) {
  df$rural <- ifelse(df$grille_densite >= 4, 1, 0)

  for (type in c("Urban (dense)", "Rural (sparse)")) {
    sub <- if (type == "Urban (dense)") df[df$rural == 0, ] else df[df$rural == 1, ]
    r <- run_rdd(sub$female_emp_rate, sub$pop_centered, type)
    if (!is.null(r)) results_het[[type]] <- r
  }
}

## ===========================================================
## 10. Equivalence Testing (TOST)
## ===========================================================

cat("\n--- Equivalence Testing ---\n")
cat("SESOI = 1 percentage point (0.01)\n")

sesoi <- 0.01  # 1 pp — smallest effect of scientific interest

equiv_results <- list()

for (out in outcomes_labor[c(1, 2, 4)]) {  # Female emp, LFPR, gap
  r <- results_labor[[out$var]]
  if (is.null(r)) next

  # TOST: two one-sided tests
  # H1: effect > -SESOI AND effect < +SESOI
  t_lower <- (r$coef_conv - (-sesoi)) / r$se_robust
  t_upper <- (r$coef_conv - sesoi) / r$se_robust

  p_lower <- 1 - pnorm(t_lower)   # reject H01: effect <= -SESOI (need large t_lower)
  p_upper <- pnorm(t_upper)       # reject H02: effect >= +SESOI (need small t_upper)

  p_tost <- max(p_lower, p_upper)

  cat(sprintf("  %s: TOST p = %.4f %s\n",
      out$name, p_tost,
      ifelse(p_tost < 0.05, "(EQUIVALENT — reject |effect| >= 1pp)",
             "(Cannot reject |effect| >= 1pp)")))

  equiv_results[[out$var]] <- list(
    name = out$name,
    coef = r$coef_conv,
    se = r$se_robust,
    sesoi = sesoi,
    p_tost = p_tost,
    equivalent = p_tost < 0.05
  )
}

## ===========================================================
## Save all results
## ===========================================================

all_results <- list(
  labor = results_labor,
  political = results_political,
  spending = results_spending,
  entrepreneurship = results_entrep,
  fuzzy = results_fuzzy,
  validation_3500 = results_3500,
  placebo = results_placebo,
  heterogeneity = results_het,
  equivalence = equiv_results
)

saveRDS(all_results, "../data/rd_results_v2.rds")
# Also save labor results separately for backward compatibility
saveRDS(results_labor, "../data/rd_results.rds")

cat("\nMain analysis complete. All results saved.\n")
