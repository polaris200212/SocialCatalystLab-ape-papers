## 04_robustness.R — Robustness checks for main DDD results
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
out_tables <- "../tables"
dir.create(out_tables, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_post83.rds"))
df_whipped <- df[free_vote == 0]
df_whipped[, party_period := paste0(ppg, "_", elecper)]

cat("=== ROBUSTNESS CHECKS ===\n\n")

## ============================================================
## R1: Alternative party-line definitions
## ============================================================
cat("--- R1: Alternative party-line definitions ---\n")

## R1a: 90% supermajority threshold (strong party line only)
df_strong <- df_whipped[cohesion >= 0.90]
r1a <- feols(deviate_own ~ female * district + elecsafe_overall |
               party_period,
             data = df_strong, cluster = "id_de_parliament")
cat(sprintf("R1a: Strong party line (≥90%% cohesion), N=%s\n",
            format(nrow(df_strong), big.mark = ",")))
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r1a)["female:district"],
            se(r1a)["female:district"],
            coeftable(r1a)["female:district", 4]))

## R1b: Final passage votes only
df_final <- df_whipped[vote_finalpassage == 1]
r1b <- feols(deviate_own ~ female * district + elecsafe_overall |
               party_period,
             data = df_final, cluster = "id_de_parliament")
cat(sprintf("R1b: Final passage votes only, N=%s\n",
            format(nrow(df_final), big.mark = ",")))
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r1b)["female:district"],
            se(r1b)["female:district"],
            coeftable(r1b)["female:district", 4]))

## ============================================================
## R2: Free votes analysis (when party whip is removed)
## ============================================================
cat("\n--- R2: Free votes (conscience votes) ---\n")

df_free <- df[free_vote == 1 & !is.na(deviate_own)]
cat(sprintf("Free vote observations: %s\n",
            format(nrow(df_free), big.mark = ",")))

## In free votes, there's no party line, but we can still measure
## deviation from the party majority (informative about preferences)
r2 <- tryCatch(
  feols(deviate_own ~ female * district | ppg + elecper,
        data = df_free, cluster = "id_de_parliament"),
  error = function(e) NULL
)
if (!is.null(r2)) {
  cat(sprintf("  Female: %.4f (SE=%.4f, p=%.3f)\n",
              coef(r2)["female"], se(r2)["female"], coeftable(r2)["female", 4]))
  if ("female:district" %in% names(coef(r2))) {
    cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
                coef(r2)["female:district"],
                se(r2)["female:district"],
                coeftable(r2)["female:district", 4]))
  }
}

## ============================================================
## R3: RCV selection bias — drop opposition-initiated RCVs
## ============================================================
cat("\n--- R3: RCV selection bias ---\n")

## Opposition-requested RCVs
df_nooppo <- df_whipped[request_oppo == 0]
r3 <- feols(deviate_own ~ female * district + elecsafe_overall |
              party_period,
            data = df_nooppo, cluster = "id_de_parliament")
cat(sprintf("R3: Excluding opposition-initiated RCVs, N=%s\n",
            format(nrow(df_nooppo), big.mark = ",")))
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r3)["female:district"],
            se(r3)["female:district"],
            coeftable(r3)["female:district", 4]))

## ============================================================
## R4: Placebo outcome — absenteeism
## ============================================================
cat("\n--- R4: Placebo outcome (absenteeism) ---\n")

## vote_beh = 0 is absent — need the FULL panel (including absent obs)
panel_raw <- readRDS(file.path(data_dir, "panel_raw.rds"))
panel_raw <- panel_raw[!is.na(gender) & !is.na(mandate)]
panel_raw[, female := as.integer(gender == 0)]
panel_raw[, district := as.integer(mandate == 1)]
panel_raw[, party_period := paste0(ppg, "_", elecper)]
panel_raw[, absent := as.integer(vote_beh == 0)]
panel_raw <- panel_raw[free_vote == 0 & elecper >= 10]

r4 <- feols(absent ~ female * district + elecsafe_overall |
              party_period,
            data = panel_raw[!is.na(elecsafe_overall)],
            cluster = "id_de_parliament")
cat(sprintf("R4: Absenteeism as outcome, N=%s\n",
            format(nrow(panel_raw[!is.na(elecsafe_overall)]), big.mark = ",")))
cat(sprintf("  Female: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r4)["female"], se(r4)["female"], coeftable(r4)["female", 4]))
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r4)["female:district"],
            se(r4)["female:district"],
            coeftable(r4)["female:district", 4]))

## ============================================================
## R5: Close-race RDD for dual candidates
## ============================================================
cat("\n--- R5: Close-race RDD ---\n")

