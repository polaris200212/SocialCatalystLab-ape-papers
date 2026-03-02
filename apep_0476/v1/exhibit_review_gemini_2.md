# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T23:18:36.873296
**Route:** Direct Google API + PDF
**Tokens:** 19957 in / 2173 out
**Response SHA256:** 0a2182f8decbf724

---

This review evaluates the exhibits in "Linking Americans Across the Half-Century" according to the standards of top-tier economics journals.

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Variable Availability by Census Year"
**Page:** 7
- **Formatting:** Clean, uses standard booktabs-style horizontal lines. The use of checkmarks and em-dashes is intuitive.
- **Clarity:** Excellent. High contrast between available and unavailable data.
- **Storytelling:** Essential for a data-focused paper. It justifies why certain decades are used for specific analyses (e.g., SEI or Education).
- **Labeling:** Good. Notes clearly define symbols.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "MLP Linked Census Panel: Summary Statistics"
**Page:** 8
- **Formatting:** Professional. Large numbers are properly comma-separated.
- **Clarity:** High. Logic is easy to follow: Year $\to$ N $\to$ Pop $\to$ Rate.
- **Storytelling:** Provides the "big picture" of the dataset's scale.
- **Labeling:** "Link Rate" is well-defined in the notes as being relative to the base year.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Linkage Rates by Race, Sex, and Age Group"
**Page:** 10
- **Formatting:** Multi-panel (A, B, C) layout is appropriate for AER/QJE. Font sizes are readable.
- **Clarity:** Panel C (Age Group) is slightly cluttered with seven bars per decade. The colors are distinguishable, but the x-axis labels are slanted, which can be avoided.
- **Storytelling:** Strong. It visually confirms the text's points about Black and female under-representation.
- **Labeling:** Y-axis is clearly labeled with units (%).
- **Recommendation:** **REVISE**
  - Group Panel C into fewer buckets (e.g., 0-19, 20-39, 40-59, 60+) to reduce the "rainbow" effect and make the "Inverted-U" shape easier to see.

### Table 3: "Selection into Linkage: Linked vs. Unlinked Populations"
**Page:** 13
- **Formatting:** Decimals are aligned. The stacking of decade pairs vertically is standard but makes for a very long table.
- **Clarity:** The "N" rows are at the bottom of each sub-section, which is correct. However, comparing 1900 to 1940 requires scanning across a lot of vertical space.
- **Storytelling:** This is the "Balance Table." It is crucial.
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Add a column for "Difference" or "t-stat" between Linked and Unlinked. Currently, the reader has to do the mental math to see how large the selection bias is.

### Figure 2: "Selection into Linkage: Linked vs. Unlinked Populations"
**Page:** 14
- **Formatting:** Coefficient plot style. Clean and modern.
- **Clarity:** Excellent. The zero line (dashed) allows for instant parsing of the direction of bias.
- **Storytelling:** It complements Table 3 by showing that selection is *consistent* across 50 years.
- **Labeling:** Axis labels are clear. Legend is well-placed.
- **Recommendation:** **KEEP AS-IS** (This is the "10-second parse" winner of the paper).

### Table 4: "Linkage Rate Comparison: MLP v2.0 vs. ABE Crosswalks"
**Page:** 16
- **Formatting:** Standard. 
- **Clarity:** Simple and effective. 
- **Storytelling:** Crucial for the "Recall vs. Precision" argument. 
- **Labeling:** Note explains the acronyms (MLP, ABE).
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Within-Person SEI Changes Across Decades"
**Page:** 17
- **Formatting:** Density plot. The "0" peak is very sharp.
- **Clarity:** The overlapping densities (1920s vs 1930s) are distinct. 
- **Storytelling:** Effectively shows the "leftward shift" (downward mobility) during the Great Depression.
- **Labeling:** Units for $\Delta$ SEI are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Occupation Transition Matrix, 1920$\to$1930"
**Page:** 18
- **Formatting:** Heatmap with text overlays. Very professional.
- **Clarity:** Colors (blue scale) correspond well to the percentages.
- **Storytelling:** Highlights "Diagonal Dominance." 
- **Labeling:** The "Row %" note is essential and present.
- **Recommendation:** **KEEP AS-IS** (Note: Ensure the 1930-1940 version is in the appendix for comparison).

