# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T20:42:50.694124
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1890 out
**Response SHA256:** ec711ffbe8c50efc

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by EPC Band"
**Page:** 7
- **Formatting:** Clean and professional. Use of horizontal rules is appropriate (Booktabs style). Numbers are readable.
- **Clarity:** Excellent. Columns correspond to the natural ordering of the EPC bands (G to A).
- **Storytelling:** Critical for establishing the "modal" property (Band D) and showing that prices are broadly comparable across bands, supporting the local comparison.
- **Labeling:** Clear. Units (sq m, £, %) are explicitly stated.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of EPC Scores in Analysis Sample"
**Page:** 8
- **Formatting:** Modern and clean. The background grid is subtle.
- **Clarity:** Good. The overlay of band letters (G-A) at the bottom is very helpful. 
- **Storytelling:** Essential to show where the data is concentrated. It hints at the bunching later discussed in the robustness section.
- **Labeling:** Axis labels are clear. Legend for dashed lines is inside the plot area; might be cleaner as a standard figure note.
- **Recommendation:** **REVISE**
  - Change the y-axis label from "Number of Transactions" to "Frequency" or "Count".
  - Increase the font size of the EPC Band letters (G, F, E, etc.) at the bottom for better legibility.

### Table 2: "RDD Estimates at EPC Band Boundaries"
**Page:** 11
- **Formatting:** Standard journal format. 
- **Clarity:** Good. It clearly presents five separate RD designs in one table.
- **Storytelling:** This is the core "result" table. It highlights the E/F and A/B significance immediately.
- **Labeling:** Standard errors are correctly in parentheses. Significance stars are defined. 
- **Recommendation:** **REVISE**
  - Decimal-align the coefficients and standard errors. Currently, the minus signs for D/E and B/C push the numbers out of alignment with the positive coefficients.
  - Add a row for "Controls" (Yes/No) to make it explicitly clear that covariates mentioned in the notes are included in the estimation.

### Figure 2: "RDD Plots at EPC Band Boundaries"
**Page:** 13
- **Formatting:** Multi-panel layout is excellent. Colors are distinct but professional.
- **Clarity:** High. Binned means and local linear fits are standard and well-executed.
- **Storytelling:** Visually confirms the E/F jump and the lack of jump in C/D and B/C.
- **Labeling:** Titles for each panel are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Multi-Cutoff RDD Estimates"
**Page:** 14
- **Formatting:** Coefficient plot style is standard for top journals.
- **Clarity:** Very high.
- **Storytelling:** Summarizes Table 2 visually. Arguably redundant if Table 2 exists, but helpful for "10-second" parsing.
- **Labeling:** Well-labeled.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "EPC Label Effects by Period: Crisis Amplification"
**Page:** 15
- **Formatting:** Sparse. The "staircase" layout is a bit unusual and wastes a lot of white space.
- **Clarity:** Medium. It takes a moment to realize each "Estimate" row is a separate regression.
- **Storytelling:** Essential for the "Crisis" argument.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - Consolidate the rows. Instead of 12 "Estimate" rows, use 3 rows (E/F, D/E, C/D) and 4 columns (the time periods). This would be much easier to read horizontally.

### Figure 4: "EPC Label Effects Over Time"
**Page:** 16
- **Formatting:** Clean line plot.
- **Clarity:** High. Shows the divergence of E/F during the crisis.
- **Storytelling:** Much better at telling the "Crisis" story than Table 3.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Decomposition: Information vs Regulatory Effects at E/F Boundary"
**Page:** 17
- **Formatting:** Similar "staircase" issue as Table 3.
- **Clarity:** Low. The calculation of "Panel B" from "Panel A" requires too much mental math from the reader.
- **Storytelling:** Central to the paper's "Regulation vs Information" claim.
- **Labeling:** Notes are helpful.
- **Recommendation:** **REVISE**
  - Restructure to show the subtraction more clearly. A layout that has "Total Effect", "Info Effect (Benchmark)", and "Regulatory Residual" as rows would be more intuitive.

### Figure 5: "E/F Discontinuity by Tenure: Rental vs. Owner-Occupied"
**Page:** 18
- **Formatting:** High quality.
- **Clarity:** High. The contrast between the red (rental) and blue (owner) lines is the "smoking gun" of the paper.
- **Storytelling:** Most important figure for causal identification (placebo test).
- **Labeling:** Excellent.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "McCrary Density Tests at EPC Band Boundaries"
**Page:** 19
- **Formatting:** Journal-ready.
- **Clarity:** High.
- **Storytelling:** Necessary for RD validity.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Bandwidth Sensitivity of RDD Estimates"
**Page:** 20
- **Formatting:** Excellent use of shaded 95% CIs.
- **Clarity:** High.
- **Storytelling:** Standard robustness check.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Real vs. Placebo Cutoffs"
**Page:** 21
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** Demonstrates that the findings aren't random noise.
- **Labeling:** Color coding is effective.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 8: "McCrary Density Tests at Main EPC Boundaries"
**Page:** 32
- **Formatting:** Clean histograms.
- **Clarity:** High.
- **Storytelling:** Visualizes the results from Table 5.
- **Labeling:** p-values are clearly displayed in panel titles.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 7 main figures, 0 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The figures are "AER-ready" in terms of aesthetic and clarity. The tables are standard but could benefit from more compact layouts in the heterogeneity/decomposition sections.
- **Strongest exhibits:** Figure 5 (Tenure Placebo) and Figure 2 (RD Plots). These tell the entire story of the paper alone.
- **Weakest exhibits:** Table 3 and Table 4. The vertical "staircase" layout makes comparing across time periods or components unnecessarily difficult.
- **Missing exhibits:** 
    1. **Covariate Balance Table:** While mentioned in text (B.1), a table showing the RD estimates for floor area, age, etc., is standard for Econometrica/QJE. 
    2. **Map of Observations:** A small map of England showing the density of the 85k transactions would add "geographic" weight to the data section.

### Top 3 Improvements:
1.  **Restructure Tables 3 and 4:** Move away from the staggered row "staircase" format. Use columns for time periods and rows for coefficients to facilitate side-by-side comparison.
2.  **Decimal-Align Table 2:** This is a minor but "tell-tale" sign of professional formatting in top-5 journals. Ensure all coefficients are aligned on the decimal point.
3.  **Add a Covariate Balance Table to the Appendix:** Formally demonstrate that there are no jumps in "pre-determined" characteristics at the E/F boundary to silence concerns about sorting.