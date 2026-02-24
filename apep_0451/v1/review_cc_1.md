# Internal Review — Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Cocoa Booms and Human Capital in Ghana
**Date:** 2026-02-24

---

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** 25 pages main text (pages 1-25). Meets threshold.
- **References:** 45+ references in bibliography, strong coverage of commodity-education literature, econometric methods, and Ghana-specific studies.
- **Prose:** All major sections in paragraph form. No bullet-point results.
- **Section depth:** Each section has 3+ substantive paragraphs.
- **Figures:** 6 figures with visible data, proper axes, appropriate labels.
- **Tables:** 6 tables with real regression output.

### Statistical Methodology
- Standard errors reported in parentheses for all coefficients. PASS.
- Significance stars defined. PASS.
- Sample sizes reported for all regressions. PASS.
- Not staggered DiD — two-period comparison (2000 vs 2010). PASS.
- DR DiD estimates complement Bartik specification. PASS.
- **Concern:** Few clusters (6 in forest belt). Paper now correctly acknowledges this limitation and uses DR DiD with influence-function SEs as partial remedy.

### Identification Strategy
- Bartik design exploiting geographic cocoa shares × world price changes. Credible.
- Pre-trend tests using 1984-2000: all coefficients near zero. Strong.
- Event study with 3 periods. Clean "flat pre, sharp post" pattern.
- Migration test, negative control (gender composition), sensitivity analysis (Cinelli-Hazlett). Adequate.
- Forest-belt restriction ensures ecological comparability. Good design choice.
- **Concern:** Only 6 clusters. Cannot be fully overcome but is handled honestly.

### Literature
- Comprehensive engagement with commodity-education literature (Kruger, Edmonds, Cogneau, Beegle).
- Resource curse debate covered (Sachs-Warner, van der Ploeg, Allcott-Keniston).
- Methodological references adequate (Sant'Anna-Zhao, Goldsmith-Pinkham, Cameron-Gelbach-Miller, Cinelli-Hazlett).
- Ghana-specific context well-cited (Kolavalli-Vigneri, Aryeetey-Kanbur).
- No critical gaps.

### Writing Quality
- Strong opening hook with the $906-to-$2800 price shock.
- Clear theoretical framework.
- Results section avoids excessive "column X of Table Y" narration.
- Discussion engages meaningfully with the broader literature.
- Minor areas for improvement: some "throat-clearing" in Related Literature section.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **DR DiD results table:** The DR DiD results are only reported in text. Adding a table showing both Bartik and DR DiD side-by-side would strengthen transparency.
2. **Heterogeneity by gender:** The age-gender heterogeneity table (Table 4) shows insignificant results. Consider whether a triple-diff specification (cocoa × post × female) would yield more precise gender estimates.
3. **Long-run effects:** Could examine 2010 census cohort effects — children of specific birth cohorts who were school-age during different phases of the boom.

## OVERALL ASSESSMENT

- **Key strengths:** Novel census microdata for Ghana; clean pre-trends; multiple estimation strategies; thorough engagement with literature.
- **Critical weaknesses:** Few clusters (inherent limitation); DR DiD results not in tables; literacy pre-trend unavailable.
- **Specific suggestions:** Add DR DiD results table; discuss COCOBOD pass-through more quantitatively.

DECISION: MINOR REVISION
