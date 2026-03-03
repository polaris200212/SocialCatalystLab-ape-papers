# Reviewer Response Plan

## Common Themes Across All Three Referees

1. **Inference validity (ALL):** RI p=0.342 undercuts TWFE p<0.01. Few-cluster problem is real.
2. **TWFE vs CS-DiD divergence (ALL):** CS ATT=0.0014 is half the TWFE estimate; need reconciliation.
3. **Cross-state event study (GPT, Grok):** Current event study is within-expansion-states only.
4. **Cycle aggregation timing (GPT, Grok):** Partial treatment in straddle cycles.
5. **Linkage validation (GPT, Grok):** Need representativeness diagnostics for matched sample.

## Workstream 1: Inference (Must-Fix)

- Increase RI permutations from 199 to 999
- Report wild cluster bootstrap p-values if feasible
- Frame RI/CS as primary inference, TWFE as benchmark
- Add power/MDE calculation

## Workstream 2: TWFE/CS Reconciliation (Must-Fix)

- Report CS-DiD ATT by cohort (which expansion cohorts drive the difference?)
- Add cohort-specific effects table
- Discuss negative weighting in TWFE interaction estimand

## Workstream 3: Cross-State Event Study (High-Value)

- Implement a DDD event study using both expansion and non-expansion states
- Assign pseudo-event-times to never-treated states or include them in regression

## Workstream 4: Claims Calibration (Must-Fix)

- Soften all causal language throughout (already suggestive, make more consistent)
- Remove "answers these questions" from intro
- Lead with RI result in abstract
- Frame TWFE as one of several estimates, not the "preferred" estimate

## Workstream 5: Prose & Exhibits (From A.5/A.6 Reviews)

- Kill roadmap paragraph (DONE)
- Active voice in data section (DONE)
- Consider scaling Table 3 to percentage points

## Workstream 6: Linkage Diagnostics (High-Value)

- Add matched vs unmatched provider comparison
- Report results under alternative linkage rules in appendix text

## Priority Order

1. Claims calibration (text changes, fast)
2. Increase RI permutations (code change, moderate compute)
3. TWFE/CS reconciliation (analysis + text)
4. Cross-state event study (new analysis)
5. Linkage diagnostics (text + analysis)
6. Prose/exhibit improvements (text)
