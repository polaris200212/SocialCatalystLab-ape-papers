# Research Plan: "The First Retirement Age" v3

## Parent: apep_0442_v2

## Summary of Changes

### Data Source Switch
- **From:** IPUMS 1.4% oversampled 1910 census (N~3,800 Union veterans)
- **To:** Costa Union Army dataset (NBER "Early Indicators", N~39,340 white Union veterans)
  - Census records linked to 1900 and 1910 (panel)
  - Pension records with amounts, dates, law categories
  - Military service records with birth year, regiment
  - Surgeons' certificates with disability ratings, medical exams

### Identification Upgrade
- **Primary:** Panel RDD (ΔY = LFP₁₉₁₀ - LFP₁₉₀₀) at age-62-in-1907 threshold
- **First stage:** Observed pension take-up jump at 62 from pension records
- **Validation:** Pre-treatment falsification (LFP₁₉₀₀ smooth at cutoff)
- **Dropped:** Confederate placebo, diff-in-disc, border-state RDD

### New Analyses
- B1: Cross-sectional RDD with 10x power (MDE ~3-5pp)
- B2: Panel RDD (headline — absorbs person-fixed confounds)
- B3: Pre-treatment falsification (LFP₁₉₀₀ at cutoff)
- B4: Observed first stage (pension take-up at 62)
- B5: Fuzzy RDD / 2SLS LATE
- B6: Randomization inference (5,000 permutations)
- B7: Subgroup heterogeneity (by pension status, disability, occupation)
- B8: Dose-response (pension $ increase)
- B9: Health mechanisms (surgeons' certificates)
- B10: Occupation transitions (1900→1910)
- B11: Household effects (spouse LFP, mobility)

## Script Pipeline

```
00_packages.R              → Load libraries, set paths
01_fetch_data.R            → Download Costa UA data from NBER
01b_explore_data.R         → Data exploration and quality checks
02_clean_data.R            → Census panel construction via recidnum
02b_pension_records.R      → Pension record construction
02c_health_military.R      → Health + military records
03_main_analysis.R         → Cross-section + Panel RDD at 62
03b_first_stage.R          → Observed first stage + Fuzzy RDD
04_robustness.R            → Full robustness battery
04b_rand_inference.R       → Randomization inference
04c_subgroups.R            → Subgroup heterogeneity
04d_dose_response.R        → Pension amount dose-response
04e_health_mechanisms.R    → Health analysis from surgeons' certs
04f_occupation_transitions.R → Occupation flows 1900→1910
04g_household_panel.R      → Household/mobility effects
05_figures.R               → All 14 figures
06_tables.R                → All 13+ tables
paper.tex                  → Full paper (major revision)
references.bib             → Extended bibliography
```
