# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-11T19:12:43.824513
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1818 out
**Response SHA256:** e5f3edb5fb3c3a68

---

This review evaluates the visual exhibits of "Your Backyard, Your Rules? The Capitalization of Community Planning Power in England" against the standards of top-tier economics journals (AER, QJE, JPE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Clean and professional. Minimalist horizontal lines (top, below headers, bottom) align with AER style. 
- **Clarity:** Excellent. The variables are logically ordered (outcomes first, then treatment indicator).
- **Storytelling:** Provides the necessary scale of the data (5,747 observations). 
- **Labeling:** Variable names are intuitive. Units (GBP 000s) are clearly indicated.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Pre-Treatment Balance (2008–2012)"
**Page:** 12
- **Formatting:** Standard balance table format. 
- **Clarity:** Clear comparison between groups.
- **Storytelling:** Crucial for the identification strategy to show the level differences that necessitate a DiD approach rather than a simple cross-sectional comparison.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Main Results: Effect of Neighbourhood Plans on House Prices"
**Page:** 16
- **Formatting:** Good use of empty space. Decimal alignment is present.
- **Clarity:** The transition from TWFE to CS-DiD (2021) is well-handled across columns.
- **Storytelling:** This is the "money table." It successfully shows that the choice of estimator matters for the coefficient magnitude, even if results remain insignificant.
- **Labeling:** Significance stars are defined. Standard errors are in parentheses. Note specifies the dependent variable.
- **Recommendation:** **REVISE**
  - Add a row for "Mean of Dep. Var." to give context to the coefficient magnitudes.
  - The dash "–" in columns 3 and 4 for FE is technically correct (as CS-DiD uses a different logic), but explicitly stating "N/A (CS-DiD)" or "Included" in the note can prevent reviewer confusion.

### Figure 1: "Event Study: Callaway-Sant’Anna Dynamic Treatment Effects"
**Page:** 17
- **Formatting:** Modern, clean "ggplot2" style. The blue color is professional.
- **Clarity:** The message is clear in <10 seconds: flat pre-trends, slightly positive but insignificant post-trends.
- **Storytelling:** This is the most important figure for establishing the validity of the parallel trends assumption.
- **Labeling:** Y-axis clearly labeled with units (Log Median Price). Reference period (-1) is noted.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Cohort-Specific Treatment Effects"
**Page:** 18
- **Formatting:** Consistent with Figure 1. 
- **Clarity:** Good, though the 2014 CI is very wide, which is visually distracting but honest.
- **Storytelling:** Supports the discussion on early vs. late adopters.
- **Labeling:** X-axis identifies the cohort year clearly.
- **Recommendation:** **MOVE TO APPENDIX** 
  - The main result is a null. While heterogeneity is interesting, this figure is quite "noisy" (large CIs) and doesn't change the primary conclusion. Moving it would tighten the main text.

### Table 4: "Robustness Checks"
**Page:** 19
- **Formatting:** Unusual for a top journal. It's a "summary of results" table rather than a standard regression table.
- **Clarity:** Very high. It's much easier to read than a 6-column regression table.
- **Storytelling:** Effectively hammers home the stability of the null price result and the outlier significance of the transaction volume effect.
- **Labeling:** Detailed "Description" column is helpful.
- **Recommendation:** **REVISE**
  - For a top journal, reviewers usually expect to see the full "Transaction Volume" results in a standard regression table format (like Table 3) because it is a "Striking Result" (as mentioned on page 3). 
  - **Action:** Split the "Log transactions" row out and create a new **Table 5: Effect on Market Activity (Transaction Volume)** in the main text. Keep the rest of the robustness in the appendix or a condensed version of this table.

### Figure 3: "Randomization Inference Distribution"
**Page:** 21
- **Formatting:** Professional histogram. 
- **Clarity:** Very high. The red line vs. distribution is the standard way to show RI.
- **Storytelling:** Strong "nail in the coffin" for the null result.
- **Labeling:** P-value and number of permutations are clearly noted.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 4: "Distribution of Neighbourhood Plan Adoption by Year"
**Page:** 29
- **Formatting:** Clean bar chart.
- **Clarity:** High.
- **Storytelling:** Useful for understanding the "staggered" nature of the treatment.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "House Price Trends: Treated vs. Control Districts"
**Page:** 30
- **Formatting:** Standard "raw trends" plot.
- **Clarity:** The shaded region for the treatment period is excellent practice.
- **Storytelling:** Provides the raw data visual that reviewers always ask for to verify the DiD.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals often want to see the raw data (Figure 5) immediately before or after the Event Study (Figure 1). It builds trust in the data.

### Figure 6: "Event Study: Never-Treated Controls"
**Page:** 31
- **Formatting:** Consistent with Figure 1.
- **Clarity:** High.
- **Storytelling:** Necessary robustness.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Referendum Turnout and Approval Rates"
**Page:** 32
- **Formatting:** Scatter plot with LOESS fit. 
- **Clarity:** The cluster at the top-left is very clear.
- **Storytelling:** Supports the "Broad Support" claim.
- **Recommendation:** **KEEP AS-IS**

---

# Overall Assessment

- **Exhibit count:** 3 main tables, 3 main figures, 0 appendix tables, 4 appendix figures.
- **General quality:** Extremely high. The formatting is "AER-ready" with clean lines, consistent fonts, and a modern aesthetic. The use of modern DiD methods (CS 2021) is well-reflected in the visuals.
- **Strongest exhibits:** Figure 1 (Event Study) and Figure 3 (Randomization Inference).
- **Weakest exhibits:** Table 4 (Too much "summary" style, lacks the raw regression detail for the volume effect).
- **Missing exhibits:** 
    - **A Map:** For a paper about England's geography and localism, a map showing the spatial distribution of treated vs. control districts is almost mandatory for a top journal (QJE/AER).
    - **Full Regression Table for Volume:** Since the volume effect is the only significant result, it needs its own Table 3-style exhibit.

### Top 3 Improvements:
1.  **Add a Spatial Map:** Create a figure showing England's Local Authority Districts, color-coded by adoption year (or treated/control). This grounds the "Geography of Adoption" section (2.4).
2.  **Create a Dedicated Transaction Volume Table:** Elevate the "Log transactions" result from the Table 4 summary into a full regression table with different specifications (TWFE, CS-DiD, etc.) to match Table 3.
3.  **Shuffle for Flow:** Promote Figure 5 (Raw Trends) to the main text to precede the Event Study, and move Figure 2 (Cohort Heterogeneity) to the appendix to keep the main text focused on the primary null result.