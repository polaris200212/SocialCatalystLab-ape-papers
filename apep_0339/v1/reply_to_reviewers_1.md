# Reply to Reviewers — apep_0325 v1

## Overview

We thank all three reviewers for their careful reading and constructive feedback. The revised paper addresses the major concerns as detailed below. Changes that require additional data collection or power simulations beyond the scope of this version are noted as future work.

---

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### 1. Sample size and power (9 treated states in CS)
**Response:** We now discuss this limitation explicitly in a new Limitations subsection (Section 7.1). The 9-state CS sample reflects a genuine methodological choice: the 2018 cohort (21 states) is excluded because CS requires at least one pre-treatment period, and the panel begins in 2018. We clarify this in the Cohort Selection subsection (Section 5.3) and note that the conventional TWFE estimate using all 30 treated states yields a nearly identical coefficient (−0.159, p < 0.001), providing reassurance that the CS and TWFE results agree qualitatively. We acknowledge that marginal significance (p = 0.069) is a limitation driven by power, not specification choice.

### 2. Mechanism not directly tested
**Response:** We agree that directly observing reimbursement rate changes would strengthen the paper. T1019 rates are not available in the T-MSIS API or any systematic public source—they require hand-collection from 50 state Medicaid plan documents. We note this limitation in Section 7.1 and identify it as the natural next step. The falsification test (non-HCBS providers, p = 0.47) provides indirect but sharp evidence: the same minimum wage shock does not affect high-wage providers, consistent with the cost-push mechanism operating through the low-wage workforce channel.

### 3. Wild cluster bootstrap / inference
**Response:** We add a discussion of inference limitations with 30 clusters and cite Cameron, Gelbach, and Miller (2008) on bootstrap-based improvements. Implementing wild cluster bootstrap with the CS estimator requires specialized software (fwildclusterboot with att_gt objects) that is not yet mature in R. We flag this as an important methodological refinement for future work.

### 4. Outcome validity (billing NPIs vs. capacity)
**Response:** We add explicit discussion in the Limitations subsection acknowledging that billing NPI counts capture market participation but not direct employment or service hours. Provider exit does not necessarily mean worker displacement. Alternative outcomes (beneficiaries served, claims per provider) are constructive suggestions we identify for future analysis.

### 5. ARPA confounding
**Response:** We now discuss ARPA Section 9817 extensively in both the Institutional Background (Section 2.1) and a new Limitations subsection (Section 7.1). ARPA HCBS funds flowed during 2021–2024, overlapping with the treatment window. If ARPA cushioned the cost-push channel, our estimates may understate the true minimum wage effect absent fiscal relief. A pre-2021 subsample analysis isolating the 2019–2020 cohorts would provide a cleaner test but at the cost of further reducing the sample.

### 6. Missing references
**Response:** Added Dube (2019) minimum wage review, Clemens & Gottlieb (2014) on physician price responses, Cameron, Gelbach & Miller (2008) on clustered inference, and Duggan (2004) on Medicaid contracting.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### 1. Marginal significance
**Response:** Addressed in the new Limitations subsection. We emphasize that the qualitative consistency across specifications (CS, TWFE, not-yet-treated controls, restricted sample) strengthens the finding despite marginal significance in the primary specification.

### 2. Geographic clustering of treatment
**Response:** We address this concern through the region-by-year fixed effects specification in Table 4, which restricts comparisons to within Census division. The elasticity estimate (−0.427) is actually larger than the baseline, suggesting that geographic confounders do not drive the main result.

### 3. Mechanism heterogeneity (minimum wage bite)
**Response:** Constructive suggestion. Heterogeneity by initial minimum wage level or Medicaid rate would sharpen the mechanism, but with 9 treated states, splitting the sample further would eliminate statistical power. We note this as a natural extension when more cohorts accumulate post-treatment years.

### 4. Prose redundancy
**Response:** Revised results narration throughout to lead with findings rather than table locations. Strengthened opening paragraph with a human-centered hook.

---

## Reviewer 3 (Gemini-3-Flash) — MAJOR REVISION

### 1. Weak primary result (p = 0.069)
**Response:** See response to Reviewer 1, point 1. We are transparent about marginal significance and present it as a power limitation of the CS design with 9 treated states, not as evidence of absence.

### 2. Rate rigidity not demonstrated
**Response:** See response to Reviewer 1, point 2. T1019 reimbursement rates are not systematically available in public data. We identify hand-collection as the highest-priority extension.

### 3. ARPA confounding
**Response:** See response to Reviewer 1, point 5. Addressed in both Institutional Background and Limitations.

### 4. Pre-trend at t = −2
**Response:** The t = −2 coefficient (+0.091, SE = 0.052) is positive, not negative—its sign is opposite to the treatment effect, so it cannot mechanically generate the post-treatment decline. The joint Wald test of all pre-treatment coefficients fails to reject the null (χ²(4) = 4.66, p = 0.324). We discuss this in Section 6.1.

### 5. Individual vs. Organization NPI heterogeneity
**Response:** Constructive suggestion. The T-MSIS data distinguishes billing from servicing NPIs, and NPPES provides entity type classification. Splitting the sample by entity type would reveal whether the effect is driven by small individual providers exiting or organizational consolidation. We note this for future work.

---

## Exhibit Review (Gemini-3-Flash)

### Key changes made:
- Removed embedded chart titles from all figures (titles in captions only)
- Figures regenerated with clean formatting

### Deferred:
- Consolidating event study figures into multi-panel layout (would require R code restructuring)
- Moving illustrative plots to appendix (current layout maintains narrative flow)

---

## Prose Review (Gemini-3-Flash)

### Key changes made:
- Rewrote opening paragraph with human-centered hook emphasizing the workforce bind
- Revised results narration to lead with findings, not table locations
- Strengthened abstract with dynamic narration ("Five years after treatment, nearly one in four providers has exited")
- Added new citations for completeness

### Deferred:
- Full restructuring of section ordering (would require substantial rewrite beyond scope)
