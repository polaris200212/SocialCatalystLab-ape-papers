# Reviewer Response Plan — Round 1

**Paper:** apep_0281 v1
**Date:** 2026-02-13
**Review Status:**
- GPT-5-mini: MINOR REVISION
- Grok-4.1-Fast: CONDITIONALLY ACCEPT
- Gemini-3-Flash: MINOR REVISION

---

## Executive Summary

The reviewers unanimously find the paper well-executed with a credible RDD design and rigorous methodology. All three agree the null result is precisely estimated and policy-relevant. The decision recommendations are positive (Minor Revision × 2, Conditional Accept × 1), indicating the paper is close to publication quality.

The revision strategy focuses on **five feasible improvements** that can be implemented immediately, while acknowledging two major extensions (transaction prices, EUI mechanism tests) that require substantial re-analysis and are better addressed in future work.

---

## Common Themes Across All Three Reviews

### 1. **Add Fuzzy RD (LATE/Wald) Estimate** [FEASIBLE — HIGH PRIORITY]
- **GPT-5-mini:** "strongly recommend (not optional) presenting the fuzzy-RD/2SLS estimate... with appropriate robust inference"
- **Grok-4.1-Fast:** "Wald ratio mentioned for fuzzy RDD context"
- **All reviewers:** Expect first-stage F-statistic explicitly reported

**Action:** Use `rdrobust` with `fuzzy` option to compute LATE estimate and first-stage F-stat. Add as new column in Table 2 or new Panel A showing first stage explicitly.

---

### 2. **Add 95% Confidence Intervals to Table 2** [FEASIBLE — HIGH PRIORITY]
- **GPT-5-mini:** "recommend adding a column or parentheses showing the 95% confidence interval explicitly"
- **Gemini-3-Flash:** "For a null-result paper, the reader's first question is 'how big of an effect can you rule out?' Putting the CIs directly in the table makes this answer immediate."
- **Exhibit Review:** "Add 95% CIs to Table 2"

**Action:** Modify Table 2 to include 95% CI in brackets below standard errors for main estimates.

---

### 3. **Transaction Price Analysis** [NOT FEASIBLE — NOTE AS LIMITATION]
- **GPT-5-mini:** "I encourage adding more direct transaction-price analyses despite low trade volume"
- **Gemini-3-Flash:** "Major Suggestion: Add a column to Table 2... showing the RDD estimate using actual transaction prices"
- **Grok-4.1-Fast:** "Transaction-price IV (sparse but feasible)"

**Status:** This requires re-running the entire RDD analysis on sales data (DOF Rolling Sales), which is sparse near the threshold. The paper already acknowledges this limitation in Section 7.2. A thorough transaction-price analysis would require:
- Filtering sales to arms-length transactions
- Handling sparse trades (likely <200 within bandwidth)
- Constructing repeated-sales indices
- Possibly a separate paper on valuation lags

**Action:** Strengthen the assessed-value-lag discussion in Section 7.2 ("Limitations"). Add a footnote acknowledging that transaction-price analysis is a valuable extension but underpowered with current data.

---

### 4. **Mechanisms: EUI/Energy Performance Tests** [NOT FEASIBLE — NOTE AS LIMITATION]
- **GPT-5-mini:** "test whether EUI or ENERGY STAR scores change differentially across the cutoff over time"
- **Grok-4.1-Fast:** "Test H1 (price-EUI correlation jump above cutoff? Var(log V) discontinuity?)"
- **All reviewers:** Want evidence that benchmarking didn't induce energy investments

**Status:** This requires:
- Merging time-series EUI data from LL84 filings (2017–2023)
- Constructing panel RDD to test whether EUI improves differentially above threshold
- Testing for discontinuity in variance of log value (H1 information revelation)
- Parsing permit data to isolate energy-specific permits (HVAC, lighting, envelope)

The current paper uses cross-sectional assessed values. Adding dynamic EUI analysis would require a panel structure and is beyond the scope of a "feasible revision." This is a natural extension for future work.

**Action:** Expand Discussion (Section 7.2) to explicitly flag EUI dynamics and investment-response heterogeneity as avenues for future research. Acknowledge that the null on property values is consistent with either (a) no information revelation or (b) offsetting effects, and that distinguishing requires direct energy performance data over time.

---

### 5. **Power/MDE Discussion in Main Text** [FEASIBLE — MODERATE PRIORITY]
- **GPT-5-mini:** "please present this calculation succinctly in main text or in a robustness table"
- **All reviewers:** Want explicit statement of minimum detectable effect to contextualize the null

**Action:** Add a short paragraph in Section 6 (Results) or Section 7 (Discussion) stating: "The effective sample of 3,740 buildings and robust SE of 0.059 imply a minimum detectable effect (MDE) at 80% power and 5% significance of approximately 16%. This rules out property value effects comparable to the 15–20% premiums documented for voluntary ENERGY STAR certification (Eichholtz et al. 2010)."

Currently this is buried in Appendix E. Move it to main text immediately after Table 2.

---

## Exhibit Review: Visual Consolidation [FEASIBLE — MODERATE PRIORITY]

The exhibit review (Gemini 3 Flash) provides detailed recommendations to streamline the 13 main-text exhibits:

### Moves to Appendix:
1. **Figure 3** (RDD per sq ft) — "robustness check, Figure 2 already makes the point"
2. **Figure 6** (McCrary density) — "standard validity check, text mention sufficient"
3. **Table 4** (Placebo cutoffs table) — "redundant with Figure 5, keep figure in main text"

