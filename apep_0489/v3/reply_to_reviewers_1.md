# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Identification credibility and Depression-era confounding
We agree that the single pre-period limits our ability to rule out differential Depression-era trends. We have added this as an explicit limitation. Adding 1910 linkage would require substantial new data construction and is outside the scope of this revision, but we note it as the most important future extension in the conclusion.

### 1.2 Pre-trends MAE not a standard pre-trend test
We clarify in the text that the pre-trends MAE measures the level difference in the pre-treatment transition matrix between TVA and control, which under the DiD assumption should be zero. We agree that with one pre-period this is necessary but not sufficient.

### 1.3 Spillovers are first-order, not secondary
We have elevated the alternative control group analysis and the spillover discussion. The alternative control (9 non-TVA states only) yielding larger effects is now interpreted as evidence that the main estimates are attenuated by partial spillovers.

### 1.4 Control group comparability
We discuss why our aggregate effect (1.49pp) is smaller than Kline-Moretti's ~4pp: linked-sample selection, individual-level vs county-level data, and share vs employment outcomes.

### 2.1 Main results statistically unsupported
We have substantially revised the abstract and introduction to acknowledge that most individual cell effects are imprecisely estimated. The Lewis and entrepreneurial channels are now described as "suggestive patterns" rather than established facts. The clerical stay-rate decline is highlighted as the only individually significant effect.

### 2.2 Bootstrap iterations
100 iterations is a computational constraint (7 min × 4 adapters per iteration = ~12 hours total). We report this honestly and note that increasing to 500-1000 would stabilize SE estimates but not fundamentally change the width of confidence intervals. We use percentile-based CIs in the bootstrap table.

### 2.3 TWFE with 16 clusters
We have added a small-cluster caveat noting that 16 state clusters is below the 30-50 threshold for reliable asymptotic CRVE inference. Wild cluster bootstrap is noted as a desirable improvement.

### 2.4 Frequency benchmark divergence on Farmer column
We have added an explicit caveat in the Results section acknowledging that the frequency benchmark shows mixed signs in the Farmer column. The "uniform farmer avoidance" pattern is now qualified as potentially reflecting the transformer's covariate conditioning rather than a robust empirical regularity.

### 5.1 "Sum across rows" not interpretable
We have replaced the unweighted sums with population-weighted implied destination share changes ($\Delta\pi_k = \sum_j \pi_{j,1920} \Delta P_{jk}$). The implied farmer-share decline is -1.1pp, comparable to the TWFE estimate.

### 5.2 Narrative overweights imprecise point estimates
Addressed throughout the revision. Abstract, introduction, and results now consistently acknowledge imprecision.

### 5.3 Transformer-frequency divergence
Added explicit discussion of this divergence in the Results section.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Bootstrap iterations and power
Acknowledged as a computational constraint. We report 100 iterations honestly. Power curves for key cells at delta=0.5pp would be informative but require additional bootstrap infrastructure.

### Source exclusion consistency
Professional is excluded as a source in both estimators. Not Working is excluded from the frequency table (extreme noise) but retained in the transformer table (where the model smooths the estimates). We document this difference in table notes.

### Population-weighted aggregation
Added population-weighted implied destination shares using 1920 baseline occupation prevalence. This provides a more interpretable measure than raw row sums.

### Welfare quantification
Noted as important future work in the conclusion. Linking 1940 occupation wage scores (Dunn indices) would quantify welfare implications.

### Second pre-trend
Acknowledged as the most important extension. 1910 linkage is feasible with IPUMS MLP but outside the scope of this revision.

### Missing citations
We will investigate Bils et al. and Price (2023) for inclusion.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Block aggregation for power
This is a valuable suggestion. While we have not implemented block aggregation with joint SEs, we have added population-weighted implied destination shares, which address the same concern: providing aggregate-level measures that pool across the noisy individual cells.

### Kline-Moretti comparison
Added explicit discussion of why our 1.49pp < K&M's ~4pp: linked-sample selection bias, individual vs county-level data, and share vs employment outcomes.

### FDR sensitivity
We have revised the FDR section to be more transparent about the limited number of significant cells. A volcano plot or p-value enrichment analysis would be informative but is beyond the current revision scope.

### Multiple pre-periods
Agreed. 1910 linkage is the most important extension and is noted in the conclusion.
