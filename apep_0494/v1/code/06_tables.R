## ===========================================================================
## 06_tables.R — All Table Generation
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("=== Loading data for tables ===\n")
dvf <- fread(file.path(DAT, "dvf_analysis.csv"))
panel <- fread(file.path(DAT, "panel_commune_year.csv"))

dvf[, code_commune := as.factor(code_commune)]
dvf[, dept := as.factor(dept)]

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\n=== Table 1: Summary Statistics ===\n")

# Panel A: Transaction-level
summ_a <- data.table(
  Variable = c("Price per m\\textsuperscript{2} (\\euro{})",
               "Transaction price (\\euro{})",
               "Surface (m\\textsuperscript{2})",
               "Rooms",
               "Apartment (share)"),
  Mean = round(c(mean(dvf$price_m2), mean(dvf$valeur_fonciere),
                 mean(dvf$surface_reelle_bati),
                 mean(dvf$nombre_pieces_principales, na.rm = TRUE),
                 mean(dvf$is_apartment)), 1),
  SD = round(c(sd(dvf$price_m2), sd(dvf$valeur_fonciere),
               sd(dvf$surface_reelle_bati),
               sd(dvf$nombre_pieces_principales, na.rm = TRUE),
               sd(dvf$is_apartment)), 1),
  Median = round(c(median(dvf$price_m2), median(dvf$valeur_fonciere),
                   median(dvf$surface_reelle_bati),
                   median(dvf$nombre_pieces_principales, na.rm = TRUE),
                   median(dvf$is_apartment)), 1),
  N = format(nrow(dvf), big.mark = ",")
)

# Panel B: Commune-level
th_baseline <- fread(file.path(DAT, "th_baseline_2017.csv"))
rei_clean <- fread(file.path(DAT, "rei_clean.csv"))
tfb_2017 <- rei_clean[year == 2017 & !is.na(taux_tfb)]

summ_b <- data.table(
  Variable = c("TH commune rate, 2017 (\\%)",
               "TFB commune rate, 2017 (\\%)",
               "TH rate, P25 (\\%)",
               "TH rate, P75 (\\%)"),
  Mean = round(c(mean(th_baseline$th_rate_2017, na.rm = TRUE),
                 mean(tfb_2017$taux_tfb, na.rm = TRUE),
                 quantile(th_baseline$th_rate_2017, 0.25, na.rm = TRUE),
                 quantile(th_baseline$th_rate_2017, 0.75, na.rm = TRUE)), 2),
  SD = round(c(sd(th_baseline$th_rate_2017, na.rm = TRUE),
               sd(tfb_2017$taux_tfb, na.rm = TRUE), NA, NA), 2),
  Median = round(c(median(th_baseline$th_rate_2017, na.rm = TRUE),
                   median(tfb_2017$taux_tfb, na.rm = TRUE), NA, NA), 2),
  N = c(format(nrow(th_baseline), big.mark = ","),
        format(nrow(tfb_2017), big.mark = ","),
        "", "")
)

# LaTeX output
sink(file.path(TAB, "table1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lrrrr}\n")
cat("\\toprule\n")
cat("& Mean & SD & Median & N \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Transaction-Level (2020--2025)}} \\\\\n")
for (i in 1:nrow(summ_a)) {
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              summ_a$Variable[i], summ_a$Mean[i], summ_a$SD[i],
              summ_a$Median[i], summ_a$N[i]))
}
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Commune-Level Tax Rates}} \\\\\n")
for (i in 1:nrow(summ_b)) {
  sd_str <- ifelse(is.na(summ_b$SD[i]), "", as.character(summ_b$SD[i]))
  med_str <- ifelse(is.na(summ_b$Median[i]), "", as.character(summ_b$Median[i]))
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              summ_b$Variable[i], summ_b$Mean[i], sd_str,
              med_str, summ_b$N[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\end{table}\n")
sink()

cat("  Saved table1_summary.tex\n")


# ============================================================================
# Table 2: Main Results
# ============================================================================

cat("\n=== Table 2: Main Results ===\n")

a1 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept + year,
            data = dvf, cluster = ~dept)

a2 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf, cluster = ~dept)

