# Internal Review — Reviewer 2 (Harsh Skeptic)

**Paper:** Who Moved Where? Occupation Transition Matrices as Treatment Effects
**Version:** v4 (revision of apep_0489_v3)
**Decision:** MINOR REVISION

## Summary

This revision is a substantial conceptual improvement over v3. The paper now correctly identifies the bootstrap as epistemologically confused — these are population quantities from the near-universe of linkable men, not sample statistics. The inference framework section is honest and well-reasoned. The reframing around the estimand (transition matrices as treatment effects) rather than the method (transformer) is exactly right.

## Strengths

1. **Conceptual clarity.** The inference framework section (6.1) is the strongest part of the paper. Distinguishing optimizer stochasticity from sampling uncertainty is a genuine insight. The discussion of randomization inference as the principled alternative is appropriately brief and forward-looking.

2. **Economics-first framing.** The abstract now leads with what TVA did to workers, not with how many parameters the transformer has. The Blount County hook in the introduction is vivid.

3. **Frequency benchmark foregrounded.** Presenting the model-free estimator alongside the transformer throughout makes the findings robust to method choice.

4. **Clean prose.** Active voice, specific numbers, minimal throat-clearing. The conclusion reframes rather than summarizes.

## Concerns

1. **Single pre-period.** The paper has one pre-treatment period (1920→1930). This is inherent to the data but should be acknowledged more prominently as a limitation of the identification strategy, not just the placebo test.

2. **Population-weighted aggregation.** The Δπ_k formula aggregating across origin occupations should receive more discussion — how sensitive are the aggregate findings to the weighting scheme?

3. **"Near-universe" qualifier.** The paper says 2.5M is the "near-universe" of linkable men. How near? What fraction of the actual male population in these counties is this? If it's 60%, the population-quantities argument is weaker than if it's 95%.

## Minor

- The transition from Section 5 (Results) to Section 6 (Robustness) could be smoother.
- Consider noting that the frequency benchmark's agreement with the transformer is itself a finding — it implies the transformer is measuring a real object, not hallucinating patterns.

## Verdict

The v4 rewrite addresses the fundamental conceptual problems of v3. The paper is now honest about what it knows and what it doesn't. Minor revisions to acknowledge the single-pre-period limitation more prominently and quantify the "near-universe" coverage would strengthen it further.
