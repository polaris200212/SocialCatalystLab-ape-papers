# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T18:34:07.526888
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 2462 out
**Response SHA256:** 563768ae442e2658

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Generally clean. Panel structure is appropriate for top journals. Decimal points are mostly aligned, though the "Beneficiaries served" row lacks a comma for the 110,972 value in the medium tercile for consistency with the full sample.
- **Clarity:** Clear. The distinction between the treatment variable and outcomes is helpful.
- **Storytelling:** Strong. It immediately shows the "Medicaid wage penalty" (Panel A) and establishes that low-competitiveness states are actually the largest markets (Panel B), which motivates the "fragility" argument.
- **Labeling:** Good. Note defines the wage ratio and HCBS providers clearly.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Event Study: Wage Competitiveness and HCBS Provider Supply"
**Page:** 14
- **Formatting:** Modern and professional. The use of a shaded 95% CI is standard. The red vertical line for the shock is effective.
- **Clarity:** Excellent. The "pre-trend" (or lack thereof) is visible, and the post-COVID divergence is the primary takeaway.
- **Storytelling:** This is the "money plot" of the paper. It proves the identification strategy's validity and shows the timing of the effect.
- **Labeling:** Y-axis label "Coefficient on Wage Ratio × Month" is precise. Annotations (subtitle) help the 10-second parse.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Wage Competitiveness and HCBS Outcomes: Main Results"
**Page:** 15
- **Formatting:** Journal-ready. Professional borders (top, bottom, and under headers only). Significance stars are standard.
- **Clarity:** The table is a bit wide. The scientific notation for COVID cases (e.g., $-3.55 \times 10^{-5}$) is technically accurate but harder for a reader to mentally process than "Cases per 100k."
- **Storytelling:** Groups the main outcome with secondary outcomes (Beneficiaries, Spending, Claims).
- **Labeling:** Proper definition of standard errors in parentheses.
- **Recommendation:** **REVISE**
  - Change the scale of the "COVID Cases" variable (e.g., cases per 1,000 or 10,000) to avoid scientific notation in the coefficient cells. This makes the table much more readable.

### Table 3: "Heterogeneity by Provider Type"
**Page:** 16
- **Formatting:** Consistent with Table 2.
- **Clarity:** Clear comparison between Column 2 (Sole Props) and Column 3 (Organizations). 
- **Storytelling:** Vital for the "Monopsony" argument. It shows the effect is driven by firms, which are the ones constrained by state-set rates.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Wage Competitiveness Ratio by State, 2019"
**Page:** 17
- **Formatting:** The map is clean, but the projection for Alaska and Hawaii is a bit disconnected from the mainland.
- **Clarity:** Color scale (orange to green) is intuitive (low to high competitiveness). 
- **Storytelling:** Helps show that this isn't just a "Red State vs. Blue State" or "North vs. South" issue—there is idiosyncratic variation.
- **Labeling:** Source note is present.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "ARPA HCBS Spending and Workforce Recovery"
**Page:** 18
- **Formatting:** Consistent.
- **Clarity:** Column 2 is the key. The interaction term "wage_ratio_x_post_arpa" clearly shows the recovery boost.
- **Storytelling:** Essential "Prediction 3" evidence. It shows that the "rich get richer" (competitive states recovered faster with federal help).
- **Labeling:** Note explains the ARPA timing.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Randomization Inference: Distribution of Placebo Coefficients"
**Page:** 19
- **Formatting:** Clean histogram. The blue vertical line for the observed coefficient is standard for papers in *Econometrica* or *QJE*.
- **Clarity:** Very high. The p-value is explicitly labeled.
- **Storytelling:** Provides non-parametric support for the main result, which is crucial when dealing with 51 clusters (states).
- **Labeling:** All axes and lines are labeled.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Leave-One-Out Sensitivity Analysis"
**Page:** 20
- **Formatting:** Clean dot plot. 
- **Clarity:** Labeling the specific outliers (PA, ND, TX, DC) is excellent practice.
- **Storytelling:** Addresses the "outlier state" concern immediately.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** This table is quite "busy." It mixes a Region FE check (Col 2) with a Functional Form check (Col 4) and a Variable Definition check (Col 5).
- **Storytelling:** Important for robustness, but might be better as an Appendix exhibit to keep the main text leaner.
- **Labeling:** Standard.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text already has a lot of exhibits. The paper's flow would be stronger if Table 5 lived in the Appendix, with the results summarized in text.

