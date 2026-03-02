# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-01T09:17:55.957740
**Route:** Direct Google API + PDF
**Tokens:** 21517 in / 3516 out
**Response SHA256:** aa48a1ba3eb42c8b

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Newspaper Coverage of Elevator Operators: Thematic Composition and Corpus-Normalized Volume"
**Page:** 6
- **Formatting:** High quality. Use of two panels is effective. The horizontal gridlines are subtle and helpful.
- **Clarity:** Panel A (stacked area) is clear for showing shifts in shares. Panel B clearly shows the spike in normalized volume.
- **Storytelling:** This is the foundational evidence for the "discourse" argument. It successfully shows that while absolute mentions spiked during the 1945 strike, the composition had already begun shifting toward automation.
- **Labeling:** Source notes are thorough. The "1945 strike" annotation in Panel A is helpful. Units (Rate per 10,000 articles) are clearly defined.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "The Discursive Shift: Thematic Category Trends in Elevator Coverage"
**Page:** 8
- **Formatting:** Clean line plot. The dashed line for the 1945 strike provides a clear temporal anchor.
- **Clarity:** The omission of the "Construction" category (noted in the caption) reduces clutter and focuses the reader on the relevant categories.
- **Storytelling:** This figure is somewhat redundant with Figure 1. While Fig 1 shows *shares* and *total* volume, Fig 2 shows *absolute counts* of categories. Given the uneven digitization of the corpus (mentioned on page 6), absolute counts can be misleading. 
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**. Figure 1, Panel B already captures the volume story using a normalized metric, which is more methodologically sound for this corpus. Figure 2 adds little beyond raw counts that may just reflect corpus growth.

### Figure 3: "Geographic Variation in Elevator Newspaper Coverage"
**Page:** 9
- **Formatting:** Standard line plot with multiple series.
- **Clarity:** Hard to parse. With six overlapping lines, the "spaghetti" effect makes it difficult to follow cities other than Washington and New York.
- **Storytelling:** Supports the claim that DC and NYC dominate the discourse data.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**. Convert this to a small multiples plot (a grid of 6 small charts, one for each city). This would allow the reader to see the individual trajectories (like the early peak in Minneapolis) that are currently obscured by the Washington/NYC lines.

### Table 1: "Summary Statistics: Linked Panel, 1940 Characteristics"
**Page:** 12
- **Formatting:** Excellent. Professional use of horizontal rules (booktabs style). Numbers are clearly aligned.
- **Clarity:** The separation of 1940 characteristics and 1950 outcomes is logical. 
- **Storytelling:** Crucial for establishing the "refuge occupation" narrative and showing that operators were younger and more concentrated in NYC than the comparison group.
- **Labeling:** Note explains the comparison group and the linked sample clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Rise, Plateau, and Extinction: Elevator Operators per 10,000 Employed, 1900–1980"
**Page:** 13
- **Formatting:** Clean, publication-ready line plot.
- **Clarity:** The "Linked panel data window" shading is a professional touch that connects the descriptive data to the regression sample.
- **Storytelling:** This is the "money plot" of the paper. It perfectly illustrates the 40-year lag between technology and extinction.
- **Labeling:** All axes and data labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Elevator Operators vs. Comparison Occupations per 10,000 Employed, 1900–1980"
**Page:** 14
- **Formatting:** High contrast, easy to read.
- **Clarity:** Very high. The contrast between the disappearing operators and the booming janitors is immediate.
- **Storytelling:** Essential "placebo" check. It proves that the decline wasn't a general building-service trend, but specific to the automated occupation.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Rise, Plateau, and Extinction: Elevator Operators in the United States, 1900–1980"
**Page:** 15
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Redundant. Every data point in this table is already visualized more effectively in Figure 4. Top journals generally discourage presenting the exact same data in both a table and a figure unless the specific point-estimates are crucial for a secondary calculation.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**. Let Figure 4 carry the weight in the main text.

