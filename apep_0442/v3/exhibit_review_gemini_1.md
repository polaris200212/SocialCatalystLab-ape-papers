# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T15:01:09.241696
**Route:** Direct Google API + PDF
**Tokens:** 27757 in / 2931 out
**Response SHA256:** 3a4f9253a929c4f2

---

This review evaluates the exhibits for "The First Retirement Age: Civil War Pensions and the Labor Supply Response to Age-Based Eligibility" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Costa Union Army Sample"
**Page:** 14
- **Formatting:** Clean and professional. Uses Panel A, B, and C effectively to distinguish between the cross-section, panel, and eligibility groups.
- **Clarity:** High. Logical grouping of variables (Outcomes, Pension, Demographic).
- **Storytelling:** Essential. It establishes the "thinness" of the below-62 sample (N=2,554 vs 18,748) which explains the precision issues later.
- **Labeling:** Good. Includes N, SD, and Mean.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at Age-62 Threshold"
**Page:** 18
- **Formatting:** Standard RDD balance table. Decimal alignment is good.
- **Clarity:** Clear. Shows the reader exactly where the identification might be "leaky" (literate, homeowner).
- **Storytelling:** Necessary for RDD validity.
- **Labeling:** Defines "rdrobust" usage in notes.
- **Recommendation:** **REVISE**
  - Group variables by category (Socio-economic vs. Military history).
  - Add a "Mean" column to provide context for the RD Estimate magnitude.

### Figure 1: "Density of the Running Variable at the Age-62 Threshold"
**Page:** 18
- **Formatting:** Professional. Good use of the vertical dashed line.
- **Clarity:** The internal label says "Figure 7" while the caption says "Figure 1". This must be fixed.
- **Storytelling:** Critical for proving no manipulation of age.
- **Labeling:** Clear axis labels.
- **Recommendation:** **REVISE**
  - Fix the internal title discrepancy ("Figure 7" vs "Figure 1").
  - Remove the redundant internal title at the top; let the caption do the work.

### Figure 2: "Covariate Balance at the Age-62 Threshold"
**Page:** 19
- **Formatting:** Standard "coefficient plot" style.
- **Clarity:** Internal title says "Figure 6".
- **Storytelling:** Redundant with Table 2. Top journals usually prefer the table for balance or the plot, rarely both in the main text unless there are 20+ covariates.
- **Labeling:** X-axis clearly labeled with units.
- **Recommendation:** **MOVE TO APPENDIX** (Keep Table 2 in main text as it provides more precision).

### Figure 3: "First Stage: Pension Receipt Under the 1907 Act at Age 62"
**Page:** 20
- **Formatting:** Standard RD plot. Bin sizes are visible.
- **Clarity:** Internal title says "Figure 3" (consistent). The jump is visually obvious.
- **Storytelling:** This is the "Central data advantage" of the paper. It must stay.
- **Labeling:** Axis labels are good. 
- **Recommendation:** **KEEP AS-IS**

### Table 3: "First Stage: Pension Receipt at Age-62 Threshold"
**Page:** 20
- **Formatting:** Professional.
- **Clarity:** Excellent. Breaks down the first stage into receipt, amount, and change.
- **Storytelling:** Quantifies the visual from Figure 3.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Monthly Pension Amount by Age"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Shows the "steps" at 62, 70, and 75.
- **Storytelling:** Explains the "Dose" in the dose-response section later.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Cross-Sectional RDD: Labor Force Participation at Age 62"
**Page:** 22
- **Formatting:** Professional. The local linear fit is clear.
- **Clarity:** Internal title says "Figure 1". Caption says "Figure 5". Fix this.
- **Storytelling:** The "null" result. Important to show.
- **Labeling:** Point size legend missing (Note says proportional to cell counts, but a visual scale is better).
- **Recommendation:** **REVISE**
  - Synchronize figure numbers.
  - Remove internal title.

### Table 4: "Main RDD Results: Effect of Pension Eligibility on Labor Supply"
**Page:** 23
- **Formatting:** Excellent use of Panel A (Cross-section), B (Panel), and C (Falsification). This is QJE-style formatting.
- **Clarity:** Very high.
- **Storytelling:** This is the "Money Table" of the entire paper.
- **Labeling:** "NL" and "NR" should be defined in the notes (Number Left/Right of cutoff).
- **Recommendation:** **KEEP AS-IS** (with minor note addition).

### Figure 6: "Pre-Treatment Falsification: LFP in 1900 at the Age-62 Threshold"
**Page:** 24
- **Formatting:** Consistent with Fig 5.
- **Clarity:** Internal title "Figure 5" vs Caption "Figure 6".
- **Storytelling:** Vital for honesty. Shows the "pre-trend" concern.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Synchronize figure numbers.

### Table 5: "Fuzzy RDD: Local Average Treatment Effect of Pension on LFP"
**Page:** 25
- **Formatting:** Small table, lots of white space.
- **Clarity:** Clear.
- **Storytelling:** The results are "imprecise for inference."
- **Recommendation:** **MOVE TO APPENDIX** or consolidate as a bottom panel in Table 4. It's too small for its own main-text table when results are null.