## Use dual candidates (those who ran in both district and list)
## Running variable = district vote closeness (closeness_district)
## Treatment = district mandate (won district)
## Need to look at how closeness is measured
df_dual <- df_whipped[dualcand == 1 & !is.na(closeness_district)]
cat(sprintf("Dual candidate observations: %s\n",
            format(nrow(df_dual), big.mark = ",")))
cat(sprintf("Unique dual-candidate MPs: %d\n",
            uniqueN(df_dual$id_de_parliament)))

## Collapse to MP-period level for RDD
mp_period <- df_dual[, .(
  rebellion_rate = mean(deviate_own),
  n_votes = .N,
  district = first(district),
  female = first(female),
  closeness = first(closeness_district),
  elecsafe = first(elecsafe_overall),
  party = first(ppg)
), by = .(id_de_parliament, elecper)]

cat(sprintf("MP-period observations for RDD: %d\n", nrow(mp_period)))
cat(sprintf("  Of which district winners: %d\n", sum(mp_period$district == 1)))
cat(sprintf("  Of which list entrants: %d\n", sum(mp_period$district == 0)))

## RDD: mandate type (district=1) as a function of closeness
## For dual candidates, closeness measures how close the district race was
## Higher closeness = closer race (less safe)
## Need to construct the proper running variable

## RD with rdrobust — rebellion rate as outcome, closeness as running variable
## Treatment: district mandate
if (sum(mp_period$district == 1) > 50 & sum(mp_period$district == 0) > 50) {
  ## First: verify the "first stage" — does closeness predict mandate type?
  cat("\nFirst stage: closeness → district mandate\n")
  fs <- lm(district ~ closeness, data = mp_period)
  cat(sprintf("  Coefficient: %.4f (p=%.3f)\n",
              coef(fs)["closeness"], summary(fs)$coefficients["closeness", 4]))

  ## RDD on rebellion rate
  ## Construct signed running variable: positive = won district, negative = lost
  ## closeness_district is the absolute vote share margin
  mp_period[, margin_signed := ifelse(district == 1, closeness, -closeness)]

  ## Filter to close races (within 20pp of threshold on either side)
  close_races <- mp_period[abs(margin_signed) < 0.20]
  cat(sprintf("\nClose races (margin < 20pp): %d MP-periods\n", nrow(close_races)))

  ## Run RDD with rdrobust
  if (nrow(close_races) > 100) {
    ## Nonparametric RDD via rdrobust using signed margin
    cat("Nonparametric RDD via rdrobust (close races):\n")
    rdd_np <- tryCatch(
      rdrobust(y = close_races$rebellion_rate,
               x = close_races$margin_signed,
               c = 0,
               kernel = "triangular",
               all = TRUE),
      error = function(e) {
        cat(sprintf("  rdrobust failed: %s\n", e$message))
        NULL
      }
    )
    if (!is.null(rdd_np)) {
      cat(sprintf("  RD Estimate (robust): %.4f\n", rdd_np$coef[1]))
      cat(sprintf("  SE (robust): %.4f\n", rdd_np$se[3]))
      cat(sprintf("  p-value (robust): %.3f\n", rdd_np$pv[3]))
      cat(sprintf("  Bandwidth (h): %.4f\n", rdd_np$bws[1, 1]))
      cat(sprintf("  N (left/right): %d / %d\n", rdd_np$N_h[1], rdd_np$N_h[2]))
    }

    ## Parametric RDD as supplement
    rdd_simple <- lm(rebellion_rate ~ district * closeness + female,
                     data = close_races)
    cat("\nParametric RDD supplement (close races):\n")
    cat(sprintf("  District: %.4f (SE=%.4f, p=%.3f)\n",
                coef(rdd_simple)["district"],
                summary(rdd_simple)$coefficients["district", 2],
                summary(rdd_simple)$coefficients["district", 4]))
    if ("district:closeness" %in% names(coef(rdd_simple))) {
      cat(sprintf("  District×Closeness: %.4f\n",
                  coef(rdd_simple)["district:closeness"]))
    }

    ## Bandwidth sensitivity
    cat("\nBandwidth sensitivity (parametric RDD):\n")
    for (bw in c(0.05, 0.10, 0.15, 0.20, 0.25)) {
      sub_bw <- mp_period[closeness < bw]
      if (nrow(sub_bw) > 50) {
        m_bw <- lm(rebellion_rate ~ district * closeness + female, data = sub_bw)
        cat(sprintf("  BW=%.2f (N=%d): District=%.4f (SE=%.4f, p=%.3f)\n",
                    bw, nrow(sub_bw),
                    coef(m_bw)["district"],
                    summary(m_bw)$coefficients["district", 2],
                    summary(m_bw)$coefficients["district", 4]))
      }
    }
  }

  ## Gender heterogeneity in RDD
  cat("\nRDD by gender (close races):\n")
  for (g in c(0, 1)) {
    sub <- close_races[female == g]
    if (nrow(sub) > 50) {
      m <- lm(rebellion_rate ~ district * closeness, data = sub)
      label <- ifelse(g == 1, "Female", "Male")
      cat(sprintf("  %s (N=%d): District=%.4f (SE=%.4f, p=%.3f)\n",
                  label, nrow(sub),
                  coef(m)["district"],
                  summary(m)$coefficients["district", 2],
                  summary(m)$coefficients["district", 4]))
    }
  }
} else {
  cat("Insufficient variation for RDD — too few in one group.\n")
}

