## ============================================================
## 03_main_analysis.R — Main econometric analysis
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir  <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(data_dir, "district_year_panel.csv"))
cat("Panel:", nrow(panel), "district-years\n")

## ════════════════════════════════════════════════════════════
## 1. TWFE (Benchmark — known to be biased under heterogeneity)
## ════════════════════════════════════════════════════════════

cat("\n=== TWFE Estimates ===\n")

## Simple DiD
twfe1 <- feols(log_light ~ treated | dist_id + year,
               data = panel, cluster = ~dist_id)
cat("TWFE (binary):\n")
print(summary(twfe1))

## Event study with TWFE (Sun-Abraham correction via sunab)
## Note: sunab requires first_treat cohort variable
panel[, first_treat := treat_year]

twfe_es <- feols(log_light ~ sunab(first_treat, year) | dist_id + year,
                 data = panel, cluster = ~dist_id)
cat("\nTWFE Event Study (Sun-Abraham):\n")
print(summary(twfe_es))

## Save TWFE results
saveRDS(twfe1, file.path(tab_dir, "twfe_binary.rds"))
saveRDS(twfe_es, file.path(tab_dir, "twfe_event_study.rds"))

## ════════════════════════════════════════════════════════════
## 2. Callaway-Sant'Anna (Heterogeneity-Robust)
## ════════════════════════════════════════════════════════════

cat("\n=== Callaway-Sant'Anna Estimates ===\n")

## CS requires: yname, tname, idname, gname, data
## gname = first treatment year (0 for never-treated)
## Since all districts are eventually treated (Phase III),
## we use not-yet-treated as comparison group

cs_out <- att_gt(
  yname  = "log_light",
  tname  = "year",
  idname = "dist_id",
  gname  = "first_treat",
  data   = as.data.frame(panel),
  control_group = "notyettreated",
  base_period   = "universal",
  est_method    = "dr",       # Doubly-robust
  biter         = 1000,       # Bootstrap iterations
  clustervars   = "dist_id",
  print_details = FALSE
)

cat("CS group-time ATTs computed.\n")
cat("Number of ATT(g,t) estimates:", length(cs_out$att), "\n")

## Aggregate to dynamic event-time effects
cs_dynamic <- aggte(cs_out, type = "dynamic", min_e = -12, max_e = 16)
cat("\nCS Dynamic (Event-Time) Aggregation:\n")
print(summary(cs_dynamic))

## Aggregate to simple overall ATT
cs_simple <- aggte(cs_out, type = "simple")
cat("\nCS Simple (Overall) ATT:\n")
print(summary(cs_simple))

## Aggregate by group (cohort-specific ATTs)
cs_group <- aggte(cs_out, type = "group")
cat("\nCS Group (Cohort-Specific) ATTs:\n")
print(summary(cs_group))

## Aggregate by calendar time
cs_calendar <- aggte(cs_out, type = "calendar")
cat("\nCS Calendar-Time ATTs:\n")
print(summary(cs_calendar))

## Save CS results
saveRDS(cs_out, file.path(tab_dir, "cs_att_gt.rds"))
saveRDS(cs_dynamic, file.path(tab_dir, "cs_dynamic.rds"))
saveRDS(cs_simple, file.path(tab_dir, "cs_simple.rds"))
saveRDS(cs_group, file.path(tab_dir, "cs_group.rds"))
saveRDS(cs_calendar, file.path(tab_dir, "cs_calendar.rds"))

## ════════════════════════════════════════════════════════════
## 3. Heterogeneity by Baseline Characteristics
## ════════════════════════════════════════════════════════════

cat("\n=== Heterogeneity Analysis ===\n")

## By SC/ST share quartile
het_scst <- list()
for (q in c("Q1", "Q2", "Q3", "Q4")) {
  sub <- panel[sc_st_q == q]
  if (sub[, uniqueN(first_treat)] >= 2 & nrow(sub) > 100) {
    het_scst[[q]] <- feols(log_light ~ treated | dist_id + year,
                           data = sub, cluster = ~dist_id)
    cat("SC/ST", q, ": coef =", coef(het_scst[[q]])["treated"],
        ", se =", se(het_scst[[q]])["treated"], "\n")
  }
}

## By agricultural labor share quartile
het_ag <- list()
for (q in c("Q1", "Q2", "Q3", "Q4")) {
  sub <- panel[ag_labor_q == q]
  if (sub[, uniqueN(first_treat)] >= 2 & nrow(sub) > 100) {
    het_ag[[q]] <- feols(log_light ~ treated | dist_id + year,
                         data = sub, cluster = ~dist_id)
    cat("Ag Labor", q, ": coef =", coef(het_ag[[q]])["treated"],
        ", se =", se(het_ag[[q]])["treated"], "\n")
  }
}

## By baseline literacy quartile
het_lit <- list()
for (q in c("Q1", "Q2", "Q3", "Q4")) {
  sub <- panel[lit_q == q]
  if (sub[, uniqueN(first_treat)] >= 2 & nrow(sub) > 100) {
    het_lit[[q]] <- feols(log_light ~ treated | dist_id + year,
                          data = sub, cluster = ~dist_id)
    cat("Literacy", q, ": coef =", coef(het_lit[[q]])["treated"],
        ", se =", se(het_lit[[q]])["treated"], "\n")
  }
}

saveRDS(het_scst, file.path(tab_dir, "het_scst.rds"))
saveRDS(het_ag, file.path(tab_dir, "het_ag.rds"))
saveRDS(het_lit, file.path(tab_dir, "het_lit.rds"))

## ════════════════════════════════════════════════════════════
## 4. Phase-Specific Effects (do gains persist for Phase I?)
## ════════════════════════════════════════════════════════════

cat("\n=== Phase-Specific Analysis ===\n")

## Phase I vs Phase III (largest treatment contrast)
panel_p1_p3 <- panel[mgnrega_phase %in% c(1, 3)]
panel_p1_p3[, treat_p1 := as.integer(mgnrega_phase == 1 & year >= 2007)]

twfe_p1_p3 <- feols(log_light ~ treat_p1 | dist_id + year,
                     data = panel_p1_p3, cluster = ~dist_id)
cat("Phase I vs III:\n")
print(summary(twfe_p1_p3))

## Split into 5-year windows to see dynamics
for (window in list(c(2007, 2011), c(2012, 2016), c(2017, 2023))) {
  sub <- panel_p1_p3[year >= 1994 & year <= window[2]]
  sub[, treat_window := as.integer(mgnrega_phase == 1 &
                                     year >= window[1] & year <= window[2])]
  mod <- feols(log_light ~ treat_window | dist_id + year,
               data = sub, cluster = ~dist_id)
  cat(sprintf("Phase I effect (%d-%d): %.4f (%.4f)\n",
              window[1], window[2], coef(mod)["treat_window"],
              se(mod)["treat_window"]))
}

saveRDS(twfe_p1_p3, file.path(tab_dir, "twfe_phase1_vs3.rds"))

cat("\n=== Main analysis complete ===\n")