### Table 6: "Robustness: Cross-Sectional RDD Across Bandwidths"
**Page:** 26
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Supporting evidence for the cross-sectional null.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 7: "Bandwidth Sensitivity of Cross-Sectional and Panel RDD Estimates"
**Page:** 26
- **Formatting:** Internal title says "Figure 8".
- **Clarity:** It ONLY shows the cross-sectional estimates (based on the blue dots). The caption says "Cross-Sectional and Panel".
- **Storytelling:** Crucial for the argument that the effect is stable at wider bandwidths.
- **Recommendation:** **REVISE**
  - Add the Panel RDD estimates to this same plot (perhaps as red triangles) to show how they diverge from the cross-section as bandwidth increases.

### Table 7: "Randomization Inference Results"
**Page:** 28
- **Formatting:** Professional.
- **Clarity:** Clear.
- **Storytelling:** Confirms the p-values.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 8: "Randomization Inference: Permutation Distribution"
**Page:** 29
- **Formatting:** Internal title says "Figure 10".
- **Clarity:** Clear histogram.
- **Storytelling:** Methodological robustness.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 9: "Placebo Cutoff Tests"
**Page:** 30
- **Formatting:** Good use of color (Red vs Blue).
- **Clarity:** Internal title says "Figure 9" (Correct).
- **Storytelling:** High value. Shows the 62 effect is unique.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Subgroup Heterogeneity: RDD by Pre-Treatment Characteristics"
**Page:** 31
- **Formatting:** Long table.
- **Clarity:** A bit cluttered.
- **Storytelling:** Good for exploration but mostly nulls.
- **Recommendation:** **REVISE**
  - Only keep the 4-5 most "interesting" subgroups in main text. Move the full list to Appendix.

### Figure 10: "Subgroup Heterogeneity: Panel RDD Estimates at Age 62"
**Page:** 32
- **Formatting:** Internal title "Figure 11".
- **Clarity:** Much easier to parse than Table 8.
- **Storytelling:** Shows "Topped up" and "Wounded" are the drivers.
- **Recommendation:** **REVISE** (Fix figure number, keep in main text).

### Table 9: "Multi-Cutoff Dose-Response: LFP at Different Pension Thresholds"
**Page:** 33
- **Clarity:** Clear.
- **Storytelling:** Shows the lack of response at 70 and 75.
- **Recommendation:** **MOVE TO APPENDIX** (The text handles this point sufficiently).

### Figure 11: "Multi-Cutoff Dose-Response: Pension Thresholds at 62, 70, and 75"
**Page:** 34
- **Formatting:** Internal title "Figure 12".
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 12: "Civil War Pension Schedule Under the 1907 Act"
**Page:** 35
- **Formatting:** Internal title "Figure 14".
- **Clarity:** Good "theory" figure.
- **Storytelling:** Should be earlier in the paper (Section 2) to help the reader understand the shock.
- **Recommendation:** **KEEP AS-IS** (but move to page 5).

### Table 10: "Occupation Transitions: Labor Force Exit Rates by 1900 Occupation"
**Page:** 35
- **Clarity:** Very interesting descriptive data.
- **Storytelling:** Sets the stage for the mechanism.
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Occupation Exit Rates at the Age-62 Threshold"
**Page:** 36
- **Formatting:** Horizontal bar chart.
- **Clarity:** Clear.
- **Storytelling:** Good visualization of Table 10.
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Health Mechanisms: Disability and Mortality at Age-62 Threshold"
**Page:** 37
- **Clarity:** Crucial for ruling out the "Sicker at 62" story.
- **Storytelling:** Essential.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 12: "Summary of Major Union Army Pension Laws"
**Page:** 49
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Section 2). Top journals love institutional context tables.

### Table 13: "Panel Selection: Probability of Appearing in Both Censuses"
**Page:** 49
- **Recommendation:** **KEEP AS-IS**

### Figure 14: "Panel RDD: Change in Labor Force Participation at Age 62"
**Page:** 51
- **Formatting:** Internal title "Figure 2".
- **Clarity:** This is the most important "results" figure in the paper.
- **Storytelling:** It shows the actual jump in the panel RDD.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Next to Figure 5).

---

# Overall Assessment

- **Exhibit count:** 11 main tables, 13 main figures, 2 appendix tables, 1 appendix figure.
- **General quality:** High. The paper adopts the "standard" RDD visual toolkit effectively. However, the figure numbering is a mess—nearly every figure has an internal title (exported from R/Stata) that contradicts the LaTeX caption number.
- **Strongest exhibits:** Table 4 (Main results), Figure 3 (First stage).
- **Weakest exhibits:** Figure 7 (Missing the panel results it claims to show), Table 5 (Too small/empty).
- **Missing exhibits:** A map or regiment distribution table (common in economic history) to show the geographic spread of the Costa sample.

### Top 3 Improvements:
1. **Fix Figure Numbering and Titles:** Remove all internal titles (e.g., "Figure 14: 1907 Service..."). Ensure the LaTeX caption is the only title. Synchronize numbering.
2. **Promote the Panel RDD Figure:** Move Figure 14 (Appendix) to the main text. It is much more important than the cross-sectional Figure 5 because it shows the paper's primary contribution.
3. **Consolidate/Slim Down:** Move the Randomization Inference and Bandwidth Sensitivity tables to the Appendix to let the main results (Table 4) shine. The paper currently feels "over-visualized" with redundant plots and tables for the same tests.