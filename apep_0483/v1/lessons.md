## Discovery
- **Policy chosen:** UK teacher pay austerity squeeze (2010-2019) — the interaction of nationally-set teacher pay with locally varying private-sector wages creates differential competitiveness shocks across ~150 Local Authorities
- **Ideas rejected:** Academy pay deviation (treatment unobservable in public data), Teach First (already studied by Allen & Allnutt 2017), Training bursaries (severe treatment dilution per Gemini 3.1 Pro review — bursary cohorts are tiny fraction of teaching workforce)
- **Data source:** NOMIS ASHE (verified: 370+ LAs × 29 years), DfE KS4 performance (verified: 150+ LAs × 16 years), DfE SWC teacher vacancies (verified: 14 years)
- **Key risk:** Local economic conditions drive both private wages AND student outcomes directly (gentrification, migration, school composition) — need Bartik IV or panel FE to address
- **Design evolution:** Tri-model panel unanimously recommended upgrading from pure DR-AIPW to DRDID (Sant'Anna & Zhao 2020) — combines doubly robust estimation with panel fixed effects

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok, Gemini, Codex PASS; GPT FAIL on @CONTRIBUTOR_GITHUB placeholder)
- **Top criticism:** Cross-fitted AIPW reveals in-sample RF significance (p=0.037) does not survive out-of-fold estimation (p=0.737) — the most impactful finding of the review cycle
- **Surprise feedback:** All three referees independently flagged the placebo test concern as disqualifying. The failed placebo (p=0.101, similar magnitude to main effect) is the paper's Achilles heel.
- **What changed:** (1) Implemented 5-fold cross-fitted DML-style AIPW — honest result: -0.57 (SE=1.69, p=0.737). (2) Softened all causal language to "association" framing. (3) Added significance stars to Table 2. (4) Improved prose: vivid opening hook (£14.15/hour), reduced table narration, stronger conclusion. (5) Added Chernozhukov et al. 2018 citation for cross-fitting methodology.
