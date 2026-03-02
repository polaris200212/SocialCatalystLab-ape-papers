# Internal Review - Round 1

**Reviewer:** Claude Code (internal)
**Date:** 2026-02-23
**Paper:** Does Sanitation Drive Development? Satellite Evidence from India's Swachh Bharat Mission

## Verdict: MAJOR REVISION

## Summary

This paper studies the economic effects of India's Swachh Bharat Mission using staggered DiD with satellite nightlights. The main contribution is a well-identified null result: ODF declarations have no detectable effect on nighttime economic activity. The paper effectively demonstrates TWFE bias and uses CS-DiD as a correction.

## Major Concerns

1. **Internal consistency of reported statistics.** Several numbers in the text did not match the tables (rural share values, summary statistics). These have been corrected.

2. **Missing DMSP pre-trend figure.** The paper claims an extended pre-trend analysis using DMSP (2008-2013) but provides no figure. A textual description has been added to the appendix explaining the DMSP analysis.

3. **Table formatting issues.** Table 3 (modelsummary output) had column truncation issues due to tabularray format. Rewritten in standard tabular format.

4. **Figure 5 (heterogeneity by rural share) had artifacts.** The grouping variable included post_odf, creating spurious spikes. Fixed by removing post_odf from the grouping.

5. **Wild cluster bootstrap claimed but not reported.** The inference section promised wild cluster bootstrap results that were not computed. Removed the claim.

## Minor Concerns

1. Table 1 population figures hard to read (7+ digit numbers). Fixed by reporting in millions/thousands.
2. Figures placed suboptimally - raw trends and ODF timeline should appear earlier. Moved to Data/Background sections.
3. Opening sentence could be stronger. Revised to lead with the striking fact about open defecation prevalence.

## Changes Made

All major and minor concerns addressed. Paper recompiled and verified.
