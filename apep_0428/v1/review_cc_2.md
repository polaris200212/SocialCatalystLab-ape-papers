# Internal Review — Claude Code (Round 2)

**Role:** Internal reviewer (follow-up)
**Reviewer:** Claude Code (Opus 4.6)
**Paper:** Connecting the Most Remote: Road Eligibility and Development in India's Tribal Periphery
**Date:** 2026-02-20

---

## Changes Since Round 1

The paper has been substantially revised since initial drafting:
- Removed all text references to outcomes not shown in tables (gender gap, DMSP post, female non-ag worker share)
- Fixed bandwidth sensitivity text inconsistency (75% bandwidth p-value)
- Added footnote explaining BW sensitivity vs. main table differences
- Moved key figures (RDD binscatters, NL event study) from appendix to main text
- Improved opening paragraph with vivid monsoon imagery
- Corrected "15-23 years" to "14-22 years" for data coverage accuracy
- Reformatted Table 2 with shorter headers to prevent truncation

## Remaining Issues

1. **Minor:** The paper still defines `gender_lit_gap_11` in the Variable Definitions appendix table but never reports its RDD estimate. This is fine (not all defined variables need to appear in results), but could confuse a careful reader.

2. **Minor:** The comparison sample filter (300-750 for non-designated) differs from the analysis sample filter (50-500 for designated). The asymmetry is justified by the different thresholds but could be noted more explicitly.

3. **Suggestion:** The donut-hole estimates lose significance (p > 0.25) which is expected with reduced sample, but could benefit from reporting the donut with a wider exclusion zone (e.g., ±10) to show sensitivity.

## Assessment

All major issues have been addressed. The paper is internally consistent, with text claims matching table values. The methodology is sound and robustness checks are comprehensive.

DECISION: MINOR REVISION
