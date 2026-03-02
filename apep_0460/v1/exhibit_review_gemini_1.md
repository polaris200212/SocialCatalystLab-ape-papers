# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T13:39:53.916028
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 2012 out
**Response SHA256:** 41e56002f3b9beb0

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Generally professional. Panel A and B are clearly delineated. Numbers are cleanly presented.
- **Clarity:** High. Provides a clear overview of the variation in the treatment (SCI) and the outcome variables.
- **Storytelling:** Essential. It establishes the "bite" of the data, specifically noting the wide variation in SCI to the UK.
- **Labeling:** Clear. The use of (e) for Euros is a bit non-standard (usually €); notes correctly define SCI and DVF.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Cross-Border Network Spillovers from Brexit to French Housing Markets"
**Page:** 14
- **Formatting:** Clean and professional. Significance stars are used correctly. Standard errors are in parentheses.
- **Clarity:** Good. It clearly shows the main result in Column 1 and the breakdown of timing in Column 2.
- **Storytelling:** Central to the paper. Column 3 (the "horse race" with Germany) is a bit messy because the coefficient names are inconsistently formatted (`post_referendum x log_sci_de` vs `Log SCI(UK) x Post-Referendum`).
- **Labeling:** Axis and column labels are clear.
- **Recommendation:** **REVISE**
  - Standardize variable names in the first column. Use "Log SCI(Germany) $\times$ Post-Referendum" instead of the snake_case `log_sci_de` to match the UK rows.

### Table 3: "Placebo Tests: UK Treatment vs. Germany and Switzerland"
**Page:** 15
- **Formatting:** Consistent with Table 2.
- **Clarity:** High. It isolates the different placebo tests effectively.
- **Storytelling:** Redundant. Most of this information is already in Table 2 or discussed in the text. Column 1 is identical to Table 2 Col 1. Column 3 is identical to Table 2 Col 3.
- **Labeling:** Good.
- **Recommendation:** **REMOVE** (Consolidate)
  - Merge the Switzerland result (Col 4) into Table 2 as a new column or move it to the Appendix. Table 2 already contains the critical Germany "horse race." Having two tables with 75% overlapping content slows the reader down.

### Figure 1: "Event Study: Housing Prices and UK Social Connectedness"
**Page:** 16
- **Formatting:** Professional ggplot2 style. Confidence intervals are clear.
- **Clarity:** Good. The $y$-axis label is descriptive. The dashed vertical line for the referendum is standard and helpful.
- **Storytelling:** Critical for identifying the timing of the effect and checking pre-trends. It highlights the $\tau=-4$ outlier honestly.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Permutation Inference: Randomized SCI Weights"
**Page:** 17
- **Formatting:** Clean histogram. The orange vertical line for the actual estimate is effective.
- **Clarity:** High. The viewer immediately sees that the result is in the tail.
- **Storytelling:** Strong robustness exhibit.
- **Labeling:** Excellent inclusion of the p-value and actual coefficient within the plot area.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Leave-One-UK-Region-Out Sensitivity"
**Page:** 18
- **Formatting:** Professional coefficient plot.
- **Clarity:** High. It clearly shows stability across different UK sub-regions.
- **Storytelling:** Good, though perhaps slightly "thin" for a main text figure.
- **Labeling:** "UK Country Excluded" is a clear $y$-axis.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check, but the main text is getting crowded with figures that essentially show the same 0.025 coefficient.

### Table 4: "UK Country Composition: Progressively Restricting Exposure"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** This is the tabular version of Figure 3.
- **Labeling:** Clear.
- **Recommendation:** **REMOVE**
  - This is entirely redundant with Figure 3. Since Figure 3 is more visually intuitive, keep the figure (but move it to the appendix) and drop this table.

### Figure 4: "Population-Weighted vs. Probability-Weighted SCI"
**Page:** 19
- **Formatting:** Clean but very simple (only two points).
- **Clarity:** High.
- **Storytelling:** This shows that the weighting choice doesn't matter.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a methodological point that can be handled in a single sentence in the main text.

### Figure 5: "Cross-Border Spillovers: Treatment vs. Placebo Countries"
**Page:** 20
- **Formatting:** Consistent with other figures.
- **Clarity:** High.
- **Storytelling:** A "money shot" figure that compares the treatment to the two placebos. 
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness: Alternative Specifications"
**Page:** 21
- **Formatting:** **INCOMPLETE.** The table is cut off on the right side. Columns 4 and 5 are missing, and coefficients for rows 2 and 3 are missing.
- **Clarity:** Low due to technical rendering error.
- **Storytelling:** Important for showing the results hold under different clustering and controls.
- **Labeling:** Notes are good.
- **Recommendation:** **REVISE**
  - Fix the LaTeX/rendering so the full table is visible. Ensure all coefficients are populated.

---

## Appendix Exhibits

### Figure 6: "Social Connectedness to the United Kingdom Across French Regions"
**Page:** 31
- **Formatting:** Map-based visualization. The "darker is stronger" note in the text contradicts the "Yellow is higher" color scale in the legend.
- **Clarity:** High.
- **Storytelling:** Essential "Figure 1" style exhibit.
- **Labeling:** Fix the note regarding color intensity.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals like QJE/AER expect a geographic visualization of the treatment early in the paper (Section 4).

### Figure 7: "UK Social Connectedness and Housing Price Changes"
**Page:** 32
- **Formatting:** A bit cluttered. Labels for every single département make the center of the cloud unreadable.
- **Clarity:** Moderate. The raw correlation is visible, but the overlapping text is distracting.
- **Storytelling:** Excellent "raw data" visualization.
- **Recommendation:** **REVISE**
  - Use a "repel" algorithm for labels or only label the outliers (Paris, Creuse, etc.) to clean up the center of the plot. Move this to the main text as a "Reduced-Form Evidence" figure before the regression tables.

### Table 6: "Permutation Inference: Randomization of SCI Exposure"
**Page:** 32
- **Formatting:** Simple.
- **Clarity:** High.
- **Storytelling:** Tabular version of Figure 2.
- **Recommendation:** **REMOVE**
  - Figure 2 is much more impactful and contains all the same information (p-value and coefficient).

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 5 main figures, 1 appendix table, 2 appendix figures.
- **General quality:** The visual identity is very strong and consistent. The paper uses a modern "clean" aesthetic that fits perfectly in AEJ or AER: Insights. However, there is significant redundancy between tables and figures.
- **Strongest exhibits:** Figure 1 (Event Study), Figure 2 (Permutation), Figure 6 (Map).
- **Weakest exhibits:** Table 5 (Rendering error), Table 4 (Redundant).
- **Missing exhibits:** A table or figure showing the **UK side of the data** (e.g., a map of the UK regions or a chart showing the sterling depreciation) would help ground the "shock" for the reader.

### Top 3 Improvements:
1.  **Consolidate and De-duplicate:** Remove Table 3, Table 4, and Table 6. They repeat information found in other exhibits. This will make the paper feel much tighter.
2.  **Fix Technical Errors:** Table 5 must be re-rendered to show all columns and coefficients. This is a "desk reject" level error if not fixed.
3.  **Optimize Flow:** Move Figure 6 (Map) and Figure 7 (Binscatter/Scatter) to the main text (Section 4 and 6 respectively). These provide the "visual proof" of the raw data before the reader gets to the complex regression tables.