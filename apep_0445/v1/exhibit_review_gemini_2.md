# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T15:38:40.329031
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1974 out
**Response SHA256:** f7831ff6066dc271

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Generally clean. However, the number of tracts and population figures should not have decimals. Values like "173,428" are correctly formatted, but the alignment in the "Above 20%" and "Full Sample" columns is slightly staggered.
- **Clarity:** Logical grouping into Panels A, B, and C. It clearly shows the baseline differences.
- **Storytelling:** Essential. It establishes that while there is balance on some dimensions, there are mechanical differences in poverty-correlated variables.
- **Labeling:** Good. Notes clearly define the bandwidth and time periods.
- **Recommendation:** **REVISE**
  - Ensure all columns are strictly decimal-aligned.
  - Remove decimals from "Number of tracts" and "Total population."
  - Add a note explaining what "$\Delta$" represents (though defined in text, tables should be self-contained).

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Modern and professional. The use of different colors for "Below" and "Above" is helpful.
- **Clarity:** The heaping at the 20% mark is immediately visible, which supports the author's later decision to use a donut RDD.
- **Storytelling:** Directly addresses the McCrary test and potential manipulation/heaping.
- **Labeling:** Axis labels are clear. The red dashed line for the threshold is standard and effective.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** Professional use of binned scatter points with confidence intervals and a linear fit.
- **Clarity:** Clearly shows the "weak" first stage near the cutoff, which is a vital caveat for the ITT interpretation.
- **Storytelling:** High value. It explains why the RD effect might be small (low treatment intensity jump).
- **Labeling:** "Probability of OZ Designation" is clear.
- **Recommendation:** **REVISE**
  - Increase the font size of the axis tick labels (10, 20, 30, 40) for better readability in print.

### Table 2: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** standard regression table format. Numbers are decimal aligned.
- **Clarity:** Efficient way to show multiple RDD tests.
- **Storytelling:** Supports the validity section. It honestly shows where the design fails balance (e.g., % White, Unemployment), which is common in poverty-threshold papers.
- **Labeling:** Defining "Robust SE" and "p-value" columns is helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Standard journal format. 
- **Clarity:** Panel structure (Levels vs. Changes) is excellent.
- **Storytelling:** This is the "Money Table." It delivers the null result clearly across multiple outcomes.
- **Labeling:** Significance stars are defined. CI is provided.
- **Recommendation:** **REVISE**
  - The "N" column should be consistent across rows or explained if it varies (likely due to different optimal bandwidths per outcome).
  - Add a row for "Mean of Dependent Variable" to help readers scale the coefficients.

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 17
- **Formatting:** Good use of point size to represent tract counts.
- **Clarity:** The message of "no jump" is clear in 10 seconds.
- **Storytelling:** Visual proof of the main result in Table 3.
- **Labeling:** Y-axis label is a bit long; consider "$\Delta$ Total Employment (2019-23 vs 2015-17)".
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Reduced-Form RDD: Change in Information-Sector Employment at the Threshold"
**Page:** 18
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High. Shows the null on the most "at-risk" sector.
- **Storytelling:** Crucial for the "Data Center" argument.
- **Recommendation:** **REVISE**
  - This figure and Figure 3 are essentially the same visualization for different outcomes. Consider merging them into **Figure 3, Panel A and Panel B** to save space and allow for direct comparison of scales.

### Table 4: "Bandwidth Sensitivity: $\Delta$ Total Employment"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** Shows the stability of the null.
- **Storytelling:** Standard robustness check. 
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard check that clutters the main text. The text can simply state "results are robust to bandwidth (Table C1)."

### Figure 5: "Placebo Cutoff Tests"
**Page:** 19
- **Formatting:** Unique and effective visualization of placebo estimates.
- **Clarity:** Very high.
- **Storytelling:** Strongest evidence against the result being a fluke of the 20% threshold.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 20
- **Formatting:** Professional event-study style plot.
- **Clarity:** Clear distinction between Pre and Post.
- **Storytelling:** Validates the parallel trends assumption and shows no delayed effect.
- **Recommendation:** **KEEP AS-IS** (Consider promoting to a more prominent spot earlier in the results section).

### Table 5: "Parametric RDD Specifications"
**Page:** 21
- **Formatting:** Standard OLS output.
- **Clarity:** A bit cluttered with the interaction terms.
- **Storytelling:** Shows the result holds with controls and different functional forms.
- **Recommendation:** **REVISE**
  - Use more descriptive labels than "Above Threshold $\times$ I(pov_centered^2)". 
  - Group columns better: Columns (1)-(3) for Total Emp, (4)-(5) for Info Emp.

---

## Appendix Exhibits

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** (Strong visual complement to the table).

### Figure 8: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 32
- **Formatting:** "Dot plot" style for t-stats is excellent for a summary view.
- **Clarity:** Very high.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals (AER/QJE) love these "Coefficient plots" for balance. Replace the dry Table 2 with this figure in the main text, or put them side-by-side as a Panel.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The figures are modern, use appropriate weighting (point size), and follow the "Cattaneo style" of RDD visualization which is the gold standard for top journals.
- **Strongest exhibits:** Figure 5 (Placebos) and Figure 8 (Balance Plot).
- **Weakest exhibits:** Table 4 (redundant for main text) and Table 5 (formatting is a bit "raw" compared to others).
- **Missing exhibits:** 
    - **A Map:** A map showing the geographic distribution of "Data Center Heavy" tracts vs. "OZ Designated" tracts would be very helpful for context.
    - **Infrastructure Balance:** Since the argument is that "infrastructure fundamentals" drive the result, the author should include an RDD balance test on "Fiber Proximity" or "Power Grid Capacity" to prove these don't jump at the threshold.

**Top 3 improvements:**
1. **Consolidate Results:** Merge Figures 3 and 4 into a single two-panel figure (Panel A: Total, Panel B: Information).
2. **Visual Balance:** Promote Figure 8 (Balance Plot) to the main text and move Table 4 (Bandwidth Table) to the appendix.
3. **Address Mechanisms Visually:** Add a figure or table showing balance on **infrastructure variables** (fiber, power) to bolster the "Infrastructure Dominance" claim in Section 6.5.