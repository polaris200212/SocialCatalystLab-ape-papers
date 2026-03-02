# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-17T15:20:32.545991
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 2212 out
**Response SHA256:** da2cbd90a32865c3

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Clean, standard "booktabs" style. However, SDs for HCBS spending ($2454.1M) suggest high skewness. 
- **Clarity:** Good use of panels to separate outcomes from treatment variation.
- **Storytelling:** Essential. It establishes the scale of the Medicaid HCBS market ($1.09T).
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Add a column for "N" (Observations) to clarify if this is state-year or NPI-level. 
  - For spending variables, consider adding a "Median" column given the high standard deviations relative to the mean.

### Table 2: "Baseline Balance: Treated vs. Never-Treated States (2018)"
**Page:** 10
- **Formatting:** Professional. Standard errors/SDs are correctly placed in parentheses.
- **Clarity:** The "Difference" column is helpful for a quick 10-second parse of selection into treatment.
- **Storytelling:** Critical for DiD papers to show baseline differences, even if the identification relies on parallel trends.
- **Labeling:** "N (states)" at the bottom is excellent practice.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Minimum Wage Increases on HCBS Provider Supply"
**Page:** 12
- **Formatting:** AER-ready. Decimal-aligned coefficients and consistent use of parentheses/brackets.
- **Clarity:** Excellent. Columns are logical (Log vs. Levels, Providers vs. Spending).
- **Storytelling:** This is the "money" table of the paper. It clearly shows the supply contraction.
- **Labeling:** Significance stars and CI notes are standard and clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Event Study: Effect of Minimum Wage Increases on HCBS Provider Supply"
**Page:** 13
- **Formatting:** Professional, though the light grey background grid is a bit prominent for *Econometrica*. 
- **Clarity:** The path from 0 to -0.26 is very clear. Shaded CIs are readable.
- **Storytelling:** This provides the visual proof of parallel trends and the "growing" effect over time.
- **Labeling:** Good y-axis labeling.
- **Recommendation:** **REVISE**
  - Remove the plot title "Effect of Minimum Wage..." from *inside* the chart area (journal style usually puts titles in the caption only).
  - Increase the font size of the axis labels and tick marks.

### Figure 2: "Event Study: Effect of Minimum Wage Increases on HCBS Spending"
**Page:** 14
- **Formatting:** Consistent with Figure 1.
- **Clarity:** The null effect is immediately obvious.
- **Storytelling:** Important contrast to Figure 1; suggests the "intensive margin" or "composition" effect mentioned in the text.
- **Recommendation:** **REVISE**
  - Consolidate: Merge Figure 1 and Figure 2 into a single Figure with Panel A (Providers) and Panel B (Spending). This allows the reader to compare the two trajectories on one page.

### Figure 3: "Staggered Adoption of State Minimum Wage Increases, 2018–2024"
**Page:** 15
- **Formatting:** Good use of a choropleth map.
- **Clarity:** Colors are distinct. The "Orange" for federal minimum stands out well.
- **Storytelling:** Essential for showing the geographic clustering (Northeast/West vs. South).
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Raw HCBS Provider Trends by Treatment Cohort"
**Page:** 16
- **Formatting:** Clean line plot.
- **Clarity:** Good. The "Typical first treatment" vertical line is helpful.
- **Storytelling:** Supports the DiD by showing raw data trends.
- **Recommendation:** **MOVE TO APPENDIX**
  - The Event Study (Fig 1) is a more rigorous version of this. While "raw" plots are nice, top journals prefer space for mechanism/heterogeneity plots.

### Figure 5: "Treatment Effects by Adoption Cohort"
**Page:** 17
- **Formatting:** Standard dot-and-whisker plot.
- **Clarity:** Clear, though N is small for some cohorts (as noted in text).
- **Storytelling:** Shows the result isn't driven by one weird year/cohort.
- **Recommendation:** **REVISE**
  - Add the number of states in each cohort (n=X) directly above the x-axis labels to signal the weight of each point.

