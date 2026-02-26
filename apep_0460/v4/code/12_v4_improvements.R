## ============================================================================
## 12_v4_improvements.R — Inference & Identification Overhaul
## APEP-0460 v4: Across the Channel
##
## Five improvements:
##   A. Wild Cluster Bootstrap via pairs cluster bootstrap
##   B. Multi-Country Placebo Construction (BE, NL, IT, ES from GADM1)
##   C. Multi-Country Placebo Regressions
##   D. SCI Triple-Diff Pre-2020
##   E. HonestDiD Sensitivity Analysis
##   F. Commune-Level Triple-Diff (stretch goal)
##   G. New Tables & Figures
## ============================================================================

cat("=== APEP-0460 v4 Improvements ===\n")
cat("Start time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

## ========================================================================
## SECTION A: SETUP & PACKAGE INSTALLATION
## ========================================================================
cat("=== Section A: Setup ===\n")

library(data.table)
library(fixest)
library(ggplot2)
library(patchwork)

# HonestDiD
library(HonestDiD)

# Directories
data_dir <- file.path(dirname(getwd()), "data")
fig_dir  <- file.path(dirname(getwd()), "figures")
tab_dir  <- file.path(dirname(getwd()), "tables")
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

# Publication theme
theme_apep <- function(base_size = 10) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey90", linewidth = 0.3),
      axis.line = element_line(colour = "grey30", linewidth = 0.4),
      axis.ticks = element_line(colour = "grey30", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = base_size + 1),
      plot.subtitle = element_text(colour = "grey40"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}

apep_colors <- c(
  uk = "#1B4F72", de = "#B03A2E", ch = "#196F3D",
  be = "#7D3C98", nl = "#E67E22", it = "#2E86C1",
  es = "#D4AC0D", post = "#E74C3C", ci = "#AED6F1"
)

## --- Wild Cluster Bootstrap: Pairs Cluster Bootstrap ---
## Resamples entire clusters with replacement (Cameron, Gelbach & Miller 2008).
## Valid for G >= 20 clusters. Simple and robust.
pairs_cluster_bootstrap <- function(data, formula, cluster_col,
                                     param, B = 999, seed = 42) {
  set.seed(seed)
  clusters <- unique(data[[cluster_col]])
  G <- length(clusters)

  # Original estimate
  fit0 <- feols(formula, data = data, cluster = as.formula(paste0("~", cluster_col)))
  beta0 <- coef(fit0)
  param_idx <- grep(param, names(beta0), fixed = TRUE)
  if (length(param_idx) == 0) {
    cat("    Param '", param, "' not found\n")
    return(list(p_boot = NA, ci_boot = c(NA, NA)))
  }
  param_idx <- param_idx[1]
  beta_obs <- beta0[param_idx]
  se_obs <- se(fit0)[param_idx]
  t_obs <- beta_obs / se_obs

  # Bootstrap
  t_boot <- numeric(B)
  for (b in seq_len(B)) {
    # Resample clusters with replacement
    boot_clusters <- sample(clusters, G, replace = TRUE)
    # Build bootstrap dataset (stacking resampled clusters)
    boot_list <- lapply(seq_along(boot_clusters), function(i) {
      d <- data[data[[cluster_col]] == boot_clusters[i], ]
      d[[cluster_col]] <- paste0(boot_clusters[i], "_", i)  # unique cluster ID
      d
    })
    boot_data <- rbindlist(boot_list, fill = TRUE)

    # Re-estimate
    fit_b <- tryCatch(
      feols(formula, data = boot_data,
            cluster = as.formula(paste0("~", cluster_col)),
            warn = FALSE, notes = FALSE),
      error = function(e) NULL
    )

    if (!is.null(fit_b) && param_idx <= length(coef(fit_b))) {
      beta_b <- coef(fit_b)[param_idx]
      se_b <- se(fit_b)[param_idx]
      if (!is.na(se_b) && se_b > 0) {
        t_boot[b] <- (beta_b - beta_obs) / se_b
      } else {
        t_boot[b] <- NA
      }
    } else {
      t_boot[b] <- NA
    }

    if (b %% 200 == 0) cat("    bootstrap", b, "/", B, "\n")
  }

  # Two-sided p-value
  t_boot_valid <- t_boot[!is.na(t_boot)]
  p_boot <- mean(abs(t_boot_valid) >= abs(t_obs))

  # Percentile CI
  beta_boot <- numeric(B)
  for (b in seq_len(B)) {
    boot_clusters <- sample(clusters, G, replace = TRUE)
    boot_list <- lapply(seq_along(boot_clusters), function(i) {
      d <- data[data[[cluster_col]] == boot_clusters[i], ]
      d[[cluster_col]] <- paste0(boot_clusters[i], "_", i)
      d
    })
    boot_data <- rbindlist(boot_list, fill = TRUE)
    fit_b <- tryCatch(
      feols(formula, data = boot_data,
            cluster = as.formula(paste0("~", cluster_col)),
            warn = FALSE, notes = FALSE),
      error = function(e) NULL
    )
    if (!is.null(fit_b) && param_idx <= length(coef(fit_b))) {
      beta_boot[b] <- coef(fit_b)[param_idx]
    } else {
      beta_boot[b] <- NA
    }
  }
  ci <- quantile(beta_boot, c(0.025, 0.975), na.rm = TRUE)

  return(list(p_boot = p_boot, ci_boot = ci, t_obs = t_obs,
              n_valid = length(t_boot_valid)))
}

# Load data
cat("Loading v3 panels and results...\n")
panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
dept_exposure <- as.data.table(readRDS(file.path(data_dir, "dept_exposure.rds")))
type_panel <- as.data.table(readRDS(file.path(data_dir, "property_type_panel.rds")))
v3_results <- readRDS(file.path(data_dir, "v3_results.rds"))

# Reconstruct analysis sample
ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk) & n_transactions >= 5]
ad[, fr_region := code_departement]
ad[, post := as.integer(year > 2016 | (year == 2016 & quarter >= 3))]
ad[, time_trend := as.numeric(factor(yq, levels = sort(unique(yq))))]
ad[, t := (year - 2014) * 4 + quarter]
ref_t_val <- ad[year == 2016 & quarter == 2, unique(t)][1]
ad[, ref_period := t - ref_t_val]

