# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T22:02:15.867128
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1885 out
**Response SHA256:** db76cf725800a8b9

---

This review evaluates the exhibits of the paper "Who Captures a Tax Cut? Property Price Capitalization from France’s Taxe d’Habitation Abolition" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by Period"
**Page:** 9
- **Formatting:** Clean layout. However, standard errors or counts for the means are missing in the main rows.
- **Clarity:** The comparison between pre- and post-reform is clear, but the "Median property price" row lacks a currency symbol in the label.
- **Storytelling:** Good for establishing the "seam" in the data (2021 shift to transaction-level data), though the jump in mean transactions suggests a change in sample composition that needs careful handling.
- **Labeling:** "TH rate 2017 (%)" is well-labeled. Units for price are missing in the row header.
- **Recommendation:** **REVISE**
  - Add "(€)" to the Median property price label.
  - Include standard deviations for all continuous variables (currently marked as "—").
  - Add a "Difference" column with a t-test to formally show how the sample changed post-2018.

### Figure 1: "Distribution of Communal TH Rates, 2017"
**Page:** 10
- **Formatting:** Professional and clean.
- **Clarity:** Excellent. The reader immediately sees the identifying variation.
- **Storytelling:** Essential. It justifies the continuous DiD approach.
- **Labeling:** Clear axis labels and a helpful median line.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Main Results: Effect of TH Dose on Property Prices"
**Page:** 13
- **Formatting:** Standard LaTeX table style. Numbers are centered but should be decimal-aligned. 
- **Clarity:** Good. It clearly shows the null on aggregate prices vs. the strong effect on apartments.
- **Storytelling:** This is the "money table." However, the contrast between Column 3 and Column 4 is the whole story; it might be better to move Column 5 (Transactions) to the appendix to keep the focus on prices.
- **Labeling:** "TH Dose x Post" is clear. Table notes are comprehensive.
- **Recommendation:** **REVISE**
  - Decimal-align all coefficients and standard errors.
  - Change "Num.Obs." to "Observations."
  - Explicitly state the unit of observation in the notes (Commune-Year).

### Figure 2: "Event Study: Dynamic Effects of TH Dose on Log Median Price"
**Page:** 14
- **Formatting:** Shaded 95% CIs are standard, but the y-axis spans a very small range (0.00 to 0.03), making the pre-trend look "jumpier" than it is.
- **Clarity:** The blue dots are clear. The vertical dashed line at -1 is standard.
- **Storytelling:** This figure shows a null result for *median* prices. Given the paper's finding that the effect is in *apartments*, the main text figure should probably be the apartment-specific event study.
- **Labeling:** "βt (TH Dose x Year)" is a bit technical for a Y-axis; "Effect on Log Price" is more intuitive.
- **Recommendation:** **REVISE**
  - Swap this figure for an event study specifically using the "Apartment price per m2" outcome.
  - Use a solid line for the zero-coefficient baseline.

### Table 3: "Callaway-Sant’Anna Group-Time ATT Estimates"
**Page:** 15
- **Formatting:** Logical but looks a bit like raw software output.
- **Clarity:** High. It confirms the "delayed" story.
- **Storytelling:** Important for robustness against TWFE bias. 
- **Labeling:** "ATT(g,t)" is slightly jargon-heavy.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text is getting heavy with tables. Figure 2 (if updated to show apartments) would tell this story more effectively. This level of granular detail belongs in the appendix.

### Table 4: "Heterogeneity: Property Type and Supply Elasticity"
**Page:** 16
- **Formatting:** Consistent with Table 2.
- **Clarity:** The grouping is logical.
- **Storytelling:** Very strong. It explains *why* the aggregate result is a null.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (but decimal-align numbers).

### Figure 3: "Leave-One-Out Sensitivity: Coefficient by Département Dropped"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** Good for showing stability.
- **Storytelling:** Standard robustness. 
- **Recommendation:** **MOVE TO APPENDIX**
  - Top journals prefer the main text to focus on the "what" and "how," leaving the "is it driven by one outlier" to the appendix.

### Figure 4: "Price Trends by TH Tercile, 2014–2024"
**Page:** 19
- **Formatting:** Colors (Red, Blue, Green) are standard but check for color-blind friendliness (use different dash patterns).
- **Clarity:** The divergence after 2018 is visible but subtle.
- **Storytelling:** Important for the "raw" data look.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Binned Scatter: TH Rate and Price Change"
**Page:** 20
- **Formatting:** The confidence interval (shaded region) is very wide, which visually undermines the "significant" finding.
- **Clarity:** A bit cluttered with the point sizes.
- **Storytelling:** This is a "weak" visual compared to the others. The slope looks almost flat.
- **Recommendation:** **REMOVE**
  - The event study and the tercile trends are much more convincing. This adds noise rather than clarity.

---

## Appendix Exhibits

### Table 5: "Robustness: Alternative Specifications"
**Page:** 30
- **Recommendation:** **KEEP AS-IS** (Standard appendix fare).

### Figure 6: "Supply Elasticity Heterogeneity"
**Page:** 31
- **Recommendation:** **REVISE**
  - This is redundant with Table 4. If the author wants a figure, it should be a bar chart or a more detailed coefficient plot with more categories of density.

### Figure 7: "Normalized Price Trends by TH Tercile (2017 = 100)"
**Page:** 32
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is actually much clearer than Figure 4. By centering on 100 in the year before the reform, the "divergence" becomes immediately obvious to the reader.

---

# Overall Assessment

- **Exhibit count:** 2 main tables (after moves), 3 main figures, 2 appendix tables, 2 appendix figures.
- **General quality:** The tables are standard but need better alignment. The figures are high-quality but the paper currently prioritizes the "Null" aggregate results in its visuals rather than the "Significant" apartment results.
- **Strongest exhibits:** Figure 1 (Distribution) and Figure 7 (Normalized Trends).
- **Weakest exhibits:** Figure 5 (Binscatter) and Table 3 (Too much raw data for main text).
- **Missing exhibits:** 
    1. **A Map:** For a paper on France, a map showing the geographic distribution of TH rates (treatment intensity) is almost mandatory for a top journal.
    2. **Event Study for Apartments:** Since the paper's core claim is about apartments, Figure 2 should be replaced with its apartment-only counterpart.

**Top 3 Improvements:**
1.  **Prioritize the "Normalized" Trends:** Replace Figure 4 with Figure 7 in the main text; it makes the divergence much easier to see.
2.  **Align Table Formatting:** Decimal-align all numbers in Tables 1, 2, and 4 to meet AER/QJE professional standards.
3.  **Add Geographic Context:** Include a map of France showing communal TH rates to demonstrate that the treatment dose isn't just a "Paris vs. the rest" or "North vs. South" proxy.