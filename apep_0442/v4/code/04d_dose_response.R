## ============================================================================
## 04d_dose_response.R — Pension amount dose-response analysis
## Project: The First Retirement Age v3
## Multi-cutoff at ages 62, 70, 75
## ============================================================================

source("code/00_packages.R")

cat("=== DOSE-RESPONSE ANALYSIS ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
cross[, age_1907 := 1907 - birth_year]

## =========================================================================
## 1. MULTI-CUTOFF RDD
## =========================================================================
cat("--- 1. MULTI-CUTOFF RDD ---\n")
## 1907 Act pension amounts by age:
## Age 62-69: $12/month
## Age 70-74: $15/month
## Age 75+:   $20/month

cutoffs <- data.table(
  age_cutoff = c(62, 70, 75),
  pension_amount = c(12, 15, 20),
  label = c("$12/mo (age 62)", "$15/mo (age 70)", "$20/mo (age 75)")
)

multi_results <- list()
for (i in 1:nrow(cutoffs)) {
  ac <- cutoffs$age_cutoff[i]
  cross[, running_tmp := age_1907 - ac]

  fit <- tryCatch(rdrobust(cross$lfp_1910, cross$running_tmp, c = 0),
                  error = function(e) NULL)
  if (!is.null(fit)) {
    ## Consistent p-value: conventional coef / robust SE
    dose_p <- 2 * pnorm(-abs(fit$coef[1] / fit$se[3]))
    multi_results[[as.character(ac)]] <- data.table(
      cutoff = ac, pension_amt = cutoffs$pension_amount[i],
      label = cutoffs$label[i],
      coef = fit$coef[1], se = fit$se[3], pval = dose_p,
      ci_lo = fit$coef[1] - 1.96 * fit$se[3],
      ci_hi = fit$coef[1] + 1.96 * fit$se[3],
      bw = fit$bws[1, 1],
      N_left = fit$N_h[1], N_right = fit$N_h[2])
    cat(sprintf("  %s: coef=%.4f, se=%.4f, p=%.3f, bw=%.1f\n",
                cutoffs$label[i], fit$coef[1], fit$se[3], dose_p, fit$bws[1, 1]))
  }
}
multi_dt <- rbindlist(multi_results)

## =========================================================================
## 2. CONTINUOUS DOSE-RESPONSE
## =========================================================================
cat("\n--- 2. CONTINUOUS DOSE-RESPONSE ---\n")
## Among those above 62, pension amount increases with age
## Test whether larger pension amounts produce larger LFP declines

above62 <- cross[age_1907 >= 62 & !is.na(pen_dollars_1910)]
cat("Veterans above 62:", nrow(above62), "\n")
cat("Correlation (pension $, LFP):", round(cor(above62$pen_dollars_1910, above62$lfp_1910), 3), "\n")

## OLS: LFP ~ pension amount (conditional on age)
ols_dose <- lm(lfp_1910 ~ pen_dollars_1910 + poly(age_1907, 2), data = above62)
cat("OLS coef (pen $ → LFP):", round(coef(ols_dose)["pen_dollars_1910"], 5), "\n")
cat("SE:", round(sqrt(vcovHC(ols_dose, "HC1")["pen_dollars_1910", "pen_dollars_1910"]), 5), "\n")

## =========================================================================
## 3. PENSION $ BY AGE CELL
## =========================================================================
cat("\n--- 3. PENSION $ BY AGE ---\n")
dose_by_age <- cross[age_1907 >= 55 & age_1907 <= 85,
                     .(mean_pen = mean(pen_dollars_1910, na.rm = TRUE),
                       mean_lfp = mean(lfp_1910, na.rm = TRUE),
                       pct_1907 = mean(under_1907_act, na.rm = TRUE),
                       N = .N),
                     by = age_1907][order(age_1907)]
print(dose_by_age[age_1907 >= 60 & age_1907 <= 80])

## =========================================================================
## SAVE
## =========================================================================
dose_results <- list(
  multi_cutoff = multi_dt,
  dose_by_age = dose_by_age
)
saveRDS(dose_results, file.path(data_dir, "dose_results.rds"))
cat("\n=== DOSE-RESPONSE COMPLETE ===\n")
