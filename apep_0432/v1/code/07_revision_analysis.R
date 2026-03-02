## ============================================================
## 07_revision_analysis.R — Revision additions
## Male literacy, multiple testing, CIs, ST literacy RDD plot
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "analysis_panel.RData"))
load(file.path(data_dir, "main_results.RData"))

## ================================================================
## PART A: ADD MALE LITERACY OUTCOME
## ================================================================

cat("=== A: Constructing male literacy outcomes ===\n")

## Male literacy rate (analogous to female)
panel_rdd[, m_litrate_01 := fifelse(pc01_pca_tot_m > 0,
                                     pc01_pca_m_lit / pc01_pca_tot_m, NA_real_)]
panel_rdd[, m_litrate_11 := fifelse(pc11_pca_tot_m > 0,
                                     pc11_pca_m_lit / pc11_pca_tot_m, NA_real_)]
panel_rdd[, d_m_litrate := m_litrate_11 - m_litrate_01]

## Gender literacy gap
panel_rdd[, d_lit_gap := d_m_litrate - d_f_litrate]

## Also add to panel_bw
panel_bw[, m_litrate_01 := fifelse(pc01_pca_tot_m > 0,
                                    pc01_pca_m_lit / pc01_pca_tot_m, NA_real_)]
panel_bw[, m_litrate_11 := fifelse(pc11_pca_tot_m > 0,
                                    pc11_pca_m_lit / pc11_pca_tot_m, NA_real_)]
panel_bw[, d_m_litrate := m_litrate_11 - m_litrate_01]
panel_bw[, d_lit_gap := d_m_litrate - d_f_litrate]

cat(sprintf("Mean male literacy 2001: %.3f\n", mean(panel_bw$m_litrate_01, na.rm = TRUE)))
cat(sprintf("Mean male literacy 2011: %.3f\n", mean(panel_bw$m_litrate_11, na.rm = TRUE)))
cat(sprintf("Mean change male literacy: %.4f\n", mean(panel_bw$d_m_litrate, na.rm = TRUE)))
cat(sprintf("Mean change female literacy: %.4f\n", mean(panel_bw$d_f_litrate, na.rm = TRUE)))

## ================================================================
## PART B: POOLED RDD FOR MALE LITERACY
## ================================================================

cat("\n=== B: Pooled RDD — Male Literacy ===\n")

new_outcomes <- c("d_m_litrate", "d_lit_gap")
new_labels <- c("Chg Male Literacy", "Chg Literacy Gender Gap")

rdd_male_lit <- data.table(
  Outcome = new_labels,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
  BW = NA_real_, N_eff = NA_integer_,
  CI_lo = NA_real_, CI_hi = NA_real_
)

for (i in seq_along(new_outcomes)) {
  v <- new_outcomes[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    rdd_male_lit[i, `:=`(
      Coeff = rd_fit$coef["Conventional", ],
      SE    = rd_fit$se["Conventional", ],
      Pval  = rd_fit$pv["Conventional", ],
      BW    = rd_fit$bws["h", "left"],
      N_eff = rd_fit$N_h[1] + rd_fit$N_h[2],
      CI_lo = rd_fit$ci["Conventional", 1],
      CI_hi = rd_fit$ci["Conventional", 2]
    )]
  }
}
cat("\nPooled RDD — Male Literacy Results:\n")
print(rdd_male_lit)

## ================================================================
## PART C: HETEROGENEOUS RDD FOR MALE LITERACY BY CASTE
## ================================================================

cat("\n=== C: RDD Male Literacy by Caste ===\n")

caste_cats <- c("General/OBC-dominated", "SC-dominated", "ST-dominated")
hetero_male_lit <- list()

