# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T04:05:01.621233
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 28237 in / 5146 out
**Response SHA256:** d7fef0540758c197

---

## Summary

The paper proposes “DiD in representation space” using transformers: pre-train a national career-sequence model, fine-tune four LoRA adapters corresponding to the \(2\times2\) DiD cells (treated/control × pre/post) with temporal loss masking, and form a “weight-space DiD” as the double-difference of adapter weights; SVD of this object is used to characterize dimensionality of treatment effects. The authors also extract an interpretable transition-matrix DiD by aggregating predicted next-token probabilities.

The core idea—using a high-capacity sequence model to estimate a high-dimensional transition object and then imposing DiD structure via cell-specific fine-tuning—is interesting and potentially impactful. However, in its current form the paper is **not publication-ready** for a top general-interest journal, mainly because (i) the causal estimand is not cleanly identified given the use of post-treatment treated outcomes in “region-blind” pre-training, (ii) the paper provides **no valid uncertainty quantification** for the main (transformer-based) results, and (iii) several key design choices create additional threats (migration, conditioning on being linked across all three censuses, small number of clusters in TWFE benchmark inference, etc.) that are not adequately addressed.

Below I focus on scientific substance and publication readiness (not prose or figure design).

---

# 1. Identification and empirical design (critical)

### 1.1 What is the causal estimand?
The paper’s target is the transition-matrix DiD (eq. (2) / (4)):  
\[
\Delta P_{\text{DiD}} = (P^{T,\text{post}}-P^{T,\text{pre}})-(P^{C,\text{post}}-P^{C,\text{pre}}),
\]
interpretable under parallel trends in transition probabilities (Assumption 1, Section 3.5).

That estimand is standard and meaningful. The novelty is using a transformer to estimate \(\hat P^{g,\tau}\) in high-dimensional state spaces and using weight-space differences as an auxiliary diagnostic.

### 1.2 Major identification problem: national pre-training uses post-treatment treated outcomes
Section 3.3 (“National pre-training”) and Assumption 2 (“Common Pre-Training”) assert the base model is “region-blind” and thus not contaminated. But **region-blindness is not sufficient**: if the base model is trained on the full sample including **treated units in the post-treatment period**, then the base parameters \(\theta_0\) encode the average of treated post-treatment transition dynamics. This creates at least two problems:

1. **Bad controls / post-treatment information in the baseline**: the object you treat as “common trends representation” is partially shaped by the treatment itself. Freezing \(\theta_0\) then conditions all four adapters on a baseline that has absorbed some treatment-induced structure.

2. **Cell-specific fine-tuning no longer maps cleanly to \((g,\tau)\) deviations**: your adapter deltas \(\Delta\theta_{g,\tau}\) are deviations from a mixture model that already incorporates post-treatment treated outcomes. The weight-space DiD and transition-space DiD extracted from these adapted models may be attenuated, distorted, or otherwise hard to interpret as estimates of the DiD counterfactual. (Direction of bias is ambiguous because the subsequent fine-tuning could “undo” or “re-express” patterns, but interpretability as a causal DiD object is compromised.)

This is a fundamental design issue: in causal work, the “first stage” predictive model cannot freely use post-treatment treated outcomes if you later claim to identify counterfactual evolution via DiD logic. The paper needs either (i) **pre-train only on pre-treatment periods** (and ideally multiple pre periods), or (ii) pre-train on a sample that excludes treated-post observations (e.g., control units and/or pre periods), or (iii) formalize why using treated-post in pre-training does not bias the extracted \(\Delta \hat P_{\text{DiD}}\) (which will be difficult without strong orthogonality/linearity results that are not present).

The current synthetic validation does not resolve this, because the synthetic setup appears to follow the same pipeline without explicitly demonstrating robustness to “pre-training contamination” (i.e., including treated-post in \(\theta_0\)).