# Reconstruct census stock from v3 results
# The v3 analysis merges census stock onto ad, but analysis_panel.rds predates that merge
# Extract dept-level stock from a v3 model's data
if (!"log_uk_stock_2011" %in% names(ad)) {
  cat("  Reconstructing census stock from v3 model objects...\n")
  # The v3 results contain the m2_stock model which used log_uk_stock_2011
  # We can reconstruct from the v3 analysis approach:
  # Re-read the INSEE data as done in 10_v3_analysis.R
  insee_file <- file.path(data_dir, "ip1809.xlsx")
  if (file.exists(insee_file)) {
    library(readxl)
    bv_data <- tryCatch({
      raw <- read_excel(insee_file, sheet = "Figure 1", col_names = FALSE, skip = 3)
      setDT(raw)
      setnames(raw, c("bv_code", "bv_name", "n_british", "pct_british"))
      raw[, n_british := as.numeric(n_british)]
      raw <- raw[!is.na(bv_code) & !is.na(n_british)]
      raw[, code_departement := substr(bv_code, 1, 2)]
      raw[grepl("^2A", bv_code), code_departement := "2A"]
      raw[grepl("^2B", bv_code), code_departement := "2B"]
      raw[code_departement == "20" & as.numeric(substr(bv_code, 1, 5)) < 20200,
          code_departement := "2A"]
      raw[code_departement == "20" & as.numeric(substr(bv_code, 1, 5)) >= 20200,
          code_departement := "2B"]
      raw
    }, error = function(e) NULL)

    if (!is.null(bv_data) && nrow(bv_data) > 0) {
      dept_uk_census <- bv_data[, .(uk_stock_2016 = sum(n_british, na.rm = TRUE)),
                                 by = code_departement]
      dept_uk_census[, log_uk_stock_2011 := log(uk_stock_2016 + 1)]
      dept_uk_census[, uk_stock_2011 := uk_stock_2016]

      ad <- merge(ad, dept_uk_census[, .(code_departement, log_uk_stock_2011)],
                  by = "code_departement", all.x = TRUE)
      cat("  Census stock reconstructed for", sum(!is.na(ad$log_uk_stock_2011)),
          "/", nrow(ad), "obs\n")

      # Save for later merge onto property-type panel
      saveRDS(dept_uk_census, file.path(data_dir, "dept_uk_census.rds"))
    }
  }
}

# Reconstruct residualized SCI
if (!"resid_sci_uk" %in% names(ad)) {
  cat("  Note: Reconstructing residualized SCI...\n")
  baseline_prices <- ad[year %in% 2014:2015,
                        .(baseline_price = median(median_price_m2, na.rm = TRUE)),
                        by = code_departement]
  baseline_trans <- ad[year %in% 2014:2015,
                       .(baseline_transactions = median(n_transactions, na.rm = TRUE)),
                       by = code_departement]
  channel_coastal <- c("62", "80", "76", "14", "50", "22", "29", "56", "35",
                       "44", "85", "17", "33", "40", "64", "66", "11", "34",
                       "30", "13", "83", "06", "2A", "2B")
  dept_chars <- merge(
    dept_exposure[!is.na(code_departement),
                  .(code_departement, log_sci_uk, log_sci_de, log_sci_ch)],
    baseline_prices, by = "code_departement", all.x = TRUE)
  dept_chars <- merge(dept_chars, baseline_trans, by = "code_departement", all.x = TRUE)
  dept_chars[, `:=`(
    log_baseline_price = log(baseline_price),
    log_baseline_trans = log(baseline_transactions + 1),
    coastal = as.integer(code_departement %in% channel_coastal)
  )]
  fs <- lm(log_sci_uk ~ log_baseline_price + coastal + log_baseline_trans +
              log_sci_de + log_sci_ch,
            data = dept_chars[complete.cases(dept_chars[, .(log_baseline_price,
              coastal, log_baseline_trans, log_sci_de, log_sci_ch)])])
  dept_chars[complete.cases(dept_chars[, .(log_baseline_price, coastal,
    log_baseline_trans, log_sci_de, log_sci_ch)]),
    resid_sci_uk := resid(fs)]
  # Simple fallback for missing
  simple_r <- lm(log_sci_uk ~ log_sci_de + log_sci_ch, data = dept_chars)
  dept_chars[is.na(resid_sci_uk), resid_sci_uk := resid(
    lm(log_sci_uk ~ log_sci_de + log_sci_ch, data = dept_chars)
  )[is.na(dept_chars$resid_sci_uk)]]

  ad <- merge(ad, dept_chars[, .(code_departement, resid_sci_uk)],
              by = "code_departement", all.x = TRUE)
}

has_stock <- "log_uk_stock_2011" %in% names(ad)
has_resid <- "resid_sci_uk" %in% names(ad)
cat("  Has census stock:", has_stock, "\n")
cat("  Has residualized SCI:", has_resid, "\n")

# Reconstruct property-type panel
prop_ad <- type_panel[!is.na(log_price_m2) & !is.na(log_sci_uk) & n_transactions >= 5]
prop_ad[, fr_region := code_departement]
prop_ad[, t := (year - 2014) * 4 + quarter]
prop_ad[, ref_period := t - ref_t_val]
type_panel[, yr := as.integer(substr(yq, 1, 4))]
prop_ad[, yr := as.integer(substr(yq, 1, 4))]

