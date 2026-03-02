# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T22:08:09.321123
**Route:** Direct Google API + PDF
**Tokens:** 23597 in / 2845 out
**Response SHA256:** c149178161fb6895

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Professional and clean. Uses clear panel structures (A, B, C) to group variables. 
- **Clarity:** High. Separating by "Below 20%" and "Above 20%" allows for immediate visual inspection of balance at the threshold.
- **Storytelling:** Essential. It establishes the comparability of tracts around the cutoff and the "jump" in OZ designation.
- **Labeling:** Clear. Note includes bandwidth details and data sources.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Good use of colors to distinguish sides of the threshold.
- **Clarity:** Clear, though the "Density" label on the y-axis is standard, the bins are slightly wide.
- **Storytelling:** Crucial for RDD. It visually confirms the McCrary test result (the bunching).
- **Labeling:** The annotation "McCrary test: t = 5.03..." is helpful.
- **Recommendation:** **REVISE**
  - Increase the number of bins (smaller bin width) to better show the distribution density immediately around the 20% mark.

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** High quality. Point size proportional to tract count is an excellent AER-style touch.
- **Clarity:** Very high. The discontinuity is unmistakable.
- **Storytelling:** Establishes the "Fuzzy" RDD first stage.
- **Labeling:** Excellent axis labels and descriptive note.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "First Stage: Effect of Poverty Threshold on OZ Designation"
**Page:** 15
- **Formatting:** Standard regression table. Decimal alignment is good.
- **Clarity:** High.
- **Storytelling:** Quantifies the jump seen in Figure 2.
- **Labeling:** Clear. Defined significance stars.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Fuzzy RDD Estimates: Local Average Treatment Effect of OZ Designation"
**Page:** 16
- **Formatting:** Professional.
- **Clarity:** Good. Reports both Point Estimates and CIs.
- **Storytelling:** Central result for employment.
- **Labeling:** Note explains the `rdrobust` specification.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** Standard balance table.
- **Clarity:** Logical layout.
- **Storytelling:** Shows where balance fails (socioeconomics) and where it holds (pre-period employment).
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Consider moving this to the Appendix and replacing it in the main text with the visual version (Figure 12) which is much faster to parse.

### Table 5: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 17
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** This is the reduced-form version of Table 3. Having both might be redundant.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - **Consolidate:** Merge Table 3 (Wald/LATE) and Table 5 (Reduced Form/ITT) into a single "Main Results" table with different panels. This is more common in top journals to save space and show the full logic of the IV/Fuzzy RDD in one place.

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 18
- **Formatting:** Excellent. Use of shaded confidence intervals and binned means is standard.
- **Clarity:** High. The flat line through the threshold clearly communicates "No Effect."
- **Storytelling:** Primary visual evidence for the null result.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Reduced-Form RDD: Change in Information-Sector Employment at the Threshold"
**Page:** 18
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High.
- **Storytelling:** Focuses on the sector most likely to house data centers.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Design-Based Results: Local Randomization Inference"
**Page:** 19
- **Formatting:** Logic is sound, but the table is repetitive.
- **Clarity:** A bit cluttered with many rows for different windows.
- **Storytelling:** Supports the continuity RDD results.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text already has continuity RDD results. This "Design-Based" approach is great for robustness but clutters the main results section.

### Table 7: "RDD Estimates: Effect of OZ Eligibility on Data Center Presence"
**Page:** 20
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** This is the most important "new" result of the paper (direct facility measurement).
- **Labeling:** Note includes the MDE (Minimum Detectable Effect), which is excellent practice for null results.
- **Recommendation:** **KEEP AS-IS** (Wait, see recommendation for Figure 5).

### Figure 5: "Direct Data Center Presence at the OZ Eligibility Threshold"
**Page:** 21
- **Formatting:** Good, but the y-axis scale is very small (0.0% to 0.6%) because data centers are rare.
- **Clarity:** Low. The sparsity of the data makes the binned means look like "noise" at the bottom of the graph.
- **Storytelling:** Visually confirms the null in Table 7.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Add a "zoom" or an inset plot, or change the y-axis to a log scale (if appropriate) or simply acknowledge the sparsity more clearly in the title.

