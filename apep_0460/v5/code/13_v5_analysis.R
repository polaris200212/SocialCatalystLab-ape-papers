## ============================================================================
## 13_v5_analysis.R — v5 Reframing: Cosmopolitan Confounding Diagnosis
## APEP-0460 v5
##
## New analyses:
##   A. Epoch Decomposition (pre-COVID vs post-COVID Brexit coefficients)
##   B. GADM1 Symmetric Placebos (harmonize UK/DE to GADM1 level)
##   C. COVID Disentanglement (WFH proxy, Channel distance)
##   D. Choropleth Map (UK census stock / SCI across départements)
##   E. Updated Tables & Figures
## ============================================================================

cat("=== APEP-0460 v5 Analysis ===\n")
cat("Start time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

## ========================================================================
## SECTION 0: SETUP
## ========================================================================
cat("=== Section 0: Setup ===\n")

library(data.table)
library(fixest)
library(ggplot2)
library(patchwork)
library(readxl)
library(sf)

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

## --- Load data ---
cat("Loading data...\n")
panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))
dept_exposure <- as.data.table(readRDS(file.path(data_dir, "dept_exposure.rds")))
type_panel <- as.data.table(readRDS(file.path(data_dir, "property_type_panel.rds")))
v3_results <- readRDS(file.path(data_dir, "v3_results.rds"))
v4_results <- readRDS(file.path(data_dir, "v4_results.rds"))

# Reconstruct analysis samples (same as v4 script)
ad <- panel[!is.na(log_price_m2) & !is.na(sci_total_uk) & n_transactions >= 5]
ad[, fr_region := code_departement]
ad[, post := as.integer(year > 2016 | (year == 2016 & quarter >= 3))]
ad[, time_trend := as.numeric(factor(yq, levels = sort(unique(yq))))]
ad[, t := (year - 2014) * 4 + quarter]
ref_t_val <- ad[year == 2016 & quarter == 2, unique(t)][1]
ad[, ref_period := t - ref_t_val]

# Merge census stock
if (!"log_uk_stock_2011" %in% names(ad)) {
  cat("  Reconstructing census stock...\n")
  insee_file <- file.path(data_dir, "ip1809.xlsx")
  if (file.exists(insee_file)) {
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
      saveRDS(dept_uk_census, file.path(data_dir, "dept_uk_census.rds"))
    }
  }
}

# Residualized SCI
if (!"resid_sci_uk" %in% names(ad)) {
  cat("  Reconstructing residualized SCI...\n")
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
  dept_chars[is.na(resid_sci_uk), resid_sci_uk := 0]
  ad <- merge(ad, dept_chars[, .(code_departement, resid_sci_uk)],
              by = "code_departement", all.x = TRUE)
}

has_stock <- "log_uk_stock_2011" %in% names(ad)
has_resid <- "resid_sci_uk" %in% names(ad)
cat("  Has census stock:", has_stock, "\n")
cat("  Has residualized SCI:", has_resid, "\n")

# Property-type panel
prop_ad <- type_panel[!is.na(log_price_m2) & !is.na(log_sci_uk) & n_transactions >= 5]
prop_ad[, fr_region := code_departement]
prop_ad[, t := (year - 2014) * 4 + quarter]
prop_ad[, ref_period := t - ref_t_val]
prop_ad[, yr := as.integer(substr(yq, 1, 4))]

# Merge census stock onto property-type panel
if (has_stock && !"log_uk_stock_2011" %in% names(prop_ad)) {
  census_file <- file.path(data_dir, "dept_uk_census.rds")
  if (file.exists(census_file)) {
    dept_uk_census <- readRDS(census_file)
    prop_ad <- merge(prop_ad, dept_uk_census[, .(code_departement, log_uk_stock_2011)],
                     by = "code_departement", all.x = TRUE)
  }
}

cat("  Analysis sample:", nrow(ad), "obs\n")
cat("  Property-type sample:", nrow(prop_ad), "obs\n\n")


## ========================================================================
## SECTION A: EPOCH DECOMPOSITION
## ========================================================================
cat("=== Section A: Epoch Decomposition ===\n")
cat("  Creating epoch indicators...\n")

# Epoch 1: Brexit referendum to COVID (2016-Q3 to 2019-Q4)
# Epoch 2: COVID onwards (2020-Q1+)
ad[, epoch_brexit := as.integer(post == 1 & year < 2020)]
ad[, epoch_covid  := as.integer(year >= 2020)]

prop_ad[, epoch_brexit := as.integer(post == 1 & yr < 2020)]
prop_ad[, epoch_covid  := as.integer(yr >= 2020)]

cat("  Epoch counts (DiD panel):\n")
cat("    Pre-referendum:", sum(ad$post == 0), "\n")
cat("    Brexit epoch (2016Q3-2019Q4):", sum(ad$epoch_brexit == 1), "\n")
cat("    COVID epoch (2020Q1+):", sum(ad$epoch_covid == 1), "\n")