### Consolidations:
4. **Table 5 → merge into Table 3 as Panel E** — "keeps all alternative cuts in one place"
5. **Figure 8** (heterogeneity visual) — "redundant with Table 5, remove or move to appendix"

**Action:**
- Move Figure 3, Figure 6, Table 4 to Appendix
- Optionally merge Table 5 into Table 3 (lower priority, preserves current structure if skipped)
- Remove Figure 8 or move to appendix

---

## Prose Review: Minor Polish [FEASIBLE — LOW PRIORITY]

The prose review finds the paper "top-journal ready" with only minor throat-clearing improvements:

1. **Active voice:** "The analysis sample is constructed..." → "I construct the analysis sample..."
2. **Eliminate hedging:** "A concern with any threshold-based RDD is that..." → "Multiple treatments could coincide at the 25,000 sq ft threshold."
3. **Sharpen transitions:** "I briefly consider each mechanism." → "Why does the market ignore the light?"

**Action:** Make 3–5 targeted sentence-level improvements in Introduction, Data, and Discussion sections.

---

## Literature Additions [FEASIBLE — LOW PRIORITY]

All three reviewers suggest adding 2–4 methodological or topical references:

### GPT-5-mini:
- Calonico et al. (2014, 2020) — already cited, ensure in bibliography
- Imbens & Kalyanaraman (2012) — bandwidth selection
- McCrary (2008) — already cited

### Grok-4.1-Fast:
- Cattaneo et al. (2021) — RDD robustness (donut/placebo context)
- Busse et al. (2013) — fuel economy labels null in informed markets (parallels H4)
- Kahn & Kotchen (2017) — green amenities in NYC

### Gemini-3-Flash:
- Fuerst & Wegener (2020) — greenwashing/green lemons in commercial sector

**Action:** Add 3–4 BibTeX entries to `references.bib` and cite them in relevant sections (Introduction for Busse; Literature Review for Fuerst/Kahn; Methodology for Cattaneo).

---

## Prioritized Workstreams

### Tier 1: Critical for Publication (Implement Immediately)
1. **Add fuzzy RD estimate and first-stage F-stat** — Use `rdrobust` fuzzy option, report in Table 2 or new table
2. **Add 95% CIs to Table 2** — Edit table file to include [CI_lower, CI_upper] in brackets
3. **Move MDE/power to main text** — Short paragraph in Section 6 or 7

### Tier 2: Strengthen Contribution (Implement if Time Permits)
4. **Move Figure 3, Figure 6, Table 4 to appendix** — Tighten narrative, reduce main-text exhibits from 13 to 10
5. **Add 3–4 literature citations** — Busse (2013), Cattaneo (2021), Fuerst (2020), Kahn (2017)
6. **Minor prose improvements** — 3–5 sentence-level edits for active voice and clarity

### Tier 3: Major Extensions (Acknowledge as Future Work)
7. **Transaction price analysis** — Requires re-analysis of DOF sales data; note as limitation
8. **EUI mechanism tests** — Requires panel data and dynamic RDD; note as future work
9. **Dynamic RDD by year** — Test for anticipation of LL97/LL88; requires panel PLUTO

---

## Response to Individual Reviewer Concerns

### GPT-5-mini Specific Concerns:
- **Compound treatment (LL88/LL97 anticipation):** Addressed in Section 2.2 and Section 5.3.2. Add explicit statement that LL97 anticipation would bias *toward* negative effect (carbon cap costs), making null conservative.
- **More covariate balance checks:** Already extensive (year built, lot area, age, floors). Adding ownership type/building class would require merging additional datasets; acknowledge as potential extension but not critical given current balance diagnostics pass.
- **Dynamic analysis pre/post 2019:** Requires panel PLUTO; acknowledge as future work.

### Grok-4.1-Fast Specific Concerns:
- **EUI-price correlation test:** See Tier 3; requires time-series energy data.
- **Permit-type analysis:** Current permit count RDD mentioned in Appendix C; drilling into HVAC-specific permits requires re-coding permit descriptions. Acknowledge limitation.

### Gemini-3-Flash Specific Concerns:
- **Heterogeneity by building use (commercial vs mixed-use vs residential):** Good idea; feasible if building class data is in PLUTO. May require recoding and re-running subgroup RDDs. Consider for future revision if time permits.
- **Interpretation of floors discontinuity:** Already addressed in Section 5.3.1 and Section 6.4.2. Reviewers found explanation convincing.

---

## Timeline Estimate

- **Tier 1 (Critical):** 2–3 hours (fuzzy RD, CIs, MDE text)
- **Tier 2 (Strengthen):** 1–2 hours (exhibit moves, literature, prose polish)
- **Total feasible revision:** 3–5 hours

---

## Final Note

This is a **strong revision position**. All three reviewers find the identification credible, the methodology rigorous, and the null result policy-relevant. The requested changes are standard "dotting i's and crossing t's" for top-journal publication:
- Fuzzy RD is a mechanical extension of existing first-stage analysis
- 95% CIs are already computed by `rdrobust`, just need to be added to table
- MDE discussion exists in appendix, just needs to move to main text
- Exhibit consolidation is purely editorial

The two "major extensions" (transaction prices, EUI dynamics) are appropriately deferred to future work with a clear explanation of why they require substantial re-analysis beyond the scope of this revision.
