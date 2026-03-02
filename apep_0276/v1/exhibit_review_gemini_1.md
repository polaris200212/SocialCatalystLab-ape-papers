# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-13T13:30:16.740314
**Route:** Direct Google API + PDF
**Tokens:** 16837 in / 2180 out
**Response SHA256:** d3fc7ceb5ff982f7

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 8
- **Formatting:** Generally professional, but the "Mean Cell Size" and "State-Year Cells" columns are slightly crowded. The use of Panel A and B is standard for top journals.
- **Clarity:** Good. It clearly differentiates between the racial groups and treatment status.
- **Storytelling:** Essential. It establishes the baseline participation gaps (White turnout > Black turnout) and the sample size. 
- **Labeling:** Clear. Note explains the exclusion of reversal states and the definition of cell size.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Felon Voting Rights Restoration: Treatment Timing"
**Page:** 11
- **Formatting:** Clean layout. 
- **Clarity:** High. This is a very useful reference for a staggered DiD paper.
- **Storytelling:** Crucial for transparency in policy papers. It allows the reader to verify the "treatment" definitions.
- **Labeling:** Includes source notes and specific coding rules.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Staggered Adoption of Felon Voting Rights Restoration, 1996–2024"
**Page:** 12
- **Formatting:** Map is clean. Legend is well-positioned.
- **Clarity:** Good visual of geographic variation. However, the colors for "Early" and "Middle" reform are both shades of blue/teal that might be hard to distinguish in grayscale or for colorblind readers.
- **Storytelling:** Shows the "rollout" is not purely a regional (e.g., Southern) phenomenon, which helps the identification argument.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Use a more distinct color palette (e.g., Viridis or a sequential multi-hue scale) to ensure the timing cohorts are visually distinct.

### Figure 2: "Treatment Rollout Timeline by State and Reform Type"
**Page:** 13
- **Formatting:** Professional "dot plot" style.
- **Clarity:** Excellent. It combines timing with the *type* of reform (ballot vs. executive vs. legislative).
- **Storytelling:** It illustrates the 2020 "surge" in reforms mentioned in the text.
- **Labeling:** Clear axes and legend.
- **Recommendation:** **KEEP AS-IS** (Though redundant with Table 2, top journals often allow both for visual impact).

### Figure 3: "Voter Turnout by Race and Reform Status, 1996–2024"
**Page:** 14
- **Formatting:** The "sawtooth" pattern of presidential/midterm cycles is very busy.
- **Clarity:** Cluttered. Four lines on one plot with heavy oscillation makes it hard to see the "divergence" the author claims in the text.
- **Storytelling:** Aims to show raw trends, but the election cycle noise overwhelms the treatment effect.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - Consider adding a version that "residuals out" the year fixed effects or presents presidential and midterm years as separate panels/lines to smooth the visualization.

