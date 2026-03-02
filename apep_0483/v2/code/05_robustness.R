###############################################################################
# 05_robustness.R — Robustness checks
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

la_panel <- fread(paste0(data_dir, "la_panel.csv"))
school_panel <- fread(paste0(data_dir, "school_panel.csv"))

est_la <- la_panel[!is.na(progress8) & !is.na(comp_ratio)]
cat(sprintf("LA estimation sample: %d obs, %d LAs\n",
            nrow(est_la), uniqueN(est_la$la_code)))

###############################################################################
# 1. Leave-One-Region-Out
###############################################################################

cat("\n=== LEAVE-ONE-REGION-OUT ===\n\n")

# Map LAs to broad regions
est_la[, region := fcase(
  grepl("^E09", la_code), "London",
  band == "fringe", "Fringe",
  band == "inner_london" | band == "outer_london", "London",
  default = "Rest"
)]

# Also try a more granular regional split
# Use KS4 data for region if available
la_raw <- fread(paste0(data_dir, "ks4_la_multiyear_raw.csv"), showProgress = FALSE,
                select = c("new_la_code", "region_name"))
la_raw <- unique(la_raw[new_la_code != "" & region_name != ""])
est_la <- merge(est_la, la_raw[, .(la_code = new_la_code, gor_region = region_name)],
                by = "la_code", all.x = TRUE)

# Use GOR regions if available
if (sum(!is.na(est_la$gor_region)) > 0) {
  regions <- unique(est_la$gor_region[!is.na(est_la$gor_region)])
} else {
  regions <- unique(est_la$region)
}
cat(sprintf("Regions: %s\n", paste(regions, collapse=", ")))

loor_results <- list()
region_col <- if (sum(!is.na(est_la$gor_region)) > 0) "gor_region" else "region"

for (r in regions) {
  if (is.na(r)) next
  subset_data <- est_la[get(region_col) != r]
  if (uniqueN(subset_data$la_code) < 10) next

  m_r <- tryCatch(
    feols(progress8 ~ comp_ratio | la_id + year,
          data = subset_data, cluster = ~la_code),
    error = function(e) NULL
  )
  if (!is.null(m_r) && !is.na(coef(m_r)["comp_ratio"])) {
    loor_results[[r]] <- data.table(
      excluded_region = r,
      n_obs = nobs(m_r),
      n_las = uniqueN(subset_data$la_code),
      beta = coef(m_r)["comp_ratio"],
      se = se(m_r)["comp_ratio"],
      pvalue = coeftable(m_r)["comp_ratio", "Pr(>|t|)"]
    )
    cat(sprintf("  Excl %s: beta=%.3f (SE=%.3f) p=%.3f N=%d\n",
                r, coef(m_r)["comp_ratio"], se(m_r)["comp_ratio"],
                coeftable(m_r)["comp_ratio", "Pr(>|t|)"], nobs(m_r)))
  }
}

loor_dt <- rbindlist(loor_results)
fwrite(loor_dt, paste0(data_dir, "leave_one_region_out.csv"))

###############################################################################
# 2. Randomization Inference
###############################################################################

cat("\n=== RANDOMIZATION INFERENCE ===\n\n")

set.seed(42)
n_perms <- 999

m_actual <- feols(progress8 ~ comp_ratio | la_id + year,
                  data = est_la, cluster = ~la_code)
beta_actual <- coef(m_actual)["comp_ratio"]
cat(sprintf("Actual: %.4f\n", beta_actual))

# Permute competitiveness across LAs within year
la_ids <- unique(est_la$la_code)
perm_betas <- numeric(n_perms)

cat(sprintf("Running %d permutations...\n", n_perms))
for (i in 1:n_perms) {
  if (i %% 200 == 0) cat(sprintf("  %d/%d\n", i, n_perms))

  # Shuffle LA assignments within each year
  perm_data <- copy(est_la)
  for (yr in unique(perm_data$year)) {
    idx <- perm_data$year == yr
    perm_data[idx, comp_ratio := sample(comp_ratio)]
  }

  m_p <- tryCatch(
    feols(progress8 ~ comp_ratio | la_id + year,
          data = perm_data, cluster = ~la_code),
    error = function(e) NULL
  )
  perm_betas[i] <- if (!is.null(m_p)) coef(m_p)["comp_ratio"] else NA
}

perm_betas <- perm_betas[!is.na(perm_betas)]
ri_pvalue <- mean(abs(perm_betas) >= abs(beta_actual))

cat(sprintf("RI p-value: %.3f (from %d permutations)\n", ri_pvalue, length(perm_betas)))

fwrite(data.table(beta_actual = beta_actual, ri_pvalue = ri_pvalue,
                  n_perms = length(perm_betas),
                  perm_mean = mean(perm_betas), perm_sd = sd(perm_betas)),
       paste0(data_dir, "ri_results.csv"))
