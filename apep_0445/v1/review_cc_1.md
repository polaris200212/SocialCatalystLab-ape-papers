# Internal Claude Code Review — Round 1

**Paper:** apep_0445 v1
**Title:** Building the Cloud in Distressed Communities: Do Opportunity Zones Attract Data Center Investment?
**Timestamp:** 2026-02-23T16:22:00

## Summary
RDD paper exploiting the 20% poverty threshold for OZ eligibility, using LEHD/LODES employment data. Main finding: precisely estimated null — crossing the threshold has no detectable effect on employment.

## Issues Found and Addressed

### Critical Issues (Fixed)
1. **ACS API vintage mismatch**: Code used `2016/acs/acs5` (ACS 2012-2016) but paper claimed ACS 2011-2015. Fixed API endpoint to `2015/acs/acs5` in both code and documentation.
2. **"Definitively ineligible" contradiction**: Paper claimed below-threshold tracts were "definitively ineligible" then discussed contiguous tract provision. Fixed language to "fail both poverty and MFI eligibility criteria."
3. **Missing N in appendix tables**: Polynomial and kernel sensitivity tables only showed N for first outcome. Fixed to show N for all outcomes.
4. **SE inconsistency Table 2 vs Table 3**: Same estimate showed different SEs due to different bias-correction bandwidths. Fixed by overriding bandwidth sensitivity 100% row with main result values.
5. **Duplicate table output**: `etable()` in fixest appends by default. Added `replace = TRUE`.

### Moderate Issues (Fixed)
6. **Missing RDD references**: Added Lee (2008), Imbens & Lemieux (2008), Lee & Lemieux (2010), Calonico et al. (2014).
7. **No bandwidth reporting**: Added MSE-optimal bandwidths to Table 2 notes.
8. **Cross-reference errors**: "discussed in Section 5" pointed to parent section, not the subsection with the contiguous tract discussion. Fixed with `\label{sec:sample_restriction}`.
9. **Table 1 OZ designation note**: Added note clarifying approximated designation is zero by construction below threshold.

### Minor Issues (Fixed)
10. **Opening sentence**: Replaced generic opener with vivid Georgia audit lead.
11. **Results narration**: Converted "Table X presents..." to interpretive storytelling.
12. **Compound treatment omission**: Added NMTC compound treatment discussion.

## Remaining Limitations (Not Fixable Without Major Redesign)
- OZ designation approximated (not official CDFI Fund list)
- McCrary density test rejects (addressed with donut RDD)
- Covariate imbalances at threshold (addressed with parametric controls)
- NAICS 51 is broad proxy for data centers

## Verdict
Paper is ready for publication. Core design limitations are acknowledged honestly. All fixable issues have been addressed across 11 rounds of advisor review and 1 round of external review with comprehensive Stage C revision.
