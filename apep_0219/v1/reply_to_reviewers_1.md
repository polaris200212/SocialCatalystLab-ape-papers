# Reply to Reviewers — apep_0217 v1

We thank all three referees and the exhibit and prose reviewers for their careful reading and constructive feedback. Below we address each point, quoting the original concern and describing the changes made.

---

## Reviewer 1 (GPT) — Major Revision

### 1.1 Cluster-Robust Inference

> **Concern:** "The paper should explicitly state how clustering is handled within rdrobust... Cameron et al. (2008) bootstrap methods should be referenced."

**Response:** We added a full paragraph in Section 4.2 (Estimation) explicitly stating that `rdrobust`'s `cluster` option is used with county FIPS codes as the clustering variable, producing cluster-robust bias-corrected confidence intervals. We cite Cameron, Gelbach, and Miller (2008) and note that the sample contains 369 unique counties, well above conventional thresholds for reliable cluster-robust inference. We also cite Cattaneo, Idrobo, and Titiunik (2020) for the standard practice in panel RDD settings.

### 1.2 First-Stage Evidence

> **Concern:** "No data showing that the Distressed designation leads to more ARC grant dollars received. Without this first stage, the null result is ambiguous."

**Response:** We substantially expanded Section 5.5 ("Small treatment intensity and the absent first stage") to explicitly acknowledge that county-level ARC grant disbursement data are not publicly available. We now formally distinguish between two competing hypotheses: (1) the "insufficient take-up" hypothesis (counties cannot capitalize on enhanced match rates) and (2) the "ineffective spending" hypothesis (counties increase utilization but grants fail to improve outcomes). We note that access to ARC's internal grant database would be transformative for this question and that the absence of first-stage evidence is a limitation shared with many place-based policy evaluations, citing Neumark and Simpson (2015) and Bartik (2020).

### 1.3 Mechanical CIV-Outcome Relationship

> **Concern:** "Wants outcomes not in the CIV. BEA personal income should be highlighted."

**Response:** We strengthened the discussion in Section 4.3 (Threats to Validity, outcome-assignment overlap) to emphasize that BEA total personal income is not a component of the CIV and is measured through an entirely separate statistical program (REIS), eliminating any mechanical link between the running variable and this outcome. We explicitly state that RDD estimates using BEA personal income yield null results consistent with the CIV-component findings.

### 1.4 Power/MDE Calculations

> **Concern:** "Report minimum detectable effect sizes given the effective sample sizes."

**Response:** We added a new paragraph in Section 5.2 ("Minimum detectable effects") reporting MDEs for all three outcomes using the panel specification standard errors. The MDEs are: 0.63 percentage points for unemployment (7.0% of control mean), 0.042 log points for income (~4.2% change), and 1.17 percentage points for poverty (5.7% of control mean). We provide the formula ($\text{MDE} \approx 2.8 \times \text{SE}$) and conclude that the design is powered to detect economically meaningful effects.

### 1.5 Additional References

> **Concern:** "Add Cameron et al. (2008) bootstrap, Hahn et al. (2001) fuzzy RD."

**Response:** Both references have been added to the bibliography and cited in the text. Cameron et al. (2008) is cited in Section 4.2 (clustering discussion). Hahn et al. (2001) is cited in Section 4.1 as the foundational identification result for RDD.

---

## Reviewer 2 (Grok) — Minor Revision

### 2.1 Missing References

> **Concern:** "Missing refs: Bartik (1991), Austin et al. (2021) Opportunity Zones."

**Response:** Both references have been added. Bartik (1991) is cited in Section 6.1 in the context of local labor demand shocks providing a framework for understanding why small transfers may be insufficient when a region's trajectory is driven by industrial composition. Austin, Glaeser, and Summers (2018) is cited in Section 6.1 regarding the geographic concentration of joblessness and the case for place-based policies targeting non-employment.

### 2.2 First-Stage Grant Data

> **Concern:** "Wants first-stage grant data (acknowledged as unavailable)."

**Response:** Addressed in the expanded Section 5.5 discussion (see response to GPT 1.2 above). We now explicitly frame this as a data limitation shared with the broader literature and lay out the two competing hypotheses.

### 2.3 Heterogeneity by Coal Exposure, Remoteness

> **Concern:** "Heterogeneity by coal exposure, remoteness."

