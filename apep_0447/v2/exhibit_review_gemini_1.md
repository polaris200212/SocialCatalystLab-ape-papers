# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T17:40:23.747406
**Route:** Direct Google API + PDF
**Tokens:** 22037 in / 1956 out
**Response SHA256:** 94f269783023f5ea

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: State-Level Monthly Medicaid Billing (Clean HCBS)"
**Page:** 11
- **Formatting:** Generally professional. Panel structure is clear. Number alignment is decent but could be improved by decimal-aligning the "Mean" and "SD" columns.
- **Clarity:** Excellent. It clearly defines the size of the sectors and the variation in the treatment variable.
- **Storytelling:** Critical. It establishes that HCBS and BH are comparable in scale, which is a prerequisite for the DDD logic.
- **Labeling:** Good. "($M)" and "(000s)" are helpful. Note clearly defines the sample.
- **Recommendation:** **KEEP AS-IS** (Minor: decimal-align columns).

### Table 2: "Triple-Difference Estimates: Effect of Lockdown Stringency on HCBS vs Behavioral Health"
**Page:** 16
- **Formatting:** Journal-ready. Use of brackets for 95% CI and parentheses for SE is standard for top-tier journals.
- **Clarity:** Logical layout with increasing levels of specificity (total paid $\rightarrow$ beneficiaries/provider).
- **Storytelling:** The core results table. Shows that while point estimates are large, precision is an issue. Column (4) should be the focus.
- **Labeling:** Axis and row labels are clear. Significance stars are correctly defined.
- **Recommendation:** **REVISE**
  - Change the header of Column (4) to "Log Beneficiaries" rather than "Log Benef." to avoid ambiguity.
  - The $p$-value row is redundant if stars and SEs are present, but it's acceptable for transparency.

### Figure 1: "Dynamic Triple-Difference: Quarterly Coefficients (Clean HCBS)"
**Page:** 17
- **Formatting:** Clean, standard "event study" style. Shaded CI is professional.
- **Clarity:** The message—flat pre-trend and late-onset effect—is parseable in 10 seconds.
- **Storytelling:** This is the most important visual in the paper. It validates the parallel trends and shows the "scarring" effect over time.
- **Labeling:** Clear. Reference quarter $q=-1$ is correctly marked.
- **Recommendation:** **KEEP AS-IS**.

### Table 3: "Decomposition: Separate Difference-in-Differences for HCBS and Behavioral Health"
**Page:** 18
- **Formatting:** Clean panel structure.
- **Clarity:** Very high. Separating the two components of the DDD is essential for the author's argument against demand shocks.
- **Storytelling:** High value. It prevents the critique that the result is driven by a surge in behavioral health (mental health) demand.
- **Labeling:** Standard errors and CIs are present.
- **Recommendation:** **KEEP AS-IS**.

### Figure 2: "Period-Specific Triple-Difference Effects on Log Total Paid (Clean HCBS)"
**Page:** 19
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Clean summary of the time-path shown in Figure 1.
- **Storytelling:** Somewhat redundant with Figure 1, but useful for grouping the "post" period into logical phases (Lockdown, Recovery, etc.).
- **Labeling:** Labels on the x-axis are very clear.
- **Recommendation:** **KEEP AS-IS** (Consider merging with Table 6 if space is tight, but visual is preferred).

### Table 4: "Robustness of Triple-Difference Estimates"
**Page:** 20
- **Formatting:** A "one-stop shop" robustness table. Very standard for AER/QJE.
- **Clarity:** High. Includes coefficient, SE, CI, and $p$-value.
- **Storytelling:** Crucial for defending the main result against alternative specifications.
- **Labeling:** Good. Note explains the RI and placebo rows well.
- **Recommendation:** **KEEP AS-IS**.

