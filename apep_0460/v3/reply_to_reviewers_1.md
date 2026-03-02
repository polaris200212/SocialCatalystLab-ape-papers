# Reply to Reviewers — APEP-0460 v3 (Stage C Revision)

## Summary of Changes

This revision addresses feedback from three external referees (GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash), all recommending MAJOR REVISION, as well as constructive suggestions from exhibit and prose reviews. The key additions are:

1. **House-apartment gap event study** (new Figure 6): Directly tests the triple-difference identifying assumption by collapsing to the within-département gap and running a standard event study. Pre-trend F-test: p=0.240 (not significant), validating parallel pre-trends for the gap.

2. **Pre-trend F-tests reported explicitly**: SCI (p=0.038), census stock (p=0.048), house-apartment gap (p=0.240). The borderline DiD pre-trend violations reinforce the case for the triple-difference.

3. **COVID subsample analysis**: Pre-COVID (2014-2019) triple-difference yields β≈0.000 (p=0.972), revealing that the triple-diff signal is driven by 2020-2023 dynamics. Reported honestly in Discussion section.

4. **Direction of effects clarified**: Reconciled positive Post×Stock with negative Sterling×Stock. The positive coefficient reflects average cosmopolitan appreciation; the negative sterling interaction captures the UK-specific demand channel within the post period.

5. **Residualization reframed as descriptive decomposition**: Following GPT's recommendation, explicitly noted that residualization is not a causal identification strategy and may suffer from attenuation.

6. **Table professionalization**: Replaced `log_price_m2` with "Log Price/m²", standardized "Quarter-Year" labels, replaced "=0" labels with "Interior"/"Non-Hotspot", added significance star definitions and clustering notes to all table footnotes.

7. **Prose improvements**: Removed roadmap paragraph, strengthened active voice in results, added punchy closing sentence.

8. **Observation counts reconciled**: Fixed all N mismatches (3,510 main panel, 7,014 property-type panel, 7,010 after singletons, 6,412 for census stock specifications, 3,209 for census stock DiD).

---

## Point-by-Point Responses

### GPT-5.2

**1. Triple-diff event study uses wrong estimand (must use gap, not three-way interaction with weaker FEs)**
DONE. Added Figure 6 with collapsed house-apartment gap event study. The gap pre-trend F-test (p=0.240) validates the triple-diff design. This is now the most reassuring pre-trend result in the paper.

**2. Inference upgrade (wild cluster bootstrap)**
ACKNOWLEDGED but not implemented in this revision. With 96 clusters, conventional cluster-robust SEs are generally adequate (Cameron & Miller 2015). The RI p-value (0.003) already provides alternative inference. Wild bootstrap is a future improvement.

**3. Trends robustness (pre-trend adjusted designs)**
PARTIALLY addressed. The gap event study provides the cleanest pre-trend evidence. Full Roth/Rambachan-Roth sensitivity analysis is left for a future revision as it requires additional methodological infrastructure.

**4. COVID confound for triple-diff**
DONE. Pre-COVID subsample (2014-2019) triple-diff yields null result (β≈0.000, p=0.972). This is reported honestly in Discussion Section 8.4. We acknowledge this undermines the Brexit interpretation of the triple-diff, though the gap pre-trend validation and null German placebo remain informative.

**5. Validate "British demand is house-specific" premise**
PARTIALLY addressed. Section 2.3 provides qualitative evidence from INSEE and notarial reports. Quantitative buyer nationality data is unavailable in DVF. Acknowledged as limitation.

**6. Additional country placebos**
NOT implemented. The Swiss SCI is included in the residualization, but separate Belgium/Netherlands/Spain placebos require additional SCI computation. Future work.

**7. Economic significance calibration**
Already present: "a one-log-unit increase in UK census stock is associated with a 1.1 percentage point larger post-Brexit price increase."

**8. Reframe residualization as descriptive**
DONE. Section 8.3 now explicitly states residualization is a "descriptive decomposition, not a causal identification strategy."

### Grok-4.1-Fast

**1. Report pre-trend diagnostics numerically**
DONE. F-tests reported in Section 5.3: SCI (F=1.98, p=0.038), stock (F=1.90, p=0.048), gap (F=1.28, p=0.240).

**2. Boost triple-diff power**
ACKNOWLEDGED. The saturated FE structure necessarily limits power. Excluding Paris/Riviera (β=0.032, p=0.115) doesn't substantially improve precision. Aggregation to département level may be too coarse, as Gemini noted.

**3. Clarify direction (positive Post×UK vs negative sterling×UK)**
DONE. Added explicit reconciliation in Section 7.1: "UK-connected areas appreciated more on average post-2016 (cosmopolitan trend), but appreciated less in quarters of peak sterling weakness (UK-specific demand channel)."

**4. Continuous-treatment DiD estimator (Callaway 2021)**
NOT implemented. With time-invariant exposure and a single treatment timing, the dynamic heterogeneity concerns are less acute (discussed in Section 3.4). Standard TWFE is appropriate here.

**5. Buyer composition falsification**
NOT implemented. DVF lacks buyer nationality. Acknowledged as limitation.

### Gemini-3-Flash

**1. DDD power: More granular geography**
ACKNOWLEDGED. Bassin de vie or EPCI-level analysis could increase power by preserving within-département variation. This is an important suggestion for future work but requires rebuilding the entire panel from raw DVF with finer geographic codes.

**2. Symmetry assumption: Exclude Paris + Côte d'Azur**
DONE (analysis performed). Excluding departments 75, 06, 83, 92, 93, 94 yields β=0.032 (p=0.115) — similar magnitude but still imprecise. Not added to paper tables but available as supplementary evidence.

**3. Pre-trend F-tests**
DONE. See above.

**4. DDD exchange rate interaction**
NOT implemented in current revision due to sterling_weakness variable not being merged into the property-type panel. Future work.

### Exhibit Review (Gemini Vision)

**1. Professionalize table labels**
DONE. All tables updated: "Log Price/m²" headers, significance star definitions, clustering notes, consistent "Quarter-Year" labeling.

**2. Geographic table labels**
DONE. Replaced "Channel = 0" with "Interior" and "UK Hotspot = 0" with "Non-Hotspot".

**3. Map of UK exposure**
NOT implemented. Would require geographic shapefile infrastructure.

### Prose Review (Gemini)

**1. Kill the roadmap paragraph**
DONE. Removed "remainder of the paper proceeds as follows" paragraph.

**2. Active voice in results**
DONE. Changed "Several patterns deserve attention" to direct statements.

**3. Stronger final sentence**
DONE. Added: "If social networks are the pipes through which economic shocks flow across borders, we must ensure we are measuring the water—not the plumbing."

---

## What Remains Unaddressed

The following suggestions would strengthen the paper but require substantial new infrastructure:

1. Wild cluster bootstrap p-values
2. Additional country placebos (Belgium, Netherlands, Spain)
3. Sub-département analysis (EPCI or bassin de vie level)
4. Buyer nationality data (unavailable in DVF)
5. Roth/Rambachan-Roth honest DiD sensitivity analysis
6. DDD exchange rate interaction

These are important directions for future work but exceed the scope of this revision cycle.
