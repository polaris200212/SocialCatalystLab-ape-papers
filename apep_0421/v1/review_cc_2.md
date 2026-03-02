# Internal Review — Round 2

**Reviewer:** Claude Code (self-review)
**Date:** 2026-02-20
**Mode:** Editor (constructive)

---

## Format and Presentation

The paper is well-formatted at 42 pages total (~32 pages main text). Tables and figures are professional and AER-ready. The title change from "Piped Water" to "Water Access" correctly reflects the empirical measure. Figure-caption alignment has been corrected.

## Methodology Assessment

The Bartik exposure design is appropriate given data constraints. The paper acknowledges this is a cross-sectional first-difference design, not a panel DiD. The first-stage F-statistic exceeds 1,000, eliminating weak instrument concerns.

Key methodological strengths:
- Seven distinct robustness checks (LOSO, RI, WCB, alternative treatments, pre-trend controls, Oster bounds, Conley bounds)
- Multiple hypothesis testing correction via Anderson (2008) q-values
- Health mechanism channel tested with five outcomes
- Nightlights placebo provides clean test of exclusion restriction

## Remaining Issues from Round 1

1. The paper now correctly distinguishes "improved drinking water access" from "piped water" throughout. The alternative treatment definition section (Section 7.4) uses piped-water-specific deficit as a robustness check — this is well-framed.

2. Figure alignment is now correct: first stage binscatter in Figure 2, reduced form in Figure 3, RI distribution in Figure 5, LOSO in Figure 6, placebos in Figure 7.

3. The hardcoded path issues in 00_data_access_test.R have been resolved.

## Suggestions for Final Polish

1. Consider adding the word count of the abstract to ensure it stays under 150 words.
2. The Conley bounds section references a figure that no longer exists (the figure was moved to the nightlights section). Verify no dangling \Cref references remain.
3. Minor: the heterogeneity section previously had a figure reference that was removed — ensure the text flows without it.

## Assessment

The paper has improved substantially from round 1. The treatment definition is now internally consistent, figures match their captions, and code paths are portable. The paper is ready for external review.

DECISION: CONDITIONALLY ACCEPT