### Figure 3: "Randomization Inference: Distribution of Permuted DDD Coefficients"
**Page:** 23
- **Formatting:** Standard RI histograms.
- **Clarity:** Very clear where the actual estimate sits in the permuted distribution.
- **Storytelling:** Critical given the marginal $p$-values in Table 2. It demonstrates that the result isn't a fluke of clustering assumptions.
- **Labeling:** Red vertical line and text annotations are effective.
- **Recommendation:** **KEEP AS-IS**.

### Figure 4: "State-Level Lockdown Stringency (April 2020)"
**Page:** 27
- **Formatting:** Clean bar chart.
- **Clarity:** Shows the variation in the treatment variable.
- **Storytelling:** Good for transparency but could be argued as "secondary." However, it helps visualize which states are "High" vs "Low."
- **Labeling:** State abbreviations are standard.
- **Recommendation:** **MOVE TO APPENDIX**. This information is useful for context but does not directly test the hypothesis. It takes up a full page that could be used for results.

### Figure 5: "Raw Trends in Medicaid Spending by Service Type and Lockdown Intensity"
**Page:** 28
- **Formatting:** Multi-panel time series.
- **Clarity:** A bit cluttered. The legend at the bottom is very long and hard to match to the lines.
- **Storytelling:** Essential. Every DiD/DDD paper needs to show the raw data trends.
- **Labeling:** Legend needs improvement.
- **Recommendation:** **REVISE**
  - Simplify the legend. Use line colors (Red for High Stringency, Blue for Low) and line styles (Solid for HCBS, Dashed for BH).
  - Move the legend inside the plot or group it better to reduce the "spaghetti" effect.

### Figure 6: "Clean HCBS-to-Behavioral Health Spending Ratio Over Time"
**Page:** 29
- **Formatting:** Single line plot.
- **Clarity:** Very high. This is the visual representation of the DDD assumption.
- **Storytelling:** High value. It shows the "ratio" which is the direct target of the DDD estimator.
- **Labeling:** Shaded lockdown period is helpful.
- **Recommendation:** **KEEP AS-IS**.

---

## Appendix Exhibits

### Table 5: "HCPCS Code Classification: T-Codes (HCBS) by In-Home Status"
**Page:** 39
- **Formatting:** Clear classification table.
- **Clarity:** High.
- **Storytelling:** Essential for transparency on how the "Clean HCBS" group was constructed.
- **Labeling:** Clearly differentiates "Yes/No" for In-Home status.
- **Recommendation:** **KEEP AS-IS**.

### Table 6: "Period-Specific Triple-Difference Effects"
**Page:** 40
- **Formatting:** Regression output for Figure 2.
- **Clarity:** Clean.
- **Storytelling:** Redundant with Figure 2, but standard practice to provide the exact numbers in the appendix.
- **Recommendation:** **KEEP AS-IS**.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 6 main figures (pre-revision), 2 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The exhibits follow the "AER style" (clean lines, minimal gridlines, comprehensive notes). The paper does a great job of showing both raw data (Fig 5/6) and estimated effects (Fig 1/2).
- **Strongest exhibits:** Figure 1 (Event Study) and Table 3 (Decomposition). These two do the most work to prove the causal claim and rule out the main alternative explanation.
- **Weakest exhibits:** Figure 5 (Legend is too busy) and Figure 4 (Low informational density for a main text exhibit).
- **Missing exhibits:** 
    - **Geographic Map:** A map of the US shaded by stringency (replacing or supplementing Figure 4) would be more visually engaging and show regional clustering of the treatment.
    - **Summary Statistics Table for the Appendix:** A table showing the specific T-codes' summary stats (beyond just classification in Table 5) would help justify why some codes are "Clean" vs not.

### Top 3 Improvements:
1.  **Simplify Figure 5 Legend:** Use a 2x2 legend structure (Service Type x Stringency Group) so the reader doesn't have to scan 8 items.
2.  **Move Figure 4 to Appendix:** Replace its spot in the main text with Figure 6 or a map. Figure 6 is a much stronger "descriptive" result than Figure 4.
3.  **Decimal Alignment:** Ensure all numbers in Table 1 and Table 2 are aligned on the decimal point to improve vertical scannability.