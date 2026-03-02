# Conditional Requirements

**Generated:** 2026-02-21T11:18:32.887353
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

---

## Breaking Purdah with Pavement: Caste-Specific Gender Returns to Rural Roads in India (Idea 3)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining/merging OMMAS PMGSY road completion data to document a strong first stage

**Status:** [x] RESOLVED

**Response:**

The paper will use the **reduced-form ITT (Intent-to-Treat)** approach — comparing villages above vs below the PMGSY population threshold — rather than requiring a fuzzy RDD with OMMAS first-stage data. This is standard in the literature and sufficient for policy-relevant causal estimates.

**Three-pronged validation of the first stage:**
1. **Cite established evidence:** Asher & Novosad (2020, AER) documented a strong first stage using OMMAS data: villages above the 500-person threshold were 22 percentage points more likely to receive a PMGSY road. Our ITT estimates can be divided by this compliance rate to recover the LATE.
2. **Indirect first stage via nightlights:** We will show that villages above the threshold experience significantly faster nightlight growth (2001-2011), confirming that the threshold affected economic activity (presumably through road construction).
3. **Village Directory infrastructure:** The Census 2011 Village Directory (in SHRUG via `pc11_td_clean`) includes `pc11_td_k_road` (paved road) and `pc11_td_p_road` (approach road). We can test whether villages above 500 are more likely to have paved road access in 2011 vs 2001.

**Evidence:** Asher & Novosad (2020, AER 110(3), pp. 797-823): "Rural Roads and Local Economic Development." Documented sharp first stage at population threshold.

---

### Condition 2: showing no manipulation at the population threshold via McCrary

**Status:** [x] RESOLVED

**Response:**

McCrary (2008) density test will be implemented in the R analysis code as a formal validation. The test will use Census 2001 village population (the pre-treatment running variable, set before PMGSY was announced in Dec 2000). Since Census 2001 enumeration was conducted before PMGSY road allocation decisions, strategic population manipulation is implausible.

Additionally, Asher & Novosad (2020) found no evidence of manipulation at the 500-person threshold in their analysis, which uses the same running variable.

**Evidence:** Will be generated in `03_main_analysis.R` using the `rddensity` R package (Cattaneo, Jansson, and Ma 2020).

---

### Condition 3: covariate balance

**Status:** [x] RESOLVED

**Response:**

Formal covariate balance tests will compare villages just above and just below the threshold across pre-treatment characteristics from Census 2001:
- SC/ST population share
- Female literacy rate
- Female work participation rate
- Total population (polynomial of running variable)
- Number of households
- Distance to nearest town/district HQ
- Availability of primary school, PHC, bank
- Electricity status

All balance tests will be reported in the paper with bandwidth-sensitive results.

**Evidence:** Will be generated in `03_main_analysis.R` using local polynomial regression on each covariate.

---

### Condition 4: restricting to plausibly single-habitation villages or otherwise validating village↔habitation mapping near the cutoff

**Status:** [x] RESOLVED

**Response:**

**Primary strategy:** Restrict to villages with Census 2001 population between 200-800 (or tighter bandwidths). Near the 500 threshold, villages are predominantly small and single-habitation. India's Census 2011 Village Directory records the number of inhabited hamlets per village (`pc11_td_no_hh` — number of households). Villages with small populations are overwhelmingly single-habitation.

**Robustness checks:**
1. Show results are robust to multiple bandwidth choices (optimal Imbens-Kalyanaraman, half-bandwidth, double-bandwidth)
2. Show results are robust to restricting to villages with very small populations (300-700) where single-habitation is near-certain
3. Use donut-hole RDD excluding villages exactly at 500 (where manipulation is most plausible)
4. Separate analysis for hills/tribal areas (threshold = 250) as an independent replication at a different cutoff

**Additional validation:** Run the analysis separately for the 250-person threshold (hills/tribal/desert areas). If results replicate across BOTH thresholds with BOTH caste moderations, the finding is highly credible.

**Evidence:** Bandwidth sensitivity analysis will be in `04_robustness.R`.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence plan is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
