## ==========================================================================
## 06_tables.R — Publication-ready tables
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- Load data ----
dvf <- fread(file.path(data_dir, "dvf_zfe_analysis.csv"))
results <- readRDS(file.path(data_dir, "rdd_results.rds"))
rob <- readRDS(file.path(data_dir, "robustness_results.rds"))

post <- dvf[strong_enforcement == 1]
pre  <- dvf[enforcement_phase == 0]

stars <- function(p) {
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
}

# ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

# Overall summary
summary_data <- dvf[, .(
  N = .N,
  mean_price_sqm = round(mean(price_sqm), 0),
  sd_price_sqm = round(sd(price_sqm), 0),
  median_price_sqm = round(median(price_sqm), 0),
  mean_surface = round(mean(surface_reelle_bati), 1),
  mean_rooms = round(mean(nombre_pieces_principales, na.rm = TRUE), 2),
  pct_apartment = round(mean(type_local == "Appartement") * 100, 1),
  mean_dist_km = round(mean(abs(dist_km)), 2)
)]

# By inside/outside and enforcement phase
# Use strong_enforcement (0 = weak/pre, 1 = strong) instead of post_zfe

# Format for LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrrr}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{Weak Enforcement} & \\multicolumn{2}{c}{Strong Enforcement} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat(" & Outside & Inside & Outside & Inside \\\\\n")
cat("\\midrule\n")

# Build it row by row from the data
# Use enforcement_phase: 0 = weak (2020), >=2 = strong (June 2021+)
# Exclude phase 1 (Jan-May 2021) for cleaner comparison
vals <- list()
for (se in 0:1) {
  for (iz in 0:1) {
    key <- paste0(se, "_", iz)
    if (se == 0) {
      sub <- dvf[enforcement_phase == 0 & inside_zfe == iz]
    } else {
      sub <- dvf[strong_enforcement == 1 & inside_zfe == iz]
    }
    vals[[key]] <- list(
      n = nrow(sub),
      price = round(mean(sub$price_sqm), 0),
      sd_price = round(sd(sub$price_sqm), 0),
      surface = round(mean(sub$surface_reelle_bati), 1),
      rooms = round(mean(sub$nombre_pieces_principales, na.rm = TRUE), 2),
      apt = round(mean(sub$type_local == "Appartement") * 100, 1)
    )
  }
}

fmt <- function(x) format(x, big.mark = ",")

cat("Price/m\\textsuperscript{2} (\\euro{}) & ",
    fmt(vals[["0_0"]]$price), " & ", fmt(vals[["0_1"]]$price), " & ",
    fmt(vals[["1_0"]]$price), " & ", fmt(vals[["1_1"]]$price), " \\\\\n")
cat(" & (", fmt(vals[["0_0"]]$sd_price), ") & (", fmt(vals[["0_1"]]$sd_price), ") & (",
    fmt(vals[["1_0"]]$sd_price), ") & (", fmt(vals[["1_1"]]$sd_price), ") \\\\\n")
cat("Surface (m\\textsuperscript{2}) & ",
    vals[["0_0"]]$surface, " & ", vals[["0_1"]]$surface, " & ",
    vals[["1_0"]]$surface, " & ", vals[["1_1"]]$surface, " \\\\\n")
cat("Rooms & ",
    vals[["0_0"]]$rooms, " & ", vals[["0_1"]]$rooms, " & ",
    vals[["1_0"]]$rooms, " & ", vals[["1_1"]]$rooms, " \\\\\n")
cat("Apartment (\\%) & ",
    vals[["0_0"]]$apt, " & ", vals[["0_1"]]$apt, " & ",
    vals[["1_0"]]$apt, " & ", vals[["1_1"]]$apt, " \\\\\n")
