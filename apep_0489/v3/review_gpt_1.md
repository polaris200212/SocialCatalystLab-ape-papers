# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-03-04T01:28:16.658483
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 18983 in / 4691 out
**Response SHA256:** a55e35e4229e3bc6

---

## Summary / overall impression

The paper proposes an interesting and potentially useful estimand—cell-by-cell DiD effects on an occupation transition matrix—and applies it to linked US census records around the TVA (1920–1940). The paper is unusually transparent about imprecision in many cells and provides a model-free frequency benchmark.

However, in its current form the paper is not yet publication-ready for a top general-interest journal because (i) the causal design faces major unresolved threats (especially geography/composition/migration and Depression-related differential trends) that are not convincingly addressed with only one pre-period, (ii) the main “transformer DiD” estimator’s estimand is not clearly aligned with the frequency/DiD object and risks baking in smoothing/regularization that is hard to interpret causally, and (iii) the inference strategy is not yet strong enough (bootstrap design, number of draws, and randomization/permutation alternatives) to support the causal and “matrix anatomy” claims.

I think the core idea is promising and salvageable, but it needs substantial redesign/strengthening of identification and inference, plus a clearer, more standard econometric baseline.

---

# 1. Identification and empirical design (critical)

### 1.1. Core DiD design: only one pre-period transition is a serious limitation
You use 1920→1930 as “pre” and 1930→1940 as “post” (Sections 1, 5). With only **one** pre transition, your ability to diagnose parallel trends is limited. The “pre-trends MAE” diagnostic (Section 4.1) is essentially a *baseline difference in transition matrices*, not an assessment of *trend similarity over multiple pre periods*. This is not sufficient to rule out differential trend shocks emerging after 1930.

**Why it matters:** TVA begins in 1933, but the 1930→1940 decade includes the deepest part of the Great Depression and major agricultural shocks. Differential exposure of TVA counties to Depression-era agricultural collapse could produce transition changes even absent TVA. With only one pre period, this remains a first-order threat.

**Concrete fixes:**
- Extend the linked panel backward if feasible (1910–1920–1930–1940) as you note in the Conclusion. Even if linkage quality is lower, having **two** pre transitions would materially strengthen credibility.
- If that is infeasible, you need stronger quasi-experimental structure: e.g., *border-county designs* (TVA vs adjacent non-TVA counties), watershed discontinuities, or matched controls with transparent balancing on pre-1930 county characteristics and outcomes.

### 1.2. Treatment assignment and migration: ITT by 1920 county is not enough without bounding / decomposition
Treatment is assigned by 1920 county (Section 3.1). Yet many individuals may move across counties between 1920 and 1940, potentially differentially by treatment. You acknowledge this (Conclusion; Section 6.6), but do not quantify it or show whether migration differs by treatment group.

**Why it matters:** If TVA increases migration into/out of TVA counties, the observed “transition probabilities” in 1930→1940 reflect both occupational mobility and selective migration/selection into being observed in TVA counties in later censuses (even though treatment is defined by baseline county). In linked data, selection into being linkable is also correlated with mobility.

**Concrete fixes:**
- Report migration rates by treatment status (e.g., fraction leaving baseline county/state between 1920–1930 and 1930–1940), and show how much they differ.
- Decompose transitions into “within-county stayers” vs “movers” (even if movers are selected): do effects load on mover status?
- Provide partial-identification bounds or sensitivity analysis for differential attrition/linkage and migration (e.g., Lee bounds-style monotonicity under “TVA increases mobility and reduces linkage”).

### 1.3. Control group validity and spillovers: needs a more formal argument
You include (i) non-TVA counties within TVA states and (ii) counties in 9 additional states (Section 3.1). You later run a restricted control group excluding TVA-region states and get larger effects (Section 6.7).

**Why it matters:** This pattern is consistent with spillovers/contamination in the baseline control group. But it also suggests high sensitivity to control definition; correlation 0.86 is not a small change in a 144-cell object, and some key highlighted patterns (e.g., “uniform farmer avoidance”) may be control-driven.

**Concrete fixes:**
- Make the restrictive control group (non-TVA states only) the **primary** specification or co-primary, with a clear justification for why those states provide a better counterfactual.
- Consider county-pair matching or synthetic control weighting at the county level based on 1920 characteristics and 1920→1930 transitions (pre-period outcomes).
- Explicitly address possible “partial treatment” in nearby non-TVA counties (electricity diffusion, labor market spillovers). A spatial spillover analysis (effects vs distance to TVA infrastructure) would help.

### 1.4. Depression and agricultural shocks are not adequately addressed
The paper notes differential Depression impacts as a threat (Section 5.4) but does not do much with it.

