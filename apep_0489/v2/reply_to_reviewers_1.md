# Reply to Reviewers — Round 1 (Updated after Round 2)

## Reviewer 1 (GPT-5.2): MAJOR REVISION

**1. No standard errors for transition matrix cells.**
We fully agree this is the paper's main limitation. We have expanded the limitations section to discuss county-cluster bootstrap and permutation inference as important extensions. The current validation stack (pre-trends MAE = 0.0002, placebo specificity test, TWFE consistency) provides indirect evidence but does not replace formal inference. We view developing tractable bootstrap procedures for transformer-estimated transition matrices as the most important direction for future work.

**2. Spillover from non-TVA counties in TVA states.**
We now explicitly discuss this threat in the limitations section. Non-TVA counties within TVA states may benefit from electricity access or labor market spillovers, biasing estimates toward zero. We propose testing robustness to excluding TVA-region states entirely as an important check.

**3. Migration and selection bias.**
We have clarified that our estimates are intent-to-treat (ITT) by 1920 county of residence. The direction of selection bias (more mobile workers harder to link) attenuates our estimates. We discuss linkage rate comparisons and inverse probability weighting as potential corrections.

**4. Aggregation methodology.**
We acknowledge that equal-weighted token aggregation may not correspond to a population-weighted estimand. We discuss frequency-weighted aggregation anchored to a fixed baseline distribution as a robustness check.

**5. Single pre-period.**
We acknowledge the limitation of a single pre-transition (1920→1930). Extension to 1910–1920 links would provide a second pre-period but requires earlier census crosswalks not currently available.

**6. (Round 2) Need frequency-based benchmark.**
GPT-5.2 requests computing the same DiD transition matrix using raw frequencies and comparing to transformer-based estimates. This would anchor the contribution as "better measurement" rather than "model creates pattern." We agree this is a high-value robustness check and have listed it as a priority for future revision.

**7. (Round 2) Mechanism claims exceed evidence.**
GPT-5.2 notes that "skill-match channels," "entrepreneurial channel," and "general equilibrium mechanism" are interpretive labels applied to reduced-form reallocation patterns, not directly identified mechanisms. We have added caveats in the structural transformation section making clear these are "patterns consistent with" theoretical channels.

**8. (Round 2) FDR correction is ad hoc.**
The "10× pre-trends MAE" threshold is not a standard Benjamini-Hochberg procedure using p-values. We acknowledge this limitation and note that proper FDR requires the bootstrap CIs from item 1.

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

Most concerns overlap with Reviewer 1. Additional points:

**Benchmark against simpler estimators.**
We compare to TWFE at the aggregate level. Cell-by-cell TWFE on the full 12×12 matrix would require county-level panel data for each cell, which is computationally feasible but was not included in this version.

**Literature gaps.**
Grok suggests adding Artuñeda et al. (2018 QJE) on 1850-80 US mobility and Deming & Noray (2020 QJE) on skill transfer. These would strengthen the historical context and skill-match claims.

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

**Inference concerns** addressed as above.
**Vocabulary and tokenization design** — we discuss the 10-category occupation × 9 industry × 4 marital × 4 children bundling in the data section, and note that aggregation back to occupation averages over industry/demographics.
**Bootstrap request** — Gemini suggests 50-100 county-level bootstrap iterations. We agree this is feasible (~1min per adapter × 4 × 50 = ~3.5 hours) and is the priority for the next revision.
