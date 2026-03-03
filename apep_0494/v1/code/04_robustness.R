## ===========================================================================
## 04_robustness.R — Robustness Checks
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

source("00_packages.R")

cat("=== Loading data ===\n")
dvf <- fread(file.path(DAT, "dvf_analysis.csv"))
dvf[, code_commune := as.factor(code_commune)]
dvf[, dept := as.factor(dept)]
dvf[, rel_year := year - 2020]

cat(sprintf("  %d transactions, %d communes\n", nrow(dvf), uniqueN(dvf$code_commune)))


# ============================================================================
# 1. Alternative Treatment Measures
# ============================================================================

cat("\n=== Alternative Treatment Measures ===\n")

# a) Binary treatment (above/below median TH rate)
dvf[, high_th_binary := as.integer(th_rate_2017 > median(th_rate_2017, na.rm = TRUE))]

r1 <- feols(log_price_m2 ~ high_th_binary +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf, cluster = ~dept)

cat("\nBinary treatment (above median TH):\n")
summary(r1)

# b) Standardized treatment (1 SD = 1 unit)
th_sd <- sd(dvf$th_rate_2017, na.rm = TRUE)
dvf[, th_std := th_rate_2017 / th_sd]

r2 <- feols(log_price_m2 ~ th_std +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf, cluster = ~dept)

cat("\nStandardized treatment (per SD of TH rate):\n")
summary(r2)

# c) Quadratic — nonlinear capitalization
dvf[, th_sq := th_rate_2017^2]

r3 <- feols(log_price_m2 ~ th_rate_2017 + th_sq +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf, cluster = ~dept)

cat("\nQuadratic specification:\n")
summary(r3)


# ============================================================================
# 2. Sample Restrictions
# ============================================================================

cat("\n=== Sample Restrictions ===\n")

# a) Exclude Île-de-France (Paris region — different dynamics)
r4 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf[!dept %in% c("75", "77", "78", "91", "92", "93", "94", "95")],
            cluster = ~dept)

cat("\nExcluding Île-de-France:\n")
summary(r4)

# b) Only transactions > 50k EUR (drop small/unusual)
r5 <- feols(log_price_m2 ~ th_rate_2017 +
              is_apartment + log(surface_reelle_bati) |
              dept^year,
            data = dvf[valeur_fonciere > 50000],
            cluster = ~dept)

cat("\nOnly transactions > 50k EUR:\n")
summary(r5)

# c) Apartments only
r6_apt <- feols(log_price_m2 ~ th_rate_2017 +
                  log(surface_reelle_bati) |
                  dept^year,
                data = dvf[type_local == "Appartement"],
                cluster = ~dept)

cat("\nApartments only:\n")
summary(r6_apt)

# d) Houses only
r6_house <- feols(log_price_m2 ~ th_rate_2017 +
                    log(surface_reelle_bati) |
                    dept^year,
                  data = dvf[type_local == "Maison"],
                  cluster = ~dept)

cat("\nHouses only:\n")
summary(r6_house)


# ============================================================================
# 3. Leave-One-Out by Département
# ============================================================================

cat("\n=== Leave-One-Out by Département ===\n")

all_depts <- sort(unique(as.character(dvf$dept)))
loo_results <- data.table(
  dept_excluded = character(),
  coefficient = numeric(),
  se = numeric(),
  n_obs = integer()
)

for (d in all_depts) {
  tryCatch({
    m_loo <- feols(log_price_m2 ~ th_rate_2017 +
                     is_apartment + log(surface_reelle_bati) |
                     dept^year,
                   data = dvf[dept != d],
                   cluster = ~dept)

    loo_results <- rbind(loo_results, data.table(
      dept_excluded = d,
      coefficient = coef(m_loo)["th_rate_2017"],
      se = se(m_loo)["th_rate_2017"],
      n_obs = m_loo$nobs
    ))
  }, error = function(e) NULL)
}

cat(sprintf("  LOO results: %d iterations\n", nrow(loo_results)))
cat(sprintf("  Coefficient range: [%.6f, %.6f]\n",
            min(loo_results$coefficient), max(loo_results$coefficient)))
cat(sprintf("  Mean coefficient: %.6f\n", mean(loo_results$coefficient)))

fwrite(loo_results, file.path(TAB, "loo_results.csv"))
saveRDS(loo_results, file.path(DAT, "loo_results.rds"))


# ============================================================================
# 4. Wild Cluster Bootstrap
# ============================================================================

cat("\n=== Wild Cluster Bootstrap ===\n")

main_model <- feols(log_price_m2 ~ th_rate_2017 +
                      is_apartment + log(surface_reelle_bati) |
                      dept^year,
                    data = dvf, cluster = ~dept)

tryCatch({
  boot_result <- boot(main_model, param = "th_rate_2017",
                      B = 999, seed = 42)
  cat("  Bootstrap p-value:\n")
  print(boot_result)
}, error = function(e) {
  cat(sprintf("  Bootstrap failed: %s\n", e$message))
  cat("  Using analytical cluster-robust SEs instead\n")
})


# ============================================================================
# 5. Commune Size Heterogeneity
# ============================================================================

cat("\n=== Commune Size Heterogeneity ===\n")

comm_size <- dvf[, .(n_trans = .N), by = code_commune]
comm_size[, size_cat := fifelse(n_trans >= median(n_trans), "Large", "Small")]

dvf <- merge(dvf, comm_size[, .(code_commune, size_cat)],
             by = "code_commune", all.x = TRUE)

r_large <- feols(log_price_m2 ~ th_rate_2017 +
                   is_apartment + log(surface_reelle_bati) |
                   dept^year,
                 data = dvf[size_cat == "Large"],
                 cluster = ~dept)

r_small <- feols(log_price_m2 ~ th_rate_2017 +
                   is_apartment + log(surface_reelle_bati) |
                   dept^year,
                 data = dvf[size_cat == "Small"],
                 cluster = ~dept)

cat("\nLarge communes (above median transactions):\n")
summary(r_large)
cat("\nSmall communes:\n")
summary(r_small)


# ============================================================================
# 6. Save Robustness Table
# ============================================================================

cat("\n=== Saving robustness table ===\n")

sink(file.path(TAB, "robustness.tex"))
etable(r1, r2, r4, r5, r6_apt, r6_house,
       headers = c("Binary", "Std.", "No IDF", ">50k", "Apt.", "House"),
       dict = c("high_th_binary" = "High TH (Binary)",
                "th_std" = "TH Rate (Std.)",
                "th_rate_2017" = "TH Rate (2017)",
                "is_apartment" = "Apartment",
                "log(surface_reelle_bati)" = "Log Surface"),
       se.below = TRUE,
       fitstat = ~ n + r2 + wr2,
       tex = TRUE,
       title = "Robustness: Alternative Specifications",
       label = "tab:robustness")
sink()

cat("  Saved robustness.tex\n")
cat("\n=== Robustness checks complete ===\n")
