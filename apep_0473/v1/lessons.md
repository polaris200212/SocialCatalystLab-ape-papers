## Discovery
- **Policy chosen:** Universal Credit Full Service rollout (2015-2018) — staggered across ~643 JCPs/325 LAs, genuinely novel for employment composition analysis
- **Ideas rejected:** Benefit Cap (small treated population, continuous treatment intensity risk), Council Tax Support (simultaneous adoption, not truly staggered), LA austerity (continuous treatment, endogenous allocation), Apprenticeship Levy (national policy, no geographic staggering)
- **Data source:** NOMIS APS (quarterly LA-level employment/self-employment) + DWP rollout schedule (public) + Claimant Count (monthly)
- **Key risk:** APS estimates have wide CIs for small LAs; rollout timing may not be fully exogenous (operational readiness correlated with LA characteristics)

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok, Gemini, Codex; GPT FAIL on control group identification)
- **Top criticism:** GPT raised legitimate concern about short identified post-treatment horizon with not-yet-treated controls (only 1-2 years of exposure identifiable). Addressed by explicit documentation.
- **Surprise feedback:** Codex caught region_id[year] syntax issue (varying slopes vs interaction FEs). Within R² of 6.53e-5 flagged by Gemini as suspicious but is correct for null treatment effect.
- **What changed:** Added CS identification detail, exact-match robustness check, dose dilution calculation, softened conclusions. Fixed ~10 numerical inconsistencies across 6 rounds of advisor review.

## Summary
- **Key lesson:** NOMIS variable labels can be misleading (var 18 = economic activity rate, not unemployment rate). Always verify variable definitions against ONS documentation.
- **Discovery insight:** UK local authority data from NOMIS/APS provides decent panel for staggered DiD but APS is survey data with sampling error at LA level. Administrative data would be stronger.
- **Method note:** Callaway-Sant'Anna with not-yet-treated controls loses identification quickly when all units eventually treated in short window. Consider quarterly data or never-treated controls if available.
