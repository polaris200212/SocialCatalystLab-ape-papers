# Conditional Requirements

**Generated:** 2026-02-17T11:13:00.831964
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## State Minimum Wage Increases and the Medicaid Home Care Workforce

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: dropping/handling cohorts without adequate pre-period

**Status:** [x] RESOLVED

**Response:**

We will define treatment cohorts by the year of their first MW increase during 2018–2024. Cohorts with fewer than 24 months of pre-treatment data (i.e., states that increased MW in 2018 or early 2019) will be handled as follows:

1. **Primary specification:** Restrict to cohorts with ≥24 months pre-treatment. This drops states whose first increase occurs before January 2020, ensuring at least 2 full years of pre-data.
2. **Robustness:** Report results including all cohorts (relaxing to ≥12 months pre-treatment). The Callaway & Sant'Anna estimator handles heterogeneous treatment timing and allows cohort-specific pre-trend testing.
3. **Sensitivity:** Show results are stable across different minimum pre-period thresholds (12, 18, 24, 36 months).

**Evidence:** T-MSIS covers Jan 2018–Dec 2024 (84 months). States with first MW increase in 2020+ have ≥24 months pre. Most large MW increases occurred 2019–2023, so this restriction retains the majority of variation.

---

### Condition 2: demonstrating no differential pre-trends using event studies

**Status:** [x] RESOLVED

**Response:**

The CS estimator produces group-time ATTs that directly enable event-study plots. We will:

1. **Event-study specification:** Plot dynamic ATT estimates for 24+ months before and after treatment. Test joint significance of pre-treatment coefficients.
2. **Pre-trend F-tests:** Report formal tests of H0: all pre-treatment coefficients = 0.
3. **HonestDiD sensitivity:** Apply Rambachan & Roth (2023) to bound ATTs under violations of parallel trends, reporting honest confidence intervals.
4. **Placebo cohorts:** Assign fake treatment dates to never-treated states and verify null effects.

**Evidence:** CS estimator's `aggte()` function with `type = "dynamic"` produces exactly these event-study estimates.

---

### Condition 3: strengthening the control strategy beyond "never-treated states"

**Status:** [x] RESOLVED

**Response:**

Three complementary control strategies:

1. **Not-yet-treated controls:** In addition to never-treated states (those at federal $7.25 throughout), use not-yet-treated states as controls — this is the default in CS and increases the comparison group substantially.
2. **Contiguous border-county pairs:** Following Dube, Lester, and Reich (2010), construct pairs of counties straddling state borders where one side experienced a MW increase and the other did not. NPPES ZIP codes → county FIPS → border-pair fixed effects. This absorbs unobserved local economic conditions.
3. **Covariate balancing:** Match treated and control states on pre-treatment HCBS spending levels, provider counts, urbanization, Medicaid expansion status, and political lean using propensity-score weighting within the CS framework (`est_method = "ipw"`).

**Evidence:** Border-county designs are the gold standard in minimum wage research (Dube, Lester, Reich 2010; Cengiz et al. 2019). NPPES provides ZIP-level geography enabling county-level analysis. Census ZCTA-to-county crosswalk is freely available.

---

### Condition 4: (malformed — duplicate of conditions 3 and 5)

**Status:** [x] NOT APPLICABLE

**Response:** This condition appears to be a parsing artifact (the text reads `" e.g.`). The substance is captured in Conditions 3 and 5.

---

### Condition 5: border-pair / matched-state designs

**Status:** [x] RESOLVED

**Response:**

Addressed in Condition 3 above. Specifically:

1. **Border-county pairs:** Identify all county pairs where counties share a state border and experienced differential MW changes. Estimate within-pair DiD. This is the most credible specification in MW research.
2. **Matched-state design:** Use synthetic control methods (for case studies of large single increases like CA's move to $15+) as robustness checks on the CS main results.
3. **Region × time fixed effects:** Include Census division × month FE to absorb regional trends, ensuring comparisons are within-region.

**Evidence:** NPPES maps NPIs to 9-digit ZIPs → county FIPS. Census TIGER/Line shapefiles identify contiguous county pairs across state borders.

---

### Condition 6: falsification outcomes

**Status:** [x] RESOLVED

**Response:**

Three falsification tests:

1. **Non-HCBS Medicaid providers:** Estimate the same specification on providers billing CPT codes (physician office visits like 99213/99214). These providers are NOT low-wage and should be unaffected by MW changes. A null result validates the mechanism.
2. **High-wage provider specialties:** Using NPPES taxonomy, restrict to providers with high-wage specialties (physicians, dentists) billing Medicaid. MW should not affect their supply.
3. **Drug/DME codes:** J-codes (injectable drugs) and E-codes (durable medical equipment) are not labor-intensive services. MW increases should not affect billing patterns for these codes.

**Evidence:** T-MSIS contains all HCPCS codes, enabling clean separation of treatment-exposed (T/H/S codes, low-wage workforce) from treatment-unexposed (CPT, J, E codes, high-wage workforce) outcomes.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git
