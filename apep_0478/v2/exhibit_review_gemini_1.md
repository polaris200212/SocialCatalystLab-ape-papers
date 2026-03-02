# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T10:58:13.038975
**Route:** Direct Google API + PDF
**Tokens:** 22037 in / 2857 out
**Response SHA256:** 835d04cda96da79d

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 7
- **Formatting:** Clean and professional. Adheres to AER style with minimal horizontal rules and no vertical lines.
- **Clarity:** Excellent. Provides a clear bird's-eye view of the occupation’s lifecycle and demographic shifts (aging and feminization).
- **Storytelling:** Essential. It establishes the "peak and plateau" mentioned in the text.
- **Labeling:** Clear. Source and OCC codes are well-defined in the note.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "The Rise and Fall of the Elevator Operator, 1900–1950"
**Page:** 8
- **Formatting:** Modern and clean. The use of a shaded region for the 1945 strike is an effective visual anchor.
- **Clarity:** High. The labels on data points help the reader parse the specific counts without looking back at Table 1.
- **Storytelling:** Redundant. This figure visualizes exactly what is in the "Total operators" column of Table 1. 
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - **Specific Change:** To reduce redundancy and increase "AER-style" density, move the counts to a secondary Y-axis or consolidate this into a multi-panel figure with demographic shares. Alternatively, replace the line with "Operators per 10k employed" to show the relative decline more sharply.

### Figure 2: "Demographic Transformation of the Elevator Operator Workforce"
**Page:** 10
- **Formatting:** Good use of panels. Panel A (stacked area) and Panel B (line) are standard.
- **Clarity:** Panel A is a bit "heavy" visually. The colors for "Other" and "White" are distinct, but the message of the growing "Black" share is the key; consider a simple line chart for the Black share to match Panel B.
- **Storytelling:** Strong. It shows the occupation becoming a "refuge" for marginalized groups.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Building Service Occupations: Elevator Operators vs. Comparison Group, 1900–1950"
**Page:** 12
- **Formatting:** Standard line plot.
- **Clarity:** Good. The 1945 strike shadow is helpful for context.
- **Storytelling:** Crucial. It shows that the decline was occupation-specific, not a general trend in building services.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Geographic Distribution of Elevator Operators Across States"
**Page:** 13
- **Formatting:** Clean.
- **Clarity:** The New York line dominates, which is the point. 
- **Storytelling:** This could be consolidated. The "story" is that New York is an outlier.
- **Labeling:** Descriptive.
- **Recommendation:** **REVISE**
  - **Specific Change:** Consider turning this into a map for 1940 (the peak) or moving it to the appendix. The "New York outlier" story is already well-handled by the Synthetic Control figure.

### Figure 5: "Age Distribution: Elevator Operators vs. General Workforce"
**Page:** 14
- **Formatting:** The stacked area chart for age groups is slightly confusing because "aging" is usually better shown by shifting density plots or a line chart of shares.
- **Clarity:** It takes a moment to realize the "60+" group (lightest blue) is expanding significantly at the bottom (or top depending on the stack).
- **Storytelling:** Important for the "refuge" argument.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - **Specific Change:** Use a "Small Multiples" approach or two overlaid Kernel Density plots (1900 vs 1950) to show the bimodal shift more clearly.

### Table 2: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 15
- **Formatting:** Professional.
- **Clarity:** Very high.
- **Storytelling:** This is the "meat" of the transition analysis.
- **Labeling:** Clear note on sample restrictions.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Occupational Transitions of 1940 Elevator Operators by 1950"
**Page:** 16
- **Formatting:** Clean bar chart.
- **Clarity:** High.
- **Storytelling:** Total redundancy with Table 2. Top journals rarely allow both a table and a bar chart of the exact same data.
- **Labeling:** Clear.
- **Recommendation:** **REMOVE** (The table is more precise and sufficient for the main text).

### Figure 7: "Direction of Occupational Mobility: Upward, Lateral, and Downward Transitions"
**Page:** 17
- **Formatting:** Colorful, but perhaps a bit "corporate" for QJE/AER.
- **Clarity:** The message is clear, though the N-values in parentheses make the bars look cluttered.
- **Storytelling:** Strong. It categorizes the messy data in Table 2 into a clear economic narrative.
- **Labeling:** Excellent notes defining "Upward" and "Downward" via OCCSCORE.
- **Recommendation:** **KEEP AS-IS** (But consider grayscale or more muted "academic" colors).

