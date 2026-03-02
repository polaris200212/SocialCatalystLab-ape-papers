# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T19:11:07.749551
**Route:** Direct Google API + PDF
**Tokens:** 20997 in / 1626 out
**Response SHA256:** 8a43d2b49d8f7d47

---

This review evaluates the visual exhibits of the paper "Connecting the Most Remote: Road Eligibility and Development in India’s Tribal Periphery" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Designated vs Non-Designated Areas"
**Page:** 12
- **Formatting:** Generally clean. However, it uses three decimal places for population means (141.666), which is excessive for integer data. The "Notes" section is clear but lacks a source citation.
- **Clarity:** Logical layout comparing below-threshold, above-threshold, and comparison groups.
- **Storytelling:** Critical for establishing the "as-good-as-random" balance. It effectively shows that "Above 250" and "Below 250" are similar, while "Non-Designated" is fundamentally different.
- **Labeling:** Variable names are intuitive. Units (e.g., "log points" or "share") are clear.
- **Recommendation:** **REVISE**
  - Reduce decimal precision for Population (0 or 1 decimal max).
  - Add a "Source: Author's calculations from SHRUG/Census" line.

### Table 2: "RDD Estimates: Effect of PMGSY Eligibility on Development Outcomes"
**Page:** 17
- **Formatting:** Professional AER-style layout. Good use of panels (A, B, C) to separate different samples/placebos.
- **Clarity:** The key findings (Columns 2 and 6) are immediately visible. Standard errors are correctly placed in parentheses.
- **Storytelling:** This is the "money table." It successfully contrasts the positive effects in Panel A with the null effects in Panel C.
- **Labeling:** Significance stars are defined. Bandwidth and Effective N are properly reported.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "RDD Bin Scatters: Main Outcomes at 250 Threshold"
**Page:** 35 (Note: Reference in text on p. 15)
- **Formatting:** Standard ggplot2/Stata defaults. The fit lines and confidence intervals are clear.
- **Clarity:** Multi-panel layout is easy to read. The vertical dashed line at zero (normalized threshold) is essential and present.
- **Storytelling:** Panel D (Nightlights) is the most compelling visual evidence in the paper. Panel B (Female Literacy) shows a clear jump.
- **Labeling:** Axes are well-labeled. The sub-titles (A, B, C, D) are helpful.
- **Recommendation:** **REVISE**
  - **Relocation:** This figure is currently in the Appendix. Given that it provides the primary visual evidence for the RDD, it **must be promoted to the main text**, likely near page 15.

### Figure 5: "Dynamic Effects of Road Eligibility on Nightlights"
**Page:** 37
- **Formatting:** Excellent use of different colors/markers for DMSP vs. VIIRS sensors.
- **Clarity:** The horizontal dashed line at zero helps assess pre-trends.
- **Storytelling:** Crucial for the paper's argument regarding "long-run" effects. It shows the treatment effect emerging only after 2012, which matches the implementation timeline.
- **Labeling:** Legend is clear. "PMGSY launched" vertical line is helpful.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This figure handles the "threats to validity" (pre-trends) and the "mechanism" (gestation period) simultaneously. It belongs in the main results section.

---

## Appendix Exhibits

### Table 3: "RDD Validity: Covariate Balance and Placebo Tests"
**Page:** 19 (Note: This is currently in the main text)
- **Formatting:** Professional.
- **Clarity:** Clean separation of balance tests and placebo thresholds.
- **Storytelling:** Provides necessary "hand-wringing" for a top journal to prove the result isn't a fluke of the threshold.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - While important, Figure 4 (balance plot) and Table 7 (placebo list) cover this. To keep the main text punchy for AER/QJE, this detailed table can live in the appendix.

### Figure 1: "Population Density Around the 250 Threshold"
**Page:** 34
- **Formatting:** Standard McCrary/Cattaneo density plot.
- **Clarity:** Clear evidence of no manipulation.
- **Storytelling:** Necessary check, but standard.
- **Recommendation:** **KEEP AS-IS (Appendix)**

### Figure 4: "Covariate Balance at 250 Threshold"
**Page:** 37
- **Formatting:** Coefficient plot style.
- **Clarity:** More intuitive than Table 3 for showing null results.
- **Storytelling:** Quickly dispatches concerns about sorting or baseline differences.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Replace the text-heavy Table 3 with this figure in the main text to improve visual flow.

### Figure 7: "Comparison of RDD Estimates: 250 vs. 500 Threshold"
**Page:** 38
- **Formatting:** Comparative coefficient plot.
- **Clarity:** Uses color coding effectively to distinguish the two thresholds.
- **Storytelling:** This is the best visual summary of the paper's contribution (why the 250 threshold matters specifically).
- **Recommendation:** **KEEP AS-IS (Appendix)** or use as a "Summary Figure" in the Conclusion.

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 0 main figures (text refers to them, but they are physically in the appendix), 7 appendix tables/figures.
- **General quality:** The paper has "AER-quality" data and results, but the **physical layout is suboptimal**. The most important figures (the RDD plots and the event study) are relegated to the back, forcing the reader to flip back and forth.
- **Strongest exhibits:** Figure 5 (Dynamic Effects) and Table 2 (Main Results).
- **Weakest exhibits:** Table 3 (Too much text/redundant) and Figure 2 (Formatting is slightly "out-of-the-box" ggplot).
- **Missing exhibits:** A **Map of India** highlighting the "Special Category States" and "Schedule V Areas." For an international audience (AER), readers need to see the "Periphery" geography described in the title.

### Top 3 Improvements:
1.  **Bring the Figures Home:** Move Figure 2 (Bin scatters) and Figure 5 (Dynamic effects) from the Appendix to the Main Results section. A paper in a top journal without a main-text RDD plot is unthinkable.
2.  **Geographic Visualization:** Add a map as "Figure 1." Show the treated villages vs. control villages across the Indian subcontinent. This anchors the "Remote/Periphery" narrative.
3.  **Consolidate Validity Checks:** Use Figure 4 (Coefficient plot) in the main text to show covariate balance and move the detailed Table 3 to the appendix. Visualizing the "nulls" on balance is more effective than a table of p-values.