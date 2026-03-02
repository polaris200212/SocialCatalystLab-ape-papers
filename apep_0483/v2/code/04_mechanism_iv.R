###############################################################################
# 04_mechanism_iv.R — Mechanism (vacancy first stage) + Bartik IV
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

la_panel <- fread(paste0(data_dir, "la_panel.csv"))

###############################################################################
# Part A: Vacancy First Stage
###############################################################################

cat("=== VACANCY FIRST STAGE ===\n\n")

# Check what vacancy columns are available
vac_cols <- grep("vacanc|vac_rate|headcount", names(la_panel),
                 value = TRUE, ignore.case = TRUE)
cat(sprintf("Vacancy columns: %s\n", paste(vac_cols, collapse=", ")))

if (length(vac_cols) > 0) {
  # Use the first vacancy column
  vac_col <- vac_cols[1]
  cat(sprintf("Using: %s\n", vac_col))

  vac_sample <- la_panel[!is.na(get(vac_col)) & !is.na(comp_ratio)]
  cat(sprintf("Vacancy sample: %d LA-years\n", nrow(vac_sample)))

  if (nrow(vac_sample) > 20) {
    m_vac <- feols(as.formula(paste0(vac_col, " ~ comp_ratio | la_id + year")),
                   data = vac_sample, cluster = ~la_code)

    cat("First stage:\n")
    cat(sprintf("  beta = %.4f (SE = %.4f), p = %.3f\n",
                coef(m_vac)["comp_ratio"], se(m_vac)["comp_ratio"],
                coeftable(m_vac)["comp_ratio", "Pr(>|t|)"]))

    saveRDS(list(fs1 = m_vac), paste0(data_dir, "vacancy_first_stage.rds"))
  }
} else {
  cat("No vacancy data available in panel.\n")
}

###############################################################################
# Part B: Bartik IV
###############################################################################

cat("\n=== BARTIK IV ===\n\n")

bres_file <- paste0(data_dir, "bres_industry_2010.csv")
ashe_file <- paste0(data_dir, "ashe_earnings_by_la.csv")

