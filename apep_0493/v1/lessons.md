## Discovery
- **Policy chosen:** Council Tax Support localisation (April 2013) — sharp quasi-experimental variation across 326 English LAs in benefit conditionality, virtually no peer-reviewed causal literature
- **Ideas rejected:** Apprenticeship Levy (Bartik concerns, simultaneous standards reform), Enterprise Zones (only 48 zones, well-trodden), Benefit Cap (confounded with CTS reform timing), UC in-work conditionality (annual data too coarse, UC literature crowded)
- **Data source:** NOMIS claimant count (monthly, LA-level, back to 1986) + DLUHC council taxbase LCTS data + DLUHC collection rates. All freely downloadable.
- **Key risk:** Treatment variable (minimum payment %) not in a single downloadable file — must construct from DLUHC taxbase changes or request from Entitledto. Fallback to binary (cut vs protected) is well-documented.

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok, Gemini, Codex; GPT failed on placeholder metadata)
- **Top criticism:** Pre-2020 subsample renders all results insignificant — COVID drives the statistical power
- **Surprise feedback:** GPT caught genuine N mismatches in donut/placebo sample sizes (hand-typed in LaTeX didn't match code output)
- **What changed:** Added pre-2020 subsample (both insignificant), quadratic trends (insignificant), expanded UC rollout discussion, honest reframing of results and abstract

## Summary
- **Strongest finding:** Sign reversal between naive TWFE (-0.156***) and LA-trends (+0.152**) is methodologically interesting, but pre-2020 insignificance limits causal claims
- **Key lesson:** When the post-treatment window includes COVID, ALWAYS run pre-2020 subsample as primary robustness check
- **Data lesson:** Fuzzy name-matching between NOMIS and DLUHC dropped 50 LAs (15%); official crosswalk would be better
- **Table lesson:** Hand-typed regression table values in LaTeX diverged from code output; always verify every number
