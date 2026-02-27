# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T22:24:42.207026
**Route:** Direct Google API + PDF
**Tokens:** 20477 in / 2359 out
**Response SHA256:** 652f7b0dbe7503d6

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Variable Availability by Census Year"
**Page:** 7
- **Formatting:** Clean and professional. Use of checkmarks and em-dashes is clear.
- **Clarity:** Excellent. High-level overview of a complex data harmonization task.
- **Storytelling:** Essential for a data-focused paper. It establishes the "infrastructure" claim immediately.
- **Labeling:** Notes are comprehensive; defines HISTID and the logic for panel inclusion.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "MLP Linked Census Panel: Summary Statistics"
**Page:** 8
- **Formatting:** Standard journal format. Good use of horizontal rules (booktabs style).
- **Clarity:** Clear, though "Census Population" should be explicitly labeled as "Base Year Population" in the header to avoid confusion.
- **Storytelling:** Provides the "big picture" of the sample size. The inclusion of the Balanced Panel is vital.
- **Labeling:** Notes are helpful.
- **Recommendation:** **REVISE**
  - Change "Census Population" to "Base Year Population" in the column header for clarity.

### Figure 1: "Record Linkage Rates by Decade Pair"
**Page:** 9
- **Formatting:** Professional bar chart. Good use of data labels on bars.
- **Clarity:** High. The 10-second test is passed; the reader sees the upward trend and the $N$ counts.
- **Storytelling:** Redundant with Table 2. Usually, in top journals, you either show the table or the figure for summary stats, not both in the main text unless the figure adds a specific distributional insight.
- **Labeling:** Axes are well-labeled.
- **Recommendation:** **REMOVE** (Move to Appendix)
  - The information is already in Table 2. Table 2 is more precise for researchers needing the $N$ counts for their own power calculations.

### Figure 2: "Linkage Rates by Race, Sex, and Age Group"
**Page:** 10
- **Formatting:** Multi-panel (A, B, C) is standard and well-executed.
- **Clarity:** Good. Colors are distinguishable. Panel C (Age Group) is a bit crowded.
- **Storytelling:** Crucial. This documents the selection bias that motivates the IPW section.
- **Labeling:** Sub-titles and legends are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Selection into Linkage: Linked vs. Unlinked Populations"
**Page:** 13
- **Formatting:** The "Native-born (%)" row shows 0.0 for several decades. This looks like a data processing error or a rounding issue in the LaTeX/Code output.
- **Clarity:** The table is very long.
- **Storytelling:** This is the most important "Balance Table" in the paper. 
- **Labeling:** Logical.
- **Recommendation:** **REVISE**
  - Check the "Native-born (%)" values; it is highly unlikely to be 0.0 across all unlinked populations.
  - Consider consolidating this into a single "Difference" table (Linked mean minus Unlinked mean) to save space, or use a "Panel" structure by variable rather than by decade.

### Figure 3: "Selection into Linkage: Linked vs. Unlinked Populations"
**Page:** 14
- **Formatting:** This is a "Coefficient Plot" style visualization of Table 3.
- **Clarity:** Very clean. It shows the stability of selection across decades.
- **Storytelling:** Excellent. It makes the "direction and consistency" argument much faster than Table 3.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Consider promoting this and moving the bulky Table 3 to the appendix).

