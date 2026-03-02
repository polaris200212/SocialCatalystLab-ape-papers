# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T12:16:54.045116
**Route:** Direct Google API + PDF
**Tokens:** 23597 in / 2231 out
**Response SHA256:** ab116622ac5d5c14

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Near-Threshold Villages (Population 300–700)"
**Page:** 11
- **Formatting:** Generally clean and follows standard economics style (top/bottom rules). 
- **Clarity:** Logical grouping of columns (Full Sample vs. Caste Groups). However, the row labels use abbreviations like "F Ag Labor Share" which should be spelled out or clearly defined in the header for 10-second parsing.
- **Storytelling:** Highly effective. It establishes the "dual disparity" (higher participation but lower literacy for ST) mentioned in the text.
- **Labeling:** Clear. Notes define SC/ST/Gen-OBC. $\Delta$ is defined.
- **Recommendation:** **REVISE**
  - Spell out "Female" instead of "F" in row labels.
  - Decimal-align the numbers in all columns to improve vertical scanning.
  - Add a "Standard Deviation" column for the caste-specific subsamples, not just the full sample, to show the variance within groups.

### Table 2: "Effect of PMGSY Eligibility on Female Employment and Human Capital Outcomes (Pooled RDD)"
**Page:** 15
- **Formatting:** Standard journal format. 
- **Clarity:** Excellent. The 5-column structure (Coeff, SE, p-value, BW, Neff) is very transparent.
- **Storytelling:** Central to the "precisely estimated null" argument.
- **Labeling:** Notes are comprehensive. Stars are defined.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Heterogeneous RDD Effects by Village Caste Composition"
**Page:** 17
- **Formatting:** Good use of horizontal space.
- **Clarity:** The juxtaposition of the three groups allows for immediate comparison.
- **Storytelling:** This is the most important table in the paper. It clearly shows the -0.0072 literacy effect standing out against the nulls.
- **Labeling:** Standard errors in parentheses are noted.
- **Recommendation:** **REVISE**
  - The "Neff (approx.)" row at the bottom is a bit vague. Provide the specific median Neff across the outcomes for each column or specify which outcome's BW the Neff corresponds to.

### Figure 1: "RDD Plots by Village Caste Composition"
**Page:** 18
- **Formatting:** Consistent font; clean background.
- **Clarity:** 4-panel structure is excellent. The red dashed line for the threshold is standard.
- **Storytelling:** Visually confirms the nulls.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **REVISE**
  - The Y-axis scale is identical across panels (good), but the binned scatter points are quite crowded near the 500 mark. Consider slightly larger bins or a slightly wider Y-axis range if it helps distinguish the confidence bands.
  - The title inside the plot area ("RDD estimates...") is redundant with the figure caption. Remove it to save whitespace.

### Table 4: "Parametric RDD with Caste Interactions (BW 300–700)"
**Page:** 20
- **Formatting:** Very dense. 
- **Clarity:** Hard to parse the interactions quickly. The "Pop. - 500" rows are essentially controls and clutter the view of the main coefficients of interest.
- **Storytelling:** Provides the "gradient" proof that the effect isn't just a subsample artifact.
- **Labeling:** Well-labeled.
- **Recommendation:** **REVISE**
  - Group coefficients: Place the "Interaction" terms at the top (the primary interest) and "Baseline Caste Shares" below them.
  - Move "Pop - 500" and "Pop - 500 x Eligible" to a "Controls" section at the bottom of the table or replace with a "Running Variable Controls: Yes" row to improve readability.

### Figure 2: "Coefficient Plot: Pooled and Caste-Specific RDD Estimates"
**Page:** 21
- **Formatting:** Professional and modern.
- **Clarity:** High. Color-coding by caste is intuitive.
- **Storytelling:** Excellent summary of the paper's findings. The separation of the green dot (ST) for literacy is the "smoking gun."
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS** (This is a "top-tier journal" quality exhibit).

