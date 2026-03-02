## Discovery
- **Policy chosen:** Action Cœur de Ville (ACV) — €5B French program targeting 222 medium-city centers with zero causal evaluations in the literature. Scored 78/100 by GPT-5.2 ranking.
- **Ideas rejected:** (1) Permis de Louer — no centralized adoption date dataset, massive outcome dilution. (2) DPE Energy Penalty — July 2021 DPE reform confound + only 1 year pre-treatment with DVF. (3) Rent Control + Firm Creation — only 9 treated territories, fails ≥20 cluster rule.
- **Data source:** INSEE Sirene (establishment registry, full history since 1973) — pivoted from DVF after discovering it only covers 2020H2+, insufficient for pre-2018 trends. ACV commune list from data.gouv.fr with 244 communes and convention dates.
- **Key risk:** ACV cities were selected because they were declining — parallel trends assumption requires strong event-study diagnostics and HonestDiD sensitivity. Also, ACV is a bundled policy package (ACV + ORT + Denormandie), making it impossible to isolate individual components.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT FAIL, Grok/Gemini/Codex PASS) — took 5 rounds due to treatment definition inconsistencies (244 vs 222), PSM language contradictions, and HonestDiD/CS claims without supporting output
- **Top criticism:** GPT referee identified that commune-level outcome does not measure "downtown" effects; sectoral proxy is insufficient for the paper's central claim about city-center revitalization
- **Surprise feedback:** Pre-trend F-test p=0.055 — just barely passing at 5% level, need to report honestly
- **What changed:** (1) Added PPML robustness for zero-heavy counts, (2) Rewritten control group section with replicable matching algorithm, (3) New subsection on announcement vs implementation timing, (4) Expanded spillover and outcome dilution discussions, (5) Softened all claims from "downtown revitalization" to "commune-level entry in downtown-facing sectors", (6) Promoted Figure 6 to main text, (7) Added Kline & Moretti 2014, Ahlfeldt et al. 2015, Silva & Tenreyro 2006

## Summary
- **Policy:** France's Action Cœur de Ville (ACV) — €5B downtown revitalization for 222 medium-sized cities
- **Finding:** Precisely estimated null on commune-level establishment creation in downtown-facing sectors
- **Method strength:** Common treatment timing avoids staggered DiD pitfalls; 24 pre-treatment quarters; RI and PPML robustness
- **Key limitation:** Commune-level outcome dilutes potential city-center effects; cannot measure intensive margin
- **Lesson for future:** When studying place-based policies targeting sub-municipal areas, geocoding is essential for credible "downtown" claims
