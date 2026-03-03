# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-03-03

## Summary

This paper exploits arXiv's daily 14:00 ET submission cutoff using an RDD to test whether listing position causally affects citation outcomes in AI/ML research. The first stage is strong (-0.70 position percentile jump, z=-17.1). The main finding is a well-identified null: despite the massive visibility shock, there is no detectable effect on citations at any horizon or on industry adoption.

## Strengths

1. **Sharp institutional variation**: The arXiv cutoff provides a clean, sharp discontinuity with a massive first stage.
2. **Honest null result**: The paper does not torture data to find significance. The null is presented as informative.
3. **Comprehensive robustness**: Bandwidth sensitivity, donut RDD, placebo cutoffs, kernel/polynomial checks.
4. **Engaging writing**: The Transformer paper anecdote is effective; the prose is clear throughout.

## Weaknesses

1. **Limited statistical power**: Effective N of 84-129 means MDE ~120-170%. Cannot distinguish zero from moderate effects (20-30% as in Feenberg 2017).
2. **Treatment bundles position + delay**: Cannot separate position from timeliness. The 24-hour delay confound is fundamental.
3. **OpenAlex match rate of 25%**: Missing 75% of papers raises sample selection concerns, though the match rate balance test is reassuring.
4. **Single platform, single field**: External validity is limited to AI/ML on arXiv.

## Revision Requests

### Must-Fix
- None remaining after advisor review fixes.

### High-Value
- Discuss statistical power more prominently — the MDE should be in the abstract or at least early in the results.
- Consider presenting the result as a one-sided test: can rule out large positive effects.

### Optional
- A summary coefficient plot showing all outcomes would strengthen the visual narrative.

## Overall Assessment

A well-executed RDD with an informative null result. The identification is clean, the robustness is thorough, and the writing is strong. The main limitation is statistical power, which the paper acknowledges. Suitable for a specialized journal (Journal of the European Economic Association, Review of Economics and Statistics) or as a strong null-result contribution to science-of-science literature.

DECISION: MINOR REVISION