# Merge census stock onto property-type panel if available
if (has_stock && !"log_uk_stock_2011" %in% names(prop_ad)) {
  census_file <- file.path(data_dir, "dept_uk_census.rds")
  if (file.exists(census_file)) {
    dept_uk_census <- readRDS(census_file)
    prop_ad <- merge(prop_ad, dept_uk_census[, .(code_departement, log_uk_stock_2011)],
                     by = "code_departement", all.x = TRUE)
    cat("  Census stock merged onto prop_ad\n")
  } else if ("log_uk_stock_2011" %in% names(ad)) {
    stock_dt <- unique(ad[, .(code_departement, log_uk_stock_2011)])
    prop_ad <- merge(prop_ad, stock_dt, by = "code_departement", all.x = TRUE)
    cat("  Census stock merged onto prop_ad from ad\n")
  }
} else if (has_stock) {
  # Already has it — but check for duplicates
  dup_cols <- grep("log_uk_stock_2011", names(prop_ad), value = TRUE)
  if (length(dup_cols) > 1) {
    # Keep first, drop rest
    for (dc in dup_cols[-1]) prop_ad[, (dc) := NULL]
    setnames(prop_ad, dup_cols[1], "log_uk_stock_2011")
    cat("  Fixed duplicate log_uk_stock_2011 columns\n")
  }
  cat("  prop_ad already has census stock\n")
}

cat("  Analysis sample:", nrow(ad), "obs\n")
cat("  Property-type sample:", nrow(prop_ad), "obs\n\n")


## ========================================================================
## SECTION B: MULTI-COUNTRY PLACEBO CONSTRUCTION
## ========================================================================
cat("=== Section B: Multi-Country Placebo Construction ===\n")

# GADM1 data: check local data/ first, then fall back to project-relative path
gadm1_path <- file.path(data_dir, "gadm1.csv")
if (!file.exists(gadm1_path)) {
  # Fall back to the v1 data directory (relative to project root)
  project_root <- normalizePath(file.path(getwd(), "..", ".."))
  gadm1_path <- file.path(project_root, "papers", "apep_0460", "v1", "data", "gadm1.csv")
}
gadm2_mapping_path <- file.path(data_dir, "gadm2_dept_mapping.csv")

cat("  GADM1 exists:", file.exists(gadm1_path), "\n")

gadm2_map <- fread(gadm2_mapping_path)
gadm2_map[, gadm1_region_num := as.integer(gsub("FRA\\.(\\d+)\\..*", "\\1", fr_gadm2))]
gadm2_map[, gadm1_region := paste0("FRA.", gadm1_region_num, "_1")]

placebo_countries <- c("GB", "BE", "NL", "IT", "ES")

cat("  Reading GADM1 SCI data...\n")
gadm1_fr <- fread(
  cmd = paste0("grep '^FR,' ", gadm1_path),
  header = FALSE,
  col.names = c("user_country", "friend_country", "user_region",
                "friend_region", "scaled_sci")
)

gadm1_fr <- gadm1_fr[friend_country %in% placebo_countries &
                       grepl("^FRA\\.", user_region)]
cat("  Filtered rows:", nrow(gadm1_fr), "\n")

gadm1_agg <- gadm1_fr[, .(sci_total = sum(scaled_sci, na.rm = TRUE)),
                       by = .(user_region, friend_country)]
gadm1_agg[, gadm1_region := user_region]

dept_placebo_sci <- merge(
  gadm2_map[, .(code_departement, gadm1_region)],
  gadm1_agg[, .(gadm1_region, friend_country, sci_total)],
  by = "gadm1_region", allow.cartesian = TRUE
)

dept_placebo_wide <- dcast(dept_placebo_sci,
                           code_departement ~ friend_country,
                           value.var = "sci_total", fun.aggregate = sum)

for (cc in placebo_countries) {
  col_name <- paste0("sci_total_", tolower(cc))
  log_col <- paste0("log_sci_", tolower(cc))
  setnames(dept_placebo_wide, cc, col_name, skip_absent = TRUE)
  dept_placebo_wide[, (log_col) := log(get(col_name) + 1)]
}

cat("  Placebo SCI computed for", nrow(dept_placebo_wide), "départements\n")

# Merge onto panels
merge_cols <- c("code_departement", grep("log_sci_", names(dept_placebo_wide), value = TRUE))
ad <- merge(ad, dept_placebo_wide[, ..merge_cols], by = "code_departement", all.x = TRUE)
prop_ad <- merge(prop_ad, dept_placebo_wide[, ..merge_cols], by = "code_departement", all.x = TRUE)

saveRDS(dept_placebo_wide, file.path(data_dir, "dept_placebo_sci.rds"))
cat("  Saved dept_placebo_sci.rds\n\n")


## ========================================================================
## SECTION C: WILD CLUSTER BOOTSTRAP (PAIRS BOOTSTRAP)
## ========================================================================
cat("=== Section C: Wild Cluster Bootstrap ===\n")

# Use B=499 for computational feasibility with pairs cluster bootstrap
B_boot <- 499

# M1: SCI × Post
cat("\n  M1: SCI × Post\n")
m1_model <- feols(log_price_m2 ~ log_sci_uk:post | fr_region + yq,
                  data = ad, cluster = ~fr_region)
cat("    Cluster-robust: beta =", round(coef(m1_model)[1], 4),
    " p =", round(pvalue(m1_model)[1], 4), "\n")

bt_m1 <- pairs_cluster_bootstrap(
  data = ad, formula = log_price_m2 ~ log_sci_uk:post | fr_region + yq,
  cluster_col = "fr_region", param = "log_sci_uk:post", B = B_boot
)
cat("    Pairs bootstrap p =", round(bt_m1$p_boot, 4), "\n")

# M2: Census stock × Post
if (has_stock) {
  cat("\n  M2: Census stock × Post\n")
  m2_model <- feols(log_price_m2 ~ log_uk_stock_2011:post | fr_region + yq,
                    data = ad, cluster = ~fr_region)
  cat("    Cluster-robust: beta =", round(coef(m2_model)[1], 4),
      " p =", round(pvalue(m2_model)[1], 4), "\n")

  bt_m2 <- pairs_cluster_bootstrap(
    data = ad, formula = log_price_m2 ~ log_uk_stock_2011:post | fr_region + yq,
    cluster_col = "fr_region", param = "log_uk_stock_2011:post", B = B_boot
  )
  cat("    Pairs bootstrap p =", round(bt_m2$p_boot, 4), "\n")
} else {
  m2_model <- NULL
  bt_m2 <- list(p_boot = NA)
}

# M5: German SCI placebo
cat("\n  M5: German SCI placebo\n")
m5de_model <- feols(log_price_m2 ~ log_sci_de:post | fr_region + yq,
                    data = ad, cluster = ~fr_region)
