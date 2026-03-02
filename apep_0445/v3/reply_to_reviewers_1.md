# Reply to Reviewers 1 -- apep_0445 v3

**Date:** 2026-02-23

We thank all three reviewers for their careful reading and constructive feedback. This document provides a point-by-point response. Many issues raised apply to aspects inherited from the parent paper (apep_0445 v2); we address them in this revision.

---

## Reviewer 1: GPT-5.2 (Major Revision)

### Format
> Convert Intro enumerate to prose.

**Done.** The "incentive hierarchy" enumeration in the Introduction has been converted to a prose paragraph.

### Methodology

> (2c) Discrete/heaped running variable: local randomization should be co-primary, not auxiliary.

**Addressed.** We have elevated local randomization inference to co-primary status. The results section now presents continuity-based (rdrobust) and design-based (local randomization) estimates side-by-side. We pre-specify windows of +/-0.5pp and +/-1.0pp justified by the mass-point structure.

> Report a common bandwidth version for comparability across outcomes.

**Addressed.** We add a common-bandwidth specification table to facilitate comparability across outcomes and between first-stage and reduced-form estimates.

> Report first-stage, reduced form, and Wald in one table on same sample.

**Addressed.** The fuzzy RDD presentation now includes all three components in a unified table with matched bandwidth and sample.

### Identification

> (i) Density discontinuity is a design fork, not a footnote.

**Addressed.** We restructure the presentation so that the McCrary rejection is introduced early as a central design feature motivating the dual-framework (continuity + local randomization) approach, rather than appearing only in a validity section.

> (ii) Covariate imbalance: cannot argue "works against the null" without more structure.

**Partially addressed.** We add pre-period outcome smoothness tests for information-sector and construction employment alongside total employment. We make covariate-adjusted results more prominent. We acknowledge that the direction of bias from imbalances is ambiguous without further structure.

> (iii) Direct data center measure is 2023 stock, not post-2018 flow.

**Partially addressed.** We investigate whether EIA-860 operational year data permits a pre-2018/post-2018 split. If available, we run the placebo test (pre-2018 stock should show no discontinuity) and the flow test (post-2018 openings). We add discussion quantifying the likely share of post-2018 facilities and the implied attenuation of the stock measure.

> (iv) Compound treatment at the cutoff (LIC bundle).

**Addressed.** We tighten the estimand language throughout to consistently describe the treatment as "eligibility for OZ designation via the poverty channel (and correlated LIC-linked programs)." We avoid overinterpreting the null as purely "OZ fails" and frame it as the bundle effect of crossing the LIC threshold.

### Literature

> Add McCrary (2008), Cattaneo et al. (2020), Lee and Card (2008), GAO (2022), Arefeva et al. (2024), Elliott (2023), Masanet et al. (2020).

**Addressed.** We add McCrary (2008), Lee and Card (2008), and Masanet et al. (2020) as these are most directly relevant. We verify and add the OZ evaluation references where they strengthen the positioning. Some suggested references are verified for accuracy before inclusion.

### Writing

> Be more disciplined about the estimand.

**Addressed.** See compound treatment response above. Estimand is defined once and used consistently.

> Move the key design fork earlier.

**Addressed.** See density discontinuity response above.

> Translate DC null into interpretable magnitudes.

**Addressed.** We add "facilities per 10,000 tracts" and percentage-change interpretations, with a caveat about undercounting smaller facilities.

### Constructive Suggestions

> (A) Make local randomization co-primary. **Done.** See above.

> (B) Improve DC outcome to capture new investment. **Partially done.** We investigate EIA-860 dates and add discussion of stock-vs-flow attenuation.

> (C) Clarify OZ vs. LIC bundle. **Done.** See above.

> (D) Strengthen fuzzy RDD presentation. **Done.** See above.

> (E) Add pre-treatment falsification more systematically. **Done.** Dynamic RDD added for information-sector and construction outcomes.

> (F) Infrastructure-specific heterogeneity (power, fiber). **Partially addressed.** We add crude proxies where available; full treatment deferred to future work.

---

## Reviewer 2: Grok-4.1-Fast (Minor Revision)

### Format
> Convert Intro enumerate to prose.

**Done.** See response to Reviewer 1.

### Methodology
> No fundamental issues. Stock DC data justified.

**Acknowledged.** We appreciate the positive assessment and have further strengthened the stock-data justification per Reviewer 1's suggestions.

### Literature
> Add Busso, Gregory, and Kline (2014 AER).

**Addressed.** Added to place-based policy discussion.

> Add Roth (2022 JoE) for LRI/discrete RDD refinements.

**Addressed.** Added to methodology discussion.

> Add Aobdia (2020 JoF) for tech firm location elasticities.

**Noted.** We verify this reference and add if confirmed relevant. The low-location-elasticity point for infrastructure-heavy firms is already supported by our discussion of siting fundamentals.

### Writing
> Prose-ify Intro enumerate.

**Done.**

> Note N discrepancy across common-sample parametric tables.

**Addressed.** We add explicit notes explaining sample-size variation across outcomes/bandwidths.

### Constructive Suggestions
> Event-study RDD by DC construction waves.

**Partially addressed.** We investigate EIA-860 dates for time-stamped analysis. Full event-study RDD by construction wave is data-limited but we add what is feasible.

> Interact with state DC incentives (OZ + state effects).

**Noted for future work.** Compiling a state-level DC incentive panel is beyond the scope of this revision but flagged as a promising extension.

> Quantify fiscal costs; spillover to adjacent tracts.

**Noted for future work.** These are valuable extensions that would strengthen the policy implications but require additional data collection.

> Lead Discussion hierarchy earlier (Intro figure).

**Partially addressed.** The hierarchy framing is now introduced more prominently in the Introduction via prose.

> Simulate OZ NPV for DC investor vs. operator.

**Noted for future work.** A calibration exercise would strengthen the mechanism argument. We add a back-of-envelope discussion of investor vs. operator cost shares.

---

## Reviewer 3: Gemini-3-Flash (Conditionally Accept)

### Literature
> Add Kennedy and Wheeler (2022) on OZ investment geography.

**Addressed.** Added to support the discussion of QOF intermediation attenuating investment signals.

### Constructive Suggestions
> Explicitly acknowledge MDE limitations relative to 0.028% base rate.

**Addressed.** We add explicit discussion that the 233% MDE means our design rules out state-level magnitude effects but cannot detect smaller marginal shifts. This is framed as a limitation of the direct-presence outcome.

> First-stage heterogeneity by state (top 5 DC states).

**Addressed.** We add an appendix table showing the first-stage designation jump for top data center states (VA, TX, CA, OH, GA) to examine whether governor discretion varies in policy-relevant geographies.

---

## Summary of Changes

| Category | Action |
|----------|--------|
| Local randomization elevated to co-primary | Major restructuring of results |
| Estimand language tightened (LIC bundle) | Throughout |
| McCrary discussion moved earlier | Section 3/4 restructured |
| Fuzzy RDD unified table | New table format |
| Pre-period falsification expanded | Info-sector, construction |
| Stock-vs-flow discussion | New subsection + EIA dates if available |
| MDE interpretation sharpened | Results + Discussion |
| Literature expanded | 5-7 new references |
| First-stage heterogeneity by state | New appendix table |
| Intro enumerate to prose | Introduction rewritten |
