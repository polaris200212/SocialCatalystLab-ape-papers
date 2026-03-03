## Discovery
- **Policy chosen:** Help to Buy Equity Loan 2021 regional price caps — 9 simultaneous cap thresholds replacing a uniform £600K cap create a natural multi-cutoff bunching/RDD experiment. Unanimous PURSUE from tri-model panel (74/85/78).
- **Ideas rejected:** (1) Flood zone spatial RDD — compelling mechanism decomposition but postcode centroid measurement error at boundaries is near-fatal for spatial RDD; all three models flagged this. (2) SDLT holiday temporal RDD — unanimously SKIP due to saturated literature and COVID confounds.
- **Data source:** HM Land Registry Price Paid Data — confirmed accessible, ~132K new builds/year, new-build flag in column 6, postcode for regional assignment. URL updated from old S3 to new CloudFront domain.
- **Key risk:** Interpreting bunching without individual HTB take-up data. Mitigated by second-hand property placebo (should show no bunching at HTB caps) and London placebo (cap unchanged).

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT, Grok, Codex PASS; Gemini FAIL on London £2K bin and spatial RDD)
- **Top criticism:** DiB at £600K showed bunching persisting in non-London regions (especially Yorkshire +2.562), contradicting the initial "disappeared" claim. Required complete rewrite of DiB section to honestly present mixed results and emphasize triple-difference design.
- **Surprise feedback:** The i.i.d. bootstrap concern from GPT-5.2 — cluster bootstrap by development/postcode would be more appropriate but development identifiers unavailable in Land Registry data.
- **What changed:** (1) Rewrote DiB section to honestly present heterogeneous results; (2) Added triple-difference column to Table 5 with SEs; (3) Narrowed incidence claim from "25%" to "15-35% range"; (4) Removed "Design 3" framing for spatial RDD; (5) Added bootstrap clustering caveat; (6) Removed empty appendix promises; (7) Strengthened opening hook per prose review.

## Summary
- **Policy:** Help to Buy 2021 regional cap reform — 9 simultaneous price thresholds
- **Key strength:** Multi-cutoff replication with built-in placebos (second-hand, pre-reform, post-scheme)
- **Key limitation:** DiB at £600K contaminated by round-number pricing in lower-priced regions
- **Lesson for future:** Be honest about mixed results early — the honest framing was stronger than the original overclaim