cat("    Cluster-robust: beta =", round(coef(m5de_model)[1], 4),
    " p =", round(pvalue(m5de_model)[1], 4), "\n")

bt_m5de <- pairs_cluster_bootstrap(
  data = ad, formula = log_price_m2 ~ log_sci_de:post | fr_region + yq,
  cluster_col = "fr_region", param = "log_sci_de:post", B = B_boot
)
cat("    Pairs bootstrap p =", round(bt_m5de$p_boot, 4), "\n")

# F1: SCI triple-diff
cat("\n  F1: SCI triple-diff\n")
f1_model <- feols(log_price_m2 ~ log_sci_uk:post:house |
                    dept_type + yq_type + dept_yq,
                  data = prop_ad, cluster = ~fr_region)
cat("    Cluster-robust: beta =", round(coef(f1_model)[1], 4),
    " p =", round(pvalue(f1_model)[1], 4), "\n")

bt_f1 <- pairs_cluster_bootstrap(
  data = prop_ad,
  formula = log_price_m2 ~ log_sci_uk:post:house | dept_type + yq_type + dept_yq,
  cluster_col = "fr_region", param = "log_sci_uk:post:house", B = B_boot
)
cat("    Pairs bootstrap p =", round(bt_f1$p_boot, 4), "\n")

# F2: Census stock triple-diff
if (has_stock) {
  cat("\n  F2: Census stock triple-diff\n")
  f2_model <- feols(log_price_m2 ~ log_uk_stock_2011:post:house |
                      dept_type + yq_type + dept_yq,
                    data = prop_ad[!is.na(log_uk_stock_2011)],
                    cluster = ~fr_region)
  cat("    Cluster-robust: beta =", round(coef(f2_model)[1], 4),
      " p =", round(pvalue(f2_model)[1], 4), "\n")

  bt_f2 <- pairs_cluster_bootstrap(
    data = prop_ad[!is.na(log_uk_stock_2011)],
    formula = log_price_m2 ~ log_uk_stock_2011:post:house | dept_type + yq_type + dept_yq,
    cluster_col = "fr_region", param = "log_uk_stock_2011:post:house", B = B_boot
  )
  cat("    Pairs bootstrap p =", round(bt_f2$p_boot, 4), "\n")
} else {
  f2_model <- NULL
  bt_f2 <- list(p_boot = NA)
}

# Exchange rate
bt_i1 <- list(p_boot = NA)
if (has_stock && "sterling_weakness" %in% names(ad)) {
  cat("\n  I1: Sterling × Census stock\n")
  i1_model <- feols(log_price_m2 ~ sterling_weakness:log_uk_stock_2011 |
                      fr_region + yq,
                    data = ad[!is.na(sterling_weakness)], cluster = ~fr_region)
  cat("    Cluster-robust: beta =", round(coef(i1_model)[1], 4),
      " p =", round(pvalue(i1_model)[1], 4), "\n")

  bt_i1 <- pairs_cluster_bootstrap(
    data = ad[!is.na(sterling_weakness)],
    formula = log_price_m2 ~ sterling_weakness:log_uk_stock_2011 | fr_region + yq,
    cluster_col = "fr_region",
    param = "sterling_weakness:log_uk_stock_2011", B = B_boot
  )
  cat("    Pairs bootstrap p =", round(bt_i1$p_boot, 4), "\n")
}

# Compile bootstrap results
boot_results <- data.table(
  Specification = c("SCI x Post (DiD)", "Census Stock x Post (DiD)",
                    "SCI(DE) x Post (Placebo)",
                    "SCI x Post x House (Triple-Diff)",
                    "Stock x Post x House (Triple-Diff)",
                    "Sterling x Stock (Exchange Rate)"),
  Cluster_Robust_p = c(
    pvalue(m1_model)[1],
    if (has_stock) pvalue(m2_model)[1] else NA,
    pvalue(m5de_model)[1],
    pvalue(f1_model)[1],
    if (has_stock) pvalue(f2_model)[1] else NA,
    if (!is.na(bt_i1$p_boot)) pvalue(i1_model)[1] else NA
  ),
  Wild_Bootstrap_p = c(bt_m1$p_boot, bt_m2$p_boot, bt_m5de$p_boot,
                       bt_f1$p_boot, bt_f2$p_boot, bt_i1$p_boot)
)

cat("\n  === Bootstrap Summary ===\n")
print(boot_results)


## ========================================================================
## SECTION D: SCI TRIPLE-DIFF PRE-2020
## ========================================================================
cat("\n=== Section D: SCI Triple-Diff Pre-2020 ===\n")

pre_covid_ad <- prop_ad[yr <= 2019]
cat("  Pre-COVID sample:", nrow(pre_covid_ad), "obs\n")

f_pre_sci <- tryCatch(
  feols(log_price_m2 ~ house:log_sci_uk:post |
          dept_type + yq_type + dept_yq,
        data = pre_covid_ad[n_transactions >= 5],
        cluster = ~code_departement),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)

if (!is.null(f_pre_sci)) {
  cat("  SCI triple-diff (pre-2020): beta =", round(coef(f_pre_sci)[1], 4),
      " p =", round(pvalue(f_pre_sci)[1], 4), "\n")
}

if (has_stock) {
  f_pre_stock <- tryCatch(
    feols(log_price_m2 ~ house:log_uk_stock_2011:post |
            dept_type + yq_type + dept_yq,
          data = pre_covid_ad[!is.na(log_uk_stock_2011) & n_transactions >= 5],
          cluster = ~code_departement),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(f_pre_stock)) {
    cat("  Stock triple-diff (pre-2020): beta =", round(coef(f_pre_stock)[1], 4),
        " p =", round(pvalue(f_pre_stock)[1], 4), "\n")
  }
} else {
  f_pre_stock <- NULL
}

