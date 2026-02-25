# Internal Review — Round 1

**Reviewer:** Claude Code (self-review)
**Paper:** Cash and Convergence: Banking Infrastructure, Demonetization, and the Leveling of India's Economic Geography
**Date:** 2026-02-25

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The continuous-treatment DiD design is well-motivated: a national shock (demonetization) with cross-sectional intensity variation (banking density). The event study shows clean pre-trends (2012-2014 coefficients near zero).
- The treatment variable (Census 2011 banking density) pre-dates demonetization by 5 years, avoiding reverse causality.
- The paper explicitly tests and discusses the parallel trends assumption.

**Weaknesses:**
- Banking density is correlated with development indicators (literacy, urbanization, agricultural share). The paper acknowledges this but the controlled specification (Column 2 of Table 3) shows the banking coefficient is fully absorbed by these controls. This weakens the causal interpretation — the paper is identifying a "development effect" more than a "banking effect."
- The paper appropriately flags this limitation but could be more precise about what the estimand is: the *differential* post-demonetization trajectory by banking density, not a causal effect of banking per se.

### 2. Inference and Statistical Validity

- Standard errors are clustered at the state level (35 clusters) — appropriate for India's administrative structure.
- Randomization inference with 100 permutations provides a second layer of inference. The (r+1)/(B+1) p-value convention is correctly implemented.
- Sample sizes are consistent across specifications (7,680 for the main panel).
- The main coefficient (-0.017, p=0.065) is marginally significant at conventional levels. The paper is honest about this.

### 3. Robustness and Alternative Explanations

- Placebo test (fake 2014 shock) yields null — good.
- Government-only bank measure strengthens the result — consistent with the mechanism story.
- Trimming outliers strengthens the result — reassuring.
- Pre-COVID sample yields similar results — addresses COVID confound.
- The urbanization channel test is the key finding: banking density is a proxy for formality.

### 4. Contribution and Literature Positioning

- The paper cites the core references (Chodorow-Reich et al. 2020, Chanda & Cook 2022, Burgess & Pande 2005, Henderson et al. 2012). Additional citations (Lahiri 2020, Aggarwal 2020, Karmakar & Narayanan 2020) strengthen the positioning.
- The "formality paradox" framing is novel and compelling.
- The contrast with Chodorow-Reich et al. (supply-side vs. demand-side) is well-drawn.

### 5. Results Interpretation

- The magnitude claims now correctly report ~8% for a 1-SD change.
- The balance table description now accurately describes the non-monotonic patterns.
- The paper is appropriately cautious about causal claims given the absorption by controls.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Must-Fix Issues
1. None remaining — statistical consistency issues resolved.

### High-Value Improvements
1. **Spatial heterogeneity map**: A chloropleth map of banking density would ground the geography story.
2. **Formal Bonferroni/FDR correction**: With multiple subgroup comparisons, multiple hypothesis testing adjustment would strengthen inference.
3. **Callaway-Sant'Anna estimator**: Though this is a continuous-treatment, single-event design (not staggered), discussing why CS-DiD is not needed would preempt referee concerns.

### Optional Polish
1. Clean up snake_case variable names in etable output (partially addressed with fixest dict).
2. Consider adding standard deviations to balance table.

---

## OVERALL ASSESSMENT

**Key strengths:** Novel framing, clean pre-trends, honest about limitations, excellent prose quality.

**Key weaknesses:** Marginal statistical significance on main result (p=0.065), banking effect fully absorbed by controls.

**Publishability:** Strong working paper. The "formality paradox" insight and the urbanization decomposition are the real contributions.

DECISION: MINOR REVISION
