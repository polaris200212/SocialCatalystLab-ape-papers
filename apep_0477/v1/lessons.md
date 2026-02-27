## Discovery
- **Policy chosen:** UK EPC band labeling system + MEES rental regulation — chosen because the multi-cutoff RDD design uniquely decomposes information vs regulation vs salience, filling a clear gap (no UK RDD at EPC boundaries exists).
- **Ideas rejected:** ULEZ spatial RDD (boundary = major road, classic pre-existing barrier confound); Business Rates Relief (address matching noise, valuation manipulation); Flood Re construction date RDD (noisy running variable, GFC confound); Cladding crisis 18m threshold (building-level data not publicly available from DLUHC).
- **Data source:** EPC register (30M certificates, bulk download) + Land Registry PPD (24M transactions) linked via postcode/address. Both confirmed accessible and free.
- **Key risk:** Assessor bunching at EPC band boundaries could invalidate standard RDD — addressed by treating bunching as mechanism evidence (Kleven estimators) + donut RDD + pre/post-MEES comparison.

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok + Gemini + Codex; GPT failed on placeholders only). Required 10 rounds to achieve.
- **Top criticism:** Cross-cutoff decomposition is not credibly identified; use within-cutoff tenure comparison as primary identification instead
- **Surprise feedback:** All three referees flagged postcode matching as a serious concern — a feature we treated as a minor limitation is actually central to credibility
- **What changed:** Reframed decomposition to use C/D-only benchmark; added caveat about cross-cutoff assumption; moderated "information is zero" claims; added postcode matching discussion; added pre-MEES anticipation discussion

## Summary
- **Key lesson:** For RDD papers, the matching/running variable measurement strategy is as important as the design itself. Postcode-level matching is a genuine limitation that reviewers immediately identify.
- **What worked:** Owner-occupied placebo at E/F is the paper's strongest card — all reviewers praised it. Multi-cutoff design provides natural placebos.
- **What would improve:** UPRN matching, formal diff-in-disc framework, clustering-robust inference.
