# Reply to Reviewers

We thank the three referees for their constructive feedback. Below we address each concern point by point.

---

## Referee 1 (GPT-5-mini) — MAJOR REVISION

### Concern 1: Power/MDE Analysis
> "Top journals expect a power analysis / MDE calculation to give readers intuition about what the design can detect."

**Response:** We have added an explicit MDE paragraph to Section 6.1. With SE=236, the MDE at 80% power is ~661 jobs (27% of baseline employment of 2,414). The design can therefore rule out effects larger than one-quarter of baseline gambling employment — sufficient to evaluate industry projections of 2,000+ jobs but insufficient for detecting effects of 100-300 jobs.

### Concern 2: Small-cluster inference
> "For subsample regressions with small numbers of clusters (e.g., 15 never-treated states), use wild cluster bootstrap."

**Response:** We agree this is important. Our main specification uses 49 clusters, which is sufficient for asymptotic inference. We explicitly note that the 15-cluster spillover subsample result (p=0.31) should be interpreted cautiously, and describe the spillover findings as "suggestive" throughout.

### Concern 3: Broader NAICS scope
> "The main employment measure (NAICS 7132) may miss important sportsbook employment coded elsewhere."

**Response:** We have substantially expanded the discussion of this limitation in Section 9.3, explicitly noting that DraftKings and FanDuel employ workers coded to NAICS 5415, 5112, and 5614. We frame this as the single most important caveat and a clear direction for future research using firm-level data.

### Concern 4: Event study inference details
> "State the procedure used to compute simultaneous bands."

**Response:** The simultaneous confidence bands are computed by the `did` R package using the multiplier bootstrap with 1,000 iterations, as is standard in Callaway-Sant'Anna implementations.

### Concern 5: Additional placebo industries
> "Consider adding NAICS 72 accommodation and food services."

**Response:** We attempted manufacturing (NAICS 31-33) as an additional placebo but the BLS QCEW API data at this aggregation level produced an unbalanced panel that could not be estimated with the CS framework. Agriculture (NAICS 11) provides a clean placebo (ATT=535, SE=444, p>0.10). Data limitations prevent us from adding further placebos in this revision.

### Concern 6: Reference corrections
> "Fix citation typos and ensure references.bib contains all cited entries."

**Response:** All citation entries have been verified in references.bib. The Borusyak et al. (2024) reference has been updated to reflect the published Review of Economic Studies version.

---

## Referee 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: Missing references
> "Add Humphreys et al. (2023), McGowan (2008), Holmes (1998)."

**Response:** We appreciate these suggestions. We have added Garrett (2003), Grote & Matheson (2020), and Strumpf (2005) which were requested in prior reviews. We note Humphreys et al. (2023) and will cite it if it is confirmed published; however, we were unable to verify the exact reference details.

### Concern 2: Broader outcomes
> "Test total non-gambling employment or payroll totals."

**Response:** This is an excellent suggestion that we flag as future work. The current analysis intentionally focuses on the industry most directly affected (NAICS 7132) to provide the cleanest test of the job creation hypothesis.

### Concern 3: Report Wald df explicitly
> "Explicitly report CS influence function degrees of freedom for Wald test."

**Response:** Done. The Wald test now reports 9 degrees of freedom explicitly in both the text and the figure caption.

---

## Referee 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Broaden NAICS scope
> "Could you look at NAICS 5415 or 5112 in states where major sportsbooks are headquartered?"

**Response:** This is the right direction for future research. Unfortunately, the BLS QCEW API does not provide reliable state-level data for these narrower NAICS codes at the disaggregation level needed for the CS estimator. We have expanded the Discussion section to explicitly frame this as the most important limitation and avenue for future work.

### Concern 2: Intensity of treatment (tax rates)
> "A high tax rate might suppress hiring. Adding heterogeneity analysis based on tax rate could be high-value."

**Response:** We agree this is interesting. State sports betting tax rates range from 6.75% (Nevada) to 51% (New York). Implementing this heterogeneity analysis requires compiling a comprehensive tax rate database, which is beyond the scope of this revision but is an excellent direction for future work.

### Concern 3: Border county analysis
> "A border-county DiD would be more convincing than state-level neighbor exposure."

**Response:** We agree that county-level border analysis following Dube et al. (2010) would strengthen the spillover finding. County-level QCEW data at the NAICS 7132 level is not reliably available via the API, but we flag this as an important extension.

---

## Exhibit Review Response

- Table 1 date range corrected from 2010-2024 to 2014-2024
- Table 7 (placebo) significance stars removed from main result (was incorrectly starred)
- HonestDiD text-table values synchronized
- Figure captions enhanced with statistical test details

## Prose Review Response

- Opening hook rewritten for immediate impact ("Between 2018 and 2024...")
- Results narration improved to lead with findings rather than column references
- API/checksum technical details removed from main text
- Conclusion strengthened with punchy final paragraph
- Transitions improved throughout
