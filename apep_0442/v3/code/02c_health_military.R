## ============================================================================
## 02c_health_military.R — Health and military record construction
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== CONSTRUCTING HEALTH & MILITARY RECORDS ===\n\n")

base <- file.path(data_dir, "costa_ua_raw")

## Load disease data (surgeons' certificates)
disease <- as.data.table(read_dta(file.path(base, "Data101_Disease_All/Disease_unionarmy.dta")))

## Load basics for military data and full merged for linkage
basics <- as.data.table(read_dta(file.path(base, "Data101_The_Basics_All/The_Basics_unionarmy.dta")))
dt <- readRDS(file.path(data_dir, "full_merged.rds"))

cat("Disease records:", nrow(disease), "\n")
cat("Unique veterans in disease:", uniqueN(disease$recidnum), "\n\n")

## ---- Parse exam dates ----
disease[, exam_year := as.numeric(substr(a_xmdate, 1, 4))]
disease[, exam_month := as.numeric(substr(a_xmdate, 5, 6))]
disease[, exam_date := exam_year + exam_month / 12]

## ---- Disability ratings from disease data ----
## gen_c_rat = cardiac rating
## gen_r_rat = respiratory rating
## gen_q_rat = abdominal/GI rating
## gen_d_rat = disease rating (composite)
## gen_w_rat = wound rating
## gen_p_rat = pulmonary rating

## Construct composite disability index per exam
## d_dia columns are character; count non-empty diagnoses
dia_cols <- intersect(c("d_dia1", "d_dia2", "d_dia3"), names(disease))
disease[, n_diagnoses := rowSums(sapply(.SD, function(x) !is.na(x) & nchar(x) > 0)),
        .SDcols = dia_cols]

## Severity scores are character — convert to numeric and sum
sev_cols <- grep("^d_sev[123][1-6]$", names(disease), value = TRUE)
for (col in sev_cols) {
  disease[, (col) := as.numeric(get(col))]
}
disease[, severity_sum := rowSums(.SD, na.rm = TRUE),
        .SDcols = sev_cols]

## Wound indicator — w_cau columns are also character
wnd_cols <- grep("^w_cau[1-9]$", names(disease), value = TRUE)
disease[, has_wound := as.integer(rowSums(sapply(.SD, function(x) !is.na(x) & nchar(x) > 0)) > 0),
        .SDcols = wnd_cols]

## ---- Collapse to veteran-level: most recent exam before 1907 ----
pre1907 <- disease[exam_year < 1907 & exam_year > 1870]
pre1907 <- pre1907[order(recidnum, -exam_date)]
pre1907_last <- pre1907[, .SD[1], by = recidnum]

cat("Veterans with pre-1907 exams:", nrow(pre1907_last), "\n")

## ---- Collapse to veteran-level: most recent exam after 1907 ----
post1907 <- disease[exam_year >= 1907 & exam_year <= 1920]
post1907 <- post1907[order(recidnum, -exam_date)]
post1907_last <- post1907[, .SD[1], by = recidnum]

cat("Veterans with post-1907 exams:", nrow(post1907_last), "\n")

## ---- Merge health indicators to main data ----
# Pre-1907 health
health_pre <- pre1907_last[, .(
  recidnum,
  n_diagnoses_pre = n_diagnoses,
  severity_pre = severity_sum,
  has_wound_pre = has_wound,
  exam_year_pre = exam_year,
  cardiac_pre = gen_c_rat,
  respiratory_pre = gen_r_rat,
  wound_rating_pre = gen_w_rat,
  disease_rating_pre = gen_d_rat
)]

# Post-1907 health
health_post <- post1907_last[, .(
  recidnum,
  n_diagnoses_post = n_diagnoses,
  severity_post = severity_sum,
  has_wound_post = has_wound,
  exam_year_post = exam_year,
  cardiac_post = gen_c_rat,
  respiratory_post = gen_r_rat,
  wound_rating_post = gen_w_rat,
  disease_rating_post = gen_d_rat
)]

dt <- merge(dt, health_pre, by = "recidnum", all.x = TRUE)
dt <- merge(dt, health_post, by = "recidnum", all.x = TRUE)

## ---- Health change (for mechanisms) ----
dt[, severity_change := severity_post - severity_pre]
dt[, n_diagnoses_change := n_diagnoses_post - n_diagnoses_pre]
dt[, cardiac_change := cardiac_post - cardiac_pre]

## ---- Military variables from Basics ----
## Height at enlistment
dt[, enlist_height := gen_hgt_early]

## Death cause
dt[, death_cause := rd_cause]

## ---- Count exams per veteran ----
exam_counts <- disease[, .(n_exams = .N,
                           n_exams_pre1907 = sum(exam_year < 1907, na.rm = TRUE),
                           n_exams_post1907 = sum(exam_year >= 1907, na.rm = TRUE)),
                       by = recidnum]
dt <- merge(dt, exam_counts, by = "recidnum", all.x = TRUE)
dt[is.na(n_exams), n_exams := 0L]
dt[is.na(n_exams_pre1907), n_exams_pre1907 := 0L]
dt[is.na(n_exams_post1907), n_exams_post1907 := 0L]

## ---- Summary ----
cat("\n--- HEALTH SUMMARY ---\n")
cat("Veterans with pre-1907 exam:", sum(dt$n_exams_pre1907 > 0), "\n")
cat("Veterans with post-1907 exam:", sum(dt$n_exams_post1907 > 0), "\n")
cat("Veterans with both:", sum(dt$n_exams_pre1907 > 0 & dt$n_exams_post1907 > 0), "\n")

cat("\nPre-1907 health (among those with exams):\n")
cat("  Mean severity:", round(mean(dt$severity_pre, na.rm = TRUE), 2), "\n")
cat("  Mean n_diagnoses:", round(mean(dt$n_diagnoses_pre, na.rm = TRUE), 2), "\n")
cat("  Pct with wounds:", round(mean(dt$has_wound_pre, na.rm = TRUE) * 100, 1), "%\n")

cat("\nMilitary:\n")
cat("  Mean enlist height:", round(mean(dt$enlist_height, na.rm = TRUE), 1), "inches\n")
cat("  Height non-missing:", sum(!is.na(dt$enlist_height)), "\n")

## ---- Save ----
saveRDS(dt, file.path(data_dir, "full_merged.rds"))

## Update analysis samples
cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))

health_vars <- c("n_diagnoses_pre", "severity_pre", "has_wound_pre", "exam_year_pre",
                 "cardiac_pre", "respiratory_pre", "wound_rating_pre", "disease_rating_pre",
                 "n_diagnoses_post", "severity_post", "has_wound_post", "exam_year_post",
                 "cardiac_post", "respiratory_post", "wound_rating_post", "disease_rating_post",
                 "severity_change", "n_diagnoses_change", "cardiac_change",
                 "enlist_height", "n_exams", "n_exams_pre1907", "n_exams_post1907")

for (v in health_vars) {
  if (v %in% names(dt)) {
    cross[[v]] <- dt[[v]][match(cross$recidnum, dt$recidnum)]
    panel[[v]] <- dt[[v]][match(panel$recidnum, dt$recidnum)]
  }
}

saveRDS(cross, file.path(data_dir, "cross_section_sample.rds"))
saveRDS(panel, file.path(data_dir, "panel_sample.rds"))

## Save disease-level data for mechanisms analysis
saveRDS(disease, file.path(data_dir, "disease_exams.rds"))

cat("\nAll health/military data merged and saved.\n")
cat("=== HEALTH & MILITARY RECORDS COMPLETE ===\n")
