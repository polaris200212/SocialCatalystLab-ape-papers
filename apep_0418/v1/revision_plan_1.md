# Revision Plan 1

**Paper:** apep_0418 — Where the Sun Don't Shine: The Null Effect of IRA Energy Community Bonus Credits on Clean Energy Investment
**Date:** 2026-02-19

## Summary of Reviewer Feedback

Three external reviews received:
- **GPT-5.2:** MAJOR REVISION — treatment definition concerns, timing, sign-test validity
- **Grok-4.1-Fast:** MINOR REVISION — citations, power analysis, pre-IRA placebo
- **Gemini-3-Flash:** MINOR REVISION — coefficient magnitude, confidence intervals

## Planned Changes

### 1. Add 95% Confidence Intervals to Table 2
- Add CI row from rdrobust robust bias-corrected inference
- Makes interpretation of null more transparent

### 2. Remove Invalid Sign-Test Argument
- Bandwidth sensitivity estimates are mechanically correlated (overlapping samples)
- Replace formal sign-test claim with honest acknowledgment

### 3. Pre-IRA Placebo Test
- Run same RDD on pre-IRA clean energy capacity (generators before 2023)
- If significant: confirms pre-existing pattern, strengthens "physics vs policy" narrative
- Add to robustness section and appendix table

### 4. Minimum Detectable Effect (Power Analysis)
- Use rdpower package for formal MDE calculation
- Report MDE at 80% power to contextualize null result
- Add to "Statistical Power and Limitations" section

### 5. Add Missing Citations
- Lee & Lemieux (2010) — canonical RDD guide
- Imbens & Lemieux (2008) — foundational RDD reference
- Cattaneo, Titiunik & Vazquez-Bare (2019) — rdpower methodology

### 6. Recompile and Verify
- Re-run all R scripts (04-06) for updated results
- Full LaTeX compilation with bibliography
- Verify no unresolved citations
