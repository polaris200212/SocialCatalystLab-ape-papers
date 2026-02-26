# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T15:17:13.930948
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 2453 out
**Response SHA256:** 484578a3a4d81176

---

As a visual exhibit advisor for top-tier economics journals, I have reviewed the 11 tables and 7 figures in your manuscript. This paper has a high-quality "look and feel" reminiscent of the *AEJ: Applied* or *AER: Insights*, but there are critical issues regarding the grouping of results and the transparency of the "German Placebo" problem that need to be addressed before submission to a top-five journal.

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Professional. Panel structure is clear. Numbers are properly aligned.
- **Clarity:** Good. It clearly distinguishes between cross-sectional variation and quarterly panel outcomes.
- **Storytelling:** Essential. It establishes the variation in the SCI, which is the core of your identification.
- **Labeling:** Clear. Notes define SCI and DVF.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Social Connectedness to the United Kingdom Across French Départements"
**Page:** 9
- **Formatting:** Excellent. The "magma" color scale is accessible and professional.
- **Clarity:** High. The spatial pattern (Channel-facing vs. interior) is immediately obvious.
- **Storytelling:** Strong. It justifies the "Geography Heterogeneity" section later in the paper.
- **Labeling:** Good. The log scale is correctly noted.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Cross-Border Network Spillovers from Brexit to French Housing Markets"
**Page:** 12
- **Formatting:** Standard journal style.
- **Clarity:** This table is trying to do too much. It mixes the main result (Col 1), a timing test (Col 2), a horse race (Col 3), and two placebos (Col 4, 6).
- **Storytelling:** For a top journal, the main result should be isolated or paired only with its most direct controls. The "German Placebo" is so significant here that it threatens the main story; burying it in Column 4 of the first results table feels evasive.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - **Change:** Split this. Create a "Table 2: Main Results" with Col 1 (Baseline), Col 5 (Transactions), and your house/apartment split (currently Table 9). 
  - **Change:** Move the placebos (Col 4, 6) and the horse race (Col 3) to a dedicated "Table 3: Identification Challenges."

### Table 3: "Identification Strengthening: Controlling for General European Openness"
**Page:** 13
- **Formatting:** Clean.
- **Clarity:** "Resid.(DE)" is slightly jargon-heavy for a column header.
- **Storytelling:** This is a "defense" table. It’s necessary but could be consolidated with the horse-race results.
- **Labeling:** Define "DE+CH" in the notes more explicitly.
- **Recommendation:** **REVISE**
  - **Change:** Rename headers to "Residualized (DE)" and "Triple Horse Race."

### Table 4: "Exchange Rate Channel: Sterling Depreciation and Housing Prices"
**Page:** 14
- **Formatting:** Column 5 is cut off in the screenshot/OCR. Ensure the LaTeX `table*` environment or `resizebox` isn't clipping the margin.
- **Clarity:** The negative sign on "Sterling Weakness" is counter-intuitive for a reader.
- **Storytelling:** High value. Referees love exchange rate variation as a "dosage" test.
- **Labeling:** Note 1 mentions a "negative sign reflects the coding"—move this into the table note so the table is self-contained.
- **Recommendation:** **REVISE**
  - **Change:** Ensure the table fits within margins. Add a "Mean of Dep. Var" row.

### Table 5: "Robustness: Controlling for Baseline Département Characteristics"
**Page:** 15
- **Formatting:** Professional.
- **Clarity:** Very high.
- **Storytelling:** This is the most "dangerous" table in the paper because Column 3 kills the main effect. In a QJE-style paper, this belongs in the main text as a "honesty" check.
- **Labeling:** Standard errors are properly placed.
- **Recommendation:** **KEEP AS-IS** (But consider if it should be merged with Table 2 to show the "death" of the coefficient immediately).

