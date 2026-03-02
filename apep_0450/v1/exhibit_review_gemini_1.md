# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T19:02:04.099317
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1992 out
**Response SHA256:** 14883a9b8650f858

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: State-Level Consumer Price Index (General)"
**Page:** 10
- **Formatting:** Subpar for top-tier journals. Headers are misaligned with data. "Inflation (Tax Intensity..." is an overlapping text error in the third row. 
- **Clarity:** Low. The variable names in the first column contain typos/overlapping text. The "N States" and "N Months" should be in the table notes or a separate "Panel B," not listed as rows with empty mean/SD values.
- **Storytelling:** Provides necessary context, but the messy row labels distract from the variation in tax intensity.
- **Labeling:** Variable names are messy. Note is comprehensive.
- **Recommendation:** REVISE
  - Fix overlapping text in row 3 ("Inflation (Tax Intensity...").
  - Decimal-align all numbers.
  - Move "N States" and "N Months" to the table notes to clean up the data rows.

### Figure 1: "Cross-State Consumer Price Dispersion Over Time"
**Page:** 13
- **Formatting:** Clean "ggplot2" style, but gridlines are slightly too dark for AER style. 
- **Clarity:** Good. The dual lines (raw vs. smoothed) are helpful.
- **Storytelling:** Crucial. It shows that dispersion was *rising* before the reform, which sets the stage for the paper's specific DiD identification.
- **Labeling:** Excellent. The vertical dashed lines for "Demonetization" and "GST" are well-placed.
- **Recommendation:** KEEP AS-IS

### Figure 2: "Cross-State Price Dispersion by Commodity Group"
**Page:** 14
- **Formatting:** Standard. Colors are distinguishable but a bit "default."
- **Clarity:** Moderate. With six lines, it is starting to look like "spaghetti." 
- **Storytelling:** Important for motivating the triple-difference. It shows that different groups have wildly different dispersion levels.
- **Labeling:** Clear.
- **Recommendation:** REVISE
  - Consider using a "small multiples" (faceted) approach—one small plot per commodity—so the individual trends (especially the rise in "Tobacco") are easier to see without line crossings.

### Figure 3: "Average CPI: High vs. Low Pre-GST Tax States"
**Page:** 15
- **Formatting:** High quality. No gridlines, clean axes.
- **Clarity:** Excellent. The narrowing gap post-2017 is visible.
- **Storytelling:** This is the most "honest" look at the raw data. It shows that "convergence" is a relative slowdown in the high-tax group rather than an absolute fall in prices.
- **Labeling:** Clear legend and subtitle.
- **Recommendation:** KEEP AS-IS

### Table 2: "GST and State-Level CPI: Main Results"
**Page:** 16
- **Formatting:** Professional. Uses standard horizontal rules.
- **Clarity:** High. Clear comparison across three types of "treatment."
- **Storytelling:** This is the "money table." It shows the baseline effect is small and only marginally significant (10% level).
- **Labeling:** Good. Standard errors are correctly in parentheses.
- **Recommendation:** REVISE
  - Add the Randomization Inference (RI) p-value as a row at the bottom of Column 1, as the abstract mentions it (0.056) and it is more robust than the clustered p-value.

### Figure 4: "Event Study: GST and State-Level CPI"
**Page:** 17
- **Formatting:** Professional. 
- **Clarity:** High. The reference month (-1) is clearly marked.
- **Storytelling:** Essential. It validates the parallel trends assumption (flat before 0) and shows the dynamic nature of the effect (widening over time).
- **Labeling:** Axis labels are descriptive.
- **Recommendation:** KEEP AS-IS

### Table 3: "Triple-Difference: State Tax Intensity × Commodity Tax Change"
**Page:** 18
- **Formatting:** Consistent with Table 2.
- **Clarity:** Good. 
- **Storytelling:** This is the paper's strongest econometric result. It moves from 10% significance to 1% significance by using granular variation.
- **Labeling:** The variable names are slightly long; consider abbreviations in the table with full names in the notes.
- **Recommendation:** KEEP AS-IS