## ============================================================
## R6: Randomization inference
## ============================================================
cat("\n--- R6: Randomization inference ---\n")

## Permute gender within party-period cells
set.seed(20260302)
n_perms <- 999
true_coef <- coef(feols(deviate_own ~ female * district | party_period,
                        data = df_whipped))["female:district"]

perm_coefs <- numeric(n_perms)
for (i in seq_len(n_perms)) {
  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))
  df_perm <- copy(df_whipped)
  ## Permute gender within party-period (preserving composition)
  df_perm[, female_perm := sample(female), by = party_period]
  m_perm <- feols(deviate_own ~ female_perm * district | party_period,
                  data = df_perm)
  perm_coefs[i] <- coef(m_perm)["female_perm:district"]
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(true_coef))
cat(sprintf("Randomization Inference p-value: %.3f\n", ri_pvalue))
cat(sprintf("  True coefficient: %.5f\n", true_coef))
cat(sprintf("  Permutation mean: %.5f\n", mean(perm_coefs)))
cat(sprintf("  Permutation SD: %.5f\n", sd(perm_coefs)))

## R6b: Randomization inference on preferred specification (with electoral safety)
cat("\n--- R6b: Randomization inference on preferred specification (with electoral safety) ---\n")

## Filter to sample matching Column 4 (non-missing elecsafe_overall)
df_whipped_pref <- df_whipped[!is.na(elecsafe_overall)]
cat(sprintf("  Preferred spec sample (non-missing elecsafe_overall): %s observations\n",
            format(nrow(df_whipped_pref), big.mark = ",")))

## Observed coefficient from the preferred specification
set.seed(20260303)
n_perms_pref <- 999
true_coef_pref <- coef(feols(deviate_own ~ female * district + elecsafe_overall | party_period,
                             data = df_whipped_pref))["female:district"]

perm_coefs_pref <- numeric(n_perms_pref)
for (i in seq_len(n_perms_pref)) {
  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms_pref))
  df_perm_pref <- copy(df_whipped_pref)
  ## Permute gender within party-period cells (preserving composition)
  df_perm_pref[, female_perm := sample(female), by = party_period]
  m_perm_pref <- feols(deviate_own ~ female_perm * district + elecsafe_overall | party_period,
                       data = df_perm_pref)
  perm_coefs_pref[i] <- coef(m_perm_pref)["female_perm:district"]
}

ri_pvalue_pref <- mean(abs(perm_coefs_pref) >= abs(true_coef_pref))
cat(sprintf("Randomization Inference p-value (preferred spec): %.3f\n", ri_pvalue_pref))
cat(sprintf("  True coefficient: %.5f\n", true_coef_pref))
cat(sprintf("  Permutation mean: %.5f\n", mean(perm_coefs_pref)))
cat(sprintf("  Permutation SD: %.5f\n", sd(perm_coefs_pref)))

cat(sprintf("\nRI Summary:\n"))
cat(sprintf("  R6  (uncontrolled spec): p = %.3f  (coef = %.5f)\n", ri_pvalue, true_coef))
cat(sprintf("  R6b (preferred spec):    p = %.3f  (coef = %.5f)\n", ri_pvalue_pref, true_coef_pref))

## ============================================================
## R7: Wild cluster bootstrap (party-level clustering)
## ============================================================
cat("\n--- R7: Alternative clustering ---\n")

## Cluster at party-period level (more conservative)
r7a <- feols(deviate_own ~ female * district + elecsafe_overall |
               party_period,
             data = df_whipped[!is.na(elecsafe_overall)],
             cluster = "party_period")
cat("R7a: Clustered at party-period level:\n")
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r7a)["female:district"],
            se(r7a)["female:district"],
            coeftable(r7a)["female:district", 4]))

