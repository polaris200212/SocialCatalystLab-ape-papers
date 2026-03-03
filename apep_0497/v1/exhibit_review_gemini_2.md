# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T22:34:10.952911
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 1950 out
**Response SHA256:** 837b40a5e7f21916

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by Period"
**Page:** 9
- **Formatting:** Clean and professional. Uses standard booktabs-style horizontal lines. Decimal points are mostly aligned, but "Sales per commune-year" and "Median property price" have varying digits that make the columns look slightly uneven.
- **Clarity:** Good. The split between Pre and Post mean/SD is logical for a DiD paper.
- **Storytelling:** Essential. It establishes the scale of the housing market and the variation in the treatment variable (TH rate).
- **Labeling:** Clear. Units (euros, %, etc.) are included. The note is comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Communal TH Rates, 2017"
**Page:** 10
- **Formatting:** Professional. Gridlines are subtle. The red dashed line for the median is a helpful touch.
- **Clarity:** Very high. Immediately shows the "dose" variation that drives the paper's identification.
- **Storytelling:** Strong. It justifies the use of a continuous treatment by showing the broad, smooth distribution of tax rates.
- **Labeling:** Axis labels are clear. Legend/Note is concise.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Main Results: Effect of TH Dose on Property Prices"
**Page:** 13
- **Formatting:** Standard journal format. Standard errors are correctly in parentheses.
- **Clarity:** Good, but Column (4) is the "star" of the paper (apartments) yet it's buried in the middle of a table where the first three columns show null results for the aggregate market.
- **Storytelling:** This table is trying to do too much. It combines the "failed" aggregate results with the "successful" apartment results and a secondary "transaction volume" result.
- **Labeling:** Definition of stars is present. Significance levels are clear.
- **Recommendation:** **REVISE**
  - **Specific changes:** Move Column (4) (Apartments) to a new Table 2 focused specifically on the headline results (Apartments vs. Houses). Keep the aggregate/volume results in a separate "Table 3: Aggregate and Extensive Margin Results." This highlights the paper's main contribution (the apartment/house contrast) more effectively.

### Figure 2: "Event Study: Dynamic Effects of TH Dose on Apartment Prices per m2"
**Page:** 14
- **Formatting:** Standard event study plot. The shaded 95% CI is clear.
- **Clarity:** High. The 10-second takeaway is obvious: flat pre-trend, significant and growing post-treatment effect.
- **Storytelling:** This is the most important visual in the paper. It proves parallel trends and shows the "delayed capitalization" narrative perfectly.
- **Labeling:** Clear axis labels. Note explains the omitted period.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Event Study: Dynamic Effects of TH Dose on Log Median Price (Overall)"
**Page:** 15
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Clear, though the y-axis scale is much smaller than Figure 2, which might confuse a quick reader.
- **Storytelling:** Important as a contrast to Figure 2. It shows why the aggregate data masks the real effect.
- **Labeling:** The y-axis label is a bit cluttered ($\beta_t$ (TH Dose $\times$ Year)).
- **Recommendation:** **MOVE TO APPENDIX**
  - The aggregate null is well-explained in text/tables. The main text should focus on the apartment vs. house discovery.

### Table 3: "Two-Group DiD: High-Dose versus Low-Dose Communes"
**Page:** 16
- **Formatting:** Unusual for a main text table. It's essentially a list of coefficients that would be better served by a figure.
- **Clarity:** Low. Reading a list of 10+ coefficients and CIs is taxing compared to a plot.
- **Storytelling:** Redundant with the event study figures.
- **Labeling:** Sufficient.
- **Recommendation:** **REMOVE**
  - All the information here is better captured by the event study figures. If the author wants to keep the "Overall Average" row, it can be a single line in a results table.

### Table 4: "Heterogeneity: Property Type and Supply Elasticity"
**Page:** 17
- **Formatting:** Professional.
- **Clarity:** The "Dense" and "Sparse" columns are for the median price (aggregate), while the next columns are for specific property types. This is confusing. 
- **Storytelling:** This table is the "Mechanism" table. It should be the heart of the paper.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Specific changes:** Split this into Panel A (Property Type: Apartments vs Houses) and Panel B (Supply Elasticity: Dense vs Sparse). Ensure both panels use the same outcome variable (or explain clearly why they don't) to allow for direct comparison.

### Figure 4: "Normalized Price Trends by TH Tercile (2017 = 100)"
**Page:** 20
- **Formatting:** Excellent. Color-coded lines for terciles are very effective.
- **Clarity:** Extremely high. This is the "raw data" version of the event study.
- **Storytelling:** Essential. It shows the reader that the "High TH" group actually pulled away from the others in raw index terms.
- **Labeling:** Perfect.
- **Recommendation:** **KEEP AS-IS** (Consider promoting to much earlier in the paper to establish the "raw" pattern before regressions).

---

## Appendix Exhibits

### Table 5: "Robustness: Alternative Specifications"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** (Standard appendix content).

### Figure 5: "Leave-One-Out Sensitivity: Coefficient by Département Dropped"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** (Very strong robustness visual).

### Figure 6: "Supply Elasticity Heterogeneity"
**Page:** 32
- **Recommendation:** **REMOVE**
  - This is a redundant visualization of the first two columns of Table 4. The point estimates are so similar and insignificant that the visual doesn't add value.

### Table 6: "Welfare Decomposition: Key Parameters"
**Page:** 33
- **Recommendation:** **KEEP AS-IS** (Crucial for transparency of the Section 7 calculations).

### Figure 7: "Raw Price Trends by TH Tercile, 2014–2024"
**Page:** 34
- **Recommendation:** **KEEP AS-IS** (Provides the non-indexed level data).

### Figure 8: "Binned Scatter: TH Rate and Price Change"
**Page:** 35
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This "binscatter" is a standard requirement for top journals now. It shows the cross-sectional relationship very clearly and would be a great "Figure 2" after the distribution plot.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 4 main figures, 2 appendix tables, 4 appendix figures.
- **General quality:** High. The paper uses modern empirical visualizations (event studies, binscatters, tercile trends) that would be very welcome at AER or QJE.
- **Strongest exhibits:** Figure 2 (Apartment Event Study) and Figure 4 (Tercile Trends).
- **Weakest exhibits:** Table 3 (Table of coefficients) and Figure 3 (Aggregate Event Study).
- **Missing exhibits:** A **Map** showing the spatial distribution of the treatment (TH rates in 2017) across France. This is standard for papers using regional variation and helps the reader understand if the "dose" is clustered (e.g., only in the South).

**Top 3 improvements:**
1.  **Refactor the Main Results:** Merge the key columns of Table 2 and Table 4 into a single, powerful "Table 2" that shows the contrast between Apartments and Houses. This is the paper's "Aha!" moment.
2.  **Add a Treatment Map:** Create a geographic heat map of 2017 TH rates to show the variation is truly national and not driven by a single region (e.g., Paris vs. the rest).
3.  **Visual Consolidation:** Replace the text-heavy Table 3 with the Binscatter (Figure 8) in the main text. A binscatter is much more convincing to a reviewer than a table of coefficients for a continuous DiD.