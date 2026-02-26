## ============================================================================
## 11_v3_revision.R — Stage C Revision: Additional analyses requested by referees
## APEP-0460 v3: Across the Channel
## ============================================================================

cat("=== APEP-0460 v3 Stage C Revision ===\n")
cat("Start time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")

library(data.table)
library(fixest)
library(ggplot2)
library(patchwork)

# Directories
data_dir <- file.path(dirname(getwd()), "data")
fig_dir  <- file.path(dirname(getwd()), "figures")
tab_dir  <- file.path(dirname(getwd()), "tables")

# Load data
type_panel <- as.data.table(readRDS(file.path(data_dir, "property_type_panel.rds")))

# Load saved results for diagnostics
results <- readRDS(file.path(data_dir, "v3_results.rds"))

# Publication theme
apep_theme <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", size = 12),
        axis.title = element_text(size = 10))

## ========================================================================
## R1: HOUSE-APARTMENT GAP EVENT STUDY (GPT request)
## ========================================================================
cat("=== R1: House-Apartment Gap Event Study ===\n")

# Create wide panel: one row per dept x quarter
type_wide <- dcast(type_panel, code_departement + yq + post +
                     log_sci_uk + log_uk_stock_2011 + log_sci_de ~
                     type_local,
                   value.var = "log_price_m2")

type_wide[, gap := Maison - Appartement]
type_wide <- type_wide[!is.na(gap)]
cat("  Gap panel:", nrow(type_wide), "observations\n")

# Create numeric period relative to 2016-Q3
yq_levels <- sort(unique(type_wide$yq))
ref_idx <- which(yq_levels == "2016Q2")
type_wide[, ref_period := match(yq, yq_levels) - ref_idx]

# Event study: gap ~ exposure x period | dept + period FE
es_gap_sci <- tryCatch(
  feols(gap ~ i(ref_period, log_sci_uk, ref = 0) | code_departement + yq,
        data = type_wide, cluster = ~code_departement),
  error = function(e) { cat("  Error (SCI):", e$message, "\n"); NULL }
)

es_gap_stock <- tryCatch(
  feols(gap ~ i(ref_period, log_uk_stock_2011, ref = 0) | code_departement + yq,
        data = type_wide[!is.na(log_uk_stock_2011)], cluster = ~code_departement),
  error = function(e) { cat("  Error (stock):", e$message, "\n"); NULL }
)

if (!is.null(es_gap_sci)) cat("  SCI gap event study: OK\n")
if (!is.null(es_gap_stock)) cat("  Stock gap event study: OK\n")

