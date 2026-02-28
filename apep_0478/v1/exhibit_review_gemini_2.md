# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T02:22:48.597177
**Route:** Direct Google API + PDF
**Tokens:** 21517 in / 2432 out
**Response SHA256:** 53ee7bb0d6c4e361

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 9
- **Formatting:** Clean and professional. Numbers are centered; decimal alignment would be slightly better but is not strictly necessary for percentages.
- **Clarity:** Excellent. It provides a comprehensive demographic "atlas" in a single view.
- **Storytelling:** Strong. It immediately justifies the "Aging Workforce" narrative discussed later by showing the "Under 20" vs "60+" shift.
- **Labeling:** Good. It defines the OCC code in the notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "The Rise and Fall of the Elevator Operator"
**Page:** 10
- **Formatting:** Modern and clean. The red highlight for the "1945 Strike" is effective.
- **Clarity:** High. The labels on the data points (82,666, etc.) make the table nearly redundant, but they help the "10-second parse."
- **Storytelling:** This is the "hook" figure. It clearly shows that absolute counts grew while the "strike" coincided with a tapering off.
- **Labeling:** Descriptive title and source notes present.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Building Service Occupations, 1900–1950"
**Page:** 11
- **Formatting:** Colors are distinct. Gridlines are subtle.
- **Clarity:** Good. It clearly shows the divergence of elevator operators from other service roles.
- **Storytelling:** Crucial. It shows that the decline was occupation-specific, not a general decline in building service labor.
- **Labeling:** Y-axis is clearly labeled "Workers per 10,000 employed."
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Geographic Concentration of Elevator Operators"
**Page:** 12
- **Formatting:** Standard line plot.
- **Clarity:** The "New York" line is so dominant that the other four states are bunched at the bottom.
- **Storytelling:** Advances the argument that New York is the "only" place that matters for a case study.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Use a log scale for the Y-axis or a "New York vs. Others" average to make the "others" more readable, though the current version effectively shows New York's "Outsized Share."

### Figure 4: "Demographic Transformation of the Elevator Operator Workforce"
**Page:** 13
- **Formatting:** Good use of colors.
- **Clarity:** Clear, though the "Black (%)" and "Female (%)" lines represent very different stories (one is steady, one is an explosion).
- **Storytelling:** Supports the demographic transformation section.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Age Distribution of Elevator Operators, 1900–1950"
**Page:** 14
- **Formatting:** Stacked area chart.
- **Clarity:** Very clear. The "aging out" of the bottom (youngest) cohorts is visually striking.
- **Storytelling:** This is one of the most important figures for the "attrition" argument.
- **Labeling:** Legend and axes are appropriate.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Mean Age of Elevator Operators, 1900–1950"
**Page:** 14
- **Formatting:** Standard line chart.
- **Clarity:** High.
- **Storytelling:** **REDUNDANT.** This conveys the exact same information as Figure 5 but with less detail.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** or **REMOVE**. Figure 5 is the superior visual for this story.

### Figure 7: "Synthetic Control: New York vs. Synthetic New York"
**Page:** 18
- **Formatting:** Two-panel vertical layout.
- **Clarity:** Panel A (levels) and Panel B (gap) are the gold standard for SCM papers.
- **Storytelling:** This is the core causal exhibit. It shows the "paradox" (NY retaining more than its counterfactual).
- **Labeling:** Clear 1945 strike marker.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Placebo Tests: New York vs. Donor State Gaps"
**Page:** 19
- **Formatting:** "Spaghetti plot."
- **Clarity:** New York (red) stands out clearly.
- **Storytelling:** Necessary for SCM validity.
- **Labeling:** Includes the p-value (0.056) in the note, which is vital.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Event Study: New York Elevator Operators Relative to Comparison States"
**Page:** 20
- **Formatting:** Standard event study plot with CI bands.
- **Clarity:** The blue shading for CIs is standard.
- **Storytelling:** Complements SCM by showing the "structural break" in the trend.
- **Labeling:** Reference year (1940) correctly centered at zero.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 22
- **Formatting:** Bar chart with percentages on top.
- **Clarity:** Very high.
- **Storytelling:** Visually represents the transition matrix.
- **Labeling:** X-axis labels are rotated for readability.
- **Recommendation:** **KEEP AS-IS** (Consider merging with Table 2 or removing Table 2 from the main text to avoid redundancy).

