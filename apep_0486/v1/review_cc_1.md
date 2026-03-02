# Internal Review: review_cc_1.md

**Paper:** The Equity Paradox of Progressive Prosecution
**Reviewer:** Claude Code (Internal)
**Verdict:** Minor Revision

## Summary

This paper examines the causal effects of progressive district attorney elections on county jail populations, homicide rates, and racial disparities using a staggered DiD design with 25 treated counties. The main finding is that progressive DAs reduce jail rates by ~18% without increasing homicides, but widen the Black-to-White incarceration ratio. The paper is well-executed, clearly written, and contributes to an important policy debate.

## Strengths

1. **Novel and important finding:** The racial equity paradox — that reforms designed to help Black Americans disproportionately benefit White Americans — is genuinely interesting and policy-relevant.
2. **Comprehensive robustness:** Pre-COVID sample, leave-one-out, HonestDiD sensitivity, AAPI placebo, population weighting.
3. **Multiple identification strategies:** TWFE, CS-DiD, DDD, state×year FE.
4. **Clear writing:** The introduction is compelling and the paper flows well.
5. **Strong data infrastructure:** Four distinct data sources merged coherently.

## Concerns

### Major
1. **Identification with 25 treated units and ~3000 controls:** The asymmetry is extreme. The parallel trends assumption is doing heavy lifting — treated counties are vastly different from controls (urban vs rural, 1.9M vs 92K population). The paper should more directly address whether the "other counties" are a credible counterfactual or whether a matched control group would be more appropriate.

2. **TWFE vs CS-DiD divergence:** The TWFE gives -179, CS-DiD gives -406. The paper explains this as expected but the 2.3x difference is large. More discussion of which estimate is preferred and why would strengthen the paper.

### Minor
1. **Homicide data window is short (2019-2024).** Only 6 years with most treated counties having limited pre-treatment homicide observations. The paper acknowledges this but should be more cautious about strong causal claims on homicide.
2. **Table numbering mismatch:** The in-text table numbering (Table 1, 2, etc.) should be verified against actual compiled output.
3. **Missing Figure 3 (mechanism pretrial vs sentenced):** Referenced in code but not in paper text.
4. **Cost-benefit calculation uses the -105 TWFE estimate** but should clarify which specification this corresponds to.

## Recommendation

Proceed to external review. The paper is strong enough to benefit from detailed referee feedback. The main vulnerability is identification — the extreme treated/control asymmetry — but the robustness checks partially address this.
