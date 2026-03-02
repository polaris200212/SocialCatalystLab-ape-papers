# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T20:20:47.691323
**Route:** Direct Google API + PDF
**Tokens:** 25157 in / 2642 out
**Response SHA256:** 72853ab4edfd7de9

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Civil War Veterans in the 1910 Census (1.4% Oversampled)"
**Page:** 13
- **Formatting:** High quality. Proper use of booktabs (horizontal rules only). Number alignment is good, though the "N" row should be integer-aligned while the means are decimal-aligned.
- **Clarity:** Excellent. The grouping of outcomes vs. covariates is logical.
- **Storytelling:** Strong. It immediately highlights the power problem: $N=220$ for the below-cutoff treatment group is the "Achilles' heel" of the paper.
- **Labeling:** Clear. Definitions in notes (e.g., LFP) are helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Age Distribution of Union Veterans in the 1910 Census"
**Page:** 17
- **Formatting:** Clean, modern. Gridlines are subtle.
- **Clarity:** The McCrary test result is clearly annotated. The spikes at 60 and 65 (age heaping) are immediately visible.
- **Storytelling:** Essential. It justifies why a density test is necessary and explains the demographic "steep cliff" that complicates the RDD.
- **Labeling:** Clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at the Age 62 Threshold"
**Page:** 18
- **Formatting:** Professional. Standard errors in parentheses.
- **Clarity:** Direct. The "NL / NR" column is very helpful for RDD transparency.
- **Storytelling:** Crucial. It flags the "Literate" and "White" imbalances that the author must address.
- **Labeling:** Significance stars are standard.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Covariate Balance at the Age 62 Threshold"
**Page:** 19
- **Formatting:** Multi-panel layout is good, but the individual plots are quite small.
- **Clarity:** Low. The y-axis scales vary or are not optimized for each panel, and the data points are cluttered.
- **Storytelling:** Redundant with Table 2 and Figure 11 (Appendix). 
- **Recommendation:** **MOVE TO APPENDIX** (Keep Table 2 in main text as the primary balance evidence).

### Figure 3: "Labor Force Participation of Union Veterans: RDD at Age 62"
**Page:** 20
- **Formatting:** Excellent. Point sizes proportional to N is standard for top journals.
- **Clarity:** High. The 95% CIs on the bins help visualize why the result is a null.
- **Storytelling:** This is the "money plot." It shows the slight positive (counter-intuitive) jump and the lack of a drop.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Pension Eligibility on Labor Force Participation: RDD at Age 62"
**Page:** 21
- **Formatting:** AER-standard. 
- **Clarity:** High. Reporting MDE (80% power) is a sophisticated touch that editors at *Econometrica* or *AER* will appreciate for a null result.
- **Storytelling:** The core results table. 
- **Labeling:** Explicitly mentions "Triangular kernel," which is helpful.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Difference-in-Discontinuities: Union vs. Confederate Veterans at Age 62"
**Page:** 22
- **Formatting:** Beautiful. Distinct colors (Red/Blue) and shaded CIs.
- **Clarity:** High. Can be parsed in seconds.
- **Storytelling:** Strongest visual evidence in the paper. It shows the Confederate "placebo" group has no jump, while the Union group does.
- **Labeling:** Clear legend and axis.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Difference-in-Discontinuities: Union vs. Confederate Veterans at Age 62"
**Page:** 23
- **Formatting:** Good.
- **Clarity:** Logical layout (Union | Confederate | Difference).
- **Storytelling:** Statistical version of Figure 4. 
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Pooled Parametric Difference-in-Discontinuities Regression"
**Page:** 23
- **Formatting:** Standard OLS table.
- **Clarity:** Clear.
- **Storytelling:** Potentially redundant with Table 4. However, it shows the "Age - 62" slope parameter which is useful.
- **Recommendation:** **REVISE** — Merge this into Table 4 as an additional column/panel to keep the main text lean.

