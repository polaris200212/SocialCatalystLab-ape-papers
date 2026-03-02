# Internal Review - Claude Code (Round 1)

**Role:** Journal referee (Reviewer 2 — skeptical)
**Paper:** Going Up Alone: Automation, Trust, and the Disappearance of the Elevator Operator

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The paper uses three complementary empirical strategies: (a) synthetic control comparing New York to a data-driven counterfactual, (b) individual-level displacement analysis using linked census records, and (c) triple-difference combining occupation × state × time variation.

**Strengths:**
- SCM is appropriate for a single-treated-unit design with a well-defined pre-treatment period
- The paper honestly acknowledges that the event study shows non-parallel pre-trends and uses this to motivate SCM
- The data-frequency limitation (decennial census, treatment in 1945) is now explicitly discussed

**Weaknesses:**
- The single effective donor (DC weight = 1.000) is concerning. The synthetic New York IS Washington, D.C. This makes the SCM essentially a two-unit comparison, not a weighted combination of many donors. The permutation inference is valid but the p-value (0.056) is marginal.
- The claim-design alignment has improved but the paper still walks a fine line between what SCM identifies (NY relative to counterfactual) and broader interpretive claims about the strike's national effects.

### 2. Inference and Statistical Validity

- Standard errors are properly clustered at the state level throughout
- Permutation inference is used for SCM (appropriate)
- Sample sizes are coherently reported
- The displacement regressions with clustered SE show marginal significance (p = 0.059, 0.079) — the paper honestly reports these

### 3. Robustness

- Janitor placebo FAILS (significant coefficient), which the paper acknowledges
- Time placebo FAILS (significant coefficient), which the paper acknowledges
- The paper uses these failures to motivate SCM over simple DiD, which is defensible
- Triple-difference with R² = 0.995 has ~30 effective degrees of freedom — now explained

### 4. Contribution and Literature Positioning

- Clear differentiation from Feigenbaum & Gross (2024 QJE) on telephone operators
- Strong historical narrative contribution
- Individual-level transition analysis using MLP is novel

### 5. Results Interpretation

- The paradoxical finding (strike epicenter retained operators) is now interpreted carefully
- National spillover claims are appropriately hedged as interpretation/hypothesis

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **High-frequency data**: Even a few annual data points on elevator installations or permits would strengthen the timing argument
2. **Selection into linking**: The 46.7% linkage rate deserves more attention — are linked operators systematically different?
3. **Magnitudes**: Contextualizing the SCM gap (34.4 per 1,000 building service workers) in terms of actual worker counts would help readers grasp the magnitude

## DECISION

Overall a strong descriptive contribution with an interesting but methodologically limited causal analysis. The honest acknowledgment of limitations is appreciated.

DECISION: MINOR REVISION
