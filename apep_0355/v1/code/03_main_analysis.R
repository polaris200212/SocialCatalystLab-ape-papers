## ============================================================================
## 03_main_analysis.R — Primary regression analysis
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
##
## Unit of analysis: ZIP × service-category × month
## Treatment: OIG exclusion of a provider with ≥3% service-level market share
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- Load panels ----
zip_panel <- readRDS(file.path(DATA, "zip_svc_panel.rds"))
rom_panel <- readRDS(file.path(DATA, "rom_panel.rds"))
analysis_excl <- readRDS(file.path(DATA, "analysis_exclusions.rds"))

cat("=== Main Analysis ===\n")
cat(sprintf("ZIP-service panel: %s rows\n", format(nrow(zip_panel), big.mark = ",")))
cat(sprintf("ROM panel: %s rows, %d treated units\n",
            format(nrow(rom_panel), big.mark = ","),
            uniqueN(rom_panel$unit_id)))

# Clean: handle negative paid values
rom_panel[rom_paid < 0, rom_paid := 0]
rom_panel[, ln_rom_paid := log(rom_paid + 1)]

## ====================================================================
## 1. TWFE Event Study — Rest-of-Market Spending
## ====================================================================
cat("\n--- TWFE Event Study ---\n")

# Cap event time at [-18, +18]
rom_panel[, event_time_c := pmin(pmax(event_time, -18), 18)]

# State × month FE
rom_panel[, state_month := paste0(state, "_", month_num)]

# 1a. Event study: ln(ROM spending) — basic FE
es_paid <- feols(
  ln_rom_paid ~ i(event_time_c, ref = -1) | unit_id + month_num,
  data = rom_panel[event_time >= -18 & event_time <= 18],
  cluster = ~unit_id
)

cat("Event study — ln(ROM spending), basic FE:\n")
print(summary(es_paid))

# 1b. Event study with state × month FE
es_paid_sm <- feols(
  ln_rom_paid ~ i(event_time_c, ref = -1) | unit_id + state_month,
  data = rom_panel[event_time >= -18 & event_time <= 18],
  cluster = ~unit_id
)

cat("\nEvent study — ln(ROM spending), state×month FE:\n")
print(summary(es_paid_sm))

# 1c. Event study: ln(ROM providers)
es_providers <- feols(
  ln_rom_providers ~ i(event_time_c, ref = -1) | unit_id + state_month,
  data = rom_panel[event_time >= -18 & event_time <= 18],
  cluster = ~unit_id
)

# 1d. Event study: ln(ROM beneficiaries)
es_bene <- feols(
  ln_rom_bene ~ i(event_time_c, ref = -1) | unit_id + state_month,
  data = rom_panel[event_time >= -18 & event_time <= 18],
  cluster = ~unit_id
)

saveRDS(list(paid = es_paid, paid_sm = es_paid_sm,
             providers = es_providers, beneficiaries = es_bene),
        file.path(DATA, "event_study_models.rds"))

## ====================================================================
## 2. Callaway-Sant'Anna Estimator
## ====================================================================
cat("\n--- Callaway-Sant'Anna ---\n")

# Need wider panel with never-treated controls
# Use the full zip_panel for CS-DiD
cs_data <- copy(zip_panel[svc_cat %in% unique(rom_panel$svc_cat)])
cs_data[, unit_num := as.integer(factor(unit_id))]

# Replace NaN/Inf in outcomes
cs_data[!is.finite(ln_paid), ln_paid := 0]

