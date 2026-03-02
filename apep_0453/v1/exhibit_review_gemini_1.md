# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-25T14:38:47.030245
**Route:** Direct Google API + PDF
**Tokens:** 16317 in / 1898 out
**Response SHA256:** 23808280d3d45065

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Distribution of Banking Infrastructure Across Indian Districts"
**Page:** 8
- **Formatting:** Clean and modern. The use of a vertical dashed line for the median is standard. No excessive gridlines.
- **Clarity:** High. The right-skew of the data is immediately apparent.
- **Storytelling:** Essential. It justifies why the authors might look at quartiles (Table 2/Figure 3) and helps the reader understand the "intensity" of the treatment.
- **Labeling:** Good. "Bank branches per 100,000 population" is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Standard three-line LaTeX table (booktabs style). Numbers are readable.
- **Clarity:** Good. Dividing into Panel A (cross-section) and Panel B (panel) is helpful.
- **Storytelling:** Essential for establishing the landscape.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Decimal Alignment:** Align all numbers by the decimal point. Currently, the wide range of magnitudes (from 0.105 to 1,891,783) makes the columns look jagged.
  - **Units:** Add a "Units" column or specify units in the variable names (e.g., "Population (Millions)" or "Literacy (0-1)").

### Table 2: "District Characteristics by Banking Infrastructure Quartile"
**Page:** 9
- **Formatting:** Professional.
- **Clarity:** Very high. Quickly shows that banking density doesn't correlate linearly with literacy, which is a key part of the paper's identification discussion.
- **Storytelling:** Good, but could be merged with Table 1 to save space if needed.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Add standard deviations in parentheses below the means. Top journals generally expect to see the spread within groups, not just the mean, to evaluate the balance.

### Figure 2: "Event Study: Banking Intensity and Post-Demonetization Nightlight Growth"
**Page:** 12
- **Formatting:** Excellent. The shading for confidence intervals is clean. The vertical line at the reference year is standard.
- **Clarity:** The key finding (sharp drop in 2017) is visible in under 5 seconds.
- **Storytelling:** This is the "money shot" of the paper. It establishes pre-trends and the persistent shock.
- **Labeling:** Clear, though "Coefficient on banking intensity" could be more descriptive (e.g., "Elasticity of Nightlights w.r.t. Banking Density").
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Main Results: Banking Infrastructure and Post-Demonetization Nightlights"
**Page:** 14
- **Formatting:** Professional.
- **Clarity:** Logical progression from baseline to controls to temporal split.
- **Storytelling:** Effectively summarizes the regression results.
- **Labeling:** The variable names (e.g., `bank_per_100k x post`) are slightly "code-heavy." 
- **Recommendation:** **REVISE**
  - **Clean Labels:** Replace snake_case variable names with professional labels: "Bank Branches per 100k $\times$ Post," "Post (Short-Run: 2017–18)," etc.
  - **Redundancy:** Move "Fixed-effects" and "Fit statistics" rows to the same line if space is needed (e.g., "District & Year FE: Yes").

### Figure 3: "Nightlight Trends by Banking Infrastructure Quartile (2012–2023)"
**Page:** 15
- **Formatting:** Good use of colors.
- **Clarity:** A bit cluttered. The lines are very close together in the 2012–2016 period.
- **Storytelling:** Demonstrates the raw "convergence" without the regression machinery.
- **Labeling:** Title and legend are clear.
- **Recommendation:** **KEEP AS-IS** (Or consider making the Q1 and Q4 lines thicker to highlight the narrowing gap).

### Table 4: "Heterogeneity by Agricultural Structure"
**Page:** 16
- **Formatting:** Consistent with Table 3.
- **Clarity:** High. The comparison between Column 1 and 2 is stark.
- **Storytelling:** Crucial for the mechanism (the "mandi"/agricultural channel).
- **Labeling:** Needs cleaner variable names (replace `ag_share`).
- **Recommendation:** **REVISE**
  - Group columns 1 and 2 under a header "Subsample Analysis" and Column 3 under "Full Sample (Triple Interaction)" to help the reader navigate the logic.

### Figure 4: "Nightlight Trends by Agriculture and Banking Status"
**Page:** 17
- **Formatting:** Good.
- **Clarity:** Four lines start to get busy. 
- **Storytelling:** Directly supports the "Agricultural Channel" argument.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Consider a Panel A / Panel B approach. Panel A: High Ag (High vs Low Bank). Panel B: Low Ag (High vs Low Bank). This would make the "null effect" in non-ag districts even more obvious.

### Table 5: "Robustness Checks"
**Page:** 18
- **Formatting:** Tight, fits many specifications well.
- **Clarity:** Column headers are descriptive.
- **Storytelling:** Standard "everything holds up" table.
- **Labeling:** Clean.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Randomization Inference: Distribution of Placebo Coefficients"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** High. The distance between the orange line and the distribution is the key.
- **Storytelling:** Strong evidence that the result isn't a fluke.
- **Labeling:** "Actual = -0.01672" is a bit too many decimals for a plot; "-0.017" is enough.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Event Study with Baseline Controls"
**Page:** 20
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Shows the "null" clearly.
- **Storytelling:** Supports the "proxy for formality" argument.
- **Recommendation:** **KEEP AS-IS**

## Appendix Exhibits

### Table 6: "Variable Definitions"
**Page:** 27
- **Formatting:** Simple grid.
- **Clarity:** High.
- **Storytelling:** Vital for transparency.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 4 tables main, 6 figures main, 1 table appendix, 0 figures appendix.
- **General quality:** Extremely high. The paper follows the "Visual DiD" playbook perfectly (Event study $\rightarrow$ Pooled Table $\rightarrow$ Heterogeneity $\rightarrow$ Mechanism).
- **Strongest exhibits:** Figure 2 (Event Study) and Figure 5 (Randomization Inference). They provide immediate visual proof of the claim.
- **Weakest exhibits:** Table 2 (lacks SDs) and Table 3/4 (raw variable names from code).
- **Missing exhibits:** 
    1. **A Map:** A paper on "India's Economic Geography" is missing a map. A heat map of India showing `bank_per_100k` by district would be standard for AER/QJE.
    2. **Currency Replacement Map/Table:** Since the paper contrasts itself with Chodorow-Reich et al. (2020), a correlation plot or map comparing banking density with their currency replacement variable would be a strong addition.
- **Top 3 improvements:**
  1. **Clean up Table Labels:** Replace all `snake_case` variable names with LaTeX-formatted professional names across all tables.
  2. **Add a Map:** Include a district-level map of banking density to ground the "geography" aspect of the title.
  3. **Decimal Alignment:** In Table 1, align the decimals to make the descriptive statistics easier to scan. Large numbers like population should be scaled (e.g., "Population in Millions") to keep the digits comparable.