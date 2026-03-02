# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T10:55:37.949373
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 2368 out
**Response SHA256:** de39c60b557c5fbc

---

As a visual exhibit advisor for top-tier economics journals (AER, QJE, JPE, etc.), I have reviewed the tables and figures in your paper. Your exhibits are technically proficient but currently lack the "polish" and "density" expected in a top-five journal. 

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Pre-Treatment Municipality Characteristics (2011–2012)"
**Page:** 9
- **Formatting:** Generally clean. However, the $N$ column is inconsistent (781, 781, 781, 755, 768).
- **Clarity:** Logical layout comparing "Above 20%" to "Below 20%."
- **Storytelling:** Good. It immediately shows that treated municipalities are smaller and more tourism-dependent, justifying the RDD approach over a simple OLS comparison of means.
- **Labeling:** Clear. Good notes on data sources.
- **Recommendation:** **REVISE**
  - Use decimal alignment for all numbers. Currently, integers (781) and decimals (19.3) are center-aligned.
  - Add a "Difference" column (Above vs. Below) with a t-test of means. While RDD doesn't require balance across the full sample, it is standard practice to show the magnitude of the raw differences.

### Figure 1: "Distribution of Second-Home Shares Across Swiss Municipalities"
**Page:** 10
- **Formatting:** "Standard GGPlot" look. Too much grey gridline noise.
- **Clarity:** The message is clear—most data is on the left—but the bin width is a bit coarse.
- **Storytelling:** Vital for an RDD to show the density of the running variable.
- **Labeling:** "Number of Municipalities" on the y-axis is clear.
- **Recommendation:** **REVISE**
  - Make it journal-ready: Remove the background grey and minor gridlines. Use a "theme_bw()" or "theme_classic()" style.
  - The blue "20% Threshold" text is a bit informal. Use a black dashed vertical line and label it in the legend or a cleaner annotation.

### Figure 2: "McCrary Density Test at the 20% Threshold"
**Page:** 13
- **Formatting:** Color scheme (green/red) is a bit "Christmas-y" and may not print well in grayscale.
- **Clarity:** Shows the bunching concern well.
- **Storytelling:** Essential given the $p=0.043$ result.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Change colors to grayscale (e.g., solid black line vs. dashed black line or dark grey/light grey) to ensure readability in all formats.
  - Remove the background gridlines.

### Table 2: "McCrary Density Test at the 20% Threshold"
**Page:** 14
- **Formatting:** Too much white space. The table is very "skinny."
- **Clarity:** Provides the stats, but is it worth a standalone table?
- **Storytelling:** Supports Figure 2.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX** or **CONSOLIDATE**. This information can be placed in the notes of Figure 2. It doesn't deserve its own table in a main-text AER-style layout.

### Table 3: "Main RDD Estimates: Effect of Second-Home Construction Ban on Local Employment"
**Page:** 14
- **Formatting:** Professional. Good use of horizontal lines (no vertical lines).
- **Clarity:** Very high.
- **Storytelling:** This is the "Money Table." It delivers the precise null.
- **Labeling:** Good notes on SEs and $p$-values.
- **Recommendation:** **REVISE**
  - **Group these results.** You currently have three rows for three outcomes. Usually, top journals prefer these as Columns (1), (2), and (3). 
  - Put the "Kernel," "Polynomial order," and "Bandwidth selection" in the bottom panel of the table as rows rather than a list.

### Figure 3: "RDD Plot: Employment Growth at the 20% Threshold"
**Page:** 15
- **Formatting:** Clean but "default" looking.
- **Clarity:** The binning is clear.
- **Storytelling:** Essential visual proof of the null.
- **Labeling:** Y-axis label is a bit long; consider "Employment Growth (%)".
- **Recommendation:** **REVISE**
  - Increase the font size for axis labels. 
  - Remove the background grid.
  - Ensure the 95% CI shaded region is visible but not distracting (it’s a bit hard to see the right-hand side CI).

### Figure 4: "Event-Study RDD: Year-by-Year Treatment Effects on Log Employment"
**Page:** 16
- **Formatting:** Good use of a timeline.
- **Clarity:** The confidence interval "tube" is very wide, which is the honest way to show the result.
- **Storytelling:** Crucial for the "No Pre-Trends" argument.
- **Labeling:** "Initiative (March 2012)" annotation is excellent.
- **Recommendation:** **REVISE**
  - The y-axis scale is very wide (-2 to 3), making the point estimates look like a flat line. While this emphasizes the null, narrowing the scale slightly (e.g., -1 to 1) might allow the reader to see the yearly variation more clearly.

