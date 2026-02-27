# Conditional Requirements

**Generated:** 2026-02-27T02:34:52.727201
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

## Idea 1: The Unequal Legacies of the Tennessee Valley Authority — Individual-Level Evidence

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: rigorous bounding of linking-attrition bias

**Status:** [x] RESOLVED

**Response:**

Census linking produces a non-random sample: literate, native-born, male individuals with common names are more likely to link across censuses. This is a well-known issue in the historical census linking literature (Bailey et al. 2020, "How Well Do Automated Linking Methods Perform?"). We address this through a four-pronged strategy:

1. **Inverse probability weighting (IPW):** Estimate the probability of successful linkage as a function of observable characteristics (age, race, sex, literacy, nativity, name frequency) using logistic regression. Weight all regressions by inverse link probability to reweight the linked sample back to the full population.

2. **Lee (2009) bounding:** Compute worst-case bounds on treatment effects by assuming extreme selection into linking. The Lee bounds tighten when link rates are similar across treatment and control groups (which we verify).

3. **Linked vs. unlinked comparison:** Report summary statistics for linked and unlinked individuals separately. Test whether TVA/non-TVA differential in link rates is substantively meaningful. If link rates differ by <5pp across treatment groups, attrition bias is unlikely to drive results.

4. **ABE-conservative vs. ABE-standard robustness:** Run all analyses on both the conservative linkage (requiring exact match on first name, last name, birthplace, and birth year ±2) and the standard linkage (allowing Jaro-Winkler fuzzy matching). Stability across linkage definitions provides evidence against linking-driven artifacts.

**Evidence:**

The IPUMS MLP documentation (ipums.org/projects/ipums-usa/d010.v4.0) confirms HISTID availability across 1920-1940 censuses. Bailey et al. (2020, Journal of Economic Literature) provide the standard framework for evaluating link quality and bounding. Abramitzky et al. (2021, AER) demonstrate that IPW-corrected estimates are robust to alternative linking methods in similar historical settings.

---

### Condition 2: controlling for county-level exposure to other New Deal spending

**Status:** [x] RESOLVED

**Response:**

The TVA region received other New Deal programs simultaneously (CCC, WPA, FERA, AAA). If these correlated spatially with TVA exposure, our distance gradient could capture non-TVA New Deal effects. We address this through:

1. **Direct controls:** Fishback, Kantor, and Wallis (2003, JEH; 2006, "New Deal" book) compiled county-level New Deal spending data for all major programs (WPA, CCC, FERA, AAA, RFC). We include per-capita New Deal spending (excluding TVA) as a control in all specifications.

2. **TVA-specific distance gradient:** Our running variable is distance to the nearest TVA dam/facility, not distance to the TVA boundary. Other New Deal programs were not spatially organized around TVA dams. The dam-specific gradient isolates TVA infrastructure effects from generic New Deal spending.

3. **Placebo programs:** Test whether distance to the nearest CCC camp or WPA project site produces similar gradient effects. If the gradient is TVA-specific (not general New Deal), placebo gradients should be flat.

4. **Triple difference:** TVA × Post × (Occupation type). If TVA works through electrification and manufacturing, effects should concentrate in industrial/manufacturing workers, not agricultural workers receiving AAA payments. This within-county variation is orthogonal to other New Deal programs.

**Evidence:**

Fishback et al. (2003) county-level New Deal spending data is publicly available. Kline and Moretti (2014) controlled for other New Deal programs in their aggregate analysis and found TVA effects robust. Our individual-level design improves on this by exploiting within-county demographic variation.

---

## The Unequal Legacies of the Tennessee Valley Authority — Individual-Level Evidence from Linked Census Microdata, 1920–1940

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: robust link-quality sensitivity analyses

**Status:** [x] RESOLVED

**Response:**

Addressed under Condition 1 above (same idea, duplicate from different model). The four-pronged linking strategy (IPW, Lee bounds, linked vs. unlinked comparison, conservative vs. standard linkage) directly satisfies this requirement.

---

### Condition 2: pre-register outcome hierarchy for multiple testing

**Status:** [x] RESOLVED

**Response:**

We pre-register a three-tier outcome hierarchy with Holm-Bonferroni correction within each family:

**Primary outcomes (Family 1 — 3 outcomes):**
1. Occupational score (OCC1950-based socioeconomic index)
2. Manufacturing employment indicator
3. Wage income (1940, log)

**Secondary outcomes (Family 2 — 3 outcomes):**
1. Labor force participation
2. Home ownership
3. Farm employment indicator

**Exploratory outcomes (Family 3 — unbounded):**
- Literacy, weeks worked, migration indicator, education (children only)

All heterogeneity analyses (race × gender × age) are pre-specified as interactions, not as post-hoc subgroup fishing. We report unadjusted p-values alongside Holm-corrected p-values for each family.

**Evidence:**

This hierarchy follows the pre-specification standards recommended by Anderson (2008, JASA) and Westfall and Young (1993). The outcome families align with economic theory: primary outcomes directly measure the occupational upgrading channel; secondary outcomes capture broader welfare effects; exploratory outcomes are acknowledged as such.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
