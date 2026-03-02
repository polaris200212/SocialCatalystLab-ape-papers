# Exhibit Review — Gemini 3 Flash (Round 4)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T15:46:17.473902
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 2243 out
**Response SHA256:** 581b600b10780bf7

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Professional and clean. Uses standard LaTeX booktabs style. Numbers are generally well-aligned, though Panel A decimals could be more consistent (e.g., 3894 vs 15.4).
- **Clarity:** Excellent. The comparison between "Below 20%" and "Above 20%" immediately conveys the balance (or lack thereof) near the cutoff.
- **Storytelling:** Essential. It establishes the sample composition. Using a bandwidth-restricted sample for summary stats is best practice in RDD papers.
- **Labeling:** Clear. Units (%) are included. Notes are comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Good use of color to distinguish sides of the threshold. The "McCrary test" result in the subtitle is standard for top journals.
- **Clarity:** High. The heaping at round numbers (10, 20, 30) is clearly visible, supporting the author's discussion of "round number heaping" versus "strategic manipulation."
- **Storytelling:** Necessary for RDD validity.
- **Labeling:** Axis labels are clear. Red dashed line for the threshold is intuitive.
- **Recommendation:** **REVISE**
  - Increase the font size of the axis labels and McCrary test results to ensure readability in a printed journal column.
  - Remove the background gridlines to give it a cleaner "AER-style" look.

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** Standard binned scatter plot. Point sizes correctly reflect the number of observations.
- **Clarity:** The key message—that the first stage is weak at the cutoff but grows with poverty—is clear. 
- **Storytelling:** This is a "honesty exhibit." It explains why the author focuses on ITT (reduced-form) rather than Fuzzy RDD. This transparency is highly valued in Econometrica/AER.
- **Labeling:** "0%" and "50%" on the Y-axis are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** Clean. Standard error parentheses and p-value column are standard.
- **Clarity:** Logic is sound; grouping pre-determined variables to check for discontinuities.
- **Storytelling:** This identifies the "threats to validity." The significant jumps in education and race are problematic for a pure RDD but the author addresses this in the text.
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Add a column for the "Mean" of each variable to help readers interpret the magnitude of the "RDD Estimate" (e.g., is -85 population a big or small jump?).

### Table 3: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Excellent. Use of Panels A and B to separate levels and changes is a standard "Top 5" technique.
- **Clarity:** Very high. The confidence intervals being included in the table (rather than just SEs) makes the null result easier to verify visually.
- **Storytelling:** This is the "money table." It delivers the core result of the paper.
- **Labeling:** Significance stars and notes are perfect.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 17
- **Formatting:** High quality. Error bars for each bin mean are a nice touch.
- **Clarity:** The flat line through the threshold is unmistakable.
- **Storytelling:** Visual proof of the main result in Table 3.
- **Labeling:** Y-axis title is a bit long; could be shortened.
- **Recommendation:** **REVISE**
  - Simplify the Y-axis label to "$\Delta$ Total Employment (2019-23 vs 2015-17)".
  - Consider merging this with Figure 4 as Panel A and Panel B of a single "Main Results" figure to save page space.

### Figure 4: "Reduced-Form RDD: Information Sector (NAICS 51) Employment Change"
**Page:** 18
- **Formatting:** Consistent with Figure 3.
- **Clarity:** Good. The green color distinguishes it from the total employment figure.
- **Storytelling:** Shows the result for the most relevant sector for data centers.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Combine with Figure 3 into a single multi-panel figure (Figure 3A: Total Employment, Figure 3B: Info Employment).

### Table 4: "Bandwidth Sensitivity: $\Delta$ Total Employment"
**Page:** 18
- **Formatting:** Logical layout.
- **Clarity:** Shows the robustness of the null across various bandwidths.
- **Storytelling:** Standard robustness check.
- **Labeling:** "Size (pp)" is clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check that can be summarized in one sentence in the text. Figure 7 in the appendix already shows this more effectively.

### Figure 5: "Placebo Cutoff Tests"
**Page:** 19
- **Formatting:** Professional. Red vs. Grey distinction works well.
- **Clarity:** Shows that the 20% result is part of a distribution of zeros at higher poverty levels.
- **Storytelling:** Essential for RDD papers to prove the result isn't a fluke of the threshold.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 20
- **Formatting:** Clean. Color coding for pre/post period is helpful.
- **Clarity:** The "flatness" across time is very clear.
- **Storytelling:** Strongest evidence against "delayed effects." 
- **Labeling:** The red vertical line for 2018 (program start) is essential.
- **Recommendation:** **KEEP AS-IS** (Wait, move the "Pre-period estimates..." note to the figure note below instead of floating it in the plot area).

### Table 5: "Parametric RDD Specifications"
**Page:** 21
- **Formatting:** Standard OLS table.
- **Clarity:** Slightly cluttered due to the number of rows (interactions and covariates).
- **Storytelling:** Shows the result holds with controls.
- **Labeling:** Column numbers (1)-(5) are clear.
- **Recommendation:** **REVISE**
  - Use "Controls: Yes/No" rows at the bottom instead of printing all the covariate coefficients (Population, % White, etc.). This makes the table much tighter and focuses the reader on the "Above Threshold" row.

### Table 6: "Heterogeneity: Urban versus Rural Tracts"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** Good.
- **Storytelling:** Crucial for the data center story (since data centers need urban infrastructure).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 32
- **Formatting:** Good.
- **Clarity:** Clearer than Table 4.
- **Storytelling:** Robustness.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 33
- **Formatting:** Standard "Love Plot" / Coefficient plot.
- **Clarity:** Very high. Immediately shows which variables are "unbalanced."
- **Storytelling:** Summarizes Table 2 visually.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is often more effective than Table 2 for the main body of a paper in AEJ or AER: Policy.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 2 appendix figures
- **General quality:** High. The exhibits follow the visual language of modern empirical microeconomics (Cattaneo-style RDD plots, clean binned scatters, and structured panels).
- **Strongest exhibits:** Table 3 (Core Results) and Figure 6 (Event Study).
- **Weakest exhibits:** Table 5 (Parametric specs are too long/cluttered) and Table 4 (redundant with Figure 7).
- **Missing exhibits:** 
  1. **A map:** Since this is a place-based policy paper, a map showing the spatial distribution of the "Poverty RDD Sample" or the location of data centers relative to OZs would be very impactful.
  2. **First Stage Table:** While Figure 2 shows the first stage, a table quantifying the "Jump" in designation probability at the 20% threshold (even if weak) is standard.

### Top 3 Improvements:
1. **Consolidate Figures 3 and 4:** Merge them into a single two-panel figure for the main result. It makes the "Total" vs "Sector-Specific" comparison much tighter.
2. **Streamline Table 5:** Use "Yes/No" indicators for covariates. Top journals rarely want to see the coefficients of the controls (like % Bachelor's) unless they are the focus.
3. **Add a Map:** Visualizing the geographic intensity of data center investment vs. OZs would move this toward QJE/AER quality.