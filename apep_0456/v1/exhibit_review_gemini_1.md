# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-25T20:52:07.173406
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1953 out
**Response SHA256:** 40f03417b1b6b47a

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 7
- **Formatting:** Substandard for top journals. The "NaN" values in the Pre-ZFE columns are jarring and unprofessional. Decimal alignment is missing.
- **Clarity:** The presence of empty/NaN columns suggests a data limitation that should be handled in the text or appendix, not as a primary feature of the first table.
- **Storytelling:** It establishes the price and density gradient (Inside vs. Outside), which justifies the RDD. However, the lack of Pre-ZFE data for "Inside" makes the temporal comparison weak.
- **Labeling:** Source and sample restrictions are clear. Units (Euro, sqm) are present.
- **Recommendation:** **REVISE**
  - Remove the "Pre-ZFE" columns if data is truly unavailable for that period geocoded, or replace "NaN" with "---" and explain in the note.
  - Align numbers by decimal point.
  - Group "Post-ZFE" as the primary header and "Outside/Inside" as sub-headers to save horizontal space.

### Figure 1: "Property Prices at the ZFE Boundary"
**Page:** 10
- **Formatting:** Good. Clean ggplot-style aesthetic. The 95% CI shading is professional.
- **Clarity:** High. The 10-second rule is met: prices are higher inside, but the lines meet at the threshold (null result).
- **Storytelling:** This is the "money plot" of the paper. It perfectly visualizes the main finding.
- **Labeling:** Axis labels are clear. Legend is placed well.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Main Results: Effect of ZFE on Property Prices"
**Page:** 11
- **Formatting:** Standard economics layout. Using "Implied % effect" is a helpful touch for top-tier readers.
- **Clarity:** The transition from Baseline to Controls to Placebo is logical.
- **Storytelling:** Central to the paper's argument. It rules out the effect across specifications.
- **Labeling:** Significance stars and standard errors are correctly documented.
- **Recommendation:** **REVISE**
  - Add a row for "Dependent Variable" at the top (Log Price per m2).
  - Use more descriptive column headers (e.g., "(3) Placebo (2020)").

### Figure 2: "Density of Transactions at ZFE Boundary (McCrary Test)"
**Page:** 13
- **Formatting:** Clean histogram. The dashed line at zero is clear.
- **Clarity:** The mass shift at the boundary is obvious, supporting the author's point about the A86 being a physical barrier.
- **Storytelling:** Crucial for RDD validity. It honestly shows the "failure" of the density test and allows the author to pivot to the Diff-in-Disc strategy.
- **Labeling:** The "McCrary p=0" annotation is clear but could be formatted more professionally (e.g., in a text box or note).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Covariate Balance at ZFE Boundary"
**Page:** 14
- **Formatting:** Simple and clean.
- **Clarity:** The "Status" (PASS/FAIL) column is a bit "hand-holding" for an AER/QJE audience; typically, readers prefer to look at p-values themselves.
- **Storytelling:** Necessary to address the density failure in Figure 2.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Remove the "Status" column.
  - Consider moving this to the Appendix and replacing it with Figure 8 (the coefficient plot version) in the main text, which is more visually striking.

### Table 4: "Heterogeneity by Property Type"
**Page:** 14
- **Formatting:** Professional.
- **Clarity:** The contrast between "Appartement" and "Maison" is stark.
- **Storytelling:** Essential. It shows that the null is driven by apartments and that the "Maison" result is likely underpowered.
- **Recommendation:** **KEEP AS-IS** (Or consolidate into Table 2 as extra columns to save space).

### Figure 3: "ZFE Boundary Effect Over Time"
**Page:** 16
- **Formatting:** Standard event-study/dynamic style.
- **Clarity:** Clear evidence that the 2021 result was a spike rather than a trend.
- **Storytelling:** Important for dismissing the idea that capitalization is just "starting" to happen.
- **Labeling:** Y-axis clearly labeled as "Treatment Effect (log points)".
- **Recommendation:** **KEEP AS-IS**

### Table 5: "ZFE Price Effect by City"
**Page:** 17
- **Formatting:** Clean but redundant.
- **Clarity:** It only shows one city (Paris).
- **Storytelling:** This is very weak as a standalone table since the paper states other city data was unavailable.
- **Recommendation:** **REMOVE** (The text already states the sample is limited to Grand Paris; a one-row table adds no value).

### Table 6: "Robustness Checks"
**Page:** 17
- **Formatting:** Good use of Panel A and Panel B.
- **Clarity:** High.
- **Storytelling:** Good "stress testing" of the result. Panel B (Donut Hole) is particularly important given geocoding error concerns.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Bandwidth Sensitivity"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** Shows the "stability" of the coefficient.
- **Storytelling:** Reassures the reader that the results aren't "p-hacked" based on bandwidth choice.
- **Recommendation:** **MOVE TO APPENDIX** (Standard robustness, but takes up a full page of main text).

### Figure 5: "Placebo Cutoffs"
**Page:** 20
- **Formatting:** Standard RDD placebo plot.
- **Clarity:** The blue dot at 0 compared to the others is the key.
- **Storytelling:** High. It shows the real boundary is no more "special" than random fake boundaries.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 6: "Pre vs. Post ZFE: Property Prices at the Boundary"
**Page:** 30
- **Storytelling:** This is actually a very strong visualization of the Diff-in-Disc logic.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Replace Figure 1 with this, or put it immediately after).

### Figure 7: "Map of Property Transactions Near the Paris ZFE Boundary"
**Page:** 31
- **Storytelling:** Vital for a spatial paper to show the "footprint" of the data.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Ideally in Section 3: Data).

### Figure 8: "Covariate Balance at ZFE Boundary"
**Page:** 32
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Replace Table 3 with this).

### Figure 9: "ZFE Price Effect by City"
**Page:** 33
- **Recommendation:** **REMOVE** (Same reason as Table 5).

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 0 appendix tables, 4 appendix figures.
- **General quality:** The figures are very strong and follow current "Best Practices" for RDD papers (Cattaneo style). The tables are a bit "thin"—Table 5 and Table 1 need consolidation or cleaning.
- **Strongest exhibits:** Figure 1 (Main result), Figure 3 (Dynamics), Figure 6 (Pre/Post comparison).
- **Weakest exhibits:** Table 5 (Redundant), Table 1 (NaN values).
- **Missing exhibits:** 
    1. A **Map of Air Quality** (even if from a model) to show if a pollution discontinuity *should* exist.
    2. A **Table of the Difference-in-Discontinuities** coefficients (only mentioned in text on page 12).

- **Top 3 improvements:**
  1. **Spatial Context:** Move Figure 7 (Map) to the main text. Top journals want to see the geography immediately.
  2. **Table Hygiene:** Clean Table 1 (remove NaNs) and delete the redundant Table 5.
  3. **Visual Balance:** Use Figure 8 (Coefficient plot) for covariate balance instead of Table 3 to make the paper feel less "table-heavy" in the validity section.