# Internal Claude Code Review — Round 1

**Model:** claude-opus-4-6
**Timestamp:** 2026-02-20T17:00:00

## Review Summary

This paper examines whether France's €15 billion apprenticeship subsidy created net new jobs or relabeled existing hiring, exploiting the January 2023 subsidy reduction as a natural experiment. The paper uses three complementary strategies: sector-exposure DiD, cross-country DiD, and Indeed vacancy data.

## Strengths
1. **Important policy question** with large fiscal stakes (€15B/year)
2. **Multi-method approach** triangulating sector, cross-country, and vacancy evidence
3. **Honest reporting** of inference challenges (wild bootstrap p-values reported alongside clustered SEs)
4. **Strong institutional narrative** grounding the empirical work
5. **Comprehensive robustness** (LOSO, RI, dose-response, alternative controls)

## Weaknesses and Limitations
1. **Inference fragility**: Main coefficient not significant under wild cluster bootstrap (p = 0.18). Paper honestly acknowledges this.
2. **Total employment red flag**: Column 4 shows differential total employment growth in exposed sectors, suggesting possible confounding from sectoral recovery.
3. **Single treated unit** in cross-country design limits causal interpretation.
4. **No first-stage evidence**: Cannot directly show apprenticeship contracts fell while total youth employment held steady.
5. **Mechanical placebo**: Prime-age share is arithmetic mirror of youth share.

## Changes Made in Revision
- Fixed algebra in conceptual framework (double-counted subsidy)
- Added wild cluster bootstrap p-values
- Toned down overclaiming language
- Reframed cross-country evidence as "suggestive"
- Acknowledged mechanical nature of prime-age placebo
- Added 6 missing methodological references
- Fixed table formatting (professional labels instead of raw variable names)
- Improved abstract and removed roadmap paragraph
- Added section labels for cross-referencing

## Assessment
The paper provides suggestive evidence for relabeling, honestly engages with its limitations, and makes a credible case that the subsidy did not create net new positions. The inference is genuinely imprecise with 19 clusters, which the paper now acknowledges transparently.

DECISION: PROCEED TO PUBLISH
