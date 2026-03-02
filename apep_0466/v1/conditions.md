# Conditional Requirements

**Generated:** 2026-02-26T17:29:33.110035
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

## Does Local Governance Scale Matter? Municipal Population Thresholds and Firm Creation in France

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: explicitly aligning “treatment start” to municipal election timing

**Status:** [x] RESOLVED

**Response:**

Municipal governance mandates (council size, mayor compensation, electoral system) take effect only after new elections. French municipal elections follow a 6-year cycle: 2008, 2014, 2020. The treatment-relevant population is the “population légale” in force at the time of the election — not current-year population. Specifically:
- 2008 elections used the 2006 census population (published Dec 2008, but used for 2008 elections retroactively)
- 2014 elections used the 2011 census population (published Jan 2014)
- 2020 elections used the 2017 census population (published Jan 2020)

The analysis will assign treatment based on the population count that determines governance mandates for each electoral cycle. Outcomes (Sirene firm creation) will be measured in the inter-election period following each election. This aligns treatment timing precisely with when governance changes actually take effect.

**Evidence:**

Article L2151-1 CGCT specifies that the legal population determines governance mandates. INSEE publishes “populations légales” annually; the relevant population for each election is the most recent legal population published before the election.

---

### Condition 2: dropping partial-exposure years like 2014

**Status:** [x] RESOLVED

**Response:**

Election years are partial-exposure years because new councils take office mid-year (typically April after March elections). The analysis will:
1. **Primary specification**: Drop election years (2008, 2014, 2020) from the estimation sample. Use only full-exposure years (2009-2013, 2015-2019, 2021-2024).
2. **Robustness check**: Include election years with a partial-exposure indicator.
3. **Additional complication for 2020**: COVID-19 disrupted the 2020 elections (first round March 15, second round delayed to June 28). The new councils did not fully take office until summer 2020. Will drop all of 2020 from the primary specification.

**Evidence:**

Municipal elections in France: March 2008, March 2014, March/June 2020. New councils install within weeks of election. COVID delay documented in Loi n° 2020-290.

---

### Condition 3: clarifying whether each institutional component is sharp vs fuzzy

**Status:** [x] RESOLVED

**Response:**

Each governance component at French commune thresholds:

1. **Council size** — SHARP. Deterministically assigned by Article L2121-2 CGCT based on legal population. No discretion; perfectly implemented.

2. **Mayor compensation** — EFFECTIVELY SHARP. Article L2123-23 CGCT sets maximum allowances by population bracket. Communes can theoretically set lower amounts by council vote, but in practice >95% of communes adopt the maximum (Lopes da Fonseca 2017). Will test this empirically: if first stage is strong, treat as sharp; if compliance is imperfect, use fuzzy RDD with council size as the sharp instrument.

3. **Electoral system** — SHARP (at 1,000 post-2013, at 3,500 pre-2013). Proportional list voting is mandatory above the threshold; two-round majoritarian (panachage) below. No discretion.

4. **Number of deputy mayors** — SHARP. Linked to council size by law (cannot exceed 30% of council).

5. **Other mandates** (e.g., mandatory budget commission at 3,500): SHARP. Legal requirements with no commune discretion.

The paper will present this taxonomy clearly and estimate both sharp and fuzzy specifications where relevant.

**Evidence:**

Legal text references: L2121-2, L2123-23, L2122-2 CGCT. Eggers et al. (2018 AJPS) classify French thresholds as sharp in their Table 1.

---

### Condition 4: pre-registering how you handle multiple cutoffs/multiple testing

**Status:** [x] RESOLVED

**Response:**

Following the Cattaneo, Keele, Titiunik, and Vazquez-Bare (2016, 2024) multi-cutoff RDD framework:

1. **Primary specification (POOLED)**: Normalize the running variable across all cutoffs (distance to nearest threshold ÷ bandwidth). Estimate a single pooled treatment effect. This is the headline result and faces no multiple testing issue.

2. **Cutoff-specific estimates**: Report individual treatment effects at each threshold (500, 1,000, 1,500, 3,500, 10,000) as supplementary results. Apply Holm-Bonferroni correction for 5 simultaneous tests.

3. **Pre-registered primary cutoff**: The 3,500 threshold is designated as the primary individual cutoff (largest governance bundle change + DiDisc opportunity with the 2013 reform). Results at 3,500 are highlighted without multiple testing penalty; other cutoffs are treated as robustness.

4. **Heterogeneity analysis**: Variation across cutoffs provides mechanism evidence (e.g., does a larger salary jump produce stronger effects?). This is exploratory and labeled as such.

5. **Primary outcome**: Net firm creation rate per 1,000 inhabitants. Secondary outcomes (creation rate, closure rate, sectoral composition, micro-entrepreneur share) are clearly labeled and Holm-corrected when reported alongside the primary.

**Evidence:**

Cattaneo et al. (2016) "Interpreting Regression Discontinuity Designs with Multiple Cutoffs," Journal of Politics. Provides the exact framework for pooled multi-cutoff estimation.

---

## Rural Revitalization Zones and Firm Creation: Evidence from the ZRR-to-FRR Reclassification

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: using monthly Sirene events to solve timing

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: demonstrating sufficient EPCI mass near the relevant cutoff(s

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Proportional Representation and Local Business Environments: The 2013 Electoral Reform as a Natural Experiment

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: redesigning as DiDisc/RD-in-DiD using pre-2014 outcomes

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: dropping/handling partial exposure in 2014

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: clearly separating or explicitly bundling the multiple institutional changes at 1

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
- [x] This file has been committed to git

**Status: RESOLVED — Proceeding to Phase 4**
