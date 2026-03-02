# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T09:42:32.856998
**Route:** Direct Google API + PDF
**Tokens:** 23077 in / 2490 out
**Response SHA256:** 79ee3cb5e9f0c825

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 10
- **Formatting:** Clean and professional. Proper use of horizontal rules (booktabs style). Panels are clearly delineated.
- **Clarity:** Excellent. Using "(pp)" for percentage points and "(%)" for levels helps avoid common confusion in long-difference papers.
- **Storytelling:** Essential. It establishes the baseline "room for improvement" (12.31 pp deficit) and the scale of the shock.
- **Labeling:** Clear. Notes define the sample and the construction of the primary instrument.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Baseline Water Infrastructure Deficit"
**Page:** 11
- **Formatting:** Modern and clean. The red dashed line for the median is a helpful touch.
- **Clarity:** High. It clearly shows the mass of districts with small deficits and the "treatment" tail.
- **Storytelling:** Good, but the bar at 100 on the x-axis looks like an artifact or a small cluster of extreme outliers.
- **Labeling:** The y-axis "Number of Districts" is appropriate. The sub-label under the title is slightly redundant with the axis label.
- **Recommendation:** **REVISE**
  - Investigate the bar at 100. If these are districts with 0% improved water, ensure they aren't driving the entire result. 
  - Change "Water Infrastructure Deficit (percentage points)" to "Baseline Water Deficit (pp)" to match Table 1 nomenclature.

### Table 2: "First Stage: Baseline Water Deficit Predicts Water Improvement"
**Page:** 14
- **Formatting:** Standard journal format. Decimal alignment is good. 
- **Clarity:** Very high. The progression from unconditional to controlled models is logical.
- **Storytelling:** This is a "powerhouse" first stage ($F > 1000$). It effectively shuts down concerns about instrument relevance.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "First Stage: Water Deficit vs. Water Improvement"
**Page:** 15
- **Formatting:** Binscatter is the "gold standard" for this type of paper. Residualization on FE is appropriate.
- **Clarity:** Very clean. Error bars are helpful.
- **Storytelling:** Confirms the linear relationship identified in Table 2.
- **Labeling:** The y-axis label is a bit long; "$\Delta$ Improved Water (residualized, pp)" would suffice.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Reduced Form: Water Deficit and Education Outcomes"
**Page:** 16
- **Formatting:** Journal-ready.
- **Clarity:** Good. It presents the raw "intent-to-treat" style effect of the deficit.
- **Storytelling:** This table and Table 4 (IV) are the "meat" of the paper. 
- **Labeling:** Significance stars and clustering are well-noted.
- **Recommendation:** **REVISE**
  - **Consolidation Opportunity:** Consider merging Table 3 and Table 4. You can have Panel A: Reduced Form and Panel B: IV. This saves space and allows the reader to see the scaling immediately.

### Figure 3: "Reduced Form: Water Deficit vs. Change in Female School Attendance"
**Page:** 17
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Clear, though the outlier bin at the bottom left (around -25, -12) is prominent.
- **Storytelling:** Shows the primary result is not driven by a specific part of the distribution.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "IV Estimates: Effect of Water Improvement on Education"
**Page:** 18
- **Formatting:** Professional.
- **Clarity:** Clear scaling.
- **Storytelling:** Provides the causal magnitudes discussed in the abstract.
- **Labeling:** Notes explain the 2SLS procedure.
- **Recommendation:** **REVISE**
  - As noted for Table 3, consolidate this with the Reduced Form table to create a single "Education Impacts" exhibit.

### Table 5: "Health Mechanism: Water Deficit and Health Outcomes"
**Page:** 19
- **Formatting:** Good use of Panel A (RF) and Panel B (IV). This is the correct way to present multi-stage results.
- **Clarity:** 5 columns might be tight in some journals; ensure font size is legible.
- **Storytelling:** Crucial for the mechanism. The "Diarrhea" anomaly is handled well in the text, but could be flagged in the table note as "likely reporting bias."
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Multi-Outcome Coefficient Plot: Effect of Water Infrastructure Deficit on Human Capital"
**Page:** 20
- **Formatting:** Excellent. Color-coding by domain (Education, Health, Maternal) is high-level visual storytelling.
- **Clarity:** Allows for a 5-second "at-a-glance" understanding of the paper's breadth.
- **Storytelling:** This is your "AER/QJE" figure. It summarizes the whole paper.
- **Labeling:** The x-axis "Coefficient on Water Gap" is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Placebo: Water Deficit and Nighttime Lights"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** Clear "null" result.
- **Storytelling:** Essential for the exclusion restriction.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** 
  - While important, the Figure 5 (event study) is a more powerful way to show this. The table can be moved to the appendix to save main-text space.

