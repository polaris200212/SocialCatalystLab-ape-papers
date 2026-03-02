# Revision Plan — Round 1

**Date:** 2026-02-25
**Paper:** apep_0455 — Vacancy Taxes and Housing Markets: Evidence from France's 2023 TLV Expansion
**Reviews received:** GPT-5.2 (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Major Revision)

---

## Summary of Reviewer Feedback

All three reviewers praised the policy question, large administrative dataset, and clean single-cohort design. Key concerns centered on:

1. **COVID pre-trend contamination** (all three) — 2020 shows differential tourism shock
2. **Transaction-level price composition** (GPT, Grok) — No hedonic controls in transaction regressions
3. **2025 partial-year bias** (Gemini, Grok) — Treated tourism communes may have differential seasonality
4. **Zero-transaction commune-years excluded** (GPT) — Volume estimate is conditional
5. **Matched sample outlier** (all three) — 8.4% matched estimate vs 1.2% baseline
6. **External validity** (GPT, Gemini) — 87% tourism communes ≠ typical vacancy tax target

## Revision Actions

### Completed

1. **Hedonic-controlled transaction-level regressions** (Section 6.5.6)
   - Added log(surface), property type, rooms as controls
   - Result: 3.7% → 3.7% (unchanged), confirming observable composition is not driving the estimate

2. **Restricted pre-period specification** (Section 6.5.7)
   - Dropped 2020 COVID year, using 2021–2025 only
   - Result: Price null strengthens (0.5%, p=0.48), volume decline strengthens (-7.3%***)

3. **2024-only specification** (Section 6.5.8)
   - Dropped partial 2025
   - Result: Price 1.1% (p=0.17), Volume -4.0%***, TX-level 3.6%***

4. **Expanded matched sample discussion** (Section 6.5.4)
   - Explained why 8.4% divergence is a matching failure, not evidence of large effect
   - Noted entropy balancing/SDID as better alternatives

5. **Zero-transaction limitation** (Section 7.6)
   - Explicitly discussed conditional nature of volume estimate
   - Noted Poisson PML as appropriate extension

6. **External validity framing** (Section 8)
   - Sharpened to "second-home markets in high-amenity areas" rather than vacancy taxes broadly

### Deferred to Future Work

- Monthly/quarterly event study around August 25 announcement
- Triple-diff with always-treated communes
- Border/ring-based spillover analysis
- Lee (2009) bounds on price estimates
- Rental market data (SeLoger/Leboncoin)
- Choropleth map replacing bar chart
- Wild cluster bootstrap / Conley spatial SEs
- Stratified randomization inference

## Verification

All new R results run successfully (04_robustness.R updated with sections 7-9). Paper recompiled to 38 pages, no undefined references.
