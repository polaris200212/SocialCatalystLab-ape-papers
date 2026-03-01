# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-01T02:16:38.118949
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 2396 out
**Response SHA256:** 07865c417005c8c5

---

This review evaluates the visual exhibits of "Automating Elevators" against the standards of top-tier economics journals (AER, QJE, JPE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Rise, Plateau, and Extinction: Elevator Operators per 10,000 Employed, 1900–1980"
**Page:** 10
- **Formatting:** Clean, professional. The use of data labels directly on points is helpful but slightly crowds the top.
- **Clarity:** Excellent. The "Linked panel data window" shading provides crucial context for the later analysis.
- **Storytelling:** This is the "hook" of the paper. It successfully demonstrates the 40-year lag between tech availability and occupational decline.
- **Labeling:** Clear. The y-axis unit is specific.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Elevator Operators vs. Comparison Occupations per 10,000 Employed, 1900–1980"
**Page:** 11
- **Formatting:** Standard line plot. Color palette is distinguishable.
- **Clarity:** The "Janitors" line dominates the scale, making the variation in "Porters" and "Guards" harder to see.
- **Storytelling:** Essential for showing that the decline was occupation-specific, not a general decline in building services.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Consider a secondary y-axis or a log scale to make the porters/guards trends more visible relative to the high-volume janitor category.

### Table 1: "Rise, Plateau, and Extinction: Elevator Operators in the United States, 1900–1980"
**Page:** 12
- **Formatting:** Good use of horizontal rules. Number alignment is correct.
- **Clarity:** Very high.
- **Storytelling:** Redundant with Figure 1. In top journals, you rarely show the exact same data in both a table and a figure in the main text.
- **Labeling:** Note is comprehensive.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 3: "Demographic Composition of Elevator Operators, 1900–1950"
**Page:** 13
- **Formatting:** Professional area charts.
- **Clarity:** Panel B (Age) is a bit "busy" with six shades of blue. 
- **Storytelling:** Supports the "refuge occupation" narrative.
- **Labeling:** Y-axis is properly labeled as Share (%).
- **Recommendation:** **REVISE**
  - In Panel B, group age into fewer categories (e.g., <25, 25-50, 50+) to make the "aging" story more immediately visible.

### Figure 4: "Elevator Operators per 10,000 Employed by State, 1920–1950"
**Page:** 14
- **Formatting:** Small multiples are a good choice for temporal comparison.
- **Clarity:** The "NA" in 1920 (likely for Western states) is a bit distracting.
- **Storytelling:** Shows the geographic concentration, justifying the focus on NYC/DC.
- **Labeling:** Legend scale is appropriate.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Elevator Operators in Major Metropolitan Areas, 1940 vs. 1950"
**Page:** 15
- **Formatting:** Standard. Decimal points are aligned.
- **Clarity:** Logical sorting by 1940 count.
- **Storytelling:** Vital for showing the heterogeneity of the "plateau" phase.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Elevator Operator Rates in Major Metropolitan Areas, 1900–1950"
**Page:** 15
- **Formatting:** Good line weights.
- **Clarity:** Cluttered. Many lines overlap at the bottom (Detroit, LA, Chicago).
- **Storytelling:** Manhattan is the clear outlier. 
- **Labeling:** Legend takes up a lot of white space.
- **Recommendation:** **REVISE**
  - Use a "Manhattan vs. Others (Average)" line to simplify, or highlight Manhattan in bold color and grey out the other metros to reduce visual noise.

### Table 3: "Occupational Transitions: 1940 Elevator Operators in 1950"
**Page:** 16
- **Formatting:** Clean.
- **Clarity:** Excellent.
- **Storytelling:** The core of the transition analysis. 
- **Labeling:** Note identifies the source clearly.
- **Recommendation:** **KEEP AS-IS** (Or merge with Figure 6).

### Figure 6: "Occupational Transitions of 1940 Elevator Operators by 1950"
**Page:** 17
- **Formatting:** Standard bar chart. 
- **Clarity:** High.
- **Storytelling:** Redundant with Table 3.
- **Labeling:** Data labels (%) on bars are helpful.
- **Recommendation:** **REMOVE** (Table 3 is more precise for an academic audience).

### Figure 7: "Occupational Destinations by Race: 1940 Elevator Operators in 1950"
**Page:** 18
- **Formatting:** Grouped bar chart.
- **Clarity:** High.
- **Storytelling:** This is the "Starkest finding" (Racial Channeling). 
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS** (This is a "Star" exhibit).

### Table 4: "Selection into Persistence: Who Remains an Elevator Operator?"
**Page:** 19
- **Formatting:** Odd layout—it includes two separate regression-style outputs on one page without clear Panel A/B distinctions.
- **Clarity:** The top table lacks a title and notes. The bottom table (Table 4) is better but uses a non-standard regression format (includes p-values in a column instead of stars/SEs in parentheses).
- **Storytelling:** Crucial for the "Institutional Thickness" (NYC) and "Refuge" (Female/Older) arguments.
- **Labeling:** Needs standard regression stars (*, **, ***).
- **Recommendation:** **REVISE**
  - Consolidate the two tables on Page 19 into one "Table 4: Determinants of Occupational Persistence." Use standard LaTeX regression formatting (Coefficients with stars, SEs in parentheses below).

### Figure 8: "Selection into Persistence: Average Marginal Effects from Logit Model"
**Page:** 20
- **Formatting:** Coefficient plot (whisker plot). Very professional.
- **Clarity:** Very high.
- **Storytelling:** Excellent summary of the regression in Table 4.
- **Labeling:** Legend for significance is helpful.
- **Recommendation:** **KEEP AS-IS** (This is often preferred over tables in modern QJE/AER papers).

### Figure 9: "Prior Occupations of 1950 Elevator Operators Who Were Not Operators in 1940"
**Page:** 21
- **Formatting:** Clean bar chart.
- **Clarity:** High.
- **Storytelling:** Shows the "entry" side of the churning.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX** (The exit story is more central to "automation displacement" than the entry story).

### Figure 10: "NYC vs. Non-NYC: Displacement Outcomes for 1940 Elevator Operators"
**Page:** 22
- **Formatting:** Side-by-side bar chart.
- **Clarity:** High.
- **Storytelling:** Directly tests the "Institutional Thickness" hypothesis.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 11: "Elevator Operators Across New York City Boroughs, 1900–1950"
**Page:** 23
- **Formatting:** Line plot.
- **Clarity:** Manhattan is so dominant it flattens the others.
- **Storytelling:** Shows that the NYC effect is really a Manhattan effect.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

## Appendix Exhibits

### Figure 12: "Synthetic Control Method: Actual vs. Synthetic Elevator Operator Trajectory"
**Page:** 32
- **Formatting:** Professional SCM plot.
- **Clarity:** High.
- **Storytelling:** Provides a formal counterfactual.
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Placebo Tests: Gaps for All Donor Occupations"
**Page:** 33
- **Formatting:** Standard SCM inference plot.
- **Clarity:** A bit messy due to the nature of placebo tests, but standard.
- **Recommendation:** **KEEP AS-IS**

---

# Overall Assessment

- **Exhibit count:** 4 Main Tables, 11 Main Figures, 0 Appendix Tables, 2 Appendix Figures.
- **General quality:** High. The figures are modern and clean (likely R/ggplot2). The tables need to transition from "summary output" style to "journal-ready" style.
- **Strongest exhibits:** Figure 1 (The Arc), Figure 7 (Racial Channeling), Figure 8 (Coefficient Plot).
- **Weakest exhibits:** Table 4 (Formatting), Figure 5 (Overlapping lines).
- **Missing exhibits:** 
    1. **Summary Statistics Table:** Essential for any top-tier paper. Need a table showing means/SDs for the 1940 and 1950 samples (Age, Race, Sex, Region).
    2. **Balance Table for Linked Panel:** A table comparing linked vs. unlinked individuals to address selection bias (currently mentioned in text but not shown).
- **Top 3 improvements:**
  1. **Consolidate and Reformat Regressions:** Merge the disparate regression outputs on pages 19, 22, and 24 into 2-3 high-quality "Table 4" and "Table 5" exhibits using standard AER formatting (SEs in parentheses, stars for significance, etc.).
  2. **Reduce Redundancy:** Move Table 1 and Figure 9 to the Appendix. They repeat information or provide "nice to know" rather than "need to know" data.
  3. **Standardize Tables:** Remove columns like "p-value" and "AME" into more condensed formats. Ensure all tables have a consistent "Note" style.