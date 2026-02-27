# Internal Review — Round 1

**Reviewer:** Claude Code (internal)
**Date:** 2026-02-27
**Paper:** The Gig Economy That Wasn't: Universal Credit and the Composition of Employment in Britain

## Verdict: MINOR REVISION

## Summary

This paper examines whether UC's Full Service rollout shifted the composition of employment toward self-employment using staggered DiD across 378 local authorities. The finding is a well-powered null: CS ATT = −0.14 (SE = 0.35) on self-employment share.

## Strengths

1. **Clean identification**: Staggered rollout with 6+ pre-treatment years, strong parallel trends support (p = 0.99), and appropriate use of CS estimator.
2. **Comprehensive robustness**: Region×year FE, exclude London, England-only, exact-match-only, placebo, HonestDiD sensitivity all confirm the null.
3. **Honest about limitations**: Explicitly documents short identified horizon, dose dilution, and ITT nature.
4. **Well-written**: Clear narrative arc from policy question to contribution.

## Issues Found and Addressed

1. **Variable mislabeling (FIXED)**: Economic activity rate was initially labeled as unemployment rate. Corrected throughout.
2. **Cohort count inconsistencies (FIXED)**: Multiple inconsistencies between text and tables. All reconciled to first_treat values (33/137/208).
3. **SE inconsistency (FIXED)**: Bootstrap SEs varied across tables due to unseeded random number generator. Fixed with set.seed.
4. **Region FE syntax (FIXED)**: region_id[year] changed to region_id^year for proper interaction FEs.
5. **Missing 2018 cohort explanation (FIXED)**: Now explicitly documented in text and table notes.
6. **Contribution language (FIXED)**: Added explicit "This paper makes three contributions" language.
7. **Dose dilution (ADDED)**: Formal back-of-envelope calculation added to Limitations.
8. **Treatment sensitivity (ADDED)**: Exact-match-only robustness check added.

## Remaining Concerns (Minor)

- Short identified post-treatment horizon (1-2 years) is a real limitation but adequately acknowledged.
- Survey-estimated outcomes treated as exact; ideally would use microdata but access not available.
- The \floatfoot commands produce LaTeX warnings but do not affect the compiled PDF.

## Recommendation

Paper is ready for external review and publication. The null result is well-powered and credibly identified for the short-to-medium run at the LA level.
