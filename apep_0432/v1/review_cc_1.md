# Internal Review (Claude Code) — Round 1

**Role:** Internal reviewer (Reviewer 2 mode)
**Model:** Claude Code (claude-opus-4-6)
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T12:45:00
**Route:** Internal review

---

## 1. FORMAT CHECK

- **Length**: 40 pages total, well above 25-page minimum. Main text before references is approximately 30-32 pages.
- **References**: Comprehensive — 48+ citations covering RDD methodology (Calonico et al., Imbens & Lemieux, Lee & Lemieux, Hahn et al.), PMGSY literature (Asher & Novosad, Aggarwal, Adukia et al.), gender norms (Jayachandran, Eswaran et al.), multiple testing (Benjamini & Hochberg, Romano & Wolf), and the opportunity cost mechanism (Shah & Steinberg).
- **Prose**: All major sections in paragraph form. No bullet-point-heavy sections.
- **Section depth**: Each section has 3+ substantive paragraphs.
- **Figures**: All figures use includegraphics with real data.
- **Tables**: All tables contain real numbers with SEs, p-values, and sample sizes.

**Format: PASS**

## 2. STATISTICAL METHODOLOGY

a) **Standard Errors**: PASS — Every coefficient has SEs in parentheses. Parametric models cluster at district level.

b) **Significance Testing**: PASS — p-values and stars reported consistently.

c) **Confidence Intervals**: PASS — 95% CIs added to Table 2. CIs discussed in text.

d) **Sample Sizes**: PASS — N_eff reported for all RDD tables. Total N for parametric.

e) **DiD**: N/A — RDD design.

f) **RDD**: PASS — State-of-the-art:
   - McCrary density test (T=0.068, p=0.945)
   - MSE-optimal bandwidth via rdrobust
   - Bandwidth sensitivity (0.5x to 2x)
   - Polynomial order sensitivity (1-3)
   - Placebo thresholds at 6 cutoffs
   - Donut hole (±10)
   - Covariate balance (8 covariates, all p>0.05)

**Multiple testing**: Benjamini-Hochberg q-values reported within outcome families. Transparent about fragility of individual estimates.

**Methodology: PASS**

## 3. IDENTIFICATION STRATEGY

**Credible.** The PMGSY 500-person threshold creates a sharp discontinuity in eligibility using pre-program Census 2001 population. Manipulation is implausible (census conducted before program announcement). Balance tests pass. Placebo cutoffs produce nulls.

**Strengths:**
- ITT framing is appropriate and transparently discussed
- Split-sample + parametric interactions complement each other
- The opportunity cost mechanism is well-motivated

**Concerns (addressable):**
- First stage on actual road receipt not shown (acknowledged as limitation)
- 250-threshold non-replication discussed but not fully explained
- Nightlights and EC outcomes are null, creating tension with "roads raised opportunity cost" mechanism — the paper handles this by noting modest marginal effects at the threshold

**Identification: PASS with noted limitations**

## 4. LITERATURE

**Well-positioned.** The paper engages thoroughly with:
- PMGSY evaluation literature (Asher & Novosad 2020, Aggarwal 2018, Adukia et al. 2020)
- RDD methodology (Calonico et al. 2014, 2015; Imbens & Lemieux 2008; Lee & Lemieux 2010; Hahn et al. 2001)
- Gender norms and development (Jayachandran 2015, Goldin 1995, Eswaran et al. 2013)
- Opportunity cost of schooling (Shah & Steinberg 2017, 2021)
- Multiple testing (Benjamini & Hochberg 1995)

**No major gaps.**

## 5. WRITING QUALITY

a) **Prose vs. Bullets**: PASS — Full paragraphs throughout.

b) **Narrative Flow**: Strong. The "Roads Don't Break Purdah — But They Disrupt Education" framing creates a compelling arc from the null employment result to the literacy disruption finding.

c) **Sentence Quality**: Good. Active voice predominant. Magnitudes well-contextualized ("one-third of the expected educational catch-up for that decade").

d) **Accessibility**: Good. RDD intuition explained clearly. Caste context provided for non-specialists.

e) **Tables**: Well-structured with notes. CI column added to Table 2.

**Writing: PASS**

## 6. CONSTRUCTIVE SUGGESTIONS

1. **Male literacy vs. Female literacy decomposition**: The finding that BOTH decline is powerful. Consider adding a figure that directly overlays male and female literacy RDD plots for ST villages.

2. **School availability**: If SHRUG has school distance or availability measures, testing for a supply-side channel would strengthen the opportunity cost interpretation.

3. **Dynamic effects**: Consider whether Economic Census 2005 (midway between Census waves) shows any intermediate effects.

## 7. OVERALL ASSESSMENT

**Key strengths:**
- Bulletproof RDD with comprehensive validity checks
- Novel finding: roads cause general educational disruption (both genders) in tribal areas
- Transparent about limitations (null first stage, BH corrections, 250 non-replication)
- Well-written with clear narrative arc

**Critical weaknesses:**
- None that would prevent publication

**Minor weaknesses:**
- No direct first-stage on road receipt
- Individual subgroup estimates fragile to multiple testing
- @CONTRIBUTOR_GITHUB placeholder in author block (structural — will be replaced at publish)

DECISION: MINOR REVISION
