## Discovery
- **Policy chosen:** 2019 FOBT stake cut (£100→£2) — mass betting shop closures with zero causal economics literature, clear national shock with predetermined cross-sectional exposure, and theoretically ambiguous effects (belief-changing potential)
- **Ideas rejected:** Pub closures (severe endogeneity, no clean shock), Scotland MUP border (power concerns, tiny border sample), Flood events (crowded literature, measurement challenges)
- **Data source:** Gambling Commission LA Statistics (free Excel, 329 LAs, 2015-2025) + Police API bulk crime + Land Registry PPD + NOMIS — all confirmed accessible and free
- **Key risk:** Pre-trends may not hold unconditionally because betting shops concentrate in deprived areas with different crime trajectories. DR conditioning on deprivation/demographics is the mitigation, but if conditional parallel trends also fail, the paper weakens significantly.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT PASS, Grok PASS, Codex PASS, Gemini FAIL — false positive on "future-dated" data due to model knowledge cutoff)
- **Top criticism:** Post-treatment measurement of density variable — all 3 referees flagged this as the #1 design flaw. Cannot be fixed without historical GC data.
- **Surprise feedback:** GPT-5.2 gave REJECT AND RESUBMIT while other two gave MAJOR REVISION. GPT was particularly harsh on property price causal claims, wanting formal event study regression. The severity difference is notable.
- **What changed:** (1) Removed "first causal estimates" claim, replaced with "first systematic empirical examination". (2) Systematically calibrated all property price language from "unambiguous" to "precisely estimated association with caveats". (3) Collapsed Data section into flowing prose. (4) Promoted balance table to main text. (5) Added multiple testing caveat. (6) Moved dose-response to appendix. (7) Acknowledged treatment proxy limitation as "most important data limitation."

## Summary
- **Policy:** UK 2019 FOBT stake cut (£100→£2) — a rare natural experiment from betting regulation
- **Key finding:** Crime result is an honest null (pre-trends, placebo failures); property prices show precisely estimated slower growth in high-density areas
- **Methodological lesson:** Using post-closure registers as treatment proxies is a fundamental limitation that all reviewers caught. Future work with historical licensing data is essential.
- **Process lesson:** 6 advisor rounds needed to pass — most issues were text-number consistency rather than substantive. The Gemini advisor has a structural false-positive for "future-dated" data when the paper uses data beyond its training cutoff.
