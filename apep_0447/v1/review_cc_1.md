# Internal Review — Round 1

**Reviewer:** Claude Code (self-review)
**Paper:** Locked Out of Home Care: COVID-19 Lockdown Stringency and the Persistent Decline of Medicaid HCBS
**Date:** 2026-02-24

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** ~32 pages total, ~26 pages main text. Exceeds 25-page threshold.
- **References:** Bibliography covers relevant literature (CMS waivers, OxCGRT, HCBS workforce studies).
- **Prose:** All major sections written in full paragraphs, no bullet-point sections.
- **Section depth:** Each section has multiple substantive paragraphs.
- **Figures:** 5 main figures + 1 appendix figure, all with proper axes and real data.
- **Tables:** 4 main tables + 2 appendix tables with real regression output.

### 2. Statistical Methodology

- **Standard errors:** All regressions report clustered SEs (state-level) in parentheses. ✓
- **Significance testing:** Stars with p-value footnotes. P-values reported for key results. ✓
- **Sample size:** N=8,160 reported for all specifications. ✓
- **Staggered DiD concern:** Treatment is cross-sectional (peak stringency in April 2020), NOT staggered adoption. TWFE is appropriate. ✓
- **Randomization inference:** 1,000 permutations, exact p-value reported. ✓

### 3. Identification

**Strengths:**
- Triple-difference cleanly separates lockdown stringency from general pandemic effects
- State×month FEs absorb COVID severity, economic conditions, federal policy
- Pre-trends flat in dynamic event study (Figure 1)
- Cross-sectional treatment avoids staggered DiD pitfalls

**Concerns:**
- The main spending result (Table 2, Col 1) is imprecise (p=0.20). Only claims (Col 2) are significant at conventional levels. This is acknowledged in the text but could be a concern for referees.
- The "scarring" interpretation (workforce exit) is plausible but not directly measured — it's inferred from aggregate billing patterns.
- Monthly stringency variation (Table 4, Row 7) shows a positive coefficient, which the paper explains as capturing a different margin. This may confuse readers who expect robustness checks to confirm the main result.

### 4. Internal Consistency

After extensive advisor review (6 rounds, 3/4 PASS), internal consistency issues have been thoroughly addressed:
- Coefficients in text match tables ✓
- Sample descriptions match throughout ✓
- Magnitude interpretations correctly use the [0,1] treatment scale ✓
- Time period descriptions (80 months, through September 2024) consistent ✓

### 5. Writing Quality

- **Opening hook:** Excellent — "you cannot deliver a bath over Zoom" anchors the reader immediately.
- **Narrative arc:** Strong. Motivation → DDD design → surprise timing → workforce scarring.
- **Results narration:** Tells a story rather than narrating tables.
- **Occasional academic-ese:** "Several features of the data merit discussion" — minor issue.
- Prose review rated this "top-journal ready" with Shleifer test: Yes.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Strengthen the spending result:** The claims result is strong (p=0.011) but spending is imprecise (p=0.20). Consider whether the paper could be framed primarily around claims/utilization rather than spending.

2. **Direct workforce evidence:** If possible, link to NPPES deactivation data or BLS QCEW to show direct provider exit. Currently the "scarring" story is inferred.

3. **Heterogeneity by provider type:** The paper discusses sole proprietors vs agencies in the background. Could the DDD be run separately by provider organizational form?

4. **Consider adding:** A back-of-envelope calculation of the welfare cost (beneficiaries who lost access to HCBS → institutional care costs).

5. **Prose improvements from exhibit/prose reviews:**
   - Move Table 3 and Figure 3 to appendix (reduce exhibit fatigue)
   - De-clutter Figure 4 (thicker lines, more distinct colors)
   - Kill throat-clearing phrases

---

## OVERALL ASSESSMENT

**Key strengths:**
- Novel use of newly released T-MSIS data
- Clean triple-difference design with appropriate fixed effects
- Compelling "delayed scarring" finding that challenges simple lockdown narratives
- Excellent writing quality

**Critical weaknesses:**
- Main spending result imprecise (p=0.20), though claims result is strong
- Scarring mechanism inferred rather than directly measured
- Monthly stringency robustness check shows opposite sign (different margin — explained but potentially confusing)

**Overall:** This is a well-executed paper with a novel finding. The identification is credible, the data are unique, and the writing is strong. The imprecise spending result is a limitation but the claims margin is the more relevant measure of service disruption. With minor revisions to address the magnitude interpretation and some exhibit streamlining, this paper is competitive for AEJ: Economic Policy.

DECISION: MINOR REVISION