### 1.3 Parallel trends: limited testability with only one pre period
The application has only one pre transition (1920→1930) and one post transition (1930→1940). The paper reports a “pre-trends MAE” comparing \(\hat P^{T,\text{pre}}\) and \(\hat P^{C,\text{pre}}\) (Section 3.5; Table 7 reports 0.8pp).

This is **not a pre-trend test**. It is a **level-difference diagnostic** at one pre period. Parallel trends is about changes; with only one pre period you cannot test trends in the usual sense. For a top journal, the paper needs a stronger design or additional pre periods (e.g., incorporating 1910/1900 where linkable; or alternative outcomes/aggregates with more annual data; or complementary designs).

The traditional county-level event study in Section 6.4 uses 1920/1930/1940 and tests a 1930 “pre” coefficient relative to 1920 for employment shares, which is better—but it’s still limited (one pre coefficient), and it’s on aggregates rather than the transition object.

### 1.4 Treatment definition and migration / exposure
Treatment is defined by 1920 county of residence (intent-to-treat), which is defensible. But several exposure threats remain:

- **Migration and differential mobility**: treated individuals may move out/in differentially between 1920 and 1940. ITT is fine, but if migration is itself affected by TVA, the estimated transition matrix conflates “career transitions in place” with “career transitions plus relocation selection.” That may be substantively acceptable, but it must be explicit: what is the estimand—effect on individuals initially residing in TVA counties regardless of later residence, or effect of residing in TVA counties at the time of transition? The transformer conditions on sequence tokens that include state (occupation/industry/marital/children) but does not appear to include **geography at later dates**, so interpretation is unclear.

- **Exposure intensity**: TVA intensity varied across counties (dam locations, electrification rollout). The paper uses a binary county treatment, which may be acceptable, but top journals will expect either (i) intensity/continuous treatment checks, or (ii) a rationale for why binary treatment aligns with historical exposure.

### 1.5 Selection into the linked panel (conditioning on being linked across all 3 waves)
Section 5.2 restricts to males 18–65 in 1920 who are “successfully linked across all three census waves.” That selection is likely endogenous to mobility, name changes, incarceration, mortality, and migration—many of which could be affected by TVA (directly or indirectly). Conditioning on being linkable can create selection bias, especially if linking probability differs by treated status and changes over time.

At minimum the paper needs:
- balance and differential attrition/linking rates by treatment group and baseline characteristics,
- sensitivity analyses using link-quality thresholds,
- bounding exercises or reweighting to address differential linkage.

### 1.6 Comparison group construction
Control states are a broad set of Southern/border states (Section 5.2). This is plausible but coarse. Kline & Moretti (2014) emphasize careful counterfactuals (including “proposed but not approved” authorities). The paper’s benchmark TWFE includes alternative controls, but the transformer application appears to use the baseline control definition without showing that the *transition-matrix DiD* is stable to control group choice.

Because the core output is a high-dimensional object, it is especially important to show it is not sensitive to the control set.

---

# 2. Inference and statistical validity (critical)

### 2.1 No valid uncertainty quantification for the main transformer estimates
The paper explicitly states “No Confidence Intervals” (Remark in Section 3.5). For a top economics journal, this is not acceptable as-is.

Even if the weight-space object lacks a standard distribution, the **transition-space DiD** \(\Delta \hat P_{\text{DiD}}\) is a function of observed data and estimated model parameters; you can and must provide uncertainty quantification for key summaries (and ideally for the matrix itself via multiple-testing-aware summaries).

Concrete feasible approaches include:

- **Cluster/block bootstrap at the county level** (or county×year blocks): resample counties within treatment and control strata, retrain adapters (possibly warm-started), and recompute \(\Delta \hat P_{\text{DiD}}\). With LoRA and a small model, this is computationally feasible (your runtimes suggest it might be).

