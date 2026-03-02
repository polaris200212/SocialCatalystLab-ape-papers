# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 03_main_analysis.R - Primary DR-DiD analysis
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

# Load data
state_year <- readRDS(file.path(data_dir, "state_year_panel.rds"))

cat("=== Primary Analysis: DR-DiD (Callaway-Sant'Anna) ===\n\n")

# ============================================================================
# 1. Callaway-Sant'Anna: Smoking Rate
# ============================================================================

cat("--- Model 1: Current Smoking Prevalence ---\n")

cs_smoking <- att_gt(
  yname = "smoking_rate",
  tname = "year",
  idname = "state_fips",
  gname = "first_treat",
  data = state_year,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  panel = TRUE,
  allow_unbalanced_panel = TRUE
)

att_smoking <- aggte(cs_smoking, type = "simple")
cat(sprintf("  Overall ATT on smoking rate: %.4f (SE: %.4f, p: %.4f)\n",
            att_smoking$overall.att,
            att_smoking$overall.se,
            2 * pnorm(-abs(att_smoking$overall.att / att_smoking$overall.se))))

es_smoking <- aggte(cs_smoking, type = "dynamic", min_e = -10, max_e = 15)
cal_smoking <- aggte(cs_smoking, type = "calendar")

# ============================================================================
# 2. Callaway-Sant'Anna: Everyday Smoking Rate
# ============================================================================

cat("\n--- Model 2: Everyday Smoking Rate ---\n")

cs_everyday <- att_gt(
  yname = "everyday_rate",
  tname = "year",
  idname = "state_fips",
  gname = "first_treat",
  data = state_year,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  panel = TRUE,
  allow_unbalanced_panel = TRUE
)

att_everyday <- aggte(cs_everyday, type = "simple")
cat(sprintf("  Overall ATT on everyday smoking: %.4f (SE: %.4f, p: %.4f)\n",
            att_everyday$overall.att,
            att_everyday$overall.se,
            2 * pnorm(-abs(att_everyday$overall.att / att_everyday$overall.se))))

es_everyday <- aggte(cs_everyday, type = "dynamic", min_e = -10, max_e = 15)

# ============================================================================
# 3. Callaway-Sant'Anna: Quit Attempt Rate
# ============================================================================

cat("\n--- Model 3: Quit Attempt Rate (among ever-smokers) ---\n")

quit_panel <- state_year %>% filter(!is.na(quit_rate))

# Use regression-based estimator to avoid DR segfault with small groups
cs_quit <- tryCatch({
  att_gt(
    yname = "quit_rate",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = quit_panel,
    control_group = "nevertreated",
    est_method = "reg",
    base_period = "universal",
    panel = TRUE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat(sprintf("  CS-DiD quit error: %s\n", e$message))
  NULL
})

att_quit <- NULL
es_quit <- NULL
if (!is.null(cs_quit)) {
  att_quit <- aggte(cs_quit, type = "simple")
  cat(sprintf("  Overall ATT on quit attempts: %.4f (SE: %.4f, p: %.4f)\n",
              att_quit$overall.att,
              att_quit$overall.se,
              2 * pnorm(-abs(att_quit$overall.att / att_quit$overall.se))))

  es_quit <- aggte(cs_quit, type = "dynamic", min_e = -10, max_e = 15)
}

# ============================================================================
# 4. TWFE comparison
# ============================================================================

cat("\n--- TWFE Comparison ---\n")

twfe_smoking <- feols(smoking_rate ~ treated | state_fips + year,
                       data = state_year %>% mutate(treated = as.integer(first_treat > 0 & year >= first_treat)),
                       cluster = ~state_fips)

twfe_everyday <- feols(everyday_rate ~ treated | state_fips + year,
                        data = state_year %>% mutate(treated = as.integer(first_treat > 0 & year >= first_treat)),
                        cluster = ~state_fips)

twfe_quit <- feols(quit_rate ~ treated | state_fips + year,
                    data = quit_panel %>% mutate(treated = as.integer(first_treat > 0 & year >= first_treat)),
                    cluster = ~state_fips)

cat("  TWFE smoking rate:\n")
print(summary(twfe_smoking))
cat("\n  TWFE everyday smoking rate:\n")
print(summary(twfe_everyday))
cat("\n  TWFE quit attempt rate:\n")
print(summary(twfe_quit))

# ============================================================================
# 5. Pre-trend test
# ============================================================================

cat("\n--- Pre-trend Tests ---\n")

pretest_smoking <- tryCatch({
  pt <- pretest_het(cs_smoking)
  cat(sprintf("  Pre-trend test (smoking): chi2 = %.2f, p = %.4f\n",
              pt$Wald, pt$p.value))
  pt
}, error = function(e) {
  cat(sprintf("  Pre-trend test (smoking) failed: %s\n", e$message))
  NULL
})

# ============================================================================
# 6. Save results
# ============================================================================

results <- list(
  cs_smoking = cs_smoking,
  cs_everyday = cs_everyday,
  cs_quit = cs_quit,
  att_smoking = att_smoking,
  att_everyday = att_everyday,
  att_quit = att_quit,
  es_smoking = es_smoking,
  es_everyday = es_everyday,
  es_quit = es_quit,
  cal_smoking = cal_smoking,
  twfe_smoking = twfe_smoking,
  twfe_everyday = twfe_everyday,
  twfe_quit = twfe_quit
)

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== Main analysis complete. Results saved. ===\n")

# Print summary
cat("\n=== RESULTS SUMMARY ===\n")
cat(sprintf("%-25s %10s %10s %10s\n", "Outcome", "ATT", "SE", "p-value"))
cat(paste(rep("-", 55), collapse = ""), "\n")
for (nm in c("att_smoking", "att_everyday", "att_quit")) {
  obj <- results[[nm]]
  if (!is.null(obj)) {
    pval <- 2 * pnorm(-abs(obj$overall.att / obj$overall.se))
    cat(sprintf("%-25s %10.4f %10.4f %10.4f\n",
                gsub("att_", "", nm), obj$overall.att, obj$overall.se, pval))
  }
}
