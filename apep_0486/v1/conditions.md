# Conditional Requirements

**Generated:** 2026-03-02T18:33:08.916198
**Status:** RESOLVED

---

## Decarceration Without Danger (Idea 1) — Merged with Racial Convergence (Idea 4)

### Condition 1: COVID/post-2020 shock strategy

**Status:** [x] RESOLVED

**Response:**
Three-pronged strategy: (1) Restrict primary specification to pre-COVID treatment cohorts only (DAs elected 2014–2019, observed through 2019). (2) Full-sample specification includes year × region FEs and COVID severity controls (county-level COVID death rates). (3) Cohort-specific event studies show effects separately for pre-2020 and post-2020 cohorts. If only post-2020 cohorts drive effects, conclude COVID confounding.

**Evidence:** Staggered timing provides 15+ pre-COVID treated counties (Foxx 2016, Krasner 2018, Ogg 2016, Gardner 2016, etc.) with 3–5 years of post-treatment, pre-COVID data. CS-DiD naturally separates cohort-specific effects.

---

### Condition 2: Statewide bail/sentencing reform controls

**Status:** [x] RESOLVED

**Response:**
Hand-code statewide bail reform dates for states containing treated counties: NJ (Jan 2017 bail reform), NY (Jan 2020), CA (SB 10 signed 2018, not implemented; Prop 25 failed 2020), IL (Jan 2023 Pretrial Fairness Act). Include state × year FE in primary specification, which absorbs all statewide reforms. For states with DA-level AND state-level reform overlap, run specifications that interact treatment with state reform indicator and show effects are from DA elections, not state reforms.

**Evidence:** State × year FE is standard in CS-DiD literature (Callaway & Sant'Anna include group × time structure). The key NJ reform (2017) predates most progressive DA elections; NY reform (2020) is post-COVID and handled by COVID strategy.

---

### Condition 3: Leave-one-large-county-out influence analysis

**Status:** [x] RESOLVED

**Response:**
Run full specification sequentially dropping each of the 5 largest treated counties: Cook (5.2M), LA (10M), Harris (4.7M), Philadelphia (1.6M), and Dallas (2.6M). Report coefficient stability. If any single county drives the result, flag it explicitly and report with/without.

**Evidence:** Standard sensitivity test; will be implemented in 04_robustness.R.

---

### Condition 4: Transparent suppression/measurement plan (Race-specific data)

**Status:** [x] RESOLVED

**Response:**
For Vera jail data: Race-specific populations are continuous and not suppressed. For CHR homicide data: Race-specific rates use vital statistics with multi-year averages. Counties with zero race-specific homicides in any period will be flagged. Primary DDD analysis restricted to counties with ≥10 homicides per race-year cell (effectively the large-county subsample). Report how many counties/observations are dropped and show results with and without the restriction.

**Evidence:** Progressive DA counties are overwhelmingly large urban counties (median population >500K) where race-specific homicide counts are substantial. This reduces the suppression concern considerably.

---

### Condition 5: Pre-trend/event-study visuals

**Status:** [x] RESOLVED

**Response:**
Primary analysis uses Callaway & Sant'Anna (2021) with group-time ATT estimates. Event study plots will show dynamic effects from -8 to +6 years relative to DA election. Pre-trend test: joint F-test of pre-treatment coefficients. Visual inspection of event study for parallel trends. HonestDiD sensitivity analysis for pre-trend violations.

**Evidence:** Will be generated as main Figure 1 (jail population event study) and Figure 2 (homicide event study). 8+ years of pre-treatment data for earliest cohorts.

---

### Condition 6: Race-placebo tests

**Status:** [x] RESOLVED

**Response:**
Run DDD with AAPI or "Other" race categories as placebo groups. Progressive DAs did not specifically target AAPI incarceration, so any effects on AAPI jail populations or homicides would indicate confounding rather than DA policy. Also run White-only DiD as a benchmark; effects should be smaller than Black effects if the policy targets racial disparities.

**Evidence:** Vera data includes AAPI, Native, and "Other" race categories at the county level.

---

### Condition 7: COVID-robustness checks (Grok)

**Status:** [x] RESOLVED

**Response:** Covered by Condition 1. Additionally: (1) Include COVID death rate as time-varying control, (2) Show results excluding 2020 entirely, (3) Show results using only 2010–2019 sample.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
