## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")

## ============================================================================
## 1. Descriptive statistics
## ============================================================================

cat("=== Summary Statistics ===\n")

# Baseline (1994-1999) means by treatment group
baseline <- panel_dmsp[year <= 1999, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  mean_log_nl = mean(log_nl, na.rm = TRUE),
  sd_nl = sd(nightlights, na.rm = TRUE),
  n_districts = uniqueN(dist_id)
), by = .(treated)]

print(baseline)

# By state pair
by_pair <- panel_dmsp[year <= 1999, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  n_districts = uniqueN(dist_id)
), by = .(state_pair, treated)]

cat("\nBaseline nightlights by state pair:\n")
print(by_pair[order(state_pair, treated)])

## ============================================================================
## 2. TWFE (benchmark — known to be biased with staggered treatment)
## ============================================================================

cat("\n=== TWFE Estimation (2000 cohort only, DMSP 1994-2013) ===\n")

# Restrict to 2000 cohort only
panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

# Basic TWFE
twfe_basic <- feols(log_nl ~ treat_post | did + year,
                     data = panel_2000,
                     cluster = ~cluster_state)
cat("TWFE basic:\n")
print(summary(twfe_basic))

# TWFE with state-pair × year FE (absorb common shocks within pairs)
panel_2000[, pair_year := paste0(state_pair, "_", year)]
twfe_pair <- feols(log_nl ~ treat_post | did + pair_year,
                    data = panel_2000,
                    cluster = ~cluster_state)
cat("\nTWFE with pair×year FE:\n")
print(summary(twfe_pair))

## ============================================================================
## 3. Event study (TWFE)
## ============================================================================

cat("\n=== Event Study ===\n")

# Create event time
panel_2000[, event_time := year - 2001L]

# Event study with fixest::i()
es_twfe <- feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
                  data = panel_2000,
                  cluster = ~cluster_state)

cat("Event study coefficients:\n")
print(coeftable(es_twfe))

# Save event study coefficients for plotting
es_coefs <- as.data.table(coeftable(es_twfe), keep.rownames = TRUE)
setnames(es_coefs, c("term", "estimate", "se", "tstat", "pvalue"))
es_coefs[, event_time := as.integer(gsub("event_time::", "", gsub(":treated", "", term)))]
es_coefs <- es_coefs[!is.na(event_time)]

save(es_coefs, file = "../data/es_coefs.RData")

## ============================================================================
## 4. Callaway-Sant'Anna (heterogeneity-robust)
## ============================================================================

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# Prepare data for CS-DiD
# Need: panel with idname, tname, yname, gname
cs_data <- panel_dmsp[in_sample == 1L, .(
  id = did, year, log_nl, first_treat,
  cluster_state, treated, state_pair
)]

# Never-treated = control (first_treat == 0)
# Ensure balanced panel: keep only districts present in all years
year_counts <- cs_data[, .N, by = id]
balanced_ids <- year_counts[N == uniqueN(cs_data$year), id]
cs_balanced <- cs_data[id %in% balanced_ids]
cat("Balanced panel:", uniqueN(cs_balanced$id), "districts,",
    uniqueN(cs_balanced$year), "years\n")

cs_out <- tryCatch({
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = cs_balanced,
    control_group = "nevertreated",
    base_period = "universal",
    clustervars = "cluster_state",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("CS-DiD error:", conditionMessage(e), "\n")
  # Try with panel = FALSE for unbalanced
  att_gt(
    yname = "log_nl",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = cs_data,
    control_group = "nevertreated",
    base_period = "universal",
    clustervars = "cluster_state",
    panel = FALSE,
    bstrap = TRUE,
    biters = 1000
  )
})

cat("CS-DiD group-time ATTs:\n")
print(summary(cs_out))

# Aggregate: simple ATT
cs_att <- aggte(cs_out, type = "simple")
cat("\nCS-DiD aggregate ATT:\n")
print(summary(cs_att))

# Aggregate: event study (dynamic)
cs_es <- aggte(cs_out, type = "dynamic")
cat("\nCS-DiD event study:\n")
print(summary(cs_es))

# Save CS results
save(cs_out, cs_att, cs_es, file = "../data/cs_results.RData")

## ============================================================================
## 5. Sun-Abraham estimator (via fixest)
## ============================================================================

cat("\n=== Sun-Abraham Estimation ===\n")

# Sun-Abraham via sunab()
# Use the full panel data (not cs_balanced which may be empty)
sa_data <- panel_dmsp[in_sample == 1L]
sa_out <- feols(log_nl ~ sunab(first_treat, year) | did + year,
                 data = sa_data,
                 cluster = ~cluster_state)

