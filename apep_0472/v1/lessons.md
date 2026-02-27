## Discovery
- **Policy chosen:** Selective licensing of private rented housing (Housing Act 2004 Part 3) — staggered LA adoption since 2007 with 30+ treated units, genuinely novel crime/displacement angle, LOW NBER overlap
- **Ideas rejected:** Flood Re (HIGH lit overlap with US flood-property papers despite novel UK eligibility design); CIGA zombie firms (national policy, no staggering for DiD); Clean Air Zones (too few treated units <10); PDR Article 4 (borderline 20 units, endogenous adoption); Alcohol CIPs (75+ LAs but Bristol group has first-mover advantage)
- **Data source:** UK Police API (LSOA × month crime data, confirmed working), HM Land Registry PPD (24M+ transactions, confirmed), NOMIS (LA-level covariates, confirmed)
- **Key risk:** Endogeneity of licensing adoption — LAs adopt BECAUSE of crime problems. Mitigation: event-study pre-trends, CS-DiD with not-yet-treated controls, HonestDiD sensitivity.

## Execution
- **Memory constraints:** 16GB RAM limit hit 3 times parsing police bulk data; solved by discovering archives are cumulative (not monthly) and using only latest archive
- **Crime category names:** API uses Title Case ("Anti-social behaviour") not hyphenated-lowercase — caused silent data loss in category matching
- **Population data:** NOMIS API failed silently (empty response); created approximate data manually
- **modelsummary API change:** `output="latex"` now returns tinytable object, not character string — must use `output=file_path` instead
- **Panel balancing (CRITICAL):** Police API only reports LSOA-months with ≥1 crime. Initial panel had 1,090,991 obs vs expected 1,150,092 balanced (5.1% gap). Balancing with structural zeros changed all results — borough-wide coefficient flipped from +1.78*** to -0.001. Always construct full balanced grid for crime data.
- **Key finding:** Null aggregate effect (CS-DiD ATT = +0.50, p>0.25) with striking category heterogeneity — ASB increases (+0.32) while violence (-0.59), public order (-0.24), vehicle crime (-0.13) decrease significantly
- **Honest results:** Paper rewritten to present null honestly rather than overselling borderline TWFE result — stronger paper for it

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok, Gemini, Codex) after 10 iterations
- **Top criticism:** Panel conditioning on positive crime changed the estimand. Balancing the panel was the single most important fix.
- **Surprise feedback:** Borough-wide subsample result completely flipped after balancing — old positive coefficient was artifact of selection bias
- **What changed in revision:** (1) Balanced panel with structural zeros; (2) C&S estimate in Table 2; (3) Holm corrections for multiple testing; (4) Leave-one-out sensitivity; (5) TWFE contamination narrative fixed; (6) "Waterbed" reframed as categorical displacement
- **Referee feedback:** GPT=Major, Grok=Minor, Gemini=Minor. Common requests: spatial displacement test (deferred — needs boundary data), C&S at LSOA-month (computationally infeasible), weapons placebo (addressed with Region×Month FE)