- **Randomization inference / permutation tests** at the county level: repeatedly reassign “TVA” status among counties within a region (or within matched sets), re-run adapter fine-tuning/extraction, and build a null distribution for chosen test statistics (e.g., top singular value of \(\Delta \hat P\), or agriculture→manufacturing flow mass). This is particularly attractive given the historical quasi-experiment.

- **Sample splitting / cross-fitting over individuals or counties**: train the base and adapters on one fold and evaluate transition matrices on a held-out fold to reduce overfitting and allow repeated-split variability assessment.

Right now, statements like “Farmer→Operative = 5.2pp” (Table 7) are presented with no SE/CI, making it impossible to judge precision, compare magnitudes across cells, or assess whether secondary patterns (e.g., 1.1pp) are distinguishable from noise.

### 2.2 TWFE benchmark inference: too few clusters, needs robust methods
Section 6 clusters SEs at the state level “following Kline & Moretti.” But your sample includes ~16 states (7 TVA states + control states), which is **a small number of clusters**. Conventional cluster-robust SEs can be severely biased downward. Top journals will expect **wild cluster bootstrap** p-values or randomization inference at the state/county level, plus sensitivity to clustering at the county level (though serial correlation with only 3 periods is limited).

This matters because the TWFE benchmark is used as an “external validation” for the transformer; if the benchmark inference is itself fragile, it is not a strong anchor.

### 2.3 Multiple comparisons / “dominant cells” selection
Table 7 reports only cells with \(|\Delta P|>1\)pp. This is effectively a selected set of “discoveries” from a large matrix. Without a principled multiple-testing adjustment or out-of-sample validation, the paper risks **selecting noise** as patterns—particularly for smaller effects.

At minimum, provide:
- a pre-registered-style set of primary hypotheses (e.g., total agriculture→manufacturing mass; or specific historically motivated flows),
- family-wise error / FDR control for secondary exploratory cells,
- or resampling-based stability measures (e.g., how often each cell exceeds 1pp across bootstrap draws).

### 2.4 Internal validity of the ML procedure: overfitting and leakage
The paper reports pre-training perplexity and synthetic DGP recovery, but does not establish that the adapter fine-tuning and extraction are evaluated out-of-sample in the TVA application. With flexible models, it is easy to fit idiosyncratic patterns.

You should:
- evaluate extracted transition matrices on held-out individuals/counties,
- report calibration metrics for predicted transition probabilities,
- check sensitivity to training steps/early stopping.

---

# 3. Robustness and alternative explanations

### 3.1 Robustness of transformer-based results to control groups and design choices
The paper provides robustness for traditional TWFE but not for the transformer transition matrix. High-value robustness checks:

- **Alternative control groups** in the transformer application (bordering counties; same-state non-TVA; proposed-but-not-approved authorities if feasible). Show that the main matrix patterns and key aggregated summaries are stable.

- **Alternative treatment definitions**: intensity or distance-to-dam, electrification rollout timing, or excluding counties with ambiguous service area classification.

- **Migration handling**: (i) restrict to non-movers between 1920 and 1930 (pre) and/or 1930 and 1940 (post), if residence is observed; (ii) include residence token/embedding so the model conditions on place; (iii) decompose effects into “within-county stayers” vs movers.

### 3.2 Mechanisms vs reduced form
The paper sometimes drifts into mechanism language (“TVA primarily shifted which occupations workers entered rather than sequential dynamics,” Section 5.5). That conclusion is based on where the SVD energy lies in weight modules, which is not a validated mapping from weights to economic channels. Treat this as descriptive/heuristic unless you can show a formal link (e.g., intervention studies in the model, or ablations that isolate modules and demonstrate impact on specific transition margins).

The transition-matrix DiD is a reduced-form object; mechanism claims should be carefully bounded.

### 3.3 External validity / generality
The method is pitched as general for high-dimensional outcomes. That may be true, but the current validation relies heavily on synthetic Markov/non-Markov DGPs where the transformer is correctly specified. Real data have missingness, measurement error, occupational coding changes, and selection into being observed/linked.

