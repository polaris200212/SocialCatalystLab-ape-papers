## Discovery
- **Policy chosen:** Germany's MMP electoral system (list vs district mandates) — provides within-parliament variation in institutional dependence on party, which is the key mechanism channel for gender differences in party discipline.
- **Ideas rejected:** Brazil (female representation too low, 8-18%, insufficient power; 2009 quota reform muddied by "laranja" dummy candidates); European Parliament (gender data not native to voting datasets, dual loyalty complicates party-line definition); South Korea (data primarily in Korean, no English-language dataset infrastructure).
- **Data source:** BTVote V2 on Harvard Dataverse — gold-standard academic dataset with 1.1M individual votes, gender, mandate type, party, policy area all pre-coded. Three linked datasets downloadable as tab-delimited files.
- **Key risk:** Roll-call vote selection bias — RCVs are ~5% of all Bundestag votes and strategically requested by opposition. Gender × mandate type interaction could be an artifact of which votes become RCVs. Mitigation: test robustness to dropping opposition-initiated RCVs; analyze free votes separately.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex pass; Gemini fail on false positives about interaction model coefficients)
- **Top criticism:** GPT referee argued the DDD is not truly causal — only descriptive within party-period cells. RDD has selection concern (losers only observed if list-safe). Both valid.
- **Surprise feedback:** RI p-value (0.028) rejects sharp null even on preferred spec, while asymptotic p-value is 0.50. Discrepancy driven by highly skewed binary outcome (1.6% mean).
- **What changed:** Reframed DDD as descriptive decomposition; added rdrobust with signed running variable; reconciled District sign flip; added preferred-spec RI; added EP literature (Hix et al. 2005)

## Summary
- **Key lesson:** "Precisely estimated null" papers need especially careful framing — the null IS the finding
- **Data lesson:** BTVote V2 is excellent for legislative behavior research — clean, large, well-documented
- **Method lesson:** LPM with 1.6% mean outcome creates RI vs asymptotic inference discrepancy due to non-normal residuals
