# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-16T16:51:04.519178
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 2117 out
**Response SHA256:** cba7a4d73e7a102f

---

# Exhibit-by-Exhibit Review

This review evaluates the visual exhibits in "Compensating Danger: Workers’ Compensation Laws and Industrial Safety in the Progressive Era" against the standards of top-tier economics journals (AER, QJE, etc.).

---

## Main Text Exhibits

### Table 1: "Summary Statistics: IPUMS Census Analysis Sample"
**Page:** 10
- **Formatting:** Clean, standard "booktabs" style. However, the number of observations and mean age should be decimal-aligned with the percentages below for a more professional look.
- **Clarity:** Excellent. The 10-second takeaway (stability of dangerous occupation share between 1910–1920) is clear.
- **Storytelling:** Essential. It establishes the baseline and the demographic differences that necessitate the Doubly Robust (DR) approach.
- **Labeling:** Good notes. The explanation of "Occ. income score" is helpful. **Minor fix:** Define "SE" or ensure units are consistent (using % in labels is good).
- **Recommendation:** **REVISE**
  - Decimal-align all numerical columns. 
  - Add a row for "N (States)" to clearly distinguish the microdata size from the geographic variation.

### Table 2: "Pre-Treatment State Characteristics by Workers’ Compensation Adoption Cohort"
**Page:** 11
- **Formatting:** Professional. Good use of population-weighted percentages.
- **Clarity:** Very high. It immediately justifies the paper’s empirical strategy by showing the stark selection into early adoption (industrial/urban states adopted first).
- **Storytelling:** Strong. This "Table 2" is a classic requirement for papers dealing with non-random policy adoption.
- **Labeling:** Clear. The "Never" category definition in the notes is crucial and well-placed.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Staggered Adoption of Workers’ Compensation Laws, 1911–1925"
**Page:** 14
- **Formatting:** The dual-axis (Number of States vs. Cumulative States) is a bit "Excel-default" in style. Top journals prefer a cleaner step-function for cumulative counts.
- **Clarity:** The red line is readable, but the labels "9 states" inside the plot area are slightly cluttered. 
- **Storytelling:** Necessary to show identifying variation.
- **Labeling:** The y-axis for the line (right side) and bars (left side) are clear.
- **Recommendation:** **REVISE**
  - Change the red line to a "Step" line (staircase) to represent discrete policy adoptions more accurately.
  - Remove the "9 states (incl. WI, CA, IL)" text box; put this detail in the figure note to declutter the visual field.

### Figure 2: "Share of Workers in Dangerous Occupations, by Treatment Status"
**Page:** 15
- **Formatting:** Colors (purple/blue) are distinguishable, but the y-axis starting at 0% leaves a lot of empty space since the data clusters at 15-20%.
- **Clarity:** The bars are very wide.
- **Storytelling:** This is a "raw data" figure. While it shows the levels, it doesn't show the *effect*.
- **Recommendation:** **MOVE TO APPENDIX**
  - Raw trends are less informative than an event-study plot or a coefficient plot of the DR estimates. In the main text, a figure showing the *ATT over time* (if data permitted) or a *Coefficient Plot* for different industries would be more "AER-style."

### Table 3: "Main Results: Doubly Robust Estimates of Workers’ Compensation Effects"
**Page:** 16
- **Formatting:** Excellent. Standard errors in parentheses, t-statistics included.
- **Clarity:** Clear distinction between the binary outcome and the continuous income score.
- **Storytelling:** The "heart" of the paper. It shows the 5.3pp increase.
- **Labeling:** Thorough notes.
- **Recommendation:** **REVISE**
  - Add significance stars (*, **, ***) to the coefficients. While t-stats are provided, top journals expect stars for quick scanning.
  - Add "Mean of Dep. Var." at the bottom of the table to provide a sense of the effect size relative to the baseline.

