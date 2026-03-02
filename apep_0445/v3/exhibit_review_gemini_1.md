# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T20:31:14.377730
**Route:** Direct Google API + PDF
**Tokens:** 20997 in / 2566 out
**Response SHA256:** 9d6da8c6ea8ef296

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Professional and clean. Uses clear panel structures (A, B, C) to group variables. Decimal alignment is mostly consistent.
- **Clarity:** Excellent. It provides a quick snapshot of the differences between tracts just above and below the threshold.
- **Storytelling:** Essential. It establishes the "sharpness" of the poverty jump and the "fuzziness" of the OZ designation jump (Panel C).
- **Labeling:** Clear. The note is comprehensive, defining the MSE-bandwidth and data sources.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 13
- **Formatting:** Clean "modern" look. The McCrary test result is presented inside the plot area, which is standard.
- **Clarity:** High. The color change at the threshold helps the reader identify the bins.
- **Storytelling:** Critical for RD. It honestly shows the heaping/bunching at the 20% mark, which the author addresses in the text.
- **Labeling:** Axis labels and legend are clear. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Uses point sizes proportional to tract counts, which is best practice.
- **Clarity:** Clear jump visible. The confidence intervals on the bins help assess the precision of the first stage.
- **Storytelling:** Necessary to prove that the "instrument" (eligibility) actually leads to the "treatment" (designation).
- **Labeling:** "Probability of OZ Designation" on Y-axis is perfect.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "First Stage: Effect of Poverty Threshold on OZ Designation"
**Page:** 14
- **Formatting:** Standard three-line LaTeX table. Professional.
- **Clarity:** Easy to read. Reports the F-stat, which is essential for IV/Fuzzy RD.
- **Storytelling:** Supports Figure 2 with formal coefficients. 
- **Labeling:** Well-annotated significance stars and standard error notes.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Fuzzy RDD Estimates: Local Average Treatment Effect of OZ Designation"
**Page:** 15
- **Formatting:** Clean. Reports Wald estimates and 95% CIs.
- **Clarity:** Good. The null result is obvious as CIs cross zero.
- **Storytelling:** This is a "headline" table but it focuses on employment. 
- **Labeling:** Defines "Robust SE" and the use of `rdrobust`.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** Standard.
- **Clarity:** High. The p-values allow for a quick scan for imbalances.
- **Storytelling:** Shows the lack of balance in education/race, which the author correctly notes works "against" the null (strengthening the finding).
- **Labeling:** Sufficient.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Consistent with Table 3.
- **Clarity:** Redundant with Table 3? Table 3 is Fuzzy (LATE), Table 5 is Reduced Form (ITT). In RD papers, these are often shown in one table with panels.
- **Storytelling:** Strong. Shows the ITT is also a precise null.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Change:** Consolidate Table 3 and Table 5 into a single "Main Results: Employment Outcomes" table. Use Panel A for Reduced Form (ITT) and Panel B for Fuzzy RD (LATE). This saves space and allows for direct comparison.

### Figure 3 & Figure 4: "Reduced-Form RDD: Change in [Outcome] Employment..."
**Page:** 17
- **Formatting:** High quality. Consistent with Figure 2.
- **Clarity:** The flat lines through the threshold are the "money shot" for a null result.
- **Storytelling:** Essential visual proof.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Change:** These take up a lot of vertical space. Place them side-by-side as Panel A and Panel B of a single figure to allow for easier comparison between Total and Info sector employment.

### Table 6: "RDD Estimates: Effect of OZ Eligibility on Data Center Presence"
**Page:** 18
- **Formatting:** Consistent.
- **Clarity:** Very high.
- **Storytelling:** **This is the most important table in the paper.** It uses the new "direct" data.
- **Labeling:** Excellent. The note includes the "Base rate" and "MDE," which is crucial for interpreting a null.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Direct Data Center Presence at the 20% Poverty Threshold"
**Page:** 19
- **Formatting:** The Y-axis scale is very small (0.0% to 0.6%) because data centers are rare.
- **Clarity:** A bit "noisy" due to the low frequency of data centers, but the smooth lines help.
- **Storytelling:** Visual proof of the direct facility null.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Bandwidth Sensitivity: $\Delta$ Total Employment"
**Page:** 20
- **Formatting:** Professional.
- **Clarity:** Shows the estimate is stable across many bandwidths.
- **Storytelling:** Standard robustness.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** While important, the stability of the null is well-established. Moving this to the appendix improves the flow toward the placebo and event study results.

