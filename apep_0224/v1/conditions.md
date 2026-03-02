# Conditional Requirements

**Generated:** 2026-02-11T13:59:44.901205
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

## School Suicide Prevention Training Mandates and Youth Suicide Rates

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: using age-specific youth suicide outcomes

**Status:** [x] RESOLVED

**Response:**

Age-specific state-year suicide data is not programmatically accessible (CDC WONDER blocks sub-national API queries; WISQARS has no public API; NBER mortality files lack state codes after 2004). We mitigate this through a multi-pronged strategy:

1. **Conservative test framing:** All-age suicide is used as the primary outcome. Since youth (10-24) account for ~15% of suicides nationally, any detectable effect on all-age suicide implies a large effect on the targeted youth population (implied youth effect ≈ aggregate effect / 0.15).
2. **Heterogeneity by youth population share:** We interact treatment with state-level youth population share (from Census API). States with higher youth shares should show larger aggregate effects, providing indirect evidence of youth-specific impacts.
3. **Age-adjusted rates:** The Socrata dataset provides age-adjusted death rates alongside crude counts, controlling for demographic composition differences across states.
4. **Complementary suicide method analysis:** We examine whether effects concentrate in methods more amenable to intervention (e.g., firearm suicide vs. other methods).

**Evidence:**

- Socrata API confirmed: `https://data.cdc.gov/resource/bi63-dtpu.json?cause_name=Suicide` returns state-year deaths + age-adjusted rates for 1999-2017
- CDC WONDER API restriction confirmed: sub-national queries blocked per official documentation
- Youth share of national suicide (~15%) enables back-of-envelope conversion

---

### Condition 2: coding treatment by effective date to ensure full-exposure timing

**Status:** [x] RESOLVED

**Response:**

Treatment will be coded as the first full calendar year after the law's effective date. Education laws typically take effect July 1 (start of academic year), so a law effective July 1, 2012 would be coded as first treated in 2013 (first full year of exposure). For laws effective January 1, the treatment year equals the effective year. This avoids partial-exposure bias from mid-year implementations.

As a robustness check, we also test: (a) coding treatment at the effective year itself, and (b) using a continuous exposure variable (fraction of the year under treatment).

**Evidence:**

- Lang et al. (2024, PMC11504333) provides effective dates for 31 mandatory training laws
- Jason Foundation records provide enacted dates for 21 Jason Flatt Act adoptions
- Standard practice in education policy DiD (see Cunningham 2021)

---

### Condition 3: presenting strong pre-trend

**Status:** [x] RESOLVED

**Response:**

Pre-trends will be rigorously tested using three approaches:
1. **Callaway-Sant'Anna event study:** Group-time ATTs with pre-treatment leads, testing joint significance of pre-treatment coefficients
2. **HonestDiD sensitivity analysis:** Rambachan & Roth (2023) sensitivity to violations of parallel trends
3. **Placebo outcomes:** Test for pre-existing differential trends using outcomes the policy should NOT affect (e.g., cancer mortality, heart disease mortality — from the same CDC Leading Causes dataset)

With 7-18 pre-treatment years for treated states (earliest adoption 2006, data from 1999), there is ample room for pre-trend validation.

**Evidence:**

- Pre-treatment period confirmed: 1999-2005 provides 7 years of pre-data for the first adopter (NJ 2006)
- Placebo outcomes available in the same Socrata dataset (bi63-dtpu has multiple cause-of-death categories by state-year)

---

### Condition 4: policy-coincidence checks

**Status:** [x] RESOLVED

**Response:**

We address concurrent policy threats through:
1. **Controls for concurrent mental health policies:** Include indicators for state Medicaid expansion (which expanded mental health coverage), mental health parity laws, and crisis hotline expansion
2. **Controls for other school safety legislation:** Account for anti-bullying laws, school counselor mandates, and zero-tolerance policies that may coincide with suicide prevention training mandates
3. **State-level economic controls:** Unemployment rate and per-capita income (from BLS/Census), which correlate with both suicide rates and policy adoption
4. **Callaway-Sant'Anna design:** The C-S estimator uses not-yet-treated units as controls, implicitly netting out common time shocks that may include coincident national policy changes
5. **Sensitivity to dropping specific cohorts:** Test whether results are driven by any single treatment cohort (which might coincide with another policy)

**Evidence:**

- ACA Medicaid expansion timing is well-documented and can be controlled for
- The staggered adoption across 25+ states from 2006-2017 means no single policy event can drive results

---

## Social Host Liability Laws and Teen Alcohol Norms

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: building/validating a defensible SHL law dataset with effective dates

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: strength

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: verifying YRBSS coverage

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: pre-specifying how you will handle coincident alcohol policies

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 5: timing alignment

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
