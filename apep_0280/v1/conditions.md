# Conditional Requirements

**Generated:** 2026-02-13T15:02:34.797994
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

---

## From Workplace to Living Room — Do Indoor Smoking Bans Cultivate Anti-Smoking Norms Beyond Their Legal Reach?

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: using month-of-interview to construct full-exposure measures or dropping partial-exposure first years

**Status:** [x] RESOLVED

**Response:**
BRFSS includes IMONTH (interview month) and IDAY (interview day) for each respondent. For bans taking effect mid-year (e.g., July 1), I will construct a binary treatment indicator that equals 1 only for respondents interviewed AFTER the ban's effective date. Additionally, as a robustness check, I will drop the partial-exposure adoption year entirely and define treatment as beginning in the first FULL calendar year after the ban takes effect. This ensures no measurement error from partial exposure.

**Evidence:**
BRFSS codebook confirms IMONTH variable availability across all years. CDC MMWR reports provide exact effective dates (month/day) for all 28 state bans. Implementation plan: `treatment_it = 1(interview_date >= state_ban_effective_date)`.

---

### Condition 2: explicitly controlling for cigarette taxes

**Status:** [x] RESOLVED

**Response:**
State-level cigarette excise tax rates (annual, all states) are available from the Tax Foundation and CDC's STATE System. I will include real (inflation-adjusted) state cigarette excise tax per pack as a time-varying control variable. Tax hikes are a major confounder because they often coincide with smoking ban adoption as part of broader tobacco-control packages.

**Evidence:**
Tax Foundation publishes "State Cigarette Excise Tax Rates & Rankings" annually. CDC STATE System API (https://data.cdc.gov) has dataset "hbkk-wb47" with state tobacco legislation including tax data. These will be downloaded in 01_fetch_data.R.

---

### Condition 3: tobacco-control funding

**Status:** [x] RESOLVED

**Response:**
CDC's STATE System tracks state tobacco-control spending (CDC Best Practices-recommended and actual spending). I will include per-capita state tobacco-control expenditures as a time-varying covariate. This controls for the possibility that states adopting bans also invest more in cessation campaigns, media, and quitlines.

**Evidence:**
CDC STATE System includes tobacco-control spending data by state and year, accessible via data.cdc.gov Socrata API. If API access proves difficult, I will use the published data tables from the Campaign for Tobacco-Free Kids, which compile state spending annually.

---

### Condition 4: major cessation-coverage expansions

**Status:** [x] RESOLVED

**Response:**
I will control for Medicaid cessation benefit expansion timing using indicators for: (1) whether the state's Medicaid program covered all 7 FDA-approved cessation medications, and (2) ACA Medicaid expansion status (2014+). The ACA mandated coverage of preventive services including cessation for private insurance (2010) and expanded Medicaid eligibility (2014). State variation in Medicaid expansion provides additional temporal variation.

**Evidence:**
KFF State Health Facts tracks Medicaid expansion dates by state. ASHLINE (American Lung Association) and CMS data document state Medicaid cessation coverage changes. I will construct binary indicators for these expansions.

---

### Condition 5: demonstrating clean pre-trends

**Status:** [x] RESOLVED

**Response:**
I will demonstrate clean pre-trends using three approaches:
1. **Event study plots** from the Callaway-Sant'Anna estimator showing group-time ATTs for all pre-treatment periods. Coefficients should be statistically indistinguishable from zero.
2. **HonestDiD sensitivity analysis** (Rambachan & Roth, 2023) to quantify how much pre-trend violation would be needed to explain away the post-treatment effects.
3. **Formal pre-trend tests** using the `pre_test_hom()` and `pre_test_het()` functions in the `did` package.

**Evidence:**
The `did` package in R (Callaway & Sant'Anna, 2021) automatically produces event study estimates with pre-treatment coefficients. The `HonestDiD` package implements the Rambachan-Roth sensitivity bounds. Both are well-established in the APEP codebase.

---

### Condition 6: running "leave-one-region-out"/border-state robustness

**Status:** [x] RESOLVED

**Response:**
I will implement two geographic robustness checks:
1. **Leave-one-region-out:** Re-estimate the main specification 4 times, each time dropping one Census region (Northeast, Midwest, South, West). Results should be qualitatively stable. This tests whether the effect is driven by a single region's idiosyncratic trends.
2. **Border-state analysis:** Restrict the comparison group to states that are geographically contiguous with treated states. Border states share labor markets, media markets, and cultural norms, providing a more comparable control group and addressing concerns about never-treated states being fundamentally different (Southern/low-regulation).

**Evidence:**
Census region codes available in BRFSS (_STATE). State adjacency can be coded directly. CS-DiD supports custom control group specification.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