A top journal will expect clearer discussion (and some evidence) on:
- robustness to misclassification of occupation/industry,
- coding changes between censuses,
- linkage error (beyond a short limitation paragraph).

---

# 4. Contribution and literature positioning

### 4.1 Methodological contribution: needs clearer relation to existing work on distributional/high-dimensional DiD
You cite CiC (Athey-Imbens), quantile DiD, and modern staggered DiD. But the closest conceptual neighbors are:

- **ML for structured high-dimensional outcomes / distributional causal effects**: work on distribution regression, causal ML for functional outcomes, and embedding-based causal estimands. Consider citing work on causal inference with text/embeddings and representation learning where the estimand is learned but identification remains causal (e.g., Egami et al. on text as data for causal inference; Roberts et al.; as well as recent work on “causal representation learning” though that literature is more structural).

- **Matrix completion / interactive fixed effects for high-dimensional panels**: you cite Moon & Weidner, but there’s also Athey et al. (2017) “matrix completion methods for causal panel data models” (synthetic control generalizations) and related low-rank causal panel literature. Your “rank/dimensionality” narrative would benefit from engaging that literature and clarifying how your approach differs (sequence model vs low-rank outcome model).

- **Staggered adoption / heterogeneous effects**: you mention extension is “conceptually straightforward” but do not show it. That’s fine, but the paper should be explicit that the current method is validated only in a clean \(2\times2\) setting.

### 4.2 TVA literature positioning
You benchmark against Kline & Moretti, and cite Hornbeck & Moretti. If you claim “first individual-level distributional analysis,” you should ensure coverage of related linked-census work on place-based shocks and mobility. Even if not TVA-specific, cite linked-census studies of migration, intergenerational mobility, and local labor markets where similar linked panels have been used.

---

# 5. Results interpretation and claim calibration

### 5.1 Over-interpretation given lack of uncertainty
Many substantive claims (e.g., “substantial effects on … service sector entry,” “roughly 40% smaller for non-white workers”) are not supported with uncertainty measures. With 10.85M individuals, many effects will be precise, but precision is not automatic given clustering, selection, and model-based estimation.

### 5.2 Comparing TWFE (aggregate) to transformer (cell-level) requires coherent aggregation
Section 6.3 compares TWFE Ag→Mfg transition (+4.8pp) to Farmer→Operative (+5.2pp) plus FarmLabor→Operative (+4.7pp). That comparison is not apples-to-apples: TWFE is an unconditional transition rate aggregated over origins, while the table entries are conditional on specific origins. You need to present a properly aggregated transformer-based estimate matching the TWFE outcome definition (same denominator, same conditioning, same sample restrictions), and then compare.

### 5.3 Weight-space SVD claims are not yet substantively interpretable
Interpreting “early layers vs late layers” as economic channel evidence is speculative. Keep this as exploratory unless validated via controlled experiments (e.g., projecting \(\Delta W\) onto specific parameter subspaces and showing impact on interpretable transition summaries).

---

# 6. Actionable revision requests (prioritized)

## (1) Must-fix issues before acceptance

1. **Fix the pre-training contamination problem**
   - **Issue**: \(\theta_0\) is trained on treated-post outcomes, undermining causal interpretation of both weight-space and transition-space DiD.
   - **Why it matters**: This threatens identification at the core design level.
   - **Concrete fix**: Re-run the pipeline with base pre-training restricted to:  
     (a) pre-treatment transitions only (e.g., 1920→1930), and/or  
     (b) control units only, and/or  
     (c) an explicitly “leave-treated-post-out” training split.  
     Then show how estimates change. Ideally make (a) the main specification, with (b) as robustness.

