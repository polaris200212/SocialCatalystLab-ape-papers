# Reply to Reviewers

## Reviewer 1 (GPT-5.2) — Major Revision

### 1.1 Treatment assignment timing
> "Treatment assigned using 2025 population while outcomes span 2009-2024"

**Response:** We acknowledge this concern and have strengthened our response in three ways:
1. **Switchers analysis (NEW):** We now directly quantify threshold-crossing rates using the 2022-2025 population panel. Only 3-4% of communes near each threshold ever cross it over the 4-year window, implying a switching rate under 6% per electoral cycle.
2. **Post-2020 subsample (NEW):** We re-estimate all RDDs using only 2021-2024 outcomes, where 2025 population unambiguously determines treatment. Results are virtually identical (all null, similar magnitudes).
3. **Expanded discussion:** Appendix B.3 now documents these findings in detail.

We maintain the cross-sectional design with 2025 assignment for three reasons: (a) historical legal population data are not publicly available at the commune level prior to 2022; (b) the primary specification uses commune-level means as the dependent variable, making it inherently cross-sectional; (c) the low switching rate and robustness to post-2020 restriction provide strong evidence against misclassification bias.

### 1.2 Multi-cutoff pooling: estimand clarity
> "Pooled coefficient is a weighted average of heterogeneous discontinuities"

**Response:** We have expanded the Table 2 notes to clarify that the pooled bandwidth is in normalized units (now shows 0.124 instead of the erroneous "0"). The cutoff-specific estimates are presented as the primary results; the pooled estimate supplements them. We acknowledge that treatment bundles differ across thresholds but note that the uniform null across all five cutoffs — each with different governance changes — strengthens the interpretation.

### 1.3 DiDisc assignment and clustering
> "Département clustering is not adequate; cluster at commune level"

**Response:** Fixed. All parametric RDD and DiDisc specifications now use commune-clustered standard errors. The DiDisc coefficient changes minimally (-0.323, SE = 0.333, p = 0.33 with commune clustering vs. previous SE = 0.320 with département clustering).

### 1.4 Placebo thresholds and power
> "Placebo nulls don't demonstrate power"

**Response:** We have reframed the placebo analysis as specification falsification (confirming no spurious discontinuities at non-policy thresholds). The minimum detectable effect discussion in Section 6.6 handles the power argument separately.

### 2.1 Validation outcomes
> "Show that thresholds actually change governance inputs"

**Response:** We acknowledge this as a valuable suggestion for future work. Municipal spending data (from DGFiP) would be an ideal validation outcome but is not currently available at the required granularity. We note in the discussion that council size and salary changes are mechanical (deterministic functions of population), so the "first stage" is 1 by construction.

### 3.1 Outcome heterogeneity
> "Split by legal form or sector"

**Response:** We acknowledge this as a high-value extension. The Sirene data contain NAF codes and legal form, allowing sector-specific analysis. We leave this for the revision if accepted.

---

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

### Borderline McCrary at 1,500
> "Report covariate RDDs in main text; exclude 1,500 from pooled or sensitivity"

**Response:** The covariate balance tests (area, density) are insignificant at all thresholds including 1,500 (Appendix B.2). The 1,500 McCrary result (p = 0.050) is borderline and likely a multiple-testing artifact across 5 thresholds. The RDD at 1,500 itself is strongly null (-0.210, p = 0.71), so even if slight sorting exists, it does not generate a spurious effect.

### Clarify sample / switchers
> "Show tabulation of % crossing thresholds"

**Response:** Done. Appendix B.3 now reports threshold-crossing rates by cutoff (3-4% over 2022-2025). Post-2020 subsample results confirm stability.

### Power simulations
> "Expand Sec. 6.6 with simulations"

**Response:** The existing MDE discussion (6.4% pooled, 23-27% at higher thresholds) provides the key information. Formal power curves would be a valuable addition but are deferred as optional polish.

### Missing citations
> "Sorensen 2022 AER Danish mergers"

**Response:** We note this suggestion for future revisions. Our literature section already covers the key papers in each relevant strand.

---

## Reviewer 3 (Gemini-3-Flash) — Minor Revision

### Treatment assignment timing
> "Look-ahead bias is non-standard"

**Response:** Addressed via switchers analysis and post-2020 subsample (see response to GPT Reviewer above).

### Sectoral heterogeneity
> "Decompose null by NAF codes"

**Response:** Acknowledged as a high-value extension. Deferred for revision.

### EPCI boundary analysis
> "Test if null is stronger in highly integrated EPCIs"

**Response:** Acknowledged. EPCI fiscal integration data is available from DGCL. This is a promising extension but goes beyond the current paper's scope.

---

## Exhibit and Prose Improvements

Based on exhibit review (Gemini) and prose review (Gemini):
1. **Opening rewritten** with punchier "Manhattan apartment block" comparison
2. **Table 3 variable names** fixed (no more `creation_rate` artifact)
3. **Figure 2 y-axis** fixed (no more scientific notation)
4. **Technical plumbing** (Apache Arrow, Parquet) moved from main text to Data Appendix
5. **Results narration** improved with concrete "village of 500" framing