**Concrete fixes:**
- Add controls or stratification for baseline agricultural dependence, cotton share, farm tenancy, or other county characteristics that predict Depression severity; then show whether estimated matrix effects persist within strata.
- Run placebo “treatments” on pre-1930 periods if you can extend data, or run placebo outcomes less directly tied to Depression agriculture shocks.

### 1.5. The transformer estimator changes the estimand in ways that blur causal interpretation
You state the transformer “conditions on the full life-state token…effectively controlling for within-occupation composition differences” (Section 4.5, 5.2). But the causal estimand in Section 5.1 is written as \(P(s_{t+1}=k \mid s_t=j, D, \text{period})\), i.e., conditional only on occupation \(j\). The transformer effectively targets something closer to:
\[
E_{x \mid s_t=j, D, \text{period}}[P(s_{t+1}=k \mid s_t=j, x, D, \text{period})]
\]
with a complex, model-implied \(P(\cdot)\), and then you aggregate tokens to occupations with **equal token weighting** (Section 6.7), which is not the population distribution.

**Why it matters:** It becomes unclear whether the transformer DiD is estimating the same causal object as the frequency DiD (which is a transparent row-normalized transition probability). Differences between the two are not just “bias vs variance”; they may be different estimands.

**Concrete fixes:**
- Define *explicitly* the transformer estimand: what distribution over tokens is being averaged? equal-token vs population-token weighting? conditional on what covariates?
- Make population-weighted aggregation (by token prevalence in a fixed reference distribution, e.g., pooled 1920) the main aggregation; report equal-token as a robustness check.
- Provide a “traditional econometric” conditional model (e.g., multinomial logit / multinomial probit / flexible ML) that conditions on the same covariates and produces a clearly defined marginal transition effect, to triangulate the transformer.

---

# 2. Inference and statistical validity (critical)

### 2.1. Bootstrap design and number of iterations are not adequate for a high-dimensional object + multiple testing
You use a county-cluster bootstrap with **100 iterations** for the full transformer pipeline (Section 6.1; Appendix E). For a 144-cell matrix plus BH-FDR, this is thin.

**Why it matters:**
- With 100 draws, SEs and tail quantiles (95% CIs) are noisy; p-values below 0.05 are not stable.
- For BH-FDR, you need reasonably accurate p-values across many hypotheses; 100 bootstrap draws cannot support this well.

**Concrete fixes:**
- Increase to at least 500 (preferably 1,000) bootstrap replications if you will present cell-level inference and FDR.
- Report Monte Carlo error of SEs / CIs (or show stability as bootstrap draws increase).
- Consider a **multiplier/bootstrap** approach that avoids retraining the neural nets each time (if feasible) or a computationally cheaper approximation that can scale to many draws. But then you must validate that approximation against full retraining.

### 2.2. For TWFE, 16 state clusters is too few; you need small-cluster robust inference
You correctly caution readers (Table 5 notes), but then still use the p-value (0.012) substantively.

**Concrete fixes:**
- Use wild cluster bootstrap (Rademacher/Webb weights) at the state level, report bootstrap p-values and CIs.
- Alternatively, cluster at the county level if the panel is county-year and treatment varies at county level (but note serial correlation; with only 3 periods, this is unusual but still more clusters). If you keep state clustering for spatial correlation, do wild cluster.

### 2.3. The frequency estimator inference seems more credible than the transformer inference—lean into it
You provide county-cluster bootstrap SEs for frequency cells (200 iterations) and find sharp significance for some key cells (Section 4.5). By contrast, transformer SEs are very large for many highlighted cells (Table 6; Appendix E). At present, the most defensible causal statements appear to be those supported by the frequency DiD in high-support cells.

**Concrete fixes:**
- Reframe the transformer as a *smoother / imputer* whose role is to propose patterns in sparse cells, not as the main inferential object, unless you can substantially improve inference quality.
- In sparse cells, consider hierarchical Bayes/shrinkage with transparent likelihoods (Dirichlet-multinomial transition models) as an alternative smoother with well-defined uncertainty.

### 2.4. Multiple testing: BH-FDR on “|estimate|/SE” z-scores from bootstrap is not ideal
Section 6.3 describes using \(z = |\hat\Delta|/SE\). That’s not a bootstrap p-value; it is an asymptotic normal approximation using bootstrap SEs. With heavy-tailed bootstrap distributions (likely with re-training noise), this can misstate significance.

**Concrete fixes:**
- Compute p-values directly from the bootstrap distribution (percentile or studentized bootstrap), then apply BH-FDR to those p-values.
- Report how many hypotheses survive FDR at 10% and 5%, and whether those are robust to alternative bootstrap methods.

