# Reviewer Response Plan — Round 1

## Summary of Reviewer Feedback

| Reviewer | Decision | Key Concern |
|----------|----------|-------------|
| GPT-5.2 | Major Revision | Triple-diff not insulated from COVID type-specific shocks; GADM1 inference (13 regions); mixed placebos |
| Grok-4.1-Fast | Major Revision | GADM1 placebos not fully null; triple-diff imprecise; economic magnitudes unclear |
| Gemini-3-Flash | Minor Revision | Triple-diff p-values need more explicit acknowledgment; Italy placebo in PACA |

## Workstreams

### WS1: Language Calibration (All 3 reviewers)
- Replace "resolve" with "address" or "diagnose" throughout
- Be more explicit about triple-diff imprecision (p ≈ 0.10–0.18)
- Reframe conclusion around methodological contribution, not causal effect

### WS2: Multiple Testing / Placebo Framework (GPT, Grok)
- Add Bonferroni-adjusted p-values for 5-country placebo battery (adjust threshold to 0.01)
- Add note that 3 of 5 GADM1 triple-diff placebos significant individually but only 1 survives Bonferroni
- Frame placebo failures as evidence that cross-border demand operates for multiple neighboring countries

### WS3: Economic Magnitude (Grok)
- Add 1-SD interpretation for census stock DiD: 1.39 SD → 1.5pp price rise
- Add triple-diff magnitude: "the house–apartment gap widened by X pp for a 1-SD exposure increase"
- Loire vs Dordogne comparison already in text — extend to triple-diff

### WS4: GADM1 Inference Caveat (GPT)
- Add paragraph noting that with 13 GADM1 regions, the effective cluster variation is limited
- Note that département-clustered SEs may be conservative or liberal depending on correlation structure
- Flag as a limitation rather than re-estimating (region-level bootstrap is new analysis)

### WS5: COVID Threat Discussion (GPT)
- Expand discussion of COVID-era type-specific shocks as the main remaining threat
- Note that dept×quarter FE absorbs all symmetric shocks but not type-specific ones
- Emphasize that rural amenity control is insignificant (does not absorb signal)

### WS6: Prose Improvements (Prose Review)
- Apply top prose review suggestions already partially done
- Improve transitions and section endings

### WS7: Exhibit Fixes (Exhibit Review)
- Table 3: already fixed log_price_m2 → Log Price/m²
- Add frequency note to Table 2

## Execution Order
1. WS1 (language) → paper.tex edits
2. WS2 (multiple testing) → table notes + text
3. WS3 (magnitudes) → text additions
4. WS4 (GADM1 caveat) → limitations section
5. WS5 (COVID threat) → discussion expansion
6. WS6-7 (prose/exhibit) → integrated
7. Recompile
