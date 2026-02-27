# Internal Review — Round 1

**Paper:** Downtown for Sale? Commercial Displacement Effects of France's Action Cœur de Ville Program
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-27
**Verdict:** CONDITIONALLY ACCEPT (Minor Revision)

---

## Summary

This paper evaluates France's €5 billion Action Cœur de Ville (ACV) program using the universe of French business establishments from the Sirene registry (2010–2024). A difference-in-differences design compares 244 ACV communes to 58 matched controls. The main finding is a precisely estimated null: ACV designation had no statistically significant effect on downtown-facing establishment creations (β = −0.040, SE = 0.039, p = 0.31). The null is robust to randomization inference (p = 0.46), leave-one-out analysis, donut specifications, and placebo sector tests.

## Strengths

1. **Well-identified null result.** The single-cohort design (all 222 cities announced simultaneously) eliminates staggered DiD bias concerns. The 24 pre-treatment quarters provide extensive evidence of parallel trends. The null is not an artifact of noisy data — the RI p-value of 0.46 places the estimate squarely in the center of the permutation distribution.

2. **Strong placebo validation.** The wholesale sector placebo (β = 0.003, p = 0.76) confirms that the identification strategy does not generate spurious effects, lending credibility to the null on downtown sectors.

3. **Policy relevance.** This is the first causal evaluation of ACV, addressing a knowledge gap explicitly identified by the Cour des Comptes (2022). The null finding is policy-relevant: €5 billion in coordinated investment did not generate measurable commercial entry.

4. **Conceptual framework.** The new Section 3 formalizes how ACV might affect entry through demand enhancement, cost reduction, and coordination channels, and generates testable predictions that the empirical analysis addresses.

5. **Honest framing.** The paper does not oversell the null. The discussion of candidate explanations (structural headwinds, intensive margin, resource dilution, selection effects) is balanced and measured.

## Weaknesses and Suggestions

1. **Control group construction.** The paper mentions propensity-score matching on pre-treatment characteristics but the matched sample has only 58 control communes — an unusual 4:1 treatment-to-control ratio. More discussion of why so few controls survived matching and whether results are sensitive to matching choices would strengthen the paper.

2. **Intensive margin.** The paper acknowledges this limitation but could be more explicit about what ACV might have achieved on margins not measured (existing business survival, employment, property values). A brief power calculation showing the MDE given the sample size would help readers assess how large an effect could have been detected.

3. **Table 3 formatting.** Column headers are slightly clipped on the right margin. The variable names could be cleaner for presentation.

4. **HonestDiD sensitivity.** The paper mentions implementing Rambachan-Roth (2023) sensitivity analysis but does not report the results or present a sensitivity plot. Either report the bounds or remove the reference.

5. **CS equivalence claim.** The paper states that TWFE and CS are equivalent in single-cohort settings. This should cite Goodman-Bacon (2021) directly for the decomposition result.

## Minor Issues

- The acknowledgements section has placeholder text (@CONTRIBUTOR_GITHUB) — will need to be replaced at publish time.
- The "confirms statistical significance" language in Section 7.4 appears to be a drafting error — this is a null result. [FIXED in revision]

## Verdict

The paper presents a credible, well-executed null result on an important policy question. The identification strategy is clean, the robustness battery is thorough, and the framing is honest. The main suggestions are expositional improvements (control group discussion, MDE calculation, HonestDiD results). This merits publication as a well-identified null with real policy implications.

**Decision: CONDITIONALLY ACCEPT — Minor revisions recommended.**
