# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T21:16:55.910684
**Route:** Direct Google API + PDF
**Tokens:** 23597 in / 2463 out
**Response SHA256:** 6090fe1db560bd3c

---

This review evaluates the exhibits in "The Depleted Safety Net: Provider Attrition and Medicaid’s Pandemic-Era Disruption" based on the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 12
- **Formatting:** Clean layout. Professional use of horizontal rules (booktabs style).
- **Clarity:** Excellent separation of treatment (Panel A) and outcome variables (Panel B).
- **Storytelling:** Effectively highlights the right-skewed nature of the data and the wide variation in exit rates (9.7% to 55.3%).
- **Labeling:** Clear notes. Unit for spending ($M) is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Pre-COVID Medicaid Provider Exit Rates by State (Overall, All Provider Types)"
**Page:** 18
- **Formatting:** Good use of a horizontal bar chart to show ranking. Color palette is distinguishable and professional.
- **Clarity:** High. Ranking states by exit rate immediately identifies the "high-attrition" states discussed in the text.
- **Storytelling:** Essential for the paper’s "Geography of Exit" narrative.
- **Labeling:** Source notes and axis labels are clear.
- **Recommendation:** **REVISE**
  - Change the Y-axis (state abbreviations) font to be slightly larger or sans-serif to match the title and improve readability at publication scale.

### Table 2: "Balance: High vs. Low Pre-COVID Exit States (Dec 2019)"
**Page:** 19
- **Formatting:** Standard balance table. Numbers are well-aligned.
- **Clarity:** Very clear.
- **Storytelling:** Crucial for defending the "selection into exit intensity" section.
- **Labeling:** Defines "Low Exit" and "High Exit" in the notes (above/below median).
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Study: HCBS Provider Supply and Pre-COVID Exit Exposure"
**Page:** 19
- **Formatting:** Clean ggplot2 style. Confidence interval shading is appropriate.
- **Clarity:** The pre-trend is immediately obvious, which is the "key message" of the paper.
- **Storytelling:** This is the "money plot." It shows why a static DiD is misleading.
- **Labeling:** Vertical lines for COVID and ARPA are well-placed.
- **Recommendation:** **REVISE**
  - The Y-axis label "Coefficient on Exit Rate x Event Time" is technically accurate but clunky. Suggest: "Differential Log Provider Supply."
  - Remove the redundant title at the top of the plot area; the figure caption below is sufficient.

### Figure 3: "HCBS Provider Supply Trends by Pre-COVID Exit Intensity Quartile"
**Page:** 21
- **Formatting:** High contrast between lines.
- **Clarity:** The Q4 (highest exit) line stands out clearly.
- **Storytelling:** Complements Figure 2 by showing raw trends.
- **Labeling:** Good legend placement.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Pre-COVID Provider Exits, Pandemic Disruption, and Beneficiary Consequences"
**Page:** 22
- **Formatting:** Excellent decimal alignment.
- **Clarity:** logical progression from Supply (1-3) to Access (4-6).
- **Storytelling:** Consolidates the "null" static result across multiple outcomes.
- **Labeling:** Note on restricted sample size for Column 3 (Stringency) is vital.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Broken-Trend Model: Pre-Trend, Level Shift, and Slope Change"
**Page:** 23
- **Formatting:** Standard.
- **Clarity:** Separates the three key coefficients ($\lambda, \beta, \kappa$) effectively.
- **Storytelling:** This is the core empirical table of the paper.
- **Labeling:** Clear definitions of what the Greek letters represent in the notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Broken-Trend Model: Pre-Trend Extrapolation vs. Actual Post-COVID Trajectory"
**Page:** 24
- **Formatting:** Clean visualization of a complex model.
- **Clarity:** High. The contrast between the dashed (extrapolated) and solid (actual) line tells the story in <5 seconds.
- **Storytelling:** Effectively visualizes the "moderation" ($\kappa > 0$) finding.
- **Labeling:** Excellent annotations.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Collapsed Cross-Sectional Regression: Pre-Period Exit Rate vs. Pandemic-Era Change in Log Providers (N = 51)"
**Page:** 25
- **Formatting:** Standard scatter with fit.
- **Clarity:** Shows the null result and the outlier (likely NV) clearly.
- **Storytelling:** Provides a "sanity check" for the panel regressions.
- **Recommendation:** **MOVE TO APPENDIX**
  - While it's a good check, Table 3 Column 1 and Figure 2 already establish the null/trend story. This takes up a lot of space for a secondary validation.

