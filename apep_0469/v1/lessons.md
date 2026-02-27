## Discovery
- **Policy chosen:** WWII military mobilization (1941-1945) — largest exogenous labor market shock in US history with county-level variation in intensity
- **Ideas rejected:** Born Under Rosie (MLP ends 1950, children too young for adult outcomes); Marriage Market standalone (US WWII mortality too small for standalone sex-ratio paper; integrated as mechanism chapter); Great Reshuffling standalone (defense placement endogeneity too hard to crack alone)
- **Data source:** IPUMS MLP 1930-1940-1950 linked censuses (HISTID); CenSoc WWII Army Enlistment (9M records, county FIPS); Jaworski (2017) county war production (OpenICPSR 140421)
- **Key risk:** Exclusion restriction for mobilization — abandoned agricultural IV in favor of directly observed treatment + rich pre-trend validation using 1930-1940 wave. Gemini reviewer rightly flagged that US WWII mortality (~400K) is too small for "selective mortality" to be THE story — reframed as decomposition of within-person changes vs compositional shifts broadly.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex pass; Gemini fail on minor interpretation issues). Took 6 rounds to clear the gate — most issues were text-table inconsistencies.
- **Top criticism:** Triple-diff magnitude (-0.284) seems too large vs state-level (-0.0073); selection-on-observables not credible for causal claims; baby boom confound unaddressed.
- **Surprise feedback:** HC3 SEs are *smaller* than IID (0.0025 vs 0.0029). Randomization inference p < 0.001 despite bootstrap CI touching zero. All 49 leave-one-out betas are negative.
- **What changed:** Added RI, HC3, LOO, ANCOVA. Softened causal language. Added 4 citations (Rambachan & Roth, Cameron et al., Bound & Turner, Conley & Taber). Cleaned table names. Improved prose per exhibit/prose review.

## Summary
- **Final length:** 41 pages
- **Key insight:** Result is statistically robust (RI p < 0.001, LOO all negative) but identification is fragile (Oster δ = -0.37, balance test rejects). Paper's contribution is honest documentation of this tension.
- **Process lesson:** Always verify text against actual model objects. Never transcribe coefficients by hand — extract from saved .rds models. Six rounds of advisor review mostly fixed text-table mismatches.
