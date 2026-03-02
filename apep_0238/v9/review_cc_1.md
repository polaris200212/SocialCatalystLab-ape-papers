# Internal Claude Code Review — Round 1

**Role:** Internal review (self-assessment)
**Paper:** apep_0238 v9
**Timestamp:** 2026-02-26T11:05:00

---

## Changes Made in This Revision (v9 of v8)

### Workstream A: Model Architecture Fix
1. Changed separation rate delta from 0.034 to 0.023 (SS UR: 0.078 -> 0.059)
2. Added AR(1) mean-reverting demand shock (rho_a = 0.99, half-life ~69 months)
3. Maintained peak-ratio scaling for SMM (4 params: lambda, chi1, A, kappa)
4. Re-estimated SMM: lambda=0.27, chi1=0.0054, A=0.39, kappa=2.20
5. Welfare ratio: 71:1 -> 12:1 (range 7-18:1 depending on rho_a)
6. Scarring share: 1.8% -> 9%

### Workstream B: Empirical Additions
1. Romano-Wolf stepdown p-values (1000 bootstrap replications)
2. Montiel Olea-Pflueger weak IV diagnostics (F_eff=29.4 > 23.1 at all horizons)
3. Per-moment SMM fit table

### Workstream C: Paper Rewrite
1. Abstract: leads with pi_LR, reports welfare as range, acknowledges model rejection
2. Introduction: softened causal claims, added comparative-case-study caveat
3. Model section: AR(1) shock process, perceived-permanent beliefs discussion
4. Calibration: delta=0.023, rho_a=0.99, updated SMM estimates
5. Welfare: 12:1 baseline with 7-18:1 range, J-test rejection acknowledged
6. Robustness: honest RW reporting (no horizon survives at 5%), MOP confirmation
7. Sensitivity: replaced fabricated inlined table with auto-generated tab13
8. All tables: added controls documentation, harmonized persistence ratios

### Stage C: Referee Feedback Addressed
1. GPT: Softened causal claims, led with pi_LR, presented welfare as range
2. Grok: Added fiscal confounding discussion, model J-test caveats
3. Gemini: Fixed IV claim (comparable through h=24, not h=48)

## Remaining Known Issues
- J-test rejects (p=0.000): AR(1) too simple for near-permanent GR pattern
- SS UR=0.059 vs target 0.055: slightly overshoots
- Raw Bartik coefficients in appendix tables are large (inherent to small SD)
- 2-episode external validity limitation (acknowledged in text)