# A1: DiD with epoch interactions — SCI
cat("\n  A1: SCI epoch decomposition (DiD)\n")
m_epoch_sci <- feols(log_price_m2 ~ log_sci_uk:epoch_brexit + log_sci_uk:epoch_covid |
                       fr_region + yq,
                     data = ad, cluster = ~fr_region)
cat("    Brexit epoch: beta =", round(coef(m_epoch_sci)[1], 5),
    " p =", round(pvalue(m_epoch_sci)[1], 4), "\n")
cat("    COVID epoch:  beta =", round(coef(m_epoch_sci)[2], 5),
    " p =", round(pvalue(m_epoch_sci)[2], 4), "\n")

# A2: DiD with epoch interactions — Census stock
if (has_stock) {
  cat("\n  A2: Census stock epoch decomposition (DiD)\n")
  m_epoch_stock <- feols(log_price_m2 ~ log_uk_stock_2011:epoch_brexit +
                           log_uk_stock_2011:epoch_covid |
                           fr_region + yq,
                         data = ad, cluster = ~fr_region)
  cat("    Brexit epoch: beta =", round(coef(m_epoch_stock)[1], 5),
      " p =", round(pvalue(m_epoch_stock)[1], 4), "\n")
  cat("    COVID epoch:  beta =", round(coef(m_epoch_stock)[2], 5),
      " p =", round(pvalue(m_epoch_stock)[2], 4), "\n")
} else {
  m_epoch_stock <- NULL
}

# A3: Triple-diff with epoch interactions — SCI
cat("\n  A3: SCI epoch decomposition (Triple-Diff)\n")
m_epoch_triple_sci <- tryCatch(
  feols(log_price_m2 ~ log_sci_uk:house:epoch_brexit + log_sci_uk:house:epoch_covid |
          dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)
if (!is.null(m_epoch_triple_sci)) {
  cat("    Brexit epoch: beta =", round(coef(m_epoch_triple_sci)[1], 5),
      " p =", round(pvalue(m_epoch_triple_sci)[1], 4), "\n")
  cat("    COVID epoch:  beta =", round(coef(m_epoch_triple_sci)[2], 5),
      " p =", round(pvalue(m_epoch_triple_sci)[2], 4), "\n")
}

# A4: Triple-diff with epoch interactions — Census stock
if (has_stock) {
  cat("\n  A4: Census stock epoch decomposition (Triple-Diff)\n")
  m_epoch_triple_stock <- tryCatch(
    feols(log_price_m2 ~ log_uk_stock_2011:house:epoch_brexit +
            log_uk_stock_2011:house:epoch_covid |
            dept_type + yq_type + dept_yq,
          data = prop_ad[!is.na(log_uk_stock_2011)], cluster = ~fr_region),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(m_epoch_triple_stock)) {
    cat("    Brexit epoch: beta =", round(coef(m_epoch_triple_stock)[1], 5),
        " p =", round(pvalue(m_epoch_triple_stock)[1], 4), "\n")
    cat("    COVID epoch:  beta =", round(coef(m_epoch_triple_stock)[2], 5),
        " p =", round(pvalue(m_epoch_triple_stock)[2], 4), "\n")
  }
} else {
  m_epoch_triple_stock <- NULL
}

# A5: German epoch decomposition (diagnostic — does DE show same pattern?)
cat("\n  A5: German SCI epoch decomposition (DiD diagnostic)\n")
m_epoch_de <- feols(log_price_m2 ~ log_sci_de:epoch_brexit + log_sci_de:epoch_covid |
                      fr_region + yq,
                    data = ad, cluster = ~fr_region)
cat("    DE Brexit epoch: beta =", round(coef(m_epoch_de)[1], 5),
    " p =", round(pvalue(m_epoch_de)[1], 4), "\n")
cat("    DE COVID epoch:  beta =", round(coef(m_epoch_de)[2], 5),
    " p =", round(pvalue(m_epoch_de)[2], 4), "\n")

# German triple-diff epoch
cat("\n  A6: German SCI epoch decomposition (Triple-Diff diagnostic)\n")
m_epoch_triple_de <- tryCatch(
  feols(log_price_m2 ~ log_sci_de:house:epoch_brexit + log_sci_de:house:epoch_covid |
          dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)
if (!is.null(m_epoch_triple_de)) {
  cat("    DE Brexit epoch: beta =", round(coef(m_epoch_triple_de)[1], 5),
      " p =", round(pvalue(m_epoch_triple_de)[1], 4), "\n")
  cat("    DE COVID epoch:  beta =", round(coef(m_epoch_triple_de)[2], 5),
      " p =", round(pvalue(m_epoch_triple_de)[2], 4), "\n")
}

# Table: Epoch Decomposition
cat("\n  Generating epoch decomposition table...\n")
epoch_tex <- paste0(
  "\\begin{table}[htbp]\n\\centering\n",
  "\\caption{Epoch Decomposition: Brexit vs.\\ COVID Periods}\n",
  "\\label{tab:epoch}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lcccc}\n\\toprule\n",
  " & \\multicolumn{2}{c}{Baseline DiD} & \\multicolumn{2}{c}{Triple-Difference} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  " & SCI & Census Stock & SCI & Census Stock \\\\\n",
  " & (1) & (2) & (3) & (4) \\\\\n",
  "\\midrule\n"
)

# SCI DiD epochs
epoch_tex <- paste0(epoch_tex,
  "\\textit{Brexit Epoch} & & & & \\\\\n",
  "\\quad Exposure $\\times$ Post$_{2016\\text{Q3}-2019\\text{Q4}}$ & ",
  formatC(coef(m_epoch_sci)[1], format = "f", digits = 4), " & ")
if (has_stock) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_stock)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " & ")
if (!is.null(m_epoch_triple_sci)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_sci)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " & ")
if (!is.null(m_epoch_triple_stock)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_stock)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " \\\\\n")

