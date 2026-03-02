## Discovery
- **Policy chosen:** Universal Credit full service rollout (2015-2018) — genuinely staggered across 300+ LAs with month-level precision from DWP published schedule
- **Ideas rejected:** Brexit immigration shock (severe COVID confound), Council Tax Support localisation (IFS published comprehensive null result Jan 2026), NLW geographic bite (single treatment date, existing literature), Scotland devolved employment services (N=2 nations, underpowered)
- **Data source:** Companies House bulk CSV (firm formation by postcode) + NOMIS APS (self-employment rates by LA) — both confirmed accessible and working
- **Key risk:** UC rollout order may correlate with LA characteristics (IT readiness, deprivation). Need careful pre-trend testing and robustness to selection-on-observables.

## Review
- **Advisor verdict:** 4 of 4 PASS (after 5 rounds of fixes)
- **Top criticism:** Outcome mismatch — Companies House captures limited companies but UC self-employed are mostly sole traders. All three referees flagged this as the central validity threat.
- **Surprise feedback:** GPT-5.2 gave MAJOR REVISION while Grok and Gemini gave MINOR — the key divergence was whether the MIF timing test and treatment measurement issues were "must-fix" or acceptable limitations. Also surprising: the MIF test was most harshly criticized despite being framed as a novel contribution.
- **What changed:** Reframed MIF test as "exploratory" throughout; added formal attenuation calculation showing individual-level effects <33% are undetectable; added treatment measurement discussion for multi-jobcentre LAs; tempered "precisely estimated null" language; added 95% CI to tables; added spillover discussion; renamed high-formation LAs from "placebo" to "heterogeneity"; added Roth et al. (2023) and Borusyak et al. (2024) citations.
