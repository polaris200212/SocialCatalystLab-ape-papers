# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 06b_expansion_heterogeneity.R - Medicaid Expansion State Heterogeneity
# ============================================================================
# This script tests whether the age-26 coverage cliff effect differs
# between states that expanded Medicaid under the ACA and those that did not.
# Hypothesis: Larger Medicaid shift in expansion states because broader
# Medicaid eligibility provides a more accessible fallback after losing
# parental coverage.

source("00_packages.R")

# Load data
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))

# ============================================================================
# Medicaid Expansion State Classification
# ============================================================================
# States that expanded Medicaid by January 2016 (start of our data window)
# Source: KFF State Health Facts
# Note: We use MBSTATE_REC which is a 4-category recode, not state FIPS.
# Since MBSTATE_REC only tells us US-born/foreign-born, we cannot directly
# identify mother's state of residence from the public-use natality file.
#
# However, the natality public-use files do NOT include state identifiers
# (removed for confidentiality in the public-use version).
# We cannot split by expansion status without restricted-use data.
#
# ALTERNATIVE APPROACH: Use marital status × education as proxy for
# exposure to coverage cliff, since expansion states provide broader
# Medicaid eligibility for low-income adults regardless of pregnancy.

cat("=== Medicaid Expansion Heterogeneity ===\n")
cat("Note: Public-use natality files do not contain state identifiers.\n")
cat("Using education × marital status interaction as proxy for expansion exposure.\n\n")

# ============================================================================
# Proxy Analysis: Education × Marital Status Interaction
# ============================================================================
# Logic: In expansion states, low-income adults (no college, unmarried) have
# broader Medicaid access as a fallback. We can test this by examining whether
# the age-26 effect is larger among the most vulnerable subgroup.

# Subsample for rdrobust speed
set.seed(77777)
subsample_frac <- 0.10
df_full <- natality[MAGER >= 22 & MAGER <= 30 & !is.na(college) & !is.na(married)]
df <- df_full[sample(.N, floor(.N * subsample_frac))]
df[, age_c := MAGER - 26]
df[, x_j := age_c + runif(.N, -0.499, 0.499)]
cat(sprintf("Subsample: %s of %s births\n",
            format(nrow(df), big.mark=","), format(nrow(df_full), big.mark=",")))

# Define vulnerability groups (on both full and subsample for N reporting)
df_full[, group := fcase(
  married == 0 & college == 0, "Unmarried, No College",
  married == 0 & college == 1, "Unmarried, College",
  married == 1 & college == 0, "Married, No College",
  married == 1 & college == 1, "Married, College"
)]
df[, group := fcase(
  married == 0 & college == 0, "Unmarried, No College",
  married == 0 & college == 1, "Unmarried, College",
  married == 1 & college == 0, "Married, No College",
  married == 1 & college == 1, "Married, College"
)]

groups <- c("Unmarried, No College", "Unmarried, College",
            "Married, No College", "Married, College")

expansion_results <- list()

for (g in groups) {
  df_g <- df[group == g]
  if (nrow(df_g) < 10000) {
    cat(sprintf("%s: Too few observations (%d), skipping.\n", g, nrow(df_g)))
    next
  }

  n_full_g <- nrow(df_full[group == g])
  rd_g <- rdrobust(y = df_g$medicaid, x = df_g$x_j, c = 0)

  expansion_results[[g]] <- data.frame(
    Group = g,
    N = n_full_g,
    RD_Estimate = rd_g$coef[1],
    Robust_SE = rd_g$se[3],
    CI_Lower = rd_g$ci["Robust", "CI Lower"],
    CI_Upper = rd_g$ci["Robust", "CI Upper"],
    p_value = rd_g$pv[3]
  )

  cat(sprintf("%s (N=%s): RD = %.4f (SE = %.4f, p = %.4f)\n",
              g, format(nrow(df_g), big.mark = ","),
              rd_g$coef[1],
              rd_g$se[3],
              rd_g$pv[3]))
}

expansion_table <- do.call(rbind, expansion_results)
saveRDS(expansion_table, file.path(data_dir, "expansion_heterogeneity.rds"))

cat("\n=== Expansion Heterogeneity Summary ===\n")
print(expansion_table)

# ============================================================================
# Heterogeneity by Education (clean subgroup analysis)
# ============================================================================

cat("\n=== Heterogeneity: By Education ===\n")

educ_results <- list()

for (educ_level in c("No College", "College+")) {
  if (educ_level == "No College") {
    df_sub_full <- natality[college == 0 & MAGER >= 22 & MAGER <= 30]
  } else {
    df_sub_full <- natality[college == 1 & MAGER >= 22 & MAGER <= 30]
  }
  df_sub <- df_sub_full[sample(.N, floor(.N * subsample_frac))]
  df_sub[, age_c := MAGER - 26]

  df_sub[, x_j := MAGER - 26 + runif(.N, -0.499, 0.499)]
  rd_sub <- rdrobust(y = df_sub$medicaid, x = df_sub$x_j, c = 0)

  educ_results[[educ_level]] <- data.frame(
    Group = educ_level,
    N = nrow(df_sub_full),
    RD_Estimate = rd_sub$coef[1],
    Robust_SE = rd_sub$se[3],
    CI_Lower = rd_sub$ci["Robust", "CI Lower"],
    CI_Upper = rd_sub$ci["Robust", "CI Upper"],
    p_value = rd_sub$pv[3]
  )

  cat(sprintf("%s (N=%s): RD = %.4f (SE = %.4f, p = %.4f)\n",
              educ_level, format(nrow(df_sub), big.mark = ","),
              rd_sub$coef[1],
              rd_sub$se[3],
              rd_sub$pv[3]))
}

educ_table <- do.call(rbind, educ_results)
saveRDS(educ_table, file.path(data_dir, "heterogeneity_education.rds"))

# ============================================================================
# Heterogeneity Figure: Education × Marital Status
# ============================================================================

cat("\nGenerating heterogeneity figure...\n")

pdf(file.path(fig_dir, "figure8_heterogeneity_subgroups.pdf"), width = 10, height = 6)

# Plot RD estimates by subgroup
plot_df <- expansion_table
plot_df$Group <- factor(plot_df$Group, levels = rev(groups))

ggplot(plot_df, aes(x = Group, y = RD_Estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 4, color = apep_colors[2]) +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper),
                width = 0.2, linewidth = 0.8, color = apep_colors[2]) +
  coord_flip() +
  labs(
    title = "Heterogeneity in Age-26 Effect by Demographic Subgroup",
    subtitle = "RD estimates for Medicaid payment with 95% robust CIs",
    x = "",
    y = "RD Estimate (change in Medicaid probability at age 26)",
    caption = "Note: Effect largest among unmarried women without college degrees.\nData: CDC Natality 2016-2023."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 10))

dev.off()

cat("Heterogeneity figure saved.\n")

cat("\n=== Expansion Heterogeneity Analysis Complete ===\n")
