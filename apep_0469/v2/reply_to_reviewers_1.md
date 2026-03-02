# Reply to Reviewers — apep_0469 v2

## GPT-5.2 (Major Revision)

**1. Wild cluster bootstrap for inference with 49 clusters.**
Done. Implemented manual wild cluster bootstrap (Rademacher weights, B=999, imposed null). Bootstrap p < 0.001, 95% CI [0.0036, 0.0100]. Added Section 7.13 and Table 8 row.

**2. Soften causal language given observational identification.**
Done. Changed "mobilization expanded" → "higher mobilization corresponds to" and similar throughout. Added "associated with" framing consistently.

**3. Report exact p-values for borderline significance.**
Done. Randomization inference p = 0.033 (wives), bootstrap p < 0.001. Both reported in text and Table 8.

**4. Replication of Acemoglu et al. (2004) aggregate results with original induction data.**
Noted as limitation. CenSoc captures Army enlistees only; the original Selective Service data covers all branches. We acknowledge this in Section 6.9 and note it as a data limitation rather than a contradiction.

**5. Inverse probability weighting (IPW) for selection into linked sample.**
Added as future work suggestion. The Oster (2019) delta of -0.28 for wives suggests unobservables would need to work in the opposite direction, providing indirect evidence against selection bias.

## Grok-4.1-Fast (Minor Revision)

**1. Industry decomposition of mobilization effect.**
Noted as valuable extension. The 1940 census reports detailed industry codes, but the state-level mobilization instrument does not have industry-specific variation. Flagged for future work.

**2. Check if mobilization caused migration to defense hubs.**
Addressed. Added non-mover couples robustness check (Section 7.14). Among 88.1% of couples who stayed in the same state, beta = +0.0079 (SE = 0.0035), slightly larger than full sample. Migration does not drive results.

## Gemini-3-Flash (Minor Revision)

**1. Mobilization measure discrepancy with Acemoglu et al. (2004).**
Same as GPT point 4. Addressed in text as data-driven difference (CenSoc Army-only vs. Selective Service all-branch).

**2. Selection correction with IPW.**
Same as GPT point 5. Oster bounds provide indirect evidence; formal IPW is future work.

**3. Decomposition: all women vs. married wives population mismatch.**
Addressed extensively. Reframed entire Section 5 as "comparison" rather than "decomposition identity." Added explicit population mismatch caveats. The within-couple panel measures married wives; the aggregate cross-section includes all women. The gap (-3.79 pp) reflects this population difference plus compositional turnover.