cat("\\midrule\n")
cat("Observations & ",
    fmt(vals[["0_0"]]$n), " & ", fmt(vals[["0_1"]]$n), " & ",
    fmt(vals[["1_0"]]$n), " & ", fmt(vals[["1_1"]]$n), " \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Standard deviations in parentheses for price. ",
    "``Inside'' and ``Outside'' refer to the ZFE boundary (A86 motorway). ",
    "``Weak Enforcement'' = 2020 (Crit'Air 5 only). ",
    "``Strong Enforcement'' = June 2021 onward (Crit'Air 4+). ",
    "Sample restricted to residential sales (apartments and houses) ",
    "with price per m\\textsuperscript{2} between \\euro{}500 and \\euro{}30,000. ",
    "Source: DVF (data.gouv.fr).\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

# ---- Table 2: Main RDD Results ----
cat("Table 2: Main results...\n")

sink(file.path(tab_dir, "tab2_main.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Main Results: Effect of ZFE on Property Prices}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) \\\\\n")
cat(" & Strong Enf. & Strong Enf. & Weak Enf. \\\\\n")
cat(" & Baseline & + Controls & Placebo \\\\\n")
cat("\\midrule\n")

# Extract results
r_main <- results$rdd_main_obj
r_cov <- results$rdd_cov_obj
r_plac <- results$rdd_placebo_obj

cat("Inside ZFE & ", sprintf("%.4f%s", r_main$coef[1], stars(r_main$pv[3])),
    " & ", sprintf("%.4f%s", r_cov$coef[1], stars(r_cov$pv[3])),
    " & ", sprintf("%.4f%s", r_plac$coef[1], stars(r_plac$pv[3])),
    " \\\\\n")
cat(" & (", sprintf("%.4f", r_main$se[3]),
    ") & (", sprintf("%.4f", r_cov$se[3]),
    ") & (", sprintf("%.4f", r_plac$se[3]),
    ") \\\\\n")
cat("\\addlinespace\n")
cat("Implied \\% effect & ", sprintf("%.2f\\%%", (exp(r_main$coef[1])-1)*100),
    " & ", sprintf("%.2f\\%%", (exp(r_cov$coef[1])-1)*100),
    " & ", sprintf("%.2f\\%%", (exp(r_plac$coef[1])-1)*100),
    " \\\\\n")
cat("\\addlinespace\n")
cat("Controls & No & Yes & No \\\\\n")
cat("Bandwidth (km) & ", sprintf("%.3f", r_main$bws[1,1]),
    " & ", sprintf("%.3f", r_cov$bws[1,1]),
    " & ", sprintf("%.3f", r_plac$bws[1,1]),
    " \\\\\n")
cat("N (left) & ", fmt(r_main$N[1]), " & ", fmt(r_cov$N[1]),
    " & ", fmt(r_plac$N[1]), " \\\\\n")
cat("N (right) & ", fmt(r_main$N[2]), " & ", fmt(r_cov$N[2]),
    " & ", fmt(r_plac$N[2]), " \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Robust bias-corrected standard errors in parentheses ",
    "(Cattaneo, Idrobo, and Titiunik 2019). ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$. ",
    "Local linear regression with triangular kernel and MSE-optimal bandwidth. ",
    "Outcome: log price per m\\textsuperscript{2}. ",
    "Controls in column (2): surface area, number of rooms, apartment indicator. ",
    "Column (3) uses weak-enforcement transactions (2020, Crit'Air 5 only) as a placebo.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:main}\n")
cat("\\end{table}\n")
sink()

# ---- Table 3: City-by-City Results ----
cat("Table 3: City results...\n")

if (nrow(results$city) > 0) {
  sink(file.path(tab_dir, "tab3_cities.tex"))
  cat("\\begin{table}[H]\n")
  cat("\\centering\n")
  cat("\\caption{ZFE Price Effect: Grand Paris Metropole}\n")
  cat("\\begin{threeparttable}\n")
  cat("\\begin{tabular}{lccccc}\n")
  cat("\\toprule\n")
  cat("City & Estimate & Robust SE & \\% Effect & Bandwidth & N \\\\\n")
  cat("\\midrule\n")

  for (i in 1:nrow(results$city)) {
    r <- results$city[i, ]
    cat(r$city, " & ",
        sprintf("%.4f%s", r$tau, stars(r$pval_robust)), " & ",
        sprintf("%.4f", r$se_robust), " & ",
        sprintf("%.2f\\%%", r$pct_effect), " & ",
        sprintf("%.3f", r$bw), " & ",
        fmt(r$n_left + r$n_right), " \\\\\n")
  }

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item Notes: Separate RDD estimates for each city. ",
      "Robust bias-corrected standard errors. ",
      "* $p<0.10$, ** $p<0.05$, *** $p<0.01$. ",
      "Local linear, triangular kernel, MSE-optimal bandwidth.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{threeparttable}\n")
  cat("\\label{tab:cities}\n")
  cat("\\end{table}\n")
  sink()
}

# ---- Table 4: Covariate Balance ----
cat("Table 4: Covariate balance...\n")

if (nrow(rob$balance) > 0) {
  sink(file.path(tab_dir, "tab4_balance.tex"))
  cat("\\begin{table}[H]\n")
  cat("\\centering\n")
  cat("\\caption{Covariate Balance at ZFE Boundary}\n")
  cat("\\begin{threeparttable}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat("Covariate & Discontinuity & Robust SE & $p$-value & BW (km) \\\\\n")
  cat("\\midrule\n")

  for (i in 1:nrow(rob$balance)) {
    r <- rob$balance[i, ]
    cat(r$covariate, " & ",
        sprintf("%.3f", r$tau), " & ",
        sprintf("%.3f", r$se), " & ",
        sprintf("%.3f", r$pval), " & ",
        sprintf("%.3f", r$bw), " \\\\\n")
  }

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item Notes: RDD estimates using each covariate as the outcome. ",
      "Covariates should show no discontinuity at the boundary (all $p > 0.05$). ",
      "Local linear, triangular kernel, MSE-optimal bandwidth.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{threeparttable}\n")
  cat("\\label{tab:balance}\n")
  cat("\\end{table}\n")
  sink()
}

# ---- Table 5: Robustness ----
cat("Table 5: Robustness...\n")

sink(file.path(tab_dir, "tab5_robustness.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{llcccc}\n")
cat("\\toprule\n")
cat("Panel & Specification & Estimate & Robust SE & $p$-value & N \\\\\n")
cat("\\midrule\n")

# Panel A: Polynomial order
cat("\\multicolumn{6}{l}{\\textit{Panel A: Polynomial Order}} \\\\\n")
if (nrow(rob$polynomial_sensitivity) > 0) {
  for (i in 1:nrow(rob$polynomial_sensitivity)) {
    r <- rob$polynomial_sensitivity[i, ]
    cat(" & Order ", r$order, " & ",
        sprintf("%.4f%s", r$tau, stars(r$pval)), " & ",
        sprintf("%.4f", r$se), " & ",
        sprintf("%.4f", r$pval), " & ",
        fmt(nrow(post)), " \\\\\n")
  }
}

cat("\\addlinespace\n")

# Panel B: Donut hole
cat("\\multicolumn{6}{l}{\\textit{Panel B: Donut Hole}} \\\\\n")
if (nrow(rob$donut) > 0) {
  for (i in 1:nrow(rob$donut)) {
    r <- rob$donut[i, ]
    cat(" & Excl. $\\pm$", sprintf("%.0f", r$donut_km * 1000), "m & ",
        sprintf("%.4f%s", r$tau, stars(r$pval)), " & ",
        sprintf("%.4f", r$se), " & ",
        sprintf("%.4f", r$pval), " & ",
        fmt(r$n), " \\\\\n")
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Panel A varies polynomial order (baseline is local linear, order 1). ",
    "Panel B excludes observations within the stated distance of the boundary to address ",
    "measurement error. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:robustness}\n")
cat("\\end{table}\n")
sink()

# ---- Table 6: Heterogeneity ----
cat("Table 6: Heterogeneity...\n")

het_df <- results$heterogeneity
type_rows <- het_df[!grepl("^Year", het_df$group), ]

if (nrow(type_rows) > 0) {
  sink(file.path(tab_dir, "tab6_heterogeneity.tex"))
  cat("\\begin{table}[H]\n")
  cat("\\centering\n")
  cat("\\caption{Heterogeneity by Property Type}\n")
  cat("\\begin{threeparttable}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat("Subgroup & Estimate & Robust SE & \\% Effect & N \\\\\n")
  cat("\\midrule\n")

  for (i in 1:nrow(type_rows)) {
    r <- type_rows[i, ]
    cat(r$group, " & ",
        sprintf("%.4f%s", r$tau, stars(r$pval)), " & ",
        sprintf("%.4f", r$se_robust), " & ",
        sprintf("%.2f\\%%", r$pct_effect), " & ",
        fmt(r$n), " \\\\\n")
  }

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item Notes: Separate RDD estimates by property type. ",
      "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{threeparttable}\n")
  cat("\\label{tab:heterogeneity}\n")
  cat("\\end{table}\n")
  sink()
}

cat("\nAll tables saved to:", tab_dir, "\n")
cat("Files:", paste(list.files(tab_dir), collapse = ", "), "\n")
