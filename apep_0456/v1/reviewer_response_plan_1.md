# Reviewer Response Plan

## Cross-Reviewer Consensus Issues

### 1. Boundary Segment Fixed Effects (GPT #1.5, All)
All reviewers note the A86 creates along-boundary heterogeneity. Simple distance-only RDD pools 79km of boundary.
**Fix:** Add boundary segment FE. Project each transaction to nearest boundary point, bin boundary into ~15 segments (~5km each), include segment FE in main specification.

### 2. Spatial Clustering / Conley SEs (GPT #2.2, Grok #3)
rdrobust SEs may understate uncertainty due to spatial correlation.
**Fix:** Add commune-clustered SEs as robustness. Report alongside rdrobust SEs.

### 3. Effective N Within Bandwidth (GPT #2.1)
N reported in Table 2 is total sample on each side, not within-bandwidth N.
**Fix:** Report both total N and effective N within bandwidth for all specifications.

### 4. Month-Year Fixed Effects (GPT #2.4)
Year FE too coarse for mid-year policy changes and seasonal housing patterns.
**Fix:** Replace year FE with year×quarter FE in main specification.

### 5. Formal Power Calculation (Grok #2.2)
Strengthen "evidence of absence" with formal MDE.
**Fix:** Calculate and report minimum detectable effect at 80% power.

### 6. Tighten Novelty Claims (GPT #4.1)
"First causal evidence" overstated given Berlin studies.
**Fix:** Reframe as "first within-city boundary evidence" and "first France evidence."

### 7. No Air Quality First Stage (All 3)
All reviewers want evidence that pollution actually changes at boundary.
**Status:** Cannot address in this revision — Airparif data would require new pipeline. Will acknowledge as limitation and discuss expected pollution gradients.

### 8. No Pre-Period Data (All 3)
Geocoded DVF starts 2020; true pre-ZFE baseline unavailable.
**Status:** Cannot address — pre-2019 DVF not geocoded. Acknowledge limitation.

### 9. Donut Instability (All 3)
200m donut result (+18.5%) is a red flag.
**Fix:** Report segment-level donut results; discuss that instability arises from segment heterogeneity.

## Prose Workstream
- Opening hook already sharpened (done)
- Roadmap paragraph removed (done)
- Heterogeneity narration improved (done)
- Conclusion punchier (done)

## Exhibits Workstream
- Map moved to main text (done)
- Balance table "Status" column removed (done)
- Will update Table 2 with effective N

## Execution Order
1. Code: Add segment FE, commune clustering, quarter FE, effective N
2. Code: Power calculation
3. Paper: Update tables, text, novelty claims
4. Recompile and verify
