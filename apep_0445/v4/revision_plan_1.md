# Revision Plan 1 -- apep_0445 v3

**Date:** 2026-02-23
**Reviews:** GPT-5.2 (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Conditionally Accept)

---

## Priority 1: Identification and Design Framing

1. **Elevate local randomization inference to co-primary status.** GPT-5.2 argues that the McCrary rejection (t=5.03) means continuity-based RDD should not stand alone. Reframe the results section so that local randomization and continuity-based estimates are presented side-by-side as co-primary designs, not as main + robustness.

2. **Tighten estimand language throughout.** GPT-5.2 notes inconsistent use of "OZ designation," "OZ eligibility," and "LIC threshold bundle." Define the estimand precisely in Section 3 and enforce consistent language in all subsequent sections. Acknowledge compound treatment (LIC bundle) up front rather than only in limitations.

3. **Address covariate imbalance more carefully.** The current argument that imbalances "work against the null" needs more structure. Add pre-period outcome smoothness tests for information-sector and construction employment (not just total employment). Consider covariate-adjusted results as a more prominent specification.

## Priority 2: Data Center Measurement

4. **Address the stock-vs-flow concern for data center presence.** GPT-5.2 identifies this as a central weakness: the 2023 stock measure conflates pre-2018 legacy facilities with post-2018 siting decisions. If EIA-860 operational year data is available, split facilities into pre-2018 (placebo) and post-2018 (treatment-relevant). At minimum, quantify what share of facilities opened after 2018 and discuss the implied attenuation.

5. **Sharpen the MDE discussion.** Gemini notes the MDE is 233% of the base rate. Explicitly frame what the design can and cannot rule out -- it rules out state-level magnitude shifts but may miss smaller effects on marginal facilities.

## Priority 3: Presentation and Structure

6. **Strengthen fuzzy RDD presentation.** Report first-stage, reduced-form, and Wald estimates in one table on the same bandwidth/sample. Explain complier population and interpret LATE accordingly.

7. **Convert Introduction enumeration to prose.** Both Grok and GPT-5.2 flag the numbered "incentive hierarchy" list in the Introduction. Convert to paragraph form for consistency with journal norms.

8. **Move density discontinuity discussion earlier.** Rather than presenting the McCrary failure as a validity check resolved later, introduce it as a central design feature that motivates the dual-framework approach.

## Priority 4: Literature

9. **Add missing references.** Key additions flagged across reviewers:
   - McCrary (2008) -- formal citation for the density test
   - Lee and Card (2008) -- discrete running variable concerns
   - Busso, Gregory, and Kline (2014 AER) -- place-based employment effects
   - Kennedy and Wheeler (2022) -- OZ investment geography
   - Masanet et al. (2020 Science) -- data center energy constraints
   - Arefeva, Davis, and Ghent (2024) -- OZ capital geography

## Priority 5: Extensions (if feasible)

10. **First-stage heterogeneity by state.** Gemini suggests showing designation probability jumps for top data center states (VA, TX, CA, OH, GA).

11. **Infrastructure-specific heterogeneity.** GPT-5.2 suggests interacting with power/fiber proximity. Add if crude proxies are available.