### Figure 6: "Multi-Panel Event Study: Supply and Access Consequences of Pre-COVID Provider Exits"
**Page:** 26
- **Formatting:** Good use of facet_wrap.
- **Clarity:** Panels C and D are a bit noisy but show the lack of trend.
- **Storytelling:** Shows the "supply-access-intensity chain" results.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Safety Net Vulnerability: Exit Rate x COVID Severity"
**Page:** 27
- **Formatting:** Standard triple interaction.
- **Clarity:** Interpretation of triple interactions is always hard; the notes help.
- **Storytelling:** Tests the "amplification" hypothesis.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Exploratory: ARPA HCBS Investment and Supply Recovery"
**Page:** 28
- **Formatting:** Standard.
- **Clarity:** The "—" for missing variables in columns is clear.
- **Storytelling:** Adds the exploratory policy analysis.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "DDD Event Study: ARPA HCBS Investment and Recovery in Depleted Markets"
**Page:** 29
- **Formatting:** Quarterly bins reduce noise compared to Figure 2.
- **Clarity:** Shows the "positive-then-declining" pre-trend clearly.
- **Storytelling:** Justifies why Table 6 is "descriptive rather than causal."
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Provider Supply Trends: HCBS vs. Non-HCBS by Exit Intensity"
**Page:** 30
- **Formatting:** Four lines in one plot.
- **Clarity:** Becoming cluttered. The dashed/solid and color differences are subtle.
- **Storytelling:** Raw data for the DDD.
- **Recommendation:** **REVISE**
  - Split this into two panels: Panel A (High Exit States: HCBS vs Non-HCBS) and Panel B (Low Exit States: HCBS vs Non-HCBS). This would make the "steeper decline" for High-Exit HCBS much easier to see.

### Figure 9: "Randomization Inference p-Values Across Five Stratifications"
**Page:** 31
- **Formatting:** Bar chart for p-values.
- **Clarity:** Very clear "sea of red" above the significance lines.
- **Storytelling:** Strongest evidence of the robustness of the null.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Entity-Type Event Studies: Individual (Type 1) vs. Organization (Type 2) Providers"
**Page:** 32
- **Formatting:** Side-by-side facets.
- **Clarity:** Good.
- **Storytelling:** Validates that the results aren't driven by "mom-and-pop" agencies versus individuals.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a robustness check (Section 6.9). The main text is getting long (11 figures).

### Figure 11: "Exit Timing Validation: Monthly Change in National HCBS Provider Counts"
**Page:** 33
- **Formatting:** Bar plot of first differences.
- **Clarity:** The March 2020 spike is the focus.
- **Storytelling:** Proves that "exits" didn't bunch *just before* the pandemic, supporting the pre-treatment measure.
- **Recommendation:** **MOVE TO APPENDIX**
  - Methodologically important, but visually jarring in the middle of the results.

---

## Appendix Exhibits

### Table 7: "Robustness Checks"
**Page:** 42
- **Formatting:** Massive summary table.
- **Clarity:** Very efficient way to show many specifications.
- **Storytelling:** Essential for the "Resolution of the identification puzzle" discussion.
- **Recommendation:** **KEEP AS-IS** (Could even be promoted to main text if space allows, as it summarizes the paper's "Synthesis").

### Table 8: "Entity-Type Heterogeneity: Individual vs. Organization Providers"
**Page:** 43
- **Formatting:** Standard.
- **Clarity:** Clear columns.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 11 main figures, 2 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper uses modern "broken-trend" visualizations that are common in recent *AEJ: Policy* or *AER: Insights* papers.
- **Strongest exhibits:** Figure 2 (Event Study) and Figure 4 (Broken-Trend Visualization).
- **Weakest exhibits:** Figure 8 (cluttered raw trends) and Figure 5 (redundant cross-section).
- **Missing exhibits:** A **Map** of the US showing exit intensity quartiles would be a standard and high-impact addition for a paper about state-level variation.

**Top 3 Improvements:**
1.  **Reduce Figure Count in Main Text:** Move Figure 5 (Collapsed), Figure 10 (Entity Type), and Figure 11 (Timing Validation) to the Appendix. 11 figures in the main text is too many; 7-8 is the "sweet spot" for QJE/AER.
2.  **Simplify Figure 8:** Split the four-line plot into two panels (High vs. Low exit) to improve visual clarity of the raw trends.
3.  **Add a Geographic Map:** Replace the bar chart (Fig 1) with a map, or add a map as Figure 1b, to show the regional clustering (Southeast/Mountain West) mentioned in the text.