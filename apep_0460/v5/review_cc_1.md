# Internal Review — Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** "Cosmopolitan Confounding: Diagnosing Social Network Identification in Cross-Border Housing Markets"
**Date:** 2026-02-27

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The triple-difference design (houses vs apartments × exposure × post) is well-motivated by the empirical regularity that British buyers in France purchase rural houses.
- The dept×quarter FE absorb all time-varying département shocks — a demanding specification that eliminates the cosmopolitan confounding documented in the baseline DiD.
- The German placebo as a diagnostic (rather than just a robustness check) is a genuine methodological contribution.
- The GADM1 harmonization resolves the measurement asymmetry problem cleanly.

**Concerns:**
- The triple-difference signal concentrates entirely post-2020, not post-2016. The paper acknowledges this honestly, but it substantially weakens the Brexit causal claim. The "three candidate mechanisms" (Section 6.2) are speculative.
- The GADM1 triple-difference placebos for Belgium, Italy, and Spain are significant, which undermines the claim that the toolkit "resolves" cosmopolitan confounding. The paper now acknowledges this as a limitation, but it remains concerning.
- Pre-trend F-tests for the baseline DiD are borderline significant (p = 0.038, 0.048), suggesting the parallel trends assumption may be violated.

### 2. Inference and Statistical Validity

- Standard errors clustered at the département level (96 clusters) — adequate.
- Bootstrap inference reported; bootstrap p-values generally confirm asymptotic results.
- Sample sizes are now clearly documented with singleton removal notes.
- HonestDiD sensitivity analysis is a strong addition.

### 3. Robustness

- Leave-one-out, randomization inference, geographic restrictions, short window — comprehensive.
- The census stock result (p = 0.001) is highly robust and is the paper's strongest empirical finding.
- The triple-difference is imprecisely estimated (p ≈ 0.10–0.18), which is appropriate given the demanding specification.

### 4. Contribution and Literature

- Well-positioned relative to Bailey et al. (2018, 2021), Badarinza & Ramadorai (2019), and the Brexit literature.
- The methodological contribution (cosmopolitan confounding diagnosis) is genuine and replicable.

### 5. Results Interpretation

- Claims are well-calibrated. The paper does not overclaim the Brexit effect.
- The honest treatment of the timing puzzle (Section 6) is a strength.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. The paper could strengthen the timing argument by testing whether the post-2020 effect correlates with actual migration flows (ONS emigration data to France, if available).
2. Consider testing an IV approach using census stock as an instrument for SCI to address the endogeneity of the 2021-measured SCI.
3. The commune-level triple-difference could be the headline specification rather than the département-level, given the much larger sample.

---

## OVERALL ASSESSMENT

**Key strengths:** Novel methodological contribution (cosmopolitan confounding), honest treatment of null and ambiguous results, comprehensive robustness battery, clean GADM1 harmonization result.

**Critical weaknesses:** Post-2020 timing concentration complicates causal interpretation; GADM1 triple-diff placebos partially significant.

**Publishability:** The paper's primary contribution is methodological — the diagnosis and toolkit — not the Brexit causal estimate per se. On those terms, it is publishable.

DECISION: MINOR REVISION
