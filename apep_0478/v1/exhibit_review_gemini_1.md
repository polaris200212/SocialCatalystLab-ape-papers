# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T01:48:39.111276
**Route:** Direct Google API + PDF
**Tokens:** 19957 in / 2228 out
**Response SHA256:** 9863c8472cf11806

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 9
- **Formatting:** Clean, standard booktabs style. However, the "Year" and "Total operators" columns are slightly crowded. Numbers are not perfectly decimal-aligned.
- **Clarity:** Excellent. The 1940–1950 structural break in "Per 10k emp." is immediately visible.
- **Storytelling:** Strong. It sets the stage for the adoption puzzle by showing growth until 1940 and the aging/feminization of the workforce.
- **Labeling:** Clear. The note correctly identifies the occupation code.
- **Recommendation:** **REVISE**
  - Decimal-align all numeric columns.
  - Add a horizontal rule (midrule) between the header and the 1900 row to separate the unit descriptors (%, mean, etc.) from the data.

### Figure 1: "The Rise and Fall of the Elevator Operator"
**Page:** 10
- **Formatting:** Modern look, but the internal labels (e.g., "7,943") on the data points create visual clutter. The source note is too close to the x-axis.
- **Clarity:** The "1945 Strike" shaded region is a great touch.
- **Storytelling:** Effective, though it partially duplicates Table 1.
- **Labeling:** Y-axis needs "Number of" before "Elevator operators."
- **Recommendation:** **REVISE**
  - Remove the data point labels (the numbers above the line) to reduce clutter; the y-axis already provides the scale.
  - Increase the font size of the "1945 Strike" text within the red band.

### Figure 2: "Building Service Occupations, 1900–1950"
**Page:** 11
- **Formatting:** Standard ggplot-style grid. Top journals often prefer minimal or no gridlines.
- **Clarity:** Colors are distinguishable, but "Janitors" dominates the scale, making the "Elevator operators" line look flat.
- **Storytelling:** Crucial for the "why just elevators?" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Minor: remove gridlines).

### Figure 3: "Geographic Concentration of Elevator Operators"
**Page:** 12
- **Formatting:** Consistent with Figure 2.
- **Clarity:** New York's outlier status is very clear.
- **Storytelling:** Justifies the use of New York as the treated unit in the SCM.
- **Labeling:** Descriptive.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Demographic Transformation of the Elevator Operator Workforce"
**Page:** 13
- **Formatting:** Clean.
- **Clarity:** Dual lines work well here.
- **Storytelling:** Shows the "Gateway occupation" and "Feminization" themes.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Age Distribution of Elevator Operators, 1900–1950"
**Page:** 14
- **Formatting:** Stacked area chart is appropriate for showing composition.
- **Clarity:** The transition from a "young" to "old" occupation is stark.
- **Storytelling:** Central to the "attrition" narrative.
- **Labeling:** Legend and axes are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Mean Age of Elevator Operators, 1900–1950"
**Page:** 14
- **Formatting:** Redundant with Figure 5.
- **Clarity:** Clear, but adds little that Figure 5 didn't show.
- **Storytelling:** It emphasizes the "Dying Occupation" point.
- **Recommendation:** **MOVE TO APPENDIX**
  - Figure 5 is much richer. Having both in the main text is unnecessary.

### Figure 7: "Synthetic Control: New York vs. Synthetic New York"
**Page:** 17
- **Formatting:** Good use of two panels. 
- **Clarity:** The divergence in 1950 is clear, but the "Synthetic NYC" line in Panel A has a strange jump in 1910.
- **Storytelling:** This is the "money shot" of the paper.
- **Labeling:** "NYC (actual)" vs "Synthetic NYC" is clear.
- **Recommendation:** **REVISE**
  - Ensure the x-axis scale is identical in both panels.
  - In the notes, briefly list the donor states with non-zero weights (or refer to Table 6).

