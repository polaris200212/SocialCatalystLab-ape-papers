# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T16:29:54.981999
**Route:** Direct Google API + PDF
**Tokens:** 20997 in / 2432 out
**Response SHA256:** f347992a89aa6e7f

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: HCBS Provider Panel"
**Page:** 9
- **Formatting:** Clean, professional LaTeX-style formatting. Good use of horizontal rules (booktabs style).
- **Clarity:** The layout is logical, comparing pre and post periods.
- **Storytelling:** Essential. It establishes the scale of the data and the raw trend (growth) that the identification strategy must account for.
- **Labeling:** Variable names are clear. Units (e.g., $M) are included. The note explains the dash for SDs.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Medicaid Unwinding Treatment Cohorts"
**Page:** 10
- **Formatting:** Good, consistent with Table 1.
- **Clarity:** Very high. Quickly shows the staggered timing and treatment intensity.
- **Storytelling:** Vital for the DiD identification. It justifies the four treatment cohorts.
- **Labeling:** All columns clearly labeled with units (%).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Main Results: Effect of Medicaid Unwinding on HCBS Providers"
**Page:** 13
- **Formatting:** Journal-ready. Decimal-aligned coefficients. Standard errors in parentheses.
- **Clarity:** High. Covers the primary and secondary outcomes in one view.
- **Storytelling:** This is the "money table." It provides the central null result across four key margins.
- **Labeling:** Significance stars defined. Notes explain the FEs and clustering.
- **Recommendation:** **REVISE**
  - Change "Num.Obs." to "Observations."
  - Explicitly state "Dependent Variable:" above the column headers to make it perfectly clear what the coefficients represent.

### Figure 1: "National HCBS Provider Counts Over Time"
**Page:** 14
- **Formatting:** Modern ggplot2 style. Gridlines are subtle but helpful here.
- **Clarity:** The massive drop at the end (late 2024/2025) is visually jarring and likely due to reporting lags in T-MSIS data, not a "collapse" (as it happens long after the unwinding).
- **Storytelling:** Useful for showing the secular trend, but the right-side cliff distracts from the main argument.
- **Labeling:** Legend and axis labels are clear.
- **Recommendation:** **REVISE**
  - **Truncate the x-axis:** If the data for late 2024 is incomplete due to claims lag, truncate the figure at June 2024. The current "cliff" at the end of the line suggests a catastrophic collapse that contradicts your paper's text.
  - Add a "Data Source" note directly on the figure or in the caption.

### Figure 2: "Event Study: Effect of Unwinding on Log HCBS Providers"
**Page:** 15
- **Formatting:** Professional. Shaded 95% CIs are standard.
- **Clarity:** The strong monotonic trend makes it hard to see a "break" at $k=0$.
- **Storytelling:** This exhibit actually highlights the *weakness* of the event study in this specific context (secular growth).
- **Labeling:** Clear axis titles and reference line at $k=-1$.
- **Recommendation:** **REVISE**
  - **Detrended Version:** Consider adding a second panel (Panel B) that shows the event study *after* removing the linear secular trend. This would make the null result at $t=0$ much more visually striking for a QJE/AER audience.

### Figure 3: "Callaway-Sant’Anna Dynamic ATT: Log HCBS Providers"
**Page:** 17
- **Formatting:** Good use of colors to distinguish pre/post.
- **Clarity:** This is much cleaner than Figure 2 because it handles the timing heterogeneity better.
- **Storytelling:** This is your strongest visual evidence of a null result. It shows the "pre-trend" is actually just noise around zero when using the robust estimator.
- **Labeling:** Clear legend.
- **Recommendation:** **KEEP AS-IS** (Consider promoting this to be Figure 2 and moving the TWFE version to the appendix).

### Table 4: "Treatment Intensity and Heterogeneity"
**Page:** 18
- **Formatting:** Consistent with Table 3.
- **Clarity:** Mixing intensity (cols 1-2) and heterogeneity (3-5) in one table is efficient.
- **Storytelling:** Supports the "robustness of the null" across different slices of the data.
- **Labeling:** Good notes.
- **Recommendation:** **REVISE**
  - Add "Panel A: Treatment Intensity" and "Panel B: Heterogeneity by Type" headers within the table to help the reader parse the different types of tests.