### Table 4: "Heterogeneity: Effects by Industry Subsample"
**Page:** 17
- **Formatting:** Consistent with Table 3.
- **Clarity:** High. Grouping by Mining vs. Manufacturing is logical.
- **Storytelling:** Critical for the moral hazard vs. safety argument.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Propensity Score Overlap: Early vs. Late Workers’ Comp Adoption"
**Page:** 19
- **Formatting:** The density plot is clean.
- **Clarity:** It effectively shows that there is common support (overlap), which is the main technical requirement for DR estimation.
- **Storytelling:** Important for credibility, but largely a diagnostic.
- **Labeling:** The legend is clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - Common support is a diagnostic check. Unless there is a "failure" of overlap that the author needs to explain, this usually belongs in an Identification Appendix.

### Figure 4: "Workers’ Compensation Law Adoption by State"
**Page:** 20
- **Formatting:** Standard choropleth map.
- **Clarity:** The color ramp (yellow to dark blue) is clear. 
- **Storytelling:** Good for showing the "Deep South" holdouts.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Use a color-blind friendly palette (e.g., Viridis or Magma). 
  - Ensure the "1940+" category is distinct from the "Never" used in the text (which usually means "post-1920" in this specific sample).

### Table 5: "Robustness: Alternative Specifications and Samples"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** Logic of columns (Baseline -> Timing -> Placebo) is standard and effective.
- **Storytelling:** Reassures the reader that the result isn't a "Southern" effect or a "Mining" effect.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Sensitivity Analysis: Robustness to Unmeasured Confounders"
**Page:** 24
- **Formatting:** A standard "Cinelli-Hazlett" plot.
- **Clarity:** This plot is notoriously difficult for non-experts to read in 10 seconds.
- **Storytelling:** Crucial for modern identification standards.
- **Labeling:** The red dashed line is the most important part (where the effect becomes zero).
- **Recommendation:** **REVISE**
  - Increase the font size of the "1x foreign born," "2x literate," etc., labels. They are currently overlapping and nearly unreadable.
  - Add a one-sentence summary in the figure note: "The point estimate remains positive unless an unobserved confounder is twice as strong as the foreign-born share."

---

## Appendix Exhibits

*Note: The current PDF contains "Data Appendix" and "Identification Appendix" sections with text, but no numbered Appendix Tables/Figures (e.g., Table A.1). Based on the text:*

### [Missing Exhibit] "Table A.1: Full List of Adoption Dates by State"
- **Recommendation:** **ADD**
  - The text in Section A.3 should be converted into a reference table in the Appendix for transparency.

### [Missing Exhibit] "Table A.2: First-Stage Propensity Score Regressions"
- **Recommendation:** **ADD**
  - Top journals often want to see the coefficients of the model that predicts treatment, especially for DR and IPW methods.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 5 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** The tables are very strong and follow the "Fishback" style of economic history papers. The figures are informative but some are more "diagnostic" than "storytelling."
- **Strongest exhibits:** Table 2 (Selection) and Table 3 (Main Results).
- **Weakest exhibits:** Figure 5 (cluttered labels) and Figure 1 (dual-axis line could be cleaner).
- **Missing exhibits:** 
    1. **Appendix Table of Adoption Dates:** Critical for replication. 
    2. **Coefficient Plot:** A summary figure that shows the ATT across different industries (Mining, Mfg, Construction, White-Collar) in one visual would be a "power exhibit" for the main text.
- **Top 3 improvements:**
  1. **Consolidate and Relocate Diagnostics:** Move Figure 2 (Raw Trends) and Figure 3 (Overlap) to the Appendix. This tightens the main text and focuses the reader on the causal results.
  2. **Create a "Summary of Results" Figure:** Replace Figure 2 with a coefficient plot showing the ATT for the main outcome across different subsamples. This makes the "Heterogeneity" story (Table 4) visual and immediate.
  3. **Technical Polish of Figure 5:** The sensitivity plot is the most "modern" part of the paper but is visually messy. Cleaning up the text labels is a high-priority "AER-level" fix.