# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T13:48:25.974445
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 2035 out
**Response SHA256:** 176706ad4daadd6f

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Clean and professional. Follows standard booktabs style with clear panel divisions. Numbers are appropriately rounded, though population figures are quite long (consider displaying in millions).
- **Clarity:** Excellent. The two panels logically separate static census characteristics from time-varying outcomes.
- **Storytelling:** Essential. It establishes the massive heterogeneity in Indian districts, which justifies the use of log transformations and motivates the concern for selection bias.
- **Labeling:** Very good. Definitions are clear.
- **Recommendation:** **REVISE**
  - Divide "Population" and "Households" by 1,000,000 and 1,000 respectively and update labels to "(Millions)" and "(Thousands)". This avoids decimal-aligned strings of 7+ digits that are hard to read.
  - Add a note defining "Log Nightlights" (e.g., "Log(NL+1)") to the table footer for standalone readability.

### Table 2: "Covariate Balance Across Treatment Cohorts"
**Page:** 10
- **Formatting:** Standard journal format.
- **Clarity:** High. Clearly shows the "selection on levels" problem mentioned in the text (e.g., 2016 cohort literacy 0.77 vs 2019 cohort 0.61).
- **Storytelling:** Critical for the paper's argument that ODF timing is not random.
- **Labeling:** Clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of ODF Declaration on District Nightlights"
**Page:** 13
- **Formatting:** Professional. Good use of column headers to distinguish specifications.
- **Clarity:** The juxtaposition of TWFE results in the table and the CS-DiD result in the note is effective for the paper's "de-biasing" narrative.
- **Storytelling:** This is the "money table." It shows the naive negative results that the rest of the paper deconstructs.
- **Labeling:** Significance stars and SE notes are present.
- **Recommendation:** **REVISE**
  - **Major Suggestion:** Add a final column (6) for the **Callaway-Sant’Anna (CS-DiD)** estimate. While the paper argues it's a null, hiding the primary robust result in the table notes weakens the visual impact. Journals like AER/QJE prefer seeing the preferred robust estimator side-by-side with the naive one.
  - Include the "Mean of Dep. Var." in the bottom rows to help readers interpret the magnitude of the coefficients.

### Figure 1: "TWFE Event Study: Effect of ODF Declaration on Log Nightlights"
**Page:** 15
- **Formatting:** Modern and clean. The use of a shaded confidence area is standard.
- **Clarity:** The key message (massive pre-trend) is immediately obvious.
- **Storytelling:** Perfectly illustrates why the TWFE coefficient in Table 3 is biased.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Callaway-Sant’Anna Event Study"
**Page:** 16
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Shows the reduction in pre-trends and the resulting null effect clearly.
- **Storytelling:** The logical "fix" to Figure 1.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - For easier comparison, ensure the Y-axis scale is identical to Figure 1. This allows the reader to see the "shrinkage" of the coefficients visually without checking the numbers.

### Table 4: "Heterogeneous Effects by District Characteristics"
**Page:** 17
- **Formatting:** Professional.
- **Clarity:** Good. The interaction terms are clearly labeled.
- **Storytelling:** Supports the confounding story (effects are stronger where they *shouldn't* be).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks"
**Page:** 18
- **Formatting:** This is a "summary of results" table. It is efficient but less standard than a full regression table.
- **Clarity:** Very high. It allows for a quick scan of many tests.
- **Storytelling:** Moves several robustness checks into one view, which is good for flow.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - While useful, Top-5 journals usually prefer these results to be in individual full tables in the appendix or a "Robustness" section. The main text should focus on the 2-3 most critical ones.

### Figure 3: "Randomization Inference: Distribution of Placebo Coefficients"
**Page:** 19
- **Formatting:** Professional. Red line provides a clear anchor.
- **Clarity:** High.
- **Storytelling:** Useful for showing that the naive TWFE result is on the tail but not "extreme."
- **Labeling:** "Actual = -0.0948" label is very helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Raw Nightlights Trends by ODF Declaration Cohort"
**Page:** 20
- **Formatting:** Excellent color palette (color-blind friendly).
- **Clarity:** Extremely high. This is actually one of the most important figures in the paper.
- **Storytelling:** This should be much earlier in the paper. It shows the "Parallel Trends" violation in raw data before any econometrics are applied.
- **Labeling:** Legend and axis labels are perfect.
- **Recommendation:** **KEEP AS-IS** (But move it to Section 4 or 5).

### Figure 5: "Staggered ODF Declarations Across Indian States"
**Page:** 21
- **Formatting:** Clean, "dot plot" style is very effective for timing.
- **Clarity:** Excellent.
- **Storytelling:** Provides the "Institutional Background" in one visual.
- **Labeling:** State names are legible.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 6: "Variable Definitions"
**Page:** 30
- **Formatting:** Simple and functional.
- **Clarity:** Good.
- **Storytelling:** Necessary for transparency.
- **Labeling:** N/A.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Cohort-Specific Treatment Effects (CS-DiD)"
**Page:** 33
- **Formatting:** Consistent with previous figures.
- **Clarity:** Shows the imprecision of the 2016 cohort well.
- **Storytelling:** Explains *why* the aggregate effect is a null.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Nightlights Trends by District Rural Share"
**Page:** 34
- **Formatting:** High quality.
- **Clarity:** Very clear.
- **Storytelling:** Supports the "urban placebo" argument.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 1 appendix table, 2 appendix figures.
- **General quality:** The visual exhibits are exceptionally high quality. They use modern R/Stata aesthetics that look very much at home in the AEA/UChicago/OUP journal styles. The figures are clean, and the tables follow the "less is more" rule with gridlines.
- **Strongest exhibits:** Figure 4 (Raw Trends) and Figure 5 (Staggered Timeline). They tell the institutional and data story without needing the regression results.
- **Weakest exhibits:** Table 3 (hiding the main result in the footer) and Table 5 (redundant with text).
- **Missing exhibits:** 
    1. **A Map:** For a paper using satellite data and Indian districts, a choropleth map showing ODF declaration years by district/state is a standard "Figure 1" in development economics.
    2. **DMSP Figure:** The text mentions an "extended pre-trend analysis" using DMSP data (2008-2013) but says it is only summarized textually. A figure showing the flat trends in that era would be a powerful "Pre-SBM" validation.

- **Top 3 improvements:**
  1. **Add a Map:** Create a map of India shaded by ODF declaration year. This grounds the "staggered" variation geographically for the reader.
  2. **Integrate CS-DiD into Table 3:** Do not leave the primary robust estimate in the table notes. Make it a prominent column to show the "correction" of the bias.
  3. **Re-order for Storytelling:** Move Figure 4 (Raw Trends) and Figure 5 (Timeline) to earlier in the paper (Data/Methodology sections). They provide the intuition that makes the subsequent regressions easier to digest.