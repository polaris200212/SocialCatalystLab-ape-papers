# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (Opus 4.6)
**Paper:** apep_0448 v1
**Date:** 2026-02-24

---

## Summary

This paper examines whether early termination of the $300/week FPUC supplement in 26 states increased Medicaid HCBS provider supply, using T-MSIS provider spending data. The CS-DiD ATT shows a 6.3% increase in active providers and 15.1% increase in beneficiaries served, with a null behavioral health placebo.

## Issues Found and Fixed

### Critical Issues (Fixed)

1. **Placeholder contributor names** (@CONTRIBUTOR_GITHUB) — replaced with @ai1scl
2. **Summary statistics text-table mismatch** (text: 352/302, table: 318/287) — updated all text
3. **Cohort definition error** (Indiana listed as August cohort instead of Arizona) — fixed
4. **Log-to-percentage conversion errors** (0.061 ≠ 6.1%, should be 6.3%) — corrected all using exact formula 100×(e^β − 1)
5. **Undefined LaTeX command** (\floatfoot) — added definition to preamble
6. **NPPES match rate inconsistency** (99.1% vs 98.1%) — standardized to 98.1%
7. **Phantom methodology claims** (entropy balancing, COVID controls mentioned but not implemented) — removed

### Substantive Improvements

1. **Main text expansion** from 22 to 26 pages (Political Economy section, expanded panel construction, threats to identification, visual evidence, comparison with prior literature)
2. **CS-DiD randomization inference** (200 permutations, p = 0.060) — resolves tension with TWFE RI (p = 0.150)
3. **95% confidence intervals** added to Table 2 for all CS-DiD ATTs
4. **Panel C completed** — behavioral health placebo now shows all 4 outcomes
5. **Significance stars** added to Tables 2 and 3
6. **December 2024 data truncation** — figures now end at November 2024 due to T-MSIS reporting lag
7. **ARPA Section 9817** added as fifth limitation
8. **Missing references** added (de Chaisemartin & D'Haultfoeuille 2020, Roth 2022, Borusyak et al. 2024)

### Table/Figure Fixes

- RI row in robustness table restructured: now shows CS-DiD RI (p = 0.060) and TWFE RI (p = 0.150) separately
- Table notes clarified: Panel A uses bootstrap SEs, Panel B uses clustered SEs
- Figure legends changed from "units" to "jurisdictions"
- South definition in text updated to include WV (matching table)
- Maryland treatment status clarified (FPUC terminated, PUA/PEUC reinstated)

## Remaining Limitations (Acknowledged)

- Billing NPIs represent entities, not necessarily individual workers
- No entity-type decomposition (individual vs. organizational NPIs)
- ARPA HCBS spending plans as potential confounder (mitigated by BH placebo)
- State-level panel limits sub-state heterogeneity analysis

## Assessment

Paper passes internal quality checks. Main text is 26 pages, all tables contain real data with significance stars and CIs, all figures render correctly, no unresolved citations, and the identification strategy is well-supported by robustness checks including the new CS-DiD RI result.
