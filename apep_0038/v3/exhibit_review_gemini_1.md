# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (vertex)
**Paper:** paper.pdf
**Timestamp:** 2026-02-09T15:13:52.031651
**Route:** Direct Google API + PDF
**Tokens:** 18693 in / 2113 out
**Response SHA256:** bdf490a7992430a9

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Gambling Industry Employment (NAICS 7132)"
**Page:** 24
- **Formatting:** Clean and professional. Use of horizontal rules is consistent with top-tier journals. Numbers are well-aligned.
- **Clarity:** Excellent. The grouping into Sample Composition, Employment Statistics, and Pre-Treatment Balance is logical and easy to digest.
- **Storytelling:** Essential. It establishes the comparability of treated and control states.
- **Labeling:** Clear. Table notes define the sample and the "always-treated" exclusion correctly.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Sports Betting Legalization Timeline"
**Page:** 25
- **Formatting:** Simple and effective. Standard journal layout.
- **Clarity:** High. It allows the reader to quickly verify the staggered adoption timing and the split between mobile/retail.
- **Storytelling:** Useful for transparency, though some journals might prefer this in the appendix if space is tight. For this paper, it justifies the DiD variation.
- **Labeling:** Clearly identifies the "N" and the mobile betting count.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Sports Betting Legalization on Gambling Industry Employment"
**Page:** 25
- **Formatting:** Excellent. Significance stars, standard errors in parentheses, and confidence intervals in brackets follow AER/QJE conventions perfectly.
- **Clarity:** Very clean. The juxtaposition of CS and TWFE estimators is standard for modern DiD papers.
- **Storytelling:** This is the "money" table. It successfully proves the null across various specifications.
- **Labeling:** Detailed notes. Significance levels (*, **, ***) are clearly defined.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Event Study: Employment Effects of Sports Betting Legalization"
**Page:** 29
- **Formatting:** Professional ggplot2 style. Confidence bands are transparent, and the zero line is distinct.
- **Clarity:** High. The 10-second takeaway (a flat line around zero) is unmistakable.
- **Storytelling:** Crucial. It validates the parallel trends assumption visually.
- **Labeling:** Axis labels are clear. The title in the caption is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Pre-Treatment Trends by Cohort"
**Page:** 30
- **Formatting:** Good use of distinct colors for cohorts. No excessive gridlines.
- **Clarity:** A bit cluttered due to the number of cohorts. The "dip" around 2020 (COVID) is very visible across all cohorts.
- **Storytelling:** Important for showing raw data trends, but redundant with Figure 1's aggregated test.
- **Labeling:** Legend is clear. 
- **Recommendation:** **MOVE TO APPENDIX** — The main text should focus on the causal estimates (Fig 1). The raw cohort trends are supporting evidence for the appendix.

### Figure 3: "Sports Betting Legalization Timeline" (Map)
**Page:** 30
- **Formatting:** Standard US map. Colors are distinguishable.
- **Clarity:** Good. Provides a spatial sense of the policy adoption.
- **Storytelling:** Largely decorative/descriptive. It doesn't prove the causal effect but helps with context.
- **Labeling:** Legend is well-placed.
- **Recommendation:** **REVISE** — If this stays in the main text, consider moving it to the Introduction or Data section rather than the Results section to aid flow.

---

## Appendix Exhibits

### Table 4: "Event Study Estimates: Dynamic Treatment Effects"
**Page:** 26
- **Formatting:** Standard table format.
- **Clarity:** Good. Provides the underlying numbers for Figure 1.
- **Storytelling:** Necessary for completeness, but standard practice is to keep the figure in the main and the table in the appendix.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (as an appendix exhibit).

### Table 5: "Heterogeneity in Treatment Effects"
**Page:** 26
- **Formatting:** Professional.
- **Clarity:** Clean.
- **Storytelling:** Groups the three most important heterogeneity checks.
- **Labeling:** Definitions in notes are helpful.
- **Recommendation:** **PROMOTE TO MAIN TEXT** — This is a major part of the "story" (the mobile vs. retail distinction). It should be in the main results section.

