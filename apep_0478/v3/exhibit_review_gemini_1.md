# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T23:51:58.841635
**Route:** Direct Google API + PDF
**Tokens:** 21517 in / 3092 out
**Response SHA256:** e3ce0971630137c4

---

This review evaluates the visual exhibits of the paper "Going Up Alone: The Lifecycle and Unequal Displacement of the Elevator Operator" according to the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 7
- **Formatting:** Clean, standard "booktabs" style. Number alignment is generally good.
- **Clarity:** Excellent. Provides a clear high-level overview of the occupation's demographic shift.
- **Storytelling:** Strong. It justifies the "paradoxical growth" mentioned in the abstract by showing the jump from 1900 to 1930.
- **Labeling:** Needs a clearer definition of "Per 10k employed" (denominator: all workers or urban workers?).
- **Recommendation:** **KEEP AS-IS** (Minor note adjustment only).

### Figure 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 8
- **Formatting:** Modern and professional. The 1945 strike highlight is a nice touch.
- **Clarity:** Very high.
- **Storytelling:** Redundant with Table 1. Figures 1 and 2 cover similar temporal ground.
- **Labeling:** Y-axis clearly labeled.
- **Recommendation:** **REVISE**
  - Consolidate this with Figure 2 as a multi-panel Figure (Panel A: Count, Panel B: Composition). This saves space and keeps the national "lifecycle" story in one place.

### Figure 2: "Demographic Transformation of the Elevator Operator Workforce"
**Page:** 9
- **Formatting:** Consistent with Figure 1. Legend is well-placed.
- **Clarity:** Good. Stacked area charts can be tricky, but here the message (Black share growth) is clear.
- **Storytelling:** Crucial for the "inequality" argument.
- **Labeling:** Axis titles are appropriate.
- **Recommendation:** **REVISE**
  - Merge into a composite Figure with Fig 1. In Panel B, ensure the colors for "Female share" and "Mean age" are high-contrast for black-and-white printing.

### Figure 3: "Building Service Occupations: Elevator Operators vs. Comparison Group, 1900–1950"
**Page:** 11
- **Formatting:** Excellent line weights.
- **Clarity:** The "1945 Strike" shaded region is a helpful visual anchor.
- **Storytelling:** This is the "money shot" for the counterfactual argument—showing that other service jobs grew while elevators declined.
- **Labeling:** Source note is complete.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Geographic Distribution of Elevator Operators Across States"
**Page:** 12
- **Formatting:** Consistent.
- **Clarity:** A bit cluttered with five lines. New York clearly dominates, but the others (OH, PA, IL) bunch up.
- **Storytelling:** Essential to set up the "Paradox of the Epicenter" (NYC).
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Consider a "New York vs. Rest of US" line or a "New York vs. Mean of Top 5" to reduce the spaghetti-plot effect.

### Figure 5: "Age Distribution: Elevator Operators vs. General Workforce"
**Page:** 13
- **Formatting:** Stacked area chart showing share of all operators.
- **Clarity:** The legend "60+" vs "Under 20" is easy to read.
- **Storytelling:** Important for explaining why displacement was so painful for the older cohort.
- **Labeling:** "Percent / Years" on y-axis is slightly confusing.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a nuance of Table 1. Fig 11 (Appendix) actually does a better job of showing the aging trend.

### Table 2: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 14
- **Formatting:** Standard. Decimal alignment is perfect.
- **Clarity:** Excellent. The ranking from highest to lowest share makes it easy to digest.
- **Storytelling:** Core finding. The 15.8% persistence is the key number.
- **Labeling:** Note defines N and the link to Figure 6.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Occupational Transitions of 1940 Elevator Operators by 1950"
**Page:** 15
- **Formatting:** Clean bar chart.
- **Clarity:** High.
- **Storytelling:** Redundant with Table 2. Top journals rarely allow both a table and a bar chart of the exact same data.
- **Labeling:** Annotating bars with percentages is good practice.
- **Recommendation:** **REMOVE** (The table is more precise; the figure adds no new info).

### Figure 7: "Direction of Occupational Mobility: Upward, Lateral, and Downward Transitions"
**Page:** 16
- **Formatting:** Professional color palette.
- **Clarity:** High.
- **Storytelling:** Very important for the "Lesson 2" argument in the discussion.
- **Labeling:** Definitions of Upward/Downward (OCCSCORE +/- 2) are in the notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "The Unequal Burden: Occupational Destinations by Race"
**Page:** 17
- **Formatting:** Grouped bar chart.
- **Clarity:** Very good. 
- **Storytelling:** This is the core "Unequal Displacement" finding.
- **Labeling:** Ensure "Non-Black" is used consistently (does it include "Other" from Fig 2?).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Individual Displacement: Elevator Operators vs. Other Building Service Workers"
**Page:** 18
- **Formatting:** Standard regression table.
- **Clarity:** Good.
- **Storytelling:** Crucial regression evidence. 
- **Labeling:** "Same Occ." and "Interstate Move" should be defined more formally (e.g., "Pr(Stayed in Same Occ.)"). Define significance stars in the note.
- **Recommendation:** **REVISE**
  - Add the mean of the dependent variable for the comparison group at the bottom of the table to help the reader interpret the magnitude of the 0.024 coefficient.

