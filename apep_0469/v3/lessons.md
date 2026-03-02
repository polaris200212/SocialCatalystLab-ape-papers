## Inherited from parent
- v2 used CLP/ABE crosswalks (14M men, 5.6M couples); reviewers flagged lack of pre-trend test
- Decomposition used all-women aggregate (not comparable to within-couple married women)
- Mobilization measure (CenSoc) not externally validated
- No IPW or linkage selection analysis

## Discovery
- **Policy chosen:** WWII mobilization and female LFP (continuation of apep_0469 family)
- **Key innovation:** 3-wave MLP panel (1930-1940-1950) for pre-trend test
- **Data upgrade:** MLP v2 crosswalk (175.6M records) replaces CLP/ABE, accessed via Azure Blob Storage
- **Schema discovery:** 1930 census Parquet lacks MOMLOC, POPLOC, SPLOC, EMPSTAT, EDUC — had to hardcode actual column lists instead of using 00_config.R
- **LFP construction for 1930:** Uses CLASSWKR > 0 ("gainful employment") since EMPSTAT not available

## Execution
- Built custom 04_build_1930_1940_1950.R panel builder (adapted from 03_build_multi.R)
- 43.5M unique 1:1:1 links found in MLP crosswalk for 3-census balanced panel
- Rewrote all 7 R scripts (00-06) for Azure-native data access
- Added 6 new robustness checks (R15-R20): mobilization validation, linkage vs mob, IPW, finer age bins, war mortality proxy, pre-trend event study
- Paper rewritten from scratch — no version mentions, married-women decomposition as primary finding

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex PASS; Gemini FAIL) — took 5 rounds
- **Top criticism:** Text-vs-table coefficient mismatches (paper text had anticipated numbers that didn't match regression output). Required systematic reconciliation across ~15 locations.
- **Surprise feedback:** GPT correctly flagged "All Women" column in Table 8 as logically inconsistent (within-couple panel only tracks married women). Also: the -0.0011 residual is not statistically distinguishable from zero, making the "central finding" claim require more hedging than initially written.
- **What changed in Stage C:** (1) Scaled back causal language throughout — "gradient" not "effect," ITT estimand defined; (2) Added uncertainty caveat to decomposition residual; (3) Labeled husband-wife dynamics as reduced-form correlation; (4) Prose improvements per Gemini review — narrative paragraphs in data section, less "table talk" in results, vivid opening, rewritten conclusion; (5) Added honest hedging about mobilization measure limitations.

## Summary
- **Key lesson for future papers:** ALWAYS reconcile text with table output before advisor review. Writing paper text with "anticipated" numbers that don't match actual regression output wastes 4 advisor review cycles.
- **Second lesson:** For decomposition results, compute standard errors from the start. A tiny residual without inference is scientifically meaningless.
- **Third lesson:** Cross-model review (tri-model referee) is valuable — GPT's structural criticism (reframe as descriptive, not causal) was the most important feedback, while Grok validated technical details and Gemini caught presentation issues.
