# Revision Plan — Round 1

## Summary of Reviewer Consensus

All three referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) recommend MAJOR REVISION across two review rounds. The core consensus issues are:

1. **No formal inference** for transition matrix cells (all 3 reviewers, both rounds)
2. **Spillover contamination** from non-TVA counties in TVA states (GPT, Grok)
3. **Migration/selection bias** in linked sample (all 3)
4. **Aggregation weights** not well-defined (GPT, Grok)
5. **Single pre-period** limits parallel trends testing (GPT, Grok)
6. **Need frequency-based benchmark** to anchor transformer estimates (GPT, Round 2)
7. **Mechanism claims exceed evidence** — reframe as interpretive patterns (GPT, Round 2)

## Revisions Made in This Round

### Addressed via text
- Expanded limitations section to directly acknowledge all 5 consensus concerns
- Reframed placebo test as pattern-specificity check (not clean null)
- Clarified estimand as ITT by 1920 residence
- Noted frequency-weighted aggregation as important robustness check
- Discussed spillover threat and alternative control groups

### Addressed via computation (pre-review)
- Pre-trends MAE = 0.0002 (token level)
- Placebo adapter test with structural comparison
- TWFE benchmark with state-clustered SEs
- FDR correction using pre-trends MAE as noise benchmark

### Deferred to future work
- County-cluster bootstrap for cell-level confidence intervals
- Permutation inference under restricted assignment
- Alternative control groups (border counties, excluding TVA states)
- Frequency-weighted aggregation sensitivity
- Extension to 1910–1920 links for additional pre-period