if (file.exists(bres_file) && file.exists(ashe_file)) {

  bres <- fread(bres_file)
  ashe <- fread(ashe_file)

  cat(sprintf("BRES 2010: %d rows, %d LAs\n", nrow(bres), uniqueN(bres$la_code)))

  # Step 1: Industry employment shares (2010 baseline)
  bres[, total_emp := sum(employment, na.rm = TRUE), by = la_code]
  bres[, share_2010 := employment / total_emp]
  bres <- bres[!is.na(share_2010) & is.finite(share_2010)]

  # Step 2: National industry wage growth
  # Since ASHE by industry nationally failed, compute from LA-level ASHE
  # Use ASHE sectoral data if available, otherwise construct Bartik
  # from BRES shares × overall wage growth

  # Alternative Bartik: Use BRES shares × ASHE district-level wage growth
  # For each district: compute actual wage growth
  ashe_growth <- ashe[year %in% c(2010, 2023),
                      .(pay = mean(median_annual_pay, na.rm = TRUE)),
                      by = .(la_code, year)]
  ashe_growth <- dcast(ashe_growth, la_code ~ year, value.var = "pay")
  setnames(ashe_growth, c("la_code", "pay_2010", "pay_2023"))
  ashe_growth[, wage_growth := (pay_2023 - pay_2010) / pay_2010]

  cat(sprintf("Wage growth (2010-2023): mean = %.3f, sd = %.3f\n",
              mean(ashe_growth$wage_growth, na.rm = TRUE),
              sd(ashe_growth$wage_growth, na.rm = TRUE)))

  # Bartik approach: predicted wage growth for each LA
  # B_i = Σ_k (share_k,i,2010 × national_wage_growth_k)
  # Since we don't have industry-level national wages, use a modified Bartik:
  # Use leave-one-out mean wage growth as the national component
  # This avoids the mechanical correlation issue

  # For each LA × industry, compute the national (leave-one-out) employment growth
  # in that industry. Then predict LA wage growth as:
  # B_i = Σ_k (share_k,i,2010 × leave_out_national_growth_k)

  # Simplified Bartik: industry employment shares × national total wage growth
  # This captures the "predicted" wage growth from an LA's industrial mix

  national_growth <- ashe[, .(nat_pay = mean(median_annual_pay, na.rm = TRUE)),
                          by = year]
  nat_2010 <- national_growth[year == 2010]$nat_pay
  national_growth[, nat_growth := (nat_pay - nat_2010) / nat_2010]

  # Industry-specific national employment trends (from BRES)
  # Since BRES is 2010 only, use a shift-share with overall wage growth
  # weighted by industry composition

  # For each LA, the Bartik predicted wage growth is:
  # B_{i,t} = Σ_k (share_{k,i,2010} × national_wage_growth_t)
  # Since all industries share the same national growth (we lack industry detail),
  # this simplifies to just the national growth rate — not useful

  # Approach: Use BRES to capture whether an LA's economy is
  # concentrated in high-wage industries (proxy for outside option strength).
  # We lack industry-level national wage growth data for a full Bartik,
  # so we use the baseline industry mix (high vs low wage industries)
  # as a proxy instrument. See paper text for discussion of this limitation.

  # Compute an "outside option strength" index from BRES
  # Industries with above-median national pay get weight 1, others 0
  # This captures whether an LA's economy is in "competing" industries

  bres[, high_wage_ind := fifelse(grepl("Financial|Insurance|Information|Professional|Real estate",
                                        industry, ignore.case = TRUE), 1L, 0L)]
  outside_option <- bres[, .(high_wage_share = sum(share_2010 * high_wage_ind, na.rm = TRUE)),
                         by = la_code]

  cat(sprintf("High-wage industry share: mean = %.3f, sd = %.3f\n",
              mean(outside_option$high_wage_share, na.rm = TRUE),
              sd(outside_option$high_wage_share, na.rm = TRUE)))

  # Merge into panel
  la_panel_iv <- merge(la_panel, outside_option, by = "la_code", all.x = TRUE)

  # Create interaction: high_wage_share × year (time-varying instrument)
  la_panel_iv[, bartik_proxy := high_wage_share * (year - 2018)]

  iv_sample <- la_panel_iv[!is.na(progress8) & !is.na(comp_ratio) &
                             !is.na(bartik_proxy)]

  if (nrow(iv_sample) > 50) {
    # IV estimation
    m_iv <- tryCatch(
      feols(progress8 ~ 1 | la_id + year | comp_ratio ~ bartik_proxy,
            data = iv_sample, cluster = ~la_code),
      error = function(e) {
        cat(sprintf("IV failed: %s\n", e$message))
        NULL
      }
    )

    if (!is.null(m_iv)) {
      cat("\nBartik proxy IV:\n")
      print(summary(m_iv))

      # First stage
      m_fs <- feols(comp_ratio ~ bartik_proxy | la_id + year,
                    data = iv_sample, cluster = ~la_code)
      cat(sprintf("\nFirst stage: beta = %.4f, SE = %.4f, p = %.3f\n",
                  coef(m_fs)["bartik_proxy"], se(m_fs)["bartik_proxy"],
                  coeftable(m_fs)["bartik_proxy", "Pr(>|t|)"]))

      fs_fstat <- tryCatch(fitstat(m_iv, "ivf"), error = function(e) NULL)
      if (!is.null(fs_fstat)) {
        cat(sprintf("First-stage F: %.1f\n", fs_fstat[[1]]$stat))
      }

      saveRDS(list(iv = m_iv, first_stage = m_fs),
              paste0(data_dir, "bartik_iv_results.rds"))
    }
  }

  fwrite(la_panel_iv[, .(la_code, year, high_wage_share, bartik_proxy)],
         paste0(data_dir, "bartik_predictions.csv"))

} else {
  cat("BRES data not available. Skipping Bartik IV.\n")
}

cat("\n=== MECHANISM & IV COMPLETE ===\n")