fwrite(data.table(perm_beta = perm_betas), paste0(data_dir, "ri_permutations.csv"))

###############################################################################
# 3. MDE and Equivalence Testing
###############################################################################

cat("\n=== MDE / EQUIVALENCE ===\n\n")

se_main <- se(m_actual)["comp_ratio"]
mde_80 <- 2.8 * se_main
p8_sd <- sd(est_la$progress8, na.rm = TRUE)

cat(sprintf("SE: %.4f\n", se_main))
cat(sprintf("MDE (80%% power): %.3f P8 points per unit comp_ratio\n", mde_80))
cat(sprintf("P8 SD: %.3f\n", p8_sd))
cat(sprintf("MDE in SD units: %.3f\n", mde_80 / p8_sd))

# TOST equivalence
eq_bound <- 0.1 * p8_sd
tost_lo <- (beta_actual - (-eq_bound)) / se_main
tost_hi <- (eq_bound - beta_actual) / se_main
tost_p <- max(pnorm(-abs(tost_lo)), pnorm(-abs(tost_hi)))
cat(sprintf("TOST p-value (bound=0.1 SD): %.3f\n", tost_p))

###############################################################################
# 4. Alternative Treatment Definitions
###############################################################################

cat("\n=== ALTERNATIVE TREATMENTS ===\n\n")

alt_results <- list()

# Binary (bottom quartile)
est_la[, low_comp := fifelse(comp_ratio <= quantile(comp_ratio, 0.25, na.rm = TRUE),
                              1L, 0L)]

m_bin <- tryCatch(
  feols(progress8 ~ low_comp | la_id + year, data = est_la, cluster = ~la_code),
  error = function(e) NULL
)
if (!is.null(m_bin)) {
  alt_results[["binary_q1"]] <- m_bin
  cat(sprintf("Binary Q1: %.3f (%.3f) p=%.3f\n",
              coef(m_bin)["low_comp"], se(m_bin)["low_comp"],
              coeftable(m_bin)["low_comp", "Pr(>|t|)"]))
}

# Quadratic
m_quad <- tryCatch(
  feols(progress8 ~ comp_ratio + I(comp_ratio^2) | la_id + year,
        data = est_la, cluster = ~la_code),
  error = function(e) NULL
)
if (!is.null(m_quad)) {
  alt_results[["quadratic"]] <- m_quad
  cat(sprintf("Quadratic: linear=%.3f, squared=%.3f\n",
              coef(m_quad)["comp_ratio"], coef(m_quad)["I(comp_ratio^2)"]))
}

# Log specification
est_la[, log_comp := log(comp_ratio)]
m_log <- tryCatch(
  feols(progress8 ~ log_comp | la_id + year, data = est_la[is.finite(log_comp)],
        cluster = ~la_code),
  error = function(e) NULL
)
if (!is.null(m_log)) {
  alt_results[["log"]] <- m_log
  cat(sprintf("Log: %.3f (%.3f) p=%.3f\n",
              coef(m_log)["log_comp"], se(m_log)["log_comp"],
              coeftable(m_log)["log_comp", "Pr(>|t|)"]))
}

saveRDS(alt_results, paste0(data_dir, "alt_treatment_results.rds"))

###############################################################################
# 5. Academy Placebo (already in 03_main_analysis.R, summarize here)
###############################################################################

cat("\n=== ACADEMY PLACEBO SUMMARY ===\n\n")

acad_file <- paste0(data_dir, "academy_placebo.rds")
if (file.exists(acad_file)) {
  acad <- readRDS(acad_file)
  if (!is.null(acad$maintained)) {
    cat(sprintf("Maintained: %.3f (%.3f) p=%.3f\n",
                coef(acad$maintained)["comp_ratio"],
                se(acad$maintained)["comp_ratio"],
                coeftable(acad$maintained)["comp_ratio", "Pr(>|t|)"]))
  }
  if (!is.null(acad$academy)) {
    cat(sprintf("Academy: %.3f (%.3f) p=%.3f\n",
                coef(acad$academy)["comp_ratio"],
                se(acad$academy)["comp_ratio"],
                coeftable(acad$academy)["comp_ratio", "Pr(>|t|)"]))
  }
}

###############################################################################
# 6. Region x Year FE (addresses correlated shocks concern)
###############################################################################

cat("\n=== REGION x YEAR FE ===\n\n")

