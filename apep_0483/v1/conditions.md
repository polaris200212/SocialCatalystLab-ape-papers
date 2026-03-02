# Conditional Requirements

**Generated:** 2026-03-02T13:33:42.165555
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

---

## Idea 1: The Decade of Decline: How the Austerity Pay Squeeze on Teachers Shaped Student Achievement in England

**Rank:** #1 | **Recommendation:** PURSUE (2/3 models)

### Condition 1: abandoning DR-AIPW in favor of a panel fixed-effects or shift-share design

**Status:** [x] RESOLVED

**Response:**

We will use **Doubly Robust Difference-in-Differences (DRDID)** from Sant'Anna & Zhao (2020), implemented via the `DRDID` R package. This estimator:
- Uses panel structure (LA fixed effects absorb time-invariant unobservables)
- Is doubly robust (consistent if either the propensity score or outcome model is correct)
- Handles the binary treatment case (high vs. low competitiveness shock LAs)
- Provides event-study/dynamic treatment effects via Callaway & Sant'Anna (2021)

Additionally, as robustness:
- Two-way fixed effects (LA + year FE) with cluster-robust SEs
- Bartik/shift-share IV: predicted local wage growth from baseline (2005) industry employment shares × national industry-level wage growth
- The pure DR-AIPW cross-sectional estimate as a sensitivity check

**Evidence:** `DRDID` package on CRAN; Sant'Anna & Zhao (2020, Journal of Econometrics). The panel runs LA × year, 2005-2023, with pre-austerity period (2005-2010) providing parallel trend validation.

---

### Condition 2: proving parallel pre-trends in the 2000s

**Status:** [x] RESOLVED

**Response:**

NOMIS ASHE data goes back to 1997. DfE KS4 data goes back to 2009/10 (with earlier data available from historical performance tables). We will:
1. Construct the competitiveness ratio (teacher-to-private-wage) for all LAs from 2005-2023
2. Split LAs into treated (top quartile competitiveness decline 2010-2019) and control
3. Show parallel trends in GCSE outcomes during 2005-2010 (5 pre-treatment periods)
4. Formal pre-trend tests using event-study coefficients from CS-DiD
5. HonestDiD/Rambachan-Roth bounds for robustness to pre-trend violations

**Evidence:** NOMIS ASHE confirmed accessible from 1997-2025. DfE data available from 2009/10 at LA level with pupil characteristics. Pre-period is 2009/10-2010/11 (before austerity bite manifests in competitiveness divergence).

---

### Condition 3: adding school-level falsification tests

**Status:** [x] RESOLVED

**Response:**

Planned falsification/placebo tests:
1. **Private school placebo:** Private school outcomes should not be affected by state teacher pay competitiveness (private schools set own pay). If we find effects on private school outcomes, this indicates confounding from local economic conditions rather than the teacher pay channel.
2. **Subject-level heterogeneity:** STEM subjects (where private-sector alternatives are strongest) should show larger effects than humanities (weaker outside options). This is a mechanism-specific placebo.
3. **Retired/senior teacher placebo:** Experienced teachers are less mobile; effects should be concentrated among early-career teachers (most responsive to outside options).
4. **Leave-one-out sensitivity:** Drop each region and show results are not driven by London or any single region.

**Evidence:** DfE publishes school-level data including establishment type (allows state/private separation). Subject-level GCSE data available.

---

### Condition 4: Rosenbaum sensitivity expanded to quantify bias bounds

**Status:** [x] RESOLVED

**Response:**

Will implement:
1. **Rosenbaum Γ bounds** via `rbounds` R package — report the critical Γ at which the treatment effect becomes insignificant (sensitivity to hidden bias)
2. **Oster (2019) δ** — coefficient stability test; report δ needed to explain away the result via selection on unobservables, using R² movement as benchmark
3. **HonestDiD** bounds (Rambachan & Roth 2023) for robustness to non-parallel trends
4. **E-value** for unmeasured confounding sensitivity

**Evidence:** `rbounds`, `HonestDiD`, and `sensemakr` (for Oster δ and E-values) all available on CRAN.

---

## Teach First Meets Doubly Robust (Idea 4)

**Status:** [x] NOT APPLICABLE — Idea 4 is not being pursued.

---

## Teaching the STEM Gap (Idea 2)

**Status:** [x] NOT APPLICABLE — Idea 2 is not being pursued.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
