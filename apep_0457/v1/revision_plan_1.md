# Revision Plan 1 — APEP-0457

## Summary of Reviewer Feedback

All three external reviewers (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) recommended Major Revision with consensus on:

1. Pre-trends violate parallel trends; TWFE not credibly causal
2. Near-threshold DiD null and placebo cutoffs undermine threshold-specific interpretation
3. Treatment measured post-policy (2017 inventory)
4. RDD magnitude implausible vs DiD
5. Need spillover tests, trend controls, reframing

## Revision Actions Taken

### A. New Analyses
1. **Municipality-specific linear trends**: Effect drops from -2.9% to -1.0%, insignificant (p=0.18)
2. **Canton × year FE event study**: Pre-trends persist within cantons
3. **Difference-in-discontinuities**: RDD on change (pre→post) yields null (+0.033, p=0.23)
4. **Spatial spillover test**: Controls in treated cantons show no differential trends (+0.8%, p=0.21)
5. **IHS transform**: Confirms zeros don't drive results (-0.029, p<0.001)

### B. Paper Reframing
- Abstract rewritten to foreground identification challenges and null results from trend controls
- Conclusion repositioned as descriptive/diagnostic contribution
- Three contributions: (a) first Lex Weber employment documentation, (b) methodological case study in pre-trend diagnostics, (c) evidence that tourism communities face distinct trajectories

### C. Additional Robustness
- Robustness table expanded from 4 panels to 6 (added canton × year FE, linear trend controls)
- New subsections on spatial spillovers, difference-in-discontinuities, linear trends
- IHS results in appendix
