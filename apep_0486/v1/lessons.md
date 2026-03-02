## Discovery
- **Policy chosen:** Progressive district attorney elections (~30 US counties, 2014-2022) — staggered timing, first-order stakes (crime, incarceration, racial equity), clear institutional variation.
- **Ideas rejected:** (1) Spatial spillovers — implausible mechanism for incarceration displacement, urban/rural border asymmetry; (2) Charge channel DDD — data infeasibility (city Socrata portals inconsistent); (3) Economic activity — causal chain too long, COVID confounding in retail/food; (4) Generic "progressive DA → crime" — already saturated (Agan et al. 2025, Petersen et al. 2024).
- **Data source:** Vera Institute Incarceration Trends (GitHub, confirmed download) + County Health Rankings (confirmed download) + Census ACS API. FBI CDE API is non-functional for crime data.
- **Key risk:** COVID/2020 confounding — many progressive DAs took office during the pandemic-era homicide surge. Mitigated by pre-COVID cohort restriction and cohort-specific event studies.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex PASS; Gemini persistent FAIL on homicide data-design)
- **Top criticism:** TWFE vs CS-DiD divergence (-179 vs -406) was universally flagged; control group credibility (25 urban vs 2,780 rural)
- **Surprise feedback:** Gemini consistently flags the homicide always-treated issue even after extensive text clarification; GPT caught missing Appendix D.1 cross-reference
- **What changed:** Rewrote abstract/intro to make CS-DiD primary estimand; added HonestDiD table; added pretrial mechanism paragraph; added control group comparability discussion; strengthened treatment coding criteria; added sample construction/missingness appendix; toned down all homicide claims to "inconclusive"; removed cost-benefit over-claims

## Summary
- **Policy chosen:** Progressive prosecution (progressive DAs) — rich staggered adoption variation (25 counties, 2015-2023), timely policy question
- **Ideas rejected:** Medicaid expansion, minimum wage, marijuana legalization (all well-studied)
- **Data source:** Vera Institute jail data (2005-2023) + CHR homicide (2019-2024) + ACS demographics
- **Key methodological concern:** Short homicide panel + COVID confounding made safety claims structurally weak; the homicide analysis is the paper's acknowledged Achilles heel