cat("Sun-Abraham:\n")
print(summary(sa_out))

save(sa_out, file = "../data/sa_results.RData")

## ============================================================================
## 6. By-pair heterogeneity
## ============================================================================

cat("\n=== Heterogeneity by State Pair ===\n")

pair_results <- list()
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair == pair]
  fit <- feols(log_nl ~ treat_post | did + year,
               data = sub, cluster = ~cluster_state)
  pair_results[[pair]] <- fit
  cat(pair, ": coef =", coef(fit)["treat_post"],
      ", se =", se(fit)["treat_post"], "\n")
}

## ============================================================================
## 7. Capital city effects
## ============================================================================

cat("\n=== Capital vs Non-Capital Districts ===\n")

# Interact treatment with capital indicator
panel_2000[, capital_treat := is_capital * post_2000]
panel_2000[, noncapital_treat := (treated - is_capital) * post_2000]
# But we want: capital × post, noncapital_treated × post
panel_2000[, capital_post := is_capital * post_2000]
panel_2000[, treated_noncap := fifelse(treated == 1L & is_capital == 0L, 1L, 0L)]
panel_2000[, treated_noncap_post := treated_noncap * post_2000]

capital_het <- feols(log_nl ~ capital_post + treated_noncap_post | did + year,
                      data = panel_2000, cluster = ~cluster_state)
cat("Capital city heterogeneity:\n")
print(summary(capital_het))

## ============================================================================
## 8. Wild cluster bootstrap (corrected: proper restricted residuals)
## ============================================================================

cat("\n=== Wild Cluster Bootstrap (Corrected Implementation) ===\n")

# Manual wild cluster bootstrap (Cameron, Gelbach, Miller 2008)
# Key fix: restricted model imposes H0: beta_treat_post = 0
# by regressing y on FE only (no treat_post), then forming residuals under H0
wild_cluster_bootstrap <- function(model, data, cluster_var, param, n_boot = 999) {
  clusters <- unique(data[[cluster_var]])
  G <- length(clusters)

  # Step 1: Restricted model (impose null: beta = 0)
  restricted <- feols(log_nl ~ 1 | did + year, data = data,
                       cluster = as.formula(paste0("~", cluster_var)))
  fitted_r <- fitted(restricted)
  resid_r <- residuals(restricted)

  # Step 2: Original (unrestricted) t-statistic
  orig_coef <- coef(model)[param]
  orig_se <- se(model)[param]
  orig_t <- orig_coef / orig_se

  # Step 3: With 6 clusters, enumerate all 2^6 = 64 Rademacher combinations
  if (G <= 8) {
    all_signs <- as.matrix(expand.grid(replicate(G, c(-1, 1), simplify = FALSE)))
    n_boot <- nrow(all_signs)
    cat("  Enumerating all", n_boot, "Rademacher sign combinations (G =", G, ")\n")
  } else {
    all_signs <- matrix(sample(c(-1, 1), G * n_boot, replace = TRUE),
                        nrow = n_boot, ncol = G)
  }

  boot_t <- numeric(n_boot)
  boot_data <- copy(data)

  for (b in 1:n_boot) {
    weights <- all_signs[b, ]
    names(weights) <- clusters
    # Bootstrap DGP under H0: y* = fitted_r + w_g * resid_r
    boot_data[, boot_y := fitted_r + resid_r * weights[as.character(get(cluster_var))]]

    boot_fit <- tryCatch({
      feols(boot_y ~ treat_post | did + year, data = boot_data,
            cluster = as.formula(paste0("~", cluster_var)))
    }, error = function(e) NULL)

    if (!is.null(boot_fit)) {
      boot_t[b] <- coef(boot_fit)[param] / se(boot_fit)[param]
    } else {
      boot_t[b] <- NA
    }
  }

  p_val <- mean(abs(boot_t) >= abs(orig_t), na.rm = TRUE)
  list(p_val = p_val, orig_t = orig_t, boot_t = boot_t[!is.na(boot_t)],
       n_boot = n_boot)
}

