# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-25T16:25:17.042087
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 1980 out
**Response SHA256:** fa2c7d4ed717384d

---

As a visual exhibit advisor for top-tier economics journals, I have reviewed the five exhibits in your paper. Overall, the exhibits provide a clean, professional foundation, but they require several high-impact adjustments to meet the "self-contained" and "story-focused" standards of the AER or QJE.

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Property Transactions by Treatment Group"
**Page:** 9
- **Formatting:** Clean and professional. Good use of horizontal rules (booktabs style).
- **Clarity:** The comparison is immediate. However, the alignment of numbers in the "N" and "Communes" columns should be right-aligned or decimal-aligned to avoid visual "weaving."
- **Storytelling:** This table is essential. It highlights the massive selection issue (treated communes are nearly 2x as expensive as controls), which justifies the use of FE and the "compositional shift" argument later in the paper.
- **Labeling:** Units are mentioned in notes but should be in the header (e.g., "Price/m² (EUR)"). "Share Apts" should be "Share Apartments (%)".
- **Recommendation:** **REVISE**
  - Add units (EUR, m²) to column headers.
  - Right-align all numeric columns.
  - Add a "Total" row or a column for the ratio/difference between groups to help the reader quantify the "amenity premium" mentioned in the text.

### Table 2: "Effect of TLV Expansion on Housing Prices and Transaction Volume"
**Page:** 12
- **Formatting:** Standard journal format. Excellent use of checkmarks for Fixed Effects.
- **Clarity:** Column headers are informative.
- **Storytelling:** This is the "money table." It clearly shows the divergence between commune-level (null) and transaction-level (positive) price effects.
- **Labeling:** Excellent notes explaining the clusters and significance levels.
- **Recommendation:** **REVISE**
  - The title is a bit generic. Consider: "Main Estimates: Housing Prices vs. Transaction Volume."
  - Highlight the "selection" story by adding a row for "Mean of Dep. Variable" to provide a sense of scale for the coefficients.

### Figure 1: "Event Study: Effect of TLV Expansion on Housing Prices"
**Page:** 14
- **Formatting:** Clean ggplot2 style. Confidence intervals are visible.
- **Clarity:** The "TLV Expansion" label on the dashed line is helpful but slightly overlaps the grid line.
- **Storytelling:** Crucial for the "announcement effect" argument. It clearly shows the 2023 spike.
- **Labeling:** The y-axis label "Coefficient (log price/m²)" is accurate but "Log Points" or "Percent" is more intuitive for a quick scan.
- **Recommendation:** **REVISE**
  - Increase the font size for axis labels.
  - Move the "Reference year: 2022" text from the subtitle into the figure notes to reduce clutter at the top.
  - Change the y-axis units to percentage points (multiply by 100) to make the coefficients (e.g., "2.9") more readable than "0.029".

### Figure 2: "Event Study: Effect of TLV Expansion on Transaction Volume"
**Page:** 15
- **Formatting:** Consistent with Figure 1.
- **Clarity:** The drop in 2024–2025 is very clear.
- **Storytelling:** Complements Table 2 perfectly.
- **Labeling:** Same as Figure 1.
- **Recommendation:** **REVISE**
  - Mirror the changes from Figure 1 (font size, y-axis scale in percentages).
  - Combine Figure 1 and Figure 2 into a single Figure with **Panel A (Prices)** and **Panel B (Volume)**. This allows the reader to see the simultaneous price-spike/volume-drop at a glance, which is the core of your "selection" and "announcement" argument.

### Table 3: "Heterogeneity by Zone Type"
**Page:** 16
- **Formatting:** Standard.
- **Clarity:** Logical grouping.
- **Storytelling:** Supports the signaling mechanism.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Or consider merging with Table 4 as Panel A/B to save space).

### Table 4: "Heterogeneity by Property Type (Transaction Level)"
**Page:** 17
- **Formatting:** Standard.
- **Clarity:** Very clear evidence of the composition effect.
- **Storytelling:** Critical for the "survivor bias" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks"
**Page:** 18
- **Formatting:** Good use of columns for different specifications.
- **Clarity:** "Donut" and "Matched" labels are clear to economists.
- **Storytelling:** Comprehensive.
- **Labeling:** Standard errors in parentheses is noted.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Parallel Trends: Mean Price/m² by Treatment Group"
**Page:** 20
- **Formatting:** Good use of color and shapes.
- **Clarity:** The level difference is massive; the "parallelism" is visible but slightly compressed due to the scale.
- **Storytelling:** Essential for DiD validity.
- **Labeling:** "Never Treated (Control)" is clearer than just "Control."
- **Recommendation:** **REVISE**
  - Add a "Log Scale" version or an inset for 2022-2025. Because the treated group is so much higher than the control, the 6% changes look small. A secondary y-axis or a "Normalized to 2022=100" version would make the parallel trends more visually "parallel."

---

## Appendix Exhibits

### Figure 4: "Geographic Distribution of Treated Communes"
**Page:** 30
- **Formatting:** Bar chart is clean.
- **Clarity:** Y-axis uses French département codes (e.g., 73, 14).
- **Storytelling:** Good for institutional context.
- **Labeling:** The y-axis should include the *name* of the département alongside the code (e.g., "73 - Savoie") so readers don't have to look up French geography.
- **Recommendation:** **REVISE**
  - Add names to the département codes.
  - **BETTER:** Replace this bar chart with a **Choropleth Map of France**. For a paper in a top journal, a map showing the coastal and mountain "rings" of treatment is much more impactful than a bar chart.

### Figure 5: "Price Trends by Zone Type: Tourism vs. Non-Tourism Expansion"
**Page:** 33
- **Formatting:** Clean.
- **Clarity:** Shows the divergence in 2023 well.
- **Storytelling:** Supports the heterogeneity analysis.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 3 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** High. The paper follows the "Modern Empirical Paper" template very closely. The tables are extremely clean. Figures are standard but could be more "ambitious" (e.g., using maps).
- **Strongest exhibits:** Table 2 (Main Results) and Figure 1 (Price Event Study).
- **Weakest exhibits:** Figure 4 (Bar chart for geography) and Figure 3 (Parallel Trends, due to the scale compression).
- **Missing exhibits:** 
    1. **A Map:** As mentioned, a map of France showing treated communes is standard for any paper exploiting geographic policy variation.
    2. **Balance Table for Matching:** Table 5 Column 5 shows matched results, but a table showing covariate balance before/after matching (standard for AEJ or JPE) is missing from the Appendix.

### Top 3 Improvements:
1.  **Consolidate Figures 1 & 2:** Create a two-panel figure (Panel A: Prices, Panel B: Volume). This forces the reader to acknowledge the "Liquidity vs. Price" trade-off that is the paper’s central contribution.
2.  **Upgrade the Geography Visual:** Replace Figure 4 with a map of France. It immediately communicates that treatment is "coastal and mountain" more effectively than a list of codes.
3.  **Address Scale in Figure 3:** Either log-transform the y-axis or provide a "Relative to 2022" plot. The current scale makes the 2023-2024 treatment effect look visually negligible because the level difference is so large.