for (cc in caste_cats) {
  sub <- panel_rdd[caste_dominant == cc]
  cat(sprintf("\n--- %s (N = %s) ---\n", cc, formatC(nrow(sub), big.mark = ",")))

  res_cc <- data.table(
    Caste = cc,
    Outcome = new_labels,
    Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
    BW = NA_real_, N_eff = NA_integer_,
    CI_lo = NA_real_, CI_hi = NA_real_
  )

  for (i in seq_along(new_outcomes)) {
    v <- new_outcomes[i]
    yy <- sub[[v]]
    ok <- !is.na(yy) & !is.na(sub$pop01)
    if (sum(ok) < 100) next
    rd_fit <- tryCatch(
      rdrobust(y = yy[ok], x = sub$pop01[ok], c = 500, kernel = "triangular"),
      error = function(e) NULL
    )
    if (!is.null(rd_fit)) {
      res_cc[i, `:=`(
        Coeff = rd_fit$coef["Conventional", ],
        SE    = rd_fit$se["Conventional", ],
        Pval  = rd_fit$pv["Conventional", ],
        BW    = rd_fit$bws["h", "left"],
        N_eff = rd_fit$N_h[1] + rd_fit$N_h[2],
        CI_lo = rd_fit$ci["Conventional", 1],
        CI_hi = rd_fit$ci["Conventional", 2]
      )]
    }
  }
  print(res_cc[, .(Caste, Outcome, Coeff, SE, Pval)])
  hetero_male_lit[[cc]] <- res_cc
}

hetero_male_all <- rbindlist(hetero_male_lit)

## ================================================================
## PART D: 95% CIs FOR ALL MAIN RESULTS
## ================================================================

cat("\n=== D: Extracting 95% CIs for all main outcomes ===\n")

## Re-run pooled RDD with CI extraction
outcomes_all <- c("d_fwpr", "d_mwpr", "d_gender_gap",
                  "d_f_aglabor", "d_f_cultiv", "d_f_other",
                  "d_f_nonwork", "d_f_litrate", "d_csr",
                  "d_m_litrate", "d_lit_gap")
labels_all <- c("Chg Female WPR", "Chg Male WPR", "Chg Gender Gap",
                "Chg F Ag Labor", "Chg F Cultivator", "Chg F Other Work",
                "Chg F Non-Worker", "Chg F Literacy", "Chg Child Sex Ratio",
                "Chg Male Literacy", "Chg Literacy Gender Gap")

rdd_pooled_ci <- data.table(
  Outcome = labels_all,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
  BW = NA_real_, N_eff = NA_integer_,
  CI_lo = NA_real_, CI_hi = NA_real_
)

for (i in seq_along(outcomes_all)) {
  v <- outcomes_all[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    rdd_pooled_ci[i, `:=`(
      Coeff = rd_fit$coef["Conventional", ],
      SE    = rd_fit$se["Conventional", ],
      Pval  = rd_fit$pv["Conventional", ],
      BW    = rd_fit$bws["h", "left"],
      N_eff = rd_fit$N_h[1] + rd_fit$N_h[2],
      CI_lo = rd_fit$ci["Conventional", 1],
      CI_hi = rd_fit$ci["Conventional", 2]
    )]
  }
}

cat("\nPooled RDD with 95% CIs:\n")
print(rdd_pooled_ci)

## ================================================================
## PART E: MULTIPLE TESTING ADJUSTMENT (Benjamini-Hochberg)
## ================================================================

cat("\n=== E: Benjamini-Hochberg q-values ===\n")

## Family 1: Employment outcomes (indices 1-7)
emp_idx <- 1:7
emp_pvals <- rdd_pooled_ci$Pval[emp_idx]
emp_qvals <- p.adjust(emp_pvals, method = "BH")
rdd_pooled_ci[emp_idx, qval := emp_qvals]

## Family 2: Human capital outcomes (indices 8-11)
hc_idx <- 8:11
hc_pvals <- rdd_pooled_ci$Pval[hc_idx]
hc_qvals <- p.adjust(hc_pvals, method = "BH")
rdd_pooled_ci[hc_idx, qval := hc_qvals]

cat("\nWith BH q-values:\n")
print(rdd_pooled_ci[, .(Outcome, Coeff, Pval, qval)])

## Also do BH for heterogeneous (within each caste group)
for (cc in caste_cats) {
  sub_res <- hetero_all[Caste == cc]
  pvals <- sub_res$Pval
  qvals <- p.adjust(pvals, method = "BH")
  hetero_all[Caste == cc, qval := qvals]
}

cat("\nHeterogeneous RDD with BH q-values:\n")
print(hetero_all[, .(Caste, Outcome, Coeff, Pval, qval)])

## ================================================================
## PART F: PARAMETRIC RDD — Male Literacy Interactions
## ================================================================

cat("\n=== F: Parametric RDD — Male Literacy with Caste Interactions ===\n")

