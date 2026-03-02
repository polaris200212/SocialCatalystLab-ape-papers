# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T16:10:10.675064
**Route:** Direct Google API + PDF
**Tokens:** 22557 in / 1898 out
**Response SHA256:** c6cf1cd0f079cec1

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: RDD Sample"
**Page:** 11
- **Formatting:** Generally clean and consistent with top journals. Numbers are right-aligned. Clear use of panels (A-D).
- **Clarity:** Excellent. The logic moves from election characteristics to outcomes and then baseline covariates.
- **Storytelling:** Essential. It establishes the sample sizes (N=3,249 and N=2,034) which helps the reader interpret later effective sample sizes.
- **Labeling:** Good. Includes units (thousands, shares, etc.). 
- **Recommendation:** **REVISE**
  - Add decimal alignment for all columns to improve professional appearance.
  - In Panel B, clarify "Log NL" units or mention they are unitless in the notes.

### Table 2: "Main Results: Effect of Criminal Politician on Nightlights"
**Page:** 15
- **Formatting:** Standard AER/QJE style. Includes coefficients, standard errors, and p-values.
- **Clarity:** The column headers clearly distinguish the specifications.
- **Storytelling:** This is the "money" table of the paper. It highlights the reversal of the literature's benchmark finding.
- **Labeling:** Significance stars missing from the coefficients themselves (though defined in notes). 
- **Recommendation:** **REVISE**
  - **Crucial:** Add significance stars (*, **, ***) to the coefficients in the table rows. While p-values are present, top journals expect visual shorthand for significance.
  - The row "Eff. N (left/right)" is excellent; keep this as it is a hallmark of high-quality RDD reporting.

### Figure 1: "RDD Plot: Nightlights Growth by Vote Margin"
**Page:** 16
- **Formatting:** Professional. Shaded confidence intervals and binned means are standard.
- **Clarity:** The discontinuity is visible, though the "noisy" nature of binned means is apparent.
- **Storytelling:** Provides the necessary visual evidence for the discontinuity identified in Table 2.
- **Labeling:** Y-axis needs more frequent tick marks or a more descriptive label than just "Nightlights Growth" (e.g., "$\Delta$ Nightlights (Post-Pre)/Pre").
- **Recommendation:** **REVISE**
  - The dotted vertical lines for bandwidth boundaries are a bit light; darken them slightly.
  - Increase the font size of the axis labels to match the main text's readability.

### Table 3: "Mechanism Decomposition: Effect on Village Amenities..."
**Page:** 17
- **Formatting:** Consistent with Table 2.
- **Clarity:** Shows the "Private prosperity without public investment" story clearly across three outcomes.
- **Storytelling:** Central to the paper’s second contribution.
- **Labeling:** Same issue as Table 2—missing significance stars on the coefficients.
- **Recommendation:** **REVISE**
  - Add significance stars to the "Comm. Bank" coefficient.
  - Align columns better so the outcome names are centered over the statistics.

### Table 4: "Heterogeneity: Nightlights Growth by Subgroup"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** Logical split between BIMARU and reservation status.
- **Storytelling:** Explains *where* the effect is coming from (BIMARU states).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Add stars if following the Table 2/3 revision).

### Figure 2: "McCrary Density Test"
**Page:** 20
- **Formatting:** Standard output.
- **Clarity:** Clear visual evidence of no sorting.
- **Storytelling:** Essential for RDD validity.
- **Labeling:** Title and p-value in notes are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Covariate Balance at the RDD Cutoff"
**Page:** 21
- **Formatting:** Clean, but a bit sparse.
- **Clarity:** Very easy to read.
- **Storytelling:** Proves "as-if" random assignment.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - This information is summarized in the text and Figure 5. Main text space is better used for results. Table 9 is the more detailed version anyway.

### Figure 3: "Bandwidth Sensitivity: Nightlights Growth"
**Page:** 22
- **Formatting:** Clean, modern look.
- **Clarity:** Shows that the sign is stable even if significance fluctuates.
- **Storytelling:** Addresses the "bandwidth selection" contribution mentioned in the introduction.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Placebo Cutoff Tests"
**Page:** 23
- **Formatting:** Horizontal layout is clear.
- **Clarity:** High.
- **Storytelling:** Robustness check.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check that can be summarized in one sentence in the main text.

### Table 7: "Donut Hole Robustness"
**Page:** 23
- **Formatting:** Good.
- **Clarity:** Shows the fragility of the result to the closest races.
- **Storytelling:** Important for transparency, as the author admits this is a limitation.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Important for the "honesty" of the paper's results).

---

## Appendix Exhibits

### Table 8: "Variable Definitions" (p. 32)
- **Recommendation:** **KEEP AS-IS**. Essential for replication.

### Table 9: "Full Covariate Balance" (p. 33)
- **Recommendation:** **KEEP AS-IS**.

### Table 10-12: "Robustness Checks" (p. 33-34)
- **Recommendation:** **KEEP AS-IS**.

### Figure 4: "RDD Estimates for Village Amenity Outcomes" (p. 38)
- **Recommendation:** **PROMOTE TO MAIN TEXT**.
  - This coefficient plot is much more "10-second readable" than Table 3. It visualizes the nulls on public goods versus the bank decline perfectly.

### Figure 5: "Covariate Balance at the RDD Cutoff" (p. 39)
- **Recommendation:** **PROMOTE TO MAIN TEXT**.
  - Replace Table 5 with this figure. Top journals prefer visual balance checks.

### Figure 7: "Heterogeneity in the Effect of Criminal Politicians" (p. 41)
- **Recommendation:** **PROMOTE TO MAIN TEXT**.
  - This summarizes Table 4 and more. It is a very strong summary visual of the paper's heterogeneity results.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 3 main figures, 9 appendix tables, 4 appendix figures (Proposed: 3 main tables, 6 main figures).
- **General quality:** The tables are structurally sound and follow political economy norms. The figures are modern and clean but underutilized in the main text.
- **Strongest exhibits:** Table 2 (Main Results), Figure 3 (Bandwidth Sensitivity), Figure 7 (Heterogeneity Plot).
- **Weakest exhibits:** Table 5 (Redundant with Fig 5), Table 6 (Standard robustness, belongs in appendix).
- **Missing exhibits:** 
  1. **Map of India:** Highlighting BIMARU states and the intensity of criminal politicians by constituency. This is standard for papers on India (e.g., in *Econometrica* or *AER*).
  2. **Raw Data Scatter:** A simple scatter of Nightlights vs. Vote Margin before the local polynomial fit to show data density.

- **Top 3 improvements:**
  1. **Visual-First Strategy:** Swap Table 5 for Figure 5 and promote Figures 4 and 7 to the main text. Visualizing coefficients is more impactful for a "storytelling" approach.
  2. **Significance Stars:** Systematically add `***`, `**`, and `*` to all regression tables. While p-values are precise, the visual scanning of a table in a top journal relies on stars.
  3. **Table Consolidation:** Move the placebo and balance tables to the appendix. The main text should focus on the surprising nightlights growth and the mechanism decomposition.