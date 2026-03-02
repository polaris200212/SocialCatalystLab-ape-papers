# Revision Plan 1: Post-Review Fixes (apep_0417 v3)

## Context

This is a **layout-focused revision** (v2 → v3) that split paired desert maps into individual figures, fixed LaTeX float placement, and added per-specialty discussion text. The analysis and data are unchanged from v2.

## Reviewer Feedback Summary

| Reviewer | Decision | Key Concerns |
|----------|----------|-------------|
| GPT-5.2 | MAJOR REVISION | Treatment timing (forward-looking intensity), T-MSIS reporting confounding, log(+1) functional form |
| Grok-4.1-Fast | MINOR REVISION | Short post-period, suppression bias, add Callaway-Sant'Anna estimator |
| Gemini-3-Flash | MINOR REVISION | Practice size heterogeneity, travel distance deserts, log payments outcome |

## Changes Made in This Cycle

### Text Fixes (from advisor review)
1. **Fixed broken cross-references** in appendix: `eq:es` → `eq:eventstudy`, `fig:event_study` → `fig:eventstudy`, `tab:main_results` → `tab:main_by_spec`
2. **Fixed surgery trajectory description**: Changed "trending downward" to accurately describe surgery's modest growth per Table 2
3. **Added table reference for desert indicator claim**: Pointed to Table 5 "Medicaid pop denominator (desert)" row with coefficient value
4. **Removed unsupported MD vs NP Decomposition subsection**: Merged into No-NP/PA discussion
5. **Softened "by construction" claims**: Both in main text (§7.7) and appendix (Table 8 notes)
6. **Strengthened specialty event study appendix text**: Added F-test details and proper references

### Prose Improvements (from prose review)
1. **Punchier results lead**: Replaced "precisely estimated null" opening with vivid description of the shock's non-effect
2. **Active voice**: Changed passive "Standard errors are clustered..." to active "We cluster..."

## Deferred to Future Revisions

The following substantive suggestions from GPT-5.2 would require re-running the analysis pipeline and are beyond the scope of this layout revision:
- Time-varying quarterly cumulative disenrollment as treatment
- T-MSIS data quality metrics as controls
- PPML/count models for zero-heavy outcomes
- FFS vs MCO encounter splits
- Wild cluster bootstrap inference
- Callaway-Sant'Anna estimator

These are valuable suggestions for a future substantive revision (v4+).