cat("Running CS-DiD for ln(total spending)...\n")
cs_paid <- tryCatch({
  att_gt(
    yname = "ln_paid",
    tname = "month_num",
    idname = "unit_num",
    gname = "excl_month_num",
    data = as.data.frame(cs_data),
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "dr",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("CS-DiD error:", conditionMessage(e), "\n")
  # Try with simpler settings
  tryCatch({
    att_gt(
      yname = "ln_paid",
      tname = "month_num",
      idname = "unit_num",
      gname = "excl_month_num",
      data = as.data.frame(cs_data),
      control_group = "notyettreated",
      anticipation = 0,
      est_method = "reg",
      bstrap = TRUE,
      biters = 500
    )
  }, error = function(e2) {
    cat("CS-DiD fallback error:", conditionMessage(e2), "\n")
    NULL
  })
})

cs_paid_agg <- NULL
cs_paid_simple <- NULL
if (!is.null(cs_paid)) {
  cs_paid_agg <- tryCatch(aggte(cs_paid, type = "dynamic", min_e = -12, max_e = 12),
                           error = function(e) NULL)
  cs_paid_simple <- tryCatch(aggte(cs_paid, type = "simple"),
                              error = function(e) NULL)

  if (!is.null(cs_paid_simple)) {
    cat("CS-DiD simple ATT:\n")
    print(summary(cs_paid_simple))
  }
  if (!is.null(cs_paid_agg)) {
    cat("CS-DiD dynamic:\n")
    print(summary(cs_paid_agg))
  }
}

saveRDS(list(paid = cs_paid, paid_agg = cs_paid_agg, paid_simple = cs_paid_simple),
        file.path(DATA, "cs_did_models.rds"))

## ====================================================================
## 3. Static DiD — Main Results
## ====================================================================
cat("\n--- Static DiD ---\n")

# (1) Basic TWFE: unit FE + month FE
did_basic <- feols(
  ln_rom_paid ~ post | unit_id + month_num,
  data = rom_panel,
  cluster = ~unit_id
)

# (2) State × month FE
did_sm <- feols(
  ln_rom_paid ~ post | unit_id + state_month,
  data = rom_panel,
  cluster = ~unit_id
)

# (3) With county controls
rom_panel[, ln_pop := log(pmax(total_pop, 1))]
did_controls <- feols(
  ln_rom_paid ~ post + ln_pop + poverty_rate + elderly_share |
    unit_id + state_month,
  data = rom_panel,
  cluster = ~unit_id
)

# Providers
did_prov <- feols(
  ln_rom_providers ~ post | unit_id + state_month,
  data = rom_panel,
  cluster = ~unit_id
)

# Beneficiaries
did_bene <- feols(
  ln_rom_bene ~ post | unit_id + state_month,
  data = rom_panel,
  cluster = ~unit_id
)

cat(sprintf("Static DiD results:\n"))
cat(sprintf("  ln(ROM paid) basic:     β=%.4f (SE=%.4f)\n",
            coef(did_basic)["post"], se(did_basic)["post"]))
cat(sprintf("  ln(ROM paid) state×mo:  β=%.4f (SE=%.4f)\n",
            coef(did_sm)["post"], se(did_sm)["post"]))
cat(sprintf("  ln(ROM paid) controls:  β=%.4f (SE=%.4f)\n",
            coef(did_controls)["post"], se(did_controls)["post"]))
cat(sprintf("  ln(ROM prov) state×mo:  β=%.4f (SE=%.4f)\n",
            coef(did_prov)["post"], se(did_prov)["post"]))
cat(sprintf("  ln(ROM bene) state×mo:  β=%.4f (SE=%.4f)\n",
            coef(did_bene)["post"], se(did_bene)["post"]))

saveRDS(list(
  paid = list(basic = did_basic, sm = did_sm, controls = did_controls),
  providers = list(sm = did_prov),
  beneficiaries = list(sm = did_bene)
), file.path(DATA, "static_did_models.rds"))

## ====================================================================
## 4. Heterogeneity by Service Category
## ====================================================================
cat("\n--- Heterogeneity by Service Category ---\n")

# Merge service category info to rom_panel
rom_panel_het <- merge(rom_panel,
                       analysis_excl[, .(npi, zip5, svc_cat, market_share,
                                         hcbs_related, EXCLTYPE)],
                       by = c("zip5", "svc_cat"),
                       all.x = TRUE, allow.cartesian = TRUE)

# Remove duplicates from merge
rom_panel_het <- unique(rom_panel_het, by = c("unit_id", "month_num"))

# By market share intensity
rom_panel_het[, high_share := market_share >= 0.10]

het_share <- tryCatch(
  feols(ln_rom_paid ~ post + post:high_share | unit_id + state_month,
        data = rom_panel_het, cluster = ~unit_id),
  error = function(e) NULL
)

# By HCBS vs non-HCBS service
rom_panel_het[, is_hcbs_svc := svc_cat %in% c("HCBS_TS", "BH_H")]

het_hcbs <- tryCatch(
  feols(ln_rom_paid ~ post + post:is_hcbs_svc | unit_id + state_month,
        data = rom_panel_het, cluster = ~unit_id),
  error = function(e) NULL
)

# By rurality
rom_panel_het[, rural := total_pop < 50000]

het_rural <- tryCatch(
  feols(ln_rom_paid ~ post + post:rural | unit_id + state_month,
        data = rom_panel_het, cluster = ~unit_id),
  error = function(e) NULL
)

if (!is.null(het_share)) {
  cat("By market share:\n")
  print(summary(het_share))
}

saveRDS(list(share = het_share, hcbs = het_hcbs, rural = het_rural),
        file.path(DATA, "heterogeneity_models.rds"))

## ====================================================================
## 5. Absorption Rate
## ====================================================================
cat("\n--- Absorption Rate ---\n")

absorption <- rom_panel[, .(
  pre_mean = mean(rom_paid[event_time >= -12 & event_time < 0], na.rm = TRUE),
  post_6m = mean(rom_paid[event_time >= 0 & event_time < 6], na.rm = TRUE),
  post_12m = mean(rom_paid[event_time >= 0 & event_time < 12], na.rm = TRUE)
), by = unit_id]

# Merge excluded provider's baseline
excl_baseline <- analysis_excl[, .(
  excl_baseline = pre_paid / 12
), by = .(zip5, svc_cat)]
excl_baseline[, unit_id := paste0(zip5, "_", svc_cat)]
excl_baseline <- excl_baseline[, .SD[1], by = unit_id]

absorption <- merge(absorption, excl_baseline[, .(unit_id, excl_baseline)],
                    by = "unit_id")

absorption[, absorb_6m := (post_6m - pre_mean) / excl_baseline]
absorption[, absorb_12m := (post_12m - pre_mean) / excl_baseline]

cat(sprintf("Absorption rates:\n"))
cat(sprintf("  6-month mean:  %.1f%%\n", 100 * mean(absorption$absorb_6m, na.rm = TRUE)))
cat(sprintf("  12-month mean: %.1f%%\n", 100 * mean(absorption$absorb_12m, na.rm = TRUE)))
cat(sprintf("  6-month median:  %.1f%%\n", 100 * median(absorption$absorb_6m, na.rm = TRUE)))
cat(sprintf("  12-month median: %.1f%%\n", 100 * median(absorption$absorb_12m, na.rm = TRUE)))

saveRDS(absorption, file.path(DATA, "absorption_rates.rds"))

cat("\n=== Main analysis complete ===\n")