### Figure 6: "Demographic Composition of Elevator Operators, 1900–1950"
**Page:** 16
- **Formatting:** Consistent with Figure 1. 
- **Clarity:** Panel B (Age) is a bit "busy" with six categories in a stacked area. 
- **Storytelling:** Key to the "refuge" and "feminization" arguments.
- **Labeling:** Good.
- **Recommendation:** **REVISE**. In Panel B, collapse the age groups into three categories (e.g., Under 30, 30–50, 50+) to make the "aging out" and "entry of middle-aged women" stories more visually obvious.

### Figure 7: "Elevator Operators per 10,000 Employed by State, 1920–1950"
**Page:** 17
- **Formatting:** Standard choropleth.
- **Clarity:** Reasonable, but the "NA" for 1920 in the West is a bit distracting.
- **Storytelling:** Visualizes the urban/coastal concentration.
- **Labeling:** Legend scale is clear.
- **Recommendation:** **MOVE TO APPENDIX**. Table 3 and Figure 8 provide much higher-resolution geographic information (Metro-level) which is more relevant for an urban occupation than state-level data.

### Table 3: "Elevator Operators in Major Metropolitan Areas, 1940 vs. 1950"
**Page:** 18
- **Formatting:** Professional.
- **Clarity:** Good use of columns to show both counts (N) and rates (per 10k).
- **Storytelling:** Highlights the extreme dominance of NYC and the variance in decline rates across cities.
- **Labeling:** Note defines "Change (%)" clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Elevator Operator Rates in Major Metropolitan Areas, 1900–1950"
**Page:** 18
- **Formatting:** Good use of color to highlight Manhattan.
- **Clarity:** Similar to Figure 3, it is a bit crowded. However, because Manhattan and NYC are so much higher than the rest, the "Manhattan is an outlier" message survives the clutter.
- **Storytelling:** Visualizes the "Institutional Thickness" of NYC.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**. The legend has "Manhattan" and "New York City" as separate lines, which might confuse readers (Manhattan is a subset of NYC). The text explains that NYC is the aggregate of 5 boroughs. It might be cleaner to show only the "New York City" aggregate and remove the Manhattan line to reduce clutter.

### Table 4: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Vital for the "where did they go?" question.
- **Labeling:** Good.
- **Recommendation:** **REMOVE**. This table is entirely redundant with Figure 9 on the very next page, which presents the exact same data points in a more intuitive bar chart.

### Figure 9: "Occupational Transitions of 1940 Elevator Operators by 1950"
**Page:** 20
- **Formatting:** Standard bar chart.
- **Clarity:** Excellent. Sorting by frequency (descending) makes it very easy to read.
- **Storytelling:** Central to the "Individual Displacement" section.
- **Labeling:** Percentages on top of bars are helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Occupational Destinations by Race: 1940 Elevator Operators in 1950"
**Page:** 21
- **Formatting:** Grouped bar chart.
- **Clarity:** Very high. The contrast in the "Craftsman" and "Farm worker" bars by race is immediately apparent.
- **Storytelling:** This is one of the "starkest findings" (as the text says). It visually proves racial channeling.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Individual Displacement: Elevator Operators vs. Other Building Service Workers"
**Page:** 22
- **Formatting:** Standard regression table.
- **Clarity:** Clean. No excessive gridlines.
- **Storytelling:** Provides the formal econometric test for the displacement effects.
- **Labeling:** Significance stars and clustering are properly noted.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Selection into Persistence: Who Remains an Elevator Operator?"
**Page:** 21
- **Formatting:** Standard logit output.
- **Clarity:** High.
- **Storytelling:** Complements the regression analysis by showing *who* was able to hang on to the job.
- **Labeling:** Defines AME and Coefficient SE clearly in the notes.
- **Recommendation:** **KEEP AS-IS** (but see Figure 11).

### Figure 11: "Selection into Persistence: Average Marginal Effects from Logit Model"
**Page:** 23
- **Formatting:** Coefficient plot (whisker plot).
- **Clarity:** Much higher than Table 6 for a general reader. The use of color (n.s. vs p<0.05) is very effective.
- **Storytelling:** It visualizes the "NYC resident" and "Female" persistence effect much better than the table.
- **Labeling:** Good.
- **Recommendation:** **REVISE**. This should be the primary exhibit. Consider merging Table 6 and Figure 11 by keeping the figure and moving the table to the Appendix for readers who want the exact point estimates.