# Create region×year interaction for FE
if (sum(!is.na(est_la$gor_region)) > 0) {
  est_la[, region_year := paste0(gor_region, "_", year)]

  m_regyr <- tryCatch(
    feols(progress8 ~ comp_ratio | la_id + region_year,
          data = est_la, cluster = ~la_code),
    error = function(e) {
      cat(sprintf("Region×Year FE failed: %s\n", e$message))
      NULL
    }
  )

  if (!is.null(m_regyr) && !is.na(coef(m_regyr)["comp_ratio"])) {
    cat(sprintf("Region×Year FE: beta = %.3f (SE = %.3f), p = %.3f, N = %d\n",
                coef(m_regyr)["comp_ratio"], se(m_regyr)["comp_ratio"],
                coeftable(m_regyr)["comp_ratio", "Pr(>|t|)"], nobs(m_regyr)))
    saveRDS(m_regyr, paste0(data_dir, "region_year_fe_results.rds"))
  }
}

###############################################################################
# 7. Exclude London (addresses London Effect concern)
###############################################################################

cat("\n=== EXCLUDE LONDON ===\n\n")

est_no_london <- est_la[!(gor_region %in% c("London", "Inner London", "Outer London")) &
                           !(band %in% c("inner_london", "outer_london")) &
                           !grepl("^E09", la_code)]
cat(sprintf("Excluding London: %d obs, %d LAs\n",
            nrow(est_no_london), uniqueN(est_no_london$la_code)))

m_no_london <- tryCatch(
  feols(progress8 ~ comp_ratio | la_id + year,
        data = est_no_london, cluster = ~la_code),
  error = function(e) NULL
)

if (!is.null(m_no_london) && !is.na(coef(m_no_london)["comp_ratio"])) {
  cat(sprintf("Excl London: beta = %.3f (SE = %.3f), p = %.3f, N = %d\n",
              coef(m_no_london)["comp_ratio"], se(m_no_london)["comp_ratio"],
              coeftable(m_no_london)["comp_ratio", "Pr(>|t|)"], nobs(m_no_london)))
  saveRDS(m_no_london, paste0(data_dir, "excl_london_results.rds"))
}

# Also exclude London from event study
est_no_london[, year_f := factor(year)]
ref_year <- 2018
if (as.character(ref_year) %in% levels(est_no_london$year_f)) {
  est_no_london[, year_f := relevel(year_f, ref = as.character(ref_year))]
}

m_event_nol <- tryCatch(
  feols(progress8 ~ i(year, baseline_comp, ref = ref_year) | la_id + year,
        data = est_no_london, cluster = ~la_code),
  error = function(e) NULL
)

if (!is.null(m_event_nol)) {
  cat("Event study (excl London):\n")
  print(coeftable(m_event_nol))
  saveRDS(m_event_nol, paste0(data_dir, "event_excl_london.rds"))
}

###############################################################################
# 8. IV Falsification + Reduced Form
###############################################################################

cat("\n=== IV FALSIFICATION + REDUCED FORM ===\n\n")

bartik_file <- paste0(data_dir, "bartik_predictions.csv")
if (file.exists(bartik_file)) {
  bartik <- fread(bartik_file)
  iv_data <- merge(est_la, bartik[, .(la_code, year, high_wage_share, bartik_proxy)],
                   by = c("la_code", "year"), all.x = TRUE)
  iv_data <- iv_data[!is.na(bartik_proxy)]

  # Reduced form: Progress 8 ~ Bartik instrument
  m_rf <- tryCatch(
    feols(progress8 ~ bartik_proxy | la_id + year,
          data = iv_data, cluster = ~la_code),
    error = function(e) NULL
  )
  if (!is.null(m_rf)) {
    cat(sprintf("Reduced form: beta = %.4f (SE = %.4f), p = %.3f\n",
                coef(m_rf)["bartik_proxy"], se(m_rf)["bartik_proxy"],
                coeftable(m_rf)["bartik_proxy", "Pr(>|t|)"]))
    saveRDS(m_rf, paste0(data_dir, "reduced_form_results.rds"))
  }

  # IV Falsification: instrument on Attainment 8 (broader measure, possibly pre-existing)
  if ("attainment8" %in% names(iv_data) && sum(!is.na(iv_data$attainment8)) > 50) {
    m_falso <- tryCatch(
      feols(attainment8 ~ bartik_proxy | la_id + year,
            data = iv_data[!is.na(attainment8)], cluster = ~la_code),
      error = function(e) NULL
    )
    if (!is.null(m_falso)) {
      cat(sprintf("IV Falsification (Attainment 8): beta = %.4f (SE = %.4f), p = %.3f\n",
                  coef(m_falso)["bartik_proxy"], se(m_falso)["bartik_proxy"],
                  coeftable(m_falso)["bartik_proxy", "Pr(>|t|)"]))
      saveRDS(m_falso, paste0(data_dir, "iv_falsification_results.rds"))
    }
  }
}

cat("\n=== ROBUSTNESS COMPLETE ===\n")