### Table 4: "The Paradox of the Epicenter: NYC vs. Non-NYC Occupational Transitions"
**Page:** 20
- **Formatting:** Clean comparison.
- **Clarity:** High.
- **Storytelling:** Crucial for the "Institutional Thickness" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "The Paradox of the Epicenter: NYC vs. Non-NYC Occupational Transitions"
**Page:** 20
- **Formatting:** Side-by-side bar chart.
- **Clarity:** High.
- **Storytelling:** Visualizes Table 4.
- **Labeling:** Note is comprehensive.
- **Recommendation:** **KEEP AS-IS** (Unlike Fig 6, this comparison is visually striking enough to keep alongside the table).

### Table 5: "The Paradox of the Epicenter: NYC vs. Non-NYC Elevator Operators"
**Page:** 21
- **Formatting:** Standard regression.
- **Clarity:** The interaction term `is_nyc_1940 x is_black` is the key.
- **Storytelling:** Vital for the "Lesson 3" argument.
- **Labeling:** Clarify what "Persist x Race" column represents (Interaction model for Pr(Still Elevator)).
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Selection into Persistence: Who Remains an Elevator Operator?"
**Page:** 22
- **Formatting:** Unusual to see Coefficient and AME in the same table without standard errors for both.
- **Clarity:** High.
- **Storytelling:** Supports the "Negative Selection" narrative.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - In a top journal, authors usually just report AMEs (Marginal Effects) for Logit/Probit models to save space. Remove the "Coefficient" column and just show AME with SE.

### Figure 10: "Who Remained? Average Marginal Effects on Probability of Persistence"
**Page:** 23
- **Formatting:** Coefficient plot (whisker plot).
- **Clarity:** Excellent. The vertical dashed line at zero is standard.
- **Storytelling:** This is a much better way to present Table 6.
- **Labeling:** Use of "n.s." vs "p < 0.05" in colors is very helpful.
- **Recommendation:** **KEEP AS-IS** (And consider removing Table 6 if space is tight).

### Table 7: "Heterogeneous Displacement: By Race, Sex, and City"
**Page:** 24
- **Formatting:** Logical grouping.
- **Clarity:** Good.
- **Storytelling:** Consolidates multiple interaction models.
- **Labeling:** Standard errors in parentheses.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Inverse Probability Weighting: Addressing Linkage Selection Bias"
**Page:** 25
- **Formatting:** Side-by-side comparison of Unweighted vs. IPW.
- **Clarity:** High.
- **Storytelling:** Essential robustness check.
- **Labeling:** "Unwtd" and "IPW" clearly delineated.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 11: "Mean Age of Elevator Operators, 1900–1950"
**Page:** 32
- **Formatting:** Clean line plot.
- **Recommendation:** **KEEP AS-IS** (Supports Fig 5/Table 1).

### Table 9: "Occupational Transitions by Age Group (1940 Age)"
**Page:** 33
- **Formatting:** Dense but readable.
- **Recommendation:** **KEEP AS-IS**

### Figure 12: "Elevator Operators by State, 1900–1950"
**Page:** 34
- **Formatting:** Small multiples (faceted bar charts).
- **Clarity:** Very high.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is more informative than the line plot in Figure 4. It shows the relative scale of NYC vs. the others much more effectively.

### Figure 13: "New York vs. Synthetic New York: Elevator Operator Concentration, 1900–1950"
**Page:** 35
- **Formatting:** Standard SCM plot.
- **Clarity:** Dashed line for synthetic is standard.
- **Recommendation:** **KEEP AS-IS**

### Figure 14: "Placebo Tests: Permutation Inference for Synthetic Control"
**Page:** 36
- **Formatting:** Gray "spaghetti" lines with the red treatment line.
- **Recommendation:** **KEEP AS-IS**

### Figure 15: "Event Study: New York State Elevator Operators Relative to Other States"
**Page:** 37
- **Formatting:** Standard event study plot with 95% CIs.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - For top journals (AER/QJE), an event study is a "must-have" in the main body if you are claiming a specific shock or divergence over time.

### Table 10: "New York State vs. Synthetic New York..."
**Page:** 38
- **Recommendation:** **REMOVE** (This is just the data points for Figure 13).

### Table 11: "Robustness Checks"
**Page:** 39
- **Formatting:** Combines Event Study, Triple Diff, and Excl. Janitors.
- **Clarity:** A bit "kitchen sink." 
- **Recommendation:** **REVISE**
  - Split this. The "Excl. Janitors" robustness belongs with Table 3. The "Triple Diff" belongs in the SCM section.

---

# Overall Assessment

- **Exhibit count:** 7 main tables, 10 main figures, 4 appendix tables, 5 appendix figures.
- **General quality:** Extremely high. The paper follows modern "clean" visualization standards (minimal gridlines, high-quality fonts, logical grouping).
- **Strongest exhibits:** Figure 3 (The Counterfactual comparison) and Figure 10 (The Selection plot).
- **Weakest exhibits:** Figure 1 and Figure 6 (both are redundant with tables).
- **Missing exhibits:** A "Table 0" of **Summary Statistics** is missing. Readers need to see the means of age, race, and income for the elevator operators vs. the comparison group in 1940 before seeing the transitions.

### Top 3 Improvements:
1.  **Consolidate and Prune:** Merge Figure 1 and 2 into a single demographic lifecycle exhibit. Remove Figure 6 (the bar chart of the transition table) to reduce redundancy.
2.  **Add Summary Statistics Table:** Include a table showing 1940 baseline characteristics for the linked sample vs. the full census to prove linkage quality visually.
3.  **Promote Key Evidence:** Move the Event Study (Fig 15) and State Small Multiples (Fig 12) to the main text. These provide the "institutional" evidence that the paper's discussion leans on heavily.