2. **Provide valid inference for the main transformer-based causal quantities**
   - **Issue**: No SE/CI/p-values for \(\Delta \hat P_{\text{DiD}}\) or key aggregated summaries.
   - **Why it matters**: Without uncertainty, the paper cannot meet top-journal standards; readers cannot assess which effects are distinguishable from noise.
   - **Concrete fix**: Implement a county-level (or county×group) **cluster bootstrap** or **randomization inference** procedure for:  
     - key pre-specified summaries (e.g., total agriculture→manufacturing transition mass; exit from farm; occupation-change rate),  
     - a small set of historically motivated cells, and  
     - optionally the leading singular values of \(\Delta \hat P_{\text{DiD}}\).  
     Report 95% CIs and adjusted p-values where appropriate.

3. **Address selection into linked sample and differential linkage**
   - **Issue**: Conditioning on being linked across all 3 censuses may induce selection bias correlated with treatment.
   - **Why it matters**: Could overturn causal interpretation.
   - **Concrete fix**:  
     - Report linkage rates by treatment group and baseline covariates (using the universe of candidates in 1920 as denominator where possible).  
     - Re-estimate effects across link-quality thresholds.  
     - Consider inverse-probability weighting for linkage, with sensitivity/bounds.

4. **Upgrade benchmark TWFE inference**
   - **Issue**: State-level clustering with ~16 clusters is fragile.
   - **Why it matters**: Benchmark is used to validate the new method.
   - **Concrete fix**: Report wild cluster bootstrap p-values (state clusters) and/or randomization inference; show sensitivity to clustering level.

## (2) High-value improvements

5. **Demonstrate robustness of the transformer transition-matrix results to control group choices**
   - **Why**: The key output is high-dimensional and may be sensitive to controls.
   - **Fix**: Replicate the transition-matrix DiD under bordering-county controls, same-state non-TVA controls, and any historically motivated counterfactual set (e.g., proposed authorities if feasible). Provide stability metrics (correlation of \(\Delta \hat P\), overlap of “top cells,” stability of aggregated flows).

6. **Align transformer-based aggregates with traditional outcomes**
   - **Why**: Current comparisons mix conditional and unconditional rates.
   - **Fix**: Construct transformer analogues of TWFE outcomes (same denominators, conditioning) and compare directly.

7. **Clarify estimand regarding migration/exposure**
   - **Why**: ITT is fine, but interpretation must be explicit.
   - **Fix**: Add analyses splitting by movers vs stayers (if possible), or include geography tokens/embeddings.

## (3) Optional polish (once the above are done)

8. **Temper or validate module-level SVD interpretations**
   - **Fix**: Reframe as exploratory; or provide ablation/intervention evidence connecting module perturbations to interpretable transition-margin changes.

9. **Strengthen literature connections**
   - **Fix**: Add citations/positioning around (i) matrix completion causal panel methods (Athey et al.), and (ii) causal inference with embeddings/functional outcomes/text-as-data causal work.

---

# 7. Overall assessment

### Key strengths
- Ambitious and potentially important: high-dimensional/distributional treatment effects on career transitions are a real gap in applied work.
- Clever engineering idea: four adapters with temporal loss masking is an intuitively appealing way to map DiD cells to parameter perturbations.
- Synthetic validation is extensive and thoughtfully designed (Markov vs non-Markov, rank structure, sample size).

### Critical weaknesses
- **Identification is not currently credible** because the “common trends” base model is trained on post-treatment treated outcomes, which can bake treatment effects into the baseline.
- **No valid inference** for the main transformer-based causal results; pre-trends MAE and synthetic benchmarks cannot substitute for uncertainty quantification on real data.
- **Selection into linked sample** and migration/exposure issues are not resolved and could meaningfully bias results.
- Benchmark TWFE inference needs small-cluster corrections.

### Publishability after revision
With a redesigned pre-training strategy, credible uncertainty quantification (bootstrap/permutation), and explicit handling of linkage selection/migration, the paper could become a serious candidate. Without those, it does not meet the standards for AER/QJE/JPE/ReStud/Ecta/AEJ:Policy.

**DECISION: REJECT AND RESUBMIT**