# Internal Review — Round 1

**Reviewer:** Claude Code (self-review)
**Date:** 2026-02-20
**Mode:** Reviewer 2 (harsh, skeptical)

---

## 1. Format Check

- **Length:** ~32 pages main text, well above the 25-page minimum.
- **References:** 44 entries covering JJM, NFHS, water infrastructure, DiD methodology, and development economics. Adequate.
- **Prose:** All major sections in paragraph form. No bullet-point narration.
- **Section depth:** Each section has 3+ substantive paragraphs.
- **Figures/Tables:** 8 figures, 8 main tables, 6 appendix tables. All contain real data.

## 2. Statistical Methodology

- **Standard errors:** All regressions report SEs in parentheses, clustered at state level (35 clusters).
- **Inference:** Significance stars defined. RI p-values and wild cluster bootstrap reported.
- **Sample sizes:** N = 629 consistently reported.
- **Design:** Cross-sectional Bartik exposure, not staggered DiD — avoids TWFE issues.
- **First-stage F:** >1,000 — no weak instrument concerns.
- **Concern:** With 35 clusters, the wild cluster bootstrap and RI provide important corrections. These are included.

## 3. Identification Strategy

**Strengths:**
- Bartik-style design exploiting baseline deficit as exposure measure is creative.
- Strong first stage (F > 1,000) with tight binscatter.
- Extensive robustness: LOSO, RI, Oster bounds, Conley bounds, multiple hypothesis testing.
- Nightlights placebo provides clean exclusion restriction support.

**Concerns:**
- The baseline water deficit likely correlates with general underdevelopment. The exclusion restriction requires that conditional on state FE and controls, the deficit has no direct effect on education. The Oster delta of 4.7 is reassuring but not definitive.
- The significant placebo results for child marriage and health insurance (from 04_robustness.R) are concerning, though the paper's main placebo table uses different outcomes (sex ratio, TV, electricity) which are all insignificant. This difference should be acknowledged.
- Cross-sectional design cannot test parallel pre-trends. The NFHS-3 to NFHS-4 period would be ideal but may not have compatible district definitions.

## 4. Literature

The paper cites the main JJM, NFHS, and water infrastructure literature. Missing references:
- Devoto et al. (2012) on water connections and time use in Morocco
- Kremer et al. (2011) on spring protection in Kenya (health pathway)
- Could cite the WASH literature more broadly

## 5. Writing Quality

Prose is strong — hooks the reader with the Red Fort announcement, maintains narrative throughout. Abstract is concise (under 150 words). Results tell a story rather than narrating tables. The diarrhea discussion is handled honestly.

## 6. Constructive Suggestions

1. Add a discussion of the significant child marriage and health insurance placebos from the robustness code. These suggest the water deficit captures broader development convergence.
2. Consider adding a Bartik shift-share decomposition (Goldsmith-Pinkham et al. 2020 style) to formally test the identifying assumption.
3. The cost-effectiveness calculation would benefit from a discount rate and comparison to other interventions (e.g., Conditional Cash Transfers).

## 7. Overall Assessment

**Strengths:** Novel question, strong first stage, extensive robustness, honest treatment of limitations.
**Weaknesses:** Cross-sectional design limits causal claims; some placebos suggest broader convergence pattern; mechanism could be tighter.

DECISION: MINOR REVISION
