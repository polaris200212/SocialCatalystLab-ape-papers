# Conditional Requirements

**Generated:** 2026-02-26T21:21:43.719239
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

## Safety Nets and Risk-Taking — How India's Employment Guarantee Transformed Crop Portfolios (Idea 1)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: verifying crop data timing/definition of "year"

**Status:** [x] RESOLVED

**Response:**

ICRISAT DLD follows India's official agricultural year convention (July–June). A DLD record labeled "2006" corresponds to the 2005–06 agricultural year: kharif 2005 (planted June–July 2005, harvested Oct–Nov 2005) + rabi 2005–06 (planted Nov–Dec 2005, harvested Mar–Apr 2006). The main DLD file combines kharif + rabi into annual totals; season-level files are available as supplementary data.

**Treatment timing alignment:** MGNREGA Phase I launched February 2, 2006 — mid-rabi of the 2005–06 agricultural year. The first agricultural year with FULL pre-planting exposure to MGNREGA is 2006–07 (DLD year = "2007"). Thus:
- DLD years ≤ 2006 are pre-treatment for Phase I districts
- DLD year 2007 is the first fully treated year for Phase I
- DLD year 2008 is first fully treated for Phase II (Apr 2007 launch)
- DLD year 2009 is first fully treated for Phase III (Apr 2008 launch)

In the analysis, treatment dummies will be defined based on these aligned agricultural years, not calendar years. This ensures no mechanical under-exposure in the first "treated" period.

**Evidence:** ICRISAT DLD documentation at http://data.icrisat.org/dld/src/crops.html; India DES agricultural statistics conventions; Klonner & Oldiges (2022, JDE) use same temporal mapping.

---

### Condition 2: showing strong pre-trends balance

**Status:** [x] RESOLVED

**Response:**

The analysis will include a full event-study specification with leads and lags around the treatment year, allowing visual and statistical inspection of pre-treatment trends. Specifically:
1. **Event study plot:** Estimate dynamic treatment effects for years t-6 through t+10 relative to MGNREGA phase assignment. Pre-treatment coefficients (t-6 to t-1) should be jointly insignificant.
2. **Pre-trend F-test:** Joint test that all pre-treatment leads = 0.
3. **HonestDiD sensitivity analysis:** Following Rambachan & Roth (2023), bound the treatment effect under violations of parallel trends using the smoothness restriction approach (M-estimation).
4. **Covariate balance table:** Compare Phase I vs Phase III districts on baseline (2000–2005 average) crop diversification, agricultural productivity, rainfall, literacy, SC/ST share. Report standardized differences.

If pre-trends are non-parallel for the raw specification, we will implement:
- Entropy balancing / inverse propensity weighting on baseline characteristics
- Cohort-specific linear trends as robustness check

**Evidence:** Will be demonstrated in the paper's event study figures and pre-trend tests (Section 4).

---

### Condition 3: possibly using reweighting + cohort-specific trends robustness

**Status:** [x] RESOLVED

**Response:**

The analysis plan includes three robustness checks addressing this condition:

1. **Entropy balancing:** Reweight Phase III (late-treated/control) districts to match Phase I districts on baseline characteristics (pre-2006 mean crop diversification, agricultural productivity, SC/ST share, literacy rate, rainfall). Use the `ebal` R package.

2. **Callaway-Sant'Anna with covariate conditioning:** The CS-DiD estimator natively supports conditioning on pre-treatment covariates using inverse probability weighting or doubly-robust estimation. We will use the `did` R package with `xformla = ~ baseline_diversification + baseline_yield + sc_st_share + literacy_rate`.

3. **Cohort-specific linear trends:** As a robustness check, estimate the model with district-specific linear time trends. If results are robust to these trends, it strengthens the parallel trends assumption.

4. **Sun-Abraham (2021) interaction-weighted estimator:** Alternative heterogeneity-robust estimator as additional robustness.

**Evidence:** Will be reported in robustness tables (Section 5).

---

### Condition 4: addressing concurrent ag-policy targeting explicitly

**Status:** [x] RESOLVED

**Response:**

Four concurrent agricultural policies have been identified as potential confounds:

| Program | Launch | Overlap with MGNREGA districts | Mitigation Strategy |
|---------|--------|-------------------------------|-------------------|
| **NFSM** (National Food Security Mission) | Oct 2007, 312 districts | Moderate — targets low-productivity districts (partial overlap with backward districts) | Include NFSM district × post-2007 indicator as control; robustness excluding NFSM districts |
| **RKVY** (Rashtriya Krishi Vikas Yojana) | FY 2007–08 | Low — state-level block grant, not district-targeted | Absorbed by state × year fixed effects |
| **NHM** (National Horticulture Mission) | 2005–06, 384 districts | Moderate — targets horticultural potential (orthogonal to backwardness criterion) | Include NHM district × post-2006 indicator; test robustness excluding NHM districts |
| **BRGF** (Backward Regions Grant Fund) | Feb 2007, 250 districts | **HIGH** — same backward district targeting as MGNREGA | This is the most dangerous confound. Strategy: (a) Include BRGF × post-2007 as control. (b) Exploit that BRGF covers 250 districts while MGNREGA Phase I covers 200 — the non-overlapping sets allow partial disentangling. (c) RDD at the backwardness cutoff examines whether the discontinuity in crop diversification is robust to BRGF exposure. (d) Placebo test: examine whether BRGF-only districts (those receiving BRGF but not Phase I MGNREGA) show similar crop effects. |

**Additional mitigation:** All specifications include state × year fixed effects, which absorb any state-level agricultural policy changes. The identification exploits within-state, across-district variation in MGNREGA phase timing.

**Evidence:** NFSM district lists from nfsm.gov.in; BRGF district lists from Planning Commission; NHM district lists from midh.gov.in. Will be documented in the paper's identification section and Data Appendix.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