### Figure 4: "Treatment Intensity: Disenrollment Rate vs. Provider Change"
**Page:** 19
- **Formatting:** Scatter plot with state labels.
- **Clarity:** A bit cluttered with 50+ state labels.
- **Storytelling:** Excellent "visual check" on the dose-response relationship.
- **Labeling:** Axis labels include units.
- **Recommendation:** **REVISE**
  - Use "repel" for the state labels (e.g., `geom_text_repel` in R) to prevent text overlapping.
  - Highlight 2-3 "extreme" states (e.g., TX and PA) and lighten the labels for the others to reduce clutter.

### Figure 5: "Heterogeneity: Individual vs. Organizational HCBS Providers"
**Page:** 20
- **Formatting:** Clean line plot.
- **Clarity:** The indexing to 100 makes the comparison easy.
- **Storytelling:** Shows that both "large" and "small" providers followed the same trajectory.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Market Concentration Effects"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** Very high.
- **Storytelling:** Important for the IO/competition argument.
- **Labeling:** Coefficients clearly marked.
- **Recommendation:** **MOVE TO APPENDIX**
  - The text already establishes a null on the extensive margin (provider counts). Market concentration is a secondary mechanism. Move this to the appendix to keep the main text focused on "Resilience = Survival."

### Figure 6: "HCBS Market Concentration Over Time"
**Page:** 22
- **Formatting:** Line with IQR ribbon.
- **Clarity:** Good.
- **Storytelling:** Shows the stability of the market structure.
- **Labeling:** Y-axis explanation (10,000 = monopoly) is very helpful.
- **Recommendation:** **MOVE TO APPENDIX** (Keep with Table 5).

### Figure 7: "Placebo: HCBS vs. Non-HCBS Providers"
**Page:** 23
- **Formatting:** Two-line comparison.
- **Clarity:** The comparison is stark.
- **Storytelling:** This is a vital "sanity check" for the research design.
- **Labeling:** Clear legend.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Robustness Checks"
**Page:** 24
- **Formatting:** Summary table format.
- **Clarity:** Very efficient way to show 6 different models in one view.
- **Storytelling:** Essential for the "Econometrica/ReStud" level of rigor.
- **Labeling:** Footnotes clarify the different estimators and p-values.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Permutation Inference: 1,000 Random Reassignments"
**Page:** 25
- **Formatting:** Histogram with "Actual" line.
- **Clarity:** Immediate understanding of the p-value.
- **Storytelling:** Classic robustness exhibit.
- **Labeling:** Clear title and notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Leave-One-Out: Excluding Each State"
**Page:** 26
- **Formatting:** Dot plot with rank.
- **Clarity:** Shows that no single outlier (like CA or NY) is driving the result.
- **Storytelling:** High. Provides confidence in the stability of the estimate.
- **Labeling:** Y-axis clearly labeled.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 10: "Medicaid Unwinding Start Date by State"
**Page:** 37
- **Formatting:** US Choropleth map.
- **Clarity:** High. Shows the geographic distribution of treatment timing.
- **Storytelling:** Useful context for the variation.
- **Labeling:** Legend is clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This should be Figure 1 or 2 in the main text. Top journals like to see the "map of the experiment" early in the paper to understand the source of variation.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 9 main figures, 0 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The paper uses modern "Best Practices" for DiD (Callaway-Sant'Anna, Permutation tests, Leave-one-out). The tables are formatted to the standard of the "Top 5" journals.
- **Strongest exhibits:** Figure 3 (CS-DiD), Table 6 (Robustness Summary), and Figure 9 (Leave-one-out).
- **Weakest exhibits:** Figure 1 (due to the claims-lag cliff) and Figure 6 (redundant for main text).
- **Missing exhibits:** 
    - **A Summary Statistics Table for the State-Level Unwinding Data:** While Table 2 covers cohorts, a table showing the top/bottom 5 states by disenrollment rate would be helpful context.
    - **A Regression Table for the Appendix:** The paper mentions "Raw counts" and "Asinh" results in the text; these should be in a formal Appendix Table.

### Top 3 Improvements:
1. **Truncate Figure 1 and 2 at June 2024.** The "drop-off" at the end of the time series is almost certainly a data artifact (reporting lag) and undermines the "Resilience" narrative visually.
2. **Promote the Map (Figure 10) to the Main Text.** Place it in the "Institutional Background" or "Data" section to ground the identification strategy.
3. **Consolidate and Detrend Figures.** Group the Event Study (Fig 2) and CS-DiD (Fig 3) into a single two-panel figure. Add a detrended version of Fig 2 to show the "break" more clearly.