### Figure 2: "Event Study: Housing Prices and UK Social Connectedness"
**Page:** 16
- **Formatting:** High quality. Clean background, clear CI bands.
- **Clarity:** The reference period ($\tau=0$) is clearly marked.
- **Storytelling:** Crucial. It shows the effect starts exactly at the referendum.
- **Labeling:** Add "Relative to Referendum (2016 Q2)" to the x-axis label.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Robustness: Shorter Event Window and Département Trends"
**Page:** 17
- **Formatting:** Column 6 is cut off. Formatting broken in the PDF.
- **Clarity:** Poor due to the cut-off.
- **Storytelling:** Important for ruling out COVID, but feels like an appendix table.
- **Labeling:** Incomplete.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 3: "Permutation Inference: Randomized SCI Weights"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** Very high.
- **Storytelling:** This is a "modern" robustness check that QJE/AER editors appreciate for papers with $<100$ clusters.
- **Labeling:** Excellent.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Leave-One-UK-Region-Out Sensitivity"
**Page:** 19
- **Formatting:** Good use of dot-whisker plot.
- **Clarity:** Clear.
- **Storytelling:** Proves the result isn't just "London."
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** (Too much real estate for a simple check).

### Table 7: "UK Country Composition: Progressively Restricting Exposure"
**Page:** 19
- **Formatting:** Redundant with Figure 4.
- **Clarity:** Clear.
- **Storytelling:** Redundant.
- **Labeling:** Clear.
- **Recommendation:** **REMOVE** (Figure 4 tells this story better).

### Figure 5: "Population-Weighted vs. Probability-Weighted SCI"
**Page:** 20
- **Formatting:** Too much white space for two points.
- **Clarity:** Clear.
- **Storytelling:** This is a technical nuance of the SCI.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 6: "Cross-Border Spillovers: Treatment vs. Placebo Countries"
**Page:** 21
- **Formatting:** Good use of color.
- **Clarity:** Clear.
- **Storytelling:** This summarizes Table 2 placebos visually.
- **Labeling:** Clear.
- **Recommendation:** **REVISE** (Promote this to a "Main Result" figure, perhaps as Figure 3, to be upfront about the German placebo).

### Table 8: "Robustness: Alternative Specifications"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Clear.
- **Storytelling:** Standard robustness.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 9: "Mechanism: Property Type Heterogeneity"
**Page:** 22
- **Formatting:** Simple and clean.
- **Clarity:** Very high.
- **Storytelling:** This is one of your strongest arguments for why the effect is *UK-specific* (houses vs. apartments). 
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Merge this into the main Table 2).

### Table 10: "Mechanism: Geographic Heterogeneity"
**Page:** 23
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Fascinating result (Hotspots vs. Channel). It adds a lot of "texture" to the paper.
- **Labeling:** Define "Hotspot" in the notes.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 7: "UK Social Connectedness and Housing Price Changes" (Binscatter)
**Page:** 31
- **Formatting:** Very "busy" with all the labels.
- **Clarity:** Low. The département names overlap and create a mess in the center.
- **Storytelling:** This is a great "intuition" plot. 
- **Recommendation:** **REVISE**
  - **Change:** Remove most labels. Only label the outliers (Paris, Creuse, Dordogne, etc.). Use a standard `binscatter` or `rdplot` style if possible, or just a cleaner scatter.
  - **Change:** Promote to Main Text (near Table 2) once cleaned.

### Table 11: "Permutation Inference: Randomization of SCI Exposure"
**Page:** 31
- **Formatting:** Redundant with Figure 3.
- **Recommendation:** **REMOVE** (Keep the figure, it's more intuitive).

---

# Overall Assessment

- **Exhibit count:** 10 main tables, 6 main figures, 1 appendix table, 1 appendix figure.
- **General quality:** High. The paper uses modern visualization (dot-whisker, magma maps, permutation plots) that signals technical competence to top-tier reviewers.
- **Strongest exhibits:** Figure 1 (Map), Figure 2 (Event Study), Table 9 (House/Apartment split).
- **Weakest exhibits:** Table 2 (too cluttered), Figure 7 (too many labels), Table 6/7 (formatting/redundancy).

### Missing Exhibits:
1. **Raw Trend Figure:** You need a figure showing the raw average price of "High SCI" vs "Low SCI" départements over time. Event studies are great, but reviewers want to see the underlying levels to ensure the "Parallel Trends" assumption is visually plausible in the raw data.

### Top 3 Improvements:
1. **Consolidate and Streamline Table 2:** Move the placebos to a "threats to identification" table. Bring the house/apartment heterogeneity (Table 9) into the main results table.
2. **Fix Margin/Clipping Issues:** Tables 4 and 6 are physically cut off. Use `\adjustbox{max width=\textwidth}` in LaTeX.
3. **Clean up Figure 7 (Scatter):** It is your best "one-glance" proof of the correlation, but the label clutter makes it look amateurish. Label only the 5 most important départements.