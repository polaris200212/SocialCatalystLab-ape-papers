# Reviewer Response Plan (Stage C)

## Common Themes Across Reviewers

1. **Wild cluster bootstrap** (GPT, Grok, Gemini) — All 3 recommend WCB for state-level clusters
2. **Missing references** (all 3) — Key methodological and domain papers
3. **Mandi-level dates** (all 3) — Cannot obtain; acknowledge limitation
4. **Arrival analysis** (Gemini, Grok) — Data too sparse; note limitation
5. **CS weight diagnostics** (GPT, Grok) — Desirable but complex; partially address

## Actionable Changes

### 1. Add missing references
Add BibTeX entries for: Borusyak et al. (2024), de Chaisemartin & D'Haultfoeuille (2020), Roth et al. (2023), Conley & Taber (2011), Donaldson (2018). Cite in text.

### 2. Wild cluster bootstrap
Implement `fwildclusterboot` for headline TWFE estimates at state level. Report WCB p-values.

### 3. Confidence intervals
Add 95% CIs for headline CS-DiD estimates in text.

### 4. Cluster counts
Add number of mandis and states to table notes.

### 5. Prose
- Explain CS vs SA disagreement more concretely (GPT suggestion)
- Reduce repetition in Sections 6-7

## Not Feasible in This Round
- Mandi-level dates (data not available)
- Stacked DiD (substantial rewrite)
- Full CS weight diagnostics
- Arrival quantity analysis (API data gaps)
- BJS imputation estimator
