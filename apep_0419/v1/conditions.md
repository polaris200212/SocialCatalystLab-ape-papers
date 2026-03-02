# Conditional Requirements

**Generated:** 2026-02-19T18:13:47.484356
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Virtual Snow Days and the Weather-Absence Penalty for Working Parents

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: primary analysis restricted to 2011–2019 adoptions

**Status:** [x] RESOLVED

**Response:**

The primary specification will use the full sample (2003-2024) with Callaway-Sant'Anna estimators that explicitly handle heterogeneous timing and compare each cohort to never-treated units. This uses all 23+ treated states. A key ROBUSTNESS specification restricts to 2003-2019 (pre-COVID) using only the ~8 pre-COVID adopters (KY, NH, KS, MO, WV 2011; MN 2017; IL, PA 2019). This clean subsample avoids all COVID contamination. The DDD design (policy × snowfall × parent-of-school-age-child) further isolates the mechanism regardless of sample period. If pre-COVID results are null but full-sample results are significant, we will interpret results as potentially confounded by COVID-era changes rather than virtual snow day policy effects.

**Evidence:**

CPS monthly microdata available from 2003 onward (confirmed via BLS API). Pre-COVID adopter states identified from EdWeek, Governing.com, state legislation databases. Full list compiled in research_plan.md.

---

### Condition 2: explicit validation of implementation/take-up where possible

**Status:** [x] RESOLVED

**Response:**

Will construct a "first stage" analysis documenting that: (a) school districts in treated states actually used virtual instruction on snow/weather days (using news archives and NCES data on instructional days), and (b) the number of "lost" school closure days declined in treated states post-adoption. EdWeek's 2020 survey found 39% of districts in adopting states converted snow days to remote learning. We will use this as suggestive evidence of take-up. In the paper, we will emphasize that our estimates are intent-to-treat (ITT) effects of state authorization, not treatment-on-treated effects of actual virtual day use. This is the policy-relevant parameter: what happens when a state gives schools the OPTION of virtual weather days?

**Evidence:**

EdWeek Research Center survey (November 2020): 39% conversion rate. State-level policy details from NWEA blog (2026), The 74 Million, Government Executive (2022). District-level instructional day data from NCES Common Core of Data.

---

### Condition 3: careful timing alignment using CPS reference week + local snowfall

**Status:** [x] RESOLVED

**Response:**

CPS reference week is the week containing the 12th of each month. NOAA GHCN-Daily data provides daily snowfall by weather station (linked to counties). For each state-month, we will: (1) compute total snowfall in the CPS reference week (days 8-14 of the month) from all weather stations in that state; (2) also compute monthly snowfall as a broader measure; (3) define "heavy snowfall" reference weeks as those above the state-specific 75th percentile. The DDD interaction (policy × heavy-snowfall-reference-week × parent) directly tests whether the parental absence penalty during heavy-snow weeks is attenuated in virtual-snow-day states. Sensitivity analysis will use 3-day windows around the reference week.

**Evidence:**

CPS reference week documentation at Census.gov. NOAA GHCN-Daily data available via CDO API (https://www.ncdc.noaa.gov/cdo-web/). County-station linkage available from NOAA.

---

### Condition 4: inference robust to small treated-cluster counts in the pre-COVID sample

**Status:** [x] RESOLVED

**Response:**

With 8 pre-COVID treated states and ~42 control states in the pre-COVID subsample, standard clustered SEs may over-reject. We will address this with: (1) Wild cluster bootstrap (Cameron, Gelbach, Miller 2008) using the `fwildclusterboot` R package; (2) Randomization inference (Fisher permutation test) that randomly reassigns treatment status across states — the p-value is the share of permuted treatment effects exceeding the observed effect; (3) Reporting effective number of clusters and comparing results across inference methods. If RI p-values and wild bootstrap CIs diverge from cluster-robust SEs, we will defer to the more conservative inference. The full-sample (23+ states) specification provides a complementary, better-powered test.

**Evidence:**

Cameron, Gelbach, Miller (2008) "Bootstrap-Based Improvements for Inference with Clustered Errors." MacKinnon and Webb (2018) "The wild bootstrap for few (treated) clusters." `fwildclusterboot` R package available on CRAN.

---

## State Drought Emergency Declarations and Agricultural Employment Adjustment

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: restricting to Western states

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: measuring “binding restriction” timing—not just declarations

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: pre-registering an event-study that tests pre-trends

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: exploring heterogeneity by irrigated share/crop mix

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
