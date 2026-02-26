# Internal Review — Round 1

**Paper:** Does Local Governance Scale Matter? Municipal Population Thresholds and Firm Creation in France
**Reviewer:** Claude Code (acting as Reviewer 2 + Editor)
**Date:** 2026-02-26

## Overall Assessment

**Verdict: CONDITIONALLY ACCEPT**

This paper makes a genuine contribution by providing the first causal test of whether municipal governance scale affects local entrepreneurship in France. The multi-cutoff RDD design is well-executed, the data are comprehensive (22,951 communes from the universe of establishments via INSEE Sirene), and the null result is honestly reported with extensive robustness checks.

## Strengths

1. **Novel research question.** While prior work (Eggers et al. 2018) used French population thresholds for political outcomes, no paper has connected these governance discontinuities to firm dynamics. The question has direct policy relevance for the *communes nouvelles* debate.

2. **Comprehensive identification strategy.** The multi-cutoff design provides internal replication across five independent thresholds. The difference-in-discontinuities at 3,500 exploiting the 2013 electoral reform adds a second identification strategy that separately identifies electoral vs. governance effects.

3. **Data quality.** Using the complete Sirene stock file (parquet bulk download) rather than API-queried subsamples ensures the analysis covers the universe of French establishments. The sample sizes are large: 6,394 communes near 500, 5,109 near 1,000, etc.

4. **Honest null.** The paper does not overinterpret or apologize for the null. The discussion considers offsetting channels, external validity, and the interpretation gap between governance *scale* and governance *quality*.

## Concerns

### Major

1. **McCrary test at 1,500 is borderline (p = 0.050).** While the other four thresholds pass easily, the p-value exactly at 0.05 warrants discussion. Consider reporting the 1,500 threshold results with appropriate caveats or running the donut-hole specification at 1,500 more prominently.

2. **Mass points in the running variable.** The rdrobust warnings about mass points are important. Population is an integer, so mass points are inevitable. Consider using the `masspoints` option in rdrobust (e.g., `masspoints = "adjust"` or `masspoints = "off"`) and reporting both versions for transparency.

### Minor

3. **Bandwidth for the pooled RDD shows "0" in Table 2.** The pooled specification uses normalized running variables, so bandwidth should be reported in normalized units (0.124), not raw units. Fix the table to display this correctly.

4. **Tab3 shows `creation_rate` as column header.** Should be formatted as "Firm Creation Rate" or "Creation Rate" rather than the raw variable name.

5. **Figure notes slightly overlap figure captions** in the compiled PDF (visible on Figure 2). Minor formatting issue.

6. **The paper does not discuss the auto-entrepreneur reform of 2009.** This massively increased firm creation counts and could affect year-to-year comparisons. Consider mentioning this in the data section and verifying it doesn't interact with the RDD design.

## Recommendation

Address the mass points issue (use rdrobust's masspoints option) and clean up the minor table/figure formatting issues. The paper is strong enough to proceed to external review with these fixes.
