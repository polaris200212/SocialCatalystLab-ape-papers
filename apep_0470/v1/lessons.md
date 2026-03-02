## Discovery
- **Policy chosen:** Tennessee Valley Authority (1933) — the most ambitious place-based program in US history. Famous economics literature (Kline & Moretti 2014 QJE) exists but used only county-level aggregates. No paper has used individual-level linked census microdata.
- **Ideas rejected:** (1) "Electrification dividend" gender-only paper — too narrow, subsumed by main idea. (2) Intergenerational children-only paper — also subsumed as a section. Both backup ideas scored lower in ranking.
- **Data source:** IPUMS MLP v2.0 (July 2025) — links 175M people across 1850-1950 censuses with 645M cross-census links. Version 2.0 added women's linking via XGBoost + Numident, making gender analysis credible for the first time.
- **Key risk:** Census linking has known selection bias (literate, native-born, male individuals link better). Lower match rates for Black and female individuals in historical censuses could bias heterogeneity estimates. Mitigation: IPW, Lee bounds, linked vs. unlinked comparison, conservative vs. standard linkage robustness.
- **Pivot:** MLP crosswalk was unavailable via IPUMS API; fell back to county-level repeated cross-sections (IPUMS 1% samples). This actually worked well — county aggregation sidesteps linking bias entirely.

## Review
- **Advisor verdict:** 3 of 4 PASS (Grok, Gemini, Codex). GPT failed on sample size wording (cosmetic, not substantive).
- **Referee decisions:** GPT MAJOR REVISION, Grok MINOR REVISION, Gemini MINOR REVISION.
- **Top criticism:** GPT's concern about treatment definition (using all 16 dam sites including 9 completed after 1940 in the distance measure). Addressed with ITT framing and explicit dam timing defense paragraph.
- **Surprise feedback:** The Holm-Bonferroni correction table was a double-edged sword — it showed transparency but all three reviewers flagged that analytical p-values don't survive correction (mfg p_adj=0.240). The resolution: non-parametric methods (RI, bootstrap) are more appropriate for the few-cluster setting and strongly reject the null.
- **What changed in Stage C:**
  - RI p-value corrected from <0.001 to 0.002 throughout (500 permutations + 1 correction)
  - Added gradient pre-trend validation (all three outcomes insignificant: mfg p=0.42, ag p=0.63, SEI p=0.97)
  - Added population-weighted estimates (mfg stronger: 0.016, p=0.02; ag stronger: -0.030, p=0.006)
  - Softened mechanism language ("consistent with" rather than "identifies")
  - Expanded migration section with quantitative composition analysis
  - Added explicit Limitations paragraph in Discussion
  - Cleaned all table variable labels per exhibit review
  - Punched up opening sentence per prose review

## Summary
- **What worked:** Historical IPUMS data + county-level DiD + distance gradient is a powerful combination. The triple-difference by race/gender is the paper's core contribution and survived scrutiny. The spatial decay pattern (strong within 50-150km, zero beyond 200km) is robust and distinguishes local from regional channels.
- **What didn't:** The Holm correction exposed the tension between conventional and non-parametric inference. Future papers in few-cluster settings should lead with non-parametric methods from the start.
- **Key lesson:** When using all planned/authorized infrastructure sites (not just completed ones), frame as ITT upfront, not as a defense after reviewers flag it. The ITT framing is actually stronger — it captures the full policy footprint.
