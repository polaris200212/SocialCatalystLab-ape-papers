# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T15:23:53.949251
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1863 out
**Response SHA256:** 15f489702751812c

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Pre-Period (2005–2013)"
**Page:** 9
- **Formatting:** Clean, professional LaTeX style. Good use of horizontal rules (booktabs style). Number alignment is generally good.
- **Clarity:** Very clear. Dividing by "High Oil" and "Low/No Oil" provides immediate context for the identifying variation.
- **Storytelling:** Essential. It establishes that high-oil countries are wealthier (GDP p.c.) but spend less on health as a % of GDP, setting the stage for the "resource curse" narrative.
- **Labeling:** Clear. Units (%, $, 1,000 live births) are included. Note explicitly defines "High Oil."
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Event Study: Oil Dependence and Under-5 Mortality"
**Page:** 13
- **Formatting:** Standard ggplot2/Stata appearance. Gridlines are a bit heavy for top journals.
- **Clarity:** The message—flat pre-trends and null post-treatment effect—is visible in 5 seconds.
- **Storytelling:** This is the "money shot" of the paper. It validates the DiD design.
- **Labeling:** Y-axis label is a bit technical ("Coefficient on Oil Rents x Post"). Descriptive title is good.
- **Recommendation:** **REVISE**
  - Lighten or remove background gridlines to match AER/QJE aesthetic.
  - Simplify Y-axis label to "Effect on Under-5 Mortality" or similar.
  - Ensure the "0" on the x-axis (the excluded year 2013) is clearly marked as the reference period.

### Figure 2: "Under-5 Mortality Trends by Oil Dependence Group"
**Page:** 14
- **Formatting:** Good use of colors and confidence bands. 
- **Clarity:** A bit cluttered due to overlapping 95% CIs.
- **Storytelling:** Useful for showing raw data, but somewhat redundant with the event study.
- **Labeling:** Excellent. Legend is clear and includes group definitions.
- **Recommendation:** **MOVE TO APPENDIX**
  - While helpful, top journals prioritize the identification (Figure 1). This is "supporting evidence" for the parallel trends shown in the event study.

### Table 2: "Oil Dependence and Under-5 Mortality: Main Results"
**Page:** 12
- **Formatting:** Excellent. Decimal-aligned, professional layout. 
- **Clarity:** Three-column structure (Baseline, Controls, Governance) is the standard way to show robustness of a null result.
- **Storytelling:** Central table of the paper.
- **Labeling:** Significance stars and clustering clearly defined in notes. Includes 95% CI as a row, which is excellent for a "precisely estimated null" paper.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Oil Dependence and Alternative Development Outcomes"
**Page:** 15
- **Formatting:** Logical layout.
- **Clarity:** Good. It uses a "row-per-regression" format which is efficient.
- **Storytelling:** Important for showing the effect isn't just hidden in a different mortality metric or education.
- **Labeling:** Note explains that each row is a separate regression.
- **Recommendation:** **REVISE**
  - Group these into "Panel A: Health" and "Panel B: Education" to improve the visual narrative.

### Table 4: "Robustness Checks"
**Page:** 16
- **Formatting:** Consistent with other tables.
- **Clarity:** Very high.
- **Storytelling:** Consolidates many potential "reviewer 2" concerns into one space.
- **Labeling:** Clear descriptions of each specification.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Sensitivity to Time Window"
**Page:** 18
- **Formatting:** Coefficient plot style.
- **Clarity:** Excellent. Shows the stability of the coefficient.
- **Storytelling:** Good, but this is often considered a "check" rather than a main result.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This information can be summarized in one sentence in the text; the visual exhibit is better suited for an online supplement.

### Table 5: "Fiscal Mechanism: Oil Dependence and Government Spending"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** High.
- **Storytelling:** Vital. This explains *why* the main result is a null (the fiscal channel didn't break).
- **Labeling:** Units (% GDP) included in column headers.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Health vs. Military Expenditure by Oil Dependence Group"
**Page:** 20
- **Formatting:** Clean line plot.
- **Clarity:** The use of solid vs. dotted lines is effective.
- **Storytelling:** Excellent visual confirmation of the "no guns over vaccines" finding.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Nigeria: Key Indicators Around the 2014 Oil Price Crash"
**Page:** 22
- **Formatting:** Multi-panel (2x2) grid.
- **Clarity:** High.
- **Storytelling:** The Nigeria case study provides the "intuition" for the cross-country results.
- **Labeling:** Each panel has clear units and titles.
- **Recommendation:** **KEEP AS-IS** (or move to Appendix if space is tight, but it adds a nice "human" scale to the macro data).

---

## Appendix Exhibits

### Table 6: "Variable Definitions and Sources"
**Page:** 28
- **Formatting:** Standard table.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Brent Crude Oil Price, 2000–2024"
**Page:** 29
- **Formatting:** Clear time-series plot.
- **Storytelling:** Establishes the timing of the "natural experiment."
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This should be Figure 1 in the main text. Every "Resource Curse" or "Commodity Shock" paper needs to show the price shock clearly at the start.

### Figure 7: "Pre-Crash Oil Dependence and Under-5 Mortality (2013)"
**Page:** 30
- **Formatting:** Scatter plot with regression line.
- **Storytelling:** Shows the cross-sectional correlation.
- **Recommendation:** **KEEP AS-IS** (Properly placed in Appendix).

### Table 7: "Region-Specific Estimates"
**Page:** 31
- **Formatting:** Standard table.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 5 Main Figures, 2 Appendix Tables, 2 Appendix Figures.
- **General quality:** Extremely high. The paper follows the "AER/QJE style" closely. The use of precisely estimated nulls (and including CIs in tables) is exactly what editors at top journals look for in this type of work.
- **Strongest exhibits:** Table 2 (Main Results) and Figure 5 (Nigeria Case).
- **Weakest exhibits:** Figure 2 and Figure 3 (slightly redundant for main text).
- **Missing exhibits:** A **Map** showing treatment intensity (oil rents as % of GDP) would be a standard and highly effective addition for Figure 1 or the Appendix to show the geographic distribution of "High Oil" countries.

**Top 3 improvements:**
1.  **Promote Figure 6 (Oil Price) to Figure 1** of the main text to immediately ground the reader in the 2014 shock.
2.  **Move Figure 2 and Figure 3 to the Appendix** to declutter the main text; the event study (Figure 1) already covers the identification concerns these address.
3.  **Add a map** (as Figure 2) showing which countries are in the "High Oil" group. This helps with the "Storytelling" aspect, showing the reader that the results aren't driven by just one region (e.g., only the Middle East).