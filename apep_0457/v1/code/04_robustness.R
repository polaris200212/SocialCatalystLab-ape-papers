##############################################################################
# 04_robustness.R — Robustness Checks
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")

load(file.path(data_dir, "main_results.RData"))
cat("Panel loaded:", nrow(panel), "rows\n")

# ══════════════════════════════════════════════════════════════════════════════
# 1. BACON DECOMPOSITION (identify problematic 2×2 comparisons)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Bacon Decomposition ===\n")

# Prepare data for bacondecomp (needs balanced panel)
bacon_data <- panel %>%
  select(gem_no, year, treated, post, log_emp_total) %>%
  filter(!is.na(log_emp_total), is.finite(log_emp_total)) %>%
  # Ensure balanced
  group_by(gem_no) %>%
  filter(n() == max(panel$year) - min(panel$year) + 1) %>%
  ungroup()

bacon_result <- tryCatch({
  library(bacondecomp)
  bacon(log_emp_total ~ treat_post,
        data = bacon_data %>% mutate(treat_post = treated * post),
        id_var = "gem_no", time_var = "year")
}, error = function(e) {
  cat("Bacon decomposition error:", e$message, "\n")
  NULL
})

if (!is.null(bacon_result)) {
  cat("Bacon decomposition components:\n")
  print(bacon_result)
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. RANDOMIZATION INFERENCE
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Randomization Inference ===\n")

# Observed treatment effect
obs_effect <- coef(main_models$total)["treat_post"]
cat("Observed ATT:", obs_effect, "\n")

# Permute treatment assignment 1000 times
set.seed(42)
n_perms <- 1000
muni_ids <- unique(panel$gem_no)
n_treated <- sum(panel$treated == 1 & panel$year == min(panel$year))

perm_effects <- numeric(n_perms)
for (i in 1:n_perms) {
  # Random treatment assignment
  fake_treated <- sample(muni_ids, n_treated, replace = FALSE)
  perm_data <- panel %>%
    mutate(
      fake_treat = as.integer(gem_no %in% fake_treated),
      fake_treat_post = fake_treat * post
    )
  m <- tryCatch({
    feols(log_emp_total ~ fake_treat_post | gem_no + year, data = perm_data,
          cluster = ~gem_no)
  }, error = function(e) NULL)
  perm_effects[i] <- if (!is.null(m)) coef(m)["fake_treat_post"] else NA

  if (i %% 200 == 0) cat("  Permutation", i, "/", n_perms, "\n")
}

ri_pvalue <- mean(abs(perm_effects) >= abs(obs_effect), na.rm = TRUE)
cat("RI p-value:", ri_pvalue, "\n")
cat("RI 95% CI: [", quantile(perm_effects, 0.025, na.rm = TRUE), ",",
    quantile(perm_effects, 0.975, na.rm = TRUE), "]\n")

# ══════════════════════════════════════════════════════════════════════════════
# 3. PLACEBO: PRIMARY SECTOR (agriculture — should NOT be affected)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Placebo: Primary Sector ===\n")

panel <- panel %>%
  mutate(log_emp_primary = log(pmax(emp_primary, 1)))

placebo_primary <- feols(log_emp_primary ~ treat_post | gem_no + year,
                         data = panel, cluster = ~gem_no)
cat("Primary sector (placebo):\n")
summary(placebo_primary)

# ══════════════════════════════════════════════════════════════════════════════
# 4. ALTERNATIVE TREATMENT TIMING
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Alternative Treatment Timing ===\n")

# Try 2013 (year after vote)
panel_2013 <- panel %>%
  mutate(
    post_2013 = as.integer(year >= 2013),
    treat_post_2013 = treated * post_2013
  )
m_2013 <- feols(log_emp_total ~ treat_post_2013 | gem_no + year,
                data = panel_2013, cluster = ~gem_no)
cat("\n--- Treatment from 2013 (post-vote) ---\n")
summary(m_2013)

# Try 2015 (anticipation)
panel_2015 <- panel %>%
  mutate(
    post_2015 = as.integer(year >= 2015),
    treat_post_2015 = treated * post_2015
  )
m_2015 <- feols(log_emp_total ~ treat_post_2015 | gem_no + year,
                data = panel_2015, cluster = ~gem_no)
cat("\n--- Treatment from 2015 (anticipation) ---\n")
summary(m_2015)

# ══════════════════════════════════════════════════════════════════════════════
# 5. BANDWIDTH SENSITIVITY (RDD)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== RDD Bandwidth Sensitivity ===\n")

bandwidths <- c(3, 5, 7, 10, 15, 20)
rdd_bw_results <- list()

for (bw in bandwidths) {
  bw_data <- post_data %>% filter(abs(running) <= bw)
  if (nrow(bw_data) < 20) next

  rdd_bw <- tryCatch({
    rdrobust(y = bw_data$mean_log_emp, x = bw_data$running, c = 0, h = bw)
  }, error = function(e) NULL)

  if (!is.null(rdd_bw)) {
    rdd_bw_results[[as.character(bw)]] <- data.frame(
      bandwidth = bw,
      n_obs = nrow(bw_data),
      estimate = rdd_bw$coef["Conventional"],
      se = rdd_bw$se["Conventional"],
      pvalue = rdd_bw$pv["Conventional"]
    )
    cat("  BW =", bw, ": est =", round(rdd_bw$coef["Conventional"], 4),
        "se =", round(rdd_bw$se["Conventional"], 4), "\n")
  }
}

if (length(rdd_bw_results) > 0) {
  rdd_bw_df <- bind_rows(rdd_bw_results)
  cat("\nRDD bandwidth sensitivity:\n")
  print(rdd_bw_df)
}

# ══════════════════════════════════════════════════════════════════════════════
# 6. NEAR-THRESHOLD SAMPLE (narrow DiD)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Near-Threshold DiD (±5pp) ===\n")

narrow_panel <- panel %>%
  filter(abs(share_secondhome - 20) <= 5)
cat("Narrow sample:", n_distinct(narrow_panel$gem_no), "municipalities\n")

m_narrow <- feols(log_emp_total ~ treat_post | gem_no + year,
                  data = narrow_panel, cluster = ~gem_no)
cat("Narrow DiD:\n")
summary(m_narrow)

# ══════════════════════════════════════════════════════════════════════════════
# 7. PLACEBO CUTOFF (test at 15% and 25%)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Placebo Cutoffs ===\n")

for (cutoff in c(10, 15, 25)) {
  placebo_panel <- panel %>%
    mutate(
      fake_treated = as.integer(share_secondhome > cutoff),
      fake_treat_post = fake_treated * post
    )

  m_placebo <- feols(log_emp_total ~ fake_treat_post | gem_no + year,
                     data = placebo_panel, cluster = ~gem_no)
  cat("\n--- Placebo cutoff at", cutoff, "% ---\n")
  cat("  Treated:", sum(placebo_panel$fake_treated == 1 & placebo_panel$year == min(placebo_panel$year)), "\n")
  cat("  Estimate:", round(coef(m_placebo)["fake_treat_post"], 4),
      "SE:", round(se(m_placebo)["fake_treat_post"], 4),
      "p:", round(pvalue(m_placebo)["fake_treat_post"], 4), "\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# SAVE
# ══════════════════════════════════════════════════════════════════════════════
save(bacon_result, perm_effects, ri_pvalue, obs_effect,
     placebo_primary, m_2013, m_2015,
     rdd_bw_results, m_narrow,
     file = file.path(data_dir, "robustness_results.RData"))
cat("\nSaved robustness_results.RData\n")