### Figure 5: "VIIRS Nighttime Lights Event Study: No Differential Trends by Water Deficit"
**Page:** 22
- **Formatting:** Excellent event-study plot. Vertical line for JJM launch is key.
- **Clarity:** Clear visual evidence of parallel trends/no pre-trends.
- **Storytelling:** This is the most important "defensive" exhibit. It should definitely stay in the main text.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Heterogeneity in Education Effects"
**Page:** 23
- **Formatting:** Clean. $p$-values for equality of coefficients are included (very important for reviewers).
- **Clarity:** Logical splits.
- **Storytelling:** Supports the "time-reallocation" mechanism.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Leave-One-State-Out Estimates: Female School Attendance"
**Page:** 24
- **Formatting:** A bit cluttered on the x-axis due to the number of states.
- **Clarity:** Hard to read the state names.
- **Storytelling:** High-quality robustness check.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check that doesn't need to be in the main text of a top-tier journal unless a single state is particularly controversial.

### Figure 7: "Randomization Inference: Permutation Distribution of Coefficients"
**Page:** 25
- **Formatting:** Standard RI plot.
- **Clarity:** Clear evidence that the result is not a fluke.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 8: "Robustness Summary: Female School Attendance"
**Page:** 27
- **Formatting:** Good summary table.
- **Clarity:** Combines several different tests into one view.
- **Storytelling:** Very efficient for the reader.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Placebo Outcomes"
**Page:** 28
- **Formatting:** Standard.
- **Storytelling:** More "null" results. 
- **Recommendation:** **MOVE TO APPENDIX**
  - These are useful but second-order compared to the Nightlights and Education results.

### Figure 8: "Placebo Test: Distribution of Placebo Coefficients"
**Page:** 29
- **Formatting:** Consistent with Figure 4.
- **Storytelling:** Visually groups the "nulls."
- **Recommendation:** **MOVE TO APPENDIX**

---

## Appendix Exhibits

### Table A1: "District Matching Between NFHS-4 and NFHS-5"
**Page:** 36
- **Recommendation:** **KEEP AS-IS** (Essential for replication/transparency).

### Table A2: "Variable Definitions"
**Page:** 38
- **Recommendation:** **KEEP AS-IS** (Standard best practice).

### Table A3: "Full OLS Coefficients: Reduced-Form Regression"
**Page:** 39
- **Recommendation:** **KEEP AS-IS** (Good to show control coefficients).

### Table A4: "Correlation Matrix: Outcome Changes"
**Page:** 40
- **Recommendation:** **KEEP AS-IS**.

### Table A5: "Multiple Hypothesis Testing: Sharpened q-Values"
**Page:** 41
- **Recommendation:** **KEEP AS-IS**.

### Table A6: "Wild Cluster Bootstrap p-Values"
**Page:** 42
- **Recommendation:** **KEEP AS-IS**.

### Table A7: "First Stage by Region"
**Page:** 42
- **Recommendation:** **KEEP AS-IS**.

---

## Overall Assessment

- **Exhibit count:** 9 main tables (recommended 6), 7 main figures (recommended 4), 7 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The exhibits look like they belong in a top-5 journal. The use of binscatters, coefficient plots, and event studies demonstrates a mastery of modern empirical visualization.
- **Strongest exhibits:** Figure 4 (Multi-outcome plot) and Figure 5 (Nightlights event study).
- **Weakest exhibits:** Figure 6 (Cluttered x-axis) and the redundancy between Tables 3 and 4.
- **Missing exhibits:** A **Map of India** showing the baseline water deficit by district. Top journals (especially Development papers) almost always expect a geographic visualization of the identifying variation.

### Top 3 Improvements:
1.  **Add a map:** Create a Choropleth map of India showing the "Baseline Water Deficit" by district. This helps the reader understand the geography of the "shock."
2.  **Consolidate Education Tables:** Merge Table 3 and Table 4 into a single "Impacts on Education" table with Reduced Form and IV panels.
3.  **Streamline Main Text:** Move the technical robustness/placebo exhibits (Table 9, Figure 6, Figure 7, Figure 8) to the Appendix. A leaner main text with only the most powerful visuals (Figures 2, 4, 5) will be more persuasive to editors.