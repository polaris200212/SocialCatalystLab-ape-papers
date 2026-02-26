# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T18:26:17.140300
**Route:** Direct Google API + PDF
**Tokens:** 20477 in / 2632 out
**Response SHA256:** 4a9dbd71ff112a6e

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Clean and professional. Proper use of horizontal rules (booktabs style).
- **Clarity:** Numbers are easy to read, but the decimal alignment is inconsistent (e.g., Log price vs. Median price). "Transactions" having three decimal places is unnecessary for a count variable.
- **Storytelling:** Provides a good overview of the sample. However, it lacks a column for "N" per variable, which is important since the note mentions missing observations for some variables.
- **Labeling:** Clear labels. The note explains the sample restrictions well.
- **Recommendation:** **REVISE**
  - Remove decimal places from the "Transactions" row; counts should be integers.
  - Align all numbers by the decimal point.
  - Add a "Number of Observations" column to clarify exactly how many observations contribute to each mean.

### Table 2: "Main Results: UK Exposure and French Housing Prices"
**Page:** 12
- **Formatting:** Standard AER/QJE style. Good use of checkmarks for fixed effects.
- **Clarity:** The column headers are a bit cramped. The dependent variable "log_price_m2" is in a raw variable format; it should be "Log Price per $m^2$".
- **Storytelling:** This is the core "failure" table described in the introduction. It effectively shows how the result changes with different measures and controls.
- **Labeling:** Significance stars are used but not defined in the table note. Standard errors are in parentheses, which should be explicitly stated.
- **Recommendation:** **REVISE**
  - Change "log_price_m2" to "Log Price per $m^2$".
  - Define significance stars in the notes (* p<0.1, ** p<0.05, *** p<0.01).
  - Explicitly state "Standard errors clustered at the département level are in parentheses."

### Table 3: "Triple-Difference: UK Exposure × Post × Houses"
**Page:** 14
- **Formatting:** Consistent with Table 2.
- **Clarity:** The interaction terms are very long. "House $\times$ Log SCI(UK) $\times$ Post" is clear but visually heavy.
- **Storytelling:** This is the "centerpiece" exhibit. It successfully shows the UK effect surviving the horse race (Col 5) while the German placebo (Col 4) is null.
- **Labeling:** Notes are sparse. Needs a description of the FE structure (which is complex here).
- **Recommendation:** **REVISE**
  - Simplify variable names in the first column (e.g., "UK Exposure $\times$ Post $\times$ House").
  - Add a note explaining that the sample size in Column 2 is smaller due to census data availability.

### Table 4: "Triple-Difference: Pre-2020 Subsample (2014–2019)"
**Page:** 15
- **Formatting:** Consistent.
- **Clarity:** Very clean as it only has two columns.
- **Storytelling:** Important for the COVID-19 confounding argument.
- **Labeling:** Descriptive title.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Event Studies: SCI and Census Stock Exposure"
**Page:** 16
- **Formatting:** High-quality ggplot2-style output. Shaded 95% CIs are standard.
- **Clarity:** The vertical red dotted line is helpful. The y-axis scales are different for Panel A and B, which is appropriate given the different units of treatment, but should be noted.
- **Storytelling:** Crucial for visualizing the "borderline" pre-trends mentioned in the text.
- **Labeling:** Clear axis titles. Legend is missing, but the titles for Panel A and B make it redundant.
- **Recommendation:** **REVISE**
  - Ensure the y-axis 0-line is a slightly heavier dashed line to clearly show the null hypothesis.
  - The caption should explicitly state the omitted reference period (2016-Q2).

### Figure 2: "Triple-Difference Event Study: Houses vs. Apartments"
**Page:** 17
- **Formatting:** Matches Figure 1.
- **Clarity:** The "noise" in the data is visible, but the trend change at the red line is the focus.
- **Storytelling:** Connects the DiD event study to the Triple-Diff logic.
- **Labeling:** Y-axis label is a bit technical ("Log SCI(UK) $\times$ House $\times$ Period").
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "House-Apartment Price Gap Event Study"
**Page:** 18
- **Formatting:** Two panels, well-aligned.
- **Clarity:** Clearer than Figure 2 because it collapses the outcome to the gap itself.
- **Storytelling:** This is the strongest evidence for parallel trends.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Pairs Cluster Bootstrap Inference"
**Page:** 19
- **Formatting:** Simple summary table.
- **Clarity:** Compares two p-values side-by-side. Very effective.
- **Storytelling:** Addresses the "small number of clusters" (96) critique.
- **Labeling:** Note explains the number of iterations (499).
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Multi-Country Placebo Battery"
**Page:** 20
- **Formatting:** Complex table with a "Horse Race" sub-section.
- **Clarity:** It's a bit of a "wall of numbers." The differentiation between GADM1 and GADM2 is vital but buried in the row labels.
- **Storytelling:** This is the most complex part of the paper's identification check. It might be better as a figure.
- **Recommendation:** **REVISE**
  - Consider bolding the "United Kingdom" row to make it the clear benchmark.
  - The "Horse Race" section has blank cells for the DiD columns; use "—" or "N/A" to indicate they aren't estimated there.

