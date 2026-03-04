# Research Ideas

## Idea 1: DiD-Transformer — Distributional Treatment Effects on Career Trajectories (Revised)

**Policy:** Tennessee Valley Authority (TVA), created 1933. Massive federal infrastructure investment that transformed an agricultural region. County-level treatment with ~125 TVA service area counties.

**Outcome:** Full career transition matrices from linked census panel (MLP v2.0, 10.85M males aged 18-65 linked across 1920-1930-1940). 576 life-state tokens (OCC × IND × MARST × NCHILD).

**Identification:** Four-adapter DiD in transformer representation space. Pre-train a national career transformer on all data (region-blind), then fine-tune 4 LoRA adapters on the 2×2 cells (Treatment/Control × Pre/Post) with temporal loss masking. Double-difference in weight space reveals the distributional treatment effect.

**Why it's novel:**
1. Standard DiD estimates E[Y(1)-Y(0)] — a scalar. This method recovers the full treatment effect on transition matrices — a high-dimensional object.
2. First paper to apply task vector arithmetic (Ilharco et al. 2023) to causal inference.
3. SVD of the weight-space DiD reveals the dimensionality and structure of the treatment effect — a new diagnostic.
4. The transformer captures non-Markov (history-dependent) treatment effects that standard Markov DiD cannot.
5. Builds on CAREER (Vafa et al. 2022) architecture but with causal identification.

**Feasibility check:**
- Variation: ~125 TVA counties vs comparable non-TVA counties, well above 20-unit threshold
- Data: MLP v2.0 already extracted and pre-trained (10.85M individuals, val loss 3.685)
- POC: All 5 synthetic validation tests pass (DGPs 1-4 in projects/did_transformer/)
- Literature: No existing paper combines transformers with DiD for distributional effects
- Comparison: Traditional county-level DiD with fixest replicates Kline & Moretti (2014) as sanity check

**Revision focus (paper_199):**
- Deepen exposition of parallel trends assumption in representation space
- Clarify identification strategy: theoretical justification for double-difference in weights
- Strengthen connection to structural economics (career choice models, migration)
- Expand heterogeneity analysis by occupation, race, and age cohorts