### Figure 3: "Bandwidth Sensitivity of RDD Estimates"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** Standard sensitivity plot. 
- **Storytelling:** Shows the result isn't cherry-picked.
- **Labeling:** Axis labels present.
- **Recommendation:** **MOVE TO APPENDIX**
  - Bandwidth sensitivity is a standard robustness check but rarely belongs in the main text of a QJE/AER paper unless the result is extremely fragile. Summarizing it in the text is sufficient.

### Figure 4: "Placebo Threshold Tests"
**Page:** 23
- **Formatting:** Consistent with Figure 3.
- **Clarity:** Clear distinction between red (actual) and grey (placebo).
- **Storytelling:** Important for validity.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - Similar to the bandwidth plot, this is a "check-the-box" validity test. Move to the appendix to keep the main text focused on the economic mechanism.

### Table 5: "RDD at 250-Person Threshold (Hills/Tribal Subsample, ST Share > 25%)"
**Page:** 25
- **Formatting:** Identical to Table 2.
- **Clarity:** High.
- **Storytelling:** This is a "non-result" replication.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - The paper admits this fails to replicate the main result for specific reasons. Keeping it in the main text creates a "distraction" from the headline findings.

---

## Appendix Exhibits

### Figure 5: "McCrary Density Test at the PMGSY 500-Person Threshold"
**Page:** 38
- **Formatting:** Clear bar chart with a superimposed density fit.
- **Clarity:** High.
- **Storytelling:** Essential proof of no manipulation.
- **Labeling:** The text "McCrary test: T=0.068..." is very helpful.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - In RDD papers in top journals, the Density (McCrary) plot and the Covariate Balance plot are almost always in the main text (often as a 2-panel figure) to immediately establish identification validity.

### Table 6: "Covariate Balance at the PMGSY Threshold"
**Page:** 39
- **Formatting:** Clean.
- **Clarity:** Standard balance table.
- **Storytelling:** Validates the design.
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (See logic for Figure 5).

### Figure 6: "Covariate Balance at the 500-Person Threshold"
**Page:** 39
- **Formatting:** Dot-and-whisker plot.
- **Clarity:** High.
- **Storytelling:** Redundant with Table 6.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Consolidate this with Table 6. Keep the Figure (visuals are better for balance) and put the Table in the Appendix. **PROMOTE THIS FIGURE** to the main text alongside the McCrary plot.

### Figure 7: "Descriptive Trends in Female Work Participation by Caste Group"
**Page:** 43
- **Formatting:** Line plot with different styles for male/female.
- **Clarity:** A bit cluttered with 6 lines.
- **Storytelling:** Important context for the "U-shaped decline" mentioned in the intro.
- **Labeling:** Descriptive.
- **Recommendation:** **REVISE**
  - Use facets (panels) for the three caste groups to avoid the "spaghetti" effect of 6 overlapping lines. This would make the "parallel trends" much more obvious.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 4 main figures, 1 appendix table, 3 appendix figures.
- **General quality:** High. The exhibits are technically proficient and follow the "minimalist" aesthetic preferred by top journals. Tables are very consistent.
- **Strongest exhibits:** Figure 2 (Coefficient Plot) and Figure 1 (RDD Plots).
- **Weakest exhibits:** Table 4 (too much control clutter) and Table 5 (distracts from the main story).
- **Missing exhibits:** 
  1. **A first-stage figure:** Since the paper references a "weak nightlight first stage," a figure showing the discontinuity in nightlights (or road presence if available) is standard.
  2. **Human Capital RDD Plots:** Figure 1 only shows WPR. Since the "headline" result is female literacy, a Figure showing the RDD plot for literacy in ST villages is **essential** for the main text.

**Top 3 improvements:**
1. **Create an Identification Figure:** Combine the McCrary density test (Fig 5) and the Covariate Balance plot (Fig 6) into a single Panel Figure in the main text to establish validity early.
2. **Prioritize the Headline Result:** Add a figure showing the RDD plot for the **Female Literacy** outcome specifically for the ST subsample. Currently, the most significant result is only shown as a number in a table.
3. **Streamline the Main Text:** Move the sensitivity plots (Fig 3, Fig 4) and the non-replicating 250-threshold table (Table 5) to the appendix to keep the reader focused on the "Missed Opportunity" narrative.