# SEs for Brexit epoch
epoch_tex <- paste0(epoch_tex, " & (",
  formatC(se(m_epoch_sci)[1], format = "f", digits = 4), ") & (")
if (has_stock) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_stock)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") & (")
if (!is.null(m_epoch_triple_sci)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_sci)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") & (")
if (!is.null(m_epoch_triple_stock)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_stock)[1], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") \\\\\n")

# COVID epoch
epoch_tex <- paste0(epoch_tex,
  "\\textit{COVID Epoch} & & & & \\\\\n",
  "\\quad Exposure $\\times$ Post$_{2020\\text{Q1}+}$ & ",
  formatC(coef(m_epoch_sci)[2], format = "f", digits = 4), " & ")
if (has_stock) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_stock)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " & ")
if (!is.null(m_epoch_triple_sci)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_sci)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " & ")
if (!is.null(m_epoch_triple_stock)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_stock)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, " \\\\\n")

# SEs for COVID epoch
epoch_tex <- paste0(epoch_tex, " & (",
  formatC(se(m_epoch_sci)[2], format = "f", digits = 4), ") & (")
if (has_stock) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_stock)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") & (")
if (!is.null(m_epoch_triple_sci)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_sci)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") & (")
if (!is.null(m_epoch_triple_stock)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_stock)[2], format = "f", digits = 4))
} else {
  epoch_tex <- paste0(epoch_tex, "---")
}
epoch_tex <- paste0(epoch_tex, ") \\\\\n")

# German diagnostic
epoch_tex <- paste0(epoch_tex,
  "\\midrule\n",
  "\\textit{German Placebo} & & & & \\\\\n",
  "\\quad DE SCI $\\times$ Post$_{2016\\text{Q3}-2019\\text{Q4}}$ & ",
  formatC(coef(m_epoch_de)[1], format = "f", digits = 4),
  " & & ")
if (!is.null(m_epoch_triple_de)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_de)[1], format = "f", digits = 4))
}
epoch_tex <- paste0(epoch_tex, " & \\\\\n")

epoch_tex <- paste0(epoch_tex, " & (",
  formatC(se(m_epoch_de)[1], format = "f", digits = 4),
  ") & & (")
if (!is.null(m_epoch_triple_de)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_de)[1], format = "f", digits = 4))
}
epoch_tex <- paste0(epoch_tex, ") & \\\\\n")

epoch_tex <- paste0(epoch_tex,
  "\\quad DE SCI $\\times$ Post$_{2020\\text{Q1}+}$ & ",
  formatC(coef(m_epoch_de)[2], format = "f", digits = 4),
  " & & ")
if (!is.null(m_epoch_triple_de)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(coef(m_epoch_triple_de)[2], format = "f", digits = 4))
}
epoch_tex <- paste0(epoch_tex, " & \\\\\n")

epoch_tex <- paste0(epoch_tex, " & (",
  formatC(se(m_epoch_de)[2], format = "f", digits = 4),
  ") & & (")
if (!is.null(m_epoch_triple_de)) {
  epoch_tex <- paste0(epoch_tex,
    formatC(se(m_epoch_triple_de)[2], format = "f", digits = 4))
}
epoch_tex <- paste0(epoch_tex, ") & \\\\\n")

epoch_tex <- paste0(epoch_tex,
  "\\midrule\n",
  "Observations & ", format(nrow(ad), big.mark = ","),
  " & ", format(nrow(ad[!is.na(log_uk_stock_2011)]), big.mark = ","),
  " & ", format(nrow(prop_ad), big.mark = ","),
  " & ", format(nrow(prop_ad[!is.na(log_uk_stock_2011)]), big.mark = ","),
  " \\\\\n",
  "D\\'epartement FE / Quarter FE & Yes & Yes & --- & --- \\\\\n",
  "Dept$\\times$Type / Quarter$\\times$Type / Dept$\\times$Quarter & --- & --- & Yes & Yes \\\\\n",
  "\\bottomrule\n\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\\footnotesize\n",
  "\\item \\textit{Notes:} Standard errors clustered at the d\\'epartement level in parentheses. ",
  "Brexit epoch: 2016-Q3 through 2019-Q4. COVID epoch: 2020-Q1 onward. ",
  "The decomposition tests whether the SCI/stock effect concentrates in the immediate ",
  "post-referendum period or the post-COVID period.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n\\end{table}\n")

