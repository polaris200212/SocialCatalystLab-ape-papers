# Conditional Requirements

**Generated:** 2026-02-28T11:21:18.124839
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

We are pursuing **Idea 1: The Durbin Amendment** (unanimous PURSUE across all 3 models). Conditions for non-selected ideas are marked NOT APPLICABLE.

---

## Merger Waves and Teller Displacement — The Labor Market Cost of Bank Consolidation

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: making FDIC-assisted/failed-bank resolutions the primary design
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected. Pursuing Idea 1 (Durbin Amendment) instead.

### Condition 2: demonstrating clean pre-trends
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected.

### Condition 3: adding outcomes beyond headcounts—wages
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected.

### Condition 4: occupational transitions
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected.

### Condition 5: local banking access
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected.

---

## Idea 1: When Revenue Falls, Branches Follow — The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: passing strict pre-trend tests

**Status:** [x] RESOLVED

**Response:** The event-study specification uses 2006–2010 as pre-treatment years (5 pre-periods before October 2011 implementation). We will estimate year-by-year coefficients on Exposure_c × Year_t and test: (a) joint F-test of all pre-treatment coefficients = 0, (b) visual inspection of event-study plot, (c) HonestDiD sensitivity analysis allowing for non-zero pre-trends. If pre-trends emerge, we will (1) add county-specific linear trends, (2) restrict to tighter bandwidth (2009–2014), and (3) report HonestDiD robust confidence sets.

**Evidence:** Design structure guarantees testability — 5 pre-periods is well above the minimum. FDIC SOD and BLS QCEW are available for all years 2006–2018.

---

### Condition 2: demonstrating the DDD effectively absorbs local macro shocks

**Status:** [x] RESOLVED

**Response:** The DDD uses non-banking employment (e.g., NAICS sectors outside 52) as a within-county control. The identifying assumption: the Durbin Amendment affected banking employment differentially relative to other sectors in high-exposure counties. We will validate by: (a) showing non-banking employment in high-exposure counties does NOT trend differently post-2011, (b) testing placebo sectors (manufacturing, retail) as alternative "treatment" groups — they should show null effects, (c) comparing DDD estimates to simple DiD to show sign/magnitude stability.

**Evidence:** BLS QCEW provides county × industry × quarter employment for all NAICS sectors, enabling clean within-county industry comparisons.

---

### Condition 3 (from Grok panel): validating no pre-Durbin branch anticipation in event study

**Status:** [x] RESOLVED

**Response:** The Durbin Amendment was signed into law as part of Dodd-Frank in July 2010, with the final rule issued June 2011 and effective October 2011. Banks may have anticipated the regulation between July 2010 and October 2011. We address this by: (a) defining treatment onset as 2012 (first full post-implementation year), (b) treating 2010–2011 as a "phase-in" window and testing for anticipation effects explicitly in the event study, (c) if 2011 shows significant pre-implementation effects, we will report and discuss (this is actually interesting — it tells us about bank planning horizons).

**Evidence:** Legislative timeline is well-documented. Dodd-Frank signed July 21, 2010; Reg II final rule June 29, 2011; effective October 1, 2011.

---

### Condition 4 (from Grok panel): linking to consumer welfare via deposit shifts

**Status:** [x] RESOLVED

**Response:** FDIC SOD provides deposit data at the branch level. We will examine: (a) whether branch closures in high-exposure counties led to deposit outflows to smaller (exempt) banks, (b) whether consumers in high-exposure counties experienced reduced physical banking access (branches per capita), (c) a simple revealed-preference welfare argument: if consumers switch to exempt banks or go unbanked, this reveals welfare loss from branch closures.

**Evidence:** FDIC SOD deposit data available at branch level, enabling within-county deposit reallocation analysis.

---

## Idea 2: The Digital Cliff — How Mobile Banking Adoption Broke the ATM-Teller Complementarity

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: strong first-stage/terrain validation via placebo industries
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected. Pursuing Idea 1.

### Condition 2: FCC data pilot confirming tract coverage power
**Status:** [x] NOT APPLICABLE
**Response:** Idea not selected.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED** ✓
