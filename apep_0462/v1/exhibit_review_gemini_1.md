# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T16:08:52.416216
**Route:** Direct Google API + PDF
**Tokens:** 15277 in / 2123 out
**Response SHA256:** 98d00ad21b4cd169

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Treatment Rollout: Cumulative Départements Restoring 90 km/h"
**Page:** 16
- **Formatting:** Clean and modern. The use of a step-plot is appropriate for a staggered rollout. Gridlines are subtle.
- **Clarity:** Excellent. The reader immediately understands the timing and pace of the policy reversal. Point sizes indicating cohort size add a useful third dimension without clutter.
- **Storytelling:** Strong. It justifies the use of a staggered DiD design.
- **Labeling:** Clear. Axis labels and the LOM enactment line are helpful. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Study: Total Corporal Accidents (Callaway-Sant’Anna)"
**Page:** 17
- **Formatting:** Standard "stargazer/ggplot" style. The shaded confidence interval is professional.
- **Clarity:** The message is clear but negative for the author's initial hypothesis: there is a visible pre-trend violation, which the note correctly identifies.
- **Storytelling:** Essential. This figure "fails" the standard DiD, which motivates the entire second half of the paper (the DDD approach).
- **Labeling:** Y-axis clearly labeled with units. The sub-title "Callaway-Sant’Anna (2021)..." belongs in a note, not as a floating text inside the plot area.
- **Recommendation:** **REVISE**
  - Move the "Callaway-Sant'Anna (2021)..." text from the top-left of the plot area into the Figure Note to reduce clutter.

### Figure 3: "Event Study: Fatalities (Callaway-Sant’Anna)"
**Page:** 18
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Shows the "underpowered" nature of the fatality data (noisy CIs).
- **Storytelling:** Good. Supports the claim that the effect is driven by frequency, not necessarily severity.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Raw Trends: Mean Accidents and Fatalities by Treatment Status"
**Page:** 19
- **Formatting:** Two-panel vertical layout is standard.
- **Clarity:** The "COVID dip" in 2020 is extremely obvious, which helps the story. However, the x-axis labels (2015.0, 2017.5) are awkward; years should be integers.
- **Storytelling:** Very important for the "COVID confounding" narrative.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Fix the x-axis date labels to show whole years (2015, 2016...) or quarters (2015Q1) rather than decimals like 2017.5.

### Figure 5: "Placebo Diagnostic: Treated Roads vs. Autoroutes in Reversal Départements"
**Page:** 20
- **Formatting:** Good use of colors to distinguish road types.
- **Clarity:** High. The parallel movement of the two lines during the 2020 dip is the "smoking gun" of the paper.
- **Storytelling:** This is the most important figure in the paper for identification.
- **Labeling:** The subtitle "Both decline post-2020..." is a bit "hand-holdy" for a top journal; let the caption/text do that.
- **Recommendation:** **REVISE**
  - Remove the internal subtitle ("Both decline post-2020...") to meet the stylistic standards of AER/QJE, which prefer "cold" exhibits.

### Figure 6: "Randomization Inference: Distribution of Permuted TWFE Coefficients"
**Page:** 21
- **Formatting:** Professional histogram. 
- **Clarity:** The red line is clearly an outlier, proving the naive result isn't random.
- **Storytelling:** Provides "frequentist" support for the confounding story.
- **Labeling:** Well-labeled.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a robustness check. In a top-tier paper, the main text should focus on the DDD results now that the DiD is sufficiently "debunked" by Figures 2-5.

### Figure 7: "Treatment Intensity: Share of Départmental Road Network at 90 km/h"
**Page:** 22
- **Formatting:** Horizontal bar chart is the right choice for 30 categories.
- **Clarity:** High.
- **Storytelling:** Shows the "Treatment Intensity" mentioned in Section 2.4.
- **Labeling:** Y-axis (Département names) is legible.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Event Study: Serious Injuries (Hospitalized)"
**Page:** 23
- **Formatting:** Consistent with other event studies.
- **Clarity:** High.
- **Storytelling:** Redundant. It tells the same story as Figure 2. 
- **Recommendation:** **MOVE TO APPENDIX**