writeLines(epoch_tex, file.path(tab_dir, "tab_epoch_decomposition.tex"))
cat("  Saved tab_epoch_decomposition.tex\n\n")


## ========================================================================
## SECTION B: GADM1 SYMMETRIC PLACEBOS
## ========================================================================
cat("=== Section B: GADM1 Symmetric Placebos ===\n")

# The key issue: UK and DE placebos used GADM2 SCI (département-level),
# while BE/NL/IT/ES used GADM1 SCI (region-level).
# To make apples-to-apples comparison: aggregate UK and DE GADM2 SCI up to GADM1.

gadm1_path <- file.path(data_dir, "gadm1.csv")
gadm2_map <- fread(file.path(data_dir, "gadm2_dept_mapping.csv"))

# Extract GADM1 region from GADM2 code: FRA.X.Y_1 -> FRA.X_1
gadm2_map[, gadm1_region_num := as.integer(gsub("FRA\\.(\\d+)\\..*", "\\1", fr_gadm2))]
gadm2_map[, gadm1_region := paste0("FRA.", gadm1_region_num, "_1")]

cat("  GADM2 -> GADM1 mapping: ", nrow(gadm2_map), " départements across ",
    uniqueN(gadm2_map$gadm1_region), " GADM1 regions\n")

# Read GADM1 data for all relevant countries
all_countries <- c("GB", "DE", "BE", "NL", "IT", "ES")

cat("  Reading GADM1 SCI data for all countries...\n")
gadm1_fr <- fread(
  cmd = paste0("grep '^FR,' ", gadm1_path),
  header = FALSE,
  col.names = c("user_country", "friend_country", "user_region",
                "friend_region", "scaled_sci")
)
gadm1_fr <- gadm1_fr[friend_country %in% all_countries &
                       grepl("^FRA\\.", user_region)]
cat("  Filtered GADM1 rows:", nrow(gadm1_fr), "\n")

# Aggregate: sum SCI across friend regions within each country, for each FR GADM1 region
gadm1_agg <- gadm1_fr[, .(sci_total = sum(scaled_sci, na.rm = TRUE)),
                       by = .(user_region, friend_country)]

# Map to départements via GADM1 region
# Each département gets its GADM1 region's aggregated SCI
dept_gadm1_sci <- merge(
  gadm2_map[, .(code_departement, gadm1_region)],
  gadm1_agg,
  by.x = "gadm1_region", by.y = "user_region",
  allow.cartesian = TRUE
)

dept_gadm1_wide <- dcast(dept_gadm1_sci,
                         code_departement ~ friend_country,
                         value.var = "sci_total", fun.aggregate = sum)

# Create log versions
for (cc in all_countries) {
  log_col <- paste0("log_sci_gadm1_", tolower(cc))
  dept_gadm1_wide[, (log_col) := log(get(cc) + 1)]
}

cat("  GADM1-harmonized SCI computed for", nrow(dept_gadm1_wide), "départements\n")
cat("  Countries:", paste(all_countries, collapse = ", "), "\n")

# Merge onto analysis panels
gadm1_merge_cols <- c("code_departement",
                      grep("log_sci_gadm1", names(dept_gadm1_wide), value = TRUE))
ad <- merge(ad, dept_gadm1_wide[, ..gadm1_merge_cols],
            by = "code_departement", all.x = TRUE)
prop_ad <- merge(prop_ad, dept_gadm1_wide[, ..gadm1_merge_cols],
                 by = "code_departement", all.x = TRUE)

# B1: GADM1-harmonized DiD placebos
cat("\n  --- B1: GADM1-Harmonized DiD Placebos ---\n")
gadm1_did_results <- list()
for (cc in tolower(all_countries)) {
  var_name <- paste0("log_sci_gadm1_", cc)
  if (!var_name %in% names(ad)) next
  fml <- as.formula(paste0("log_price_m2 ~ ", var_name, ":post | fr_region + yq"))
  m_cc <- tryCatch(feols(fml, data = ad, cluster = ~fr_region),
                   error = function(e) NULL)
  if (!is.null(m_cc)) {
    sig_star <- ifelse(pvalue(m_cc)[1] < 0.01, "***",
                  ifelse(pvalue(m_cc)[1] < 0.05, "**",
                    ifelse(pvalue(m_cc)[1] < 0.1, "*", "")))
    cat("  ", toupper(cc), "(GADM1) DiD: beta =", round(coef(m_cc)[1], 4),
        " SE =", round(se(m_cc)[1], 4),
        " p =", round(pvalue(m_cc)[1], 4), sig_star, "\n")
    gadm1_did_results[[cc]] <- m_cc
  }
}

