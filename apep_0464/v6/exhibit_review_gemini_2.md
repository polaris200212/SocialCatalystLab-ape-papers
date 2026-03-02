# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-02T16:13:14.192341
**Route:** Direct Google API + PDF
**Tokens:** 27757 in / 2317 out
**Response SHA256:** 0cafca468085d005

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Fuel Vulnerability by Département"
**Page:** 8
- **Formatting:** Clean map; the Viridis color scale is professional. Gridlines behind the map are slightly distracting and unnecessary for a map.
- **Clarity:** The message is clear—vulnerability is concentrated in the rural center.
- **Storytelling:** Essential "shift" visualization for the shift-share design. 
- **Labeling:** Legend is clear. Units ($tCO_2/worker/year$) are correctly specified.
- **Recommendation:** **REVISE**
  - Remove background gridlines and axis ticks (lat/long) as they add no economic value to a thematic map.

### Figure 2: "Network Fuel Exposure by Département"
**Page:** 9
- **Formatting:** Consistent with Figure 1. 
- **Clarity:** Clearly shows how the "network" measure smooths out the geographic variation compared to Figure 1.
- **Storytelling:** Essential "exposure" visualization. It effectively shows the "northern industrial belt" as the high-exposure region.
- **Labeling:** Title and notes are descriptive.
- **Recommendation:** **REVISE**
  - Remove background gridlines. Ensure the color scale limits are the same as Figure 1 if you want to emphasize the "smoothing" effect visually, or clearly state they differ.

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Good use of horizontal rules. Decimal alignment is mostly consistent.
- **Clarity:** Clean and easy to read. 
- **Storytelling:** Provides necessary context on the dependent and independent variables.
- **Labeling:** $N$ is clearly stated in the notes.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Département-Level Results (Primary Specification)"
**Page:** 15
- **Formatting:** Standard journal format. 
- **Clarity:** Column headers are clear.
- **Storytelling:** This is the "money table." It groups unweighted, weighted, and continuous treatments logically.
- **Labeling:** Significance stars and clustering levels are well-defined.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Horse-Race: Network Fuel Exposure vs. Network Immigration Exposure"
**Page:** 16
- **Formatting:** **CRITICAL ERROR.** The table is cut off on the right margin. Standard errors and coefficients in Column 4 are missing digits. The title in the OCR/PDF seems to have a stray "rn_share" header.
- **Clarity:** Low due to the clipping.
- **Storytelling:** Vital for the "bundle of cues" argument.
- **Labeling:** Needs "Dependent Variable: RN Vote Share" more clearly at the top.
- **Recommendation:** **REVISE**
  - Fix the margin clipping immediately. Shrink column widths or use a smaller font to fit all 4 columns. Fix the "textitNotes" and "rn_share" artifacts in the LaTeX code.

### Table 4: "Timing Decomposition: Carbon Tax Era vs. Post-Gilets Jaunes"
**Page:** 18
- **Formatting:** Significant LaTeX/OCR artifacts ("textitNotes", "euro7", "d'epartement"). 
- **Clarity:** The coefficients are readable, but the notes are a mess.
- **Storytelling:** Important for showing the effect existed before the 2018 protests.
- **Labeling:** Definitions of "Post Carbon Only" and "Post GJ Only" are buried in messy notes.
- **Recommendation:** **REVISE**
  - Clean up the table notes formatting. Remove the "rn_share" header. Align the coefficients properly.