### 2.5. Coherence checks: transition matrices should satisfy probability constraints
It is not shown whether (i) each row of each group×period transition matrix sums to 1, (ii) the DiD rows necessarily sum to 0, and how aggregation affects these constraints. This matters for interpretation: some reported “column sums” and “total increases” appear to treat cells as additively meaningful across rows.

**Concrete fixes:**
- Provide explicit constraint diagnostics: row sums pre/post and after aggregation; if you renormalize, state it.
- Avoid interpreting sums across heterogeneous source rows as “total increases” unless they are properly weighted by source occupation prevalence.

---

# 3. Robustness and alternative explanations

### 3.1. Placebo test is suggestive but not a strong falsification
Your placebo splits non-TVA individuals into pseudo-treated/control by state (Section 6.2). This is not a sharp placebo for TVA assignment because the real assignment is geographic and correlated with watershed/economic structure; state splits generate different composition shifts.

**Concrete fixes:**
- Use permutation/randomization inference that mirrors assignment: e.g., randomly assign “treated” status to a set of counties matched on baseline characteristics, or permute treatment labels within state or within matched sets, recompute matrix effects, and compare to the observed statistic (e.g., farmer-column norm, agriculture-destination weighted change).
- Use border discontinuities: treat counties just inside TVA boundary as treated and adjacent just outside as controls; placebo by shifting the boundary.

### 3.2. Mechanism claims exceed what is statistically supported
The “Lewis channel” and “entrepreneurial channel” narratives (Section 4.3–4.4) are plausible, but your own bootstrap table (Table 6) shows farm labor→operative and farm labor→craftsman are not distinguishable from zero in the transformer estimates, while the frequency estimates show a different pattern (farm labor→farmer positive; laborer→operative positive).

**Concrete fix:** Calibrate the mechanism discussion to cells that are robust across estimators and have support/precision. Where evidence is mixed, present mechanisms as hypotheses.

### 3.3. External validity and population interpretation are limited by linkage
You note linkage selection (Section 6.6). The argument that bias is “toward zero” is plausible but not guaranteed: differential linkage could also change composition in ways that alter transition probabilities non-monotonically.

**Concrete fixes:**
- Report linkage rates by county type if possible (or proxy via MLP match quality scores).
- Reweight observations by inverse estimated linkage propensity to test sensitivity (at least a simple robustness).

---

# 4. Contribution and literature positioning

### 4.1. Clear contribution: transition-matrix treatment effects are interesting; the transformer angle is currently the weak link
The transition matrix DiD object is a nice contribution and could be publishable if executed with standard tools and strong identification. The “transformer + LoRA adapters” approach is innovative but currently reads as an engineering solution to sparsity with difficult-to-interpret statistical properties.

### 4.2. Missing/underused relevant methodological literatures
You cite DiD and ML for causal inference broadly, but the paper should engage more directly with:
- **Partial identification / sensitivity in DiD:** Rambachan & Roth (2023) style sensitivity to violations of parallel trends (you cite Roth 2023; consider adding explicit sensitivity analysis).
- **Modern DiD diagnostics / pretrend tests:** even in 2×2, show robustness to alternative specifications and discuss low power.
- **Mobility / transition matrix estimation with shrinkage:** Dirichlet-multinomial, empirical Bayes smoothing, hierarchical models for transition matrices.
- **Randomization inference / permutation tests for cluster settings** (especially given few clusters in TWFE and complex ML estimator).

Concrete citations to consider adding (illustrative; not exhaustive):
- Rambachan, A. & Roth, J. (2023), “A More Credible Approach to Parallel Trends,” *ReStud* (or working paper versions depending on exact year).
- MacKinnon & Webb (wild cluster bootstrap guidance for few clusters).
- Literature on estimating Markov transition matrices with Bayesian/shrinkage methods (statistics/econometrics crossover) to provide a transparent alternative to the transformer for sparsity.

---

# 5. Results interpretation and claim calibration

### 5.1. Several highlighted qualitative conclusions rely on imprecise or estimator-sensitive cells
Examples:
- “Farm laborers shifted into operative and craftsman roles (+0.5pp each)” (Abstract; Section 4.3) is not supported with transformer inference (Table 6 CIs include negative values).
- “Workers across the occupation structure stopped entering agriculture” (Abstract; Conclusion) is strongly estimator-dependent; frequency matrix has positive farmer entry for some sources (Table 4), including a large farm labor→farmer increase.

**Concrete fix:** Reframe the headline around what is robust:
- Robust finding: **farm labor stay-rate declines** (strong in frequency estimator; weaker/uncertain in transformer but same sign).
- Aggregate TWFE: agriculture share declines modestly in linked sample (with correct few-cluster inference).
Everything else should be clearly labeled exploratory.

