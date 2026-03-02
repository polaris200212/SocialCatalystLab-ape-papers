# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (skeptical) + Editor (constructive)
**Model:** claude-opus-4-6 (self-review)
**Paper:** paper.pdf
**Timestamp:** 2026-03-02T10:15:00

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The DDD design (Female × District × Party-Period FE) is clearly specified and appropriate. The key identifying assumption — that within a party-period cell, gender is quasi-random conditional on mandate type — is reasonable given that party nomination processes don't sort women into district/list seats based on unobservable rebellion propensity.

**Strengths:**
- The dual-candidate RDD is a genuine methodological contribution, exploiting a clean institutional feature (close district races among candidates who appear on both list and district)
- The nonparametric rdrobust estimate with data-driven bandwidth selection adds credibility
- The first stage is strong (coefficient -0.56, p<0.001)

**Concerns:**
- The RDD running variable (signed vote margin) has mass points, as rdrobust warned. This is common in vote share data but worth acknowledging more explicitly
- The RDD sample (dual candidates in close races) is a specific subpopulation. External validity to non-dual candidates is limited

### 2. Inference and Statistical Validity

- Standard errors appropriately clustered at legislator level throughout
- Alternative clustering (party-period, two-way) reported as robustness
- MDE analysis shows 36% of baseline — adequate power for detecting meaningful effects
- The RI p-value discrepancy (0.014 without electoral safety vs 0.50 with) is well-explained as specification sensitivity, not a contradiction

**One concern:** The RI is run on a different specification than the preferred model. Ideally, RI should be run on the preferred specification (Column 4), even if computationally more expensive.

### 3. Robustness and Alternative Explanations

Comprehensive battery of checks:
- Alternative party-line definitions (90% cohesion, final passage only)
- RCV selection bias (excluding opposition-initiated)
- Placebo outcome (absenteeism)
- Free votes analysis
- Multiple testing correction (Holm method)
- Bandwidth sensitivity for RDD

**Missing:** No pre-trends analysis. While this is technically a cross-sectional comparison (not event-study DiD), showing that the gender gap didn't change discontinuously at any point would strengthen the "institutional constraint" interpretation.

### 4. Contribution and Literature Positioning

Strong positioning relative to:
- U.S. gender-politics literature (Swers, Anzia, Volden)
- German MMP literature (Stratmann, Sieberer, Ohmura)
- Developing-country quota literature (Clayton, Besley)

The contribution is clear: first paper to examine gender × mandate type interaction in party discipline, using the German MMP system's natural variation.

### 5. Results Interpretation and Claim Calibration

The paper appropriately frames the null as a finding, not a non-result. The Green Party exception is handled well — it's presented as suggestive evidence for the mechanism (gender parity → institutional independence → revealed preferences), not as the main result.

The temporal convergence finding adds depth without overstepping.

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Actionable Revision Requests

**Must-fix:**
1. Run RI on the preferred specification (Column 4 with electoral safety) to avoid the awkward specification mismatch explanation
2. Acknowledge mass-point warning from rdrobust more explicitly in text

**High-value improvements:**
3. Add a brief discussion of whether the null extends to other legislative activities (committee assignments, speeches, bill sponsorship) — the paper currently restricts claims to floor votes, which is correct, but a paragraph on what we can and cannot generalize to would strengthen the discussion
4. The Green Party result deserves more scrutiny — is it driven by a few specific votes? A brief robustness check (dropping Green Party's most controversial votes) would help

**Optional polish:**
5. Consider adding a McCrary density test for the RDD, even if informal
6. The time evolution results could note the specific quota adoption dates more prominently

## OVERALL ASSESSMENT

**Key strengths:** Large N, clean institutional variation, well-powered null result, comprehensive robustness, strong RDD complement

**Critical weaknesses:** RI specification mismatch is minor but avoidable; RDD mass points warrant acknowledgment

**Publishability:** This is a well-executed paper with a clear contribution. The null result is precisely estimated and carefully interpreted. Minor revision.

DECISION: MINOR REVISION
