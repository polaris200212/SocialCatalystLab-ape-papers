# Internal Review - Round 1

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:** The four-adapter LoRA design cleanly maps onto the standard 2×2 DiD framework. The temporal loss masking innovation addresses the pre-training contamination concern convincingly. The control group definition (non-TVA counties across all 16 states) is now stated consistently.

**Concerns:**
- The parallel trends assumption rests on a single pre-period (1920→1930 vs 1930→1940). The paper acknowledges this limitation (p. 20) but the pre-trends MAE of 0.0002 at the token level is reassuring.
- The TVA was established in 1933, so the 1930→1940 transition captures 7 years of pre-treatment and 7 years of post-treatment. The paper should discuss this timing issue more explicitly.
- Selection into the linked IPUMS MLP sample is a concern: more mobile workers (those most affected by TVA) may be harder to link. The paper argues this biases toward zero, which is plausible but unverifiable.

### 2. Inference and Statistical Validity

**Critical issue:** The transformer does not produce standard errors for the transition matrix cells. The paper's inference strategy relies on:
1. Pre-trends near zero (0.0002 MAE)
2. Placebo test (pattern specificity, not a true null)
3. TWFE consistency (aggregate only)
4. FDR correction based on pre-trends MAE ratio

This is the paper's main weakness. The FDR correction (Section 7.3) uses the pre-trends MAE as a noise benchmark, which is defensible but unconventional. A bootstrap or permutation approach would be stronger, and the paper correctly identifies this as future work.

The TWFE regressions have proper state-clustered SEs with 16 clusters. The t-statistics and p-values are correctly computed.

### 3. Robustness

- The placebo test is informative about pattern specificity but is not a clean null test (the random state split creates composition differences). The paper now frames this appropriately.
- No alternative control groups are tested (e.g., bordering counties only, same-state non-TVA only).
- Hyperparameter sensitivity (LoRA rank, learning rate) is not reported.
- The weight-space SVD analysis provides a complementary view but doesn't constitute independent robustness.

### 4. Contribution and Literature

The paper positions well relative to distributional treatment effects (Athey & Imbens 2006), quantile DiD (Callaway & Li 2019), and the CAREER model (Vafa, Athey et al. 2022). The connection to Kline & Moretti (2014) is central and well-developed.

Missing citations: Dahl & Lochner (2012) on income and occupational transitions; Autor et al. (2014) on trade and labor market adjustment; Notowidigdo (2020) on incidence of local labor demand shocks.

### 5. Results Interpretation

The paper's central finding—universal decline in farmer-entry transitions—is well-supported by the data. The interpretation is appropriately cautious. The comparison to TWFE aggregates is insightful: the transformer reveals that displaced agricultural workers spread across multiple destinations rather than concentrating in manufacturing.

The Professional category having all zeros is a minor concern but adequately addressed with the footnote.

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Must-Fix
1. Discuss the TVA timing issue (1933 establishment vs 1930-1940 census window)
2. Report at least LoRA rank sensitivity (r=4,8,16)

### High-Value
3. Add a geographic map of TVA vs control counties
4. Promote event study figure to main text
5. Add difference column to balance table
6. Discuss what the "Unclassified" category captures and why it's 22%

### Optional
7. Permutation inference for key summary statistics
8. Alternative control group (bordering counties)
9. Bold FDR-significant cells in Table 3

## 7. Overall Assessment

**Strengths:** Novel methodological contribution connecting transformers to causal inference. Real computation on real data with transparent reporting. Economic interpretation is rich and insightful. Writing quality is high.

**Weaknesses:** No standard errors on the main estimates. Single pre-period limits parallel trends testing. Placebo test is not a clean null.

**Publishability:** Strong contribution with a meaningful methodological innovation applied to a canonical setting. The lack of formal inference is the main limitation, but the validation stack (pre-trends + placebo + TWFE consistency + synthetic validation) provides reasonable credibility.

DECISION: MINOR REVISION