### Figure 8: "Placebo Tests: New York vs. Donor State Gaps"
**Page:** 18
- **Formatting:** Standard SCM "spaghetti plot."
- **Clarity:** NY stands out clearly.
- **Storytelling:** Essential for SCM inference.
- **Labeling:** Includes p-value, which is excellent.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Event Study: New York Elevator Operators Relative to Comparison States"
**Page:** 19
- **Formatting:** The 95% CI is shown as a shaded area.
- **Clarity:** Clear "null" effect pre-1940.
- **Storytelling:** Validates the parallel trends assumption.
- **Labeling:** The y-axis label is a bit long.
- **Recommendation:** **REVISE**
  - Shorten y-axis to "$\beta$ Coefficients (Rel. to 1940)".
  - Add a horizontal line at $y=0$.

### Figure 10: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 21
- **Formatting:** Clean bar chart.
- **Clarity:** Labels on the x-axis are rotated, which is okay but can be avoided.
- **Storytelling:** Key finding on "dispersive" vs "concentrated" displacement.
- **Labeling:** Values on top of bars are helpful.
- **Recommendation:** **REVISE**
  - Flip the axes to a horizontal bar chart so the occupation labels can be read horizontally without tilting the head.

### Table 2: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 22
- **Formatting:** Redundant with Figure 10.
- **Clarity:** Logic is sound.
- **Storytelling:** Usually, journals prefer a table for transition matrices.
- **Recommendation:** **REVISE**
  - Merge this with Figure 10's information. Choose either the figure (more visual) or the table (more precise) for the main text. Move the other to the appendix.

### Table 3: "Individual Displacement: Elevator Operators vs. Other Building Service Workers"
**Page:** 23
- **Formatting:** Standard regression table.
- **Clarity:** Good.
- **Storytelling:** Quantifies the "Same Occupation" persistence.
- **Labeling:** Significance stars and SE parentheses are correct.
- **Recommendation:** **KEEP AS-IS**

### Figure 11 & 12: "Occupational Transitions by Race" and "...NYC vs. Other Cities"
**Page:** 24
- **Formatting:** Side-by-side bar charts.
- **Clarity:** A bit busy.
- **Storytelling:** Important for the heterogeneity discussion.
- **Recommendation:** **REVISE**
  - Consolidate these into a single "Figure 11: Heterogeneity in Transitions" with Panel A (Race) and Panel B (Geography).

---

## Appendix Exhibits

### Table 4: "Census Data Files"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** (Good for transparency).

### Table 5: "Variable Availability by Census Year"
**Page:** 33
- **Recommendation:** **KEEP AS-IS** (Standard in economic history papers).

### Table 6 & 7: "Synthetic Control Donor Weights" & "Pre-Treatment Balance"
**Page:** 34
- **Recommendation:** **KEEP AS-IS** (Table 6 reveals DC is the only donor, which is a significant finding that should be discussed).

### Figure 13: "Elevator Operators per 10,000 Population by State"
**Page:** 36
- **Formatting:** Faceted bar charts.
- **Storytelling:** Shows the "Rise" part of the story across different contexts.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 12 main figures (some clusters), 4 appendix tables, 1 appendix figure.
- **General quality:** High. The paper uses modern visualization (SCM, Event Studies) effectively. The "Aging Occupation" figures are particularly AER-style.
- **Strongest exhibits:** Figure 7 (SCM), Figure 5 (Age Distribution).
- **Weakest exhibits:** Figure 10/Table 2 (Redundancy), Figure 1 (Numerical clutter).
- **Missing exhibits:** A **Balance Table** for the individual-level linked panel (comparing linked vs. non-linked workers) is standard to address selection bias.

### Top 3 Improvements:
1.  **Reduce Redundancy:** Consolidate the transition data (Table 2 and Figure 10) and the heterogeneity plots (Figures 11 and 12).
2.  **Horizontal Bar Charts:** Change Figure 10 (Transitions) to a horizontal layout to improve readability of occupation names.
3.  **Clean up Line Charts:** Remove the numeric data-point labels from Figure 1 and remove the light grey background grids across all figures for a "whiter," cleaner journal look.