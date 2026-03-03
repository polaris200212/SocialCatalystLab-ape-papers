# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T23:29:47.927108
**Route:** Direct Google API + PDF
**Tokens:** 15277 in / 1675 out
**Response SHA256:** b238587ba748f5be

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Synthetic Validation Results"
**Page:** 9
- **Formatting:** Clean and professional. Good use of horizontal rules (booktabs style).
- **Clarity:** High. Clearly demonstrates the model's accuracy across different scales.
- **Storytelling:** Essential for a paper introducing a new ML-based estimator. It builds confidence before the real-world application.
- **Labeling:** Units for "Time" (seconds/minutes) are clear. "Control MAE" is well-defined in notes.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Sample Characteristics by Treatment Status (1920 Baseline)"
**Page:** 11
- **Formatting:** Standard balance table. Decimal alignment is good.
- **Clarity:** Clear distinction between Treated (TVA) and Control.
- **Storytelling:** Important for establishing baseline differences. It correctly identifies the agricultural skew of the TVA region.
- **Labeling:** Needs a "Difference" column or p-values for the difference in means to be truly "top journal" ready.
- **Recommendation:** **REVISE**
  - Add a third column showing the difference (TVA - Control) and stars for statistical significance of the difference.

### Figure 1: "Pre-Trends Diagnostic: TVA_pre - Control_pre Transition Matrix"
**Page:** 13
- **Formatting:** Heatmap is clean. Diverging color scale (blue-white-red) is appropriate.
- **Clarity:** The 12x12 grid is readable. The color bar clearly indicates the scale.
- **Storytelling:** Vital for the DiD identification strategy. It shows that pre-treatment, the groups were moving similarly.
- **Labeling:** "Source Occupation" and "Destination Occupation" are clear. MAE is prominently displayed.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "DiD Transition Effect Matrix (12 Occupation Categories)"
**Page:** 14
- **Formatting:** Consistent with Figure 1. Professional.
- **Clarity:** The "blue column" for Farmers is immediately visible, which is the paper's key claim.
- **Storytelling:** This is the "money plot" of the paper. It visualizes the high-dimensional treatment effect effectively.
- **Labeling:** Title and legend are descriptive.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Occupation-Level DiD Transition Matrix (percentage points)"
**Page:** 15
- **Formatting:** Large 12x12 numerical table. Alignment is good.
- **Clarity:** Harder to parse than the figure, but provides the exact precision needed for reference.
- **Storytelling:** Redundant with Figure 2 but necessary for "look-up" value.
- **Labeling:** Note † regarding the Professional category is crucial and well-placed.
- **Recommendation:** **REVISE**
  - Bold coefficients that survive the FDR correction mentioned in the text (Section 7.3). This helps the reader identify the "signal" in a sea of 144 numbers.

### Figure 3: "Top 15 DiD Transition Effects by Magnitude"
**Page:** 16
- **Formatting:** Horizontal bar chart. Clean.
- **Clarity:** Very high. Instantly shows the largest movements.
- **Storytelling:** Excellent "at-a-glance" summary of the most important transition shifts.
- **Labeling:** Labels like "Clerical (stay)" are intuitive.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Weight-Space DiD Analysis"
**Page:** 17
- **Formatting:** Two-panel bar chart. 
- **Clarity:** Good. The red/blue distinction is gone here, but the bar structure works.
- **Storytelling:** This is more technical (ML-focused). It supports the "single direction of change" narrative.
- **Labeling:** x-axis labels (layer names) are technical; ensure they are defined in the text or a note.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "TWFE Benchmark: County-Level Regressions"
**Page:** 18
- **Formatting:** Standard regression table.
- **Clarity:** Clear comparison to the paper's main ML results.
- **Storytelling:** Essential for grounding the new method in traditional econometrics.
- **Labeling:** Significance stars and SE notes are present.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Real Treatment vs. Placebo DiD Transition Matrices"
**Page:** 19
- **Formatting:** Side-by-side heatmaps.
- **Clarity:** Good for comparison.
- **Storytelling:** Robustness check. Shows that the "farmer avoidance" isn't just a mechanical artifact of the model.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text is becoming "heatmap-heavy." The text description of the placebo is sufficient for the main flow; the visual proof is better suited for the appendix.

---

## Appendix Exhibits

### Table 5: "TVA Counties by State"
**Page:** 23
- **Recommendation:** **KEEP AS-IS** (Standard appendix data detail).

### Table 6: "Model Configuration"
**Page:** 24
- **Recommendation:** **KEEP AS-IS** (Crucial for replicability).

### Table 7: "Four-Adapter Training Summary"
**Page:** 25
- **Recommendation:** **KEEP AS-IS** (Technical detail).

### Table 8: "Weight-Space DiD SVD by Layer"
**Page:** 26
- **Recommendation:** **KEEP AS-IS** (Supports Figure 4).

### Figure 6: "TWFE Event Study Coefficients"
**Page:** 27
- **Formatting:** Standard event study plot.
- **Clarity:** High.
- **Storytelling:** For an AER/QJE audience, an event study is a "required" exhibit for any DiD paper.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Place this near the TWFE Benchmark table (Table 4). Reviewers will look for this immediately to verify the parallel trends assumption in the raw data.

---

## Overall Assessment

- **Exhibit count:** 4 Main Tables, 5 Main Figures, 4 Appendix Tables, 1 Appendix Figure.
- **General quality:** Extremely high. The use of heatmaps to visualize the $K \times K$ matrix is a clever solution to a difficult visualization problem.
- **Strongest exhibits:** Figure 2 (The Main Matrix) and Figure 3 (Top 15 Effects).
- **Weakest exhibits:** Table 2 (Needs a "Difference" column).
- **Missing exhibits:** A **Map of the Study Area**. Top journals (especially in R11/N32 JEL codes) almost always require a map showing the TVA service area vs. the control counties.

### Top 3 Improvements:
1.  **Add a Map:** Create a "Figure 0" or Figure 1 showing the geographic distribution of treated vs. control counties.
2.  **Promote the Event Study:** Move Figure 6 from the appendix to the main text. It is the most recognizable "badge of validity" for an economics audience.
3.  **Enhance Table 3:** Bold the significant cells in the 12x12 matrix. It is currently very difficult to distinguish noise from signal without referring back to Figure 2.