# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (Reviewer 2 mode + Editor mode)
**Paper:** Missing Men, Rising Women: WWII Mobilization and the Paradox of Gender Convergence
**Date:** 2026-02-27

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:** The paper is commendably honest about identification challenges. The state-level first-difference design is straightforward and transparent. The individual-level triple-difference (female × post × mobilization) provides a useful complement. The CenSoc Army Enlistment Records offer a novel measure of mobilization intensity.

**Concerns:**

1. **Endogeneity of mobilization (CRITICAL).** The balance test rejects conditional exogeneity (F = 2.6, p = 0.031). The Oster δ of −0.37 falls well below the robustness threshold of 1. The paper acknowledges this honestly, but the implication is that the main coefficient is not credibly causal. The sign reversal upon adding controls (from ~0 to −0.0073) is itself evidence of confounding, not of a hidden treatment effect. The paper should more explicitly frame results as descriptive/conditional correlations rather than causal effects.

2. **Individual-level pre-trend is significant (SERIOUS).** The female × pre × mobilization coefficient for 1930–1940 is −0.304 (p < 0.01), which is comparable in magnitude to the main triple-difference estimate (−0.284). This is a serious threat to the parallel trends assumption. The paper discusses it but could do more to address it—e.g., event-study-style analysis with the 1930 period or difference-in-differences-in-differences that explicitly nets out the pre-trend.

3. **N = 49 treated units.** The state-level analysis has only 49 observations. With 6 controls, degrees of freedom are limited. The bootstrap is appropriate but the CI barely includes zero at the upper bound.

### 2. Inference and Statistical Validity

- Standard errors are clustered at the state level (appropriate).
- Bootstrap CI reported ([-0.012, 0.000]) — the upper bound touches zero, reinforcing the borderline nature of the result.
- Sample sizes are consistent across specifications (49 states; 1,686,447 individuals).
- The occ_score sample attrition (1,027,280) is well-explained.

### 3. Robustness and Alternative Explanations

- Nine robustness checks are thorough and honest.
- The quintile specification confirms a monotonic gradient (Q5 = −0.0208**).
- The placebo on women 50+ is clean (0.007, insignificant).
- The paper honestly reports where robustness fails (Oster, balance test).
- **Missing check:** Randomization inference (permutation test) would strengthen inference with N = 49.

### 4. Contribution and Literature Positioning

- Well-positioned against Acemoglu, Autor & Lyle (2004) and Goldin (1991).
- The Rose (2018) discussion is excellent.
- The veteran displacement channel (GI Bill, seniority provisions) is a genuine contribution.
- **Missing citations:** Bound & Turner (2002) on the GI Bill's labor market effects; Goldin & Olivetti (2013) on WWII and women's economic advancement.

### 5. Results Interpretation and Claim Calibration

- The paper correctly calibrates claims as conditional rather than definitive.
- The sign reversal narrative is compelling but the paper could be clearer that "conditioning reveals" does not equal "causal."
- The discussion of the positive state-level occ score (+0.148) vs negative individual-level triple-diff (−1.977) is now well-explained via composition effects.

### 6. Actionable Revision Requests

**Must-fix:**
1. Add randomization inference (permutation of mobilization across states, 1000+ draws) to validate the p-value from the state-level regression.
2. Strengthen the framing around identification limitations — the paper is honest but could be clearer that results are best interpreted as conditional associations.

**High-value:**
3. Add Goldin & Olivetti (2013) and Bound & Turner (2002) to the literature review.
4. Consider a "bounding" exercise that accounts for the significant individual-level pre-trend (e.g., subtract the pre-trend from the post-treatment estimate).

**Optional:**
5. The comparison with Acemoglu et al. (2004) in the appendix (Table A11) could be promoted to the main text.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Randomization inference** would be the single highest-value addition. With N = 49, asymptotic inference is uncertain. A permutation test showing where the actual coefficient falls in the null distribution would be compelling.

2. **Pre-trend adjustment.** Given the significant individual-level pre-trend (−0.304), consider reporting a "bias-adjusted" triple-difference estimate that accounts for differential pre-trends. This could follow Rambachan & Roth (2023) or a simpler approach of subtracting the pre-trend magnitude.

3. **Promote Table A11** to the main text — the comparison of estimation approaches is central to the paper's contribution.

4. The paper would benefit from a brief discussion of how the CenSoc Army mobilization measure correlates with the Acemoglu et al. (2004) Selective Service measure. Even without the Selective Service data, noting the expected correlation and discussing differences in coverage would strengthen the data section.

---

## 7. Overall Assessment

**Key strengths:**
- Honest and transparent about identification challenges
- Novel data (CenSoc enlistment records)
- Compelling veteran displacement narrative
- Thorough robustness battery
- Well-written prose with a strong narrative arc

**Critical weaknesses:**
- Failed balance test and low Oster δ undermine causal claims
- Significant individual-level pre-trend (−0.304) comparable to main effect
- N = 49 for the primary specification
- Missing randomization inference

**Publishability:** The paper is a solid working paper with a novel finding and transparent methodology. It would benefit from randomization inference and a more careful framing of results as "conditional" rather than "causal." With these revisions, it is publishable in AEJ: Economic Policy or a strong field journal. The identification challenges are real but the paper's honesty about them is itself a contribution.

DECISION: MINOR REVISION
