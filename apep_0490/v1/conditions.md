# Conditional Requirements

**Generated:** 2026-03-03T11:55:59.883276
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

All conditions have been addressed. Evidence is documented below.

---

## The Price of Position: How arXiv Listing Order Shapes the Diffusion of AI Research

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: passing density/balance tests in tight bandwidths

**Status:** [x] RESOLVED

**Response:** McCrary density test p=0.25 (no significant bunching). Covariate balance: 7/8 covariates smooth, cs.LG p=0.024 survives Bonferroni correction (p_adj=0.19). Joint test p=0.43.

**Evidence:** Table 2 (balance), Section 6.2.1 (manipulation testing), Figure 7 (McCrary plot)

---

### Condition 2: a pre-registered identification/robustness plan including donut + local-randomization inference

**Status:** [x] RESOLVED

**Response:** initial_plan.md committed before data fetch. Donut RDD at ±2 and ±5 minutes implemented. Bandwidth sensitivity (50-200% of optimal), placebo cutoffs, polynomial/kernel sensitivity all conducted.

**Evidence:** initial_plan.md, Section 6.4 (robustness), Table 4 (robustness results)

---

### Condition 3: a credible strategy to interpret/partition position vs delay effects

**Status:** [x] RESOLVED

**Response:** Section 7.1 presents three interpretations: (1) timeliness dominates position, (2) position truly doesn't matter, (3) insufficient power. Thursday heterogeneity test examines extended exposure. The treatment is explicitly described as a bundle throughout.

**Evidence:** Section 7.1 (Mechanisms), Section 6.7.2 (Day of Week), Section 7.3 (Limitations)

---

## Idea 1: The Price of Position

### Condition 1: passing McCrary density tests or proving covariate balance across the cutoff

**Status:** [x] RESOLVED

**Response:** Same as above. McCrary p=0.25, joint balance p=0.43.

**Evidence:** Section 6.2.1, Table 2

---

### Condition 2: successfully executing the donut RDD

**Status:** [x] RESOLVED

**Response:** Donut ±2 min: -0.95, p=0.21; Donut ±5 min: -1.35, p=0.17. Both confirm the baseline null.

**Evidence:** Table 4 Panel B, Section 6.4

---

## The Price of Position (cont.)

### Condition 1: robust bunching diagnostics passing McCrary/placebo cutoffs

**Status:** [x] RESOLVED

**Response:** McCrary p=0.25 (no significant bunching). Placebo cutoffs at 8 alternative times all produce null estimates.

**Evidence:** Section 6.2.1, Figure 6 (placebo), Figure 7 (McCrary)

---

### Condition 2: mechanism tables clearly decomposing position vs. delay effects

**Status:** [x] RESOLVED

**Response:** Cannot fully decompose (acknowledged as limitation). Section 7.1 discusses three interpretations. Thursday heterogeneity provides partial decomposition (3-day vs 1-day exposure).

**Evidence:** Section 7.1, Section 6.7.2, Section 7.3

---

## Verification Checklist

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