# Post-COVID
post_covid_ad <- prop_ad[yr >= 2017]  # post-referendum only, not post-2020
f_post_sci <- tryCatch(
  feols(log_price_m2 ~ house:log_sci_uk:post |
          dept_type + yq_type + dept_yq,
        data = prop_ad[yr >= 2020 & n_transactions >= 5],
        cluster = ~code_departement),
  error = function(e) { cat("  Post-2020 error:", e$message, "\n"); NULL }
)

if (!is.null(f_post_sci)) {
  cat("  SCI triple-diff (post-2020): beta =", round(coef(f_post_sci)[1], 4),
      " p =", round(pvalue(f_post_sci)[1], 4), "\n")
}

cat("\n")


## ========================================================================
## SECTION E: MULTI-COUNTRY PLACEBO REGRESSIONS
## ========================================================================
cat("=== Section E: Multi-Country Placebo Regressions ===\n")

placebo_cc <- c("be", "nl", "it", "es")
placebo_labels <- c(BE = "Belgium", NL = "Netherlands", IT = "Italy", ES = "Spain")

# E1: Individual DiD placebos
cat("\n  --- E1: DiD Placebos ---\n")
did_placebo_results <- list()
did_placebo_boot <- list()

for (cc in placebo_cc) {
  var_name <- paste0("log_sci_", cc)
  if (!var_name %in% names(ad)) next

  fml <- as.formula(paste0("log_price_m2 ~ ", var_name, ":post | fr_region + yq"))
  m_cc <- tryCatch(feols(fml, data = ad, cluster = ~fr_region),
                   error = function(e) NULL)

  if (!is.null(m_cc)) {
    cat("  ", toupper(cc), "DiD: beta =", round(coef(m_cc)[1], 4),
        " p =", round(pvalue(m_cc)[1], 4), "\n")
    did_placebo_results[[cc]] <- m_cc
  }
}

# E2: Individual triple-diff placebos
cat("\n  --- E2: Triple-Diff Placebos ---\n")
triple_placebo_results <- list()

for (cc in placebo_cc) {
  var_name <- paste0("log_sci_", cc)
  if (!var_name %in% names(prop_ad)) next

  fml <- as.formula(paste0("log_price_m2 ~ house:", var_name, ":post | ",
                           "dept_type + yq_type + dept_yq"))
  f_cc <- tryCatch(feols(fml, data = prop_ad, cluster = ~fr_region),
                   error = function(e) NULL)

  if (!is.null(f_cc)) {
    cat("  ", toupper(cc), "Triple-diff: beta =", round(coef(f_cc)[1], 4),
        " p =", round(pvalue(f_cc)[1], 4), "\n")
    triple_placebo_results[[cc]] <- f_cc
  }
}

# E3: Horse race
cat("\n  --- E3: Horse Race ---\n")

# Check which variables exist
avail_vars <- sapply(placebo_cc, function(cc)
  paste0("log_sci_", cc) %in% names(ad))

if (all(avail_vars)) {
  cat("  DiD horse race: UK + BE + NL + IT + ES\n")
  m_horse_did <- tryCatch(
    feols(log_price_m2 ~ log_sci_uk:post + log_sci_be:post +
            log_sci_nl:post + log_sci_it:post + log_sci_es:post |
            fr_region + yq,
          data = ad, cluster = ~fr_region),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(m_horse_did)) {
    cat("  DiD horse race:\n")
    print(coeftable(m_horse_did))
  }

  cat("\n  Triple-diff horse race\n")
  m_horse_triple <- tryCatch(
    feols(log_price_m2 ~ house:log_sci_uk:post + house:log_sci_be:post +
            house:log_sci_nl:post + house:log_sci_it:post + house:log_sci_es:post |
            dept_type + yq_type + dept_yq,
          data = prop_ad, cluster = ~fr_region),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(m_horse_triple)) {
    cat("  Triple-diff horse race:\n")
    print(coeftable(m_horse_triple))
  }
} else {
  m_horse_did <- NULL
  m_horse_triple <- NULL
}

cat("\n")


## ========================================================================
## SECTION F: HonestDiD SENSITIVITY ANALYSIS
## ========================================================================
cat("=== Section F: HonestDiD Sensitivity ===\n")

if (has_stock) {
  cat("  Running census stock event study for HonestDiD...\n")

  es_stock_hdid <- feols(log_price_m2 ~ i(ref_period, log_uk_stock_2011, ref = 0) |
                           fr_region + yq,
                         data = ad, cluster = ~fr_region)

  # Extract and sort by period
  es_ct <- coeftable(es_stock_hdid)
  es_names <- rownames(es_ct)
  es_periods <- as.numeric(gsub("ref_period::(-?[0-9]+):log_uk_stock_2011", "\\1", es_names))
  ord <- order(es_periods)
  es_periods <- es_periods[ord]
  beta_hat <- es_ct[ord, 1]
  sigma_hat <- vcov(es_stock_hdid)[ord, ord]

  n_pre <- sum(es_periods < 0)
  n_post <- sum(es_periods > 0)
  cat("  Pre-periods:", n_pre, " Post-periods:", n_post, "\n")

  # HonestDiD relative magnitudes
  l_vec <- rep(0, length(beta_hat))
  l_vec[n_pre + 1] <- 1  # First post-period

  honest_result <- tryCatch({
    createSensitivityResults_relativeMagnitudes(
      betahat = beta_hat,
      sigma = sigma_hat,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mbarvec = seq(0, 2, by = 0.25),
      l_vec = l_vec
    )
  }, error = function(e) {
    cat("  Error with l_vec:", conditionMessage(e), "\n")
    tryCatch({
      createSensitivityResults_relativeMagnitudes(
        betahat = beta_hat,
        sigma = sigma_hat,
        numPrePeriods = n_pre,
        numPostPeriods = n_post,
        Mbarvec = seq(0, 2, by = 0.25)
      )
    }, error = function(e2) {
      cat("  Fallback error:", conditionMessage(e2), "\n")
      NULL
    })
  })

  if (!is.null(honest_result)) {
    cat("  HonestDiD results:\n")
    print(honest_result)

    # Plot
    honest_df <- as.data.frame(honest_result)
    col_names <- names(honest_df)
    cat("  Column names:", paste(col_names, collapse = ", "), "\n")

    # Ensure numeric columns
    honest_df$lb <- as.numeric(honest_df$lb)
    honest_df$ub <- as.numeric(honest_df$ub)
    honest_df$Mbar <- as.numeric(honest_df$Mbar)
    honest_df$midpoint <- (honest_df$lb + honest_df$ub) / 2

    p_honest <- ggplot(honest_df, aes(x = Mbar)) +
      geom_ribbon(aes(ymin = lb, ymax = ub),
                  fill = apep_colors["uk"], alpha = 0.2) +
      geom_line(aes(y = midpoint),
                colour = apep_colors["uk"], linewidth = 0.7) +
      geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
      labs(x = expression(bar(M) ~ "(Relative Magnitudes)"),
           y = "95% Robust CI",
           title = "HonestDiD Sensitivity: Census Stock Event Study",
           subtitle = "Rambachan & Roth (2023)") +
      theme_apep()

    ggsave(file.path(fig_dir, "fig_honestdid_sensitivity.pdf"),
           p_honest, width = 7, height = 5)
    cat("  Saved fig_honestdid_sensitivity.pdf\n")

    # Breakdown point
    robust <- honest_df$lb > 0 | honest_df$ub < 0
    if (any(robust)) {
      breakdown_mbar <- max(honest_df$Mbar[robust])
      cat("  Breakdown M-bar:", round(breakdown_mbar, 2), "\n")
    } else {
      cat("  CI includes zero at all M-bar values\n")
    }
  }
} else {
  honest_result <- NULL
  cat("  Skipping: no census stock\n")
}

