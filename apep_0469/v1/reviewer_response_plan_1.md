# Reviewer Response Plan — Round 1

## Cross-Reviewer Themes

| Theme | GPT | Grok | Gemini | Priority |
|-------|-----|------|--------|----------|
| Identification fragility / selection on observables | ✓ | ✓ | ✓ | Address in framing |
| Triple-diff pre-trend failure (−0.304***) | ✓ | ✓ | ✓ | Add cohort restriction |
| Sensitivity to weights (unweighted is NS) | ✓ | ✓ | ✓ | Add justification |
| Baby boom / fertility confound | ✓ | ✓ | ✓ | Add fertility controls |
| Need to benchmark CenSoc vs AAL mob measure | ✓ | ✓ | ✓ | Promote Table A11 |
| Small-N inference (N=49) | ✓ | ✓ | ✓ | Add RI + HC3 + wild bootstrap |
| Triple-diff magnitude too large (−0.284) | ✓ | | | Audit and clarify |
| Missing citations | ✓ | ✓ | | Add key references |

## Workstreams

### W1: Inference Upgrades (R code — 04_robustness.R)
- Add randomization inference (1000 permutations of mob_std across states)
- Add HC2/HC3 standard errors for state-level regressions
- Add leave-one-out influence diagnostics
- Add wild cluster bootstrap for triple-diff (fwildclusterboot)

### W2: Additional Robustness (R code — 04_robustness.R)
- Add ANCOVA specification (include 1940 LFP level as control)
- Add fertility control (% with children under 5 from IPUMS NCHILD)
- Restrict triple-diff cohort to age 25-45 in 1940 for pre-trend retest

### W3: Framing and Language (paper.tex)
- Soften causal language throughout → "conditional association"
- Clarify triple-diff magnitudes (predicted values at ±1 SD)
- Promote Table A11 (AAL comparison) to main text
- Add weight justification paragraph

### W4: Literature (paper.tex + references.bib)
- Add Rambachan & Roth (2023) on pre-trend sensitivity
- Add Cameron, Gelbach & Miller (2008) on wild cluster bootstrap
- Add Bound & Turner (2002) on GI Bill
- Add Goldin & Olivetti (2013) on WWII women

### W5: Prose and Exhibits
- Address prose review suggestions (already partially done)
- Table names already cleaned (setFixest_dict)