### Table 4: "GST Price Effects by Commodity Group"
**Page:** 18
- **Formatting:** A bit sparse. 
- **Clarity:** Good.
- **Storytelling:** This table is entirely redundant because its information is contained in both Figure 5 and the Appendix Table on page 32.
- **Recommendation:** REMOVE
  - The figure (Fig 5) tells this story much more effectively for the main text.

### Figure 5: "GST Price Convergence by Commodity Group"
**Page:** 19
- **Formatting:** Excellent "coefficient plot."
- **Clarity:** High. Color-coding for significance is very helpful.
- **Storytelling:** Highlights the "Fuel" outlier/puzzle effectively.
- **Labeling:** Clear.
- **Recommendation:** KEEP AS-IS

### Table 5: "Robustness Checks: Alternative Samples and Placebo Tests"
**Page:** 20
- **Formatting:** Consistent.
- **Clarity:** Clear columns.
- **Storytelling:** Solidifies the result by excluding shocks (Demonetization, COVID).
- **Labeling:** Good.
- **Recommendation:** KEEP AS-IS

### Table 6: "Leave-One-Out Sensitivity: Excluding Each State"
**Page:** 21
- **Formatting:** Simplistic.
- **Clarity:** High.
- **Storytelling:** Usually, this is better summarized in a sentence or a histogram in the appendix. It takes up a lot of space for only 5 rows of data.
- **Recommendation:** MOVE TO APPENDIX
  - Replace this in the main text with a single sentence: "Results are robust to excluding any single state, with coefficients ranging from -0.011 to -0.006 (see Appendix Table X)."

### Figure 6: "Randomization Inference: Permutation Distribution"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** High. 
- **Storytelling:** Crucial for papers with a small number of clusters (35 states). It proves the result isn't a fluke of the specific state tax assignments.
- **Labeling:** "Actual" line is well-annotated.
- **Recommendation:** KEEP AS-IS

---

## Appendix Exhibits

### [Table]: "Pre-Trend Test Details" (No Table Number)
**Page:** 30
- **Formatting:** Good.
- **Clarity:** High.
- **Storytelling:** Explicitly shows the marginal significance in 2015/2016 which the author admits is "concerning."
- **Labeling:** Needs a Table Number (e.g., Table A1).
- **Recommendation:** REVISE
  - Assign a table number.

### [Table]: "Commodity-Level Results" (No Table Number)
**Page:** 32
- **Formatting:** Good.
- **Clarity:** High.
- **Storytelling:** Provides the N and SE for the heterogenous effects.
- **Labeling:** Needs a Table Number (e.g., Table A2).
- **Recommendation:** REVISE
  - Assign a table number.

---

## Overall Assessment

- **Exhibit count:** 5 main tables (after recommended removal), 6 main figures, 2 appendix tables.
- **General quality:** High. The figures are significantly more polished than the tables. The paper follows modern "Best Practices" for DiD (Event studies, RI, Triple-Diff).
- **Strongest exhibits:** Figure 4 (Event Study) and Figure 6 (Randomization Inference).
- **Weakest exhibits:** Table 1 (formatting errors) and Table 4 (redundant).
- **Missing exhibits:** A **Map of India** shaded by "Pre-GST Tax Intensity" is a glaring omission. For a paper about cross-state variation, the reader needs to see the geography of the treatment.

**Top 3 improvements:**
1.  **Add a Treatment Map:** Create a choropleth map of India showing pre-GST tax intensity. This is standard for QJE/AER papers using regional variation.
2.  **Clean Table 1:** Fix the overlapping text/typos in the summary statistics. It is the first table readers see and currently looks unprofessional.
3.  **Consolidate and Streamline:** Remove Table 4 (already in Figure 5) and move Table 6 to the appendix to make the "Results" section tighter and more focused on the Triple-Diff (Table 3).