# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (self-review)
**Paper:** Where the Sun Don't Shine: The Null Effect of IRA Energy Community Bonus Credits on Clean Energy Investment
**Date:** 2026-02-19

---

## 1. Format Check

- **Length:** 30 pages total, main text ends page 25. PASS.
- **References:** 9 references. Adequate for an RDD paper but could benefit from additional citations (see Section 4).
- **Prose:** All sections written in paragraph form. PASS.
- **Section depth:** Each section has 3+ substantive paragraphs. PASS.
- **Figures/Tables:** All 7 figures and 5 tables contain real data. PASS.

## 2. Statistical Methodology

- **Standard errors:** All coefficients report robust SEs in parentheses. PASS.
- **Significance testing:** P-values from robust bias-corrected inference reported. PASS.
- **Confidence intervals:** Not explicitly displayed but implied by SE + p-value. Could add 95% CIs to Table 2.
- **Sample sizes:** N(left) and N(right) reported for all RDD specs. PASS.
- **RDD methodology:** Uses rdrobust with CCT optimal bandwidth. McCrary density test included (p=0.33). Bandwidth sensitivity across 6 multipliers. PASS.

## 3. Identification Strategy

**Strengths:**
- Sharp RDD with clear institutional motivation
- McCrary test confirms no manipulation
- Covariate balance (6/7 pass)
- Placebo cutoffs at 9 alternative thresholds
- Treatment proxy discussion (ACS vs LAUS, 2021 vs "since 2009")

**Concerns:**
- Small effective sample (N=40 at optimal bandwidth). Power is limited.
- The coefficient magnitude (-8.14 vs mean 0.84) is large and driven by local extrapolation with few observations
- The donut at 0.03 flips sign, suggesting sensitivity to influential observations
- Using 2023 data to evaluate a 2022 policy gives only ~1 year of post-treatment

## 4. Literature

The paper cites foundational RDD work (Calonico et al. 2014, Cattaneo et al. 2020) and relevant policy literature (Bistline et al. 2023, Holland et al. 2025). Missing:
- Lee & Lemieux (2010) "Regression Discontinuity Designs in Economics" — canonical RDD guide
- Imbens & Lemieux (2008) — another foundational RDD reference
- Aldy et al. (2024) or similar IRA implementation analyses

## 5. Writing Quality

The prose is strong. The introduction hooks with a clear tension between policy promise and empirical reality. Results are narrated rather than mechanically described. The "Physics vs. Policy" framing is compelling. Minor issues: the roadmap paragraph could be shortened.

## 6. Constructive Suggestions

1. **Zoomed-in RDD plot:** The main figure is dominated by outliers far from the cutoff. A zoomed version focusing on the 0-1% range would better visualize the discontinuity.
2. **Winsorize or trim outliers:** Check if a few extreme observations drive the large coefficient.
3. **95% confidence intervals:** Add to Table 2 for easier interpretation.
4. **First-stage validation:** Compare your constructed treatment to Treasury's published energy community lists for the same year.

## 7. Overall Assessment

**Strengths:** Novel research question, clean institutional setting for RDD, thorough robustness checks, honest engagement with negative/null results, excellent prose.

**Weaknesses:** Small sample near cutoff, coefficient magnitude concerns, limited post-treatment window, treatment is a proxy for statutory designation.

**This is a well-executed paper with an interesting finding. The main limitation is statistical power, which is inherent to the research design.**

DECISION: MINOR REVISION
