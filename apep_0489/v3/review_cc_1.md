# Internal Review — Round 1 (Claude Code, Reviewer 2)

**Paper:** DiD-LLMs
**Date:** 2026-03-04
**Mode:** Internal review (harsh, skeptical)

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The identification strategy is a standard two-period DiD comparing TVA vs. non-TVA counties, using 1920→1930 as pre-treatment and 1930→1940 as post-treatment, with TVA established in 1933. This is credible and well-documented. The authors acknowledge that the design is simple (single treatment date, not staggered), which is appropriate.

**Concerns:**
- The control group includes non-TVA counties *within* TVA states, which could receive spillover effects. The paper addresses this with an alternative control group test (correlation 0.86), but the fact that effects are *larger* with the restrictive control group suggests some spillover contamination in the main results. This deserves more prominence.
- Treatment assignment is by 1920 county of residence (intent-to-treat), which is appropriate but means movers are misclassified. The paper acknowledges this correctly.
- The parallel trends test relies on a single pre-period (1920→1930 vs 1930→1940). With only one pre-period, the pre-trends test has low power. The paper acknowledges this limitation.

### 2. Inference and Statistical Validity

**This is the paper's primary weakness.** The bootstrap SEs are honestly reported, and the honesty is commendable. But the bottom line is that most of the paper's headline findings are statistically insignificant:

- Farm laborer stay-rate disruption: −1.9pp (SE 3.2) → t = 0.59, not significant
- Farm laborer → Operative: +0.5pp (SE 1.0) → t = 0.50, not significant
- Farm laborer → Craftsman: +0.5pp (SE 1.7) → t = 0.29, not significant
- Farmer → Manager: +0.3pp (SE 0.4) → t = 0.75, not significant
- Clerical stay rate: −2.5pp (SE 0.8) → t = 3.1, **significant**

Only the clerical stay-rate decline is statistically significant among the highlighted cells. The paper's narrative — Lewis channel, entrepreneurial channel, universal farmer avoidance — rests entirely on point estimates with confidence intervals that comfortably include zero. The abstract and introduction should be more upfront about this limitation.

The frequency benchmark provides an independent check with tighter SEs for some cells (farm laborer stay rate: −4.2pp, SE 0.6, t = 7.0), but the two estimators disagree substantially on many cells (e.g., farm laborer → farmer: +4.1pp frequency vs −0.4pp transformer). This disagreement is not adequately resolved.

### 3. Robustness and Alternative Explanations

The paper includes several robustness checks:
- Placebo test with opposite sign pattern (good)
- Alternative control group (correlation 0.86, good)
- LoRA rank sensitivity (0.74–0.86 correlation, adequate)
- Pre-trends analysis (MAE 0.0002, good)

**Missing:**
- No heterogeneity analysis by race (7.4% Black in TVA, 10.9% in control). The TVA era involved significant racial discrimination in hiring. Pooling races may mask important heterogeneity.
- No analysis of linkage rates by TVA/control status. If linkage is differential, this could bias the transition matrix.
- The weight-space SVD analysis (Section 6.5) is interesting but doesn't add to causal identification. It's unclear what economic insight "rank-1 treatment structure" provides beyond saying "something happened."

### 4. Contribution and Literature Positioning

The contribution is clear: extend DiD to the full transition matrix rather than scalar outcomes. This is genuinely novel and potentially valuable.

**Missing citations:**
- Dix-Carneiro & Kovak (2017) — trade shocks and worker transitions in Brazil (directly relevant transition-matrix approach)
- Traiberman (2019) — occupation transitions and trade policy
- Autor, Dorn & Hanson (2013) is cited in the conclusion but should appear in the introduction's literature discussion

### 5. Results Interpretation and Claim Calibration

The paper's narrative claims are not well-supported by the inference:
- "Farm laborers shifted into factory operative and craftsman roles at higher rates" (abstract) — but SEs include zero
- "distinct skill-match pathways" — economically intuitive but statistically imprecise
- "The clerical stay-rate disruption is statistically significant" — correct, but this is not the paper's main story

The paper is reasonably honest about this in the robustness section but still frames the abstract and introduction around point estimates as if they were precise.

### 6. Actionable Revision Requests

**Must-fix:**
1. Abstract should explicitly acknowledge that most individual cell estimates are imprecisely estimated. The current abstract says "County-cluster bootstrap standard errors (100 iterations)..." which sounds like the bootstrap confirms significance. It doesn't — it mostly shows insignificance.
2. Resolve the transformer-frequency divergence on the Farmer column more clearly. The current discussion is balanced but the disagreement is large and mostly unresolved.

**High-value:**
3. Add racial heterogeneity analysis (or acknowledge it as a limitation).
4. Report linkage rates by TVA/control status.
5. Consider foregrounding the frequency estimator results more, since they have tighter SEs for well-populated cells.

**Optional:**
6. The SVD weight-space analysis could move to the appendix — it's methodologically interesting but tangential to the economics.
7. Add Dix-Carneiro & Kovak (2017) and Traiberman (2019) to the literature review.

### 7. Overall Assessment

**Strengths:**
- Genuinely novel question: transition matrices as treatment effects
- Honest reporting of bootstrap SEs despite unflattering results
- Multiple estimation approaches (transformer + frequency) with transparent comparison
- Clean placebo test with opposite sign pattern
- Well-written, economics-first framing (much improved over prior version)

**Weaknesses:**
- Most headline findings are statistically insignificant
- Transformer and frequency estimators disagree substantially on key cells
- Only one pre-period limits pre-trends analysis
- No heterogeneity by race or linkage rate analysis

**Publishability:** The paper introduces a genuinely novel estimand (transition-matrix DiD) and demonstrates it on an important historical setting. The statistical imprecision is a real limitation, but the paper is largely honest about it. With minor revisions to better calibrate the abstract and introduction to the actual precision of the estimates, this could be a credible contribution to the methodology literature. It falls short of top-5 journal standards due to the inference limitations, but is competitive for a field journal (JoLE, JHR, JOLE, or AEJ:Applied).

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Foreground the frequency estimator.** The frequency benchmark has much tighter SEs for well-populated cells. Consider presenting it as the primary estimator for those cells, with the transformer as the smoother for sparse cells. This would strengthen the paper's credibility.

2. **Power calculation.** How large would the effects need to be for the bootstrap to detect them at 5%? This would contextualize whether the imprecision is a sample size issue or a method issue.

3. **Earnings linkage.** The conclusion mentions linking to earnings data as future work. Even rough earnings proxies (occupation-level median wages from the 1940 census) could quantify the welfare implications of the transition channels.

4. **Extension to women.** The sample is men only. A brief discussion of why (linkage difficulty for women who change names at marriage) and what the implications are would strengthen the paper.

5. **Bayesian shrinkage comparison.** The transformer effectively does hierarchical shrinkage. A direct comparison with a Bayesian multinomial model (e.g., Dirichlet-multinomial with hierarchical priors) would clarify the transformer's value-add over simpler shrinkage approaches.

---

DECISION: MINOR REVISION