boot_result <- tryCatch({
  wild_cluster_bootstrap(twfe_basic, panel_2000, "cluster_state", "treat_post")
}, error = function(e) {
  cat("Bootstrap error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(boot_result)) {
  cat("Wild bootstrap p-value:", boot_result$p_val, "\n")
  cat("Original t-stat:", boot_result$orig_t, "\n")
  cat("Number of bootstrap replications:", boot_result$n_boot, "\n")
}

## ============================================================================
## 9. Distance-to-capital mechanism
## ============================================================================

cat("\n=== Distance-to-Capital Mechanism ===\n")

# Capital city coordinates (approximate lat/lon)
# Dehradun: 30.3165, 78.0322
# Ranchi: 23.3441, 85.3096
# Raipur: 21.2514, 81.6296
# Lucknow (UP parent capital): 26.8467, 80.9462
# Patna (Bihar parent capital): 25.6093, 85.1376
# Bhopal (MP parent capital): 23.2599, 77.4126

capital_coords <- data.table(
  state_pair = c("UK-UP", "UK-UP", "JH-BR", "JH-BR", "CG-MP", "CG-MP"),
  cap_type = c("new", "parent", "new", "parent", "new", "parent"),
  cap_name = c("Dehradun", "Lucknow", "Ranchi", "Patna", "Raipur", "Bhopal"),
  lat = c(30.3165, 26.8467, 23.3441, 25.6093, 21.2514, 23.2599),
  lon = c(78.0322, 80.9462, 85.3096, 85.1376, 81.6296, 77.4126)
)

# We'll use the GADM district centroids to compute distance to capitals
# For now, use a proxy: create a continuous distance variable based on
# the district's position relative to the new capital
# This requires GADM data — will be computed after 07_border_analysis.R runs
# For now, test the capital × non-capital heterogeneity with finer decomposition

# State-pair fixed effects version of capital heterogeneity
panel_2000[, pair_fe := as.integer(factor(state_pair))]
capital_het_pair <- feols(log_nl ~ capital_post + treated_noncap_post | did + pair_year,
                           data = panel_2000, cluster = ~cluster_state)
cat("Capital heterogeneity with pair×year FE:\n")
print(summary(capital_het_pair))

## ============================================================================
## 10. Census mechanism variables (cross-sectional DiD, 2001 vs 2011)
## ============================================================================

cat("\n=== Census Mechanism Analysis ===\n")

# Load Census 2001 data for cross-sectional comparison
shrug_dir <- "../../../../data/india_shrug"
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_pc01dist.csv"))
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))

# For mechanism analysis, compute changes 2001→2011 for treatment districts
# Census 2011 variables
census11 <- pca11[, .(
  pc11_state_id, pc11_district_id,
  pop_11 = pc11_pca_tot_p,
  lit_rate_11 = pc11_pca_p_lit / pc11_pca_tot_p,
  worker_rate_11 = pc11_pca_tot_work_p / pc11_pca_tot_p,
  ag_share_11 = (pc11_pca_main_cl_p + pc11_pca_main_al_p) / pc11_pca_tot_work_p,
  nonag_share_11 = (pc11_pca_main_hh_p + pc11_pca_main_ot_p) / pc11_pca_tot_work_p
)]
census11[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Census 2001 — uses pc01 district IDs, need to map via state
# SHRUG harmonizes boundaries, so we can use state-level aggregation
# For a simpler approach: aggregate to state level and test treatment effect
census11_states <- census11[pc11_state_id %in% c(5L, 9L, 10L, 20L, 22L, 23L)]
census11_states[, treated := fifelse(pc11_state_id %in% c(5L, 20L, 22L), 1L, 0L)]

# Cross-sectional comparison of 2011 outcomes
mech_vars <- c("lit_rate_11", "worker_rate_11", "ag_share_11", "nonag_share_11")
cat("2011 Census outcomes by treatment status:\n")
mechanism_results <- list()
for (mv in mech_vars) {
  tt <- t.test(census11_states[[mv]][census11_states$treated == 1],
               census11_states[[mv]][census11_states$treated == 0])
  mechanism_results[[mv]] <- list(
    treated_mean = mean(census11_states[[mv]][census11_states$treated == 1], na.rm = TRUE),
    control_mean = mean(census11_states[[mv]][census11_states$treated == 0], na.rm = TRUE),
    diff = tt$estimate[1] - tt$estimate[2],
    pval = tt$p.value
  )
  cat("  ", mv, ": treated =", round(mechanism_results[[mv]]$treated_mean, 4),
      ", control =", round(mechanism_results[[mv]]$control_mean, 4),
      ", diff =", round(mechanism_results[[mv]]$diff, 4),
      ", p =", round(mechanism_results[[mv]]$pval, 3), "\n")
}

## ============================================================================
## 11. Save all results
## ============================================================================

save(twfe_basic, twfe_pair, es_twfe, pair_results, capital_het,
     capital_het_pair, boot_result, panel_2000, mechanism_results,
     file = "../data/main_results.RData")

cat("\n=== Main analysis complete ===\n")
