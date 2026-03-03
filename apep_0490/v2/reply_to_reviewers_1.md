# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Estimand mismatch with motivation
**Concern:** Conceptual framework (Predictions 1-4) is about position → attention → citations, but the estimand is (position gain − delay cost).

**Response:** We agree this was a tension in the earlier draft. The revised paper reframes the title ("Batch Assignment and Idea Diffusion"), abstract, and introduction from scratch. The estimand is now explicitly presented as the net effect of batch reassignment throughout. The conceptual framework's predictions remain useful as benchmarks, but the text now makes clear that the RDD tests the net tradeoff, not the isolated position channel.

### 1.2 Statistical power
**Concern:** Effective N of 84-90 is far too small; MDE 1.5-2.4 log points cannot detect policy-relevant effects.

**Response:** We acknowledge this is the paper's most important limitation and now state this more prominently in the introduction, results, discussion, and conclusion. Extending the sample to 2021-2024 and improving the OpenAlex match rate (currently ~25%) are identified as priorities for future work but are blocked by current API rate limits.

### 1.3 OpenAlex match rate and selection
**Concern:** 25% match rate creates potential selection; smooth match rate at cutoff is necessary but not sufficient.

**Response:** We expanded the limitations discussion to acknowledge that (a) matching may correlate with citation levels, (b) the matched subsample may have a different outcome model, and (c) inverse-probability weighting or alternative sources (Semantic Scholar) would strengthen the analysis.

### 1.4 Position measurement from incomplete batch
**Concern:** Position percentile computed from sampled papers, not full arXiv listing.

**Response:** We expanded the limitations paragraph to acknowledge that validating the proxy against full batch data (available through date-range API queries) would strengthen the analysis.

### 1.5 Kernel sensitivity
**Concern:** Epanechnikov and uniform kernels yield p≈0.09-0.10, suggesting specification sensitivity.

**Response:** We now explicitly acknowledge this sensitivity in Section 6.4.4, noting that the null is not robust to all reasonable weighting schemes.

### 1.6 Clustering/dependence
**Concern:** Citations may be correlated within announcement batches.

**Response:** Added new Section 6.4.5 discussing within-batch dependence, noting that formal clustering is infeasible with eff. N = 84-90, and that standard errors may understate uncertainty.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### 2.1 Power limitations
**Concern:** MDE 1.5-2.4 log points (4-11× baseline) cannot detect moderate effects.

**Response:** Agreed. The revised paper emphasizes this throughout as the most important limitation. The conclusion now states that "the design's inability to speak to moderate effects means that any substantive conclusion must be heavily qualified."

### 2.2 Position proxy unvalidated
**Concern:** Position from sampled batch, not full listings.

**Response:** Acknowledged in expanded limitations section. Validation against full batch data is identified as future work.

### 2.3 Conference exclusion significance
**Concern:** Conference exclusion yields p<0.001 — needs careful handling.

**Response:** Revised Section 6.4.4 now honestly notes this is "the one specification that yields a significant result" and discusses potential explanations (genuine heterogeneity vs. small-sample instability).

### 2.4 IV for pure position
**Concern:** Could use 2SLS-rdrobust to isolate position from delay.

**Response:** This is an interesting suggestion for future work. The current design's small sample makes IV estimates unreliable; we note the bundling issue throughout and suggest that isolating the channels requires either within-batch variation or a design like the NBER randomization.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 3.1 Sample size
**Concern:** Effective N = 86 is extremely small; MDE of 675% is too large for meaningful conclusions.

**Response:** Agreed. Power limitations are now the paper's central caveat, stated prominently in abstract, introduction, results, discussion, and conclusion.

### 3.2 Dependence in standard errors
**Concern:** Within-batch audience dependence may cause SEs to understate uncertainty.

**Response:** Added Section 6.4.5 discussing this issue and noting that randomization inference would provide a finite-sample alternative.

### 3.3 Sample expansion
**Concern:** Improve matching rate or use larger initial sample.

**Response:** Both approaches are identified as future work priorities. Fuzzy title matching and Semantic Scholar API integration could substantially increase coverage.

### 3.4 2020 cohort truncation
**Concern:** 5-year citation window incomplete for 2020.

**Response:** Now explicitly noted in results: "the 2020 cohort papers remain in the sample but their 5-year counts are mechanically truncated."