### Table 1 & 2: "Summary Statistics: Pre-Period (2015–2019)"
**Page:** 24
- **Formatting:** There is a typo in the PDF where the title "Table 1" and "Table 2" appear for the same table. 
- **Clarity:** Good comparison between groups.
- **Storytelling:** Essential for showing the baseline imbalance (rural vs. urban).
- **Labeling:** Needs "Standard Errors" or "Standard Deviations" clearly indicated for the second row of each variable.
- **Recommendation:** **REVISE**
  - Merge the two titles into one: "Table 1: Summary Statistics."
  - Align numbers by decimal point.
  - Add a note specifying that SDs are in parentheses if that is the case (currently it says "SD Accidents" as a row, which is fine, but decimal alignment is messy).

### Table 3 & 4: "Main Results: Effect of 90 km/h Reversal on Road Safety"
**Page:** 25
- **Formatting:** Duplicate titles again (Table 3/4). No significance stars? Top journals expect stars.
- **Clarity:** Good side-by-side of CS-DiD and TWFE.
- **Storytelling:** This table is the "Motivation" table. It shows the "misleading" results.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Fix the duplicate title.
  - Add significance stars (* p<0.1, ** p<0.05, *** p<0.01).
  - Use the standard AER format: Coefficients on top, SEs in parentheses below. Currently, they are in a separate column, which wastes horizontal space.

### Table 5 & 6: "Robustness Checks"
**Page:** 26
- **Formatting:** Duplicate titles. 
- **Clarity:** This is a "Summary" robustness table. It is very effective for a quick glance.
- **Storytelling:** The last row (DDD) is the "Headline" result. This feels like the "Money" table of the paper.
- **Labeling:** Good.
- **Recommendation:** **PROMOTE TO TABLE 2**
  - This should follow the summary stats. It effectively summarizes the paper's journey from Naive DiD to the DDD. Fix the duplicate title.

### Table 7 & 8: "Treatment Rollout by Year"
**Page:** 27
- **Formatting:** Duplicate titles. 
- **Clarity:** High.
- **Storytelling:** Descriptive. 
- **Recommendation:** **MOVE TO APPENDIX**
  - Figure 1 already visualizes this effectively. This level of tabular detail is better suited for an appendix.

---

## Overall Assessment

- **Exhibit count:** 4 main tables (with duplicate numbering issues), 8 main figures. 0 appendix exhibits (currently all in main).
- **General quality:** The visual aesthetics are high (likely R/ggplot2), but the organization is "Appendix-heavy" in the main text. There are significant clerical errors with table/figure numbering (duplicates).
- **Strongest exhibits:** Figure 5 (Placebo Diagnostic) and Figure 1 (Rollout).
- **Weakest exhibits:** Table 3/4 (Main Results) due to lack of stars and inefficient "column-wise" SE placement.

- **Missing exhibits:** 
  1. **A Triple-Difference (DDD) Event Study:** The paper relies on a static DDD coefficient in Table 5. For a top journal, you **must** show the DDD event study to prove that the "difference-in-differences-in-differences" satisfies parallel trends.
  2. **A Map:** An economics paper about French départements almost requires a map showing treated vs. control areas.

- **Top 3 improvements:**
  1. **Clean up Numbering and Titles:** Eliminate the "Table 1 / Table 2" double-labeling and the duplicate titles on every page. This looks like a LaTeX/Markdown rendering error.
  2. **Consolidate Results:** Combine the various event studies. Keep "Total Accidents" in the main text; move "Fatalities" and "Hospitalized" event studies to the Appendix. 
  3. **Standardize Tables:** Use the standard vertical format (SEs under coefficients) and add significance stars to all regression tables. Decimal-align all values to improve readability.