### Table 6: "Robustness Checks"
**Page:** 27
- **Formatting:** Professional.
- **Clarity:** High. Summarizes multiple complex regressions in one view.
- **Storytelling:** Vital for establishing the stability of the null result.
- **Labeling:** Clearly noted.
- **Recommendation:** **PROMOTE TO MAIN TEXT** — Top journals want to see the "stability" table in the main body.

### Table 7: "HonestDiD Sensitivity Analysis (Rambachan-Roth)"
**Page:** 27
- **Formatting:** Clear.
- **Clarity:** Excellent for a technical table.
- **Storytelling:** Important for modern DiD papers to show the result holds even with some trend violation.
- **Labeling:** Notes explain the "M" parameter well.
- **Recommendation:** **KEEP AS-IS** (in appendix).

### Table 8: "Placebo Tests: Unrelated Industries"
**Page:** 27
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Simple but effective evidence for identification.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (in appendix).

### Table 9: "Effect of Sports Betting Legalization on Gambling Industry Wages"
**Page:** 28
- **Formatting:** Professional.
- **Clarity:** Good.
- **Storytelling:** Secondary outcome.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (in appendix).

### Table 10: "Spillover Effects: Neighbor Legalization and Employment"
**Page:** 28
- **Formatting:** Standard TWFE table.
- **Clarity:** Good.
- **Storytelling:** This is one of the more interesting "suggestive" results in the paper (the -786 coefficient).
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT** — The spillover argument is a key "Discussion" point (Section 9.2). Having the evidence in the main text supports that argument.

### Figure 4: "Employment Effects by Betting Type"
**Page:** 31
- **Formatting:** Good use of dual panels/colors.
- **Clarity:** The overlap in confidence intervals is clear.
- **Storytelling:** Visual version of Table 5.
- **Recommendation:** **KEEP AS-IS** (in appendix).

### Figure 5: "Robustness of Main Result" (Coefficient Plot)
**Page:** 31
- **Formatting:** Excellent "whisker plot." This is very common in AEJ/AER papers.
- **Clarity:** High. Shows stability at a glance.
- **Storytelling:** Visual version of Table 6.
- **Recommendation:** **PROMOTE TO MAIN TEXT** — A coefficient plot is often more impactful than a robustness table for a general audience.

### Figure 6: "Leave-One-Out Sensitivity (All Treated States)"
**Page:** 32
- **Formatting:** Good use of sorting by estimate magnitude.
- **Clarity:** Excellent. Shows New Jersey as an outlier without breaking the null.
- **Storytelling:** Important for "bulletproofing" the result.
- **Recommendation:** **KEEP AS-IS** (in appendix).

### Figure 7: "Wage Event Study"
**Page:** 33
- **Formatting:** Consistent with Figure 1.
- **Clarity:** High.
- **Storytelling:** Supporting evidence for the wage null.
- **Recommendation:** **KEEP AS-IS** (in appendix).

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 3 main figures, 7 appendix tables, 4 appendix figures.
- **General quality:** Extremely high. The exhibits are formatted to the specific standards of top-tier economics journals. The use of modern DiD diagnostics (HonestDiD, Callaway-Sant'Anna, Leave-one-out) is visually well-supported.
- **Strongest exhibits:** Table 3 (Primary Results) and Figure 1 (Event Study).
- **Weakest exhibits:** Figure 2 (Pre-Trends by Cohort) is a bit messy and less informative than the event study.
- **Missing exhibits:** A table showing **Industry Handle/Revenue growth** over time would be a powerful "counter-exhibit" to show alongside the flat employment line. It would visually prove that the industry *is* growing while employment is *not*.

**Top 3 improvements:**
1. **Strategic Promotion:** Move Table 5 (Heterogeneity), Figure 5 (Robustness Plot), and Table 10 (Spillovers) to the main text. Currently, the main text is a bit "light" on exhibits while the appendix is "heavy."
2. **The "Scale" Exhibit:** Add a figure showing the massive growth in Sports Betting Handle (Revenue) vs. the flat line of employment. This directly addresses the paper's core paradox.
3. **Consolidation:** Move Figure 2 and Figure 3 to the appendix to keep the main text focused on causal inference rather than raw data/descriptive geography.