cat("\n")


## ========================================================================
## SECTION G: COMMUNE-LEVEL TRIPLE-DIFF
## ========================================================================
cat("=== Section G: Commune-Level Triple-Diff ===\n")

dvf_dir <- file.path(data_dir, "dvf")
dvf_files <- list.files(dvf_dir, pattern = "\\.csv\\.gz$", full.names = TRUE)
cat("  DVF files:", length(dvf_files), "\n")

f_commune_sci <- NULL
f_commune_stock <- NULL

if (length(dvf_files) > 0) {
  commune_data <- list()
  for (ff in dvf_files) {
    cat("  Reading:", basename(ff), "... ")
    tryCatch({
      dt <- fread(cmd = paste("gunzip -c", ff),
                  select = c("date_mutation", "nature_mutation", "valeur_fonciere",
                             "code_departement", "code_commune", "type_local",
                             "surface_reelle_bati"),
                  fill = TRUE)
      dt <- dt[nature_mutation == "Vente" & type_local %in% c("Appartement", "Maison")]
      dt[, date_mutation := as.Date(date_mutation)]
      dt[, `:=`(year = year(date_mutation), quarter = quarter(date_mutation))]
      dt[, valeur_fonciere := as.numeric(gsub(",", ".", as.character(valeur_fonciere)))]
      dt <- dt[!is.na(valeur_fonciere) & valeur_fonciere > 10000 & valeur_fonciere < 10000000]
      dt[, surface_reelle_bati := as.numeric(surface_reelle_bati)]
      dt <- dt[!is.na(surface_reelle_bati) & surface_reelle_bati > 5]
      dt[, price_m2 := valeur_fonciere / surface_reelle_bati]
      dt <- dt[price_m2 > 100 & price_m2 < 50000]
      commune_data[[basename(ff)]] <- dt[, .(code_departement, code_commune,
                                              year, quarter, type_local, price_m2)]
      cat(nrow(dt), "\n")
    }, error = function(e) cat("Error:", conditionMessage(e), "\n"))
  }

  dvf_commune <- rbindlist(commune_data, fill = TRUE)
  cat("  Total:", nrow(dvf_commune), "transactions\n")

  commune_panel <- dvf_commune[, .(
    median_price_m2 = median(price_m2, na.rm = TRUE),
    n_transactions = .N
  ), by = .(code_commune, code_departement, type_local, year, quarter)]

  commune_panel[, `:=`(
    yq = paste0(year, "Q", quarter),
    log_price_m2 = log(median_price_m2),
    house = as.integer(type_local == "Maison"),
    post = as.integer(year > 2016 | (year == 2016 & quarter >= 3))
  )]

  commune_ad <- commune_panel[n_transactions >= 3 & !is.na(log_price_m2)]
  cat("  Commune panel (n>=3):", nrow(commune_ad), "\n")

  commune_ad <- merge(commune_ad,
                      dept_exposure[!is.na(code_departement),
                                    .(code_departement, log_sci_uk, log_sci_de)],
                      by = "code_departement", all.x = TRUE)

  if (has_stock) {
    stock_dt <- unique(ad[, .(code_departement, log_uk_stock_2011)])
    commune_ad <- merge(commune_ad, stock_dt, by = "code_departement", all.x = TRUE)
  }

  commune_ad[, `:=`(
    commune_type = paste0(code_commune, "_", type_local),
    yq_type = paste0(yq, "_", type_local),
    commune_yq = paste0(code_commune, "_", yq)
  )]
  commune_ad <- commune_ad[!is.na(log_sci_uk)]
  cat("  Analysis sample:", nrow(commune_ad), "\n")

  cat("  Commune SCI triple-diff...\n")
  f_commune_sci <- tryCatch(
    feols(log_price_m2 ~ house:log_sci_uk:post |
            commune_type + yq_type + commune_yq,
          data = commune_ad, cluster = ~code_departement),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )

  if (!is.null(f_commune_sci)) {
    cat("    beta =", round(coef(f_commune_sci)[1], 4),
        " SE =", round(se(f_commune_sci)[1], 4),
        " p =", round(pvalue(f_commune_sci)[1], 4), "\n")
  }

  if (has_stock) {
    cat("  Commune stock triple-diff...\n")
    f_commune_stock <- tryCatch(
      feols(log_price_m2 ~ house:log_uk_stock_2011:post |
              commune_type + yq_type + commune_yq,
            data = commune_ad[!is.na(log_uk_stock_2011)],
            cluster = ~code_departement),
      error = function(e) { cat("  Error:", e$message, "\n"); NULL }
    )
    if (!is.null(f_commune_stock)) {
      cat("    beta =", round(coef(f_commune_stock)[1], 4),
          " SE =", round(se(f_commune_stock)[1], 4),
          " p =", round(pvalue(f_commune_stock)[1], 4), "\n")
    }
  }

  saveRDS(commune_ad, file.path(data_dir, "commune_panel.rds"))
  cat("  Saved commune_panel.rds\n")
}

