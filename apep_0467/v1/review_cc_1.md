# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Priced Out of Care: Medicaid Wage Competitiveness and the Fragility of Home Care Workforce Supply
**Date:** 2026-02-26

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The continuous treatment DiD using pre-determined (2019) wage ratios is clever and avoids endogeneity concerns from contemporaneous policy changes.
- COVID as the exogenous shock is well-motivated — it affected all states simultaneously but the wage ratio determines differential exposure.
- The monopsony framework provides clear theoretical grounding for why wage competitiveness matters.

**Concerns:**
- The core identifying assumption is that pre-2019 wage ratios are uncorrelated with post-COVID provider supply trajectories conditional on state and month FE. The marginally significant pre-trend (p=0.08) raises questions about this assumption.
- The wage ratio is a function of both the numerator (PCA wage) and denominator (competing wages). Changes in competing industries' wages could confound the results if they are correlated with COVID impact.
- Treatment is continuous and cross-sectional — no within-state variation over time in the treatment variable. This means all identification comes from cross-state comparisons in the post period relative to the pre period.

### 2. Inference and Statistical Validity

- Standard errors clustered at state level (51 clusters) — appropriate but on the lower end for reliable cluster-robust inference.
- Randomization inference (p=0.006) provides strong evidence beyond cluster-robust SEs.
- Wild cluster bootstrap attempted — would strengthen inference with 51 clusters if fwildclusterboot were available.
- Sample sizes consistent at N=4,233 across all main specifications.

### 3. Robustness and Alternative Explanations

- Region × month FE specification is convincing.
- No-lockdown specification appropriately addresses acute disruption.
- Tercile specification provides non-parametric check.
- Wage level specification confirms ratio is not driving results mechanically.
- BH placebo is well-chosen — telehealth-eligible providers as control.
- LOO analysis reassuring — no single state drives results.

**Concerns:**
- The pre-trend test result (p=0.08) should be addressed more thoroughly. Consider Rambachan and Roth (2023) honest confidence intervals to bound the effect under plausible trend violations.
- Missing: Bacon decomposition or similar diagnostic for potential heterogeneity in treatment timing effects.
- The ARPA result is interesting but the mechanism (why wage-competitive states benefit more from ARPA) deserves deeper exploration.

### 4. Contribution and Literature Positioning

- Clear contribution to monopsony literature (Manning 2003, Azar et al 2022, Berger et al 2022).
- Good connection to Staiger et al (2010) nurse supply elasticity.
- Could benefit from citing Clemens and Strain (2021) on low-wage labor market dynamics during COVID.
- Literature positioning is adequate for the claims made.

### 5. Results Interpretation

- Main effect magnitude is reasonable: 1-SD wage ratio difference → ~10% provider difference.
- Organizational vs sole proprietor heterogeneity is well-interpreted.
- ARPA finding is suggestive but the claim about "infrastructure absorption" could be moderated.
- The spending result (not significant) is appropriately hedged in the text.

### 6. Actionable Revision Requests

**Must-fix:**
1. Address the pre-trend more robustly — Rambachan-Roth or similar sensitivity analysis.

**High-value improvements:**
2. Rescale COVID cases variable to per 10,000 to eliminate scientific notation in tables.
3. Consider adding a Bacon-style decomposition diagnostic.
4. Explore mechanisms behind the ARPA differential effect.

**Optional polish:**
5. Consider promoting the cross-sectional scatter to main text for intuition.

## PART 2: CONSTRUCTIVE SUGGESTIONS

The paper is well-executed with a clear question and credible design. The main risk is the pre-trend, which should be addressed with formal sensitivity analysis. The monopsony framing is compelling and the ARPA extension adds policy relevance. With the pre-trend addressed, this is a solid AEJ: Economic Policy paper.

## DECISION

Key strengths: Novel use of COVID as monopsony stress test, clean continuous treatment, strong RI evidence.
Critical weaknesses: Marginally significant pre-trend, 51 clusters.
Publishability: Ready for submission after minor revisions.

DECISION: MINOR REVISION