### Figure 8: "The Unequal Burden: Occupational Destinations by Race"
**Page:** 18
- **Formatting:** Side-by-side bars are standard.
- **Clarity:** Clear.
- **Storytelling:** This is the most "impactful" figure in the paper. It shows the divergence in opportunities.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Individual Displacement: Elevator Operators vs. Other Building Service Workers"
**Page:** 19
- **Formatting:** Standard regression table.
- **Clarity:** Good.
- **Storytelling:** Formalizes the comparison group analysis.
- **Labeling:** Defines significance stars and clustering.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "The Paradox of the Epicenter: NYC vs. Non-NYC Occupational Transitions"
**Page:** 21
- **Formatting:** A bit cluttered with four columns of data.
- **Clarity:** Hard to parse the comparison quickly.
- **Storytelling:** Important, but Figure 9 does the work better.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 9: "The Paradox of the Epicenter: NYC vs. Non-NYC Occupational Transitions"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** High. Shows the "Persistence" (Stayed) advantage in NYC.
- **Storytelling:** Essential to the paper's core paradox.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "The Paradox of the Epicenter: NYC vs. Non-NYC Elevator Operators"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** The interaction term `is_nyc_1940 x is_black` is the key finding here.
- **Storytelling:** Crucial.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Selection into Persistence: Who Remains an Elevator Operator?"
**Page:** 23
- **Formatting:** Logit results with AME.
- **Clarity:** Very high.
- **Storytelling:** Supporting evidence for the demographic profile of those "left behind."
- **Labeling:** Descriptive.
- **Recommendation:** **KEEP AS-IS** (Or move to appendix if space is tight).

### Figure 10: "Who Remained? Average Marginal Effects on Probability of Persistence"
**Page:** 24
- **Formatting:** Dot-and-whisker plot is perfect for top journals.
- **Clarity:** Excellent. One glance tells the whole selection story.
- **Storytelling:** Superior to Table 6 for the main text.
- **Labeling:** Clear legend for significance.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Heterogeneous Displacement: By Race, Sex, and City"
**Page:** 25
- **Formatting:** Standard.
- **Clarity:** These are three different interaction models.
- **Storytelling:** Robustness/Heterogeneity.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 11: "New York vs. Synthetic New York: Elevator Operators After the 1945 Strike"
**Page:** 27
- **Formatting:** Standard Synthetic Control plot.
- **Clarity:** High. The divergence is obvious.
- **Storytelling:** The "visual proof" of the paradox.
- **Labeling:** Note explains the donors and p-value.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Inverse Probability Weighting: Addressing Linkage Selection Bias"
**Page:** 28
- **Formatting:** Standard.
- **Clarity:** Easy to compare Unweighted vs. IPW.
- **Storytelling:** Standard robustness.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 12: "Mean Age of Elevator Operators, 1900–1950"
**Page:** 35
- **Recommendation:** **REMOVE**. This is already plotted in Figure 2 Panel B. Redundant even for an appendix.

### Figure 13: "Placebo Tests: Permutation Inference for Synthetic Control"
**Page:** 36
- **Recommendation:** **KEEP AS-IS**. Standard SCM robustness.

### Figure 14: "Event Study: New York State Elevator Operators Relative to Other States"
**Page:** 37
- **Recommendation:** **PROMOTE TO MAIN TEXT**. Top journals (AER/QJE) almost always require an Event Study figure alongside Synthetic Control to assess pre-trends visually. This is a "power exhibit."

### Table 9: "New York State vs. Synthetic New York..."
**Page:** 38
- **Recommendation:** **KEEP AS-IS**. Good for replication transparency.

### Table 10: "Occupational Transitions by Age Group (1940 Age)"
**Page:** 38
- **Recommendation:** **KEEP AS-IS**. Adds necessary granular detail.

### Table 11: "Robustness Checks"
**Page:** 39
- **Recommendation:** **KEEP AS-IS**.

### Figure 15: "Elevator Operators by State, 1900–1950"
**Page:** 40
- **Recommendation:** **KEEP AS-IS**. Excellent use of small multiples for state-level transparency.

---

## Overall Assessment

- **Exhibit count:** 8 main tables, 10 main figures, 3 appendix tables, 4 appendix figures.
- **General quality:** Extremely high. The paper uses modern visualization techniques (dot-and-whisker, SCM plots) that would look at home in a top-5 journal. The tables are strictly formatted to academic standards.
- **Strongest exhibits:** Figure 8 (Race inequality), Figure 10 (AME Plot), Figure 11 (Synthetic Control).
- **Weakest exhibits:** Figure 1 (redundant with Table 1), Figure 6 (redundant with Table 2), Figure 12 (redundant with Figure 2).
- **Missing exhibits:** A **Summary Statistics** table (Table 0) comparing the linked 1940 sample to the full 1940 census population is standard to demonstrate linkage quality before diving into the results.

### Top 3 Improvements:
1.  **Reduce Redundancy:** Remove Figure 1 and Figure 6. They visualize the exact same data as the preceding tables. Use that space to breathe or add the missing Summary Stats table.
2.  **Promote the Event Study:** Move Figure 14 to the main text next to the Synthetic Control. It is essential for readers to evaluate the pre-trend convergence you discuss on page 26.
3.  **Refine Age Visualization:** Figure 5's stacked area is "mushy." Replace it with a simpler line graph of shares (e.g., share of workers 60+) or a density plot to make the "aging in place" argument more visceral.