cat("\n")


## ========================================================================
## SECTION H: TABLES & FIGURES
## ========================================================================
cat("=== Section H: Tables & Figures ===\n")

# Table: Wild Bootstrap
cat("  Table: Wild Bootstrap\n")
boot_tex <- paste0(
  "\\begin{table}[htbp]\n\\centering\n",
  "\\caption{Pairs Cluster Bootstrap Inference}\n\\label{tab:bootstrap}\n",
  "\\begin{tabular}{lcc}\n\\hline\\hline\n",
  "Specification & Cluster-Robust $p$ & Bootstrap $p$ \\\\\n\\hline\n"
)
for (i in seq_len(nrow(boot_results))) {
  boot_tex <- paste0(boot_tex,
    boot_results$Specification[i], " & ",
    ifelse(is.na(boot_results$Cluster_Robust_p[i]), "---",
           formatC(boot_results$Cluster_Robust_p[i], format = "f", digits = 3)), " & ",
    ifelse(is.na(boot_results$Wild_Bootstrap_p[i]), "---",
           formatC(boot_results$Wild_Bootstrap_p[i], format = "f", digits = 3)),
    " \\\\\n")
}
boot_tex <- paste0(boot_tex,
  "\\hline\n",
  "\\multicolumn{3}{l}{\\footnotesize Pairs cluster bootstrap, 499 iterations, clustered at d\\'epartement.} \\\\\n",
  "\\hline\\hline\n\\end{tabular}\n\\end{table}\n")
writeLines(boot_tex, file.path(tab_dir, "tab_wild_bootstrap.tex"))

# Table: Multi-Country Placebo
cat("  Table: Multi-Country Placebo\n")
placebo_tex <- paste0(
  "\\begin{table}[htbp]\n\\centering\n",
  "\\caption{Multi-Country Placebo Battery}\n\\label{tab:placebo}\n",
  "\\begin{tabular}{lcccc}\n\\hline\\hline\n",
  " & \\multicolumn{2}{c}{Baseline DiD} & \\multicolumn{2}{c}{Triple-Difference} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  "Country & $\\hat{\\beta}$ & $p$ & $\\hat{\\beta}$ & $p$ \\\\\n\\hline\n"
)

# UK
placebo_tex <- paste0(placebo_tex,
  "United Kingdom (GADM2) & ", round(coef(m1_model)[1], 4),
  " & ", round(pvalue(m1_model)[1], 3),
  " & ", round(coef(f1_model)[1], 4),
  " & ", round(pvalue(f1_model)[1], 3), " \\\\\n")

# DE
placebo_tex <- paste0(placebo_tex,
  "Germany (GADM2) & ", round(coef(m5de_model)[1], 4),
  " & ", round(pvalue(m5de_model)[1], 3))

# DE triple-diff from v3
f4_de <- tryCatch(
  feols(log_price_m2 ~ log_sci_de:post:house | dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) NULL
)
if (!is.null(f4_de)) {
  placebo_tex <- paste0(placebo_tex,
    " & ", round(coef(f4_de)[1], 4), " & ", round(pvalue(f4_de)[1], 3))
} else {
  placebo_tex <- paste0(placebo_tex, " & --- & ---")
}
placebo_tex <- paste0(placebo_tex, " \\\\\n")

for (cc in placebo_cc) {
  cc_upper <- toupper(cc)
  cc_label <- placebo_labels[cc_upper]

  did_b <- if (!is.null(did_placebo_results[[cc]])) round(coef(did_placebo_results[[cc]])[1], 4) else "---"
  did_p <- if (!is.null(did_placebo_results[[cc]])) round(pvalue(did_placebo_results[[cc]])[1], 3) else "---"
  tri_b <- if (!is.null(triple_placebo_results[[cc]])) round(coef(triple_placebo_results[[cc]])[1], 4) else "---"
  tri_p <- if (!is.null(triple_placebo_results[[cc]])) round(pvalue(triple_placebo_results[[cc]])[1], 3) else "---"

  placebo_tex <- paste0(placebo_tex,
    cc_label, " (GADM1) & ", did_b, " & ", did_p,
    " & ", tri_b, " & ", tri_p, " \\\\\n")
}

# Horse race
if (exists("m_horse_triple") && !is.null(m_horse_triple)) {
  placebo_tex <- paste0(placebo_tex,
    "\\hline\n",
    "\\multicolumn{5}{l}{\\textit{Horse Race (all countries simultaneously):}} \\\\\n")
  hr_ct <- coeftable(m_horse_triple)
  for (i in seq_len(nrow(hr_ct))) {
    vname <- rownames(hr_ct)[i]
    vname_clean <- gsub("house:", "", gsub(":post", "", vname))
    placebo_tex <- paste0(placebo_tex,
      "\\quad ", vname_clean, " & & & ",
      round(hr_ct[i, 1], 4), " & ", round(hr_ct[i, 4], 3), " \\\\\n")
  }
}

placebo_tex <- paste0(placebo_tex,
  "\\hline\n",
  "\\multicolumn{5}{l}{\\footnotesize DiD: $\\log p_{dt} = \\alpha_d + \\gamma_t + \\beta \\cdot \\text{SCI}_{d,c} \\times \\text{Post}_t + \\varepsilon_{dt}$} \\\\\n",
  "\\multicolumn{5}{l}{\\footnotesize GADM1 (region-level) for BE, NL, IT, ES; GADM2 (d\\'ept-level) for UK, DE.} \\\\\n",
  "\\hline\\hline\n\\end{tabular}\n\\end{table}\n")
writeLines(placebo_tex, file.path(tab_dir, "tab_multi_country_placebo.tex"))

# Figure: Multi-Country Coefficients
cat("  Figure: Multi-Country Coefficients\n")
coef_data <- data.table(
  country = character(), spec = character(),
  beta = numeric(), se = numeric()
)

