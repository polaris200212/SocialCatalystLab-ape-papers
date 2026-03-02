## ============================================================
## 07_revision_robustness.R
## Additional robustness checks from referee revision:
##   1. 95% CIs for headline coefficients
##   2. Second-order exposure (neighbors-of-neighbors)
##   3. Specification without OwnPDMP
##   4. Common support period (2011-2019)
##   5. Drug-type suppression rates by exposure
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)
results <- readRDS(paste0(data_dir, "main_results.rds"))

## ============================================================
## 1. 95% CIs for headline coefficients
## ============================================================

cat("=== 95% CONFIDENCE INTERVALS ===\n\n")

# Main TWFE results
for (nm in c("twfe_total", "twfe_cont", "twfe_popw")) {
  mod <- results[[nm]]
  coef_name <- names(coef(mod))[1]
  b <- coef(mod)[coef_name]
  s <- se(mod)[coef_name]
  ci_lo <- b - 1.96 * s
  ci_hi <- b + 1.96 * s
  cat(sprintf("%s: β = %.3f [%.3f, %.3f]\n", nm, b, ci_lo, ci_hi))
}

# CS-DiD ATT
if (!is.null(results$cs_simple)) {
  att <- results$cs_simple$overall.att
  att_se <- results$cs_simple$overall.se
  cat(sprintf("CS-DiD ATT: %.3f [%.3f, %.3f]\n", att,
              att - 1.96 * att_se, att + 1.96 * att_se))
}

# Drug-type CIs
cat("\nDrug-type 95% CIs:\n")
for (drug in names(results$drug_results)) {
  mod <- results$drug_results[[drug]]
  b <- coef(mod)["high_exposure_50"]
  s <- se(mod)["high_exposure_50"]
  ci_lo <- b - 1.96 * s
  ci_hi <- b + 1.96 * s
  cat(sprintf("  %s: β = %.3f [%.3f, %.3f]\n", drug, b, ci_lo, ci_hi))
}

## ============================================================
## 2. Second-order exposure (neighbors-of-neighbors)
## ============================================================

cat("\n=== SECOND-ORDER EXPOSURE ===\n\n")

# Load adjacency data
adjacency <- read_csv(paste0(data_dir, "state_adjacency.csv"), show_col_types = FALSE)

# Build adjacency list
adj_list <- list()
for (i in 1:nrow(adjacency)) {
  s1 <- adjacency$state[i]
  s2 <- adjacency$neighbor[i]
  adj_list[[s1]] <- c(adj_list[[s1]], s2)
  adj_list[[s2]] <- c(adj_list[[s2]], s1)
}

# Pre-compute second-order neighbor sets for each state
second_order_neighbors <- list()
for (st in unique(panel$state_abbr)) {
  neighbors <- adj_list[[st]]
  if (is.null(neighbors) || length(neighbors) == 0) {
    second_order_neighbors[[st]] <- character(0)
    next
  }
  nn <- unique(unlist(lapply(neighbors, function(n) adj_list[[n]])))
  nn <- setdiff(nn, c(st, neighbors))
  second_order_neighbors[[st]] <- nn
}

# Compute second-order exposure for each state-year
# Create a lookup table: state × year → own_pdmp
pdmp_lookup <- panel %>% select(state_abbr, year, own_pdmp)

second_order_rows <- panel %>%
  select(state_abbr, year) %>%
  pmap_dbl(function(state_abbr, year) {
    nn <- second_order_neighbors[[state_abbr]]
    if (length(nn) == 0) return(NA_real_)
    nn_pdmp <- pdmp_lookup %>%
      filter(state_abbr %in% nn, year == !!year)
    if (nrow(nn_pdmp) == 0) return(NA_real_)
    mean(nn_pdmp$own_pdmp, na.rm = TRUE)
  })

panel$second_order_exposure <- second_order_rows

# TWFE with second-order exposure
twfe_second <- feols(
  total_overdose_rate ~ high_exposure_50 + second_order_exposure + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate),
                          !is.na(second_order_exposure)),
  cluster = ~state_abbr
)

