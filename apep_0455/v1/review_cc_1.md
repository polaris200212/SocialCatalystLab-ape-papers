# Internal Review — Round 1

**Paper:** Vacancy Taxes and Housing Markets: Evidence from France's 2023 TLV Expansion
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-25

## Verdict: MINOR REVISION

## Summary

This paper exploits France's 2023 expansion of the Taxe sur les Logements Vacants to 2,590 communes to estimate causal effects on housing prices and transaction volumes. The design is credible (large single-cohort DiD with 2,590 treated and 29,447 control communes), the data are excellent (universe of French property transactions), and the paper honestly engages with mixed results. The main finding — volume declines significantly while commune-level prices show null effects — is nuanced and policy-relevant.

## Strengths

1. **Honest reporting of mixed results.** The paper does not cherry-pick the significant transaction-level estimate but instead frames the null commune-level estimate as the primary finding. The composition/selection interpretation is carefully developed.

2. **Strong institutional knowledge.** The description of the TLV regime, its evolution, and the 2023 expansion is detailed and accurate. The distinction between tourism and non-tourism zones is well-motivated.

3. **Comprehensive robustness.** Placebo tests, dept×year FE, donut specification, matching, randomization inference, and property-type heterogeneity provide a thorough picture.

4. **Volume result is compelling.** The -6.0% volume decline (p<0.001) is the most robust finding and provides clean evidence of market response.

## Concerns

### Major

1. **Placebo test failure.** The fake-2022 placebo yields a 2.4%*** coefficient. The paper attributes this to COVID mean-reversion, which is plausible but not fully convincing. The event study showing a negative 2020 coefficient and near-zero 2021 coefficient is more reassuring, but the binary placebo failure is a red flag that needs stronger discussion.

2. **Pre-trend in 2023.** The 2023 event-study coefficient (2.9%***) precedes the policy's effective date. While framed as an "announcement effect," this could also indicate that treated communes were already diverging from controls for reasons unrelated to TLV. The paper should more explicitly address why a causal interpretation of the 2024-2025 coefficients remains valid.

### Minor

3. **Matched sample estimate.** The 8.4%*** matched estimate is 7x the baseline — this needs more discussion of what went wrong with matching, not just a brief caution.

4. **Missing RI figure.** Figure 4 (randomization inference distribution) appears in the code but was not generated (likely because the ri_results loading failed in 05_figures.R). Should be included.

5. **References.** Some bib entries have inconsistent formatting. The Kopczuk & Munroe entry title doesn't match the actual paper title.

## Recommendation

Address the pre-trend and placebo concerns with clearer discussion. Add the RI figure. The paper is close to ready for external review.
