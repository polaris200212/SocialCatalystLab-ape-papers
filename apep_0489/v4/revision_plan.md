# Revision Plan — apep_0489 v4

## Core Conceptual Change

v3 bolted on a county-cluster bootstrap because reviewers asked "where are the standard errors?" Nobody stopped to ask whether standard errors are the right object. They aren't.

The 2.5 million linked men in TVA and control counties are not a sample from a superpopulation — they are essentially the universe of linkable men in these counties during these decades. The TVA happened once, to specific counties. There is no population parameter to do inference about. The transition matrix point estimates ARE the finding.

The bootstrap mixed together optimizer stochasticity (retraining neural networks gives different answers) and county resampling noise, then pretended the result was a confidence interval for a population parameter that doesn't exist. This was epistemologically confused.

## What Changes

### 1. Drop the bootstrap
- Remove Table 6 (bootstrap SEs for key cells)
- Remove Appendix E (full 12x12 bootstrap SE table)
- Remove Section 6.1 (County-Cluster Bootstrap)
- Remove Section 6.3 (FDR Correction)
- Remove all bootstrap references from abstract, intro, results, conclusion

### 2. New inference section: "Why Standard Inference Does Not Apply"
- Population vs sample: we observe the universe, not a draw
- The transformer adds estimation noise, but this is optimizer stochasticity, not sampling uncertainty
- The frequency benchmark provides model-free validation (no inference needed — it's a direct count)
- Randomization inference (permuting TVA assignment) is the principled design-based alternative for readers who want p-values
- Note: RI for the frequency estimator is computationally cheap and would give sharp null hypothesis tests

### 3. Reframe the contribution
- The advancement is the ESTIMAND: transition matrices as first-class treatment effects
- The transformer is one possible estimator; the frequency benchmark is another
- The paper introduces both the question ("who moves where?") and demonstrates that answering it is feasible
- De-emphasize the transformer as "the method" — it's a tool, not the contribution

### 4. Sharpen writing for economists
- Rewrite abstract from scratch — lead with the economics, not the method
- Rewrite introduction with hook, puzzle, finding, implication
- Make every sentence earn its place
- Active voice, specific numbers, vivid examples
- The paper should read like a Kline & Moretti follow-up that happens to use a transformer, not like a CS paper that happens to be about economics

### 5. Foreground the frequency benchmark
- Present frequency estimates alongside transformer throughout
- Where they agree = robust finding regardless of method
- Where they diverge = honest about what we know and don't know

## Execution Order

1. Rewrite paper.tex (one pass, comprehensive)
2. Compile and verify
3. Run review pipeline
4. Publish