cat("TWFE with second-order exposure:\n")
print(summary(twfe_second))
cat(sprintf("\nFirst-order β = %.3f (SE = %.3f)\n",
            coef(twfe_second)["high_exposure_50"],
            se(twfe_second)["high_exposure_50"]))
cat(sprintf("Second-order β = %.3f (SE = %.3f)\n",
            coef(twfe_second)["second_order_exposure"],
            se(twfe_second)["second_order_exposure"]))

## ============================================================
## 3. Specification without OwnPDMP
## ============================================================

cat("\n=== SPECIFICATION WITHOUT OwnPDMP ===\n\n")

twfe_no_own <- feols(
  total_overdose_rate ~ high_exposure_50 +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Without OwnPDMP control:\n")
b_no <- coef(twfe_no_own)["high_exposure_50"]
s_no <- se(twfe_no_own)["high_exposure_50"]
cat(sprintf("  β = %.3f (SE = %.3f) [%.3f, %.3f]\n",
            b_no, s_no, b_no - 1.96*s_no, b_no + 1.96*s_no))

cat("\nBaseline (with OwnPDMP):\n")
b_base <- coef(results$twfe_total)["high_exposure_50"]
s_base <- se(results$twfe_total)["high_exposure_50"]
cat(sprintf("  β = %.3f (SE = %.3f) [%.3f, %.3f]\n",
            b_base, s_base, b_base - 1.96*s_base, b_base + 1.96*s_base))

## ============================================================
## 4. Common Support Period (2011-2019)
## ============================================================

cat("\n=== COMMON SUPPORT PERIOD (2011-2019) ===\n\n")

twfe_pre2020 <- feols(
  total_overdose_rate ~ high_exposure_50 + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, year <= 2019, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Common support period (2011-2019):\n")
b_cs <- coef(twfe_pre2020)["high_exposure_50"]
s_cs <- se(twfe_pre2020)["high_exposure_50"]
cat(sprintf("  β = %.3f (SE = %.3f) [%.3f, %.3f]\n",
            b_cs, s_cs, b_cs - 1.96*s_cs, b_cs + 1.96*s_cs))
cat(sprintf("  N = %d\n", nobs(twfe_pre2020)))

## ============================================================
## 5. Drug-type suppression rates by exposure
## ============================================================

cat("\n=== DRUG-TYPE SUPPRESSION ANALYSIS ===\n\n")

# For each drug type, count suppressed obs (NA) by exposure status
drug_vars <- c("rx_opioids_rate", "heroin_rate", "synthetic_opioids_rate",
               "cocaine_rate", "psychostimulants_rate")

vsrr_panel <- panel %>% filter(year >= 2015)

for (drug in drug_vars) {
  total_obs <- nrow(vsrr_panel)
  missing <- sum(is.na(vsrr_panel[[drug]]))
  pct_missing <- 100 * missing / total_obs

  # By exposure status
  exposed <- vsrr_panel %>% filter(high_exposure_50 == 1)
  unexposed <- vsrr_panel %>% filter(high_exposure_50 == 0)

  miss_exp <- sum(is.na(exposed[[drug]]))
  miss_unexp <- sum(is.na(unexposed[[drug]]))
  pct_exp <- 100 * miss_exp / nrow(exposed)
  pct_unexp <- if (nrow(unexposed) > 0) 100 * miss_unexp / nrow(unexposed) else NA

  cat(sprintf("%s: %d/%d missing (%.1f%%) | Exposed: %.1f%% | Unexposed: %.1f%%\n",
              drug, missing, total_obs, pct_missing, pct_exp,
              ifelse(is.na(pct_unexp), 0, pct_unexp)))
}

## ============================================================
## 6. Save revision results
## ============================================================

cat("\nSaving revision robustness results...\n")

rev_results <- list(
  twfe_second = twfe_second,
  twfe_no_own = twfe_no_own,
  twfe_pre2020 = twfe_pre2020
)

saveRDS(rev_results, paste0(data_dir, "revision_results.rds"))

cat("\n==============================\n")
cat("Revision robustness checks complete.\n")
cat("==============================\n")