## Two-way clustering: legislator + vote
r7b <- feols(deviate_own ~ female * district + elecsafe_overall |
               party_period,
             data = df_whipped[!is.na(elecsafe_overall)],
             cluster = c("id_de_parliament", "vote_id"))
cat("R7b: Two-way clustered (legislator + vote):\n")
cat(sprintf("  Female×District: %.4f (SE=%.4f, p=%.3f)\n",
            coef(r7b)["female:district"],
            se(r7b)["female:district"],
            coeftable(r7b)["female:district", 4]))

## ============================================================
## R8: MDE calculation
## ============================================================
cat("\n--- R8: Minimum Detectable Effect ---\n")

## SE of the female:district interaction from main model
se_fxd <- se(feols(deviate_own ~ female * district + elecsafe_overall |
                     party_period,
                   data = df_whipped[!is.na(elecsafe_overall)],
                   cluster = "id_de_parliament"))["female:district"]
mde <- 2.8 * se_fxd  # ~80% power at 5% significance
baseline <- mean(df_whipped$deviate_own, na.rm = TRUE)
cat(sprintf("  SE(Female×District): %.5f\n", se_fxd))
cat(sprintf("  MDE (80%% power, 5%% sig): %.4f (%.1f%% of baseline %.4f)\n",
            mde, mde / baseline * 100, baseline))

## ============================================================
## R9: Multiple testing correction (Holm)
## ============================================================
cat("\n--- R9: Multiple testing correction (policy domains) ---\n")

## Collect p-values from policy domain analysis
## Feminine, Masculine, Other domains
m_fem <- feols(deviate_own ~ female * district + elecsafe_overall |
                 party_period,
               data = df_whipped[feminine_policy == 1 & !is.na(elecsafe_overall)],
               cluster = "id_de_parliament")
m_masc <- feols(deviate_own ~ female * district + elecsafe_overall |
                  party_period,
                data = df_whipped[masculine_policy == 1 & !is.na(elecsafe_overall)],
                cluster = "id_de_parliament")
m_other <- feols(deviate_own ~ female * district + elecsafe_overall |
                   party_period,
                 data = df_whipped[feminine_policy == 0 & masculine_policy == 0 &
                                     !is.na(elecsafe_overall)],
                 cluster = "id_de_parliament")

pvals_raw <- c(
  Feminine = coeftable(m_fem)["female:district", 4],
  Masculine = coeftable(m_masc)["female:district", 4],
  Other = coeftable(m_other)["female:district", 4]
)
pvals_holm <- p.adjust(pvals_raw, method = "holm")
cat("Policy domain p-values (Female×District):\n")
cat(sprintf("  %-12s Raw: %.3f  Holm: %.3f\n",
            names(pvals_raw), pvals_raw, pvals_holm))

## ============================================================
## Save robustness results
## ============================================================

robustness <- list(
  r1a_strong = r1a, r1b_final = r1b,
  r2_free = r2,
  r3_nooppo = r3,
  r4_absent = r4,
  ri_pvalue = ri_pvalue,
  ri_pvalue_pref = ri_pvalue_pref,
  r7a_partyperiod = r7a, r7b_twoway = r7b,
  mde = mde, baseline = baseline,
  pvals_raw = pvals_raw, pvals_holm = pvals_holm
)
saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

## Summary table
sink(file.path(out_tables, "table_robustness.txt"))
cat("=== Robustness Summary ===\n\n")
cat("Specification                   | Female×District | SE      | p-value\n")
cat("-------------------------------------------------------------------\n")
specs <- list(
  list("Main (party-period FE)", r1a, "female:district"),
  list("Strong party line (≥90%)", r1a, "female:district"),
  list("Final passage only", r1b, "female:district"),
  list("Excl. opposition RCVs", r3, "female:district"),
  list("Two-way clustering", r7b, "female:district")
)
for (s in specs) {
  if (!is.null(s[[2]]) && s[[3]] %in% names(coef(s[[2]]))) {
    cat(sprintf("%-32s| %8.4f       | %7.4f | %5.3f\n",
                s[[1]], coef(s[[2]])[s[[3]]],
                se(s[[2]])[s[[3]]], coeftable(s[[2]])[s[[3]], 4]))
  }
}
cat(sprintf("\nRandomization Inference p-value (uncontrolled spec, R6):  %.3f\n", ri_pvalue))
cat(sprintf("Randomization Inference p-value (preferred spec, R6b):   %.3f\n", ri_pvalue_pref))
cat(sprintf("MDE (80%% power): %.4f (%.1f%% of baseline)\n", mde, mde/baseline*100))
sink()

cat("\nRobustness checks complete.\n")