a3 <- feols(log_price_m2 ~ th_rate_2017 + tfb_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf, cluster = ~dept)

a4 <- feols(log_price_m2 ~ th_rate_2017 +
              log(surface_reelle_bati) |
              dept^year + type_local^year,
            data = dvf, cluster = ~dept)

sink(file.path(TAB, "table2_main.tex"))
etable(a1, a2, a3, a4,
       dict = c("th_rate_2017" = "TH Rate (2017)",
                "tfb_rate_2017" = "TFB Rate (2017)",
                "is_apartment" = "Apartment",
                "log(surface_reelle_bati)" = "Log Surface"),
       se.below = TRUE,
       fitstat = ~ n + r2 + wr2,
       tex = TRUE,
       title = "Effect of Taxe d'Habitation Abolition on Property Prices",
       label = "tab:main")
sink()

cat("  Saved table2_main.tex\n")


# ============================================================================
# Table 3: Fiscal Substitution
# ============================================================================

cat("\n=== Table 3: Fiscal Substitution ===\n")

fiscal_file <- file.path(DAT, "fiscal_change_panel.csv")
if (file.exists(fiscal_file)) {
  fiscal <- fread(fiscal_file)
  fiscal <- fiscal[!is.na(delta_tfb)]
  fiscal[, dept := substr(code_commune, 1, 2)]
  fiscal[, dept := as.factor(dept)]

  fs1 <- feols(delta_tfb ~ th_rate_2017 | dept,
               data = fiscal, cluster = ~dept)

  fs2 <- feols(delta_tfb ~ th_rate_2017 + tfb_rate_2017 | dept,
               data = fiscal, cluster = ~dept)

  tex_out <- capture.output(
    etable(fs1, fs2,
           dict = c("th_rate_2017" = "TH Rate (2017)",
                    "tfb_rate_2017" = "TFB Rate (2017)"),
           se.below = TRUE,
           fitstat = ~ n + r2,
           tex = TRUE,
           title = "Fiscal Substitution: TFB Rate Change (2017--2024)",
           label = "tab:fiscal_sub")
  )
  writeLines(tex_out, file.path(TAB, "table3_fiscal_sub.tex"))

  cat("  Saved table3_fiscal_sub.tex\n")
}


# ============================================================================
# Table 4: Robustness (generated by 04_robustness.R)
# ============================================================================

cat("\n=== Table 4: Robustness ===\n")
if (file.exists(file.path(TAB, "robustness.tex"))) {
  cat("  robustness.tex exists from 04_robustness.R\n")
} else {
  cat("  WARNING: robustness.tex not found — run 04_robustness.R first\n")
}


# ============================================================================
# Table 5: Heterogeneity by Property Type
# ============================================================================

cat("\n=== Table 5: Heterogeneity ===\n")

m_apt <- feols(log_price_m2 ~ th_rate_2017 +
                 log(surface_reelle_bati) |
                 dept^year,
               data = dvf[type_local == "Appartement"],
               cluster = ~dept)

m_house <- feols(log_price_m2 ~ th_rate_2017 +
                   log(surface_reelle_bati) |
                   dept^year,
                 data = dvf[type_local == "Maison"],
                 cluster = ~dept)

sink(file.path(TAB, "table5_heterogeneity.tex"))
etable(m_apt, m_house,
       headers = c("Apartments", "Houses"),
       dict = c("th_rate_2017" = "TH Rate (2017)",
                "log(surface_reelle_bati)" = "Log Surface"),
       se.below = TRUE,
       fitstat = ~ n + r2 + wr2,
       tex = TRUE,
       title = "Heterogeneity by Property Type",
       label = "tab:hetero")
sink()

cat("  Saved table5_heterogeneity.tex\n")

cat("\n=== All tables generated ===\n")
cat(sprintf("  Output directory: %s\n", normalizePath(TAB)))
cat(sprintf("  Files: %s\n", paste(list.files(TAB), collapse = ", ")))