### Table 2: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 23
- **Formatting:** Clean, standard LaTeX booktabs style.
- **Clarity:** High.
- **Storytelling:** Redundant with Figure 10.
- **Labeling:** Note explains the sample.
- **Recommendation:** **MOVE TO APPENDIX**. Figure 10 is more impactful for the main text.

### Table 3: "Individual Displacement: Elevator Operators vs. Other Building Service Workers"
**Page:** 24
- **Formatting:** Standard 3-column regression table.
- **Clarity:** High. Decimal-aligned coefficients and SEs in parentheses.
- **Storytelling:** Shows the "persistence" effect (Column 1).
- **Labeling:** Stars defined in notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 11 & 12: "Occupational Transitions by Race" and "...NYC vs. Other Cities"
**Page:** 25
- **Formatting:** Grouped bar charts.
- **Clarity:** Good, but having two separate figures for heterogeneity makes the paper feel "long."
- **Storytelling:** These are the "mechanism" figures.
- **Labeling:** Legends are clear.
- **Recommendation:** **REVISE**. Combine these into a single "Figure 11: Heterogeneity in Transitions" with Panel A (Race) and Panel B (Geography).

### Table 4: "Heterogeneous Displacement: By Race, Sex, and City"
**Page:** 26
- **Formatting:** Interaction table.
- **Clarity:** The "x Black" and "x Female" notation is standard.
- **Storytelling:** Formalizes the visual evidence from Figures 11 and 12.
- **Labeling:** Clear notes.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks: Alternative Specifications and Placebo Tests"
**Page:** 29
- **Formatting:** High-density table.
- **Clarity:** Good. It packs five distinct tests into one view.
- **Storytelling:** Essential "defensive" table for top journals.
- **Labeling:** Explains each column clearly.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 6: "Census Data Files"
**Page:** 35
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Variable Availability by Census Year"
**Page:** 36
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Synthetic Control Donor Weights"
**Page:** 37
- **Clarity:** Note that 100% of the weight goes to DC. 
- **Recommendation:** **KEEP AS-IS**. This is a vital (and potentially controversial) SCM finding.

### Table 9: "Pre-Treatment Balance: New York vs. Synthetic New York"
**Page:** 37
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Elevator Operators per 10,000 Population by State, 1900–1950"
**Page:** 39
- **Formatting:** Multi-panel bar charts.
- **Clarity:** Very high.
- **Storytelling:** Useful for showing that New York's trend was not just a general urban trend.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 12 main figures, 4 appendix tables, 1 appendix figure.
- **General quality:** The visual quality is very high (likely R/ggplot2). The paper is currently "figure-heavy," which is good for storytelling but might lead to some redundancy.
- **Strongest exhibits:** Figure 5 (Age Distribution), Figure 7 (SCM Results), Figure 10 (Transitions).
- **Weakest exhibits:** Figure 6 (redundant with Fig 5), Figure 3 (extreme scale issues).
- **Missing exhibits:** A **Summary Statistics Table** for the individual-level linked panel (showing Means/SDs of age, education, and income for Operators vs. Controls in 1940) would be standard for the AER/QJE "Where did they go?" section.

### Top 3 Improvements:
1.  **Reduce Redundancy:** Remove Figure 6 (Mean Age) and move Table 2 (Transition Matrix) to the appendix. Figure 5 and Figure 10 tell those stories more effectively in the main text.
2.  **Consolidate Heterogeneity:** Merge Figures 11 and 12 into a single multi-panel figure. This tightens the narrative in the "Transitions" section.
3.  **Address Figure 3 Scale:** Adjust Figure 3 to handle New York's dominance—either use a log scale or move it to the appendix and keep the focus on the SCM counterfactual.