# B2: GADM1-harmonized Triple-Diff placebos
cat("\n  --- B2: GADM1-Harmonized Triple-Diff Placebos ---\n")
gadm1_triple_results <- list()
for (cc in tolower(all_countries)) {
  var_name <- paste0("log_sci_gadm1_", cc)
  if (!var_name %in% names(prop_ad)) next
  fml <- as.formula(paste0("log_price_m2 ~ house:", var_name, ":post | ",
                           "dept_type + yq_type + dept_yq"))
  f_cc <- tryCatch(feols(fml, data = prop_ad, cluster = ~fr_region),
                   error = function(e) NULL)
  if (!is.null(f_cc)) {
    sig_star <- ifelse(pvalue(f_cc)[1] < 0.01, "***",
                  ifelse(pvalue(f_cc)[1] < 0.05, "**",
                    ifelse(pvalue(f_cc)[1] < 0.1, "*", "")))
    cat("  ", toupper(cc), "(GADM1) Triple-Diff: beta =", round(coef(f_cc)[1], 4),
        " SE =", round(se(f_cc)[1], 4),
        " p =", round(pvalue(f_cc)[1], 4), sig_star, "\n")
    gadm1_triple_results[[cc]] <- f_cc
  }
}

# B3: GADM1-harmonized horse race (all countries at GADM1)
cat("\n  --- B3: GADM1-Harmonized Horse Race ---\n")
gadm1_vars <- paste0("log_sci_gadm1_", tolower(all_countries))
avail <- sapply(gadm1_vars, function(v) v %in% names(ad))

if (all(avail)) {
  # DiD horse race
  fml_horse_did <- as.formula(paste0(
    "log_price_m2 ~ ",
    paste0(gadm1_vars, ":post", collapse = " + "),
    " | fr_region + yq"
  ))
  m_gadm1_horse_did <- tryCatch(
    feols(fml_horse_did, data = ad, cluster = ~fr_region),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(m_gadm1_horse_did)) {
    cat("  GADM1 DiD Horse Race:\n")
    print(coeftable(m_gadm1_horse_did))
  }

  # Triple-diff horse race
  gadm1_vars_prop <- paste0("log_sci_gadm1_", tolower(all_countries))
  avail_prop <- sapply(gadm1_vars_prop, function(v) v %in% names(prop_ad))
  if (all(avail_prop)) {
    fml_horse_triple <- as.formula(paste0(
      "log_price_m2 ~ ",
      paste0("house:", gadm1_vars_prop, ":post", collapse = " + "),
      " | dept_type + yq_type + dept_yq"
    ))
    m_gadm1_horse_triple <- tryCatch(
      feols(fml_horse_triple, data = prop_ad, cluster = ~fr_region),
      error = function(e) { cat("  Error:", e$message, "\n"); NULL }
    )
    if (!is.null(m_gadm1_horse_triple)) {
      cat("\n  GADM1 Triple-Diff Horse Race:\n")
      print(coeftable(m_gadm1_horse_triple))
    }
  } else {
    m_gadm1_horse_triple <- NULL
  }
} else {
  m_gadm1_horse_did <- NULL
  m_gadm1_horse_triple <- NULL
}

# Table: GADM1-Harmonized Placebos
cat("\n  Generating GADM1 placebo table...\n")
country_labels <- c(gb = "United Kingdom", de = "Germany", be = "Belgium",
                    nl = "Netherlands", it = "Italy", es = "Spain")

gadm1_tab_tex <- paste0(
  "\\begin{table}[htbp]\n\\centering\n",
  "\\caption{GADM1-Harmonized Multi-Country Placebo Battery}\n",
  "\\label{tab:gadm1placebo}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lcccc}\n\\toprule\n",
  " & \\multicolumn{2}{c}{Baseline DiD} & \\multicolumn{2}{c}{Triple-Difference} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  "Country (GADM1) & $\\hat{\\beta}$ & SE & $\\hat{\\beta}$ & SE \\\\\n",
  "\\midrule\n"
)

for (cc in tolower(all_countries)) {
  label <- country_labels[cc]
  did_b <- if (!is.null(gadm1_did_results[[cc]])) formatC(coef(gadm1_did_results[[cc]])[1], format = "f", digits = 4) else "---"
  did_se <- if (!is.null(gadm1_did_results[[cc]])) formatC(se(gadm1_did_results[[cc]])[1], format = "f", digits = 4) else "---"
  did_star <- ""
  if (!is.null(gadm1_did_results[[cc]])) {
    p <- pvalue(gadm1_did_results[[cc]])[1]
    did_star <- ifelse(p < 0.01, "$^{***}$", ifelse(p < 0.05, "$^{**}$", ifelse(p < 0.1, "$^{*}$", "")))
  }
  tri_b <- if (!is.null(gadm1_triple_results[[cc]])) formatC(coef(gadm1_triple_results[[cc]])[1], format = "f", digits = 4) else "---"
  tri_se <- if (!is.null(gadm1_triple_results[[cc]])) formatC(se(gadm1_triple_results[[cc]])[1], format = "f", digits = 4) else "---"
  tri_star <- ""
  if (!is.null(gadm1_triple_results[[cc]])) {
    p <- pvalue(gadm1_triple_results[[cc]])[1]
    tri_star <- ifelse(p < 0.01, "$^{***}$", ifelse(p < 0.05, "$^{**}$", ifelse(p < 0.1, "$^{*}$", "")))
  }

  bold_open <- ifelse(cc == "gb", "\\textbf{", "")
  bold_close <- ifelse(cc == "gb", "}", "")

  gadm1_tab_tex <- paste0(gadm1_tab_tex,
    bold_open, label, bold_close, " & ",
    bold_open, did_b, did_star, bold_close, " & (",
    did_se, ") & ",
    bold_open, tri_b, tri_star, bold_close, " & (",
    tri_se, ") \\\\\n")
}

