# Exhibit Review — Gemini 3 Flash (Round 3)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T15:43:04.820691
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1832 out
**Response SHA256:** cdbf9d6b7e9f6e24

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Generally clean. Uses horizontal booktabs style. 
- **Clarity:** Excellent. The grouping into Panels A, B, and C provides a logical flow from demographics to outcomes to treatment.
- **Storytelling:** Essential. It establishes the comparability of tracts across the threshold. 
- **Labeling:** Good, but "Info employment" should be "Information Sector Employment" for professional consistency. 
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** The gridlines are a bit heavy. The "OZ Eligibility Threshold" text is slightly small.
- **Clarity:** High. The color coding clearly distinguishes the sides of the cutoff.
- **Storytelling:** Vital for RDD. It shows the "heaping" mentioned in the text, which justifies the donut RDD robustness check.
- **Labeling:** The y-axis "Density" is appropriate. Subtitle contains the McCrary test, which is standard.
- **Recommendation:** **REVISE**
  - Lighten or remove vertical gridlines. Increase the font size of the "OZ Eligibility Threshold" label.

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** Standard RDD plot.
- **Clarity:** The bin sizes (points) are helpful. The confidence interval shading is clear.
- **Storytelling:** This is the most "problematic" exhibit in the paper because it shows the first stage is quite weak at the cutoff due to the author's approximation method. This is addressed in the text, but the figure highlights the limitation.
- **Labeling:** The y-axis label "Probability of OZ Designation" is clear.
- **Recommendation:** **KEEP AS-IS** (Essential for transparency).

### Table 2: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** Simple and effective. 
- **Clarity:** Logical. $p$-values are helpful for a quick scan.
- **Storytelling:** Redundant with Figure 8 (Appendix). 
- **Labeling:** "Pre-period total employment" should be formatted with commas for thousands.
- **Recommendation:** **KEEP AS-IS** (Table 2 is better for main text than Figure 8).

### Table 3: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Professional. Good use of panels to distinguish between levels and changes.
- **Clarity:** The 95% CI column is very helpful for the "precisely estimated null" argument.
- **Storytelling:** This is the paper's core result.
- **Labeling:** Significance stars explained in notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 17
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Good. The null result is visually obvious.
- **Storytelling:** This is the visual anchor for the main finding.
- **Labeling:** Legend "n 500 1000..." is slightly cluttered; could be labeled "Number of observations in bin."
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Reduced-Form RDD: Change in Information-Sector Employment at the Threshold"
**Page:** 18
- **Formatting:** Color change (green) is a nice touch to distinguish from total employment.
- **Clarity:** Clear, though the wide error bars on the right side of the plot should be noted (likely due to fewer tracts at high poverty).
- **Storytelling:** Directly addresses the "Data Center" sector.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Bandwidth Sensitivity: $\Delta$ Total Employment"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** The "Size (pp)" column is very helpful context for the bandwidth percentages.
- **Storytelling:** Robustness. 
- **Recommendation:** **MOVE TO APPENDIX** 
  - The text already summarizes that results are robust. To save main-text space for top journals, move this to the Appendix.

### Figure 5: "Placebo Cutoff Tests"
**Page:** 19
- **Formatting:** Clean "coefficient plot" style.
- **Clarity:** Excellent. The use of red for the true cutoff makes the point immediately.
- **Storytelling:** Strong evidence that the main result isn't a fluke of the threshold choice.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 20
- **Formatting:** Clear. 
- **Clarity:** The distinction between Pre-OZ and Post-OZ using color and the dashed vertical line is standard and effective.
- **Storytelling:** Critical for validating the parallel trends/pre-trend assumption in a dynamic context.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Parametric RDD Specifications"
**Page:** 21
- **Formatting:** Standard regression table.
- **Clarity:** Columns (1)-(3) vs (4)-(5) are clearly distinguished in the notes.
- **Storytelling:** Necessary robustness check to show nonparametric results hold in OLS.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard "double-check" table. Most top journals prefer the nonparametric plots and estimates in the main text.

---

## Appendix Exhibits

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 31
- **Formatting:** Good.
- **Clarity:** Visualizes Table 4.
- **Storytelling:** Redundant if Table 4 exists.
- **Recommendation:** **KEEP AS-IS** (But consolidate Table 4 here).

### Figure 8: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 32
- **Formatting:** "Forest plot" style.
- **Clarity:** Very high. 
- **Storytelling:** Visually confirms Table 2.
- **Recommendation:** **REVISE**
  - The x-axis label "Standardized RDD Coefficient (t-statistic)" is good, but the dotted red lines for $\pm 1.96$ should be more prominent.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The paper follows the modern "Cattaneo-style" RDD presentation standards perfectly. The visual language is consistent throughout.
- **Strongest exhibits:** Figure 5 (Placebo Cutoffs) and Table 3 (Main Results).
- **Weakest exhibits:** Figure 1 (due to heaping/density issues) and Table 5 (too cluttered for main text).
- **Missing exhibits:** 
  1. **Map of Opportunity Zones:** A paper on "place-based" policy almost always needs a geographic map showing the distribution of treated vs. control tracts, or at least a map of data center clusters.
  2. **Heterogeneity Table:** Section 6.4 discusses Urban vs. Rural heterogeneity but doesn't provide a table/figure. This should be added to the Appendix.

### Top 3 Improvements:
1. **Streamline Main Text:** Move Table 4 (Bandwidth) and Table 5 (Parametric) to the Appendix. Top journals (AER/QJE) prefer a leaner main text focused on the core identification and results.
2. **Add a Map:** Provide a geographic visualization of the sample and OZ designations to ground the "place-based" nature of the study.
3. **Refine Figure 1:** Address the density "heaping" more aggressively in the notes of Figure 1 to preempt reviewer concerns about running variable manipulation.