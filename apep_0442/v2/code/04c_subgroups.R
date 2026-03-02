## ============================================================================
## 04c_subgroups.R — Powered subgroup RDD analysis
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## With expanded sample data, each subgroup has thousands of veterans,
## enabling meaningful heterogeneity analysis.
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))

cat("=== Subgroup RDD Analysis ===\n")
cat("Expanded sample enables powered subgroup estimates.\n\n")

## ---- 1. Define subgroups ----
subgroup_defs <- list(
  # Race
  "White" = expression(white == 1),
  "Non-white" = expression(white == 0),

  # Urbanicity
  "Urban" = expression(urban == 1),
  "Rural" = expression(urban == 0),

  # Literacy
  "Literate" = expression(literate == 1),
  "Illiterate" = expression(literate == 0),

  # Nativity
  "Native born" = expression(native_born == 1),
  "Foreign born" = expression(native_born == 0),

  # Region
  "Northeast" = expression(region == "Northeast"),
  "Midwest" = expression(region == "Midwest"),
  "South" = expression(region == "South"),
  "West" = expression(region == "West"),

  # Marital status
  "Married" = expression(married == 1),
  "Unmarried" = expression(married == 0),

  # Home ownership
  "Homeowner" = expression(owns_home == 1),
  "Non-homeowner" = expression(owns_home == 0),

  # Household status
  "Household head" = expression(is_head == 1),
  "Not head" = expression(is_head == 0)
)

## ---- 2. Run RDD for each subgroup ----
subgroup_results <- data.table(
  subgroup = character(),
  category = character(),
  n_total = integer(),
  n_below_62 = integer(),
  n_above_62 = integer(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  ci_lower = numeric(),
  ci_upper = numeric(),
  bw_left = numeric(),
  bw_right = numeric(),
  n_eff_left = numeric(),
  n_eff_right = numeric(),
  baseline_lfp = numeric()
)

# Assign categories for grouping in forest plot
subgroup_categories <- c(
  "White" = "Race", "Non-white" = "Race",
  "Urban" = "Urbanicity", "Rural" = "Urbanicity",
  "Literate" = "Literacy", "Illiterate" = "Literacy",
  "Native born" = "Nativity", "Foreign born" = "Nativity",
  "Northeast" = "Region", "Midwest" = "Region", "South" = "Region", "West" = "Region",
  "Married" = "Marital Status", "Unmarried" = "Marital Status",
  "Homeowner" = "Home Ownership", "Non-homeowner" = "Home Ownership",
  "Household head" = "Household Status", "Not head" = "Household Status"
)

for (sg_name in names(subgroup_defs)) {
  sg <- union[eval(subgroup_defs[[sg_name]])]

  if (nrow(sg) < 100) {
    cat(sprintf("  %-25s: Too few observations (%d)\n", sg_name, nrow(sg)))
    next
  }

  tryCatch({
    rd <- rdrobust(sg$in_labor_force, sg$AGE, c = 62,
                   kernel = "triangular", p = 1)

    bw <- rd$bws["h", "left"]
    baseline <- mean(sg$in_labor_force[sg$AGE >= (62 - bw) & sg$AGE < 62], na.rm = TRUE)

    subgroup_results <- rbind(subgroup_results, data.table(
      subgroup = sg_name,
      category = subgroup_categories[sg_name],
      n_total = nrow(sg),
      n_below_62 = sum(sg$AGE < 62),
      n_above_62 = sum(sg$AGE >= 62),
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      ci_lower = rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
      ci_upper = rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1],
      bw_left = rd$bws["h", "left"],
      bw_right = rd$bws["h", "right"],
      n_eff_left = rd$N_h[1],
      n_eff_right = rd$N_h[2],
      baseline_lfp = baseline
    ))

    cat(sprintf("  %-25s (N=%7s, N<62=%6s): coef = %7.4f (SE = %6.4f), p = %.3f\n",
                sg_name, format(nrow(sg), big.mark = ","),
                format(sum(sg$AGE < 62), big.mark = ","),
                rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  %-25s: ERROR - %s\n", sg_name, e$message))
  })
}

## ---- 3. Diff-in-disc for key subgroups ----
cat("\n=== Diff-in-Disc by Subgroup ===\n")

confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))

# Only for subgroups with enough Confederate veterans
key_subgroups <- c("White", "Rural", "Literate", "South", "Married")

did_subgroup <- data.table(
  subgroup = character(),
  tau_union = numeric(), se_union = numeric(),
  tau_confed = numeric(), se_confed = numeric(),
  tau_did = numeric(), se_did = numeric(), pvalue_did = numeric()
)

for (sg_name in key_subgroups) {
  sg_u <- union[eval(subgroup_defs[[sg_name]])]
  sg_c <- confed[eval(subgroup_defs[[sg_name]])]

  if (nrow(sg_c) < 50) {
    cat(sprintf("  %-25s: Too few Confederate veterans (%d)\n", sg_name, nrow(sg_c)))
    next
  }

  tryCatch({
    rd_u <- rdrobust(sg_u$in_labor_force, sg_u$AGE, c = 62,
                      kernel = "triangular", p = 1)
    rd_c <- rdrobust(sg_c$in_labor_force, sg_c$AGE, c = 62,
                      kernel = "triangular", p = 1)

    t_d <- rd_u$coef["Conventional", 1] - rd_c$coef["Conventional", 1]
    s_d <- sqrt(rd_u$se["Conventional", 1]^2 + rd_c$se["Conventional", 1]^2)
    p_d <- 2 * pnorm(-abs(t_d / s_d))

    did_subgroup <- rbind(did_subgroup, data.table(
      subgroup = sg_name,
      tau_union = rd_u$coef["Conventional", 1],
      se_union = rd_u$se["Conventional", 1],
      tau_confed = rd_c$coef["Conventional", 1],
      se_confed = rd_c$se["Conventional", 1],
      tau_did = t_d, se_did = s_d, pvalue_did = p_d
    ))
    cat(sprintf("  %-25s: DiD = %7.4f (SE = %6.4f), p = %.3f\n",
                sg_name, t_d, s_d, p_d))
  }, error = function(e) {
    cat(sprintf("  %-25s: ERROR\n", sg_name))
  })
}

## ---- 4. Save ----
saveRDS(subgroup_results, file.path(data_dir, "subgroup_results.rds"))
saveRDS(did_subgroup, file.path(data_dir, "did_subgroup_results.rds"))

cat("\nSubgroup analysis complete.\n")
cat("Subgroups estimated:", nrow(subgroup_results), "\n")
cat("Subgroups with SE < 0.05:", sum(subgroup_results$se < 0.05), "\n")