### Table 4: "Linkage Rate Comparison: MLP v2.0 vs. ABE Crosswalks"
**Page:** 16
- **Formatting:** Standard. 
- **Clarity:** Clear, but the "NA" for 1920-1940 MLP links needs a footnote explaining why (presumably because it's a 20-year jump not yet processed in the same way).
- **Storytelling:** Establishes the "2.7 to 2.9 times" coverage advantage over the literature standard.
- **Labeling:** Definition of MLP and ABE in notes is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Linkage Rate Comparison: MLP v2.0 vs. ABE Crosswalks"
**Page:** 16
- **Formatting:** Simple bar chart.
- **Clarity:** High.
- **Storytelling:** Completely redundant with Table 4, which is right above it.
- **Labeling:** Clear.
- **Recommendation:** **REMOVE**
  - The ratio in Table 4 is more informative than the visual height of these bars.

### Figure 5: "Within-Person SEI Changes Across Decades"
**Page:** 17
- **Formatting:** Density plot with shading. Professional.
- **Clarity:** The overlap of 1920-30 and 1930-40 is clear.
- **Storytelling:** This is the core "Atlas" finding. It shows the Great Depression shift.
- **Labeling:** X-axis units (SEI points) are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Occupation Transition Matrix, 1920→1930"
**Page:** 18
- **Formatting:** Heatmap with text labels. 
- **Clarity:** Excellent. The diagonal dominance is immediately visible.
- **Storytelling:** High value. It moves from the "How" of the data to the "What" of the history.
- **Labeling:** Rows and columns clearly labeled with occupation groups.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Occupation Group Switching Rates Across Decades"
**Page:** 19
- **Formatting:** Line plot with points.
- **Clarity:** High.
- **Storytelling:** Shows the 1940s structural transformation.
- **Labeling:** Data labels on points help.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Mobility Patterns by Race"
**Page:** 20
- **Formatting:** Clean horizontal layout.
- **Clarity:** Good.
- **Storytelling:** Vital for documenting the Great Migration dynamics.
- **Labeling:** Units (%, pp) clearly indicated in sub-headers.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Interstate Migration Rates Across Census Decades"
**Page:** 21
- **Formatting:** Line plot. 
- **Clarity:** High.
- **Storytelling:** Shows the "Dust Bowl" dip and the subsequent rise.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Consider merging this with Figure 7 or Figure 10 to reduce the total number of "Trend Line" figures.

### Table 6: "Top Interstate Migration Corridors, 1900–1950"
**Page:** 22
- **Formatting:** Simple list.
- **Clarity:** High.
- **Storytelling:** Provides "flavor" and validation.
- **Labeling:** Note explains the aggregation.
- **Recommendation:** **MOVE TO APPENDIX**
  - While interesting, it is less "central" than the transition matrices or the racial mobility tables.

### Figure 9: "Farm-to-Nonfarm Transition Rates by Race"
**Page:** 23
- **Formatting:** Grouped bar chart.
- **Clarity:** Clear.
- **Storytelling:** Visualizes the "Farm Exit" column from Table 5.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - The Y-axis title says "Farm Decline (pp)". Be careful—the bars for 1900-1920 for Black Americans are negative (meaning farm residence *increased*). The text explains this, but the label "Decline" makes a negative bar confusing. Change label to "Net Change in Farm Residence (pp)".

### Figure 10: "Demographic Transition Rates Across Census Decades"
**Page:** 24
- **Formatting:** Multi-line plot.
- **Clarity:** Good.
- **Storytelling:** Summary figure for the "Atlas" section. 
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Individual-Level Transitions Across Census Decades"
**Page:** 24
- **Formatting:** Summary table.
- **Clarity:** High.
- **Storytelling:** This is the "Master Table" for the descriptive section.
- **Labeling:** Defines variables well.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 10 main figures, 0 appendix tables (though many are referenced in text), 0 appendix figures.
- **General quality:** Extremely high. The exhibits look "top-five" ready. They use a consistent aesthetic, clear fonts (likely CMU Serif/LaTeX), and appropriate white space.
- **Strongest exhibits:** Figure 3 (Selection Plot), Figure 6 (Transition Matrix), and Figure 10 (Demographic Trends).
- **Weakest exhibits:** Figure 1 and Figure 4 (both are redundant with nearby tables).
- **Missing exhibits:** 
    1. **Appendix Tables:** The text mentions "Detailed Link Rate Tables" (Section B) and "Additional Transition Matrices" (Section E), but they are not in the provided PDF. They need to be physically included in the Supplement.
    2. **Map:** A paper about an "Atlas" and "Interstate Migration" would benefit immensely from a US map (choropleth) showing link rates by state.
- **Top 3 improvements:**
  1. **Consolidate Redundancy:** Remove Figures 1 and 4. The tables provide the necessary precision, and the space is better used for more "story-heavy" visuals.
  2. **Fix Table 3 Data:** Investigate the "Native-born (%)" 0.0 values. This is a red flag for reviewers.
  3. **Visual Geographic Component:** Add a figure showing a map of the US with link rates or migration outflows to justify the "Atlas" title.