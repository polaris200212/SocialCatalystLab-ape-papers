# Internal Review - Round 1

**Reviewer:** Claude Code (self-review as Reviewer 2)
**Paper:** "Coverage Cliffs and the Cost of Discontinuity: Health Insurance Transitions at Age 26"
**Date:** 2026-02-09

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** ~26 pages of main text (before references/appendix). Meets the 25-page minimum.
- **References:** Adequate coverage of the ACA dependent coverage literature (Sommers, Antwi, Barbaresco, Simon), RDD methodology (Cattaneo, Calonico, Lee & Lemieux, Kolesár & Rothe, McCrary), and health economics (Card et al., Currie & Gruber). Missing Goodman-Bacon (2021) and Callaway & Sant'Anna (2021) — though these are DiD-specific and less critical for an RD paper.
- **Prose:** All major sections are written in full paragraphs. No bullet point sections.
- **Section depth:** Each major section has 3+ substantive paragraphs.
- **Figures:** 11 figures referenced; all appear to render correctly.
- **Tables:** 10 tables with real numeric values. No placeholders detected.

### 2. Statistical Methodology

**a) Standard Errors:** All regression tables report robust bias-corrected SEs in parentheses from rdrobust. PASS.

**b) Significance Testing:** Main results report p-values. Permutation inference provides nonparametric confirmation. The rdrobust p-values for the main outcomes (Medicaid p=0.012, Private p=0.019) are significant at the 5% level but NOT at the 1% level. The text claims significance "at the 0.1 percent level (p < 0.001) in the local randomization framework" (p.19) — this conflates the OLS-detrended permutation p-value with the rdrobust p-value. The rdrobust p-values should be reported more prominently since rdrobust is the primary specification. Minor concern.

**c) Confidence Intervals:** 95% CIs reported in Tables 2, 5, 6, 7, 8. PASS.

**d) Sample Sizes:** N reported in all regression tables. PASS.

**e) RDD-specific:** Bandwidth sensitivity (Table 6), McCrary density test (Section 9.1), placebo tests at non-policy ages (Table 4), covariate balance (Table 3). Comprehensive. PASS.

**f) Discrete running variable:** Addressed through jitter + subsample approach with discussion of Lee & Card (2008) and Kolesár & Rothe (2018). The approach is reasonable but somewhat ad hoc — no formal justification that jitter preserves inference properties. The year-by-year stability provides indirect validation. Acceptable.

### 3. Identification Strategy

**Strengths:**
- Clean institutional setting (federal age-26 cutoff, no manipulation possible)
- Density test passes (p=0.492)
- Placebo tests at other ages show no spurious discontinuities
- Balance tests largely pass (marital status clean)
- Plan termination timing limitation acknowledged upfront

**Concerns:**
- Education imbalance (small but significant discontinuity in college education at 26). The paper acknowledges this and shows covariate adjustment increases the estimate, which is reassuring. But the imbalance itself is puzzling — why would education jump at age 26? This could reflect differential fertility timing by education, which would be a composition effect, not a balance failure per se. The paper could discuss this more.
- The "first stage" is somewhat circular: the paper uses payment source from natality data as both the first stage and the main outcome. A true first stage would use external insurance coverage data (ACS PUMS). The paper acknowledges this framing but calling it "first stage" is generous.

### 4. Literature

Literature coverage is adequate. Missing but not critical:
- Imbens & Kalyanaraman (2012) on optimal bandwidth for RD
- Cattaneo, Jansson & Ma (2020) on rdrobust
- Depew & Bailey (2015) on age-26 and fertility
- Abramowitz (2016) on ACA dependent coverage and young adult labor

### 5. Writing Quality

The prose is excellent — engaging, well-structured, and accessible. The introduction effectively motivates the research question with the "seams" metaphor. Sections flow logically. Technical details are explained clearly for a general audience.

Minor issues:
- Section 6.3 text still references "rdrandinf function from the rdlocrand package" but the actual implementation is OLS-detrended permutation. Should update this description.
- The paper could be tightened in places — the institutional background section is thorough but somewhat long for what is ultimately a well-known policy.

### 6. Substantive Concerns

**A. Magnitude discrepancy between rdrobust and OLS estimates:** The rdrobust estimate for Medicaid is +1.1 pp while the OLS-detrended estimate is +2.6 pp. This is a factor of 2.4x difference. The paper attributes this to "global linear trend vs. local nonlinearity" but this deserves more discussion. Which estimate should readers trust? The rdrobust estimate is the standard in the literature, but the OLS estimate uses the full sample. The discrepancy suggests the age-Medicaid relationship is significantly nonlinear.

**B. Significance levels:** The main rdrobust estimates are significant at p<0.05 but not p<0.01. For a paper making strong causal claims about a well-studied policy, some readers may find 5% significance underwhelming, especially given the massive sample size (1.4M in the estimation subsample). The paper should be more transparent about the significance levels of the primary specification (rdrobust) rather than leading with the permutation p-values.

**C. Subgroup heterogeneity is weak:** None of the four education×marital status subgroups achieves significance. The paper now appropriately acknowledges this, but the heterogeneity analysis adds little to the contribution.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Strengthen the first-stage:** If feasible, incorporate ACS PUMS data showing the insurance coverage discontinuity at 26 in the general population. This would provide a true first stage separate from the natality outcome data.

2. **Address the magnitude gap:** Add a brief discussion or appendix table showing how estimates vary with polynomial order in both the rdrobust and OLS frameworks. This would help readers understand why the two approaches give different magnitudes.

3. **Sharpen the contribution:** The paper's strongest finding is the near-zero self-pay effect combined with the Medicaid-private swap. This "safety net works" finding could be framed more prominently as the main contribution, rather than the (relatively small) treatment effect itself.

4. **State-level analysis:** The paper acknowledges the public-use files lack state identifiers. If restricted-use files could be obtained, Medicaid expansion heterogeneity would substantially strengthen the paper.

5. **Report rdrobust p-values prominently:** Table 2 shows p=0.012 for Medicaid and p=0.019 for Private. The text should lead with these rather than the permutation p-values, since rdrobust is the primary specification.

---

## 7. Overall Assessment

**Strengths:**
- Clean identification strategy with a sharp institutional cutoff
- Massive sample size (13M births pooled over 8 years)
- Comprehensive robustness: polynomial, kernel, bandwidth, donut-hole, covariate adjustment
- Well-powered null results on health outcomes with explicit MDE calculations
- Excellent prose quality and clear exposition

**Weaknesses:**
- The marginal significance of the primary rdrobust estimates (p≈0.01-0.02) is somewhat surprising given the enormous sample
- The discrete running variable (9 integer age values) limits the effective variation
- The "first stage" from natality data is not a true first stage
- Subgroup heterogeneity results are uninformative

**Overall:** This is a competent applied RD paper that documents a real but modest coverage transition at age 26. The identification is credible, the robustness checks are thorough, and the null health findings are well-powered and informative. The main limitation is that the effect sizes are small and the policy setting is well-studied. The paper's best contribution is the combination of (1) high-powered null health effects and (2) the "safety net works" interpretation.

DECISION: MINOR REVISION