### Table 4: "Covariate Balance at the 20% Threshold"
**Page:** 17
- **Formatting:** Clean.
- **Clarity:** Excellent.
- **Storytelling:** Proves the local validity of the RDD.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Though consider consolidating with Table 1 as a "Balance Table" if page count is an issue).

### Figure 5: "Covariate Balance at the 20% Threshold"
**Page:** 18
- **Formatting:** Clear "Coefficient Plot" style.
- **Clarity:** Immediate visual confirmation of balance.
- **Storytelling:** Redundant with Table 4.
- **Recommendation:** **MOVE TO APPENDIX**. In top journals, you either show the table or the plot for balance. The table is more precise for reviewers; the plot is for presentations.

### Table 5: "Bandwidth Sensitivity: Employment Growth"
**Page:** 18
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Robustness check.
- **Recommendation:** **MOVE TO APPENDIX**. Figure 6 tells the same story more effectively.

### Figure 6: "Bandwidth Sensitivity: Employment Growth Estimates"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** Shows the stability of the coefficient.
- **Storytelling:** Essential robustness.
- **Recommendation:** **KEEP AS-IS** (but remove gridlines).

### Table 6: "Robustness: Polynomial Order and Kernel Sensitivity"
**Page:** 20
- **Formatting:** Good panel structure (Panel A and B).
- **Clarity:** High.
- **Storytelling:** Standard RDD robustness.
- **Recommendation:** **KEEP AS-IS**.

### Table 7: "Placebo Threshold Tests"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Logical.
- **Storytelling:** Excellent "negative control" test.
- **Recommendation:** **MOVE TO APPENDIX**. Figure 7 is sufficient for the main text.

### Figure 7: "Placebo Threshold Tests"
**Page:** 21
- **Formatting:** Good use of different colors/shapes for the "Actual" vs "Placebo."
- **Clarity:** Very clear.
- **Storytelling:** High impact.
- **Recommendation:** **KEEP AS-IS**.

### Table 8: "Donut-Hole RDD Estimates"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Addresses the density/sorting concern.
- **Recommendation:** **KEEP AS-IS** (Crucial given the McCrary result).

---

## Appendix Exhibits
*Note: The current PDF only contains text descriptions in the Appendix (A.1–D.2) but no actual tables/figures. This is a missed opportunity.*

- **Recommendation:** **ADD** the results mentioned in C.4 (Tourism Outcome) as a table. Even if the sample size is small ($N_{right}=3$), transparency requires showing the table.

---

# Overall Assessment

- **Exhibit count:** 6 main tables, 7 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** High technical competence. The exhibits follow the "Cattaneo et al." school of RDD visualization perfectly, which reviewers will appreciate. However, the paper is currently "over-exhibited" in the main text with 13 total items, leading to redundancy.
- **Strongest exhibits:** Table 3 (Main Results), Figure 4 (Event Study), Figure 7 (Placebo Plot).
- **Weakest exhibits:** Table 2 (Skinny/Redundant), Table 5 (Redundant with Fig 6).

### Missing Exhibits:
1. **Map of Switzerland:** You need a map showing which municipalities are "Above 20%" and "Below 20%." This is standard for any paper using geographic units of analysis. It helps the reader understand the "Alpine vs. Lowland" divide you mention.
2. **Raw Data Plot (Non-Binned):** A simple scatter plot of the outcome vs. the running variable (perhaps in the appendix) to show the underlying variation before binning.

### Top 3 Improvements:
1. **Consolidate for Density:** Merge the information in Table 2 into the notes of Figure 2. Move Figure 5 (Balance Plot) and Table 7 (Placebo Table) to the Appendix to reduce clutter.
2. **Journal Standard Styling:** Remove the "Grey Grid" background from all figures. Use `theme_classic()` in R/GGPlot. Top journals prefer a minimalist, white-background look.
3. **Table 3 Structure:** Pivot Table 3 so that outcomes are columns. This allows you to add rows at the bottom for "Mean of Dep. Variable," "Bandwidth," and "Observations," which is the expected format in AER/QJE.