### Table 6: "Falsification and Placebo Tests"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** Column 2 (Behavioral Health) is a very strong "Placebo" check.
- **Storytelling:** Critical for identification.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Event Studies: Multiple HCBS Outcomes"
**Page:** 23
- **Formatting:** Stacked panels are good, but the Y-axis scales are different for each panel, which can be misleading if not read carefully.
- **Clarity:** Cluttered. Having three separate event studies in one figure makes each one small and hard to read.
- **Storytelling:** It's a bit redundant given Table 2. 
- **Recommendation:** **MOVE TO APPENDIX**
  - The main Figure 1 (Providers) is enough for the main text. This multi-outcome figure is "Appendix material" for the curious reader.

### Figure 6: "Event Study by Wage Ratio Tercile"
**Page:** 24
- **Formatting:** The overlapping CIs make this plot very "noisy."
- **Clarity:** Low. The Low/Medium/High lines are hard to distinguish when their confidence intervals overlap so heavily.
- **Storytelling:** Tries to show the "dose-response" relationship.
- **Recommendation:** **REMOVE**
  - Figure 1 (continuous) and Figure 7 (placebo) are much cleaner. This tercile-based event study doesn't add enough new information to justify the visual clutter.

### Figure 7: "Behavioral Health Placebo: Event Study Comparison"
**Page:** 25
- **Formatting:** Two-color comparison is good.
- **Clarity:** High. It visually confirms Table 6, Col 2.
- **Storytelling:** Very powerful. It shows that the "shock" only hit the in-person sector (HCBS) and not the telehealth-capable sector (BH).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Wait—Actually, consolidate this with Figure 1 or keep as the primary Falsification figure).

---

## Appendix Exhibits

### Table 7: "Sample Construction"
**Page:** 32
- **Formatting:** Simple and clean.
- **Clarity:** Excellent. It shows that no observations are lost at any stage.
- **Storytelling:** Standard "transparency" exhibit.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Raw Trends in Log HCBS Providers by Wage Ratio Tercile"
**Page:** 33
- **Formatting:** A bit "rawer" than the main text figures. 
- **Clarity:** The "Index (Jan 2020 = 100)" is the correct way to show this.
- **Storytelling:** It shows that the "levels" are moving in the right direction even without the regression machinery.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Wage Competitiveness and Post-COVID Provider Change"
**Page:** 34
- **Formatting:** Scatter plot with regression line and CI.
- **Clarity:** High. Labeling every state code is very helpful for readers looking for their own state.
- **Storytelling:** This is a "binned scatter" or simple correlation that "sells" the paper's main result in a way a non-economist can understand.
- **Labeling:** Axis units (% change) are clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This should be "Figure 1" or "Figure 2." It is the most intuitive visualization of the entire paper.

---

## Overall Assessment

- **Exhibit count:** 6 main tables, 7 main figures, 1 appendix table, 2 appendix figures
- **General quality:** High. The figures are modern and look like they were produced in R (ggplot2), which is standard for top-tier journals. Tables are clean but occasionally too dense.
- **Strongest exhibits:** Figure 1 (Event Study), Figure 9 (Cross-sectional Scatter), Figure 3 (Randomization Inference).
- **Weakest exhibits:** Figure 6 (Tercile Event Study - too much overlap), Table 5 (Too many unrelated robustness tests).
- **Missing exhibits:** A **"Variable Definitions"** table in the Appendix listing the exact NAICS codes and T/S codes in a clean list would be helpful, though they are in the text.

### Top 3 Improvements:
1.  **Re-scale COVID controls:** In Table 2 and others, change "Cases" to "Cases per 10,000" to eliminate scientific notation (E-05). It looks unprofessional and is hard to read.
2.  **Strategic Promotion/Demotion:** Move Figure 9 (Cross-sectional Scatter) to the main text (early on). Move Table 5 (Robustness) and Figure 5 (Multiple Event Studies) to the Appendix to reduce main-text clutter.
3.  **Simplify Figures:** Remove Figure 6. The overlapping confidence intervals are messy and detract from the professionalism of the other figures. Figure 1 already carries that weight.