# Plot
plot_gap_event <- function(model, title, color = "#1B4F72") {
  if (is.null(model)) return(ggplot() + ggtitle(paste(title, "(FAILED)")))
  ct <- coeftable(model)
  rows <- grepl("ref_period", rownames(ct))
  if (sum(rows) == 0) return(ggplot() + ggtitle(paste(title, "(no coefs)")))
  d <- data.frame(
    period = as.numeric(gsub("ref_period::(-?[0-9]+):.*", "\\1", rownames(ct)[rows])),
    coef = ct[rows, 1],
    se = ct[rows, 2]
  )
  d <- rbind(d, data.frame(period = 0, coef = 0, se = 0))
  d <- d[order(d$period), ]
  d$ci_lo <- d$coef - 1.96 * d$se
  d$ci_hi <- d$coef + 1.96 * d$se

  ggplot(d, aes(x = period, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = 0, linetype = "dotted", color = "red", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = color, alpha = 0.2) +
    geom_line(color = color) +
    geom_point(color = color, size = 1.5) +
    labs(title = title, x = "Quarters relative to 2016-Q3",
         y = "Coefficient on Exposure") +
    apep_theme
}

p1 <- plot_gap_event(es_gap_sci, "A: House-Apt Gap x SCI", "#1B4F72")
p2 <- plot_gap_event(es_gap_stock, "B: House-Apt Gap x Census Stock", "#922B21")

p_combined <- p1 + p2 + plot_layout(ncol = 2) +
  plot_annotation(title = "House-Apartment Price Gap Event Study",
                  theme = theme(plot.title = element_text(face = "bold", size = 13)))

ggsave(file.path(fig_dir, "fig_gap_event_study.pdf"),
       p_combined, width = 10, height = 5)
cat("  Saved fig_gap_event_study.pdf\n")

# Pre-trend F-test on gap
if (!is.null(es_gap_stock)) {
  gap_ct <- coeftable(es_gap_stock)
  gap_pre <- rownames(gap_ct)[grepl("ref_period", rownames(gap_ct))]
  gap_pre_p <- as.numeric(gsub("ref_period::(-?[0-9]+):.*", "\\1", gap_pre))
  gap_pre <- gap_pre[gap_pre_p < 0]
  if (length(gap_pre) > 0) {
    wald_gap <- wald(es_gap_stock, gap_pre)
    cat("  Gap pre-trend F-test: F =", round(wald_gap$stat, 3),
        " p =", round(wald_gap$p, 4), "\n")
  }
}

## ========================================================================
## R2: COVID SUBSAMPLE — Triple-diff pre/post-2020
## ========================================================================
cat("\n=== R2: COVID Subsample ===\n")

# Parse year from yq
type_panel[, yr := as.integer(substr(yq, 1, 4))]

# Pre-COVID (2014-2019)
f_pre_covid <- tryCatch(
  feols(log_price_m2 ~ house:log_uk_stock_2011:post |
          dept_type + yq_type + dept_yq,
        data = type_panel[yr <= 2019 & !is.na(log_uk_stock_2011) & n_transactions >= 5],
        cluster = ~code_departement),
  error = function(e) { cat("  Pre-COVID error:", e$message, "\n"); NULL }
)

# Post-COVID (2020-2023)
f_post_covid <- tryCatch(
  feols(log_price_m2 ~ house:log_uk_stock_2011:post |
          dept_type + yq_type + dept_yq,
        data = type_panel[yr >= 2020 & !is.na(log_uk_stock_2011) & n_transactions >= 5],
        cluster = ~code_departement),
  error = function(e) { cat("  Post-COVID error:", e$message, "\n"); NULL }
)

if (!is.null(f_pre_covid)) {
  cat("  Pre-COVID (2014-2019) triple-diff:\n")
  print(coeftable(f_pre_covid))
}
if (!is.null(f_post_covid)) {
  cat("  Post-COVID (2020-2023) triple-diff:\n")
  print(coeftable(f_post_covid))
}

## ========================================================================
## R3: EXCLUDE PARIS + COTE D'AZUR TRIPLE-DIFF
## ========================================================================
cat("\n=== R3: Triple-diff ex. luxury departments ===\n")

luxury_depts <- c("75", "06", "83", "92", "93", "94")
cat("  Excluding:", paste(luxury_depts, collapse = ", "), "\n")

f_no_luxury <- tryCatch(
  feols(log_price_m2 ~ house:log_sci_uk:post |
          dept_type + yq_type + dept_yq,
        data = type_panel[!(code_departement %in% luxury_depts) & n_transactions >= 5],
        cluster = ~code_departement),
  error = function(e) { cat("  Error:", e$message, "\n"); NULL }
)

if (!is.null(f_no_luxury)) {
  cat("  Triple-diff (no luxury):\n")
  print(coeftable(f_no_luxury))
}

## ========================================================================
## R4: PRE-TREND F-TEST SUMMARY
## ========================================================================
cat("\n=== R4: Pre-trend Summary ===\n")

if (!is.null(results$wald_pre_sci)) {
  cat("SCI event study pre-trend: F =", round(results$wald_pre_sci$stat, 3),
      " p =", round(results$wald_pre_sci$p, 4), "\n")
}
if (!is.null(results$wald_pre_stock)) {
  cat("Stock event study pre-trend: F =", round(results$wald_pre_stock$stat, 3),
      " p =", round(results$wald_pre_stock$p, 4), "\n")
}

cat("\n=== Stage C Complete ===\n")
cat("End time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