### Figure 3: "Event Study: Network Fuel Exposure and Rassemblement National Vote Share"
**Page:** 20
- **Formatting:** Professional two-panel layout.
- **Clarity:** High. The 2012 reference period is clearly marked.
- **Storytelling:** The most important figure for identification. The "mirror image" pre-trend is visually striking.
- **Labeling:** Y-axis clearly labeled. 
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "RN Vote Share Trajectory by Fuel Vulnerability Quartile"
**Page:** 21
- **Formatting:** Nice use of colors and confidence intervals.
- **Clarity:** The divergence after 2014 is obvious.
- **Storytelling:** Good descriptive evidence.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Spatial Model Comparison"
**Page:** 23
- **Formatting:** Clean comparison of SAR, SEM, and SDM.
- **Clarity:** Logical layout.
- **Storytelling:** Addresses the "contagion vs. correlated shocks" tension.
- **Labeling:** Model diagnostics (AIC, BIC, LR test) are well-placed.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Robustness Checks (Département-Level)"
**Page:** 26
- **Formatting:** Good "summary" style table for multiple regressions.
- **Clarity:** High.
- **Storytelling:** Efficiently handles 8 different checks in one exhibit.
- **Labeling:** Notes clearly explain each row.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Inference Comparison: Network × Post Coefficient (Département-Level)"
**Page:** 28
- **Formatting:** Clear separation of Panel A and B.
- **Clarity:** Easy to see which p-values are significant.
- **Storytelling:** Critical for shift-share papers (addressing the Adão et al. 2019 critique).
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Network Effect by Distance Bin"
**Page:** 31
- **Formatting:** Simple bar chart.
- **Clarity:** The non-monotonic pattern is very clear.
- **Storytelling:** This provides the mechanism of "distant ties" vs "local moderation."
- **Labeling:** Axis and bins are well-labeled.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Rotemberg Weights vs. Fuel Vulnerability Shifts"
**Page:** 33
- **Formatting:** Standard diagnostic plot for shift-share designs.
- **Clarity:** Shows high dispersion (good for identification).
- **Storytelling:** Reassures the reader that no single département (like Paris) is driving the whole result.
- **Labeling:** "Equal weight" line is a helpful benchmark.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Additional Robustness: Donut Design and Pre-Trend Adjustment"
**Page:** 34
- **Formatting:** **REPETITIVE ERROR.** Like Table 4, this has broken LaTeX code in the notes ("times(year-2012)lineartrend").
- **Clarity:** Columns are clear, but the note is unreadable.
- **Storytelling:** Important for the HonestDiD/Parallel trends discussion.
- **Recommendation:** **REVISE**
  - Fix the LaTeX source code in the notes.

### Table 9: "Channel Decomposition: Bartik Residualization and Orthogonalized Fuel Exposure"
**Page:** 35
- **Formatting:** Good comparison.
- **Clarity:** Clear.
- **Storytelling:** Directly addresses the immigration/fuel confounding.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "HonestDiD Sensitivity: Robust Confidence Intervals Under Pre-Trend Violations"
**Page:** 38
- **Formatting:** Professional plot of CIs.
- **Clarity:** Easy to see the "break point" where the effect becomes insignificant.
- **Storytelling:** This is state-of-the-art for DiD papers now (AER/QJE).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table A1: "Elections in the Panel"
**Page:** 45
- **Formatting:** Simple data table.
- **Recommendation:** **KEEP AS-IS**

### Figure A1: "SCI-Based vs. Migration-Based Network Exposure"
**Page:** 48
- **Formatting:** Good scatter with fit line. 
- **Clarity:** Clearly shows the correlation.
- **Storytelling:** Validates the post-treatment SCI measure.
- **Recommendation:** **KEEP AS-IS**

### Table A2: "Commune-Level Results (Ancillary)"
**Page:** 49
- **Formatting:** Clean 6-column table.
- **Storytelling:** Shows the results hold at the finer 37k observation level.
- **Recommendation:** **KEEP AS-IS**

### Table A3: "Controls Sensitivity" & Table A4: "Migration-Proxy Validation"
**Page:** 50
- **Formatting:** Standard.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 7 Main Tables, 7 Main Figures, 4 Appendix Tables, 1 Appendix Figure.
- **General quality:** Extremely high. The paper follows the visual conventions of top-five journals (event studies, HonestDiD plots, Bartik diagnostics).
- **Strongest exhibits:** Figure 3 (Event Study) and Figure 5 (Distance Bins). They tell the whole story.
- **Weakest exhibits:** Table 3 (clipped margin) and Table 4/8 (broken LaTeX notes).
- **Missing exhibits:** A **Balance Table** or "Table 0" showing how fuel-vulnerable départements differ from others on baseline characteristics (education, income, etc.) would be standard.

### Top 3 Improvements:
1. **Fix Technical Errors:** Resolve the clipping in Table 3 and the LaTeX artifacts in all table notes (Tables 4, 8).
2. **Standardize Maps:** Remove gridlines from Figure 1 and 2 to give them a "QJE" clean look.
3. **Consolidate Robustness:** You have many robustness tables (6, 8, 9, A3). Consider moving the smaller ones (8 and 9) to the Appendix and keeping Table 6 as the "one-stop-shop" for the main text.