# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-16T13:27:07.565942
**Route:** Direct Google API + PDF
**Tokens:** 19957 in / 2311 out
**Response SHA256:** 12ebe5bb66fa2ce7

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 10
- **Formatting:** Clean and professional. Use of panels (A-D) is excellent for grouping.
- **Clarity:** Very high. Logical flow from outcomes to treatment to covariates.
- **Storytelling:** Essential. It establishes the scale of the mortality crisis and the variation in the network exposure variable (Mean 0.455).
- **Labeling:** Good. "State-years" and "States" are clearly separated. 
- **Recommendation:** **KEEP AS-IS**

### Table 2: "PDMP Network Exposure and Total Overdose Death Rate"
**Page:** 13
- **Formatting:** Standard three-column regression layout. Decimal alignment is generally good, but some coefficients vary in precision (e.g., 2.767 vs 0.8818). 
- **Clarity:** The comparison between Binary, Continuous, and Pop-Weighted models is clear.
- **Storytelling:** This is the "money table." It provides the core evidence of the paper.
- **Labeling:** "state_abbr fixed effects" is a bit "code-heavy." 
- **Recommendation:** **REVISE**
  - Change "state_abbr fixed effects" to "State Fixed Effects".
  - Standardize all coefficients and standard errors to three decimal places for consistency.
  - Add the sample mean of the dependent variable to the bottom of the table to help readers interpret the 2.767 coefficient as a ~12% increase.

### Figure 1: "Drug Overdose Death Rates by PDMP Network Exposure Status"
**Page:** 14
- **Formatting:** Modern and clean. The shaded confidence intervals are helpful.
- **Clarity:** A bit cluttered. The labels inside the plot ("First PDMP mandates", "High exposure...") overlap with the gridlines and data.
- **Storytelling:** Vital for establishing the "divergence" after the policy rollout. 
- **Labeling:** The x-axis title "Year" is redundant given the date labels. The y-axis label is clear.
- **Recommendation:** **REVISE**
  - Remove the background gridlines to make the trend lines pop.
  - Move the descriptive text in the subtitle ("High exposure: >=50%...") into the figure note or legend.
  - Fix the "Low Exposure" series termination; the sudden cut-off in 2019 is explained in the note but looks visually like a data error. Consider a dashed line if the sample size is small.

### Figure 2: "Event Study: Network Exposure and Overdose Deaths (Callaway-Sant’Anna DR)"
**Page:** 15
- **Formatting:** Professional. Point estimates with 95% CIs is standard.
- **Clarity:** Excellent. The reference period (t-1) is correctly omitted and marked at zero.
- **Storytelling:** Crucial for identification. It proves no pre-trends and show the growing "balloon effect" over time.
- **Labeling:** Labels are clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Network Exposure Effects by Drug Type (2015–2023)"
**Page:** 16
- **Formatting:** Horizontal layout is standard.
- **Clarity:** Good. The drug type names (rx_opioids, etc.) are a bit like variable names.
- **Storytelling:** Important for mechanism (substitution). It shows the effect is driven by Heroin and Rx Opioids.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **REVISE**
  - Rename column headers to be more formal: "Rx Opioids", "Heroin", "Synthetic Opioids", etc. (remove underscores).
  - Add the ICD-10 codes (T40.2, etc.) to the column headers or a row right below them for medical precision.

### Figure 3: "Network Exposure Effects by Drug Type (TWFE, 2015–2023)"
**Page:** 17
- **Formatting:** Clean coefficient plot. 
- **Clarity:** Excellent. It's a visual summary of Table 3.
- **Storytelling:** Redundant with Table 3. In top journals, you usually choose one or the other for the main text.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - Table 3 provides the exact numbers and standard errors which are more useful for the main argument. The figure is a nice visual but doesn't add new info.