### Figure 6 & Figure 7: "Systematic Placebo Cutoff Tests"
**Page:** 20-21
- **Formatting:** High quality. 
- **Clarity:** Figure 7 (the histogram) is particularly effective at showing the true estimate is unremarkable.
- **Storytelling:** Powerful defense against the "bunching" concern noted in Figure 1.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Change:** Combine into one multi-panel figure. Figure 6 as Panel A, Figure 7 as Panel B.

### Figure 8: "Dynamic RDD: Year-by-Year Estimates"
**Page:** 22
- **Formatting:** Excellent. The use of colors for Pre- vs Post-OZ is helpful.
- **Clarity:** Shows no pre-trends and no delayed effects.
- **Storytelling:** Essential for the "Time-differenced" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (But promote to a more prominent position earlier in the results).

### Table 8: "Parametric RDD Specifications"
**Page:** 23
- **Formatting:** Slightly cluttered. Too many columns with high-digit standard errors.
- **Clarity:** Harder to parse than the nonparametric tables.
- **Storytelling:** Redundant with the `rdrobust` results which are generally preferred in top journals.
- **Labeling:** The note is very long.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** Nonparametric RDD is the modern standard. Parametric checks are secondary.

### Table 9: "Heterogeneity: Urban versus Rural Tracts"
**Page:** 24
- **Formatting:** Clean.
- **Clarity:** Direct.
- **Storytelling:** Important because it addresses the "infrastructure prerequisite" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Infrastructure Heterogeneity: RDD Estimates by Broadband Access"
**Page:** 25
- **Formatting:** Good.
- **Clarity:** The huge error bar on Q4 is distracting but honest.
- **Storytelling:** Very strong. It shows the null holds even where infrastructure is "ready."
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 10: "Local Randomization Covariate Balance"
**Page:** 34
- **Formatting:** Professional.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 34
- **Recommendation:** **REMOVE**
  - **Reason:** This is a visual version of Table 7. Having both in the appendix is redundant. Keep the table.

### Table 11, 12, 13, 14, 15: "Robustness Checks"
**Pages:** 35-37
- **Formatting:** High quality and consistent with the main text.
- **Recommendation:** **KEEP AS-IS**

### Figure 11: "Covariate Balance Figure"
**Page:** 37
- **Formatting:** Excellent "Coefficient Plot" style. 
- **Clarity:** Much easier to parse than Table 4.
- **Storytelling:** This is the most effective way to show balance.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reason:** Top journals (AER/QJE) love coefficient plots for balance. Replace Table 4 with this figure in the main text, or put them side-by-side.

---

## Overall Assessment

- **Exhibit count:** 9 main tables, 9 main figures, 6 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The figures are "clean" and use a consistent aesthetic (likely `ggplot2` or `stata` schemes). Tables follow the "Three-Line" rule (booktabs style) which is mandatory for top journals.
- **Strongest exhibits:** Figure 7 (Placebo distribution), Table 6 (Direct facility null), and Figure 11 (Balance plot).
- **Weakest exhibits:** Table 8 (Parametric OLS) and Figure 10 (Redundant bandwidth plot).
- **Missing exhibits:** A **map**! For a paper about Census tracts and geography, a map showing the distribution of data centers across the US or in a cluster (like Northern Virginia) relative to OZs would be very helpful for the "Institutional Background" section.

### Top 3 improvements:
1.  **Consolidate Result Tables:** Merge Table 3 (Fuzzy) and Table 5 (ITT) into one table with Panel A/B. This is the standard "AER style" for RD papers.
2.  **Visual Overhaul of Result Figures:** Place Figures 3 and 4 side-by-side. Group Figure 6 and 7. This reduces "scrolling fatigue" for the reader.
3.  **Add a Geospatial Figure:** Include a map in the main text showing data center locations geocoded from the EIA/EPA data. It proves the "innovation" of the paper (direct measurement) is real.