### Figure 4: "Black-White Voter Turnout Gap by Reform Status, 1996–2024"
**Page:** 15
- **Formatting:** Good use of confidence intervals.
- **Clarity:** Much clearer than Figure 3 because it collapses race into a single "gap" measure.
- **Storytelling:** This is the "raw data" version of the main result. It shows the gap widening in reform states post-2016.
- **Labeling:** Y-axis clearly labeled "pp" (percentage points).
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Felon Voting Rights Restoration on the Black-White Participation Gap"
**Page:** 16
- **Formatting:** AER-style. Standard errors in parentheses. Significance stars used correctly. 
- **Clarity:** High. Column (1) vs (2) contrast is the "money shot" of the paper (Turnout vs. Registration).
- **Storytelling:** Central to the paper. It shows the "Registered but Not Voting" paradox.
- **Labeling:** Comprehensive. Defines the unit of observation and the meaning of the interaction term.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Event Study: Effect of Rights Restoration on Black-White Turnout Gap"
**Page:** 17
- **Formatting:** Clean. Reference period ($t-1$) is correctly omitted.
- **Clarity:** The 95% CI is quite wide post-treatment.
- **Storytelling:** This is the most "honest" exhibit. It shows that while the DD is significant, the event study is noisy, which the author transparently discusses.
- **Labeling:** "Election Cycles Relative to Reform" is a good x-axis choice.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Event Study Coefficients: Callaway-Sant’Anna Estimator"
**Page:** 18
- **Formatting:** Standard.
- **Clarity:** High. 
- **Storytelling:** Redundant with Figure 5. Most top journals prefer the figure in the main text and this table in the appendix.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 5: "Triple-Difference Mechanism Test: Community Spillovers vs. Direct Effects"
**Page:** 19
- **Formatting:** Good use of column headers to define samples.
- **Clarity:** Complex. The "triple" coefficient is the key, but the table carries many lower-order terms.
- **Storytelling:** This table is the "Checkmate" for the "Civic Chill" theory. 
- **Labeling:** Note clearly defines "Low-risk" and "High-risk."
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Turnout by Race and Felony-Risk Subgroup in Reform States"
**Page:** 20
- **Formatting:** Again, the election cycle oscillation makes this hard to read.
- **Clarity:** Too many dashed/solid lines of similar colors (blue/teal and pink/orange).
- **Storytelling:** Important for showing that the "Low-risk" group (the spillover test) doesn't change behavior.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Similar to Figure 3, consider a "Gap" version of this figure (Low-Risk Gap vs High-Risk Gap) to reduce the number of lines and focus on the *relative* changes.

### Table 6: "Robustness Checks"
**Page:** 21
- **Formatting:** "Coefficient-per-row" style is excellent for summary.
- **Clarity:** Very high.
- **Storytelling:** Efficiently disposes of 8 potential critiques in one small space.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Robustness: Black × Post-Reform Coefficient Across Specifications"
**Page:** 22
- **Formatting:** Professional "whisker plot."
- **Clarity:** Excellent. Visually confirms the stability of the -0.037 estimate.
- **Storytelling:** Strong closing visual.
- **Labeling:** Clearly shows the "Registration Outcome" as the outlier.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Placebo Test: Hispanic-White Voter Turnout Gap by Reform Status"
**Page:** 23
- **Formatting:** Consistent with Figure 4.
- **Clarity:** Good.
- **Storytelling:** Essential "falsification" test.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** (The result is a "null" and already summarized in Table 6/Figure 7).

---

## Appendix Exhibits
*Note: The author states in Section D (page 30) that there are no additional figures or tables beyond those in the main text.*

---

## Overall Assessment

- **Exhibit count:** 5 main tables (Table 4 moved), 5 main figures (Figure 8 moved), 2 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper follows modern "Staggered DiD" best practices (Callaway & Sant’Anna). Tables are QJE-ready. Figures are good but suffer from the natural "noise" of US biennial election cycles.
- **Strongest exhibits:** Table 3 (The core finding) and Figure 7 (Visual robustness).
- **Weakest exhibits:** Figure 3 and Figure 6 (The "spaghetti" line charts with too much oscillation).
- **Missing exhibits:** 
  1. **A State-Level Map of "Felony Risk":** A map showing which states have the highest Black disenfranchisement rates *prior* to reform would help justify the "Civic Chill" mechanism's relevance.
  2. **Event Study for Registration:** Since registration is the only positive result, an event study for *Registration* (matching Figure 5) is a glaring omission.

- **Top 3 improvements:**
  1. **Add a Registration Event Study:** To mirror Figure 5, show that the +2.3pp registration effect isn't driven by pre-trends.
  2. **Simplify Figures 3 and 6:** Convert these into "Gap" plots (Black minus White) to remove the distracting election-cycle oscillation.
  3. **Move Redundancies to Appendix:** Move Table 4 (Event Study Coefficients) and Figure 8 (Hispanic Placebo) to the Appendix to tighten the main narrative.