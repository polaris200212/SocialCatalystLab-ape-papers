# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T00:20:49.574071
**Route:** Direct Google API + PDF
**Tokens:** 16837 in / 2824 out
**Response SHA256:** 0ac4b8baa55eae0b

---

This review evaluates the visual exhibits of "Cosmopolitan Confounding" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 8
- **Formatting:** Generally clean. Uses horizontal lines appropriately.
- **Clarity:** Logical grouping. Including both log and level of prices is helpful for scale.
- **Storytelling:** Establishes the cross-sectional variation. The note about missing cells is important for transparency.
- **Labeling:** Good. "Sterling Weakness" is clearly defined in the text, but the note could benefit from a one-sentence definition of the variable's sign (e.g., "higher values indicate a weaker pound").
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Geographic Distribution of UK Exposure across French Départements"
**Page:** 8
- **Formatting:** Professional chloropleth maps. Legend placement is clean.
- **Clarity:** Excellent 10-second parse. One can immediately see the concentration in the "Dordogne" and coastal areas mentioned in the text.
- **Storytelling:** Essential to show that SCI and Census stocks are highly correlated but not identical.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Main Results: UK Exposure and French Housing Prices"
**Page:** 10
- **Formatting:** Standard journal layout. Standard errors in parentheses. Significance stars used.
- **Clarity:** Column headers are descriptive. However, the contrast between Col (2) and Col (5) is the paper's core "hook."
- **Storytelling:** Excellent. Shows the "German Placebo failure" clearly. 
- **Labeling:** The note is very thorough, particularly explaining the R-squared in Col (6).
- **Recommendation:** **REVISE**
  - **Specific Improvement:** Decimal-align all coefficients. Currently, the signs and digits are slightly ragged.
  - **Specific Improvement:** In the "Notes," explicitly state the frequency of the data (Quarterly) for clarity.

### Table 3: "Triple-Difference: UK Exposure x Post x Houses"
**Page:** 11
- **Formatting:** Clean. Grouping of Fixed Effects at the bottom is standard.
- **Clarity:** The dependent variable "log_price_m2" has an underscore—this should be "Log Price/m²" to match Table 1 and 2.
- **Storytelling:** Effectively shows the "null" for Germany in the triple-diff.
- **Labeling:** Consistent.
- **Recommendation:** **REVISE**
  - **Specific Improvement:** Change "log_price_m2" to "Log Price/m²" to remove LaTeX/Stata-style underscores.
  - **Specific Improvement:** The "UK+DE" column (5) should be renamed "Horse Race" or "Joint" to be more descriptive.

### Figure 2: "Event Study: SCI Exposure" [Panel A] and "Census Stock" [Panel B]
**Page:** 11 (and 12)
- **Formatting:** The figure is split across pages in the PDF layout; ensure it fits on one page in the final manuscript.
- **Clarity:** High. Clearly shows the "pre-trend" tests.
- **Storytelling:** Vital for DiD validity. Shows the "Post-2020" jump described in the text.
- **Labeling:** The Y-axis labels are a bit cluttered ("Log SCI(UK) x Period"). Consider "Coefficient on Exposure."
- **Recommendation:** **REVISE**
  - **Specific Improvement:** Ensure the 95% CI shading is consistent in opacity between Panel A and B.
  - **Specific Improvement:** Add a vertical line at $t=0$ (the referendum) and perhaps a second dashed line at $t=14$ (start of COVID) since that is a major part of the paper's argument.

### Figure 3: "House–Apartment Price Gap Event Study"
**Page:** 12
- **Formatting:** High quality. Good use of panels.
- **Clarity:** The Y-axis "Coefficient on Exposure" is better than Figure 2.
- **Storytelling:** This is the most important figure for the "Triple-Diff" identification strategy.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "GADM1-Harmonized Multi-Country Placebo Battery"
**Page:** 13
- **Formatting:** Bold text for the UK row is a helpful touch for top journals.
- **Clarity:** The "Horse Race" section at the bottom is a bit crowded.
- **Storytelling:** This table is the "Harmonized" version of the critique—essential for the methodological contribution.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - **Specific Improvement:** Add a horizontal line between the individual country estimates and the "Horse Race" section to separate the specifications more clearly.

### Figure 4: "GADM1-Harmonized Multi-Country Placebo Coefficients"
**Page:** 14
- **Formatting:** Excellent use of color and shape to distinguish DiD from Triple-Diff.
- **Clarity:** Very high.
- **Storytelling:** This is the "Money Plot." It summarizes the entire paper's identification success in one glance.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Epoch Decomposition: Brexit vs. COVID Periods"
**Page:** 16
- **Formatting:** Standard.
- **Clarity:** This is a complex table. The sub-headings ("Brexit Epoch", "COVID Epoch") help immensely.
- **Storytelling:** Essential for the "Brexit vs. COVID" disentanglement.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Specific Improvement:** Column (3) and (4) coefficients are quite small/insignificant for the Brexit epoch. Consider adding the p-values in brackets or a note highlighting where the "action" is to help the reader.

