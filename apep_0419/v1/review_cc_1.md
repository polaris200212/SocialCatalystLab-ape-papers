# Internal Review - Round 1

**Reviewer:** Claude Code (internal)
**Paper:** No Snow Day Left Behind
**Date:** 2026-02-19

## PART 1: CRITICAL REVIEW

### Major Issues

1. **Outcome proxy construction (Section 4.6):** The weather-absence proxy multiplies national BLS rates by state-level storm z-scores. This introduces state variation only through weather, not through actual state-level absence measurement. The paper acknowledges this limitation but should emphasize more strongly that the proxy is a noisy measure that biases toward zero.

2. **Treatment timing correction:** The original coding assigned treatment when `winter_season >= adopt_year`, which meant Nov-Dec of the year before adoption were counted as treated. This was corrected to `winter_season > adopt_year` and `first_treat = adopt_year + 1`, shifting all CS-DiD cohorts forward by one year.

3. **Storm interaction marginal significance (p=0.063):** The preferred specification's interaction is only marginally significant. Columns 2-4 interactions are all insignificant. The paper should be more explicit that this is suggestive evidence, not a definitive finding.

4. **Pre-COVID subsample (N=504):** With only 8 treated clusters, inference is limited. The wild bootstrap (p=0.52) and RI (p=0.57) both confirm the null.

### Minor Issues

5. Summer placebo is marginally significant (p<0.05), which weakens the falsification argument. The paper addresses this but should note it more prominently.

6. Regional estimates have very wide SEs; no region produces a significant estimate.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. CPS microdata with state identifiers would provide direct state-level absence measurement.
2. District-level implementation data would enable treatment-on-the-treated estimates.
3. Heterogeneity by child age and single-parent status would strengthen the mechanism.
4. A formal power analysis should be front-and-center given the null results.

## DECISION

DECISION: MINOR REVISION
