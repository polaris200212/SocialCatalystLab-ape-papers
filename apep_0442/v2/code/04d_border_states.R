## ============================================================================
## 04d_border_states.R — Geographic RDD: Border State Analysis
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## Border states (KY, MO, MD, WV, DE) have BOTH Union and Confederate
## veterans living in the SAME local labor markets. This eliminates
## geographic confounds — Union and Confederate veterans face identical
## local economic conditions. The diff-in-disc in border states is the
## cleanest specification in the paper.
## ============================================================================

source("code/00_packages.R")

all_data <- readRDS(file.path(data_dir, "census_1910_veterans.rds"))

# Border states: KY=21, MO=29, MD=24, WV=54, DE=10
border_fips <- c(21, 29, 24, 54, 10)
border_names <- c("21" = "Kentucky", "29" = "Missouri", "24" = "Maryland",
                   "54" = "West Virginia", "10" = "Delaware")

border <- all_data[STATEFIP %in% border_fips & any_veteran == 1]
cat("=== Border State Geographic RDD ===\n")
cat("Border states: KY, MO, MD, WV, DE\n")
cat("Total veterans in border states:", format(nrow(border), big.mark = ","), "\n")

border_union <- border[union_veteran == 1]
border_confed <- border[confed_veteran == 1]

cat("  Union veterans:", format(nrow(border_union), big.mark = ","), "\n")
cat("  Confederate veterans:", format(nrow(border_confed), big.mark = ","), "\n")
cat("  Union below 62:", format(sum(border_union$AGE < 62), big.mark = ","), "\n")
cat("  Confederate below 62:", format(sum(border_confed$AGE < 62), big.mark = ","), "\n")

border_results <- list()

## ---- 1. Separate RDD in border states ----
cat("\n--- Separate RDD Estimates (Border States) ---\n")

tryCatch({
  rd_bu <- rdrobust(border_union$in_labor_force, border_union$AGE, c = 62,
                     kernel = "triangular", p = 1)
  border_results$union_rdd <- rd_bu
  cat("  Union (border):", round(rd_bu$coef["Conventional", 1], 4),
      "(SE:", round(rd_bu$se["Conventional", 1], 4),
      "), N:", rd_bu$N_h[1], "+", rd_bu$N_h[2], "\n")
}, error = function(e) cat("  Union border RDD: ERROR\n"))

tryCatch({
  rd_bc <- rdrobust(border_confed$in_labor_force, border_confed$AGE, c = 62,
                     kernel = "triangular", p = 1)
  border_results$confed_rdd <- rd_bc
  cat("  Confederate (border):", round(rd_bc$coef["Conventional", 1], 4),
      "(SE:", round(rd_bc$se["Conventional", 1], 4),
      "), N:", rd_bc$N_h[1], "+", rd_bc$N_h[2], "\n")
}, error = function(e) cat("  Confederate border RDD: ERROR\n"))

## ---- 2. Diff-in-disc in border states ----
cat("\n--- Diff-in-Disc (Border States Only) ---\n")

if (!is.null(border_results$union_rdd) && !is.null(border_results$confed_rdd)) {
  tau_u <- border_results$union_rdd$coef["Conventional", 1]
  se_u <- border_results$union_rdd$se["Conventional", 1]
  tau_c <- border_results$confed_rdd$coef["Conventional", 1]
  se_c <- border_results$confed_rdd$se["Conventional", 1]

  tau_d <- tau_u - tau_c
  se_d <- sqrt(se_u^2 + se_c^2)
  p_d <- 2 * pnorm(-abs(tau_d / se_d))

  border_results$diff_in_disc <- list(
    tau_union = tau_u, se_union = se_u,
    tau_confed = tau_c, se_confed = se_c,
    tau_did = tau_d, se_did = se_d, pvalue = p_d
  )

  cat("  Border DiD:", round(tau_d, 4), "(SE:", round(se_d, 4),
      "), p =", round(p_d, 4), "\n")
  cat("  95% CI: [", round(tau_d - 1.96 * se_d, 4), ",",
      round(tau_d + 1.96 * se_d, 4), "]\n")
}

## ---- 3. State-by-state estimates ----
cat("\n--- State-by-State Estimates ---\n")

state_results <- data.table(
  state = character(), fips = integer(),
  n_union = integer(), n_confed = integer(),
  tau_union = numeric(), se_union = numeric(),
  tau_confed = numeric(), se_confed = numeric(),
  tau_did = numeric(), se_did = numeric()
)

for (fips in border_fips) {
  state_name <- border_names[as.character(fips)]
  u <- border_union[STATEFIP == fips]
  c <- border_confed[STATEFIP == fips]

  cat(sprintf("  %s: %d Union, %d Confederate\n", state_name, nrow(u), nrow(c)))

  t_u <- NA; s_u <- NA; t_c <- NA; s_c <- NA

  if (nrow(u) >= 50 && sum(u$AGE < 62) >= 10) {
    tryCatch({
      rd <- rdrobust(u$in_labor_force, u$AGE, c = 62, kernel = "triangular", p = 1)
      t_u <- rd$coef["Conventional", 1]
      s_u <- rd$se["Conventional", 1]
    }, error = function(e) {})
  }

  if (nrow(c) >= 50 && sum(c$AGE < 62) >= 10) {
    tryCatch({
      rd <- rdrobust(c$in_labor_force, c$AGE, c = 62, kernel = "triangular", p = 1)
      t_c <- rd$coef["Conventional", 1]
      s_c <- rd$se["Conventional", 1]
    }, error = function(e) {})
  }

  t_d <- if (!is.na(t_u) && !is.na(t_c)) t_u - t_c else NA
  s_d <- if (!is.na(s_u) && !is.na(s_c)) sqrt(s_u^2 + s_c^2) else NA

  state_results <- rbind(state_results, data.table(
    state = state_name, fips = fips,
    n_union = nrow(u), n_confed = nrow(c),
    tau_union = t_u, se_union = s_u,
    tau_confed = t_c, se_confed = s_c,
    tau_did = t_d, se_did = s_d
  ))
}

print(state_results)
border_results$by_state <- state_results

## ---- 4. County-level analysis (if COUNTYICP available) ----
if ("COUNTYICP" %in% names(border)) {
  cat("\n--- County-Level Fixed Effects (Border States) ---\n")

  # Parametric regression with county FEs
  border[, age_c := AGE - 62]
  border[, above := as.integer(AGE >= 62)]

  # Within optimal bandwidth
  h <- 8  # Conservative bandwidth for parametric
  border_bw <- border[AGE >= (62 - h) & AGE <= (62 + h)]

  tryCatch({
    # County FE diff-in-disc
    reg_county <- feols(in_labor_force ~ union_veteran * above * age_c | COUNTYICP,
                         data = border_bw)
    cat("  County FE diff-in-disc (Union × Above62):",
        round(coef(reg_county)["union_veteran:above"], 4),
        "(SE:", round(se(reg_county)["union_veteran:above"], 4), ")\n")
    border_results$county_fe <- reg_county
  }, error = function(e) {
    cat("  County FE regression: ERROR -", e$message, "\n")
  })
}

## ---- 5. Save ----
saveRDS(border_results, file.path(data_dir, "border_results.rds"))

rm(all_data, border)
gc()

cat("\nBorder state analysis complete.\n")
