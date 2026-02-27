## Inherited from parent
- v1 used IPUMS 1% samples as pooled cross-sections; HISTID not available in 1% samples
- State-level first-difference design following AAL (2004) was statistically robust (RI p < 0.001, all 49 LOO betas negative)
- Triple-diff on pooled cross-sections is NOT within-person — it's just stacked different people

## Discovery (v2)
- **Key insight:** HISTID is only available in IPUMS full-count (100%) databases, not 1% samples
- **Data source:** IPUMS extract #195 — full-count 1930/1940/1950 with HISTID (~400M records)
- **Key risk:** Linkage rate across censuses may be low; need to assess selection into linking
- **Pivot:** IPUMS extract timed out; used Census Linking Project (CLP) crosswalks from Harvard Dataverse instead — pre-computed ABE links, much faster

## Review (v2)
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex — after 8 attempts)
- **Top criticism:** Decomposition framing as formal identity when populations differ (all women vs married wives) — required complete rewrite of Section 5 as "comparison" not "identity"
- **Surprise feedback:** Wife identity verification (same wife in 1940 vs 1950?) was a strong GPT concern — resolved with age consistency check (85.9% pass rate, coefficient unchanged)
- **What changed:** Added wild cluster bootstrap (p < 0.001), non-mover couples check (88.1%, beta = +0.0079), reframed decomposition, softened causal language
- **Key lesson:** With 49 clusters, always provide wild bootstrap from the start — reviewers will flag state-clustered SEs as insufficient
- **External reviews:** 1 MAJOR (GPT), 2 MINOR (Grok, Gemini) — all constructive, no fatal flaws