### Figure 5: "Occupation Group Switching Rates Across Decades"
**Page:** 19
- **Formatting:** Line graph with points. 
- **Clarity:** High. 
- **Storytelling:** The spike in 1940-1950 is the "hero" of this story.
- **Labeling:** Data labels (45.5%, etc.) on the points are helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Mobility Patterns by Race"
**Page:** 20
- **Formatting:** Good use of sub-headers for decades.
- **Clarity:** "Farm Exit (pp)" is a derived column that adds great value.
- **Storytelling:** Shows the Great Migration via the Black "Migration (%)" and "Farm Exit" columns.
- **Labeling:** Note defines Y1/Y2.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Interstate Migration Rates Across Census Decades"
**Page:** 21
- **Formatting:** Consistent with Figure 5.
- **Clarity:** The "V" shape is striking.
- **Storytelling:** Shows the "immobility" of the Depression decade.
- **Labeling:** Units present.
- **Recommendation:** **MOVE TO APPENDIX** or **CONSOLIDATE**. This is almost identical in structure to Figure 8. See below.

### Figure 7: "Farm-to-Nonfarm Transition Rates by Race"
**Page:** 22
- **Formatting:** Bar chart.
- **Clarity:** High.
- **Storytelling:** Contrast between the 1900-1920 (where Black farm residence increased) and 1940-1950 is the key finding.
- **Labeling:** Y-axis clearly marked as "pp".
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Demographic Transition Rates Across Census Decades"
**Page:** 23
- **Formatting:** Multi-line graph.
- **Clarity:** Can be a bit busy with three crossing lines.
- **Storytelling:** Summary of the paper's descriptive section.
- **Recommendation:** **REVISE**
  - This figure renders Figure 6 redundant. Consolidate them. Use this figure but ensure the line weights are thicker to distinguish the series more easily.

### Table 6: "Individual-Level Transitions Across Census Decades"
**Page:** 23
- **Formatting:** Broad overview table.
- **Clarity:** Too many different concepts (N, Migration, Switch, Farm, Married).
- **Storytelling:** This is more of a "Data Summary" than a "Finding" table.
- **Recommendation:** **MOVE TO APPENDIX**. Table 5 and the figures already cover these points more effectively for the narrative.

## Appendix Exhibits

### Table 7: "Top Interstate Migration Corridors, 1900–1950"
**Page:** 35
- **Formatting:** Clean list.
- **Clarity:** Easy to read.
- **Storytelling:** Interesting detail for historians.
- **Recommendation:** **KEEP AS-IS** (Appropriately placed in Appendix).

---

# Overall Assessment

- **Exhibit count:** 6 Main Tables, 8 Main Figures, 1 Appendix Table.
- **General quality:** Extremely high. The exhibits use a consistent aesthetic (likely `ggplot2` in R) that mimics the AEJ/AER style.
- **Strongest exhibits:** Figure 2 (Selection Plot) and Figure 4 (Transition Heatmap).
- **Weakest exhibits:** Figure 8 (over-crowded lines) and Table 6 (redundant summary statistics).

- **Missing exhibits:**
  1. **A Map:** Given this is a "Descriptive Atlas," a choropleth map of link rates by state (mentioned in text 3.3) is missing. This is a "must-have" for a paper about geography and census data.
  2. **Validation Figure:** A scatter plot comparing MLP link rates vs. ABE link rates at the state level would strengthen the validation section.

- **Top 3 improvements:**
  1. **Add a Map:** Create a 48-state heatmap of link rates to visualize the "Geographic Variation" discussed in Section 3.3.
  2. **Consolidate Trends:** Remove Figure 6 and Table 6 from the main text. Use Figure 8 as the primary summary of trends to reduce "exhibit fatigue."
  3. **Enhance Table 3:** Add "Difference" columns and significance stars to the Balance Table to make the magnitude of selection bias explicit for the reader.