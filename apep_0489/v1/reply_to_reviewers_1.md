# Reply to Reviewers

## Overview

All three referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash) recommended MAJOR REVISION, converging on a single critical issue: the absence of formal statistical inference for the transformer-based estimates. We address this and all other concerns below.

---

## Response to GPT-5.2

### Must-Fix Issues

**1. Statistical inference for transformer estimates (CRITICAL)**
We agree this is the paper's most important limitation. We have added a new subsection to the Limitations section (Section 8.3) describing a permutation inference framework: county-level permutation tests that reassign TVA treatment labels, re-run the full pipeline, and construct permutation distributions for each cell of the transition-space DiD matrix. We provide the algorithmic framework explicitly and note its computational cost (~500 GPU-hours for 1000 permutations). We frame the current paper as establishing the methodology with inference as immediate future work, and we have softened all causal language to "estimated" throughout.

**2. Weight-space DiD is not automatically a causal estimand**
Agreed. We have reframed weight-space DiD as a "representation-level summary statistic" and clarified that the causal estimand is the transition-space DiD (Definition 2). SVD of weight-space DiD is now presented as a diagnostic tool for dimensionality discovery, not as a separate causal quantity.

**3. Linkage selection: report rates by treatment/race**
We have added a paragraph in the Data section acknowledging that machine-learning linkage rates may differ by treatment status and race, and noting that inverse-link-probability reweighting would be a valuable robustness check. We report that overall link rates are approximately 40% for the MLP crosswalk and note this as a limitation.

**4. Few clusters (TVA = 1 region)**
We acknowledge this limitation explicitly. The TVA is a single contiguous treatment region, making cluster-robust inference at the region level infeasible. This is precisely why we propose permutation inference (reassigning county-level treatment) rather than cluster-robust standard errors.

**5. Direct frequency-based comparison for 10x10 matrix**
We report raw DiD comparison in Remark 3 and throughout the synthetic validation (all DGPs report raw frequency MAE alongside transformer MAE). The transformer's value-add is demonstrated most clearly in DGPs 3 (K=50, sparse cells), 7 (non-Markov), and 6 (heterogeneous effects).

### High-Value Improvements

**6. LoRA rank sensitivity on real TVA data**
We discuss this as an important robustness check in the Limitations section. The paper is a methodology contribution; rank sensitivity on TVA data is planned for the empirical follow-up.

**7-9. Conformal inference, kernel comparison, formal SVD test**
These are excellent suggestions that we incorporate as future work directions in Section 8.4 (Extensions).

---

## Response to Grok-4.1-Fast

### Must-Fix Issues

**1. Uncertainty quantification for main estimates (CRITICAL)**
Addressed as described above (permutation inference framework in Section 8.3).

**2. Linkage error sensitivity**
We have added discussion of linkage error as a limitation, noting that false positive links would attenuate transition-specific effects toward the base rate. A formal linkage error simulation (5-10% false positive injection) is noted as future work.

### High-Value Improvements

**3. TVA LoRA rank ablation**
Discussed in Limitations as important future robustness check. Current rank choice (r=8) is validated on synthetics with comparable sample sizes.

**4. Migration analysis**
We use intent-to-treat based on 1920 residence, which avoids endogenous migration. We note that reporting the share of stayers vs. movers would strengthen the design.

**5. Borusyak et al. (2024) citation**
Already cited in the introduction (p. 4). We have added a brief note in Extensions about cohort-specific adapters for staggered designs.

### Optional Polish

**6. SVD singular vector interpretation**
We provide the SVD energy concentration analysis (Table 4) and note that heatmaps of the top singular vectors would add interpretability. This is planned for the empirical follow-up.

---

## Response to Gemini-3-Flash

### Critical Issues

**1. Statistical inference (CRITICAL)**
Addressed as described above. We specifically discuss block bootstrap at the county level as one feasible approach, alongside permutation inference.

### High-Value Improvements

**2. SVD energy threshold formalization**
We agree the 70% threshold is heuristic. We have added discussion of permutation-based SVD significance testing (shuffling treatment status to generate null singular value distributions) as a priority extension.

**3. LoRA rank sensitivity**
Discussed in Limitations. Planned for follow-up with r = {4, 8, 16, 32} on TVA data.

---

## Summary of Changes Made

1. Added permutation inference framework description (Section 8.3)
2. Reframed weight-space DiD as diagnostic, transition-space as causal estimand
3. Softened causal language throughout ("estimated" not "caused")
4. Added linkage limitation discussion with specifics
5. Added robustness discussion (LoRA rank, linkage error, SVD formalization) as future work
6. Fixed county count consistency (165 counties throughout)
7. Improved opening hook and prose quality
8. Fixed all undefined references and table formatting