### Table 8: "RDD Estimates: Data Center Presence by Vintage"
**Page:** 22
- **Formatting:** Good use of Panel A (Post-2018) and Panel B (Pre-2018).
- **Clarity:** Clear.
- **Storytelling:** Elegant "placebo" test using pre-existing facilities.
- **Labeling:** Note is very detailed.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Data Center Presence by Vintage at the OZ Eligibility Threshold"
**Page:** 23
- **Formatting:** Two-color scheme for different vintages.
- **Clarity:** Very difficult to read because the points overlap on the zero line due to sparsity.
- **Storytelling:** Visual version of Table 8.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Jitter the points slightly or use "lollipop" style stems to show where the non-zero tracts are. As it stands, it looks like an empty plot.

### Table 9: "Bandwidth Sensitivity: Δ Total Employment"
**Page:** 23
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Standard robustness.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - Main text should focus on the "best" estimate; sensitivity is for the appendix.

### Figure 7: "Systematic Placebo Cutoff Tests"
**Page:** 24
- **Formatting:** Professional.
- **Clarity:** High. Red dot vs. grey dots is effective.
- **Storytelling:** Powerful evidence that the 20% threshold isn't just a random fluke in the data.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Distribution of Placebo t-Statistics"
**Page:** 25
- **Formatting:** Standard histogram.
- **Clarity:** High.
- **Storytelling:** Complements Figure 7.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is redundant with Figure 7. Figure 7 shows the coefficients/CIs; this just shows the distribution of the same tests. One is enough for the main text.

### Figure 9: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 26
- **Formatting:** Very clean "event study" style RDD.
- **Clarity:** High.
- **Storytelling:** Vital for showing the pre-trend is flat and the effect doesn't "emerge" later.
- **Labeling:** Vertical "OZ Designated" line is helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Parametric RDD Specifications"
**Page:** 27
- **Formatting:** Large table, many columns.
- **Clarity:** Medium. Column (3) and (5) add a lot of clutter.
- **Storytelling:** Shows robustness to controls and polynomials.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 11: "Heterogeneity: Urban versus Rural Tracts"
**Page:** 28
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** Addresses a major alternative explanation (that it only works in cities).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Infrastructure Heterogeneity: RDD Estimates by Broadband Access Quartile"
**Page:** 29
- **Formatting:** Clean coefficient plot.
- **Clarity:** High. Q4 has a massive CI, which is clearly labeled as "uninformative."
- **Storytelling:** Directly tests the "infrastructure fundamentals" theory.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 12: "Local Randomization Covariate Balance"
**Page:** 39
- **Recommendation:** **KEEP AS-IS** (Stronger than Table 4).

### Figure 11: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 39
- **Recommendation:** **KEEP AS-IS**

### Table 13, 14, 15: "Donut / Polynomial / Kernel Sensitivity"
**Page:** 40-41
- **Recommendation:** **KEEP AS-IS** (Standard appendix fodder).

### Table 16: "Inference Robustness"
**Page:** 41
- **Recommendation:** **KEEP AS-IS**

### Figure 12: "Covariate Balance at the 20% Poverty Threshold" (Coefficient Plot)
**Page:** 42
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This visual summary of balance is much more effective than Table 4.

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 8 main figures, 7 appendix tables, 2 appendix figures
- **General quality:** Extremely high. The paper follows modern "Best Practices" for RDD (Cattaneo et al. style). Most figures look QJE/AER ready.
- **Strongest exhibits:** Figure 2 (First Stage), Figure 9 (Dynamic RDD), Figure 10 (Heterogeneity).
- **Weakest exhibits:** Figure 5 and 6 (too sparse to see effectively), Table 6 (too repetitive for main text).
- **Missing exhibits:** A **Map** showing the spatial distribution of Data Centers vs. Opportunity Zones would be highly valuable for a "Place-Based" paper to give the reader a sense of the geography.
- **Top 3 improvements:**
  1. **Consolidate Results:** Merge Table 3 (LATE) and Table 5 (ITT) into one "Main Results" table.
  2. **Visual Promotion:** Move the Covariate Balance Table (Table 4) to the appendix and bring the Balance Plot (Figure 12) to the main text.
  3. **Address Sparsity:** Revise Figure 5 and 6 to make the few non-zero data points visible (jitter or stems), as "empty-looking" plots can be perceived as a lack of data.