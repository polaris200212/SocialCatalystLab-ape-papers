# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-04T02:13:31.757841
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 1990 out
**Response SHA256:** 831665f928d04bb8

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Sample Characteristics by Treatment Status (1920 Baseline)"
**Page:** 7
- **Formatting:** Generally clean and follows standard economic conventions (top, middle, and bottom rules).
- **Clarity:** Excellent. Groups variables logically into N, Occupation Shares, and Demographics.
- **Storytelling:** Vital for establishing balance (or lack thereof). It clearly shows the agricultural nature of TVA counties compared to controls.
- **Labeling:** Clear. Units (%) are included. Notes section is comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Pre-trends diagnostic: difference in pre-treatment transition probabilities between TVA and control regions (occupation level)."
**Page:** 9
- **Formatting:** Professional heatmap. The color bar is appropriate.
- **Clarity:** The "Difference" scale is well-defined. However, the text in the cells is quite small and may be difficult to read in a printed journal format.
- **Storytelling:** Central to the identification strategy. It visually proves that pre-trends are near-zero.
- **Labeling:** Axis labels (Source/Destination) are clear. The title includes the MAE, which is a helpful summary statistic.
- **Recommendation:** **REVISE**
  - Increase the font size of the numerical values inside the heatmap cells for legibility.

### Figure 2: "DiD transition effect matrix."
**Page:** 10
- **Formatting:** Identical to Figure 1. High-quality visualization.
- **Clarity:** The divergence of blue (decrease) and red (increase) allows for a quick 10-second parse of the "Lewis" and "Entrepreneurial" channels.
- **Storytelling:** This is the "money shot" of the paper. It visualizes the transition matrix estimand better than a raw table.
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Like Figure 1, increase the font size of the cell values. 
  - Consider adding "Source" and "Destination" labels more prominently or clarifying the $j \to k$ notation in the axis titles.

### Table 2: "Occupation-Level DiD Transition Matrix (percentage points)"
**Page:** 11
- **Formatting:** Very dense. Columns are narrow, making it look slightly "squashed." No decimal alignment (centered values).
- **Clarity:** It is difficult to read because the occupation abbreviations (FmLab, Oper, Uncl) are not standard.
- **Storytelling:** Provides the exact numbers for Figure 2. Essential for the "Scale of Reallocation" argument.
- **Labeling:** The notes are excellent—they include the effective N for each row, which is a high level of transparency rarely seen.
- **Recommendation:** **REVISE**
  - Use a landscape orientation or reduce the font size to allow for full occupation names in the headers.
  - Decimal-align the values. 
  - Use a "0.0" instead of "0.0" (ensure negative signs are proper en-dashes and consistent).

### Figure 3: "Top 15 DiD transition effects by magnitude."
**Page:** 13
- **Formatting:** Clean horizontal bar chart.
- **Clarity:** Extremely high. It distills a 132-cell matrix into the most important findings.
- **Storytelling:** Effectively highlights the "Stay-rate disruptions" and "Farmer avoidance."
- **Labeling:** Clear x-axis with units. Legend is not needed because of the color coding (red/blue).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Frequency-Based DiD Transition Matrix (percentage points)"
**Page:** 15
- **Formatting:** Similar to Table 2; suffers from the same "squashed" appearance and non-aligned decimals.
- **Clarity:** Harder to parse because the variance is higher (e.g., the 4.1 for Farm Lab -> Farm).
- **Storytelling:** Crucial benchmark to show the Transformer isn't hallucinating.
- **Labeling:** Clear notes on exclusions.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a validation/robustness exhibit. The main text should focus on the preferred estimator (Transformer). Moving this improves the flow of the Results section.

### Table 4: "TWFE Benchmark: County-Level Regressions"
**Page:** 16
- **Formatting:** Standard AER-style regression table.
- **Clarity:** High. Familiar format for any economist.
- **Storytelling:** Serves as the "Traditional" point of comparison. 
- **Labeling:** Notes define SEs and clustering. Significance stars are oddly missing (though p-values are provided).
- **Recommendation:** **REVISE**
  - Add standard significance stars (*, **, ***) to coefficients to align with journal expectations.

### Figure 4: "TWFE event study."
**Page:** 17
- **Formatting:** Standard event study plots.
- **Clarity:** High. Clean 95% CIs.
- **Storytelling:** Supports the TWFE benchmark by showing the timing of the effect.
- **Labeling:** Red vertical line for treatment year is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Real treatment (left) vs. placebo (right) DiD transition matrices."
**Page:** 21
- **Formatting:** Side-by-side heatmaps.
- **Clarity:** Good for comparison, but the double heatmaps are very small on the page.
- **Storytelling:** Powerful "placebo test" visualization.
- **Labeling:** Clear distinction between the two.
- **Recommendation:** **REVISE**
  - Increase the size of the heatmaps; perhaps stack them vertically if the width is an issue, or move to the Appendix. Given the novelty of the method, keeping it in the main text is good, but it needs to be more legible.

### Figure 6: "Weight-space DiD analysis."
**Page:** 22
- **Formatting:** Professional bar charts.
- **Clarity:** Very high.
- **Storytelling:** This is highly technical (SVD of weights). It adds "black box" transparency.
- **Labeling:** "L2 Norm" and "Top-1 Energy" are well-labeled.
- **Recommendation:** **MOVE TO APPENDIX**
  - While impressive, this is more of interest to ML-inclined economists. The core economic argument doesn't depend on weight-space SVD.

---

## Appendix Exhibits

### Table 5: "Model Configuration"
**Page:** 28
- **Formatting:** Clean parameter-value list.
- **Clarity:** Excellent for reproducibility.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Four-Adapter Training Summary"
**Page:** 29
- **Formatting:** Standard summary table.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Synthetic Validation Results"
**Page:** 29
- **Formatting:** Clear.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Weight-Space DiD SVD by Layer"
**Page:** 30
- **Formatting:** Clear.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "TVA Counties by State"
**Page:** 31
- **Formatting:** Simple list.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 3 main tables (if Table 3 is moved), 6 main figures, 6 appendix tables.
- **General quality:** Extremely high. The use of heatmaps to visualize DiD transition matrices is a significant visual innovation for applied micro.
- **Strongest exhibits:** Figure 2 (The Transition Effect Matrix) and Figure 3 (Top 15 Effects).
- **Weakest exhibits:** Table 2 and Table 3 (formatting/density issues).
- **Missing exhibits:** 
    - **Map of Treatment:** A map showing the TVA service area counties vs. control counties in the 16-state region is standard for any regional/historical paper (QJE/AER style).
    - **Outcome Variable Definitions:** A small table or list in the appendix mapping specific OCC1950 codes to the 12 categories.
- **Top 3 improvements:**
  1. **Legibility:** Increase the font size of values within the heatmaps (Figs 1, 2, 5).
  2. **Table Formatting:** In Tables 2 and 3, use landscape orientation to allow for full occupation names and decimal-align all numbers.
  3. **Mapping:** Add a geographic map of the study area to the main text (Introduction or Data section).