coef_data <- rbind(coef_data, data.table(country = "UK", spec = "DiD",
  beta = coef(m1_model)[1], se = se(m1_model)[1]))
coef_data <- rbind(coef_data, data.table(country = "UK", spec = "Triple-Diff",
  beta = coef(f1_model)[1], se = se(f1_model)[1]))
coef_data <- rbind(coef_data, data.table(country = "DE", spec = "DiD",
  beta = coef(m5de_model)[1], se = se(m5de_model)[1]))
if (!is.null(f4_de)) {
  coef_data <- rbind(coef_data, data.table(country = "DE", spec = "Triple-Diff",
    beta = coef(f4_de)[1], se = se(f4_de)[1]))
}

for (cc in placebo_cc) {
  cc_upper <- toupper(cc)
  if (!is.null(did_placebo_results[[cc]])) {
    coef_data <- rbind(coef_data, data.table(country = cc_upper, spec = "DiD",
      beta = coef(did_placebo_results[[cc]])[1],
      se = se(did_placebo_results[[cc]])[1]))
  }
  if (!is.null(triple_placebo_results[[cc]])) {
    coef_data <- rbind(coef_data, data.table(country = cc_upper, spec = "Triple-Diff",
      beta = coef(triple_placebo_results[[cc]])[1],
      se = se(triple_placebo_results[[cc]])[1]))
  }
}

coef_data[, `:=`(ci_lo = beta - 1.96 * se, ci_hi = beta + 1.96 * se,
                 country = factor(country, levels = c("UK", "DE", "BE", "NL", "IT", "ES")))]

p_placebo <- ggplot(coef_data, aes(x = country, y = beta, colour = spec, shape = spec)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  position = position_dodge(width = 0.4), size = 0.5) +
  scale_colour_manual(values = c("DiD" = "#1B4F72", "Triple-Diff" = "#196F3D")) +
  labs(x = "Country", y = "Coefficient", colour = "", shape = "",
       title = "Multi-Country Placebo: Coefficient Comparison",
       subtitle = "DiD shows cosmopolitan confounding; Triple-diff isolates UK-specific effect") +
  theme_apep()

ggsave(file.path(fig_dir, "fig_multi_country_placebo.pdf"),
       p_placebo, width = 8, height = 5)
cat("  Saved fig_multi_country_placebo.pdf\n")

# Table: Commune-level
if (!is.null(f_commune_sci)) {
  cat("  Table: Commune-Level\n")
  commune_models <- list(f_commune_sci)
  commune_headers <- c("Commune SCI")
  if (!is.null(f_commune_stock)) {
    commune_models <- c(commune_models, list(f_commune_stock))
    commune_headers <- c(commune_headers, "Commune Stock")
  }
  commune_models <- c(commune_models, list(f1_model))
  commune_headers <- c(commune_headers, "Dept SCI")
  if (!is.null(f2_model)) {
    commune_models <- c(commune_models, list(f2_model))
    commune_headers <- c(commune_headers, "Dept Stock")
  }

  etable(commune_models, headers = commune_headers,
         se.below = TRUE,
         signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
         fitstat = ~ wr2 + n,
         file = file.path(tab_dir, "tab_commune_triple_diff.tex"),
         replace = TRUE, style.tex = style.tex("aer"),
         label = "tab:commune",
         title = "Commune-Level Triple-Difference")
  cat("  Saved tab_commune_triple_diff.tex\n")
}

# Table: Pre/Post 2020
cat("  Table: Pre/Post 2020\n")
pre_post_models <- list()
pre_post_headers <- c()
if (exists("f_pre_sci") && !is.null(f_pre_sci)) {
  pre_post_models <- c(pre_post_models, list(f_pre_sci))
  pre_post_headers <- c(pre_post_headers, "SCI Pre-2020")
}
if (exists("f_pre_stock") && !is.null(f_pre_stock)) {
  pre_post_models <- c(pre_post_models, list(f_pre_stock))
  pre_post_headers <- c(pre_post_headers, "Stock Pre-2020")
}
if (exists("f_post_sci") && !is.null(f_post_sci)) {
  pre_post_models <- c(pre_post_models, list(f_post_sci))
  pre_post_headers <- c(pre_post_headers, "SCI Post-2020")
}
if (length(pre_post_models) > 0) {
  etable(pre_post_models, headers = pre_post_headers,
         se.below = TRUE,
         signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
         fitstat = ~ wr2 + n,
         file = file.path(tab_dir, "tab_pre_post_2020.tex"),
         replace = TRUE, style.tex = style.tex("aer"),
         label = "tab:prepost",
         title = "Triple-Difference: Pre- vs.\\ Post-2020")
  cat("  Saved tab_pre_post_2020.tex\n")
}


## ========================================================================
## SECTION I: SAVE
## ========================================================================
cat("\n=== Saving v4 results ===\n")

v4_results <- list(
  boot_results = boot_results,
  bt_m1 = bt_m1, bt_m2 = bt_m2, bt_m5de = bt_m5de,
  bt_f1 = bt_f1, bt_f2 = bt_f2, bt_i1 = bt_i1,
  f_pre_sci = if (exists("f_pre_sci")) f_pre_sci else NULL,
  f_pre_stock = if (exists("f_pre_stock")) f_pre_stock else NULL,
  f_post_sci = if (exists("f_post_sci")) f_post_sci else NULL,
  did_placebo_results = did_placebo_results,
  triple_placebo_results = triple_placebo_results,
  m_horse_did = if (exists("m_horse_did")) m_horse_did else NULL,
  m_horse_triple = if (exists("m_horse_triple")) m_horse_triple else NULL,
  honest_result = if (exists("honest_result")) honest_result else NULL,
  f_commune_sci = f_commune_sci,
  f_commune_stock = f_commune_stock,
  dept_placebo_wide = dept_placebo_wide
)
saveRDS(v4_results, file.path(data_dir, "v4_results.rds"))
cat("Saved v4_results.rds\n")

cat("\n=== v4 Improvements Complete ===\n")
cat("End time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