### 5.2. Summing matrix entries across rows/columns needs careful weighting and interpretation
Statements like “total increase in manager-entry transitions … is 5.3pp” (Section 4.3) and comparisons of sums across columns are not population quantities unless weighted by the distribution of source occupations and conditioned on row sizes.

**Concrete fix:** Always present population-weighted implied destination share changes as the main aggregate mapping, with uncertainty (delta method/bootstrap).

---

# 6. Actionable revision requests (prioritized)

## 1) Must-fix issues before acceptance

1. **Strengthen identification beyond single pre-period DiD**
   - **Why:** Current parallel-trends support is insufficient; Depression-era differential shocks are a major confound.
   - **Fix:** Add another pre period (ideally 1910–1920–1930–1940) or adopt a design with sharper counterfactual validity (border counties, matched/synthetic controls on pre transitions and baseline covariates).

2. **Repair inference: increase bootstrap draws; use correct bootstrap p-values; address few-cluster TWFE**
   - **Why:** With 100 transformer bootstraps and asymptotic z-scores, cell-level inference and BH-FDR are not reliable; TWFE p-values with 16 clusters are not reliable.
   - **Fix:** ≥500 bootstraps (or validated alternative), bootstrap-based p-values for each cell, BH-FDR on those p-values, and wild cluster bootstrap for TWFE.

3. **Clarify and align estimands: frequency DiD vs transformer DiD**
   - **Why:** Currently they are different objects due to token conditioning and equal-token aggregation.
   - **Fix:** Define the transformer estimand formally; make population-weighted aggregation primary; add a standard conditional multinomial model baseline that targets the same marginal transition object.

4. **Quantify migration and linkage selection; show sensitivity**
   - **Why:** Mobility/linkage is central in linked census data; could drive apparent transition changes.
   - **Fix:** Report migration rates by group/period; stratify results by mover/stayer if possible; reweight by linkage propensity or provide bounding/sensitivity.

## 2) High-value improvements

5. **Introduce transparent shrinkage alternatives to the transformer for sparse transitions**
   - **Why:** A hierarchical Dirichlet-multinomial or empirical Bayes transition model could deliver smoothing + uncertainty with clearer statistical meaning.
   - **Fix:** Add a Bayesian/hierarchical transition-matrix estimator as an intermediate benchmark between raw frequencies and transformer.

6. **Stronger placebo/permutation tests that mirror TVA assignment**
   - **Why:** Current placebo split-by-state is not assignment-like.
   - **Fix:** Permute treated counties within matched strata; randomization inference on a scalar summary (e.g., weighted farmer-destination decline).

7. **Recalibrate mechanisms and headline claims to what is statistically supported**
   - **Why:** Several mechanism claims hinge on imprecise cells.
   - **Fix:** Rewrite interpretation to emphasize robust cells; present “channels” as hypotheses unless jointly supported across estimators and inference.

## 3) Optional polish (substantive, not prose)

8. **Report joint/functional uncertainty for derived quantities**
   - **Why:** Many policy-relevant summaries are functions of matrix cells.
   - **Fix:** Bootstrap the population-weighted implied destination share changes and report CIs.

9. **Heterogeneity**
   - **Why:** Race/age heterogeneity is important historically and substantively.
   - **Fix:** At minimum, show heterogeneity in a few well-supported rows (farm laborers, farmers) by race/age bins if sample sizes allow.

---

# 7. Overall assessment

### Key strengths
- Interesting and policy-relevant estimand (transition-matrix treatment effects).
- Valuable use of linked microdata; clear description of data construction and categories (Section 3).
- Honest acknowledgement that many cell estimates are imprecise; inclusion of a frequency benchmark is a strong credibility move (Section 4.5).
- Recognition of spillovers and linkage issues, with at least some sensitivity checks (Section 6.6–6.7).

### Critical weaknesses
- Identification remains too fragile for strong causal claims given only one pre-period and major contemporaneous shocks (Depression).
- The transformer-based estimator’s causal/statistical interpretation is not yet sufficiently transparent; it appears to change the estimand and introduce model-dependent structure.
- Inference is not yet credible for cell-level claims (100 bootstraps; asymptotic z from bootstrap SEs; BH-FDR implementation), and TWFE inference needs few-cluster methods.

### Publishability after revision
Potentially publishable if you (i) materially strengthen the identification (extra pre period or sharper design), (ii) upgrade inference to modern standards, and (iii) clarify/standardize the estimand and provide stronger conventional benchmarks. Without those changes, the paper is not ready for a top field/general journal.

DECISION: MAJOR REVISION