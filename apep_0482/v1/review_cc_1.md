# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-03-02

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- Multi-cutoff RDD design at 5,000 and 3,000 thresholds is well-motivated by institutional features
- Density tests pass at both cutoffs
- Covariate balance tests are appropriate
- Placebo cutoffs at 4,000 and 6,000 provide useful validation

**Concerns:**
- The running variable (average population) includes post-treatment years, though the paper now addresses this explicitly with persistence statistics (within-municipality SD ~150, <3% cross threshold). This is adequate but not ideal.
- The weak first stage limits interpretability of reduced-form estimates as effects of female representation. The paper correctly frames as ITT effects of the threshold.
- The 3,000 threshold pre-treatment placebo shows marginal significance for secondary education (p=0.06), warranting the noted caution.

### 2. Inference and Statistical Validity

- Standard errors, p-values, bandwidths, and effective N are consistently reported across all tables
- MSE-optimal bandwidth selection via rdrobust is standard and appropriate
- The footnote explaining why sub-period N can exceed full-period N (different optimal bandwidths) is helpful
- Polynomial sensitivity (p=1,2,3) shows stability

### 3. Robustness

- Donut RDD (100, 200), bandwidth sensitivity (0.5x-2x), polynomial order, and placebo cutoffs provide thorough robustness
- Pre-LRSAL/post-LRSAL temporal heterogeneity is the paper's key contribution
- Pre-LRSAL result (primary school facilities, p=0.032) is a single test — could benefit from multiple testing adjustment discussion

### 4. Contribution and Literature

- Literature positioning is strong: Bagues & Campa (2021), Ferreira & Gyourko (2014), Chattopadhyay & Duflo (2004), Gagliarducci & Paserman (2013)
- Clear differentiation: within-education composition vs. aggregate education spending
- The institutional constraints story adds theoretical value

### 5. Results Interpretation

- Null results are honestly presented and well-calibrated
- Pre-LRSAL finding is presented with appropriate caveats about sample size and single test
- Policy implications are proportional to evidence

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Multiple testing:** With 8 education subcategories tested, the pre-LRSAL finding (p=0.032 for primary school facilities) would not survive Bonferroni correction. Consider discussing this and noting whether Benjamini-Hochberg or Romano-Wolf would preserve significance.

2. **Effect heterogeneity by party:** If data permit, examining whether the compositional effect varies by governing party (PSOE vs PP) would add value to the mechanism story.

3. **Election-specific RDD as robustness:** Even if the main analysis uses averaged running variable, estimating the RDD separately for the 2007 and 2011 elections (when the first stage was strongest) would directly address the temporal attenuation story and strengthen the pre-LRSAL finding.

---

## 7. OVERALL ASSESSMENT

**Key strengths:**
- Novel question: within-education composition as outcome
- Rigorous multi-cutoff RDD with comprehensive robustness
- Pre-LRSAL/post-LRSAL temporal heterogeneity tells a compelling institutional story
- Honest engagement with null results and weak first stage
- Well-written prose

**Critical weaknesses:**
- Pre-LRSAL finding based on a single significant result among many tests
- Weak first stage limits causal interpretation

**Publishability:** Strong candidate for AEJ: Economic Policy after minor revision. The institutional constraints story is the key contribution and is well-supported by the data.

DECISION: MINOR REVISION
