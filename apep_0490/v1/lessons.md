## Discovery
- **Policy chosen:** arXiv daily submission cutoff at 14:00 ET — creates a sharp discontinuity in listing position that has never been exploited with modern RDD methods
- **Ideas rejected:** Multi-platform comparison (SSRN/bioRxiv lack precise timestamps), GitHub Trending (no public historical data), standalone topic diffusion (too noisy for standalone)
- **Data source:** arXiv Atom API / Kaggle bulk metadata (exact HH:MM:SS timestamps confirmed) + OpenAlex (citations, affiliations, career trajectories). Download counts NOT available from arXiv.
- **Key risk:** Strategic bunching at the cutoff — sophisticated authors (especially at top AI labs) know the 14:00 ET rule and time submissions. McCrary density test is the gating diagnostic.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex; Gemini FAIL) — required 6 rounds
- **Top criticism:** Statistical power too low to detect plausible moderate effects (20-30%); MDE ~170% renders null uninformative for policy-relevant effect sizes
- **Surprise feedback:** Treatment bundle (position + delay) interpretation was flagged by all reviewers as under-discussed; day-of-week heterogeneity as a test of delay costs was a creative suggestion
- **What changed:** Reframed all null-effect language to "rules out large effects"; added MDE to Table 2; added bundling discussion paragraph; strengthened limitations on sample coverage and match rates; moved heterogeneity table to appendix

## Summary
- **Policy:** arXiv daily submission cutoff and listing position effects on AI/ML citations
- **Method:** Sharp RDD (rdrobust, MSE-optimal bandwidth)
- **Key finding:** Null result — no detectable large effects, but underpowered for moderate effects
- **Biggest challenge:** Iterative advisor review (6 rounds) due to cascading consistency issues
- **Lesson learned:** Fixing one advisor issue often exposes or creates another; need comprehensive consistency pass before each round
