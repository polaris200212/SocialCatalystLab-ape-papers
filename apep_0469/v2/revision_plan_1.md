# Revision Plan 1 — apep_0469 v2

## Summary

Address all referee feedback from tri-model review panel (GPT-5.2 Major Revision, Grok-4.1-Fast Minor Revision, Gemini-3-Flash Minor Revision).

## Workstreams

### W1: Wild Cluster Bootstrap (GPT, Grok)
- **Rationale:** 49 state clusters make asymptotic inference borderline; wild bootstrap provides exact finite-sample p-values.
- **Implementation:** Manual wild cluster bootstrap with Rademacher weights, B=999, imposed null (Cameron-Gelbach-Miller 2008).
- **Result:** p < 0.001, 95% CI [0.0036, 0.0100]. Added Section 7.13 and Table 8 row.

### W2: Non-Mover Couples (Grok, Gemini)
- **Rationale:** Migration to defense hubs could confound mobilization effects if couples moved to high-opportunity states.
- **Implementation:** Merge mover flag from individual panel; restrict to 88.1% of couples where husband stayed in same state.
- **Result:** beta = +0.0079 (SE = 0.0035, N = 4,826,586). Added Section 7.14 and Table 8 row.

### W3: Causal Language Softening (GPT)
- **Rationale:** State-level mobilization is an instrument, not a randomized treatment. Language should reflect associational identification.
- **Implementation:** Replaced "mobilization expanded" → "higher mobilization corresponds to", "caused" → "associated with" throughout.

### W4: Decomposition Caveats (GPT, Gemini)
- **Rationale:** Within-couple panel tracks married wives; aggregate cross-section includes all women. Formal identity requires same population.
- **Implementation:** Already reframed in previous advisor revision cycle. Added explicit IPW note as future work.

### W5: Industry Decomposition (Grok — deferred)
- **Rationale:** Valuable extension but state-level instrument lacks industry-specific variation.
- **Action:** Noted as future work in text.

### W6: Mobilization Measure Discrepancy (GPT, Gemini — deferred)
- **Rationale:** CenSoc Army-only vs. Selective Service all-branch. Would require obtaining original Acemoglu et al. (2004) data.
- **Action:** Acknowledged as data limitation in Section 6.9.

## Verification

All workstreams executed. Code changes in 04_robustness.R (R13, R14), 06_tables.R (Table 8 rows), paper.tex (Sections 7.13, 7.14, causal language). PDF recompiled at 45 pages with no placeholders or undefined references.
