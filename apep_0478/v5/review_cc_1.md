# Internal Review - Claude Code (Round 1)

**Role:** Internal reviewer (Reviewer 2 mode)
**Paper:** Going Up Alone: The Lifecycle and Unequal Decline of the American Elevator Operator
**Timestamp:** 2026-03-01T08:40:00

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The paper is primarily descriptive — it traces the lifecycle of an occupation through census data and newspaper records. The identification strategy is a comparison of elevator operators to other building service workers (janitors, porters, guards) using a linked census panel (1940-1950). This is reasonable for a descriptive paper, though the comparison group selection deserves scrutiny.

**Strengths:**
- The linked panel (MLP v2.0) provides individual-level tracking, which is rare for this period
- The comparison group (building service workers) shares employer type and workplace, controlling for many unobservables
- IPW analysis addresses linkage selection bias

**Concerns:**
- The comparison group conflates janitors, porters, and guards — these have very different labor market dynamics. Sensitivity to individual comparison occupations should be shown.
- The 84% exit rate is presented as high but acknowledged to be similar to comparison workers (82.3%). The 2.4pp difference is modest — the story is about *where* people go, not *whether* they leave.

### 2. Inference and Statistical Validity

- Standard errors are clustered at the state level — appropriate given state-level policy variation.
- IPW analysis is a good robustness check for linkage selection.
- Sample sizes are reported and coherent (38,562 operators, 374,317 comparison).
- The SCM in the appendix has a very small donor pool (9 states) and limited pre-treatment periods (4 decennial observations). This limits the credibility of the SCM inference.

### 3. Robustness and Alternative Explanations

- The newspaper analysis is now backed by data (7,458 classified articles, corpus normalization).
- The keyword classifier validation is transparent about its limitations.
- The heterogeneity analysis by race, sex, and city is valuable.
- **Missing:** No formal test of whether the comparison group experienced parallel trends in the pre-treatment period.

### 4. Contribution and Literature Positioning

The paper contributes to:
- Economics of automation (Acemoglu & Restrepo 2020, Autor 2015)
- Historical labor markets (Goldin & Katz)
- Racial inequality in occupational displacement

The literature review is adequate. The newspaper analysis is now a genuine empirical contribution, distinguishing this from a pure census descriptive study.

### 5. Results Interpretation

- The "84% exit" finding is correctly calibrated — it's the differential outcomes by race that carry the story.
- The newspaper section appropriately hedges timing claims.
- The SCM results in the appendix should be more clearly framed as suggestive rather than causal.

### 6. Actionable Revision Requests

**Must-fix:**
1. None remaining — previous fatal errors have been addressed.

**High-value improvements:**
1. Show sensitivity of main results to individual comparison occupations (janitors only vs. porters only vs. guards only).
2. Add mean of dependent variable to regression tables for interpretability.
3. Clean variable labels in regression tables (replace code names with readable labels).

**Optional:**
1. Consider promoting SCM to main text with stronger caveats.
2. Add transition between newspaper section and data section.

### 7. Overall Assessment

**Strengths:** Ambitious scope covering the full lifecycle of an occupation; novel newspaper analysis with corpus normalization and geographic variation; careful linked-panel analysis with IPW robustness; compelling racial channeling results.

**Weaknesses:** SCM evidence is thin (small donor pool); comparison group heterogeneity not explored; some exhibit redundancy.

DECISION: MINOR REVISION
