# Internal Review — Claude Code (Round 1)

**Role:** Internal reviewer
**Reviewer:** Claude Code (Opus 4.6)
**Paper:** Connecting the Most Remote: Road Eligibility and Development in India's Tribal Periphery
**Date:** 2026-02-20

---

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** ~38 pages including appendix, ~26 pages main text. Meets the 25-page minimum.
- **References:** Comprehensive bibliography with 30+ references covering RDD methodology, Indian development, transportation infrastructure, and gender economics.
- **Prose:** All major sections written in full paragraphs. No bullet-point results.
- **Section depth:** Each section has multiple substantive paragraphs.
- **Figures:** All 7 figures contain real data with proper axes and labels.
- **Tables:** All 3 tables contain real numerical values.

### Statistical Methodology
- **Standard Errors:** All coefficients reported with robust bias-corrected SEs in parentheses. PASS.
- **Significance Testing:** Stars and p-values reported throughout. PASS.
- **Sample Sizes:** Effective N reported for all RDD specifications. PASS.
- **RDD Requirements:** McCrary density test (p=0.546), bandwidth sensitivity (0.5× to 2×), placebo thresholds, donut-hole specification, polynomial sensitivity. PASS.
- **Covariate Balance:** 7 pre-treatment variables tested, all insignificant. PASS.

### Identification Strategy
The 250-threshold RDD in designated areas is credible. The key strengths are:
1. No evidence of manipulation (McCrary p=0.546)
2. Comprehensive covariate balance
3. Null results at all 5 placebo thresholds
4. Null results at the 500 threshold in plains (important specificity check)
5. Nightlight event study showing no pre-trends

**Concern:** The ITT interpretation is well-discussed, but without a first stage, we cannot know how much of the eligible population actually received roads. The paper acknowledges this limitation clearly.

### Literature
The paper engages well with Asher & Novosad (2020), Calonico et al. (2014), Henderson et al. (2012), and the broader infrastructure-development literature. The gender-focused citations (Muralidharan & Prakash, Beaman et al., Dinkelman) are appropriate.

**Missing reference:** Aggarwal (2018) is cited but could be engaged more deeply given it directly studies PMGSY. The Lehne et al. (2018) citation on political allocation is well-placed.

### Writing Quality
Strong prose overall. The institutional background section is particularly vivid. The revised opening (monsoon imagery) is effective. Some technical clutter remains in the results section (bandwidth numbers, effective samples) but this is standard for the RDD literature.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Map figure:** A map of India highlighting the 11 Special Category States would help international readers visualize the "periphery" described in the title.

2. **Heterogeneity:** Consider reporting estimates separately for northeastern states vs. western hill states (HP, Uttarakhand, J&K) to explore whether effects vary by geography.

3. **LATE estimation:** Even without first-stage data, the paper could discuss what the LATE would be under plausible compliance rates (e.g., if 50% of eligible villages received roads, the LATE is roughly double the ITT).

4. **Welfare calculation:** The back-of-the-envelope cost-benefit is valuable but could be formalized with a simple welfare calculation following Donaldson (2018).

## OVERALL ASSESSMENT

**Strengths:** Clean identification, comprehensive robustness, important policy question, strong nightlight results.

**Weaknesses:** Only ITT (no first stage), overall literacy borderline significant, some imprecision in labor market outcomes.

**Verdict:** This is a solid paper with a credible design and meaningful results. The female literacy and nightlight findings are robust and policy-relevant.

DECISION: MINOR REVISION
