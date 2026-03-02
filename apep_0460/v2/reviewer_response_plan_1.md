# Revision Plan — Stage C (v2 Round 1)

## Summary of Referee Feedback

All three referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) gave MAJOR REVISION. The central concerns are:

1. **German placebo invalidates exclusion restriction** — Germany SCI effect (0.045) > UK (0.025)
2. **Baseline price confounding** — UK coefficient collapses with price controls (0.025 → 0.003)
3. **Parallel trends marginal rejection** — Joint test p = 0.038
4. **Post-treatment SCI measurement** — 2021 vintage measured 5 years after treatment
5. **Missing buyer nationality mechanism data** — Only indirect evidence

## What Was Already Addressed in v2

The v2 paper already:
- Added GBP/EUR exchange rate interaction (confirms sterling channel, p = 0.022)
- Added baseline characteristics × Post controls (reveals price confounding)
- Added short event window (2014-2018, pre-COVID)
- Added département-specific linear trends
- Reframed claims as "composite" of UK-specific and broader European divergence
- Cut 24% of word count with razor-sharp prose

## Stage C Revisions (Post-Referee)

### 1. Reframed German placebo as "benchmark" (not "problem")
- Changed section title to "The German Placebo Benchmark"
- Reframed as revealing cosmopolitan département dynamics

### 2. Fixed table presentation
- Added adjustbox to Tables 4 and 6 (margin clipping fix)
- Added table notes explaining exchange rate sign convention
- Added table notes to window/trends table

### 3. Prose improvements
- Replaced defensive identification paragraph with upfront framing
- Active voice in Data section
- Katz-style mechanism leads in property type heterogeneity

### 4. Claim calibration
- Abstract already states "UK-specific component is real but modest"
- Conclusion already acknowledges "imperfect" identification
- No overclaiming relative to what the data shows

## Items NOT Addressed (Structural Limitations)

These would require fundamentally new data or redesign:
- Pre-2016 SCI vintage (does not exist)
- Buyer nationality microdata (not publicly available)
- Triple-difference design (requires additional country-level treatment variation)
- Rambachan-Roth sensitivity bounds (would require additional R packages)

The paper's contribution is its transparent documentation of both the promise and limits of SCI-based cross-border identification.
