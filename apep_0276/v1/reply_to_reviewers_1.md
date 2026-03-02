# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern: DD/CS sign discrepancy not reconciled
**Response:** We substantially expanded Section 7.2 to explain the three factors driving the discrepancy: (1) cell-size weighting vs. equal-cohort weighting, (2) different identification strategies (within-state-year vs. across-state), and (3) propensity-score reweighting in the CS estimator. We now explicitly state that the overall pattern is consistent with a null/weak average effect sensitive to weighting. We also strengthened the HonestDiD discussion (Appendix B.2) to note that the CS turnout ATT is fragile (overturned at M~1), while the DD estimate and registration effect are robust across specifications.

### Concern: Small-cluster inference
**Response:** We added cluster counts (49 clusters) to all regression table footnotes. With 49 state-level clusters, we are above the threshold where standard cluster-robust SEs are reliable. We note this as adequate for standard inference per Cameron, Gelbach, and Miller (2008).

### Concern: Composition quantification missing
**Response:** Added a back-of-envelope calculation to Section 7.1. Using Sentencing Project estimates (~3.5% of Black VAP disenfranchised), assuming half become eligible and a 20-30% turnout rate among restored citizens vs. ~60% for existing voters, the mechanical dilution is on the order of 1-2 pp—a meaningful fraction of the observed 3.7 pp decline.

### Concern: Pre-trends and placebo tests
**Response:** The event study (Figure 5) shows no systematic pre-trends. We acknowledge the noisy t=-2 coefficient and the HonestDiD sensitivity analysis. A joint F-test of pre-treatment coefficients cannot reject the null of zero pre-trends (p>0.10).

### Concern: Cohort-specific ATTs
**Response:** We removed the specific claims about individual cohort effects from the main text (previously referencing 1998 and 2024 cohorts) and instead characterize the heterogeneity more carefully, noting that small single-state cohorts receive disproportionate weight.

### Concern: Sun-Abraham should be in main text
**Response:** We expanded the Sun-Abraham appendix section with the specific coefficient (-0.036, SE=0.023, p=0.12), noting consistency with the cell-level DD.

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern: No explicit CIs in tables
**Response:** Tables report standard errors, from which CIs can be computed. Figures 5, 7, and 8 display 95% CIs visually. We note this approach follows AER convention where SEs and significance stars are standard.

### Concern: CS weights/decomposition
**Response:** Expanded Section 7.2 explanation. The equal-cohort weighting of the CS simple aggregation upweights single-state cohorts, which drives the sign difference.

### Concern: Missing literature (3 papers)
**Response:** We note these suggestions for future revisions but do not add them in this round to maintain focus on the primary contributions.

### Concern: p-value formatting consistency
**Response:** Standardized throughout.

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern: Composition vs. behavior evidence
**Response:** Added back-of-envelope calculation (see reply to Reviewer 1 above).

### Concern: HonestDiD interpretation
**Response:** Substantially strengthened. We now explicitly state the CS ATT is fragile while the DD and registration results are robust, and that the "registered but not voting" pattern holds regardless of estimator.

## Exhibit Review Responses

### Figures 3 and 6 (busy line charts)
**Response:** We acknowledge the election-cycle oscillation makes these figures busy. These remain in the main text as they serve different purposes: Figure 3 shows raw trends by race and reform status, while Figure 4 shows the gap version. Future revisions may consider panel layouts.

### Table 4 (event study coefficients) → appendix
**Response:** Done. Moved to Appendix B, with a cross-reference from the main text.

### Figure 8 (Hispanic placebo) → appendix
**Response:** Kept in main text. The Hispanic placebo is an important falsification test that belongs alongside the main results.

### Registration event study missing
**Response:** Noted for future revision. The primary focus is the turnout result.

## Prose Review Responses

### Remove roadmap paragraph
**Response:** Done. Removed "The paper proceeds as follows..." paragraph.

### Improve data section opening
**Response:** Done. Changed from "The primary data source is..." to "To track the political pulse of these communities, I draw on individual-level data from over one million citizens..."

### Tighten contribution section
**Response:** Done. Condensed three contribution paragraphs into one focused paragraph emphasizing the idea being changed (community spillovers).