# Horse race section
if (!is.null(m_gadm1_horse_triple)) {
  gadm1_tab_tex <- paste0(gadm1_tab_tex,
    "\\midrule\n",
    "\\multicolumn{5}{l}{\\textit{Horse Race (all countries simultaneously, Triple-Diff):}} \\\\\n")
  hr_ct <- coeftable(m_gadm1_horse_triple)
  for (i in seq_len(nrow(hr_ct))) {
    vname <- rownames(hr_ct)[i]
    # Clean up variable name
    cc_match <- regmatches(vname, regexpr("gadm1_[a-z]+", vname))
    cc_clean <- toupper(gsub("gadm1_", "", cc_match))
    p <- hr_ct[i, 4]
    star <- ifelse(p < 0.01, "$^{***}$", ifelse(p < 0.05, "$^{**}$", ifelse(p < 0.1, "$^{*}$", "")))
    bold_open <- ifelse(cc_clean == "GB", "\\textbf{", "")
    bold_close <- ifelse(cc_clean == "GB", "}", "")
    gadm1_tab_tex <- paste0(gadm1_tab_tex,
      "\\quad ", bold_open, cc_clean, bold_close,
      " & & & ", bold_open,
      formatC(hr_ct[i, 1], format = "f", digits = 4), star,
      bold_close, " & (", formatC(hr_ct[i, 2], format = "f", digits = 4), ") \\\\\n")
  }
}

gadm1_tab_tex <- paste0(gadm1_tab_tex,
  "\\midrule\n",
  "Observations & \\multicolumn{2}{c}{", format(nrow(ad), big.mark = ","),
  "} & \\multicolumn{2}{c}{", format(nrow(prop_ad), big.mark = ","), "} \\\\\n",
  "\\bottomrule\n\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\\footnotesize\n",
  "\\item \\textit{Notes:} All six countries measured at the same GADM1 (administrative region) level. ",
  "SCI from GADM2 regions aggregated up to GADM1 for UK and Germany to ensure symmetric comparison. ",
  "Standard errors clustered at the d\\'epartement level in parentheses. ",
  "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$. ",
  "UK row in bold.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n\\end{table}\n")

writeLines(gadm1_tab_tex, file.path(tab_dir, "tab_gadm1_symmetric_placebos.tex"))
cat("  Saved tab_gadm1_symmetric_placebos.tex\n")

# Figure: GADM1-Harmonized coefficient comparison
cat("  Generating GADM1-harmonized coefficient figure...\n")
gadm1_coef_data <- data.table(
  country = character(), spec = character(),
  beta = numeric(), se = numeric()
)

for (cc in tolower(all_countries)) {
  cc_upper <- toupper(cc)
  if (!is.null(gadm1_did_results[[cc]])) {
    gadm1_coef_data <- rbind(gadm1_coef_data, data.table(
      country = cc_upper, spec = "DiD",
      beta = coef(gadm1_did_results[[cc]])[1],
      se = se(gadm1_did_results[[cc]])[1]))
  }
  if (!is.null(gadm1_triple_results[[cc]])) {
    gadm1_coef_data <- rbind(gadm1_coef_data, data.table(
      country = cc_upper, spec = "Triple-Diff",
      beta = coef(gadm1_triple_results[[cc]])[1],
      se = se(gadm1_triple_results[[cc]])[1]))
  }
}

gadm1_coef_data[, `:=`(
  ci_lo = beta - 1.96 * se,
  ci_hi = beta + 1.96 * se,
  country = factor(country, levels = c("GB", "DE", "BE", "NL", "IT", "ES"))
)]

p_gadm1 <- ggplot(gadm1_coef_data, aes(x = country, y = beta, colour = spec, shape = spec)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  position = position_dodge(width = 0.4), size = 0.5) +
  scale_colour_manual(values = c("DiD" = "#1B4F72", "Triple-Diff" = "#196F3D")) +
  labs(x = "Country (GADM1-Harmonized SCI)", y = "Coefficient",
       colour = "", shape = "",
       title = "Symmetric Multi-Country Placebo Battery",
       subtitle = "All countries at GADM1 resolution") +
  theme_apep()

ggsave(file.path(fig_dir, "fig_gadm1_symmetric_placebos.pdf"),
       p_gadm1, width = 8, height = 5)
cat("  Saved fig_gadm1_symmetric_placebos.pdf\n\n")


## ========================================================================
## SECTION C: COVID DISENTANGLEMENT
## ========================================================================
cat("=== Section C: COVID Disentanglement ===\n")

# C1: WFH amenity proxy — use population density as inverse WFH amenity
# Départements with lower density are more attractive for WFH migration
# We use baseline (2014-2015) transaction density as a proxy
cat("  C1: WFH Amenity Proxy (Population Density)\n")

