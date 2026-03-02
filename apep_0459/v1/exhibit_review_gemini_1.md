# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T12:56:17.723523
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 1954 out
**Response SHA256:** c643ea61732ccf2e

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Skills-Based Hiring Policy Adoption Dates"
**Page:** 7
- **Formatting:** Clean and professional. Use of the dagger (†) for data availability is a nice touch.
- **Clarity:** High. Staggered timing is easily parsed.
- **Storytelling:** Essential. It establishes the "treatment" variation central to the paper.
- **Labeling:** Clear. The note explaining the "First Treat" logic (adoption month $\le$ 6) is critical and well-placed.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Pre-Treatment Summary Statistics: State Government Employees"
**Page:** 9
- **Formatting:** Standard AER style. Numbers are properly aligned.
- **Clarity:** Excellent. The 2-column comparison (Treated vs. Never-Treated) immediately shows the lack of large baseline imbalances.
- **Storytelling:** Necessary to satisfy the "balance" requirement of DiD papers.
- **Labeling:** Units ($, %, N) are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Skills-Based Hiring Laws on State Government Workforce Composition"
**Page:** 14
- **Formatting:** Good use of parentheses for SEs. Significance stars are missing from the table body but defined in the notes—this is a minor inconsistency.
- **Clarity:** The comparison of TWFE, CS, and SA across columns is the standard way to present modern DiD results.
- **Storytelling:** This is the "Money Table." It consolidates the primary null results.
- **Labeling:** The dependent variable is clearly stated.
- **Recommendation:** **REVISE**
  - Add significance stars to the coefficients in the table body to match the note's definition.
  - Decimal-align all coefficients and standard errors for easier vertical scanning.

### Figure 1: "Event Study: Skills-Based Hiring Laws and Share of State Government Workers Without BA"
**Page:** 14
- **Formatting:** Professional ggplot2/Stata style. 
- **Clarity:** The message is clear: the pre-trend at $e=-3$ is problematic.
- **Storytelling:** Essential for the paper's argument that the laws were endogenous responses to trends.
- **Labeling:** Y-axis needs more descriptive units. "ATT (Share Without BA)" is okay, but "Change in Share (Percentage Points)" would be more intuitive for a general reader.
- **Recommendation:** **REVISE**
  - Change y-axis label to "Effect on Non-BA Share (Percentage Points)".
  - Add a horizontal dashed line at $y=0$ (it's there, but faint).

### Figure 2: "Share of State Government Workers Without BA: Treated vs. Never-Treated States"
**Page:** 15
- **Formatting:** High quality. Shaded CIs are transparent and don't obscure the lines.
- **Clarity:** Shows the "Parallel-ish" trends before the 2018 divergence.
- **Storytelling:** Provides the raw data context for Figure 1.
- **Labeling:** Clear title and legend.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Robustness Checks and Heterogeneity"
**Page:** 16
- **Formatting:** Logical panel structure (A, B, C).
- **Clarity:** High. It packs a lot of information (placebos, heterogeneity, demographics) without feeling cluttered.
- **Storytelling:** Effectively "unpacks" the null result. Panel B is particularly strong for the "Mandate" argument.
- **Labeling:** Column headers (Coefficient, Std. Error, p-value) are standard.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Heterogeneity by Policy Strength Among Treated States"
**Page:** 17
- **Formatting:** Clean.
- **Clarity:** Shows the "Strong" vs "Moderate" trend difference clearly.
- **Storytelling:** Supports Panel B of Table 4. However, having both the table and the figure for the same result might be overkill for the main text.
- **Labeling:** Descriptive.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text is becoming visual-heavy. Table 4 already carries the statistical weight of this point.

### Figure 4: "Triple-Difference: State Government vs. Private Sector by Treatment Group"
**Page:** 18
- **Formatting:** Multi-paneled layout is effective.
- **Clarity:** The comparison of the "wedge" (or lack thereof) is intuitive.
- **Storytelling:** This is the most convincing visual evidence for the null effect, as it controls for state-level shocks.
- **Labeling:** Excellent. The annotation "If policy drives the effect, divergence should appear only in treated states..." is a great "reader-friendly" addition.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Share of Black Workers in State Government: Treated vs. Never-Treated States"
**Page:** 20
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Clearly shows no trend break.
- **Storytelling:** Important for the "Diversity" policy goal discussion.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - Table 4 Panel C already reports the null for Black workers. This figure is a secondary "visual check."

### Figure 6: "Staggered Adoption of Skills-Based Hiring Laws, 2022–2025"
**Page:** 21
- **Formatting:** Excellent "event plot" or "timeline plot."
- **Clarity:** Very high. Categorizing by Strength and Type using shapes/colors is effective.
- **Storytelling:** It makes the "policy cascade" mentioned in the intro tangible. 
- **Labeling:** Excellent.
- **Recommendation:** **KEEP AS-IS** (But move it earlier in the paper, perhaps near Table 1).

---

## Appendix Exhibits

### Table 5: "Variable Definitions"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** — Vital for transparency.

### Table 6: "Bacon Decomposition of TWFE Estimate"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** — Standard requirement for modern DiD papers to address the "weights" issue.

### Table 7: "Sun-Abraham Interaction-Weighted Estimator: Full Coefficients"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** — Good to show the full lead/lag structure that Figure 1 summarizes.

### Figure 7: "Raw Trends in Non-BA Share: Treated vs. Never-Treated States (Reproduced)"
**Page:** 34
- **Recommendation:** **REMOVE**
  - It is an exact duplicate of Figure 2. There is no need to reproduce it in the appendix "for convenience" in a digital PDF; it just adds bulk.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 6 main figures, 3 appendix tables, 1 appendix figure (reproduced).
- **General quality:** The exhibits are exceptionally high quality, following the modern "visual DiD" toolkit used in top journals. The figures are clean and the tables follow proper typesetting conventions.
- **Strongest exhibits:** Figure 4 (DDD Visual) and Table 4 (Heterogeneity/Placebo).
- **Weakest exhibits:** Figure 7 (Redundant) and Table 3 (Missing significance stars in body).
- **Missing exhibits:** 
  - **A "Flow" Figure/Table:** The author discusses "Stock vs. Flow" in the text. An exhibit showing the share of *new hires* (if data allows) or at least a tenure-based breakdown (hired in last 2 years vs earlier) would be a "home run" for a top journal.
  - **Map of Adoption:** A simple U.S. map shaded by adoption year/strength is often expected in policy papers to show geographic clustering.

### Top 3 Improvements:
1.  **Streamline the Main Text:** Move Figure 3 and Figure 5 to the appendix. The paper currently has 10 main text exhibits; reducing this to 7 or 8 will make the "Storytelling" punchier and less repetitive (since the tables already cover these points).
2.  **Fix Table 3 Annotations:** Ensure significance stars are in the table body. Top-tier editors expect the "stars" to do the quick-scan work.
3.  **Enhance Figure 1 (Event Study):** Improve the Y-axis label to be more intuitive (Percentage Points) and consider adding the p-value for the pre-trend test directly onto the plot.