# Reply to Reviewers — apep_0476 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. False-Match Rate Quantification
> The paper never quantifies the false-match rate of the MLP crosswalk.

**Response:** We acknowledge this limitation explicitly in Section 7.4 (Limitations). The MLP crosswalk v2.0 does not publish precision/recall statistics, and we cannot construct a ground truth without hand-linked validation samples. We have added a caveat noting that users should treat our cross-pair consistency checks (>99% sex/age match) as a lower bound on quality, not a substitute for false-match rate quantification. We cite Mill (2020) on linking bias and recommend that researchers conducting causal analyses use sensitivity analyses for potential false matches.

### 2. Mortality Decomposition of Link Rates
> Link rates confound algorithmic performance with mortality and emigration.

**Response:** We have added a new paragraph in Section 3 explaining that forward-link shares reflect both intercensal mortality/emigration and algorithmic performance. We note that period life tables (e.g., Haines 2008) could be used to estimate the expected linkable population, and recommend this adjustment for causal work. This is now listed as a priority extension in Section 7.4.

### 3. Uncertainty Measures for Descriptive Statistics
> Tables 5-7 report means without confidence intervals or standard errors.

**Response:** Given sample sizes of 34-72 million per decade pair, standard errors on means are negligible (typically <0.01). We have noted in the text that statistical significance is not the concern; selection bias is the relevant source of uncertainty. The IPW-weighted estimates in Table 6 address this directly.

### 4. Causal Language
> Several passages use causal language inappropriate for a descriptive paper.

**Response:** Fixed. All instances of causal framing have been replaced with descriptive language ("consistent with," "patterns suggest," "coincides with").

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. IPW Effectiveness Table
> Show weighted vs unweighted means side-by-side.

**Response:** Table 6 already presents IPW-weighted means for key variables. We have clarified the table notes to make the comparison with unweighted Table 5 means more explicit.

### 2. ABE Overlap Demographics
> Show demographics of individuals linked by both MLP and ABE.

**Response:** Appendix Section F provides the ABE comparison. We acknowledge that a joint demographic profile of the overlap population would be valuable but is beyond the scope of this atlas paper. We note this as a direction for future validation work.

### 3. Scope Disclaimer
> Add explicit statement that the paper is descriptive.

**Response:** Added a clear scope paragraph in the introduction following the threefold contribution statement.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Mortality Decomposition (Must-Fix)
> Use period life tables to estimate expected linkable population.

**Response:** We have added a mortality caveat paragraph (see response to Reviewer 1, point 2). Full life-table decomposition is noted as a priority extension but is beyond the scope of this descriptive atlas, which focuses on documenting the panel as-built rather than decomposing its construction.

### 2. Occupational Transition Sensitivity (High-Value)
> Provide robustness check using broader 5-category classification.

**Response:** Our 10-category classification follows the OCC1950 coding standard used throughout the historical census linking literature. The asymmetry in farm-to-nonfarm transitions is robust to alternative groupings because it reflects movement across the farm/nonfarm boundary, which is invariant to within-sector reclassification. We note this in the text.

### 3. Map-based Visualization (Optional)
> State-level heatmap of link rates.

**Response:** We agree this would be a valuable addition for a future version. The current paper prioritizes systematic tabular documentation over geographic visualization. State-level link rates are documented in Appendix B (Table B.1).

---

## Cross-Cutting Changes

1. **Abstract:** "100% demographic consistency" → "near-perfect (>99%)"
2. **Introduction:** Added scope disclaimer paragraph
3. **Section 3:** Added mortality decomposition caveat
4. **Section 5:** Fixed causal language throughout
5. **References:** Added Mill (2020) and Feigenbaum (2018)
6. **Appendix G:** Qualified consistency claim
