# Internal Review — Round 1

**Paper:** Cash Scarcity and Food Markets: Evidence from Nigeria's 2023 Currency Redesign
**Reviewer:** Claude Code (Reviewer 2 + Editor)
**Date:** 2026-02-26

## Verdict: MINOR REVISION

The paper is well-written and methodologically honest. The null result is presented transparently, with appropriate caveats. The fuel price finding is genuinely interesting. Several issues should be addressed before external review.

## Major Issues

1. **Wild cluster bootstrap CI is suspicious.** Table 4 reports WCB CI as [-0.570, -0.110] — a confidence interval that does NOT contain zero, despite a p-value of 0.523. This is internally contradictory. Either the CI or the p-value is wrong. This must be fixed before external review.

2. **CONTRIBUTOR_GITHUB placeholders.** The author block has `@CONTRIBUTOR_GITHUB` and `FIRST_CONTRIBUTOR_GITHUB` — these need to be replaced with actual values from the environment.

3. **Acknowledgements section formatting.** The "Project Repository" and "Contributors" lines use `\noindent` after section breaks, which is fine, but the `FIRST_CONTRIBUTOR_GITHUB` line appears to be a template artifact.

## Minor Issues

4. **Abstract word count.** The abstract appears to be ~140 words — within the 150-word limit, but verify.

5. **Page 1 check.** Need to verify that the front matter (title, authors, abstract, JEL, keywords) all fit on page 1.

6. **Placebo test discussion could be stronger.** The paper acknowledges placebo failures honestly, but could briefly discuss whether a de-trended specification or state-specific linear trends might help.

7. **Missing formal power calculation in main text.** The power analysis is in the appendix (B.1), but the main text (Section 5.3) only mentions "limited power" without specifics. Consider adding the MDE number (0.336 log points) to the main text.

8. **Dose-response p-values.** Section 6.4 reports dose-response quintile coefficients with p-values but doesn't mention which quintile is the reference category until the figure note. Clarify in text.

## Strengths

- Honest null result with transparent discussion of limitations
- Fuel price finding adds real value
- Multiple inference procedures (cluster-robust, WCB, RI)
- Well-structured placebo tests that honestly reveal parallel trends violations
- Strong conceptual framework with clear predictions
- Comparison with Chodorow-Reich et al. (2020) is well-done

## Recommendation

Fix the WCB confidence interval issue (critical), replace placeholders, and address minor issues. Then proceed to external review.
