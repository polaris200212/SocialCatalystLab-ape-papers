# Internal Review — Round 1

**Paper:** Shining Light on Nothing? The Null Effect of Mandatory Energy Benchmarking on NYC Property Values
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-13

## Verdict: MINOR REVISION

## Summary

This paper uses a sharp RDD at NYC's 25,000 sq ft gross floor area threshold to estimate the effect of mandatory energy benchmarking disclosure (Local Law 84) on commercial property values. The null finding (ITT = -0.040, SE = 0.059) is credibly identified and well-executed. The paper makes a meaningful contribution to the energy disclosure literature by showing that information provision alone does not capitalize into property values.

## Strengths

1. **Clean identification.** The 25,000 sq ft threshold provides a sharp discontinuity with strong first-stage compliance (42.3pp jump). McCrary density test shows no bunching (p = 0.432).
2. **Comprehensive robustness.** Bandwidth sensitivity, polynomial order variation, donut-hole RDD, placebo cutoffs, and covariate-adjusted specifications all confirm the null.
3. **Honest interpretation.** The paper takes the null seriously, discussing power (MDE = 16%), mechanisms, and implications for disclosure policy.
4. **Well-written.** Clear motivation, good use of institutional detail, effective figures.

## Issues to Address

### Major
- **Fuzzy RDD missing.** The paper reports only the sharp (ITT) estimate. Given imperfect compliance, the fuzzy RDD (LATE/Wald) estimate should be reported as the primary causal parameter.
- **First-stage inconsistency.** The raw compliance gap (73.5pp) and local RDD estimate (42.3pp) are both reported but the distinction needs clearer framing.

### Minor
- Add 95% confidence intervals to Table 2 for reader convenience.
- Consider moving less essential figures (per-sqft RDD, McCrary density) to appendix.
- Strengthen prose in a few places (reduce passive voice, eliminate throat-clearing).
- Add references: Imbens & Kalyanaraman (2012), Cattaneo et al. (2021).

## Recommendation

Address the fuzzy RDD and framing issues, add CIs, and clean up prose. Paper is close to publication-ready.