### Table 4: "Treatment Cohort Characteristics"
**Page:** 18
- **Formatting:** Simple and clean.
- **Clarity:** Logical layout.
- **Storytelling:** Redundant with Table 6 in the Appendix (they are identical).
- **Recommendation:** **REMOVE**
  - The text on page 17/18 already describes these patterns. Table 2 already handles baseline balance. This table doesn't add enough marginal value for the main text.

### Figure 6: "Falsification Test: Effect on Non-HCBS (CPT) Provider Supply"
**Page:** 18
- **Formatting:** Consistent with main event study.
- **Clarity:** The "Expected null effect" annotation inside the plot is a bit "chatty" for top journals.
- **Storytelling:** High-value exhibit. Proves the mechanism is specific to low-wage sectors.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (as a Panel in the primary Results figure).

### Table 5: "Robustness of Main Result"
**Page:** 19
- **Formatting:** Concise.
- **Clarity:** Very high.
- **Storytelling:** Essential for "bulletproofing" the result.
- **Recommendation:** **KEEP AS-IS** (Note: Table 8 in the appendix is identical; delete the duplicate in the appendix).

### Figure 7: "Leave-One-Out Sensitivity Analysis"
**Page:** 21
- **Formatting:** Good "Caterpillar" plot.
- **Clarity:** High. The vertical dashed line for the full-sample ATT is a great benchmark.
- **Storytelling:** Standard robustness.
- **Recommendation:** **MOVE TO APPENDIX**
  - These are rarely in the main text of an AER/QJE paper unless a single state is highly controversial.

### Figure 8: "State Minimum Wage Trajectories, 2017–2024"
**Page:** 22
- **Formatting:** Good use of colors for different states.
- **Clarity:** Cluttered. Too many overlapping lines at the $10-$12 range.
- **Storytelling:** Illustrative but not analytical.
- **Recommendation:** **MOVE TO APPENDIX**

---

## Appendix Exhibits

### Table 6: "Treatment Cohort Characteristics"
**Page:** 29
- **Recommendation:** **KEEP AS-IS** (Keep here, remove from main text).

### Table 7: "Event Study Coefficients: Log(HCBS Providers)"
**Page:** 30
- **Formatting:** Excellent. Showing the exact numbers behind Figure 1 is a must for the appendix.
- **Clarity:** High.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Robustness of Main Result"
**Page:** 30
- **Recommendation:** **REMOVE** (Exact duplicate of Table 5).

### Figure 9: "Robustness of Main Result Across Specifications"
**Page:** 31
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Visual version of Table 5.
- **Recommendation:** **REVISE**
  - This is actually better than Table 5 for a reader to quickly digest. I would **PROMOTE** this to the main text and move Table 5 to the appendix.

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 8 Main Figures; 3 Appendix Tables, 1 Appendix Figure.
- **General quality:** High. The paper uses modern "Heterogeneity-robust" (CS 2021) visualization standards. Formatting is 90% of the way to a top journal.
- **Strongest exhibits:** Table 3 (Main Results) and Figure 6 (Falsification).
- **Weakest exhibits:** Figure 8 (Trajectory clutter) and Table 4 (Redundancy).
- **Missing exhibits:** 
    1. **Mechanism Table:** A table showing the interaction of minimum wage with "Medicaid Rate Generosity" (Prediction 1 in your framework).
    2. **State-Level Data Appendix:** A list of states, their first treatment year, and their 2018 vs 2024 min wage.

### Top 3 Improvements:
1. **Consolidate and Panelize:** Merge Figure 1 (Providers) and Figure 2 (Spending) into one two-panel figure. Merge Figure 6 (Falsification) into a three-panel result figure. This creates a "unified theory" of the results in one visual.
2. **Reduce Redundancy:** You have several tables (4 & 6, 5 & 8) that are duplicates. Eliminate the duplicates and move "illustrative" plots (Fig 4, Fig 7, Fig 8) to the appendix to leave room for more analytical charts in the main text.
3. **Professionalize Aesthetics:** Remove titles from *inside* the chart boxes (Figures 1, 2, 6, 9). Top journals use the caption (below the figure) for the title. Ensure all fonts in figures (axis labels) match the document font (Computer Modern/LaTeX).