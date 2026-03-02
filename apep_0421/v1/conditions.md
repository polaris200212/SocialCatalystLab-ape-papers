# Conditional Requirements

**Generated:** 2026-02-20T08:49:11.900699
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for Idea #1 (JJM → Human Capital).

---

## Does Piped Water Build Human Capital? Evidence from India's Jal Jeevan Mission

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: Define exposure on an academic-year basis with lags

**Status:** [x] RESOLVED

**Response:**
JJM coverage will be measured as of the START of each academic year (June of year t for academic year t/t+1), not calendar year. UDISE+ data is reported per academic year (e.g., 2019-20 = data as of Sept 30, 2019). Treatment exposure is lagged: JJM coverage as of June 2020 maps to UDISE+ 2020-21 outcomes. This ensures that infrastructure built during an academic year does not contaminate same-year outcomes. The event study will define "treatment onset" as the first academic year where district JJM coverage exceeded a meaningful threshold (e.g., 20% of households connected).

**Evidence:**
UDISE+ reporting calendar confirmed via udiseplus.gov.in documentation. JJM dashboard provides cumulative coverage data that can be extracted at any point in time.

---

### Condition 2: Pre-specify a COVID strategy

**Status:** [x] RESOLVED

**Response:**
Three-pronged COVID strategy:
1. **Primary specification:** DROP academic years 2020-21 and 2021-22 from the estimation sample. Pre-period: 2015-16 through 2019-20 (5 years). Post-period: 2022-23 through 2024-25 (3 years). This gives a clean pre/post without COVID contamination.
2. **Robustness check 1:** Include COVID years but add state × year fixed effects to absorb heterogeneous COVID impacts.
3. **Robustness check 2:** Include COVID years with explicit COVID control variables (state-level school closure duration from UNESCO/UDISE+ monitoring data).
4. **Event study:** Will show dynamic effects with COVID years visible as a "dip" — if the post-COVID recovery shows JJM-correlated improvement, this strengthens the result.

**Evidence:**
Strategy aligns with standard practice in education DiD papers during COVID era (e.g., Agostinelli et al. 2022). Dropping 2020-21 is common when school closures create measurement artifacts in enrollment data.

---

### Condition 3: Validate JJM dashboard coverage against NFHS/other surveys

**Status:** [x] RESOLVED

**Response:**
Cross-validation plan:
1. Compare JJM dashboard "% HH with tap connections" against NFHS-5 district factsheet indicator "Households with piped water into dwelling" for overlapping districts and time periods.
2. Compute correlation between JJM coverage (2019-20 early implementation) and NFHS-5 piped water indicator (2019-21 fieldwork) at district level. High correlation validates the JJM administrative data.
3. Report the cross-validation results in the paper as a "data quality" section.
4. If discrepancies are large, use NFHS-5 piped water indicator as an alternative treatment measure (cross-sectional intensity) and report as robustness.

**Evidence:**
NFHS-5 district factsheets available as CSV (GitHub: SaiSiddhardhaKalla/NFHS). JJM dashboard confirmed accessible with district-level data. Both sources report "piped water" indicators at district level.

---

### Additional Design Decisions (from ranking feedback)

**Outcome dilution (JJM is rural, UDISE+ includes urban schools):**
Will restrict sample to rural schools/blocks where possible using UDISE+ school-level rural/urban classification. Alternatively, weight district outcomes by rural population share from Census 2011.

**Selection into treatment (faster rollout in better-governed districts):**
Include district-level baseline controls (Census 2011: population, literacy, SC/ST share, urbanization). Test for pre-trend differences using 5 pre-treatment years. Report balance tables for early vs late treated districts. Use Callaway & Sant'Anna (2021) estimator that is robust to heterogeneous treatment timing.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
