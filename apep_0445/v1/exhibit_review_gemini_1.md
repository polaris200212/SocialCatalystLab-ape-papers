# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T15:31:24.879609
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 2156 out
**Response SHA256:** 8e39ddee803e0b65

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Professional. Uses standard three-line LaTeX table style. Logical grouping into panels (Demographics, Employment, OZ Status).
- **Clarity:** High. Clearly distinguishes between tracts above and below the running variable threshold.
- **Storytelling:** Essential. Establishes the sample size and the fact that "Above 20%" tracts have higher unemployment and lower home values, which justifies why the null result isn't due to selecting "already wealthy" areas.
- **Labeling:** Clear. Units (%, $) are included. Note explains the 7.9% bandwidth.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Clean, but the title and McCrary test stats are in the plot area (standard for some packages, but top journals prefer these in the note or a cleaner header).
- **Clarity:** Good. The color change at the 20% mark helps visualization.
- **Storytelling:** This is a "validity check" exhibit. It shows significant heaping at the threshold ($p < 0.001$), which usually invalidates an RDD. The author addresses this in the text via a donut RDD, but the figure itself highlights a major empirical hurdle.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **REVISE**
  - Move the "McCrary test" statistics from the subtitle/plot area into the Figure Note to match QJE/AER style.
  - Add a vertical line or annotation explaining the "heaping" if it corresponds to specific policy rounding (as mentioned in the text).

### Figure 2: "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
**Page:** 15
- **Formatting:** Professional. Point sizes proportional to N is a nice touch.
- **Clarity:** Very high. One can see the "fuzzy" jump clearly.
- **Storytelling:** Critical for a fuzzy RDD. It shows that while the probability jumps, it's a weak first stage near the cutoff (rising much later).
- **Labeling:** Clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** Standard regression table.
- **Clarity:** Good.
- **Storytelling:** This table is actually slightly redundant with Figure 8 in the appendix. More importantly, it shows significant imbalances (Bachelor's, White, Unemployment all $p=0.000$).
- **Labeling:** Defined significance levels are missing from the notes (though p-values are present).
- **Recommendation:** **REVISE**
  - Add a note explicitly stating that standard errors are in parentheses. 
  - Consider consolidating this with Table 1 (adding a "Difference" column with stars) to save space, as is common in AER papers.

### Table 3: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Clean panel structure. 
- **Clarity:** The jump from Panel B to Panel C is jarring because the coefficients in Panel C (IV) are massive (20,000+) compared to the reduced form. This is due to the weak first stage.
- **Storytelling:** This is the "Money Table." It proves the null.
- **Labeling:** Units are missing. Are these "Number of Jobs"? "Percentage Change"? The text says levels and changes, but the table should specify (e.g., "Estimate (Jobs)").
- **Recommendation:** **REVISE**
  - Specify units in the column headers or panel titles.
  - Add "Mean of Dep. Var" at the bottom of each panel to provide scale for the coefficients.

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 17
- **Formatting:** Good use of binned means and confidence intervals.
- **Clarity:** The y-axis range (-200 to 200) is appropriate for the data density.
- **Storytelling:** Visual proof of the null for the primary outcome.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Reduced-Form RDD: Change in Information-Sector Employment at the Threshold"
**Page:** 18
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High.
- **Storytelling:** This is the "Industry Specific" null.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Bandwidth Sensitivity: Δ Total Employment"
**Page:** 18
- **Formatting:** Standard. 
- **Clarity:** Easy to read.
- **Storytelling:** Supporting evidence for the main table.
- **Labeling:** "Size (pp)" is clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check. In top journals, one bandwidth sensitivity table for the primary outcome is often relegated to the Online Appendix to keep the main text lean, especially since Figure 7 shows this graphically.

### Figure 5: "Placebo Cutoff Tests"
**Page:** 19
- **Formatting:** Clean "coefficient plot" style.
- **Clarity:** High. Red vs. Grey distinction is effective.
- **Storytelling:** Strong validation of the RD design.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 20
- **Formatting:** Standard event-study style.
- **Clarity:** Good use of colors for pre/post.
- **Storytelling:** Crucial for showing no pre-trends and no "lagged" effects.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Parametric RDD Specifications"
**Page:** 21
- **Formatting:** Standard "Stars and Bars" regression table.
- **Clarity:** Dense. Columns (1)-(3) are Total Emp, (4)-(5) are Info Emp. 
- **Storytelling:** Shows that adding covariates doesn't change the null.
- **Labeling:** Missing "Mean of Dep Var". The interaction term `Above Threshold x I(pov_centered^2)` has a typo in the label (`pov_centered^2` vs `pov_centered^2`).
- **Recommendation:** **REVISE**
  - Fix the typo in the last row label.
  - Group columns (1-3) and (4-5) under a common header (e.g., "Outcome: Δ Total Employment").

---

## Appendix Exhibits

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 31
- **Formatting:** Clean.
- **Clarity:** Redundant with Table 4.
- **Storytelling:** Visual representation of Table 4.
- **Recommendation:** **KEEP AS-IS** (But ensure Table 4 is also in the appendix nearby).

### Figure 8: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 32
- **Formatting:** Coefficient plot.
- **Clarity:** Excellent.
- **Storytelling:** Actually shows the imbalances more clearly than Table 2. It shows % White and Unemployment are well outside the insignificance region.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals (like AEJ: Policy) love covariate balance plots. Moving this to the main text (and potentially moving the balance table to the appendix) makes the "failed" balance check more transparent and easier to parse.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** The exhibits are technically proficient and follow the "Cattaneo-style" RDD visualization standards. The use of binned means with proportional sizing is excellent.
- **Strongest exhibits:** Figure 2 (First Stage) and Figure 5 (Placebo Cutoffs).
- **Weakest exhibits:** Table 3 (Panel C's IV estimates are mechanically exploded and distracting) and Figure 1 (McCrary info inside the plot).
- **Missing exhibits:** 
    1. **A map:** Since this is about "Distressed Communities" and "Data Centers," a map of the US showing the density of data centers vs. Opportunity Zones would be a powerful "Figure 1" to motivate the paper.
    2. **Industry Breakdown Table:** A table showing the sub-sectors of NAICS 51 (as discussed on page 9) would help the reader understand why the "Information" sector is a good proxy.

- **Top 3 improvements:**
  1. **Consolidate and Scale:** Add "Mean of Dependent Variable" to all regression tables. This is standard in top-5 journals to help readers interpret the magnitude of the null.
  2. **Address the Balance Visuals:** Promote Figure 8 (Covariate Balance Plot) to the main text. It is a more modern and clearer way to show the RDD validity than Table 2.
  3. **Unit Clarity:** Explicitly label y-axes and table headers with units (e.g., "Change in number of employees") rather than just "Estimate."