### Figure 12: "Prior Occupations of 1950 Elevator Operators Who Were Not Operators in 1940"
**Page:** 24
- **Formatting:** Consistent with Figure 9.
- **Clarity:** High.
- **Storytelling:** Essential for the "entry point for the disadvantaged" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "NYC vs. Non-NYC: Displacement Outcomes for 1940 Elevator Operators"
**Page:** 25
- **Formatting:** Grouped bar chart.
- **Clarity:** High.
- **Storytelling:** Visual proof of the "Institutional Thickness" narrative.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "NYC vs. Non-NYC: Institutional Thickness and Displacement"
**Page:** 26
- **Formatting:** Regression table with interactions.
- **Clarity:** Clear.
- **Storytelling:** Formal test of the NYC effect and the Race x NYC interaction.
- **Labeling:** Correct.
- **Recommendation:** **KEEP AS-IS**

### Figure 14: "Elevator Operators Across New York City Boroughs, 1900–1950"
**Page:** 26
- **Formatting:** Line plot.
- **Clarity:** Clear. 
- **Storytelling:** Shows Manhattan's dominance within NYC.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Heterogeneous Displacement: By Race, Sex, and City"
**Page:** 27
- **Formatting:** Regression table.
- **Clarity:** High.
- **Storytelling:** Consolidates the various heterogeneity stories into a single table. 
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Inverse Probability Weighting: Addressing Linkage Selection Bias"
**Page:** 28
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Standard robustness check.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**. This is a methodological check, not a core result.

## Appendix Exhibits

### Figure 15: "Synthetic Control Method: New York State vs. Synthetic Comparison"
**Page:** 38
- **Formatting:** Standard SCM plot.
- **Clarity:** High.
- **Storytelling:** Powerful evidence that New York was an outlier.
- **Labeling:** Good.
- **Recommendation:** **PROMOTE TO MAIN TEXT**. SCM is a high-signal method in modern economics. Placing this in Section 6.5 (The NYC Case) would significantly strengthen the causal claim that institutions delayed adoption.

### Figure 16: "Placebo Tests: New York vs. Donor States"
**Page:** 39
- **Formatting:** Standard SCM inference plot.
- **Clarity:** Clear.
- **Storytelling:** Proves the NYC divergence isn't just noise.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (in Appendix).

---

## Overall Assessment

- **Exhibit count:** 8 main tables, 14 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** Extremely high. The paper follows modern "Top 5" journal conventions (clean charts, minimal gridlines, thorough notes, coefficient plots). The use of color is purposeful and consistent.
- **Strongest exhibits:** Figure 4 (The Arc), Figure 5 (Comparison groups), Figure 10 (Racial channeling).
- **Weakest exhibits:** Figure 2 (Redundant), Figure 3 (Cluttered), Table 4 (Redundant).
- **Missing exhibits:** 
    - **A Regression Table for Entrants:** While Figure 12 shows where entrants came from, a regression (similar to Table 5 but for the 1950 sample) would formally show that "entrant" status is correlated with more disadvantaged backgrounds compared to other new building service workers.
    - **Newspaper Validation Table:** The text on page 37 describes a validation exercise. A small table showing the Confusion Matrix (Hand-coded vs. Keyword) would be more professional than the paragraph of text.

- **Top 3 improvements:**
  1. **Reduce Redundancy:** Remove Table 4 (redundant with Fig 9) and Table 2 (redundant with Fig 4). Move Table 9 to the Appendix. This will improve the "paper-to-results" ratio.
  2. **Strategic Promotion:** Move the Synthetic Control plot (Figure 15) to the main text. It is a much more "AER-style" exhibit than some of the simple descriptive maps.
  3. **Visual De-cluttering:** Use "Small Multiples" for the city-level newspaper trends (Figure 3) to make the data for smaller cities like Birmingham or Omaha actually readable.