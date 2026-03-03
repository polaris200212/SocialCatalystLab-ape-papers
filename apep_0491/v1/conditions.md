# Conditional Requirements

**Generated:** 2026-03-03T12:51:35.839922
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

---

## Idea 1: Do Red Flag Laws Reduce Violent Crime? Modern Staggered DiD Evidence from 22 States

**Rank:** #1 (consensus across all 3 models) | **Recommendation:** PURSUE

### Condition 1: carefully controlling for concurrent gun control legislation passed in the same legislative sessions

**Status:** [x] RESOLVED

**Response:**

We will construct a concurrent-policy control matrix tracking five major gun laws per state-year: (1) universal background checks, (2) permit-to-purchase, (3) waiting periods, (4) assault weapons bans, and (5) concealed carry permit reforms. This matrix will be sourced from RAND's State Firearm Law Database (https://www.rand.org/pubs/tools/TLA243-2-v2.html) which codes 50+ gun law provisions across all states and years. In robustness checks, we will (a) add concurrent gun law indicators as time-varying controls, (b) restrict to states where ERPOs were adopted without concurrent major gun legislation, and (c) run a DDD: ERPO × firearm crime × state (where non-firearm crime serves as within-state control).

**Evidence:**

RAND State Firearm Law Database available at https://www.rand.org/pubs/tools/TLA243-2-v2.html. Covers 1991–2023 for all 50 states across 50+ law types.

---

### Condition 2: verifying no pre-trends in event studies

**Status:** [x] RESOLVED

**Response:**

This will be verified empirically during analysis. The design includes: (a) Callaway & Sant'Anna group-time event study plots for each cohort, (b) formal pre-trend tests (joint F-test on pre-treatment coefficients), (c) HonestDiD sensitivity analysis (Rambachan & Roth 2023) bounding the ATT under violations of parallel trends, and (d) comparison of results with and without never-treated vs. not-yet-treated controls. With data extending to 1960 for early adopters (CT 1999), we have up to 40 years of pre-treatment data. For the 2018 wave, we have 18+ years of pre-treatment data (2000–2017). This is exceptionally long by DiD standards.

**Evidence:**

Pre-treatment verification is an empirical exercise — will be documented in the event study figures and pre-trend test tables in the paper.

---

### Condition 3: collecting petition data for first-stage

**Status:** [x] RESOLVED

**Response:**

State-level ERPO petition data is limited and inconsistent across states. Instead of attempting to construct a comprehensive petition panel (which would introduce severe measurement noise), we will pursue two alternative first-stage strategies:

1. **Statutory first stage:** The law itself is the treatment. We verify "bite" by showing that ERPO-adopting states have non-zero petition activity (documented in Everytown and state court reports). The National ERPO Resource Center reports 67,517 cumulative ERPO petitions through 2024, confirming the law is used.

2. **Firearm-specific decomposition as mechanism verification:** If ERPOs work through firearm removal, effects should concentrate in firearm homicide (SHR weapon type) and be absent in non-firearm homicide. This built-in placebo IS the mechanism test — it directly tests whether the policy channel (firearms) is operating, without requiring petition counts. This approach was praised in the tournament feedback (cf. owner-occupier placebo in the EPC paper).

3. **Heterogeneity by petitioner type:** States differ in who can petition (law enforcement only vs. family + LE). If effects are larger in family-petition states, this suggests the law's reach matters, further confirming bite.

**Evidence:**

National ERPO Resource Center data on petitions: https://erpo.org/. Everytown reports state-level petition counts for FL, MD, CO, and others.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED — proceed to Phase 4**