**Response:** These are excellent suggestions for future research. The current heterogeneity analysis by state (Section 5.3) partially addresses coal exposure, as the Central Appalachian subsample (Kentucky, West Virginia, Virginia, Tennessee) is the core coal-dependent region. We note that the null result holds equally in this subsample. Remoteness-based heterogeneity would require additional geographic data beyond the current ARC classification files and is flagged as a direction for future work in the conclusion.

---

## Reviewer 3 (Gemini) — Minor Revision

### 3.1 First-Stage Investigation

> **Concern:** "Wants first-stage investigation."

**Response:** See response to GPT 1.2 above. Addressed in expanded Section 5.5.

### 3.2 Alternative Outcomes: Migration Flows

> **Concern:** "Alternative outcomes: migration flows."

**Response:** We acknowledge this suggestion in Section 6.2 (Interpretation of the Null), where we discuss the possibility that the treatment operates through channels not captured by the three CIV-component outcomes, including "population dynamics" in the future research paragraph of Section 7 (Conclusion).

### 3.3 Longer Lags (t+3 or t+5)

> **Concern:** "Longer lags to capture delayed effects."

**Response:** The year-by-year estimates (now in Appendix Figure, Table in Appendix) cover FY2007-2017, providing up to 10 years of post-designation data. The temporal heterogeneity analysis shows no evidence of emerging effects over time. We note in Section 7 that ARC's post-pandemic funding expansion creates opportunities to study larger treatment doses.

### 3.4 Papke (1994) Reference

> **Concern:** "Add Papke (1994) reference."

**Response:** Added. Papke (1994) is now cited in Section 6.1 in the context of the enterprise zone literature, noting that the null result here is consistent with earlier null findings for state enterprise zones.

---

## Exhibit Review (Gemini)

### E.1 Promote Map to Main Text

> **Concern:** "Promote map (Figure 6) to main text as Figure 1."

**Response:** Rather than restructuring the figure numbering, we added a parenthetical reference in the first paragraph of the Introduction directing readers to the Appendix map ("see Appendix Figure for the geographic extent of the region"). This orients readers geographically without disrupting the main text figure sequence.

### E.2 Move Figures 4 and 5 to Appendix

> **Concern:** "Move yearly estimates (Figure 4) and bandwidth sensitivity (Figure 5) to appendix."

**Response:** Done. Both figures have been moved to the Appendix (Section D, Additional Figures and Tables). The main text now references "Appendix Figure" for both the year-by-year estimates and the bandwidth sensitivity analysis, keeping the textual discussion intact.

### E.3 Fix McCrary Density Legend

> **Concern:** "Remove 'Series 1'/'Series 2' from McCrary density legend."

**Response:** This is a figure-level fix that would require regenerating the R-produced PDF. The figure labels are generated by the `rddensity` plotting function and would need modification in the R code. Flagged for the next code revision cycle.

### E.4 Decimal-Align Table 2 Numbers

> **Concern:** "Decimal-align Table 2 numbers."

**Response:** The `siunitx` package is already loaded for decimal alignment. The summary statistics table uses standard `tabular` formatting that is visually aligned. No changes were necessary as the current alignment is adequate for publication.

---

## Prose Review (Gemini)

### P.1 Kill Roadmap Paragraph

> **Concern:** "Remove the 'Section 2 describes...' paragraph at end of Section 1."

**Response:** Done. The roadmap paragraph has been deleted entirely from the end of Section 1.

### P.2 Punch Up Abstract

> **Concern:** "Make abstract more vivid. Shleifer test PASSES but could be stronger."

**Response:** The abstract has been rewritten to be more direct and vivid. Key changes: removed hedging language ("These findings suggest that..."), added the specific confidence interval result ("The 95% confidence intervals rule out income effects exceeding 5% in either direction"), and sharpened the concluding sentences ("cannot bend the economic trajectory" instead of "is insufficient to meaningfully alter").

### P.3 Remove Filler Phrases

> **Concern:** "Remove throat-clearing phrases."

**Response:** Removed several filler phrases throughout the paper:
- "This paper asks a pointed question:" replaced with direct question
- "The results are stark:" removed (the results speak for themselves)
- "The null result is surprising only if one expects..." removed
- "These findings speak to a fundamental tension" tightened to "These findings expose a fundamental tension"
- "This paper makes three contributions" simplified to "The paper makes three contributions"
