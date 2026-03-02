# Initial Research Plan: apep_0483 v2

## Research Question
Does the erosion of teacher pay competitiveness — driven by a decade of austerity-era pay restraint under the STPCD — affect student value-added (Progress 8) in English secondary schools?

## Identification Strategy
1. **Panel FE**: LA + year fixed effects exploit within-LA variation in competitiveness over time
2. **Event Study**: Baseline (2018) competitiveness × year interactions test for cumulative effects
3. **Bartik IV**: 2010 industry composition × time trend instruments competitiveness
4. **Academy DDD**: Maintained (STPCD-bound) vs. academy (pay-flexible) schools as falsification

## Expected Effects
- Negative: Higher competitiveness (private sector more attractive) → worse Progress 8
- Heterogeneity: Stronger in deprived areas (harder to recruit), Rest of England band (least London premium)
- Mechanism: Competitiveness → vacancies → student outcomes

## Primary Specification
`feols(progress8 ~ comp_ratio | la_id + year, cluster = ~la_code)`

## Planned Robustness
- Leave-one-region-out
- Randomization inference (999 permutations)
- Alternative treatment definitions (binary Q1, log, quadratic)
- MDE and equivalence testing
- Academy placebo
