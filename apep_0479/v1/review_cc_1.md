# Internal Review - Round 1

**Reviewer:** Claude Code (internal)
**Date:** 2026-02-28
**Paper:** When Revenue Falls, Branches Follow: The Durbin Amendment, Bank Restructuring, and the Decline of the Bank Teller

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The Bartik/shift-share design exploiting pre-determined (2010) deposit shares in Durbin-affected banks is well-motivated and standard in the literature.
- The triple-difference (DDD) comparing banking vs. non-banking sectors within counties is a strong addition that absorbs county-specific macro shocks.
- The paper correctly uses 2010 classification to avoid endogenous threshold manipulation.

**Concerns:**
- The pre-treatment coefficients for branches in 2005-2006 are statistically significant, and the joint F-test rejects parallel trends (F=5.85, p<0.001). While the paper acknowledges this and argues the employment null is unaffected, this substantially weakens the branch "first stage" evidence.
- The positive placebo effects for retail (0.049, p=0.001) and healthcare (0.161, p<0.001) are concerning. If Durbin exposure correlates with county-level economic dynamism, the employment null could mask a small negative true effect.
- The Bartik share exogeneity discussion cites Goldsmith-Pinkham et al. (2020) but does not implement any of their recommended diagnostics (Rotemberg weights, overidentification tests).

### 2. Inference and Statistical Validity

- Standard errors clustered at the state level are appropriate for state-level policy correlation.
- Clustering sensitivity (county, state, state×year) is demonstrated and results are robust.
- The continuous treatment variable (Durbin exposure) is appropriate for the Bartik design.
- Power analysis in text is informal but adequate — can rule out effects >5%.

### 3. Robustness

- Bandwidth sensitivity, leave-one-state-out, clustering sensitivity, and crisis-county exclusion all appropriately tested.
- All robustness checks confirm the null employment result.
- The HonestDiD reference has been properly removed (it was not implemented).

### 4. Contribution and Literature

- The paper fills a genuine gap: no prior work examines Durbin Amendment effects on banking employment.
- The null result is itself a contribution — documenting the branch-employment decoupling.
- The Related Literature section is thorough and well-positioned.
- Missing: Nguyen (2019, AEJ:Applied) on bank branch closings should be discussed more prominently.

### 5. Results Interpretation

- The null is honestly reported and not oversold. The paper appropriately frames the divergence between branches and employment as the central finding.
- The deposit reallocation results (opposite to prediction) are transparently reported.
- The 2016 data gap is appropriately documented.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### High-Value Improvements
1. Implement Goldsmith-Pinkham et al. (2020) Rotemberg weight decomposition to validate the Bartik design more formally.
2. Address the branch pre-trends more directly — consider restricting the branch analysis to 2007+ where pre-trends are near zero.
3. The positive placebo coefficients deserve more discussion of what they imply for the identifying assumption.

### Optional Polish
1. Consider a back-of-envelope power calculation for the minimum detectable effect (MDE).
2. The conceptual framework (Section 3) predicts employment declines but the results show a null — discuss which model assumption breaks.

---

## OVERALL ASSESSMENT

**Key Strengths:**
- Novel question with clear policy relevance
- Honest reporting of a null result with appropriate interpretation
- Multiple robustness checks consistently support the null
- Strong DDD design that absorbs county-specific confounders

**Critical Weaknesses:**
- Branch pre-trends undermine the first-stage interpretation
- Positive placebo effects suggest potential bias in the employment estimates
- Bartik design diagnostics (Rotemberg weights) not implemented

**Publishability:** The paper is publishable after addressing the pre-trend concerns more carefully and being more explicit about the placebo bias direction. The null result is genuine and contributes to the literature.

DECISION: MINOR REVISION