### Table 4: "Heterogeneity: Period Splits and Network Position"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** The column headers for (1) and (2) are multi-line and slightly confusing.
- **Storytelling:** Very strong. Column (3) showing the negative interaction with "degree" is a top-tier finding.
- **Labeling:** Significance stars are clear.
- **Recommendation:** **REVISE**
  - Fix the column headers. Use "Pre-Fentanyl (2011-13)" and "Fentanyl Era (2014-23)" as single-row headers.
  - Add a row for "Main Effect at Mean Degree" or similar to help with interpretation of the interaction in Column 3.

### Table 5: "Robustness: Alternative Network Exposure Thresholds"
**Page:** 19
- **Formatting:** Standard.
- **Clarity:** The diagonal structure of the coefficients (since each is a different regression) is clear.
- **Storytelling:** Excellent "dose-response" evidence.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Leave-One-Out Sensitivity Analysis"
**Page:** 21
- **Formatting:** "Caterpillar plot" is very effective for this.
- **Clarity:** Good, though the state abbreviations on the y-axis are a bit small.
- **Storytelling:** Proves the result isn't driven by West Virginia or Ohio. 
- **Labeling:** Dashed line for the full-sample estimate is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Propensity Score Overlap by Treatment Group"
**Page:** 23
- **Formatting:** Density plot with transparency is professional.
- **Clarity:** Very high.
- **Storytelling:** Technically necessary for the Callaway-Sant’Anna method but visually "filler" for the main text.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a diagnostic plot. Top journals prefer to see results in the main text and diagnostics in the appendix.

---

## Appendix Exhibits

### Table 6: "PDMP Must-Query Mandate Adoption Dates"
**Page:** 33
- **Formatting:** Very long list. 
- **Clarity:** Simple and effective.
- **Storytelling:** Great for transparency/replication.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Placebo Tests: Non-Drug Outcomes"
**Page:** 34
- **Formatting:** Matches main text tables.
- **Clarity:** Clear "null" results.
- **Storytelling:** Strong robustness.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Sensitivity to Unmeasured Confounding (Cinelli and Hazlett, 2020)"
**Page:** 34
- **Formatting:** Standard contour plot.
- **Clarity:** Low. These plots are notoriously hard for non-experts to read quickly. The text labels overlap.
- **Storytelling:** High-level robustness.
- **Labeling:** The "Unadjusted" point is clear, but others are cluttered.
- **Recommendation:** **REVISE**
  - Increase the font size of the benchmark labels (e.g., "1x own_pdmp").
  - Use a cleaner color palette or higher contrast for the red dashed line.

### Figure 7: "PDMP Network Exposure by State, Selected Years"
**Page:** 35
- **Formatting:** Faceted bar chart.
- **Clarity:** Medium. The y-axis (states) is very crowded. 
- **Storytelling:** Visually shows the "balloon" filling up across the country.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - Consider a **Map** instead of a bar chart. A 4-panel map of the US (2011, 2015, 2019, 2023) showing exposure intensity would be much more intuitive for a "Geography of Mortality" paper.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 2 appendix tables, 2 appendix figures.
- **General quality:** High. The paper follows modern empirical standards (CS-DiD, sensitivity analysis). The tables are AER-ready.
- **Strongest exhibits:** Figure 2 (Event Study) and Table 5 (Dose-Response).
- **Weakest exhibits:** Figure 7 (Appendix bar chart) and Table 3 (Variable-style headers).
- **Missing exhibits:** 
    - **A Heat Map:** The paper is about geography but contains no maps. A map showing network exposure in 2023 would be a powerful "Figure 1".
    - **Raw Data Scatter:** A scatter plot of "Exposure" vs "Change in Mortality" would be a nice "first look" at the data.

### Top 3 Improvements:
1. **Add a Map:** Replace or supplement Figure 7 with a US choropleth map. This is a paper about spatial spillovers; the reader needs to see the geography.
2. **Clean up Main Text:** Move Figure 3 and Figure 5 to the appendix. They are diagnostic/redundant. This tightens the "story" in the main text to focus on the mortality results.
3. **Professionalize Table 3 & 4:** Remove "code" language (underscores, `state_abbr`) from headers. Top journals want "Human-readable" tables that look like they were typed, not exported directly from Stata/R.