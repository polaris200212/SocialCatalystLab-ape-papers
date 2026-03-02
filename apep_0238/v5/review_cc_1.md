# Internal Review - Round 1 (Claude Code)

**Paper:** Demand Recessions Scar, Supply Recessions Don't
**Reviewer:** Claude Code (internal self-review)
**Date:** 2026-02-13

## Format Check
- **Length:** 52 pages total, ~30 pages main text. Exceeds 25-page minimum.
- **References:** Comprehensive bibliography covering Jorda LP, Mian-Sufi housing, Bartik instruments.
- **Prose:** All major sections in paragraph form.
- **Tables:** 8 tables with real numbers, proper SEs in parentheses.
- **Figures:** 10 figures with real data.

## Statistical Methodology
- HC1 standard errors throughout — appropriate for cross-sectional LP.
- Permutation p-values (1,000 reassignments) — excellent for N=50 inference.
- Clustered SEs by census division (9 clusters) — reported in appendix.
- Leave-one-out analysis confirms no single state drives results.
- Sample sizes clearly reported.

## Identification Strategy
- Housing price boom instrument for Great Recession — well-established in literature.
- Bartik shift-share for COVID — appropriate with leave-one-out national shifts.
- Pre-trend validation at h=-36, -24, -12 shows no significant pre-trends.
- Extensive robustness: subsample analysis, alternative controls, Bartik for GR.

## Key Strengths
1. Clean comparison of two recession types using same cross-state methodology.
2. Structural DMP model with endogenous labor force participation.
3. Well-calibrated model that matches empirical half-lives.
4. Strong prose quality — reads like a Shleifer paper.

## Key Weaknesses
1. Cross-sectional design (N=50) limits power for heterogeneity analysis.
2. LFPR estimates imprecise — cannot empirically validate the participation channel.
3. No formal test distinguishing "demand" vs "supply" as mechanism (interpretation rests on theory).
4. Figure 10 rescaling methodology could be made more transparent.

## Suggestions
1. Add formal comparison of DMP model predictions vs LP impulse responses (e.g., SMM estimation).
2. Consider using individual-level CPS data to test the skill depreciation mechanism.
3. The Midwest subsample result (positive at h=60) deserves more discussion.

DECISION: MINOR REVISION