### Table 6: "COVID Disentanglement: WFH Amenity and Channel Proximity Controls"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** Good.
- **Storytelling:** Supporting robustness.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reasoning:** The paper already has many tables. This is a standard robustness check that confirms the main result holds; it doesn't need to take up main text real estate in a QJE/AER submission.

### Table 7: "Pairs Cluster Bootstrap Inference"
**Page:** 18
- **Formatting:** Double horizontal lines at the top are not standard for AER/QJE. Use single thick lines.
- **Clarity:** Clear.
- **Storytelling:** Purely technical robustness.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 8: "Multi-Country Placebo Battery (Mixed Resolution)"
**Page:** 19
- **Formatting:** Bold UK row.
- **Clarity:** Good.
- **Storytelling:** This shows the *problem*. Table 4 shows the *solution*.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Wait—consider merging with Table 4 or moving to Appendix since Table 4 is the "Correct" version). Actually, **REVISE**: Keep in main text but perhaps move to Section 2 (The Problem) rather than Section 7 (Robustness).

### Figure 5: "HonestDiD Sensitivity Analysis: Census Stock Event Study"
**Page:** 20
- **Formatting:** High quality (standard HonestDiD output).
- **Clarity:** Clear for those familiar with Rambachan & Roth (2023).
- **Storytelling:** Vital for modern top-journal DiD papers.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Commune-Level Triple-Difference"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Shows the result holds at higher resolution.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 10: "Robustness: Census Stock Specification"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** Column headers like "No IdF" (No Île-de-France) should be spelled out or defined more clearly in the note.
- **Storytelling:** Standard robustness.
- **Labeling:** Defined in notes.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 6: "Randomization Inference: Census Stock"
**Page:** 22
- **Formatting:** Clean histogram.
- **Clarity:** Very clear.
- **Storytelling:** Visual proof that the result isn't a fluke.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 7: "Leave-One-Out Analysis: Census Stock"
**Page:** 23
- **Formatting:** Standard dot plot.
- **Clarity:** The X-axis "Département dropped" is fine, but the dots are very small.
- **Storytelling:** Shows no single outlier drives the result.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 11: "Exchange Rate Channel: Sterling Depreciation and Housing Prices"
**Page:** 24
- **Formatting:** Underscores in "log_price_m2" again.
- **Clarity:** Good.
- **Storytelling:** Mechanism check.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Mechanisms are important for main text).

### Table 12: "Geographic Heterogeneity: Channel-Facing and UK Buyer Hotspots"
**Page:** 24
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Mechanism check.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "GBP/EUR Exchange Rate, 2014–2023"
**Page:** 25
- **Formatting:** Clean time series.
- **Clarity:** Very high.
- **Storytelling:** Context for the "Post-2016" shock.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (or merge into Figure 2 as a top panel).

### Figure 9: "Triple-Difference Event Study: Houses vs. Apartments"
**Page:** 25
- **Formatting:** Consistent with Figure 2.
- **Clarity:** High.
- **Storytelling:** This is the core evidence for the Triple-Diff.
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO EARLIER IN MAIN TEXT** (Should appear near Table 3).

---

# Overall Assessment

- **Exhibit count:** 12 Main Tables, 9 Main Figures (0 Appendix currently identified, though many recommendations suggest moves).
- **General quality:** Extremely high. The figures are "modern" and use clean ggplot2-style aesthetics which are very popular in AEA journals right now. Tables follow the "no vertical lines" rule.
- **Strongest exhibits:** Figure 4 (Placebo Battery) and Figure 1 (Maps). These tell the whole story.
- **Weakest exhibits:** Table 5 (Too dense) and Table 7 (Formatting of double lines).
- **Missing exhibits:** A **"Variable Definitions"** table in the appendix would be standard for a paper with this many constructed variables (SCI, Residualized SCI, Census Stocks, etc.).

**Top 3 Improvements:**
1. **Streamline the Main Text:** Move the purely technical robustness (Tables 6, 7, 9, 10 and Figures 6, 7) to an Online Appendix. A paper with 20+ exhibits in the main text is too "heavy" for AER/QJE. Aim for 8-10 total.
2. **Clean LaTeX/Stata Artifacts:** Remove all underscores (e.g., `log_price_m2`) and ensure all tables use decimal-aligned columns.
3. **Consolidate the Narrative:** Merge Figure 8 (Exchange Rate) into the background or a panel of Figure 2. This links the "shock" directly to the "estimated effects" in one visual.