# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T20:48:05.646751
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 1915 out
**Response SHA256:** 1a414bddc8487064

---

# Exhibit-by-Exhibit Review

This review evaluates the exhibits in "When Revenue Falls, Branches Follow" for submission to top-tier economics journals (AER, QJE, etc.).

---

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Generally clean. However, the alignment of decimals in the "Mean" and "(SD)" columns is slightly off; they should be strictly decimal-aligned. The use of horizontal rules is appropriate.
- **Clarity:** Excellent. Splitting by pre/post period allows for immediate comparison of secular trends.
- **Storytelling:** Essential. It establishes the scale of the "typical" county and shows the variation in Durbin Exposure (SD of 0.27 on a mean of 0.35).
- **Labeling:** Clear. Note includes source and explains "Banking Emp. per 100K."
- **Recommendation:** **KEEP AS-IS** (with minor decimal alignment tweaks).

### Table 2: "Effect of Durbin Exposure on Banking Outcomes"
**Page:** 14
- **Formatting:** Professional. Standard errors are correctly placed in parentheses.
- **Clarity:** Good, but the headers are redundant. Having both the variable name `log_branches_pc` and the label "Log Branches/cap" is unnecessary. Keep only the human-readable label.
- **Storytelling:** This is the "money table" of the paper. It shows the sharp contrast between Column 1 (significant decline) and Columns 2-3 (precise nulls).
- **Labeling:** Clear. Significance stars are well-defined.
- **Recommendation:** **REVISE**
  - Remove the raw variable names (e.g., `log_bank_emp`) from the column headers; use only the descriptive labels.
  - Report $p$-values for the null results in the text or as a footnote to emphasize the precision of the zero.

### Figure 1: "Event Study: Effect of Durbin Exposure on Banking Employment"
**Page:** 15
- **Formatting:** High quality. The shaded 95% CI is clean. Gridlines are appropriately subtle.
- **Clarity:** The message—a precise null with no pre-trend—is visible in seconds.
- **Storytelling:** Central to the paper’s argument for parallel trends.
- **Labeling:** The y-axis label is a bit repetitive. "Coefficient on Durbin Exposure × Year" is sufficient without the subtitle.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Study: Effect of Durbin Exposure on Bank Branches"
**Page:** 16
- **Formatting:** Consistent with Figure 1. 
- **Clarity:** Shows a very clear "breaking point" at 2011, though the 2005-2006 pre-trend is visually obvious.
- **Storytelling:** Crucial "first stage" evidence. 
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS** (The V-shape pre-trend is a content issue, not a visual one).

### Table 3: "Triple-Difference: Banking vs. Non-Banking Employment"
**Page:** 17
- **Formatting:** Standard. 
- **Clarity:** Single column table. While clear, it feels like it wastes space.
- **Storytelling:** This is a robustness check to the main result.
- **Labeling:** Note is comprehensive.
- **Recommendation:** **REVISE**
  - Consider moving this into Table 2 as a new column or a Panel B to allow the reader to compare the DiD and DDD estimates in one place.

### Table 4: "Deposit Reallocation Following Durbin Amendment"
**Page:** 18
- **Formatting:** Journal-ready.
- **Clarity:** Logical progression from Durbin-affected to Exempt banks.
- **Storytelling:** Provides a mechanism/counter-argument to the "reallocation" hypothesis.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Banking Employment per Capita: High vs. Low Durbin Exposure Counties"
**Page:** 18
- **Formatting:** Clean line plot.
- **Clarity:** Effectively shows that both groups follow the same secular decline.
- **Storytelling:** Good for a "raw data" look, though the event study (Fig 1) is more rigorous. 
- **Labeling:** "Index (2005=100)" is clearly labeled.
- **Recommendation:** **MOVE TO APPENDIX** (This is a visual "sanity check" but less informative than Figure 1).

### Figure 4: "Placebo Tests: Durbin Exposure Effect by Sector"
**Page:** 19
- **Formatting:** Categorical dot-and-whisker plot. Very clean.
- **Clarity:** Excellent. Immediately shows that Banking is the outlier (or rather, the only one not showing positive growth).
- **Storytelling:** Strong robustness evidence against local demand shocks.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 5: "Placebo Tests: Non-Banking Sectors"
**Page:** 20
- **Formatting:** Consistent with main tables.
- **Clarity:** Good.
- **Storytelling:** The tabular version of Figure 4. 
- **Recommendation:** **KEEP AS-IS** (Redundant with Figure 4, but standard to have the table in the appendix).

### Table 6: "Robustness: Alternative Specifications"
**Page:** 21
- **Formatting:** The scientific notation ($6.2 \times 10^{-5}$) is unusual for econ tables.
- **Clarity:** Good comparison of coefficients.
- **Recommendation:** **REVISE**
  - Change $6.2 \times 10^{-5}$ to `0.000` to maintain decimal consistency with other columns.

### Figure 5: "Leave-One-State-Out Sensitivity Analysis"
**Page:** 21
- **Formatting:** Standard "dot plot."
- **Clarity:** Shows the stability of the estimate.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Clustering Sensitivity"
**Page:** 22
- **Formatting:** Simple and clean.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Distribution of County-Level Durbin Exposure"
**Page:** 29
- **Formatting:** Histogram is well-scaled.
- **Clarity:** Highlights the mass at zero (community-bank counties).
- **Storytelling:** Important for understanding where the identification comes from.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Place near Section 5.5. It helps the reader understand the "Exposure" variable immediately).

### Figure 7: "National Trends in Bank Branches and Banking Employment"
**Page:** 30
- **Formatting:** Good use of dual-line indexing.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Deposit Share of Durbin-Exempt Banks by Exposure Group"
**Page:** 31
- **Clarity:** The flat lines show the persistence of bank-county relationships.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 4 main figures, 3 appendix tables, 4 appendix figures.
- **General quality:** Extremely high. The figures use a consistent, modern aesthetic (likely `ggplot2`) that looks professional and uncluttered.
- **Strongest exhibits:** Figure 1 (Event Study) and Figure 4 (Placebo Dot Plot).
- **Weakest exhibits:** Table 3 (Empty space) and Figure 3 (Secondary to Figure 1).
- **Missing exhibits:** A **Map of Durbin Exposure** across U.S. counties. In a Bartik/spatial paper, a heat map is standard for AER/QJE to show if exposure is purely regional (e.g., just the "Rust Belt") or truly idiosyncratic.

### Top 3 Improvements:
1.  **Add a Geographic Heat Map:** Show the 2010 Durbin Exposure by county. This validates the "Bartik" variation visually.
2.  **Consolidate Table 3:** Merge the Triple-Difference result into Table 2. This creates a "Master Results" table that is much more impactful.
3.  **Refine Table Headers:** Remove raw Stata/R variable names from the tops of tables. Replace them with clean, centered labels (e.g., "Log Employment").