### Table 6: "RDD Estimates for Secondary Outcomes at the Age 62 Threshold"
**Page:** 24
- **Formatting:** Professional.
- **Clarity:** Good.
- **Storytelling:** Broadens the paper beyond just LFP.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Civil War Pension Schedule Under the 1907 Act"
**Page:** 25
- **Formatting:** A bit simple. Looks like a basic bar chart.
- **Clarity:** High, but low information density.
- **Storytelling:** This is a "setup" figure.
- **Recommendation:** **MOVE TO APPENDIX** (Explain the schedule in the text; a figure isn't strictly necessary for a simple step function).

### Figure 6: "Dose-Response: Pension Increases and Labor Supply"
**Page:** 26
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Very important. It shows that even with bigger "shocks" at 70 and 75, the response is still basically zero.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Robustness of Main RDD Estimate (Labor Force Participation)"
**Page:** 27
- **Formatting:** Heavy. Four panels is a lot for one table.
- **Clarity:** Medium. It's a wall of numbers.
- **Storytelling:** Essential "stress test" for the results. 
- **Recommendation:** **REVISE** — Move Panels A and B to a separate Appendix table. Keep Panels C and D as they are more "thematic" than "mechanical."

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 28
- **Formatting:** Standard "coefficient plot."
- **Clarity:** High.
- **Storytelling:** Standard for RDD papers.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 8: "Placebo Cutoff Tests"
**Page:** 29
- **Formatting:** Good.
- **Clarity:** High. The red dot (true cutoff) vs blue dots is a great visual cue.
- **Storytelling:** Strong validity evidence.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Randomization Inference: Finite-Sample P-Values"
**Page:** 30
- **Formatting:** Simple.
- **Clarity:** Comparison of RI vs. Asymptotic p-values is very clear.
- **Storytelling:** Directly addresses the "small sample/discrete running variable" critique.
- **Recommendation:** **REVISE** — Consolidate this into Table 3 (Main Results) as additional rows.

### Figure 9: "Randomization Inference: Permutation Distribution"
**Page:** 30
- **Formatting:** Clean histogram.
- **Clarity:** High.
- **Storytelling:** Visual proof of the RI p-value.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 9: "Subgroup Heterogeneity: RDD at Age 62 by Demographic Group"
**Page:** 31
- **Formatting:** Very long table. 
- **Clarity:** Low. Too much to digest.
- **Storytelling:** Important for exploring the "Null," but overwhelming as a table.
- **Recommendation:** **MOVE TO APPENDIX** (The forest plot in Figure 10 is much better for the main text).

### Figure 10: "Subgroup Heterogeneity: RDD Estimates at Age 62"
**Page:** 33
- **Formatting:** Excellent forest plot.
- **Clarity:** High. Allows the reader to scan 15+ regressions in 5 seconds.
- **Storytelling:** Shows the "Married" subgroup is the only one with a significant (positive) coefficient.
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Household Spillover Effects: RDD at Veteran’s Age 62 Threshold"
**Page:** 34
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** High-level extension.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table B.4: "Confederate State Pension Rules circa 1910"
**Page:** 44
- **Formatting:** Good.
- **Clarity:** High.
- **Storytelling:** Essential for the Diff-in-Disc identification. It proves the age-62 threshold wasn't "contaminated" by Southern states.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (This is not just data construction; it is the core of the identification strategy).

### Figure 11: "Covariate Balance at the Age 62 Threshold (Detailed)"
**Page:** 46
- **Formatting:** Identical to Figure 2.
- **Clarity:** Same issues as Figure 2.
- **Recommendation:** **KEEP AS-IS** (as an Appendix backup for the table).

---

## Overall Assessment

- **Exhibit count:** 7 main tables, 8 main figures, 1 appendix table, 1 appendix figure.
- **General quality:** Extremely high. The paper follows modern RDD "best practices" (Cattaneo et al.) and uses publication-quality themes (resembling *ggplot2* or *Stata* "cleanplots").
- **Strongest exhibits:** Figure 4 (Diff-in-Disc visual) and Figure 10 (Subgroup forest plot).
- **Weakest exhibits:** Figure 2 and Table 9 (too much information density for the main text).

### Missing Exhibits:
1. **Raw Data Scatter Plot:** A plot showing the number of Union vs. Confederate veterans at every age across the full sample (45-90) would help the reader see the "survivor" distribution before the RDD zooming.
2. **First Stage (Likely Appendix):** A table/figure showing the "jump" in pension receipt at 62 using the 1910 IPUMS "INCOMEPENSION" variable (if available and not too sparse).

### Top 3 Improvements:
1. **Aggressive Consolidation:** Merge Table 8 (Randomization Inference) into Table 3, and Table 5 into Table 4. This reduces the number of exhibits while increasing the "punch" per page.
2. **Identification Promotion:** Move the "Confederate State Pension Rules" table to the main text. For an *AEJ: Policy* or *AER* audience, the institutional proof that the control group is "clean" is just as important as the results.
3. **Strategic "Burying":** Move mechanical robustness (Bandwidth sensitivity Figure 7) and diagnostic visuals (RI distribution Figure 9) to the Appendix. This keeps the main text focused on the **Story** (1. Here is the design -> 2. Here is the null -> 3. Here is why it's a valid null).