fit_m_litrate <- feols(d_m_litrate ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                         pop01_c500 + I(pop01_c500 * eligible_500) |
                         pc11_state_id,
                       data = panel_bw, cluster = ~pc11_district_id)

fit_lit_gap <- feols(d_lit_gap ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                       pop01_c500 + I(pop01_c500 * eligible_500) |
                       pc11_state_id,
                     data = panel_bw, cluster = ~pc11_district_id)

cat("\n--- Male Literacy ---\n")
print(summary(fit_m_litrate))
cat("\n--- Literacy Gender Gap ---\n")
print(summary(fit_lit_gap))

## ================================================================
## PART G: ST LITERACY RDD FIGURE
## ================================================================

cat("\n=== G: Creating ST Literacy RDD Figure ===\n")

sub_st <- panel_rdd[caste_dominant == "ST-dominated" & !is.na(d_f_litrate)]

## Create binned scatter
sub_st[, pop_bin := cut(pop01, breaks = seq(200, 800, by = 20), labels = FALSE)]
bin_means <- sub_st[, .(
  y = mean(d_f_litrate, na.rm = TRUE),
  x = mean(pop01, na.rm = TRUE),
  n = .N
), by = pop_bin][!is.na(pop_bin)]

## Fit local polynomials on each side
left_data <- sub_st[pop01 < 500 & pop01 >= 300]
right_data <- sub_st[pop01 >= 500 & pop01 <= 700]

fit_left <- lm(d_f_litrate ~ poly(pop01, 2), data = left_data)
fit_right <- lm(d_f_litrate ~ poly(pop01, 2), data = right_data)

## Prediction grids
x_left <- data.frame(pop01 = seq(300, 499, length.out = 100))
x_right <- data.frame(pop01 = seq(500, 700, length.out = 100))
x_left$pred <- predict(fit_left, x_left)
x_right$pred <- predict(fit_right, x_right)

p_st_lit <- ggplot() +
  geom_point(data = bin_means, aes(x = x, y = y),
             color = "#2ca25f", alpha = 0.7, size = 2) +
  geom_line(data = x_left, aes(x = pop01, y = pred),
            color = "#2ca25f", linewidth = 1) +
  geom_line(data = x_right, aes(x = pop01, y = pred),
            color = "#2ca25f", linewidth = 1) +
  geom_vline(xintercept = 500, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(x = "Census 2001 Population",
       y = "Change in Female Literacy Rate",
       title = "ST-Dominated Villages: Female Literacy at PMGSY Threshold") +
  theme_apep() +
  theme(plot.title = element_text(size = 11, face = "bold"))

ggsave(file.path(fig_dir, "fig_st_literacy_rdd.pdf"), p_st_lit,
       width = 7, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig_st_literacy_rdd.png"), p_st_lit,
       width = 7, height = 5, dpi = 300)
cat("ST literacy RDD figure saved.\n")

## ================================================================
## PART H: IDENTIFICATION VALIDITY COMBINED FIGURE
## ================================================================

cat("\n=== H: Combined Identification Figure (McCrary + Balance) ===\n")

## Panel A: McCrary density
mc_plot_data <- rddensity::rdplotdensity(mc_500, panel_rdd$pop01,
                                          plotRange = c(300, 700))

## Panel B: Balance coefficient plot
balance_plot_data <- balance_results[!is.na(Coeff)]
balance_plot_data[, sig := fifelse(Pval < 0.05, "p < 0.05", "p >= 0.05")]

p_balance <- ggplot(balance_plot_data, aes(x = Coeff, y = reorder(Variable, Coeff))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = Coeff - 1.96 * SE, xmax = Coeff + 1.96 * SE),
                 height = 0.2, color = "#636363") +
  geom_point(aes(color = sig), size = 3) +
  scale_color_manual(values = c("p < 0.05" = "red", "p >= 0.05" = "#2171b5")) +
  labs(x = "RDD Estimate", y = "", color = "") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig_balance_main.pdf"), p_balance,
       width = 7, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig_balance_main.png"), p_balance,
       width = 7, height = 5, dpi = 300)
cat("Balance figure saved.\n")

## ================================================================
## SAVE
## ================================================================

save(rdd_male_lit, hetero_male_all, rdd_pooled_ci, hetero_all,
     fit_m_litrate, fit_lit_gap,
     file = file.path(data_dir, "revision_results.RData"))
cat("\nAll revision results saved.\n")