### Figure 4: "Multi-Country Placebo: Coefficient Comparison"
**Page:** 21
- **Formatting:** Excellent visual summary of Table 6.
- **Clarity:** Different colors/shapes for DiD vs Triple-Diff.
- **Storytelling:** Effectively "rescues" the paper's argument by showing the Triple-Diff narrowing the placebo effects toward zero.
- **Labeling:** The horizontal line at 0 is essential and present.
- **Recommendation:** **KEEP AS-IS** (This is a "top-tier journal" quality figure).

### Figure 5: "HonestDiD Sensitivity: Census Stock Event Study"
**Page:** 22
- **Formatting:** Standard Rambachan & Roth (2023) plot.
- **Clarity:** Easy to see the breakdown value.
- **Storytelling:** Essential for modern DiD papers to handle pre-trend violations.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Commune-Level Triple-Difference"
**Page:** 23
- **Formatting:** Good comparison of "Commune" vs "Dept" levels.
- **Clarity:** Large N (214,660) is impressive.
- **Storytelling:** Shows that the point estimates are stable but precision increases with more data.
- **Labeling:** "code_departement" should be changed to "Département" in the Standard-Errors row.
- **Recommendation:** **REVISE**
  - Fix the "code_departement" technical label to plain English.

### Figure 6: "Randomization Inference: Census Stock"
**Page:** 24
- **Formatting:** Clean histogram.
- **Clarity:** The red vertical line clearly shows the observed coefficient is an outlier.
- **Storytelling:** Robustness check for cross-sectional correlation.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Leave-One-Out Analysis: Census Stock"
**Page:** 25
- **Formatting:** Sorted dot plot.
- **Clarity:** Very easy to see that no single département (like Paris) drives the result.
- **Storytelling:** Important for France, where Paris often skews results.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Robustness: Census Stock Specification"
**Page:** 26
- **Formatting:** Standard.
- **Clarity:** Columns 2 and 3 address geographic outliers (Paris/Corsica).
- **Storytelling:** Standard "kitchen sink" robustness.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Exchange Rate Channel: Sterling Depreciation and Housing Prices"
**Page:** 27
- **Formatting:** The title is cut off in the "DE (Placeb" header.
- **Clarity:** The negative coefficients are the key finding.
- **Storytelling:** Explains the "why" (purchasing power).
- **Recommendation:** **REVISE**
  - Fix header "(Placeb" to "(Placebo)".

### Table 10: "Geographic Heterogeneity: Channel-Facing and UK Buyer Hotspots"
**Page:** 28
- **Formatting:** Uses "= 0" in labels to indicate the "Interior" or "Non-Hotspot" groups.
- **Clarity:** A bit confusing. Usually, authors use "Interaction" and "Main Effect" or separate rows for "In Group" and "Out of Group".
- **Storytelling:** Shows the effect is localized where expected.
- **Recommendation:** **REVISE**
  - Relabel "Log UK Stock... $\times$ Channel = 0" to "Log UK Stock... $\times$ Interior" for better readability.

### Figure 8: "GBP/EUR Exchange Rate, 2014–2023"
**Page:** 29
- **Formatting:** Professional line plot.
- **Clarity:** The "Brexit referendum" annotation is well-placed.
- **Storytelling:** Provides the macroeconomic context.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 10 main tables, 8 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The figures are modern, clean, and follow the latest econometric standards (Event studies, HonestDiD, RI). Tables follow the "booktabs" style preferred by top journals.
- **Strongest exhibits:** Figure 4 (Multi-country comparison) and Figure 1 (Event studies).
- **Weakest exhibits:** Table 6 (too much data in one table) and Table 10 (confusing labeling of groups).
- **Missing exhibits:** A map of France showing the "UK Census Stock" or "SCI" intensity. For a paper on geography/social networks, a heat map is almost mandatory to help the reader visualize the Dordogne/Brittany clusters mentioned in the intro.

**Top 3 improvements:**
1. **Add a Map:** Create a figure showing the geographic distribution of treatment (UK Census Stock 2016) across French départements. This anchors the "rural vs urban" story.
2. **Standardize Table Notes:** Ensure every table has a note defining significance stars and explicitly stating the clustering level and SE placement. 
3. **Clean Header Tech-Speak:** Remove raw variable names (e.g., `log_price_m2`, `code_departement`) from table headers and replace them with formatted English labels.