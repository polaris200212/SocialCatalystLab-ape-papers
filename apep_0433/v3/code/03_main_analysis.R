## ============================================================
## 03_main_analysis.R — RDD estimation (v3: expanded outcomes)
## Pre-specified outcome hierarchy + BPE facilities +
## executive pipeline + expanded spending
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
dir.create("../tables", showWarnings = FALSE)

cat("=== MAIN RDD ANALYSIS (v3) ===\n")
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

## v3: Female share distribution near cutoff
cat("\nFemale share distribution near cutoff (BW=300):\n")
sub300 <- df %>% filter(abs(pop_centered) <= 300)
cat("  Below: mean=", round(mean(sub300$female_share[sub300$above_threshold == 0]), 3),
    " sd=", round(sd(sub300$female_share[sub300$above_threshold == 0]), 3), "\n")
cat("  Above: mean=", round(mean(sub300$female_share[sub300$above_threshold == 1]), 3),
    " sd=", round(sd(sub300$female_share[sub300$above_threshold == 1]), 3), "\n")

## ===========================================================
## 2. PRIMARY OUTCOMES: Labor Market (Holm-corrected)
## ===========================================================

cat("\n--- PRIMARY OUTCOMES: Labor Market ---\n")

outcomes_primary <- list(
  list(name = "Female Employment Rate", var = "female_emp_rate"),
  list(name = "Female LFPR", var = "female_lfpr"),
  list(name = "Gender Employment Gap", var = "gender_emp_gap")
)

results_primary <- list()
for (out in outcomes_primary) {
  r <- run_rdd(df[[out$var]], df$pop_centered, out$name)
  if (!is.null(r)) results_primary[[out$var]] <- r
}

## ===========================================================
## 3. SECONDARY OUTCOMES
## ===========================================================

cat("\n--- SECONDARY OUTCOMES ---\n")

## 3a. Additional labor
outcomes_labor_secondary <- list(
  list(name = "Male Employment Rate", var = "male_emp_rate"),
  list(name = "Female Share of Employment", var = "female_share_employed"),
  list(name = "Total Employment Rate", var = "total_emp_rate"),
  list(name = "Unemployment Rate", var = "unemployment_rate")
)

results_labor_secondary <- list()
for (out in outcomes_labor_secondary) {
  r <- run_rdd(df[[out$var]], df$pop_centered, out$name)
  if (!is.null(r)) results_labor_secondary[[out$var]] <- r
}

## 3b. Executive pipeline (NEW v3)
cat("\n--- Executive Pipeline ---\n")

results_pipeline <- list()

r_mayor <- run_rdd(as.numeric(df$has_female_mayor), df$pop_centered,
                   "Female Mayor Probability")
if (!is.null(r_mayor)) results_pipeline[["female_mayor"]] <- r_mayor

if ("female_share_adjoints" %in% names(df)) {
  r_adj <- run_rdd(df$female_share_adjoints, df$pop_centered,
                   "Female Share of Adjoints")
  if (!is.null(r_adj)) results_pipeline[["female_share_adjoints"]] <- r_adj
}

if ("female_first_adjoint" %in% names(df)) {
  r_fa <- run_rdd(df$female_first_adjoint, df$pop_centered,
                  "Female First Adjoint")
  if (!is.null(r_fa)) results_pipeline[["female_first_adjoint"]] <- r_fa
}

if ("female_share_top3_adjoints" %in% names(df)) {
  r_t3 <- run_rdd(df$female_share_top3_adjoints, df$pop_centered,
                  "Female Share Top-3 Adjoints")
  if (!is.null(r_t3)) results_pipeline[["female_share_top3_adjoints"]] <- r_t3
}

## 3c. Spending composition (v3 expanded)
cat("\n--- Spending Composition ---\n")

results_spending <- list()

spending_outcomes <- list(
  list(name = "Social Spending PC", var = "spend_social_pc"),
  list(name = "Culture Spending PC", var = "spend_culture_pc"),
  list(name = "Sports Spending PC", var = "spend_sports_pc"),
  list(name = "Total Spending PC", var = "spend_total_pc"),
  list(name = "Spending HHI", var = "spend_hhi"),
  list(name = "Social Spending Share", var = "social_share")
)

for (out in spending_outcomes) {
  y <- df[[out$var]]
  if (sum(!is.na(y) & is.finite(y)) > 200) {
    q01 <- quantile(y, 0.01, na.rm = TRUE)
    q99 <- quantile(y, 0.99, na.rm = TRUE)
    y[y < q01] <- q01
    y[y > q99] <- q99
    r <- run_rdd(y, df$pop_centered, out$name)
    if (!is.null(r)) results_spending[[out$var]] <- r
  }
}

## 3d. Facility provision (NEW v3)
cat("\n--- Facility Provision (BPE) ---\n")

results_facilities <- list()

facility_outcomes <- list(
  list(name = "Childcare Facilities PC", var = "bpe_childcare_pc"),
  list(name = "Social Facilities PC", var = "bpe_social_pc"),
  list(name = "Sports Facilities PC", var = "bpe_sports_pc"),
  list(name = "Education Facilities PC", var = "bpe_education_pc"),
  list(name = "Total Facilities PC", var = "bpe_total_pc"),
  list(name = "Has Crèche", var = "has_creche")
)

for (out in facility_outcomes) {
  y <- df[[out$var]]
  if (sum(!is.na(y) & is.finite(y)) > 200) {
    r <- run_rdd(y, df$pop_centered, out$name)
    if (!is.null(r)) results_facilities[[out$var]] <- r
  } else {
    cat("  ", out$name, ": insufficient data\n")
  }
}