# Compute baseline density proxy from transaction count / surface
baseline_density <- ad[year %in% 2014:2015,
                       .(baseline_trans_density = median(n_transactions, na.rm = TRUE)),
                       by = code_departement]
baseline_density[, log_density := log(baseline_trans_density + 1)]
# Rural amenity = inverse density (standardized)
baseline_density[, rural_amenity := -scale(log_density)[, 1]]

ad <- merge(ad, baseline_density[, .(code_departement, rural_amenity, log_density)],
            by = "code_departement", all.x = TRUE)
prop_ad <- merge(prop_ad, baseline_density[, .(code_departement, rural_amenity, log_density)],
                 by = "code_departement", all.x = TRUE)

# Triple-diff with rural amenity control
cat("  Running COVID-controlled triple-diff...\n")
m_covid_control_sci <- tryCatch(
  feols(log_price_m2 ~ log_sci_uk:house:post + rural_amenity:house:epoch_covid |
          dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)
if (!is.null(m_covid_control_sci)) {
  cat("    UK SCI (with rural amenity control): beta =", round(coef(m_covid_control_sci)[1], 4),
      " p =", round(pvalue(m_covid_control_sci)[1], 4), "\n")
  cat("    Rural amenity x COVID: beta =", round(coef(m_covid_control_sci)[2], 4),
      " p =", round(pvalue(m_covid_control_sci)[2], 4), "\n")
}

if (has_stock) {
  m_covid_control_stock <- tryCatch(
    feols(log_price_m2 ~ log_uk_stock_2011:house:post + rural_amenity:house:epoch_covid |
            dept_type + yq_type + dept_yq,
          data = prop_ad[!is.na(log_uk_stock_2011)], cluster = ~fr_region),
    error = function(e) { cat("  Error:", e$message, "\n"); NULL }
  )
  if (!is.null(m_covid_control_stock)) {
    cat("    Census stock (with rural amenity control): beta =",
        round(coef(m_covid_control_stock)[1], 4),
        " p =", round(pvalue(m_covid_control_stock)[1], 4), "\n")
  }
} else {
  m_covid_control_stock <- NULL
}

# C2: Channel proximity control
cat("\n  C2: Channel Proximity Control\n")

# Channel/tunnel proximity — départements near Calais, ferry ports
# Approximate: code_departement for Channel-adjacent départements
channel_adjacent <- c("62", "59", "80", "76", "14", "50", "35", "22", "29")
ad[, channel_proximity := as.integer(code_departement %in% channel_adjacent)]
prop_ad[, channel_proximity := as.integer(code_departement %in% channel_adjacent)]

m_channel_sci <- tryCatch(
  feols(log_price_m2 ~ log_sci_uk:house:post + channel_proximity:house:post |
          dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)
if (!is.null(m_channel_sci)) {
  cat("    UK SCI (with Channel control): beta =", round(coef(m_channel_sci)[1], 4),
      " p =", round(pvalue(m_channel_sci)[1], 4), "\n")
  cat("    Channel proximity: beta =", round(coef(m_channel_sci)[2], 4),
      " p =", round(pvalue(m_channel_sci)[2], 4), "\n")
}

# C3: Combined — all COVID controls
cat("\n  C3: Combined COVID controls\n")
m_combined <- tryCatch(
  feols(log_price_m2 ~ log_sci_uk:house:post +
          rural_amenity:house:epoch_covid +
          channel_proximity:house:post |
          dept_type + yq_type + dept_yq,
        data = prop_ad, cluster = ~fr_region),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)
if (!is.null(m_combined)) {
  cat("    UK SCI (fully controlled): beta =", round(coef(m_combined)[1], 4),
      " p =", round(pvalue(m_combined)[1], 4), "\n")
}

# Table: COVID Disentanglement
cat("\n  Generating COVID disentanglement table...\n")
covid_models <- list()
covid_headers <- c()

if (!is.null(m_covid_control_sci)) {
  covid_models <- c(covid_models, list(m_covid_control_sci))
  covid_headers <- c(covid_headers, "WFH Control")
}
if (!is.null(m_channel_sci)) {
  covid_models <- c(covid_models, list(m_channel_sci))
  covid_headers <- c(covid_headers, "Channel Control")
}
if (!is.null(m_combined)) {
  covid_models <- c(covid_models, list(m_combined))
  covid_headers <- c(covid_headers, "Combined")
}

if (length(covid_models) > 0) {
  etable(covid_models, headers = covid_headers,
         se.below = TRUE,
         signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
         fitstat = ~ wr2 + n,
         file = file.path(tab_dir, "tab_covid_disentanglement.tex"),
         replace = TRUE, style.tex = style.tex("aer"),
         label = "tab:covid",
         title = "COVID Disentanglement: WFH Amenity and Channel Proximity Controls")
  cat("  Saved tab_covid_disentanglement.tex\n")
}

cat("\n")


## ========================================================================
## SECTION D: CHOROPLETH MAP
## ========================================================================
cat("=== Section D: Choropleth Map ===\n")

# Download French département shapefile
dept_shp_url <- "https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/departements.geojson"
dept_shp_file <- file.path(data_dir, "departements.geojson")

if (!file.exists(dept_shp_file)) {
  cat("  Downloading département shapefile...\n")
  tryCatch({
    download.file(dept_shp_url, dept_shp_file, method = "curl", quiet = TRUE)
    cat("  Downloaded successfully\n")
  }, error = function(e) {
    cat("  Download failed:", e$message, "\n")
    cat("  Will skip choropleth\n")
  })
}

if (file.exists(dept_shp_file)) {
  dept_sf <- tryCatch({
    sf_data <- st_read(dept_shp_file, quiet = TRUE)
    # Standardize département codes
    sf_data$code <- sf_data$code
    sf_data
  }, error = function(e) {
    cat("  Error reading shapefile:", e$message, "\n")
    NULL
  })

  if (!is.null(dept_sf)) {
    # Merge exposure data
    exposure_map <- dept_exposure[, .(code_departement, log_sci_uk)]

    if (has_stock) {
      dept_uk_census <- readRDS(file.path(data_dir, "dept_uk_census.rds"))
      exposure_map <- merge(exposure_map,
                            dept_uk_census[, .(code_departement, uk_stock_2016, log_uk_stock_2011)],
                            by = "code_departement", all.x = TRUE)
    }

    dept_sf <- merge(dept_sf, exposure_map, by.x = "code", by.y = "code_departement",
                     all.x = TRUE)

    # Filter to mainland France only (exclude overseas)
    dept_sf <- dept_sf[!grepl("^97", dept_sf$code), ]

    # Panel A: SCI map
    p_map_sci <- ggplot(dept_sf) +
      geom_sf(aes(fill = log_sci_uk), colour = "white", linewidth = 0.2) +
      scale_fill_gradient(low = "#f7fbff", high = "#08306b",
                          name = "Log SCI(UK)",
                          na.value = "grey90") +
      labs(title = "A: Social Connectedness to the UK") +
      theme_void() +
      theme(plot.title = element_text(face = "bold", size = 10),
            legend.position = "bottom",
            legend.key.width = unit(1.5, "cm"))

    # Panel B: Census stock map
    if (has_stock && "log_uk_stock_2011" %in% names(dept_sf)) {
      p_map_stock <- ggplot(dept_sf) +
        geom_sf(aes(fill = log_uk_stock_2011), colour = "white", linewidth = 0.2) +
        scale_fill_gradient(low = "#fff5f0", high = "#67000d",
                            name = "Log UK Census Stock",
                            na.value = "grey90") +
        labs(title = "B: UK Census Population (2016)") +
        theme_void() +
        theme(plot.title = element_text(face = "bold", size = 10),
              legend.position = "bottom",
              legend.key.width = unit(1.5, "cm"))

      p_map <- p_map_sci + p_map_stock +
        plot_annotation(title = "Geographic Distribution of UK Exposure",
                        theme = theme(plot.title = element_text(face = "bold", size = 12)))
    } else {
      p_map <- p_map_sci +
        plot_annotation(title = "Geographic Distribution of UK Exposure")
    }

    ggsave(file.path(fig_dir, "fig_exposure_choropleth.pdf"),
           p_map, width = 10, height = 6)
    cat("  Saved fig_exposure_choropleth.pdf\n")
  }
} else {
  cat("  Skipping choropleth (no shapefile)\n")
}

cat("\n")


## ========================================================================
## SECTION E: SAVE v5 RESULTS
## ========================================================================
cat("=== Saving v5 results ===\n")

v5_results <- list(
  # Epoch decomposition
  m_epoch_sci = m_epoch_sci,
  m_epoch_stock = if (exists("m_epoch_stock")) m_epoch_stock else NULL,
  m_epoch_triple_sci = if (exists("m_epoch_triple_sci")) m_epoch_triple_sci else NULL,
  m_epoch_triple_stock = if (exists("m_epoch_triple_stock")) m_epoch_triple_stock else NULL,
  m_epoch_de = m_epoch_de,
  m_epoch_triple_de = if (exists("m_epoch_triple_de")) m_epoch_triple_de else NULL,

  # GADM1 harmonized
  gadm1_did_results = gadm1_did_results,
  gadm1_triple_results = gadm1_triple_results,
  m_gadm1_horse_did = if (exists("m_gadm1_horse_did")) m_gadm1_horse_did else NULL,
  m_gadm1_horse_triple = if (exists("m_gadm1_horse_triple")) m_gadm1_horse_triple else NULL,
  dept_gadm1_wide = dept_gadm1_wide,

  # COVID disentanglement
  m_covid_control_sci = if (exists("m_covid_control_sci")) m_covid_control_sci else NULL,
  m_covid_control_stock = if (exists("m_covid_control_stock")) m_covid_control_stock else NULL,
  m_channel_sci = if (exists("m_channel_sci")) m_channel_sci else NULL,
  m_combined = if (exists("m_combined")) m_combined else NULL
)

saveRDS(v5_results, file.path(data_dir, "v5_results.rds"))
cat("Saved v5_results.rds\n")

cat("\n=== v5 Analysis Complete ===\n")
cat("End time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
