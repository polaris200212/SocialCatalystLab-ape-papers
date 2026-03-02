# Revision Plan - Round 1

## Summary of Changes

Based on feedback from 3 external reviewers (GPT-5-mini: Major Revision, Grok-4.1-Fast: Minor Revision, Gemini-3-Flash: Major Revision), exhibit review, and prose review, we made the following revisions:

### Critical Fixes
1. **Text-table consistency**: Fixed coefficient magnitude in abstract/intro (0.15 → 0.41 pp)
2. **Table formatting**: Restructured all tables to use separate coefficient/SE rows (fixed LaTeX column alignment)
3. **Code crash**: Added NULL guard for IV fiscal results in 06_tables.R
4. **Pre-sample timing**: Clarified that 1995-2005 HtM average eliminates cyclical contamination despite partial overlap with analysis window

### Prose Improvements
1. **Opening paragraph**: Rewrote to start with concrete Mississippi vs New Hampshire comparison (per prose review)
2. **Results narration**: Replaced dry table references with economic story of coefficient building over horizons
3. **Transition between monetary and fiscal sections**: Added unifying MPC mechanism framing
4. **Identification language**: Made more accessible ("For these estimates to be causal, two things must be true")

### Literature
1. Added Beraja, Fuster, Hurst, Vavra (2019, QJE) on refinancing channel
2. Added Cloyne, Ferreira, Froemel, Surico (2023, JEEA) on monetary policy with debt
3. Both cited in structural interpretation section

### Statistical Honesty
1. Acknowledged permutation p-value of 0.39 explicitly
2. Discussed power constraints and directional evidence interpretation
3. Expanded limitations section with 5 specific caveats
4. Fixed SNAP proxy discussion (near-zero, not "positive and significant")

### Scope Notes
- Did not extend BRW shocks past 2020 (data not available yet)
- Did not construct composite HtM index (would be a natural extension for revision 2)
- Did not add pre-trends visualization (h<0 LP plot — future improvement)