## ===========================================================
## 4. EXPLORATORY OUTCOMES
## ===========================================================

cat("\n--- EXPLORATORY OUTCOMES ---\n")

results_exploratory <- list()

if ("female_self_emp_share" %in% names(df)) {
  r <- run_rdd(df$female_self_emp_share, df$pop_centered,
               "Female Self-Employment Share")
  if (!is.null(r)) results_exploratory[["female_self_emp_share"]] <- r
}

r_ncouncil <- run_rdd(df$n_councillors, df$pop_centered,
                       "Number of Councillors")
if (!is.null(r_ncouncil)) results_exploratory[["n_councillors"]] <- r_ncouncil

if (any(!is.na(df$female_candidate_share))) {
  r_fcand <- run_rdd(df$female_candidate_share, df$pop_centered,
                     "Female Candidate Share")
  if (!is.null(r_fcand)) results_exploratory[["female_candidate_share"]] <- r_fcand

  r_ncand <- run_rdd(df$n_candidates, df$pop_centered,
                     "Total Candidates")
  if (!is.null(r_ncand)) results_exploratory[["n_candidates"]] <- r_ncand

  if ("n_lists" %in% names(df) && any(!is.na(df$n_lists))) {
    r_nlists <- run_rdd(df$n_lists, df$pop_centered,
                        "Number of Lists (PR Signature)")
    if (!is.null(r_nlists)) results_exploratory[["n_lists"]] <- r_nlists
  }
}

if ("spend_education_pc" %in% names(df)) {
  y <- df$spend_education_pc
  if (sum(!is.na(y) & is.finite(y)) > 200) {
    q01 <- quantile(y, 0.01, na.rm = TRUE)
    q99 <- quantile(y, 0.99, na.rm = TRUE)
    y[y < q01] <- q01
    y[y > q99] <- q99
    r <- run_rdd(y, df$pop_centered, "Education Spending PC")
    if (!is.null(r)) results_exploratory[["spend_education_pc"]] <- r
  }
}

## ===========================================================
## 5. Fuzzy RD-IV
## ===========================================================

cat("\n--- Fuzzy RD-IV Specification ---\n")

results_fuzzy <- list()

for (out in outcomes_primary) {
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
## 6. 3,500 Threshold Validation
## ===========================================================

cat("\n--- 3,500 Threshold Validation ---\n")

results_3500 <- list()
df_3500 <- df %>% filter(pop >= 2000 & pop <= 5000)
cat("  Communes in [2000, 5000]:", nrow(df_3500), "\n")

if (nrow(df_3500) > 200) {
  r_fs_3500 <- run_rdd(df_3500$female_share, df_3500$pop_centered_3500,
                        "Female Share (3500)")
  if (!is.null(r_fs_3500)) results_3500[["female_share"]] <- r_fs_3500

  for (out in outcomes_primary) {
    r <- run_rdd(df_3500[[out$var]], df_3500$pop_centered_3500,
                 paste0(out$name, " (3500)"))
    if (!is.null(r)) results_3500[[paste0(out$var, "_3500")]] <- r
  }

  r_mayor_3500 <- run_rdd(as.numeric(df_3500$has_female_mayor),
                           df_3500$pop_centered_3500, "Female Mayor (3500)")
  if (!is.null(r_mayor_3500)) results_3500[["female_mayor_3500"]] <- r_mayor_3500
}

## ===========================================================
## 7. Pre-treatment Placebo (2011 + 2016)
## ===========================================================

cat("\n--- Pre-treatment Placebo: 2011 + 2016 outcomes ---\n")

pre_vars <- c("female_emp_rate_2011", "female_lfpr_2011", "total_emp_rate_2011",
              "female_emp_rate_2016", "female_lfpr_2016", "total_emp_rate_2016")
results_placebo <- list()

for (v in pre_vars) {
  if (!v %in% names(df)) next
  r <- run_rdd(df[[v]], df$pop_centered, v)
  if (!is.null(r)) results_placebo[[v]] <- r
}

## ===========================================================
## 8. Heterogeneity: Urban vs Rural
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
## 9. Equivalence Testing (TOST)
## ===========================================================

cat("\n--- Equivalence Testing ---\n")
cat("SESOI = 1 percentage point (0.01)\n")

sesoi <- 0.01
equiv_results <- list()

for (out in outcomes_primary) {
  r <- results_primary[[out$var]]
  if (is.null(r)) next

  t_lower <- (r$coef_conv - (-sesoi)) / r$se_robust
  t_upper <- (r$coef_conv - sesoi) / r$se_robust

  p_lower <- 1 - pnorm(t_lower)
  p_upper <- pnorm(t_upper)
  p_tost <- max(p_lower, p_upper)

  cat(sprintf("  %s: TOST p = %.4f %s\n",
      out$name, p_tost,
      ifelse(p_tost < 0.05, "(EQUIVALENT)", "(Cannot reject)")))

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
## 10. Save all results (v3 structure)
## ===========================================================

results_labor <- c(results_primary, results_labor_secondary)

all_results <- list(
  primary = results_primary,
  labor = results_labor,
  pipeline = results_pipeline,
  spending = results_spending,
  facilities = results_facilities,
  exploratory = results_exploratory,
  fuzzy = results_fuzzy,
  validation_3500 = results_3500,
  placebo = results_placebo,
  heterogeneity = results_het,
  equivalence = equiv_results,
  # v2 compat keys
  political = results_pipeline,
  entrepreneurship = results_exploratory[c("female_self_emp_share")]
)

saveRDS(all_results, "../data/rd_results_v2.rds")
saveRDS(results_labor, "../data/rd_results.rds")

cat("\nMain analysis complete. All results saved.\n")
